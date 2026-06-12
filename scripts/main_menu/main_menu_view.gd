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
const SETTINGS_OVERLAY_SCRIPT := preload("res://scripts/main_menu/main_menu_settings_overlay.gd")
const FOCUS_NAVIGATOR := preload("res://scripts/main_menu/main_menu_focus_navigator.gd")
const ACCESSIBILITY_CONTRACT := preload("res://scripts/main_menu/main_menu_accessibility_contract.gd")
const PROFILE_STYLER := preload("res://scripts/main_menu/main_menu_profile_styler.gd")
const TEXTURE_APPLIER := preload("res://scripts/main_menu/main_menu_texture_applier.gd")
const TEXT_CATALOG := preload("res://scripts/main_menu/main_menu_text_catalog.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
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
var _element_icons: Array = []
var _element_labels: Array = []
var _stat_icons: Array = []
var _stat_titles: Array = []
var _stat_values: Array = []

var _settings_overlay = SETTINGS_OVERLAY_SCRIPT.new()


func _init() -> void:
	_settings_overlay.speed_selected.connect(func(speed: String) -> void: settings_speed_selected.emit(speed))
	_settings_overlay.reduced_motion_toggled.connect(func() -> void: settings_reduced_motion_toggled.emit())
	_settings_overlay.game_juice_toggled.connect(func() -> void: settings_game_juice_toggled.emit())
	_settings_overlay.game_juice_flag_toggled.connect(func(flag_key: String) -> void: settings_game_juice_flag_toggled.emit(flag_key))
	_settings_overlay.defaults_reset.connect(func() -> void: settings_defaults_reset.emit())
	_settings_overlay.closed.connect(func() -> void: settings_closed.emit())


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
	_settings_overlay.ensure(host)


func apply_textures(paths: Dictionary) -> void:
	(
		TEXTURE_APPLIER
		. apply(
			paths,
			{
				"background_texture": _background_texture,
				"logo_texture": _logo_texture,
				"outer_border_texture": _outer_border_texture,
				"footer_buttons": [_profile_button, _achievements_button, _footer_settings_button],
			},
			_element_icons,
			_stat_icons
		)
	)


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
	(
		PROFILE_STYLER
		. apply(
			_profile_panel,
			_profile_title_label,
			_profile_name_label,
			_profile_score_label,
			_reset_profile_button,
			_close_profile_button,
			{
				"panel_fill": PROFILE_PANEL_FILL_COLOR,
				"panel_border": PROFILE_PANEL_BORDER_COLOR,
				"label": PROFILE_LABEL_COLOR,
				"title": PROFILE_TITLE_COLOR,
				"label_outline": PROFILE_LABEL_OUTLINE_COLOR,
			},
			Callable(self, "_set_label_style"),
			Callable(self, "_apply_menu_button_style")
		)
	)
	_settings_overlay.apply_style()

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
	var safe_rect := ACCESSIBILITY_CONTRACT.inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (34.0 / DESIGN_SIZE.x))

	ACCESSIBILITY_CONTRACT.set_control_rect(_background_texture, Rect2(Vector2.ZERO, viewport_size))
	ACCESSIBILITY_CONTRACT.set_control_rect(_overlay_tint, Rect2(Vector2.ZERO, viewport_size))
	ACCESSIBILITY_CONTRACT.set_control_rect(_outer_frame, Rect2(Vector2.ZERO, viewport_size))
	ACCESSIBILITY_CONTRACT.set_control_rect(
		_outer_border_texture, ACCESSIBILITY_CONTRACT.inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (12.0 / DESIGN_SIZE.x))
	)
	ACCESSIBILITY_CONTRACT.set_control_rect(_logo_texture, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.06, 0.11, 0.88, 0.20))
	ACCESSIBILITY_CONTRACT.set_control_rect(_menu_button_column, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.18, 0.34, 0.64, 0.44))
	ACCESSIBILITY_CONTRACT.set_control_rect(_element_row, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.03, 0.57, 0.94, 0.12))
	ACCESSIBILITY_CONTRACT.set_control_rect(_stats_panel, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14))
	ACCESSIBILITY_CONTRACT.set_control_rect(_footer_actions, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.077))
	ACCESSIBILITY_CONTRACT.set_control_rect(_version_label, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.33, 0.946, 0.34, 0.022))
	ACCESSIBILITY_CONTRACT.set_control_rect(_status_label, ACCESSIBILITY_CONTRACT.rect_from_percent_in_rect(safe_rect, 0.04, 0.973, 0.92, 0.019))
	ACCESSIBILITY_CONTRACT.set_control_rect(
		_stats_row, Rect2(Vector2(_stats_panel.size.x * 0.055, _stats_panel.size.y * 0.28), Vector2(_stats_panel.size.x * 0.89, _stats_panel.size.y * 0.48))
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

	_profile_panel.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.78, 520.0, 760.0), clampf(viewport_size.y * 0.22, 330.0, 460.0))
	_reset_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))
	_close_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))
	_settings_overlay.layout(viewport_size)
	_apply_font_sizes(viewport_size)


func configure_focus_navigation() -> void:
	FOCUS_NAVIGATOR.configure(
		_main_menu_buttons(),
		[_reset_profile_button, _close_profile_button],
		_settings_overlay.focus_controls(),
		_settings_overlay.is_visible(),
		_profile_overlay
	)


static func layout_probe_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	return ACCESSIBILITY_CONTRACT.layout_probe_snapshot(viewport_size)


static func accessibility_audit_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	return ACCESSIBILITY_CONTRACT.accessibility_audit_snapshot(viewport_size)


func set_generate_log_toggle(enabled: bool) -> void:
	_generate_log_toggle.set_pressed_no_signal(enabled)


func set_continue_enabled(enabled: bool) -> void:
	_continue_button.disabled = not enabled
	_apply_menu_button_style(_continue_button, false, not enabled)


func show_settings(settings: Variant) -> void:
	_settings_overlay.show(settings)


func hide_settings() -> void:
	_settings_overlay.hide()
	if _settings_button != null and not _settings_button.disabled:
		_settings_button.grab_focus.call_deferred()


func set_profile_overlay_visible(visible: bool) -> void:
	_profile_overlay.visible = visible
	if visible:
		FOCUS_NAVIGATOR.focus_first([_reset_profile_button, _close_profile_button])
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


func _can_grab_main_menu_focus() -> bool:
	return FOCUS_NAVIGATOR.can_grab_main_menu_focus(_settings_overlay.is_visible(), _profile_overlay)


func _text(key_name: String) -> String:
	return TEXT_CATALOG.text(key_name)


static func localization_keys() -> Array[String]:
	return TEXT_CATALOG.localization_keys()


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
	button.modulate = Color(1.0, 1.0, 1.0, 0.92 if is_disabled else 1.0)


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


func _set_label_style(label: Label, color: Color, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)


func _make_panel_style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	return UI_UTILS.panel_style(fill, border, border_width, corner_radius, Vector4(8, 6, 8, 6))
