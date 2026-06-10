extends RefCounted
class_name MainMenuView

signal settings_speed_selected(speed: String)
signal settings_reduced_motion_toggled
signal settings_game_juice_toggled
signal settings_game_juice_flag_toggled(flag_key: String)
signal settings_defaults_reset
signal settings_closed

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const LOCALIZATION_BOOTSTRAP := preload("res://scripts/ui/localization_bootstrap.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const TEXT_KEYS := {
	"start_run": "MAIN_MENU_START_RUN",
	"generate_log": "MAIN_MENU_GENERATE_LOG",
	"continue": "MAIN_MENU_CONTINUE",
	"collection": "MAIN_MENU_COLLECTION",
	"tutorial": "MAIN_MENU_TUTORIAL",
	"settings": "MAIN_MENU_SETTINGS",
	"quit": "MAIN_MENU_QUIT",
	"profile": "MAIN_MENU_PROFILE",
	"achievements": "MAIN_MENU_ACHIEVEMENTS",
	"version": "MAIN_MENU_DEMO_VERSION",
	"runtime_status": "MAIN_MENU_RUNTIME_STATUS",
	"profile_title": "MAIN_MENU_PROFILE",
	"profile_default": "MAIN_MENU_DEFAULT_PROFILE",
	"profile_score_zero": "MAIN_MENU_PROFILE_SCORE_ZERO",
	"reset_profile": "MAIN_MENU_RESET_PROFILE",
	"close": "MAIN_MENU_CLOSE",
	"settings_title": "MAIN_MENU_SETTINGS_TITLE",
	"settings_vfx_speed": "MAIN_MENU_SETTINGS_VFX_SPEED",
	"settings_comfort": "MAIN_MENU_SETTINGS_COMFORT",
	"settings_game_juice": "MAIN_MENU_SETTINGS_GAME_JUICE",
	"settings_actions": "MAIN_MENU_SETTINGS_ACTIONS",
	"settings_reduced_motion": "MAIN_MENU_SETTINGS_REDUCED_MOTION",
	"settings_reset_defaults": "MAIN_MENU_SETTINGS_RESET_DEFAULTS",
}
const ELEMENT_LABEL_KEYS := [
	"MAIN_MENU_ELEMENT_FIRE",
	"MAIN_MENU_ELEMENT_ICE",
	"MAIN_MENU_ELEMENT_EARTH",
	"MAIN_MENU_ELEMENT_HEART",
	"MAIN_MENU_ELEMENT_ARMOR",
	"MAIN_MENU_ELEMENT_GOLD",
]
const STAT_TITLE_KEYS := [
	"MAIN_MENU_RELICS_UNLOCKED",
	"MAIN_MENU_MASTERY_PROGRESS",
	"MAIN_MENU_BEST_RUN",
]
const STAT_VALUE_KEYS := [
	"MAIN_MENU_STAT_RELICS_VALUE",
	"MAIN_MENU_STAT_MASTERY_VALUE",
	"MAIN_MENU_STAT_BEST_RUN_VALUE",
]
const SPEED_ORDER := ["slow", "normal", "fast", "instant"]
const SPEED_LABEL_KEYS := {
	"slow": "MAIN_MENU_SPEED_SLOW",
	"normal": "MAIN_MENU_SPEED_NORMAL",
	"fast": "MAIN_MENU_SPEED_FAST",
	"instant": "MAIN_MENU_SPEED_INSTANT",
}
const MENU_FILL_COLOR := Color(0.055, 0.085, 0.13, 0.96)
const MENU_BORDER_COLOR := Color(0.29, 0.38, 0.49, 0.96)
const MENU_PRIMARY_FILL_COLOR := Color(0.07, 0.11, 0.17, 0.98)
const MENU_PRIMARY_BORDER_COLOR := Color(0.43, 0.57, 0.72, 0.98)
const MENU_FOCUS_BORDER_COLOR := Color(0.68, 0.82, 0.98, 1.0)
const MENU_FONT_COLOR := Color(0.90, 0.94, 0.98, 1.0)
const MENU_PRIMARY_FONT_COLOR := Color(0.96, 0.98, 1.0, 1.0)
const MENU_HOVER_FONT_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const MENU_PRIMARY_HOVER_FONT_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const MENU_PRESSED_FONT_COLOR := Color(0.84, 0.90, 0.98, 1.0)
const MENU_DISABLED_FONT_COLOR := Color(0.62, 0.70, 0.79, 0.84)
const MENU_FONT_OUTLINE_COLOR := Color(0.03, 0.04, 0.07, 0.96)
const FOOTER_FILL_COLOR := Color(0.045, 0.075, 0.115, 0.94)
const FOOTER_BORDER_COLOR := Color(0.24, 0.33, 0.42, 0.92)
const FOOTER_FONT_COLOR := Color(0.86, 0.92, 0.98, 0.98)
const FOOTER_HOVER_FONT_COLOR := Color(0.93, 0.97, 1.0, 1.0)
const FOOTER_PRESSED_FONT_COLOR := Color(0.80, 0.88, 0.96, 0.98)
const FOOTER_DISABLED_FONT_COLOR := Color(0.61, 0.69, 0.76, 0.80)
const FOOTER_ICON_COLOR := Color(1.0, 1.0, 1.0, 0.94)
const FOOTER_DISABLED_ICON_COLOR := Color(0.72, 0.72, 0.72, 0.62)
const SECONDARY_LABEL_COLOR := Color(0.86, 0.73, 0.46, 0.96)
const SECONDARY_LABEL_OUTLINE_COLOR := Color(0.05, 0.06, 0.10, 0.95)
const GOLD_LABEL_COLOR := Color(0.86, 0.75, 0.51, 0.98)
const GOLD_LABEL_OUTLINE_COLOR := Color(0.04, 0.05, 0.08, 0.96)
const STAT_VALUE_COLOR := Color(0.96, 0.90, 0.76, 0.99)
const PROFILE_PANEL_FILL_COLOR := Color(0.07, 0.055, 0.045, 0.96)
const PROFILE_PANEL_BORDER_COLOR := Color(0.86, 0.63, 0.24, 1.0)
const PROFILE_LABEL_COLOR := Color(0.95, 0.88, 0.72, 1.0)
const PROFILE_TITLE_COLOR := Color(1.0, 0.78, 0.30, 1.0)
const PROFILE_LABEL_OUTLINE_COLOR := Color(0.04, 0.03, 0.02, 0.96)
const SETTINGS_PANEL_FILL_COLOR := Color(0.045, 0.065, 0.085, 0.98)
const SETTINGS_PANEL_BORDER_COLOR := Color(0.78, 0.58, 0.20, 1.0)
const MIN_TEXT_CONTRAST_RATIO := 4.5
const MIN_NON_TEXT_CONTRAST_RATIO := 3.0
const MIN_TOUCH_TARGET_PX := 48.0

