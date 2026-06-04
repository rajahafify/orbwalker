extends RefCounted
class_name CombatMaxVfxIceRecipePresenter

var _tier_provider: Callable
var _layer_size_provider: Callable
var _atmospheric_flipbook_spawner: Callable
var _status_flipbook_spawner: Callable
var _flipbook_spawner: Callable
var _pack_layer_spawner: Callable
var _burst_particles_spawner: Callable
var _light_spawner: Callable
var _status_path_afterimage_spawner: Callable
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
	_status_path_afterimage_spawner = dependencies.get("status_path_afterimage_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())


func spawn_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var tier := _ice_vfx_tier(intensity, screen_wide)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var wide_target := draw_size.x > draw_size.y * 1.35
	var ice_center := center + Vector2(0.0, draw_size.y * (0.16 if wide_target else 0.0))
	var impact_extent := maxf(122.0, base_size * 0.52) if tier == 1 else maxf(172.0, base_size * (0.62 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var wind_size := Vector2(
		maxf(draw_size.x * 1.04, impact_extent * (1.18 if tier >= 2 else 0.96)),
		maxf(draw_size.y * (1.52 if wide_target else 0.82), impact_extent * (0.62 if tier >= 2 else 0.48))
	)
	_spawn_atmospheric_flipbook("frost", ice_center, wind_size * Vector2(0.88, 0.74), duration * 1.12, Color(0.74, 0.94, 1.0, 0.24), 0.0, Vector2(0.0, -max_size * 0.04), 1.02, 0.25, 0.0, 1)
	_spawn_status_flipbook("freeze", ice_center, impact_size * (0.46 if tier == 1 else 0.56), duration * 0.92, Color(0.86, 0.98, 1.0, 0.64), 0.0, Vector2.ZERO, 1.08, 1.7, -0.04, 1)
	if tier == 1:
		_spawn_iceball_impact_layers(ice_center, impact_size, duration, layer_intensity, max_size, 0.0)
	elif tier == 2:
		_spawn_windy_ice_block_layers(ice_center, impact_size * Vector2(1.22, 1.02), duration, layer_intensity, 0.0, 0.92)
	else:
		_spawn_ice_blizzard_layers(ice_center, wind_size * Vector2(1.08, 1.20), duration, layer_intensity, 0.0, wide_target)
	var burst_radius := impact_extent * (0.45 if tier == 1 else 0.70 + float(tier) * 0.10)
	_spawn_burst_particles("ice", ice_center, burst_radius, duration * 0.82, layer_intensity)
	_spawn_light(ice_center, Color(0.72, 0.94, 1.0, 1.0), 2.0 + float(layer_intensity) * (0.24 + float(tier) * 0.06), impact_extent * (0.82 + float(tier) * 0.16), duration * 0.74)


func spawn_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	var tier := _ice_vfx_tier(intensity)
	var layer_intensity := intensity if tier == 1 else maxi(3, intensity)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var source_size := spool_size * (0.90 + float(tier) * 0.10)
	var impact_extent := maxf(134.0, source_size.x * 0.78) if tier == 1 else maxf(184.0, source_size.x * (0.98 + float(tier) * 0.12))
	var impact_size := Vector2(impact_extent, impact_extent)
	var impact_delay := launch_delay + travel_duration * 0.84
	_spawn_light(source, core, 2.2 + float(layer_intensity) * 0.24, source_size.x * (1.12 + float(tier) * 0.08), spool_duration * 1.10)
	_spawn_atmospheric_flipbook("frost", source, source_size * Vector2(1.20, 0.92), spool_duration * 1.14, Color(0.72, 0.94, 1.0, 0.34), 0.0, Vector2(0.0, -14.0), 1.04, 0.42, angle, 1)
	_spawn_status_flipbook("freeze", source, source_size * (0.48 if tier == 1 else 0.58), spool_duration * 0.92, Color(0.86, 0.98, 1.0, 0.64), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
	if tier == 1:
		_spawn_iceball_travel_layers(source, target, delta, source_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_iceball_impact_layers(target, impact_size, travel_duration * 1.02, layer_intensity, impact_extent, impact_delay)
	elif tier == 2:
		_spawn_windy_ice_block_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_windy_ice_block_layers(target, impact_size * Vector2(1.20, 1.02), travel_duration * 1.14, layer_intensity, impact_delay, 0.98)
	else:
		_spawn_ice_blizzard_travel_layers(source, target, delta, normal, impact_size, travel_duration, launch_delay, layer_intensity, angle)
		_spawn_ice_blizzard_layers(target, impact_size * Vector2(1.55, 1.18), travel_duration * 1.26, layer_intensity, impact_delay, true)
	_spawn_camera_kick(delta.normalized() * (3.8 + float(layer_intensity) * (0.75 + float(tier) * 0.20)), impact_delay)


func spawn_windy_block_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	_spawn_windy_ice_block_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle)


func _spawn_iceball_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var ball_size := Vector2(maxf(120.0, source_size.x * 0.82), maxf(82.0, source_size.y * 0.58))
	_spawn_status_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.04, intensity, angle)
	_spawn_flipbook("ice_projectile", source, ball_size, travel_duration * 1.04, Color(0.86, 0.98, 1.0, 0.88), launch_delay, delta, 0.72, 2.1, angle)
	_spawn_status_flipbook("freeze", source, ball_size * 0.58, travel_duration * 0.90, Color(0.76, 0.94, 1.0, 0.42), launch_delay + travel_duration * 0.04, delta, 0.70, 2.3, angle, 1)
	_spawn_atmospheric_flipbook("frost", source + delta * 0.50, Vector2(delta.length() * 0.48, 74.0 + float(intensity) * 5.0), travel_duration * 0.92, Color(0.70, 0.92, 1.0, 0.26), launch_delay + travel_duration * 0.03, Vector2.ZERO, 0.82, 1.4, angle, 1)
	_spawn_pack_layer("hit_02", source + delta * 0.62, "ice", ball_size * 0.44, travel_duration * 0.36, intensity, launch_delay + travel_duration * 0.50, angle, 2.7, 0.32)


func _spawn_windy_ice_block_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var lane_center := source + delta * 0.50
	var lane_length := delta.length() * 0.96
	var block_size := source_size * Vector2(1.12, 0.82)
	_spawn_atmospheric_flipbook("wind", lane_center, Vector2(lane_length, 128.0 + float(intensity) * 12.0), travel_duration * 1.16, Color(0.72, 0.92, 1.0, 0.30), launch_delay, Vector2.ZERO, 1.02, 0.84, angle, 1)
	_spawn_atmospheric_flipbook("snow", lane_center + normal * 10.0, Vector2(lane_length * 0.88, 108.0 + float(intensity) * 9.0), travel_duration * 1.08, Color(0.86, 0.98, 1.0, 0.34), launch_delay + travel_duration * 0.04, Vector2.ZERO, 0.94, 1.0, angle + 0.04, 1)
	_spawn_flipbook("ice_projectile", source + normal * 4.0, block_size, travel_duration * 1.04, Color(0.86, 0.98, 1.0, 0.78), launch_delay + travel_duration * 0.02, delta, 0.82, 2.7, angle, 0.22)
	_spawn_status_flipbook("freeze", source - normal * 6.0, block_size * Vector2(0.74, 0.64), travel_duration * 1.00, Color(0.82, 0.98, 1.0, 0.46), launch_delay + travel_duration * 0.04, delta + normal * 8.0, 0.76, 2.85, angle - 0.04, 1, -0.28)
	_spawn_flipbook("ice_shards", source + delta * 0.12 - normal * 10.0, block_size * Vector2(0.56, 0.38), travel_duration * 0.76, Color(0.82, 0.98, 1.0, 0.52), launch_delay + travel_duration * 0.16, delta * 0.78 + normal * 16.0, 0.56, 3.05, angle + 0.10)
	_spawn_pack_layer("hit_02", lane_center, "ice", block_size * 0.36, travel_duration * 0.42, intensity, launch_delay + travel_duration * 0.42, angle, 3.15, 0.26)
	for lane_index in [-1, 0, 1]:
		var lane := normal * float(lane_index) * (12.0 + float(intensity) * 1.8)
		var shard_size := source_size * Vector2(0.62, 0.42)
		_spawn_status_flipbook("freeze", source + lane, shard_size, travel_duration * 0.94, Color(0.76, 0.94, 1.0, 0.40), launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.32, 0.78, 2.2, angle + float(lane_index) * 0.08, 1)
		_spawn_flipbook("ice_shards", source + lane + delta * 0.16, shard_size * 0.82, travel_duration * 0.74, Color(0.78, 0.96, 1.0, 0.46), launch_delay + float(lane_index + 1) * 0.040, delta * 0.72 - lane * 0.20, 0.58, 2.4, angle + float(lane_index) * 0.10)
	_spawn_status_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.12, intensity, angle)


func _spawn_ice_blizzard_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, impact_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	var layer_size := _vfx_layer_size()
	var lane_center := source + delta * 0.50
	_spawn_windy_ice_block_travel_layers(source, target, delta, normal, impact_size * 0.62, travel_duration, launch_delay, intensity, angle)
	if layer_size.x > 1.0 and layer_size.y > 1.0:
		var focus_y := clampf(target.y, layer_size.y * 0.08, layer_size.y * 0.50)
		var focus := Vector2(layer_size.x * 0.5, focus_y)
		_spawn_atmospheric_flipbook("snow", focus, Vector2(layer_size.x * 1.16, layer_size.y * 0.62), travel_duration * 1.26, Color(0.82, 0.96, 1.0, 0.50), launch_delay, Vector2(0.0, -layer_size.y * 0.05), 1.02, -0.80, 0.0, 2)
		_spawn_atmospheric_flipbook("frost", focus + Vector2(0.0, layer_size.y * 0.04), Vector2(layer_size.x * 1.02, layer_size.y * 0.48), travel_duration * 1.12, Color(0.58, 0.86, 1.0, 0.34), launch_delay + travel_duration * 0.06, Vector2(0.0, -layer_size.y * 0.03), 0.96, -0.55, 0.0, 1)
	for i in range(5 + mini(5, intensity)):
		var progress := float(i) / float(maxi(1, 4 + mini(5, intensity)))
		var start := lane_center + Vector2((progress - 0.5) * impact_size.x * 1.25, -impact_size.y * (0.72 + 0.10 * float(i % 3)))
		var end := target + Vector2((progress - 0.5) * impact_size.x * 0.46, impact_size.y * (0.05 + 0.02 * float(i % 2)))
		var move := end - start
		_spawn_flipbook("ice_shards", start, impact_size * Vector2(0.28, 0.18), travel_duration * 0.74, Color(0.86, 0.98, 1.0, 0.56), launch_delay + travel_duration * (0.10 + progress * 0.18), move, 0.58, 2.8, move.angle())


func _spawn_iceball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float, delay: float) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	_spawn_flipbook("ice_impact", center, impact_size * 0.66, duration * 0.72, Color(0.86, 0.98, 1.0, 0.72), delay, Vector2.ZERO, 0.86, 2.8, 0.05)
	_spawn_flipbook("ice_shards", center + Vector2(-extent * 0.08, -extent * 0.04), impact_size * 0.48, duration * 0.56, Color(0.80, 0.96, 1.0, 0.54), delay + duration * 0.06, Vector2(extent * 0.10, -extent * 0.08), 0.56, 3.0, -0.18)
	_spawn_status_flipbook("freeze", center, impact_size * 0.46, duration * 0.82, Color(0.84, 0.98, 1.0, 0.48), delay + duration * 0.02, Vector2.ZERO, 0.96, 3.1, -0.06, 1)
	_spawn_pack_layer("impact_02", center, "ice", impact_size * 0.46, duration * 0.48, intensity, delay + duration * 0.08, 0.0, 3.2, 0.34)
	_spawn_atmospheric_flipbook("frost", center + Vector2(0.0, -max_size * 0.04), impact_size * Vector2(0.92, 0.56), duration * 0.72, Color(0.70, 0.92, 1.0, 0.24), delay + duration * 0.04, Vector2(0.0, -max_size * 0.08), 0.74, 2.6, 0.0, 1)
	_spawn_light(center, Color(0.70, 0.94, 1.0, 1.0), 1.8 + float(intensity) * 0.22, extent * 0.92, duration * 0.58, delay)


func _spawn_windy_ice_block_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float) -> void:
	var extent := maxf(impact_size.x, impact_size.y)
	var block_size := impact_size * Vector2(0.76, 0.66)
	_spawn_atmospheric_flipbook("wind", center, impact_size * Vector2(1.32, 0.72), duration * 1.02, Color(0.68, 0.92, 1.0, 0.32 * alpha_scale), delay, Vector2(0.0, -extent * 0.04), 1.02, 2.2, 0.0, 1)
	_spawn_atmospheric_flipbook("frost", center + Vector2(0.0, -extent * 0.04), impact_size * Vector2(1.02, 0.76), duration * 1.08, Color(0.72, 0.94, 1.0, 0.36 * alpha_scale), delay + duration * 0.02, Vector2(0.0, -extent * 0.05), 1.00, 2.4, 0.0, 1)
	_spawn_status_flipbook("freeze", center, block_size, duration * 0.98, Color(0.86, 0.98, 1.0, 0.62 * alpha_scale), delay, Vector2.ZERO, 1.08, 2.8, 0.0, 1)
	_spawn_status_flipbook("slow", center + Vector2(0.0, -extent * 0.12), block_size * Vector2(0.74, 0.58), duration * 0.82, Color(0.54, 0.88, 1.0, 0.42 * alpha_scale), delay + duration * 0.08, Vector2.ZERO, 0.94, 3.1, 0.12, 1)
	_spawn_flipbook("ice_impact", center, block_size * 0.84, duration * 0.76, Color(0.82, 0.98, 1.0, 0.58 * alpha_scale), delay + duration * 0.05, Vector2.ZERO, 0.94, 3.0, -0.04)
	for i in range(4 + mini(4, intensity)):
		var progress := float(i) / float(maxi(1, 3 + mini(4, intensity)))
		var offset := Vector2((progress - 0.5) * impact_size.x * 0.68, sin(float(i) * 1.7) * impact_size.y * 0.12)
		_spawn_flipbook("ice_shards", center + offset, impact_size * Vector2(0.22, 0.16), duration * 0.48, Color(0.82, 0.98, 1.0, 0.48 * alpha_scale), delay + duration * (0.08 + progress * 0.14), offset.normalized() * extent * 0.10 + Vector2(0.0, -extent * 0.08), 0.54, 3.2, -0.35 + progress * 0.70)
	_spawn_pack_layer("impact_02", center, "ice", impact_size * 0.44, duration * 0.58, intensity, delay + duration * 0.10, 0.0, 3.3, 0.44 * alpha_scale)
	_spawn_light(center, Color(0.66, 0.92, 1.0, 1.0), 2.0 + float(intensity) * 0.26, extent * 1.04, duration * 0.66, delay)


