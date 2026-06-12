extends RefCounted
class_name CombatMaxVfxReplayFallbackPresenter

var _kind_colors: Callable
var _impact_key: Callable
var _mist_key: Callable
var _light_spawner: Callable
var _flipbook_spawner: Callable
var _burst_particles_spawner: Callable
var _screen_wide_spawner: Callable
var _coin_rain_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_colors = dependencies.get("kind_colors", Callable())
	_impact_key = dependencies.get("impact_key", Callable())
	_mist_key = dependencies.get("mist_key", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_burst_particles_spawner = dependencies.get("burst_particles_spawner", Callable())
	_screen_wide_spawner = dependencies.get("screen_wide_spawner", Callable())
	_coin_rain_spawner = dependencies.get("coin_rain_spawner", Callable())


func spawn_armor_replay_fallback(
	center: Vector2, kind: String, _draw_size: Vector2, _max_size: float, base_size: float, duration: float, intensity: int, _screen_wide: bool
) -> bool:
	if not _flipbook_spawner.is_valid() or not _light_spawner.is_valid():
		return false
	var core: Color = _colors_for(kind).get("core", Color.WHITE)
	_spawn_armor_grid_snap(center, base_size * 0.74, duration, intensity)
	_light_spawner.call(center, core, 2.5 + float(intensity) * 0.30, base_size * 1.10, duration * 0.72)
	return true


func spawn_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> bool:
	if not _flipbook_spawner.is_valid() or not _light_spawner.is_valid():
		return false
	var max_size := maxf(draw_size.x, draw_size.y)
	_spawn_armor_grid_snap(center, max_size * 0.82, lifetime, intensity)
	_light_spawner.call(center, Color(0.78, 0.92, 1.0, 1.0), 2.1 + float(intensity) * 0.24, max_size * 0.78, lifetime)
	return true


func spawn_lightweight_replay_fallback(
	center: Vector2, kind: String, _draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	if not _light_spawner.is_valid() or not _flipbook_spawner.is_valid():
		return false
	var colors := _colors_for(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	_light_spawner.call(center, core, 2.4 + float(intensity) * 0.34, base_size * 1.15, duration * 0.65)
	_flipbook_spawner.call(
		_key_for(_impact_key, kind, "orb_clear"),
		center,
		Vector2(base_size, base_size),
		duration,
		Color(1, 1, 1, 0.95),
		0.0,
		Vector2.ZERO,
		1.12 + float(intensity) * 0.04,
		0.0,
		0.18
	)
	_flipbook_spawner.call(
		"shockwave_ring",
		center,
		Vector2(base_size * 0.92, base_size * 0.92),
		duration * 0.78,
		Color(core.r, core.g, core.b, 0.82),
		0.03,
		Vector2.ZERO,
		1.52 + float(intensity) * 0.07,
		-0.8,
		0.0
	)
	_flipbook_spawner.call(
		_key_for(_mist_key, kind, "smoke_puff"),
		center + Vector2(0.0, max_size * 0.08),
		Vector2(base_size * 1.10, base_size * 0.78),
		duration * 1.08,
		Color(accent.r, accent.g, accent.b, 0.36),
		0.04,
		Vector2(0.0, -max_size * 0.10),
		1.18,
		-1.2,
		0.08
	)
	if _burst_particles_spawner.is_valid():
		_burst_particles_spawner.call(kind, center, max_size, duration, intensity)
	if screen_wide and _screen_wide_spawner.is_valid():
		_screen_wide_spawner.call(kind, center, duration, intensity)
	if kind == "gold" and _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, max_size, duration, intensity, false)
	return true


func _colors_for(kind: String) -> Dictionary:
	if _kind_colors.is_valid():
		return _kind_colors.call(kind)
	return {"accent": Color.WHITE, "core": Color.WHITE}


func _key_for(provider: Callable, kind: String, fallback: String) -> String:
	if provider.is_valid():
		return String(provider.call(kind))
	return fallback


func _spawn_armor_grid_snap(center: Vector2, max_size: float, lifetime: float, intensity: int) -> void:
	var shell_size := maxf(96.0, max_size)
	_flipbook_spawner.call(
		"armor_impact", center, Vector2(shell_size * 0.96, shell_size * 0.96), lifetime * 0.78, Color(0.36, 0.76, 1.0, 0.20), 0.0, Vector2.ZERO, 1.10, 0.8, 0.0
	)
	var cell_size := maxf(28.0, shell_size * (0.17 + float(intensity) * 0.004))
	var gap := cell_size * 0.92
	var start := Vector2(-gap, -gap)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.24 if row % 2 == 1 else 0.0), float(row) * gap)
			var distance: int = absi(row - 1) + absi(column - 1)
			var delay := lifetime * (0.03 + float(distance) * 0.035 + float(index % 2) * 0.012)
			var alpha := 0.52 if distance == 0 else 0.38
			_flipbook_spawner.call(
				"armor_impact",
				center + offset,
				Vector2(cell_size, cell_size * 1.10),
				lifetime * 0.62,
				Color(0.70, 0.92, 1.0, alpha),
				delay,
				Vector2.ZERO,
				1.08,
				2.2,
				PI / 6.0
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
		_flipbook_spawner.call(
			"light_rays",
			center + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			lifetime * 0.44,
			Color(0.88, 0.98, 1.0, 0.78),
			lifetime * (0.04 + float(i) * 0.022),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.72,
			2.8,
			float(spec.get("rotation", 0.0))
		)
