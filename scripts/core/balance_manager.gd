extends RefCounted
class_name BalanceManager

const PROTOTYPE_BALANCE_PROJECT_SETTINGS_PREFIX := "matchatro/prototype_balance/"
const PROTOTYPE_BALANCE_DEFAULTS := {
	"starting_gold": 0,
	"gold_orb_spawn_weight_multiplier": 1.0,
	"shop_price_multiplier": 1.0,
	"reroll_cost_multiplier": 1.0,
	"level_1_fight_gold_reward": 10,
	"level_2_fight_gold_reward": 12,
	"level_3_fight_gold_reward": 14,
	"enemy_hp_multiplier": 1.0,
	"enemy_damage_multiplier": 1.0,
	"level_1_normal_hp_multiplier": 0.50,
	"level_1_normal_damage_multiplier": 0.50,
	"level_1_boss_hp_multiplier": 0.60,
	"level_1_boss_damage_multiplier": 0.65,
	"level_2_normal_hp_multiplier": 0.90,
	"level_2_normal_damage_multiplier": 1.00,
	"level_2_boss_hp_multiplier": 1.0,
	"level_2_boss_damage_multiplier": 1.10,
	"level_3_normal_hp_multiplier": 2.2,
	"level_3_normal_damage_multiplier": 1.20,
	"level_3_boss_hp_multiplier": 2.60,
	"level_3_boss_damage_multiplier": 1.30,
}

var _prototype_balance_levers: Dictionary = PROTOTYPE_BALANCE_DEFAULTS.duplicate(true)


func starting_gold() -> int:
	return maxi(0, int(_prototype_balance_levers.get("starting_gold", 0)))


func apply_to_encounter(source: Dictionary, dungeon_level: int, max_levels: int) -> Dictionary:
	var encounter := source.duplicate(true)
	if encounter.is_empty():
		return encounter
	var resolved_max_levels := maxi(1, max_levels)
	var encounter_level := clampi(int(encounter.get("dungeon_level", dungeon_level)), 1, resolved_max_levels)
	var encounter_is_boss := bool(encounter.get("is_boss", false))
	var hp_multiplier := float(_prototype_balance_levers.get("enemy_hp_multiplier", 1.0))
	hp_multiplier *= _level_scoped_multiplier(encounter_level, encounter_is_boss, "hp", resolved_max_levels)
	var damage_multiplier := float(_prototype_balance_levers.get("enemy_damage_multiplier", 1.0))
	damage_multiplier *= _level_scoped_multiplier(encounter_level, encounter_is_boss, "damage", resolved_max_levels)
	if not is_equal_approx(hp_multiplier, 1.0):
		encounter["max_hp"] = maxi(1, int(round(float(encounter.get("max_hp", 1)) * hp_multiplier)))
	if not is_equal_approx(damage_multiplier, 1.0):
		var intents: Array = encounter.get("intent_cycle", [])
		var scaled_intents: Array = []
		for raw_intent in intents:
			var intent: Dictionary = Dictionary(raw_intent).duplicate(true)
			intent["attack"] = maxi(0, int(round(float(intent.get("attack", 0)) * damage_multiplier)))
			scaled_intents.append(intent)
		encounter["intent_cycle"] = scaled_intents
	return encounter


func sync_content_registry(content_registry) -> void:
	if content_registry != null and content_registry.has_method("set_prototype_balance_levers"):
		content_registry.set_prototype_balance_levers(_prototype_balance_levers)


func levers_snapshot() -> Dictionary:
	return _prototype_balance_levers.duplicate(true)


func defaults_snapshot() -> Dictionary:
	return PROTOTYPE_BALANCE_DEFAULTS.duplicate(true)


func set_levers(levers: Dictionary) -> Dictionary:
	_prototype_balance_levers = _normalized_levers(levers)
	_sync_project_settings()
	return levers_snapshot()


func reset_levers() -> Dictionary:
	return set_levers(PROTOTYPE_BALANCE_DEFAULTS)


func fight_gold_reward_for(level: int, max_levels: int) -> int:
	var clamped_level := clampi(level, 1, maxi(1, max_levels))
	var key := "level_%d_fight_gold_reward" % clamped_level
	return maxi(0, int(_prototype_balance_levers.get(key, PROTOTYPE_BALANCE_DEFAULTS.get(key, 0))))


func _normalized_levers(levers: Dictionary) -> Dictionary:
	var normalized := PROTOTYPE_BALANCE_DEFAULTS.duplicate(true)
	for key in normalized.keys():
		if not levers.has(key):
			continue
		match key:
			"starting_gold", "level_1_fight_gold_reward", "level_2_fight_gold_reward", "level_3_fight_gold_reward":
				normalized[key] = maxi(0, int(levers.get(key, normalized[key])))
			_:
				normalized[key] = maxf(0.0, float(levers.get(key, normalized[key])))
	return normalized


func _sync_project_settings() -> void:
	for key in _prototype_balance_levers.keys():
		ProjectSettings.set_setting(
			PROTOTYPE_BALANCE_PROJECT_SETTINGS_PREFIX + String(key),
			_prototype_balance_levers[key]
		)


func _level_scoped_multiplier(level: int, is_boss: bool, stat: String, max_levels: int) -> float:
	var clamped_level := clampi(level, 1, maxi(1, max_levels))
	var scope := "boss" if is_boss else "normal"
	var key := "level_%d_%s_%s_multiplier" % [clamped_level, scope, stat]
	return maxf(0.0, float(_prototype_balance_levers.get(key, 1.0)))