var _background_texture: TextureRect
var _overlay_tint: ColorRect
var _outer_frame: Control
var _outer_border_texture: TextureRect
var _logo_texture: TextureRect
var _menu_button_column: VBoxContainer
var _start_run_button: Button
var _generate_log_toggle: CheckButton
var _continue_button: Button
var _collection_button: Button
var _tutorial_button: Button
var _settings_button: Button
var _quit_button: Button
var _element_row: HBoxContainer
var _stats_panel: Panel
var _stats_row: HBoxContainer
var _footer_actions: HBoxContainer
var _profile_button: Button
var _achievements_button: Button
var _footer_settings_button: Button
var _version_label: Label
var _status_label: Label
var _profile_overlay: Control
var _profile_panel: PanelContainer
var _profile_title_label: Label
var _profile_name_label: Label
var _profile_score_label: Label
var _reset_profile_button: Button
var _close_profile_button: Button
var _settings_overlay: Control = null
var _settings_panel: Panel = null
var _settings_box: VBoxContainer = null
var _settings_scroll: ScrollContainer = null
var _settings_content: VBoxContainer = null
var _settings_title_label: Label = null
var _settings_actions_label: Label = null
var _settings_actions: HBoxContainer = null
var _settings_speed_buttons: Array[Button] = []
var _settings_reduced_motion_button: Button = null
var _settings_game_juice_button: Button = null
var _settings_game_juice_flag_buttons: Dictionary = {}
var _settings_reset_button: Button = null
var _settings_close_button: Button = null
var _element_icons: Array = []
var _element_labels: Array = []
var _stat_icons: Array = []
var _stat_titles: Array = []
var _stat_values: Array = []

var _stats_panel_texture: Texture2D = null

func bind(root_nodes: Dictionary) -> void:
	_background_texture = root_nodes.get("background_texture") as TextureRect
	_overlay_tint = root_nodes.get("overlay_tint") as ColorRect
	_outer_frame = root_nodes.get("outer_frame") as Control
	_outer_border_texture = root_nodes.get("outer_border_texture") as TextureRect
	_logo_texture = root_nodes.get("logo_texture") as TextureRect
	_menu_button_column = root_nodes.get("menu_button_column") as VBoxContainer
	_start_run_button = root_nodes.get("start_run_button") as Button
	_generate_log_toggle = root_nodes.get("generate_log_toggle") as CheckButton
	_continue_button = root_nodes.get("continue_button") as Button
	_collection_button = root_nodes.get("collection_button") as Button
	_tutorial_button = root_nodes.get("tutorial_button") as Button
	_settings_button = root_nodes.get("settings_button") as Button
	_quit_button = root_nodes.get("quit_button") as Button
	_element_row = root_nodes.get("element_row") as HBoxContainer
	_stats_panel = root_nodes.get("stats_panel") as Panel
	_stats_row = root_nodes.get("stats_row") as HBoxContainer
	_footer_actions = root_nodes.get("footer_actions") as HBoxContainer
	_profile_button = root_nodes.get("profile_button") as Button
	_achievements_button = root_nodes.get("achievements_button") as Button
	_footer_settings_button = root_nodes.get("footer_settings_button") as Button
	_version_label = root_nodes.get("version_label") as Label
	_status_label = root_nodes.get("status_label") as Label
	_profile_overlay = root_nodes.get("profile_overlay") as Control
	_profile_panel = root_nodes.get("profile_panel") as PanelContainer
	_profile_title_label = root_nodes.get("profile_title_label") as Label
	_profile_name_label = root_nodes.get("profile_name_label") as Label
	_profile_score_label = root_nodes.get("profile_score_label") as Label
	_reset_profile_button = root_nodes.get("reset_profile_button") as Button
	_close_profile_button = root_nodes.get("close_profile_button") as Button
	_element_icons = root_nodes.get("element_icons", [])
	_element_labels = root_nodes.get("element_labels", [])
	_stat_icons = root_nodes.get("stat_icons", [])
	_stat_titles = root_nodes.get("stat_titles", [])
	_stat_values = root_nodes.get("stat_values", [])


func configure_ui_nodes(host: Control) -> void:
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_logo_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	_outer_border_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_outer_border_texture.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	_menu_button_column.alignment = BoxContainer.ALIGNMENT_CENTER
	_generate_log_toggle.visible = false
	_collection_button.visible = false
	_element_row.visible = false
	_stats_panel.visible = false
	_footer_actions.visible = false
	_outer_border_texture.visible = false
	_version_label.visible = false

	if _profile_button.get_parent() != _menu_button_column:
		_profile_button.reparent(_menu_button_column)
	var ordered_buttons := _main_menu_buttons()
	for button_index in range(mini(ordered_buttons.size(), _menu_button_column.get_child_count())):
		_menu_button_column.move_child(ordered_buttons[button_index], button_index)

	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
			icon.custom_minimum_size = Vector2.ZERO

	for icon_node in _stat_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
			icon.custom_minimum_size = Vector2.ZERO

	for container in [_menu_button_column, _element_row, _stats_row, _footer_actions]:
		container.custom_minimum_size = Vector2.ZERO

	host.clip_contents = true
	_element_row.clip_contents = true
	_stats_panel.clip_contents = true
	_footer_actions.clip_contents = true
	_ensure_settings_overlay(host)


func apply_textures(paths: Dictionary) -> void:
	_background_texture.texture = _safe_load_texture(String(paths.get("background", "")), "main_menu_background")
	_logo_texture.texture = _safe_load_texture(String(paths.get("logo", "")), "main_menu_logo")
	_outer_border_texture.texture = _safe_load_texture(String(paths.get("outer_border", "")), "main_menu_outer_border")
	_stats_panel_texture = _safe_load_texture(String(paths.get("stats_panel", "")), "main_menu_stats_panel")

	var element_paths: Array = Array(paths.get("element_icons", []))
	for i in mini(_element_icons.size(), element_paths.size()):
		(_element_icons[i] as TextureRect).texture = _safe_load_texture(String(element_paths[i]), "element_%d" % i)

	var stat_paths: Array = Array(paths.get("stat_icons", []))
	for i in mini(_stat_icons.size(), stat_paths.size()):
		(_stat_icons[i] as TextureRect).texture = _safe_load_texture(String(stat_paths[i]), "stat_%d" % i)

	var footer_paths: Array = Array(paths.get("footer_icons", []))
	var footer_buttons := [_profile_button, _achievements_button, _footer_settings_button]
	for i in mini(footer_buttons.size(), footer_paths.size()):
		footer_buttons[i].icon = null


