extends RefCounted
class_name CombatMaxVfxFireRecipePresenter

var _tier_provider: Callable
var _layer_size_provider: Callable
var _atmospheric_flipbook_spawner: Callable
var _status_flipbook_spawner: Callable
var _flame_scene_spawner: Callable
var _pack_layer_spawner: Callable
var _burst_particles_spawner: Callable
var _spark_spray_spawner: Callable
var _light_spawner: Callable
var _fireball_impact_spawner: Callable
var _meteor_impact_spawner: Callable
var _fragmented_impact_spawner: Callable
var _aurora_layer_spawner: Callable
var _screen_ember_field_spawner: Callable
var _ember_lane_spawner: Callable
var _status_path_afterimage_spawner: Callable
var _beam_effect_spawner: Callable
var _fireball_spell_spawner: Callable
var _meteor_attack_spawner: Callable
var _camera_kick_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_tier_provider = dependencies.get("tier_provider", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())
	_status_flipbook_spawner = dependencies.get("status_flipbook_spawner", Callable())
	_flame_scene_spawner = dependencies.get("flame_scene_spawner", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_burst_particles_spawner = dependencies.get("burst_particles_spawner", Callable())
	_spark_spray_spawner = dependencies.get("spark_spray_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_fireball_impact_spawner = dependencies.get("fireball_impact_spawner", Callable())
	_meteor_impact_spawner = dependencies.get("meteor_impact_spawner", Callable())
	_fragmented_impact_spawner = dependencies.get("fragmented_impact_spawner", Callable())
	_aurora_layer_spawner = dependencies.get("aurora_layer_spawner", Callable())
	_screen_ember_field_spawner = dependencies.get("screen_ember_field_spawner", Callable())
	_ember_lane_spawner = dependencies.get("ember_lane_spawner", Callable())
	_status_path_afterimage_spawner = dependencies.get("status_path_afterimage_spawner", Callable())
	_beam_effect_spawner = dependencies.get("beam_effect_spawner", Callable())
	_fireball_spell_spawner = dependencies.get("fireball_spell_spawner", Callable())
	_meteor_attack_spawner = dependencies.get("meteor_attack_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())


func spawn_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _fire_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var fire_center := center + Vector2(0.0, draw_size.y * (0.20 if wide_target else 0.0))
	var impact_extent := maxf(124.0, base_size * 0.54) if tier == 1 else maxf(170.0, base_size * (0.70 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var area_cover_size := Vector2(
		maxf(draw_size.x * 1.04, impact_extent * (0.88 if wide_target else 1.0)),
		maxf(draw_size.y * (1.86 if wide_target else 1.10), impact_extent * (0.58 if wide_target else 0.54))
	)
	var aura_size := Vector2(
		maxf(area_cover_size.x, base_size * (1.05 + float(tier) * 0.20)),
		maxf(area_cover_size.y, base_size * (0.54 + float(tier) * 0.06))
	)
	var area_alpha := 0.30 if wide_target else 0.48
	_spawn_atmospheric_flipbook("fog", fire_center, area_cover_size * Vector2(1.06, 1.18), duration * 1.20, Color(1.0, 0.12, 0.03, 0.16 if wide_target else 0.22), 0.0, Vector2(0.0, -max_size * 0.04), 1.03, 0.15, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", fire_center, aura_size, duration * 1.22, Color(1.0, 0.48, 0.18, area_alpha), 0.0, Vector2(0.0, -max_size * 0.08), 1.08, 0.35, 0.0, 1)
	if wide_target:
		var base_center := center + Vector2(0.0, draw_size.y * 0.48)
		_spawn_atmospheric_flipbook("fog", base_center, area_cover_size * Vector2(1.04, 0.82), duration * 1.24, Color(1.0, 0.08, 0.02, 0.18), 0.02, Vector2(0.0, -draw_size.y * 0.20), 1.04, 0.55, 0.0, 1)
		_spawn_atmospheric_flipbook("embers", base_center, area_cover_size * Vector2(1.02, 0.72), duration * 1.12, Color(1.0, 0.26, 0.04, 0.28), 0.05, Vector2(0.0, -draw_size.y * 0.24), 1.02, 0.80, 0.0, 2)
	_spawn_status_flipbook("burn", fire_center, impact_size * 0.62, duration * 0.96, Color(1.0, 0.72, 0.22, 0.72), 0.0, Vector2.ZERO, 1.18, 1.8, 0.04, 1)
	if not wide_target:
		_spawn_flame_scene(fire_center + Vector2(0.0, max_size * 0.05), impact_size * 0.92, duration * 1.00, layer_intensity, 0.02, Vector2(0.0, -max_size * 0.08), 2.0, 0.96)
	var weak_impact_scale := 0.72 if tier == 1 else 1.0
	_spawn_pack_layer("impact_01", fire_center, "fire", impact_size * (0.86 * weak_impact_scale), duration * 0.64, layer_intensity, 0.06, 0.10, 2.6, 0.56 if tier == 1 else 0.72)
	_spawn_pack_layer("hit_01", fire_center + Vector2(max_size * 0.09, -max_size * 0.08), "fire", impact_size * (0.50 * weak_impact_scale), duration * 0.48, layer_intensity, 0.13, -0.28, 2.9, 0.42 if tier == 1 else 0.58)
	_spawn_burst_particles("fire", fire_center, maxf(max_size * 0.78, impact_extent * 0.52) if tier == 1 else maxf(max_size * 1.30, impact_extent * 0.62), duration * 0.88, layer_intensity)
	_spawn_spark_spray(fire_center, maxf(max_size * 0.74, impact_extent * 0.48) if tier == 1 else maxf(max_size * 1.20, impact_extent * 0.58), duration * 0.78, layer_intensity, 0.02, tier)
	_spawn_light(fire_center, Color(1.0, 0.56, 0.14, 1.0), (2.0 + float(layer_intensity) * 0.24) if tier == 1 else (3.0 + float(layer_intensity) * 0.36), impact_extent * (0.86 if tier == 1 else 1.08), duration * 0.72)
	if tier == 1:
		_spawn_fireball_impact_layers(fire_center, impact_size, duration, layer_intensity, max_size)
	if tier >= 2:
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(0.0, -max_size * 0.16), aura_size * Vector2(1.22, 0.82), duration * 1.06, Color(1.0, 0.28, 0.06, 0.36), duration * 0.03, Vector2(0.0, -max_size * 0.10), 1.03, 0.60, 0.04, 1)
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(-max_size * 0.18, -max_size * 0.04), impact_size * Vector2(1.05, 0.60), duration * 0.76, Color(1.0, 0.42, 0.12, 0.30), duration * 0.08, Vector2(max_size * 0.30, -max_size * 0.04), 0.88, 1.2, -0.10, 1)
		_spawn_status_flipbook("rage", fire_center + Vector2(0.0, -max_size * 0.12), impact_size * 0.38, duration * 0.74, Color(1.0, 0.30, 0.08, 0.48), duration * 0.08, Vector2.ZERO, 1.10, 2.4, 0.10, 1)
		_spawn_pack_layer("hit_01", fire_center + Vector2(-max_size * 0.12, max_size * 0.02), "fire", impact_size * 0.62, duration * 0.54, layer_intensity + 1, 0.17, 0.34, 3.0, 0.52)
		_spawn_burst_particles("fire", fire_center, maxf(max_size * 1.75, impact_extent * 0.82), duration * 0.76, layer_intensity + 1)
		_spawn_spark_spray(fire_center, maxf(max_size * 1.60, impact_extent * 0.76), duration * 0.72, layer_intensity + 1, duration * 0.08, tier)
	if tier >= 3:
		var wide_size := Vector2(maxf(area_cover_size.x, base_size * 1.24), maxf(area_cover_size.y * 1.18, base_size * 0.88))
		if not wide_target:
			_spawn_fire_aurora_layer(fire_center, duration * 1.36, intensity, 0.0, 0.50)
			_spawn_fire_screen_ember_field(fire_center + Vector2(0.0, _vfx_layer_size().y * 0.20), duration * 1.18, layer_intensity + 1, 0.0, 0.36)
		_spawn_fire_meteor_impact_layers(fire_center, wide_size, duration, layer_intensity, 0.0, wide_target)
		_spawn_atmospheric_flipbook("embers", fire_center + Vector2(0.0, -max_size * 0.06), wide_size * Vector2(1.06, 0.80), duration * 1.22, Color(1.0, 0.24, 0.04, 0.24 if wide_target else 0.34), 0.02, Vector2(0.0, -max_size * 0.08), 1.04, -0.4, 0.0, 2)
		if not wide_target:
			_spawn_flame_scene(fire_center + Vector2(0.0, max_size * 0.10), wide_size * Vector2(0.82, 0.92), duration * 1.18, layer_intensity + 2, 0.04, Vector2(0.0, -max_size * 0.06), 2.6, 0.92)
			_spawn_pack_layer("big_impact_01", fire_center, "fire", wide_size * Vector2(0.82, 0.96), duration * 0.84, layer_intensity + 2, 0.08, 0.06, 3.3, 0.68)
		else:
			_spawn_fire_fragmented_impact_cluster(fire_center, wide_size * Vector2(0.92, 0.68), duration * 0.78, layer_intensity + 2, duration * 0.08, 0.62)
		_spawn_burst_particles("fire", fire_center, maxf(base_size * 1.12, max_size * 3.0), duration * 0.94, layer_intensity + 2)
		_spawn_spark_spray(fire_center, maxf(base_size * 0.98, max_size * 2.60), duration * 0.92, layer_intensity + 2, duration * 0.04, tier)
		_spawn_light(fire_center, Color(1.0, 0.32, 0.06, 1.0), 4.2 + float(layer_intensity) * 0.42, wide_size.x * 0.62, duration * 0.82)


func spawn_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _fire_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (1.02 + float(tier) * 0.12)
	var impact_extent := maxf(142.0, maxf(source_size.x, source_size.y) * 0.72) if tier == 1 else maxf(190.0, maxf(source_size.x, source_size.y) * (1.10 + float(tier) * 0.16))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.82
	_spawn_light(source, core, 3.8 + float(layer_intensity) * 0.36, source_size.x * 2.05, spool_duration * 1.24)
	_spawn_atmospheric_flipbook("embers", source, source_size * Vector2(2.18, 1.36), spool_duration * 1.44, Color(1.0, 0.34, 0.08, 0.72), 0.0, Vector2(0.0, -22.0), 1.16, 0.66, angle, 2)
	_spawn_atmospheric_flipbook("embers", source + Vector2(0.0, -18.0), source_size * Vector2(1.64, 1.08), spool_duration * 1.12, Color(1.0, 0.18, 0.03, 0.46), spool_duration * 0.08, Vector2(0.0, -34.0), 1.04, 0.92, angle + 0.10, 1)
	_spawn_atmospheric_flipbook("embers", source + Vector2(0.0, -10.0), source_size * Vector2(1.28, 0.82), spool_duration * 0.86, Color(1.0, 0.36, 0.08, 0.32), spool_duration * 0.12, Vector2(0.0, -20.0), 0.88, 1.05, angle, 1)
	_spawn_status_flipbook("burn", source, source_size * 0.88, spool_duration * 1.02, Color(1.0, 0.68, 0.18, 0.90), 0.0, Vector2.ZERO, 1.26, 1.0, angle, 1)
	_spawn_flame_scene(source, source_size * 1.34, spool_duration * 1.18, layer_intensity + 1, 0.02, Vector2(0.0, -22.0), 1.45, 1.0)
	_spawn_pack_layer("hit_01", source, "fire", source_size * 0.86, spool_duration * 0.66, layer_intensity + 1, 0.08, angle, 1.6, 0.70)
	_spawn_spark_spray(source, source_size.x * 1.04, spool_duration * 0.86, layer_intensity + 1, 0.02, tier + 1)
	_spawn_fire_ember_lane(source, delta, launch_delay, travel_duration, layer_intensity, angle, tier)
	_spawn_status_path_afterimage("fire", source, delta, launch_delay, travel_duration, layer_intensity, angle)
	_spawn_beam_effect(source, delta, "fire", travel_duration * 1.06, layer_intensity, launch_delay, 1.08 + float(tier) * 0.12)
	_spawn_status_flipbook("burn", source, Vector2(142 + layer_intensity * 18, 92 + layer_intensity * 9), travel_duration * 1.04, Color(1.0, 0.58, 0.18, 0.50), launch_delay, delta, 0.84, 2.3, angle, 1)
	if tier == 1:
		_spawn_fireball_spell_layers(source, target, delta, source_size, impact_size, launch_delay, travel_duration, layer_intensity, angle)
	if tier < 3:
		_spawn_flame_scene(target, impact_size * (0.58 if tier == 1 else 0.82), travel_duration * 1.18, layer_intensity, impact_delay, Vector2.ZERO, 2.8, 0.62 if tier == 1 else 0.96)
	_spawn_pack_layer("impact_01", target, "fire", impact_size * (0.52 if tier == 1 else 0.72), travel_duration * 0.66, layer_intensity, impact_delay + travel_duration * 0.03, angle, 3.0, 0.44 if tier == 1 else 0.68)
	_spawn_status_flipbook("rage", target + Vector2(0.0, -impact_extent * 0.06), impact_size * (0.24 if tier == 1 else 0.34), travel_duration * 0.90, Color(1.0, 0.30, 0.08, 0.30 if tier == 1 else 0.48), impact_delay + travel_duration * 0.02, Vector2.ZERO, 1.06 if tier == 1 else 1.12, 3.2, angle, 1)
	_spawn_burst_particles("fire", target, impact_extent * (0.42 if tier == 1 else 0.62), travel_duration * 0.82, layer_intensity)
	_spawn_spark_spray(target, impact_extent * (0.46 if tier == 1 else 0.68), travel_duration * 0.78, layer_intensity, impact_delay, tier)
	_spawn_light(target, Color(1.0, 0.46, 0.10, 1.0), (2.2 + float(layer_intensity) * 0.24) if tier == 1 else (3.2 + float(layer_intensity) * 0.34), impact_extent * (0.86 if tier == 1 else 1.12), travel_duration * 0.78)
	if tier >= 2:
		_spawn_fire_screen_ember_field(source + delta * 0.50, travel_duration * 1.22, layer_intensity, launch_delay + travel_duration * 0.03, 0.28)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.50 + normal * 12.0, Vector2(delta.length() * 1.04, 118.0 + float(layer_intensity) * 12.0), travel_duration * 1.18, Color(1.0, 0.30, 0.06, 0.36), launch_delay + travel_duration * 0.04, Vector2.ZERO, 0.98, 1.05, angle + 0.04, 1)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.52 - normal * 12.0, Vector2(delta.length() * 0.88, 88.0 + float(layer_intensity) * 8.0), travel_duration * 0.92, Color(1.0, 0.46, 0.14, 0.30), launch_delay + travel_duration * 0.12, Vector2.ZERO, 0.92, 1.15, angle - 0.05, 1)
		_spawn_beam_effect(source + normal * 8.0, delta - normal * 6.0, "fire", travel_duration * 0.90, layer_intensity + 1, launch_delay + travel_duration * 0.04, 0.82 + float(tier) * 0.08)
		_spawn_pack_layer("hit_01", target + normal * 12.0, "fire", impact_size * 0.58, travel_duration * 0.48, layer_intensity + 1, impact_delay + travel_duration * 0.08, angle + 0.18, 3.1, 0.56)
		_spawn_burst_particles("fire", target, impact_extent * 0.82, travel_duration * 0.76, layer_intensity + 1)
		_spawn_spark_spray(target, impact_extent * 0.86, travel_duration * 0.72, layer_intensity + 1, impact_delay + travel_duration * 0.06, tier)
	if tier >= 3:
		var meteor_target := target
		var meteor_impact_size := impact_size * Vector2(1.65, 1.28)
		meteor_target = target + Vector2(0.0, impact_extent * 0.12)
		_spawn_fire_meteor_attack_layers(meteor_target, launch_delay, travel_duration, layer_intensity, meteor_impact_size)
		_spawn_beam_effect(source, delta, "fire", travel_duration * 1.12, layer_intensity + 2, launch_delay, 1.78)
		for lane_index in [-1, 1]:
			var lane := normal * float(lane_index) * 14.0
			_spawn_beam_effect(source + lane, delta - lane * 0.40, "fire", travel_duration * 0.94, layer_intensity + 1, launch_delay + 0.04, 1.02)
		_spawn_atmospheric_flipbook("embers", source + delta * 0.50, Vector2(delta.length() * 0.92, 126.0 + float(layer_intensity) * 9.0), travel_duration * 1.16, Color(1.0, 0.20, 0.04, 0.30), launch_delay, Vector2.ZERO, 1.02, 0.72, angle, 1)
		_spawn_fire_fragmented_impact_cluster(meteor_target, meteor_impact_size * Vector2(0.88, 0.72), travel_duration * 0.76, layer_intensity + 2, impact_delay + travel_duration * 0.04, 0.72, angle)
		_spawn_burst_particles("fire", meteor_target, maxf(impact_extent * 1.08, meteor_impact_size.y * 0.74), travel_duration * 0.92, layer_intensity + 2)
		_spawn_spark_spray(meteor_target, maxf(impact_extent * 1.16, meteor_impact_size.y * 0.82), travel_duration * 0.90, layer_intensity + 2, impact_delay + travel_duration * 0.04, tier)
		_spawn_light(meteor_target, Color(1.0, 0.28, 0.04, 1.0), 4.6 + float(layer_intensity) * 0.42, meteor_impact_size.x * 0.88, travel_duration * 0.90)
	_spawn_camera_kick(delta.normalized() * (6.0 + float(layer_intensity) * (1.15 + float(tier) * 0.18)), impact_delay)


func spawn_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	var tier := _fire_vfx_tier(intensity)
	var layer_intensity := maxi(3, intensity)
	var normal := Vector2(-delta.y, delta.x).normalized()
	_spawn_fire_ember_lane(source, delta, 0.0, duration, layer_intensity, angle, maxi(2, tier))
	_spawn_beam_effect(source, delta, "fire", duration * 1.14, layer_intensity, 0.0, 1.42 + float(tier) * 0.16)
	_spawn_status_path_afterimage("fire", source, delta, 0.0, duration, layer_intensity, angle)
	_spawn_status_flipbook("burn", source, Vector2(182 + layer_intensity * 22, 118 + layer_intensity * 12), duration * 1.04, Color(1.0, 0.60, 0.18, 0.62), 0.0, delta, 0.88, 2.2, angle, 1)
	_spawn_light(source + delta * 0.50, Color(1.0, 0.50, 0.10, 1.0), 2.8 + float(layer_intensity) * 0.28, maxf(160.0, delta.length() * 0.32), duration * 0.86)
	if tier >= 2:
		_spawn_fire_screen_ember_field(source + delta * 0.50, duration * 1.12, layer_intensity, 0.0, 0.82)
		_spawn_beam_effect(source + normal * 10.0, delta - normal * 6.0, "fire", duration * 0.98, layer_intensity + 1, 0.04, 1.12)
	if tier >= 3:
		_spawn_fire_aurora_layer(source + delta, duration * 1.10, intensity, 0.0, 0.75)
		_spawn_beam_effect(source, delta, "fire", duration * 1.16, layer_intensity + 2, 0.0, 2.05)


func _fire_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	if _tier_provider.is_valid():
		return int(_tier_provider.call(intensity, screen_wide))
	return 1


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


func _spawn_flame_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float, alpha: float) -> void:
	if _flame_scene_spawner.is_valid():
		_flame_scene_spawner.call(center_local, draw_size, lifetime, intensity, delay, move_offset, z, alpha)


func _spawn_pack_layer(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func _spawn_burst_particles(kind: String, center: Vector2, radius: float, lifetime: float, intensity: int) -> void:
	if _burst_particles_spawner.is_valid():
		_burst_particles_spawner.call(kind, center, radius, lifetime, intensity)


func _spawn_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	if _spark_spray_spawner.is_valid():
		_spark_spray_spawner.call(center, radius, lifetime, intensity, delay, tier)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	if _fireball_impact_spawner.is_valid():
		_fireball_impact_spawner.call(center, impact_size, duration, intensity, max_size)


func _spawn_fire_meteor_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool) -> void:
	if _meteor_impact_spawner.is_valid():
		_meteor_impact_spawner.call(center, impact_size, duration, intensity, delay, fragmented_wide)


func _spawn_fire_fragmented_impact_cluster(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float, rotation: float = 0.0) -> void:
	if _fragmented_impact_spawner.is_valid():
		_fragmented_impact_spawner.call(center, draw_size, duration, intensity, delay, alpha_scale, rotation)


func _spawn_fire_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if _aurora_layer_spawner.is_valid():
		_aurora_layer_spawner.call(center, lifetime, intensity, delay, alpha_scale)


func _spawn_fire_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if _screen_ember_field_spawner.is_valid():
		_screen_ember_field_spawner.call(center, lifetime, intensity, delay, alpha_scale)


func _spawn_fire_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	if _ember_lane_spawner.is_valid():
		_ember_lane_spawner.call(source, delta, launch_delay, travel_duration, intensity, angle, tier)


func _spawn_status_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if _status_path_afterimage_spawner.is_valid():
		_status_path_afterimage_spawner.call(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_beam_effect(source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float, radius_scale: float) -> void:
	if _beam_effect_spawner.is_valid():
		_beam_effect_spawner.call(source_local, delta, kind, lifetime, intensity, delay, radius_scale)


func _spawn_fireball_spell_layers(source: Vector2, target: Vector2, delta: Vector2, source_size: Vector2, impact_size: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if _fireball_spell_spawner.is_valid():
		_fireball_spell_spawner.call(source, target, delta, source_size, impact_size, launch_delay, travel_duration, intensity, angle)


func _spawn_fire_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	if _meteor_attack_spawner.is_valid():
		_meteor_attack_spawner.call(target, launch_delay, travel_duration, intensity, impact_size)


func _spawn_camera_kick(offset: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(offset, delay)
