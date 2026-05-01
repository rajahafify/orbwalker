extends Control

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PANEL_WIDTH := 1048.0
const PREVIEW_PANEL_FRAME_PATH := "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_panel_frame.png"
const PREVIEW_CARD_PATH_BY_ORB_ID := {
	OrbType.Id.FIRE: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_fire.png",
	OrbType.Id.ICE: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_ice.png",
	OrbType.Id.EARTH: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_earth.png",
	OrbType.Id.HEART: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_heart.png",
	OrbType.Id.ARMOR: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_armor.png",
	OrbType.Id.GOLD: "res://resources/art/first_pass/derived/ui_chrome/mastery_preview_card_gold.png",
}
const REAL_MASTERY_ICON_PATH_BY_ORB_ID := {
	OrbType.Id.FIRE: "res://resources/art/first_pass/derived/icons/mastery_fire.png",
	OrbType.Id.ICE: "res://resources/art/first_pass/derived/icons/mastery_ice.png",
	OrbType.Id.EARTH: "res://resources/art/first_pass/derived/icons/mastery_earth.png",
	OrbType.Id.HEART: "res://resources/art/first_pass/derived/icons/mastery_heart.png",
	OrbType.Id.ARMOR: "res://resources/art/first_pass/derived/icons/mastery_armor.png",
	OrbType.Id.GOLD: "res://resources/art/first_pass/derived/icons/mastery_gold.png",
}
const ORB_IDS: Array[int] = [
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
]

var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _texture_cache: Dictionary = {}

@onready var _background: ColorRect = %Background
@onready var _variant_list: VBoxContainer = %VariantList


func _ready() -> void:
	_background.color = Color(0.035, 0.045, 0.065, 1.0)
	_build_variant_gallery()


func _build_variant_gallery() -> void:
	_clear_children(_variant_list)
	_variant_list.add_child(_make_page_header())
	for spec in _variant_specs():
		_variant_list.add_child(_make_variant_section(spec))


func _make_page_header() -> Control:
	var header := VBoxContainer.new()
	header.custom_minimum_size = Vector2(PANEL_WIDTH, 86.0)

	var title := Label.new()
	title.text = "Elemental Mastery HUD Variants"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.98, 0.92, 0.62, 1.0))
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_color_override("font_outline_color", Color(0.06, 0.04, 0.02, 0.95))
	header.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Reference study: 5 composed card styles using contained mastery icons"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.82, 0.84, 0.90, 0.95))
	header.add_child(subtitle)
	return header


func _make_variant_section(spec: Dictionary) -> Control:
	var section := VBoxContainer.new()
	var panel_height := float(spec.get("panel_height", 348.0))
	section.custom_minimum_size = Vector2(PANEL_WIDTH, panel_height + 118.0)
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 8)

	var title := Label.new()
	title.text = String(spec.get("title", "Variant"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color(0.95, 0.89, 0.66, 1.0))
	title.add_theme_constant_override("outline_size", 1)
	title.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.02, 0.95))
	section.add_child(title)

	var note := Label.new()
	note.text = String(spec.get("note", ""))
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	note.add_theme_font_size_override("font_size", 16)
	note.add_theme_color_override("font_color", Color(0.78, 0.82, 0.88, 0.92))
	section.add_child(note)

	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.custom_minimum_size = Vector2(PANEL_WIDTH, panel_height + 8.0)
	section.add_child(center)

	var sample := Control.new()
	sample.custom_minimum_size = Vector2(PANEL_WIDTH, panel_height)
	sample.size = sample.custom_minimum_size
	center.add_child(sample)
	_build_mastery_panel(sample, spec)

	return section


