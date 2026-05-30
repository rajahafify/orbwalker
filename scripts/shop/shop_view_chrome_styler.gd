extends RefCounted
class_name ShopViewChromeStyler

const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const ACTION_BUTTON_TEXTURE_MARGIN := SHOP_LAYOUT_METRICS.ACTION_BUTTON_TEXTURE_MARGIN
const ACTION_BUTTON_CONTENT_MARGIN := SHOP_LAYOUT_METRICS.ACTION_BUTTON_CONTENT_MARGIN
const ACTION_BUTTON_FONT_SIZE := SHOP_LAYOUT_METRICS.ACTION_BUTTON_FONT_SIZE
const RELIC_PRICE_FONT_SIZE := SHOP_LAYOUT_METRICS.RELIC_PRICE_FONT_SIZE
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const NEGATIVE_COLOR := Color(1.0, 0.45, 0.38, 1.0)
const RELIC_UNAVAILABLE_PRICE_FRAME_MODULATE := Color(0.34, 0.28, 0.21, 0.52)
const RELIC_UNAVAILABLE_PRICE_TEXT_COLOR := Color(0.52, 0.42, 0.30, 0.70)


static func apply_card_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.18), 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


static func apply_transparent_button_chrome(button: Button) -> void:
	button.flat = true
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())


static func apply_action_button_chrome(button: Button, visuals: Variant, kind: String) -> void:
	var texture: Texture2D = visuals.shop_action_button_frame(kind)
	var normal := action_button_stylebox(texture, Color(1.0, 1.0, 1.0, 1.0))
	var hover := action_button_stylebox(texture, Color(1.08, 1.06, 0.98, 1.0))
	var pressed := action_button_stylebox(texture, Color(0.88, 0.86, 0.82, 1.0))
	var disabled := action_button_stylebox(texture, Color(0.52, 0.52, 0.54, 0.70))
	button.flat = false
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", INK_COLOR)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.86, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.88, 0.84, 0.74, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.66, 0.66, 0.68, 0.82))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.90))
	button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)


static func action_button_stylebox(texture: Texture2D, modulate_color: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = ACTION_BUTTON_TEXTURE_MARGIN
	style.texture_margin_right = ACTION_BUTTON_TEXTURE_MARGIN
	style.texture_margin_top = 28
	style.texture_margin_bottom = 28
	style.content_margin_left = ACTION_BUTTON_CONTENT_MARGIN
	style.content_margin_right = ACTION_BUTTON_CONTENT_MARGIN
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	style.modulate_color = modulate_color
	return style


static func apply_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.16), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


static func apply_round_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.16), 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


static func make_price_badge(parent: Node, visuals: Variant, rect: Rect2, text: String, disabled: bool) -> void:
	var disabled_affordability := disabled and text.begins_with("$")
	var sold_or_blocked := text == "SOLD OUT" or text == "WAIT CHEST"
	var label_color := GOLD_COLOR
	if disabled:
		if disabled_affordability:
			label_color = RELIC_UNAVAILABLE_PRICE_TEXT_COLOR
		elif sold_or_blocked:
			label_color = GOLD_COLOR if text == "WAIT CHEST" else NEGATIVE_COLOR
		else:
			label_color = MUTED_COLOR
	var badge_texture_value: Texture2D = visuals.collection_price_badge()
	var badge_rect := rect.grow_individual(2, 1, 2, 1) if not disabled else rect
	var badge_frame := SHOP_VIEW_NODE_FACTORY.make_texture("PriceBadgeFrame", parent)
	badge_frame.position = badge_rect.position
	badge_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	badge_frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	badge_frame.texture = badge_texture_value
	badge_frame.custom_minimum_size = badge_rect.size
	badge_frame.size = badge_rect.size
	badge_frame.modulate = Color(1.08, 1.04, 0.94, 1.0) if not disabled else RELIC_UNAVAILABLE_PRICE_FRAME_MODULATE
	var font_size := RELIC_PRICE_FONT_SIZE if text.begins_with("$") else 20
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(parent, text, badge_rect, label_color, font_size, HORIZONTAL_ALIGNMENT_CENTER)
