extends RefCounted
class_name PlayerLoadoutIntentPreview

const INTENT_PREVIEW_MIN_SEGMENT_WIDTH := 6.0
const INTENT_PREVIEW_PULSE_SECONDS := 0.52
const ARMOR_PREVIEW_PULSE_SECONDS := 0.84

var _hud: Variant


func bind(hud: Variant) -> void:
	_hud = hud


func _sync_intent_damage_preview(preview: Dictionary) -> void:
	_hud._intent_damage_preview = preview.duplicate(true)
	_ensure_intent_damage_preview_nodes()
	_layout_player_armor_overshield(_current_visible_armor())
	_layout_intent_damage_preview()


func _current_visible_armor() -> int:
	var display_values: Dictionary = _hud._player_data.get("display_values", {})
	if display_values.has("current_armor"):
		return maxi(0, int(display_values.get("current_armor", 0)))
	var player_state = _hud._player_data.get("player_state", null)
	if player_state != null:
		return maxi(0, int(player_state.armor))
	return 0


func _ensure_intent_damage_preview_nodes() -> void:
	var hp_bar := _hud._hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar != null:
		if _hud._player_armor_overshield_rect == null or not is_instance_valid(_hud._player_armor_overshield_rect):
			_hud._player_armor_overshield_rect = ColorRect.new()
			_hud._player_armor_overshield_rect.name = "PlayerArmorOvershieldFill"
			_hud._player_armor_overshield_rect.color = Color(0.86, 0.90, 0.94, 0.46)
			_hud._player_armor_overshield_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_hud._player_armor_overshield_rect.visible = false
		if _hud._player_armor_overshield_rect.get_parent() != hp_bar:
			var existing_overshield_parent: Node = _hud._player_armor_overshield_rect.get_parent()
			if existing_overshield_parent != null:
				existing_overshield_parent.remove_child(_hud._player_armor_overshield_rect)
			hp_bar.add_child(_hud._player_armor_overshield_rect)
		if _hud._intent_hp_danger_button == null or not is_instance_valid(_hud._intent_hp_danger_button):
			_hud._intent_hp_danger_button = Button.new()
			_hud._intent_hp_danger_button.name = "HpDangerPreviewButton"
			_hud._intent_hp_danger_button.text = ""
			_hud._intent_hp_danger_button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
			_hud._intent_hp_danger_button.visible = false
			_hud._intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_hud._intent_hp_danger_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND as Control.CursorShape
			var clear_style := StyleBoxEmpty.new()
			_hud._intent_hp_danger_button.add_theme_stylebox_override("normal", clear_style)
			_hud._intent_hp_danger_button.add_theme_stylebox_override("hover", clear_style)
			_hud._intent_hp_danger_button.add_theme_stylebox_override("pressed", clear_style)
			_hud._intent_hp_danger_button.add_theme_stylebox_override("focus", clear_style)
			_hud._intent_hp_danger_button.mouse_entered.connect(_on_intent_damage_preview_hovered)
			_hud._intent_hp_danger_button.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		if _hud._intent_hp_danger_button.get_parent() != hp_bar:
			var existing_parent: Node = _hud._intent_hp_danger_button.get_parent()
			if existing_parent != null:
				existing_parent.remove_child(_hud._intent_hp_danger_button)
			hp_bar.add_child(_hud._intent_hp_danger_button)
		if _hud._intent_hp_danger_empty == null or not is_instance_valid(_hud._intent_hp_danger_empty):
			_hud._intent_hp_danger_empty = ColorRect.new()
			_hud._intent_hp_danger_empty.name = "HpDangerPreviewEmpty"
			_hud._intent_hp_danger_empty.color = Color(0.04, 0.07, 0.10, 1.0)
			_hud._intent_hp_danger_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_hud._intent_hp_danger_empty.visible = false
		if _hud._intent_hp_danger_empty.get_parent() != _hud._intent_hp_danger_button:
			var existing_empty_parent: Node = _hud._intent_hp_danger_empty.get_parent()
			if existing_empty_parent != null:
				existing_empty_parent.remove_child(_hud._intent_hp_danger_empty)
			_hud._intent_hp_danger_button.add_child(_hud._intent_hp_danger_empty)
		if _hud._intent_hp_danger_fill == null or not is_instance_valid(_hud._intent_hp_danger_fill):
			_hud._intent_hp_danger_fill = ColorRect.new()
			_hud._intent_hp_danger_fill.name = "HpDangerPreviewFill"
			_hud._intent_hp_danger_fill.color = Color(1.0, 0.02, 0.02, 1.0)
			_hud._intent_hp_danger_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_hud._intent_hp_danger_fill.visible = false
		if _hud._intent_hp_danger_fill.get_parent() != _hud._intent_hp_danger_button:
			var existing_fill_parent: Node = _hud._intent_hp_danger_fill.get_parent()
			if existing_fill_parent != null:
				existing_fill_parent.remove_child(_hud._intent_hp_danger_fill)
			_hud._intent_hp_danger_button.add_child(_hud._intent_hp_danger_fill)

	if hp_bar != null:
		if _hud._intent_armor_risk_rect == null or not is_instance_valid(_hud._intent_armor_risk_rect):
			_hud._intent_armor_risk_rect = ColorRect.new()
			_hud._intent_armor_risk_rect.name = "PlayerBlockIntentPreviewFill"
			_hud._intent_armor_risk_rect.color = Color(0.86, 0.90, 0.94, 0.68)
			_hud._intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			_hud._intent_armor_risk_rect.visible = false
			_hud._intent_armor_risk_rect.mouse_entered.connect(_on_intent_block_preview_hovered)
			_hud._intent_armor_risk_rect.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		if _hud._intent_armor_risk_rect.get_parent() != hp_bar:
			var existing_armor_parent: Node = _hud._intent_armor_risk_rect.get_parent()
			if existing_armor_parent != null:
				existing_armor_parent.remove_child(_hud._intent_armor_risk_rect)
			hp_bar.add_child(_hud._intent_armor_risk_rect)


