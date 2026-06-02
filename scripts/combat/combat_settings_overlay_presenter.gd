extends RefCounted
class_name CombatSettingsOverlayPresenter

const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const DEFAULT_DESIGN_SIZE := Vector2(1080.0, 1920.0)
const PANEL_MARGIN := Vector2(36.0, 64.0)
const PANEL_INSET := Vector2(42.0, 36.0)
const SPEED_OPTIONS: Array[String] = ["slow", "normal", "fast", "instant"]
const QUALITY_OPTIONS: Array[String] = ["low", "high"]

const CALLBACK_CONTINUE := "continue"
const CALLBACK_NEW_RUN := "new_run"
const CALLBACK_MAIN_MENU := "main_menu"
const CALLBACK_SPEED_SELECTED := "speed_selected"
const CALLBACK_QUALITY_SELECTED := "quality_selected"
const CALLBACK_REDUCED_MOTION_TOGGLED := "reduced_motion_toggled"
const CALLBACK_GAME_JUICE_TOGGLED := "game_juice_toggled"
const CALLBACK_GAME_JUICE_FLAG_TOGGLED := "game_juice_flag_toggled"
const CALLBACK_RESET_DEFAULTS := "reset_defaults"

var _parent: Control = null
var _overlay: Control = null
var _panel: Panel = null
var _speed_buttons: Array[Button] = []
var _quality_buttons: Array[Button] = []
var _reduced_motion_button: Button = null
var _game_juice_button: Button = null
var _game_juice_flag_buttons: Dictionary = {}
var _continue_button: Button = null
var _new_run_button: Button = null
var _main_menu_button: Button = null
var _reset_defaults_button: Button = null
var _callbacks: Dictionary = {}
var _design_size := DEFAULT_DESIGN_SIZE


func bind(parent: Control, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_parent = parent
	_callbacks = callbacks.duplicate()
	_design_size = config.get("design_size", DEFAULT_DESIGN_SIZE)


func show(settings: Variant) -> void:
	ensure_overlay()
	if _overlay == null:
		return
	_overlay.visible = true
	update_settings_state(_settings_dictionary(settings))


func hide() -> void:
	if _overlay != null:
		_overlay.visible = false


func is_visible() -> bool:
	return _overlay != null and _overlay.visible


func ensure_overlay() -> void:
	if _overlay != null or _parent == null:
		return
	_speed_buttons.clear()
	_quality_buttons.clear()
	_game_juice_flag_buttons.clear()
	_overlay = Control.new()
	_overlay.name = "CombatSettingsOverlay"
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.z_index = 260
	_overlay.position = Vector2.ZERO
	_overlay.size = _design_size
	_parent.add_child(_overlay)

	var scrim := ColorRect.new()
	scrim.name = "SettingsScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.66)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	scrim.position = Vector2.ZERO
	scrim.size = _design_size
	_overlay.add_child(scrim)

	_panel = Panel.new()
	_panel.name = "SettingsPanel"
	_panel.position = PANEL_MARGIN
	_panel.size = _design_size - PANEL_MARGIN * 2.0
	_panel.add_theme_stylebox_override("panel", _settings_panel_style())
	_overlay.add_child(_panel)

	var box := VBoxContainer.new()
	box.name = "SettingsBox"
	box.position = PANEL_INSET
	box.size = _panel.size - PANEL_INSET * 2.0
	box.add_theme_constant_override("separation", 12)
	_panel.add_child(box)

	box.add_child(_settings_label("Settings", 44))
	var scroll := ScrollContainer.new()
	scroll.name = "SettingsScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED as ScrollContainer.ScrollMode
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var content := VBoxContainer.new()
	content.name = "SettingsContent"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)

	content.add_child(_settings_label("VFX Speed", 28))
	for speed in SPEED_OPTIONS:
		var button := _make_settings_menu_button(speed.to_upper())
		button.pressed.connect(func() -> void: _emit_speed_selected(speed))
		_speed_buttons.append(button)
		content.add_child(button)
	content.add_child(_settings_label("VFX Quality", 28))
	for quality in QUALITY_OPTIONS:
		var button := _make_settings_menu_button(quality.to_upper())
		button.pressed.connect(func() -> void: _emit_quality_selected(quality))
		_quality_buttons.append(button)
		content.add_child(button)
	content.add_child(_settings_label("Comfort", 28))
	_reduced_motion_button = _make_settings_toggle_button()
	_reduced_motion_button.pressed.connect(func() -> void: _emit_reduced_motion_toggled())
	content.add_child(_settings_toggle_row(_reduced_motion_button, "Reduced Motion", "Suppresses motion-heavy juice even when the flags below are enabled."))
	content.add_child(_settings_label("Game Juice", 28))
	_game_juice_button = _make_settings_toggle_button()
	_game_juice_button.pressed.connect(func() -> void: _emit_game_juice_toggled())
	content.add_child(_settings_toggle_row(_game_juice_button, "Game Juice", "Master switch for optional feedback layers."))
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var flag_button := _make_settings_toggle_button()
		flag_button.name = _settings_flag_button_name(flag_key)
		var captured_flag_key := flag_key
		flag_button.pressed.connect(func() -> void: _emit_game_juice_flag_toggled(captured_flag_key))
		_game_juice_flag_buttons[flag_key] = flag_button
		content.add_child(_settings_toggle_row(flag_button, _juice_flag_label(flag_key), _juice_flag_description(flag_key)))

	box.add_child(_settings_label("Actions", 28))
	var action_grid := GridContainer.new()
	action_grid.name = "SettingsActions"
	action_grid.columns = 2
	action_grid.add_theme_constant_override("h_separation", 12)
	action_grid.add_theme_constant_override("v_separation", 10)
	action_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(action_grid)

	_continue_button = _make_settings_menu_button("CONTINUE")
	_reset_defaults_button = _make_settings_menu_button("RESET DEFAULTS")
	_new_run_button = _make_settings_menu_button("NEW RUN")
	_main_menu_button = _make_settings_menu_button("MAIN MENU")
	_continue_button.pressed.connect(func() -> void: _emit(CALLBACK_CONTINUE))
	_reset_defaults_button.pressed.connect(func() -> void: _emit(CALLBACK_RESET_DEFAULTS))
	_new_run_button.pressed.connect(func() -> void: _emit(CALLBACK_NEW_RUN))
	_main_menu_button.pressed.connect(func() -> void: _emit(CALLBACK_MAIN_MENU))
	action_grid.add_child(_continue_button)
	action_grid.add_child(_reset_defaults_button)
	action_grid.add_child(_new_run_button)
	action_grid.add_child(_main_menu_button)


