extends RefCounted
class_name CombatVfxMasteryBeamPresenter

const MASTERY_BEAM_AURA_THICKNESS := 472.0
const MASTERY_BEAM_GLOW_THICKNESS := 344.0
const MASTERY_BEAM_SOLID_THICKNESS := 216.0
const MASTERY_BEAM_CORE_THICKNESS := 216.0
const MASTERY_BEAM_HOT_CORE_THICKNESS := 80.0
const MASTERY_BEAM_GLOW_ALPHA := 0.82
const MASTERY_BEAM_SOLID_ALPHA := 0.38

var _vfx_layer: Control = null
var _visual_registry: Variant = null
var _player_loadout_hud: Variant = null
var _elemental_mastery_cards: Control = null
var _timer_owner: Node = null
var _max_vfx_overlay: Variant = null
var _runtime_sprite_presenter: Variant = null
var _mastery_cast_vfx_presenter: Variant = null


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_max_vfx_overlay = dependencies.get("max_vfx_overlay")
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_mastery_cast_vfx_presenter = dependencies.get("mastery_cast_vfx_presenter")


func spawn_mastery_beam(
	source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float, streams_enabled: bool, max_combat_vfx_enabled: bool
) -> void:
	if not streams_enabled:
		return
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
	if orb_id == OrbType.Id.ARMOR or orb_id == OrbType.Id.HEART:
		return
	if max_combat_vfx_enabled and _max_vfx_overlay.spawn_mastery_beam(orb_id, source_point, target_global, beam_lifetime):
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
	_mastery_cast_vfx_presenter.spawn_source_pulse(source_local, orb_id, beam_lifetime)

	var beam_angle := delta.angle()
	var accent := OrbType.color(orb_id)
	var core_color := accent.lightened(0.42)
	_spawn_low_quality_beam_rect(
		"MasteryBeamLowQualitySolidBand",
		source_local,
		distance,
		MASTERY_BEAM_SOLID_THICKNESS,
		beam_angle,
		Color(accent.r, accent.g, accent.b, MASTERY_BEAM_SOLID_ALPHA),
		92,
		beam_lifetime * 1.14
	)
	_spawn_low_quality_beam_rect(
		"MasteryBeamLowQualityWhiteBand",
		source_local,
		distance,
		MASTERY_BEAM_HOT_CORE_THICKNESS,
		beam_angle,
		Color(1.0, 1.0, 1.0, 0.58),
		97,
		beam_lifetime * 0.84
	)
	_runtime_sprite_presenter.spawn_sprite_local(
		"MasteryBeamLowQualityAura",
		"soft_glow",
		source_local + delta * 0.5,
		Vector2(distance * 1.04, MASTERY_BEAM_AURA_THICKNESS),
		Color(accent.r, accent.g, accent.b, 0.48),
		beam_lifetime * 1.20,
		Vector2(1.08, 1.14),
		0.0,
		Vector2.ZERO,
		0.0,
		90,
		beam_angle
	)
	_runtime_sprite_presenter.spawn_sprite_local(
		"MasteryBeamLowQualityTargetBloom",
		"soft_glow",
		target_local,
		Vector2(528, 528),
		Color(core_color.r, core_color.g, core_color.b, 0.86),
		beam_lifetime * 0.78,
		Vector2(1.28, 1.28),
		0.0,
		Vector2.ZERO,
		0.0,
		94
	)
	_runtime_sprite_presenter.spawn_sprite_local(
		"MasteryBeamLowQualityBolt",
		"ray",
		source_local + delta * 0.08,
		Vector2(672, 224),
		Color(1.0, 1.0, 1.0, 0.94),
		beam_lifetime * 0.82,
		Vector2(0.86, 1.06),
		0.0,
		delta * 0.84,
		0.0,
		95,
		beam_angle,
		Tween.EASE_IN_OUT as Tween.EaseType
	)
	_spawn_low_quality_beam_texture(
		beam_texture,
		"MasteryBeamLowQualityGlow",
		source_local,
		distance,
		MASTERY_BEAM_GLOW_THICKNESS,
		beam_angle,
		Color(1.0, 1.0, 1.0, MASTERY_BEAM_GLOW_ALPHA),
		91,
		beam_lifetime * 1.12
	)
	_spawn_low_quality_beam_texture(
		beam_texture, "MasteryBeamLowQualityCore", source_local, distance, MASTERY_BEAM_CORE_THICKNESS, beam_angle, Color.WHITE, 93, beam_lifetime * 1.08
	)
	_spawn_low_quality_beam_texture(
		beam_texture, "MasteryBeamLowQualityHotCore", source_local, distance, MASTERY_BEAM_HOT_CORE_THICKNESS, beam_angle, Color.WHITE, 96, beam_lifetime * 0.92
	)


func control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0))


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


func _spawn_low_quality_beam_rect(
	effect_name: String, source_local: Vector2, distance: float, thickness: float, angle: float, color: Color, z_index: int, lifetime: float
) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var band := ColorRect.new()
	band.name = effect_name
	band.set_meta("effect_name", effect_name)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	band.color = color
	band.size = Vector2(distance, thickness)
	band.pivot_offset = Vector2(0.0, thickness * 0.5)
	band.position = source_local - Vector2(0.0, thickness * 0.5)
	band.rotation = angle
	band.z_index = z_index
	_vfx_layer.add_child(band)
	_tween_fade_cleanup(band, lifetime)


func _spawn_low_quality_beam_texture(
	texture: Texture2D, effect_name: String, source_local: Vector2, distance: float, thickness: float, angle: float, color: Color, z_index: int, lifetime: float
) -> void:
	var beam := TextureRect.new()
	beam.name = effect_name
	beam.set_meta("effect_name", effect_name)
	beam.texture = texture
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	beam.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	beam.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	beam.size = Vector2(distance, thickness)
	beam.pivot_offset = Vector2(0.0, thickness * 0.5)
	beam.position = source_local - Vector2(0.0, thickness * 0.5)
	beam.rotation = angle
	beam.modulate = color
	beam.z_index = z_index
	_vfx_layer.add_child(beam)
	_tween_fade_cleanup(beam, lifetime)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _tween_fade_cleanup(control: Control, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	tween.finished.connect(
		func() -> void:
			if is_instance_valid(control):
				control.queue_free()
	)
