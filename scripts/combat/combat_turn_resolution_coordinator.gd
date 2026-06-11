extends RefCounted
class_name CombatTurnResolutionCoordinator

const CALLBACK_CAN_CONTINUE := "can_continue"
const CALLBACK_REPLAY_TURN_RESOLUTION := "replay_turn_resolution"
const CALLBACK_SYNC_MASTERY_TOTALS := "sync_mastery_totals"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_CURRENT_ROUTE_ID := "current_route_id"
const CONFIG_RESOLVING_INPUT_PHASE_VALUE := "resolving_input_phase_value"

var _combat: Variant = null
var _model: Variant = null
var _run_state: Variant = null
var _hud_stage_coordinator: Variant = null
var _outcome_route_coordinator: Variant = null
var _callbacks: Dictionary = {}
var _resolving_input_phase_value := 1


func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_combat = dependencies.get("combat")
	_model = dependencies.get("model")
	_run_state = dependencies.get("run_state")
	_hud_stage_coordinator = dependencies.get("hud_stage_coordinator")
	_outcome_route_coordinator = dependencies.get("outcome_route_coordinator")
	_callbacks = callbacks.duplicate()
	_resolving_input_phase_value = int(config.get(CONFIG_RESOLVING_INPUT_PHASE_VALUE, _resolving_input_phase_value))


func should_route_resolved_board_to_combat(current_input_phase: int) -> bool:
	return current_input_phase == _resolving_input_phase_value


func should_stop_after_turn_resolution() -> bool:
	return not _can_continue()


func resolve_player_turn(resolve_result: Dictionary) -> Dictionary:
	if _combat == null or _model == null or _run_state == null:
		return {"ok": false, "route": "missing_dependencies"}
	_model.begin_hud_staging(_hud_stage_coordinator.capture_values())
	var turn_log: Dictionary = _combat.resolve_player_turn(resolve_result)
	(
		_run_state
		. log_turn_result(
			turn_log,
			{
				"total_combos": int(resolve_result.get("total_combos", 0)),
				"resolve_pass_count": Array(resolve_result.get("passes", [])).size(),
			}
		)
	)
	_call(CALLBACK_SYNC_MASTERY_TOTALS)
	(
		_run_state
		. flow_trace_mark(
			"combat_before_replay_turn_resolution_from_log",
			{
				"total_combos": int(resolve_result.get("total_combos", 0)),
				"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", 0)),
			},
			_current_route_id()
		)
	)
	await _call(CALLBACK_REPLAY_TURN_RESOLUTION, [turn_log])
	if not _can_continue():
		_model.clear_hud_staging()
		return {"ok": false, "route": "async_cancelled"}
	_model.clear_hud_staging()
	_call(CALLBACK_UPDATE_HUD)
	(
		_run_state
		. flow_trace_mark(
			"combat_after_replay_turn_resolution_from_log",
			{
				"healed": int(turn_log.get("healed", 0)),
				"armor_gained": int(turn_log.get("armor_gained", 0)),
				"gold_gained": int(turn_log.get("gold_gained", 0)),
			},
			_current_route_id()
		)
	)
	if _outcome_route_coordinator == null:
		return {"ok": false, "route": "missing_outcome_coordinator"}
	var outcome: Dictionary = _outcome_route_coordinator.handle_turn_outcome(int(_combat.phase), turn_log)
	outcome["ok"] = true
	return outcome


func _can_continue() -> bool:
	if not _callbacks.has(CALLBACK_CAN_CONTINUE):
		return true
	return bool(_callbacks[CALLBACK_CAN_CONTINUE].call())


func _current_route_id() -> String:
	if not _callbacks.has(CALLBACK_CURRENT_ROUTE_ID):
		return ""
	return String(_callbacks[CALLBACK_CURRENT_ROUTE_ID].call())


func _call(callback_name: String, args: Array = []) -> Variant:
	if not _callbacks.has(callback_name):
		return null
	var callback: Callable = _callbacks[callback_name]
	if not callback.is_valid():
		return null
	return callback.callv(args)
