extends RefCounted
class_name CombatStylizedReplayVfxPresenter

const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_MAX_SCREEN_RAYS := 18
const POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS := [0, 5, 8, 12, 16, 22, 30, 42, 56]

var _vfx_layer: Control
var _visual_registry: Variant
var _vfx_profile: Variant
var _runtime_sprite_presenter: Variant
var _runtime_primitive_presenter: Variant
var _screen_wide_replay_presenter: Variant
var _global_to_local: Callable


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_vfx_profile = dependencies.get("vfx_profile")
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")
	_screen_wide_replay_presenter = dependencies.get("screen_wide_replay_presenter")
	_global_to_local = dependencies.get("global_to_local", Callable())


func runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	var index := clampi(intensity, 1, POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS.size() - 1)
	var base_count := int(POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS[index])
	var count := int(round(float(base_count) * maxf(0.1, multiplier)))
	return clampi(count, 1, POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST)


func spawn_stylized_replay_effect(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, result_amount: int, tier_index: int, screen_wide: bool) -> void:
	if global_center == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var intensity := replay_effect_intensity(result_amount, tier_index)
	if clean_kind == "armor":
		_spawn_armor_replay_effect(global_center, draw_size, lifetime, intensity)
		return
	if screen_wide and _screen_wide_replay_presenter != null:
		_screen_wide_replay_presenter.spawn_screen_wide_replay_event(global_center, clean_kind, lifetime, intensity)
	_spawn_baseline_replay_impact(global_center, clean_kind, draw_size, lifetime, intensity)
	_spawn_runtime_impact_stack(global_center, clean_kind, draw_size, lifetime, intensity)
	_spawn_replay_signature_sprite(global_center, clean_kind, draw_size, lifetime, intensity)
	match clean_kind:
		"fire":
			_spawn_fire_replay_effect(global_center, draw_size, lifetime, intensity)
		"ice":
			_spawn_ice_replay_effect(global_center, draw_size, lifetime, intensity)
		"earth":
			_spawn_earth_replay_effect(global_center, draw_size, lifetime, intensity)
		"heart":
			_spawn_heal_replay_effect(global_center, draw_size, lifetime, intensity)
		"gold":
			_spawn_gold_replay_effect(global_center, draw_size, lifetime, intensity)
		"damage":
			_spawn_damage_replay_effect(global_center, draw_size, lifetime, intensity)


func replay_effect_intensity(result_amount: int, tier_index: int) -> int:
	var amount_bonus := int(floor(float(maxi(0, result_amount)) / 12.0))
	return clampi(tier_index + 2 + amount_bonus, 2, 8)


