extends RefCounted
class_name CombatSettingsOverlayCoordinator

const COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
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


func _ensure_presenter() -> void:
	if _parent == null:
		return
	if _presenter == null:
		_presenter = COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.new()
	_presenter.bind(_parent, _callbacks, {"design_size": DESIGN_SIZE})
