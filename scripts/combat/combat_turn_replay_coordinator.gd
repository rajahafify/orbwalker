extends RefCounted
class_name CombatTurnReplayCoordinator

const COMBAT_MASTERY_RESOLUTION_ORDER: Array[int] = [
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
]

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func replay_turn_resolution_from_log(turn_log: Dictionary) -> void:
	_owner._bind_hud_stage_coordinator()
	var vfx_presenter: Variant = _owner._combat_vfx_presenter
	var enemy_damage := int(turn_log.get("enemy_damage_taken", 0))
	var enemy_blocked := int(turn_log.get("enemy_blocked", 0))
	var fire_damage := int(turn_log.get("fire_damage", 0))
	var ice_damage := int(turn_log.get("ice_damage", 0))
	var earth_damage := int(turn_log.get("earth_damage", 0))
	var heart_heal := int(turn_log.get("healed", 0))
	var armor_gain := int(turn_log.get("armor_gained", 0))
	var gold_gain := int(turn_log.get("gold_gained", 0))
	var flat_damage_bonus := int(turn_log.get("flat_damage_bonus", 0))
	var prep_armor_added := int(turn_log.get("prep_armor_added", 0))
	var applied_flat_heal_bonus := maxi(0, heart_heal - int(turn_log.get("heart_base", 0)))
	var applied_flat_gold_bonus := maxi(0, gold_gain - int(turn_log.get("gold_base", 0)))
	_owner._bind_vfx_target_resolver()
	var replay_targets: Dictionary = _owner._vfx_target_resolver.replay_targets()
	var enemy_target: Vector2 = replay_targets.get("enemy_target", Vector2.ZERO)
	var player_target: Vector2 = replay_targets.get("player_target", Vector2.ZERO)
	var player_hp_target: Vector2 = replay_targets.get("player_hp_target", Vector2.ZERO)
	var armor_mastery_target: Vector2 = replay_targets.get("armor_target", Vector2.ZERO)
	var enemy_impact_size: Vector2 = replay_targets.get("enemy_impact_size", Vector2(84, 84))
	var player_hp_impact_size: Vector2 = replay_targets.get("player_hp_impact_size", Vector2(180, 76))
	var armor_mastery_impact_size: Vector2 = replay_targets.get("armor_impact_size", Vector2(360, 360))
	var gold_impact_size: Vector2 = replay_targets.get("gold_impact_size", Vector2(70, 70))
	var damage_lifetime: float = _owner._combat_speed_duration(0.42)
	var player_lifetime: float = _owner._combat_speed_duration(0.45)
	var gold_lifetime: float = _owner._combat_speed_duration(0.55)
	var label_lifetime: float = _owner._combat_speed_duration(0.72)

	if heart_heal > 0:
		if applied_flat_heal_bonus > 0:
			await _apply_end_modifier_feedback(OrbType.Id.HEART, applied_flat_heal_bonus, _owner._modifier_sources_for_key("flat_heal_bonus"))
			if not _owner._can_continue_after_async_wait():
				return
		var staged_hp_before_heal: int = _owner._model.staged_hud_value("player_hp", int(_owner._player_state.current_hp))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(player_hp_target, "heart", player_hp_impact_size, player_lifetime, heart_heal)
			vfx_presenter.spawn_result_label("+%d" % heart_heal, player_hp_target, "heal", label_lifetime, Vector2(0, -22), heart_heal)
		_owner._play_impact_sfx("heal", "player")
		await _owner._wait_combat_speed(_owner.TURN_REPLAY_STEP_SECONDS)
		if not _owner._can_continue_after_async_wait():
			return
		_owner._hud_stage_coordinator.stage_player_hp(staged_hp_before_heal + heart_heal)
		_owner._release_combat_mastery_feedback(OrbType.Id.HEART)

	if armor_gain > 0:
		var staged_armor_before_gain: int = _owner._model.staged_hud_value("player_armor", int(_owner._player_state.armor))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(armor_mastery_target, "armor", armor_mastery_impact_size, player_lifetime, armor_gain)
			vfx_presenter.spawn_armor_bar_linger(armor_mastery_target, armor_mastery_impact_size, player_lifetime, armor_gain)
			vfx_presenter.spawn_mastery_beam(OrbType.Id.ARMOR, armor_mastery_target, player_lifetime)
			vfx_presenter.spawn_result_label("+%d Armor" % armor_gain, armor_mastery_target, "armor", label_lifetime, Vector2(0, -54), armor_gain)
		_owner._play_impact_sfx("armor", "player")
		await _owner._wait_combat_speed(_owner.TURN_REPLAY_STEP_SECONDS)
		if not _owner._can_continue_after_async_wait():
			return
		_owner._hud_stage_coordinator.stage_player_armor(staged_armor_before_gain + armor_gain)
		_owner._release_combat_mastery_feedback(OrbType.Id.ARMOR)

	if gold_gain > 0:
		if applied_flat_gold_bonus > 0:
			await _apply_end_modifier_feedback(OrbType.Id.GOLD, applied_flat_gold_bonus, _owner._modifier_sources_for_key("flat_gold_bonus"))
			if not _owner._can_continue_after_async_wait():
				return
		var staged_gold_before_gain: int = _owner._model.staged_hud_value("player_gold", int(_owner._player_state.gold))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(player_target, "gold", gold_impact_size, gold_lifetime, gold_gain)
			vfx_presenter.spawn_mastery_beam(OrbType.Id.GOLD, player_target, gold_lifetime)
			vfx_presenter.spawn_result_label("+%d Gold" % gold_gain, player_target, "gold", label_lifetime, Vector2(0, -46), gold_gain)
		_owner._play_impact_sfx("gold", "player")
		await _owner._wait_combat_speed(_owner.TURN_REPLAY_STEP_SECONDS)
		if not _owner._can_continue_after_async_wait():
			return
		_owner._hud_stage_coordinator.stage_gold(staged_gold_before_gain + gold_gain)
		_owner._release_combat_mastery_feedback(OrbType.Id.GOLD)

	if flat_damage_bonus > 0 and int(turn_log.get("total_elemental_damage_before_flat", 0)) > 0:
		var flat_damage_orb := _dominant_damage_orb_for_turn(turn_log)
		await _apply_end_modifier_feedback(flat_damage_orb, flat_damage_bonus, _owner._modifier_sources_for_key("flat_damage_bonus"))
		if not _owner._can_continue_after_async_wait():
			return

	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		if (
			fire_damage > 0
			and not await _replay_elemental_damage_result(OrbType.Id.FIRE, fire_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime)
		):
			return
		if ice_damage > 0 and not _owner._hud_stage_coordinator.staged_enemy_defeated():
			if not await _replay_elemental_damage_result(OrbType.Id.ICE, ice_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime):
				return
		if earth_damage > 0 and not _owner._hud_stage_coordinator.staged_enemy_defeated():
			if not await _replay_elemental_damage_result(OrbType.Id.EARTH, earth_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime):
				return
	elif enemy_damage > 0:
		if not await _replay_dominant_enemy_damage(turn_log, enemy_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime, vfx_presenter):
			return
	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		_owner._hud_stage_coordinator.stage_enemy_result()
	if enemy_blocked > 0:
		if vfx_presenter != null:
			vfx_presenter.spawn_result_label("-%d Damage Blocked" % enemy_blocked, enemy_target, "block", label_lifetime, Vector2(0, 16))
		_owner._hud_stage_coordinator.stage_enemy_result()
	await _owner._release_remaining_combat_mastery_feedback()
	if not _owner._can_continue_after_async_wait():
		return
	var enemy_attack_resolution: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if prep_armor_added > 0 and int(enemy_attack_resolution.get("incoming", 0)) > 0:
		await _apply_end_modifier_feedback(OrbType.Id.ARMOR, prep_armor_added, _owner._modifier_sources_for_key("start_turn_armor"))
		if not _owner._can_continue_after_async_wait():
			return
	await _owner._replay_enemy_attack_result_labels(turn_log, player_target, label_lifetime)
	if not _owner._can_continue_after_async_wait():
		return
	await _owner._wait_combat_speed(_owner.TURN_REPLAY_FINAL_HOLD_SECONDS)
	if not _owner._can_continue_after_async_wait():
		return
	_owner._reset_combat_mastery_preview()


