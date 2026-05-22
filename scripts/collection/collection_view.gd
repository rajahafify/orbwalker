extends RefCounted
class_name CollectionView

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const BACKGROUND_PATH := "res://resources/art/assetgen/backgrounds/collection_background_candidate_01.png"

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
	_overlay_tint.color = Color(0.02, 0.03, 0.05, 0.54)

	_main_margin.add_theme_constant_override("margin_left", 34)
	_main_margin.add_theme_constant_override("margin_top", 44)
	_main_margin.add_theme_constant_override("margin_right", 34)
	_main_margin.add_theme_constant_override("margin_bottom", 30)

	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.46, 1.0))
	_title_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.03, 0.95))
	_title_label.add_theme_constant_override("outline_size", 3)

	_score_label.add_theme_font_size_override("font_size", 32)
	_score_label.add_theme_color_override("font_color", Color(0.95, 0.90, 0.80, 1.0))
	_score_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.95))
	_score_label.add_theme_constant_override("outline_size", 2)

	_families_scroll.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(Color(0.05, 0.045, 0.04, 0.75), Color(0.52, 0.39, 0.20, 0.76), 2, 10, Vector4(8, 8, 8, 8))
	)
	_families_vbox.custom_minimum_size = Vector2(960, 0)

	_back_button.custom_minimum_size = Vector2(220, 62)
	_back_button.add_theme_font_size_override("font_size", 24)
	_back_button.add_theme_stylebox_override(
		"normal",
		UI_UTILS.panel_style(Color(0.14, 0.11, 0.09, 0.95), Color(0.70, 0.52, 0.24, 0.98), 2, 10, Vector4(18, 12, 18, 12))
	)
	_back_button.add_theme_stylebox_override(
		"hover",
		UI_UTILS.panel_style(Color(0.20, 0.15, 0.11, 0.98), Color(0.82, 0.64, 0.32, 1.0), 2, 10, Vector4(18, 12, 18, 12))
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
		_families_vbox.add_child(_make_family_card(family, claim_pressed))


func show_status(message: String, is_error: bool) -> void:
	_status_label.text = message
	_status_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.45, 0.41, 1.0) if is_error else Color(0.66, 0.90, 0.70, 1.0)
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


func _make_family_card(family: Dictionary, claim_pressed: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(
			Color(0.08, 0.065, 0.048, 0.94),
			Color(0.68, 0.51, 0.22, 0.96),
			2,
			12,
			Vector4(18, 14, 18, 14)
		)
	)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = String(family.get("display_name", "Family")).to_upper()
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.95, 0.86, 0.62, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 2)
	vbox.add_child(title)

	for tier in Array(family.get("tiers", [])):
		vbox.add_child(_make_tier_row(Dictionary(tier), claim_pressed))

	return panel


func _make_tier_row(tier: Dictionary, claim_pressed: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)

	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 2)
	row.add_child(text_column)

	var primary_label := Label.new()
	primary_label.text = "%s  %s" % [String(tier.get("tier_label", "TIER")), String(tier.get("item_display_name", "Unknown"))]
	primary_label.add_theme_font_size_override("font_size", 22)
	primary_label.add_theme_color_override("font_color", Color(tier.get("tier_color", Color.WHITE)))
	text_column.add_child(primary_label)

	var requirement_label := Label.new()
	requirement_label.text = String(tier.get("requirement_text", ""))
	requirement_label.add_theme_font_size_override("font_size", 16)
	requirement_label.add_theme_color_override("font_color", Color(0.78, 0.73, 0.66, 0.95))
	requirement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	text_column.add_child(requirement_label)

	var state_label := Label.new()
	state_label.custom_minimum_size = Vector2(100, 0)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	state_label.add_theme_font_size_override("font_size", 16)
	state_label.text = String(tier.get("state_text", "Locked"))
	state_label.add_theme_color_override("font_color", Color(tier.get("state_color", Color.WHITE)))
	row.add_child(state_label)

	var claim_button := Button.new()
	claim_button.custom_minimum_size = Vector2(208, 56)
	claim_button.text = String(tier.get("claim_button_text", "Claim"))
	claim_button.disabled = not bool(tier.get("claimable", false))
	claim_button.add_theme_font_size_override("font_size", 18)
	claim_button.add_theme_stylebox_override(
		"normal",
		UI_UTILS.panel_style(Color(0.20, 0.15, 0.11, 0.98), Color(0.72, 0.54, 0.22, 1.0), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.add_theme_stylebox_override(
		"hover",
		UI_UTILS.panel_style(Color(0.25, 0.18, 0.13, 1.0), Color(0.83, 0.65, 0.31, 1.0), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.add_theme_stylebox_override(
		"disabled",
		UI_UTILS.panel_style(Color(0.13, 0.10, 0.08, 0.92), Color(0.40, 0.32, 0.20, 0.86), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.pressed.connect(_on_claim_button_pressed.bind(claim_pressed, tier.duplicate(true)))
	row.add_child(claim_button)

	return row


func _on_claim_button_pressed(claim_pressed: Callable, payload: Dictionary) -> void:
	if claim_pressed.is_valid():
		claim_pressed.call(payload)
