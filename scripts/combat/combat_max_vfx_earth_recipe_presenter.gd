extends RefCounted
class_name CombatMaxVfxEarthRecipePresenter

var _tier_provider: Callable
var _layer_size_provider: Callable
var _atmospheric_flipbook_spawner: Callable
var _status_flipbook_spawner: Callable
var _flipbook_spawner: Callable
var _pack_layer_spawner: Callable
var _burst_particles_spawner: Callable
var _light_spawner: Callable
var _tornado_scene_spawner: Callable
var _camera_kick_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_tier_provider = dependencies.get("tier_provider", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())
	_status_flipbook_spawner = dependencies.get("status_flipbook_spawner", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_burst_particles_spawner = dependencies.get("burst_particles_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_tornado_scene_spawner = dependencies.get("tornado_scene_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())


func spawn_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _earth_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var earth_center := center + Vector2(0.0, draw_size.y * (0.18 if wide_target else 0.08))
	var local_extent := maxf(128.0, draw_size.y * (0.74 if wide_target else 0.92))
	var impact_extent := local_extent if tier == 1 else maxf(local_extent * 1.36, minf(base_size * 0.48, max_size * (0.74 + float(tier) * 0.20)))
	if tier >= 3:
		impact_extent = maxf(impact_extent, max_size * 1.05)
	var impact_size := Vector2(impact_extent, impact_extent)
	_spawn_earth_quake_impact_layers(earth_center, impact_size, duration, layer_intensity, 0.0, tier, screen_wide)
	if tier >= 3:
		var target_tornado_size := Vector2(draw_size.x * 0.96, draw_size.y * (0.86 if wide_target else 0.92))
		_spawn_earth_tornado_atmosphere(earth_center, target_tornado_size, duration * 1.16, layer_intensity, duration * 0.04, true)
	_spawn_burst_particles("earth", earth_center, impact_extent * (0.56 if tier == 1 else 0.82 + float(tier) * 0.08), duration * 0.82, layer_intensity)
	_spawn_light(earth_center, Color(0.92, 0.76, 0.48, 1.0), 2.1 + float(layer_intensity) * (0.24 + float(tier) * 0.06), impact_extent * (0.86 + float(tier) * 0.15), duration * 0.70)


func spawn_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _earth_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (0.92 + float(tier) * 0.10)
	var impact_extent := maxf(140.0, source_size.x * 0.78) if tier == 1 else maxf(196.0, source_size.x * (1.02 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.84
	_spawn_light(source, core, 2.1 + float(layer_intensity) * 0.24, source_size.x * (1.16 + float(tier) * 0.08), spool_duration * 1.08)
	_spawn_earth_spool_layers(source, source_size, spool_duration, layer_intensity, tier, angle)
	_spawn_earth_fracture_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, layer_intensity, angle, tier)
	_spawn_earth_quake_impact_layers(target, impact_size, travel_duration * 1.16, layer_intensity, impact_delay, tier, false)
	if tier >= 3:
		_spawn_earth_tornado_atmosphere(target, impact_size * Vector2(1.08, 0.58), travel_duration * 1.34, layer_intensity, impact_delay + travel_duration * 0.06, true)
	_spawn_camera_kick(delta.normalized() * (4.4 + float(layer_intensity) * (0.85 + float(tier) * 0.18)), impact_delay)


func spawn_fracture_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
	_spawn_earth_fracture_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle, tier)


func _spawn_earth_spool_layers(source: Vector2, source_size: Vector2, spool_duration: float, intensity: int, tier: int, angle: float) -> void:
	var ground_center := source + Vector2(0.0, source_size.y * 0.16)
	var dust_size := source_size * (Vector2(1.10, 0.46) if tier == 1 else Vector2(1.64, 0.62))
	var tornado_size := source_size * (Vector2(0.66, 0.78) if tier == 1 else Vector2(0.86, 0.98))
	_spawn_tornado_scene(source + Vector2(0.0, source_size.y * 0.08), tornado_size, spool_duration * 1.08, intensity, 0.0, Vector2.ZERO, 1.30, "tornado poison")
	_spawn_atmospheric_flipbook("bubbles", ground_center + Vector2(0.0, source_size.y * 0.03), source_size * Vector2(0.74 if tier == 1 else 1.00, 0.38 if tier == 1 else 0.50), spool_duration * 0.86, Color(0.54, 1.0, 0.24, 0.28 if tier == 1 else 0.42), 0.04, Vector2(0.0, -source_size.y * 0.08), 0.70, 1.18, angle, 1)
	_spawn_status_flipbook("poison", source + Vector2(0.0, source_size.y * 0.02), source_size * (0.34 if tier == 1 else 0.48), spool_duration * 0.96, Color(0.64, 1.0, 0.24, 0.34 if tier == 1 else 0.46), 0.02, Vector2.ZERO, 1.04, 1.38, angle, 1)
	_spawn_status_flipbook("weaken", source + Vector2(0.0, source_size.y * 0.07), source_size * Vector2(0.58, 0.36), spool_duration * 0.86, Color(0.70, 1.0, 0.28, 0.30 if tier == 1 else 0.42), 0.10, Vector2(0.0, -source_size.y * 0.04), 0.86, 1.46, angle + 0.12, 1)
	_spawn_flipbook("dust_puff", ground_center + Vector2(0.0, source_size.y * 0.10), dust_size, spool_duration * 1.02, Color(0.52, 0.42, 0.30, 0.40 if tier == 1 else 0.56), 0.04, Vector2(0.0, -source_size.y * 0.09), 0.72, 0.95, angle)
	_spawn_flipbook("shockwave_ring", ground_center, source_size * Vector2(0.92 + float(tier) * 0.20, 0.44 + float(tier) * 0.08), spool_duration * 0.66, Color(0.66, 1.0, 0.30, 0.42 if tier == 1 else 0.58), 0.08, Vector2.ZERO, 1.24, 1.06, angle)
	_spawn_pack_layer("hit_01", source + Vector2(0.0, source_size.y * 0.02), "earth", source_size * (0.34 if tier == 1 else 0.56), spool_duration * 0.48, intensity, 0.14, angle, 1.72, 0.36 if tier == 1 else 0.56)
	_spawn_earth_debris_spray(ground_center, source_size.x * (0.46 if tier == 1 else 0.72), spool_duration * 0.78, intensity, 0.06, tier, angle)
	if tier >= 2:
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, source_size.y * 0.14), source_size * Vector2(1.08, 0.48), spool_duration * 0.74, Color(0.54, 0.92, 0.30, 0.30), 0.10, Vector2(0.0, -source_size.y * 0.04), 0.74, 1.32, angle, 1)
		_spawn_status_flipbook("regen", source + Vector2(-source_size.x * 0.08, -source_size.y * 0.04), source_size * 0.36, spool_duration * 0.72, Color(0.54, 1.0, 0.30, 0.34), 0.18, Vector2(source_size.x * 0.08, -source_size.y * 0.08), 0.82, 1.86, angle - 0.16, 1)
		_spawn_pack_layer("hit_02", source + Vector2(source_size.x * 0.10, -source_size.y * 0.08), "earth", source_size * 0.48, spool_duration * 0.46, intensity + 1, 0.24, angle + 0.20, 1.92, 0.46)
		_spawn_flipbook("dust_puff", ground_center + Vector2(0.0, source_size.y * 0.08), source_size * Vector2(1.88, 0.66), spool_duration * 0.88, Color(0.42, 0.34, 0.24, 0.38), 0.12, Vector2(0.0, -source_size.y * 0.12), 0.80, 1.12, angle)
		_spawn_burst_particles("earth", source + Vector2(0.0, source_size.y * 0.08), source_size.x * 0.82, spool_duration * 0.64, intensity + 2)
	if tier >= 3:
		_spawn_tornado_scene(source + Vector2(source_size.x * 0.10, source_size.y * 0.04), source_size * Vector2(0.96, 1.06), spool_duration * 0.92, intensity + 2, 0.12, Vector2.ZERO, 1.45, "tornado poison")
		_spawn_atmospheric_flipbook("magic_wind", source + Vector2(0.0, source_size.y * 0.02), source_size * Vector2(1.72, 0.82), spool_duration * 1.02, Color(0.48, 1.0, 0.22, 0.26), 0.08, Vector2(0.0, -source_size.y * 0.12), 0.92, 0.82, angle, 1)
		_spawn_status_flipbook("shock", source + Vector2(source_size.x * 0.08, -source_size.y * 0.04), source_size * 0.34, spool_duration * 0.56, Color(0.78, 1.0, 0.34, 0.34), 0.26, Vector2(-source_size.x * 0.06, source_size.y * 0.02), 0.72, 2.05, angle + 0.24, 1)
		_spawn_earth_debris_spray(ground_center, source_size.x * 0.92, spool_duration * 0.68, intensity + 2, 0.16, 3, angle)


