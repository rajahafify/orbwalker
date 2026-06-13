extends RefCounted
class_name MainMenuSettingsOverlay

signal speed_selected(speed: String)
signal reduced_motion_toggled
signal game_juice_toggled
signal game_juice_flag_toggled(flag_key: String)
signal defaults_reset
signal closed

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const LOCALIZATION_BOOTSTRAP := preload("res://scripts/ui/localization_bootstrap.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const TEXT_KEYS := {
	"settings_title": "MAIN_MENU_SETTINGS_TITLE",
	"settings_vfx_speed": "MAIN_MENU_SETTINGS_VFX_SPEED",
	"settings_comfort": "MAIN_MENU_SETTINGS_COMFORT",
	"settings_game_juice": "MAIN_MENU_SETTINGS_GAME_JUICE",
	"settings_actions": "MAIN_MENU_SETTINGS_ACTIONS",
	"settings_reduced_motion": "MAIN_MENU_SETTINGS_REDUCED_MOTION",
	"settings_reset_defaults": "MAIN_MENU_SETTINGS_RESET_DEFAULTS",
	"close": "MAIN_MENU_CLOSE",
}
const SPEED_ORDER := ["slow", "normal", "fast", "instant"]
const SPEED_LABEL_KEYS := {
	"slow": "MAIN_MENU_SPEED_SLOW",
	"normal": "MAIN_MENU_SPEED_NORMAL",
	"fast": "MAIN_MENU_SPEED_FAST",
	"instant": "MAIN_MENU_SPEED_INSTANT",
}
const MENU_FILL_COLOR := Color(0.055, 0.085, 0.13, 0.96)
const MENU_BORDER_COLOR := Color(0.29, 0.38, 0.49, 0.96)
const MENU_FOCUS_BORDER_COLOR := Color(0.68, 0.82, 0.98, 1.0)
const MENU_FONT_COLOR := Color(0.90, 0.94, 0.98, 1.0)
const MENU_HOVER_FONT_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const MENU_PRESSED_FONT_COLOR := Color(0.84, 0.90, 0.98, 1.0)
const MENU_FONT_OUTLINE_COLOR := Color(0.03, 0.04, 0.07, 0.96)
const SETTINGS_PANEL_FILL_COLOR := Color(0.045, 0.065, 0.085, 0.98)
const SETTINGS_PANEL_BORDER_COLOR := Color(0.78, 0.58, 0.20, 1.0)
const SETTINGS_BUTTON_FONT_MIN_SIZE := 22
const SETTINGS_FLAG_FONT_MIN_SIZE := 20
const SETTINGS_TOGGLE_TITLE_FONT_SIZE := 24
const SETTINGS_TOGGLE_DESCRIPTION_FONT_SIZE := 20

var _overlay: Control = null
var _panel: Panel = null
var _box: VBoxContainer = null
var _scroll: ScrollContainer = null
var _content: VBoxContainer = null
var _title_label: Label = null
var _actions_label: Label = null
var _actions: HBoxContainer = null
var _speed_buttons: Array[Button] = []
var _reduced_motion_button: Button = null
var _game_juice_button: Button = null
var _game_juice_flag_buttons: Dictionary = {}
var _reset_button: Button = null
var _close_button: Button = null


