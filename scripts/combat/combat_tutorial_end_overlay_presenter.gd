extends RefCounted
class_name CombatTutorialEndOverlayPresenter

const CALLBACK_CONTINUE := "continue"
const CALLBACK_MAIN_MENU := "main_menu"
const DEFAULT_ROOT_SIZE := Vector2(1080.0, 1920.0)
const DEFAULT_BOARD_PANEL_RECT := Rect2(Vector2(16.0, 660.0), Vector2(1048.0, 756.0))

var _parent: Control = null
var _equipment_icons: Control = null
var _elemental_mastery_panel: Control = null
var _callbacks: Dictionary = {}

var _overlay: Control = null
var _scrim: ColorRect = null
var _equipment_focus: Panel = null
var _mastery_focus: Panel = null
var _attack_focus: Panel = null
var _modal: Panel = null
var _title_label: Label = null
var _body_label: Label = null
var _continue_button: Button = null
var _main_menu_button: Button = null
var _step := "end"
var _focus_tween: Tween = null
var _animated_focus: Panel = null


func bind(parent: Control, nodes: Dictionary = {}, callbacks: Dictionary = {}) -> void:
	_parent = parent
	_equipment_icons = nodes.get("equipment_icons") as Control
	_elemental_mastery_panel = nodes.get("elemental_mastery_panel") as Control
	_callbacks = callbacks.duplicate()


func show(step := "end", config: Dictionary = {}) -> void:
	_step = String(step)
	ensure_overlay()
	if _overlay == null:
		return
	_apply_step_content()
	_overlay.visible = true
	layout(config)


func hide() -> void:
	if _overlay == null:
		return
	_overlay.visible = false
	_stop_focus_animation()


func is_visible() -> bool:
	return _overlay != null and _overlay.visible


func ensure_overlay() -> void:
	if _overlay != null and is_instance_valid(_overlay):
		return
	if _parent == null:
		return
	_overlay = Control.new()
	_overlay.name = "TutorialEndOverlay"
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.z_index = 190
	_parent.add_child(_overlay)

	_scrim = ColorRect.new()
	_scrim.name = "TutorialEndScrim"
	_scrim.color = Color(0.0, 0.0, 0.0, 0.48)
	_scrim.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_overlay.add_child(_scrim)

	_mastery_focus = _make_focus("MasteryFocus")
	_attack_focus = _make_focus("AttackFocus")
	_equipment_focus = _make_focus("EquipmentFocus")

	_modal = Panel.new()
	_modal.name = "TutorialEndModal"
	_modal.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_modal.add_theme_stylebox_override("panel", _modal_style())
	_overlay.add_child(_modal)

	_title_label = _make_label("TutorialEndTitle", "End of tutorial", 42, Color(1.0, 0.82, 0.28, 1.0))
	_modal.add_child(_title_label)
	_body_label = _make_label(
		"TutorialEndBody",
		"Iron Shortsword adds +2 Attack.\nFire, Ice, and Earth matches now hit harder.",
		29,
		Color(0.96, 0.90, 0.76, 1.0)
	)
	_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	_modal.add_child(_body_label)

	_continue_button = _make_button("TutorialEndContinueButton", "CONTINUE")
	_main_menu_button = _make_button("TutorialEndMainMenuButton", "MAIN MENU")
	_modal.add_child(_continue_button)
	_modal.add_child(_main_menu_button)
	_continue_button.pressed.connect(func() -> void: _emit(CALLBACK_CONTINUE))
	_main_menu_button.pressed.connect(func() -> void: _emit(CALLBACK_MAIN_MENU))


