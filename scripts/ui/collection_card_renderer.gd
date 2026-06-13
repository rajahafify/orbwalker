extends RefCounted
class_name CollectionCardRenderer

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const CARD_SIZE := Vector2(340, 485)
const CARD_SURFACE_RECT := Rect2(Vector2(36, 48), Vector2(268, 380))
const CARD_TITLE_RECT := Rect2(Vector2(52, 42), Vector2(236, 84))
const CARD_TITLE_PREFIX_RECT := Rect2(Vector2(52, 42), Vector2(236, 32))
const CARD_TITLE_NAME_RECT := Rect2(Vector2(52, 68), Vector2(236, 52))
const CARD_ART_RECT := Rect2(Vector2(80, 128), Vector2(180, 180))
const CARD_COPY_RECT := Rect2(Vector2(50, 316), Vector2(240, 80))
const CARD_BADGE_RECT := Rect2(Vector2(70, 404), Vector2(200, 58))
const CARD_COPY_MAX_CHARS := 18
const CARD_TITLE_PREFIX_FONT_SIZE := 25
const CARD_TITLE_NAME_FONT_SIZE := 30
const CARD_COPY_FONT_SIZE := 24
const CARD_BADGE_FONT_SIZE := 26
const CARD_TEXT_OUTLINE_SIZE := 3
const CARD_COPY_OUTLINE_SIZE := 4
const CARD_BADGE_OUTLINE_SIZE := 4

const INK_COLOR := Color(1.0, 0.96, 0.84, 1.0)
const BADGE_ACTIVE_COLOR := Color(1.0, 0.91, 0.58, 1.0)
const BADGE_INACTIVE_COLOR := Color(1.0, 0.84, 0.50, 1.0)
const RARITY_TITLE_COLORS := {
	"common": Color(1.0, 0.82, 0.47, 1.0),
	"uncommon": Color(0.40, 0.82, 1.0, 1.0),
	"rare": Color(0.76, 0.42, 1.0, 1.0),
}
const RARITY_SURFACE_COLORS := {
	"common": Color(0.08, 0.07, 0.055, 0.94),
	"uncommon": Color(0.02, 0.24, 0.34, 0.93),
	"rare": Color(0.17, 0.06, 0.24, 0.94),
}
const RARITY_GLOW_COLORS := {
	"common": Color(0.83, 0.55, 0.20, 0.32),
	"uncommon": Color(0.17, 0.66, 1.0, 0.34),
	"rare": Color(0.62, 0.22, 1.0, 0.36),
}


static func layout_snapshot() -> Dictionary:
	var card_rect := Rect2(Vector2.ZERO, CARD_SIZE)
	return {
		"card_rect": card_rect,
		"title_rect": CARD_TITLE_RECT,
		"title_prefix_rect": CARD_TITLE_PREFIX_RECT,
		"title_name_rect": CARD_TITLE_NAME_RECT,
		"art_rect": CARD_ART_RECT,
		"copy_rect": CARD_COPY_RECT,
		"badge_rect": CARD_BADGE_RECT,
		"surface_rect": CARD_SURFACE_RECT,
		"copy_max_chars": CARD_COPY_MAX_CHARS,
		"copy_font_size": CARD_COPY_FONT_SIZE,
		"badge_font_size": CARD_BADGE_FONT_SIZE,
		"copy_outline_size": CARD_COPY_OUTLINE_SIZE,
		"badge_outline_size": CARD_BADGE_OUTLINE_SIZE,
		"renders_rarity_tag": false,
		"common_surface": RARITY_SURFACE_COLORS["common"],
		"uncommon_surface": RARITY_SURFACE_COLORS["uncommon"],
		"rare_surface": RARITY_SURFACE_COLORS["rare"],
		"title_overlaps_art": CARD_TITLE_RECT.intersects(CARD_ART_RECT),
		"title_overlaps_copy": CARD_TITLE_RECT.intersects(CARD_COPY_RECT),
		"art_overlaps_copy": CARD_ART_RECT.intersects(CARD_COPY_RECT),
		"copy_overlaps_badge": CARD_COPY_RECT.intersects(CARD_BADGE_RECT),
		"badge_inside_card": card_rect.encloses(CARD_BADGE_RECT),
		"art_inside_card": card_rect.encloses(CARD_ART_RECT),
		"button_hover_fill_visible": false,
		"copy_uses_ellipsis": false,
		"active_badge_pops": true,
		"active_badge_uses_external_shadow": false,
		"active_badge_rect_glow_visible": false,
	}