func ensure(host: Control) -> void:
	if _overlay != null or host == null:
		return
	LOCALIZATION_BOOTSTRAP.ensure_loaded()
	_speed_buttons.clear()
	_game_juice_flag_buttons.clear()
	_overlay = Control.new()
	_overlay.name = "SettingsOverlay"
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	host.add_child(_overlay)

	var scrim := ColorRect.new()
	scrim.name = "SettingsScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.66)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	_overlay.add_child(scrim)

	_panel = Panel.new()
	_panel.name = "SettingsPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.add_child(_panel)

	_box = VBoxContainer.new()
	_box.name = "SettingsBox"
	_box.add_theme_constant_override("separation", 12)
	_panel.add_child(_box)

	_title_label = Label.new()
	_title_label.name = "SettingsTitle"
	_title_label.text = _text("settings_title")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 42)
	_box.add_child(_title_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "SettingsScroll"
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED as ScrollContainer.ScrollMode
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_box.add_child(_scroll)

	_content = VBoxContainer.new()
	_content.name = "SettingsContent"
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 12)
	_scroll.add_child(_content)

	_content.add_child(_section_label(_text("settings_vfx_speed"), "SettingsSpeedLabel"))
	for speed in SPEED_ORDER:
		var button := Button.new()
		button.name = "Speed%sButton" % speed.capitalize()
		button.text = _speed_label(speed)
		button.set_meta("speed", speed)
		button.custom_minimum_size = Vector2(0.0, 58.0)
		button.pressed.connect(func() -> void: speed_selected.emit(speed))
		_speed_buttons.append(button)
		_content.add_child(button)

	_content.add_child(_section_label(_text("settings_comfort"), "SettingsComfortLabel"))
	_reduced_motion_button = CheckButton.new()
	_reduced_motion_button.name = "SettingsReducedMotionButton"
	_reduced_motion_button.custom_minimum_size = Vector2(0.0, 58.0)
	_reduced_motion_button.pressed.connect(func() -> void: reduced_motion_toggled.emit())
	_content.add_child(_toggle_row(_reduced_motion_button, _text("settings_reduced_motion"), ""))

	_content.add_child(_section_label(_text("settings_game_juice"), "SettingsGameJuiceLabel"))
	_game_juice_button = CheckButton.new()
	_game_juice_button.name = "SettingsGameJuiceButton"
	_game_juice_button.custom_minimum_size = Vector2(0.0, 58.0)
	_game_juice_button.pressed.connect(func() -> void: game_juice_toggled.emit())
	_content.add_child(_toggle_row(_game_juice_button, tr("SETTINGS_JUICE_MASTER"), tr("SETTINGS_JUICE_MASTER_DESC")))

	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var flag_button := CheckButton.new()
		flag_button.name = _flag_button_name(flag_key)
		flag_button.custom_minimum_size = Vector2(0.0, 58.0)
		var captured_flag_key := flag_key
		flag_button.pressed.connect(func() -> void: game_juice_flag_toggled.emit(captured_flag_key))
		_game_juice_flag_buttons[flag_key] = flag_button
		_content.add_child(_toggle_row(flag_button, _juice_flag_label(flag_key), _juice_flag_description(flag_key)))

	_actions_label = _section_label(_text("settings_actions"), "SettingsActionsLabel")
	_box.add_child(_actions_label)
	_actions = HBoxContainer.new()
	_actions.name = "SettingsActions"
	_actions.add_theme_constant_override("separation", 14)
	_box.add_child(_actions)

	_reset_button = Button.new()
	_reset_button.name = "SettingsResetDefaultsButton"
	_reset_button.text = _text("settings_reset_defaults").to_upper()
	_reset_button.custom_minimum_size = Vector2(0.0, 62.0)
	_reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_reset_button.pressed.connect(func() -> void: defaults_reset.emit())
	_actions.add_child(_reset_button)

	_close_button = Button.new()
	_close_button.name = "SettingsCloseButton"
	_close_button.text = _text("close")
	_close_button.custom_minimum_size = Vector2(0.0, 62.0)
	_close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_close_button.pressed.connect(func() -> void: closed.emit())
	_actions.add_child(_close_button)
	apply_style()


func show(settings: Variant) -> void:
	if _overlay == null:
		return
	_overlay.visible = true
	var settings_dict := _settings_dictionary(settings)
	_update_speed_buttons(String(settings_dict.get("vfx_speed", "normal")))
	_update_reduced_motion_button(bool(settings_dict.get("reduced_motion", false)))
	_update_game_juice_button(bool(settings_dict.get("game_juice", true)))
	_update_game_juice_flag_buttons(Dictionary(settings_dict.get("game_juice_flags", GAME_JUICE_FLAGS_SCRIPT.default_flags())))
	focus_first()


func hide() -> void:
	if _overlay != null:
		_overlay.visible = false


func is_visible() -> bool:
	return _overlay != null and _overlay.visible