func apply_static_text() -> void:
	LOCALIZATION_BOOTSTRAP.ensure_loaded()
	_start_run_button.text = _text("start_run")
	_generate_log_toggle.text = _text("generate_log")
	_continue_button.text = _text("continue")
	_collection_button.text = _text("collection")
	_tutorial_button.text = _text("tutorial")
	_settings_button.text = _text("settings")
	_quit_button.text = _text("quit")
	_profile_button.text = _text("profile")
	_achievements_button.text = _text("achievements")
	_footer_settings_button.text = _text("settings")
	_version_label.text = _text("version")
	_status_label.text = _text("runtime_status")
	_status_label.visible = false
	_continue_button.disabled = true
	_collection_button.disabled = false
	_tutorial_button.disabled = false
	_settings_button.disabled = false
	_quit_button.disabled = false
	_profile_button.disabled = false
	_achievements_button.disabled = true
	_footer_settings_button.disabled = true

	for index in mini(_element_labels.size(), ELEMENT_LABEL_KEYS.size()):
		var label := _element_labels[index] as Label
		if label != null:
			label.text = tr(ELEMENT_LABEL_KEYS[index])

	for index in mini(_stat_titles.size(), STAT_TITLE_KEYS.size()):
		var title := _stat_titles[index] as Label
		if title != null:
			title.text = tr(STAT_TITLE_KEYS[index])

	for index in mini(_stat_values.size(), STAT_VALUE_KEYS.size()):
		var value := _stat_values[index] as Label
		if value != null:
			value.text = tr(STAT_VALUE_KEYS[index])

	_profile_title_label.text = _text("profile_title")
	_profile_name_label.text = _text("profile_default")
	_profile_score_label.text = _text("profile_score_zero")
	_reset_profile_button.text = _text("reset_profile")
	_close_profile_button.text = _text("close")

	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			label.text = label.text.to_upper()

	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			title.text = title.text.to_upper()

	for value_node in _stat_values:
		var value_label := value_node as Label
		if value_label != null:
			value_label.text = value_label.text.to_upper()


func apply_chrome_styles() -> void:
	_apply_menu_button_style(_start_run_button, true, false)
	_apply_menu_button_style(_generate_log_toggle, false, false)
	_apply_menu_button_style(_continue_button, false, _continue_button.disabled)
	_apply_menu_button_style(_collection_button, false, false)
	_apply_menu_button_style(_tutorial_button, false, false)
	_apply_menu_button_style(_settings_button, false, false)
	_apply_menu_button_style(_profile_button, false, false)
	_apply_menu_button_style(_quit_button, false, false)
	_apply_footer_button_style(_achievements_button)
	_apply_footer_button_style(_footer_settings_button)
	_apply_profile_overlay_style()
	_apply_settings_overlay_style()

	_set_label_style(_version_label, SECONDARY_LABEL_COLOR, SECONDARY_LABEL_OUTLINE_COLOR, 2)
	_set_label_style(_status_label, SECONDARY_LABEL_COLOR, SECONDARY_LABEL_OUTLINE_COLOR, 2)
	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, GOLD_LABEL_COLOR, GOLD_LABEL_OUTLINE_COLOR, 2)
	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			_set_label_style(title, GOLD_LABEL_COLOR, GOLD_LABEL_OUTLINE_COLOR, 2)
	for value_node in _stat_values:
		var value := value_node as Label
		if value != null:
			_set_label_style(value, STAT_VALUE_COLOR, SECONDARY_LABEL_OUTLINE_COLOR, 2)


func layout_ui(viewport_size: Vector2) -> void:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var safe_rect := _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (34.0 / DESIGN_SIZE.x))

	_set_control_rect(_background_texture, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_overlay_tint, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_frame, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_border_texture, _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (12.0 / DESIGN_SIZE.x)))
	_set_control_rect(_logo_texture, _rect_from_percent_in_rect(safe_rect, 0.06, 0.11, 0.88, 0.20))
	_set_control_rect(_menu_button_column, _rect_from_percent_in_rect(safe_rect, 0.18, 0.34, 0.64, 0.44))
	_set_control_rect(_element_row, _rect_from_percent_in_rect(safe_rect, 0.03, 0.57, 0.94, 0.12))
	_set_control_rect(_stats_panel, _rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14))
	_set_control_rect(_footer_actions, _rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.077))
	_set_control_rect(_version_label, _rect_from_percent_in_rect(safe_rect, 0.33, 0.946, 0.34, 0.022))
	_set_control_rect(_status_label, _rect_from_percent_in_rect(safe_rect, 0.04, 0.973, 0.92, 0.019))
	_set_control_rect(
		_stats_row,
		Rect2(
			Vector2(_stats_panel.size.x * 0.055, _stats_panel.size.y * 0.28),
			Vector2(_stats_panel.size.x * 0.89, _stats_panel.size.y * 0.48)
		)
	)
	_menu_button_column.add_theme_constant_override("separation", int(round(clampf(16.0 * (viewport_size.y / DESIGN_SIZE.y), 10.0, 24.0))))
	_footer_actions.add_theme_constant_override("separation", int(round(clampf(10.0 * (viewport_size.x / DESIGN_SIZE.x), 8.0, 16.0))))

	var menu_button_min_height := int(round(viewport_size.y * 0.060))
	for button in _main_menu_buttons():
		button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))

	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var element_icon_size := int(round(clampf(118.0 * scale_factor, 58.0, 136.0)))
	var element_cell_width := _element_row.size.x / 6.0
	if element_icon_size > int(round(element_cell_width * 0.78)):
		element_icon_size = int(round(element_cell_width * 0.78))
	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.custom_minimum_size = Vector2(element_icon_size, element_icon_size)

	var stat_icon_size := int(round(clampf(88.0 * scale_factor, 48.0, 100.0)))
	for icon_node in _stat_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.custom_minimum_size = Vector2(stat_icon_size, stat_icon_size)

	var footer_button_height := int(round(_footer_actions.size.y))
	var footer_icon_max_width := int(round(clampf(72.0 * scale_factor, 36.0, 84.0)))
	for button in [_achievements_button, _footer_settings_button]:
		button.custom_minimum_size = Vector2(0.0, float(footer_button_height))
		button.add_theme_constant_override("icon_max_width", footer_icon_max_width)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = false

	_profile_panel.custom_minimum_size = Vector2(
		clampf(viewport_size.x * 0.78, 520.0, 760.0),
		clampf(viewport_size.y * 0.22, 330.0, 460.0)
	)
	_reset_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))
	_close_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))
	_layout_settings_overlay(viewport_size)
	_apply_font_sizes(viewport_size)


