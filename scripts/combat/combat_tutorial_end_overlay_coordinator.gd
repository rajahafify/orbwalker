extends RefCounted
class_name CombatTutorialEndOverlayCoordinator

const COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_overlay_presenter.gd")
const DEFAULT_BOARD_PANEL_RECT := Rect2(Vector2(16.0, 660.0), Vector2(1048.0, 756.0))

var _parent: Control = null
var _nodes: Dictionary = {}
var _callbacks: Dictionary = {}
var _presenter: Variant = null
var _board_panel_rect := DEFAULT_BOARD_PANEL_RECT


func bind(parent: Control, nodes: Dictionary = {}, callbacks: Dictionary = {}) -> void:
	_parent = parent
	_nodes = nodes.duplicate()
	_callbacks = callbacks.duplicate()
	if _presenter != null:
		_presenter.bind(_parent, _nodes, _callbacks)


func set_board_panel_rect(board_panel_rect: Rect2) -> void:
	_board_panel_rect = board_panel_rect


func ensure_overlay() -> void:
	_ensure_presenter()
	if _presenter != null:
		_presenter.ensure_overlay()


func show(step := "end") -> void:
	_ensure_presenter()
	if _presenter != null:
		_presenter.show(step, _layout_config())


func hide() -> void:
	if _presenter != null:
		_presenter.hide()


func is_visible() -> bool:
	return _presenter != null and _presenter.is_visible()


func layout() -> void:
	_ensure_presenter()
	if _presenter != null:
		_presenter.layout(_layout_config())


func modal() -> Panel:
	if _presenter == null:
		return null
	return _presenter.modal()


func continue_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.continue_button()


func main_menu_button() -> Button:
	if _presenter == null:
		return null
	return _presenter.main_menu_button()


func _layout_config() -> Dictionary:
	return {"board_panel_rect": _board_panel_rect}


func _ensure_presenter() -> void:
	if _parent == null:
		return
	if _presenter == null:
		_presenter = COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT.new()
	_presenter.bind(_parent, _nodes, _callbacks)
