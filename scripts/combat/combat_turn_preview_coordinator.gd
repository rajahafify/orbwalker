extends RefCounted
class_name CombatTurnPreviewCoordinator

const CALLBACK_SET_INPUT_PHASE := "set_input_phase"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_CLEAR_MASTERY_HOVER := "clear_mastery_hover"
const CALLBACK_SYNC_TUTORIAL_COACHMARK := "sync_tutorial_coachmark"
const CALLBACK_FORMAT_INTENT := "format_intent"
const CALLBACK_TUTORIAL_TURN_SUMMARY_TEXT := "tutorial_turn_summary_text"
const CALLBACK_TUTORIAL_TURN_STATUS_TEXT := "tutorial_turn_status_text"

var _combat: Variant = null
var _enemy_state: Variant = null
var _model: Variant = null
var _view_actions: Variant = null
var _run_state: Variant = null
var _callbacks: Dictionary = {}
var _player_input_phase_value := 0
var _status_color_neutral := Color.WHITE


func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_combat = dependencies.get("combat")
	_enemy_state = dependencies.get("enemy_state")
	_model = dependencies.get("model")
	_view_actions = dependencies.get("view_actions")
	_run_state = dependencies.get("run_state")
	_callbacks = callbacks.duplicate()
	_player_input_phase_value = int(config.get("player_input_phase_value", _player_input_phase_value))
	_status_color_neutral = config.get("status_color_neutral", _status_color_neutral)


func begin_turn_preview() -> void:
	if _combat == null or _combat.is_fight_over():
		return
	_combat.reset_to_intent_preview()
	_combat.begin_player_input()
	_call(CALLBACK_SET_INPUT_PHASE, [_player_input_phase_value])
	_model.clear_pending_next_scene_path()
	_view_actions.hide_outcome_summary()
	_view_actions.set_turn_summary_text(_turn_summary_text())
	_view_actions.set_status_text(_turn_status_text())
	_view_actions.set_status_color(_status_color_neutral)
	_call(CALLBACK_UPDATE_HUD)
	_call(CALLBACK_CLEAR_MASTERY_HOVER)
	_call(CALLBACK_SYNC_TUTORIAL_COACHMARK)
	_view_actions.append_combat_log("Turn %d intent: %s." % [_combat.turn_index, _format_intent(_enemy_state.get_current_intent())])


func _turn_summary_text() -> String:
	if _run_state.is_tutorial_run():
		return String(_call(CALLBACK_TUTORIAL_TURN_SUMMARY_TEXT))
	return "Turn Summary: Awaiting move."


func _turn_status_text() -> String:
	if _run_state.is_tutorial_run():
		return String(_call(CALLBACK_TUTORIAL_TURN_STATUS_TEXT))
	return "%s | Turn %d." % [_run_state.level_sequence_label(), _combat.turn_index]


func _format_intent(intent: Dictionary) -> String:
	return String(_call(CALLBACK_FORMAT_INTENT, [intent]))


func _call(callback_name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(callback_name, Callable())
	if not callback.is_valid():
		return null
	return callback.callv(args)
