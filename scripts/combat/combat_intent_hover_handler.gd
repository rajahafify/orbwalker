extends RefCounted
class_name CombatIntentHoverHandler

const CALLBACK_INPUT_PHASE_VALUE := "input_phase_value"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_SET_TURN_SUMMARY_TEXT := "set_turn_summary_text"
const CALLBACK_FORMAT_INTENT := "format_intent"

var _run_state: Variant = null
var _combat: Variant = null
var _enemy_state: Variant = null
var _model: Variant = null
var _view: Variant = null
var _callbacks: Dictionary = {}
var _player_input_phase_value := 0
var _warning_color := Color.WHITE


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_combat = dependencies.get("combat", null)
	_enemy_state = dependencies.get("enemy_state", null)
	_model = dependencies.get("model", null)
	_view = dependencies.get("view", null)
	_callbacks = callbacks.duplicate()
	_player_input_phase_value = int(config.get("player_input_phase_value", 0))
	_warning_color = config.get("warning_color", Color.WHITE)


func should_show_preview() -> bool:
	if _combat == null or _enemy_state == null:
		return false
	if _input_phase_value() != _player_input_phase_value:
		return false
	if _model != null and _model.has_method("is_outcome_transition_queued") and bool(_model.is_outcome_transition_queued()):
		return false
	if _combat.has_method("is_fight_over") and bool(_combat.is_fight_over()):
		return false
	return true


func intent_damage_preview_hovered(preview: Dictionary) -> void:
	if not should_show_preview():
		return
	var attack := maxi(0, int(preview.get("attack", 0)))
	var blocked := maxi(0, int(preview.get("blocked", 0)))
	var hp_loss := maxi(0, int(preview.get("hp_loss", 0)))
	if attack <= 0:
		return
	_set_status_text(_status_with_level("Incoming %d (Block %d, HP Loss %d)." % [attack, blocked, hp_loss]))
	_set_status_color(_warning_color)
	_set_turn_summary_to_current_intent()
	_start_enemy_intent_hover_emphasis("attack")


func intent_block_preview_hovered(preview: Dictionary) -> void:
	if not should_show_preview():
		return
	var blocked := maxi(0, int(preview.get("blocked", 0)))
	if blocked <= 0:
		return
	_set_status_text(_status_with_level("Incoming attack blocked by %d armor." % blocked))
	_set_status_color(_warning_color)
	_set_turn_summary_to_current_intent()
	_start_enemy_intent_hover_emphasis("block")


func enemy_block_preview_hovered(preview: Dictionary) -> void:
	if not should_show_preview():
		return
	if preview.is_empty():
		return
	var block := maxi(0, int(preview.get("block", 0)))
	if block <= 0:
		return
	_set_status_text(_status_with_level("Enemy will gain %d block." % block))
	_set_status_color(_warning_color)
	_set_turn_summary_to_current_intent()
	_start_enemy_intent_hover_emphasis("block")


func intent_damage_preview_hover_ended() -> void:
	if _view != null and _view.has_method("stop_enemy_intent_hover_emphasis"):
		_view.stop_enemy_intent_hover_emphasis()


func enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	if not should_show_preview():
		return
	var amount := maxi(0, int(entry.get("amount", 0)))
	if amount <= 0:
		return
	if kind == "attack":
		_set_status_text(_status_with_level("Enemy intent: Attack %d." % amount))
	elif kind == "block":
		_set_status_text(_status_with_level("Enemy intent: Block %d." % amount))
	else:
		_set_status_text(_status_with_level("Enemy intent: %s." % String(entry.get("label", ""))))
	_set_status_color(_warning_color)
	_start_enemy_intent_hover_emphasis(kind)


func _set_turn_summary_to_current_intent() -> void:
	if _enemy_state == null or not _enemy_state.has_method("get_current_intent"):
		return
	var intent: Dictionary = _enemy_state.get_current_intent()
	if intent.is_empty():
		return
	var format_intent: Callable = _callbacks.get(CALLBACK_FORMAT_INTENT, Callable())
	var summary := str(intent)
	if format_intent.is_valid():
		summary = String(format_intent.call(intent))
	_set_turn_summary_text(summary)


func _status_with_level(message: String) -> String:
	var label := _level_sequence_label()
	if label == "":
		return message
	return "%s | %s" % [label, message]


func _level_sequence_label() -> String:
	if _run_state != null and _run_state.has_method("level_sequence_label"):
		return String(_run_state.level_sequence_label())
	return ""


func _start_enemy_intent_hover_emphasis(kind: String) -> void:
	if _view != null and _view.has_method("start_enemy_intent_hover_emphasis"):
		_view.start_enemy_intent_hover_emphasis(kind)


func _input_phase_value() -> int:
	var input_phase_value: Callable = _callbacks.get(CALLBACK_INPUT_PHASE_VALUE, Callable())
	if input_phase_value.is_valid():
		return int(input_phase_value.call())
	return _player_input_phase_value


func _set_status_text(value: String) -> void:
	var set_status_text: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if set_status_text.is_valid():
		set_status_text.call(value)


func _set_status_color(value: Color) -> void:
	var set_status_color: Callable = _callbacks.get(CALLBACK_SET_STATUS_COLOR, Callable())
	if set_status_color.is_valid():
		set_status_color.call(value)


func _set_turn_summary_text(value: String) -> void:
	var set_turn_summary_text: Callable = _callbacks.get(CALLBACK_SET_TURN_SUMMARY_TEXT, Callable())
	if set_turn_summary_text.is_valid():
		set_turn_summary_text.call(value)