func _spawn_earth_debris_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int, angle: float) -> void:
	var count := (5 if tier == 1 else 11) + mini(8, intensity)
	for i in range(count):
		var ratio := (float(i) + 0.5) / float(count)
		var theta := angle + (ratio - 0.5) * PI * 1.38 + sin(float(i) * 1.73) * 0.22
		var direction := Vector2(cos(theta), sin(theta) * 0.48 - 0.34).normalized()
		var key := "dust_puff" if i % 3 == 0 else "stone_chunks"
		var size_base := 26.0 + float(intensity) * 3.6 + float(tier) * 5.0
		var size := Vector2(size_base * 1.34, size_base * 0.86) if key == "dust_puff" else Vector2(size_base * 0.90, size_base * 1.18)
		var start := center + direction * radius * (0.08 + float(i % 4) * 0.025)
		var travel := direction * radius * (0.30 + float(i % 5) * 0.055 + float(tier) * 0.045) + Vector2(0.0, -radius * (0.10 + float(tier) * 0.035))
		var alpha := 0.28 + float(tier) * 0.06 if key == "dust_puff" else 0.48 + float(tier) * 0.05
		_spawn_flipbook(key, start, size, lifetime * (0.42 + float(i % 4) * 0.045), Color(0.64, 0.54, 0.38, alpha), delay + float(i % 6) * lifetime * 0.018, travel, 0.40, 2.45 + float(tier) * 0.18, theta, 0.56)


