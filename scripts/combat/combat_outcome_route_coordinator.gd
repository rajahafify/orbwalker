extends RefCounted
class_name CombatOutcomeRouteCoordinator

const CALLBACK_APPEND_COMBAT_LOG := "append_combat_log"
const CALLBACK_APPEND_TURN_LOG := "append_turn_log"
const CALLBACK_BEGIN_TURN_PREVIEW := "begin_turn_preview"
const CALLBACK_BUILD_RUN_OUTCOME_SUMMARY := "build_run_outcome_summary"
const CALLBACK_CURRENT_ROUTE_ID := "current_route_id"
const CALLBACK_HIDE_OUTCOME_SUMMARY := "hide_outcome_summary"
const CALLBACK_PLAY_SFX := "play_sfx"
const CALLBACK_PULSE_TURN_SUMMARY := "pulse_turn_summary"
const CALLBACK_SET_INPUT_PHASE := "set_input_phase"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_TURN_SUMMARY_TEXT := "set_turn_summary_text"
const CALLBACK_SHOW_BOSS_REWARD_SUMMARY := "show_boss_reward_summary"
const CALLBACK_SHOW_OUTCOME_SUMMARY := "show_outcome_summary"
const CALLBACK_TRACE_AND_CHANGE_SCENE := "trace_and_change_scene"

var _run_state: Variant = null
var _model: Variant = null
var _enemy_state: Variant = null
var _turn_log_presenter: Variant = null
var _callbacks: Dictionary = {}
var _config: Dictionary = {}


func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state")
	_model = dependencies.get("model")
	_enemy_state = dependencies.get("enemy_state")
	_turn_log_presenter = dependencies.get("turn_log_presenter")
	_callbacks = callbacks.duplicate()
	_config = config.duplicate()


func handle_turn_outcome(phase: int, turn_log: Dictionary) -> Dictionary:
	if _run_state == null or _turn_log_presenter == null:
		return {"handled": false, "route": "missing_dependencies"}
	if phase == int(_config.get("victory_phase_value", -1)):
		return _handle_victory(turn_log)
	if phase == int(_config.get("defeat_phase_value", -1)):
		return _handle_defeat(turn_log)
	return _handle_continue_turn(turn_log)


func _handle_victory(turn_log: Dictionary) -> Dictionary:
	_call(CALLBACK_PLAY_SFX, ["victory"])
	_flow_trace_mark("combat_before_mark_fight_victory")
	var transition: Dictionary = _run_state.mark_fight_victory()
	var next_scene := String(transition.get("next_scene", ""))
	_flow_trace_mark(
		"combat_after_mark_fight_victory",
		{
			"next_scene": next_scene,
			"step": String(transition.get("step", "")),
		},
		next_scene
	)
	_lock_external_input()
	_call(CALLBACK_APPEND_TURN_LOG, [turn_log])
	if _run_state.is_current_step_boss_reward():
		return _handle_boss_reward(turn_log, transition)
	if next_scene == "":
		next_scene = String(_config.get("default_victory_scene", "res://scenes/main_menu.tscn"))
	if next_scene.find("run_summary") >= 0:
		return _handle_final_victory(next_scene)
	return _handle_victory_continue(turn_log, transition, next_scene)


func _handle_boss_reward(turn_log: Dictionary, transition: Dictionary) -> Dictionary:
	if _model != null:
		_model.clear_pending_next_scene_path()
	_call(CALLBACK_SET_STATUS_TEXT, ["Boss defeated. Choose one boss relic before continuing."])
	_call(CALLBACK_APPEND_COMBAT_LOG, ["Outcome: Boss victory. Waiting for boss relic selection in victory overlay."])
	_call(CALLBACK_SHOW_BOSS_REWARD_SUMMARY, [_turn_log_presenter.build_victory_gold_summary(turn_log, transition)])
	_call(CALLBACK_SET_TURN_SUMMARY_TEXT, ["Turn Summary: Boss victory. Choose a relic."])
	_flow_trace_mark("combat_boss_reward_available")
	_call(CALLBACK_PULSE_TURN_SUMMARY, [_config.get("positive_color")])
	return {"handled": true, "route": "boss_reward"}


func _handle_final_victory(next_scene: String) -> Dictionary:
	_call(CALLBACK_APPEND_COMBAT_LOG, ["Outcome: Final boss victory. Opening run summary."])
	_call(CALLBACK_HIDE_OUTCOME_SUMMARY)
	_call(
		CALLBACK_TRACE_AND_CHANGE_SCENE,
		[
			next_scene,
			_current_route_id(),
			"combat_final_summary_auto",
			"combat_before_final_summary_change_scene",
		]
	)
	return {"handled": true, "route": "final_summary"}