func _build_mastery_panel(parent: Control, spec: Dictionary) -> void:
	var panel_size := Vector2(PANEL_WIDTH, float(spec.get("panel_height", 348.0)))
	var card_size := Vector2(spec.get("card_size", Vector2(156.0, 198.0)))
	var card_gap := float(spec.get("card_gap", 8.0))
	var side_padding := float(spec.get("side_padding", 32.0))
	var cards_top := float(spec.get("cards_top", 126.0))

	var panel := Control.new()
	panel.name = "ReferenceMasteryPanel"
	panel.custom_minimum_size = panel_size
	panel.size = panel_size
	panel.clip_contents = true
	parent.add_child(panel)

	var frame := TextureRect.new()
	frame.name = "MasteryPreviewPanelFrame"
	frame.texture = _preview_panel_frame()
	frame.position = Vector2.ZERO
	frame.size = panel_size
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.modulate = Color(1.0, 1.0, 1.0, float(spec.get("frame_alpha", 1.0)))
	panel.add_child(frame)

	var title_label := Label.new()
	title_label.text = "ELEMENTAL MASTERY"
	title_label.position = Vector2(0.0, float(spec.get("title_y", 32.0)))
	title_label.size = Vector2(panel_size.x, float(spec.get("title_height", 68.0)))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", int(spec.get("title_font_size", 48)))
	title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
	title_label.add_theme_constant_override("outline_size", 3)
	title_label.add_theme_color_override("font_outline_color", Color(0.08, 0.04, 0.00, 0.98))
	panel.add_child(title_label)

	var total_cards_width := card_size.x * float(ORB_IDS.size()) + card_gap * float(ORB_IDS.size() - 1)
	var start_x := (panel_size.x - total_cards_width) * 0.5
	if start_x < side_padding:
		start_x = side_padding

	for index in range(ORB_IDS.size()):
		var orb_id := int(ORB_IDS[index])
		var card := _make_mastery_card(orb_id, spec, card_size)
		card.position = Vector2(start_x + float(index) * (card_size.x + card_gap), cards_top)
		panel.add_child(card)


func _make_mastery_card(orb_id: int, spec: Dictionary, card_size: Vector2) -> Control:
	var card := Control.new()
	card.name = "VariantCard%d" % orb_id
	card.custom_minimum_size = card_size
	card.size = card_size
	card.clip_contents = true

	var background := TextureRect.new()
	background.name = "CardArt"
	background.texture = _preview_card_for_orb(orb_id)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.modulate = Color(1.0, 1.0, 1.0, float(spec.get("card_alpha", 1.0)))
	card.add_child(background)

	var emblem_size := float(spec.get("emblem_size", 112.0))
	var emblem_holder := Control.new()
	emblem_holder.name = "MasteryPreviewEmblemHolder"
	emblem_holder.size = Vector2(emblem_size, emblem_size)
	emblem_holder.position = Vector2((card_size.x - emblem_size) * 0.5, float(spec.get("emblem_y", 22.0)))
	emblem_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(emblem_holder)

	var emblem := TextureRect.new()
	emblem.name = "RealMasteryIcon"
	emblem.texture = _real_mastery_icon_for_orb(orb_id)
	emblem.set_anchors_preset(Control.PRESET_FULL_RECT)
	emblem.offset_left = 0.0
	emblem.offset_top = 0.0
	emblem.offset_right = 0.0
	emblem.offset_bottom = 0.0
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.stretch_mode = TextureRect.STRETCH_SCALE
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem_holder.add_child(emblem)

	var name_label := _make_card_label(
		OrbType.display_name(orb_id),
		Vector2(8.0, float(spec.get("name_y", 132.0))),
		Vector2(card_size.x - 16.0, float(spec.get("name_height", 38.0))),
		int(spec.get("card_name_font_size", 28)),
		Color(0.96, 0.89, 0.72, 1.0)
	)
	name_label.name = "MasteryName"
	card.add_child(name_label)

	var level_label := _make_card_label(
		"Lv 0",
		Vector2(8.0, float(spec.get("level_y", 170.0))),
		Vector2(card_size.x - 16.0, float(spec.get("level_height", 30.0))),
		int(spec.get("card_level_font_size", 23)),
		Color(0.99, 0.76, 0.31, 1.0)
	)
	level_label.name = "MasteryLevel"
	card.add_child(level_label)

	if bool(spec.get("feedback_ready", false)):
		var feedback := _make_card_label(
			_feedback_preview_text(orb_id),
			Vector2(8.0, float(spec.get("feedback_y", 202.0))),
			Vector2(card_size.x - 16.0, float(spec.get("feedback_height", 24.0))),
			int(spec.get("feedback_font_size", 15)),
			Color(1.0, 0.90, 0.50, 0.86)
		)
		feedback.name = "MasteryFeedback"
		card.add_child(feedback)

	return card


func _make_card_label(text: String, label_position: Vector2, label_size: Vector2, font_size: int, font_color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = label_position
	label.size = label_size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.98))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _preview_panel_frame() -> Texture2D:
	return _texture_from_path(PREVIEW_PANEL_FRAME_PATH, "mastery_preview_panel_frame", Color(0.06, 0.07, 0.10, 1.0), Vector2i(1048, 348))


func _preview_card_for_orb(orb_id: int) -> Texture2D:
	var path := String(PREVIEW_CARD_PATH_BY_ORB_ID.get(orb_id, ""))
	return _texture_from_path(path, "mastery_preview_card_%d" % orb_id, OrbType.color(orb_id).darkened(0.65), Vector2i(320, 420))


