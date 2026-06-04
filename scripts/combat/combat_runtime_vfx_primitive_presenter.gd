extends RefCounted
class_name CombatRuntimeVfxPrimitivePresenter

const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132

var _vfx_layer: Control
var _runtime_sprite_presenter: Variant


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")


func spawn_replay_ring(global_center: Vector2, ring_size: Vector2, fill: Color, border: Color, _border_width: int, lifetime: float, target_scale: Vector2, delay: float) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchRingGlow", "soft_glow", center_local, ring_size * 1.18, fill, lifetime * 0.92, target_scale, delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchRing", "ripple", center_local, ring_size, border, lifetime, target_scale, delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func spawn_replay_shield(global_center: Vector2, shield_size: Vector2, fill: Color, border: Color, _border_width: int, lifetime: float) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchShieldGlow", "soft_glow", center_local, shield_size * 1.22, fill, lifetime, Vector2(1.18, 1.12), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchShield", "shield", center_local, shield_size * 1.08, border, lifetime, Vector2(1.14, 1.08), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func spawn_replay_streak(global_center: Vector2, angle: float, length: float, thickness: float, color: Color, lifetime: float, delay: float, offset: Vector2 = Vector2.ZERO) -> void:
	var center_local := _global_to_vfx_local(global_center) + offset
	_spawn_runtime_sprite_local("PostMatchStreak", "ray", center_local, Vector2(maxf(8.0, length), maxf(2.0, thickness)), color, lifetime, Vector2(1.20, 0.64), delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle)


func spawn_replay_particle(global_center: Vector2, start_offset: Vector2, travel: Vector2, particle_size: Vector2, color: Color, lifetime: float, delay: float, corner_radius: int) -> void:
	var texture_key := "spark"
	if corner_radius < 32:
		texture_key = "shard"
	elif particle_size.x > particle_size.y * 1.8 or particle_size.y > particle_size.x * 1.8:
		texture_key = "ray"
	var center_local := _global_to_vfx_local(global_center) + start_offset
	var rotation := atan2(travel.y, travel.x)
	if texture_key == "ray" and particle_size.y > particle_size.x:
		particle_size = Vector2(particle_size.y, particle_size.x)
		rotation += PI * 0.5
	_spawn_runtime_sprite_local("PostMatchParticle", texture_key, center_local, particle_size, color, lifetime, Vector2(0.62, 0.62), delay, travel, 0.28, POST_MATCH_EFFECT_FRONT_Z_INDEX, rotation)


func spawn_replay_coin(global_center: Vector2, start_offset: Vector2, travel: Vector2, coin_size: Vector2, lifetime: float, delay: float) -> void:
	var center_local := _global_to_vfx_local(global_center) + start_offset
	var spin := 0.95 + 0.10 * float(int(abs(start_offset.x)) % 5)
	_spawn_runtime_sprite_local("PostMatchCoinTrail", "ray", center_local + Vector2(0.0, -coin_size.y * 0.40), Vector2(coin_size.x * 1.45, maxf(3.0, coin_size.y * 0.24)), Color(1.0, 0.92, 0.32, 0.50), lifetime * 0.62, Vector2(0.52, 0.34), delay, travel * 0.92, 0.0, POST_MATCH_EFFECT_Z_INDEX, PI * 0.5)
	_spawn_runtime_sprite_local("PostMatchCoin", "coin", center_local, coin_size, Color(1.0, 0.78, 0.18, 0.98), lifetime, Vector2(0.78, 0.78), delay, travel, spin, POST_MATCH_EFFECT_FRONT_Z_INDEX, 0.18 * float(int(start_offset.x) % 7))


func spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, _border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var texture_key := runtime_texture_key_for_effect(name, size, corner_radius)
	var draw_size := size
	var draw_rotation := rotation
	if texture_key == "ray" and size.y > size.x:
		draw_size = Vector2(size.y, size.x)
		draw_rotation += PI * 0.5
	var tint := border if border.a >= fill.a else fill
	if texture_key == "smoke" or texture_key == "soft_glow":
		tint = fill if fill.a >= border.a else border
	if texture_key in ["ripple", "shield"]:
		_spawn_runtime_sprite_local("%sGlow" % name, "soft_glow", center_local, size * 1.12, Color(fill.r, fill.g, fill.b, minf(fill.a, 0.22)), lifetime * 0.92, target_scale, delay, move_offset * 0.72, spin * 0.5, z_index - 1, draw_rotation, move_ease)
	_spawn_runtime_sprite_local(name, texture_key, center_local, draw_size, tint, lifetime, target_scale, delay, move_offset, spin, z_index, draw_rotation, move_ease)


func runtime_texture_key_for_effect(effect_name: String, size: Vector2, corner_radius: int) -> String:
	var lower_name := effect_name.to_lower()
	var aspect := size.x / maxf(1.0, size.y)
	if lower_name.contains("coin"):
		return "coin"
	if lower_name.contains("shield") or lower_name.contains("armor"):
		return "shield"
	if lower_name.contains("shockwave") or lower_name.contains("spool") or lower_name.contains("pulse") or lower_name.contains("ring"):
		return "ripple"
	if lower_name.contains("smoke") or lower_name.contains("dust") or lower_name.contains("haze") or lower_name.contains("mist"):
		return "smoke"
	if lower_name.contains("shard") or lower_name.contains("stone") or lower_name.contains("crystal"):
		return "shard"
	if lower_name.contains("spark") or lower_name.contains("mote"):
		return "spark"
	if lower_name.contains("flash") or lower_name.contains("bloom") or lower_name.contains("core"):
		return "soft_glow"
	if aspect >= 2.1 or aspect <= 0.48:
		return "ray"
	if corner_radius < 20:
		return "shard"
	return "soft_glow"


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
