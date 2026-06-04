extends RefCounted
class_name CombatMaxVfxMasteryRecipePresenter

var _status_available_provider: Callable
var _elemental_available_provider: Callable
var _pack_available_provider: Callable
var _should_use_elemental_provider: Callable
var _kind_for_orb_provider: Callable
var _kind_colors_provider: Callable
var _status_cast_spawner: Callable
var _elemental_cast_spawner: Callable
var _pack_hit_scene_key_provider: Callable
var _pack_impact_scene_key_provider: Callable
var _pack_effect_spawner: Callable
var _light_spawner: Callable
var _camera_kick_spawner: Callable
var _impact_key_provider: Callable
var _projectile_key_provider: Callable
var _trail_key_provider: Callable
var _flipbook_spawner: Callable
var _status_beam_spawner: Callable
var _elemental_beam_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_status_available_provider = dependencies.get("status_available_provider", Callable())
	_elemental_available_provider = dependencies.get("elemental_available_provider", Callable())
	_pack_available_provider = dependencies.get("pack_available_provider", Callable())
	_should_use_elemental_provider = dependencies.get("should_use_elemental_provider", Callable())
	_kind_for_orb_provider = dependencies.get("kind_for_orb_provider", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_status_cast_spawner = dependencies.get("status_cast_spawner", Callable())
	_elemental_cast_spawner = dependencies.get("elemental_cast_spawner", Callable())
	_pack_hit_scene_key_provider = dependencies.get("pack_hit_scene_key_provider", Callable())
	_pack_impact_scene_key_provider = dependencies.get("pack_impact_scene_key_provider", Callable())
	_pack_effect_spawner = dependencies.get("pack_effect_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())
	_impact_key_provider = dependencies.get("impact_key_provider", Callable())
	_projectile_key_provider = dependencies.get("projectile_key_provider", Callable())
	_trail_key_provider = dependencies.get("trail_key_provider", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_status_beam_spawner = dependencies.get("status_beam_spawner", Callable())
	_elemental_beam_spawner = dependencies.get("elemental_beam_spawner", Callable())


func spawn_cast_sequence(orb_id: int, source: Vector2, target: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int) -> bool:
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var kind := _kind_for_orb(orb_id)
	var intensity := clampi(2 + int(floor(float(maxi(0, result_amount)) / 8.0)), 2, 8)
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var spool_size := Vector2(150, 150) * (1.0 + float(intensity) * 0.08)
	if _status_available():
		_spawn_status_cast(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)
		return true
	if _elemental_available() and _should_use_elemental(kind):
		_spawn_elemental_cast(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)
		return true
	if _pack_available():
		_spawn_pack_cast(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)
		return true
	_spawn_fallback_cast(kind, source, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)
	return true


func spawn_beam(orb_id: int, source: Vector2, target: Vector2, lifetime: float) -> bool:
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var kind := _kind_for_orb(orb_id)
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var angle := delta.angle()
	var length := delta.length()
	var beam_intensity := clampi(int(round(length / 110.0)), 2, 8)
	if _status_available():
		_spawn_status_beam(kind, source, delta, lifetime, beam_intensity, angle)
		return true
	if _elemental_available() and _should_use_elemental(kind):
		_spawn_elemental_beam(kind, source, delta, lifetime, beam_intensity, angle)
		return true
	if _pack_available():
		_spawn_pack_effect("hit_01", source, kind, Vector2(116 + beam_intensity * 8, 76 + beam_intensity * 5), lifetime, beam_intensity, 0.0, delta, angle, 1.3, 0.62)
		return true
	_spawn_flipbook("light_rays", source + delta * 0.5, Vector2(length, 44.0), lifetime * 0.82, Color(core.r, core.g, core.b, 0.72), 0.0, Vector2.ZERO, 0.62, 0.5, angle)
	_spawn_flipbook(_projectile_key(kind), source, Vector2(126, 72), lifetime, Color(1, 1, 1, 0.86), 0.0, delta, 0.72, 1.4, angle)
	return true


func _spawn_pack_cast(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
	var travel_duration := maxf(0.18, travel_lifetime)
	var pack_angle := delta.angle()
	var travel_size := Vector2(104 + intensity * 15, 74 + intensity * 9)
	_spawn_light(source, core, 1.8 + float(intensity) * 0.18, spool_size.x * 1.2, spool_lifetime * 1.2)
	_spawn_pack_effect(_pack_hit_scene_key(kind), source, kind, spool_size * 0.92, spool_lifetime * 1.10, intensity, 0.0, Vector2.ZERO, pack_angle, 0.7, 0.78)
	_spawn_pack_effect("hit_01", source, kind, travel_size, travel_duration, intensity, spool_lifetime, delta, pack_angle, 1.3, 0.58)
	_spawn_pack_effect(_pack_impact_scene_key(kind, intensity, false), target, kind, spool_size * (1.08 + float(intensity) * 0.05), travel_duration * 1.2, intensity, spool_lifetime + travel_duration * 0.86, Vector2.ZERO, pack_angle, 1.8, 0.96)
	_spawn_camera_kick(delta.normalized() * (4.0 + float(intensity)), spool_lifetime + travel_duration * 0.85)


func _spawn_fallback_cast(kind: String, source: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
	_spawn_light(source, core, 1.8 + float(intensity) * 0.18, spool_size.x * 1.2, spool_lifetime * 1.2)
	_spawn_flipbook(_impact_key(kind), source, spool_size, spool_lifetime * 1.15, Color(1, 1, 1, 0.88), 0.0, Vector2.ZERO, 0.92, 0.4, 0.22)
	_spawn_flipbook("shockwave_ring", source, spool_size * 0.78, spool_lifetime, Color(accent.r, accent.g, accent.b, 0.72), 0.05, Vector2.ZERO, 1.34, 0.2, 0.0)
	var projectile_key := _projectile_key(kind)
	var projectile_size := Vector2(170 + intensity * 18, 96 + intensity * 8)
	var fallback_angle := delta.angle()
	_spawn_flipbook(projectile_key, source, projectile_size, maxf(0.18, travel_lifetime), Color(1, 1, 1, 0.98), spool_lifetime, delta, 0.84, 1.8, fallback_angle)
	var trail_key := _trail_key(kind)
	var trail_count := 10 + intensity * 4
	for i in range(trail_count):
		var progress := float(i) / float(maxi(1, trail_count - 1))
		var lane := Vector2(-delta.y, delta.x).normalized() * sin(float(i) * 2.1) * (14.0 + float(intensity) * 3.0)
		var start := source + delta * progress * 0.72 + lane
		_spawn_flipbook(trail_key, start, Vector2(72 + intensity * 6, 44 + intensity * 4), travel_lifetime * 0.72, Color(accent.r, accent.g, accent.b, 0.58), spool_lifetime + travel_lifetime * progress * 0.62, delta * (0.30 + progress * 0.24), 0.42, 0.6, fallback_angle + sin(float(i)) * 0.3)
	_spawn_camera_kick(delta.normalized() * (4.0 + float(intensity)), spool_lifetime + travel_lifetime * 0.85)


func _status_available() -> bool:
	return _status_available_provider.is_valid() and bool(_status_available_provider.call())


func _elemental_available() -> bool:
	return _elemental_available_provider.is_valid() and bool(_elemental_available_provider.call())


func _pack_available() -> bool:
	return _pack_available_provider.is_valid() and bool(_pack_available_provider.call())


func _should_use_elemental(kind: String) -> bool:
	return _should_use_elemental_provider.is_valid() and bool(_should_use_elemental_provider.call(kind))


func _kind_for_orb(orb_id: int) -> String:
	if _kind_for_orb_provider.is_valid():
		return str(_kind_for_orb_provider.call(orb_id))
	return "generic"


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _pack_hit_scene_key(kind: String) -> String:
	if _pack_hit_scene_key_provider.is_valid():
		return str(_pack_hit_scene_key_provider.call(kind))
	return "hit_01"


func _pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if _pack_impact_scene_key_provider.is_valid():
		return str(_pack_impact_scene_key_provider.call(kind, intensity, screen_wide))
	return "impact_01"


func _impact_key(kind: String) -> String:
	if _impact_key_provider.is_valid():
		return str(_impact_key_provider.call(kind))
	return "orb_clear"


func _projectile_key(kind: String) -> String:
	if _projectile_key_provider.is_valid():
		return str(_projectile_key_provider.call(kind))
	return "spark_particles"


func _trail_key(kind: String) -> String:
	if _trail_key_provider.is_valid():
		return str(_trail_key_provider.call(kind))
	return "spark_particles"


func _spawn_status_cast(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
	if _status_cast_spawner.is_valid():
		_status_cast_spawner.call(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)


func _spawn_elemental_cast(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
	if _elemental_cast_spawner.is_valid():
		_elemental_cast_spawner.call(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)


func _spawn_status_beam(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	if _status_beam_spawner.is_valid():
		_status_beam_spawner.call(kind, source, delta, lifetime, intensity, angle)


func _spawn_elemental_beam(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	if _elemental_beam_spawner.is_valid():
		_elemental_beam_spawner.call(kind, source, delta, lifetime, intensity, angle)


func _spawn_pack_effect(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
	if _pack_effect_spawner.is_valid():
		_pack_effect_spawner.call(scene_key, center, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(direction, delay)


func _spawn_flipbook(key: String, center: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation)
