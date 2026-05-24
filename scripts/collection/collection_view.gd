extends RefCounted
class_name CollectionView

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const BACKGROUND_PATH := "res://resources/art/assetgen/backgrounds/collection_background_candidate_01.png"

const COLLECTION_CARD_SIZE := Vector2(340, 485)
const COLLECTION_CARD_SURFACE_RECT := Rect2(Vector2(36, 48), Vector2(268, 380))
const COLLECTION_CARD_TITLE_RECT := Rect2(Vector2(52, 42), Vector2(236, 84))
const COLLECTION_CARD_TITLE_PREFIX_RECT := Rect2(Vector2(52, 42), Vector2(236, 32))
const COLLECTION_CARD_TITLE_NAME_RECT := Rect2(Vector2(52, 68), Vector2(236, 52))
const COLLECTION_CARD_ART_RECT := Rect2(Vector2(86, 138), Vector2(168, 168))
const COLLECTION_CARD_COPY_RECT := Rect2(Vector2(52, 318), Vector2(236, 66))
const COLLECTION_CARD_BADGE_RECT := Rect2(Vector2(86, 410), Vector2(168, 48))
const COLLECTION_HUD_ICON_SIZE := Vector2(58, 58)
const COLLECTION_HUD_ICON_INSET := 8.0
const COLLECTION_CARD_GRID_GAP := 16.0
const COLLECTION_FAMILY_PANEL_PADDING := 36.0
const COLLECTION_CARD_COPY_MAX_CHARS := 24

const GOLD_COLOR := Color(0.94, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.97, 0.90, 0.76, 1.0)
const MUTED_COLOR := Color(0.72, 0.63, 0.47, 1.0)
const POSITIVE_COLOR := Color(0.62, 0.88, 0.56, 1.0)
const NEGATIVE_COLOR := Color(0.94, 0.45, 0.38, 1.0)
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

var _background_texture: TextureRect
var _overlay_tint: ColorRect
var _main_margin: MarginContainer
var _title_label: Label
var _score_label: Label
var _families_scroll: ScrollContainer
var _families_vbox: VBoxContainer
var _back_button: Button
var _status_label: Label
var _achievement_toast: Control
var _visuals = VISUAL_REGISTRY_SCRIPT.new()


func bind(root_nodes: Dictionary) -> void:
	_background_texture = root_nodes.get("background_texture") as TextureRect
	_overlay_tint = root_nodes.get("overlay_tint") as ColorRect
	_main_margin = root_nodes.get("main_margin") as MarginContainer
	_title_label = root_nodes.get("title_label") as Label
	_score_label = root_nodes.get("score_label") as Label
	_families_scroll = root_nodes.get("families_scroll") as ScrollContainer
	_families_vbox = root_nodes.get("families_vbox") as VBoxContainer
	_back_button = root_nodes.get("back_button") as Button
	_status_label = root_nodes.get("status_label") as Label
	_achievement_toast = root_nodes.get("achievement_toast") as Control


