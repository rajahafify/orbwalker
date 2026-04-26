extends RefCounted
class_name CombatStateMachine

const PLAYER_EFFECT_ORDER := [
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
	OrbType.Id.GOLD,
]

enum Phase {
	INTENT_PREVIEW,
	PLAYER_INPUT,
	MATCH_RESOLUTION,
	PLAYER_EFFECTS,
	ENEMY_RESPONSE,
	CLEANUP,
	VICTORY,
	DEFEAT,
}

var player: PlayerState
var enemy: EnemyState
var phase: Phase = Phase.INTENT_PREVIEW
var turn_index: int = 1
var last_turn_log: Dictionary = {}


func start_fight(player_state: PlayerState, enemy_state: EnemyState) -> void:
	player = player_state
	enemy = enemy_state
	turn_index = 1
	last_turn_log = {}
	phase = Phase.INTENT_PREVIEW
	enemy.prepare_turn_block_from_intent()


func phase_name(value: int = -1) -> String:
	if value < 0:
		value = phase
	match value:
		Phase.INTENT_PREVIEW:
			return "Intent Preview"
		Phase.PLAYER_INPUT:
			return "Player Input"
		Phase.MATCH_RESOLUTION:
			return "Match Resolution"
		Phase.PLAYER_EFFECTS:
			return "Player Effects"
		Phase.ENEMY_RESPONSE:
			return "Enemy Response"
		Phase.CLEANUP:
			return "Cleanup"
		Phase.VICTORY:
			return "Victory"
		Phase.DEFEAT:
			return "Defeat"
		_:
			return "Unknown"


func begin_player_input() -> void:
	if phase == Phase.INTENT_PREVIEW:
		phase = Phase.PLAYER_INPUT


