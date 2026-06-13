extends RefCounted
class_name CombatMaxVfxStatusRecipeContext

var _kind_cleaner: Callable
var _layer_size_provider: Callable
var _kind_colors_provider: Callable
var _status_sheet_key_provider: Callable
var _status_trail_key_provider: Callable
var _status_flipbook_spawner: Callable
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


func clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func spawn_armor_grid_snap(center: Vector2, max_size: float, lifetime: float, intensity: int, z: float, delay: float = 0.0) -> void:
	var shell_size := maxf(92.0, max_size)
	spawn_status_flipbook(
		"armor",
		center,
		Vector2(shell_size * 0.92, shell_size * 0.92),
		lifetime * 0.82,
		Color(0.38, 0.78, 1.0, 0.18),
		delay,
		Vector2.ZERO,
		1.10,
		z - 0.2,
		0.0,
		1
	)
	var cell_size := maxf(26.0, shell_size * (0.17 + float(intensity) * 0.004))
	var gap := cell_size * 0.92
	var start := Vector2(-gap, -gap)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.24 if row % 2 == 1 else 0.0), float(row) * gap)
			var distance: int = absi(row - 1) + absi(column - 1)
			var cell_delay := delay + lifetime * (0.03 + float(distance) * 0.035 + float(index % 2) * 0.012)
			var alpha := 0.52 if distance == 0 else 0.38
			spawn_status_flipbook(
				"armor",
				center + offset,
				Vector2(cell_size, cell_size * 1.10),
				lifetime * 0.62,
				Color(0.70, 0.92, 1.0, alpha),
				cell_delay,
				Vector2.ZERO,
				1.08,
				z + 0.5,
				PI / 6.0,
				1
			)
	var bar_length := shell_size * (0.60 + float(intensity) * 0.01)
	var bar_thickness := maxf(8.0, shell_size * 0.035)
	var half := shell_size * 0.50
	var specs := [
		{"offset": Vector2(0.0, -half), "rotation": 0.0, "move": Vector2(0.0, shell_size * 0.08)},
		{"offset": Vector2(0.0, half), "rotation": 0.0, "move": Vector2(0.0, -shell_size * 0.08)},
		{"offset": Vector2(-half, 0.0), "rotation": PI * 0.5, "move": Vector2(shell_size * 0.08, 0.0)},
		{"offset": Vector2(half, 0.0), "rotation": PI * 0.5, "move": Vector2(-shell_size * 0.08, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		spawn_status_flipbook(
			"armor",
			center + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			lifetime * 0.44,
			Color(0.88, 0.98, 1.0, 0.78),
			delay + lifetime * (0.04 + float(i) * 0.022),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.72,
			z + 0.7,
			float(spec.get("rotation", 0.0)),
			1
		)


func kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func status_sheet_key(kind: String) -> String:
	if _status_sheet_key_provider.is_valid():
		return String(_status_sheet_key_provider.call(kind))
	return kind


func status_trail_key(kind: String) -> String:
	if _status_trail_key_provider.is_valid():
		return String(_status_trail_key_provider.call(kind))
	return kind


func spawn_status_flipbook(
	sheet_key: String,
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	color: Color,
	delay: float,
	move_offset: Vector2,
	target_scale: float,
	z: float,
	rotation: float,
	loops: int
) -> void:
	if _status_flipbook_spawner.is_valid():
		_status_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, base_size, lifetime, intensity, screen_wide)


func spawn_replay_layers(
	kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	var spawner := (
		{"fire": _fire_replay_layers_spawner, "ice": _ice_replay_layers_spawner, "earth": _earth_replay_layers_spawner}.get(kind, Callable()) as Callable
	)
	if spawner.is_valid():
		spawner.call(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_cast_layers(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	var spawner := {"fire": _fire_cast_layers_spawner, "ice": _ice_cast_layers_spawner, "earth": _earth_cast_layers_spawner}.get(kind, Callable()) as Callable
	if spawner.is_valid():
		spawner.call(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	if _fire_beam_layers_spawner.is_valid():
		_fire_beam_layers_spawner.call(source, delta, duration, intensity, angle)


func spawn_windy_ice_block_travel_layers(
	source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, travel_size: Vector2, duration: float, launch_delay: float, intensity: int, angle: float
) -> void:
	if _windy_ice_block_travel_spawner.is_valid():
		_windy_ice_block_travel_spawner.call(source, target, delta, normal, travel_size, duration, launch_delay, intensity, angle)


func spawn_earth_fracture_travel_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	normal: Vector2,
	travel_size: Vector2,
	duration: float,
	launch_delay: float,
	intensity: int,
	angle: float,
	tier: int
) -> void:
	if _earth_fracture_travel_spawner.is_valid():
		_earth_fracture_travel_spawner.call(source, target, delta, normal, travel_size, duration, launch_delay, intensity, angle, tier)


func earth_vfx_tier(intensity: int) -> int:
	if _earth_tier_provider.is_valid():
		return int(_earth_tier_provider.call(intensity))
	return 1


func pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if _pack_impact_scene_key_provider.is_valid():
		return String(_pack_impact_scene_key_provider.call(kind, intensity, screen_wide))
	return "impact_01"


func spawn_atmospheric_replay_layer(
	kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool
) -> void:
	if _atmospheric_replay_layer_spawner.is_valid():
		_atmospheric_replay_layer_spawner.call(kind, center, max_size, base_size, lifetime, intensity, screen_wide)


func spawn_atmospheric_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if _atmospheric_travel_spawner.is_valid():
		_atmospheric_travel_spawner.call(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func spawn_beam_effect(source: Vector2, delta: Vector2, kind: String, duration: float, intensity: int, delay: float, radius_scale: float) -> void:
	if _beam_effect_spawner.is_valid():
		_beam_effect_spawner.call(source, delta, kind, duration, intensity, delay, radius_scale)


func spawn_pack_layer(
	scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float
) -> void:
	if _pack_layer_spawner.is_valid():
		_pack_layer_spawner.call(scene_key, center, kind, draw_size, lifetime, intensity, delay, rotation, z, alpha)


func spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	if _burst_particles_spawner.is_valid():
		_burst_particles_spawner.call(kind, center, base_size, lifetime, intensity)


func spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera_kick_spawner.is_valid():
		_camera_kick_spawner.call(direction, delay)
