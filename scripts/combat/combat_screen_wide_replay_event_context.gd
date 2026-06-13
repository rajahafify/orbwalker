extends RefCounted
class_name CombatScreenWideReplayEventContext

const POST_MATCH_SCREEN_EVENT_Z_INDEX := 120
const POST_MATCH_MAX_SCREEN_RAYS := 18

var _post_match_policy: Variant
var _runtime_primitive_presenter: Variant
var _runtime_sprite_presenter: Variant


func bind(dependencies: Dictionary) -> void:
	_post_match_policy = dependencies.get("post_match_policy")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")


func spawn_screen_fire_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var top_y := maxf(layer_size.y * 0.08, focus_local.y - layer_size.y * 0.15)
	var bottom_y := minf(layer_size.y * 0.48, focus_local.y + layer_size.y * 0.13)
	var column_count := mini(7 + intensity * 3, POST_MATCH_MAX_SCREEN_RAYS)
	for i in range(column_count):
		var x := (float(i) + 0.5) / float(column_count) * layer_size.x + sin(float(i) * 1.8) * 18.0
		var y := lerpf(top_y, bottom_y, float(i % 5) / 4.0)
		var height := layer_size.y * (0.14 + 0.020 * float(i % 4) + 0.020 * float(intensity))
		spawn_local_effect_panel(
			"PostMatchScreenFireColumn",
			Vector2(x, y + height * 0.24),
			Vector2(20 + intensity * 4, height),
			Color(1.0, 0.18, 0.03, 0.28),
			Color(core.r, core.g, core.b, 0.70),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.78,
			Vector2(0.58, 1.10),
			duration * (0.06 + float(i % 5) * 0.018),
			Vector2(sin(float(i) * 2.4) * 32.0, -layer_size.y * (0.20 + float(i % 3) * 0.035)),
			0.18,
			sin(float(i)) * 0.12
		)
	var spark_count := runtime_particle_count(intensity, 1.05)
	for i in range(spark_count):
		var start_y := lerpf(top_y, bottom_y, float(i % 7) / 6.0)
		var start := Vector2(layer_size.x * (float(i % 11) + 0.5) / 11.0, start_y)
		spawn_local_effect_panel(
			"PostMatchScreenFireSpark",
			start,
			Vector2(6 + intensity, 12 + intensity * 2),
			Color(accent.r, accent.g, accent.b, 0.68),
			Color(core.r, core.g, core.b, 0.84),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.52,
			Vector2(0.46, 0.62),
			float(i % 6) * duration * 0.020,
			Vector2(sin(float(i) * 1.3) * 32.0, -78.0 - float(intensity) * 10.0),
			0.45,
			-0.25 + sin(float(i)) * 0.26
		)


func spawn_screen_ice_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var top_y := maxf(layer_size.y * 0.08, focus_local.y - layer_size.y * 0.17)
	var bottom_y := minf(layer_size.y * 0.48, focus_local.y + layer_size.y * 0.16)
	var breeze_count := mini(8 + intensity * 3, POST_MATCH_MAX_SCREEN_RAYS)
	for i in range(breeze_count):
		var y := lerpf(top_y, bottom_y, float(i) / float(maxi(1, breeze_count - 1)))
		var side := -1.0 if i % 2 == 0 else 1.0
		spawn_local_effect_panel(
			"PostMatchScreenIceBreeze",
			Vector2(layer_size.x * (0.50 - side * 0.34), y),
			Vector2(layer_size.x * (0.52 + float(i % 3) * 0.05), 5 + intensity),
			Color(accent.r, accent.g, accent.b, 0.18),
			Color(core.r, core.g, core.b, 0.64),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.70,
			Vector2(1.16, 0.46),
			duration * (0.05 + float(i % 4) * 0.030),
			Vector2(side * layer_size.x * 0.24, sin(float(i)) * 16.0),
			0.0,
			sin(float(i)) * 0.08
		)
	var shard_count := runtime_particle_count(intensity, 0.98)
	for i in range(shard_count):
		var x := layer_size.x * (float(i % 9) + 0.5) / 9.0
		var y := lerpf(top_y, bottom_y, float(i % 7) / 6.0)
		spawn_local_effect_panel(
			"PostMatchScreenIceShard",
			Vector2(x, y),
			Vector2(7 + intensity, 24 + intensity * 3),
			Color(core.r, core.g, core.b, 0.62),
			Color(0.94, 1.0, 1.0, 0.90),
			1,
			4,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.58,
			Vector2(0.48, 0.78),
			float(i % 7) * duration * 0.018,
			Vector2(sin(float(i) * 1.7) * 36.0, 14.0 + float(i % 4) * 7.0),
			0.55,
			sin(float(i)) * 0.36
		)


