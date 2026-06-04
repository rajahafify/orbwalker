extends RefCounted
class_name CombatEnemyAttackVfxPresenter

const ENEMY_ATTACK_CUE_SIZE := Vector2(88, 88)
const ENEMY_ATTACK_BOLT_SIZE := Vector2(44, 44)
const ENEMY_ATTACK_BEAM_THICKNESS := 10.0

var _vfx_layer: Control
var _timer_owner: Node
var _runtime_sprite_presenter: Variant


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")


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
	_spawn_armor_snap_grid(target_global, lifetime)


func _spawn_armor_snap_grid(target_global: Vector2, lifetime: float) -> void:
	if target_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var center_local := _global_to_vfx_local(target_global)
	var shell_size := 76.0
	var cell_size := 23.0
	var gap := cell_size * 0.88
	var start := Vector2(-gap, -gap)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.22 if row % 2 == 1 else 0.0), float(row) * gap)
			var delay := lifetime * (0.03 + float(absi(row - 1) + absi(column - 1)) * 0.028 + float(index % 2) * 0.010)
			if _spawn_runtime_sprite_local(
				"EnemyAttackArmorHexCell",
				"hex_cell",
				center_local + offset,
				Vector2(cell_size, cell_size * 1.12),
				Color(0.70, 0.92, 1.0, 0.64),
				lifetime * 0.74,
				Vector2(1.08, 1.08),
				delay,
				Vector2.ZERO,
				0.0,
				119,
				PI / 6.0
			) == null:
				_spawn_hex_polygon(center_local + offset, Vector2(cell_size, cell_size * 1.12), Color(0.70, 0.92, 1.0, 0.48), 119, PI / 6.0, lifetime * 0.74, delay)
	_spawn_block_snap_bars(center_local, shell_size, lifetime)


func _spawn_block_snap_bars(center_local: Vector2, shell_size: float, lifetime: float) -> void:
	var bar_length := shell_size * 0.74
	var bar_thickness := 5.0
	var half := shell_size * 0.46
	var specs := [
		{"offset": Vector2(0.0, -half), "rotation": 0.0, "move": Vector2(0.0, 10.0)},
		{"offset": Vector2(0.0, half), "rotation": 0.0, "move": Vector2(0.0, -10.0)},
		{"offset": Vector2(-half, 0.0), "rotation": PI * 0.5, "move": Vector2(10.0, 0.0)},
		{"offset": Vector2(half, 0.0), "rotation": PI * 0.5, "move": Vector2(-10.0, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		if _spawn_runtime_sprite_local(
			"EnemyAttackArmorSnapBar",
			"ray",
			center_local + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			Color(0.88, 0.98, 1.0, 0.84),
			lifetime * 0.44,
			Vector2(0.72, 0.48),
			lifetime * (0.04 + float(i) * 0.018),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.0,
			120,
			float(spec.get("rotation", 0.0))
		) == null:
			_spawn_snap_bar(center_local + Vector2(spec.get("offset", Vector2.ZERO)), Vector2(bar_length, bar_thickness), Color(0.88, 0.98, 1.0, 0.64), 120, float(spec.get("rotation", 0.0)), lifetime * 0.44)


func _spawn_hex_polygon(center_local: Vector2, draw_size: Vector2, color: Color, z_index: int, rotation: float, lifetime: float, delay: float) -> void:
	var hex := Polygon2D.new()
	hex.name = "EnemyAttackArmorHexCell"
	hex.set_meta("effect_name", "EnemyAttackArmorHexCell")
	hex.polygon = _hex_points(draw_size)
	hex.position = center_local
	hex.rotation = rotation
	hex.color = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	hex.z_index = z_index
	_vfx_layer.add_child(hex)
	_tween_canvas_fade_cleanup(hex, lifetime, Vector2(1.08, 1.08), delay, color.a)


func _spawn_snap_bar(center_local: Vector2, draw_size: Vector2, color: Color, z_index: int, rotation: float, lifetime: float) -> void:
	var bar := ColorRect.new()
	bar.name = "EnemyAttackArmorSnapBar"
	bar.set_meta("effect_name", "EnemyAttackArmorSnapBar")
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	bar.color = color
	bar.size = draw_size
	bar.pivot_offset = draw_size * 0.5
	bar.position = center_local - draw_size * 0.5
	bar.rotation = rotation
	bar.z_index = z_index
	_vfx_layer.add_child(bar)
	_tween_fade_cleanup(bar, lifetime)


func _hex_points(draw_size: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var radius_x := draw_size.x * 0.5
	var radius_y := draw_size.y * 0.5
	for i in range(6):
		var angle := PI / 6.0 + TAU * float(i) / 6.0
		points.append(Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	return points


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = 0, rotation: float = 0.0) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation)


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


func _tween_canvas_fade_cleanup(canvas_item: CanvasItem, lifetime: float, target_scale: Vector2 = Vector2.ONE, delay: float = 0.0, target_alpha: float = 1.0) -> void:
	if canvas_item == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		canvas_item.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(canvas_item, "modulate:a", target_alpha, 0.05).set_delay(delay)
	tween.tween_property(canvas_item, "scale", target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(canvas_item, "modulate:a", 0.0, duration * 0.66).set_delay(delay + duration * 0.34)
	tween.finished.connect(func() -> void:
		if is_instance_valid(canvas_item):
			canvas_item.queue_free()
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
