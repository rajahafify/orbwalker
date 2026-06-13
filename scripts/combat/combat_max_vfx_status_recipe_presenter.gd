extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxStatusRecipePresenter

const STATUS_RECIPE_CONTEXT_SCRIPT := preload("res://scripts/combat/combat_max_vfx_status_recipe_context.gd")

var _context = STATUS_RECIPE_CONTEXT_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_context.bind(dependencies)


func spawn_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var max_size := maxf(draw_size.x, draw_size.y)
	_context.spawn_armor_grid_snap(center, max_size * (1.0 + float(intensity) * 0.035), lifetime, intensity, 2.1)
	_context.spawn_light(center, Color(0.80, 0.94, 1.0, 1.0), 2.4 + float(intensity) * 0.22, max_size * 0.82, lifetime)


func supports_replay_impact(_kind: String, _screen_wide: bool = false) -> bool:
	return true


func spawn_replay_impact(
	center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	spawn_replay_recipe(kind, center, draw_size, max_size, base_size, duration, intensity, screen_wide)
	var colors := _context.kind_colors(_context.clean_kind(kind))
	var core: Color = colors.get("core", Color.WHITE)
	_context.spawn_light(center, core, 2.9 + float(intensity) * 0.38, base_size * 1.24, duration * 0.76)
	return true


func spawn_replay_recipe(
	kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	var clean_kind := _context.clean_kind(kind)
	if clean_kind == "fire":
		_context.spawn_replay_layers("fire", center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "ice":
		_context.spawn_replay_layers("ice", center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	if clean_kind == "earth":
		_context.spawn_replay_layers("earth", center, draw_size, max_size, base_size, duration, intensity, screen_wide)
		return
	var status_size := Vector2(base_size, base_size) * (1.36 if screen_wide else 0.86)
	var colors := _context.kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	_context.spawn_atmospheric_replay_layer(clean_kind, center, max_size, base_size, duration, intensity, screen_wide)
	match clean_kind:
		"heart":
			_context.spawn_status_flipbook(
				"heal",
				center,
				status_size * Vector2(0.38, 0.52),
				duration * 0.98,
				Color(0.84, 1.0, 0.80, 0.66),
				0.0,
				Vector2(0.0, -max_size * 0.24),
				1.06,
				1.9,
				0.0,
				1
			)
			_context.spawn_status_flipbook(
				"regen",
				center + Vector2(0.0, max_size * 0.12),
				status_size * 0.30,
				duration * 0.82,
				Color(0.48, 1.0, 0.60, 0.52),
				0.08,
				Vector2(0.0, -max_size * 0.30),
				0.92,
				2.2,
				0.08,
				1
			)
			_context.spawn_pack_layer(
				"hit_02", center + Vector2(0.0, -max_size * 0.05), "heart", status_size * 0.28, duration * 0.54, intensity, 0.16, 0.0, 2.6, 0.34
			)
		"armor":
			_context.spawn_armor_grid_snap(center, status_size.x * 0.82, duration, intensity, 2.1)
		"gold":
			_context.spawn_status_flipbook(
				"blessed", center, status_size * 0.42, duration * 0.86, Color(1.0, 0.86, 0.38, 0.62), 0.0, Vector2.ZERO, 1.10, 1.9, 0.0, 1
			)
			_context.spawn_status_flipbook(
				"haste",
				center + Vector2(0.0, -max_size * 0.08),
				status_size * 0.28,
				duration * 0.58,
				Color(1.0, 0.96, 0.44, 0.42),
				0.08,
				Vector2.ZERO,
				1.05,
				2.2,
				0.12,
				1
			)
			_context.spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
			_context.spawn_pack_layer("hit_01", center, "gold", status_size * 0.30, duration * 0.46, intensity, 0.12, 0.22, 2.5, 0.42)
		"damage":
			_context.spawn_status_flipbook(
				"bleed", center, status_size * 0.40, duration * 0.72, Color(1.0, 0.56, 0.48, 0.62), 0.0, Vector2.ZERO, 1.08, 1.9, -0.10, 1
			)
			_context.spawn_status_flipbook(
				"stun", center, status_size * 0.26, duration * 0.48, Color(1.0, 0.90, 0.42, 0.34), 0.08, Vector2.ZERO, 0.88, 2.2, 0.16, 1
			)
			_context.spawn_pack_layer(
				_context.pack_impact_scene_key("damage", intensity, screen_wide),
				center,
				"damage",
				status_size * 0.46,
				duration * 0.56,
				intensity,
				0.04,
				-0.08,
				2.5,
				0.54
			)
		_:
			_context.spawn_status_flipbook(
				_context.status_sheet_key(clean_kind),
				center,
				status_size * 0.42,
				duration,
				Color(core.r, core.g, core.b, 0.62),
				0.0,
				Vector2.ZERO,
				1.10,
				1.9,
				0.0,
				1
			)
	if screen_wide:
		spawn_screen_wide(clean_kind, center, duration, intensity)
	_context.spawn_burst_particles(clean_kind, center, max_size, duration * 0.74, intensity)
	_context.spawn_light(center, core, 2.6 + float(intensity) * 0.32, base_size * 1.05, duration * 0.64)


func spawn_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	var clean_kind := _context.clean_kind(kind)
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
		_context.spawn_status_flipbook(
			_context.status_trail_key(clean_kind),
			point,
			size,
			travel_duration * 0.48,
			Color(1, 1, 1, alpha),
			delay,
			Vector2.ZERO,
			0.58,
			1.4,
			angle + sin(float(i)) * 0.18,
			1
		)


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _context.vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var clean_kind := _context.clean_kind(kind)
	var offensive := clean_kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.38), layer_size.y * (0.42 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var colors := _context.kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	if clean_kind == "armor":
		_context.spawn_armor_grid_snap(focus, minf(layer_size.x, layer_size.y) * (0.32 + float(intensity) * 0.010), lifetime, intensity, 2.1)
		_context.spawn_light(focus, core, 3.0 + float(intensity) * 0.24, layer_size.x * 0.52, lifetime * 0.68)
		return
	var sheet_key := _context.status_sheet_key(clean_kind)
	var wide_size := Vector2(layer_size.x * 0.78, layer_size.y * (0.32 if offensive else 0.42))
	_context.spawn_status_flipbook(sheet_key, focus, wide_size, lifetime * 1.04, Color(1, 1, 1, 0.46), 0.0, Vector2.ZERO, 1.06, -1.2, 0.0, 1)
	_context.spawn_light(focus, core, 3.2 + float(intensity) * 0.28, layer_size.x * 0.70, lifetime * 0.72)
	var burst_count := 4 + mini(6, intensity)
	for i in range(burst_count):
		var x := layer_size.x * (0.14 + float(i) / float(maxi(1, burst_count - 1)) * 0.72)
		var y := focus_y + sin(float(i) * 1.7) * layer_size.y * 0.052
		var delay := lifetime * (0.04 + float(i % 4) * 0.035)
		_context.spawn_status_flipbook(
			_context.status_trail_key(clean_kind),
			Vector2(x, y),
			wide_size * 0.22,
			lifetime * 0.62,
			Color(1, 1, 1, 0.42),
			delay,
			Vector2(sin(float(i)) * 28.0, -8.0),
			0.76,
			2.1,
			sin(float(i)) * 0.28,
			1
		)
	if clean_kind == "gold":
		_context.spawn_coin_rain(focus, layer_size.x * 0.34, lifetime * 1.2, intensity, true)


func spawn_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	var clean_kind := _context.clean_kind(kind)
	var duration := maxf(0.34, lifetime * 1.20)
	if clean_kind == "fire":
		_context.spawn_fire_beam_layers(source, delta, duration, intensity, angle)
		return
	if clean_kind == "ice":
		var ice_normal := Vector2(-delta.y, delta.x).normalized()
		var ice_travel_size := Vector2(184.0 + float(intensity) * 20.0, 136.0 + float(intensity) * 12.0)
		_context.spawn_windy_ice_block_travel_layers(source, source + delta, delta, ice_normal, ice_travel_size, duration, 0.0, intensity, angle)
		return
	if clean_kind == "earth":
		var earth_normal := Vector2(-delta.y, delta.x).normalized()
		var earth_travel_size := Vector2(188.0 + float(intensity) * 22.0, 132.0 + float(intensity) * 12.0)
		_context.spawn_earth_fracture_travel_layers(
			source, source + delta, delta, earth_normal, earth_travel_size, duration, 0.0, intensity, angle, _context.earth_vfx_tier(intensity)
		)
		return
	_context.spawn_atmospheric_travel(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_context.spawn_beam_effect(source, delta, clean_kind, duration * 1.04, intensity, 0.0, 1.05)
	spawn_path_afterimage(clean_kind, source, delta, 0.0, duration, intensity, angle)
	_context.spawn_status_flipbook(
		_context.status_sheet_key(clean_kind),
		source,
		Vector2(146 + intensity * 13, 104 + intensity * 8),
		duration * 1.02,
		Color(1, 1, 1, 0.66),
		0.0,
		delta,
		0.84,
		2.2,
		angle,
		1
	)


func spawn_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color,
	accent: Color
) -> void:
	var clean_kind := _context.clean_kind(kind)
	var spool_duration := maxf(0.62, spool_lifetime * 1.46)
	var travel_duration := maxf(0.46, travel_lifetime * 1.34)
	var launch_delay := maxf(0.42, spool_duration * 0.80)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(128 + intensity * 16, 106 + intensity * 10)
	if clean_kind == "fire":
		_context.spawn_cast_layers("fire", source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "ice":
		_context.spawn_cast_layers("ice", source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	if clean_kind == "earth":
		_context.spawn_cast_layers("earth", source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)
		return
	_context.spawn_light(source, core, 2.1 + float(intensity) * 0.24, spool_size.x * 1.32, spool_duration * 1.08)
	_context.spawn_atmospheric_travel(clean_kind, source, delta, launch_delay, travel_duration, intensity, angle)
	match clean_kind:
		"heart":
			_context.spawn_status_flipbook(
				"heal", source, spool_size * 0.48, spool_duration * 0.90, Color(0.82, 1.0, 0.76, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1
			)
			spawn_path_afterimage("heart", source, delta, launch_delay, travel_duration * 1.16, intensity, angle)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_context.spawn_status_flipbook(
					"regen",
					source + lane,
					travel_size * Vector2(0.34, 0.42),
					travel_duration * 1.02,
					Color(0.56, 1.0, 0.62, 0.38),
					launch_delay + float(lane_index + 1) * 0.035,
					delta - lane * 0.30,
					0.78,
					2.2,
					angle,
					1
				)
			_context.spawn_status_flipbook(
				"heal",
				target,
				spool_size * (0.50 + float(intensity) * 0.018),
				travel_duration * 1.10,
				Color(0.82, 1.0, 0.76, 0.62),
				launch_delay + travel_duration * 0.84,
				Vector2(0.0, -20.0),
				1.08,
				3.0,
				angle,
				1
			)
		"armor":
			_context.spawn_status_flipbook(
				"armor", source, spool_size * 0.40, spool_duration * 0.76, Color(0.72, 0.90, 1.0, 0.46), 0.0, Vector2.ZERO, 1.02, 1.0, angle, 1
			)
			_context.spawn_beam_effect(source, delta, "armor", travel_duration * 0.86, intensity, launch_delay, 0.74)
			_context.spawn_status_flipbook(
				"armor",
				source,
				travel_size * Vector2(0.30, 0.34),
				travel_duration * 0.86,
				Color(0.66, 0.88, 1.0, 0.34),
				launch_delay,
				delta,
				0.80,
				2.2,
				angle,
				1
			)
			_context.spawn_armor_grid_snap(
				target, spool_size.x * (0.84 + float(intensity) * 0.035), travel_duration * 1.10, intensity, 3.0, launch_delay + travel_duration * 0.82
			)
		"gold":
			_context.spawn_status_flipbook(
				"blessed", source, spool_size * 0.46, spool_duration * 0.86, Color(1.0, 0.90, 0.38, 0.60), 0.0, Vector2.ZERO, 1.06, 1.0, angle, 1
			)
			_context.spawn_beam_effect(source, delta, "gold", travel_duration * 0.78, intensity, launch_delay, 0.70)
			_context.spawn_status_flipbook(
				"haste",
				source,
				travel_size * Vector2(0.36, 0.34),
				travel_duration * 0.86,
				Color(1.0, 0.92, 0.32, 0.38),
				launch_delay,
				delta,
				0.80,
				2.2,
				angle,
				1
			)
			_context.spawn_status_flipbook(
				"blessed",
				target,
				spool_size * (0.44 + float(intensity) * 0.014),
				travel_duration * 0.90,
				Color(1.0, 0.86, 0.32, 0.58),
				launch_delay + travel_duration * 0.82,
				Vector2.ZERO,
				1.08,
				3.0,
				angle,
				1
			)
			_context.spawn_coin_rain(target, spool_size.x, travel_duration * 1.28, intensity, false)
		_:
			_context.spawn_status_flipbook(
				_context.status_sheet_key(clean_kind),
				source,
				spool_size,
				spool_duration,
				Color(core.r, core.g, core.b, 0.88),
				0.0,
				Vector2.ZERO,
				1.12,
				1.0,
				angle,
				1
			)
			_context.spawn_status_flipbook(
				_context.status_sheet_key(clean_kind),
				source,
				travel_size,
				travel_duration,
				Color(accent.r, accent.g, accent.b, 0.72),
				launch_delay,
				delta,
				0.86,
				2.2,
				angle,
				1
			)
			_context.spawn_status_flipbook(
				_context.status_sheet_key(clean_kind),
				target,
				spool_size,
				travel_duration * 1.14,
				Color(core.r, core.g, core.b, 0.90),
				launch_delay + travel_duration * 0.86,
				Vector2.ZERO,
				1.12,
				3.0,
				angle,
				1
			)
	_context.spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.1), launch_delay + travel_duration * 0.90)
