extends RefCounted
class_name CombatScreenWideReplayPresenter

const POST_MATCH_SCREEN_EVENT_Z_INDEX := 120
const POST_MATCH_MAX_SCREEN_RAYS := 18

var _vfx_layer: Control
var _post_match_policy: Variant
var _runtime_primitive_presenter: Variant
var _runtime_sprite_presenter: Variant
var _vfx_profile: Variant


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_post_match_policy = dependencies.get("post_match_policy")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_vfx_profile = dependencies.get("vfx_profile")

func spawn_screen_wide_replay_event(global_center: Vector2, clean_kind: String, lifetime: float, intensity: int) -> void:
	var layer_size := layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	clean_kind = result_vfx_kind_key(clean_kind)
	var colors := result_effect_colors(clean_kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var duration := maxf(0.50, lifetime * 0.98)
	var screen_center := layer_size * 0.5
	var impact_local := global_to_vfx_local(global_center)
	var offensive := screen_replay_is_offensive(clean_kind)
	var event_focus := screen_replay_focus(layer_size, impact_local, clean_kind)
	var max_dim := maxf(layer_size.x, layer_size.y)
	var flash_center := screen_center
	var flash_size := layer_size * 1.08
	if offensive:
		flash_center = Vector2(layer_size.x * 0.5, event_focus.y)
		flash_size = Vector2(layer_size.x * 1.10, layer_size.y * 0.58)
	spawn_runtime_sprite_local("PostMatchScreenRuntimeBloom", "soft_glow", flash_center, flash_size * Vector2(1.18, 1.08), Color(accent.r, accent.g, accent.b, 0.13), duration * 0.66, Vector2(1.08, 1.04), 0.0, Vector2.ZERO, 0.0, POST_MATCH_SCREEN_EVENT_Z_INDEX)
	spawn_runtime_sprite_local("PostMatchScreenRuntimeDistortion", "smoke", event_focus, Vector2(max_dim * 0.82, max_dim * (0.36 if offensive else 0.54)), Color(core.r, core.g, core.b, 0.13), duration * 0.68, Vector2(1.18, 1.06), duration * 0.04, Vector2(0.0, -layer_size.y * (0.03 if offensive else 0.01)), 0.05, POST_MATCH_SCREEN_EVENT_Z_INDEX + 1)
	spawn_local_effect_panel(
		"PostMatchScreenFlash",
		flash_center,
		flash_size,
		Color(accent.r, accent.g, accent.b, 0.07),
		Color(core.r, core.g, core.b, 0.10),
		1,
		0,
		POST_MATCH_SCREEN_EVENT_Z_INDEX,
		duration * 0.58,
		Vector2(1.0, 1.0)
	)
	spawn_local_effect_panel(
		"PostMatchScreenShockwave",
		event_focus,
		Vector2(max_dim * 0.58, max_dim * 0.58),
		Color(accent.r, accent.g, accent.b, 0.06),
		Color(core.r, core.g, core.b, 0.56),
		5 + mini(intensity, 8),
		999,
		POST_MATCH_SCREEN_EVENT_Z_INDEX + 1,
		duration * 0.82,
		Vector2(2.20, 2.20),
		duration * 0.04
	)
	var screen_ray_count := mini(POST_MATCH_MAX_SCREEN_RAYS, 5 + intensity)
	for i in range(screen_ray_count):
		var progress := float(i) / float(maxi(1, screen_ray_count - 1))
		var ray_y := lerpf(layer_size.y * 0.12, layer_size.y * 0.88, progress)
		var ray_angle := -0.36 + sin(float(i) * 1.7) * 0.34
		var ray_center := Vector2(layer_size.x * 0.50, ray_y)
		var ray_delay := duration * (0.04 + float(i % 6) * 0.026)
		if offensive:
			ray_y = clampf(event_focus.y + (progress - 0.5) * layer_size.y * 0.36, layer_size.y * 0.08, layer_size.y * 0.52)
			ray_center = Vector2(layer_size.x * 0.50, ray_y)
			ray_angle = -0.18 + sin(float(i) * 1.9) * 0.22
		spawn_runtime_sprite_local(
			"PostMatchScreenLightRay",
			"ray",
			ray_center,
			Vector2(max_dim * (1.08 + float(i % 3) * 0.10), 9.0 + float(intensity) * 1.8),
			Color(core.r, core.g, core.b, 0.34),
			duration * 0.52,
			Vector2(1.10, 0.36),
			ray_delay,
			Vector2(sin(float(i)) * 30.0, -12.0 if offensive else -4.0),
			0.0,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			ray_angle
		)
	for i in range(3):
		var lane_center := screen_center + Vector2(0.0, (float(i) - 1.0) * layer_size.y * 0.16)
		var lane_move := Vector2((float(i) - 1.0) * 26.0, -12.0 + float(i) * 10.0)
		var lane_rotation := -0.23 + float(i) * 0.22
		if offensive:
			lane_center = Vector2(
				layer_size.x * 0.5,
				clampf(event_focus.y + (float(i) - 1.0) * layer_size.y * 0.08, layer_size.y * 0.10, layer_size.y * 0.48)
			)
			lane_move = Vector2((float(i) - 1.0) * 32.0, -18.0 + float(i) * 4.0)
			lane_rotation = -0.14 + float(i) * 0.11
		spawn_local_effect_panel(
			"PostMatchScreenSweep",
			lane_center,
			Vector2(max_dim * 1.46, 10.0 + float(intensity) * 1.9),
			Color(accent.r, accent.g, accent.b, 0.15),
			Color(core.r, core.g, core.b, 0.48),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
			duration * 0.54,
			Vector2(1.08, 0.42),
			duration * (0.05 + float(i) * 0.055),
			lane_move,
			0.0,
			lane_rotation
		)
	match clean_kind:
		"fire":
			_spawn_screen_fire_event(layer_size, event_focus, duration, intensity, accent, core)
		"ice":
			_spawn_screen_ice_event(layer_size, event_focus, duration, intensity, accent, core)
		"earth":
			_spawn_screen_earth_event(layer_size, event_focus, duration, intensity, accent, core, dark)
		"heart":
			_spawn_screen_heal_event(layer_size, duration, intensity, accent, core)
		"armor":
			_spawn_screen_armor_event(layer_size, duration, intensity, accent, core)
		"gold":
			_spawn_screen_gold_event(layer_size, duration, intensity, accent, core)
		"damage":
			_spawn_screen_damage_event(layer_size, event_focus, duration, intensity, accent, core)


func _spawn_screen_fire_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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


func _spawn_screen_ice_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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


func _spawn_screen_earth_event(layer_size: Vector2, impact_local: Vector2, duration: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
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


func _spawn_screen_heal_event(layer_size: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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


func _spawn_screen_armor_event(layer_size: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var screen_center := layer_size * 0.5
	spawn_local_effect_panel(
		"PostMatchScreenArmorShell",
		screen_center,
		layer_size * Vector2(0.92, 0.86),
		Color(accent.r, accent.g, accent.b, 0.07),
		Color(core.r, core.g, core.b, 0.44),
		5 + mini(intensity, 6),
		22,
		POST_MATCH_SCREEN_EVENT_Z_INDEX + 2,
		duration * 0.76,
		Vector2(1.03, 1.05),
		duration * 0.02
	)
	for i in range(4):
		var side_x := -1.0 if i < 2 else 1.0
		var side_y := -1.0 if i % 2 == 0 else 1.0
		spawn_local_effect_panel(
			"PostMatchScreenArmorBrace",
			screen_center + Vector2(side_x * layer_size.x * 0.36, side_y * layer_size.y * 0.28),
			Vector2(layer_size.x * 0.24, 8 + intensity),
			Color(core.r, core.g, core.b, 0.36),
			Color(0.96, 1.0, 1.0, 0.72),
			1,
			999,
			POST_MATCH_SCREEN_EVENT_Z_INDEX + 3,
			duration * 0.52,
			Vector2(0.64, 0.52),
			duration * (0.08 + float(i) * 0.036),
			Vector2(-side_x * 32.0, -side_y * 12.0),
			0.0,
			side_y * 0.42
		)


func _spawn_screen_gold_event(layer_size: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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


func _spawn_screen_damage_event(layer_size: Vector2, focus_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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

func spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_SCREEN_EVENT_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _runtime_primitive_presenter == null:
		return
	_runtime_primitive_presenter.spawn_local_effect_panel(name, center_local, size, fill, border, border_width, corner_radius, z_index, lifetime, target_scale, delay, move_offset, spin, rotation, move_ease)


func runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	if _post_match_policy == null:
		return 1
	return _post_match_policy.runtime_particle_count(intensity, multiplier)


func screen_replay_is_offensive(clean_kind: String) -> bool:
	return _post_match_policy != null and _post_match_policy.screen_replay_is_offensive(clean_kind)


func screen_replay_focus(screen_size: Vector2, impact_local: Vector2, clean_kind: String) -> Vector2:
	if _post_match_policy == null:
		return impact_local if impact_local != Vector2.ZERO else screen_size * 0.5
	return _post_match_policy.screen_replay_focus(screen_size, impact_local, clean_kind)


func result_vfx_kind_key(impact_kind: String) -> String:
	if _post_match_policy == null:
		return impact_kind.strip_edges().to_lower()
	return _post_match_policy.kind_key(impact_kind)


func result_effect_colors(clean_kind: String) -> Dictionary:
	if _vfx_profile == null:
		return {"accent": Color.WHITE, "core": Color.WHITE, "dark": Color(0.35, 0.35, 0.35, 1.0)}
	return _vfx_profile.result_effect_colors(clean_kind)


func layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var screen_size := _vfx_layer.size
	if screen_size.x <= 1.0 or screen_size.y <= 1.0:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			screen_size = viewport.get_visible_rect().size
	return screen_size


func global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