func apply_static_chrome() -> void:
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_background_texture.texture = load(BACKGROUND_PATH)
	_overlay_tint.color = Color(0.02, 0.03, 0.05, 0.58)

	_main_margin.add_theme_constant_override("margin_left", 34)
	_main_margin.add_theme_constant_override("margin_top", 34)
	_main_margin.add_theme_constant_override("margin_right", 34)
	_main_margin.add_theme_constant_override("margin_bottom", 28)

	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.46, 1.0))
	_title_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.03, 0.96))
	_title_label.add_theme_constant_override("outline_size", 3)

	_score_label.add_theme_font_size_override("font_size", 32)
	_score_label.add_theme_color_override("font_color", Color(0.95, 0.90, 0.80, 1.0))
	_score_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.96))
	_score_label.add_theme_constant_override("outline_size", 2)

	_families_scroll.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(Color(0.025, 0.028, 0.030, 0.76), Color(0.55, 0.39, 0.14, 0.78), 2, 8, Vector4(10, 10, 10, 10))
	)
	_families_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_families_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_families_vbox.custom_minimum_size = Vector2.ZERO
	_families_vbox.add_theme_constant_override("separation", 18)

	_back_button.custom_minimum_size = Vector2(220, 62)
	_back_button.add_theme_font_size_override("font_size", 24)
	_back_button.add_theme_stylebox_override(
		"normal",
		UI_UTILS.panel_style(Color(0.14, 0.11, 0.09, 0.95), Color(0.70, 0.52, 0.24, 0.98), 2, 8, Vector4(18, 12, 18, 12))
	)
	_back_button.add_theme_stylebox_override(
		"hover",
		UI_UTILS.panel_style(Color(0.20, 0.15, 0.11, 0.98), Color(0.82, 0.64, 0.32, 1.0), 2, 8, Vector4(18, 12, 18, 12))
	)

	_status_label.add_theme_font_size_override("font_size", 18)
	_status_label.add_theme_color_override("font_color", Color(0.80, 0.75, 0.68, 1.0))


func set_score_text(text: String) -> void:
	_score_label.text = text


func set_back_button_locked(locked: bool) -> void:
	_back_button.disabled = locked


func render_families(families: Array[Dictionary], claim_pressed: Callable) -> void:
	UI_UTILS.clear_children(_families_vbox)
	for family in families:
		_families_vbox.add_child(_make_family_section(family, claim_pressed))


func show_status(message: String, is_error: bool) -> void:
	_status_label.text = message
	_status_label.add_theme_color_override(
		"font_color",
		NEGATIVE_COLOR if is_error else POSITIVE_COLOR
	)


func enqueue_unlock(item_display_name: String) -> void:
	if _achievement_toast != null and _achievement_toast.has_method("enqueue_unlock"):
		_achievement_toast.call("enqueue_unlock", item_display_name)


func enqueue_unlock_entries(entries: Array[Dictionary]) -> void:
	if entries.is_empty() or _achievement_toast == null:
		return
	if _achievement_toast.has_method("enqueue_unlock_entries"):
		_achievement_toast.call("enqueue_unlock_entries", entries)
		return
	if _achievement_toast.has_method("enqueue_unlock"):
		for entry in entries:
			var display_name := String(entry.get("display_name", entry.get("item_name", entry.get("item_id", "Unknown Item"))))
			_achievement_toast.call("enqueue_unlock", display_name)


static func collection_card_layout_probe_snapshot() -> Dictionary:
	var card_rect := Rect2(Vector2.ZERO, COLLECTION_CARD_SIZE)
	var title := COLLECTION_CARD_TITLE_RECT
	var art := COLLECTION_CARD_ART_RECT
	var copy := COLLECTION_CARD_COPY_RECT
	var badge := COLLECTION_CARD_BADGE_RECT
	return {
		"family_count": 5,
		"tiers_per_family": 3,
		"card_rect": card_rect,
		"title_rect": title,
		"art_rect": art,
		"copy_rect": copy,
		"badge_rect": badge,
		"hud_icon_size": COLLECTION_HUD_ICON_SIZE,
		"renders_rarity_tag": false,
		"common_surface": RARITY_SURFACE_COLORS["common"],
		"uncommon_surface": RARITY_SURFACE_COLORS["uncommon"],
		"rare_surface": RARITY_SURFACE_COLORS["rare"],
		"portrait_columns": 1,
		"wide_columns": 3,
		"uses_horizontal_scroll": false,
		"copy_max_chars": COLLECTION_CARD_COPY_MAX_CHARS,
		"title_overlaps_art": title.intersects(art),
		"title_overlaps_copy": title.intersects(copy),
		"art_overlaps_copy": art.intersects(copy),
		"copy_overlaps_badge": copy.intersects(badge),
		"badge_inside_card": card_rect.encloses(badge),
		"art_inside_card": card_rect.encloses(art),
	}


