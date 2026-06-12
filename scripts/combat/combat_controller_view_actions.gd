extends RefCounted
class_name CombatControllerViewActions

const CALLBACK_APPLY_LAYOUT := "apply_layout"
const CALLBACK_BIND_BOSS_REWARD_HANDLER := "bind_boss_reward_handler"
const CALLBACK_BOSS_REWARD_HANDLER := "boss_reward_handler"

var _view: Variant = null
var _outcome_overlay: Variant = null
var _debug_runtime: Variant = null
var _callbacks: Dictionary = {}


func bind(dependencies: Dictionary, callbacks: Dictionary = {}) -> void:
	_view = dependencies.get("view", null)
	_outcome_overlay = dependencies.get("outcome_overlay", null)
	_debug_runtime = dependencies.get("debug_runtime", null)
	_callbacks = callbacks.duplicate()


func console_set_status_text(message: String) -> void:
	set_status_text(message)


func set_status_text(message: String) -> void:
	if _view != null:
		_view.set_status_text(message)


func set_status_color(color: Color) -> void:
	if _view != null:
		_view.set_status_color(color)


func set_turn_summary_text(text: String) -> void:
	if _view != null:
		_view.set_turn_summary_text(text)


func pulse_turn_summary(tint: Color) -> void:
	if _view != null:
		_view.pulse_turn_summary(tint)


func show_outcome_summary(title: String, body: String, show_next: bool, button_text: String = "Continue") -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.show_summary(title, body, show_next, button_text)
	_call(CALLBACK_APPLY_LAYOUT)


func hide_outcome_summary() -> void:
	if _outcome_overlay != null:
		_outcome_overlay.hide()


func ensure_outcome_overlay_layer() -> void:
	if _outcome_overlay != null:
		_outcome_overlay.ensure_overlay_layer()


func ensure_boss_reward_controls() -> void:
	var handler: Variant = _boss_reward_handler()
	if handler != null:
		handler.ensure_controls()


func show_boss_reward_summary(body: String) -> void:
	var handler: Variant = _boss_reward_handler()
	if handler != null:
		handler.show_summary(body)


func append_combat_log(message: String, is_command_output: bool = false) -> void:
	if _debug_runtime != null:
		_debug_runtime.append_log(message, is_command_output)


func debug_console_log(message: String) -> void:
	append_combat_log(message)


func _boss_reward_handler() -> Variant:
	_call(CALLBACK_BIND_BOSS_REWARD_HANDLER)
	return _call(CALLBACK_BOSS_REWARD_HANDLER)


func _call(name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(name, Callable())
	if callback.is_valid():
		return callback.callv(args)
	return null