func _layout_player_armor_overshield(armor: int) -> void:
	if _hud._player_armor_overshield_rect == null or not is_instance_valid(_hud._player_armor_overshield_rect):
		return
	var hp_bar := _hud._hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar == null:
		return
	_hud._player_armor_overshield_rect.visible = false
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
	_hud._player_armor_overshield_rect.position = Vector2.ZERO
	_hud._player_armor_overshield_rect.size = Vector2(overshield_width, bar_height)
	_hud._player_armor_overshield_rect.visible = true


func _layout_intent_damage_preview() -> void:
	if _hud._intent_hp_danger_button != null and is_instance_valid(_hud._intent_hp_danger_button):
		_hud._intent_hp_danger_button.visible = false
		_hud._intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	if _hud._intent_hp_danger_fill != null and is_instance_valid(_hud._intent_hp_danger_fill):
		_hud._intent_hp_danger_fill.visible = false
	if _hud._intent_hp_danger_empty != null and is_instance_valid(_hud._intent_hp_danger_empty):
		_hud._intent_hp_danger_empty.visible = false
	_stop_intent_hp_danger_pulse()
	_set_armor_risk_highlight(false)
	if _hud._intent_damage_preview.is_empty():
		return
	var hp_loss := maxi(0, int(_hud._intent_damage_preview.get("hp_loss", 0)))
	var blocked := maxi(0, int(_hud._intent_damage_preview.get("blocked", 0)))
	var fully_blocked := bool(_hud._intent_damage_preview.get("fully_blocked", false))
	if blocked > 0:
		_layout_player_block_intent_preview(blocked)
	if hp_loss > 0:
		var hp_bar := _hud._hud_nodes.get("hp_bar") as ProgressBar
		if hp_bar == null or _hud._intent_hp_danger_button == null or _hud._intent_hp_danger_empty == null or _hud._intent_hp_danger_fill == null:
			return
		var bar_width := maxf(0.0, hp_bar.size.x)
		var bar_height := maxf(0.0, hp_bar.size.y)
		if bar_width <= 0.0 or bar_height <= 0.0:
			return
		var max_hp := maxf(1.0, hp_bar.max_value)
		var current_hp := float(maxi(0, int(_hud._intent_damage_preview.get("current_hp", int(round(hp_bar.value))))))
		var fill_width := bar_width * clampf(current_hp / max_hp, 0.0, 1.0)
		var segment_width := bar_width * clampf(float(hp_loss) / max_hp, 0.0, 1.0)
		segment_width = clampf(segment_width, 0.0, fill_width)
		if segment_width > 0.0:
			segment_width = maxf(segment_width, INTENT_PREVIEW_MIN_SEGMENT_WIDTH)
			segment_width = minf(segment_width, fill_width)
		if segment_width <= 0.0:
			return
		var segment_x := maxf(0.0, fill_width - segment_width)
		_hud._intent_hp_danger_button.position = Vector2(segment_x, 0.0)
		_hud._intent_hp_danger_button.size = Vector2(segment_width, bar_height)
		_hud._intent_hp_danger_button.visible = true
		_hud._intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
		_hud._intent_hp_danger_empty.visible = true
		_hud._intent_hp_danger_empty.position = Vector2.ZERO
		_hud._intent_hp_danger_empty.size = _hud._intent_hp_danger_button.size
		_hud._intent_hp_danger_fill.visible = true
		_hud._intent_hp_danger_fill.position = Vector2.ZERO
		_hud._intent_hp_danger_fill.size = _hud._intent_hp_danger_button.size
		_start_intent_hp_danger_pulse()
		return
	if fully_blocked:
		return