func _handle_victory_continue(turn_log: Dictionary, transition: Dictionary, next_scene: String) -> Dictionary:
	_call(CALLBACK_SET_STATUS_TEXT, [_turn_log_presenter.build_victory_status(turn_log, transition) + " Press Continue."])
	_call(CALLBACK_APPEND_COMBAT_LOG, ["Outcome: Victory. Waiting for Next button to continue run flow."])
	if _model != null:
		_model.set_pending_next_scene_path(next_scene)
	_call(CALLBACK_SHOW_OUTCOME_SUMMARY, ["Victory", _turn_log_presenter.build_victory_gold_summary(turn_log, transition), true])
	_call(CALLBACK_SET_TURN_SUMMARY_TEXT, ["Turn Summary: Victory. Press Continue."])
	_flow_trace_mark("combat_continue_available", {"button_text": "Continue"}, next_scene)
	_call(CALLBACK_PULSE_TURN_SUMMARY, [_config.get("positive_color")])
	return {"handled": true, "route": "victory_continue"}


func _handle_defeat(turn_log: Dictionary) -> Dictionary:
	_call(CALLBACK_PLAY_SFX, ["defeat"])
	var defeat_cause: String = _turn_log_presenter.build_defeat_cause(_enemy_display_name(), turn_log)
	var defeat_transition: Dictionary = _run_state.mark_player_defeated(defeat_cause)
	_lock_external_input()
	_call(CALLBACK_SET_STATUS_TEXT, [_turn_log_presenter.build_defeat_status(turn_log) + " Run Summary available."])
	_call(CALLBACK_APPEND_TURN_LOG, [turn_log])
	_call(CALLBACK_APPEND_COMBAT_LOG, ["Outcome: Defeat. Waiting for Run Summary button."])
	var next_scene := String(defeat_transition.get("next_scene", _config.get("run_summary_scene", "res://scenes/run_summary.tscn")))
	if _model != null:
		_model.set_pending_next_scene_path(next_scene)
	_call(CALLBACK_SHOW_OUTCOME_SUMMARY, ["Defeat", _build_run_outcome_summary(defeat_cause), true, "Run Summary"])
	_call(CALLBACK_SET_TURN_SUMMARY_TEXT, ["Turn Summary: Defeat. Run Summary available."])
	var pending_scene := next_scene
	if _model != null:
		pending_scene = String(_model.pending_next_scene_path())
	_flow_trace_mark("combat_continue_available", {"button_text": "Run Summary"}, pending_scene)
	_call(CALLBACK_PULSE_TURN_SUMMARY, [_config.get("negative_color")])
	return {"handled": true, "route": "defeat_summary"}


func _handle_continue_turn(turn_log: Dictionary) -> Dictionary:
	var status: String = _turn_log_presenter.build_turn_summary_status(turn_log)
	_call(CALLBACK_SET_STATUS_TEXT, [status])
	_call(CALLBACK_SET_STATUS_COLOR, [_config.get("positive_color")])
	_call(CALLBACK_SET_TURN_SUMMARY_TEXT, ["Turn Summary: %s" % status])
	_call(CALLBACK_PULSE_TURN_SUMMARY, [_config.get("positive_color")])
	_call(CALLBACK_APPEND_TURN_LOG, [turn_log])
	_call(CALLBACK_BEGIN_TURN_PREVIEW)
	return {"handled": true, "route": "continue_turn"}


func _build_run_outcome_summary(defeat_cause: String) -> String:
	if _callbacks.has(CALLBACK_BUILD_RUN_OUTCOME_SUMMARY):
		return String(_callbacks[CALLBACK_BUILD_RUN_OUTCOME_SUMMARY].call(defeat_cause))
	return defeat_cause


func _enemy_display_name() -> String:
	if _enemy_state != null:
		return String(_enemy_state.display_name)
	return "Enemy"


func _lock_external_input() -> void:
	_call(CALLBACK_SET_INPUT_PHASE, [int(_config.get("locked_input_phase_value", 0))])


func _flow_trace_mark(step: String, payload: Dictionary = {}, target_scene: String = "") -> void:
	if _run_state == null:
		return
	_run_state.flow_trace_mark(step, payload, _current_route_id(), target_scene)


func _current_route_id() -> String:
	if _callbacks.has(CALLBACK_CURRENT_ROUTE_ID):
		return String(_callbacks[CALLBACK_CURRENT_ROUTE_ID].call())
	return ""


func _call(callback_name: String, args: Array = []) -> Variant:
	if not _callbacks.has(callback_name):
		return null
	var callback: Callable = _callbacks[callback_name]
	if not callback.is_valid():
		return null
	return callback.callv(args)
