extends RefCounted
class_name CombatMaxVfxElementalRecipePresenter

var _kind_cleaner: Callable
var _layer_size_provider: Callable
var _elemental_effect_spawner: Callable
var _effect_stretcher: Callable
var _pack_impact_scene_key_provider: Callable
var _pack_layer_spawner: Callable
var _coin_rain_spawner: Callable
var _light_spawner: Callable
var _camera_kick_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_cleaner = dependencies.get("kind_cleaner", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_elemental_effect_spawner = dependencies.get("elemental_effect_spawner", Callable())
	_effect_stretcher = dependencies.get("effect_stretcher", Callable())
	_pack_impact_scene_key_provider = dependencies.get("pack_impact_scene_key_provider", Callable())
	_pack_layer_spawner = dependencies.get("pack_layer_spawner", Callable())
	_coin_rain_spawner = dependencies.get("coin_rain_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_camera_kick_spawner = dependencies.get("camera_kick_spawner", Callable())


func spawn_replay_recipe(kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	var clean_kind := _clean_kind(kind)
	var area_size := Vector2(base_size, base_size) * (1.35 if screen_wide else 0.86)
	match clean_kind:
		"fire":
			_spawn_elemental_effect("area", center, "fire", area_size * 1.10, duration * 1.32, intensity, 0.0, Vector2.ZERO, 0.0, 0.45, 0.96)
			_spawn_elemental_effect("projectile", center + Vector2(-max_size * 0.62, max_size * 0.16), "fire", Vector2(base_size * 0.88, base_size * 0.36), duration * 0.54, intensity, 0.02, Vector2(max_size * 1.18, -max_size * 0.18), -0.12, 1.8, 0.76)
			_spawn_elemental_effect("cast", center + Vector2(0.0, -max_size * 0.22), "fire", area_size * 0.56, duration * 0.82, intensity, 0.06, Vector2.ZERO, 0.0, 1.4, 0.72)
			_spawn_pack_layer(_pack_impact_scene_key("fire", intensity, screen_wide), center, "fire", area_size * 0.52, duration * 0.58, intensity, 0.05, 0.10, 2.0, 0.62)
			_spawn_pack_layer("hit_01", center + Vector2(max_size * 0.12, -max_size * 0.08), "fire", area_size * 0.32, duration * 0.44, intensity, 0.14, -0.35, 2.4, 0.58)
		"ice":
			_spawn_elemental_effect("area", center, "ice", area_size * 0.92, duration * 1.48, intensity, 0.0, Vector2.ZERO, 0.0, 0.40, 0.86)
			_spawn_elemental_effect("projectile", center + Vector2(-max_size * 0.58, -max_size * 0.12), "ice", Vector2(base_size * 0.74, base_size * 0.28), duration * 0.70, intensity, 0.04, Vector2(max_size * 1.08, max_size * 0.08), -0.04, 1.7, 0.60)
			_spawn_elemental_effect("projectile", center + Vector2(max_size * 0.46, max_size * 0.10), "ice", Vector2(base_size * 0.48, base_size * 0.22), duration * 0.62, intensity, 0.13, Vector2(-max_size * 0.52, -max_size * 0.04), PI - 0.10, 1.6, 0.42)
			_spawn_elemental_effect("cast", center + Vector2(0.0, max_size * 0.08), "ice", area_size * 0.34, duration * 0.92, intensity, 0.10, Vector2(0.0, max_size * 0.14), 0.0, 1.2, 0.52)
			_spawn_pack_layer("impact_02", center, "ice", area_size * 0.48, duration * 0.74, intensity, 0.10, 0.0, 2.1, 0.50)
			_spawn_pack_layer("hit_02", center + Vector2(-max_size * 0.10, -max_size * 0.10), "ice", area_size * 0.28, duration * 0.50, intensity, 0.20, 0.45, 2.5, 0.42)
		"earth":
			var ground_effect := _spawn_elemental_effect("area", center + Vector2(0.0, max_size * 0.16), "earth", area_size * 0.92, duration * 1.50, intensity, 0.0, Vector2.ZERO, 0.0, 0.28, 0.82)
			_stretch_effect(ground_effect, Vector3(1.55, 0.52, 1.0))
			for i in range(5 + mini(5, intensity)):
				var progress := float(i) / float(maxi(1, 4 + mini(5, intensity)))
				var offset := Vector2((progress - 0.5) * max_size * 1.8, max_size * (0.42 - progress * 0.32))
				var crack := _spawn_elemental_effect("area", center + offset, "earth", area_size * Vector2(0.20, 0.16), duration * 0.52, intensity, duration * (0.04 + progress * 0.18), Vector2.ZERO, sin(float(i)) * 0.42, 1.1, 0.54)
				_stretch_effect(crack, Vector3(1.80, 0.38, 1.0))
			_spawn_pack_layer("impact_01", center + Vector2(0.0, max_size * 0.10), "earth", area_size * 0.44, duration * 0.72, intensity, 0.16, 0.0, 2.0, 0.44)
		"heart":
			_spawn_elemental_effect("area", center, "heart", area_size * Vector2(0.78, 1.10), duration * 1.44, intensity, 0.0, Vector2(0.0, -max_size * 0.16), 0.0, 0.45, 0.76)
			for i in range(4 + mini(4, intensity)):
				var x := (float(i) - 1.5) * max_size * 0.18
				_spawn_elemental_effect("cast", center + Vector2(x, max_size * 0.28), "heart", area_size * 0.22, duration * 0.86, intensity, duration * (0.03 + float(i) * 0.035), Vector2(0.0, -max_size * (0.42 + float(i % 2) * 0.12)), 0.0, 1.5, 0.52)
			_spawn_pack_layer("hit_02", center + Vector2(0.0, -max_size * 0.06), "heart", area_size * 0.30, duration * 0.58, intensity, 0.18, 0.0, 2.3, 0.36)
		"armor":
			var shell := _spawn_elemental_effect("area", center, "armor", area_size * Vector2(1.06, 0.86), duration * 1.52, intensity, 0.0, Vector2.ZERO, 0.0, 0.55, 0.78)
			_stretch_effect(shell, Vector3(1.25, 0.74, 1.0))
			_spawn_elemental_effect("cast", center + Vector2(0.0, -max_size * 0.12), "armor", area_size * 0.38, duration * 0.82, intensity, 0.08, Vector2.ZERO, 0.0, 1.5, 0.54)
			_spawn_pack_layer("impact_02", center, "armor", area_size * 0.48, duration * 0.64, intensity, 0.10, 0.0, 2.1, 0.46)
		"gold":
			_spawn_elemental_effect("area", center, "gold", area_size * 0.92, duration * 1.24, intensity, 0.0, Vector2.ZERO, 0.0, 0.42, 0.78)
			for i in range(4 + mini(5, intensity)):
				var offset := Vector2(sin(float(i) * 1.7) * max_size * 0.44, -max_size * (0.28 + float(i % 3) * 0.14))
				_spawn_elemental_effect("cast", center + offset, "gold", area_size * 0.20, duration * 0.74, intensity, duration * (0.03 + float(i) * 0.035), Vector2(sin(float(i)) * max_size * 0.18, max_size * 0.30), 0.0, 1.6, 0.58)
			_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
			_spawn_pack_layer("hit_01", center, "gold", area_size * 0.34, duration * 0.50, intensity, 0.12, 0.22, 2.2, 0.48)
		_:
			_spawn_elemental_effect("area", center, kind, area_size, duration * 1.30, intensity, 0.0, Vector2.ZERO, 0.0, 0.45, 0.92)
	if screen_wide:
		spawn_screen_wide(kind, center, duration, intensity)


func spawn_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
	var clean_kind := _clean_kind(kind)
	var spool_duration := maxf(0.48, spool_lifetime * 1.30)
	var travel_duration := maxf(0.38, travel_lifetime * 1.24)
	var launch_delay := maxf(0.34, spool_duration * 0.84)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(164 + intensity * 22, 92 + intensity * 10)
	_spawn_light(source, core, 2.0 + float(intensity) * 0.22, spool_size.x * 1.25, spool_duration * 1.05)
	match clean_kind:
		"fire":
			_spawn_elemental_effect("cast", source, "fire", spool_size * 1.10, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.94)
			spawn_path_afterimage("fire", source, delta, launch_delay, travel_duration, intensity, angle)
			_spawn_elemental_effect("projectile", source, "fire", travel_size * Vector2(1.12, 0.95), travel_duration, intensity, launch_delay, delta, angle - PI, 1.5, 0.96)
			_spawn_pack_layer("hit_01", source + delta * 0.44, "fire", spool_size * 0.42, travel_duration * 0.48, intensity, launch_delay + travel_duration * 0.34, angle, 2.1, 0.42)
			_spawn_elemental_effect("area", target, "fire", spool_size * (1.22 + float(intensity) * 0.05), travel_duration * 1.42, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.98)
			_spawn_pack_layer("big_impact_01" if intensity >= 6 else "impact_01", target, "fire", spool_size * 0.56, travel_duration * 0.60, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.60)
		"ice":
			_spawn_elemental_effect("cast", source, "ice", spool_size * 0.86, spool_duration * 1.15, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.82)
			for lane_index in [-1, 1]:
				var lane := normal * float(lane_index) * (12.0 + float(intensity) * 1.8)
				_spawn_elemental_effect("projectile", source + lane, "ice", travel_size * Vector2(0.82, 0.58), travel_duration * 1.12, intensity, launch_delay + (0.05 if lane_index > 0 else 0.0), delta - lane * 0.35, angle - PI + float(lane_index) * 0.08, 1.5, 0.72)
			spawn_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.10, intensity, angle)
			_spawn_elemental_effect("area", target, "ice", spool_size * (0.98 + float(intensity) * 0.04), travel_duration * 1.58, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.82)
			_spawn_pack_layer("impact_02", target, "ice", spool_size * 0.46, travel_duration * 0.72, intensity, launch_delay + travel_duration * 0.94, angle, 2.4, 0.48)
		"earth":
			var source_rumble := _spawn_elemental_effect("area", source + Vector2(0.0, 18.0), "earth", spool_size * Vector2(1.18, 0.70), spool_duration * 1.10, intensity, 0.0, Vector2.ZERO, angle, 0.4, 0.78)
			_stretch_effect(source_rumble, Vector3(1.45, 0.48, 1.0))
			spawn_path_afterimage("earth", source, delta, launch_delay * 0.84, travel_duration * 1.24, intensity + 1, angle)
			var crawl := _spawn_elemental_effect("projectile", source, "earth", travel_size * Vector2(0.72, 0.52), travel_duration * 1.28, intensity, launch_delay, delta, angle - PI, 1.2, 0.46)
			_stretch_effect(crawl, Vector3(1.15, 0.58, 1.0))
			var impact := _spawn_elemental_effect("area", target + Vector2(0.0, 12.0), "earth", spool_size * (1.10 + float(intensity) * 0.05), travel_duration * 1.52, intensity, launch_delay + travel_duration * 0.94, Vector2.ZERO, angle, 1.9, 0.86)
			_stretch_effect(impact, Vector3(1.34, 0.56, 1.0))
			_spawn_pack_layer("impact_01", target, "earth", spool_size * 0.46, travel_duration * 0.62, intensity, launch_delay + travel_duration * 0.98, angle, 2.4, 0.44)
		"heart":
			_spawn_elemental_effect("cast", source, "heart", spool_size * 0.90, spool_duration * 1.04, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.74)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_spawn_elemental_effect("projectile", source + lane, "heart", travel_size * Vector2(0.58, 0.70), travel_duration * 1.20, intensity, launch_delay + float(lane_index + 1) * 0.035, delta - lane * 0.30, angle - PI, 1.5, 0.58)
			_spawn_elemental_effect("area", target, "heart", spool_size * (0.92 + float(intensity) * 0.04), travel_duration * 1.64, intensity, launch_delay + travel_duration * 0.88, Vector2(0.0, -18.0), angle, 1.9, 0.76)
		"armor":
			_spawn_elemental_effect("cast", source, "armor", spool_size * 0.92, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.76)
			_spawn_elemental_effect("projectile", source, "armor", travel_size * Vector2(0.74, 0.78), travel_duration * 1.10, intensity, launch_delay, delta, angle - PI, 1.5, 0.62)
			var shell := _spawn_elemental_effect("area", target, "armor", spool_size * (1.04 + float(intensity) * 0.04), travel_duration * 1.68, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.78)
			_stretch_effect(shell, Vector3(1.22, 0.78, 1.0))
			_spawn_pack_layer("impact_02", target, "armor", spool_size * 0.44, travel_duration * 0.58, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.46)
		"gold":
			_spawn_elemental_effect("cast", source, "gold", spool_size * 0.90, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.78)
			_spawn_elemental_effect("projectile", source, "gold", travel_size * Vector2(0.68, 0.62), travel_duration * 1.04, intensity, launch_delay, delta, angle - PI, 1.5, 0.62)
			_spawn_elemental_effect("area", target, "gold", spool_size * (0.94 + float(intensity) * 0.04), travel_duration * 1.28, intensity, launch_delay + travel_duration * 0.86, Vector2.ZERO, angle, 1.9, 0.74)
			_spawn_coin_rain(target, spool_size.x, travel_duration * 1.4, intensity, false)
			_spawn_pack_layer("hit_01", target, "gold", spool_size * 0.42, travel_duration * 0.50, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.48)
		_:
			_spawn_elemental_effect("cast", source, kind, spool_size * 1.04, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.92)
			_spawn_elemental_effect("projectile", source, kind, travel_size, travel_duration, intensity, launch_delay, delta, angle - PI, 1.4, 0.94)
			_spawn_elemental_effect("area", target, kind, spool_size * (1.16 + float(intensity) * 0.05), travel_duration * 1.42, intensity, launch_delay + travel_duration * 0.88, Vector2.ZERO, angle, 1.9, 0.96)
	_spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.2), launch_delay + travel_duration * 0.90)


