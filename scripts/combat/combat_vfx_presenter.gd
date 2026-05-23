extends RefCounted
class_name CombatVfxPresenter

const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")

var _vfx_layer: Control
var _visual_registry: Variant
var _player_loadout_hud: Variant
var _elemental_mastery_cards: Control
var _timer_owner: Node
var _max_vfx_overlay: Variant
var _post_match_additive_material: CanvasItemMaterial
var _post_match_runtime_material: ShaderMaterial
var _post_match_runtime_textures: Dictionary = {}
var _post_match_vfx_speed_scale := DEFAULT_POST_MATCH_VFX_SPEED_SCALE
var _post_match_vfx_quality := DEFAULT_POST_MATCH_VFX_QUALITY

const RESULT_VFX_TIER_THRESHOLDS := {
	"fire": [6, 10, 16],
	"ice": [6, 10, 16],
	"earth": [6, 10, 16],
	"damage": [6, 10, 16],
	"heart": [4, 8, 12],
	"armor": [4, 8, 12],
	"gold": [3, 6, 10],
}
const RESULT_VFX_DEFAULT_THRESHOLDS := [6, 10, 16]
const RESULT_VFX_TIER_SIZE_SCALES := [1.0, 1.5, 2.0, 3.0]
const RESULT_VFX_TIER_LIFETIME_SCALES := [1.0, 1.07, 1.14, 1.22]
const RESULT_VFX_TIER_ALPHA := [0.84, 0.91, 0.97, 1.0]
const RESULT_VFX_TIER_BRIGHTNESS := [1.0, 1.07, 1.14, 1.22]
const DEFAULT_POST_MATCH_VFX_SPEED_SCALE := 0.55
const POST_MATCH_SCREEN_EVENT_Z_INDEX := 120
const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_CAST_Z_INDEX := 128
const POST_MATCH_BAR_LINGER_Z_INDEX := 131
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const FORCE_MAX_COMBAT_VFX := true
const POST_MATCH_VFX_QUALITY_HIGH := "high"
const POST_MATCH_VFX_QUALITY_LOW := "low"
const POST_MATCH_VFX_QUALITY_OPTIONS: Array[String] = [
	POST_MATCH_VFX_QUALITY_HIGH,
	POST_MATCH_VFX_QUALITY_LOW,
]
const DEFAULT_POST_MATCH_VFX_QUALITY := POST_MATCH_VFX_QUALITY_LOW
const POST_MATCH_VFX_QUALITY_SETTING_PATH := "matchatro/combat/post_match_vfx_quality"
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_MAX_SCREEN_RAYS := 18
const POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS := 10
const POST_MATCH_RUNTIME_TEXTURE_KEYS: Array[String] = [
	"soft_glow",
	"ray",
	"spark",
	"smoke",
	"coin",
	"ripple",
	"shard",
	"shield",
]
const POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS := [0, 12, 16, 20, 24, 29, 34, 39, 44]
const ENEMY_ATTACK_CUE_SIZE := Vector2(88, 88)
const ENEMY_ATTACK_BOLT_SIZE := Vector2(44, 44)
const ENEMY_ATTACK_BEAM_THICKNESS := 10.0


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_max_vfx_overlay = COMBAT_MAX_VFX_OVERLAY_SCRIPT.new()
	_max_vfx_overlay.bind(dependencies)
	set_post_match_vfx_quality(_project_post_match_vfx_quality())


func set_post_match_vfx_speed_scale(speed_scale: float) -> void:
	_post_match_vfx_speed_scale = clampf(speed_scale, 0.25, 2.0)


func set_post_match_vfx_quality(quality: String) -> void:
	_post_match_vfx_quality = _normalized_post_match_vfx_quality(quality)


func post_match_vfx_quality() -> String:
	return _post_match_vfx_quality


func post_match_vfx_quality_options() -> Array[String]:
	return POST_MATCH_VFX_QUALITY_OPTIONS.duplicate()


func post_match_vfx_quality_uses_max_overlay() -> bool:
	return _post_match_vfx_quality == POST_MATCH_VFX_QUALITY_HIGH


func spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _visual_registry == null:
		return
	var texture: Texture2D = _visual_registry.vfx_texture(effect_name)
	if texture == null:
		return
	spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if texture == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_generic(global_center, draw_size, lifetime, modulate_color):
		return
	var sprite := TextureRect.new()
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.modulate = modulate_color
	sprite.z_index = POST_MATCH_EFFECT_Z_INDEX
	_vfx_layer.add_child(sprite)
	var local_center := _global_to_vfx_local(global_center)
	sprite.position = local_center - draw_size * 0.5
	_tween_fade_cleanup(sprite, lifetime)


func spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if global_center == Vector2.ZERO or _visual_registry == null:
		return
	var profile := replay_result_impact_profile(impact_kind, result_amount, draw_size, lifetime)
	var profile_size: Vector2 = profile.get("draw_size", draw_size)
	var profile_lifetime := float(profile.get("lifetime", lifetime))
	var profile_color: Color = profile.get("modulate_color", Color(1.0, 1.0, 1.0, 0.92))
	var tier_index := int(profile.get("tier_index", 0))
	var clean_kind := _result_vfx_kind_key(impact_kind)
	var intensity := _replay_effect_intensity(result_amount, tier_index)
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_replay_impact(global_center, clean_kind, profile_size, profile_lifetime, result_amount, intensity, replay_result_is_screen_wide(clean_kind, result_amount)):
		return
	var impact_texture: Texture2D = _visual_registry.mastery_impact_texture(impact_kind)
	if impact_texture == null:
		impact_texture = _visual_registry.vfx_texture("orb_clear")
	spawn_vfx_texture(impact_texture, global_center, profile_size, profile_lifetime, profile_color)
	_spawn_stylized_replay_effect(global_center, clean_kind, profile_size, profile_lifetime, result_amount, tier_index)


func spawn_armor_bar_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if global_center == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var tier_index := _result_vfx_tier_index(replay_result_vfx_tier("armor", result_amount))
	var intensity := _replay_effect_intensity(result_amount, tier_index)
	var duration := _post_match_vfx_lifetime(maxf(0.60, lifetime) * (1.70 + float(tier_index) * 0.16))
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_armor_linger(global_center, draw_size, duration, intensity):
		return
	_spawn_armor_bar_linger_effect(global_center, draw_size, duration, intensity)


func replay_result_impact_profile(impact_kind: String, result_amount: int, base_draw_size: Vector2, base_lifetime: float) -> Dictionary:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	var tier_index := _result_vfx_tier_index(tier)
	var size_scale: float = RESULT_VFX_TIER_SIZE_SCALES[tier_index]
	var lifetime_scale: float = RESULT_VFX_TIER_LIFETIME_SCALES[tier_index]
	return {
		"tier": tier,
		"tier_index": tier_index,
		"draw_size": base_draw_size * size_scale,
		"lifetime": _post_match_vfx_lifetime(base_lifetime * lifetime_scale),
		"modulate_color": _result_impact_modulate_color(impact_kind, tier),
	}


func replay_result_vfx_tier(impact_kind: String, result_amount: int) -> int:
	if result_amount <= 0:
		return 0
	var clean_kind := _result_vfx_kind_key(impact_kind)
	var thresholds: Array = RESULT_VFX_TIER_THRESHOLDS.get(clean_kind, RESULT_VFX_DEFAULT_THRESHOLDS)
	var medium_threshold := int(thresholds[0]) if thresholds.size() > 0 else int(RESULT_VFX_DEFAULT_THRESHOLDS[0])
	var high_threshold := int(thresholds[1]) if thresholds.size() > 1 else int(RESULT_VFX_DEFAULT_THRESHOLDS[1])
	var signature_threshold := int(thresholds[2]) if thresholds.size() > 2 else int(RESULT_VFX_DEFAULT_THRESHOLDS[2])
	if result_amount >= signature_threshold:
		return 4
	if result_amount >= high_threshold:
		return 3
	if result_amount >= medium_threshold:
		return 2
	return 1


func result_vfx_size_scale(impact_kind: String, result_amount: int) -> float:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	return RESULT_VFX_TIER_SIZE_SCALES[_result_vfx_tier_index(tier)]


func replay_result_is_screen_wide(impact_kind: String, result_amount: int) -> bool:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	return _result_vfx_tier_index(tier) >= RESULT_VFX_TIER_SIZE_SCALES.size() - 1


