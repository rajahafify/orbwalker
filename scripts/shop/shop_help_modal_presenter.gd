extends RefCounted
class_name ShopHelpModalPresenter

const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW_CHROME_STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const SHOP_HELP_MODAL_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_RECT
const SHOP_HELP_MODAL_TITLE_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_TITLE_RECT
const SHOP_HELP_MODAL_BODY_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_BODY_RECT
const SHOP_HELP_MODAL_CLOSE_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_CLOSE_RECT
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const POSITIVE_COLOR := Color(0.60, 0.88, 0.42, 1.0)

var _parent: Control = null
var _overlay: ColorRect = null
var _modal: Panel = null
var _title_label: Label = null
var _body_label: Label = null
var _close_button: Button = null


func bind(parent: Control) -> void:
	_parent = parent


func ensure_modal() -> void:
	if _overlay != null and is_instance_valid(_overlay):
		return
	if _parent == null:
		return
	_overlay = SHOP_VIEW_NODE_FACTORY.make_color_rect("ShopHelpOverlay", _parent, Color(0.0, 0.0, 0.0, 0.54))
	_overlay.visible = false
	_overlay.z_index = 70
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.gui_input.connect(_on_overlay_gui_input)
	_modal = SHOP_VIEW_NODE_FACTORY.make_panel("ShopHelpModal", _overlay)
	_modal.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_title_label = SHOP_VIEW_NODE_FACTORY.make_label("ShopHelpTitleLabel", _modal, "Shop opened. Buy, reroll, sell, or continue.", 34, POSITIVE_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_body_label = SHOP_VIEW_NODE_FACTORY.make_label("ShopHelpBodyLabel", _modal, "Tap stock or relic cards to buy. Sell filled loadout slots from the slot popover.", 26, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_close_button = SHOP_VIEW_NODE_FACTORY.make_button("ShopHelpCloseButton", _modal, "x")
	_close_button.pressed.connect(hide)


func show() -> void:
	ensure_modal()
	if _overlay == null:
		return
	_overlay.visible = true


func hide() -> void:
	if _overlay == null:
		return
	_overlay.visible = false


func is_visible() -> bool:
	return _overlay != null and _overlay.visible


func handle_global_input(event: InputEvent) -> bool:
	if not is_visible():
		return false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK:
			hide()
			return true
	return false


func layout(logical_size: Vector2) -> void:
	ensure_modal()
	if _overlay == null:
		return
	_apply_rect(_overlay, Rect2(Vector2.ZERO, logical_size))
	_apply_rect(_modal, SHOP_HELP_MODAL_RECT)
	_apply_rect(_title_label, SHOP_HELP_MODAL_TITLE_RECT)
	_apply_rect(_body_label, SHOP_HELP_MODAL_BODY_RECT)
	_apply_rect(_close_button, SHOP_HELP_MODAL_CLOSE_RECT)


func apply_chrome() -> void:
	ensure_modal()
	if _overlay == null:
		return
	_modal.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.05, 0.06, 0.07, 0.98), GOLD_COLOR, 3, 12, Vector4(8, 6, 8, 6)))
	_overlay.color = Color(0.0, 0.0, 0.0, 0.54)
	SHOP_VIEW_CHROME_STYLER.apply_round_button_chrome(_close_button, Color(0.13, 0.09, 0.05, 0.96), GOLD_COLOR, Color(0.23, 0.15, 0.07, 0.98))
	_title_label.add_theme_color_override("font_color", POSITIVE_COLOR)
	_body_label.add_theme_color_override("font_color", INK_COLOR)
	_close_button.add_theme_color_override("font_color", INK_COLOR)
	_close_button.add_theme_font_size_override("font_size", 30)


func overlay() -> ColorRect:
	return _overlay


func modal() -> Panel:
	return _modal


func title_label() -> Label:
	return _title_label


func body_label() -> Label:
	return _body_label


func close_button() -> Button:
	return _close_button


func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide()
		_overlay.accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		hide()
		_overlay.accept_event()


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size
