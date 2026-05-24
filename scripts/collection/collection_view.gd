extends RefCounted
class_name CollectionView

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const COLLECTION_CARD_RENDERER_PATH := "res://scripts/ui/collection_card_renderer.gd"
const COLLECTION_CARD_RENDERER := preload("res://scripts/ui/collection_card_renderer.gd")
const BACKGROUND_PATH := "res://resources/art/assetgen/backgrounds/collection_background_candidate_01.png"

const COLLECTION_CARD_SIZE := COLLECTION_CARD_RENDERER.CARD_SIZE
const COLLECTION_CARD_SURFACE_RECT := COLLECTION_CARD_RENDERER.CARD_SURFACE_RECT
const COLLECTION_CARD_TITLE_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_RECT
const COLLECTION_CARD_TITLE_PREFIX_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_PREFIX_RECT
const COLLECTION_CARD_TITLE_NAME_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_NAME_RECT
const COLLECTION_CARD_ART_RECT := COLLECTION_CARD_RENDERER.CARD_ART_RECT
const COLLECTION_CARD_COPY_RECT := COLLECTION_CARD_RENDERER.CARD_COPY_RECT
const COLLECTION_CARD_BADGE_RECT := COLLECTION_CARD_RENDERER.CARD_BADGE_RECT
const COLLECTION_HUD_ICON_SIZE := Vector2(58, 58)
const COLLECTION_HUD_ICON_INSET := 8.0
const COLLECTION_CARD_GRID_GAP := 16.0
const COLLECTION_FAMILY_PANEL_PADDING := 36.0
const COLLECTION_CARD_COPY_MAX_CHARS := COLLECTION_CARD_RENDERER.CARD_COPY_MAX_CHARS

const GOLD_COLOR := Color(0.94, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.97, 0.90, 0.76, 1.0)
const MUTED_COLOR := Color(0.72, 0.63, 0.47, 1.0)
const POSITIVE_COLOR := Color(0.62, 0.88, 0.56, 1.0)
const NEGATIVE_COLOR := Color(0.94, 0.45, 0.38, 1.0)
const RARITY_TITLE_COLORS := COLLECTION_CARD_RENDERER.RARITY_TITLE_COLORS
const RARITY_SURFACE_COLORS := COLLECTION_CARD_RENDERER.RARITY_SURFACE_COLORS
const RARITY_GLOW_COLORS := COLLECTION_CARD_RENDERER.RARITY_GLOW_COLORS

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
	var card_renderer: GDScript = ResourceLoader.load(COLLECTION_CARD_RENDERER_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
	var card_snapshot: Dictionary = {}
	var snapshot_value: Variant = card_renderer.call("layout_snapshot")
	if snapshot_value is Dictionary:
		card_snapshot = snapshot_value
	return {
		"family_count": 5,
		"tiers_per_family": 3,
		"card_rect": card_snapshot.get("card_rect", Rect2()),
		"title_rect": card_snapshot.get("title_rect", Rect2()),
		"art_rect": card_snapshot.get("art_rect", Rect2()),
		"copy_rect": card_snapshot.get("copy_rect", Rect2()),
		"badge_rect": card_snapshot.get("badge_rect", Rect2()),
		"hud_icon_size": COLLECTION_HUD_ICON_SIZE,
		"renders_rarity_tag": card_snapshot.get("renders_rarity_tag", false),
		"common_surface": card_snapshot.get("common_surface", RARITY_SURFACE_COLORS["common"]),
		"uncommon_surface": card_snapshot.get("uncommon_surface", RARITY_SURFACE_COLORS["uncommon"]),
		"rare_surface": card_snapshot.get("rare_surface", RARITY_SURFACE_COLORS["rare"]),
		"portrait_columns": 1,
		"wide_columns": 3,
		"uses_horizontal_scroll": false,
		"copy_max_chars": card_snapshot.get("copy_max_chars", COLLECTION_CARD_COPY_MAX_CHARS),
		"copy_font_size": card_snapshot.get("copy_font_size", COLLECTION_CARD_RENDERER.CARD_COPY_FONT_SIZE),
		"badge_font_size": card_snapshot.get("badge_font_size", COLLECTION_CARD_RENDERER.CARD_BADGE_FONT_SIZE),
		"copy_outline_size": card_snapshot.get("copy_outline_size", COLLECTION_CARD_RENDERER.CARD_COPY_OUTLINE_SIZE),
		"badge_outline_size": card_snapshot.get("badge_outline_size", COLLECTION_CARD_RENDERER.CARD_BADGE_OUTLINE_SIZE),
		"title_overlaps_art": card_snapshot.get("title_overlaps_art", false),
		"title_overlaps_copy": card_snapshot.get("title_overlaps_copy", false),
		"art_overlaps_copy": card_snapshot.get("art_overlaps_copy", false),
		"copy_overlaps_badge": card_snapshot.get("copy_overlaps_badge", false),
		"badge_inside_card": card_snapshot.get("badge_inside_card", false),
		"art_inside_card": card_snapshot.get("art_inside_card", false),
		"copy_uses_ellipsis": card_snapshot.get("copy_uses_ellipsis", true),
		"active_badge_pops": card_snapshot.get("active_badge_pops", false),
		"active_badge_uses_external_shadow": card_snapshot.get("active_badge_uses_external_shadow", true),
		"active_badge_rect_glow_visible": card_snapshot.get("active_badge_rect_glow_visible", true),
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
	var button := Button.new()
	button.name = "CollectionTierCard_%s" % String(tier.get("item_id", "unknown"))
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	COLLECTION_CARD_RENDERER.render_card(button, _visuals, tier, {
		"disabled": not bool(tier.get("card_claim_enabled", false)),
		"tooltip_text": _card_tooltip_text(tier),
		"mouse_cursor": Control.CURSOR_POINTING_HAND if bool(tier.get("card_claim_enabled", false)) else Control.CURSOR_ARROW,
	})
	if bool(tier.get("card_claim_enabled", false)):
		button.pressed.connect(_on_claim_button_pressed.bind(claim_pressed, tier.duplicate(true)))
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


func _card_tooltip_text(tier: Dictionary) -> String:
	if bool(tier.get("card_claim_enabled", false)):
		return "Claim %s." % String(tier.get("item_display_name", "item"))
	if bool(tier.get("unlocked", false)):
		return "%s is already claimed." % String(tier.get("item_display_name", "Item"))
	return String(tier.get("requirement_text", "Locked."))


func _tier_rarity(tier: Dictionary) -> String:
	var rarity := String(tier.get("rarity", tier.get("tier_id", "common"))).to_lower()
	if not RARITY_SURFACE_COLORS.has(rarity):
		return "common"
	return rarity


func _rarity_title_color(rarity: String) -> Color:
	return Color(RARITY_TITLE_COLORS.get(rarity, RARITY_TITLE_COLORS["common"]))


func _on_claim_button_pressed(claim_pressed: Callable, payload: Dictionary) -> void:
	if claim_pressed.is_valid():
		claim_pressed.call(payload)
