extends RefCounted
class_name RunSummaryView

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const BACKGROUND_PATH := "res://resources/art/assetgen/backgrounds/run_summary_background_candidate_01.png"

const COLOR_PANEL := Color(0.07, 0.055, 0.045, 0.94)
const COLOR_PANEL_EDGE := Color(0.86, 0.63, 0.24, 1.0)
const COLOR_CARD := Color(0.13, 0.105, 0.08, 0.94)
const COLOR_CARD_EDGE := Color(0.42, 0.30, 0.13, 1.0)
const COLOR_TEXT := Color(0.94, 0.88, 0.74, 1.0)
const COLOR_MUTED := Color(0.72, 0.66, 0.54, 1.0)
const COLOR_GOLD := Color(1.0, 0.77, 0.25, 1.0)
const COLOR_VICTORY := Color(1.0, 0.86, 0.36, 1.0)
const COLOR_DEFEAT := Color(0.95, 0.36, 0.32, 1.0)
const TITLE_FONT_SIZE := 62
const SUMMARY_FONT_SIZE := 30
const STAT_LABEL_FONT_SIZE := 24
const STAT_VALUE_FONT_SIZE := 44
const LOADOUT_HEADING_FONT_SIZE := 26
const LOADOUT_BODY_FONT_SIZE := 30
const ACTION_BUTTON_FONT_SIZE := 32

var _summary_label: Label
var _title_label: Label
var _center_container: CenterContainer
var _panel_container: PanelContainer
var _content_box: VBoxContainer
var _new_run_button: Button
var _main_menu_button: Button
var _achievement_toast: Control


func bind(root_nodes: Dictionary) -> void:
	_summary_label = root_nodes.get("summary_label") as Label
	_title_label = root_nodes.get("title_label") as Label
	_center_container = root_nodes.get("center_container") as CenterContainer
	_panel_container = root_nodes.get("panel_container") as PanelContainer
	_content_box = root_nodes.get("content_box") as VBoxContainer
	_new_run_button = root_nodes.get("new_run_button") as Button
	_main_menu_button = root_nodes.get("main_menu_button") as Button
	_achievement_toast = root_nodes.get("achievement_toast") as Control


