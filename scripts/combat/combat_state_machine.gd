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

	var combo_count: int = int(resolve_result.get("total_combos", 0))
	var matched_counts: Dictionary = resolve_result.get("matched_counts", {})

	phase = Phase.PLAYER_EFFECTS
	var heal_amount := int(matched_counts.get(OrbType.Id.HEART, 0)) * player.orb_value(OrbType.Id.HEART)
	var armor_gain := int(matched_counts.get(OrbType.Id.ARMOR, 0)) * player.orb_value(OrbType.Id.ARMOR)
	var gold_gain := int(matched_counts.get(OrbType.Id.GOLD, 0)) * player.orb_value(OrbType.Id.GOLD)

	var combo_scale := maxi(1, combo_count)
	var fire_damage := int(matched_counts.get(OrbType.Id.FIRE, 0)) * player.orb_value(OrbType.Id.FIRE) * combo_scale
	var ice_damage := int(matched_counts.get(OrbType.Id.ICE, 0)) * player.orb_value(OrbType.Id.ICE) * combo_scale
	var earth_damage := int(matched_counts.get(OrbType.Id.EARTH, 0)) * player.orb_value(OrbType.Id.EARTH) * combo_scale
	var total_elemental_damage := fire_damage + ice_damage + earth_damage

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

	last_turn_log = {
		"resolved_turn_index": resolved_turn_index,
		"turn_index": turn_index,
		"combo_count": combo_count,
		"matched_counts": matched_counts,
		"healed": healed,
		"armor_gained": added_armor,
		"gold_gained": gold_gain,
		"fire_damage": fire_damage,
		"ice_damage": ice_damage,
		"earth_damage": earth_damage,
		"total_elemental_damage": total_elemental_damage,
		"enemy_blocked": int(block_resolution.get("blocked", 0)),
		"enemy_damage_taken": enemy_damage_dealt,
		"enemy_intent_skipped": skipped_enemy_intent,
		"enemy_intent": enemy_intent,
		"enemy_attack_resolution": enemy_attack_resolution,
		"expired_armor": expired_armor,
		"next_phase": phase,
	}
	return last_turn_log


func is_fight_over() -> bool:
	return phase == Phase.VICTORY or phase == Phase.DEFEAT