func post_match_runtime_vfx_caps() -> Dictionary:
	return {
		"max_particles_per_burst": POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST,
		"max_screen_rays": POST_MATCH_MAX_SCREEN_RAYS,
		"max_simultaneous_emitters": POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS,
		"texture_keys": POST_MATCH_RUNTIME_TEXTURE_KEYS.duplicate(),
	}


func post_match_runtime_texture(key: String) -> Texture2D:
	return _runtime_vfx_texture(key)


func max_combat_vfx_forced() -> bool:
	return FORCE_MAX_COMBAT_VFX and post_match_vfx_quality_uses_max_overlay()


func max_combat_vfx_available() -> bool:
	return _use_max_combat_vfx()


func _use_max_combat_vfx() -> bool:
	return FORCE_MAX_COMBAT_VFX and post_match_vfx_quality_uses_max_overlay() and _max_vfx_overlay != null and _max_vfx_overlay.is_available()


func _project_post_match_vfx_quality() -> String:
	return _normalized_post_match_vfx_quality(String(ProjectSettings.get_setting(POST_MATCH_VFX_QUALITY_SETTING_PATH, DEFAULT_POST_MATCH_VFX_QUALITY)))


func _normalized_post_match_vfx_quality(quality: String) -> String:
	var normalized := quality.strip_edges().to_lower()
	if POST_MATCH_VFX_QUALITY_OPTIONS.has(normalized):
		return normalized
	return DEFAULT_POST_MATCH_VFX_QUALITY


func post_match_runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	return _runtime_particle_count(intensity, multiplier)


func _post_match_vfx_lifetime(lifetime: float) -> float:
	return lifetime / maxf(0.25, _post_match_vfx_speed_scale)


func spawn_result_label(text: String, global_center: Vector2, kind: String, lifetime: float, offset: Vector2 = Vector2.ZERO, result_amount: int = 0) -> Label:
	if text.strip_edges() == "" or global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var label_scale := result_vfx_size_scale(kind, result_amount)
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.autowrap_mode = TextServer.AUTOWRAP_OFF as TextServer.AutowrapMode
	label.add_theme_font_size_override("font_size", int(round(42.0 * label_scale)))
	label.add_theme_color_override("font_color", _result_label_color(kind, true))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", int(round(11.0 * label_scale)))
	label.custom_minimum_size = Vector2(240, 70) * label_scale
	label.size = label.custom_minimum_size
	label.pivot_offset = label.size * 0.5
	label.z_index = 500
	label.z_as_relative = false
	_vfx_layer.add_child(label)
	label.move_to_front()
	var local_center := _global_to_vfx_local(global_center) + offset
	label.position = local_center - label.size * 0.5
	_tween_result_label_cleanup(label, lifetime)
	return label


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float = 0.26) -> void:
	if source_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_cue(source_global, lifetime):
		return
	var cue := _spawn_enemy_attack_pulse(source_global, ENEMY_ATTACK_CUE_SIZE, Color(1.0, 0.45, 0.38, 0.30), Color(1.0, 0.58, 0.42, 0.95), 7, 114)
	if cue == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		cue.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(cue, "scale", Vector2(1.18, 1.18), duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(cue, "modulate:a", 0.0, duration).set_delay(duration * 0.22)
	tween.finished.connect(func() -> void:
		if is_instance_valid(cue):
			cue.queue_free()
	)


func spawn_enemy_attack_travel(source_global: Vector2, target_global: Vector2, lifetime: float = 0.28) -> void:
	if source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_travel(source_global, target_global, lifetime):
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var source_local := _global_to_vfx_local(source_global)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var beam := ColorRect.new()
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	beam.color = Color(1.0, 0.56, 0.46, 0.62)
	beam.size = Vector2(distance, ENEMY_ATTACK_BEAM_THICKNESS)
	beam.pivot_offset = Vector2(0.0, ENEMY_ATTACK_BEAM_THICKNESS * 0.5)
	beam.position = source_local - Vector2(0.0, ENEMY_ATTACK_BEAM_THICKNESS * 0.5)
	beam.rotation = delta.angle()
	beam.z_index = 112
	_vfx_layer.add_child(beam)
	_tween_fade_cleanup(beam, lifetime)

	var bolt := _spawn_enemy_attack_pulse(source_global, ENEMY_ATTACK_BOLT_SIZE, Color(1.0, 0.52, 0.42, 0.88), Color(1.0, 0.78, 0.72, 1.0), 4, 116)
	if bolt == null:
		return
	var bolt_end := target_local - bolt.size * 0.5
	_tween_move_fade_cleanup(bolt, bolt_end, lifetime)


func spawn_enemy_attack_block_impact(target_global: Vector2, lifetime: float = 0.32, blocked_amount: int = 0) -> void:
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_impact(target_global, true, blocked_amount, lifetime):
		return
	spawn_replay_impact(target_global, "armor", Vector2(90, 90), lifetime, blocked_amount)
	var pulse := _spawn_enemy_attack_pulse(target_global, Vector2(62, 62), Color(0.30, 0.48, 0.72, 0.18), Color(0.78, 0.88, 1.0, 0.78), 4, 118)
	_tween_pulse_cleanup(pulse, lifetime, Vector2(1.16, 1.16))


func spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float = 0.32, hp_damage: int = 0) -> void:
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_impact(target_global, false, hp_damage, lifetime):
		return
	spawn_replay_impact(target_global, "damage", Vector2(90, 90), lifetime, hp_damage)
	var pulse := _spawn_enemy_attack_pulse(target_global, Vector2(70, 70), Color(1.0, 0.38, 0.32, 0.28), Color(1.0, 0.58, 0.48, 0.86), 5, 118)
	_tween_pulse_cleanup(pulse, lifetime, Vector2(1.18, 1.18))


func mastery_impact_kind(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.FIRE:
			return "fire"
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.ARMOR:
			return "armor"
		OrbType.Id.GOLD:
			return "gold"
		_:
			return "fire"


func _result_impact_modulate_color(impact_kind: String, tier: int) -> Color:
	var clean_kind := _result_vfx_kind_key(impact_kind)
	var base := Color(1.0, 1.0, 1.0, 1.0)
	match clean_kind:
		"fire":
			base = Color(1.0, 0.66, 0.42, 1.0)
		"ice":
			base = Color(0.68, 0.92, 1.0, 1.0)
		"earth":
			base = Color(0.72, 0.94, 0.58, 1.0)
		"heart":
			base = Color(0.72, 1.0, 0.78, 1.0)
		"armor":
			base = Color(0.82, 0.92, 1.0, 1.0)
		"gold":
			base = Color(1.0, 0.92, 0.5, 1.0)
		"damage":
			base = Color(1.0, 0.48, 0.38, 1.0)
	var tier_index := _result_vfx_tier_index(tier)
	var alpha: float = RESULT_VFX_TIER_ALPHA[tier_index]
	var brightness: float = RESULT_VFX_TIER_BRIGHTNESS[tier_index]
	return Color(
		clampf(base.r * brightness, 0.0, 1.0),
		clampf(base.g * brightness, 0.0, 1.0),
		clampf(base.b * brightness, 0.0, 1.0),
		alpha
	)


func _result_vfx_tier_index(tier: int) -> int:
	if tier <= 0:
		return 0
	return clampi(tier - 1, 0, RESULT_VFX_TIER_SIZE_SCALES.size() - 1)


func _result_vfx_kind_key(impact_kind: String) -> String:
	var clean_kind := impact_kind.strip_edges().to_lower()
	if clean_kind == "heal":
		return "heart"
	if clean_kind == "block":
		return "armor"
	if clean_kind == "damage":
		return "damage"
	return clean_kind


func _spawn_stylized_replay_effect(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, result_amount: int, tier_index: int) -> void:
	if global_center == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var intensity := _replay_effect_intensity(result_amount, tier_index)
	if replay_result_is_screen_wide(clean_kind, result_amount):
		_spawn_screen_wide_replay_event(global_center, clean_kind, lifetime, intensity)
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
		"armor":
			_spawn_armor_replay_effect(global_center, draw_size, lifetime, intensity)
		"gold":
			_spawn_gold_replay_effect(global_center, draw_size, lifetime, intensity)
		"damage":
			_spawn_damage_replay_effect(global_center, draw_size, lifetime, intensity)


func _replay_effect_intensity(result_amount: int, tier_index: int) -> int:
	var amount_bonus := int(floor(float(maxi(0, result_amount)) / 12.0))
	return clampi(tier_index + 1 + amount_bonus, 1, 8)


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
	var count := _runtime_particle_count(intensity, 1.22)
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
	var count := _runtime_particle_count(intensity, 1.05)
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
	var count := _runtime_particle_count(intensity, 1.06)
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
	var stream_count := _runtime_particle_count(intensity, 0.96)
	for i in range(stream_count):
		var x_offset := (float(i) / float(maxi(1, stream_count - 1)) - 0.5) * draw_size.x * 0.72
		var start := Vector2(x_offset, draw_size.y * 0.20)
		var travel := Vector2(sin(float(i) * 1.7) * 12.0, -draw_size.y * (0.50 + float(intensity) * 0.055))
		var color := Color(0.42, 1.0, 0.58 + 0.06 * float(i % 2), 0.86)
		_spawn_replay_streak(global_center, -PI * 0.5 + sin(float(i)) * 0.18, draw_size.y * (0.28 + float(intensity) * 0.035), 5.0 + float(intensity), color, lifetime * 0.74, float(i % 4) * 0.025, start)
		_spawn_replay_particle(global_center, start, travel, Vector2(9 + intensity, 9 + intensity), Color(0.82, 1.0, 0.78, 0.88), lifetime * 0.86, float(i % 4) * 0.025, 999)


func _spawn_armor_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchArmorShellGlow", "shield", center_local, draw_size * Vector2(1.32 + float(intensity) * 0.06, 1.54 + float(intensity) * 0.08), Color(0.52, 0.80, 1.0, 0.48), lifetime * 0.96, Vector2(1.06, 1.10), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchArmorRefraction", "ripple", center_local, draw_size * (1.28 + float(intensity) * 0.08), Color(0.90, 0.98, 1.0, 0.76), lifetime * 0.68, Vector2(1.22, 1.28), lifetime * 0.03, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX + 1)
	_spawn_replay_shield(global_center, draw_size * Vector2(0.92, 1.16), Color(0.18, 0.46, 0.84, 0.18), Color(0.82, 0.94, 1.0, 0.98), 7 + intensity, lifetime * 0.88)
	_spawn_replay_ring(global_center, draw_size * 0.86, Color(0.22, 0.58, 1.0, 0.10), Color(0.76, 0.90, 1.0, 0.86), 4 + intensity, lifetime * 0.58, Vector2(1.12, 1.12), 0.0)
	var hit_count := _runtime_particle_count(intensity, 0.46)
	for i in range(hit_count):
		var y_offset := (float(i) / float(maxi(1, hit_count - 1)) - 0.5) * draw_size.y * 0.55
		var side := -1.0 if i % 2 == 0 else 1.0
		var start := Vector2(side * draw_size.x * 0.48, y_offset)
		var angle := 0.0 if side < 0.0 else PI
		_spawn_replay_streak(global_center, angle, draw_size.x * 0.30, 8.0 + float(intensity), Color(0.86, 0.96, 1.0, 0.82), lifetime * 0.50, float(i % 4) * 0.018, start)