func _replay_dominant_enemy_damage(
	turn_log: Dictionary,
	enemy_damage: int,
	enemy_target: Vector2,
	enemy_impact_size: Vector2,
	damage_lifetime: float,
	label_lifetime: float,
	vfx_presenter: Variant
) -> bool:
	var impact_orb := _dominant_orb_for_matches(turn_log.get("matched_counts", {}))
	if impact_orb in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
		if not await _replay_elemental_damage_result(impact_orb, enemy_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime):
			return false
		_owner._hud_stage_coordinator.stage_enemy_result()
		return true
	if vfx_presenter != null:
		vfx_presenter.spawn_replay_impact(enemy_target, _mastery_impact_kind(impact_orb), enemy_impact_size, damage_lifetime, enemy_damage)
		vfx_presenter.spawn_mastery_beam(impact_orb, enemy_target, damage_lifetime)
		vfx_presenter.spawn_result_label(
			"%d" % enemy_damage, enemy_target, _result_label_kind_for_orb(impact_orb), label_lifetime, Vector2(0, -52), enemy_damage
		)
	if _owner._view != null and _owner._view.has_method("play_enemy_hit_reaction"):
		_owner._view.play_enemy_hit_reaction(enemy_damage)
	_owner._play_impact_sfx(_mastery_impact_kind(impact_orb), "enemy")
	await _owner._wait_combat_speed(_owner.TURN_REPLAY_STEP_SECONDS)
	if not _owner._can_continue_after_async_wait():
		return false
	_owner._hud_stage_coordinator.stage_enemy_result()
	_owner._release_combat_mastery_feedback(impact_orb)
	return true