func update_speed_buttons(speed: String) -> void:
	var normalized := speed.to_lower()
	for button in _speed_buttons:
		var button_speed := button.text.replace(" *", "").to_lower()
		var selected := button_speed == normalized
		button.text = ("%s *" % button_speed.to_upper()) if selected else button_speed.to_upper()


func update_settings_state(settings: Dictionary) -> void:
	update_speed_buttons(String(settings.get("vfx_speed", "normal")))
	update_quality_buttons(String(settings.get("combat_vfx_quality", "low")))
	update_reduced_motion_button(bool(settings.get("reduced_motion", false)))
	update_game_juice_button(bool(settings.get("game_juice", false)))
	update_game_juice_flag_buttons(Dictionary(settings.get("game_juice_flags", GAME_JUICE_FLAGS_SCRIPT.default_flags())))


func update_quality_buttons(quality: String) -> void:
	var normalized := quality.to_lower()
	for button in _quality_buttons:
		var button_quality := button.text.replace(" *", "").to_lower()
		var selected := button_quality == normalized
		button.text = ("%s *" % button_quality.to_upper()) if selected else button_quality.to_upper()


func update_reduced_motion_button(enabled: bool) -> void:
	if _reduced_motion_button == null:
		return
	_reduced_motion_button.text = _on_off_label(enabled)
	_reduced_motion_button.set_pressed_no_signal(enabled)


func update_game_juice_button(enabled: bool) -> void:
	if _game_juice_button == null:
		return
	_game_juice_button.text = _on_off_label(enabled)
	_game_juice_button.set_pressed_no_signal(enabled)


func update_game_juice_flag_buttons(flags: Dictionary) -> void:
	var normalized_flags := GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		var button := _game_juice_flag_buttons.get(flag_key, null) as Button
		if button == null:
			continue
		var enabled := bool(normalized_flags.get(flag_key, true))
		button.text = _on_off_label(enabled)
		button.set_pressed_no_signal(enabled)