func spawn_screen_earth_event(layer_size: Vector2, impact_local: Vector2, duration: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
	var crack_count := 6 + intensity
	for i in range(crack_count):
		var y := clampf(impact_local.y + (float(i) - float(crack_count - 1) * 0.5) * 38.0, layer_size.y * 0.12, layer_size.y * 0.50)
		spawn_local_effect_panel(
			"PostMatchScreenEarthCrack",
			Vector2(layer_size.x * 0.5, y),
			Vector2(layer_size.x * (0.72 + float(i % 3) * 0.08), 8 + intensity),
			Color(dark.r, dark.g, dark.b, 0.42),
			Color(core.r, core.g, core.b, 0.58),
			1,
			5,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.62,
			Vector2(1.16, 0.58),
			duration * (0.05 + float(i) * 0.030),
			Vector2(sin(float(i) * 2.0) * 22.0, 0.0),
			0.04,
			sin(float(i)) * 0.10
		)
	var stone_count := runtime_particle_count(intensity, 0.92)
	for i in range(stone_count):
		var x := layer_size.x * (float(i % 10) + 0.5) / 10.0
		var y := clampf(impact_local.y + layer_size.y * (0.04 + float(i % 5) * 0.035), layer_size.y * 0.14, layer_size.y * 0.54)
		spawn_local_effect_panel(
			"PostMatchScreenEarthStone",
			Vector2(x, y),
			Vector2(18 + intensity * 3, 12 + intensity * 2),
			Color(accent.r, accent.g, accent.b, 0.34),
			Color(core.r, core.g, core.b, 0.66),
			1,
			5,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.50,
			Vector2(0.62, 0.54),
			float(i % 6) * duration * 0.020,
			Vector2(sin(float(i) * 1.8) * 16.0, -28.0 - float(i % 3) * 8.0),
			0.18
		)


func spawn_screen_heal_event(layer_size: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var stream_count := mini(9 + intensity * 2, POST_MATCH_MAX_SCREEN_RAYS)
	for i in range(stream_count):
		var x := layer_size.x * (float(i) + 0.5) / float(stream_count)
		var height := layer_size.y * (0.24 + float(i % 4) * 0.035)
		spawn_local_effect_panel(
			"PostMatchScreenHealStream",
			Vector2(x, layer_size.y * 0.78),
			Vector2(8 + intensity, height),
			Color(accent.r, accent.g, accent.b, 0.20),
			Color(core.r, core.g, core.b, 0.58),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.74,
			Vector2(0.50, 1.12),
			duration * (0.04 + float(i % 5) * 0.026),
			Vector2(sin(float(i) * 1.4) * 20.0, -layer_size.y * 0.26),
			0.0
		)
	var mote_count := runtime_particle_count(intensity, 1.08)
	for i in range(mote_count):
		var start := Vector2(layer_size.x * (float(i % 12) + 0.5) / 12.0, layer_size.y * (0.38 + float(i % 6) * 0.075))
		spawn_local_effect_panel(
			"PostMatchScreenHealMote",
			start,
			Vector2(8 + intensity, 8 + intensity),
			Color(core.r, core.g, core.b, 0.58),
			Color(accent.r, accent.g, accent.b, 0.72),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.64,
			Vector2(0.48, 0.48),
			float(i % 7) * duration * 0.018,
			Vector2(sin(float(i) * 2.2) * 26.0, -58.0 - float(intensity) * 5.0)
		)


func spawn_screen_armor_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var grid_extent := minf(layer_size.x, layer_size.y) * (0.30 + float(intensity) * 0.010)
	var cell_size := maxf(42.0, grid_extent * 0.21)
	var gap := cell_size * 0.94
	var start := Vector2(-gap, -gap)
	spawn_runtime_sprite_local(
		"PostMatchScreenArmorGridBloom",
		"soft_glow",
		focus_local,
		Vector2(grid_extent, grid_extent) * 1.28,
		Color(accent.r, accent.g, accent.b, 0.18),
		duration * 0.80,
		Vector2(1.10, 1.10),
		duration * 0.02,
		Vector2.ZERO,
		0.0,
		POST_MATCH_SCREEN_EVENT_Z_INDEX + 2
	)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.24 if row % 2 == 1 else 0.0), float(row) * gap)
			var distance_from_center: int = absi(column - 1) + absi(row - 1)
			spawn_runtime_sprite_local(
				"PostMatchScreenArmorHexCell",
				"hex_cell",
				focus_local + offset,
				Vector2(cell_size, cell_size * 1.10),
				Color(core.r, core.g, core.b, 0.56 if distance_from_center == 0 else 0.42),
				duration * 0.66,
				Vector2(1.08, 1.08),
				duration * (0.04 + float(distance_from_center) * 0.032 + float(index % 2) * 0.012),
				Vector2.ZERO,
				0.0,
				POST_MATCH_SCREEN_EVENT_Z_INDEX + 4,
				PI / 6.0
			)
	var half := grid_extent * 0.50
	var bar_length := grid_extent * 0.64
	var bar_thickness := maxf(8.0, grid_extent * 0.028)
	var specs := [
		{"offset": Vector2(0.0, -half), "rotation": 0.0, "move": Vector2(0.0, grid_extent * 0.08)},
		{"offset": Vector2(0.0, half), "rotation": 0.0, "move": Vector2(0.0, -grid_extent * 0.08)},
		{"offset": Vector2(-half, 0.0), "rotation": PI * 0.5, "move": Vector2(grid_extent * 0.08, 0.0)},
		{"offset": Vector2(half, 0.0), "rotation": PI * 0.5, "move": Vector2(-grid_extent * 0.08, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		spawn_runtime_sprite_local(
			"PostMatchScreenArmorSnapBar",
			"ray",
			focus_local + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			Color(0.90, 0.98, 1.0, 0.76),
			duration * 0.44,
			Vector2(0.72, 0.48),
			duration * (0.06 + float(i) * 0.022),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.0,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 5,
			float(spec.get("rotation", 0.0))
		)


func spawn_screen_gold_event(layer_size: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var coin_count := runtime_particle_count(intensity, 1.45)
	for i in range(coin_count):
		var x := layer_size.x * (float(i % 13) + 0.5) / 13.0 + sin(float(i) * 1.9) * 18.0
		var y := -32.0 - float(i % 5) * 22.0
		spawn_local_effect_panel(
			"PostMatchScreenGoldCoin",
			Vector2(x, y),
			Vector2(13 + intensity * 2, 18 + intensity * 2),
			Color(accent.r, accent.g, accent.b, 0.82),
			Color(core.r, core.g, core.b, 0.92),
			2,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 1.05,
			Vector2(0.74, 0.74),
			float(i % 9) * duration * 0.022,
			Vector2(sin(float(i) * 2.7) * 30.0, layer_size.y * (0.72 + float(i % 4) * 0.07)),
			0.95
		)
	var sparkle_count := runtime_particle_count(intensity, 0.86)
	for i in range(sparkle_count):
		var center := Vector2(layer_size.x * (float(i % 8) + 0.5) / 8.0, layer_size.y * (0.18 + float(i % 6) * 0.12))
		spawn_local_effect_panel(
			"PostMatchScreenGoldSpark",
			center,
			Vector2(36 + intensity * 4, 4 + intensity),
			Color(core.r, core.g, core.b, 0.46),
			Color(1.0, 1.0, 0.78, 0.78),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.48,
			Vector2(0.52, 0.46),
			float(i % 5) * duration * 0.026,
			Vector2.ZERO,
			0.0,
			float(i) * 0.72
		)


func spawn_screen_damage_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var top_y := maxf(layer_size.y * 0.10, focus_local.y - layer_size.y * 0.14)
	var bottom_y := minf(layer_size.y * 0.50, focus_local.y + layer_size.y * 0.15)
	var slash_count := mini(5 + intensity, POST_MATCH_MAX_SCREEN_RAYS)
	for i in range(slash_count):
		var y := lerpf(top_y, bottom_y, float(i) / float(maxi(1, slash_count - 1)))
		spawn_local_effect_panel(
			"PostMatchScreenDamageSlash",
			Vector2(layer_size.x * 0.5, y),
			Vector2(layer_size.x * (0.58 + float(i % 3) * 0.06), 11 + intensity),
			Color(accent.r, accent.g, accent.b, 0.24),
			Color(core.r, core.g, core.b, 0.54),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.50,
			Vector2(1.08, 0.52),
			duration * (0.05 + float(i) * 0.040),
			Vector2(sin(float(i) * 1.6) * 26.0, 0.0),
			0.0,
			-0.44 + sin(float(i)) * 0.18
		)


func spawn_runtime_sprite_local(
	name: String,
	texture_key: String,
	center_local: Vector2,
	draw_size: Vector2,
	color: Color,
	lifetime: float,
	target_scale: Vector2,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	spin: float = 0.0,
	z_index: int = POST_MATCH_SCREEN_EVENT_Z_INDEX,
	rotation: float = 0.0,
	move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType
) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(
		name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease
	)


func spawn_local_effect_panel(
	name: String,
	center_local: Vector2,
	size: Vector2,
	fill: Color,
	border: Color,
	border_width: int,
	corner_radius: int,
	z_index: int,
	lifetime: float,
	target_scale: Vector2,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	spin: float = 0.0,
	rotation: float = 0.0,
	move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType
) -> void:
	if _runtime_primitive_presenter == null:
		return
	_runtime_primitive_presenter.spawn_local_effect_panel(
		name, center_local, size, fill, border, border_width, corner_radius, z_index, lifetime, target_scale, delay, move_offset, spin, rotation, move_ease
	)


func runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	if _post_match_policy == null:
		return 1
	return _post_match_policy.runtime_particle_count(intensity, multiplier)