func layout(config: Dictionary = {}) -> void:
	if _overlay == null or not is_instance_valid(_overlay):
		return
	var root_size := _parent.size if _parent != null else DEFAULT_ROOT_SIZE
	var board_panel_rect: Rect2 = config.get("board_panel_rect", DEFAULT_BOARD_PANEL_RECT)
	_overlay.position = Vector2.ZERO
	_overlay.size = root_size
	if _scrim != null:
		_scrim.position = Vector2.ZERO
		_scrim.size = root_size
	if not _overlay.visible:
		return
	_hide_focus_nodes()

	var active_focus: Panel = null
	if _step == "shortsword":
		_apply_focus_rect(_equipment_focus, _first_equipment_rect().grow(10.0))
		active_focus = _equipment_focus
	elif _step == "mastery":
		_apply_focus_rect(_mastery_focus, _local_rect_for_control(_elemental_mastery_panel).grow(10.0))
		active_focus = _mastery_focus
	_set_focus_animation(active_focus)

	var modal_height := 438.0 if _step == "end" else 360.0
	var modal_size := Vector2(minf(820.0, root_size.x - 96.0), modal_height)
	var modal_x := (root_size.x - modal_size.x) * 0.5
	var modal_y := clampf(board_panel_rect.position.y + 64.0, 170.0, maxf(170.0, root_size.y - modal_size.y - 56.0))
	_modal.position = Vector2(modal_x, modal_y)
	_modal.size = modal_size
	_title_label.position = Vector2(32.0, 26.0)
	_title_label.size = Vector2(modal_size.x - 64.0, 64.0)
	_body_label.position = Vector2(52.0, 104.0)
	_body_label.size = Vector2(modal_size.x - 104.0, 96.0 if _step == "end" else 108.0)
	var button_size := Vector2(modal_size.x - 160.0, 76.0)
	_continue_button.position = Vector2(80.0, modal_size.y - (192.0 if _step == "end" else 112.0))
	_continue_button.size = button_size
	if _main_menu_button != null:
		_main_menu_button.visible = _step == "end"
		_main_menu_button.position = Vector2(80.0, modal_size.y - 96.0)
		_main_menu_button.size = button_size


func overlay() -> Control:
	return _overlay


func modal() -> Panel:
	return _modal


func title_label() -> Label:
	return _title_label


func body_label() -> Label:
	return _body_label


func continue_button() -> Button:
	return _continue_button


func main_menu_button() -> Button:
	return _main_menu_button


func equipment_focus() -> Panel:
	return _equipment_focus


func mastery_focus() -> Panel:
	return _mastery_focus


func attack_focus() -> Panel:
	return _attack_focus


func _apply_step_content() -> void:
	if _title_label == null or _body_label == null or _continue_button == null:
		return
	if _step == "shortsword":
		_title_label.text = "Iron Shortsword"
		_body_label.text = "Iron Shortsword adds +2 Attack.\nMore Attack makes damage matches hit harder."
		_continue_button.text = "NEXT"
	elif _step == "mastery":
		_title_label.text = "Mastery"
		_body_label.text = "Mastery is each orb type's base power.\nFire, Ice, and Earth use Attack for damage."
		_continue_button.text = "NEXT"
	else:
		_title_label.text = "End of tutorial"
		_body_label.text = "You know the basics.\nContinue the run or return to the main menu."
		_continue_button.text = "CONTINUE"
	if _main_menu_button != null:
		_main_menu_button.visible = _step == "end"


func _make_focus(node_name: String) -> Panel:
	var focus := Panel.new()
	focus.name = node_name
	focus.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	focus.add_theme_stylebox_override("panel", _focus_style())
	_overlay.add_child(focus)
	return focus


