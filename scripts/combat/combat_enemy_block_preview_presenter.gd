extends RefCounted
class_name CombatEnemyBlockPreviewPresenter

const CALLBACK_HOVERED := "hovered"
const CALLBACK_HOVER_ENDED := "hover_ended"
const FILL_COLOR := Color(0.86, 0.90, 0.94, 0.68)
const FILL_MODULATE := Color(1.0, 1.0, 1.0, 0.68)

var _enemy_hp_row: Control = null
var _enemy_hp_bar: ProgressBar = null
var _preview_button: Control = null
var _preview_fill: ColorRect = null
var _pulse_tween: Tween = null
var _preview: Dictionary = {}
var _callbacks: Dictionary = {}


func bind(enemy_hp_row: Control, enemy_hp_bar: ProgressBar, callbacks: Dictionary = {}) -> void:
	_enemy_hp_row = enemy_hp_row
	_enemy_hp_bar = enemy_hp_bar
	_callbacks = callbacks.duplicate()


func sync(preview: Dictionary) -> void:
	_preview = preview.duplicate(true)
	layout()


func layout() -> void:
	ensure_nodes()
	_hide_preview()
	_stop_pulse()
	if _preview.is_empty():
		return
	if _enemy_hp_bar == null or _preview_button == null or _preview_fill == null:
		return
	var block := maxi(0, int(_preview.get("block", 0)))
	var max_hp := maxi(1, int(_preview.get("max_hp", int(_enemy_hp_bar.max_value))))
	if block <= 0:
		return
	var bar_width := maxf(0.0, _enemy_hp_bar.size.x)
	if bar_width <= 0.0:
		return
	var preview_width := bar_width * clampf(float(block) / float(max_hp), 0.0, 1.0)
	if preview_width <= 0.0:
		return
	_preview_button.position = _enemy_hp_bar.position
	_preview_button.size = Vector2(preview_width, _enemy_hp_bar.size.y)
	_preview_button.visible = true
	_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP as Control.MouseFilter
	_preview_fill.position = Vector2.ZERO
	_preview_fill.size = _preview_button.size
	_preview_fill.visible = true
	_start_pulse()


func ensure_nodes() -> void:
	if _enemy_hp_row == null:
		return
	if _preview_button == null or not is_instance_valid(_preview_button):
		_preview_button = Control.new()
		_preview_button.name = "EnemyBlockIntentPreviewButton"
		_preview_button.visible = false
		_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		_preview_button.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND as Control.CursorShape
		_preview_button.mouse_entered.connect(_on_preview_hovered)
		_preview_button.mouse_exited.connect(_on_preview_hover_ended)
	if _preview_button.get_parent() != _enemy_hp_row:
		var existing_parent := _preview_button.get_parent()
		if existing_parent != null:
			existing_parent.remove_child(_preview_button)
		_enemy_hp_row.add_child(_preview_button)
	if _preview_fill == null or not is_instance_valid(_preview_fill):
		_preview_fill = ColorRect.new()
		_preview_fill.name = "EnemyBlockIntentPreviewFill"
		_preview_fill.color = FILL_COLOR
		_preview_fill.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		_preview_fill.visible = false
	if _preview_fill.get_parent() != _preview_button:
		var existing_fill_parent := _preview_fill.get_parent()
		if existing_fill_parent != null:
			existing_fill_parent.remove_child(_preview_fill)
		_preview_button.add_child(_preview_fill)


func button() -> Control:
	return _preview_button


func fill() -> ColorRect:
	return _preview_fill


func preview() -> Dictionary:
	return _preview.duplicate(true)


func _hide_preview() -> void:
	if _preview_button != null and is_instance_valid(_preview_button):
		_preview_button.visible = false
		_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	if _preview_fill != null and is_instance_valid(_preview_fill):
		_preview_fill.visible = false


func _start_pulse() -> void:
	if _preview_fill == null or not is_instance_valid(_preview_fill):
		return
	_stop_pulse()
	_preview_fill.modulate = FILL_MODULATE
	_pulse_tween = null


func _stop_pulse() -> void:
	if _pulse_tween != null and is_instance_valid(_pulse_tween):
		_pulse_tween.kill()
	_pulse_tween = null
	if _preview_fill != null and is_instance_valid(_preview_fill):
		_preview_fill.modulate = FILL_MODULATE


func _on_preview_hovered() -> void:
	var callback := _callback(CALLBACK_HOVERED)
	if callback.is_valid():
		callback.call(_preview.duplicate(true))


func _on_preview_hover_ended() -> void:
	var callback := _callback(CALLBACK_HOVER_ENDED)
	if callback.is_valid():
		callback.call()


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