func _spawn_earth_fracture_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
	var lane_center := source + delta * 0.50 + Vector2(0.0, 18.0)
	var lane_length := delta.length() * (0.92 + float(tier) * 0.04)
	var lane_height := (76.0 if tier == 1 else 104.0) + float(intensity) * 11.0 + float(tier) * 16.0
	_spawn_atmospheric_flipbook("caustics", lane_center, Vector2(lane_length, lane_height), travel_duration * 1.22, Color(0.54, 1.0, 0.22, 0.54 if tier == 1 else 0.72), launch_delay, Vector2(0.0, 8.0), 1.04, 1.20, angle, 1)
	_spawn_flipbook("dust_puff", lane_center + Vector2(0.0, lane_height * 0.18), Vector2(lane_length * 0.68, lane_height * 0.34), travel_duration * 0.92, Color(0.48, 0.38, 0.26, 0.22 if tier == 1 else 0.34), launch_delay + travel_duration * 0.08, Vector2(0.0, -12.0), 0.78, 1.02, angle)
	var vein_count := 3 + mini(4, tier + int(floor(float(intensity) / 3.0)))
	for i in range(vein_count):
		var progress := (float(i) + 0.42) / float(vein_count + 1)
		var wave := sin(progress * PI)
		var point := source + delta * progress + normal * sin(float(i) * 1.81) * (12.0 + float(tier) * 4.0) * wave + Vector2(0.0, 20.0 + wave * 8.0)
		var vein_size := Vector2(58.0 + float(intensity) * 6.0, 34.0 + float(intensity) * 3.0) * (1.0 + float(tier) * 0.08)
		_spawn_status_flipbook("weaken", point, vein_size, travel_duration * 0.42, Color(0.62, 1.0, 0.26, 0.34 if tier == 1 else 0.46), launch_delay + travel_duration * (0.12 + progress * 0.50), Vector2(0.0, -18.0 - float(tier) * 5.0), 0.50, 2.22, angle + sin(float(i)) * 0.24, 1)
	if tier >= 2:
		_spawn_atmospheric_flipbook("caustics", lane_center + normal * (16.0 + float(intensity) * 1.4), Vector2(lane_length * 0.82, lane_height * 0.66), travel_duration * 1.02, Color(0.76, 1.0, 0.36, 0.42), launch_delay + travel_duration * 0.08, Vector2(0.0, 12.0), 0.96, 1.05, angle + 0.08, 1)
		_spawn_atmospheric_flipbook("magic_wind", lane_center - normal * (12.0 + float(intensity)), Vector2(lane_length * 0.72, lane_height * 0.74), travel_duration * 0.98, Color(0.46, 0.94, 0.24, 0.26), launch_delay + travel_duration * 0.06, Vector2(0.0, -10.0), 0.90, 1.18, angle - 0.06, 1)
		_spawn_pack_layer("hit_01", lane_center + normal * 12.0, "earth", source_size * 0.46, travel_duration * 0.42, intensity + 1, launch_delay + travel_duration * 0.36, angle, 2.85, 0.38)
	if tier >= 3:
		_spawn_atmospheric_flipbook("fog", lane_center + Vector2(0.0, lane_height * 0.20), Vector2(lane_length * 1.02, lane_height * 0.58), travel_duration * 1.12, Color(0.40, 0.34, 0.24, 0.24), launch_delay + travel_duration * 0.04, Vector2(0.0, -18.0), 0.90, 0.92, angle, 1)
		_spawn_atmospheric_flipbook("caustics", lane_center, Vector2(lane_length * 1.08, lane_height * 0.92), travel_duration * 1.10, Color(0.46, 1.0, 0.18, 0.34), launch_delay + travel_duration * 0.14, Vector2(0.0, 14.0), 0.92, 1.32, angle - 0.04, 1)
	var chunk_count := (4 if tier == 1 else 10) + mini(8, intensity)
	for i in range(chunk_count):
		var progress := (float(i) + 0.30) / float(chunk_count)
		var offset := normal * sin(float(i) * 1.74) * (18.0 + float(tier) * 7.0) + Vector2(0.0, 18.0 + sin(float(i)) * 8.0)
		var start := source + delta * progress + offset
		var move := normal * sin(float(i) * 2.10) * (22.0 + float(intensity) * 2.2) + Vector2(0.0, -34.0 - float(tier) * 10.0)
		var key := "dust_puff" if tier >= 2 and i % 3 == 0 else "stone_chunks"
		var particle_size := Vector2(66.0 + float(intensity) * 7.0, 42.0 + float(intensity) * 4.0) if key == "dust_puff" else Vector2(44.0 + float(intensity) * 5.0, 56.0 + float(intensity) * 5.0)
		var alpha := 0.34 if key == "dust_puff" else 0.54
		_spawn_flipbook(key, start, particle_size, travel_duration * (0.40 if key == "dust_puff" else 0.46), Color(0.66, 0.58, 0.42, alpha), launch_delay + travel_duration * (0.10 + progress * 0.42), move, 0.54, 2.6, angle + sin(float(i)) * 0.42, 0.48)