func _make_family_section(family: Dictionary, claim_pressed: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(
			Color(0.025, 0.025, 0.022, 0.90),
			Color(0.66, 0.47, 0.16, 0.92),
			2,
			8,
			Vector4(18, 16, 18, 18)
		)
	)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = String(family.get("display_name", "Family")).to_upper()
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.50, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.96))
	title.add_theme_constant_override("outline_size", 2)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	vbox.add_child(title)

	var cards_grid := GridContainer.new()
	cards_grid.columns = _card_column_count()
	cards_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cards_grid.add_theme_constant_override("h_separation", int(COLLECTION_CARD_GRID_GAP))
	cards_grid.add_theme_constant_override("v_separation", 18)
	vbox.add_child(cards_grid)

	for tier in Array(family.get("tiers", [])):
		cards_grid.add_child(_make_card_unit(Dictionary(tier), claim_pressed))

	return panel


func _make_card_unit(tier: Dictionary, claim_pressed: Callable) -> VBoxContainer:
	var unit := VBoxContainer.new()
	unit.custom_minimum_size = Vector2(COLLECTION_CARD_SIZE.x, COLLECTION_CARD_SIZE.y + COLLECTION_HUD_ICON_SIZE.y + 8.0)
	unit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	unit.alignment = BoxContainer.ALIGNMENT_CENTER as BoxContainer.AlignmentMode
	unit.add_theme_constant_override("separation", 8)

	unit.add_child(_make_tier_card(tier, claim_pressed))
	unit.add_child(_make_hud_icon_preview(tier))
	return unit


func _make_tier_card(tier: Dictionary, claim_pressed: Callable) -> Button:
	var rarity := _tier_rarity(tier)
	var accent := _rarity_title_color(rarity)
	var button := Button.new()
	button.name = "CollectionTierCard_%s" % String(tier.get("item_id", "unknown"))
	button.text = ""
	button.custom_minimum_size = COLLECTION_CARD_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.disabled = not bool(tier.get("card_claim_enabled", false))
	button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	button.tooltip_text = _card_tooltip_text(tier)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if bool(tier.get("card_claim_enabled", false)) else Control.CURSOR_ARROW
	_apply_card_button_style(button, rarity)
	if bool(tier.get("card_claim_enabled", false)):
		button.pressed.connect(_on_claim_button_pressed.bind(claim_pressed, tier.duplicate(true)))

	var root := Control.new()
	root.name = "CardRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.custom_minimum_size = COLLECTION_CARD_SIZE
	root.size = COLLECTION_CARD_SIZE
	button.add_child(root)

	var glow := ColorRect.new()
	glow.name = "CardGlow"
	glow.position = COLLECTION_CARD_SURFACE_RECT.position + Vector2(10, 58)
	glow.size = Vector2(COLLECTION_CARD_SURFACE_RECT.size.x - 20, 116)
	glow.color = Color(RARITY_GLOW_COLORS.get(rarity, RARITY_GLOW_COLORS["common"]))
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(glow)

	var surface := Panel.new()
	surface.name = "CardSurface"
	surface.position = COLLECTION_CARD_SURFACE_RECT.position
	surface.size = COLLECTION_CARD_SURFACE_RECT.size
	surface.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	surface.add_theme_stylebox_override("panel", UI_UTILS.panel_style(_rarity_surface_color(rarity), Color(0, 0, 0, 0), 0, 20, Vector4.ZERO))
	root.add_child(surface)

	var frame := TextureRect.new()
	frame.name = "CardFrame"
	frame.position = Vector2.ZERO
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	frame.texture = _visuals.collection_card_frame(rarity)
	frame.custom_minimum_size = COLLECTION_CARD_SIZE
	frame.size = COLLECTION_CARD_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(frame)

	_make_card_title(root, String(tier.get("item_display_name", "Unknown Item")), accent)

	var item_art := TextureRect.new()
	item_art.name = "ItemArt"
	item_art.position = COLLECTION_CARD_ART_RECT.position
	item_art.clip_contents = true
	item_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	item_art.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	item_art.texture = _visuals.icon_for_key(String(tier.get("icon_key", "")))
	item_art.custom_minimum_size = COLLECTION_CARD_ART_RECT.size
	item_art.size = COLLECTION_CARD_ART_RECT.size
	item_art.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.add_child(item_art)

	_make_card_label(
		root,
		"CardCopy",
		_wrap_card_copy_text(String(tier.get("description", ""))),
		COLLECTION_CARD_COPY_RECT,
		INK_COLOR,
		17,
		HORIZONTAL_ALIGNMENT_LEFT,
		false
	)

	_make_badge(root, String(tier.get("card_badge_text", "")), COLLECTION_CARD_BADGE_RECT, bool(tier.get("card_claim_enabled", false)))
	return button


