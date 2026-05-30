extends RefCounted
class_name CombatEnemyIntentBubblePresenter

const CALLBACK_HOVERED := "hovered"
const CALLBACK_HOVER_ENDED := "hover_ended"
const INTENT_BUBBLE_SIZE := Vector2(136.0, 58.0)

var _intent_row: HBoxContainer = null
var _intent_label: Label = null
var _intent_badge: TextureRect = null
var _primary_intent_text_column: Control = null
var _callbacks: Dictionary = {}
var _bubble_tweens: Array[Tween] = []
var _entry_buttons: Array[Button] = []
var _tutorial_focus_kind := ""
var _entries: Array[Dictionary] = []


func bind(nodes: Dictionary, callbacks: Dictionary = {}) -> void:
	_intent_row = nodes.get("intent_row") as HBoxContainer
	_intent_label = nodes.get("intent_label") as Label
	_intent_badge = nodes.get("intent_badge") as TextureRect
	_primary_intent_text_column = nodes.get("primary_intent_text_column") as Control
	_callbacks = callbacks.duplicate()


func sync(preview: Dictionary) -> void:
	_entries.clear()
	_clear_bubbles()
	if preview.has("entries") and preview.get("entries") is Array:
		for raw in Array(preview.get("entries", [])):
			if raw is Dictionary:
				_entries.append((raw as Dictionary).duplicate(true))
	if _intent_row == null:
		return
	var has_entries := not _entries.is_empty()
	if _intent_badge != null:
		_intent_badge.visible = false
	if _intent_label != null:
		_intent_label.visible = false
	if _primary_intent_text_column != null:
		_primary_intent_text_column.visible = false
	_intent_row.visible = has_entries
	if not has_entries:
		return
	var index := 0
	for entry in _entries:
		var button := _make_entry_button(entry, index)
		_intent_row.add_child(button)
		_entry_buttons.append(button)
		index += 1
	_apply_tutorial_focus()


func start_hover_emphasis(kind: String) -> void:
	_kill_tweens()
	_reset_emphasis()
	var targets := _bubble_targets(kind)
	if targets.is_empty():
		return
	var tint := Color(1.0, 0.30, 0.24, 1.0) if kind == "attack" else Color(0.86, 0.92, 1.0, 1.0)
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		target.modulate = tint
		target.scale = Vector2(1.12, 1.12)


func stop_hover_emphasis() -> void:
	_kill_tweens()
	_reset_emphasis()


func set_tutorial_focus(kind: String) -> void:
	_tutorial_focus_kind = kind
	_apply_tutorial_focus()


func clear_tutorial_focus() -> void:
	_tutorial_focus_kind = ""
	stop_hover_emphasis()


func buttons() -> Array[Button]:
	return _entry_buttons.duplicate()


func entries() -> Array[Dictionary]:
	return _entries.duplicate(true)


func _bubble_targets(kind: String) -> Array[Control]:
	var targets: Array[Control] = []
	for button in _entry_buttons:
		if button == null or not is_instance_valid(button):
			continue
		if String(button.get_meta("intent_kind", "")) == kind:
			targets.append(button)
	if targets.is_empty() and _intent_badge != null and _intent_badge.visible:
		targets.append(_intent_badge)
	return targets


func _apply_tutorial_focus() -> void:
	if _tutorial_focus_kind == "":
		return
	_kill_tweens()
	for button in _entry_buttons:
		if button == null or not is_instance_valid(button):
			continue
		if String(button.get_meta("intent_kind", "")) != _tutorial_focus_kind:
			continue
		var focus_style := _focus_stylebox(_tutorial_focus_kind)
		button.add_theme_stylebox_override("normal", focus_style)
		button.add_theme_stylebox_override("hover", focus_style)
		button.add_theme_stylebox_override("pressed", focus_style)
		button.add_theme_color_override("font_color", Color(1.0, 0.92, 0.30, 1.0))
		button.add_theme_font_size_override("font_size", 25)
		button.modulate = Color(1.0, 0.34, 0.28, 1.0) if _tutorial_focus_kind == "attack" else Color(0.90, 0.96, 1.0, 1.0)
		button.scale = Vector2(1.18, 1.18)
		if _tutorial_focus_kind == "attack" and button.is_inside_tree():
			var pulse_tween := button.create_tween()
			pulse_tween.set_loops()
			pulse_tween.tween_property(button, "modulate", Color(1.0, 0.14, 0.10, 1.0), 0.26)
			pulse_tween.parallel().tween_property(button, "scale", Vector2(1.24, 1.24), 0.26)
			pulse_tween.tween_property(button, "modulate", Color(0.48, 0.03, 0.02, 1.0), 0.34)
			pulse_tween.parallel().tween_property(button, "scale", Vector2(1.10, 1.10), 0.34)
			_bubble_tweens.append(pulse_tween)