func speed_buttons() -> Array[Button]:
	return _speed_buttons.duplicate()


func quality_buttons() -> Array[Button]:
	return _quality_buttons.duplicate()


func reduced_motion_button() -> Button:
	return _reduced_motion_button


func game_juice_button() -> Button:
	return _game_juice_button


func game_juice_flag_buttons() -> Dictionary:
	return _game_juice_flag_buttons.duplicate()


func reset_defaults_button() -> Button:
	return _reset_defaults_button


func continue_button() -> Button:
	return _continue_button


func new_run_button() -> Button:
	return _new_run_button


func main_menu_button() -> Button:
	return _main_menu_button


func _settings_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.36, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 1.0))
	label.add_theme_constant_override("outline_size", 2)
	return label


func _settings_group_gap() -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 10.0)
	return spacer


func _settings_toggle_row(button: Button, title: String, description: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 3)
	var title_label := Label.new()
	title_label.text = title
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84, 1.0))
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 1.0))
	title_label.add_theme_constant_override("outline_size", 1)
	text_column.add_child(title_label)
	if description.strip_edges() != "":
		var description_label := Label.new()
		description_label.text = description
		description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		description_label.add_theme_font_size_override("font_size", 16)
		description_label.add_theme_color_override("font_color", Color(0.74, 0.80, 0.86, 0.94))
		description_label.add_theme_color_override("font_outline_color", Color(0.02, 0.025, 0.03, 1.0))
		description_label.add_theme_constant_override("outline_size", 1)
		text_column.add_child(description_label)
	row.add_child(text_column)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.custom_minimum_size = Vector2(132.0, 66.0)
	row.add_child(button)
	return row


func _make_settings_menu_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 66.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _settings_button_style(Color(0.055, 0.085, 0.12, 0.98), Color(0.38, 0.50, 0.62, 1.0)))
	button.add_theme_stylebox_override("hover", _settings_button_style(Color(0.075, 0.115, 0.16, 1.0), Color(0.55, 0.70, 0.84, 1.0)))
	button.add_theme_stylebox_override("pressed", _settings_button_style(Color(0.035, 0.055, 0.08, 1.0), Color(0.32, 0.43, 0.54, 1.0)))
	button.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92, 1.0))
	button.add_theme_font_size_override("font_size", 26)
	return button


func _make_settings_toggle_button() -> CheckButton:
	var button := CheckButton.new()
	button.text = "OFF"
	button.custom_minimum_size = Vector2(132.0, 66.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92, 1.0))
	button.add_theme_font_size_override("font_size", 24)
	return button


func _settings_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _settings_panel_style() -> StyleBoxFlat:
	return _settings_button_style(Color(0.035, 0.05, 0.065, 0.99), Color(0.82, 0.62, 0.22, 1.0))


func _emit_speed_selected(speed: String) -> void:
	var callback := _callback(CALLBACK_SPEED_SELECTED)
	if callback.is_valid():
		callback.call(speed)


func _emit_quality_selected(quality: String) -> void:
	var callback := _callback(CALLBACK_QUALITY_SELECTED)
	if callback.is_valid():
		callback.call(quality)


func _emit_reduced_motion_toggled() -> void:
	var callback := _callback(CALLBACK_REDUCED_MOTION_TOGGLED)
	if callback.is_valid():
		callback.call()


func _emit_game_juice_toggled() -> void:
	var callback := _callback(CALLBACK_GAME_JUICE_TOGGLED)
	if callback.is_valid():
		callback.call()


func _emit_game_juice_flag_toggled(flag_key: String) -> void:
	var callback := _callback(CALLBACK_GAME_JUICE_FLAG_TOGGLED)
	if callback.is_valid():
		callback.call(flag_key)


func _emit(name: String) -> void:
	var callback := _callback(name)
	if callback.is_valid():
		callback.call()


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()


func _settings_dictionary(settings: Variant) -> Dictionary:
	if settings is Dictionary:
		return (settings as Dictionary).duplicate()
	return {
		"vfx_speed": String(settings),
		"combat_vfx_quality": "low",
		"reduced_motion": false,
		"game_juice": false,
		"game_juice_flags": GAME_JUICE_FLAGS_SCRIPT.default_flags(),
	}


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
