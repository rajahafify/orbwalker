extends RefCounted
class_name CombatVfxPresenter

var _vfx_layer: Control
var _visual_registry: Variant
var _player_loadout_hud: Variant
var _elemental_mastery_cards: Control
var _timer_owner: Node
var _post_match_additive_material: CanvasItemMaterial
var _post_match_vfx_speed_scale := DEFAULT_POST_MATCH_VFX_SPEED_SCALE

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
const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_CAST_Z_INDEX := 128
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const ENEMY_ATTACK_CUE_SIZE := Vector2(88, 88)
const ENEMY_ATTACK_BOLT_SIZE := Vector2(44, 44)
const ENEMY_ATTACK_BEAM_THICKNESS := 10.0


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_timer_owner = dependencies.get("timer_owner") as Node


func set_post_match_vfx_speed_scale(speed_scale: float) -> void:
	_post_match_vfx_speed_scale = clampf(speed_scale, 0.25, 2.0)


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
	var impact_texture: Texture2D = _visual_registry.mastery_impact_texture(impact_kind)
	if impact_texture == null:
		impact_texture = _visual_registry.vfx_texture("orb_clear")
	var profile := replay_result_impact_profile(impact_kind, result_amount, draw_size, lifetime)
	var profile_size: Vector2 = profile.get("draw_size", draw_size)
	var profile_lifetime := float(profile.get("lifetime", lifetime))
	var profile_color: Color = profile.get("modulate_color", Color(1.0, 1.0, 1.0, 0.92))
	var tier_index := int(profile.get("tier_index", 0))
	spawn_vfx_texture(impact_texture, global_center, profile_size, profile_lifetime, profile_color)
	_spawn_stylized_replay_effect(global_center, _result_vfx_kind_key(impact_kind), profile_size, profile_lifetime, result_amount, tier_index)


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
	label.add_theme_color_override("font_color", _result_label_color(kind))
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.04, 0.03, 0.95))
	label.add_theme_constant_override("outline_size", int(round(8.0 * label_scale)))
	label.custom_minimum_size = Vector2(240, 70) * label_scale
	label.size = label.custom_minimum_size
	label.pivot_offset = label.size * 0.5
	label.z_index = 130
	_vfx_layer.add_child(label)
	var local_center := _global_to_vfx_local(global_center) + offset
	label.position = local_center - label.size * 0.5
	_tween_result_label_cleanup(label, lifetime)
	return label


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float = 0.26) -> void:
	if source_global == Vector2.ZERO:
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
	spawn_replay_impact(target_global, "armor", Vector2(90, 90), lifetime, blocked_amount)
	var pulse := _spawn_enemy_attack_pulse(target_global, Vector2(62, 62), Color(0.30, 0.48, 0.72, 0.18), Color(0.78, 0.88, 1.0, 0.78), 4, 118)
	_tween_pulse_cleanup(pulse, lifetime, Vector2(1.16, 1.16))


func spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float = 0.32, hp_damage: int = 0) -> void:
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
	_spawn_replay_ring(global_center, ring_size, Color(1.0, 0.16, 0.02, 0.20), Color(1.0, 0.74, 0.22, 0.95), 7 + intensity, lifetime * 0.86, Vector2(1.35 + float(intensity) * 0.10, 1.35 + float(intensity) * 0.10), 0.0)
	_spawn_replay_ring(global_center, ring_size * 0.62, Color(1.0, 0.72, 0.10, 0.24), Color(1.0, 0.95, 0.54, 0.85), 4 + intensity, lifetime * 0.58, Vector2(1.18, 1.18), 0.0)
	var count := 12 + intensity * 7
	for i in range(count):
		var angle := -PI * 0.35 + TAU * float(i) / float(count)
		var length := draw_size.x * (0.22 + 0.035 * float((i % 4) + intensity))
		var color := Color(1.0, 0.25 + 0.08 * float(i % 3), 0.05, 0.90)
		_spawn_replay_streak(global_center, angle, length, 7.0 + float(intensity) * 1.4, color, lifetime * 0.58, float(i % 5) * 0.012)
		var travel := Vector2(cos(angle), sin(angle) - 0.34) * draw_size.x * (0.22 + 0.025 * float(intensity))
		_spawn_replay_particle(global_center, Vector2.ZERO, travel, Vector2(10 + intensity * 2, 10 + intensity * 2), color.lightened(0.18), lifetime * 0.76, float(i % 4) * 0.018, 999)