func _reset_emphasis() -> void:
	if _intent_row != null:
		_intent_row.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _intent_label != null:
		_intent_label.scale = Vector2.ONE
		_intent_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if _intent_badge != null:
		_intent_badge.scale = Vector2.ONE
		_intent_badge.modulate = Color(1.0, 1.0, 1.0, 1.0)
	for button in _entry_buttons:
		if button == null or not is_instance_valid(button):
			continue
		button.scale = Vector2.ONE
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)
		var kind := String(button.get_meta("intent_kind", ""))
		if kind != "" and kind != _tutorial_focus_kind:
			button.add_theme_stylebox_override("normal", _stylebox(kind, false))
			button.add_theme_stylebox_override("hover", _stylebox(kind, true))
			button.add_theme_stylebox_override("pressed", _stylebox(kind, true))
	if _tutorial_focus_kind != "":
		_apply_tutorial_focus()


func _clear_bubbles() -> void:
	_kill_tweens()
	for button in _entry_buttons:
		if button != null and is_instance_valid(button):
			button.queue_free()
	_entry_buttons.clear()


func _kill_tweens() -> void:
	for tween in _bubble_tweens:
		if tween != null and is_instance_valid(tween):
			tween.kill()
	_bubble_tweens.clear()


func _make_entry_button(entry: Dictionary, index: int) -> Button:
	var button := Button.new()
	var kind := String(entry.get("kind", ""))
	var amount := maxi(0, int(entry.get("amount", 0)))
	button.name = "EnemyIntent%s%d" % [kind.capitalize(), index]
	button.text = String(entry.get("label", _entry_label(kind, amount)))
	button.custom_minimum_size = INTENT_BUBBLE_SIZE
	button.size = INTENT_BUBBLE_SIZE
	button.focus_mode = Control.FocusMode.FOCUS_NONE as Control.FocusMode
	button.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND as Control.CursorShape
	button.pivot_offset = INTENT_BUBBLE_SIZE * 0.5
	button.set_meta("intent_kind", kind)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.95))
	button.add_theme_stylebox_override("normal", _stylebox(kind, false))
	button.add_theme_stylebox_override("hover", _stylebox(kind, true))
	button.add_theme_stylebox_override("pressed", _stylebox(kind, true))
	button.mouse_entered.connect(_on_hovered.bind(kind, entry.duplicate(true)))
	button.mouse_exited.connect(_on_hover_ended)
	return button


func _entry_label(kind: String, amount: int) -> String:
	match kind:
		"attack":
			return "Attack %d" % amount
		"block":
			return "Block %d" % amount
		_:
			return "%s %d" % [kind.capitalize(), amount]


func _stylebox(kind: String, hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := Color(0.12, 0.04, 0.04, 0.94) if kind == "attack" else Color(0.10, 0.13, 0.16, 0.90)
	var border := Color(1.0, 0.22, 0.20, 1.0) if kind == "attack" else Color(0.72, 0.82, 0.92, 0.95)
	if hover:
		bg = bg.lightened(0.08)
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _focus_stylebox(kind: String) -> StyleBoxFlat:
	var style := _stylebox(kind, true)
	style.bg_color = Color(0.20, 0.02, 0.02, 0.98) if kind == "attack" else Color(0.10, 0.16, 0.22, 0.98)
	style.border_color = Color(1.0, 0.82, 0.08, 1.0)
	style.set_border_width_all(4)
	style.shadow_color = Color(1.0, 0.55, 0.0, 0.70)
	style.shadow_size = 12
	return style


func _on_hovered(kind: String, entry: Dictionary) -> void:
	var callback := _callback(CALLBACK_HOVERED)
	if callback.is_valid():
		callback.call(kind, entry)


func _on_hover_ended() -> void:
	var callback := _callback(CALLBACK_HOVER_ENDED)
	if callback.is_valid():
		callback.call()


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