func _spawn_baseline_replay_impact(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.result_effect_colors(clean_kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var center_local := _global_to_vfx_local(global_center)
	var punch := 1.0 + float(intensity) * 0.06
	_spawn_runtime_sprite_local("PostMatchBaselineFlash", "soft_glow", center_local, draw_size * (2.0 * punch), Color(core.r, core.g, core.b, 0.52), lifetime * 0.34, Vector2(0.38, 0.38), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 4)
	_spawn_runtime_sprite_local("PostMatchBaselineAfterglow", "soft_glow", center_local, draw_size * (1.48 * punch), Color(accent.r, accent.g, accent.b, 0.38), lifetime * 0.66, Vector2(1.22, 1.22), lifetime * 0.02, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX + 2)
	_spawn_replay_ring(global_center, draw_size * (0.76 + float(intensity) * 0.025), Color(accent.r, accent.g, accent.b, 0.18), Color(core.r, core.g, core.b, 0.98), 5 + mini(intensity, 5), lifetime * 0.48, Vector2(1.34, 1.34), 0.0)


func _spawn_replay_signature_sprite(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var texture_key := "post_match_%s" % clean_kind
	if clean_kind == "heal":
		texture_key = "post_match_heart"
	var sprite_size := draw_size * (1.26 + float(intensity) * 0.06)
	var glow_size := sprite_size * 1.34
	var color := Color(1.0, 1.0, 1.0, 0.94)
	var glow_color := Color(1.0, 1.0, 1.0, 0.34)
	var spin := 0.0
	match clean_kind:
		"fire":
			color = Color(1.0, 0.58, 0.20, 0.98)
			glow_color = Color(1.0, 0.20, 0.03, 0.34)
			spin = -0.18
		"ice":
			color = Color(0.72, 0.96, 1.0, 0.98)
			glow_color = Color(0.22, 0.76, 1.0, 0.30)
			spin = 0.12
		"earth":
			color = Color(0.74, 1.0, 0.34, 0.96)
			glow_color = Color(0.18, 0.78, 0.20, 0.28)
			spin = 0.08
		"heart":
			color = Color(0.72, 1.0, 0.76, 0.96)
			glow_color = Color(0.18, 1.0, 0.40, 0.30)
			spin = -0.08
		"armor":
			color = Color(0.82, 0.94, 1.0, 0.96)
			glow_color = Color(0.22, 0.64, 1.0, 0.28)
		"gold":
			color = Color(1.0, 0.88, 0.26, 0.98)
			glow_color = Color(1.0, 0.58, 0.08, 0.32)
			spin = 0.22
		"damage":
			color = Color(1.0, 0.36, 0.28, 0.96)
			glow_color = Color(1.0, 0.08, 0.05, 0.30)
			spin = -0.12
	_spawn_replay_sprite(texture_key, global_center, glow_size, glow_color, lifetime * 0.94, Vector2(1.34, 1.34), 0.0, Vector2.ZERO, spin * 0.5, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_sprite(texture_key, global_center, sprite_size, color, lifetime * 0.82, Vector2(1.12, 1.12), 0.02, Vector2.ZERO, spin, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func _spawn_fire_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var ring_size := draw_size * 1.08
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchFireHeatBloom", "soft_glow", center_local, draw_size * (2.15 + float(intensity) * 0.18), Color(1.0, 0.16, 0.02, 0.32), lifetime * 0.92, Vector2(1.22, 1.22), 0.0, Vector2.ZERO, -0.10, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchFireHeatHaze", "smoke", center_local + Vector2(0.0, -draw_size.y * 0.06), draw_size * (1.62 + float(intensity) * 0.12), Color(1.0, 0.42, 0.08, 0.26), lifetime * 1.02, Vector2(1.44, 1.12), lifetime * 0.06, Vector2(0.0, -draw_size.y * 0.16), 0.18, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_replay_ring(global_center, ring_size, Color(1.0, 0.16, 0.02, 0.20), Color(1.0, 0.74, 0.22, 0.95), 7 + intensity, lifetime * 0.86, Vector2(1.35 + float(intensity) * 0.10, 1.35 + float(intensity) * 0.10), 0.0)
	_spawn_replay_ring(global_center, ring_size * 0.62, Color(1.0, 0.72, 0.10, 0.24), Color(1.0, 0.95, 0.54, 0.85), 4 + intensity, lifetime * 0.58, Vector2(1.18, 1.18), 0.0)
	var count := runtime_particle_count(intensity, 1.22)
	for i in range(count):
		var angle := -PI * 0.35 + TAU * float(i) / float(count)
		var length := draw_size.x * (0.22 + 0.035 * float((i % 4) + intensity))
		var color := Color(1.0, 0.25 + 0.08 * float(i % 3), 0.05, 0.90)
		_spawn_replay_streak(global_center, angle, length, 7.0 + float(intensity) * 1.4, color, lifetime * 0.58, float(i % 5) * 0.012)
		var travel := Vector2(cos(angle), sin(angle) - 0.34) * draw_size.x * (0.22 + 0.025 * float(intensity))
		_spawn_replay_particle(global_center, Vector2.ZERO, travel, Vector2(10 + intensity * 2, 10 + intensity * 2), color.lightened(0.18), lifetime * 0.76, float(i % 4) * 0.018, 999)


func _spawn_ice_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchIceColdBloom", "soft_glow", center_local, draw_size * (1.92 + float(intensity) * 0.12), Color(0.22, 0.76, 1.0, 0.30), lifetime * 0.94, Vector2(1.12, 1.20), 0.0, Vector2.ZERO, 0.06, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchIceMist", "smoke", center_local + Vector2(0.0, -draw_size.y * 0.04), draw_size * (1.72 + float(intensity) * 0.10), Color(0.68, 0.96, 1.0, 0.30), lifetime * 1.08, Vector2(1.42, 0.88), lifetime * 0.04, Vector2(0.0, 12.0 + float(intensity) * 2.0), -0.08, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 0.98, Color(0.12, 0.72, 1.0, 0.12), Color(0.70, 0.96, 1.0, 0.98), 5 + intensity, lifetime * 0.74, Vector2(1.18 + float(intensity) * 0.06, 1.18 + float(intensity) * 0.06), 0.0)
	var count := runtime_particle_count(intensity, 1.05)
	for i in range(count):
		var angle := TAU * float(i) / float(count) + 0.14
		var length := draw_size.x * (0.24 + 0.03 * float(intensity + (i % 3)))
		var color := Color(0.62, 0.92, 1.0, 0.92)
		_spawn_replay_streak(global_center, angle, length, 4.0 + float(intensity), color, lifetime * 0.80, float(i % 3) * 0.012)
		if i % 2 == 0:
			var shard_travel := Vector2(cos(angle), sin(angle)) * draw_size.x * (0.18 + float(intensity) * 0.018)
			_spawn_replay_particle(global_center, Vector2.ZERO, shard_travel, Vector2(8 + intensity, 18 + intensity * 3), Color(0.86, 0.98, 1.0, 0.94), lifetime * 0.64, float(i % 5) * 0.016, 4)


func _spawn_earth_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchEarthRunicBloom", "soft_glow", center_local, draw_size * (1.86 + float(intensity) * 0.12), Color(0.38, 1.0, 0.18, 0.22), lifetime * 0.94, Vector2(1.20, 0.94), 0.0, Vector2.ZERO, 0.04, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchEarthDust", "smoke", center_local + Vector2(0.0, draw_size.y * 0.08), draw_size * (1.72 + float(intensity) * 0.12), Color(0.52, 0.82, 0.34, 0.24), lifetime * 1.04, Vector2(1.42, 0.72), lifetime * 0.04, Vector2(0.0, -draw_size.y * 0.10), 0.05, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 1.06, Color(0.16, 0.58, 0.18, 0.16), Color(0.74, 1.0, 0.30, 0.92), 6 + intensity, lifetime * 0.88, Vector2(1.30 + float(intensity) * 0.06, 1.18 + float(intensity) * 0.04), 0.0)
	var count := runtime_particle_count(intensity, 1.06)
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		var travel := Vector2(cos(angle) * 0.75, sin(angle) * 0.48 - 0.08) * draw_size.x * (0.18 + float(intensity) * 0.025)
		var color := Color(0.52 + 0.08 * float(i % 2), 0.86, 0.28, 0.90)
		_spawn_replay_particle(global_center, Vector2.ZERO, travel, Vector2(14 + intensity * 2, 11 + intensity), color, lifetime * 0.72, float(i % 4) * 0.016, 5)
		if i % 3 == 0:
			_spawn_replay_streak(global_center, angle + PI * 0.5, draw_size.x * 0.26, 5.0 + float(intensity), Color(0.86, 1.0, 0.38, 0.78), lifetime * 0.58, float(i % 5) * 0.014)


func _spawn_heal_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchHealFreshBloom", "soft_glow", center_local, draw_size * (1.92 + float(intensity) * 0.14), Color(0.42, 1.0, 0.54, 0.28), lifetime * 1.08, Vector2(1.08, 1.36), 0.0, Vector2(0.0, -draw_size.y * 0.12), 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchHealRipple", "ripple", center_local, draw_size * (1.10 + float(intensity) * 0.07), Color(0.88, 1.0, 0.78, 0.82), lifetime * 0.76, Vector2(1.36, 1.58), lifetime * 0.04, Vector2(0.0, -draw_size.y * 0.10), 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 1.00, Color(0.18, 1.0, 0.40, 0.13), Color(0.74, 1.0, 0.78, 0.94), 5 + intensity, lifetime * 0.92, Vector2(1.18, 1.42 + float(intensity) * 0.08), 0.0)
	var stream_count := runtime_particle_count(intensity, 0.96)
	for i in range(stream_count):
		var x_offset := (float(i) / float(maxi(1, stream_count - 1)) - 0.5) * draw_size.x * 0.72
		var start := Vector2(x_offset, draw_size.y * 0.20)
		var travel := Vector2(sin(float(i) * 1.7) * 12.0, -draw_size.y * (0.50 + float(intensity) * 0.055))
		var color := Color(0.42, 1.0, 0.58 + 0.06 * float(i % 2), 0.86)
		_spawn_replay_streak(global_center, -PI * 0.5 + sin(float(i)) * 0.18, draw_size.y * (0.28 + float(intensity) * 0.035), 5.0 + float(intensity), color, lifetime * 0.74, float(i % 4) * 0.025, start)
		_spawn_replay_particle(global_center, start, travel, Vector2(9 + intensity, 9 + intensity), Color(0.82, 1.0, 0.78, 0.88), lifetime * 0.86, float(i % 4) * 0.025, 999)


func _spawn_armor_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	var board_extent := maxf(draw_size.x, draw_size.y)
	var shell_size := Vector2(board_extent, board_extent) * (1.08 + float(intensity) * 0.020)
	_spawn_armor_hex_grid(center_local, shell_size, lifetime, intensity)
	_spawn_armor_snap_bars(center_local, shell_size, lifetime, intensity)


func _spawn_armor_hex_grid(center_local: Vector2, shell_size: Vector2, lifetime: float, intensity: int) -> void:
	var columns := 3
	var rows := 3
	var cell_size := maxf(52.0, minf(shell_size.x, shell_size.y) * (0.25 + float(intensity) * 0.008))
	var gap := cell_size * 0.82
	var start := Vector2(-gap, -gap)
	for row in range(rows):
		for column in range(columns):
			var index := row * columns + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.28 if row % 2 == 1 else 0.0), float(row) * gap)
			var distance_from_center: int = absi(column - 1) + absi(row - 1)
			var delay := lifetime * (0.025 + float(distance_from_center) * 0.035 + float(index % 2) * 0.012)
			var alpha := 0.98 if distance_from_center == 0 else 0.86
			_spawn_runtime_sprite_local(
				"PostMatchArmorHexCell",
				"hex_cell",
				center_local + offset,
				Vector2(cell_size, cell_size * 1.12),
				Color(0.86, 0.98, 1.0, alpha),
				lifetime * 0.90,
				Vector2(1.12, 1.12),
				delay,
				Vector2.ZERO,
				0.0,
				POST_MATCH_EFFECT_FRONT_Z_INDEX + 8,
				PI / 6.0
			)
			_spawn_runtime_sprite_local(
				"PostMatchArmorHexCellCore",
				"soft_glow",
				center_local + offset,
				Vector2(cell_size * 0.54, cell_size * 0.54),
				Color(0.50, 0.88, 1.0, 0.38),
				lifetime * 0.58,
				Vector2(1.10, 1.10),
				delay,
				Vector2.ZERO,
				0.0,
				POST_MATCH_EFFECT_FRONT_Z_INDEX + 7
			)