func configure_focus_navigation() -> void:
	var main_chain := _focusable_buttons(_main_menu_buttons())
	_apply_focus_chain(main_chain)
	_apply_focus_chain(_focusable_buttons([_reset_profile_button, _close_profile_button]))
	_apply_focus_chain(_focusable_buttons(_settings_focus_controls()))
	if _can_grab_main_menu_focus() and _start_run_button != null and not _start_run_button.disabled:
		_start_run_button.grab_focus.call_deferred()


static func layout_probe_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return {"applied": false}
	var safe_rect := _layout_inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (34.0 / DESIGN_SIZE.x))
	var stats_panel := _layout_rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14)
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var element_row := _layout_rect_from_percent_in_rect(safe_rect, 0.03, 0.57, 0.94, 0.12)
	var element_icon_size := int(round(clampf(118.0 * scale_factor, 58.0, 136.0)))
	var element_cell_width := element_row.size.x / 6.0
	if element_icon_size > int(round(element_cell_width * 0.78)):
		element_icon_size = int(round(element_cell_width * 0.78))
	return {
		"applied": true,
		"design_size": DESIGN_SIZE,
		"viewport_size": viewport_size,
		"safe_rect": safe_rect,
		"background": Rect2(Vector2.ZERO, viewport_size),
		"outer_border": _layout_inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (12.0 / DESIGN_SIZE.x)),
		"logo": _layout_rect_from_percent_in_rect(safe_rect, 0.06, 0.11, 0.88, 0.20),
		"menu_button_column": _layout_rect_from_percent_in_rect(safe_rect, 0.18, 0.34, 0.64, 0.44),
		"element_row": element_row,
		"stats_panel": stats_panel,
		"stats_row": Rect2(
			Vector2(stats_panel.size.x * 0.055, stats_panel.size.y * 0.28),
			Vector2(stats_panel.size.x * 0.89, stats_panel.size.y * 0.48)
		),
		"footer_actions": _layout_rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.077),
		"version_label": _layout_rect_from_percent_in_rect(safe_rect, 0.33, 0.946, 0.34, 0.022),
		"status_label": _layout_rect_from_percent_in_rect(safe_rect, 0.04, 0.973, 0.92, 0.019),
		"menu_button_separation": int(round(clampf(16.0 * (viewport_size.y / DESIGN_SIZE.y), 10.0, 24.0))),
		"footer_action_separation": int(round(clampf(10.0 * (viewport_size.x / DESIGN_SIZE.x), 8.0, 16.0))),
		"menu_button_min_height": int(round(viewport_size.y * 0.060)),
		"element_icon_size": element_icon_size,
		"stat_icon_size": int(round(clampf(88.0 * scale_factor, 48.0, 100.0))),
		"footer_icon_max_width": int(round(clampf(72.0 * scale_factor, 36.0, 84.0))),
	}


