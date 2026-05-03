extends RefCounted

const FEATURE_FLAG_SETTING := "debug/ar01_combat_result_probe_enabled"
const PLAYER_STATE_PATH := "res://scripts/combat/player_state.gd"
const ENEMY_STATE_PATH := "res://scripts/combat/enemy_state.gd"
const COMBAT_STATE_MACHINE_PATH := "res://scripts/combat/combat_state_machine.gd"


static func is_enabled() -> bool:
	return bool(ProjectSettings.get_setting(FEATURE_FLAG_SETTING, false))


static func set_enabled(enabled: bool) -> void:
	ProjectSettings.set_setting(FEATURE_FLAG_SETTING, enabled)


static func run_baseline_probe() -> Dictionary:
	var envelope := {
		"probe_id": "AR-01-combat-result-envelope",
		"feature_flag": FEATURE_FLAG_SETTING,
		"enabled": is_enabled(),
		"status": "disabled",
	}
	if not bool(envelope.get("enabled", false)):
		return envelope

	var player_script: Script = ResourceLoader.load(PLAYER_STATE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	var enemy_script: Script = ResourceLoader.load(ENEMY_STATE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	var combat_script: Script = ResourceLoader.load(COMBAT_STATE_MACHINE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if player_script == null or enemy_script == null or combat_script == null:
		envelope["status"] = "blocked"
		envelope["error"] = "Failed to load one or more combat probe scripts."
		return envelope
	var player = player_script.new()
	var enemy = enemy_script.new()
	var combat = combat_script.new()
	if not combat.has_method("set_debug_hooks"):
		envelope["status"] = "blocked"
		envelope["error"] = "Loaded CombatStateMachine does not expose debug hook API."
		return envelope
	var combat_modifiers := {
		"orb_bonus_by_id": {},
		"combo_flat_bonus": 0,
		"combo_multiplier_mult": 1.0,
		"start_turn_armor": 0,
		"flat_damage_bonus": 0,
		"flat_heal_bonus": 0,
		"flat_gold_bonus": 0,
		"sources": [],
	}
	var resolve_input := {
		"total_combos": 3,
		"matched_counts": {
			OrbType.Id.HEART: 4,
			OrbType.Id.ARMOR: 3,
			OrbType.Id.FIRE: 5,
			OrbType.Id.ICE: 2,
			OrbType.Id.EARTH: 1,
			OrbType.Id.GOLD: 2,
		},
	}

	player.max_hp = 50
	player.current_hp = 40
	player.armor = 0
	player.gold = 0
	player.increase_combo_modifier = 0
	player.more_combo_modifier = 1.0

	enemy.configure_from_blueprint({
		"enemy_id": "ar01_probe_enemy",
		"display_name": "AR-01 Probe Enemy",
		"max_hp": 50,
		"is_boss": false,
		"intent_cycle": [
			{"type": 2, "attack": 11, "block": 5, "label": "Probe Strike 11 + Guard 5"},
		],
	})

	combat.set_debug_hooks({
		"combat_modifiers": combat_modifiers,
		"use_local_gold": true,
		"initial_gold": 0,
		"fixed_orb_value": 1,
	})
	combat.start_fight(player, enemy)
	combat.begin_player_input()
	var phase_before: String = combat.phase_name()
	var turn_log: Dictionary = combat.resolve_player_turn(resolve_input)
	var phase_after: String = combat.phase_name()
	combat.clear_debug_hooks()

	var expected_keys := [
		"combo_count",
		"healed",
		"gold_gained",
		"enemy_damage_taken",
		"player_start",
		"player_end",
		"enemy_start",
		"enemy_end",
		"next_phase",
	]
	var missing_keys: Array[String] = []
	for key in expected_keys:
		if not turn_log.has(key):
			missing_keys.append(key)

	envelope["status"] = "ok"
	envelope["phase_before"] = phase_before
	envelope["phase_after"] = phase_after
	envelope["turn_log_has_expected_keys"] = missing_keys.is_empty()
	envelope["missing_turn_log_keys"] = missing_keys
	envelope["result"] = {
		"resolved_turn_index": int(turn_log.get("resolved_turn_index", -1)),
		"turn_index_after": int(turn_log.get("turn_index", -1)),
		"combo_count": int(turn_log.get("combo_count", -1)),
		"combo_count_with_bonus": int(turn_log.get("combo_count_with_bonus", -1)),
		"heal_amount": int(turn_log.get("healed", -1)),
		"armor_gained": int(turn_log.get("armor_gained", -1)),
		"gold_gained": int(turn_log.get("gold_gained", -1)),
		"enemy_blocked": int(turn_log.get("enemy_blocked", -1)),
		"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", -1)),
		"total_elemental_damage": int(turn_log.get("total_elemental_damage", -1)),
		"enemy_intent_skipped": bool(turn_log.get("enemy_intent_skipped", true)),
		"expired_armor": int(turn_log.get("expired_armor", -1)),
		"player_start_present": turn_log.has("player_start"),
		"player_end_present": turn_log.has("player_end"),
		"enemy_start_present": turn_log.has("enemy_start"),
		"enemy_end_present": turn_log.has("enemy_end"),
		"player_start": turn_log.get("player_start", {}),
		"player_end": turn_log.get("player_end", {}),
		"enemy_start": turn_log.get("enemy_start", {}),
		"enemy_end": turn_log.get("enemy_end", {}),
		"enemy_attack_resolution": turn_log.get("enemy_attack_resolution", {}),
		"next_phase_id": int(turn_log.get("next_phase", -1)),
		"next_phase_name": combat.phase_name(int(turn_log.get("next_phase", -1))),
	}
	print("[AR-01 Probe] %s" % JSON.stringify(envelope))
	return envelope
