extends RefCounted
class_name CombatEnemyAttackVfxPresenter

const ENEMY_ATTACK_CUE_SIZE := Vector2(88, 88)
const ENEMY_ATTACK_BOLT_SIZE := Vector2(44, 44)
const ENEMY_ATTACK_BEAM_THICKNESS := 10.0

var _vfx_layer: Control
var _timer_owner: Node


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node


func spawn_cue(source_global: Vector2, lifetime: float = 0.26) -> void:
	if source_global == Vector2.ZERO:
		return
	var cue := _spawn_pulse(source_global, ENEMY_ATTACK_CUE_SIZE, Color(1.0, 0.45, 0.38, 0.30), Color(1.0, 0.58, 0.42, 0.95), 7, 114)
	_tween_pulse_cleanup(cue, lifetime, Vector2(1.18, 1.18))


func spawn_travel(source_global: Vector2, target_global: Vector2, lifetime: float = 0.28) -> void:
	if source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var source_local := _global_to_vfx_local(source_global)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var beam := ColorRect.new()
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	beam.color = Color(1.0, 0.56, 0.46, 0.62)
	beam.size = Vector2(distance, ENEMY_ATTACK_BEAM_THICKNESS)
	beam.pivot_offset = Vector2(0.0, ENEMY_ATTACK_BEAM_THICKNESS * 0.5)
	beam.position = source_local - Vector2(0.0, ENEMY_ATTACK_BEAM_THICKNESS * 0.5)
	beam.rotation = delta.angle()
	beam.z_index = 112
	_vfx_layer.add_child(beam)
	_tween_fade_cleanup(beam, lifetime)

	var bolt := _spawn_pulse(source_global, ENEMY_ATTACK_BOLT_SIZE, Color(1.0, 0.52, 0.42, 0.88), Color(1.0, 0.78, 0.72, 1.0), 4, 116)
	if bolt == null:
		return
	var bolt_end := target_local - bolt.size * 0.5
	_tween_move_fade_cleanup(bolt, bolt_end, lifetime)


func spawn_block_impact(target_global: Vector2, lifetime: float = 0.32) -> void:
	var pulse := _spawn_pulse(target_global, Vector2(62, 62), Color(0.30, 0.48, 0.72, 0.18), Color(0.78, 0.88, 1.0, 0.78), 4, 118)
	_tween_pulse_cleanup(pulse, lifetime, Vector2(1.16, 1.16))


func spawn_hit_impact(target_global: Vector2, lifetime: float = 0.32) -> void:
	var pulse := _spawn_pulse(target_global, Vector2(70, 70), Color(1.0, 0.38, 0.32, 0.28), Color(1.0, 0.58, 0.48, 0.86), 5, 118)
	_tween_pulse_cleanup(pulse, lifetime, Vector2(1.18, 1.18))


func _spawn_pulse(global_center: Vector2, pulse_size: Vector2, fill: Color, border: Color, border_width: int, z_index: int) -> Panel:
	if global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var pulse := Panel.new()
	pulse.name = "EnemyAttackPulse"
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	pulse.size = pulse_size
	pulse.pivot_offset = pulse.size * 0.5
	pulse.position = _global_to_vfx_local(global_center) - pulse.size * 0.5
	pulse.z_index = z_index
	pulse.modulate = Color(1.0, 1.0, 1.0, 0.94)
	pulse.add_theme_stylebox_override("panel", _pulse_stylebox(fill, border, border_width))
	_vfx_layer.add_child(pulse)
	return pulse


func _pulse_stylebox(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(maxi(1, border_width))
	style.set_corner_radius_all(999)
	return style


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _tween_fade_cleanup(control: Control, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func _tween_pulse_cleanup(control: Control, lifetime: float, target_scale: Vector2 = Vector2(1.12, 1.12)) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", target_scale, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(control, "modulate:a", 0.0, duration).set_delay(duration * 0.22)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func _tween_move_fade_cleanup(control: Control, target_position: Vector2, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position", target_position, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.tween_property(control, "modulate:a", 0.0, duration).set_delay(duration * 0.42)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)