func _real_mastery_icon_for_orb(orb_id: int) -> Texture2D:
	var path := String(REAL_MASTERY_ICON_PATH_BY_ORB_ID.get(orb_id, ""))
	return _texture_from_path(path, "real_mastery_icon_%d" % orb_id, OrbType.color(orb_id), Vector2i(256, 256))


func _texture_from_path(path: String, key: String, fallback_color: Color, fallback_size: Vector2i) -> Texture2D:
	if _texture_cache.has(key):
		return _texture_cache[key]
	var texture: Texture2D = null
	if path != "" and ResourceLoader.exists(path):
		var loaded: Variant = load(path)
		texture = loaded as Texture2D
	if texture == null:
		texture = _visuals.placeholder_texture("%s_missing" % key, fallback_color, fallback_size)
	_texture_cache[key] = texture
	return texture


func _feedback_preview_text(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			return "+0 DAMAGE"
		OrbType.Id.HEART:
			return "+0 HEAL"
		OrbType.Id.ARMOR:
			return "+0 ARMOR"
		OrbType.Id.GOLD:
			return "+0 GOLD"
		_:
			return "+0"


func _variant_specs() -> Array[Dictionary]:
	return [
		{
			"title": "1) Reference Faithful",
			"note": "Closest to the ornate dark/gold reference with full-height cards and large emblem badges.",
			"panel_height": 348.0,
			"card_size": Vector2(160.0, 204.0),
			"card_gap": 7.0,
			"cards_top": 121.0,
			"side_padding": 24.0,
			"emblem_size": 124.0,
			"emblem_y": 18.0,
			"name_y": 142.0,
			"level_y": 176.0,
			"title_font_size": 50,
			"title_y": 30.0,
			"frame_alpha": 1.0,
		},
		{
			"title": "2) Combat Fit (1048 x 300)",
			"note": "Condenses the reference shape while preserving the separated title band and six ornate cards.",
			"panel_height": 300.0,
			"card_size": Vector2(150.0, 168.0),
			"card_gap": 8.0,
			"cards_top": 112.0,
			"side_padding": 42.0,
			"emblem_size": 96.0,
			"emblem_y": 14.0,
			"name_y": 112.0,
			"level_y": 141.0,
			"card_name_font_size": 21,
			"card_level_font_size": 18,
			"title_font_size": 40,
			"title_y": 25.0,
			"title_height": 58.0,
			"frame_alpha": 0.98,
		},
		{
			"title": "3) Taller Mastery Section",
			"note": "Adds vertical room for the largest badge read and more reference-like card breathing room.",
			"panel_height": 390.0,
			"card_size": Vector2(160.0, 228.0),
			"card_gap": 8.0,
			"cards_top": 132.0,
			"side_padding": 24.0,
			"emblem_size": 132.0,
			"emblem_y": 20.0,
			"name_y": 158.0,
			"level_y": 194.0,
			"card_name_font_size": 30,
			"card_level_font_size": 25,
			"title_font_size": 50,
			"title_y": 34.0,
			"frame_alpha": 1.0,
		},
		{
			"title": "4) Reduced Border Noise",
			"note": "Keeps the reference silhouette but softens the frame and cards for a cleaner combat read.",
			"panel_height": 328.0,
			"card_size": Vector2(154.0, 184.0),
			"card_gap": 9.0,
			"cards_top": 118.0,
			"side_padding": 35.0,
			"emblem_size": 106.0,
			"emblem_y": 17.0,
			"name_y": 124.0,
			"level_y": 156.0,
			"card_name_font_size": 23,
			"card_level_font_size": 20,
			"title_font_size": 42,
			"title_y": 26.0,
			"frame_alpha": 0.78,
			"card_alpha": 0.92,
		},
		{
			"title": "5) Feedback Ready",
			"note": "Keeps the reference card identity while reserving a lower feedback readout for combat effects.",
			"panel_height": 368.0,
			"card_size": Vector2(156.0, 222.0),
			"card_gap": 8.0,
			"cards_top": 122.0,
			"side_padding": 32.0,
			"emblem_size": 112.0,
			"emblem_y": 16.0,
			"name_y": 130.0,
			"level_y": 160.0,
			"feedback_y": 190.0,
			"feedback_height": 24.0,
			"card_name_font_size": 24,
			"card_level_font_size": 20,
			"feedback_font_size": 14,
			"title_font_size": 46,
			"title_y": 28.0,
			"frame_alpha": 0.98,
			"feedback_ready": true,
		},
	]


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