static func accessibility_audit_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	var layout_probe := layout_probe_snapshot(viewport_size)
	var menu_button_column_rect: Rect2 = layout_probe.get("menu_button_column", Rect2())
	var footer_rect: Rect2 = layout_probe.get("footer_actions", Rect2())
	var menu_button_height := float(layout_probe.get("menu_button_min_height", 0))
	return {
		"min_text_contrast_ratio": MIN_TEXT_CONTRAST_RATIO,
		"min_non_text_contrast_ratio": MIN_NON_TEXT_CONTRAST_RATIO,
		"min_touch_target_px": MIN_TOUCH_TARGET_PX,
		"contrast_pairs": [
			_contrast_pair("menu.primary.text", MENU_PRIMARY_FONT_COLOR, MENU_PRIMARY_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.text", MENU_FONT_COLOR, MENU_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.hover_text", MENU_HOVER_FONT_COLOR, MENU_FILL_COLOR.lightened(0.10), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.pressed_text", MENU_PRESSED_FONT_COLOR, MENU_FILL_COLOR.darkened(0.12), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.disabled_text", MENU_DISABLED_FONT_COLOR, MENU_FILL_COLOR.darkened(0.24), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.focus_border", MENU_FOCUS_BORDER_COLOR, MENU_FILL_COLOR.lightened(0.08), MIN_NON_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.text", FOOTER_FONT_COLOR, FOOTER_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.hover_text", FOOTER_HOVER_FONT_COLOR, FOOTER_FILL_COLOR.lightened(0.08), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.pressed_text", FOOTER_PRESSED_FONT_COLOR, FOOTER_FILL_COLOR.darkened(0.10), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.disabled_text", FOOTER_DISABLED_FONT_COLOR, FOOTER_FILL_COLOR.darkened(0.20), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("settings.panel_border", SETTINGS_PANEL_BORDER_COLOR, SETTINGS_PANEL_FILL_COLOR, MIN_NON_TEXT_CONTRAST_RATIO),
			_contrast_pair("profile.text", PROFILE_LABEL_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("profile.title", PROFILE_TITLE_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("profile.panel_border", PROFILE_PANEL_BORDER_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_NON_TEXT_CONTRAST_RATIO),
		],
		"touch_targets": [
			_touch_target("main_menu_button", Vector2(menu_button_column_rect.size.x, menu_button_height)),
			_touch_target("footer_action_button", Vector2(footer_rect.size.x / 3.0, footer_rect.size.y)),
			_touch_target("profile_action_button", Vector2(0.0, menu_button_height)),
		],
		"keyboard_focus_controls": [
			"start_run_button",
			"continue_button",
			"tutorial_button",
			"settings_button",
			"profile_button",
			"quit_button",
			"settings_speed_buttons",
			"settings_reduced_motion_button",
			"settings_game_juice_button",
			"settings_game_juice_flag_buttons",
			"settings_reset_button",
			"settings_close_button",
			"reset_profile_button",
			"close_profile_button",
		],
		"initial_focus_control": "start_run_button",
		"main_menu_focus_chain": [
			"start_run_button",
			"tutorial_button",
			"settings_button",
			"profile_button",
			"quit_button",
		],
	}


static func _contrast_pair(label: String, foreground: Color, background: Color, minimum_ratio: float) -> Dictionary:
	return {
		"label": label,
		"foreground": foreground,
		"background": background,
		"minimum_ratio": minimum_ratio,
	}


static func _touch_target(label: String, size: Vector2) -> Dictionary:
	return {
		"label": label,
		"size": size,
		"minimum_size": MIN_TOUCH_TARGET_PX,
	}


func set_generate_log_toggle(enabled: bool) -> void:
	_generate_log_toggle.set_pressed_no_signal(enabled)


func set_continue_enabled(enabled: bool) -> void:
	_continue_button.disabled = not enabled
	_apply_menu_button_style(_continue_button, false, not enabled)


func show_settings(settings: Variant) -> void:
	if _settings_overlay == null:
		return
	_settings_overlay.visible = true
	var settings_dict := _settings_dictionary(settings)
	_update_settings_speed_buttons(String(settings_dict.get("vfx_speed", "normal")))
	_update_settings_reduced_motion_button(bool(settings_dict.get("reduced_motion", false)))
	_update_settings_game_juice_button(bool(settings_dict.get("game_juice", true)))
	_update_settings_game_juice_flag_buttons(Dictionary(settings_dict.get("game_juice_flags", GAME_JUICE_FLAGS_SCRIPT.default_flags())))
	_focus_first_control(_settings_focus_controls())


func hide_settings() -> void:
	if _settings_overlay != null:
		_settings_overlay.visible = false
	if _settings_button != null and not _settings_button.disabled:
		_settings_button.grab_focus.call_deferred()


func set_profile_overlay_visible(visible: bool) -> void:
	_profile_overlay.visible = visible
	if visible:
		_focus_first_control([_reset_profile_button, _close_profile_button])
	elif _profile_button != null and not _profile_button.disabled:
		_profile_button.grab_focus.call_deferred()


func set_profile_content(profile_name: String, profile_score: String) -> void:
	_profile_name_label.text = profile_name
	_profile_score_label.text = profile_score


func set_start_run_locked(locked: bool) -> void:
	_start_run_button.disabled = locked
	if not locked:
		configure_focus_navigation()


func set_collection_locked(locked: bool) -> void:
	_collection_button.disabled = locked


func set_tutorial_locked(locked: bool) -> void:
	_tutorial_button.disabled = locked


func set_reset_profile_locked(locked: bool) -> void:
	_reset_profile_button.disabled = locked


func show_status(message: String) -> void:
	_status_label.text = message
	_status_label.visible = true


func _apply_font_sizes(viewport_size: Vector2) -> void:
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var menu_size := maxi(18, int(round(40.0 * scale_factor)))
	var element_size := maxi(14, int(round(24.0 * scale_factor)))
	var stat_title_size := maxi(11, int(round(15.0 * scale_factor)))
	var stat_value_size := maxi(17, int(round(27.0 * scale_factor)))
	var footer_size := maxi(13, int(round(25.0 * scale_factor)))
	var version_size := maxi(12, int(round(18.0 * scale_factor)))
	var status_size := maxi(10, int(round(13.0 * scale_factor)))

	for button in _main_menu_buttons():
		button.add_theme_font_size_override("font_size", menu_size)
	for label_node in _element_labels:
		var element_label := label_node as Label
		if element_label != null:
			element_label.add_theme_font_size_override("font_size", element_size)
	for title_node in _stat_titles:
		var stat_title := title_node as Label
		if stat_title != null:
			stat_title.add_theme_font_size_override("font_size", stat_title_size)
	for value_node in _stat_values:
		var stat_value := value_node as Label
		if stat_value != null:
			stat_value.add_theme_font_size_override("font_size", stat_value_size)
	for button in [_achievements_button, _footer_settings_button]:
		button.add_theme_font_size_override("font_size", footer_size)
	_profile_title_label.add_theme_font_size_override("font_size", maxi(32, int(round(52.0 * scale_factor))))
	_profile_name_label.add_theme_font_size_override("font_size", maxi(24, int(round(34.0 * scale_factor))))
	_profile_score_label.add_theme_font_size_override("font_size", maxi(22, int(round(30.0 * scale_factor))))
	_reset_profile_button.add_theme_font_size_override("font_size", maxi(18, int(round(28.0 * scale_factor))))
	_close_profile_button.add_theme_font_size_override("font_size", maxi(18, int(round(28.0 * scale_factor))))
	_version_label.add_theme_font_size_override("font_size", version_size)
	_status_label.add_theme_font_size_override("font_size", status_size)


func _main_menu_buttons() -> Array:
	return [_start_run_button, _continue_button, _tutorial_button, _settings_button, _profile_button, _quit_button]


func _settings_focus_controls() -> Array:
	var controls: Array = []
	controls.append_array(_settings_speed_buttons)
	controls.append(_settings_reduced_motion_button)
	controls.append(_settings_game_juice_button)
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		controls.append(_settings_game_juice_flag_buttons.get(flag_key, null))
	controls.append(_settings_reset_button)
	controls.append(_settings_close_button)
	return controls


func _focusable_buttons(raw_controls: Array) -> Array[Button]:
	var controls: Array[Button] = []
	for raw_control in raw_controls:
		var control := raw_control as Button
		if control == null:
			continue
		control.focus_mode = Control.FOCUS_ALL as Control.FocusMode
		if not control.disabled and control.visible:
			controls.append(control)
	return controls


func _apply_focus_chain(controls: Array[Button]) -> void:
	if controls.is_empty():
		return
	for control in controls:
		control.focus_mode = Control.FOCUS_ALL as Control.FocusMode
	if controls.size() == 1:
		return
	for index in controls.size():
		var control := controls[index]
		var previous_control := controls[(index - 1 + controls.size()) % controls.size()]
		var next_control := controls[(index + 1) % controls.size()]
		if not _can_link_focus_neighbor(control, previous_control) or not _can_link_focus_neighbor(control, next_control):
			continue
		var previous_path := control.get_path_to(previous_control)
		var next_path := control.get_path_to(next_control)
		control.set("focus_previous", previous_path)
		control.set("focus_next", next_path)
		control.set("focus_neighbor_top", previous_path)
		control.set("focus_neighbor_left", previous_path)
		control.set("focus_neighbor_bottom", next_path)
		control.set("focus_neighbor_right", next_path)


func _can_link_focus_neighbor(control: Control, target: Control) -> bool:
	return control != null and target != null and ((control.is_inside_tree() and target.is_inside_tree() and control.get_tree() == target.get_tree()) or (not control.is_inside_tree() and not target.is_inside_tree() and control.get_parent() != null and control.get_parent() == target.get_parent()))


func _can_grab_main_menu_focus() -> bool:
	return not _is_overlay_visible(_settings_overlay) and not _is_overlay_visible(_profile_overlay)


func _is_overlay_visible(overlay: Control) -> bool:
	return overlay != null and overlay.visible


func _focus_first_control(raw_controls: Array) -> void:
	for raw_control in raw_controls:
		var control := raw_control as Button
		if control != null and not control.disabled and control.visible:
			control.grab_focus.call_deferred()
			return


func _layout_settings_overlay(viewport_size: Vector2) -> void:
	if _settings_overlay == null or _settings_panel == null or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_set_control_rect(_settings_overlay, Rect2(Vector2.ZERO, viewport_size))
	var outer_margin := clampf(minf(viewport_size.x, viewport_size.y) * 0.035, 14.0, 42.0)
	var panel_rect := Rect2(
		Vector2(outer_margin, outer_margin),
		Vector2(maxf(0.0, viewport_size.x - outer_margin * 2.0), maxf(0.0, viewport_size.y - outer_margin * 2.0))
	)
	_set_control_rect(_settings_panel, panel_rect)
	if _settings_box != null:
		var inner_x := clampf(viewport_size.x * 0.045, 18.0, 48.0)
		var inner_y := clampf(viewport_size.y * 0.026, 18.0, 42.0)
		_set_control_rect(
			_settings_box,
			Rect2(
				Vector2(inner_x, inner_y),
				Vector2(maxf(0.0, panel_rect.size.x - inner_x * 2.0), maxf(0.0, panel_rect.size.y - inner_y * 2.0))
			)
		)
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var button_height := clampf(viewport_size.y * 0.060, 58.0, 82.0)
	var action_button_height := clampf(viewport_size.y * 0.066, 64.0, 88.0)
	var button_font := maxi(18, int(round(34.0 * scale_factor)))
	var flag_font := maxi(16, int(round(30.0 * scale_factor)))
	if _settings_title_label != null:
		_settings_title_label.add_theme_font_size_override("font_size", maxi(30, int(round(54.0 * scale_factor))))
	if _settings_actions != null:
		_settings_actions.add_theme_constant_override("separation", int(round(clampf(14.0 * scale_factor, 10.0, 18.0))))
	for button in _settings_speed_buttons:
		button.custom_minimum_size = Vector2(0.0, button_height)
		button.add_theme_font_size_override("font_size", button_font)
	for button in [_settings_reduced_motion_button, _settings_game_juice_button]:
		if button != null:
			button.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.22, 104.0, 132.0), button_height)
			button.add_theme_font_size_override("font_size", button_font)
	for raw_button in _settings_game_juice_flag_buttons.values():
		var flag_button := raw_button as Button
		if flag_button != null:
			flag_button.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.22, 104.0, 132.0), button_height)
			flag_button.add_theme_font_size_override("font_size", flag_font)
	for button in [_settings_reset_button, _settings_close_button]:
		if button != null:
			button.custom_minimum_size = Vector2(0.0, action_button_height)
			button.add_theme_font_size_override("font_size", button_font)


