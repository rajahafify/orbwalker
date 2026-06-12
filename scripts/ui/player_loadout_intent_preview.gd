extends RefCounted
class_name PlayerLoadoutIntentPreview

const INTENT_PREVIEW_MIN_SEGMENT_WIDTH := 6.0
const INTENT_PREVIEW_PULSE_SECONDS := 0.52
const ARMOR_PREVIEW_PULSE_SECONDS := 0.84

const CALLBACK_INTENT_PREVIEW_HOVERED := "intent_preview_hovered"
const CALLBACK_INTENT_BLOCK_PREVIEW_HOVERED := "intent_block_preview_hovered"
const CALLBACK_INTENT_PREVIEW_HOVER_ENDED := "intent_preview_hover_ended"

var _hud_nodes_provider: Callable
var _player_data_provider: Callable
var _callbacks: Dictionary = {}
var _intent_damage_preview: Dictionary = {}
var _player_armor_overshield_rect: ColorRect
var _intent_hp_danger_button: Button
var _intent_hp_danger_empty: ColorRect
var _intent_hp_danger_fill: ColorRect
var _intent_armor_risk_rect: ColorRect
var _intent_hp_danger_pulse_tween: Tween
var _intent_armor_risk_tween: Tween


func bind(dependencies: Dictionary, callbacks: Dictionary = {}) -> void:
	_hud_nodes_provider = dependencies.get("hud_nodes_provider", Callable())
	_player_data_provider = dependencies.get("player_data_provider", Callable())
	_callbacks = callbacks.duplicate()


func cleanup() -> void:
	_stop_intent_hp_danger_pulse()
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_tween = null
	if _intent_hp_danger_button != null and is_instance_valid(_intent_hp_danger_button):
		_intent_hp_danger_button.visible = false
	if _intent_hp_danger_empty != null and is_instance_valid(_intent_hp_danger_empty):
		_intent_hp_danger_empty.visible = false
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.visible = false
	if _intent_armor_risk_rect != null and is_instance_valid(_intent_armor_risk_rect):
		_intent_armor_risk_rect.visible = false
		_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		_intent_armor_risk_rect.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_intent_damage_preview.clear()


func _sync_intent_damage_preview(preview: Dictionary) -> void:
	_intent_damage_preview = preview.duplicate(true)
	_ensure_intent_damage_preview_nodes()
	_layout_player_armor_overshield(_current_visible_armor())
	_layout_intent_damage_preview()


func _current_visible_armor() -> int:
	var player_data := _player_data()
	var display_values: Dictionary = player_data.get("display_values", {})
	if display_values.has("current_armor"):
		return maxi(0, int(display_values.get("current_armor", 0)))
	var player_state = player_data.get("player_state", null)
	if player_state != null:
		return maxi(0, int(player_state.armor))
	return 0


