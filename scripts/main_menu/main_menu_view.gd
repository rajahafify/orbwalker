extends RefCounted
class_name MainMenuView

signal settings_speed_selected(speed: String)
signal settings_closed

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)

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
var _settings_speed_buttons: Array[Button] = []
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
	_start_run_button.text = "START RUN"
	_generate_log_toggle.text = "GENERATE LOG"
	_continue_button.text = "CONTINUE"
	_collection_button.text = "COLLECTION"
	_tutorial_button.text = "TUTORIAL"
	_settings_button.text = "SETTINGS"
	_quit_button.text = "QUIT"
	_profile_button.text = "PROFILE"
	_achievements_button.text = "ACHIEVEMENTS"
	_footer_settings_button.text = "SETTINGS"
	_version_label.text = "DEMO 0.1.0"
	_status_label.text = "Main menu runtime surface."
	_status_label.visible = false
	_continue_button.disabled = true
	_collection_button.disabled = false
	_tutorial_button.disabled = false
	_settings_button.disabled = false
	_quit_button.disabled = false
	_profile_button.disabled = false
	_achievements_button.disabled = true
	_footer_settings_button.disabled = true

	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			label.text = label.text.to_upper()

	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			title.text = title.text.to_upper()

	var value_label := _stat_values[2] as Label
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

	_set_label_style(_version_label, Color(0.86, 0.73, 0.46, 0.96), Color(0.05, 0.06, 0.10, 0.95), 2)
	_set_label_style(_status_label, Color(0.86, 0.73, 0.46, 0.88), Color(0.05, 0.06, 0.10, 0.95), 2)
	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, Color(0.86, 0.75, 0.51, 0.98), Color(0.04, 0.05, 0.08, 0.96), 2)
	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			_set_label_style(title, Color(0.86, 0.75, 0.51, 0.98), Color(0.04, 0.05, 0.08, 0.96), 2)
	for value_node in _stat_values:
		var value := value_node as Label
		if value != null:
			_set_label_style(value, Color(0.96, 0.90, 0.76, 0.99), Color(0.05, 0.06, 0.10, 0.96), 2)


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
	_apply_font_sizes(viewport_size)


func set_generate_log_toggle(enabled: bool) -> void:
	_generate_log_toggle.set_pressed_no_signal(enabled)


func set_continue_enabled(enabled: bool) -> void:
	_continue_button.disabled = not enabled
	_apply_menu_button_style(_continue_button, false, not enabled)


func show_settings(speed: String) -> void:
	if _settings_overlay == null:
		return
	_settings_overlay.visible = true
	_update_settings_speed_buttons(speed)


func hide_settings() -> void:
	if _settings_overlay != null:
		_settings_overlay.visible = false


func set_profile_overlay_visible(visible: bool) -> void:
	_profile_overlay.visible = visible


func set_profile_content(profile_name: String, profile_score: String) -> void:
	_profile_name_label.text = profile_name
	_profile_score_label.text = profile_score


func set_start_run_locked(locked: bool) -> void:
	_start_run_button.disabled = locked


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


func _ensure_settings_overlay(host: Control) -> void:
	if _settings_overlay != null or host == null:
		return
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

	var center := CenterContainer.new()
	center.name = "SettingsCenter"
	center.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	_settings_overlay.add_child(center)

	_settings_panel = Panel.new()
	_settings_panel.name = "SettingsPanel"
	_settings_panel.custom_minimum_size = Vector2(680.0, 650.0)
	center.add_child(_settings_panel)

	var box := VBoxContainer.new()
	box.name = "SettingsBox"
	box.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	box.offset_left = 42.0
	box.offset_top = 36.0
	box.offset_right = -42.0
	box.offset_bottom = -36.0
	box.add_theme_constant_override("separation", 14)
	_settings_panel.add_child(box)

	var title := Label.new()
	title.name = "SettingsTitle"
	title.text = "Settings"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	box.add_child(title)

	var speed_label := Label.new()
	speed_label.name = "SettingsSpeedLabel"
	speed_label.text = "VFX Speed"
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speed_label.add_theme_font_size_override("font_size", 26)
	box.add_child(speed_label)

	for speed in ["slow", "normal", "fast", "instant"]:
		var button := Button.new()
		button.name = "Speed%sButton" % speed.capitalize()
		button.text = speed.to_upper()
		button.custom_minimum_size = Vector2(0.0, 62.0)
		button.pressed.connect(func() -> void: settings_speed_selected.emit(speed))
		_settings_speed_buttons.append(button)
		box.add_child(button)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 18.0)
	box.add_child(gap)

	_settings_close_button = Button.new()
	_settings_close_button.name = "SettingsCloseButton"
	_settings_close_button.text = "CLOSE"
	_settings_close_button.custom_minimum_size = Vector2(0.0, 62.0)
	_settings_close_button.pressed.connect(func() -> void: settings_closed.emit())
	box.add_child(_settings_close_button)
	_apply_settings_overlay_style()


