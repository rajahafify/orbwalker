extends RefCounted
class_name ShopTreasureChestOverlayPresenter

signal option_pressed(index: int)
signal skip_pressed

const SHOP_VIEW_CHROME_STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const OVERLAY_COLOR := Color(0.0, 0.0, 0.0, 0.44)
const MODAL_RECT := Rect2(Vector2(152, 382), Vector2(776, 420))
const TITLE_RECT := Rect2(Vector2(0, 30), Vector2(776, 42))
const HINT_RECT := Rect2(Vector2(80, 82), Vector2(616, 42))
const OPTION_SIZE := Vector2(208, 236)
const SKIP_RECT := Rect2(Vector2(302, 340), Vector2(172, 54))

var _parent: Control = null
var _visuals: Variant = null
var _content_lookup: Callable = Callable()
var _overlay: ColorRect = null
var _modal: Panel = null
var _title_label: Label = null
var _hint_label: Label = null
var _option_buttons: Array[Button] = []
var _skip_button: Button = null


func bind(parent: Control, visuals: Variant, content_lookup: Callable = Callable()) -> void:
	_parent = parent
	_visuals = visuals
	_content_lookup = content_lookup


func ensure_overlay() -> void:
	if _overlay != null and is_instance_valid(_overlay):
		return
	if _parent == null:
		return
	_overlay = SHOP_VIEW_NODE_FACTORY.make_color_rect("TreasureChestOverlay", _parent, OVERLAY_COLOR)
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_modal = SHOP_VIEW_NODE_FACTORY.make_panel("TreasureChestModal", _overlay)
	_modal.mouse_filter = Control.MOUSE_FILTER_PASS as Control.MouseFilter
	_title_label = SHOP_VIEW_NODE_FACTORY.make_label("TreasureChestTitleLabel", _modal, "Choose One Treasure Chest Reward", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_hint_label = SHOP_VIEW_NODE_FACTORY.make_label("TreasureChestHintLabel", _modal, "Pick one option now, or press Skip to continue shopping.", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	_option_buttons.clear()
	for index in 3:
		var button := SHOP_VIEW_NODE_FACTORY.make_button("TreasureChestOptionButton%d" % (index + 1), _modal, "")
		button.pressed.connect(func() -> void: emit_signal("option_pressed", index))
		_option_buttons.append(button)
	_skip_button = SHOP_VIEW_NODE_FACTORY.make_button("SkipTreasureChestButton", _modal, "Skip")
	_skip_button.visible = false
	_skip_button.pressed.connect(func() -> void: emit_signal("skip_pressed"))


func render(pending_options: Array) -> void:
	ensure_overlay()
	if _overlay == null:
		return
	var overlay_visible := not pending_options.is_empty()
	_overlay.visible = overlay_visible
	_modal.visible = overlay_visible
	if not overlay_visible:
		_skip_button.visible = false
		return
	_title_label.text = "Choose One Treasure Chest Reward"
	_hint_label.text = "Pick one option now, or press Skip to continue shopping."
	for button in _option_buttons:
		button.visible = true
	for index in _option_buttons.size():
		var button := _option_buttons[index]
		SHOP_VIEW_NODE_FACTORY.clear_children(button)
		button.text = ""
		if index >= pending_options.size():
			button.visible = false
			button.disabled = true
			continue
		button.visible = true
		button.disabled = false
		var option := Dictionary(pending_options[index])
		SHOP_VIEW_CHROME_STYLER.apply_button_chrome(button, Color(0.10, 0.08, 0.13, 0.98), GOLD_COLOR, Color(0.18, 0.13, 0.08, 1.0))
		var root := SHOP_VIEW_NODE_FACTORY.make_child_root(button)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, String(option.get("type", "option")).replace("_", " ").to_upper(), Rect2(Vector2(14, 8), Vector2(180, 22)), MUTED_COLOR, 14, HORIZONTAL_ALIGNMENT_CENTER)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, String(option.get("display_name", "Option")), Rect2(Vector2(14, 36), Vector2(180, 54)), INK_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER, true)
		var content := _lookup_content_definition(String(option.get("content_id", "")))
		var icon := SHOP_VIEW_NODE_FACTORY.make_texture("TreasureChestOptionIcon", root)
		icon.texture = _visuals.icon_for_key(String(content.get("icon_key", "")))
		icon.position = Vector2(42, 92)
		icon.size = Vector2(124, 104)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "PICK", Rect2(Vector2(22, 196), Vector2(164, 42)), GOLD_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER)
	_skip_button.visible = true
	_skip_button.disabled = false


func apply_chrome() -> void:
	ensure_overlay()
	if _overlay == null:
		return
	_modal.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.05, 0.06, 0.08, 0.98), GOLD_COLOR, 3, 12, Vector4(8, 6, 8, 6)))
	_overlay.color = OVERLAY_COLOR
	SHOP_VIEW_CHROME_STYLER.apply_button_chrome(_skip_button, Color(0.20, 0.07, 0.06, 0.96), Color(0.90, 0.36, 0.30, 1.0), Color(0.30, 0.10, 0.08, 0.98))
	_skip_button.add_theme_color_override("font_color", INK_COLOR)
	_skip_button.add_theme_font_size_override("font_size", 24)


func layout(root_size: Vector2) -> void:
	ensure_overlay()
	if _overlay == null:
		return
	_apply_rect(_overlay, Rect2(Vector2.ZERO, root_size))
	_apply_rect(_modal, MODAL_RECT)
	_apply_rect(_title_label, TITLE_RECT)
	_apply_rect(_hint_label, HINT_RECT)
	for index in _option_buttons.size():
		_apply_rect(_option_buttons[index], Rect2(Vector2(46 + float(index) * 238.0, 150), OPTION_SIZE))
	_apply_rect(_skip_button, SKIP_RECT)


func overlay() -> ColorRect:
	return _overlay


func modal() -> Panel:
	return _modal


func title_label() -> Label:
	return _title_label


func hint_label() -> Label:
	return _hint_label


func option_buttons() -> Array[Button]:
	return _option_buttons.duplicate()


func skip_button() -> Button:
	return _skip_button


func _lookup_content_definition(content_id: String) -> Dictionary:
	if not _content_lookup.is_valid():
		return {}
	var result: Variant = _content_lookup.call(content_id)
	if result is Dictionary:
		return result
	return {}


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size
