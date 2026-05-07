extends RefCounted
class_name CombatVfxPresenter

var _vfx_layer: Control
var _visual_registry: Variant
var _player_loadout_hud: Variant
var _elemental_mastery_cards: Control
var _timer_owner: Node

const RESULT_VFX_TIER_THRESHOLDS := {
	"fire": [6, 10, 16],
	"ice": [6, 10, 16],
	"earth": [6, 10, 16],
	"heart": [4, 8, 12],
	"armor": [4, 8, 12],
	"gold": [3, 6, 10],
}
const RESULT_VFX_DEFAULT_THRESHOLDS := [6, 10, 16]
const RESULT_VFX_TIER_SIZE_SCALES := [1.0, 1.5, 2.0, 3.0]
const RESULT_VFX_TIER_LIFETIME_SCALES := [1.0, 1.07, 1.14, 1.22]
const RESULT_VFX_TIER_ALPHA := [0.84, 0.91, 0.97, 1.0]
const RESULT_VFX_TIER_BRIGHTNESS := [1.0, 1.07, 1.14, 1.22]
const ENEMY_ATTACK_CUE_SIZE := Vector2(88, 88)
const ENEMY_ATTACK_BOLT_SIZE := Vector2(44, 44)
const ENEMY_ATTACK_BEAM_THICKNESS := 10.0


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_timer_owner = dependencies.get("timer_owner") as Node


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
	spawn_vfx_texture(impact_texture, global_center, profile_size, profile_lifetime, profile_color)


func replay_result_impact_profile(impact_kind: String, result_amount: int, base_draw_size: Vector2, base_lifetime: float) -> Dictionary:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	var tier_index := _result_vfx_tier_index(tier)
	var size_scale: float = RESULT_VFX_TIER_SIZE_SCALES[tier_index]
	var lifetime_scale: float = RESULT_VFX_TIER_LIFETIME_SCALES[tier_index]
	return {
		"tier": tier,
		"tier_index": tier_index,
		"draw_size": base_draw_size * size_scale,
		"lifetime": base_lifetime * lifetime_scale,
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
	_spawn_enemy_attack_pulse(target_global, Vector2(72, 72), Color(0.74, 0.9, 1.0, 0.36), Color(0.86, 0.95, 1.0, 0.94), 6, 118)


func spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float = 0.32, hp_damage: int = 0) -> void:
	spawn_replay_impact(target_global, "damage", Vector2(90, 90), lifetime, hp_damage)
	_spawn_enemy_attack_pulse(target_global, Vector2(76, 76), Color(1.0, 0.38, 0.32, 0.34), Color(1.0, 0.58, 0.48, 0.96), 6, 118)


func mastery_impact_kind(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.HEART:
			return "heart"
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
		return "fire"
	return clean_kind


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
	tween.tween_property(pulse, "scale", Vector2(1.55, 1.55), duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
	tween.tween_property(label, "position:y", label.position.y - 54.0, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