func spawn_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	var count := 3 + mini(5, int(floor(float(intensity) * 0.65)))
	for i in range(count):
		var progress := (float(i) + 0.35) / float(count + 1)
		var lane := Vector2(-delta.y, delta.x).normalized() * sin(float(i) * 1.7) * (8.0 + float(intensity) * 1.8)
		var point := source + delta * progress + lane
		var delay := launch_delay + travel_duration * progress * 0.68
		var size := Vector2(58 + intensity * 8, 58 + intensity * 6)
		var alpha := 0.34
		if clean_kind == "earth":
			size *= Vector2(1.28, 0.72)
			alpha = 0.48
		elif clean_kind == "ice":
			size *= Vector2(0.90, 1.08)
			alpha = 0.38
		_spawn_elemental_effect("area", point, clean_kind, size, travel_duration * 0.44, intensity, delay, Vector2.ZERO, angle, 0.2, alpha)


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var offensive := clean_kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.42 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 0.92, layer_size.y * (0.34 if offensive else 0.42))
	_spawn_elemental_effect("area", focus, clean_kind, size, lifetime * 1.36, intensity, 0.0, Vector2.ZERO, 0.0, -0.8, 0.64)
	var bursts := 3 + mini(4, int(floor(float(intensity) * 0.45)))
	for i in range(bursts):
		var x := layer_size.x * (0.18 + float(i) / float(maxi(1, bursts - 1)) * 0.64)
		var y := focus_y + sin(float(i) * 1.9) * layer_size.y * 0.055
		var delay := lifetime * (0.06 + float(i % 4) * 0.045)
		_spawn_elemental_effect("cast", Vector2(x, y), clean_kind, size * 0.22, lifetime * 0.74, intensity, delay, Vector2.ZERO, sin(float(i)) * 0.28, 1.4, 0.42)