func _spawn_gold_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchGoldRewardBloom", "soft_glow", center_local, draw_size * (2.0 + float(intensity) * 0.14), Color(1.0, 0.68, 0.10, 0.34), lifetime * 0.98, Vector2(1.16, 1.16), 0.0, Vector2.ZERO, 0.12, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_replay_ring(global_center, draw_size * 0.92, Color(1.0, 0.74, 0.10, 0.14), Color(1.0, 0.92, 0.32, 0.98), 5 + intensity, lifetime * 0.74, Vector2(1.18, 1.18), 0.0)
	var coin_count := _runtime_particle_count(intensity, 1.18)
	for i in range(coin_count):
		var x_offset := (float(i % 9) / 8.0 - 0.5) * draw_size.x * (1.10 + float(intensity) * 0.08)
		var y_offset := -draw_size.y * (0.90 + 0.12 * float(i % 4))
		var travel := Vector2(sin(float(i) * 1.13) * 18.0, draw_size.y * (1.00 + float(intensity) * 0.07))
		var delay := float(i) * 0.018
		_spawn_replay_coin(global_center, Vector2(x_offset, y_offset), travel, Vector2(15 + intensity * 2, 18 + intensity * 2), lifetime * 1.15, delay)
	var sparkle_count := _runtime_particle_count(intensity, 0.54)
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