func _replay_elemental_damage_result(
	orb_id: int, damage_amount: int, enemy_target: Vector2, enemy_impact_size: Vector2, damage_lifetime: float, label_lifetime: float
) -> bool:
	_owner._bind_hud_stage_coordinator()
	var vfx_presenter: Variant = _owner._combat_vfx_presenter
	if vfx_presenter != null:
		vfx_presenter.spawn_mastery_cast_sequence(
			orb_id,
			enemy_target,
			_owner._combat_speed_duration(_owner.ELEMENTAL_CAST_SPOOL_SECONDS),
			_owner._combat_speed_duration(_owner.ELEMENTAL_CAST_LAUNCH_SECONDS),
			damage_amount
		)
		await _owner._wait_combat_speed(_owner.ELEMENTAL_CAST_SPOOL_SECONDS)
		if not _owner._can_continue_after_async_wait():
			return false
		await _owner._wait_combat_speed(_owner.ELEMENTAL_CAST_LAUNCH_SECONDS)
		if not _owner._can_continue_after_async_wait():
			return false
	if vfx_presenter != null:
		var impact_kind := _mastery_impact_kind(orb_id)
		var resolved_impact_size := _enemy_result_impact_size(orb_id, enemy_impact_size, damage_amount, vfx_presenter)
		vfx_presenter.spawn_replay_impact(enemy_target, impact_kind, resolved_impact_size, damage_lifetime, damage_amount)
		vfx_presenter.screen_nudge(damage_amount, enemy_target)
		vfx_presenter.spawn_result_label("%d" % damage_amount, enemy_target, _result_label_kind_for_orb(orb_id), label_lifetime, Vector2(0, -52), damage_amount)
	if _owner._view != null and _owner._view.has_method("play_enemy_hit_reaction"):
		_owner._view.play_enemy_hit_reaction(damage_amount)
	_owner._play_impact_sfx(_mastery_impact_kind(orb_id), "enemy")
	if vfx_presenter != null:
		await vfx_presenter.hit_stop(0.04)
	await _owner._wait_combat_speed(_owner.ELEMENTAL_CAST_IMPACT_HOLD_SECONDS)
	if not _owner._can_continue_after_async_wait():
		return false
	_owner._hud_stage_coordinator.stage_enemy_damage_step(damage_amount)
	_owner._release_combat_mastery_feedback(orb_id)
	return true


func _enemy_result_impact_size(orb_id: int, fallback_size: Vector2, amount: int, vfx_presenter: Variant) -> Vector2:
	_owner._bind_vfx_target_resolver()
	_owner._vfx_target_resolver.bind({"view": _owner._view, "vfx_presenter": vfx_presenter})
	return _owner._vfx_target_resolver.enemy_result_impact_size(orb_id, fallback_size, amount)


func _apply_end_modifier_feedback(orb_id: int, amount: int, sources: Array[Dictionary]) -> void:
	_owner._bind_mastery_preview_coordinator()
	await _owner._mastery_preview_coordinator.apply_end_modifier_feedback(orb_id, amount, sources, Callable(_owner, "_wait_combat_speed"))


func _mastery_impact_kind(orb_id: int) -> String:
	if _owner._combat_vfx_presenter != null:
		return String(_owner._combat_vfx_presenter.mastery_impact_kind(orb_id))
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


func _result_label_kind_for_orb(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		_:
			return "fire"


func _dominant_orb_for_matches(matched_counts: Dictionary) -> int:
	var selected_orb: int = OrbType.Id.FIRE
	var selected_count: int = -1
	for orb_id in COMBAT_MASTERY_RESOLUTION_ORDER:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count > selected_count:
			selected_count = count
			selected_orb = int(orb_id)
	return OrbType.Id.FIRE if selected_count <= 0 else selected_orb


func _dominant_damage_orb_for_turn(turn_log: Dictionary) -> int:
	var selected_orb: int = OrbType.Id.FIRE
	var selected_amount: int = -1
	var damage_by_orb := {
		OrbType.Id.FIRE: int(turn_log.get("fire_damage", 0)),
		OrbType.Id.ICE: int(turn_log.get("ice_damage", 0)),
		OrbType.Id.EARTH: int(turn_log.get("earth_damage", 0)),
	}
	for raw_orb_id in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
		var orb_id := int(raw_orb_id)
		var amount := int(damage_by_orb.get(orb_id, 0))
		if amount > selected_amount:
			selected_amount = amount
			selected_orb = orb_id
	if selected_amount > 0:
		return selected_orb
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	selected_amount = -1
	for raw_orb_id in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
		var orb_id := int(raw_orb_id)
		var amount := int(matched_counts.get(orb_id, 0))
		if amount > selected_amount:
			selected_amount = amount
			selected_orb = orb_id
	return selected_orb