func _spawn_armor_snap_bars(center_local: Vector2, shell_size: Vector2, lifetime: float, intensity: int) -> void:
	var bar_color := Color(0.92, 0.99, 1.0, 0.96)
	var bar_length := shell_size.x * (0.78 + float(intensity) * 0.012)
	var bar_thickness := maxf(9.0, 8.0 + float(intensity) * 1.1)
	var half := shell_size * 0.50
	var specs := [
		{"offset": Vector2(0.0, -half.y), "rotation": 0.0, "move": Vector2(0.0, 24.0)},
		{"offset": Vector2(0.0, half.y), "rotation": 0.0, "move": Vector2(0.0, -24.0)},
		{"offset": Vector2(-half.x, 0.0), "rotation": PI * 0.5, "move": Vector2(24.0, 0.0)},
		{"offset": Vector2(half.x, 0.0), "rotation": PI * 0.5, "move": Vector2(-24.0, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		_spawn_runtime_sprite_local(
			"PostMatchArmorGridSnapBar",
			"ray",
			center_local + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			bar_color,
			lifetime * 0.50,
			Vector2(0.82, 0.58),
			lifetime * (0.04 + float(i) * 0.022),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.0,
			POST_MATCH_EFFECT_FRONT_Z_INDEX + 9,
			float(spec.get("rotation", 0.0))
		)


func _spawn_gold_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchGoldRewardBloom", "soft_glow", center_local, draw_size * (2.0 + float(intensity) * 0.14), Color(1.0, 0.68, 0.10, 0.34), lifetime * 0.98, Vector2(1.16, 1.16), 0.0, Vector2.ZERO, 0.12, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 0.92, Color(1.0, 0.74, 0.10, 0.14), Color(1.0, 0.92, 0.32, 0.98), 5 + intensity, lifetime * 0.74, Vector2(1.18, 1.18), 0.0)
	var coin_count := runtime_particle_count(intensity, 1.18)
	for i in range(coin_count):
		var x_offset := (float(i % 9) / 8.0 - 0.5) * draw_size.x * (1.10 + float(intensity) * 0.08)
		var y_offset := -draw_size.y * (0.90 + 0.12 * float(i % 4))
		var travel := Vector2(sin(float(i) * 1.13) * 18.0, draw_size.y * (1.00 + float(intensity) * 0.07))
		var delay := float(i) * 0.018
		_spawn_replay_coin(global_center, Vector2(x_offset, y_offset), travel, Vector2(15 + intensity * 2, 18 + intensity * 2), lifetime * 1.15, delay)
	var sparkle_count := runtime_particle_count(intensity, 0.54)
	for i in range(sparkle_count):
		var angle := TAU * float(i) / float(sparkle_count)
		_spawn_replay_streak(global_center, angle, draw_size.x * 0.22, 4.0 + float(intensity), Color(1.0, 0.96, 0.45, 0.88), lifetime * 0.56, float(i % 4) * 0.012)


func _spawn_damage_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchDamageBloom", "soft_glow", center_local, draw_size * (1.76 + float(intensity) * 0.12), Color(1.0, 0.12, 0.08, 0.26), lifetime * 0.78, Vector2(1.18, 1.10), 0.0, Vector2.ZERO, -0.08, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 0.92, Color(1.0, 0.08, 0.06, 0.13), Color(1.0, 0.40, 0.28, 0.92), 5 + intensity, lifetime * 0.64, Vector2(1.22 + float(intensity) * 0.05, 1.22 + float(intensity) * 0.05), 0.0)
	var slash_count := mini(2 + intensity, POST_MATCH_MAX_SCREEN_RAYS)
	for i in range(slash_count):
		var offset := Vector2(0.0, (float(i) - float(slash_count - 1) * 0.5) * 16.0)
		_spawn_replay_streak(global_center, -0.44, draw_size.x * (0.62 + float(intensity) * 0.04), 9.0 + float(intensity) * 1.6, Color(1.0, 0.42, 0.34, 0.92), lifetime * 0.55, float(i) * 0.028, offset)


func _spawn_runtime_impact_stack(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	var colors: Dictionary = _vfx_profile.result_effect_colors(clean_kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var glow_size := draw_size * (1.72 + float(intensity) * 0.14)
	var shock_size := draw_size * (1.04 + float(intensity) * 0.08)
	_spawn_runtime_sprite_local("PostMatchRuntimeBloom", "soft_glow", center_local, glow_size, Color(accent.r, accent.g, accent.b, 0.28), lifetime * 1.04, Vector2(1.16, 1.16), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchRuntimeCoreLight", "soft_glow", center_local, draw_size * (0.78 + float(intensity) * 0.03), Color(core.r, core.g, core.b, 0.42), lifetime * 0.54, Vector2(0.76, 0.76), lifetime * 0.02, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchRuntimeShockwave", "ripple", center_local, shock_size, Color(core.r, core.g, core.b, 0.74), lifetime * 0.76, Vector2(1.42 + float(intensity) * 0.07, 1.42 + float(intensity) * 0.07), lifetime * 0.02, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	if clean_kind in ["fire", "ice", "earth", "damage", "heart"]:
		var haze_color := Color(dark.r, dark.g, dark.b, 0.16)
		if clean_kind == "ice":
			haze_color = Color(core.r, core.g, core.b, 0.20)
		elif clean_kind == "heart":
			haze_color = Color(accent.r, accent.g, accent.b, 0.14)
		_spawn_runtime_sprite_local("PostMatchRuntimeDistortion", "smoke", center_local, draw_size * (1.34 + float(intensity) * 0.08), haze_color, lifetime * 0.92, Vector2(1.26, 1.04), lifetime * 0.06, Vector2(0.0, -draw_size.y * 0.06), 0.08, POST_MATCH_EFFECT_Z_INDEX)
	var ray_count := mini(POST_MATCH_MAX_SCREEN_RAYS, 4 + intensity)
	for i in range(ray_count):
		var angle := TAU * float(i) / float(ray_count) + sin(float(i) * 1.7) * 0.18
		var offset := Vector2(cos(angle), sin(angle)) * draw_size.x * (0.06 + float(i % 3) * 0.025)
		_spawn_runtime_sprite_local(
			"PostMatchRuntimeImpactRay",
			"ray",
			center_local + offset,
			Vector2(draw_size.x * (0.56 + float(intensity) * 0.045 + float(i % 3) * 0.035), 5.0 + float(intensity) * 0.95),
			Color(core.r, core.g, core.b, 0.48),
			lifetime * 0.48,
			Vector2(1.12, 0.42),
			lifetime * (0.03 + float(i % 4) * 0.016),
			Vector2(cos(angle), sin(angle)) * draw_size.x * (0.10 + float(intensity) * 0.012),
			0.0,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			angle
		)


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func _spawn_replay_ring(global_center: Vector2, ring_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float, target_scale: Vector2, delay: float) -> void:
	_runtime_primitive_presenter.spawn_replay_ring(global_center, ring_size, fill, border, border_width, lifetime, target_scale, delay)


func _spawn_replay_shield(global_center: Vector2, shield_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float) -> void:
	_runtime_primitive_presenter.spawn_replay_shield(global_center, shield_size, fill, border, border_width, lifetime)


func _spawn_replay_streak(global_center: Vector2, angle: float, length: float, thickness: float, color: Color, lifetime: float, delay: float, offset: Vector2 = Vector2.ZERO) -> void:
	_runtime_primitive_presenter.spawn_replay_streak(global_center, angle, length, thickness, color, lifetime, delay, offset)


func _spawn_replay_particle(global_center: Vector2, start_offset: Vector2, travel: Vector2, particle_size: Vector2, color: Color, lifetime: float, delay: float, corner_radius: int) -> void:
	_runtime_primitive_presenter.spawn_replay_particle(global_center, start_offset, travel, particle_size, color, lifetime, delay, corner_radius)


func _spawn_replay_coin(global_center: Vector2, start_offset: Vector2, travel: Vector2, coin_size: Vector2, lifetime: float, delay: float) -> void:
	_runtime_primitive_presenter.spawn_replay_coin(global_center, start_offset, travel, coin_size, lifetime, delay)


func _spawn_replay_sprite(texture_key: String, global_center: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX) -> void:
	if _visual_registry == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var texture: Texture2D = _visual_registry.vfx_texture(texture_key)
	_runtime_sprite_presenter.spawn_texture_local("PostMatchSignature", texture, _global_to_vfx_local(global_center), draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _global_to_local.is_valid():
		return _global_to_local.call(global_position)
	return global_position