func _make_hud_icon_preview(tier: Dictionary) -> Control:
	var rarity := _tier_rarity(tier)
	var root := Control.new()
	root.name = "HudIconPreview_%s" % String(tier.get("item_id", "unknown"))
	root.custom_minimum_size = COLLECTION_HUD_ICON_SIZE
	root.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	root.size = COLLECTION_HUD_ICON_SIZE

	var frame := TextureRect.new()
	frame.name = "HudSlotFrame"
	frame.position = Vector2.ZERO
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	frame.texture = _visuals.collection_hud_slot_frame()
	frame.custom_minimum_size = COLLECTION_HUD_ICON_SIZE
	frame.size = COLLECTION_HUD_ICON_SIZE
	root.add_child(frame)

	var icon := TextureRect.new()
	icon.name = "HudSlotIcon"
	icon.position = Vector2(COLLECTION_HUD_ICON_INSET, COLLECTION_HUD_ICON_INSET)
	icon.clip_contents = true
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	icon.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	icon.texture = _visuals.icon_for_key(String(tier.get("icon_key", "")))
	icon.custom_minimum_size = COLLECTION_HUD_ICON_SIZE - Vector2(COLLECTION_HUD_ICON_INSET * 2.0, COLLECTION_HUD_ICON_INSET * 2.0)
	icon.size = COLLECTION_HUD_ICON_SIZE - Vector2(COLLECTION_HUD_ICON_INSET * 2.0, COLLECTION_HUD_ICON_INSET * 2.0)
	root.add_child(icon)

	var bonus := Label.new()
	bonus.name = "HudIconTierBonus"
	bonus.text = "+%d" % (int(tier.get("tier_index", 0)) + 1)
	bonus.position = Vector2(29, 36)
	bonus.size = Vector2(25, 18)
	bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	bonus.add_theme_font_size_override("font_size", 17)
	bonus.add_theme_color_override("font_color", _rarity_title_color(rarity))
	bonus.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.96))
	bonus.add_theme_constant_override("outline_size", 2)
	root.add_child(bonus)

	return root


func _make_badge(parent: Control, text: String, rect: Rect2, claim_enabled: bool) -> void:
	var badge_texture := TextureRect.new()
	badge_texture.name = "CardBadgeFrame"
	badge_texture.position = rect.position
	badge_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	badge_texture.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	badge_texture.texture = _visuals.collection_price_badge()
	badge_texture.custom_minimum_size = rect.size
	badge_texture.size = rect.size
	badge_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(badge_texture)

	var label := _make_card_label(
		parent,
		"CardBadgeLabel",
		text,
		rect,
		Color(1.0, 0.88, 0.56, 1.0) if claim_enabled else Color(0.94, 0.80, 0.50, 1.0),
		17,
		HORIZONTAL_ALIGNMENT_CENTER,
		false
	)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


func _make_card_title(parent: Control, display_name: String, color: Color) -> void:
	var parts := _split_card_title(display_name)
	_make_card_label(
		parent,
		"CardNamePrefix",
		String(parts.get("prefix", display_name)),
		COLLECTION_CARD_TITLE_PREFIX_RECT,
		color,
		24,
		HORIZONTAL_ALIGNMENT_CENTER,
		false
	)
	_make_card_label(
		parent,
		"CardNameItem",
		String(parts.get("name", "")),
		COLLECTION_CARD_TITLE_NAME_RECT,
		color,
		29,
		HORIZONTAL_ALIGNMENT_CENTER,
		true
	)