func focus_controls() -> Array:
	var controls: Array = []
	controls.append_array(_speed_buttons)
	controls.append(_reduced_motion_button)
	controls.append(_game_juice_button)
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		controls.append(_game_juice_flag_buttons.get(flag_key, null))
	controls.append(_reset_button)
	controls.append(_close_button)
	return controls


func focus_first() -> void:
	for raw_control in focus_controls():
		var control := raw_control as Button
		if control != null and not control.disabled and control.visible:
			control.grab_focus.call_deferred()
			return


func layout(viewport_size: Vector2) -> void:
	if _overlay == null or _panel == null or viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_set_control_rect(_overlay, Rect2(Vector2.ZERO, viewport_size))
	var outer_margin := clampf(minf(viewport_size.x, viewport_size.y) * 0.035, 14.0, 42.0)
	var panel_rect := Rect2(
		Vector2(outer_margin, outer_margin), Vector2(maxf(0.0, viewport_size.x - outer_margin * 2.0), maxf(0.0, viewport_size.y - outer_margin * 2.0))
	)
	_set_control_rect(_panel, panel_rect)
	if _box != null:
		var inner_x := clampf(viewport_size.x * 0.045, 18.0, 48.0)
		var inner_y := clampf(viewport_size.y * 0.026, 18.0, 42.0)
		_set_control_rect(
			_box, Rect2(Vector2(inner_x, inner_y), Vector2(maxf(0.0, panel_rect.size.x - inner_x * 2.0), maxf(0.0, panel_rect.size.y - inner_y * 2.0)))
		)
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var button_height := clampf(viewport_size.y * 0.060, 58.0, 82.0)
	var action_button_height := clampf(viewport_size.y * 0.066, 64.0, 88.0)
	var button_font := maxi(SETTINGS_BUTTON_FONT_MIN_SIZE, int(round(34.0 * scale_factor)))
	var flag_font := maxi(SETTINGS_FLAG_FONT_MIN_SIZE, int(round(30.0 * scale_factor)))
	if _title_label != null:
		_title_label.add_theme_font_size_override("font_size", maxi(30, int(round(54.0 * scale_factor))))
	if _actions != null:
		_actions.add_theme_constant_override("separation", int(round(clampf(14.0 * scale_factor, 10.0, 18.0))))
	for button in _speed_buttons:
		button.custom_minimum_size = Vector2(0.0, button_height)
		button.add_theme_font_size_override("font_size", button_font)
	for button in [_reduced_motion_button, _game_juice_button]:
		if button != null:
			button.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.22, 104.0, 132.0), button_height)
			button.add_theme_font_size_override("font_size", button_font)
	for raw_button in _game_juice_flag_buttons.values():
		var flag_button := raw_button as Button
		if flag_button != null:
			flag_button.custom_minimum_size = Vector2(clampf(viewport_size.x * 0.22, 104.0, 132.0), button_height)
			flag_button.add_theme_font_size_override("font_size", flag_font)
	for button in [_reset_button, _close_button]:
		if button != null:
			button.custom_minimum_size = Vector2(0.0, action_button_height)
			button.add_theme_font_size_override("font_size", button_font)


func apply_style() -> void:
	if _panel != null:
		_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(SETTINGS_PANEL_FILL_COLOR, SETTINGS_PANEL_BORDER_COLOR, 2, 8, Vector4(32, 28, 32, 28)))
	for button in _speed_buttons:
		_apply_button_style(button)
		button.add_theme_font_size_override("font_size", SETTINGS_BUTTON_FONT_MIN_SIZE)
	for button in [_reduced_motion_button, _game_juice_button]:
		if button != null:
			_apply_button_style(button)
			button.add_theme_font_size_override("font_size", SETTINGS_BUTTON_FONT_MIN_SIZE)
	for button in _game_juice_flag_buttons.values():
		var flag_button := button as Button
		if flag_button == null:
			continue
		_apply_button_style(flag_button)
		flag_button.add_theme_font_size_override("font_size", SETTINGS_FLAG_FONT_MIN_SIZE)
	for button in [_reset_button, _close_button]:
		if button != null:
			_apply_button_style(button)
			button.add_theme_font_size_override("font_size", SETTINGS_BUTTON_FONT_MIN_SIZE)