func _make_label(node_name: String, text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.clip_text = true
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	label.add_theme_constant_override("outline_size", 3)
	return label


func _make_button(node_name: String, text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	button.add_theme_font_size_override("font_size", 32)
	button.add_theme_color_override("font_color", Color(1.0, 0.93, 0.76, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.98, 0.86, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.86, 0.78, 0.62, 1.0))
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.90))
	button.add_theme_constant_override("outline_size", 3)
	var normal := _button_style(Color(0.13, 0.18, 0.13, 0.98), Color(0.42, 0.82, 0.32, 1.0))
	var hover := _button_style(Color(0.18, 0.25, 0.16, 1.0), Color(0.62, 0.96, 0.44, 1.0))
	var pressed := _button_style(Color(0.09, 0.13, 0.08, 1.0), Color(0.33, 0.66, 0.24, 1.0))
	if node_name.ends_with("MainMenuButton"):
		normal = _button_style(Color(0.16, 0.10, 0.08, 0.98), Color(0.86, 0.46, 0.28, 1.0))
		hover = _button_style(Color(0.24, 0.13, 0.10, 1.0), Color(1.0, 0.62, 0.38, 1.0))
		pressed = _button_style(Color(0.12, 0.07, 0.06, 1.0), Color(0.70, 0.34, 0.22, 1.0))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	return button


func _hide_focus_nodes() -> void:
	if _mastery_focus != null:
		_mastery_focus.visible = false
	if _attack_focus != null:
		_attack_focus.visible = false
	if _equipment_focus != null:
		_equipment_focus.visible = false


func _apply_focus_rect(focus: Panel, rect: Rect2) -> void:
	if focus == null or not is_instance_valid(focus):
		return
	focus.position = rect.position
	focus.size = rect.size
	focus.pivot_offset = rect.size * 0.5
	focus.visible = rect.size.x > 2.0 and rect.size.y > 2.0


func _set_focus_animation(focus: Panel) -> void:
	if focus == null or not is_instance_valid(focus) or not focus.visible:
		_stop_focus_animation()
		return
	focus.pivot_offset = focus.size * 0.5
	if _animated_focus == focus and _focus_tween != null and is_instance_valid(_focus_tween):
		return
	_stop_focus_animation()
	_animated_focus = focus
	focus.scale = Vector2.ONE
	focus.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if not focus.is_inside_tree():
		return
	_focus_tween = focus.create_tween()
	_focus_tween.set_loops()
	_focus_tween.tween_property(focus, "scale", Vector2(1.12, 1.12), 0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_focus_tween.parallel().tween_property(focus, "modulate", Color(1.0, 0.93, 0.44, 1.0), 0.46).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_focus_tween.tween_property(focus, "scale", Vector2.ONE, 0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_focus_tween.parallel().tween_property(focus, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.58).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _stop_focus_animation() -> void:
	if _focus_tween != null and is_instance_valid(_focus_tween):
		_focus_tween.kill()
	_focus_tween = null
	if _animated_focus != null and is_instance_valid(_animated_focus):
		_animated_focus.scale = Vector2.ONE
		_animated_focus.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_animated_focus = null


func _first_equipment_rect() -> Rect2:
	if _equipment_icons != null and is_instance_valid(_equipment_icons) and _equipment_icons.get_child_count() > 0:
		for child in _equipment_icons.get_children():
			if child is Control and (child as Control).visible:
				return _local_rect_for_control(child as Control)
	return _local_rect_for_control(_equipment_icons)


func _local_rect_for_control(control: Control) -> Rect2:
	if control == null or not is_instance_valid(control) or _overlay == null:
		return Rect2(Vector2(-9999.0, -9999.0), Vector2.ONE)
	var inverse := _overlay.get_global_transform().affine_inverse()
	var rect := control.get_global_rect()
	return Rect2(inverse * rect.position, rect.size)


func _focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.84, 0.12, 0.08)
	style.border_color = Color(1.0, 0.86, 0.18, 1.0)
	style.set_border_width_all(5)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(1.0, 0.72, 0.14, 0.45)
	style.shadow_size = 14
	return style


func _modal_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.050, 0.065, 0.98)
	style.border_color = Color(1.0, 0.72, 0.16, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.60)
	style.shadow_size = 16
	return style


func _button_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _emit(name: String) -> void:
	var callback := _callback(name)
	if callback.is_valid():
		callback.call()


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