func resolve_player_turn(resolve_result: Dictionary) -> Dictionary:
	phase = Phase.MATCH_RESOLUTION
	var resolved_turn_index := turn_index
	var player_start_snapshot := _build_player_snapshot()
	var enemy_start_snapshot := _build_enemy_snapshot()

	var combat_modifiers: Dictionary = RunState.current_combat_modifiers()
	var orb_bonus_by_id: Dictionary = combat_modifiers.get("orb_bonus_by_id", {})
	var combo_flat_bonus := int(combat_modifiers.get("combo_flat_bonus", 0))
	var combo_multiplier_mult := float(combat_modifiers.get("combo_multiplier_mult", 1.0))
	var start_turn_armor_bonus := int(combat_modifiers.get("start_turn_armor", 0))
	var flat_damage_bonus := int(combat_modifiers.get("flat_damage_bonus", 0))
	var flat_heal_bonus := int(combat_modifiers.get("flat_heal_bonus", 0))
	var flat_gold_bonus := int(combat_modifiers.get("flat_gold_bonus", 0))
	var modifier_sources: Array = combat_modifiers.get("sources", [])
	var prep_armor_added := player.add_temporary_armor(start_turn_armor_bonus)

	var combo_count: int = int(resolve_result.get("total_combos", 0))
	var matched_counts: Dictionary = resolve_result.get("matched_counts", {})
	var combo_count_with_bonus := combo_count + combo_flat_bonus
	var damage_combo_multiplier := player.combo_multiplier(combo_count_with_bonus) * maxf(0.0, combo_multiplier_mult)

	phase = Phase.PLAYER_EFFECTS
	var heart_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.HEART, 0)), OrbType.Id.HEART, 1.0, orb_bonus_by_id)
	var armor_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.ARMOR, 0)), OrbType.Id.ARMOR, damage_combo_multiplier, orb_bonus_by_id)
	var gold_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.GOLD, 0)), OrbType.Id.GOLD, 1.0, orb_bonus_by_id)
	var fire_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.FIRE, 0)), OrbType.Id.FIRE, damage_combo_multiplier, orb_bonus_by_id)
	var ice_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.ICE, 0)), OrbType.Id.ICE, damage_combo_multiplier, orb_bonus_by_id)
	var earth_result := _scaled_orb_total(int(matched_counts.get(OrbType.Id.EARTH, 0)), OrbType.Id.EARTH, damage_combo_multiplier, orb_bonus_by_id)

	var heal_amount := int(heart_result.get("total", 0))
	if heal_amount > 0:
		heal_amount += flat_heal_bonus
	var armor_gain := int(armor_result.get("total", 0))
	var gold_gain := int(gold_result.get("total", 0))
	if gold_gain > 0:
		gold_gain += flat_gold_bonus
	var fire_damage := int(fire_result.get("total", 0))
	var ice_damage := int(ice_result.get("total", 0))
	var earth_damage := int(earth_result.get("total", 0))
	var total_elemental_damage_before_flat := fire_damage + ice_damage + earth_damage
	var total_elemental_damage := total_elemental_damage_before_flat
	if total_elemental_damage_before_flat > 0:
		total_elemental_damage += flat_damage_bonus

	var healed := player.heal(heal_amount)
	var added_armor := player.add_temporary_armor(armor_gain)
	if gold_gain > 0:
		RunState.add_gold(gold_gain)
	player.gold = RunState.run_gold

	var block_resolution: Dictionary = enemy.consume_block_vs_player_damage(total_elemental_damage)
	var enemy_damage_dealt := enemy.apply_damage(int(block_resolution.get("final_damage", 0)))

	var enemy_intent := enemy.get_current_intent()
	var skipped_enemy_intent := enemy.is_dead()
	var enemy_attack_resolution := {
		"incoming": 0,
		"blocked_by_armor": 0,
		"hp_damage": 0,
		"remaining_hp": player.current_hp,
		"remaining_armor": player.armor,
	}

	phase = Phase.ENEMY_RESPONSE
	if not skipped_enemy_intent:
		var enemy_attack_value := int(enemy_intent.get("attack", 0))
		enemy_attack_resolution = player.apply_damage(enemy_attack_value)

	phase = Phase.CLEANUP
	var expired_armor := player.expire_temporary_armor()
	enemy.clear_turn_block()

	if enemy.is_dead():
		phase = Phase.VICTORY
	elif player.is_dead():
		phase = Phase.DEFEAT
	else:
		enemy.advance_intent()
		enemy.prepare_turn_block_from_intent()
		turn_index += 1
		phase = Phase.INTENT_PREVIEW
	var player_end_snapshot := _build_player_snapshot()
	var enemy_end_snapshot := _build_enemy_snapshot()

	last_turn_log = {
		"resolved_turn_index": resolved_turn_index,
		"turn_index": turn_index,
		"combo_count": combo_count,
		"combo_count_with_bonus": combo_count_with_bonus,
		"damage_combo_multiplier": damage_combo_multiplier,
		"increase_combo_modifier": player.increase_combo_modifier,
		"more_combo_modifier": player.more_combo_modifier,
		"combo_flat_bonus": combo_flat_bonus,
		"combo_multiplier_mult": combo_multiplier_mult,
		"orb_bonus_by_id": orb_bonus_by_id.duplicate(true),
		"prep_armor_added": prep_armor_added,
		"flat_damage_bonus": flat_damage_bonus,
		"flat_heal_bonus": flat_heal_bonus,
		"flat_gold_bonus": flat_gold_bonus,
		"modifier_sources": modifier_sources.duplicate(true),
		"matched_counts": matched_counts,
		"healed": healed,
		"armor_gained": added_armor,
		"gold_gained": gold_gain,
		"heart_base": int(heart_result.get("base", 0)),
		"armor_base": int(armor_result.get("base", 0)),
		"gold_base": int(gold_result.get("base", 0)),
		"fire_damage": fire_damage,
		"ice_damage": ice_damage,
		"earth_damage": earth_damage,
		"fire_base": int(fire_result.get("base", 0)),
		"ice_base": int(ice_result.get("base", 0)),
		"earth_base": int(earth_result.get("base", 0)),
		"total_elemental_damage_before_flat": total_elemental_damage_before_flat,
		"total_elemental_damage": total_elemental_damage,
		"enemy_blocked": int(block_resolution.get("blocked", 0)),
		"enemy_damage_taken": enemy_damage_dealt,
		"enemy_intent_skipped": skipped_enemy_intent,
		"enemy_intent": enemy_intent,
		"enemy_attack_resolution": enemy_attack_resolution,
		"expired_armor": expired_armor,
		"player_start": player_start_snapshot,
		"player_end": player_end_snapshot,
		"enemy_start": enemy_start_snapshot,
		"enemy_end": enemy_end_snapshot,
		"next_phase": phase,
	}
	return last_turn_log


func is_fight_over() -> bool:
	return phase == Phase.VICTORY or phase == Phase.DEFEAT


func _scaled_orb_total(orb_count: int, orb_id: int, combo_multiplier: float, orb_bonus_by_id: Dictionary) -> Dictionary:
	var count := maxi(0, orb_count)
	var orb_value := player.orb_value(orb_id) + int(orb_bonus_by_id.get(orb_id, 0))
	orb_value = maxi(0, orb_value)
	var base_damage := count * orb_value
	var total_damage := int(round(base_damage * combo_multiplier))
	return {
		"base": base_damage,
		"total": maxi(0, total_damage),
	}


func _build_player_snapshot() -> Dictionary:
	return {
		"hp": player.current_hp,
		"max_hp": player.max_hp,
		"armor": player.armor,
		"gold": player.gold,
	}


func _build_enemy_snapshot() -> Dictionary:
	return {
		"hp": enemy.current_hp,
		"max_hp": enemy.max_hp,
		"turn_block": enemy.current_turn_block,
		"intent": enemy.get_current_intent(),
	}
