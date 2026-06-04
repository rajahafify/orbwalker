extends RefCounted
class_name CombatMaxVfxStatusRecipePresenter

var _kind_cleaner: Callable
var _layer_size_provider: Callable
var _kind_colors_provider: Callable
var _status_sheet_key_provider: Callable
var _status_trail_key_provider: Callable
var _status_flipbook_spawner: Callable
var _shield_scene_spawner: Callable
var _light_spawner: Callable
var _coin_rain_spawner: Callable
var _fire_replay_layers_spawner: Callable
var _ice_replay_layers_spawner: Callable
var _earth_replay_layers_spawner: Callable
var _fire_cast_layers_spawner: Callable
var _ice_cast_layers_spawner: Callable
var _earth_cast_layers_spawner: Callable
var _fire_beam_layers_spawner: Callable
var _windy_ice_block_travel_spawner: Callable
var _earth_fracture_travel_spawner: Callable
var _earth_tier_provider: Callable
var _pack_impact_scene_key_provider: Callable
var _atmospheric_replay_layer_spawner: Callable
var _atmospheric_travel_spawner: Callable
var _beam_effect_spawner: Callable
var _pack_layer_spawner: Callable
var _burst_particles_spawner: Callable
var _camera_kick_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_cleaner = dependencies.get("kind_cleaner", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_status_sheet_key_provider = dependencies.get("status_sheet_key_provider", Callable())
	_status_trail_key_provider = dependencies.get("status_trail_key_provider", Callable())
	_status_flipbook_spawner = dependencies.get("status_flipbook_spawner", Callable())
	_shield_scene_spawner = dependencies.get("shield_scene_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_coin_rain_spawner = dependencies.get("coin_rain_spawner", Callable())
	_fire_replay_layers_spawner = dependencies.get("fire_replay_layers_spawner", Callable())
	_ice_replay_layers_spawner = dependencies.get("ice_replay_layers_spawner", Callable())
	_earth_replay_layers_spawner = dependencies.get("earth_replay_layers_spawner", Callable())
	_fire_cast_layers_spawner = dependencies.get("fire_cast_layers_spawner", Callable())
	_ice_cast_layers_spawner = dependencies.get("ice_cast_layers_spawner", Callable())
	_earth_cast_layers_spawner = dependencies.get("earth_cast_layers_spawner", Callable())
	_fire_beam_layers_spawner = dependencies.get("fire_beam_layers_spawner", Callable())
	_windy_ice_block_travel_spawner = dependencies.get("windy_ice_block_travel_spawner", Callable())
	_earth_fracture_travel_spawner = dependencies.get("earth_fracture_travel_spawner", Callable())
	_earth_tier_provider = dependencies.get("earth_tier_provider", Callable())
	_pack_impact_scene_key_provider = dependencies.get("pack_impact_scene_key_provider", Callable())
	_atmospheric_replay_layer_spawner = dependencies.get("atmospheric_replay_layer_spawner", Callable())
	_atmospheric_travel_spawner = dependencies.get("atmospheric_travel_spawner", Callable())
	_beam_effect_spawner = dependencies.get("beam_effect_spawner", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_burst_particles_spawner = dependencies.get("burst_particles_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())


func spawn_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var size := draw_size * (1.0 + float(intensity) * 0.035)
	_spawn_shield_scene(center, size * Vector2(0.86, 0.48), lifetime * 1.04, intensity, 0.0, Vector2.ZERO, 1.8)
	_spawn_status_flipbook("shield", center, size * Vector2(0.92, 0.58), lifetime * 1.12, Color(0.86, 0.96, 1.0, 0.76), 0.0, Vector2.ZERO, 1.06, 2.1, 0.0, 2)
	_spawn_status_flipbook("armor", center + Vector2(0.0, -draw_size.y * 0.06), size * Vector2(0.48, 0.40), lifetime * 0.78, Color(0.58, 0.84, 1.0, 0.52), lifetime * 0.08, Vector2.ZERO, 0.95, 2.5, 0.0, 1)
	_spawn_light(center, Color(0.80, 0.94, 1.0, 1.0), 2.4 + float(intensity) * 0.22, draw_size.x * 0.82, lifetime)


func spawn_replay_recipe(kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var clean_kind := _clean_kind(kind)
	if clean_kind == "fire":
		_spawn_fire_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "ice":
		_spawn_ice_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "earth":
		_spawn_earth_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	var status_size := Vector2(base_size, base_size) * (1.36 if screen_wide else 0.86)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	_spawn_atmospheric_replay_layer(clean_kind, center, max_size, base_size, duration, intensity, screen_wide)
	match clean_kind:
		"heart":
			_spawn_status_flipbook("heal", center, status_size * Vector2(0.38, 0.52), duration * 0.98, Color(0.84, 1.0, 0.80, 0.66), 0.0, Vector2(0.0, -max_size * 0.24), 1.06, 1.9, 0.0, 1)
			_spawn_status_flipbook("regen", center + Vector2(0.0, max_size * 0.12), status_size * 0.30, duration * 0.82, Color(0.48, 1.0, 0.60, 0.52), 0.08, Vector2(0.0, -max_size * 0.30), 0.92, 2.2, 0.08, 1)
			_spawn_pack_layer("hit_02", center + Vector2(0.0, -max_size * 0.05), "heart", status_size * 0.28, duration * 0.54, intensity, 0.16, 0.0, 2.6, 0.34)
		"armor":
			_spawn_status_flipbook("shield", center, status_size * Vector2(0.50, 0.42), duration * 0.98, Color(0.86, 0.96, 1.0, 0.66), 0.0, Vector2.ZERO, 1.08, 1.9, 0.0, 1)
			_spawn_shield_scene(center, status_size * Vector2(0.92, 0.62), duration * 1.10, intensity, 0.02, Vector2.ZERO, 2.1)
			_spawn_status_flipbook("armor", center + Vector2(0.0, -max_size * 0.06), status_size * 0.28, duration * 0.64, Color(0.62, 0.86, 1.0, 0.44), 0.12, Vector2.ZERO, 0.94, 2.6, 0.0, 1)
			_spawn_pack_layer("impact_02", center, "armor", status_size * 0.38, duration * 0.58, intensity, 0.12, 0.0, 2.7, 0.42)
		"gold":
			_spawn_status_flipbook("blessed", center, status_size * 0.42, duration * 0.86, Color(1.0, 0.86, 0.38, 0.62), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1)
			_spawn_status_flipbook("haste", center + Vector2(0.0, -max_size * 0.08), status_size * 0.28, duration * 0.58, Color(1.0, 0.96, 0.44, 0.42), 0.08, Vector2.ZERO, 1.05, 2.2, 0.12, 1)
			_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
			_spawn_pack_layer("hit_01", center, "gold", status_size * 0.30, duration * 0.46, intensity, 0.12, 0.22, 2.5, 0.42)
		"damage":
			_spawn_status_flipbook("bleed", center, status_size * 0.40, duration * 0.72, Color(1.0, 0.56, 0.48, 0.62), 0.0, Vector2.ZERO, 1.08, 1.9, -0.10, 1)
			_spawn_status_flipbook("stun", center, status_size * 0.26, duration * 0.48, Color(1.0, 0.90, 0.42, 0.34), 0.08, Vector2.ZERO, 0.88, 2.2, 0.16, 1)
			_spawn_pack_layer(_pack_impact_scene_key("damage", intensity, screen_wide), center, "damage", status_size * 0.46, duration * 0.56, intensity, 0.04, -0.08, 2.5, 0.54)
		_:
			_spawn_status_flipbook(_status_sheet_key(clean_kind), center, status_size * 0.42, duration, Color(core.r, core.g, core.b, 0.62), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1)
	if screen_wide:
		spawn_screen_wide(clean_kind, center, duration, intensity)
	_spawn_burst_particles(clean_kind, center, max_size, duration * 0.74, intensity)
	_spawn_light(center, core, 2.6 + float(intensity) * 0.32, base_size * 1.05, duration * 0.64)


func spawn_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	var count := 4 + mini(7, intensity)
	var normal := Vector2(-delta.y, delta.x).normalized()
	for i in range(count):
		var progress := (float(i) + 0.35) / float(count + 1)
		var wave := sin(progress * PI)
		var lane := normal * sin(float(i) * 1.65) * (9.0 + float(intensity) * 1.9) * wave
		if clean_kind == "earth":
			lane += Vector2(0.0, 16.0 * wave)
		elif clean_kind == "ice":
			lane += normal * float(i % 2 * 2 - 1) * 7.0
		elif clean_kind == "heart":
			lane += Vector2(0.0, -10.0 * wave)
		var point := source + delta * progress + lane
		var delay := launch_delay + travel_duration * progress * 0.70
		var size := Vector2(58 + intensity * 7, 58 + intensity * 6)
		var alpha := 0.46
		if clean_kind == "fire":
			size *= Vector2(1.04, 0.86)
			alpha = 0.54
		elif clean_kind == "earth":
			size *= Vector2(1.28, 0.72)
			alpha = 0.56
		elif clean_kind == "ice":
			size *= Vector2(0.92, 1.08)
			alpha = 0.44
		elif clean_kind == "heart":
			size *= Vector2(0.76, 1.08)
			alpha = 0.40
		_spawn_status_flipbook(_status_trail_key(clean_kind), point, size, travel_duration * 0.48, Color(1, 1, 1, alpha), delay, Vector2.ZERO, 0.58, 1.4, angle + sin(float(i)) * 0.18, 1)


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var offensive := clean_kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.38), layer_size.y * (0.42 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var sheet_key := _status_sheet_key(clean_kind)
	var wide_size := Vector2(layer_size.x * 0.78, layer_size.y * (0.32 if offensive else 0.42))
	_spawn_status_flipbook(sheet_key, focus, wide_size, lifetime * 1.04, Color(1, 1, 1, 0.46), 0.0, Vector2.ZERO, 1.06, -1.2, 0.0, 1)
	_spawn_light(focus, core, 3.2 + float(intensity) * 0.28, layer_size.x * 0.70, lifetime * 0.72)
	var burst_count := 4 + mini(6, intensity)
	for i in range(burst_count):
		var x := layer_size.x * (0.14 + float(i) / float(maxi(1, burst_count - 1)) * 0.72)
		var y := focus_y + sin(float(i) * 1.7) * layer_size.y * 0.052
		var delay := lifetime * (0.04 + float(i % 4) * 0.035)
		_spawn_status_flipbook(_status_trail_key(clean_kind), Vector2(x, y), wide_size * 0.22, lifetime * 0.62, Color(1, 1, 1, 0.42), delay, Vector2(sin(float(i)) * 28.0, -8.0), 0.76, 2.1, sin(float(i)) * 0.28, 1)
	if clean_kind == "gold":
		_spawn_coin_rain(focus, layer_size.x * 0.34, lifetime * 1.2, intensity, true)


func spawn_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	var duration := maxf(0.34, lifetime * 1.20)
	if clean_kind == "fire":
		_spawn_fire_beam_layers(source, delta, duration, intensity, angle)
		return
	if clean_kind == "ice":
		var ice_normal := Vector2(-delta.y, delta.x).normalized()
		var ice_travel_size := Vector2(150.0 + float(intensity) * 16.0, 116.0 + float(intensity) * 10.0)
		_spawn_windy_ice_block_travel_layers(source, source + delta, delta, ice_normal, ice_travel_size, duration, 0.0, intensity, angle)
		return
	if clean_kind == "earth":
		var earth_normal := Vector2(-delta.y, delta.x).normalized()
		var earth_travel_size := Vector2(152.0 + float(intensity) * 18.0, 110.0 + float(intensity) * 9.0)
		_spawn_earth_fracture_travel_layers(source, source + delta, delta, earth_normal, earth_travel_size, duration, 0.0, intensity, angle, _earth_vfx_tier(intensity))
		return
	_spawn_atmospheric_travel(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_spawn_beam_effect(source, delta, clean_kind, duration, intensity, 0.0, 0.72)
	spawn_path_afterimage(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_spawn_status_flipbook(_status_sheet_key(clean_kind), source, Vector2(112 + intensity * 9, 88 + intensity * 6), duration, Color(1, 1, 1, 0.58), 0.0, delta, 0.74, 2.2, angle, 1)


func spawn_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
	var clean_kind := _clean_kind(kind)
	var spool_duration := maxf(0.62, spool_lifetime * 1.46)
	var travel_duration := maxf(0.46, travel_lifetime * 1.34)
	var launch_delay := maxf(0.42, spool_duration * 0.80)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(128 + intensity * 16, 106 + intensity * 10)
	if clean_kind == "fire":
		_spawn_fire_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "ice":
		_spawn_ice_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "earth":
		_spawn_earth_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	_spawn_light(source, core, 2.1 + float(intensity) * 0.24, spool_size.x * 1.32, spool_duration * 1.08)
	_spawn_atmospheric_travel(clean_kind, source, delta, launch_delay, travel_duration, intensity, angle)
	match clean_kind:
		"heart":
			_spawn_status_flipbook("heal", source, spool_size * 0.48, spool_duration * 0.90, Color(0.82, 1.0, 0.76, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			spawn_path_afterimage("heart", source, delta, launch_delay, travel_duration * 1.16, intensity, angle)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_spawn_status_flipbook("regen", source + lane, travel_size * Vector2(0.34, 0.42), travel_duration * 1.02, Color(0.56, 1.0, 0.62, 0.38), launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.30, 0.78, 2.2, angle, 1)
			_spawn_status_flipbook("heal", target, spool_size * (0.50 + float(intensity) * 0.018), travel_duration * 1.10, Color(0.82, 1.0, 0.76, 0.62), launch_delay + travel_duration * 0.84, Vector2(0.0, -20.0), 1.08, 3.0, angle, 1)
		"armor":
			_spawn_status_flipbook("shield", source, spool_size * 0.48, spool_duration * 0.86, Color(0.84, 0.96, 1.0, 0.58), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_beam_effect(source, delta, "armor", travel_duration * 0.86, intensity, launch_delay, 0.74)
			_spawn_status_flipbook("shield", source, travel_size * Vector2(0.34, 0.38), travel_duration * 0.94, Color(0.66, 0.88, 1.0, 0.36), launch_delay, delta, 0.80, 2.2, angle, 1)
			_spawn_shield_scene(target, spool_size * (0.84 + float(intensity) * 0.035), travel_duration * 1.28, intensity, launch_delay + travel_duration * 0.82, Vector2.ZERO, 3.0)
			_spawn_status_flipbook("armor", target, spool_size * (0.40 + float(intensity) * 0.014), travel_duration * 0.94, Color(0.72, 0.90, 1.0, 0.42), launch_delay + travel_duration * 0.88, Vector2.ZERO, 1.04, 3.2, angle, 1)
		"gold":
			_spawn_status_flipbook("blessed", source, spool_size * 0.46, spool_duration * 0.86, Color(1.0, 0.90, 0.38, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1)
			_spawn_beam_effect(source, delta, "gold", travel_duration * 0.78, intensity, launch_delay, 0.70)
			_spawn_status_flipbook("haste", source, travel_size * Vector2(0.36, 0.34), travel_duration * 0.86, Color(1.0, 0.92, 0.32, 0.38), launch_delay, delta, 0.80, 2.2, angle, 1)
			_spawn_status_flipbook("blessed", target, spool_size * (0.44 + float(intensity) * 0.014), travel_duration * 0.90, Color(1.0, 0.86, 0.32, 0.58), launch_delay + travel_duration * 0.82, Vector2.ZERO, 1.08, 3.0, angle, 1)
			_spawn_coin_rain(target, spool_size.x, travel_duration * 1.28, intensity, false)
		_:
			_spawn_status_flipbook(_status_sheet_key(clean_kind), source, spool_size, spool_duration, Color(core.r, core.g, core.b, 0.88), 0.0, Vector2.ZERO, 1.12, 1.0, angle, 1)
			_spawn_status_flipbook(_status_sheet_key(clean_kind), source, travel_size, travel_duration, Color(accent.r, accent.g, accent.b, 0.72), launch_delay, delta, 0.86, 2.2, angle, 1)
			_spawn_status_flipbook(_status_sheet_key(clean_kind), target, spool_size, travel_duration * 1.14, Color(core.r, core.g, core.b, 0.90), launch_delay + travel_duration * 0.86, Vector2.ZERO, 1.12, 3.0, angle, 1)
	_spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.1), launch_delay + travel_duration * 0.90)


func _clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _status_sheet_key(kind: String) -> String:
	if _status_sheet_key_provider.is_valid():
		return String(_status_sheet_key_provider.call(kind))
	return kind


func _status_trail_key(kind: String) -> String:
	if _status_trail_key_provider.is_valid():
		return String(_status_trail_key_provider.call(kind))
	return kind


func _spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
	if _status_flipbook_spawner.is_valid():
		_status_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func _spawn_shield_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float) -> void:
	if _shield_scene_spawner.is_valid():
		_shield_scene_spawner.call(center_local, draw_size, lifetime, intensity, delay, move_offset, z)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, base_size, lifetime, intensity, screen_wide)


func _spawn_fire_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	if _fire_replay_layers_spawner.is_valid():
		_fire_replay_layers_spawner.call(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_ice_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	if _ice_replay_layers_spawner.is_valid():
		_ice_replay_layers_spawner.call(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_earth_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	if _earth_replay_layers_spawner.is_valid():
		_earth_replay_layers_spawner.call(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_fire_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	if _fire_cast_layers_spawner.is_valid():
		_fire_cast_layers_spawner.call(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_ice_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	if _ice_cast_layers_spawner.is_valid():
		_ice_cast_layers_spawner.call(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_earth_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	if _earth_cast_layers_spawner.is_valid():
		_earth_cast_layers_spawner.call(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	if _fire_beam_layers_spawner.is_valid():
		_fire_beam_layers_spawner.call(source, delta, duration, intensity, angle)


func _spawn_windy_ice_block_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, travel_size: Vector2, duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	if _windy_ice_block_travel_spawner.is_valid():
		_windy_ice_block_travel_spawner.call(source, target, delta, normal, travel_size, duration, launch_delay, intensity, angle)


func _spawn_earth_fracture_travel_layers(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, travel_size: Vector2, duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
	if _earth_fracture_travel_spawner.is_valid():
		_earth_fracture_travel_spawner.call(source, target, delta, normal, travel_size, duration, launch_delay, intensity, angle, tier)


func _earth_vfx_tier(intensity: int) -> int:
	if _earth_tier_provider.is_valid():
		return int(_earth_tier_provider.call(intensity))
	return 1


func _pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if _pack_impact_scene_key_provider.is_valid():
		return String(_pack_impact_scene_key_provider.call(kind, intensity, screen_wide))
	return "impact_01"


func _spawn_atmospheric_replay_layer(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if _atmospheric_replay_layer_spawner.is_valid():
		_atmospheric_replay_layer_spawner.call(kind, center, max_size, base_size, lifetime, intensity, screen_wide)


func _spawn_atmospheric_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if _atmospheric_travel_spawner.is_valid():
		_atmospheric_travel_spawner.call(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_beam_effect(source: Vector2, delta: Vector2, kind: String, duration: float, intensity: int, delay: float, radius_scale: float) -> void:
	if _beam_effect_spawner.is_valid():
		_beam_effect_spawner.call(source, delta, kind, duration, intensity, delay, radius_scale)


func _spawn_pack_layer(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func _spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	if _burst_particles_spawner.is_valid():
		_burst_particles_spawner.call(kind, center, base_size, lifetime, intensity)


func _spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(direction, delay)