static func render_card(button: Button, visuals, card_data: Dictionary, options: Dictionary = {}) -> void:
	UI_UTILS.clear_children(button)
	var rarity := normalized_rarity(String(card_data.get("rarity", "common")))
	button.text = ""
	button.custom_minimum_size = CARD_SIZE
	button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	button.flat = true
	button.disabled = bool(options.get("disabled", false))
	button.tooltip_text = String(options.get("tooltip_text", ""))
	button.mouse_default_cursor_shape = int(options.get("mouse_cursor", Control.CURSOR_ARROW)) as Control.CursorShape
	button.modulate = Color(options.get("modulate", Color.WHITE))
	_apply_card_button_style(button, rarity)

	var root := Control.new()
	root.name = "CardRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.custom_minimum_size = CARD_SIZE
	root.size = CARD_SIZE
	button.add_child(root)

	var glow := ColorRect.new()
	glow.name = "CardGlow"
	glow.position = CARD_SURFACE_RECT.position + Vector2(10, 58)
	glow.size = Vector2(CARD_SURFACE_RECT.size.x - 20, 116)
	glow.color = Color(RARITY_GLOW_COLORS.get(rarity, RARITY_GLOW_COLORS["common"]))
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(glow)

	var surface := Panel.new()
	surface.name = "CardSurface"
	surface.position = CARD_SURFACE_RECT.position
	surface.size = CARD_SURFACE_RECT.size
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	surface.add_theme_stylebox_override("panel", UI_UTILS.panel_style(_rarity_surface_color(rarity), Color(0, 0, 0, 0), 0, 20, Vector4.ZERO))
	root.add_child(surface)

	var frame := TextureRect.new()
	frame.name = "CardFrame"
	frame.position = Vector2.ZERO
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	frame.texture = visuals.collection_card_frame(rarity)
	frame.custom_minimum_size = CARD_SIZE
	frame.size = CARD_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(frame)

	_make_card_title(root, String(card_data.get("display_name", card_data.get("item_display_name", "Unknown Item"))), _rarity_title_color(rarity))

	var item_art := TextureRect.new()
	item_art.name = "ItemArt"
	item_art.position = CARD_ART_RECT.position
	item_art.clip_contents = true
	item_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	item_art.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	item_art.texture = visuals.icon_for_key(String(card_data.get("icon_key", "")))
	item_art.custom_minimum_size = CARD_ART_RECT.size
	item_art.size = CARD_ART_RECT.size
	item_art.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(item_art)

	_make_card_label(
		root,
		"CardCopy",
		_wrap_card_copy_text(String(card_data.get("description", ""))),
		CARD_COPY_RECT,
		INK_COLOR,
		CARD_COPY_FONT_SIZE,
		HORIZONTAL_ALIGNMENT_LEFT,
		true,
		CARD_COPY_OUTLINE_SIZE
	)

	_make_badge(
		root,
		visuals,
		String(card_data.get("badge_text", card_data.get("card_badge_text", ""))),
		CARD_BADGE_RECT,
		bool(card_data.get("badge_enabled", card_data.get("card_claim_enabled", false)))
	)


static func normalized_rarity(rarity: String) -> String:
	var clean := rarity.strip_edges().to_lower()
	if clean == "epic":
		return "rare"
	if not RARITY_SURFACE_COLORS.has(clean):
		return "common"
	return clean


static func rarity_title_color(rarity: String) -> Color:
	return _rarity_title_color(normalized_rarity(rarity))


static func _apply_card_button_style(button: Button, _rarity: String) -> void:
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, _transparent_button_stylebox())


static func _transparent_button_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.set_border_width_all(0)
	style.set_corner_radius_all(0)
	style.set_content_margin_all(0)
	return style


