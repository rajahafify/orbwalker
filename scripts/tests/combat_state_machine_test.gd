extends RefCounted
class_name CombatStateMachineTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("start_fight_prepares_intent_block_and_phase", _test_start_fight_prepares_intent_block_and_phase, failures)
	_run_case("begin_player_input_only_from_intent_preview", _test_begin_player_input_only_from_intent_preview, failures)
	_run_case("lethal_elemental_damage_victory_skips_enemy_intent", _test_lethal_elemental_damage_victory_skips_enemy_intent, failures)
	_run_case("enemy_block_reduces_player_damage_before_hp_loss", _test_enemy_block_reduces_player_damage_before_hp_loss, failures)
	_run_case("player_armor_blocks_enemy_attack_before_hp_and_expires", _test_player_armor_blocks_enemy_attack_before_hp_and_expires, failures)
	_run_case("heart_healing_clamps_to_max_hp", _test_heart_healing_clamps_to_max_hp, failures)
	_run_case("gold_gain_updates_local_debug_gold_and_player_gold", _test_gold_gain_updates_local_debug_gold_and_player_gold, failures)
	_run_case("nonlethal_turn_advances_intent_and_returns_to_preview", _test_nonlethal_turn_advances_intent_and_returns_to_preview, failures)

	return {
		"passed": failures.is_empty(),
		"total": 8,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_start_fight_prepares_intent_block_and_phase() -> String:
	var fixture := _fixture(50, 40, 30, [{"type": EnemyState.IntentType.BLOCK, "attack": 0, "block": 7, "label": "Guard 7"}])
	var combat: CombatStateMachine = fixture.combat
	var enemy: EnemyState = fixture.enemy
	if combat.phase != CombatStateMachine.Phase.INTENT_PREVIEW:
		return "Expected start_fight to begin in Intent Preview."
	if combat.phase_name() != "Intent Preview":
		return "Expected phase_name Intent Preview."
	if enemy.current_turn_block != 7:
		return "Expected start_fight to prepare current turn block from intent."
	if combat.turn_index != 1:
		return "Expected turn_index to start at 1."
	return ""


func _test_begin_player_input_only_from_intent_preview() -> String:
	var fixture := _fixture()
	var combat: CombatStateMachine = fixture.combat
	combat.begin_player_input()
	if combat.phase != CombatStateMachine.Phase.PLAYER_INPUT:
		return "Expected begin_player_input to enter Player Input from Intent Preview."
	combat.begin_player_input()
	if combat.phase != CombatStateMachine.Phase.PLAYER_INPUT:
		return "Expected begin_player_input to leave Player Input unchanged."
	return ""


func _test_lethal_elemental_damage_victory_skips_enemy_intent() -> String:
	var fixture := _fixture(50, 50, 6, [{"type": EnemyState.IntentType.ATTACK, "attack": 20, "block": 0, "label": "Strike 20"}])
	var combat: CombatStateMachine = fixture.combat
	var player: PlayerState = fixture.player
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({OrbType.Id.FIRE: 6}, 1))
	if combat.phase != CombatStateMachine.Phase.VICTORY:
		return "Expected lethal elemental damage to produce Victory."
	if not bool(turn_log.get("enemy_intent_skipped", false)):
		return "Expected enemy intent to be skipped after lethal damage."
	if int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("incoming", -1)) != 0:
		return "Expected skipped enemy attack to have zero incoming damage."
	if player.current_hp != 50:
		return "Expected player HP to remain unchanged after skipped enemy intent."
	return ""


func _test_enemy_block_reduces_player_damage_before_hp_loss() -> String:
	var fixture := _fixture(50, 50, 20, [{"type": EnemyState.IntentType.BLOCK, "attack": 0, "block": 5, "label": "Guard 5"}])
	var combat: CombatStateMachine = fixture.combat
	var enemy: EnemyState = fixture.enemy
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({OrbType.Id.FIRE: 8}, 1))
	if int(turn_log.get("enemy_blocked", -1)) != 5:
		return "Expected enemy block to absorb 5 damage."
	if int(turn_log.get("enemy_damage_taken", -1)) != 3:
		return "Expected only 3 damage to reach enemy HP."
	if enemy.current_hp != 17:
		return "Expected enemy HP 17 after blocked damage."
	return ""