func _spawn_earth_quake_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, tier: int, screen_wide: bool) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var ground_center := center + Vector2(0.0, extent * 0.12)
	_spawn_atmospheric_flipbook("fog", ground_center + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.92 if tier == 1 else 1.12, 0.46 if tier == 1 else 0.58), duration * 0.92, Color(0.42, 0.34, 0.22, 0.20 if tier == 1 else 0.30), delay + duration * 0.02, Vector2(0.0, -extent * 0.08), 0.78, 1.72, 0.0, 1)
	_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, extent * 0.06), impact_size * Vector2(0.74 if tier == 1 else 1.00, 0.36 if tier == 1 else 0.46), duration * 0.70, Color(0.54, 0.84, 0.30, 0.26 if tier == 1 else 0.34), delay + duration * 0.06, Vector2(0.0, -extent * 0.06), 0.62, 2.10, 0.0, 1)
	_spawn_atmospheric_flipbook("bubbles", ground_center + Vector2(0.0, -extent * 0.02), impact_size * Vector2(0.42 if tier == 1 else 0.58, 0.34 if tier == 1 else 0.44), duration * 0.62, Color(0.50, 1.0, 0.24, 0.24 if tier == 1 else 0.34), delay + duration * 0.10, Vector2(0.0, -extent * 0.16), 0.54, 2.42, 0.0, 1)
	_spawn_status_flipbook("weaken", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.42 if tier == 1 else 0.54, 0.36 if tier == 1 else 0.44), duration * 0.78, Color(0.66, 1.0, 0.28, 0.34 if tier == 1 else 0.46), delay + duration * 0.04, Vector2(0.0, -extent * 0.04), 0.78, 2.78, 0.06, 1)
	if tier == 1:
		_spawn_status_flipbook("poison", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.34, 0.30), duration * 0.64, Color(0.56, 1.0, 0.22, 0.30), delay + duration * 0.10, Vector2(0.0, -extent * 0.05), 0.64, 2.86, -0.10, 1)
	_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.08), impact_size * Vector2(0.88 if tier == 1 else 1.02, 0.50 if tier == 1 else 0.56), duration * 0.62, Color(0.78, 1.0, 0.36, 0.48 if tier == 1 else 0.56), delay, Vector2.ZERO, 1.30 if tier == 1 else 1.38, 2.1, 0.0)
	_spawn_pack_layer("impact_01", center + Vector2(0.0, extent * 0.08), "earth", impact_size * (0.48 if tier == 1 else 0.70), duration * 0.58, intensity, delay + duration * 0.04, 0.0, 3.15, 0.50 if tier == 1 else 0.72)
	_spawn_pack_layer("hit_01", center + Vector2(-extent * 0.12, -extent * 0.02), "earth", impact_size * (0.34 if tier == 1 else 0.48), duration * 0.44, intensity + 1, delay + duration * 0.12, -0.22, 3.35, 0.42 if tier == 1 else 0.58)
	_spawn_pack_layer("hit_02", center + Vector2(extent * 0.10, extent * 0.02), "earth", impact_size * (0.28 if tier == 1 else 0.42), duration * 0.38, intensity + 1, delay + duration * 0.20, 0.18, 3.42, 0.36 if tier == 1 else 0.50)
	if tier == 1 or (tier == 2 and intensity <= 3):
		_spawn_pack_layer("impact_02", center + Vector2(-extent * 0.06, extent * 0.06), "earth", impact_size * (0.46 if tier == 1 else 0.58), duration * 0.46, intensity + 1, delay + duration * 0.22, -0.16, 3.48, 0.42 if tier == 1 else 0.54)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.16), impact_size * Vector2(1.12 if tier == 1 else 1.26, 0.42), duration * 0.48, Color(0.64, 1.0, 0.28, 0.36 if tier == 1 else 0.46), delay + duration * 0.18, Vector2.ZERO, 1.18, 2.50, -0.02)
	_spawn_flipbook("dust_puff", center + Vector2(0.0, extent * 0.18), impact_size * Vector2(0.78 if tier == 1 else 1.00, 0.40 if tier == 1 else 0.48), duration * 0.82, Color(0.58, 0.44, 0.26, 0.36 if tier == 1 else 0.44), delay + duration * 0.08, Vector2(0.0, -extent * 0.10), 0.72, 2.35, 0.0)
	var impact_chunk_count := (2 if tier == 1 else 5) + mini(6, intensity)
	for i in range(impact_chunk_count):
		var progress := float(i) / float(maxi(1, impact_chunk_count - 1))
		var offset := Vector2((progress - 0.5) * impact_size.x * (0.78 if screen_wide else 0.58), sin(float(i) * 1.5) * impact_size.y * 0.10)
		_spawn_flipbook("stone_chunks", center + offset + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.16, 0.18), duration * 0.52, Color(0.68, 0.58, 0.40, 0.58), delay + duration * (0.06 + progress * 0.16), offset.normalized() * extent * 0.12 + Vector2(0.0, -extent * 0.12), 0.54, 3.3, -0.32 + progress * 0.64, 0.50)
	if tier >= 2:
		_spawn_status_flipbook("poison", center + Vector2(-extent * 0.04, extent * 0.02), impact_size * Vector2(0.52, 0.42), duration * 0.78, Color(0.58, 1.0, 0.24, 0.40), delay + duration * 0.05, Vector2(extent * 0.04, -extent * 0.05), 0.82, 3.05, -0.08, 1)
		_spawn_status_flipbook("shock", center + Vector2(extent * 0.08, -extent * 0.04), impact_size * Vector2(0.28, 0.24), duration * 0.48, Color(0.84, 1.0, 0.36, 0.36), delay + duration * 0.16, Vector2(-extent * 0.05, extent * 0.02), 0.60, 3.42, 0.22, 1)
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(-extent * 0.05, extent * 0.02), impact_size * Vector2(1.12, 0.44), duration * 0.62, Color(0.48, 0.74, 0.26, 0.30), delay + duration * 0.12, Vector2(extent * 0.04, -extent * 0.08), 0.66, 2.38, 0.04, 1)
		_spawn_atmospheric_flipbook("bubbles", center + Vector2(extent * 0.06, -extent * 0.02), impact_size * Vector2(0.62, 0.46), duration * 0.58, Color(0.54, 1.0, 0.22, 0.30), delay + duration * 0.16, Vector2(-extent * 0.04, -extent * 0.18), 0.52, 3.06, -0.08, 1)
		_spawn_pack_layer("impact_02", center + Vector2(extent * 0.10, -extent * 0.04), "earth", impact_size * 0.62, duration * 0.52, intensity + 1, delay + duration * 0.12, 0.18, 3.50, 0.60)
		_spawn_pack_layer("big_impact_01", center + Vector2(0.0, extent * 0.04), "earth", impact_size * 0.44, duration * 0.48, intensity + 1, delay + duration * 0.22, -0.08, 3.58, 0.34)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.14), impact_size * Vector2(1.30, 0.48), duration * 0.56, Color(0.76, 1.0, 0.38, 0.42), delay + duration * 0.08, Vector2.ZERO, 1.24, 2.55, 0.04)
		_spawn_flipbook("dust_puff", center + Vector2(0.0, extent * 0.24), impact_size * Vector2(1.28, 0.42), duration * 0.74, Color(0.42, 0.32, 0.20, 0.30), delay + duration * 0.14, Vector2(0.0, -extent * 0.08), 0.76, 2.05, 0.0)
		_spawn_atmospheric_flipbook("magic_wind", center + Vector2(0.0, extent * 0.04), impact_size * Vector2(0.92, 0.44), duration * 0.74, Color(0.48, 1.0, 0.22, 0.24), delay + duration * 0.14, Vector2(0.0, -extent * 0.06), 0.78, 2.72, 0.0, 1)
		_spawn_burst_particles("earth", center, extent * 0.64, duration * 0.70, intensity + 1)
	if tier >= 3:
		_spawn_atmospheric_flipbook("storm", center + Vector2(0.0, extent * 0.02), impact_size * Vector2(0.84, 0.48), duration * 0.72, Color(0.42, 0.58, 0.36, 0.20), delay + duration * 0.18, Vector2(0.0, -extent * 0.06), 0.72, 2.52, 0.0, 1)
		_spawn_atmospheric_flipbook("rain_splash", ground_center + Vector2(0.0, extent * 0.04), impact_size * Vector2(1.42, 0.62), duration * 0.78, Color(0.52, 0.84, 0.28, 0.40), delay + duration * 0.08, Vector2(0.0, -extent * 0.12), 0.62, 3.34, 0.0, 1)
		_spawn_atmospheric_flipbook("fog", ground_center + Vector2(0.0, extent * 0.10), impact_size * Vector2(1.28, 0.54), duration * 0.90, Color(0.34, 0.28, 0.20, 0.28), delay + duration * 0.04, Vector2(0.0, -extent * 0.10), 0.78, 2.58, 0.0, 1)
		_spawn_atmospheric_flipbook("bubbles", center + Vector2(0.0, -extent * 0.06), impact_size * Vector2(0.78, 0.56), duration * 0.64, Color(0.48, 1.0, 0.20, 0.34), delay + duration * 0.20, Vector2(0.0, -extent * 0.20), 0.50, 3.62, 0.0, 1)
		_spawn_pack_layer("big_impact_02", center + Vector2(-extent * 0.08, -extent * 0.02), "earth", impact_size * 0.52, duration * 0.56, intensity + 2, delay + duration * 0.26, 0.16, 3.76, 0.46)
		_spawn_flipbook("shockwave_ring", center + Vector2(0.0, extent * 0.18), impact_size * Vector2(1.44, 0.54), duration * 0.64, Color(0.62, 1.0, 0.28, 0.42), delay + duration * 0.20, Vector2.ZERO, 1.20, 3.02, 0.06)
		_spawn_earth_debris_spray(center + Vector2(0.0, extent * 0.08), extent * 0.58, duration * 0.70, intensity + 2, delay + duration * 0.18, 3, 0.0)
	_spawn_light(center, Color(0.92, 0.74, 0.44, 1.0), 2.0 + float(intensity) * (0.24 + float(tier) * 0.05), extent * (0.88 + float(tier) * 0.12), duration * 0.58, delay)