static func _make_card_title(parent: Control, display_name: String, color: Color) -> void:
	var parts := _split_card_title(display_name)
	_make_card_label(
		parent,
		"CardNamePrefix",
		String(parts.get("prefix", display_name)),
		CARD_TITLE_PREFIX_RECT,
		color,
		CARD_TITLE_PREFIX_FONT_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		false,
		CARD_TEXT_OUTLINE_SIZE
	)
	_make_card_label(
		parent,
		"CardNameItem",
		String(parts.get("name", "")),
		CARD_TITLE_NAME_RECT,
		color,
		CARD_TITLE_NAME_FONT_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		true,
		CARD_TEXT_OUTLINE_SIZE
	)


static func _make_badge(parent: Control, visuals, text: String, rect: Rect2, active: bool) -> void:
	var badge_texture_value: Texture2D = visuals.collection_price_badge()
	var badge_rect := rect.grow_individual(2, 1, 2, 1) if active else rect
	var badge_texture := TextureRect.new()
	badge_texture.name = "CardBadgeFrame"
	badge_texture.position = badge_rect.position
	badge_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	badge_texture.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	badge_texture.texture = badge_texture_value
	badge_texture.custom_minimum_size = badge_rect.size
	badge_texture.size = badge_rect.size
	badge_texture.modulate = Color(1.08, 1.04, 0.94, 1.0) if active else Color(0.72, 0.70, 0.66, 0.78)
	badge_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(badge_texture)

	var label := _make_card_label(
		parent,
		"CardBadgeLabel",
		text,
		badge_rect,
		BADGE_ACTIVE_COLOR if active else BADGE_INACTIVE_COLOR,
		CARD_BADGE_FONT_SIZE,
		HORIZONTAL_ALIGNMENT_CENTER,
		false,
		CARD_BADGE_OUTLINE_SIZE
	)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


static func _make_card_label(
	parent: Control,
	node_name: String,
	text: String,
	rect: Rect2,
	color: Color,
	font_size: int,
	alignment: HorizontalAlignment,
	should_wrap: bool = false,
	outline_size: int = CARD_TEXT_OUTLINE_SIZE
) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.autowrap_mode = (TextServer.AUTOWRAP_WORD_SMART if should_wrap else TextServer.AUTOWRAP_OFF) as TextServer.AutowrapMode
	label.clip_contents = not should_wrap
	label.clip_text = not should_wrap
	label.text_overrun_behavior = (TextServer.OVERRUN_NO_TRIMMING if should_wrap else TextServer.OVERRUN_TRIM_ELLIPSIS) as TextServer.OverrunBehavior
	label.custom_minimum_size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.96))
	label.add_theme_constant_override("outline_size", outline_size)
	parent.add_child(label)
	label.position = rect.position
	label.size = rect.size
	return label


static func _split_card_title(value: String) -> Dictionary:
	var words := value.strip_edges().split(" ", false)
	if words.size() <= 1:
		return {"prefix": value, "name": ""}
	var rest: Array[String] = []
	for index in range(1, words.size()):
		rest.append(String(words[index]))
	return {"prefix": String(words[0]), "name": " ".join(rest)}


static func _wrap_card_copy_text(value: String) -> String:
	var lines: Array[String] = []
	for raw_segment in value.strip_edges().split("\n", false):
		var words := String(raw_segment).strip_edges().split(" ", false)
		var current := ""
		for word_value in words:
			var word := String(word_value)
			var candidate := word if current == "" else "%s %s" % [current, word]
			if candidate.length() > CARD_COPY_MAX_CHARS and current != "":
				lines.append(current)
				current = word
			else:
				current = candidate
		if current != "":
			lines.append(current)
	return "\n".join(lines)


static func _rarity_title_color(rarity: String) -> Color:
	return Color(RARITY_TITLE_COLORS.get(rarity, RARITY_TITLE_COLORS["common"]))


static func _rarity_surface_color(rarity: String) -> Color:
	return Color(RARITY_SURFACE_COLORS.get(rarity, RARITY_SURFACE_COLORS["common"]))
