extends RefCounted
class_name CombatMasteryFillVfxPresenter

const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_CAST_Z_INDEX := 128
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS := [0, 12, 16, 20, 24, 29, 34, 39, 44]

var _runtime_sprite_presenter: Variant
var _vfx_profile: Variant


func bind(dependencies: Dictionary) -> void:
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_vfx_profile = dependencies.get("vfx_profile")


func spawn_fill_stream(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, intensity: int, streams_enabled: bool, flare_enabled: bool) -> void:
	if not streams_enabled:
		spawn_reduced_motion(source_local, target_local, orb_id, lifetime, intensity)
		return
	if flare_enabled:
		spawn_source_flash(source_local, orb_id, lifetime, intensity)
	spawn_stream_rays(source_local, target_local, orb_id, lifetime, intensity)
	spawn_stream_sparks(source_local, target_local, orb_id, lifetime, intensity)
	if flare_enabled:
		spawn_impact(target_local, orb_id, lifetime, intensity)


func spawn_reduced_motion(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	_spawn_runtime_sprite_local("MasteryFillReducedSourceFlash", "soft_glow", source_local, Vector2(76, 76) + Vector2(8, 8) * float(intensity), Color(accent.r, accent.g, accent.b, 0.40), lifetime * 0.54, Vector2(0.64, 0.64), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_runtime_sprite_local("MasteryFillReducedImpactGlow", "soft_glow", target_local, Vector2(116, 116) + Vector2(10, 10) * float(intensity), Color(core.r, core.g, core.b, 0.58), lifetime * 0.72, Vector2(1.34, 1.34), lifetime * 0.05, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 1)
	_spawn_runtime_sprite_local("MasteryFillReducedImpactRing", "ripple", target_local, Vector2(88, 88) + Vector2(7, 7) * float(intensity), Color(core.r, core.g, core.b, 0.96), lifetime * 0.62, Vector2(1.52, 1.52), lifetime * 0.05, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 2)


func spawn_source_flash(source_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	_spawn_runtime_sprite_local("MasteryFillSourceBloom", "soft_glow", source_local, Vector2(104, 104) + Vector2(10, 10) * float(intensity), Color(accent.r, accent.g, accent.b, 0.48), lifetime * 0.66, Vector2(0.72, 0.72), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("MasteryFillSourceCore", "spark", source_local, Vector2(34, 34) + Vector2(4, 4) * float(intensity), Color(core.r, core.g, core.b, 1.0), lifetime * 0.50, Vector2(0.62, 0.62), 0.0, Vector2.ZERO, 0.34, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func spawn_stream_rays(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var direction := delta / distance
	var normal := Vector2(-direction.y, direction.x)
	var angle := delta.angle()
	_spawn_runtime_sprite_local(
		"MasteryFillStreamCoreBeam",
		"ray",
		source_local - direction * distance * 0.03,
		Vector2(distance * 0.72, 24.0 + float(intensity) * 2.8),
		Color(core.r, core.g, core.b, 0.88),
		lifetime * 0.96,
		Vector2(0.48, 0.54),
		0.0,
		delta * 1.02,
		0.0,
		POST_MATCH_EFFECT_FRONT_Z_INDEX + 1,
		angle,
		Tween.EASE_IN_OUT as Tween.EaseType
	)
	_spawn_runtime_sprite_local(
		"MasteryFillStreamWideGlow",
		"soft_glow",
		source_local + delta * 0.45,
		Vector2(distance * 0.72, 76.0 + float(intensity) * 6.0),
		Color(accent.r, accent.g, accent.b, 0.30),
		lifetime * 0.90,
		Vector2(1.04, 0.72),
		0.0,
		delta * 0.16,
		0.0,
		POST_MATCH_CAST_Z_INDEX - 1,
		angle,
		Tween.EASE_IN_OUT as Tween.EaseType
	)
	var ray_count := clampi(2 + int(ceil(float(intensity) * 0.70)), 3, 8)
	for i in range(ray_count):
		var lane := float(i) - float(ray_count - 1) * 0.5
		var side_offset := normal * lane * (11.0 + float(intensity) * 2.0)
		var lead := direction * distance * 0.04
		var arc := normal * sin(float(i) * 1.7 + float(orb_id)) * (16.0 + float(intensity) * 4.0)
		var start := source_local + side_offset - lead
		var travel := delta + arc - side_offset * 0.6
		var delay := float(i) * lifetime * 0.035
		var tint := core if i == 0 else accent
		_spawn_runtime_sprite_local(
			"MasteryFillStreamRay",
			"ray",
			start,
			Vector2(distance * (0.54 + float(intensity) * 0.04), 18.0 + float(intensity) * 2.8),
			Color(tint.r, tint.g, tint.b, 0.92 if i == 0 else 0.74),
			lifetime * 0.94,
			Vector2(0.50, 0.54),
			delay,
			travel,
			0.0,
			POST_MATCH_CAST_Z_INDEX,
			angle + sin(float(i) * 2.3) * 0.08,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func spawn_stream_sparks(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var direction := delta / distance
	var normal := Vector2(-direction.y, direction.x)
	var spark_count := _runtime_particle_count(intensity, 1.15)
	for i in range(spark_count):
		var progress := float(i % 9) / 9.0
		var wave := sin(float(i) * 1.61 + float(orb_id)) * (22.0 + float(intensity) * 3.4)
		var start := source_local + delta * (progress * 0.22) + normal * wave
		var travel := delta * (0.72 + progress * 0.22) - normal * wave * 0.55 + direction * float(i % 4) * 12.0
		var size := Vector2(11.0 + float(intensity) * 1.4, 11.0 + float(intensity) * 1.4)
		var color := core if i % 3 == 0 else accent
		_spawn_runtime_sprite_local(
			"MasteryFillSpark",
			"spark",
			start,
			size,
			Color(color.r, color.g, color.b, 0.94),
			lifetime * (0.72 + float(i % 3) * 0.07),
			Vector2(0.48, 0.48),
			float(i) * lifetime * 0.012,
			travel,
			0.34,
			POST_MATCH_EFFECT_FRONT_Z_INDEX + 1,
			0.0,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func spawn_impact(target_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors: Dictionary = _vfx_profile.mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var impact_delay := lifetime * 0.34
	var base_size := Vector2(104, 104) + Vector2(11, 11) * float(intensity)
	_spawn_runtime_sprite_local("MasteryFillImpactGlow", "soft_glow", target_local, base_size * 2.05, Color(accent.r, accent.g, accent.b, 0.72), lifetime * 0.76, Vector2(1.50, 1.50), impact_delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 1)
	_spawn_runtime_sprite_local("MasteryFillImpactCore", "spark", target_local, base_size * 0.64, Color(core.r, core.g, core.b, 1.0), lifetime * 0.52, Vector2(0.82, 0.82), impact_delay, Vector2.ZERO, 0.36, POST_MATCH_EFFECT_FRONT_Z_INDEX + 3)
	_spawn_runtime_sprite_local("MasteryFillImpactRing", "ripple", target_local, base_size * 1.08, Color(core.r, core.g, core.b, 1.0), lifetime * 0.70, Vector2(1.92, 1.92), impact_delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 2)
	_spawn_runtime_sprite_local("MasteryFillImpactHalo", "ripple", target_local, base_size * 1.36, Color(accent.r, accent.g, accent.b, 0.72), lifetime * 0.82, Vector2(1.68, 1.68), impact_delay + lifetime * 0.08, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func _runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	var index := clampi(intensity, 1, POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS.size() - 1)
	var base_count := int(POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS[index])
	var count := int(round(float(base_count) * maxf(0.1, multiplier)))
	return clampi(count, 1, POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST)


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)