func _layout_player_block_intent_preview(blocked: int) -> void:
	if _hud._intent_armor_risk_rect == null or not is_instance_valid(_hud._intent_armor_risk_rect):
		return
	var hp_bar := _hud._hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar == null:
		return
	var bar_width := maxf(0.0, hp_bar.size.x)
	var max_hp := maxf(1.0, hp_bar.max_value)
	if bar_width <= 0.0 or blocked <= 0:
		return
	var preview_width := bar_width * clampf(float(blocked) / max_hp, 0.0, 1.0)
	if preview_width <= 0.0:
		return
	_hud._intent_armor_risk_rect.visible = true
	_hud._intent_armor_risk_rect.position = Vector2.ZERO
	_hud._intent_armor_risk_rect.size = Vector2(preview_width, hp_bar.size.y)
	_hud._intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_start_player_block_intent_preview_pulse()


func _start_intent_hp_danger_pulse() -> void:
	if _hud._intent_hp_danger_fill == null or not is_instance_valid(_hud._intent_hp_danger_fill):
		return
	_stop_intent_hp_danger_pulse()
	_hud._intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_hud._intent_hp_danger_pulse_tween = _hud._intent_hp_danger_fill.create_tween()
	_hud._intent_hp_danger_pulse_tween.set_loops()
	_hud._intent_hp_danger_pulse_tween.tween_property(_hud._intent_hp_danger_fill, "modulate:a", 0.0, INTENT_PREVIEW_PULSE_SECONDS)
	_hud._intent_hp_danger_pulse_tween.tween_property(_hud._intent_hp_danger_fill, "modulate:a", 1.0, INTENT_PREVIEW_PULSE_SECONDS)


func _stop_intent_hp_danger_pulse() -> void:
	if _hud._intent_hp_danger_pulse_tween != null and is_instance_valid(_hud._intent_hp_danger_pulse_tween):
		_hud._intent_hp_danger_pulse_tween.kill()
	_hud._intent_hp_danger_pulse_tween = null
	if _hud._intent_hp_danger_fill != null and is_instance_valid(_hud._intent_hp_danger_fill):
		_hud._intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _set_armor_risk_highlight(enabled: bool) -> void:
	if _hud._intent_armor_risk_rect == null or not is_instance_valid(_hud._intent_armor_risk_rect):
		return
	_hud._intent_armor_risk_rect.visible = enabled
	_hud._intent_armor_risk_rect.mouse_filter = (Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE) as Control.MouseFilter
	if enabled:
		_start_player_block_intent_preview_pulse()
		return
	if _hud._intent_armor_risk_tween != null and is_instance_valid(_hud._intent_armor_risk_tween):
		_hud._intent_armor_risk_tween.kill()
	_hud._intent_armor_risk_tween = null


func _start_player_block_intent_preview_pulse() -> void:
	if _hud._intent_armor_risk_rect == null or not is_instance_valid(_hud._intent_armor_risk_rect):
		return
	if _hud._intent_armor_risk_tween != null and is_instance_valid(_hud._intent_armor_risk_tween):
		_hud._intent_armor_risk_tween.kill()
	_hud._intent_armor_risk_rect.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_hud._intent_armor_risk_tween = _hud._intent_armor_risk_rect.create_tween()
	_hud._intent_armor_risk_tween.set_loops()
	_hud._intent_armor_risk_tween.tween_property(_hud._intent_armor_risk_rect, "modulate:a", 0.22, ARMOR_PREVIEW_PULSE_SECONDS)
	_hud._intent_armor_risk_tween.tween_property(_hud._intent_armor_risk_rect, "modulate:a", 0.68, ARMOR_PREVIEW_PULSE_SECONDS)


func _on_intent_damage_preview_hovered() -> void:
	if _hud._intent_damage_preview.is_empty():
		return
	_hud.intent_preview_hovered.emit(_hud._intent_damage_preview.duplicate(true))


func _on_intent_block_preview_hovered() -> void:
	if _hud._intent_damage_preview.is_empty():
		return
	_hud.intent_block_preview_hovered.emit(_hud._intent_damage_preview.duplicate(true))


func _on_intent_damage_preview_hover_ended() -> void:
	_hud.intent_preview_hover_ended.emit()