func _spawn_ice_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_ring(global_center, draw_size * 0.98, Color(0.12, 0.72, 1.0, 0.12), Color(0.70, 0.96, 1.0, 0.98), 5 + intensity, lifetime * 0.74, Vector2(1.18 + float(intensity) * 0.06, 1.18 + float(intensity) * 0.06), 0.0)
	var count := 9 + intensity * 6
	for i in range(count):
		var angle := TAU * float(i) / float(count) + 0.14
		var length := draw_size.x * (0.24 + 0.03 * float(intensity + (i % 3)))
		var color := Color(0.62, 0.92, 1.0, 0.92)
		_spawn_replay_streak(global_center, angle, length, 4.0 + float(intensity), color, lifetime * 0.80, float(i % 3) * 0.012)
		if i % 2 == 0:
			var shard_travel := Vector2(cos(angle), sin(angle)) * draw_size.x * (0.18 + float(intensity) * 0.018)
			_spawn_replay_particle(global_center, Vector2.ZERO, shard_travel, Vector2(8 + intensity, 18 + intensity * 3), Color(0.86, 0.98, 1.0, 0.94), lifetime * 0.64, float(i % 5) * 0.016, 4)


func _spawn_earth_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_ring(global_center, draw_size * 1.06, Color(0.16, 0.58, 0.18, 0.16), Color(0.74, 1.0, 0.30, 0.92), 6 + intensity, lifetime * 0.88, Vector2(1.30 + float(intensity) * 0.06, 1.18 + float(intensity) * 0.04), 0.0)
	var count := 8 + intensity * 6
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		var travel := Vector2(cos(angle) * 0.75, sin(angle) * 0.48 - 0.08) * draw_size.x * (0.18 + float(intensity) * 0.025)
		var color := Color(0.52 + 0.08 * float(i % 2), 0.86, 0.28, 0.90)
		_spawn_replay_particle(global_center, Vector2.ZERO, travel, Vector2(14 + intensity * 2, 11 + intensity), color, lifetime * 0.72, float(i % 4) * 0.016, 5)
		if i % 3 == 0:
			_spawn_replay_streak(global_center, angle + PI * 0.5, draw_size.x * 0.26, 5.0 + float(intensity), Color(0.86, 1.0, 0.38, 0.78), lifetime * 0.58, float(i % 5) * 0.014)


func _spawn_heal_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_ring(global_center, draw_size * 1.00, Color(0.18, 1.0, 0.40, 0.13), Color(0.74, 1.0, 0.78, 0.94), 5 + intensity, lifetime * 0.92, Vector2(1.18, 1.42 + float(intensity) * 0.08), 0.0)
	var stream_count := 7 + intensity * 5
	for i in range(stream_count):
		var x_offset := (float(i) / float(maxi(1, stream_count - 1)) - 0.5) * draw_size.x * 0.72
		var start := Vector2(x_offset, draw_size.y * 0.20)
		var travel := Vector2(sin(float(i) * 1.7) * 12.0, -draw_size.y * (0.50 + float(intensity) * 0.055))
		var color := Color(0.42, 1.0, 0.58 + 0.06 * float(i % 2), 0.86)
		_spawn_replay_streak(global_center, -PI * 0.5 + sin(float(i)) * 0.18, draw_size.y * (0.28 + float(intensity) * 0.035), 5.0 + float(intensity), color, lifetime * 0.74, float(i % 4) * 0.025, start)
		_spawn_replay_particle(global_center, start, travel, Vector2(9 + intensity, 9 + intensity), Color(0.82, 1.0, 0.78, 0.88), lifetime * 0.86, float(i % 4) * 0.025, 999)


func _spawn_armor_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_shield(global_center, draw_size * Vector2(0.92, 1.16), Color(0.18, 0.46, 0.84, 0.18), Color(0.82, 0.94, 1.0, 0.98), 7 + intensity, lifetime * 0.88)
	_spawn_replay_ring(global_center, draw_size * 0.86, Color(0.22, 0.58, 1.0, 0.10), Color(0.76, 0.90, 1.0, 0.86), 4 + intensity, lifetime * 0.58, Vector2(1.12, 1.12), 0.0)
	var hit_count := 4 + intensity * 3
	for i in range(hit_count):
		var y_offset := (float(i) / float(maxi(1, hit_count - 1)) - 0.5) * draw_size.y * 0.55
		var side := -1.0 if i % 2 == 0 else 1.0
		var start := Vector2(side * draw_size.x * 0.48, y_offset)
		var angle := 0.0 if side < 0.0 else PI
		_spawn_replay_streak(global_center, angle, draw_size.x * 0.30, 8.0 + float(intensity), Color(0.86, 0.96, 1.0, 0.82), lifetime * 0.50, float(i % 4) * 0.018, start)


