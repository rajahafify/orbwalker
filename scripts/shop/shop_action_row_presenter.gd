extends RefCounted
class_name ShopActionRowPresenter

signal reroll_pressed
signal sell_pressed
signal continue_pressed

const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW_CHROME_STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")

const ACTION_HINT_RECT := SHOP_LAYOUT_METRICS.ACTION_HINT_RECT
const ACTION_REROLL_RECT := SHOP_LAYOUT_METRICS.ACTION_REROLL_RECT
const ACTION_CONTINUE_RECT := SHOP_LAYOUT_METRICS.ACTION_CONTINUE_RECT
const ACTION_BUTTON_FONT_SIZE := SHOP_LAYOUT_METRICS.ACTION_BUTTON_FONT_SIZE
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)

var _parent: Control
var _visuals: Variant = null
var _row: Control
var _action_hint_label: Label
var _reroll_button: Button
var _sell_equipment_button: Button
var _continue_button: Button


func bind(parent: Control, visuals: Variant) -> void:
	_parent = parent
	_visuals = visuals


func ensure_row() -> void:
	if _row != null or _parent == null:
		return
	_row = Control.new()
	_row.name = "ActionRow"
	_parent.add_child(_row)
	_action_hint_label = SHOP_VIEW_NODE_FACTORY.make_label("ActionHintLabel", _row, "SELL TIP: Tap a filled loadout slot, then press Sell in the slot popover.", 20, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	_action_hint_label.visible = false
	_reroll_button = SHOP_VIEW_NODE_FACTORY.make_button("RerollButton", _row, "Reroll")
	_sell_equipment_button = SHOP_VIEW_NODE_FACTORY.make_button("SellEquipmentButton", _row, "Sell Selected")
	_continue_button = SHOP_VIEW_NODE_FACTORY.make_button("ContinueButton", _row, "Continue")
	_reroll_button.pressed.connect(_on_reroll_pressed)
	_sell_equipment_button.pressed.connect(_on_sell_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)


func render(shop_snapshot: Dictionary, treasure_chest_pending: bool) -> void:
	ensure_row()
	if _row == null:
		return
	var active := bool(shop_snapshot.get("active", false))
	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.disabled = treasure_chest_pending or not active or not bool(shop_snapshot.get("reroll_enabled", false))
	_render_action_button_label(
		_reroll_button,
		"REROLL",
		"(FREE)" if reroll_cost <= 0 else "($%d)" % reroll_cost,
		_reroll_button.disabled
	)
	_action_hint_label.visible = false
	_sell_equipment_button.visible = false
	_sell_equipment_button.disabled = true
	_continue_button.disabled = not bool(shop_snapshot.get("continue_enabled", not treasure_chest_pending))
	_render_action_button_label(_continue_button, "CONTINUE", "", _continue_button.disabled)


func layout(action_rect: Rect2) -> void:
	ensure_row()
	_apply_rect(_row, action_rect)
	_apply_rect(_action_hint_label, ACTION_HINT_RECT)
	_apply_rect(_reroll_button, ACTION_REROLL_RECT)
	_apply_rect(_continue_button, ACTION_CONTINUE_RECT)
	_apply_rect(_sell_equipment_button, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))


func apply_chrome() -> void:
	ensure_row()
	if _row == null:
		return
	SHOP_VIEW_CHROME_STYLER.apply_action_button_chrome(_reroll_button, _visuals, "reroll")
	SHOP_VIEW_CHROME_STYLER.apply_button_chrome(_sell_equipment_button, Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0), Color(0.28, 0.18, 0.09, 0.98))
	SHOP_VIEW_CHROME_STYLER.apply_action_button_chrome(_continue_button, _visuals, "continue")
	_action_hint_label.add_theme_color_override("font_color", GOLD_COLOR)
	for button in [_reroll_button, _sell_equipment_button, _continue_button]:
		(button as Button).add_theme_color_override("font_color", INK_COLOR)
		(button as Button).add_theme_font_size_override("font_size", 24)
	_reroll_button.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 1.0))
	_continue_button.add_theme_color_override("font_color", Color(0.96, 0.91, 0.80, 1.0))
	_reroll_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	_continue_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)


func row() -> Control:
	ensure_row()
	return _row


func action_hint_label() -> Label:
	ensure_row()
	return _action_hint_label


func reroll_button() -> Button:
	ensure_row()
	return _reroll_button


func sell_equipment_button() -> Button:
	ensure_row()
	return _sell_equipment_button


func continue_button() -> Button:
	ensure_row()
	return _continue_button


func _render_action_button_label(button: Button, action_text: String, cost_text: String, disabled: bool) -> void:
	button.text = action_text if cost_text == "" else "%s %s" % [action_text, cost_text]
	button.tooltip_text = ""
	button.modulate = Color(0.62, 0.62, 0.64, 0.78) if disabled else Color.WHITE


func _on_reroll_pressed() -> void:
	emit_signal("reroll_pressed")


func _on_sell_pressed() -> void:
	emit_signal("sell_pressed")


func _on_continue_pressed() -> void:
	emit_signal("continue_pressed")


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size