func _ensure_settings_overlay(host: Control) -> void:
	if _settings_overlay != null or host == null:
		return
	LOCALIZATION_BOOTSTRAP.ensure_loaded()
	_settings_speed_buttons.clear()
	_settings_game_juice_flag_buttons.clear()
	_settings_overlay = Control.new()
	_settings_overlay.name = "SettingsOverlay"
	_settings_overlay.visible = false
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_settings_overlay.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	host.add_child(_settings_overlay)

	var scrim := ColorRect.new()
	scrim.name = "SettingsScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.66)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	_settings_overlay.add_child(scrim)

	_settings_panel = Panel.new()
	_settings_panel.name = "SettingsPanel"
	_settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_settings_overlay.add_child(_settings_panel)

	_settings_box = VBoxContainer.new()
	_settings_box.name = "SettingsBox"
	_settings_box.add_theme_constant_override("separation", 12)
	_settings_panel.add_child(_settings_box)

	_settings_title_label = Label.new()
	_settings_title_label.name = "SettingsTitle"
	_settings_title_label.text = _text("settings_title")
	_settings_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_settings_title_label.add_theme_font_size_override("font_size", 42)
	_settings_box.add_child(_settings_title_label)

	_settings_scroll = ScrollContainer.new()
	_settings_scroll.name = "SettingsScroll"
	_settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED as ScrollContainer.ScrollMode
	_settings_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_settings_box.add_child(_settings_scroll)

	_settings_content = VBoxContainer.new()
	_settings_content.name = "SettingsContent"
	_settings_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_content.add_theme_constant_override("separation", 12)
	_settings_scroll.add_child(_settings_content)

	_settings_content.add_child(_settings_section_label(_text("settings_vfx_speed"), "SettingsSpeedLabel"))

	for speed in SPEED_ORDER:
		var button := Button.new()
		button.name = "Speed%sButton" % speed.capitalize()
		button.text = _speed_label(speed)
		button.set_meta("speed", speed)
		button.custom_minimum_size = Vector2(0.0, 58.0)
		button.pressed.connect(func() -> void: settings_speed_selected.emit(speed))
		_settings_speed_buttons.append(button)
		_settings_content.add_child(button)

	_settings_content.add_child(_settings_section_label(_text("settings_comfort"), "SettingsComfortLabel"))
	_settings_reduced_motion_button = CheckButton.new()
	_settings_reduced_motion_button.name = "SettingsReducedMotionButton"
	_settings_reduced_motion_button.custom_minimum_size = Vector2(0.0, 58.0)
	_settings_reduced_motion_button.pressed.connect(func() -> void: settings_reduced_motion_toggled.emit())
	_settings_content.add_child(_settings_toggle_row(_settings_reduced_motion_button, _text("settings_reduced_motion"), ""))

	var juice_label := _settings_section_label(_text("settings_game_juice"), "SettingsGameJuiceLabel")
	_settings_content.add_child(juice_label)

	_settings_game_juice_button = CheckButton.new()
	_settings_game_juice_button.name = "SettingsGameJuiceButton"
	_settings_game_juice_button.custom_minimum_size = Vector2(0.0, 58.0)
	_settings_game_juice_button.pressed.connect(func() -> void: settings_game_juice_toggled.emit())
	_settings_content.add_child(_settings_toggle_row(_settings_game_juice_button, tr("SETTINGS_JUICE_MASTER"), tr("SETTINGS_JUICE_MASTER_DESC")))

	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var flag_button := CheckButton.new()
		flag_button.name = _settings_flag_button_name(flag_key)
		flag_button.custom_minimum_size = Vector2(0.0, 58.0)
		var captured_flag_key := flag_key
		flag_button.pressed.connect(func() -> void: settings_game_juice_flag_toggled.emit(captured_flag_key))
		_settings_game_juice_flag_buttons[flag_key] = flag_button
		_settings_content.add_child(_settings_toggle_row(flag_button, _juice_flag_label(flag_key), _juice_flag_description(flag_key)))

	_settings_actions_label = _settings_section_label(_text("settings_actions"), "SettingsActionsLabel")
	_settings_box.add_child(_settings_actions_label)
	_settings_actions = HBoxContainer.new()
	_settings_actions.name = "SettingsActions"
	_settings_actions.add_theme_constant_override("separation", 14)
	_settings_box.add_child(_settings_actions)

	_settings_reset_button = Button.new()
	_settings_reset_button.name = "SettingsResetDefaultsButton"
	_settings_reset_button.text = _text("settings_reset_defaults").to_upper()
	_settings_reset_button.custom_minimum_size = Vector2(0.0, 62.0)
	_settings_reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_reset_button.pressed.connect(func() -> void: settings_defaults_reset.emit())
	_settings_actions.add_child(_settings_reset_button)

	_settings_close_button = Button.new()
	_settings_close_button.name = "SettingsCloseButton"
	_settings_close_button.text = _text("close")
	_settings_close_button.custom_minimum_size = Vector2(0.0, 62.0)
	_settings_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_close_button.pressed.connect(func() -> void: settings_closed.emit())
	_settings_actions.add_child(_settings_close_button)
	_apply_settings_overlay_style()


