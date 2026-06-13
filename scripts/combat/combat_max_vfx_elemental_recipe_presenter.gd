extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxElementalRecipePresenter

const ELEMENTAL_RECIPE_CONTEXT_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_context.gd")

var _context = ELEMENTAL_RECIPE_CONTEXT_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_context.bind(dependencies)


func supports_replay_impact(kind: String, _screen_wide: bool = false) -> bool:
	match _context.clean_kind(kind):
		"fire", "ice", "earth", "heart", "armor", "gold", "damage":
			return true
	return false


func spawn_replay_impact(
	center: Vector2, kind: String, _draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	var clean_kind := _context.clean_kind(kind)
	spawn_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)
	var colors := _context.kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	_context.spawn_light(center, core, 2.7 + float(intensity) * 0.34, base_size * 1.20, duration * 0.78)
	return true


func spawn_replay_recipe(kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_context.spawn_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)


func spawn_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color
) -> void:
	var clean_kind := _context.clean_kind(kind)
	var spool_duration := maxf(0.48, spool_lifetime * 1.30)
	var travel_duration := maxf(0.38, travel_lifetime * 1.24)
	var launch_delay := maxf(0.34, spool_duration * 0.84)
	var angle := delta.angle()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var travel_size := Vector2(164 + intensity * 22, 92 + intensity * 10)
	_context.spawn_light(source, core, 2.0 + float(intensity) * 0.22, spool_size.x * 1.25, spool_duration * 1.05)
	match clean_kind:
		"fire":
			_context.spawn_elemental_effect("cast", source, "fire", spool_size * 1.10, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.94)
			_context.spawn_path_afterimage("fire", source, delta, launch_delay, travel_duration, intensity, angle)
			_context.spawn_elemental_effect(
				"projectile", source, "fire", travel_size * Vector2(1.12, 0.95), travel_duration, intensity, launch_delay, delta, angle - PI, 1.5, 0.96
			)
			_context.spawn_pack_layer(
				"hit_01",
				source + delta * 0.44,
				"fire",
				spool_size * 0.42,
				travel_duration * 0.48,
				intensity,
				launch_delay + travel_duration * 0.34,
				angle,
				2.1,
				0.42
			)
			_context.spawn_elemental_effect(
				"area",
				target,
				"fire",
				spool_size * (1.22 + float(intensity) * 0.05),
				travel_duration * 1.42,
				intensity,
				launch_delay + travel_duration * 0.88,
				Vector2.ZERO,
				angle,
				1.9,
				0.98
			)
			_context.spawn_pack_layer(
				"big_impact_01" if intensity >= 6 else "impact_01",
				target,
				"fire",
				spool_size * 0.56,
				travel_duration * 0.60,
				intensity,
				launch_delay + travel_duration * 0.92,
				angle,
				2.4,
				0.60
			)
		"ice":
			_context.spawn_elemental_effect("cast", source, "ice", spool_size * 0.86, spool_duration * 1.15, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.82)
			for lane_index in [-1, 1]:
				var lane := normal * float(lane_index) * (12.0 + float(intensity) * 1.8)
				_context.spawn_elemental_effect(
					"projectile",
					source + lane,
					"ice",
					travel_size * Vector2(0.82, 0.58),
					travel_duration * 1.12,
					intensity,
					launch_delay + (0.05 if lane_index > 0 else 0.0),
					delta - lane * 0.35,
					angle - PI + float(lane_index) * 0.08,
					1.5,
					0.72
				)
			_context.spawn_path_afterimage("ice", source, delta, launch_delay, travel_duration * 1.10, intensity, angle)
			_context.spawn_elemental_effect(
				"area",
				target,
				"ice",
				spool_size * (0.98 + float(intensity) * 0.04),
				travel_duration * 1.58,
				intensity,
				launch_delay + travel_duration * 0.88,
				Vector2.ZERO,
				angle,
				1.9,
				0.82
			)
			_context.spawn_pack_layer(
				"impact_02", target, "ice", spool_size * 0.46, travel_duration * 0.72, intensity, launch_delay + travel_duration * 0.94, angle, 2.4, 0.48
			)
		"earth":
			var source_rumble := _context.spawn_elemental_effect(
				"area",
				source + Vector2(0.0, 18.0),
				"earth",
				spool_size * Vector2(1.18, 0.70),
				spool_duration * 1.10,
				intensity,
				0.0,
				Vector2.ZERO,
				angle,
				0.4,
				0.78
			)
			_context.stretch_effect(source_rumble, Vector3(1.45, 0.48, 1.0))
			_context.spawn_path_afterimage("earth", source, delta, launch_delay * 0.84, travel_duration * 1.24, intensity + 1, angle)
			var crawl := _context.spawn_elemental_effect(
				"projectile", source, "earth", travel_size * Vector2(0.72, 0.52), travel_duration * 1.28, intensity, launch_delay, delta, angle - PI, 1.2, 0.46
			)
			_context.stretch_effect(crawl, Vector3(1.15, 0.58, 1.0))
			var impact := _context.spawn_elemental_effect(
				"area",
				target + Vector2(0.0, 12.0),
				"earth",
				spool_size * (1.10 + float(intensity) * 0.05),
				travel_duration * 1.52,
				intensity,
				launch_delay + travel_duration * 0.94,
				Vector2.ZERO,
				angle,
				1.9,
				0.86
			)
			_context.stretch_effect(impact, Vector3(1.34, 0.56, 1.0))
			_context.spawn_pack_layer(
				"impact_01", target, "earth", spool_size * 0.46, travel_duration * 0.62, intensity, launch_delay + travel_duration * 0.98, angle, 2.4, 0.44
			)
		"heart":
			_context.spawn_elemental_effect("cast", source, "heart", spool_size * 0.90, spool_duration * 1.04, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.74)
			for lane_index in [-1, 0, 1]:
				var lane := normal * float(lane_index) * (10.0 + float(intensity))
				_context.spawn_elemental_effect(
					"projectile",
					source + lane,
					"heart",
					travel_size * Vector2(0.58, 0.70),
					travel_duration * 1.20,
					intensity,
					launch_delay + float(lane_index + 1) * 0.035,
					delta - lane * 0.30,
					angle - PI,
					1.5,
					0.58
				)
			_context.spawn_elemental_effect(
				"area",
				target,
				"heart",
				spool_size * (0.92 + float(intensity) * 0.04),
				travel_duration * 1.64,
				intensity,
				launch_delay + travel_duration * 0.88,
				Vector2(0.0, -18.0),
				angle,
				1.9,
				0.76
			)
		"armor":
			_context.spawn_elemental_effect("cast", source, "armor", spool_size * 0.92, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.76)
			_context.spawn_elemental_effect(
				"projectile", source, "armor", travel_size * Vector2(0.74, 0.78), travel_duration * 1.10, intensity, launch_delay, delta, angle - PI, 1.5, 0.62
			)
			var shell := _context.spawn_elemental_effect(
				"area",
				target,
				"armor",
				spool_size * (1.04 + float(intensity) * 0.04),
				travel_duration * 1.68,
				intensity,
				launch_delay + travel_duration * 0.88,
				Vector2.ZERO,
				angle,
				1.9,
				0.78
			)
			_context.stretch_effect(shell, Vector3(1.22, 0.78, 1.0))
			_context.spawn_pack_layer(
				"impact_02", target, "armor", spool_size * 0.44, travel_duration * 0.58, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.46
			)
		"gold":
			_context.spawn_elemental_effect("cast", source, "gold", spool_size * 0.90, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.78)
			_context.spawn_elemental_effect(
				"projectile", source, "gold", travel_size * Vector2(0.68, 0.62), travel_duration * 1.04, intensity, launch_delay, delta, angle - PI, 1.5, 0.62
			)
			_context.spawn_elemental_effect(
				"area",
				target,
				"gold",
				spool_size * (0.94 + float(intensity) * 0.04),
				travel_duration * 1.28,
				intensity,
				launch_delay + travel_duration * 0.86,
				Vector2.ZERO,
				angle,
				1.9,
				0.74
			)
			_context.spawn_coin_rain(target, spool_size.x, travel_duration * 1.4, intensity, false)
			_context.spawn_pack_layer(
				"hit_01", target, "gold", spool_size * 0.42, travel_duration * 0.50, intensity, launch_delay + travel_duration * 0.92, angle, 2.4, 0.48
			)
		_:
			_context.spawn_elemental_effect("cast", source, kind, spool_size * 1.04, spool_duration, intensity, 0.0, Vector2.ZERO, angle, 0.6, 0.92)
			_context.spawn_elemental_effect("projectile", source, kind, travel_size, travel_duration, intensity, launch_delay, delta, angle - PI, 1.4, 0.94)
			_context.spawn_elemental_effect(
				"area",
				target,
				kind,
				spool_size * (1.16 + float(intensity) * 0.05),
				travel_duration * 1.42,
				intensity,
				launch_delay + travel_duration * 0.88,
				Vector2.ZERO,
				angle,
				1.9,
				0.96
			)
	_context.spawn_camera_kick(delta.normalized() * (5.0 + float(intensity) * 1.2), launch_delay + travel_duration * 0.90)


func spawn_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_context.spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_context.spawn_screen_wide(kind, center, lifetime, intensity)


func spawn_beam_layers(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_context.spawn_beam_layers(kind, source, delta, lifetime, intensity, angle)