func _test_player_armor_blocks_enemy_attack_before_hp_and_expires() -> String:
	var fixture := _fixture(50, 50, 100, [{"type": EnemyState.IntentType.ATTACK, "attack": 8, "block": 0, "label": "Strike 8"}])
	var combat: CombatStateMachine = fixture.combat
	var player: PlayerState = fixture.player
	player.armor = 5
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({}, 0))
	var attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if int(attack.get("blocked_by_armor", -1)) != 5:
		return "Expected armor to block 5 enemy damage."
	if int(attack.get("hp_damage", -1)) != 3:
		return "Expected remaining 3 damage to hit HP."
	if player.current_hp != 47:
		return "Expected player HP 47 after partial block."
	if int(turn_log.get("expired_armor", -1)) != 0:
		return "Expected no armor left to expire after partial block."
	if player.armor != 0:
		return "Expected player armor to be zero after cleanup."
	return ""


func _test_heart_healing_clamps_to_max_hp() -> String:
	var fixture := _fixture(50, 48, 100, [{"type": EnemyState.IntentType.BLOCK, "attack": 0, "block": 0, "label": "Wait"}])
	var combat: CombatStateMachine = fixture.combat
	var player: PlayerState = fixture.player
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({OrbType.Id.HEART: 5}, 1))
	if int(turn_log.get("healed", -1)) != 2:
		return "Expected healing to clamp at max HP and report 2 healed."
	if player.current_hp != 50:
		return "Expected player HP to clamp to max HP."
	return ""


func _test_gold_gain_updates_local_debug_gold_and_player_gold() -> String:
	var fixture := _fixture(50, 50, 100, [{"type": EnemyState.IntentType.BLOCK, "attack": 0, "block": 0, "label": "Wait"}], 4)
	var combat: CombatStateMachine = fixture.combat
	var player: PlayerState = fixture.player
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({OrbType.Id.GOLD: 3}, 1))
	if int(turn_log.get("gold_gained", -1)) != 3:
		return "Expected 3 gold gained from Gold matches."
	if player.gold != 7:
		return "Expected player.gold to reflect local debug gold total 7."
	return ""


func _test_nonlethal_turn_advances_intent_and_returns_to_preview() -> String:
	var intents := [
		{"type": EnemyState.IntentType.ATTACK, "attack": 0, "block": 0, "label": "Wait"},
		{"type": EnemyState.IntentType.BLOCK, "attack": 0, "block": 4, "label": "Guard 4"},
	]
	var fixture := _fixture(50, 50, 100, intents)
	var combat: CombatStateMachine = fixture.combat
	var enemy: EnemyState = fixture.enemy
	combat.begin_player_input()
	var turn_log: Dictionary = combat.resolve_player_turn(_resolve_result({OrbType.Id.FIRE: 2}, 1))
	if combat.phase != CombatStateMachine.Phase.INTENT_PREVIEW:
		return "Expected nonlethal turn to return to Intent Preview."
	if combat.turn_index != 2:
		return "Expected turn_index to increment to 2."
	if enemy.intent_index != 1:
		return "Expected enemy intent index to advance."
	if enemy.current_turn_block != 4:
		return "Expected next intent block to be prepared."
	if int(turn_log.get("turn_index", -1)) != 2:
		return "Expected turn_log turn_index to report next turn index 2."
	return ""


func _fixture(
	player_max_hp: int = 50,
	player_current_hp: int = 50,
	enemy_max_hp: int = 100,
	intents: Array = [],
	initial_gold: int = 0
) -> Dictionary:
	var player := PlayerState.new()
	player.max_hp = player_max_hp
	player.current_hp = player_current_hp
	player.armor = 0
	player.gold = initial_gold
	player.increase_combo_modifier = 0
	player.more_combo_modifier = 1.0

	var enemy := EnemyState.new()
	enemy.configure_from_blueprint({
		"enemy_id": "combat_test_enemy",
		"display_name": "Combat Test Enemy",
		"max_hp": enemy_max_hp,
		"is_boss": false,
		"intent_cycle": intents if not intents.is_empty() else [
			{"type": EnemyState.IntentType.ATTACK, "attack": 0, "block": 0, "label": "Wait"},
		],
	})

	var combat := CombatStateMachine.new()
	combat.set_debug_hooks({
		"use_local_gold": true,
		"initial_gold": initial_gold,
		"fixed_orb_value": 1,
		"combat_modifiers": {
			"orb_bonus_by_id": {},
			"combo_flat_bonus": 0,
			"combo_multiplier_mult": 1.0,
			"start_turn_armor": 0,
			"flat_damage_bonus": 0,
			"flat_heal_bonus": 0,
			"flat_gold_bonus": 0,
			"sources": [],
		},
	})
	combat.start_fight(player, enemy)
	return {
		"player": player,
		"enemy": enemy,
		"combat": combat,
	}


func _resolve_result(matched_counts: Dictionary, combo_count: int) -> Dictionary:
	return {
		"total_combos": combo_count,
		"matched_counts": matched_counts,
	}
