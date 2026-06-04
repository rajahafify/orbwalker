extends RefCounted
class_name CombatMaxVfxFireAttackPresenter

var _layer_size_provider: Callable
var _atmospheric_flipbook_spawner: Callable
var _status_flipbook_spawner: Callable
var _elemental_effect_spawner: Callable
var _pack_layer_spawner: Callable
var _spark_spray_spawner: Callable
var _light_spawner: Callable
var _meteor_impact_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())
	_status_flipbook_spawner = dependencies.get("status_flipbook_spawner", Callable())
	_elemental_effect_spawner = dependencies.get("elemental_effect_spawner", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_spark_spray_spawner = dependencies.get("spark_spray_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_meteor_impact_spawner = dependencies.get("meteor_impact_spawner", Callable())


func spawn_fireball_spell_layers(source: Vector2, target: Vector2, delta: Vector2, source_size: Vector2, impact_size: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var normal := Vector2(-delta.y, delta.x).normalized()
	var fireball_size := Vector2(maxf(230.0, source_size.x * 1.36), maxf(150.0, source_size.y * 0.92))
	_spawn_atmospheric_flipbook("embers", source + delta * 0.48, Vector2(delta.length() * 0.72, 126.0 + float(intensity) * 9.0), travel_duration * 0.98, Color(1.0, 0.36, 0.08, 0.46), launch_delay + travel_duration * 0.02, Vector2.ZERO, 0.92, 1.35, angle, 1)
	_spawn_status_flipbook("burn", source, fireball_size, travel_duration * 1.08, Color(1.0, 0.54, 0.12, 0.76), launch_delay, delta, 0.72, 2.9, angle, 1)
	_spawn_status_flipbook("rage", source - normal * 7.0, fireball_size * 0.62, travel_duration * 0.86, Color(1.0, 0.22, 0.04, 0.52), launch_delay + 0.04, delta + normal * 10.0, 0.66, 3.0, angle + 0.08, 1)
	_spawn_elemental_effect("projectile", source, "fire", fireball_size * Vector2(1.12, 0.92), travel_duration * 1.10, intensity + 1, launch_delay, delta, angle - PI, 2.7, 0.88)
	_spawn_pack_layer("hit_01", source + delta * 0.58, "fire", fireball_size * 0.54, travel_duration * 0.40, intensity + 1, launch_delay + travel_duration * 0.44, angle, 3.1, 0.48)
	_spawn_elemental_effect("area", target, "fire", impact_size * 0.98, travel_duration * 1.18, intensity + 1, launch_delay + travel_duration * 0.84, Vector2.ZERO, angle, 3.2, 0.88)
	_spawn_pack_layer("impact_01", target, "fire", impact_size * 0.96, travel_duration * 0.70, intensity + 1, launch_delay + travel_duration * 0.88, angle, 3.4, 0.76)
	_spawn_spark_spray(target, maxf(impact_size.x, impact_size.y) * 0.78, travel_duration * 0.86, intensity + 1, launch_delay + travel_duration * 0.84, 2)
	_spawn_light(target, Color(1.0, 0.44, 0.08, 1.0), 4.0 + float(intensity) * 0.32, maxf(impact_size.x, impact_size.y) * 1.20, travel_duration * 0.78)


func spawn_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var meteor_delay := launch_delay + travel_duration * 0.12
	var descent_time := travel_duration * 1.02
	for i in range(3):
		var offset_x := (float(i) - 1.0) * impact_size.x * 0.24
		var start := Vector2(target.x + offset_x - impact_size.x * 0.22, maxf(0.0, target.y - impact_size.y * (1.35 + float(i) * 0.10)))
		var end := target + Vector2(offset_x * 0.22, impact_size.y * (0.08 + float(i) * 0.02))
		var move := end - start
		var size := Vector2(impact_size.x * (0.32 + float(i) * 0.04), impact_size.y * 0.24)
		var streak_delay := meteor_delay + travel_duration * (0.06 + float(i) * 0.07)
		_spawn_elemental_effect("projectile", start, "fire", size, descent_time * (0.78 + float(i) * 0.08), intensity + 1, streak_delay, move, move.angle() - PI, 2.6, 0.74)
		_spawn_status_flipbook("burn", start, size * Vector2(0.86, 0.62), descent_time * (0.70 + float(i) * 0.08), Color(1.0, 0.36, 0.06, 0.44), streak_delay + 0.02, move, 0.62, 2.8, move.angle(), 1)
	_spawn_meteor_impact_layers(target, impact_size * 1.26, travel_duration * 1.08, intensity + 2, launch_delay + travel_duration * 0.82, true)


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
	if _atmospheric_flipbook_spawner.is_valid():
		_atmospheric_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func _spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
	if _status_flipbook_spawner.is_valid():
		_status_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func _spawn_elemental_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
	if _elemental_effect_spawner.is_valid():
		_elemental_effect_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_pack_layer(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func _spawn_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	if _spark_spray_spawner.is_valid():
		_spark_spray_spawner.call(center, radius, lifetime, intensity, delay, tier)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_meteor_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool) -> void:
	if _meteor_impact_spawner.is_valid():
		_meteor_impact_spawner.call(center, impact_size, duration, intensity, delay, fragmented_wide)
