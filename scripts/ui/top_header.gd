extends Panel
class_name TopHeader

signal help_pressed
signal settings_pressed
signal menu_pressed

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const DESIGN_SIZE := Vector2(1048, 116)
const TITLE_RECT := Rect2(Vector2(34, 24), Vector2(560, 68))
const GOLD_RECT := Rect2(Vector2(620, 20), Vector2(220, 76))
const HELP_RECT := Rect2(Vector2(0, 18), Vector2(76, 76))
const SETTINGS_RECT := Rect2(Vector2(0, 16), Vector2(82, 82))
const HEADER_BUTTON_GAP := 18.0
const HEADER_BUTTON_RIGHT_MARGIN := 14.0
const HIDDEN_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))

const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.95, 0.91, 0.82, 1.0)

class SettingsGlyph:
	extends Control

	var glyph_color := Color(0.95, 0.91, 0.82, 1.0)

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.23
		var tooth_inner := radius + 3.0
		var tooth_outer := radius + 9.0
		draw_arc(center, radius, 0.0, TAU, 36, glyph_color, 3.0, true)
		for index in range(8):
			var angle := TAU * float(index) / 8.0
			var direction := Vector2(cos(angle), sin(angle))
			draw_line(center + direction * tooth_inner, center + direction * tooth_outer, glyph_color, 3.0, true)
		draw_circle(center, 5.0, glyph_color)

@onready var title_label: Label = %TitleLabel
@onready var gold_pill: Panel = %GoldPill
@onready var gold_label: Label = %GoldLabel
@onready var help_button: Button = %HelpButton
@onready var settings_button: Button = %SettingsButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var crest_panel: Panel = %CrestPanel
@onready var crest_label: Label = %CrestLabel
@onready var run_progress_label: Label = %RunProgressLabel
@onready var enemy_step_label: Label = %EnemyStepLabel
@onready var debug_toggle_button: Button = %DebugToggleButton

var _settings_glyph: SettingsGlyph = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	help_button.tooltip_text = "Help"
	settings_button.tooltip_text = "Settings"
	settings_button.text = ""
	settings_button.focus_mode = Control.FOCUS_NONE
	help_button.focus_mode = Control.FOCUS_NONE
	main_menu_button.visible = false
	crest_panel.visible = false
	crest_label.visible = false
	run_progress_label.visible = false
	enemy_step_label.visible = false
	debug_toggle_button.visible = false
	help_button.pressed.connect(func() -> void: help_pressed.emit())
	settings_button.pressed.connect(func() -> void: settings_pressed.emit())
	main_menu_button.pressed.connect(func() -> void: menu_pressed.emit())
	_ensure_settings_glyph()
	_apply_chrome()
	apply_header_layout()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		apply_header_layout()


func set_title(text: String) -> void:
	if title_label != null:
		title_label.text = text


func set_gold_text(text: String) -> void:
	if gold_label != null:
		gold_label.text = _format_gold_text(text)


func set_gold_value(value: int) -> void:
	set_gold_text("$%d" % value)


func set_help_tooltip(text: String) -> void:
	help_button.tooltip_text = text


func set_settings_tooltip(text: String) -> void:
	settings_button.tooltip_text = text


func controls() -> Dictionary:
	return {
		"title_label": title_label,
		"gold_pill": gold_pill,
		"gold_label": gold_label,
		"help_button": help_button,
		"settings_button": settings_button,
		"main_menu_button": main_menu_button,
		"crest_panel": crest_panel,
		"crest_label": crest_label,
		"run_progress_label": run_progress_label,
		"enemy_step_label": enemy_step_label,
		"debug_toggle_button": debug_toggle_button,
	}


func apply_header_layout() -> void:
	_apply_rect(title_label, _local_title_rect(size))
	_apply_rect(gold_pill, _local_gold_rect(size))
	_apply_rect(gold_label, Rect2(Vector2.ZERO, gold_pill.size))
	_apply_rect(help_button, _local_help_rect(size))
	_apply_rect(settings_button, _local_settings_rect(size))
	_layout_settings_glyph()
	_apply_rect(main_menu_button, HIDDEN_RECT)
	_apply_rect(crest_panel, HIDDEN_RECT)
	_apply_rect(crest_label, Rect2(Vector2.ZERO, Vector2(1, 1)))
	_apply_rect(run_progress_label, HIDDEN_RECT)
	_apply_rect(enemy_step_label, HIDDEN_RECT)
	_apply_rect(debug_toggle_button, HIDDEN_RECT)


func layout_snapshot() -> Dictionary:
	return layout_snapshot_for(Rect2(Vector2.ZERO, size))