func _spawn_gold_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_ring(global_center, draw_size * 0.92, Color(1.0, 0.74, 0.10, 0.14), Color(1.0, 0.92, 0.32, 0.98), 5 + intensity, lifetime * 0.74, Vector2(1.18, 1.18), 0.0)
	var coin_count := 14 + intensity * 6
	for i in range(coin_count):
		var x_offset := (float(i % 9) / 8.0 - 0.5) * draw_size.x * (1.10 + float(intensity) * 0.08)
		var y_offset := -draw_size.y * (0.90 + 0.12 * float(i % 4))
		var travel := Vector2(sin(float(i) * 1.13) * 18.0, draw_size.y * (1.00 + float(intensity) * 0.07))
		var delay := float(i) * 0.018
		_spawn_replay_coin(global_center, Vector2(x_offset, y_offset), travel, Vector2(15 + intensity * 2, 18 + intensity * 2), lifetime * 1.15, delay)
	var sparkle_count := 5 + intensity * 4
	for i in range(sparkle_count):
		var angle := TAU * float(i) / float(sparkle_count)
		_spawn_replay_streak(global_center, angle, draw_size.x * 0.22, 4.0 + float(intensity), Color(1.0, 0.96, 0.45, 0.88), lifetime * 0.56, float(i % 4) * 0.012)


func _spawn_damage_replay_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_spawn_replay_ring(global_center, draw_size * 0.92, Color(1.0, 0.08, 0.06, 0.13), Color(1.0, 0.40, 0.28, 0.92), 5 + intensity, lifetime * 0.64, Vector2(1.22 + float(intensity) * 0.05, 1.22 + float(intensity) * 0.05), 0.0)
	var slash_count := 2 + intensity
	for i in range(slash_count):
		var offset := Vector2(0.0, (float(i) - float(slash_count - 1) * 0.5) * 16.0)
		_spawn_replay_streak(global_center, -0.44, draw_size.x * (0.62 + float(intensity) * 0.04), 9.0 + float(intensity) * 1.6, Color(1.0, 0.42, 0.34, 0.92), lifetime * 0.55, float(i) * 0.028, offset)


func _spawn_replay_ring(global_center: Vector2, ring_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float, target_scale: Vector2, delay: float) -> void:
	var ring := Panel.new()
	ring.name = "PostMatchRing"
	ring.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	ring.material = _post_match_effect_material()
	ring.size = ring_size
	ring.pivot_offset = ring.size * 0.5
	ring.position = _global_to_vfx_local(global_center) - ring.size * 0.5
	ring.z_index = POST_MATCH_EFFECT_Z_INDEX
	ring.modulate = Color(1.0, 1.0, 1.0, 0.0 if delay > 0.0 else 1.0)
	ring.add_theme_stylebox_override("panel", _effect_stylebox(fill, border, border_width, 999))
	_vfx_layer.add_child(ring)
	_tween_effect_cleanup(ring, lifetime, target_scale, delay)


func _spawn_replay_shield(global_center: Vector2, shield_size: Vector2, fill: Color, border: Color, border_width: int, lifetime: float) -> void:
	var shield := Panel.new()
	shield.name = "PostMatchShield"
	shield.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	shield.material = _post_match_effect_material()
	shield.size = shield_size
	shield.pivot_offset = shield.size * 0.5
	shield.position = _global_to_vfx_local(global_center) - shield.size * 0.5
	shield.z_index = POST_MATCH_EFFECT_FRONT_Z_INDEX
	shield.modulate = Color(1.0, 1.0, 1.0, 1.0)
	shield.add_theme_stylebox_override("panel", _effect_stylebox(fill, border, border_width, 18))
	_vfx_layer.add_child(shield)
	_tween_effect_cleanup(shield, lifetime, Vector2(1.14, 1.08), 0.0)


func _spawn_replay_streak(global_center: Vector2, angle: float, length: float, thickness: float, color: Color, lifetime: float, delay: float, offset: Vector2 = Vector2.ZERO) -> void:
	var streak := Panel.new()
	streak.name = "PostMatchStreak"
	streak.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	streak.material = _post_match_effect_material()
	streak.size = Vector2(maxf(8.0, length), maxf(2.0, thickness))
	streak.pivot_offset = streak.size * 0.5
	streak.position = _global_to_vfx_local(global_center) + offset - streak.size * 0.5
	streak.rotation = angle
	streak.z_index = POST_MATCH_EFFECT_FRONT_Z_INDEX
	streak.modulate = Color(1.0, 1.0, 1.0, 0.0 if delay > 0.0 else 1.0)
	streak.add_theme_stylebox_override("panel", _effect_stylebox(color, color.lightened(0.20), 1, 999))
	_vfx_layer.add_child(streak)
	_tween_effect_cleanup(streak, lifetime, Vector2(1.20, 0.64), delay)