func _apply_settings_overlay_style() -> void:
	if _settings_panel != null:
		_settings_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(SETTINGS_PANEL_FILL_COLOR, SETTINGS_PANEL_BORDER_COLOR, 2, 8, Vector4(32, 28, 32, 28)))
	for button in _settings_speed_buttons:
		_apply_menu_button_style(button, false, false)
		button.add_theme_font_size_override("font_size", 22)
	if _settings_reduced_motion_button != null:
		_apply_menu_button_style(_settings_reduced_motion_button, false, false)
		_settings_reduced_motion_button.add_theme_font_size_override("font_size", 22)
	if _settings_game_juice_button != null:
		_apply_menu_button_style(_settings_game_juice_button, false, false)
		_settings_game_juice_button.add_theme_font_size_override("font_size", 22)
	for button in _settings_game_juice_flag_buttons.values():
		var flag_button := button as Button
		if flag_button == null:
			continue
		_apply_menu_button_style(flag_button, false, false)
		flag_button.add_theme_font_size_override("font_size", 20)
	if _settings_reset_button != null:
		_apply_menu_button_style(_settings_reset_button, false, false)
		_settings_reset_button.add_theme_font_size_override("font_size", 22)
	if _settings_close_button != null:
		_apply_menu_button_style(_settings_close_button, false, false)
		_settings_close_button.add_theme_font_size_override("font_size", 22)


func _settings_section_label(text: String, node_name: String = "") -> Label:
	var label := Label.new()
	if node_name != "":
		label.name = node_name
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 25)
	label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.32, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.06, 0.96))
	label.add_theme_constant_override("outline_size", 2)
	return label


func _settings_toggle_row(button: Button, title: String, description: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "%sRow" % button.name.trim_suffix("Button")
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 3)
	var title_label := Label.new()
	title_label.name = "%sTitleLabel" % button.name.trim_suffix("Button")
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	title_label.add_theme_font_size_override("font_size", 21)
	title_label.add_theme_color_override("font_color", MENU_FONT_COLOR)
	title_label.add_theme_color_override("font_outline_color", MENU_FONT_OUTLINE_COLOR)
	title_label.add_theme_constant_override("outline_size", 1)
	text_column.add_child(title_label)
	if description.strip_edges() != "":
		var description_label := Label.new()
		description_label.text = description
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		description_label.add_theme_font_size_override("font_size", 16)
		description_label.add_theme_color_override("font_color", Color(0.76, 0.82, 0.88, 0.94))
		description_label.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 0.92))
		description_label.add_theme_constant_override("outline_size", 1)
		text_column.add_child(description_label)
	row.add_child(text_column)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.custom_minimum_size = Vector2(112.0, 58.0)
	row.add_child(button)
	return row


func _update_settings_speed_buttons(speed: String) -> void:
	var normalized := speed.strip_edges().to_lower()
	for button in _settings_speed_buttons:
		var button_speed := String(button.get_meta("speed", "")).to_lower()
		var selected := button_speed == normalized
		var label := _speed_label(button_speed)
		button.text = ("%s  *" % label) if selected else label


func _update_settings_reduced_motion_button(enabled: bool) -> void:
	if _settings_reduced_motion_button == null:
		return
	_settings_reduced_motion_button.text = _on_off_label(enabled)
	_settings_reduced_motion_button.set_pressed_no_signal(enabled)


func _update_settings_game_juice_button(enabled: bool) -> void:
	if _settings_game_juice_button == null:
		return
	_settings_game_juice_button.text = _on_off_label(enabled)
	_settings_game_juice_button.set_pressed_no_signal(enabled)


func _update_settings_game_juice_flag_buttons(flags: Dictionary) -> void:
	var normalized_flags := GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var button := _settings_game_juice_flag_buttons.get(flag_key, null) as Button
		if button == null:
			continue
		var enabled := bool(normalized_flags.get(flag_key, true))
		button.text = _on_off_label(enabled)
		button.set_pressed_no_signal(enabled)


func _settings_dictionary(settings: Variant) -> Dictionary:
	if settings is Dictionary:
		return (settings as Dictionary).duplicate()
	return {
		"vfx_speed": String(settings),
		"reduced_motion": false,
		"game_juice": true,
		"game_juice_flags": GAME_JUICE_FLAGS_SCRIPT.default_flags(),
	}


func _text(key_name: String) -> String:
	return tr(String(TEXT_KEYS.get(key_name, key_name)))


func _speed_label(speed: String) -> String:
	return tr(String(SPEED_LABEL_KEYS.get(speed, speed))).to_upper()


func _on_off_label(enabled: bool) -> String:
	return "ON" if enabled else "OFF"


func _juice_flag_label(flag_key: String) -> String:
	return tr(GAME_JUICE_FLAGS_SCRIPT.label_key(flag_key))


func _juice_flag_description(flag_key: String) -> String:
	return tr(GAME_JUICE_FLAGS_SCRIPT.description_key(flag_key))


func _settings_flag_button_name(flag_key: String) -> String:
	var output := "JuiceFlag"
	for part in flag_key.split("_", false):
		output += String(part).capitalize()
	return "%sButton" % output