func apply_static_layout(host: Control) -> void:
	var background := TextureRect.new()
	background.name = "SummaryBackground"
	background.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	background.texture = load(BACKGROUND_PATH)
	background.modulate = Color(0.52, 0.48, 0.42, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	host.add_child(background)
	host.move_child(background, 0)

	var scrim := ColorRect.new()
	scrim.name = "SummaryScrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	scrim.color = Color(0.02, 0.018, 0.014, 0.54)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	host.add_child(scrim)
	host.move_child(scrim, 1)

	_center_container.custom_minimum_size = Vector2(1080, 1920)
	_panel_container.custom_minimum_size = Vector2(860, 1160)
	_panel_container.add_theme_stylebox_override("panel", UI_UTILS.panel_style(COLOR_PANEL, COLOR_PANEL_EDGE, 5, 22, Vector4(24, 20, 24, 20)))
	_content_box.custom_minimum_size = Vector2(760, 1020)
	_content_box.add_theme_constant_override("separation", 18)
	_content_box.add_theme_constant_override("margin_left", 34)
	_content_box.add_theme_constant_override("margin_right", 34)
	_content_box.add_theme_constant_override("margin_top", 34)
	_content_box.add_theme_constant_override("margin_bottom", 34)

	_title_label.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	_title_label.add_theme_color_override("font_color", COLOR_VICTORY)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	_summary_label.add_theme_font_size_override("font_size", SUMMARY_FONT_SIZE)
	_summary_label.add_theme_color_override("font_color", COLOR_MUTED)
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode

	_style_action_button(_new_run_button, true)
	_style_action_button(_main_menu_button, false)


static func readability_font_probe() -> Dictionary:
	return {
		"title": TITLE_FONT_SIZE,
		"summary": SUMMARY_FONT_SIZE,
		"stat_label": STAT_LABEL_FONT_SIZE,
		"stat_value": STAT_VALUE_FONT_SIZE,
		"loadout_heading": LOADOUT_HEADING_FONT_SIZE,
		"loadout_body": LOADOUT_BODY_FONT_SIZE,
		"action_button": ACTION_BUTTON_FONT_SIZE,
	}


func render_summary(
	title_text: String, subtitle_text: String, victory: bool, stats_rows: Array[Dictionary], equipment_lines: Array[String], relic_lines: Array[String]
) -> void:
	_title_label.text = title_text
	_title_label.add_theme_color_override("font_color", COLOR_VICTORY if victory else COLOR_DEFEAT)
	_summary_label.text = subtitle_text
	_summary_label.add_theme_color_override("font_color", COLOR_MUTED if victory else COLOR_DEFEAT)

	var button_parent := _new_run_button.get_parent()
	if button_parent != null:
		button_parent.remove_child(_new_run_button)
		button_parent.remove_child(_main_menu_button)

	_content_box.add_child(_make_spacer(8))
	_content_box.add_child(_make_stats_grid(stats_rows))
	_content_box.add_child(_make_loadout_section("Equipment", equipment_lines))
	_content_box.add_child(_make_loadout_section("Relics", relic_lines))
	_content_box.add_child(_make_action_row())


func set_transition_error(reason: String) -> void:
	_summary_label.text = "Transition failed: %s" % reason
	_summary_label.add_theme_color_override("font_color", COLOR_DEFEAT)


func set_action_buttons_disabled(disabled: bool) -> void:
	_new_run_button.disabled = disabled
	_main_menu_button.disabled = disabled


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


func _make_stats_grid(rows: Array[Dictionary]) -> GridContainer:
	var grid := GridContainer.new()
	grid.name = "SummaryStats"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	for row in rows:
		var accent := String(row.get("accent", ""))
		var value_color := COLOR_GOLD if accent == "gold" else COLOR_TEXT
		_add_stat_card(grid, String(row.get("label", "")), String(row.get("value", "")), value_color)
	return grid


func _add_stat_card(parent: GridContainer, label_text: String, value_text: String, value_color: Color) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(368, 118)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", UI_UTILS.panel_style(COLOR_CARD, COLOR_CARD_EDGE, 3, 14, Vector4(24, 20, 24, 20)))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER as BoxContainer.AlignmentMode
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.add_theme_font_size_override("font_size", STAT_LABEL_FONT_SIZE)
	label.add_theme_color_override("font_color", COLOR_MUTED)
	box.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	value.add_theme_font_size_override("font_size", STAT_VALUE_FONT_SIZE)
	value.add_theme_color_override("font_color", value_color)
	box.add_child(value)
	parent.add_child(card)


func _make_loadout_section(title: String, values: Array[String]) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "%sSection" % title.replace(" ", "")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.095, 0.078, 0.06, 0.92), COLOR_CARD_EDGE, 2, 12, Vector4(24, 20, 24, 20)))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	var heading := Label.new()
	heading.text = title.to_upper()
	heading.add_theme_font_size_override("font_size", LOADOUT_HEADING_FONT_SIZE)
	heading.add_theme_color_override("font_color", COLOR_GOLD)
	box.add_child(heading)
	var body := Label.new()
	body.text = "\n".join(values)
	body.add_theme_font_size_override("font_size", LOADOUT_BODY_FONT_SIZE)
	body.add_theme_color_override("font_color", COLOR_TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	box.add_child(body)
	return panel


func _make_action_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "SummaryActions"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	row.add_child(_new_run_button)
	row.add_child(_main_menu_button)
	return row


func _style_action_button(button: Button, primary: bool) -> void:
	button.custom_minimum_size = Vector2(0, 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	button.add_theme_color_override("font_color", Color(0.08, 0.055, 0.025, 1.0) if primary else COLOR_TEXT)
	var normal_color := Color(0.95, 0.68, 0.20, 1.0) if primary else Color(0.16, 0.13, 0.10, 1.0)
	var edge_color := Color(1.0, 0.86, 0.42, 1.0) if primary else COLOR_CARD_EDGE
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(normal_color, edge_color, 3, 12, Vector4(24, 20, 24, 20)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(normal_color.lightened(0.08), edge_color.lightened(0.1), 3, 12, Vector4(24, 20, 24, 20)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(normal_color.darkened(0.12), edge_color, 3, 12, Vector4(24, 20, 24, 20)))


func _make_spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, height)
	return spacer
