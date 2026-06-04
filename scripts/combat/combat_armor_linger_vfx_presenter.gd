extends RefCounted
class_name CombatArmorLingerVfxPresenter

const POST_MATCH_BAR_LINGER_Z_INDEX := 131

var _runtime_sprite_presenter: Variant
var _runtime_primitive_presenter: Variant


func bind(dependencies: Dictionary) -> void:
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")


func spawn_armor_linger(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var base_size := Vector2(maxf(180.0, draw_size.x), maxf(58.0, draw_size.y))
	var shell_size := Vector2(
		base_size.x * (1.08 + float(intensity) * 0.028),
		base_size.y * (1.04 + float(intensity) * 0.025)
	)
	_spawn_runtime_sprite_local("ArmorBarShieldBloom", "soft_glow", center_local, shell_size * Vector2(1.22, 1.72), Color(0.34, 0.68, 1.0, 0.22), lifetime, Vector2(1.08, 1.12), 0.0, Vector2.ZERO, 0.0, POST_MATCH_BAR_LINGER_Z_INDEX - 1)
	_spawn_runtime_sprite_local("ArmorBarShieldRuntimeShell", "shield", center_local, shell_size * Vector2(1.08, 1.36), Color(0.78, 0.92, 1.0, 0.50), lifetime * 0.96, Vector2(1.04, 1.08), 0.0, Vector2.ZERO, 0.0, POST_MATCH_BAR_LINGER_Z_INDEX + 1)
	_spawn_runtime_sprite_local("ArmorBarShieldRefraction", "ray", center_local + Vector2(0.0, -shell_size.y * 0.18), Vector2(shell_size.x * 0.96, 16.0 + float(intensity) * 2.0), Color(0.92, 0.98, 1.0, 0.62), lifetime * 0.58, Vector2(0.82, 0.42), lifetime * 0.12, Vector2(18.0, 0.0), 0.0, POST_MATCH_BAR_LINGER_Z_INDEX + 2)
	_spawn_local_effect_panel("ArmorBarShieldLinger", center_local, shell_size, Color(0.15, 0.36, 0.76, 0.16), Color(0.86, 0.96, 1.0, 0.94), 5 + mini(intensity, 6), 14, POST_MATCH_BAR_LINGER_Z_INDEX, lifetime, Vector2(1.03, 1.06))
	_spawn_local_effect_panel("ArmorBarShieldGlass", center_local + Vector2(0.0, -shell_size.y * 0.08), Vector2(shell_size.x * 0.92, shell_size.y * 0.42), Color(0.76, 0.92, 1.0, 0.12), Color(0.92, 0.98, 1.0, 0.50), 2, 999, POST_MATCH_BAR_LINGER_Z_INDEX + 1, lifetime * 0.82, Vector2(1.04, 0.82), lifetime * 0.05)
	var pulse_count := 2 + mini(intensity, 5)
	for i in range(pulse_count):
		_spawn_local_effect_panel("ArmorBarShieldPulse", center_local, shell_size * (0.88 + float(i) * 0.055), Color(0.22, 0.60, 1.0, 0.08), Color(0.88, 0.98, 1.0, 0.62), 2 + mini(intensity, 4), 16, POST_MATCH_BAR_LINGER_Z_INDEX, lifetime * 0.58, Vector2(1.10 + float(i) * 0.05, 1.18 + float(i) * 0.03), lifetime * (0.12 + float(i) * 0.09))
	var block_count := 5 + intensity * 2
	for i in range(block_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var y := (float(i) / float(maxi(1, block_count - 1)) - 0.5) * shell_size.y * 0.54
		var start := center_local + Vector2(side * shell_size.x * 0.50, y)
		_spawn_local_effect_panel("ArmorBarShieldBlockSpark", start, Vector2(34 + intensity * 4, 6 + intensity), Color(0.84, 0.96, 1.0, 0.72), Color(0.96, 1.0, 1.0, 0.86), 1, 999, POST_MATCH_BAR_LINGER_Z_INDEX + 1, lifetime * 0.42, Vector2(0.58, 0.62), lifetime * 0.10 + float(i % 5) * lifetime * 0.036, Vector2(-side * (28.0 + float(intensity) * 4.0), sin(float(i)) * 6.0), 0.0, 0.0 if side < 0.0 else PI)


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_BAR_LINGER_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func _spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _runtime_primitive_presenter == null:
		return
	_runtime_primitive_presenter.spawn_local_effect_panel(name, center_local, size, fill, border, border_width, corner_radius, z_index, lifetime, target_scale, delay, move_offset, spin, rotation, move_ease)