func _spawn_armor_bar_linger_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	var base_size := Vector2(maxf(180.0, draw_size.x), maxf(58.0, draw_size.y))
	var shell_size := Vector2(
		base_size.x * (1.08 + float(intensity) * 0.028),
		base_size.y * (1.04 + float(intensity) * 0.025)
	)
	_spawn_runtime_sprite_local("ArmorBarShieldBloom", "soft_glow", center_local, shell_size * Vector2(1.22, 1.72), Color(0.34, 0.68, 1.0, 0.22), lifetime, Vector2(1.08, 1.12), 0.0, Vector2.ZERO, 0.0, POST_MATCH_BAR_LINGER_Z_INDEX - 1)
	_spawn_runtime_sprite_local("ArmorBarShieldRuntimeShell", "shield", center_local, shell_size * Vector2(1.08, 1.36), Color(0.78, 0.92, 1.0, 0.50), lifetime * 0.96, Vector2(1.04, 1.08), 0.0, Vector2.ZERO, 0.0, POST_MATCH_BAR_LINGER_Z_INDEX + 1)
	_spawn_runtime_sprite_local("ArmorBarShieldRefraction", "ray", center_local + Vector2(0.0, -shell_size.y * 0.18), Vector2(shell_size.x * 0.96, 16.0 + float(intensity) * 2.0), Color(0.92, 0.98, 1.0, 0.62), lifetime * 0.58, Vector2(0.82, 0.42), lifetime * 0.12, Vector2(18.0, 0.0), 0.0, POST_MATCH_BAR_LINGER_Z_INDEX + 2)
	_spawn_local_effect_panel(
		"ArmorBarShieldLinger",
		center_local,
		shell_size,
		Color(0.15, 0.36, 0.76, 0.16),
		Color(0.86, 0.96, 1.0, 0.94),
		5 + mini(intensity, 6),
		14,
		POST_MATCH_BAR_LINGER_Z_INDEX,
		lifetime,
		Vector2(1.03, 1.06)
	)
	_spawn_local_effect_panel(
		"ArmorBarShieldGlass",
		center_local + Vector2(0.0, -shell_size.y * 0.08),
		Vector2(shell_size.x * 0.92, shell_size.y * 0.42),
		Color(0.76, 0.92, 1.0, 0.12),
		Color(0.92, 0.98, 1.0, 0.50),
		2,
		999,
		POST_MATCH_BAR_LINGER_Z_INDEX + 1,
		lifetime * 0.82,
		Vector2(1.04, 0.82),
		lifetime * 0.05
	)
	var pulse_count := 2 + mini(intensity, 5)
	for i in range(pulse_count):
		_spawn_local_effect_panel(
			"ArmorBarShieldPulse",
			center_local,
			shell_size * (0.88 + float(i) * 0.055),
			Color(0.22, 0.60, 1.0, 0.08),
			Color(0.88, 0.98, 1.0, 0.62),
			2 + mini(intensity, 4),
			16,
			POST_MATCH_BAR_LINGER_Z_INDEX,
			lifetime * 0.58,
			Vector2(1.10 + float(i) * 0.05, 1.18 + float(i) * 0.03),
			lifetime * (0.12 + float(i) * 0.09)
		)
	var block_count := 5 + intensity * 2
	for i in range(block_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var y := (float(i) / float(maxi(1, block_count - 1)) - 0.5) * shell_size.y * 0.54
		var start := center_local + Vector2(side * shell_size.x * 0.50, y)
		_spawn_local_effect_panel(
			"ArmorBarShieldBlockSpark",
			start,
			Vector2(34 + intensity * 4, 6 + intensity),
			Color(0.84, 0.96, 1.0, 0.72),
			Color(0.96, 1.0, 1.0, 0.86),
			1,
			999,
			POST_MATCH_BAR_LINGER_Z_INDEX + 1,
			lifetime * 0.42,
			Vector2(0.58, 0.62),
			lifetime * 0.10 + float(i % 5) * lifetime * 0.036,
			Vector2(-side * (28.0 + float(intensity) * 4.0), sin(float(i)) * 6.0),
			0.0,
			0.0 if side < 0.0 else PI
		)


func _spawn_screen_wide_replay_event(global_center: Vector2, clean_kind: String, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	clean_kind = _result_vfx_kind_key(clean_kind)
	var colors := _result_effect_colors(clean_kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var duration := maxf(0.50, lifetime * 0.98)
	var screen_center := layer_size * 0.5
	var impact_local := _global_to_vfx_local(global_center)
	var offensive := _screen_replay_is_offensive(clean_kind)
	var event_focus := _screen_replay_focus(layer_size, impact_local, clean_kind)
	var max_dim := maxf(layer_size.x, layer_size.y)
	var flash_center := screen_center
	var flash_size := layer_size * 1.08
	if offensive:
		flash_center = Vector2(layer_size.x * 0.5, event_focus.y)
		flash_size = Vector2(layer_size.x * 1.10, layer_size.y * 0.58)
	_spawn_runtime_sprite_local("PostMatchScreenRuntimeBloom", "soft_glow", flash_center, flash_size * Vector2(1.18, 1.08), Color(accent.r, accent.g, accent.b, 0.13), duration * 0.66, Vector2(1.08, 1.04), 0.0, Vector2.ZERO, 0.0, POST_MATCH_SCREEN_EVENT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchScreenRuntimeDistortion", "smoke", event_focus, Vector2(max_dim * 0.82, max_dim * (0.36 if offensive else 0.54)), Color(core.r, core.g, core.b, 0.13), duration * 0.68, Vector2(1.18, 1.06), duration * 0.04, Vector2(0.0, -layer_size.y * (0.03 if offensive else 0.01)), 0.05, POST_MATCH_SCREEN_EVENT_Z_INDEX + 1)
	_spawn_local_effect_panel(
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
	_spawn_local_effect_panel(
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
		_spawn_runtime_sprite_local(
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
		_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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
	var spark_count := _runtime_particle_count(intensity, 1.05)
	for i in range(spark_count):
		var start_y := lerpf(top_y, bottom_y, float(i % 7) / 6.0)
		var start := Vector2(layer_size.x * (float(i % 11) + 0.5) / 11.0, start_y)
		_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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
	var shard_count := _runtime_particle_count(intensity, 0.98)
	for i in range(shard_count):
		var x := layer_size.x * (float(i % 9) + 0.5) / 9.0
		var y := lerpf(top_y, bottom_y, float(i % 7) / 6.0)
		_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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
	var stone_count := _runtime_particle_count(intensity, 0.92)
	for i in range(stone_count):
		var x := layer_size.x * (float(i % 10) + 0.5) / 10.0
		var y := clampf(impact_local.y + layer_size.y * (0.04 + float(i % 5) * 0.035), layer_size.y * 0.14, layer_size.y * 0.54)
		_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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
	var mote_count := _runtime_particle_count(intensity, 1.08)
	for i in range(mote_count):
		var start := Vector2(layer_size.x * (float(i % 12) + 0.5) / 12.0, layer_size.y * (0.38 + float(i % 6) * 0.075))
		_spawn_local_effect_panel(
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
	_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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
	var coin_count := _runtime_particle_count(intensity, 1.45)
	for i in range(coin_count):
		var x := layer_size.x * (float(i % 13) + 0.5) / 13.0 + sin(float(i) * 1.9) * 18.0
		var y := -32.0 - float(i % 5) * 22.0
		_spawn_local_effect_panel(
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
	var sparkle_count := _runtime_particle_count(intensity, 0.86)
	for i in range(sparkle_count):
		var center := Vector2(layer_size.x * (float(i % 8) + 0.5) / 8.0, layer_size.y * (0.18 + float(i % 6) * 0.12))
		_spawn_local_effect_panel(
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
		_spawn_local_effect_panel(
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


func _spawn_replay_ring(global_center: Vector2, ring_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float, target_scale: Vector2, delay: float) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchRingGlow", "soft_glow", center_local, ring_size * 1.18, fill, lifetime * 0.92, target_scale, delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchRing", "ripple", center_local, ring_size, border, lifetime, target_scale, delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func _spawn_replay_shield(global_center: Vector2, shield_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_spawn_runtime_sprite_local("PostMatchShieldGlow", "soft_glow", center_local, shield_size * 1.22, fill, lifetime, Vector2(1.18, 1.12), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_Z_INDEX)
	_spawn_runtime_sprite_local("PostMatchShield", "shield", center_local, shield_size * 1.08, border, lifetime, Vector2(1.14, 1.08), 0.0, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX)


func _spawn_replay_streak(global_center: Vector2, angle: float, length: float, thickness: float, color: Color, lifetime: float, delay: float, offset: Vector2 = Vector2.ZERO) -> void:
	var center_local := _global_to_vfx_local(global_center) + offset
	_spawn_runtime_sprite_local("PostMatchStreak", "ray", center_local, Vector2(maxf(8.0, length), maxf(2.0, thickness)), color, lifetime, Vector2(1.20, 0.64), delay, Vector2.ZERO, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle)


func _spawn_replay_particle(global_center: Vector2, start_offset: Vector2, travel: Vector2, particle_size: Vector2, color: Color, lifetime: float, delay: float, corner_radius: int) -> void:
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


func _spawn_replay_coin(global_center: Vector2, start_offset: Vector2, travel: Vector2, coin_size: Vector2, lifetime: float, delay: float) -> void:
	var center_local := _global_to_vfx_local(global_center) + start_offset
	var spin := 0.95 + 0.10 * float(int(abs(start_offset.x)) % 5)
	_spawn_runtime_sprite_local("PostMatchCoinTrail", "ray", center_local + Vector2(0.0, -coin_size.y * 0.40), Vector2(coin_size.x * 1.45, maxf(3.0, coin_size.y * 0.24)), Color(1.0, 0.92, 0.32, 0.50), lifetime * 0.62, Vector2(0.52, 0.34), delay, travel * 0.92, 0.0, POST_MATCH_EFFECT_Z_INDEX, PI * 0.5)
	_spawn_runtime_sprite_local("PostMatchCoin", "coin", center_local, coin_size, Color(1.0, 0.78, 0.18, 0.98), lifetime, Vector2(0.78, 0.78), delay, travel, spin, POST_MATCH_EFFECT_FRONT_Z_INDEX, 0.18 * float(int(start_offset.x) % 7))


func _spawn_replay_sprite(texture_key: String, global_center: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_EFFECT_FRONT_Z_INDEX) -> void:
	if _visual_registry == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var texture: Texture2D = _visual_registry.vfx_texture(texture_key)
	if texture == null:
		return
	var sprite := TextureRect.new()
	sprite.name = "PostMatchSignature"
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	sprite.material = _post_match_runtime_shader_material()
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.pivot_offset = draw_size * 0.5
	sprite.position = _global_to_vfx_local(global_center) - draw_size * 0.5
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	sprite.z_index = z_index
	_vfx_layer.add_child(sprite)
	_tween_effect_cleanup(sprite, lifetime, target_scale, delay, move_offset, spin, color.a)


func _post_match_effect_material() -> CanvasItemMaterial:
	if _post_match_additive_material != null:
		return _post_match_additive_material
	_post_match_additive_material = CanvasItemMaterial.new()
	_post_match_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD as CanvasItemMaterial.BlendMode
	return _post_match_additive_material


func _post_match_runtime_shader_material() -> ShaderMaterial:
	if _post_match_runtime_material != null:
		return _post_match_runtime_material
	var shader := Shader.new()
	shader.code = "\n".join([
		"shader_type canvas_item;",
		"render_mode blend_add, unshaded;",
		"void fragment() {",
		"	vec4 texel = texture(TEXTURE, UV);",
		"	COLOR = vec4(texel.rgb * COLOR.rgb, texel.a * COLOR.a);",
		"}",
	])
	_post_match_runtime_material = ShaderMaterial.new()
	_post_match_runtime_material.shader = shader
	return _post_match_runtime_material


func _runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	var index := clampi(intensity, 1, POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS.size() - 1)
	var base_count := int(POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS[index])
	var count := int(round(float(base_count) * maxf(0.1, multiplier)))
	return clampi(count, 1, POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST)


func _spawn_runtime_impact_stack(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	var colors := _result_effect_colors(clean_kind)
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
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var texture := _runtime_vfx_texture(texture_key)
	if texture == null:
		return null
	var sprite := TextureRect.new()
	sprite.name = name
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	sprite.material = _post_match_runtime_shader_material()
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.pivot_offset = draw_size * 0.5
	sprite.position = center_local - draw_size * 0.5
	sprite.rotation = rotation
	sprite.z_index = z_index
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	_vfx_layer.add_child(sprite)
	_tween_effect_cleanup(sprite, lifetime, target_scale, delay, move_offset, spin, color.a, move_ease)
	return sprite


func _runtime_vfx_texture(key: String) -> Texture2D:
	key = key.strip_edges().to_lower()
	if not POST_MATCH_RUNTIME_TEXTURE_KEYS.has(key):
		key = "soft_glow"
	if _post_match_runtime_textures.has(key):
		return _post_match_runtime_textures[key]
	var texture: Texture2D = null
	match key:
		"soft_glow":
			texture = _make_soft_glow_texture(128)
		"ray":
			texture = _make_ray_texture()
		"spark":
			texture = _make_spark_texture(64)
		"smoke":
			texture = _make_smoke_texture(128)
		"coin":
			texture = _make_coin_texture(72)
		"ripple":
			texture = _make_ripple_texture(128)
		"shard":
			texture = _make_shard_texture()
		"shield":
			texture = _make_shield_texture(128)
	_post_match_runtime_textures[key] = texture
	return texture


func _make_soft_glow_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var distance := (Vector2(x, y) - center).length() / radius
			var alpha := pow(clampf(1.0 - distance, 0.0, 1.0), 2.15)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_ray_texture() -> Texture2D:
	var width := 256
	var height := 32
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8 as Image.Format)
	var center_y := float(height - 1) * 0.5
	for y in range(height):
		var y_falloff := pow(clampf(1.0 - abs(float(y) - center_y) / center_y, 0.0, 1.0), 2.2)
		for x in range(width):
			var t := float(x) / float(width - 1)
			var end_falloff := pow(sin(t * PI), 0.62)
			var core := 0.35 + 0.65 * pow(clampf(1.0 - abs(float(y) - center_y) / maxf(1.0, center_y * 0.28), 0.0, 1.0), 2.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, end_falloff * y_falloff * core))
	return ImageTexture.create_from_image(image)


func _make_spark_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var radial := clampf(1.0 - delta.length() / radius, 0.0, 1.0)
			var cross := maxf(
				pow(clampf(1.0 - abs(delta.y) / maxf(1.0, radius * 0.10), 0.0, 1.0), 2.0),
				pow(clampf(1.0 - abs(delta.x) / maxf(1.0, radius * 0.10), 0.0, 1.0), 2.0)
			)
			var alpha := maxf(pow(radial, 2.3), cross * pow(radial, 0.55))
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_smoke_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var distance := delta.length() / radius
			var base := pow(clampf(1.0 - distance, 0.0, 1.0), 1.25)
			var angle := atan2(delta.y, delta.x)
			var swirl := 0.5 + 0.5 * sin(angle * 5.0 + distance * 13.0)
			var noise := 0.5 + 0.5 * sin(float(x) * 0.173 + float(y) * 0.319 + sin(float(x + y) * 0.047) * 4.0)
			var alpha := base * (0.42 + swirl * 0.24 + noise * 0.24)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_coin_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.48
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var normalized := Vector2(delta.x / radius, delta.y / maxf(1.0, radius * 0.82))
			var distance := normalized.length()
			if distance <= 1.0:
				var edge := clampf((1.0 - distance) / 0.12, 0.0, 1.0)
				var inner := 0.52 + 0.48 * pow(edge, 0.55)
				var glint := pow(clampf(1.0 - (Vector2(x, y) - center + Vector2(radius * 0.26, radius * 0.24)).length() / (radius * 0.38), 0.0, 1.0), 2.0)
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(inner + glint * 0.36, 0.0, 1.0)))
			else:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
	return ImageTexture.create_from_image(image)


func _make_ripple_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var distance := (Vector2(x, y) - center).length() / radius
			var outer := clampf(1.0 - abs(distance - 0.70) / 0.055, 0.0, 1.0)
			var inner := clampf(1.0 - abs(distance - 0.44) / 0.030, 0.0, 1.0) * 0.42
			var alpha := maxf(pow(outer, 0.62), inner) * clampf(1.0 - maxf(0.0, distance - 0.94) / 0.06, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_shard_texture() -> Texture2D:
	var width := 64
	var height := 96
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(width - 1), float(height - 1)) * 0.5
	for y in range(height):
		for x in range(width):
			var nx: float = (float(x) - center.x) / (float(width) * 0.50)
			var ny: float = (float(y) - center.y) / (float(height) * 0.50)
			var diamond: float = absf(nx) * 0.88 + absf(ny)
			var alpha := clampf((1.0 - diamond) / 0.18, 0.0, 1.0)
			var spine := pow(clampf(1.0 - absf(nx) / 0.10, 0.0, 1.0), 2.0) * clampf(1.0 - absf(ny) * 0.72, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, maxf(alpha * 0.88, spine * 0.82)))
	return ImageTexture.create_from_image(image)


func _make_shield_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	for y in range(size):
		for x in range(size):
			var nx: float = (float(x) - center.x) / (float(size) * 0.48)
			var ny: float = (float(y) - center.y) / (float(size) * 0.48)
			var lower_taper := maxf(0.0, ny) * 0.34
			var upper_round := maxf(0.0, -ny - 0.10) * 0.12
			var allowed_width := 0.82 - lower_taper + upper_round
			var inside: bool = absf(nx) <= allowed_width and ny > -0.82 and ny < 0.94
			var alpha := 0.0
			if inside:
				var edge_x := clampf((allowed_width - absf(nx)) / 0.11, 0.0, 1.0)
				var edge_y := clampf(minf(ny + 0.82, 0.94 - ny) / 0.12, 0.0, 1.0)
				var edge := minf(edge_x, edge_y)
				var glass := pow(clampf(1.0 - (Vector2(nx + 0.18, ny + 0.26)).length() / 0.72, 0.0, 1.0), 1.8) * 0.24
				alpha = maxf(0.22 + glass, 1.0 - edge)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)


func _effect_stylebox(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(maxi(1, border_width))
	style.set_corner_radius_all(corner_radius)
	return style


func _tween_effect_cleanup(control: Control, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, target_alpha: float = 1.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if control == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		control.queue_free()
		return
	var start_position := control.position
	var start_rotation := control.rotation
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(control, "modulate:a", target_alpha, 0.05).set_delay(delay)
	tween.tween_property(control, "scale", target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(control, "position", start_position + move_offset, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(move_ease)
	if not is_zero_approx(spin):
		tween.tween_property(control, "rotation", start_rotation + spin, duration).set_delay(delay)
	tween.tween_property(control, "modulate:a", 0.0, duration * 0.70).set_delay(delay + duration * 0.30)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0)
	)


func spawn_mastery_cast_sequence(orb_id: int, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int = 0) -> void:
	if target_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var source := _mastery_card_source(orb_id)
	if source == null:
		return
	var source_point := control_global_center(source, 0.5)
	if source_point == Vector2.ZERO:
		return
	var source_local := _global_to_vfx_local(source_point)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	if delta.length() <= 1.0:
		return
	var clean_kind := mastery_impact_kind(orb_id)
	var tier_index := _result_vfx_tier_index(replay_result_vfx_tier(clean_kind, result_amount))
	var intensity := _replay_effect_intensity(result_amount, tier_index)
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_mastery_cast_sequence(orb_id, source_point, target_global, spool_lifetime, travel_lifetime, result_amount):
		return
	_spawn_mastery_cast_spool(source_local, orb_id, spool_lifetime, intensity)
	_spawn_mastery_cast_travel(source_local, target_local, orb_id, travel_lifetime, spool_lifetime, intensity)


func spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	var source: Control = null
	var target_global := Vector2.ZERO
	var orb_id := OrbType.Id.FIRE
	var beam_lifetime := lifetime

	if source_orb_or_node is int:
		orb_id = int(source_orb_or_node)
		source = _mastery_card_source(orb_id)
		if source == null:
			return
		target_global = target_or_start
		if orb_or_target is Vector2:
			target_global = orb_or_target
		elif orb_or_target is float:
			beam_lifetime = float(orb_or_target)
	elif source_orb_or_node is Control:
		source = source_orb_or_node
		if orb_or_target is int:
			orb_id = int(orb_or_target)
		elif orb_or_target is float:
			beam_lifetime = float(orb_or_target)
		target_global = target_or_start
	else:
		return

	if source == null or target_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var source_point := control_global_center(source, 0.5)
	if source_point == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_mastery_beam(orb_id, source_point, target_global, beam_lifetime):
		return
	if _visual_registry == null:
		return
	var beam_texture: Texture2D = _visual_registry.mastery_beam_texture(orb_id)
	if beam_texture == null:
		return
	var source_local := _global_to_vfx_local(source_point)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	_spawn_mastery_source_pulse(source_local, orb_id, beam_lifetime)

	var beam := TextureRect.new()
	beam.texture = beam_texture
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	beam.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	beam.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	var beam_thickness := 28.0
	beam.size = Vector2(distance, beam_thickness)
	beam.pivot_offset = Vector2(0.0, beam_thickness * 0.5)
	beam.position = source_local - Vector2(0.0, beam_thickness * 0.5)
	beam.rotation = delta.angle()
	beam.modulate = Color(1.0, 1.0, 1.0, 1.0)
	beam.z_index = 92
	_vfx_layer.add_child(beam)
	_tween_fade_cleanup(beam, beam_lifetime)


func _spawn_mastery_cast_spool(source_local: Vector2, orb_id: int, lifetime: float, intensity: int) -> void:
	var colors := _mastery_cast_colors(orb_id)
	var accent: Color = colors.get("accent", OrbType.color(orb_id))
	var core: Color = colors.get("core", accent.lightened(0.35))
	var dark: Color = colors.get("dark", accent.darkened(0.45))
	var duration := maxf(0.16, lifetime)
	var charge_size := Vector2(34, 34) + Vector2(6, 6) * float(intensity)
	_spawn_runtime_sprite_local("MasteryCastRuntimeBloom", "soft_glow", source_local, Vector2(110, 110) + Vector2(14, 14) * float(intensity), Color(accent.r, accent.g, accent.b, 0.30), duration, Vector2(1.24 + float(intensity) * 0.04, 1.24 + float(intensity) * 0.04), 0.0, Vector2.ZERO, 0.12, POST_MATCH_CAST_Z_INDEX)
	_spawn_runtime_sprite_local("MasteryCastRuntimeCore", "spark", source_local, charge_size * 1.34, Color(core.r, core.g, core.b, 0.96), duration * 0.84, Vector2(0.82, 0.82), duration * 0.12, Vector2.ZERO, 0.38, POST_MATCH_EFFECT_FRONT_Z_INDEX)
	_spawn_local_effect_panel(
		"MasteryCastChargeCore",
		source_local,
		charge_size,
		Color(dark.r, dark.g, dark.b, 0.52),
		Color(core.r, core.g, core.b, 1.0),
		4 + mini(intensity, 5),
		999,
		POST_MATCH_EFFECT_FRONT_Z_INDEX,
		duration * 0.96,
		Vector2(1.52 + float(intensity) * 0.04, 1.52 + float(intensity) * 0.04),
		0.0,
		Vector2.ZERO,
		0.18
	)
	_spawn_local_effect_panel(
		"MasteryCastChargeBloom",
		source_local,
		Vector2(82, 82) + Vector2(9, 9) * float(intensity),
		Color(accent.r, accent.g, accent.b, 0.12),
		Color(core.r, core.g, core.b, 0.58),
		2,
		999,
		POST_MATCH_CAST_Z_INDEX,
		duration,
		Vector2(1.32 + float(intensity) * 0.03, 1.32 + float(intensity) * 0.03),
		duration * 0.08
	)
	var ring_count := 3 + mini(intensity, 5)
	for i in range(ring_count):
		var delay := duration * 0.09 * float(i)
		var size := Vector2(54, 54) + Vector2(10, 10) * float(i)
		_spawn_local_effect_panel(
			"MasteryCastSpool",
			source_local,
			size,
			Color(accent.r, accent.g, accent.b, 0.18),
			Color(core.r, core.g, core.b, 0.94),
			3 + mini(intensity, 6),
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.72,
			Vector2(1.42 + float(i) * 0.10, 1.42 + float(i) * 0.10),
			delay
		)
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
		_spawn_local_effect_panel(
			"MasteryCastSpoolParticle",
			source_local + start,
			size,
			Color(particle_color.r, particle_color.g, particle_color.b, 0.76),
			Color(core.r, core.g, core.b, 0.88),
			1,
			999 if orb_id != OrbType.Id.ICE else 4,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			duration * 0.68,
			Vector2(0.52, 0.52),
			float(i % 5) * duration * 0.022,
			end - start,
			0.55
		)
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
			_spawn_local_effect_panel(
				"MasteryCastEarthShake",
				source_local + offset,
				Vector2(24 + intensity * 3, 5 + intensity),
				Color(accent.r, accent.g, accent.b, 0.36),
				Color(core.r, core.g, core.b, 0.72),
				1,
				999,
				POST_MATCH_CAST_Z_INDEX,
				duration * 0.48,
				Vector2(1.18, 0.62),
				float(i) * duration * 0.045,
				Vector2(sin(float(i) * 1.8) * 8.0, 0.0)
			)


func _spawn_mastery_fire_spool(source_local: Vector2, duration: float, intensity: int, _accent: Color, core: Color) -> void:
	var tongue_count := 5 + intensity
	for i in range(tongue_count):
		var lane := (float(i) / float(maxi(1, tongue_count - 1)) - 0.5) * (54.0 + float(intensity) * 4.0)
		var start := Vector2(lane, 22.0 + float(i % 3) * 4.0)
		_spawn_local_effect_panel(
			"MasteryCastFireBuild",
			source_local + start,
			Vector2(12 + intensity * 2, 34 + intensity * 5),
			Color(1.0, 0.16, 0.02, 0.48),
			Color(core.r, core.g, core.b, 0.88),
			1,
			999,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			duration * 0.70,
			Vector2(0.58, 1.38),
			duration * (0.16 + float(i % 4) * 0.035),
			Vector2(sin(float(i)) * 8.0, -50.0 - float(intensity) * 4.0),
			0.30,
			-PI * 0.5
		)
	_spawn_local_effect_panel(
		"MasteryCastFireFlash",
		source_local + Vector2(0.0, -8.0),
		Vector2(54, 70) + Vector2(8, 10) * float(intensity),
		Color(1.0, 0.23, 0.02, 0.24),
		Color(1.0, 0.86, 0.30, 0.96),
		3,
		999,
		POST_MATCH_EFFECT_FRONT_Z_INDEX,
		duration * 0.46,
		Vector2(0.66, 1.18),
		duration * 0.48,
		Vector2(0.0, -18.0),
		0.22
	)


func _spawn_mastery_ice_spool(source_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
	var breeze_count := 6 + intensity
	for i in range(breeze_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var y := (float(i) / float(maxi(1, breeze_count - 1)) - 0.5) * (70.0 + float(intensity) * 5.0)
		var start := Vector2(side * (48.0 + float(i % 3) * 8.0), y)
		_spawn_local_effect_panel(
			"MasteryCastIceBreathe",
			source_local + start,
			Vector2(46 + intensity * 5, 5 + intensity),
			Color(accent.r, accent.g, accent.b, 0.25),
			Color(core.r, core.g, core.b, 0.80),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.76,
			Vector2(0.72, 0.46),
			duration * (0.10 + float(i % 5) * 0.032),
			Vector2(-side * (46.0 + float(intensity) * 4.0), sin(float(i)) * 12.0),
			0.0,
			side * 0.10
		)
	var crystal_count := 4 + mini(intensity, 6)
	for i in range(crystal_count):
		var angle := TAU * float(i) / float(crystal_count)
		var start := Vector2(cos(angle), sin(angle)) * (22.0 + float(intensity) * 2.0)
		_spawn_local_effect_panel(
			"MasteryCastIceCondense",
			source_local + start,
			Vector2(7 + intensity, 22 + intensity * 2),
			Color(core.r, core.g, core.b, 0.54),
			Color(0.94, 1.0, 1.0, 0.94),
			1,
			4,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			duration * 0.66,
			Vector2(0.58, 0.92),
			duration * (0.24 + float(i % 3) * 0.045),
			-start * 0.68,
			0.18,
			angle + PI * 0.5
		)


func _spawn_mastery_earth_spool(source_local: Vector2, duration: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
	var root_count := 6 + intensity
	for i in range(root_count):
		var side := -1.0 if i % 2 == 0 else 1.0
		var start := Vector2(side * (20.0 + float(i % 4) * 12.0), 30.0 + sin(float(i)) * 5.0)
		_spawn_local_effect_panel(
			"MasteryCastEarthRoot",
			source_local + start,
			Vector2(30 + intensity * 4, 6 + intensity),
			Color(dark.r, dark.g, dark.b, 0.64),
			Color(core.r, core.g, core.b, 0.70),
			1,
			4,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.72,
			Vector2(1.22, 0.66),
			duration * (0.10 + float(i % 4) * 0.04),
			Vector2(-side * (18.0 + float(intensity) * 2.0), sin(float(i) * 1.7) * 7.0),
			0.06,
			sin(float(i)) * 0.34
		)
	var rumble_count := 4 + mini(intensity, 5)
	for i in range(rumble_count):
		var offset := Vector2((float(i) - float(rumble_count - 1) * 0.5) * 18.0, 42.0 + sin(float(i)) * 6.0)
		_spawn_local_effect_panel(
			"MasteryCastEarthRumble",
			source_local + offset,
			Vector2(36 + intensity * 5, 5 + intensity),
			Color(accent.r, accent.g, accent.b, 0.28),
			Color(core.r, core.g, core.b, 0.62),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.50,
			Vector2(1.34, 0.50),
			duration * (0.30 + float(i) * 0.036),
			Vector2(sin(float(i) * 2.3) * 10.0, 0.0),
			0.0
		)


func _spawn_mastery_cast_travel(source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, delay: float, intensity: int) -> void:
	var colors := _mastery_cast_colors(orb_id)
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
			_spawn_mastery_fire_launch(source_local, delta, direction, normal, angle, distance, duration, delay, intensity, accent, core)
		OrbType.Id.ICE:
			_spawn_mastery_ice_launch(source_local, delta, direction, normal, angle, distance, duration, delay, intensity, accent, core)
		OrbType.Id.EARTH:
			_spawn_mastery_earth_launch(source_local, delta, direction, normal, angle, distance, duration, delay, intensity, accent, core, dark)
		_:
			_spawn_mastery_generic_launch(source_local, delta, angle, distance, duration, delay, intensity, accent, core)


func _mastery_launch_scale(intensity: int) -> float:
	return 1.0 + float(maxi(0, intensity - 1)) * 0.14


func _spawn_mastery_fire_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, _distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_runtime_sprite_local("MasteryFireLaunchBloom", "soft_glow", source_local, Vector2(72 + intensity * 10, 54 + intensity * 6) * launch_scale, Color(1.0, 0.20, 0.04, 0.42), duration, Vector2(0.72, 0.72), delay, delta, 0.46, POST_MATCH_CAST_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_runtime_sprite_local("MasteryFireLaunchCore", "ray", source_local, Vector2(82 + intensity * 10, 18 + intensity * 2) * launch_scale, Color(core.r, core.g, core.b, 0.96), duration * 0.92, Vector2(0.62, 0.50), delay, delta, 0.22, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_local_effect_panel(
		"MasteryFireProjectile",
		source_local,
		Vector2(44 + intensity * 5, 28 + intensity * 3) * launch_scale,
		Color(1.0, 0.24, 0.04, 0.86),
		Color(core.r, core.g, core.b, 0.98),
		2,
		999,
		POST_MATCH_EFFECT_FRONT_Z_INDEX,
		duration,
		Vector2(0.72, 0.72),
		delay,
		delta,
		1.2,
		angle,
		Tween.EASE_IN_OUT as Tween.EaseType
	)
	var trail_count := _runtime_particle_count(intensity, 1.25)
	for i in range(trail_count):
		var side := (float(i % 5) - 2.0) * 5.0 * launch_scale
		var back := -float(i % 4) * 12.0 * launch_scale
		var start := normal * side + direction * back
		var color := accent if i % 2 == 0 else core
		_spawn_local_effect_panel(
			"MasteryFireTrail",
			source_local + start,
			Vector2(22 + intensity * 4, 8 + intensity) * launch_scale,
			Color(color.r, color.g, color.b, 0.62),
			Color(core.r, core.g, core.b, 0.80),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.72,
			Vector2(0.46, 0.62),
			delay + float(i) * duration * 0.018,
			delta + normal * sin(float(i)) * 18.0 * launch_scale + direction * 24.0 * launch_scale,
			0.35,
			angle,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func _spawn_mastery_ice_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_runtime_sprite_local("MasteryIceLaunchMist", "smoke", source_local, Vector2(distance * 0.28, 54 + intensity * 7) * launch_scale, Color(accent.r, accent.g, accent.b, 0.24), duration, Vector2(1.08, 0.72), delay, delta, 0.0, POST_MATCH_CAST_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	_spawn_runtime_sprite_local("MasteryIceLaunchColdRay", "ray", source_local, Vector2(distance * (0.22 + float(intensity) * 0.012), 10 + intensity) * launch_scale, Color(core.r, core.g, core.b, 0.74), duration * 0.92, Vector2(1.18, 0.40), delay, delta, 0.0, POST_MATCH_EFFECT_FRONT_Z_INDEX, angle, Tween.EASE_IN_OUT as Tween.EaseType)
	var breeze_count := 6 + intensity * 4 + maxi(0, intensity - 4) * 3
	for i in range(breeze_count):
		var lane := (float(i) / float(maxi(1, breeze_count - 1)) - 0.5) * (52.0 + float(intensity) * 8.0) * launch_scale
		var start := normal * lane - direction * float(i % 3) * 10.0 * launch_scale
		_spawn_local_effect_panel(
			"MasteryIceBreeze",
			source_local + start,
			Vector2(distance * (0.20 + float(i % 3) * 0.025 + float(intensity) * 0.010), (4 + intensity) * launch_scale),
			Color(accent.r, accent.g, accent.b, 0.26),
			Color(core.r, core.g, core.b, 0.72),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.82,
			Vector2(1.24, 0.46),
			delay + float(i) * duration * 0.035,
			delta + normal * sin(float(i) * 1.7) * 22.0 * launch_scale,
			0.0,
			angle,
			Tween.EASE_IN_OUT as Tween.EaseType
		)
	var shard_count := 8 + intensity * 5 + maxi(0, intensity - 4) * 3
	for i in range(shard_count):
		var start := normal * ((float(i % 7) - 3.0) * 7.0 * launch_scale) - direction * float(i % 4) * 7.0 * launch_scale
		_spawn_local_effect_panel(
			"MasteryIceShardLaunch",
			source_local + start,
			Vector2(8 + intensity, 22 + intensity * 3) * launch_scale,
			Color(core.r, core.g, core.b, 0.82),
			Color(0.92, 1.0, 1.0, 0.94),
			1,
			4,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			duration * 0.72,
			Vector2(0.50, 0.72),
			delay + float(i) * duration * 0.026,
			delta + normal * sin(float(i) * 2.1) * 32.0 * launch_scale,
			0.45,
			angle + PI * 0.5,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func _spawn_mastery_earth_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, _distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
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
		_spawn_local_effect_panel(
			"MasteryEarthSlither",
			center,
			Vector2(30 + intensity * 5, 10 + intensity * 2) * launch_scale,
			Color(dark.r, dark.g, dark.b, 0.68),
			Color(core.r, core.g, core.b, 0.76),
			1,
			5,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.34,
			Vector2(1.10, 0.58),
			segment_delay,
			forward + normal * sin(float(i)) * 8.0 * launch_scale,
			0.15,
			angle + sin(float(i)) * 0.28,
			Tween.EASE_IN_OUT as Tween.EaseType
		)
		if i % 2 == 0:
			_spawn_local_effect_panel(
				"MasteryEarthCrack",
				center + normal * wave * 0.22,
				Vector2(42 + intensity * 6, 5 + intensity * 2) * launch_scale,
				Color(accent.r, accent.g, accent.b, 0.28),
				Color(core.r, core.g, core.b, 0.62),
				1,
				999,
				POST_MATCH_CAST_Z_INDEX,
				duration * 0.28,
				Vector2(1.26, 0.42),
				segment_delay,
				forward * 0.55,
				0.0,
				angle,
				Tween.EASE_IN_OUT as Tween.EaseType
			)


func _spawn_mastery_generic_launch(source_local: Vector2, delta: Vector2, angle: float, _distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var launch_scale := _mastery_launch_scale(intensity)
	_spawn_local_effect_panel(
		"MasteryGenericLaunch",
		source_local,
		Vector2(28 + intensity * 3, 18 + intensity * 2) * launch_scale,
		Color(accent.r, accent.g, accent.b, 0.72),
		Color(core.r, core.g, core.b, 0.90),
		2,
		999,
		POST_MATCH_CAST_Z_INDEX,
		duration,
		Vector2(0.70, 0.70),
		delay,
		delta,
		0.35,
		angle,
		Tween.EASE_IN_OUT as Tween.EaseType
	)


func _spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var texture_key := _runtime_texture_key_for_effect(name, size, corner_radius)
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


func _runtime_texture_key_for_effect(effect_name: String, size: Vector2, corner_radius: int) -> String:
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


func _screen_replay_is_offensive(clean_kind: String) -> bool:
	return _result_vfx_kind_key(clean_kind) in ["fire", "ice", "earth", "damage"]


func _screen_replay_focus(layer_size: Vector2, impact_local: Vector2, clean_kind: String) -> Vector2:
	var focus := impact_local
	if focus == Vector2.ZERO:
		focus = layer_size * 0.5
	clean_kind = _result_vfx_kind_key(clean_kind)
	focus.x = clampf(focus.x, layer_size.x * 0.12, layer_size.x * 0.88)
	if _screen_replay_is_offensive(clean_kind):
		focus.y = clampf(focus.y, layer_size.y * 0.12, layer_size.y * 0.42)
	elif clean_kind in ["heart", "armor"]:
		focus.y = clampf(focus.y, layer_size.y * 0.62, layer_size.y * 0.88)
	elif clean_kind == "gold":
		focus.y = clampf(focus.y, layer_size.y * 0.42, layer_size.y * 0.82)
	else:
		focus.y = clampf(focus.y, layer_size.y * 0.18, layer_size.y * 0.82)
	return focus


func _result_effect_colors(clean_kind: String) -> Dictionary:
	match _result_vfx_kind_key(clean_kind):
		"fire":
			return {
				"accent": Color(1.0, 0.24, 0.04, 1.0),
				"core": Color(1.0, 0.88, 0.36, 1.0),
				"dark": Color(0.65, 0.07, 0.01, 1.0),
			}
		"ice":
			return {
				"accent": Color(0.42, 0.88, 1.0, 1.0),
				"core": Color(0.88, 1.0, 1.0, 1.0),
				"dark": Color(0.08, 0.38, 0.70, 1.0),
			}
		"earth":
			return {
				"accent": Color(0.56, 0.94, 0.30, 1.0),
				"core": Color(0.88, 1.0, 0.42, 1.0),
				"dark": Color(0.22, 0.38, 0.14, 1.0),
			}
		"heart":
			return {
				"accent": Color(0.32, 1.0, 0.52, 1.0),
				"core": Color(0.82, 1.0, 0.78, 1.0),
				"dark": Color(0.08, 0.44, 0.18, 1.0),
			}
		"armor":
			return {
				"accent": Color(0.58, 0.82, 1.0, 1.0),
				"core": Color(0.92, 0.98, 1.0, 1.0),
				"dark": Color(0.12, 0.28, 0.56, 1.0),
			}
		"gold":
			return {
				"accent": Color(1.0, 0.72, 0.12, 1.0),
				"core": Color(1.0, 0.96, 0.48, 1.0),
				"dark": Color(0.62, 0.34, 0.04, 1.0),
			}
		"damage":
			return {
				"accent": Color(1.0, 0.22, 0.16, 1.0),
				"core": Color(1.0, 0.58, 0.44, 1.0),
				"dark": Color(0.54, 0.04, 0.02, 1.0),
			}
	return {
		"accent": Color(1.0, 1.0, 1.0, 1.0),
		"core": Color(1.0, 1.0, 1.0, 1.0),
		"dark": Color(0.35, 0.35, 0.35, 1.0),
	}


func _vfx_layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var layer_size := _vfx_layer.size
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			layer_size = viewport.get_visible_rect().size
	return layer_size


func _mastery_cast_colors(orb_id: int) -> Dictionary:
	match orb_id:
		OrbType.Id.FIRE:
			return {
				"accent": Color(1.0, 0.24, 0.04, 1.0),
				"core": Color(1.0, 0.88, 0.36, 1.0),
				"dark": Color(0.65, 0.07, 0.01, 1.0),
			}
		OrbType.Id.ICE:
			return {
				"accent": Color(0.42, 0.88, 1.0, 1.0),
				"core": Color(0.88, 1.0, 1.0, 1.0),
				"dark": Color(0.08, 0.38, 0.70, 1.0),
			}
		OrbType.Id.EARTH:
			return {
				"accent": Color(0.56, 0.94, 0.30, 1.0),
				"core": Color(0.88, 1.0, 0.42, 1.0),
				"dark": Color(0.22, 0.38, 0.14, 1.0),
			}
		OrbType.Id.HEART:
			return {
				"accent": Color(0.32, 1.0, 0.52, 1.0),
				"core": Color(0.82, 1.0, 0.78, 1.0),
				"dark": Color(0.08, 0.44, 0.18, 1.0),
			}
		OrbType.Id.ARMOR:
			return {
				"accent": Color(0.58, 0.82, 1.0, 1.0),
				"core": Color(0.92, 0.98, 1.0, 1.0),
				"dark": Color(0.12, 0.28, 0.56, 1.0),
			}
		OrbType.Id.GOLD:
			return {
				"accent": Color(1.0, 0.72, 0.12, 1.0),
				"core": Color(1.0, 0.96, 0.48, 1.0),
				"dark": Color(0.62, 0.34, 0.04, 1.0),
			}
	return {
		"accent": OrbType.color(orb_id),
		"core": OrbType.color(orb_id).lightened(0.35),
		"dark": OrbType.color(orb_id).darkened(0.45),
	}


func _spawn_mastery_source_pulse(source_local: Vector2, orb_id: int, lifetime: float) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var accent := OrbType.color(orb_id)
	_spawn_runtime_sprite_local("MasterySourcePulseGlow", "soft_glow", source_local, Vector2(118, 118), Color(accent.r, accent.g, accent.b, 0.34), lifetime, Vector2(1.55, 1.55), 0.0, Vector2.ZERO, 0.0, 126)
	_spawn_runtime_sprite_local("MasterySourcePulseRing", "ripple", source_local, Vector2(96, 96), Color(accent.r, accent.g, accent.b, 0.92), lifetime, Vector2(1.55, 1.55), 0.0, Vector2.ZERO, 0.0, 127)


func _mastery_source_pulse_stylebox(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.28)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.95)
	style.set_border_width_all(8)
	style.set_corner_radius_all(14)
	return style


func _mastery_card_source(orb_id: int) -> Control:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return null
	var card: Variant = _player_loadout_hud.get_combat_mastery_card(_elemental_mastery_cards, orb_id)
	if card == null:
		var fallback_name := "CombatMasteryCard%d" % orb_id
		card = _elemental_mastery_cards.get_node_or_null(fallback_name) as Control
	if card == null:
		return null

	var slot := card.get_node_or_null("CardPanel") as Control
	if slot == null:
		return card
	var icon := slot.get_node_or_null("MasteryIcon")
	if icon == null and card.get_node_or_null("MasteryIconSlot") is Control:
		slot = card.get_node_or_null("MasteryIconSlot") as Control
		icon = slot.get_node_or_null("MasteryIcon")
	return icon if icon is Control else slot


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _result_label_color(kind: String, high_contrast: bool = false) -> Color:
	if high_contrast and kind in ["fire", "ice", "earth", "damage"]:
		return Color(1.0, 1.0, 1.0, 1.0)
	match kind:
		"fire":
			return Color(1.0, 0.37, 0.16, 1.0)
		"ice":
			return Color(0.46, 0.85, 1.0, 1.0)
		"earth":
			return Color(0.68, 0.95, 0.42, 1.0)
		"heal":
			return Color(0.44, 1.0, 0.58, 1.0)
		"armor", "block":
			return Color(0.78, 0.9, 1.0, 1.0)
		"gold":
			return Color(1.0, 0.83, 0.2, 1.0)
		"damage":
			return Color(1.0, 0.22, 0.22, 1.0)
		_:
			return Color(1.0, 1.0, 1.0, 1.0)


func _spawn_enemy_attack_pulse(global_center: Vector2, pulse_size: Vector2, fill: Color, border: Color, border_width: int, z_index: int) -> Panel:
	if global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var pulse := Panel.new()
	pulse.name = "EnemyAttackPulse"
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	pulse.size = pulse_size
	pulse.pivot_offset = pulse.size * 0.5
	pulse.position = _global_to_vfx_local(global_center) - pulse.size * 0.5
	pulse.z_index = z_index
	pulse.modulate = Color(1.0, 1.0, 1.0, 0.94)
	pulse.add_theme_stylebox_override("panel", _pulse_stylebox(fill, border, border_width))
	_vfx_layer.add_child(pulse)
	return pulse


func _pulse_stylebox(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(maxi(1, border_width))
	style.set_corner_radius_all(999)
	return style


func _tween_result_label_cleanup(label: Label, lifetime: float) -> void:
	if label == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		label.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 54.0, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(label, "modulate:a", 0.0, duration).set_delay(duration * 0.36)
	tween.finished.connect(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)


func _tween_move_fade_cleanup(control: Control, target_position: Vector2, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "position", target_position, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.tween_property(control, "modulate:a", 0.0, duration).set_delay(duration * 0.42)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func _tween_fade_cleanup(control: Control, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func _tween_pulse_cleanup(control: Control, lifetime: float, target_scale: Vector2 = Vector2(1.12, 1.12)) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", target_scale, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(control, "modulate:a", 0.0, duration).set_delay(duration * 0.22)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)