func _spawn_replay_particle(global_center: Vector2, start_offset: Vector2, travel: Vector2, particle_size: Vector2, color: Color, lifetime: float, delay: float, corner_radius: int) -> void:
	var particle := Panel.new()
	particle.name = "PostMatchParticle"
	particle.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	particle.material = _post_match_effect_material()
	particle.size = particle_size
	particle.pivot_offset = particle.size * 0.5
	particle.position = _global_to_vfx_local(global_center) + start_offset - particle.size * 0.5
	particle.z_index = POST_MATCH_EFFECT_FRONT_Z_INDEX
	particle.rotation = atan2(travel.y, travel.x)
	particle.modulate = Color(1.0, 1.0, 1.0, 0.0 if delay > 0.0 else 1.0)
	particle.add_theme_stylebox_override("panel", _effect_stylebox(color, color.lightened(0.20), 1, corner_radius))
	_vfx_layer.add_child(particle)
	_tween_effect_cleanup(particle, lifetime, Vector2(0.62, 0.62), delay, travel)


func _spawn_replay_coin(global_center: Vector2, start_offset: Vector2, travel: Vector2, coin_size: Vector2, lifetime: float, delay: float) -> void:
	var coin := Panel.new()
	coin.name = "PostMatchCoin"
	coin.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	coin.material = _post_match_effect_material()
	coin.size = coin_size
	coin.pivot_offset = coin.size * 0.5
	coin.position = _global_to_vfx_local(global_center) + start_offset - coin.size * 0.5
	coin.z_index = POST_MATCH_EFFECT_FRONT_Z_INDEX
	coin.rotation = 0.18 * float(int(start_offset.x) % 7)
	coin.modulate = Color(1.0, 1.0, 1.0, 0.0 if delay > 0.0 else 1.0)
	coin.add_theme_stylebox_override("panel", _effect_stylebox(Color(1.0, 0.72, 0.12, 0.96), Color(1.0, 0.96, 0.48, 1.0), 2, 999))
	_vfx_layer.add_child(coin)
	_tween_effect_cleanup(coin, lifetime, Vector2(0.78, 0.78), delay, travel, 0.95)


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
	sprite.material = _post_match_effect_material()
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
	if _vfx_layer == null or not is_instance_valid(_vfx_layer) or _visual_registry == null:
		return
	var source_point := control_global_center(source, 0.5)
	if source_point == Vector2.ZERO:
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


func _spawn_mastery_fire_spool(source_local: Vector2, duration: float, intensity: int, accent: Color, core: Color) -> void:
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