func _ensure_intent_damage_preview_nodes() -> void:
	var hp_bar := _hp_bar()
	if hp_bar != null:
		if _player_armor_overshield_rect == null or not is_instance_valid(_player_armor_overshield_rect):
			_player_armor_overshield_rect = ColorRect.new()
			_player_armor_overshield_rect.name = "PlayerArmorOvershieldFill"
			_player_armor_overshield_rect.color = Color(0.86, 0.90, 0.94, 0.46)
			_player_armor_overshield_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_player_armor_overshield_rect.visible = false
		_reparent(_player_armor_overshield_rect, hp_bar)
		if _intent_hp_danger_button == null or not is_instance_valid(_intent_hp_danger_button):
			_intent_hp_danger_button = Button.new()
			_intent_hp_danger_button.name = "HpDangerPreviewButton"
			_intent_hp_danger_button.text = ""
			_intent_hp_danger_button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
			_intent_hp_danger_button.visible = false
			_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_intent_hp_danger_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND as Control.CursorShape
			var clear_style := StyleBoxEmpty.new()
			_intent_hp_danger_button.add_theme_stylebox_override("normal", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("hover", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("pressed", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("focus", clear_style)
			_intent_hp_danger_button.mouse_entered.connect(_on_intent_damage_preview_hovered)
			_intent_hp_danger_button.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		_reparent(_intent_hp_danger_button, hp_bar)
		if _intent_hp_danger_empty == null or not is_instance_valid(_intent_hp_danger_empty):
			_intent_hp_danger_empty = ColorRect.new()
			_intent_hp_danger_empty.name = "HpDangerPreviewEmpty"
			_intent_hp_danger_empty.color = Color(0.04, 0.07, 0.10, 1.0)
			_intent_hp_danger_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_intent_hp_danger_empty.visible = false
		_reparent(_intent_hp_danger_empty, _intent_hp_danger_button)
		if _intent_hp_danger_fill == null or not is_instance_valid(_intent_hp_danger_fill):
			_intent_hp_danger_fill = ColorRect.new()
			_intent_hp_danger_fill.name = "HpDangerPreviewFill"
			_intent_hp_danger_fill.color = Color(1.0, 0.02, 0.02, 1.0)
			_intent_hp_danger_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_intent_hp_danger_fill.visible = false
		_reparent(_intent_hp_danger_fill, _intent_hp_danger_button)

	if hp_bar != null:
		if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
			_intent_armor_risk_rect = ColorRect.new()
			_intent_armor_risk_rect.name = "PlayerBlockIntentPreviewFill"
			_intent_armor_risk_rect.color = Color(0.86, 0.90, 0.94, 0.68)
			_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_intent_armor_risk_rect.visible = false
			_intent_armor_risk_rect.mouse_entered.connect(_on_intent_block_preview_hovered)
			_intent_armor_risk_rect.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		_reparent(_intent_armor_risk_rect, hp_bar)


func _layout_player_armor_overshield(armor: int) -> void:
	if _player_armor_overshield_rect == null or not is_instance_valid(_player_armor_overshield_rect):
		return
	var hp_bar := _hp_bar()
	if hp_bar == null:
		return
	_player_armor_overshield_rect.visible = false
	if armor <= 0:
		return
	var bar_width := maxf(0.0, hp_bar.size.x)
	var bar_height := maxf(0.0, hp_bar.size.y)
	var max_hp := maxf(1.0, hp_bar.max_value)
	if bar_width <= 0.0 or bar_height <= 0.0:
		return
	var overshield_width := bar_width * clampf(float(armor) / max_hp, 0.0, 1.0)
	if overshield_width <= 0.0:
		return
	_player_armor_overshield_rect.position = Vector2.ZERO
	_player_armor_overshield_rect.size = Vector2(overshield_width, bar_height)
	_player_armor_overshield_rect.visible = true


func _layout_intent_damage_preview() -> void:
	if _intent_hp_danger_button != null and is_instance_valid(_intent_hp_danger_button):
		_intent_hp_danger_button.visible = false
		_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.visible = false
	if _intent_hp_danger_empty != null and is_instance_valid(_intent_hp_danger_empty):
		_intent_hp_danger_empty.visible = false
	_stop_intent_hp_danger_pulse()
	_set_armor_risk_highlight(false)
	if _intent_damage_preview.is_empty():
		return
	var hp_loss := maxi(0, int(_intent_damage_preview.get("hp_loss", 0)))
	var blocked := maxi(0, int(_intent_damage_preview.get("blocked", 0)))
	var fully_blocked := bool(_intent_damage_preview.get("fully_blocked", false))
	if blocked > 0:
		_layout_player_block_intent_preview(blocked)
	if hp_loss > 0:
		var hp_bar := _hp_bar()
		if hp_bar == null or _intent_hp_danger_button == null or _intent_hp_danger_empty == null or _intent_hp_danger_fill == null:
			return
		var bar_width := maxf(0.0, hp_bar.size.x)
		var bar_height := maxf(0.0, hp_bar.size.y)
		if bar_width <= 0.0 or bar_height <= 0.0:
			return
		var max_hp := maxf(1.0, hp_bar.max_value)
		var current_hp := float(maxi(0, int(_intent_damage_preview.get("current_hp", int(round(hp_bar.value))))))
		var fill_width := bar_width * clampf(current_hp / max_hp, 0.0, 1.0)
		var segment_width := bar_width * clampf(float(hp_loss) / max_hp, 0.0, 1.0)
		segment_width = clampf(segment_width, 0.0, fill_width)
		if segment_width > 0.0:
			segment_width = maxf(segment_width, INTENT_PREVIEW_MIN_SEGMENT_WIDTH)
			segment_width = minf(segment_width, fill_width)
		if segment_width <= 0.0:
			return
		var segment_x := maxf(0.0, fill_width - segment_width)
		_intent_hp_danger_button.position = Vector2(segment_x, 0.0)
		_intent_hp_danger_button.size = Vector2(segment_width, bar_height)
		_intent_hp_danger_button.visible = true
		_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
		_intent_hp_danger_empty.visible = true
		_intent_hp_danger_empty.position = Vector2.ZERO
		_intent_hp_danger_empty.size = _intent_hp_danger_button.size
		_intent_hp_danger_fill.visible = true
		_intent_hp_danger_fill.position = Vector2.ZERO
		_intent_hp_danger_fill.size = _intent_hp_danger_button.size
		_start_intent_hp_danger_pulse()
		return
	if fully_blocked:
		return


func _layout_player_block_intent_preview(blocked: int) -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	var hp_bar := _hp_bar()
	if hp_bar == null:
		return
	var bar_width := maxf(0.0, hp_bar.size.x)
	var max_hp := maxf(1.0, hp_bar.max_value)
	if bar_width <= 0.0 or blocked <= 0:
		return
	var preview_width := bar_width * clampf(float(blocked) / max_hp, 0.0, 1.0)
	if preview_width <= 0.0:
		return
	_intent_armor_risk_rect.visible = true
	_intent_armor_risk_rect.position = Vector2.ZERO
	_intent_armor_risk_rect.size = Vector2(preview_width, hp_bar.size.y)
	_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_start_player_block_intent_preview_pulse()


func _start_intent_hp_danger_pulse() -> void:
	if _intent_hp_danger_fill == null or not is_instance_valid(_intent_hp_danger_fill):
		return
	_stop_intent_hp_danger_pulse()
	_intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_intent_hp_danger_pulse_tween = _intent_hp_danger_fill.create_tween()
	_intent_hp_danger_pulse_tween.set_loops()
	_intent_hp_danger_pulse_tween.tween_property(_intent_hp_danger_fill, "modulate:a", 0.0, INTENT_PREVIEW_PULSE_SECONDS)
	_intent_hp_danger_pulse_tween.tween_property(_intent_hp_danger_fill, "modulate:a", 1.0, INTENT_PREVIEW_PULSE_SECONDS)


func _stop_intent_hp_danger_pulse() -> void:
	if _intent_hp_danger_pulse_tween != null and is_instance_valid(_intent_hp_danger_pulse_tween):
		_intent_hp_danger_pulse_tween.kill()
	_intent_hp_danger_pulse_tween = null
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _set_armor_risk_highlight(enabled: bool) -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	_intent_armor_risk_rect.visible = enabled
	_intent_armor_risk_rect.mouse_filter = (Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE) as Control.MouseFilter
	if enabled:
		_start_player_block_intent_preview_pulse()
		return
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_tween = null


func _start_player_block_intent_preview_pulse() -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_rect.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_intent_armor_risk_tween = _intent_armor_risk_rect.create_tween()
	_intent_armor_risk_tween.set_loops()
	_intent_armor_risk_tween.tween_property(_intent_armor_risk_rect, "modulate:a", 0.22, ARMOR_PREVIEW_PULSE_SECONDS)
	_intent_armor_risk_tween.tween_property(_intent_armor_risk_rect, "modulate:a", 0.68, ARMOR_PREVIEW_PULSE_SECONDS)


func _on_intent_damage_preview_hovered() -> void:
	if _intent_damage_preview.is_empty():
		return
	_call(CALLBACK_INTENT_PREVIEW_HOVERED, [_intent_damage_preview.duplicate(true)])


func _on_intent_block_preview_hovered() -> void:
	if _intent_damage_preview.is_empty():
		return
	_call(CALLBACK_INTENT_BLOCK_PREVIEW_HOVERED, [_intent_damage_preview.duplicate(true)])


func _on_intent_damage_preview_hover_ended() -> void:
	_call(CALLBACK_INTENT_PREVIEW_HOVER_ENDED)


func _hud_nodes() -> Dictionary:
	if not _hud_nodes_provider.is_valid():
		return {}
	var value: Variant = _hud_nodes_provider.call()
	return Dictionary(value) if value is Dictionary else {}


func _player_data() -> Dictionary:
	if not _player_data_provider.is_valid():
		return {}
	var value: Variant = _player_data_provider.call()
	return Dictionary(value) if value is Dictionary else {}


func _hp_bar() -> ProgressBar:
	return _hud_nodes().get("hp_bar") as ProgressBar


func _reparent(child: Node, parent: Node) -> void:
	if child.get_parent() == parent:
		return
	var existing_parent := child.get_parent()
	if existing_parent != null:
		existing_parent.remove_child(child)
	parent.add_child(child)


func _call(callback_name: String, args: Array = []) -> void:
	var callback: Variant = _callbacks.get(callback_name, Callable())
	if not (callback is Callable):
		return
	if not callback.is_valid():
		return
	callback.callv(args)
