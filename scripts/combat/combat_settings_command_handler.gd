extends RefCounted
class_name CombatSettingsCommandHandler

const CALLBACK_SET_INPUT_PHASE := "set_input_phase"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_CURRENT_TURN_INDEX := "current_turn_index"
const CALLBACK_TRACE_AND_CHANGE_SCENE := "trace_and_change_scene"
const CALLBACK_COMBAT_SPEED_VALUE := "combat_speed_value"
const CALLBACK_APPLY_VFX_SPEED := "apply_vfx_speed"

const SCENE_COMBAT := "res://scenes/combat.tscn"
const SCENE_MAIN_MENU := "res://scenes/main_menu.tscn"

const TRACE_SOURCE_NEW_RUN := "combat.settings_new_run"
const TRACE_SOURCE_MAIN_MENU := "combat.settings_main_menu"
const TRACE_MARK_NEW_RUN := "combat_before_change_scene_to_file_settings_new_run"
const TRACE_MARK_MAIN_MENU := "combat_before_change_scene_to_file_settings_main_menu"

var _view: Variant
var _model: Variant
var _resolve_presenter: Variant
var _callbacks: Dictionary = {}
var _player_input_phase_value := 0
var _locked_input_phase_value := 2
var _neutral_status_color := Color.WHITE


func bind(view: Variant, model: Variant, resolve_presenter: Variant, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_view = view
	_model = model
	_resolve_presenter = resolve_presenter
	_callbacks = callbacks.duplicate()
	_player_input_phase_value = int(config.get("player_input_phase_value", _player_input_phase_value))
	_locked_input_phase_value = int(config.get("locked_input_phase_value", _locked_input_phase_value))
	var neutral_color: Variant = config.get("neutral_status_color", _neutral_status_color)
	if neutral_color is Color:
		_neutral_status_color = neutral_color


func bind_for_combat_controller(
	view: Variant,
	model: Variant,
	resolve_presenter: Variant,
	controller: Object,
	player_input_phase_value: int,
	locked_input_phase_value: int,
	neutral_status_color: Color
) -> void:
	bind(
		view,
		model,
		resolve_presenter,
		{
			CALLBACK_SET_INPUT_PHASE: Callable(controller, "_debug_set_input_phase"),
			CALLBACK_SET_STATUS_TEXT: Callable(controller, "_set_status_text"),
			CALLBACK_SET_STATUS_COLOR: Callable(controller, "_set_status_color"),
			CALLBACK_CURRENT_TURN_INDEX: Callable(controller, "_settings_current_turn_index"),
			CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(controller, "_settings_trace_and_change_scene"),
			CALLBACK_COMBAT_SPEED_VALUE: Callable(controller, "_combat_speed_value"),
			CALLBACK_APPLY_VFX_SPEED: Callable(controller, "_apply_vfx_speed_setting"),
		},
		{
			"player_input_phase_value": player_input_phase_value,
			"locked_input_phase_value": locked_input_phase_value,
			"neutral_status_color": neutral_status_color,
		}
	)


func open() -> void:
	RunState.load_user_settings()
	_show_overlay(RunState.vfx_speed())
	_set_input_phase(_locked_input_phase_value)
	_set_status_text("Settings opened.")


func continue_combat() -> void:
	_hide_overlay()
	_set_input_phase(_player_input_phase_value)
	_set_status_text("%s | Turn %d." % [RunState.level_sequence_label(), _current_turn_index()])
	_set_status_color(_neutral_status_color)


func start_new_run() -> void:
	_hide_overlay()
	RunState.start_new_run()
	_trace_and_change_scene(SCENE_COMBAT, TRACE_SOURCE_NEW_RUN, TRACE_MARK_NEW_RUN)


func return_to_main_menu() -> void:
	_hide_overlay()
	_trace_and_change_scene(SCENE_MAIN_MENU, TRACE_SOURCE_MAIN_MENU, TRACE_MARK_MAIN_MENU)


func select_speed(speed: String) -> void:
	RunState.set_vfx_speed(speed)
	_call_method(_model, "set_combat_speed", [RunState.vfx_speed()])
	if _resolve_presenter != null and _resolve_presenter.has_method("set_combat_speed"):
		_resolve_presenter.set_combat_speed(_combat_speed_value())
	_call_callback(CALLBACK_APPLY_VFX_SPEED)
	_show_overlay(RunState.vfx_speed())
	_set_status_text("VFX speed: %s." % RunState.vfx_speed().capitalize())


func _show_overlay(speed: String) -> void:
	_call_method(_view, "show_settings_overlay", [speed])


func _hide_overlay() -> void:
	_call_method(_view, "hide_settings_overlay")


func _set_input_phase(phase_value: int) -> void:
	_call_callback(CALLBACK_SET_INPUT_PHASE, [phase_value])


func _set_status_text(message: String) -> void:
	_call_callback(CALLBACK_SET_STATUS_TEXT, [message])


func _set_status_color(color: Color) -> void:
	_call_callback(CALLBACK_SET_STATUS_COLOR, [color])


func _current_turn_index() -> int:
	var value: Variant = _call_callback(CALLBACK_CURRENT_TURN_INDEX)
	if value is int:
		return int(value)
	if value is float:
		return int(value)
	return 1


func _trace_and_change_scene(scene_path: String, trace_source: String, trace_mark: String) -> void:
	_call_callback(CALLBACK_TRACE_AND_CHANGE_SCENE, [scene_path, trace_source, trace_mark])


func _combat_speed_value() -> String:
	var value: Variant = _call_callback(CALLBACK_COMBAT_SPEED_VALUE)
	if value is String and String(value) != "":
		return String(value)
	return RunState.vfx_speed()


func _call_callback(name: String, args: Array = []) -> Variant:
	var callback := _callback(name)
	if callback.is_valid():
		return callback.callv(args)
	return null


func _callback(name: String) -> Callable:
	if not _callbacks.has(name):
		return Callable()
	var raw_callback: Variant = _callbacks[name]
	if raw_callback is Callable:
		return raw_callback as Callable
	return Callable()


func _call_method(target: Variant, method_name: String, args: Array = []) -> void:
	if target == null:
		return
	if not target.has_method(method_name):
		return
	target.callv(method_name, args)
