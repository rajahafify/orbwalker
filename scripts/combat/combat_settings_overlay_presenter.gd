extends RefCounted
class_name CombatSettingsOverlayPresenter

const DEFAULT_DESIGN_SIZE := Vector2(1080.0, 1920.0)
const SPEED_OPTIONS: Array[String] = ["slow", "normal", "fast", "instant"]

const CALLBACK_CONTINUE := "continue"
const CALLBACK_NEW_RUN := "new_run"
const CALLBACK_MAIN_MENU := "main_menu"
const CALLBACK_SPEED_SELECTED := "speed_selected"

var _parent: Control = null
var _overlay: Control = null
var _panel: Panel = null
var _speed_buttons: Array[Button] = []
var _continue_button: Button = null
var _new_run_button: Button = null
var _main_menu_button: Button = null
var _callbacks: Dictionary = {}
var _design_size := DEFAULT_DESIGN_SIZE


func bind(parent: Control, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_parent = parent
	_callbacks = callbacks.duplicate()
	_design_size = config.get("design_size", DEFAULT_DESIGN_SIZE)


func show(speed: String) -> void:
	ensure_overlay()
	if _overlay == null:
		return
	_overlay.visible = true
	update_speed_buttons(speed)


func hide() -> void:
	if _overlay != null:
		_overlay.visible = false


func is_visible() -> bool:
	return _overlay != null and _overlay.visible


func ensure_overlay() -> void:
	if _overlay != null or _parent == null:
		return
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
	_panel.position = Vector2(190.0, 320.0)
	_panel.size = Vector2(700.0, 880.0)
	_panel.add_theme_stylebox_override("panel", _settings_panel_style())
	_overlay.add_child(_panel)

	var box := VBoxContainer.new()
	box.name = "SettingsBox"
	box.position = Vector2(46.0, 38.0)
	box.size = Vector2(608.0, 804.0)
	box.add_theme_constant_override("separation", 14)
	_panel.add_child(box)

	box.add_child(_settings_label("Settings", 44))
	box.add_child(_settings_label("VFX Speed", 28))
	for speed in SPEED_OPTIONS:
		var button := _make_settings_menu_button(speed.to_upper())
		button.pressed.connect(func() -> void: _emit_speed_selected(speed))
		_speed_buttons.append(button)
		box.add_child(button)
	box.add_child(_settings_group_gap())
	_continue_button = _make_settings_menu_button("CONTINUE")
	_new_run_button = _make_settings_menu_button("NEW RUN")
	_main_menu_button = _make_settings_menu_button("MAIN MENU")
	_continue_button.pressed.connect(func() -> void: _emit(CALLBACK_CONTINUE))
	_new_run_button.pressed.connect(func() -> void: _emit(CALLBACK_NEW_RUN))
	_main_menu_button.pressed.connect(func() -> void: _emit(CALLBACK_MAIN_MENU))
	box.add_child(_continue_button)
	box.add_child(_new_run_button)
	box.add_child(_main_menu_button)


func update_speed_buttons(speed: String) -> void:
	var normalized := speed.to_lower()
	for button in _speed_buttons:
		var button_speed := button.text.replace(" *", "").to_lower()
		var selected := button_speed == normalized
		button.text = ("%s *" % button_speed.to_upper()) if selected else button_speed.to_upper()


func speed_buttons() -> Array[Button]:
	return _speed_buttons.duplicate()


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
	spacer.custom_minimum_size = Vector2(0.0, 20.0)
	return spacer


func _make_settings_menu_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 70.0)
	button.add_theme_stylebox_override("normal", _settings_button_style(Color(0.055, 0.085, 0.12, 0.98), Color(0.38, 0.50, 0.62, 1.0)))
	button.add_theme_stylebox_override("hover", _settings_button_style(Color(0.075, 0.115, 0.16, 1.0), Color(0.55, 0.70, 0.84, 1.0)))
	button.add_theme_stylebox_override("pressed", _settings_button_style(Color(0.035, 0.055, 0.08, 1.0), Color(0.32, 0.43, 0.54, 1.0)))
	button.add_theme_color_override("font_color", Color(0.95, 0.92, 0.84, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.92, 1.0))
	button.add_theme_font_size_override("font_size", 30)
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


func _emit(name: String) -> void:
	var callback := _callback(name)
	if callback.is_valid():
		callback.call()


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
