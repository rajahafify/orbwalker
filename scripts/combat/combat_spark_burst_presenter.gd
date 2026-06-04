extends RefCounted
class_name CombatSparkBurstPresenter

const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const SPARK_Z_INDEX := 144

var _vfx_layer: Control
var _timer_owner: Node
var _reduced_motion := false
var _game_juice_enabled := false
var _game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	set_reduced_motion_enabled(bool(dependencies.get("reduced_motion", _reduced_motion)))
	set_game_juice_enabled(bool(dependencies.get("game_juice", _game_juice_enabled)))
	if dependencies.has("game_juice_flags"):
		set_game_juice_flags(Dictionary(dependencies.get("game_juice_flags", _game_juice_flags)))


func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion = enabled


func set_game_juice_enabled(enabled: bool) -> void:
	_game_juice_enabled = enabled


func set_game_juice_flags(flags: Dictionary) -> void:
	_game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)


func spawn_visible_spark_burst(global_center: Vector2, draw_size: Vector2, color: Color, lifetime: float) -> void:
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS) or _reduced_motion:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var particle_count := clampi(int(round((draw_size.x + draw_size.y) / 21.0)), 12, 28)
	var base_size := clampf(maxf(draw_size.x, draw_size.y) * 0.14, 12.0, 30.0)
	var travel_radius := clampf(maxf(draw_size.x, draw_size.y) * 0.68, 48.0, 150.0)
	var center_local := _global_to_vfx_local(global_center)
	var duration := maxf(0.18, lifetime * 1.15)
	var tint := color.lerp(Color.WHITE, 0.35)
	tint.a = maxf(tint.a, 0.94)
	for i in range(particle_count):
		var angle := TAU * float(i) / float(particle_count)
		var direction := Vector2(cos(angle), sin(angle))
		var particle := ColorRect.new()
		particle.name = "JuiceSpark"
		particle.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		particle.color = tint
		particle.size = Vector2(base_size, base_size)
		particle.pivot_offset = particle.size * 0.5
		particle.position = center_local - particle.size * 0.5
		particle.rotation = angle
		particle.z_index = SPARK_Z_INDEX
		_vfx_layer.add_child(particle)
		_tween_particle_cleanup(particle, particle.position + direction * travel_radius, duration)


func _juice_enabled(flag_key: String) -> bool:
	return _game_juice_enabled and bool(_game_juice_flags.get(flag_key, true))


func _tween_particle_cleanup(particle: ColorRect, target_position: Vector2, duration: float) -> void:
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(particle, "position", target_position, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(particle, "scale", Vector2(0.22, 0.22), duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.tween_property(particle, "modulate:a", 0.0, duration * 0.72).set_delay(duration * 0.20)
	tween.finished.connect(func() -> void:
		if is_instance_valid(particle):
			particle.queue_free()
	)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