func _spawn_mastery_fire_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	_spawn_local_effect_panel(
		"MasteryFireProjectile",
		source_local,
		Vector2(44 + intensity * 5, 28 + intensity * 3),
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
	var trail_count := 11 + intensity * 5
	for i in range(trail_count):
		var side := (float(i % 5) - 2.0) * 5.0
		var back := -float(i % 4) * 12.0
		var start := normal * side + direction * back
		var color := accent if i % 2 == 0 else core
		_spawn_local_effect_panel(
			"MasteryFireTrail",
			source_local + start,
			Vector2(22 + intensity * 4, 8 + intensity),
			Color(color.r, color.g, color.b, 0.62),
			Color(core.r, core.g, core.b, 0.80),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.72,
			Vector2(0.46, 0.62),
			delay + float(i) * duration * 0.018,
			delta + normal * sin(float(i)) * 18.0 + direction * 24.0,
			0.35,
			angle,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func _spawn_mastery_ice_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	var breeze_count := 6 + intensity * 3
	for i in range(breeze_count):
		var lane := (float(i) / float(maxi(1, breeze_count - 1)) - 0.5) * (52.0 + float(intensity) * 5.0)
		var start := normal * lane - direction * float(i % 3) * 10.0
		_spawn_local_effect_panel(
			"MasteryIceBreeze",
			source_local + start,
			Vector2(distance * (0.20 + float(i % 3) * 0.025), 4 + intensity),
			Color(accent.r, accent.g, accent.b, 0.26),
			Color(core.r, core.g, core.b, 0.72),
			1,
			999,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.82,
			Vector2(1.24, 0.46),
			delay + float(i) * duration * 0.035,
			delta + normal * sin(float(i) * 1.7) * 22.0,
			0.0,
			angle,
			Tween.EASE_IN_OUT as Tween.EaseType
		)
	var shard_count := 8 + intensity * 4
	for i in range(shard_count):
		var start := normal * ((float(i % 7) - 3.0) * 7.0) - direction * float(i % 4) * 7.0
		_spawn_local_effect_panel(
			"MasteryIceShardLaunch",
			source_local + start,
			Vector2(8 + intensity, 22 + intensity * 3),
			Color(core.r, core.g, core.b, 0.82),
			Color(0.92, 1.0, 1.0, 0.94),
			1,
			4,
			POST_MATCH_EFFECT_FRONT_Z_INDEX,
			duration * 0.72,
			Vector2(0.50, 0.72),
			delay + float(i) * duration * 0.026,
			delta + normal * sin(float(i) * 2.1) * 32.0,
			0.45,
			angle + PI * 0.5,
			Tween.EASE_IN_OUT as Tween.EaseType
		)


func _spawn_mastery_earth_launch(source_local: Vector2, delta: Vector2, direction: Vector2, normal: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color, dark: Color) -> void:
	var segment_count := 10 + intensity * 3
	for i in range(segment_count):
		var progress := float(i) / float(maxi(1, segment_count - 1))
		var wave := sin(progress * TAU * 1.75) * (18.0 + float(intensity) * 2.0)
		var center := source_local + delta * progress + normal * wave
		var segment_delay := delay + duration * progress * 0.72
		var forward := direction * (24.0 + float(intensity) * 4.0)
		_spawn_local_effect_panel(
			"MasteryEarthSlither",
			center,
			Vector2(30 + intensity * 4, 10 + intensity),
			Color(dark.r, dark.g, dark.b, 0.68),
			Color(core.r, core.g, core.b, 0.76),
			1,
			5,
			POST_MATCH_CAST_Z_INDEX,
			duration * 0.34,
			Vector2(1.10, 0.58),
			segment_delay,
			forward + normal * sin(float(i)) * 8.0,
			0.15,
			angle + sin(float(i)) * 0.28,
			Tween.EASE_IN_OUT as Tween.EaseType
		)
		if i % 2 == 0:
			_spawn_local_effect_panel(
				"MasteryEarthCrack",
				center + normal * wave * 0.22,
				Vector2(42 + intensity * 5, 5 + intensity),
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


func _spawn_mastery_generic_launch(source_local: Vector2, delta: Vector2, angle: float, distance: float, duration: float, delay: float, intensity: int, accent: Color, core: Color) -> void:
	_spawn_local_effect_panel(
		"MasteryGenericLaunch",
		source_local,
		Vector2(28 + intensity * 3, 18 + intensity * 2),
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
	var panel := Panel.new()
	panel.name = name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	panel.material = _post_match_effect_material()
	panel.size = size
	panel.pivot_offset = size * 0.5
	panel.position = center_local - size * 0.5
	panel.rotation = rotation
	panel.z_index = z_index
	panel.modulate = Color(1.0, 1.0, 1.0, 0.0 if delay > 0.0 else 1.0)
	panel.add_theme_stylebox_override("panel", _effect_stylebox(fill, border, border_width, corner_radius))
	_vfx_layer.add_child(panel)
	_tween_effect_cleanup(panel, lifetime, target_scale, delay, move_offset, spin, 1.0, move_ease)


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
	var pulse := Panel.new()
	pulse.name = "MasterySourcePulse"
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	pulse.size = Vector2(96, 96)
	pulse.pivot_offset = pulse.size * 0.5
	pulse.position = source_local - pulse.size * 0.5
	pulse.z_index = 126
	pulse.modulate = Color(1.0, 1.0, 1.0, 0.92)
	pulse.add_theme_stylebox_override("panel", _mastery_source_pulse_stylebox(accent))
	_vfx_layer.add_child(pulse)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		pulse.queue_free()
		return
	var duration := maxf(0.12, lifetime)
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(pulse, "scale", Vector2(1.55, 1.55), duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(pulse, "modulate:a", 0.0, duration).set_delay(duration * 0.20)
	tween.finished.connect(func() -> void:
		if is_instance_valid(pulse):
			pulse.queue_free()
	)


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


func _result_label_color(kind: String) -> Color:
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