static func localization_keys() -> Array[String]:
	var keys: Array[String] = []
	for value in TEXT_KEYS.values():
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


func _section_label(text: String, node_name: String = "") -> Label:
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


func _toggle_row(button: Button, title: String, description: String) -> HBoxContainer:
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
	title_label.add_theme_font_size_override("font_size", SETTINGS_TOGGLE_TITLE_FONT_SIZE)
	title_label.add_theme_color_override("font_color", MENU_FONT_COLOR)
	title_label.add_theme_color_override("font_outline_color", MENU_FONT_OUTLINE_COLOR)
	title_label.add_theme_constant_override("outline_size", 1)
	text_column.add_child(title_label)
	if description.strip_edges() != "":
		var description_label := Label.new()
		description_label.name = "%sDescriptionLabel" % button.name.trim_suffix("Button")
		description_label.text = description
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		description_label.add_theme_font_size_override("font_size", SETTINGS_TOGGLE_DESCRIPTION_FONT_SIZE)
		description_label.add_theme_color_override("font_color", Color(0.76, 0.82, 0.88, 0.94))
		description_label.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 0.92))
		description_label.add_theme_constant_override("outline_size", 1)
		text_column.add_child(description_label)
	row.add_child(text_column)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.custom_minimum_size = Vector2(112.0, 58.0)
	row.add_child(button)
	return row


func _update_speed_buttons(speed: String) -> void:
	var normalized := speed.strip_edges().to_lower()
	for button in _speed_buttons:
		var button_speed := String(button.get_meta("speed", "")).to_lower()
		var selected := button_speed == normalized
		var label := _speed_label(button_speed)
		button.text = ("%s  *" % label) if selected else label


func _update_reduced_motion_button(enabled: bool) -> void:
	if _reduced_motion_button == null:
		return
	_reduced_motion_button.text = _on_off_label(enabled)
	_reduced_motion_button.set_pressed_no_signal(enabled)


func _update_game_juice_button(enabled: bool) -> void:
	if _game_juice_button == null:
		return
	_game_juice_button.text = _on_off_label(enabled)
	_game_juice_button.set_pressed_no_signal(enabled)


func _update_game_juice_flag_buttons(flags: Dictionary) -> void:
	var normalized_flags := GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var button := _game_juice_flag_buttons.get(flag_key, null) as Button
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


func _flag_button_name(flag_key: String) -> String:
	var output := "JuiceFlag"
	for part in flag_key.split("_", false):
		output += String(part).capitalize()
	return "%sButton" % output


func _apply_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_panel_style(MENU_FILL_COLOR, MENU_BORDER_COLOR, 2, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(MENU_FILL_COLOR.lightened(0.10), MENU_BORDER_COLOR.lightened(0.10), 2, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(MENU_FILL_COLOR.darkened(0.12), MENU_BORDER_COLOR, 2, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(MENU_FILL_COLOR.lightened(0.08), MENU_FOCUS_BORDER_COLOR, 2, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(MENU_FILL_COLOR.darkened(0.24), MENU_BORDER_COLOR.darkened(0.18), 2, 10))
	button.add_theme_color_override("font_color", MENU_FONT_COLOR)
	button.add_theme_color_override("font_hover_color", MENU_HOVER_FONT_COLOR)
	button.add_theme_color_override("font_pressed_color", MENU_PRESSED_FONT_COLOR)
	button.add_theme_color_override("font_focus_color", MENU_HOVER_FONT_COLOR)
	button.add_theme_color_override("font_outline_color", MENU_FONT_OUTLINE_COLOR)
	button.add_theme_constant_override("outline_size", 2)


func _make_panel_style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	return UI_UTILS.panel_style(fill, border, border_width, corner_radius, Vector4(16, 10, 16, 10))


func _set_control_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.offset_left = rect.position.x
	control.offset_top = rect.position.y
	control.offset_right = rect.position.x + rect.size.x
	control.offset_bottom = rect.position.y + rect.size.y