func spawn_beam_layers(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	var clean_kind := _clean_kind(kind)
	match clean_kind:
		"ice":
			var normal := Vector2(-delta.y, delta.x).normalized()
			_spawn_elemental_effect("projectile", source + normal * 9.0, "ice", Vector2(142 + intensity * 10, 56 + intensity * 5), lifetime * 1.22, intensity, 0.0, delta - normal * 6.0, angle - PI + 0.06, 1.4, 0.62)
			_spawn_elemental_effect("projectile", source - normal * 9.0, "ice", Vector2(112 + intensity * 8, 46 + intensity * 4), lifetime * 1.14, intensity, 0.05, delta + normal * 6.0, angle - PI - 0.06, 1.3, 0.44)
		"earth":
			spawn_path_afterimage("earth", source, delta, 0.0, lifetime * 1.22, intensity, angle)
			var crawl := _spawn_elemental_effect("projectile", source, "earth", Vector2(118 + intensity * 10, 48 + intensity * 4), lifetime * 1.24, intensity, 0.0, delta, angle - PI, 1.2, 0.48)
			_stretch_effect(crawl, Vector3(1.20, 0.52, 1.0))
		"heart":
			_spawn_elemental_effect("projectile", source, "heart", Vector2(112 + intensity * 8, 70 + intensity * 5), lifetime * 1.20, intensity, 0.0, delta, angle - PI, 1.4, 0.54)
		"armor":
			_spawn_elemental_effect("projectile", source, "armor", Vector2(118 + intensity * 8, 76 + intensity * 6), lifetime * 1.18, intensity, 0.0, delta, angle - PI, 1.4, 0.58)
		"gold":
			_spawn_elemental_effect("projectile", source, "gold", Vector2(118 + intensity * 8, 64 + intensity * 5), lifetime * 1.10, intensity, 0.0, delta, angle - PI, 1.4, 0.58)
		_:
			_spawn_elemental_effect("projectile", source, clean_kind, Vector2(156 + intensity * 14, 84 + intensity * 7), lifetime * 1.18, intensity, 0.0, delta, angle - PI, 1.4, 0.82)


func _clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_elemental_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> Node3D:
	if _elemental_effect_spawner.is_valid():
		return _elemental_effect_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)
	return null


func _stretch_effect(effect: Node3D, stretch: Vector3) -> void:
	if effect != null and _effect_stretcher.is_valid():
		_effect_stretcher.call(effect, stretch)


func _pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if _pack_impact_scene_key_provider.is_valid():
		return String(_pack_impact_scene_key_provider.call(kind, intensity, screen_wide))
	return "impact_01"


func _spawn_pack_layer(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func _spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, base_size, lifetime, intensity, screen_wide)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(direction, delay)