static func localization_keys() -> Array[String]:
	var keys: Array[String] = []
	for value in TEXT_KEYS.values():
		keys.append(String(value))
	for value in ELEMENT_LABEL_KEYS:
		keys.append(String(value))
	for value in STAT_TITLE_KEYS:
		keys.append(String(value))
	for value in STAT_VALUE_KEYS:
		keys.append(String(value))
	for value in SPEED_LABEL_KEYS.values():
		keys.append(String(value))
	keys.append("SETTINGS_JUICE_MASTER")
	keys.append("SETTINGS_JUICE_MASTER_DESC")
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		keys.append(GAME_JUICE_FLAGS_SCRIPT.label_key(flag_key))
		keys.append(GAME_JUICE_FLAGS_SCRIPT.description_key(flag_key))
	keys.sort()
	return keys


func _apply_menu_button_style(button: Button, is_primary: bool, is_disabled: bool) -> void:
	var fill_color := MENU_FILL_COLOR
	var border_color := MENU_BORDER_COLOR
	if is_primary:
		fill_color = MENU_PRIMARY_FILL_COLOR
		border_color = MENU_PRIMARY_BORDER_COLOR
	button.add_theme_stylebox_override("normal", _make_panel_style(fill_color, border_color, 2, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(fill_color.lightened(0.10), border_color.lightened(0.10), 2, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(fill_color.darkened(0.12), border_color, 2, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(fill_color.lightened(0.08), MENU_FOCUS_BORDER_COLOR, 2, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(fill_color.darkened(0.24), border_color.darkened(0.18), 2, 10))

	var font_color := MENU_FONT_COLOR
	var hover_color := MENU_HOVER_FONT_COLOR
	if is_primary:
		font_color = MENU_PRIMARY_FONT_COLOR
		hover_color = MENU_PRIMARY_HOVER_FONT_COLOR
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", hover_color)
	button.add_theme_color_override("font_pressed_color", MENU_PRESSED_FONT_COLOR)
	button.add_theme_color_override("font_focus_color", hover_color)
	button.add_theme_color_override("font_disabled_color", MENU_DISABLED_FONT_COLOR)
	button.add_theme_color_override("font_outline_color", MENU_FONT_OUTLINE_COLOR)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 10)
	button.modulate = Color(1.0, 1.0, 1.0, (0.92 if is_disabled else 1.0))


func _apply_footer_button_style(button: Button) -> void:
	var fill_color := FOOTER_FILL_COLOR
	var border_color := FOOTER_BORDER_COLOR
	button.add_theme_stylebox_override("normal", _make_panel_style(fill_color, border_color, 1, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(fill_color.lightened(0.08), border_color.lightened(0.12), 1, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(fill_color.darkened(0.10), border_color, 1, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(fill_color.lightened(0.08), border_color.lightened(0.10), 1, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(fill_color.darkened(0.20), border_color.darkened(0.16), 1, 10))

	button.add_theme_color_override("font_color", FOOTER_FONT_COLOR)
	button.add_theme_color_override("font_hover_color", FOOTER_HOVER_FONT_COLOR)
	button.add_theme_color_override("font_pressed_color", FOOTER_PRESSED_FONT_COLOR)
	button.add_theme_color_override("font_focus_color", FOOTER_HOVER_FONT_COLOR)
	button.add_theme_color_override("font_disabled_color", FOOTER_DISABLED_FONT_COLOR)
	button.add_theme_color_override("font_outline_color", MENU_FONT_OUTLINE_COLOR)
	button.add_theme_color_override("icon_normal_color", FOOTER_ICON_COLOR)
	button.add_theme_color_override("icon_disabled_color", FOOTER_DISABLED_ICON_COLOR)
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 12)


func _apply_profile_overlay_style() -> void:
	_profile_panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(PROFILE_PANEL_FILL_COLOR, PROFILE_PANEL_BORDER_COLOR, 3, 18, Vector4(28, 24, 28, 24))
	)
	for label_node in [_profile_title_label, _profile_name_label, _profile_score_label]:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, PROFILE_LABEL_COLOR, PROFILE_LABEL_OUTLINE_COLOR, 2)
	_set_label_style(_profile_title_label, PROFILE_TITLE_COLOR, PROFILE_LABEL_OUTLINE_COLOR, 3)
	_apply_menu_button_style(_reset_profile_button, false, false)
	_apply_menu_button_style(_close_profile_button, false, false)


func _set_label_style(label: Label, color: Color, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)


func _make_texture_style(texture: Texture2D, texture_margin: float, content_margin_horizontal: float, content_margin_vertical: float, expand_margin: float) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.set_texture_margin_all(texture_margin)
	style.set_expand_margin_all(expand_margin)
	style.content_margin_left = content_margin_horizontal
	style.content_margin_right = content_margin_horizontal
	style.content_margin_top = content_margin_vertical
	style.content_margin_bottom = content_margin_vertical
	return style


func _make_panel_style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	return UI_UTILS.panel_style(fill, border, border_width, corner_radius, Vector4(8, 6, 8, 6))


func _safe_load_texture(path: String, missing_key: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		push_warning("Main menu missing texture for %s at %s" % [missing_key, path])
		return null
	var loaded: Variant = load(path)
	if loaded is Texture2D:
		return loaded as Texture2D
	push_warning("Main menu invalid texture for %s at %s" % [missing_key, path])
	return null


func _scaled_texture(texture: Texture2D, max_side: int) -> Texture2D:
	var image := texture.get_image()
	if image == null:
		return texture
	var source_size := image.get_size()
	var largest_source_side := maxi(source_size.x, source_size.y)
	if largest_source_side <= max_side:
		return texture
	var ratio := float(max_side) / float(largest_source_side)
	var target_size := Vector2i(
		maxi(1, int(round(source_size.x * ratio))),
		maxi(1, int(round(source_size.y * ratio)))
	)
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


func _rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(
		base_rect.position + Vector2(base_rect.size.x * left, base_rect.size.y * top),
		Vector2(base_rect.size.x * width, base_rect.size.y * height)
	)


func _inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(
		rect.position + Vector2(inset, inset),
		Vector2(maxf(0.0, rect.size.x - inset * 2.0), maxf(0.0, rect.size.y - inset * 2.0))
	)


static func _layout_rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(
		base_rect.position + Vector2(base_rect.size.x * left, base_rect.size.y * top),
		Vector2(base_rect.size.x * width, base_rect.size.y * height)
	)


static func _layout_inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(
		rect.position + Vector2(inset, inset),
		Vector2(maxf(0.0, rect.size.x - inset * 2.0), maxf(0.0, rect.size.y - inset * 2.0))
	)


func _set_control_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect.position
	control.size = rect.size