func _spawn_ice_blizzard_layers(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, wide_target: bool) -> void:
	var layer_size := _vfx_layer_size()
	var extent := maxf(draw_size.x, draw_size.y)
	if layer_size.x > 1.0 and layer_size.y > 1.0:
		var focus_y := clampf(center.y, layer_size.y * 0.08, layer_size.y * 0.52)
		var focus := Vector2(layer_size.x * 0.5, focus_y)
		var blizzard_size := Vector2(layer_size.x * 1.16, layer_size.y * (0.62 if wide_target else 0.52))
		_spawn_atmospheric_flipbook("snow", focus, blizzard_size, duration * 1.34, Color(0.86, 0.98, 1.0, 0.54), delay, Vector2(0.0, -layer_size.y * 0.06), 1.02, -1.0, 0.0, 2)
		_spawn_atmospheric_flipbook("wind", focus + Vector2(0.0, layer_size.y * 0.02), blizzard_size * Vector2(1.08, 0.72), duration * 1.12, Color(0.62, 0.88, 1.0, 0.36), delay + duration * 0.04, Vector2(0.0, -layer_size.y * 0.035), 0.98, -0.72, 0.0, 1)
		_spawn_atmospheric_flipbook("frost", focus + Vector2(0.0, -layer_size.y * 0.02), blizzard_size * Vector2(0.92, 0.62), duration * 1.20, Color(0.50, 0.84, 1.0, 0.30), delay + duration * 0.08, Vector2(0.0, -layer_size.y * 0.025), 0.96, -0.58, 0.0, 1)
	_spawn_windy_ice_block_layers(center, draw_size * Vector2(0.72, 0.62), duration * 0.88, intensity, delay + duration * 0.06, 0.92)
	for i in range(7 + mini(7, intensity)):
		var progress := float(i) / float(maxi(1, 6 + mini(7, intensity)))
		var start := center + Vector2((progress - 0.5) * draw_size.x * 1.06, -draw_size.y * (0.42 + 0.08 * float(i % 4)))
		var move := Vector2((0.5 - progress) * draw_size.x * 0.18, draw_size.y * (0.34 + 0.04 * float(i % 3)))
		_spawn_flipbook("ice_shards", start, Vector2(extent * 0.16, extent * 0.10), duration * 0.52, Color(0.88, 1.0, 1.0, 0.52), delay + duration * (0.04 + progress * 0.20), move, 0.54, 3.4, -0.52 + progress * 1.04)
	_spawn_pack_layer("big_impact_02", center, "ice", draw_size * Vector2(0.38, 0.34), duration * 0.58, intensity, delay + duration * 0.12, 0.0, 3.6, 0.38)
	_spawn_light(center, Color(0.72, 0.94, 1.0, 1.0), 2.8 + float(intensity) * 0.32, extent * 1.18, duration * 0.74, delay)


func _ice_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
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


func _spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int, spin: float = 0.0) -> void:
	if _status_flipbook_spawner.is_valid():
		_status_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops, spin)


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


func _spawn_status_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if _status_path_afterimage_spawner.is_valid():
		_status_path_afterimage_spawner.call(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_camera_kick(offset: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(offset, delay)
