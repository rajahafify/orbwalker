extends RefCounted
class_name CombatScreenWideReplayPresenter

const POST_MATCH_SCREEN_EVENT_Z_INDEX := 120
const POST_MATCH_MAX_SCREEN_RAYS := 18
const EVENT_CONTEXT_SCRIPT := preload("res://scripts/combat/combat_screen_wide_replay_event_context.gd")

var _vfx_layer: Control
var _post_match_policy: Variant
var _runtime_primitive_presenter: Variant
var _runtime_sprite_presenter: Variant
var _vfx_profile: Variant
var _event_context: Variant = EVENT_CONTEXT_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_post_match_policy = dependencies.get("post_match_policy")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_vfx_profile = dependencies.get("vfx_profile")
	_event_context.bind(dependencies)


func spawn_screen_wide_replay_event(global_center: Vector2, clean_kind: String, lifetime: float, intensity: int) -> void:
	var layer_size := vfx_layer_size()
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
	spawn_runtime_sprite_local(
		"PostMatchScreenRuntimeBloom",
		"soft_glow",
		flash_center,
		flash_size * Vector2(1.18, 1.08),
		Color(accent.r, accent.g, accent.b, 0.13),
		duration * 0.66,
		Vector2(1.08, 1.04),
		0.0,
		Vector2.ZERO,
		0.0,
		POST_MATCH_SCREEN_EVENT_Z_INDEX
	)
	spawn_runtime_sprite_local(
		"PostMatchScreenRuntimeDistortion",
		"smoke",
		event_focus,
		Vector2(max_dim * 0.82, max_dim * (0.36 if offensive else 0.54)),
		Color(core.r, core.g, core.b, 0.13),
		duration * 0.68,
		Vector2(1.18, 1.06),
		duration * 0.04,
		Vector2(0.0, -layer_size.y * (0.03 if offensive else 0.01)),
		0.05,
		POST_MATCH_SCREEN_EVENT_Z_INDEX + 1
	)
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
			lane_center = Vector2(layer_size.x * 0.5, clampf(event_focus.y + (float(i) - 1.0) * layer_size.y * 0.08, layer_size.y * 0.10, layer_size.y * 0.48))
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
			_event_context.spawn_screen_fire_event(layer_size, event_focus, duration, intensity, accent, core)
		"ice":
			_event_context.spawn_screen_ice_event(layer_size, event_focus, duration, intensity, accent, core)
		"earth":
			_event_context.spawn_screen_earth_event(layer_size, event_focus, duration, intensity, accent, core, dark)
		"heart":
			_event_context.spawn_screen_heal_event(layer_size, duration, intensity, accent, core)
		"armor":
			_event_context.spawn_screen_armor_event(layer_size, event_focus, duration, intensity, accent, core)
		"gold":
			_event_context.spawn_screen_gold_event(layer_size, duration, intensity, accent, core)
		"damage":
			_event_context.spawn_screen_damage_event(layer_size, event_focus, duration, intensity, accent, core)


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


func vfx_layer_size() -> Vector2:
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