func _spawn_earth_tornado_atmosphere(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, _screen_wide: bool) -> void:
	var layer_size := _vfx_layer_size()
	var focus := center
	var max_width := layer_size.x * 0.86 if layer_size.x > 1.0 else draw_size.x
	var max_height := clampf(layer_size.y * 0.13, 96.0, 130.0) if layer_size.y > 1.0 else draw_size.y
	var atmosphere_size := Vector2(minf(draw_size.x, max_width), minf(draw_size.y, max_height))
	_spawn_atmospheric_flipbook("tornado", focus + Vector2(0.0, atmosphere_size.y * 0.02), atmosphere_size, duration * 1.18, Color(0.62, 0.62, 0.56, 0.44), delay, Vector2.ZERO, 1.03, 0.70, 0.0, 2)
	_spawn_atmospheric_flipbook("fog", focus + Vector2(0.0, atmosphere_size.y * 0.24), atmosphere_size * Vector2(0.96, 0.42), duration * 1.10, Color(0.34, 0.28, 0.20, 0.30), delay + duration * 0.04, Vector2(0.0, -atmosphere_size.y * 0.06), 0.82, 0.88, 0.0, 1)
	_spawn_atmospheric_flipbook("rain_splash", focus + Vector2(0.0, atmosphere_size.y * 0.36), atmosphere_size * Vector2(0.86, 0.30), duration * 0.76, Color(0.50, 0.80, 0.26, 0.28), delay + duration * 0.10, Vector2(0.0, -atmosphere_size.y * 0.05), 0.62, 1.18, 0.0, 1)
	_spawn_atmospheric_flipbook("bubbles", focus + Vector2(0.0, atmosphere_size.y * 0.06), atmosphere_size * Vector2(0.38, 0.30), duration * 0.66, Color(0.46, 1.0, 0.20, 0.28), delay + duration * 0.16, Vector2(0.0, -atmosphere_size.y * 0.16), 0.52, 1.32, 0.0, 1)
	_spawn_status_flipbook("weaken", focus + Vector2(0.0, atmosphere_size.y * 0.02), atmosphere_size * Vector2(0.24, 0.22), duration * 0.58, Color(0.70, 1.0, 0.28, 0.32), delay + duration * 0.16, Vector2(0.0, -atmosphere_size.y * 0.10), 0.58, 1.48, 0.12, 1)
	_spawn_flipbook("dust_puff", focus + Vector2(0.0, atmosphere_size.y * 0.30), atmosphere_size * Vector2(0.82, 0.28), duration * 1.00, Color(0.50, 0.42, 0.32, 0.28), delay + duration * 0.08, Vector2(0.0, -atmosphere_size.y * 0.08), 0.78, 1.05, 0.0)
	_spawn_burst_particles("earth", focus + Vector2(0.0, atmosphere_size.y * 0.12), maxf(atmosphere_size.x, atmosphere_size.y) * 0.22, duration * 0.72, intensity + 1)


func _earth_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
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


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float = 0.0) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, spin)


func _spawn_pack_layer(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func _spawn_burst_particles(kind: String, center: Vector2, radius: float, lifetime: float, intensity: int) -> void:
	if _burst_particles_spawner.is_valid():
		_burst_particles_spawner.call(kind, center, radius, lifetime, intensity)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime, delay)


func _spawn_tornado_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float, variant_hint: String) -> void:
	if _tornado_scene_spawner.is_valid():
		_tornado_scene_spawner.call(center_local, draw_size, lifetime, intensity, delay, move_offset, z, variant_hint)


func _spawn_camera_kick(offset: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(offset, delay)
