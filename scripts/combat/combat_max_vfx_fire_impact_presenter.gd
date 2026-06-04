extends RefCounted
class_name CombatMaxVfxFireImpactPresenter

var _atmospheric_flipbook_spawner: Callable
var _status_flipbook_spawner: Callable
var _elemental_effect_spawner: Callable
var _pack_layer_spawner: Callable
var _spark_spray_spawner: Callable
var _light_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())
	_status_flipbook_spawner = dependencies.get("status_flipbook_spawner", Callable())
	_elemental_effect_spawner = dependencies.get("elemental_effect_spawner", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_spark_spray_spawner = dependencies.get("spark_spray_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())


func spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	var impact_extent := maxf(impact_size.x, impact_size.y)
	_spawn_elemental_effect("area", center, "fire", impact_size * 1.04, duration * 1.16, intensity + 1, 0.02, Vector2.ZERO, 0.0, 2.8, 0.84)
	_spawn_atmospheric_flipbook("embers", center + Vector2(0.0, -max_size * 0.06), impact_size * Vector2(1.28, 0.82), duration * 0.96, Color(1.0, 0.34, 0.08, 0.42), 0.04, Vector2(0.0, -max_size * 0.12), 1.02, 2.9, 0.0, 1)
	_spawn_status_flipbook("rage", center + Vector2(0.0, -max_size * 0.08), impact_size * 0.50, duration * 0.72, Color(1.0, 0.24, 0.04, 0.52), 0.08, Vector2.ZERO, 1.10, 3.2, 0.0, 1)
	_spawn_spark_spray(center, impact_extent * 0.72, duration * 0.80, intensity + 1, 0.04, 2)
	_spawn_light(center, Color(1.0, 0.42, 0.08, 1.0), 3.8 + float(intensity) * 0.26, impact_extent * 1.16, duration * 0.74)


func spawn_meteor_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool = false) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var vertical_target := impact_size.x > impact_size.y * 1.35
	var base_center := center + Vector2(0.0, impact_size.y * (0.22 if vertical_target else 0.08))
	_spawn_atmospheric_flipbook("fog", base_center + Vector2(0.0, impact_size.y * 0.10), impact_size * Vector2(0.78, 0.58), duration * 1.06, Color(1.0, 0.08, 0.02, 0.12 if vertical_target else 0.18), delay + duration * 0.02, Vector2(0.0, -impact_size.y * 0.08), 1.02, 2.2, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", base_center + Vector2(0.0, -impact_size.y * 0.08), impact_size * Vector2(0.92, 0.72), duration * 0.84, Color(1.0, 0.20, 0.03, 0.22 if vertical_target else 0.32), delay, Vector2(0.0, impact_size.y * 0.04), 0.94, 2.6, 0.0, 1)
	_spawn_status_flipbook("rage", base_center + Vector2(0.0, -impact_size.y * 0.12), impact_size * Vector2(0.62, 0.78), duration * 0.82, Color(1.0, 0.20, 0.03, 0.46 if vertical_target else 0.54), delay + duration * 0.04, Vector2.ZERO, 1.12, 3.2, 0.0, 1)
	if fragmented_wide or vertical_target:
		spawn_fragmented_impact_cluster(base_center, impact_size, duration, intensity, delay + duration * 0.06, 0.78)
	else:
		_spawn_elemental_effect("area", base_center, "fire", impact_size * Vector2(0.82, 0.86), duration * 1.08, intensity, delay + duration * 0.06, Vector2.ZERO, 0.0, 3.0, 0.78)
		_spawn_pack_layer("big_impact_01", base_center, "fire", impact_size * Vector2(0.76, 0.80), duration * 0.78, intensity, delay + duration * 0.08, 0.0, 3.8, 0.66)
	_spawn_spark_spray(base_center, extent * 1.18, duration * 0.92, intensity, delay + duration * 0.10, 3)
	_spawn_light(base_center, Color(1.0, 0.18, 0.02, 1.0), 5.2 + float(intensity) * 0.42, extent * 1.80, duration * 0.90)


func spawn_fragmented_impact_cluster(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float = 1.0, rotation: float = 0.0) -> void:
	var width := maxf(120.0, draw_size.x)
	var height := maxf(110.0, draw_size.y)
	var burst_base := clampf(height * 0.44, 92.0, 190.0)
	var offsets := [
		Vector2(-width * 0.34, -height * 0.12),
		Vector2(-width * 0.13, height * 0.02),
		Vector2(width * 0.12, -height * 0.08),
		Vector2(width * 0.32, height * 0.04),
		Vector2(0.0, height * 0.15),
	]
	for i in range(offsets.size()):
		var progress := float(i) / float(maxi(1, offsets.size() - 1))
		var burst_center: Vector2 = center + offsets[i]
		var burst_size := Vector2(
			burst_base * (1.08 + sin(float(i) * 1.7) * 0.12),
			burst_base * (0.78 + cos(float(i) * 1.3) * 0.10)
		)
		var burst_delay := delay + duration * (0.02 + progress * 0.10)
		var burst_rotation := rotation + (-0.24 + progress * 0.48)
		_spawn_pack_layer("impact_01", burst_center, "fire", burst_size, duration * 0.46, intensity, burst_delay, burst_rotation, 3.7, 0.46 * alpha_scale)
		_spawn_pack_layer("hit_01", burst_center + Vector2(0.0, -burst_base * 0.10), "fire", burst_size * 0.58, duration * 0.36, intensity + 1, burst_delay + duration * 0.04, burst_rotation * 0.7, 3.9, 0.42 * alpha_scale)
		_spawn_status_flipbook("burn", burst_center, burst_size * Vector2(0.78, 0.58), duration * 0.68, Color(1.0, 0.44, 0.08, 0.32 * alpha_scale), burst_delay, Vector2(0.0, -height * 0.04), 0.98, 3.2, burst_rotation, 1)
	_spawn_status_flipbook("rage", center + Vector2(0.0, -height * 0.04), Vector2(width * 0.58, height * 0.36), duration * 0.76, Color(1.0, 0.16, 0.02, 0.26 * alpha_scale), delay + duration * 0.05, Vector2.ZERO, 1.04, 3.1, rotation, 1)
	_spawn_atmospheric_flipbook("embers", center + Vector2(0.0, -height * 0.10), Vector2(width * 0.92, height * 0.46), duration * 0.86, Color(1.0, 0.30, 0.05, 0.24 * alpha_scale), delay + duration * 0.02, Vector2(0.0, -height * 0.08), 0.98, 2.8, rotation, 1)


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