func _apply_settings_overlay_style() -> void:
	if _settings_panel != null:
		_settings_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.045, 0.065, 0.085, 0.98), Color(0.78, 0.58, 0.20, 1.0), 2, 8, Vector4(32, 28, 32, 28)))
	for button in _settings_speed_buttons:
		_apply_menu_button_style(button, false, false)
		button.add_theme_font_size_override("font_size", 24)
	if _settings_close_button != null:
		_apply_menu_button_style(_settings_close_button, false, false)
		_settings_close_button.add_theme_font_size_override("font_size", 24)


func _update_settings_speed_buttons(speed: String) -> void:
	var normalized := speed.strip_edges().to_lower()
	for button in _settings_speed_buttons:
		var button_speed := button.text.replace("  *", "").to_lower()
		var selected := button_speed == normalized
		button.text = ("%s  *" % button_speed.to_upper()) if selected else button_speed.to_upper()


func _apply_menu_button_style(button: Button, is_primary: bool, is_disabled: bool) -> void:
	var fill_color := Color(0.055, 0.085, 0.13, 0.96)
	var border_color := Color(0.29, 0.38, 0.49, 0.96)
	if is_primary:
		fill_color = Color(0.07, 0.11, 0.17, 0.98)
		border_color = Color(0.43, 0.57, 0.72, 0.98)
	button.add_theme_stylebox_override("normal", _make_panel_style(fill_color, border_color, 2, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(fill_color.lightened(0.10), border_color.lightened(0.10), 2, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(fill_color.darkened(0.12), border_color, 2, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(fill_color.lightened(0.08), border_color.lightened(0.08), 2, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(fill_color.darkened(0.24), border_color.darkened(0.18), 2, 10))

	var font_color := Color(0.90, 0.94, 0.98, 1.0)
	var hover_color := Color(0.95, 0.98, 1.0, 1.0)
	if is_primary:
		font_color = Color(0.96, 0.98, 1.0, 1.0)
		hover_color = Color(1.0, 1.0, 1.0, 1.0)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", hover_color)
	button.add_theme_color_override("font_pressed_color", Color(0.84, 0.90, 0.98, 1.0))
	button.add_theme_color_override("font_focus_color", hover_color)
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.70, 0.79, 0.84))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.96))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 10)
	button.modulate = Color(1.0, 1.0, 1.0, (0.92 if is_disabled else 1.0))


func _apply_footer_button_style(button: Button) -> void:
	var fill_color := Color(0.045, 0.075, 0.115, 0.94)
	var border_color := Color(0.24, 0.33, 0.42, 0.92)
	button.add_theme_stylebox_override("normal", _make_panel_style(fill_color, border_color, 1, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(fill_color.lightened(0.08), border_color.lightened(0.12), 1, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(fill_color.darkened(0.10), border_color, 1, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(fill_color.lightened(0.08), border_color.lightened(0.10), 1, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(fill_color.darkened(0.20), border_color.darkened(0.16), 1, 10))

	button.add_theme_color_override("font_color", Color(0.86, 0.92, 0.98, 0.98))
	button.add_theme_color_override("font_hover_color", Color(0.93, 0.97, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.80, 0.88, 0.96, 0.98))
	button.add_theme_color_override("font_focus_color", Color(0.93, 0.97, 1.0, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.61, 0.69, 0.76, 0.80))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.96))
	button.add_theme_color_override("icon_normal_color", Color(1.0, 1.0, 1.0, 0.94))
	button.add_theme_color_override("icon_disabled_color", Color(0.72, 0.72, 0.72, 0.62))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 12)


func _apply_profile_overlay_style() -> void:
	_profile_panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(Color(0.07, 0.055, 0.045, 0.96), Color(0.86, 0.63, 0.24, 1.0), 3, 18, Vector4(28, 24, 28, 24))
	)
	for label_node in [_profile_title_label, _profile_name_label, _profile_score_label]:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, Color(0.95, 0.88, 0.72, 1.0), Color(0.04, 0.03, 0.02, 0.96), 2)
	_set_label_style(_profile_title_label, Color(1.0, 0.78, 0.30, 1.0), Color(0.04, 0.03, 0.02, 0.96), 3)
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


func _set_control_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect.position
	control.size = rect.size
