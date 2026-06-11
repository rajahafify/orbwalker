extends RefCounted
class_name CombatSettingsOverlayCoordinator

const COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
const CALLBACK_CONTINUE := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_CONTINUE
const CALLBACK_NEW_RUN := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_NEW_RUN
const CALLBACK_MAIN_MENU := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_MAIN_MENU
const CALLBACK_SPEED_SELECTED := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_SPEED_SELECTED
const CALLBACK_QUALITY_SELECTED := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_QUALITY_SELECTED
const CALLBACK_REDUCED_MOTION_TOGGLED := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_REDUCED_MOTION_TOGGLED
const CALLBACK_GAME_JUICE_TOGGLED := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_GAME_JUICE_TOGGLED
const CALLBACK_GAME_JUICE_FLAG_TOGGLED := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_GAME_JUICE_FLAG_TOGGLED
const CALLBACK_RESET_DEFAULTS := COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.CALLBACK_RESET_DEFAULTS
const DESIGN_SIZE := Vector2(1080.0, 1920.0)

var _parent: Control = null
var _callbacks: Dictionary = {}
var _presenter: Variant = null


func bind(parent: Control, callbacks: Dictionary = {}) -> void:
	_parent = parent
	_callbacks = callbacks.duplicate()
	if _presenter != null:
		_presenter.bind(_parent, _callbacks, {"design_size": DESIGN_SIZE})


func ensure_overlay() -> void:
	_ensure_presenter()
	if _presenter != null:
		_presenter.ensure_overlay()


func show(settings: Variant) -> void:
	_ensure_presenter()
	if _presenter != null:
		_presenter.show(settings)


func hide() -> void:
	if _presenter != null:
		_presenter.hide()


func is_visible() -> bool:
	return _presenter != null and _presenter.is_visible()


func speed_buttons() -> Array[Button]:
	if _presenter == null:
		return []
	return _presenter.speed_buttons()


func quality_buttons() -> Array[Button]:
	if _presenter == null:
		return []
	return _presenter.quality_buttons()


func reduced_motion_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.reduced_motion_button()


func game_juice_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.game_juice_button()


func game_juice_flag_buttons() -> Dictionary:
	if _presenter == null:
		return {}
	return _presenter.game_juice_flag_buttons()


func reset_defaults_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.reset_defaults_button()


func continue_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.continue_button()


func new_run_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.new_run_button()


func main_menu_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.main_menu_button()


func continue_pressed() -> void:
	_emit(CALLBACK_CONTINUE)


func new_run_pressed() -> void:
	_emit(CALLBACK_NEW_RUN)


func main_menu_pressed() -> void:
	_emit(CALLBACK_MAIN_MENU)


func speed_selected(speed: String) -> void:
	_emit(CALLBACK_SPEED_SELECTED, [speed])


func quality_selected(quality: String) -> void:
	_emit(CALLBACK_QUALITY_SELECTED, [quality])


func reduced_motion_toggled() -> void:
	_emit(CALLBACK_REDUCED_MOTION_TOGGLED)


func game_juice_toggled() -> void:
	_emit(CALLBACK_GAME_JUICE_TOGGLED)


func game_juice_flag_toggled(flag_key: String) -> void:
	_emit(CALLBACK_GAME_JUICE_FLAG_TOGGLED, [flag_key])


func reset_defaults_pressed() -> void:
	_emit(CALLBACK_RESET_DEFAULTS)


func _ensure_presenter() -> void:
	if _parent == null:
		return
	if _presenter == null:
		_presenter = COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.new()
	_presenter.bind(_parent, _callbacks, {"design_size": DESIGN_SIZE})


func _emit(name: String, args: Array = []) -> void:
	var callback := _callback(name)
	if callback.is_valid():
		callback.callv(args)


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