static func layout_snapshot_for(root_rect: Rect2) -> Dictionary:
	return {
		"title": _offset_rect(_local_title_rect(root_rect.size), root_rect.position),
		"gold_counter": _offset_rect(_local_gold_rect(root_rect.size), root_rect.position),
		"help_button": _offset_rect(_local_help_rect(root_rect.size), root_rect.position),
		"settings_button": _offset_rect(_local_settings_rect(root_rect.size), root_rect.position),
		"menu_button": HIDDEN_RECT,
		"menu_visible": false,
		"help_label": "?",
		"help_opens_modal": true,
		"settings_visible": true,
		"settings_visual_only": true,
	}


static func _local_title_rect(header_size: Vector2) -> Rect2:
	var gold_rect := _local_gold_rect(header_size)
	var title_width := maxf(240.0, gold_rect.position.x - TITLE_RECT.position.x - 26.0)
	return Rect2(Vector2(TITLE_RECT.position.x, _center_y(header_size.y, TITLE_RECT.size.y)), Vector2(title_width, TITLE_RECT.size.y))


static func _local_gold_rect(header_size: Vector2) -> Rect2:
	var x_scale := header_size.x / DESIGN_SIZE.x if DESIGN_SIZE.x > 0.0 else 1.0
	var rect := Rect2(Vector2(GOLD_RECT.position.x * x_scale, _center_y(header_size.y, minf(GOLD_RECT.size.y, header_size.y - 20.0))), GOLD_RECT.size)
	return rect


static func _local_help_rect(header_size: Vector2) -> Rect2:
	var settings_rect := _local_settings_rect(header_size)
	return Rect2(
		Vector2(settings_rect.position.x - HEADER_BUTTON_GAP - HELP_RECT.size.x, _center_y(header_size.y, HELP_RECT.size.y)),
		HELP_RECT.size
	)


static func _local_settings_rect(header_size: Vector2) -> Rect2:
	return Rect2(
		Vector2(header_size.x - HEADER_BUTTON_RIGHT_MARGIN - SETTINGS_RECT.size.x, _center_y(header_size.y, SETTINGS_RECT.size.y)),
		SETTINGS_RECT.size
	)


static func _center_y(header_height: float, control_height: float) -> float:
	return maxf(0.0, (header_height - control_height) * 0.5)


static func _offset_rect(rect: Rect2, offset: Vector2) -> Rect2:
	return Rect2(rect.position + offset, rect.size)


func _format_gold_text(text: String) -> String:
	var clean_text := text.strip_edges()
	if clean_text.begins_with("$"):
		return "$%s" % clean_text.substr(1).strip_edges()
	if clean_text.to_upper().begins_with("GOLD"):
		return "$%s" % clean_text.substr(4).strip_edges()
	return clean_text


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _apply_chrome() -> void:
	add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8, Vector4(8, 6, 8, 6)))
	gold_pill.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.22, 0.13, 0.04, 0.96), GOLD_COLOR, 2, 8, Vector4(8, 6, 8, 6)))
	title_label.add_theme_color_override("font_color", GOLD_COLOR)
	title_label.add_theme_constant_override("outline_size", 2)
	title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	title_label.add_theme_font_size_override("font_size", 44)
	gold_label.add_theme_color_override("font_color", GOLD_COLOR)
	gold_label.add_theme_constant_override("outline_size", 2)
	gold_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	gold_label.add_theme_font_size_override("font_size", 36)
	_apply_round_button_chrome(help_button)
	_apply_round_button_chrome(settings_button)
	help_button.add_theme_font_size_override("font_size", 38)
	settings_button.add_theme_font_size_override("font_size", 1)


func _apply_round_button_chrome(button: Button) -> void:
	var normal := UI_UTILS.panel_style(Color(0.08, 0.09, 0.10, 0.96), GOLD_COLOR, 2, 32, Vector4(4, 4, 4, 4))
	var hover := UI_UTILS.panel_style(Color(0.16, 0.14, 0.10, 0.98), GOLD_COLOR, 2, 32, Vector4(4, 4, 4, 4))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", INK_COLOR)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", GOLD_COLOR)


func _ensure_settings_glyph() -> void:
	if _settings_glyph != null and is_instance_valid(_settings_glyph):
		return
	_settings_glyph = SettingsGlyph.new()
	_settings_glyph.name = "SettingsGlyph"
	_settings_glyph.glyph_color = INK_COLOR
	settings_button.add_child(_settings_glyph)


func _layout_settings_glyph() -> void:
	if _settings_glyph == null or not is_instance_valid(_settings_glyph):
		return
	_settings_glyph.position = Vector2.ZERO
	_settings_glyph.size = settings_button.size
	_settings_glyph.queue_redraw()