func _make_card_label(
	parent: Control,
	node_name: String,
	text: String,
	rect: Rect2,
	color: Color,
	font_size: int,
	alignment: HorizontalAlignment,
	should_wrap: bool = false
) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	if should_wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	else:
		label.autowrap_mode = TextServer.AUTOWRAP_OFF as TextServer.AutowrapMode
	label.clip_contents = true
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.custom_minimum_size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.96))
	label.add_theme_constant_override("outline_size", 2)
	parent.add_child(label)
	label.position = rect.position
	label.size = rect.size
	return label


func _card_column_count() -> int:
	var available_width := 0.0
	if _families_scroll != null:
		available_width = _families_scroll.size.x
		if available_width <= 0.0 and _families_scroll.is_inside_tree():
			available_width = _families_scroll.get_viewport_rect().size.x - 68.0
	var usable_width := maxf(0.0, available_width - COLLECTION_FAMILY_PANEL_PADDING)
	var column_span := COLLECTION_CARD_SIZE.x + COLLECTION_CARD_GRID_GAP
	var columns := int(floor((usable_width + COLLECTION_CARD_GRID_GAP) / column_span))
	return clampi(columns, 1, 3)


func _apply_card_button_style(button: Button, rarity: String) -> void:
	var empty := StyleBoxFlat.new()
	empty.bg_color = Color(0, 0, 0, 0)
	empty.set_border_width_all(0)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(RARITY_GLOW_COLORS.get(rarity, RARITY_GLOW_COLORS["common"]))
	hover.set_border_width_all(0)
	hover.set_corner_radius_all(10)
	for state in ["normal", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, empty)
	button.add_theme_stylebox_override("hover", hover)


func _card_tooltip_text(tier: Dictionary) -> String:
	if bool(tier.get("card_claim_enabled", false)):
		return "Claim %s." % String(tier.get("item_display_name", "item"))
	if bool(tier.get("unlocked", false)):
		return "%s is already claimed." % String(tier.get("item_display_name", "Item"))
	return String(tier.get("requirement_text", "Locked."))


func _split_card_title(value: String) -> Dictionary:
	var words := value.strip_edges().split(" ", false)
	if words.size() <= 1:
		return {"prefix": value, "name": ""}
	var rest: Array[String] = []
	for index in range(1, words.size()):
		rest.append(String(words[index]))
	return {"prefix": String(words[0]), "name": " ".join(rest)}


func _wrap_card_copy_text(value: String) -> String:
	var words := value.strip_edges().split(" ", false)
	var lines: Array[String] = []
	var current := ""
	for word_value in words:
		var word := String(word_value)
		var candidate := word if current == "" else "%s %s" % [current, word]
		if candidate.length() > COLLECTION_CARD_COPY_MAX_CHARS and current != "":
			lines.append(current)
			current = word
		else:
			current = candidate
	if current != "":
		lines.append(current)
	return "\n".join(lines)


func _tier_rarity(tier: Dictionary) -> String:
	var rarity := String(tier.get("rarity", tier.get("tier_id", "common"))).to_lower()
	if not RARITY_SURFACE_COLORS.has(rarity):
		return "common"
	return rarity


func _rarity_title_color(rarity: String) -> Color:
	return Color(RARITY_TITLE_COLORS.get(rarity, RARITY_TITLE_COLORS["common"]))


func _rarity_surface_color(rarity: String) -> Color:
	return Color(RARITY_SURFACE_COLORS.get(rarity, RARITY_SURFACE_COLORS["common"]))


func _on_claim_button_pressed(claim_pressed: Callable, payload: Dictionary) -> void:
	if claim_pressed.is_valid():
		claim_pressed.call(payload)
