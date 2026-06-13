extends RefCounted
class_name CombatResolveFlowCoordinator

const CALLBACK_PLAY_SFX := "play_sfx"
const CALLBACK_SYNC_TIMER_DISPLAY := "sync_timer_display"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_SET_INPUT_PHASE := "set_input_phase"
const CALLBACK_BIND_MASTERY_PREVIEW := "bind_mastery_preview"
const CALLBACK_PLAY_RESOLVE_ANIMATIONS := "play_resolve_animations"
const CALLBACK_CAN_CONTINUE := "can_continue"
const CALLBACK_BIND_TURN_RESOLUTION := "bind_turn_resolution"
const CALLBACK_INPUT_PHASE_VALUE := "input_phase_value"
const CALLBACK_APPLY_BOARD_MODEL := "apply_board_model"
const CALLBACK_RESOLVE_TRACE := "resolve_trace"
const CALLBACK_STORE_LAST_RESOLVE_RESULT := "store_last_resolve_result"

var _model: Variant = null
var _board_controller: Variant = null
var _board_view: Variant = null
var _board_model: BoardModel = null
var _resolver: Variant = null
var _mastery_preview_coordinator: Variant = null
var _turn_resolution_coordinator: Variant = null
var _combat_modifiers: Dictionary = {}
var _callbacks: Dictionary = {}
var _player_input_phase_value := 0
var _resolving_input_phase_value := 1
var _timer_state_locked := "locked"
var _status_color_warning := Color(1.0, 0.86, 0.54, 1.0)


func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_model = dependencies.get("model")
	_board_controller = dependencies.get("board_controller")
	_board_view = dependencies.get("board_view")
	_board_model = dependencies.get("board_model")
	_resolver = dependencies.get("resolver")
	_mastery_preview_coordinator = dependencies.get("mastery_preview_coordinator")
	_turn_resolution_coordinator = dependencies.get("turn_resolution_coordinator")
	_combat_modifiers = dependencies.get("combat_modifiers", {})
	_callbacks = callbacks.duplicate()
	_player_input_phase_value = int(config.get("player_input_phase_value", _player_input_phase_value))
	_resolving_input_phase_value = int(config.get("resolving_input_phase_value", _resolving_input_phase_value))
	_timer_state_locked = String(config.get("timer_state_locked", _timer_state_locked))
	_status_color_warning = config.get("status_color_warning", _status_color_warning)


func end_drag(drag_result: Dictionary) -> void:
	if _input_phase_value() != _player_input_phase_value:
		return
	if _board_controller == null:
		return
	if not bool(drag_result.get("handled", false)):
		return
	var timed_out := bool(drag_result.get("timed_out", false))
	_call(CALLBACK_PLAY_SFX, ["drop"])
	_call(CALLBACK_SYNC_TIMER_DISPLAY, [0.0, _timer_state_locked])
	var move_end_reason := "timer expired" if timed_out else "released"
	_call(CALLBACK_SET_STATUS_TEXT, ["Move ended: %s. Locking input for resolve phase." % move_end_reason])
	_call(CALLBACK_SET_STATUS_COLOR, [_status_color_warning])
	var resolve_trace_origin_usec := Time.get_ticks_usec()
	_model.begin_resolve_trace(resolve_trace_origin_usec, true)
	_trace(resolve_trace_origin_usec, 'phase=resolve_start move_end_reason="%s" board_seed=%d' % [move_end_reason, _board_model.rng_seed])
	_board_controller.reset_visuals()
	_board_controller.clear_board_presentation()
	_call(CALLBACK_SET_INPUT_PHASE, [_resolving_input_phase_value])
	_call(CALLBACK_BIND_MASTERY_PREVIEW)
	if _mastery_preview_coordinator != null:
		_mastery_preview_coordinator.reset(_combat_modifiers)
	var resolve_models: Dictionary = _board_controller.prepare_visual_model_for_resolve()
	var visual_board_model: BoardModel = resolve_models.get("visual_board_model") as BoardModel
	var simulation_board_model: BoardModel = resolve_models.get("simulation_board_model") as BoardModel
	if visual_board_model == null or simulation_board_model == null:
		visual_board_model = _board_model.clone()
		simulation_board_model = _board_model.clone()
		_board_view.set_board_presentation_model(visual_board_model)
	_trace(resolve_trace_origin_usec, "phase=visual_state_ready board_seed=%d" % visual_board_model.rng_seed)
	_trace(resolve_trace_origin_usec, "phase=simulation_resolve_start board_seed=%d" % simulation_board_model.rng_seed)
	var resolve_result: Dictionary = _resolver.resolve_all(simulation_board_model)
	_call(CALLBACK_STORE_LAST_RESOLVE_RESULT, [resolve_result])
	_trace(
		resolve_trace_origin_usec,
		(
			"phase=simulation_resolve_complete total_combos=%d passes=%d"
			% [int(resolve_result.get("total_combos", 0)), Array(resolve_result.get("passes", [])).size()]
		)
	)
	await _call(CALLBACK_PLAY_RESOLVE_ANIMATIONS, [resolve_result, visual_board_model, resolve_trace_origin_usec])
	if not _can_continue():
		_model.end_resolve_trace()
		return
	_trace(
		resolve_trace_origin_usec,
		(
			"phase=resolve_presentation_complete total_combos=%d passes=%d"
			% [int(resolve_result.get("total_combos", 0)), Array(resolve_result.get("passes", [])).size()]
		)
	)
	_board_controller.commit_model_after_resolve(simulation_board_model)
	var committed_board_model: BoardModel = _board_controller.current_board_model()
	_call(CALLBACK_APPLY_BOARD_MODEL, [committed_board_model])
	_trace(resolve_trace_origin_usec, "phase=final_board_commit board_seed=%d" % committed_board_model.rng_seed)
	_call(CALLBACK_BIND_TURN_RESOLUTION)
	var turn_route_result: Dictionary = await _turn_resolution_coordinator.handle_resolved_board_turn(_input_phase_value(), resolve_result)
	if bool(turn_route_result.get("stop", false)):
		_model.end_resolve_trace()
		return
	_model.end_resolve_trace()


func _input_phase_value() -> int:
	var callback: Callable = _callbacks.get(CALLBACK_INPUT_PHASE_VALUE, Callable())
	return int(callback.call()) if callback.is_valid() else 0


func _can_continue() -> bool:
	var callback: Callable = _callbacks.get(CALLBACK_CAN_CONTINUE, Callable())
	return bool(callback.call(true)) if callback.is_valid() else false


func _trace(origin_usec: int, message: String) -> void:
	_call(CALLBACK_RESOLVE_TRACE, [origin_usec, message])


func _call(callback_name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(callback_name, Callable())
	if not callback.is_valid():
		return null
	return callback.callv(args)
