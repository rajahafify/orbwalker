extends RefCounted
class_name CombatVfxMasteryRouter

const MASTERY_FILL_STREAM_SECONDS := 0.46

var _vfx_layer: Control = null
var _player_loadout_hud: Variant = null
var _elemental_mastery_cards: Control = null
var _max_vfx_overlay: Variant = null
var _mastery_fill_vfx_presenter: Variant = null
var _mastery_cast_vfx_presenter: Variant = null
var _replay_result_policy: Variant = null
var _stylized_replay_vfx_presenter: Variant = null
var _mastery_beam_presenter: Variant = null
var _mastery_impact_kind_callback: Callable = Callable()
var _use_max_combat_vfx_callback: Callable = Callable()
var _juice_enabled_callback: Callable = Callable()


func bind(dependencies: Dictionary, callbacks: Dictionary = {}) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_max_vfx_overlay = dependencies.get("max_vfx_overlay")
	_mastery_fill_vfx_presenter = dependencies.get("mastery_fill_vfx_presenter")
	_mastery_cast_vfx_presenter = dependencies.get("mastery_cast_vfx_presenter")
	_replay_result_policy = dependencies.get("replay_result_policy")
	_stylized_replay_vfx_presenter = dependencies.get("stylized_replay_vfx_presenter")
	_mastery_beam_presenter = dependencies.get("mastery_beam_presenter")
	_mastery_impact_kind_callback = callbacks.get("mastery_impact_kind", Callable())
	_use_max_combat_vfx_callback = callbacks.get("use_max_combat_vfx", Callable())
	_juice_enabled_callback = callbacks.get("juice_enabled", Callable())


func control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0))


func spawn_mastery_cast_sequence(orb_id: int, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int = 0) -> void:
	if not _juice_enabled(GameJuiceFlags.MASTERY_FILL_STREAMS):
		return
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
	var clean_kind := _mastery_impact_kind(orb_id)
	var tier_index: int = _replay_result_policy.result_vfx_tier_index(_replay_result_policy.replay_result_vfx_tier(clean_kind, result_amount))
	var intensity: int = _stylized_replay_vfx_presenter.replay_effect_intensity(result_amount, tier_index)
	if (
		_use_max_combat_vfx()
		and _max_vfx_overlay.spawn_mastery_cast_sequence(orb_id, source_point, target_global, spool_lifetime, travel_lifetime, result_amount)
	):
		return
	_mastery_cast_vfx_presenter.spawn_cast_spool(source_local, orb_id, spool_lifetime, intensity)
	_mastery_cast_vfx_presenter.spawn_cast_travel(source_local, target_local, orb_id, travel_lifetime, spool_lifetime, intensity)


func spawn_mastery_fill_stream(
	orb_id: int, source_global: Vector2, amount: int, lifetime: float = MASTERY_FILL_STREAM_SECONDS, reduced_motion: bool = false
) -> void:
	var streams_enabled := _juice_enabled(GameJuiceFlags.MASTERY_FILL_STREAMS) and not reduced_motion
	var flare_enabled := _juice_enabled(GameJuiceFlags.MASTERY_CARD_INTAKE_FLARE)
	if not streams_enabled and not flare_enabled:
		return
	if not OrbType.is_valid_id(orb_id) or amount <= 0 or source_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var target := _mastery_card_source(orb_id)
	if target == null:
		return
	var target_global := control_global_center(target, 0.5)
	if target_global == Vector2.ZERO:
		return
	var source_local := _global_to_vfx_local(source_global)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var clean_lifetime := maxf(0.18, lifetime)
	var intensity := clampi(2 + int(floor(float(amount) / 4.0)), 2, 8)
	_mastery_fill_vfx_presenter.spawn_fill_stream(source_local, target_local, orb_id, clean_lifetime, intensity, streams_enabled, flare_enabled)


func spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	_mastery_beam_presenter.spawn_mastery_beam(
		source_orb_or_node, target_or_start, orb_or_target, lifetime, _juice_enabled(GameJuiceFlags.MASTERY_FILL_STREAMS), _use_max_combat_vfx()
	)


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


func _mastery_impact_kind(orb_id: int) -> String:
	if _mastery_impact_kind_callback.is_valid():
		return String(_mastery_impact_kind_callback.call(orb_id))
	return ""


func _use_max_combat_vfx() -> bool:
	return _use_max_combat_vfx_callback.is_valid() and bool(_use_max_combat_vfx_callback.call())


func _juice_enabled(flag_key: String) -> bool:
	return _juice_enabled_callback.is_valid() and bool(_juice_enabled_callback.call(flag_key))
