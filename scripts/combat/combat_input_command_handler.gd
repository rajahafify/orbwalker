extends RefCounted
class_name CombatInputCommandHandler

const CALLBACK_TOGGLE_DEBUG_OVERLAY := "toggle_debug_overlay"
const CALLBACK_CREATE_NEW_BOARD := "create_new_board"
const CALLBACK_PRINT_BOARD_MODEL := "print_board_model"
const CALLBACK_TRY_USE_FIRST_CONSUMABLE := "try_use_first_consumable"
const CALLBACK_SET_INPUT_HANDLED := "set_input_handled"

var _view: Variant = null
var _callbacks: Dictionary = {}
var _zone_guides_enabled := false


func bind(context: Dictionary, callbacks: Dictionary = {}) -> void:
	_view = context.get("view", null)
	_callbacks = callbacks.duplicate()
	if context.has("zone_guides_enabled"):
		_zone_guides_enabled = bool(context.get("zone_guides_enabled", false))


func zone_guides_enabled() -> bool:
	return _zone_guides_enabled


func handle_unhandled_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return _handle_key_event(event as InputEventKey)
	if event is InputEventMouseButton:
		return _handle_mouse_button_event(event as InputEventMouseButton)
	return false


func _handle_key_event(event: InputEventKey) -> bool:
	if not event.pressed or event.echo:
		return false
	match event.keycode:
		KEY_F1:
			_call(CALLBACK_TOGGLE_DEBUG_OVERLAY)
		KEY_F2:
			_toggle_zone_guides()
		KEY_R:
			_call(CALLBACK_CREATE_NEW_BOARD)
		KEY_P:
			_call(CALLBACK_PRINT_BOARD_MODEL)
		KEY_C:
			_call(CALLBACK_TRY_USE_FIRST_CONSUMABLE)
		_:
			return false
	_mark_input_handled()
	return true


func _handle_mouse_button_event(event: InputEventMouseButton) -> bool:
	if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return false
	var handled_click := false
	if _view != null and _view.has_method("handle_player_hud_global_click"):
		handled_click = bool(_view.handle_player_hud_global_click(event.position))
	if handled_click:
		_mark_input_handled()
	return handled_click


func _toggle_zone_guides() -> void:
	_zone_guides_enabled = not _zone_guides_enabled
	if _view != null and _view.has_method("set_zone_guides_enabled"):
		_view.set_zone_guides_enabled(_zone_guides_enabled)


func _mark_input_handled() -> void:
	_call(CALLBACK_SET_INPUT_HANDLED)


func _call(name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(name, Callable())
	if callback.is_valid():
		return callback.callv(args)
	return null
