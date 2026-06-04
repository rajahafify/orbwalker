extends RefCounted
class_name CombatMasteryCastVfxPresenter

const POST_MATCH_CAST_Z_INDEX := 128
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS := [0, 12, 16, 20, 24, 29, 34, 39, 44]

var _runtime_sprite_presenter: Variant
var _runtime_primitive_presenter: Variant
var _vfx_profile: Variant


func bind(dependencies: Dictionary) -> void:
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")
	_vfx_profile = dependencies.get("vfx_profile")


func spawn_cast_spool(source_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var duration := maxf(0.16, lifetime)
	var charge_size := Vector2(34, 34) + Vector2(6, 6) * float(intensity)
	_spawn_runtime_sprite_local("MasteryCastRuntimeBloom", "soft_glow", source_local, Vector2(110, 110) + Vector2(14, 14) * float(intensity), Color(accent.r, accent.g, accent.b, 0.30), duration, Vector2(1.24 + float(intensity) * 0.04, 1.24 + float(intensity) * 0.04), 0.0, Vector2.ZERO, 0.12, POST_MATCH_CAST_Z_INDEX)
	_spawn_runtime_sprite_local("MasteryCastRuntimeCore", "spark", source_local, charge_size * 1.34, Color(core.r, core.g, core.b, 0.96), duration * 0.84, Vector2(0.82, 0.82), duration * 0.12, Vector2.ZERO, 0.38, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_local_effect_panel("MasteryCastChargeCore", source_local, charge_size, Color(dark.r, dark.g, dark.b, 0.52), Color(core.r, core.g, core.b, 1.0), 4 + mini(intensity, 5), 999, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.96, Vector2(1.52 + float(intensity) * 0.04, 1.52 + float(intensity) * 0.04), 0.0, Vector2.ZERO, 0.18)
	_spawn_local_effect_panel("MasteryCastChargeBloom", source_local, Vector2(82, 82) + Vector2(9, 9) * float(intensity), Color(accent.r, accent.g, accent.b, 0.12), Color(core.r, core.g, core.b, 0.58), 2, 999, POST_MATCH_CAST_Z_INDEX, duration, Vector2(1.32 + float(intensity) * 0.03, 1.32 + float(intensity) * 0.03), duration * 0.08)
	var ring_count := 3 + mini(intensity, 5)
	for i in range(ring_count):
		var delay := duration * 0.09 * float(i)
		var size := Vector2(54, 54) + Vector2(10, 10) * float(i)
		_spawn_local_effect_panel("MasteryCastSpool", source_local, size, Color(accent.r, accent.g, accent.b, 0.18), Color(core.r, core.g, core.b, 0.94), 3 + mini(intensity, 6), 999, POST_MATCH_CAST_Z_INDEX, duration * 0.72, Vector2(1.42 + float(i) * 0.10, 1.42 + float(i) * 0.10), delay)
	var particle_count := 8 + intensity * 4
	for i in range(particle_count):
		var angle := TAU * float(i) / float(particle_count)
		var radius := 22.0 + float(i % 4) * 6.0
		var start := Vector2(cos(angle), sin(angle)) * radius
		var end := start.normalized() * maxf(6.0, radius * 0.22)
		var size := Vector2(7 + intensity, 7 + intensity)
		var particle_color := core if i % 2 == 0 else accent
		if orb_id == OrbType.Id.FIRE:
			end += Vector2(0.0, -22.0 - float(intensity) * 2.0)
			size = Vector2(8 + intensity, 13 + intensity * 2)
		elif orb_id == OrbType.Id.ICE:
			end += Vector2(sin(float(i)) * 18.0, -8.0)
			size = Vector2(5 + intensity, 15 + intensity * 2)
		elif orb_id == OrbType.Id.EARTH:
			end += Vector2(cos(float(i) * 0.7) * 18.0, 10.0)
			size = Vector2(11 + intensity * 2, 8 + intensity)
			particle_color = dark.lightened(0.24)
		_spawn_local_effect_panel("MasteryCastSpoolParticle", source_local + start, size, Color(particle_color.r, particle_color.g, particle_color.b, 0.76), Color(core.r, core.g, core.b, 0.88), 1, 999 if orb_id != OrbType.Id.ICE else 4, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.68, Vector2(0.52, 0.52), float(i % 5) * duration * 0.022, end - start, 0.55)
	match orb_id:
		OrbType.Id.FIRE:
			_spawn_mastery_fire_spool(source_local, duration, intensity, accent, core)
		OrbType.Id.ICE:
			_spawn_mastery_ice_spool(source_local, duration, intensity, accent, core)
		OrbType.Id.EARTH:
			_spawn_mastery_earth_spool(source_local, duration, intensity, accent, core, dark)
	if orb_id == OrbType.Id.EARTH:
		for i in range(5):
			var offset := Vector2((float(i) - 2.0) * 18.0, 28.0 + sin(float(i)) * 4.0)
			_spawn_local_effect_panel("MasteryCastEarthShake", source_local + offset, Vector2(24 + intensity * 3, 5 + intensity), Color(accent.r, accent.g, accent.b, 0.36), Color(core.r, core.g, core.b, 0.72), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.48, Vector2(1.18, 0.62), float(i) * duration * 0.045, Vector2(sin(float(i) * 1.8) * 8.0, 0.0))


func spawn_cast_travel(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, delay: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var direction := delta / distance
	var normal := Vector2(-direction.y, direction.x)
	var angle := delta.angle()
	var duration := maxf(0.16, lifetime)
	match orb_id:
		OrbType.Id.FIRE:
			_spawn_mastery_fire_launch(source_local, delta, normal, angle, duration, delay, intensity, accent, core)
		OrbType.Id.ICE:
			_spawn_mastery_ice_launch(source_local, delta, direction, normal, angle, distance, duration, delay, intensity, accent, core)
		OrbType.Id.EARTH:
			_spawn_mastery_earth_launch(source_local, delta, direction, normal, angle, duration, delay, intensity, accent, core, dark)
		_:
			_spawn_mastery_generic_launch(source_local, delta, angle, duration, delay, intensity, accent, core)


func spawn_source_pulse(source_local: Vector2, orb_id: int, lifetime: float) -> void:
	var accent := OrbType.color(orb_id)
	_spawn_runtime_sprite_local("MasterySourcePulseGlow", "soft_glow", source_local, Vector2(118, 118), Color(accent.r, accent.g, accent.b, 0.34), lifetime, Vector2(1.55, 1.55), 0.0, Vector2.ZERO, 0.0, 126)
	_spawn_runtime_sprite_local("MasterySourcePulseRing", "ripple", source_local, Vector2(96, 96), Color(accent.r, accent.g, accent.b, 0.92), lifetime, Vector2(1.55, 1.55), 0.0, Vector2.ZERO, 0.0, 127)


func _spawn_mastery_fire_spool(source_local: Vector2, duration: float, intensity: int, _accent: Color, core: Color) -> void:
	var tongue_count := 5 + intensity
	for i in range(tongue_count):
		var lane := (float(i) / float(maxi(1, tongue_count - 1)) - 0.5) * (54.0 + float(intensity) * 4.0)
		var start := Vector2(lane, 22.0 + float(i % 3) * 4.0)
		_spawn_local_effect_panel("MasteryCastFireBuild", source_local + start, Vector2(12 + intensity * 2, 34 + intensity * 5), Color(1.0, 0.16, 0.02, 0.48), Color(core.r, core.g, core.b, 0.88), 1, 999, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.70, Vector2(0.58, 1.38), duration * (0.16 + float(i % 4) * 0.035), Vector2(sin(float(i)) * 8.0, -50.0 - float(intensity) * 4.0), 0.30, -PI * 0.5)
	_spawn_local_effect_panel("MasteryCastFireFlash", source_local + Vector2(0.0, -8.0), Vector2(54, 70) + Vector2(8, 10) * float(intensity), Color(1.0, 0.23, 0.02, 0.24), Color(1.0, 0.86, 0.30, 0.96), 3, 999, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.46, Vector2(0.66, 1.18), duration * 0.48, Vector2(0.0, -18.0), 0.22)


func _spawn_mastery_ice_spool(source_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var breeze_count := 6 + intensity
	for i in range(breeze_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var y := (float(i) / float(maxi(1, breeze_count - 1)) - 0.5) * (70.0 + float(intensity) * 5.0)
		var start := Vector2(side * (48.0 + float(i % 3) * 8.0), y)
		_spawn_local_effect_panel("MasteryCastIceBreathe", source_local + start, Vector2(46 + intensity * 5, 5 + intensity), Color(accent.r, accent.g, accent.b, 0.25), Color(core.r, core.g, core.b, 0.80), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.76, Vector2(0.72, 0.46), duration * (0.10 + float(i % 5) * 0.032), Vector2(-side * (46.0 + float(intensity) * 4.0), sin(float(i)) * 12.0), 0.0, side * 0.10)
	var crystal_count := 4 + mini(intensity, 6)
	for i in range(crystal_count):
		var angle := TAU * float(i) / float(crystal_count)
		var start := Vector2(cos(angle), sin(angle)) * (22.0 + float(intensity) * 2.0)
		_spawn_local_effect_panel("MasteryCastIceCondense", source_local + start, Vector2(7 + intensity, 22 + intensity * 2), Color(core.r, core.g, core.b, 0.54), Color(0.94, 1.0, 1.0, 0.94), 1, 4, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.66, Vector2(0.58, 0.92), duration * (0.24 + float(i % 3) * 0.045), -start * 0.68, 0.18, angle + PI * 0.5)


func _spawn_mastery_earth_spool(source_local: Vector2, duration: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
	var root_count := 6 + intensity
	for i in range(root_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var start := Vector2(side * (20.0 + float(i % 4) * 12.0), 30.0 + sin(float(i)) * 5.0)
		_spawn_local_effect_panel("MasteryCastEarthRoot", source_local + start, Vector2(30 + intensity * 4, 6 + intensity), Color(dark.r, dark.g, dark.b, 0.64), Color(core.r, core.g, core.b, 0.70), 1, 4, POST_MATCH_CAST_Z_INDEX, duration * 0.72, Vector2(1.22, 0.66), duration * (0.10 + float(i % 4) * 0.04), Vector2(-side * (18.0 + float(intensity) * 2.0), sin(float(i) * 1.7) * 7.0), 0.06, sin(float(i)) * 0.34)
	var rumble_count := 4 + mini(intensity, 5)
	for i in range(rumble_count):
		var offset := Vector2((float(i) - float(rumble_count - 1) * 0.5) * 18.0, 42.0 + sin(float(i)) * 6.0)
		_spawn_local_effect_panel("MasteryCastEarthRumble", source_local + offset, Vector2(36 + intensity * 5, 5 + intensity), Color(accent.r, accent.g, accent.b, 0.28), Color(core.r, core.g, core.b, 0.62), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.50, Vector2(1.34, 0.50), duration * (0.30 + float(i) * 0.036), Vector2(sin(float(i) * 2.3) * 10.0, 0.0), 0.0)


func _mastery_launch_scale(intensity: int) -> float:
	return 1.0 + float(maxi(0, intensity - 1)) * 0.14


func _spawn_mastery_fire_launch(source_local: Vector2, delta: Vector2, normal: Vector2, angle: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_runtime_sprite_local("MasteryFireLaunchBloom", "soft_glow", source_local, Vector2(72 + intensity * 10, 54 + intensity * 6) * launch_scale, Color(1.0, 0.20, 0.04, 0.42), duration, Vector2(0.72, 0.72), delay, delta, 0.46, POST_MATCH_CAST_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_runtime_sprite_local("MasteryFireLaunchCore", "ray", source_local, Vector2(82 + intensity * 10, 18 + intensity * 2) * launch_scale, Color(core.r, core.g, core.b, 0.96), duration * 0.92, Vector2(0.62, 0.50), delay, delta, 0.22, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_local_effect_panel("MasteryFireProjectile", source_local, Vector2(44 + intensity * 5, 28 + intensity * 3) * launch_scale, Color(1.0, 0.24, 0.04, 0.86), Color(core.r, core.g, core.b, 0.98), 2, 999, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration, Vector2(0.72, 0.72), delay, delta, 1.2, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	var trail_count := _runtime_particle_count(intensity, 1.25)
	for i in range(trail_count):
		var side := (float(i % 5) - 2.0) * 5.0 * launch_scale
		var back := -float(i % 4) * 12.0 * launch_scale
		var start := normal * side + delta.normalized() * back
		var color := accent if i % 2 == 0 else core
		_spawn_local_effect_panel("MasteryFireTrail", source_local + start, Vector2(22 + intensity * 4, 8 + intensity) * launch_scale, Color(color.r, color.g, color.b, 0.62), Color(core.r, core.g, core.b, 0.80), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.72, Vector2(0.46, 0.62), delay + float(i) * duration * 0.018, delta + normal * sin(float(i)) * 18.0 * launch_scale + delta.normalized() * 24.0 * launch_scale, 0.35, angle, Tween.EASE_IN_OUT as Tween.EaseType)


func _spawn_mastery_ice_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_runtime_sprite_local("MasteryIceLaunchMist", "smoke", source_local, Vector2(distance * 0.28, 54 + intensity * 7) * launch_scale, Color(accent.r, accent.g, accent.b, 0.24), duration, Vector2(1.08, 0.72), delay, delta, 0.0, POST_MATCH_CAST_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_runtime_sprite_local("MasteryIceLaunchColdRay", "ray", source_local, Vector2(distance * (0.22 + float(intensity) * 0.012), 10 + intensity) * launch_scale, Color(core.r, core.g, core.b, 0.74), duration * 0.92, Vector2(1.18, 0.40), delay, delta, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	var breeze_count := 6 + intensity * 4 + maxi(0, intensity - 4) * 3
	for i in range(breeze_count):
		var lane := (float(i) / float(maxi(1, breeze_count - 1)) - 0.5) * (52.0 + float(intensity) * 8.0) * launch_scale
		var start := normal * lane - direction * float(i % 3) * 10.0 * launch_scale
		_spawn_local_effect_panel("MasteryIceBreeze", source_local + start, Vector2(distance * (0.20 + float(i % 3) * 0.025 + float(intensity) * 0.010), (4 + intensity) * launch_scale), Color(accent.r, accent.g, accent.b, 0.26), Color(core.r, core.g, core.b, 0.72), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.82, Vector2(1.24, 0.46), delay + float(i) * duration * 0.035, delta + normal * sin(float(i) * 1.7) * 22.0 * launch_scale, 0.0, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	var shard_count := 8 + intensity * 5 + maxi(0, intensity - 4) * 3
	for i in range(shard_count):
		var start := normal * ((float(i % 7) - 3.0) * 7.0 * launch_scale) - direction * float(i % 4) * 7.0 * launch_scale
		_spawn_local_effect_panel("MasteryIceShardLaunch", source_local + start, Vector2(8 + intensity, 22 + intensity * 3) * launch_scale, Color(core.r, core.g, core.b, 0.82), Color(0.92, 1.0, 1.0, 0.94), 1, 4, POST_MATCH_EFFECT_FRONT_Z_INDEX, duration * 0.72, Vector2(0.50, 0.72), delay + float(i) * duration * 0.026, delta + normal * sin(float(i) * 2.1) * 32.0 * launch_scale, 0.45, angle + PI * 0.5, Tween.EASE_IN_OUT as Tween.EaseType)


func _spawn_mastery_earth_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, duration: float, delay: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_runtime_sprite_local("MasteryEarthLaunchDustWake", "smoke", source_local + direction * 28.0, Vector2(96 + intensity * 16, 42 + intensity * 5) * launch_scale, Color(dark.r, dark.g, dark.b, 0.32), duration * 0.92, Vector2(1.24, 0.68), delay, delta * 0.82, 0.08, POST_MATCH_CAST_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_runtime_sprite_local("MasteryEarthLaunchRunicCrack", "ray", source_local + direction * 18.0, Vector2(74 + intensity * 13, 9 + intensity) * launch_scale, Color(core.r, core.g, core.b, 0.70), duration * 0.82, Vector2(1.18, 0.38), delay, delta * 0.96, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	var segment_count := 10 + intensity * 5 + maxi(0, intensity - 4) * 4
	for i in range(segment_count):
		var progress := float(i) / float(maxi(1, segment_count - 1))
		var wave := sin(progress * TAU * 1.75) * (18.0 + float(intensity) * 4.0) * launch_scale
		var center := source_local + delta * progress + normal * wave
		var segment_delay := delay + duration * progress * 0.72
		var forward := direction * (24.0 + float(intensity) * 6.0) * launch_scale
		_spawn_local_effect_panel("MasteryEarthSlither", center, Vector2(30 + intensity * 5, 10 + intensity * 2) * launch_scale, Color(dark.r, dark.g, dark.b, 0.68), Color(core.r, core.g, core.b, 0.76), 1, 5, POST_MATCH_CAST_Z_INDEX, duration * 0.34, Vector2(1.10, 0.58), segment_delay, forward + normal * sin(float(i)) * 8.0 * launch_scale, 0.15, angle + sin(float(i)) * 0.28, Tween.EASE_IN_OUT as Tween.EaseType)
		if i % 2 == 0:
			_spawn_local_effect_panel("MasteryEarthCrack", center + normal * wave * 0.22, Vector2(42 + intensity * 6, 5 + intensity * 2) * launch_scale, Color(accent.r, accent.g, accent.b, 0.28), Color(core.r, core.g, core.b, 0.62), 1, 999, POST_MATCH_CAST_Z_INDEX, duration * 0.28, Vector2(1.26, 0.42), segment_delay, forward * 0.55, 0.0, angle, Tween.EASE_IN_OUT as Tween.EaseType)


func _spawn_mastery_generic_launch(source_local: Vector2, delta: Vector2, angle: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_local_effect_panel("MasteryGenericLaunch", source_local, Vector2(28 + intensity * 3, 18 + intensity * 2) * launch_scale, Color(accent.r, accent.g, accent.b, 0.72), Color(core.r, core.g, core.b, 0.90), 2, 999, POST_MATCH_CAST_Z_INDEX, duration, Vector2(0.70, 0.70), delay, delta, 0.35, angle, Tween.EASE_IN_OUT as Tween.EaseType)


func _runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	var index := clampi(intensity, 1, POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS.size() - 1)
	var base_count := int(POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS[index])
	var count := int(round(float(base_count) * maxf(0.1, multiplier)))
	return clampi(count, 1, POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST)


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func _spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _runtime_primitive_presenter == null:
		return
	_runtime_primitive_presenter.spawn_local_effect_panel(name, center_local, size, fill, border, border_width, corner_radius, z_index, lifetime, target_scale, delay, move_offset, spin, rotation, move_ease)
