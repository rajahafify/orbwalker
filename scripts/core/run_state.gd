extends Node

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")
const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const SHOP_STATE_SCRIPT := preload("res://scripts/shop/shop_state.gd")
const SHOP_SERVICE_SCRIPT := preload("res://scripts/shop/shop_service.gd")
const RUN_LOG_REPORTER_SCRIPT := preload("res://scripts/core/run_log_reporter.gd")
const RUN_LOG_EXPORT_DIR := "res://logs"
const USER_SETTINGS_PATH := "user://matchatro_settings.cfg"
const USER_SETTINGS_SECTION := "run_log"
const USER_SETTINGS_GENERATE_LOG_KEY := "generate_log"
const PROFILE_PATH := "user://matchatro_profile.cfg"
const PROFILE_SECTION := "profile"
const META_PROFILE_PATH := "user://matchatro_meta_profile.cfg"
const META_PROFILE_SECTION := "meta_profile"
const SCENE_MAIN := "res://scenes/main.tscn"
const SCENE_COMBAT := "res://scenes/combat/combat_player.tscn"
const SCENE_SHOP := "res://scenes/flow/shop_player.tscn"
const SCENE_RUN_SUMMARY := "res://scenes/flow/final_run_summary.tscn"
const MAX_DUNGEON_LEVELS := 3
const FLOW_TRACE_ENABLED := true
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
const LEVEL_SEQUENCE: Array[String] = [
	"enemy_1",
	"shop",
	"enemy_2",
	"shop",
	"boss",
	"boss_relic_reward",
	"shop",
	"advance",
]

var player_state
var player_progression_state
var player_progression_service
var content_registry
var shop_state
var shop_service
var player_profile_state
var meta_profile_state
var run_gold: int = 0
var run_score: int = 0
var _run_score_banked: bool = false
var dungeon_level: int = 1
var _relic_offer_ids_by_level: Dictionary = {}
var _player_state_content_errors: Array[Dictionary] = []
var run_active: bool = false
var run_victory: bool = false
var current_step_key: String = LEVEL_SEQUENCE[0]
var _step_index: int = 0
var enemies_defeated: int = 0
var bosses_defeated: int = 0
var total_gold_earned: int = 0
var _current_encounter: Dictionary = {}
var _boss_relic_reward_options: Array[Dictionary] = []
var _boss_reward_claimed_relic_id: String = ""
var _run_summary: Dictionary = {}
var _reward_rng := RandomNumberGenerator.new()
var _flow_trace_routes: Dictionary = {}
var _flow_trace_route_serial: int = 0
var _flow_trace_active_route_id: String = ""
var _run_log_events: Array[Dictionary] = []
var _run_log_event_serial: int = 0
var _run_log_run_id: String = ""
var _run_log_started_unix: int = 0
var _run_log_started_iso: String = ""
var _run_log_current_fight_turns: int = 0
var _run_log_last_export_paths: Dictionary = {}
var _run_log_last_export_errors: Array[String] = []
var _run_log_last_export_unix: int = 0
var _generate_run_log_files := false
var _prototype_balance_levers: Dictionary = PROTOTYPE_BALANCE_DEFAULTS.duplicate(true)

var _normal_encounters_by_level := {
	1: [
		{
			"enemy_id": "cavern_striker",
			"display_name": "Cavern Striker",
			"max_hp": 76,
			"is_boss": false,
			"intent_cycle": [
				{"type": 1, "attack": 0, "block": 8, "label": "Brace 8"},
				{"type": 2, "attack": 9, "block": 6, "label": "Shield Bash 9 + Guard 6"},
				{"type": 0, "attack": 11, "block": 0, "label": "Heavy Slash 11"},
			],
		},
		{
			"enemy_id": "cavern_defender",
			"display_name": "Cavern Defender",
			"max_hp": 82,
			"is_boss": false,
			"intent_cycle": [
				{"type": 1, "attack": 0, "block": 12, "label": "Fortify 12"},
				{"type": 2, "attack": 8, "block": 9, "label": "Counter 8 + Guard 9"},
				{"type": 0, "attack": 10, "block": 0, "label": "Crush 10"},
			],
		},
	],
	2: [
		{
			"enemy_id": "ash_hunter",
			"display_name": "Ash Hunter",
			"max_hp": 94,
			"is_boss": false,
			"intent_cycle": [
				{"type": 0, "attack": 16, "block": 0, "label": "Torch Combo 16"},
				{"type": 2, "attack": 14, "block": 3, "label": "Flare Cut 14 + Guard 3"},
				{"type": 0, "attack": 18, "block": 0, "label": "Scorch Drive 18"},
			],
		},
		{
			"enemy_id": "ruin_lancer",
			"display_name": "Ruin Lancer",
			"max_hp": 98,
			"is_boss": false,
			"intent_cycle": [
				{"type": 0, "attack": 18, "block": 0, "label": "Pierce 18"},
				{"type": 0, "attack": 16, "block": 0, "label": "Thrust 16"},
				{"type": 2, "attack": 15, "block": 2, "label": "Jab 15 + Brace 2"},
			],
		},
	],
	3: [
		{
			"enemy_id": "vault_executioner",
			"display_name": "Vault Executioner",
			"max_hp": 112,
			"is_boss": false,
			"intent_cycle": [
				{"type": 0, "attack": 18, "block": 0, "label": "Execution 18"},
				{"type": 2, "attack": 12, "block": 9, "label": "Parry 9 + Cleave 12"},
				{"type": 0, "attack": 17, "block": 0, "label": "Overhead 17"},
			],
		},
		{
			"enemy_id": "goldbound_keeper",
			"display_name": "Goldbound Keeper",
			"max_hp": 118,
			"is_boss": false,
			"intent_cycle": [
				{"type": 1, "attack": 0, "block": 14, "label": "Aegis 14"},
				{"type": 0, "attack": 17, "block": 0, "label": "Coin Hammer 17"},
				{"type": 2, "attack": 13, "block": 8, "label": "Rally 8 + Strike 13"},
			],
		},
	],
}

var _boss_encounters_by_level := {
	1: {
		"enemy_id": "iron_gate",
		"display_name": "Iron Gate",
		"max_hp": 142,
		"is_boss": true,
		"intent_cycle": [
			{"type": 1, "attack": 0, "block": 20, "label": "Fortress Stance 20"},
			{"type": 2, "attack": 14, "block": 12, "label": "Wall Bash 14 + Guard 12"},
			{"type": 0, "attack": 16, "block": 0, "label": "Gate Slam 16"},
		],
	},
	2: {
		"enemy_id": "burning_knight",
		"display_name": "Burning Knight",
		"max_hp": 158,
		"is_boss": true,
		"intent_cycle": [
			{"type": 0, "attack": 24, "block": 0, "label": "Inferno Cleave 24"},
			{"type": 0, "attack": 22, "block": 0, "label": "Scorching Lunge 22"},
			{"type": 2, "attack": 18, "block": 4, "label": "Blazing Guard 4 + Slash 18"},
		],
	},
	3: {
		"enemy_id": "prism_warden",
		"display_name": "Prism Warden",
		"max_hp": 176,
		"is_boss": true,
		"intent_cycle": [
			{"type": 1, "attack": 0, "block": 18, "label": "Prism Shield 18"},
			{"type": 0, "attack": 24, "block": 0, "label": "Spectrum Beam 24"},
			{"type": 2, "attack": 16, "block": 12, "label": "Refraction 12 + Burst 16"},
		],
	},
}


func _ready() -> void:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	ensure_player_progression_state()
	ensure_player_progression_service()
	ensure_shop_state()
	ensure_shop_service()
	_reward_rng.randomize()
	load_user_settings()
	_load_meta_profile()
	_sync_meta_profile_default_unlocks()
	_sync_player_gold_from_run()
	validate_player_state_content()
	reset_run()


func ensure_player_state():
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	return player_state


func ensure_player_progression_state():
	if player_progression_state == null:
		player_progression_state = PLAYER_PROGRESSION_STATE_SCRIPT.new()
	return player_progression_state


func ensure_player_progression_service():
	if player_progression_service == null:
		player_progression_service = PLAYER_PROGRESSION_SERVICE_SCRIPT.new()
	return player_progression_service


func ensure_content_registry():
	if content_registry == null:
		content_registry = CONTENT_REGISTRY_SCRIPT.new()
	if content_registry.has_method("set_prototype_balance_levers"):
		content_registry.set_prototype_balance_levers(_prototype_balance_levers)
	return content_registry


func ensure_shop_state():
	if shop_state == null:
		shop_state = SHOP_STATE_SCRIPT.new()
	return shop_state


func ensure_shop_service():
	if shop_service == null:
		shop_service = SHOP_SERVICE_SCRIPT.new()
	return shop_service


func ensure_player_profile_state() -> PlayerProfileState:
	if player_profile_state == null:
		player_profile_state = PLAYER_PROFILE_STATE_SCRIPT.new()
		meta_profile_state = player_profile_state.meta_profile
	return player_profile_state


func ensure_meta_profile_state() -> MetaProfileState:
	var profile: PlayerProfileState = ensure_player_profile_state()
	meta_profile_state = profile.meta_profile
	return profile.meta_profile


func validate_player_state_content() -> Array[Dictionary]:
	_player_state_content_errors = ensure_content_registry().validate_player_state_content()
	return _player_state_content_errors.duplicate(true)


func player_state_content_errors() -> Array[Dictionary]:
	return _player_state_content_errors.duplicate(true)


func run_contract_snapshot() -> Dictionary:
	var snapshot := {
		"run_state_owned_fields": [
			"run_active",
			"run_victory",
			"run_gold",
			"run_score",
			"dungeon_level",
			"current_step_key",
			"enemies_defeated",
			"bosses_defeated",
			"total_gold_earned",
			"_relic_offer_ids_by_level",
			"_current_encounter",
			"_boss_relic_reward_options",
			"_boss_reward_claimed_relic_id",
			"_run_summary",
			"_prototype_balance_levers",
		],
		"scene_route_constants": {
			"SCENE_MAIN": SCENE_MAIN,
			"SCENE_COMBAT": SCENE_COMBAT,
			"SCENE_SHOP": SCENE_SHOP,
			"SCENE_RUN_SUMMARY": SCENE_RUN_SUMMARY,
		},
		"level_sequence": LEVEL_SEQUENCE.duplicate(),
		"public_transition_action_api": [
			"start_new_run",
			"skip_to_fight",
			"mark_fight_victory",
			"mark_player_defeated",
			"advance_after_shop",
			"advance_after_boss_reward",
			"claim_boss_relic_reward",
			"skip_boss_relic_reward",
			"next_scene_path",
			"run_summary_snapshot",
			"run_log_snapshot",
			"run_log_export_json",
			"run_log_export_text",
			"run_log_export_markdown",
			"run_log_last_export_snapshot",
			"run_log_last_export_paths",
			"log_turn_result",
			"prototype_balance_levers_snapshot",
			"set_prototype_balance_levers",
			"reset_prototype_balance_levers",
			"prototype_fight_gold_reward_for",
			"current_shop_ordinal_in_level",
			"profile_snapshot",
			"reset_profile",
			"create_default_profile",
			"meta_profile_snapshot",
			"is_equipment_unlocked",
			"unlock_equipment",
			"claim_equipment_unlock",
			"consume_recent_equipment_unlocks",
			"add_total_score",
		],
		"content_dependency": {
			"content_registry_owner": "ContentRegistry",
			"content_registry_provider": "ensure_content_registry",
			"content_validation_method": "validate_player_state_content",
			"combat_modifier_content_access": ["current_combat_modifiers", "ensure_content_registry"],
			"shop_content_access": ["open_shop_for_current_level", "reroll_shop_items", "buy_shop_offer"],
		},
		"compatibility_note": "AR-07 contract snapshot only; no routing, transition, resolver, summary, or presentation behavior changes.",
	}
	return snapshot.duplicate(true)


func prototype_balance_levers_snapshot() -> Dictionary:
	return _prototype_balance_levers.duplicate(true)


func prototype_balance_defaults_snapshot() -> Dictionary:
	return PROTOTYPE_BALANCE_DEFAULTS.duplicate(true)


func set_prototype_balance_levers(levers: Dictionary) -> Dictionary:
	_prototype_balance_levers = _normalized_prototype_balance_levers(levers)
	_sync_prototype_balance_project_settings()
	if content_registry != null and content_registry.has_method("set_prototype_balance_levers"):
		content_registry.set_prototype_balance_levers(_prototype_balance_levers)
	return prototype_balance_levers_snapshot()


func reset_prototype_balance_levers() -> Dictionary:
	return set_prototype_balance_levers(PROTOTYPE_BALANCE_DEFAULTS)


func prototype_fight_gold_reward_for(level: int, _step_key: String = "") -> int:
	var clamped_level := clampi(level, 1, MAX_DUNGEON_LEVELS)
	var key := "level_%d_fight_gold_reward" % clamped_level
	return maxi(0, int(_prototype_balance_levers.get(key, PROTOTYPE_BALANCE_DEFAULTS.get(key, 0))))


func progression_snapshot() -> Dictionary:
	return ensure_player_progression_state().to_snapshot()


func profile_snapshot() -> Dictionary:
	return ensure_player_profile_state().to_snapshot()


func meta_profile_snapshot() -> Dictionary:
	return ensure_meta_profile_state().to_snapshot()


func reset_profile() -> Dictionary:
	var profile: PlayerProfileState = ensure_player_profile_state()
	profile.reset_to_default()
	meta_profile_state = profile.meta_profile
	_sync_meta_profile_default_unlocks()
	_save_profile()
	reset_run()
	return {
		"ok": true,
		"reason": "",
		"profile": profile_snapshot(),
		"meta_profile": meta_profile_snapshot(),
	}


func create_default_profile() -> Dictionary:
	return reset_profile()


func is_equipment_unlocked(item_id: String) -> bool:
	if item_id == "":
		return false
	return ensure_meta_profile_state().is_equipment_unlocked(item_id)


func unlock_equipment(item_id: String, source: String) -> Dictionary:
	var equipment: Dictionary = ensure_content_registry().get_equipment(item_id)
	if item_id == "":
		return {"ok": false, "reason": "invalid_item_id"}
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown_equipment_id"}
	if is_equipment_unlocked(item_id):
		return {"ok": false, "reason": "equipment_already_unlocked", "meta_profile": meta_profile_snapshot()}
	if not ensure_meta_profile_state().unlock_equipment(item_id):
		return {"ok": false, "reason": "unlock_failed", "meta_profile": meta_profile_snapshot()}

	var unlock_payload := {
		"item_id": item_id,
		"display_name": String(equipment.get("display_name", item_id)),
		"family_id": String(equipment.get("family_id", "")),
		"rarity": String(equipment.get("rarity", "common")),
		"rarity_color": String(equipment.get("rarity_color", "white")),
		"source": source,
		"unlock_cost": int(equipment.get("unlock_cost", 0)),
	}
	if source == "victory":
		ensure_meta_profile_state().add_recent_equipment_unlock(unlock_payload)
	_save_meta_profile()
	return {
		"ok": true,
		"reason": "",
		"unlock": unlock_payload,
		"meta_profile": meta_profile_snapshot(),
	}


func claim_equipment_unlock(item_id: String) -> Dictionary:
	var equipment: Dictionary = ensure_content_registry().get_equipment(item_id)
	if item_id == "":
		return {"ok": false, "reason": "invalid_item_id"}
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown_equipment_id"}
	if is_equipment_unlocked(item_id):
		return {"ok": false, "reason": "equipment_already_unlocked", "meta_profile": meta_profile_snapshot()}

	var unlock_cost := maxi(0, int(equipment.get("unlock_cost", 0)))
	if not _can_claim_equipment_unlock(equipment):
		return {"ok": false, "reason": "unlock_prerequisite_not_met", "meta_profile": meta_profile_snapshot()}
	if not ensure_meta_profile_state().spend_total_score(unlock_cost):
		return {"ok": false, "reason": "insufficient_total_score", "meta_profile": meta_profile_snapshot()}

	var unlock_result := unlock_equipment(item_id, "score_claim")
	if not bool(unlock_result.get("ok", false)):
		ensure_meta_profile_state().add_total_score(unlock_cost)
		_save_meta_profile()
		return unlock_result
	unlock_result["score_spent"] = unlock_cost
	return unlock_result


func consume_recent_equipment_unlocks() -> Array[Dictionary]:
	var unlocks: Array[Dictionary] = ensure_meta_profile_state().consume_recent_equipment_unlocks()
	_save_meta_profile()
	return unlocks


func add_total_score(amount: int) -> int:
	var added: int = ensure_meta_profile_state().add_total_score(amount)
	if added > 0:
		_save_meta_profile()
	return added


func current_combat_modifiers() -> Dictionary:
	var modifiers := {
		"orb_bonus_by_id": {},
		"combo_flat_bonus": 0,
		"combo_multiplier_mult": 1.0,
		"start_turn_armor": 0,
		"flat_damage_bonus": 0,
		"flat_heal_bonus": 0,
		"flat_gold_bonus": 0,
		"sources": [],
	}
	var progression = ensure_player_progression_state()
	var content = ensure_content_registry()
	for item_id in progression.equipped_item_ids:
		if item_id == "":
			continue
		var equipment: Dictionary = content.get_equipment(item_id)
		_merge_combat_modifiers(modifiers, equipment)
		_append_combat_modifier_source(modifiers, equipment, "equipment")
	for relic_id in progression.relic_ids:
		if relic_id == "":
			continue
		var relic: Dictionary = content.get_relic(relic_id)
		_merge_combat_modifiers(modifiers, relic)
		_append_combat_modifier_source(modifiers, relic, "relic")
	return modifiers


func set_gold(amount: int) -> void:
	run_gold = maxi(0, amount)
	_sync_player_gold_from_run()


func add_gold(amount: int, source: String = "combat_gain") -> int:
	if amount <= 0:
		return 0
	run_gold += amount
	total_gold_earned += amount
	if _gold_source_counts_for_run_score(source):
		run_score += amount
	_sync_player_gold_from_run()
	return amount


func spend_gold(amount: int) -> bool:
	if amount < 0:
		return false
	if run_gold < amount:
		return false
	run_gold -= amount
	_sync_player_gold_from_run()
	return true


func can_afford(amount: int) -> bool:
	return amount >= 0 and run_gold >= amount


func open_shop_for_current_level() -> Dictionary:
	var result: Dictionary = ensure_shop_service().open_shop(self, dungeon_level)
	var shop_snapshot: Dictionary = ensure_shop_state().to_snapshot()
	_run_log_append(
		"shop_open",
		{
			"result": _run_log_result_brief(result),
			"dungeon_level": dungeon_level,
			"shop_ordinal": _run_log_next_shop_ordinal(),
			"shop": _run_log_sanitize_shop_snapshot(shop_snapshot, run_gold),
		}
	)
	return result


func reroll_shop_items() -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().reroll_shop_items(self)
	_run_log_shop_action("reroll", result, {}, shop_before, gold_before)
	return result


func buy_shop_offer(offer_id: String) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().buy_offer(self, offer_id)
	_run_log_shop_action("buy_offer", result, {"offer_id": offer_id}, shop_before, gold_before)
	return result


func sell_equipped_item(slot_index: int) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().sell_equipped_item(self, slot_index)
	_run_log_shop_action("sell_equipment", result, {"slot_index": slot_index}, shop_before, gold_before)
	return result


func sell_consumable_item(slot_index: int) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().sell_consumable_item(self, slot_index)
	_run_log_shop_action("sell_consumable", result, {"slot_index": slot_index}, shop_before, gold_before)
	return result


func choose_booster_option(option_index: int) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().choose_booster_option(self, option_index)
	_run_log_shop_action("choose_booster", result, {"option_index": option_index}, shop_before, gold_before)
	return result


func replace_pending_booster_option(option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().replace_pending_booster_option(self, option_index, slot_index, sell_replaced)
	_run_log_shop_action(
		"replace_booster_option",
		result,
		{
			"option_index": option_index,
			"slot_index": slot_index,
			"sell_replaced": sell_replaced,
		},
		shop_before,
		gold_before
	)
	return result


func discard_pending_booster_options() -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().discard_pending_booster_options(self)
	_run_log_shop_action("skip_booster", result, {}, shop_before, gold_before)
	return result


func close_shop(mark_skipped: bool = false) -> void:
	ensure_shop_state().close_shop(mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return String(_relic_offer_ids_by_level.get(maxi(1, level), ""))


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_relic_offer_ids_by_level[maxi(1, level)] = relic_id


func reset_run() -> void:
	ensure_player_state().reset_for_new_run()
	_sync_meta_profile_default_unlocks()
	run_gold = maxi(0, int(_prototype_balance_levers.get("starting_gold", 0)))
	run_score = 0
	_run_score_banked = false
	ensure_player_state().gold = run_gold
	dungeon_level = 1
	_relic_offer_ids_by_level.clear()
	ensure_player_progression_state().reset_for_new_run()
	ensure_shop_state().reset_for_new_run()
	run_active = false
	run_victory = false
	current_step_key = LEVEL_SEQUENCE[0]
	_step_index = 0
	enemies_defeated = 0
	bosses_defeated = 0
	total_gold_earned = 0
	_current_encounter.clear()
	_boss_relic_reward_options.clear()
	_boss_reward_claimed_relic_id = ""
	_run_summary.clear()
	_run_log_reset()
	validate_player_state_content()


func start_new_run() -> void:
	reset_run()
	run_active = true
	_run_log_append(
		"run_start",
		{
			"dungeon_level": dungeon_level,
			"step": current_step_key,
		}
	)
	_assign_current_fight()


func snapshot_run_transition_state() -> Dictionary:
	return {
		"player_state": _snapshot_player_state_for_transition(),
		"player_progression_state": _snapshot_player_progression_state_for_transition(),
		"shop_state": _snapshot_shop_state_for_transition(),
		"run_active": run_active,
		"run_victory": run_victory,
		"run_gold": run_gold,
		"run_score": run_score,
		"run_score_banked": _run_score_banked,
		"dungeon_level": dungeon_level,
		"current_step_key": current_step_key,
		"step_index": _step_index,
		"enemies_defeated": enemies_defeated,
		"bosses_defeated": bosses_defeated,
		"total_gold_earned": total_gold_earned,
		"current_encounter": _current_encounter.duplicate(true),
		"boss_relic_reward_options": _boss_relic_reward_options.duplicate(true),
		"boss_reward_claimed_relic_id": _boss_reward_claimed_relic_id,
		"relic_offer_ids_by_level": _relic_offer_ids_by_level.duplicate(true),
		"run_summary": _run_summary.duplicate(true),
		"run_log_events": _run_log_events.duplicate(true),
		"run_log_event_serial": _run_log_event_serial,
		"run_log_run_id": _run_log_run_id,
		"run_log_started_unix": _run_log_started_unix,
		"run_log_started_iso": _run_log_started_iso,
		"run_log_current_fight_turns": _run_log_current_fight_turns,
		"run_log_last_export_paths": _run_log_last_export_paths.duplicate(true),
		"run_log_last_export_errors": _run_log_last_export_errors.duplicate(),
		"run_log_last_export_unix": _run_log_last_export_unix,
	}


func restore_run_transition_state(snapshot: Dictionary) -> bool:
	if snapshot.is_empty():
		return false
	run_active = bool(snapshot.get("run_active", run_active))
	run_victory = bool(snapshot.get("run_victory", run_victory))
	run_gold = maxi(0, int(snapshot.get("run_gold", run_gold)))
	run_score = int(snapshot.get("run_score", run_score))
	_run_score_banked = bool(snapshot.get("run_score_banked", _run_score_banked))
	dungeon_level = maxi(1, int(snapshot.get("dungeon_level", dungeon_level)))
	current_step_key = String(snapshot.get("current_step_key", current_step_key))
	var saved_step_index := int(snapshot.get("step_index", -1))
	var saved_step_index_valid := saved_step_index >= 0 and saved_step_index < LEVEL_SEQUENCE.size()
	if saved_step_index_valid and String(LEVEL_SEQUENCE[saved_step_index]) == current_step_key:
		_step_index = saved_step_index
	elif LEVEL_SEQUENCE.has(current_step_key):
		_step_index = LEVEL_SEQUENCE.find(current_step_key)
	elif saved_step_index_valid:
		_step_index = saved_step_index
		current_step_key = String(LEVEL_SEQUENCE[_step_index])
	else:
		_step_index = 0
		current_step_key = String(LEVEL_SEQUENCE[_step_index])
	enemies_defeated = maxi(0, int(snapshot.get("enemies_defeated", enemies_defeated)))
	bosses_defeated = maxi(0, int(snapshot.get("bosses_defeated", bosses_defeated)))
	total_gold_earned = maxi(0, int(snapshot.get("total_gold_earned", total_gold_earned)))
	_current_encounter = Dictionary(snapshot.get("current_encounter", {})).duplicate(true)
	_boss_relic_reward_options = Array(snapshot.get("boss_relic_reward_options", [])).duplicate(true)
	_boss_reward_claimed_relic_id = String(snapshot.get("boss_reward_claimed_relic_id", ""))
	_relic_offer_ids_by_level = Dictionary(snapshot.get("relic_offer_ids_by_level", {})).duplicate(true)
	_run_summary = Dictionary(snapshot.get("run_summary", {})).duplicate(true)
	_run_log_events = Array(snapshot.get("run_log_events", [])).duplicate(true)
	_run_log_event_serial = int(snapshot.get("run_log_event_serial", _run_log_event_serial))
	_run_log_run_id = String(snapshot.get("run_log_run_id", _run_log_run_id))
	_run_log_started_unix = int(snapshot.get("run_log_started_unix", _run_log_started_unix))
	_run_log_started_iso = String(snapshot.get("run_log_started_iso", _run_log_started_iso))
	_run_log_current_fight_turns = maxi(0, int(snapshot.get("run_log_current_fight_turns", _run_log_current_fight_turns)))
	_run_log_last_export_paths = Dictionary(snapshot.get("run_log_last_export_paths", {})).duplicate(true)
	_run_log_last_export_errors = Array(snapshot.get("run_log_last_export_errors", [])).duplicate()
	_run_log_last_export_unix = int(snapshot.get("run_log_last_export_unix", _run_log_last_export_unix))
	_restore_player_state_for_transition(Dictionary(snapshot.get("player_state", {})))
	_restore_player_progression_state_for_transition(Dictionary(snapshot.get("player_progression_state", {})))
	_restore_shop_state_for_transition(Dictionary(snapshot.get("shop_state", {})))
	_sync_player_gold_from_run()
	return true


func _snapshot_player_state_for_transition() -> Dictionary:
	var state = ensure_player_state()
	return {
		"max_hp": state.max_hp,
		"current_hp": state.current_hp,
		"armor": state.armor,
		"gold": state.gold,
		"equipment_slots": state.equipment_slots,
		"consumable_slots": state.consumable_slots,
		"move_timer_seconds": state.move_timer_seconds,
		"increase_combo_modifier": state.increase_combo_modifier,
		"more_combo_modifier": state.more_combo_modifier,
	}


func _restore_player_state_for_transition(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	var state = ensure_player_state()
	state.max_hp = maxi(1, int(snapshot.get("max_hp", state.max_hp)))
	state.current_hp = clampi(int(snapshot.get("current_hp", state.current_hp)), 0, state.max_hp)
	state.armor = maxi(0, int(snapshot.get("armor", state.armor)))
	state.gold = maxi(0, int(snapshot.get("gold", state.gold)))
	state.equipment_slots = maxi(0, int(snapshot.get("equipment_slots", state.equipment_slots)))
	state.consumable_slots = maxi(0, int(snapshot.get("consumable_slots", state.consumable_slots)))
	state.move_timer_seconds = maxf(0.0, float(snapshot.get("move_timer_seconds", state.move_timer_seconds)))
	state.increase_combo_modifier = int(snapshot.get("increase_combo_modifier", state.increase_combo_modifier))
	state.more_combo_modifier = maxf(0.0, float(snapshot.get("more_combo_modifier", state.more_combo_modifier)))


func _snapshot_player_progression_state_for_transition() -> Dictionary:
	var progression = ensure_player_progression_state()
	return {
		"equipped_item_ids": progression.equipped_item_ids.duplicate(),
		"held_consumable_ids": progression.held_consumable_ids.duplicate(),
		"relic_ids": progression.relic_ids.duplicate(),
		"mastery_levels": progression.mastery_levels.duplicate(true),
		"active_effects_by_hook": progression.active_effects_by_hook.duplicate(true),
	}


func _restore_player_progression_state_for_transition(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	var progression = ensure_player_progression_state()
	progression.equipped_item_ids = _string_array_from_snapshot(snapshot.get("equipped_item_ids", []), PlayerProgressionState.EQUIPMENT_SLOT_COUNT)
	progression.held_consumable_ids = _string_array_from_snapshot(snapshot.get("held_consumable_ids", []), PlayerProgressionState.CONSUMABLE_SLOT_COUNT)
	progression.relic_ids = _string_array_from_snapshot(snapshot.get("relic_ids", []), -1)
	progression.mastery_levels = Dictionary(snapshot.get("mastery_levels", {})).duplicate(true)
	progression.active_effects_by_hook = Dictionary(snapshot.get("active_effects_by_hook", {})).duplicate(true)


func _snapshot_shop_state_for_transition() -> Dictionary:
	var state = ensure_shop_state()
	var snapshot: Dictionary = state.to_snapshot()
	snapshot["offer_sequence"] = state.offer_sequence
	return snapshot


func _restore_shop_state_for_transition(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	var state = ensure_shop_state()
	state.active = bool(snapshot.get("active", state.active))
	state.dungeon_level = maxi(1, int(snapshot.get("dungeon_level", state.dungeon_level)))
	state.item_offers = Array(snapshot.get("item_offers", [])).duplicate(true)
	state.relic_offer = Dictionary(snapshot.get("relic_offer", {})).duplicate(true)
	state.reroll_count = maxi(0, int(snapshot.get("reroll_count", state.reroll_count)))
	state.reroll_cost = maxi(0, int(snapshot.get("reroll_cost", state.reroll_cost)))
	state.pending_booster_options = Array(snapshot.get("pending_booster_options", [])).duplicate(true)
	state.pending_booster_offer_id = String(snapshot.get("pending_booster_offer_id", state.pending_booster_offer_id))
	state.offer_sequence = maxi(1, int(snapshot.get("offer_sequence", state.offer_sequence)))
	state.skipped = bool(snapshot.get("skipped", state.skipped))


func _string_array_from_snapshot(raw_values: Variant, fixed_size: int = -1) -> Array[String]:
	var values: Array = raw_values if raw_values is Array else []
	var out: Array[String] = []
	for raw_value in values:
		out.append(String(raw_value))
	if fixed_size >= 0:
		while out.size() < fixed_size:
			out.append("")
		while out.size() > fixed_size:
			out.remove_at(out.size() - 1)
	return out


func is_current_step_fight() -> bool:
	return current_step_key == "enemy_1" or current_step_key == "enemy_2" or current_step_key == "boss"


func is_current_step_shop() -> bool:
	return current_step_key == "shop"


func current_shop_ordinal_in_level() -> int:
	if not is_current_step_shop():
		return 0
	var ordinal := 0
	for index in range(_step_index + 1):
		if String(LEVEL_SEQUENCE[index]) == "shop":
			ordinal += 1
	return ordinal


func is_current_step_boss_reward() -> bool:
	return current_step_key == "boss_relic_reward"


func level_sequence_label() -> String:
	var step_label := _step_display_name(current_step_key)
	return "Level %d/%d | %s" % [dungeon_level, MAX_DUNGEON_LEVELS, step_label]


func current_level_boss_preview() -> Dictionary:
	return _prototype_balance_apply_to_encounter(Dictionary(_boss_encounters_by_level.get(dungeon_level, {})))


func current_level_boss_name() -> String:
	return String(current_level_boss_preview().get("display_name", "Unknown Boss"))


func skip_to_fight(level: int, fight: int) -> Dictionary:
	if level < 1 or level > MAX_DUNGEON_LEVELS:
		return {"ok": false, "reason": "level_must_be_1_to_%d" % MAX_DUNGEON_LEVELS, "next_scene": SCENE_COMBAT}
	if fight < 1 or fight > 3:
		return {"ok": false, "reason": "fight_must_be_1_to_3", "next_scene": SCENE_COMBAT}

	if not run_active:
		reset_run()
	run_active = true
	run_victory = false
	_run_summary.clear()
	_boss_relic_reward_options.clear()
	_boss_reward_claimed_relic_id = ""
	dungeon_level = level
	match fight:
		1:
			_step_index = 0
		2:
			_step_index = 2
		3:
			_step_index = 4
	current_step_key = LEVEL_SEQUENCE[_step_index]
	_run_log_append(
		"run_start",
		{
			"source": "skip_to_fight",
			"dungeon_level": dungeon_level,
			"step": current_step_key,
		}
	)
	_assign_current_fight()
	return _transition_result()


func current_encounter_snapshot() -> Dictionary:
	return _current_encounter.duplicate(true)


func boss_relic_reward_options_snapshot() -> Array[Dictionary]:
	return _boss_relic_reward_options.duplicate(true)


func claim_boss_relic_reward(option_index: int) -> Dictionary:
	if not run_active:
		return {"ok": false, "reason": "run_not_active"}
	if not is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step"}
	if option_index < 0 or option_index >= _boss_relic_reward_options.size():
		return {"ok": false, "reason": "invalid_option_index"}

	var option: Dictionary = _boss_relic_reward_options[option_index]
	var relic_id := String(option.get("relic_id", ""))
	var result: Dictionary = ensure_player_progression_service().add_relic(
		ensure_player_progression_state(),
		relic_id,
		ensure_content_registry()
	)
	var already_owned := String(result.get("reason", "")) == "relic_already_owned"
	if not bool(result.get("ok", false)) and not already_owned:
		return {
			"ok": false,
			"reason": String(result.get("reason", "relic_grant_failed")),
		}

	_boss_reward_claimed_relic_id = relic_id
	_boss_relic_reward_options.clear()
	_run_log_append(
		"boss_reward_choice",
		{
			"option_index": option_index,
			"relic_id": relic_id,
			"display_name": String(option.get("display_name", relic_id)),
			"already_owned": already_owned,
		}
	)
	return {
		"ok": true,
		"reason": "",
		"result": {
			"relic_id": relic_id,
			"display_name": String(option.get("display_name", relic_id)),
			"already_owned": already_owned,
		},
	}


func skip_boss_relic_reward() -> Dictionary:
	if not run_active:
		return {"ok": false, "reason": "run_not_active"}
	if not is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step"}
	_boss_reward_claimed_relic_id = ""
	_boss_relic_reward_options.clear()
	_run_log_append("boss_reward_skip", {})
	return {"ok": true, "reason": ""}


func advance_after_boss_reward() -> Dictionary:
	if not run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": SCENE_MAIN}
	if not is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step", "next_scene": SCENE_MAIN}
	_advance_sequence()
	return _transition_result()


func mark_fight_victory() -> Dictionary:
	if not run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": SCENE_MAIN}
	if not is_current_step_fight():
		return {"ok": false, "reason": "not_fight_step", "next_scene": SCENE_MAIN}
	var base_gold_reward := add_gold(
		prototype_fight_gold_reward_for(dungeon_level, current_step_key),
		"fight_base_reward"
	)
	_run_log_append("fight_end", _run_log_capture_fight_outcome_payload("victory", "", {
		"base_gold_reward": base_gold_reward,
	}))

	enemies_defeated += 1
	if bool(_current_encounter.get("is_boss", false)):
		bosses_defeated += 1
		if dungeon_level >= MAX_DUNGEON_LEVELS:
			_finalize_run(true, "Final boss defeated.")
			return _transition_result({"base_gold_reward": base_gold_reward})
		_prepare_boss_relic_reward_options()
	_advance_sequence()
	return _transition_result({"base_gold_reward": base_gold_reward})


func mark_player_defeated(cause: String) -> Dictionary:
	if run_active and is_current_step_fight():
		_run_log_append("fight_end", _run_log_capture_fight_outcome_payload("defeat", cause))
	_finalize_run(false, cause)
	return _transition_result()


func advance_after_shop(mark_skipped: bool) -> Dictionary:
	var shop_before_close: Dictionary = ensure_shop_state().to_snapshot()
	close_shop(mark_skipped)
	_run_log_append(
		"shop_leave",
		{
			"mark_skipped": mark_skipped,
			"shop_before": _run_log_sanitize_shop_snapshot(shop_before_close, run_gold),
			"shop_after": _run_log_sanitize_shop_snapshot(ensure_shop_state().to_snapshot(), run_gold),
		}
	)
	if not run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": SCENE_MAIN}
	if not is_current_step_shop():
		return {"ok": false, "reason": "not_shop_step", "next_scene": SCENE_MAIN}
	_advance_sequence()
	return _transition_result()


func run_summary_snapshot() -> Dictionary:
	if _run_summary.is_empty():
		var meta_snapshot := meta_profile_snapshot()
		return {
			"victory": false,
			"level_reached": dungeon_level,
			"levels_cleared": maxi(0, dungeon_level - 1),
			"enemies_defeated": enemies_defeated,
			"bosses_defeated": bosses_defeated,
			"gold_earned": total_gold_earned,
			"final_gold": run_gold,
			"run_score": run_score,
			"total_score": int(meta_snapshot.get("total_score", 0)),
			"cause": "Run not finished.",
			"equipment_slots": progression_snapshot().get("equipment_slots", []),
			"relic_ids": progression_snapshot().get("relic_ids", []),
		}
	return _run_summary.duplicate(true)


func run_log_snapshot() -> Dictionary:
	return {
		"run_id": _run_log_run_id,
		"started_unix": _run_log_started_unix,
		"started_iso": _run_log_started_iso,
		"event_count": _run_log_events.size(),
		"run_active": run_active,
		"run_victory": run_victory,
		"dungeon_level": dungeon_level,
		"current_step_key": current_step_key,
		"run_gold": run_gold,
		"run_score": run_score,
		"enemies_defeated": enemies_defeated,
		"bosses_defeated": bosses_defeated,
		"generate_log_files_enabled": _generate_run_log_files,
		"last_export": run_log_last_export_snapshot(),
		"summary": run_summary_snapshot(),
		"events": _run_log_events.duplicate(true),
	}


func run_log_export_json(pretty: bool = true) -> String:
	return JSON.stringify(run_log_snapshot(), "  " if pretty else "")


func run_log_export_text() -> String:
	var reporter = RUN_LOG_REPORTER_SCRIPT.new()
	return reporter.build_text_report(run_log_snapshot())


func run_log_export_markdown() -> String:
	var reporter = RUN_LOG_REPORTER_SCRIPT.new()
	return reporter.build_markdown_report(run_log_snapshot())


func run_log_last_export_snapshot() -> Dictionary:
	return {
		"paths": _run_log_last_export_paths.duplicate(true),
		"errors": _run_log_last_export_errors.duplicate(),
		"exported_unix": _run_log_last_export_unix,
	}


func run_log_last_export_paths() -> Dictionary:
	return _run_log_last_export_paths.duplicate(true)


func generate_run_log_files_enabled() -> bool:
	return _generate_run_log_files


func set_generate_run_log_files_enabled(enabled: bool) -> void:
	_generate_run_log_files = enabled
	_save_user_settings()


func load_user_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(USER_SETTINGS_PATH)
	if error == OK:
		_generate_run_log_files = bool(config.get_value(
			USER_SETTINGS_SECTION,
			USER_SETTINGS_GENERATE_LOG_KEY,
			false
		))
	else:
		_generate_run_log_files = false


func _load_meta_profile() -> void:
	_load_profile()


func _load_profile() -> void:
	var profile: PlayerProfileState = ensure_player_profile_state()
	var config := ConfigFile.new()
	var error := config.load(PROFILE_PATH)
	if error == OK:
		profile.load_from_config(config, PROFILE_SECTION)
		meta_profile_state = profile.meta_profile
		return
	var legacy_config := ConfigFile.new()
	var legacy_error := legacy_config.load(META_PROFILE_PATH)
	if legacy_error == OK:
		profile.reset_to_default()
		profile.meta_profile.load_from_config(legacy_config, META_PROFILE_SECTION)
		profile.mark_updated()
		meta_profile_state = profile.meta_profile
		_save_profile()
		return
	profile.reset_to_default()
	meta_profile_state = profile.meta_profile
	_save_profile()


func _save_meta_profile() -> void:
	_save_profile()


func _save_profile() -> void:
	var config := ConfigFile.new()
	ensure_player_profile_state().save_to_config(config, PROFILE_SECTION)
	var error := config.save(PROFILE_PATH)
	if error != OK:
		push_warning("Failed to save player profile at %s: %d" % [PROFILE_PATH, error])


func log_turn_result(turn_log: Dictionary, context: Dictionary = {}) -> void:
	var payload := {
		"turn_index_for_fight": _run_log_current_fight_turns + 1,
		"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", 0)),
		"enemy_blocked": int(turn_log.get("enemy_blocked", 0)),
		"healed": int(turn_log.get("healed", 0)),
		"armor_gained": int(turn_log.get("armor_gained", 0)),
		"gold_gained": int(turn_log.get("gold_gained", 0)),
		"damage_to_player": int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0)),
		"matches": Dictionary(turn_log.get("matched_counts", {})).duplicate(true),
		"raw_turn_log": turn_log.duplicate(true),
	}
	for key in context.keys():
		payload[key] = context[key]
	_run_log_current_fight_turns += 1
	_run_log_append("turn_result", payload)


func _advance_sequence() -> void:
	_step_index += 1
	if _step_index >= LEVEL_SEQUENCE.size():
		_step_index = LEVEL_SEQUENCE.size() - 1
	current_step_key = LEVEL_SEQUENCE[_step_index]

	if current_step_key != "advance":
		if is_current_step_fight():
			_assign_current_fight()
		return

	if dungeon_level >= MAX_DUNGEON_LEVELS:
		_finalize_run(true, "Final boss defeated.")
		return

	dungeon_level += 1
	_step_index = 0
	current_step_key = LEVEL_SEQUENCE[_step_index]
	_assign_current_fight()


func _assign_current_fight() -> void:
	if not is_current_step_fight():
		_current_encounter.clear()
		return

	var encounter: Dictionary = {}
	if current_step_key == "boss":
		encounter = Dictionary(_boss_encounters_by_level.get(dungeon_level, {})).duplicate(true)
	else:
		var fights: Array = _normal_encounters_by_level.get(dungeon_level, [])
		var fight_index := 0 if current_step_key == "enemy_1" else 1
		if fight_index >= 0 and fight_index < fights.size():
			encounter = Dictionary(fights[fight_index]).duplicate(true)

	if encounter.is_empty():
		encounter = {
			"enemy_id": "training_goblin",
			"display_name": "Training Goblin",
			"max_hp": 90,
			"is_boss": current_step_key == "boss",
			"intent_cycle": [],
		}

	encounter = _prototype_balance_apply_to_encounter(encounter)
	encounter["dungeon_level"] = dungeon_level
	encounter["step_key"] = current_step_key
	encounter["boss_preview_name"] = current_level_boss_name()
	_current_encounter = encounter
	_run_log_current_fight_turns = 0
	_run_log_append(
		"fight_start",
		{
			"encounter": _current_encounter.duplicate(true),
		}
	)


func _prepare_boss_relic_reward_options() -> void:
	_boss_relic_reward_options.clear()
	_boss_reward_claimed_relic_id = ""

	var progression = ensure_player_progression_state()
	var candidates: Array[Dictionary] = []
	for relic_data in ensure_content_registry().list_relics():
		var relic_id := String(relic_data.get("id", ""))
		if relic_id == "":
			continue
		if progression.has_relic(relic_id):
			continue
		candidates.append(Dictionary(relic_data))
	if candidates.is_empty():
		for relic_data in ensure_content_registry().list_relics():
			candidates.append(Dictionary(relic_data))
	if candidates.is_empty():
		return

	var pick_count := mini(3, candidates.size())
	for _i in pick_count:
		var index := _reward_rng.randi_range(0, candidates.size() - 1)
		var chosen: Dictionary = candidates[index]
		_boss_relic_reward_options.append({
			"relic_id": String(chosen.get("id", "")),
			"display_name": String(chosen.get("display_name", "Relic")),
			"rarity": String(chosen.get("rarity", "common")),
		})
		candidates.remove_at(index)


func _finalize_run(victory: bool, cause: String) -> void:
	run_active = false
	run_victory = victory
	var level_reached := dungeon_level
	var levels_cleared := dungeon_level - 1
	var victory_unlocks: Array[Dictionary] = []
	if victory:
		levels_cleared = MAX_DUNGEON_LEVELS
		level_reached = MAX_DUNGEON_LEVELS
		victory_unlocks = _grant_victory_equipment_unlocks()
	elif is_current_step_fight():
		levels_cleared = dungeon_level - 1

	var score_added := 0
	if not _run_score_banked:
		score_added = add_total_score(run_score)
		_run_score_banked = true
	var meta_snapshot := meta_profile_snapshot()
	var progression := progression_snapshot()
	_run_summary = {
		"victory": victory,
		"level_reached": level_reached,
		"levels_cleared": maxi(0, levels_cleared),
		"enemies_defeated": enemies_defeated,
		"bosses_defeated": bosses_defeated,
		"gold_earned": total_gold_earned,
		"final_gold": run_gold,
		"run_score": run_score,
		"score_added_to_total": score_added,
		"total_score": int(meta_snapshot.get("total_score", 0)),
		"victory_equipment_unlocks": victory_unlocks,
		"cause": cause,
		"equipment_slots": progression.get("equipment_slots", []),
		"relic_ids": progression.get("relic_ids", []),
	}
	_run_log_append(
		"run_end",
		{
			"victory": victory,
			"cause": cause,
			"summary": _run_summary.duplicate(true),
		}
	)
	if _generate_run_log_files:
		_run_log_export_to_disk()


func _run_log_reset() -> void:
	_run_log_events.clear()
	_run_log_event_serial = 0
	_run_log_run_id = _run_log_create_run_id()
	_run_log_started_unix = int(Time.get_unix_time_from_system())
	_run_log_started_iso = Time.get_datetime_string_from_system()
	_run_log_current_fight_turns = 0
	_run_log_last_export_paths.clear()
	_run_log_last_export_errors.clear()
	_run_log_last_export_unix = 0


func _run_log_append(event_type: String, payload: Dictionary) -> void:
	_run_log_event_serial += 1
	_run_log_events.append(
		{
			"seq": _run_log_event_serial,
			"event": event_type,
			"timestamp_unix": int(Time.get_unix_time_from_system()),
			"timestamp_iso": Time.get_datetime_string_from_system(),
			"run_id": _run_log_run_id,
			"dungeon_level": dungeon_level,
			"step_key": current_step_key,
			"run_gold": run_gold,
			"run_score": run_score,
			"run_active": run_active,
			"payload": payload.duplicate(true),
		}
	)


func _run_log_create_run_id() -> String:
	return "run_%d_%06d" % [int(Time.get_unix_time_from_system()), _reward_rng.randi_range(0, 999999)]


func _run_log_export_to_disk() -> void:
	_run_log_last_export_paths.clear()
	_run_log_last_export_errors.clear()
	_run_log_last_export_unix = int(Time.get_unix_time_from_system())

	var absolute_dir := ProjectSettings.globalize_path(RUN_LOG_EXPORT_DIR)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK:
		_run_log_last_export_errors.append("mkdir_failed:%s:%d" % [absolute_dir, mkdir_error])
		return

	var run_slug := _run_log_safe_filename_fragment(_run_log_run_id)
	var started_slug := _run_log_safe_filename_fragment(_run_log_started_iso)
	if started_slug == "":
		started_slug = str(_run_log_started_unix)
	var base_name := "%s_%s" % [run_slug, started_slug]

	_run_log_write_export_file(base_name + ".json", run_log_export_json(true), "json")
	_run_log_write_export_file(base_name + ".md", run_log_export_markdown(), "markdown")
	_run_log_write_export_file(base_name + ".txt", run_log_export_text(), "text")


func _save_user_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(USER_SETTINGS_SECTION, USER_SETTINGS_GENERATE_LOG_KEY, _generate_run_log_files)
	var error := config.save(USER_SETTINGS_PATH)
	if error != OK:
		push_warning("Failed to save user settings at %s: %d" % [USER_SETTINGS_PATH, error])


func _run_log_write_export_file(file_name: String, contents: String, kind: String) -> void:
	var resource_path := RUN_LOG_EXPORT_DIR.path_join(file_name)
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		_run_log_last_export_errors.append("write_failed:%s:%d" % [absolute_path, open_error])
		return
	file.store_string(contents)
	file.flush()
	file.close()
	_run_log_last_export_paths[kind] = {
		"resource_path": resource_path,
		"absolute_path": absolute_path,
	}


func _run_log_safe_filename_fragment(value: String) -> String:
	var source := value.strip_edges().to_lower()
	if source == "":
		return "run"
	var out := ""
	var underscore_pending := false
	for i in source.length():
		var c := source.unicode_at(i)
		var is_alpha := c >= 97 and c <= 122
		var is_digit := c >= 48 and c <= 57
		if is_alpha or is_digit:
			if underscore_pending and out != "":
				out += "_"
			underscore_pending = false
			out += String.chr(c)
		elif c == 45:
			if underscore_pending and out != "":
				out += "_"
			underscore_pending = false
			out += "-"
		elif c == 95:
			underscore_pending = true
		elif c == 32 or c == 46 or c == 58 or c == 47 or c == 92:
			underscore_pending = true
		else:
			underscore_pending = true
	if out == "":
		return "run"
	return out


func _run_log_result_brief(result: Dictionary) -> Dictionary:
	return {
		"ok": bool(result.get("ok", false)),
		"reason": String(result.get("reason", "")),
		"gold": int(result.get("gold", run_gold)),
		"result": Dictionary(result.get("result", {})).duplicate(true),
	}


func _run_log_shop_action(
	action: String,
	result: Dictionary,
	request: Dictionary = {},
	shop_before_snapshot: Dictionary = {},
	gold_before: int = -1
) -> void:
	if gold_before < 0:
		gold_before = run_gold
	var raw_before: Dictionary = shop_before_snapshot.duplicate(true)
	if raw_before.is_empty():
		raw_before = ensure_shop_state().to_snapshot()
	var raw_after: Dictionary = Dictionary(result.get("shop", {})).duplicate(true)
	if raw_after.is_empty():
		raw_after = ensure_shop_state().to_snapshot()
	var gold_after := int(result.get("gold", run_gold))
	var action_details := _run_log_shop_action_details(action, request, result, raw_before, gold_before)
	var payload := {
		"action": action,
		"request": request.duplicate(true),
		"result": _run_log_result_brief(result),
		"gold_before": gold_before,
		"gold_after": gold_after,
		"shop_before": _run_log_sanitize_shop_snapshot(raw_before, gold_before),
		"shop_after": _run_log_sanitize_shop_snapshot(raw_after, gold_after),
	}
	if not action_details.is_empty():
		payload["details"] = action_details
	_run_log_append("shop_action", payload)


func _run_log_shop_action_details(
	action: String,
	request: Dictionary,
	result: Dictionary,
	shop_before_snapshot: Dictionary,
	gold_before: int
) -> Dictionary:
	var details := {}
	var selected_offer := _run_log_find_selected_offer(request, shop_before_snapshot, gold_before)
	if not selected_offer.is_empty():
		details["selected_offer"] = selected_offer
	var selected_option := _run_log_find_selected_booster_option(request, shop_before_snapshot)
	if not selected_option.is_empty():
		details["selected_booster_option"] = selected_option

	var result_payload: Dictionary = Dictionary(result.get("result", {}))
	var granted := _run_log_sanitize_booster_option(Dictionary(result_payload.get("granted", {})))
	if not granted.is_empty():
		details["granted"] = granted
	var replacement: Dictionary = Dictionary(result_payload.get("replacement", {}))
	if not replacement.is_empty():
		details["replacement"] = replacement.duplicate(true)
	if bool(result_payload.get("discarded", false)):
		details["discarded"] = true

	if action == "buy_offer" and bool(result.get("ok", false)) and not selected_offer.is_empty():
		details["purchased_offer"] = selected_offer
	return details


func _run_log_find_selected_offer(request: Dictionary, shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	var offer_id := String(request.get("offer_id", ""))
	if offer_id == "":
		return {}
	for raw_offer in Array(shop_snapshot.get("item_offers", [])):
		var offer: Dictionary = Dictionary(raw_offer)
		if String(offer.get("offer_id", "")) == offer_id:
			return _run_log_sanitize_shop_offer(offer, gold_value)
	var relic_offer := Dictionary(shop_snapshot.get("relic_offer", {}))
	if String(relic_offer.get("offer_id", "")) == offer_id:
		return _run_log_sanitize_shop_relic_offer(relic_offer, gold_value)
	return {}


func _run_log_find_selected_booster_option(request: Dictionary, shop_snapshot: Dictionary) -> Dictionary:
	if not request.has("option_index"):
		return {}
	var option_index := int(request.get("option_index", -1))
	var options: Array = Array(shop_snapshot.get("pending_booster_options", []))
	if option_index < 0 or option_index >= options.size():
		return {}
	return _run_log_sanitize_booster_option(Dictionary(options[option_index]), option_index)


func _run_log_sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	var item_offers: Array[Dictionary] = []
	var item_type_counts := {}
	var has_booster_offer := false
	for raw_offer in Array(shop_snapshot.get("item_offers", [])):
		var offer := _run_log_sanitize_shop_offer(Dictionary(raw_offer), gold_value)
		if offer.is_empty():
			continue
		item_offers.append(offer)
		var offer_type := String(offer.get("type", ""))
		item_type_counts[offer_type] = int(item_type_counts.get(offer_type, 0)) + 1
		if offer_type == "booster":
			has_booster_offer = true

	var relic_offer := _run_log_sanitize_shop_relic_offer(Dictionary(shop_snapshot.get("relic_offer", {})), gold_value)
	var booster_options: Array[Dictionary] = []
	var option_index := 0
	for raw_option in Array(shop_snapshot.get("pending_booster_options", [])):
		booster_options.append(_run_log_sanitize_booster_option(Dictionary(raw_option), option_index))
		option_index += 1

	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	return {
		"active": bool(shop_snapshot.get("active", false)),
		"dungeon_level": int(shop_snapshot.get("dungeon_level", dungeon_level)),
		"item_offers": item_offers,
		"item_type_counts": item_type_counts,
		"has_booster_offer": has_booster_offer,
		"has_relic_offer": not relic_offer.is_empty(),
		"relic_offer": relic_offer,
		"reroll_count": int(shop_snapshot.get("reroll_count", 0)),
		"reroll_cost": reroll_cost,
		"can_afford_reroll": gold_value >= reroll_cost,
		"pending_booster_option_count": booster_options.size(),
		"pending_booster_options": booster_options,
		"pending_booster_offer_id": String(shop_snapshot.get("pending_booster_offer_id", "")),
		"skipped": bool(shop_snapshot.get("skipped", false)),
	}


func _run_log_sanitize_shop_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	if offer.is_empty():
		return {}
	var price := int(offer.get("price", 0))
	var sold_out := bool(offer.get("sold_out", false))
	var available := bool(offer.get("available", not sold_out))
	return {
		"offer_id": String(offer.get("offer_id", "")),
		"content_id": String(offer.get("content_id", "")),
		"display_name": String(offer.get("display_name", "")),
		"type": String(offer.get("type", "")),
		"rarity": String(offer.get("rarity", "")),
		"price": price,
		"available": available,
		"sold_out": sold_out,
		"can_afford": gold_value >= price,
	}


func _run_log_sanitize_shop_relic_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	if offer.is_empty():
		return {}
	var relic_offer := _run_log_sanitize_shop_offer(offer, gold_value)
	var relic_id := String(relic_offer.get("content_id", ""))
	relic_offer["owned"] = _run_log_owned_relic_ids().has(relic_id)
	return relic_offer


func _run_log_sanitize_booster_option(option: Dictionary, option_index: int = -1) -> Dictionary:
	if option.is_empty():
		return {}
	var out := {
		"type": String(option.get("type", "")),
		"content_id": String(option.get("content_id", "")),
		"display_name": String(option.get("display_name", "")),
	}
	if option_index >= 0:
		out["option_index"] = option_index
	return out


func _run_log_owned_relic_ids() -> Dictionary:
	var owned_ids := {}
	for raw_id in ensure_player_progression_state().relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			owned_ids[relic_id] = true
	return owned_ids


func _run_log_next_shop_ordinal() -> int:
	var count := 0
	for entry in _run_log_events:
		if String(entry.get("event", "")) == "shop_open":
			count += 1
	return count + 1


func _run_log_capture_fight_outcome_payload(outcome: String, cause: String = "", extra: Dictionary = {}) -> Dictionary:
	var payload := {
		"outcome": outcome,
		"dungeon_level": dungeon_level,
		"step_key": current_step_key,
		"is_boss": bool(_current_encounter.get("is_boss", false)),
		"enemy_id": String(_current_encounter.get("enemy_id", "")),
		"enemy_name": String(_current_encounter.get("display_name", "")),
		"turn_count": _run_log_current_fight_turns,
	}
	if cause != "":
		payload["cause"] = cause
	for key in extra.keys():
		payload[key] = extra[key]
	return payload


func _transition_result(extra: Dictionary = {}) -> Dictionary:
	var result := {
		"ok": true,
		"reason": "",
		"next_scene": next_scene_path(),
		"step": current_step_key,
		"dungeon_level": dungeon_level,
	}
	for key in extra.keys():
		result[key] = extra[key]
	return result


func next_scene_path() -> String:
	if not run_active:
		if not _run_summary.is_empty():
			return SCENE_RUN_SUMMARY
		return SCENE_MAIN
	if is_current_step_fight():
		return SCENE_COMBAT
	if is_current_step_shop():
		return SCENE_SHOP
	if is_current_step_boss_reward():
		return SCENE_COMBAT
	return SCENE_MAIN


func _gold_source_counts_for_run_score(source: String) -> bool:
	return source != "sell_refund" and source != "shop_refund" and source != "replacement_sell_refund"


func _sync_meta_profile_default_unlocks() -> void:
	var common_item_ids: Array[String] = []
	for equipment in ensure_content_registry().list_equipment():
		var data := Dictionary(equipment)
		if String(data.get("rarity", "")) != "common":
			continue
		var item_id := String(data.get("id", ""))
		if item_id != "":
			common_item_ids.append(item_id)
	if ensure_meta_profile_state().mark_default_unlocked(common_item_ids):
		_save_meta_profile()


func _can_claim_equipment_unlock(equipment: Dictionary) -> bool:
	var rarity := String(equipment.get("rarity", "common"))
	if rarity == "common":
		return true
	var previous_tier_item_id := _previous_tier_item_id(String(equipment.get("id", "")))
	if previous_tier_item_id == "":
		return false
	return is_equipment_unlocked(previous_tier_item_id)


func _previous_tier_item_id(target_item_id: String) -> String:
	if target_item_id == "":
		return ""
	for raw_equipment in ensure_content_registry().list_equipment():
		var equipment := Dictionary(raw_equipment)
		if String(equipment.get("next_tier_item_id", "")) == target_item_id:
			return String(equipment.get("id", ""))
	return ""


func _grant_victory_equipment_unlocks() -> Array[Dictionary]:
	var unlocks: Array[Dictionary] = []
	var progression = ensure_player_progression_state()
	for slot_index in range(progression.equipped_item_ids.size()):
		var item_id := String(progression.equipped_item_ids[slot_index])
		if item_id == "":
			continue
		var equipment: Dictionary = ensure_content_registry().get_equipment(item_id)
		if equipment.is_empty():
			continue
		var next_tier_item_id := String(equipment.get("next_tier_item_id", ""))
		if next_tier_item_id == "" or is_equipment_unlocked(next_tier_item_id):
			continue
		var unlock_result := unlock_equipment(next_tier_item_id, "victory")
		if not bool(unlock_result.get("ok", false)):
			continue
		var unlock_payload := Dictionary(unlock_result.get("unlock", {}))
		unlock_payload["source_item_id"] = item_id
		unlock_payload["slot_index"] = slot_index
		unlocks.append(unlock_payload)
	return unlocks


func flow_trace_begin(route_name: String, target_scene: String, details: Dictionary = {}) -> String:
	if not FLOW_TRACE_ENABLED:
		return ""
	_flow_trace_route_serial += 1
	var route_id := "%s_%d" % [route_name, _flow_trace_route_serial]
	var now := Time.get_ticks_usec()
	_flow_trace_routes[route_id] = {
		"route_name": route_name,
		"target_scene": target_scene,
		"start_usec": now,
		"last_usec": now,
	}
	_flow_trace_active_route_id = route_id
	_flow_trace_mark_internal(route_id, "route_begin", details, target_scene)
	return route_id


func flow_trace_mark(step: String, details: Dictionary = {}, route_id: String = "", target_scene_override: String = "") -> void:
	if not FLOW_TRACE_ENABLED:
		return
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = _flow_trace_active_route_id
	if resolved_route_id == "":
		return
	_flow_trace_mark_internal(resolved_route_id, step, details, target_scene_override)


func flow_trace_change_scene(
	tree: SceneTree,
	target_scene: String,
	route_id: String = "",
	source: String = "",
	before_step: String = ""
) -> int:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()

	if before_step != "":
		var before_details := {}
		if source != "":
			before_details["source"] = source
		flow_trace_mark(before_step, before_details, resolved_route_id, target_scene)

	var prepared := flow_trace_prepare_scene(target_scene, resolved_route_id, source)
	if not bool(prepared.get("ok", false)):
		return int(prepared.get("error_code", ERR_CANT_OPEN))

	return flow_trace_attach_prepared_scene(tree, prepared, target_scene, resolved_route_id, source)


func flow_trace_prepare_scene(
	target_scene: String,
	route_id: String = "",
	source: String = ""
) -> Dictionary:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()

	var transition_details := {}
	if source != "":
		transition_details["source"] = source
	flow_trace_mark("transition_manual_start", transition_details, resolved_route_id, target_scene)
	flow_trace_mark("before_resource_load", transition_details, resolved_route_id, target_scene)

	if target_scene.strip_edges() == "":
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": 0,
				"error": "target_scene_empty",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_OPEN,
			"reason": "target_scene_empty",
			"route_id": resolved_route_id,
		}

	var load_start_usec := Time.get_ticks_usec()
	var loaded_resource: Resource = ResourceLoader.load(target_scene)
	var load_ms := int((Time.get_ticks_usec() - load_start_usec) / 1000.0)
	if loaded_resource == null:
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": load_ms,
				"error": "resource_load_failed",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_OPEN,
			"reason": "resource_load_failed",
			"route_id": resolved_route_id,
		}
	if not (loaded_resource is PackedScene):
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": load_ms,
				"resource_type": loaded_resource.get_class(),
				"error": "resource_not_packed_scene",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_INVALID_DATA,
			"reason": "resource_not_packed_scene",
			"route_id": resolved_route_id,
		}

	var packed_scene := loaded_resource as PackedScene
	flow_trace_mark(
		"after_resource_load",
		{
			"ok": true,
			"load_ms": load_ms,
			"resource_type": packed_scene.get_class(),
		},
		resolved_route_id,
		target_scene
	)
	flow_trace_mark("before_scene_instantiate", transition_details, resolved_route_id, target_scene)

	var instantiate_start_usec := Time.get_ticks_usec()
	var instantiated_scene = packed_scene.instantiate()
	var instantiate_ms := int((Time.get_ticks_usec() - instantiate_start_usec) / 1000.0)
	if instantiated_scene == null:
		flow_trace_mark(
			"after_scene_instantiate",
			{
				"ok": false,
				"instantiate_ms": instantiate_ms,
				"error": "instantiate_returned_null",
			},
			resolved_route_id,
			target_scene
		)
		push_error("[FlowTrace] flow_trace_change_scene instantiate failed for %s (null)" % target_scene)
		return {
			"ok": false,
			"error_code": ERR_CANT_CREATE,
			"reason": "instantiate_returned_null",
			"route_id": resolved_route_id,
		}
	if not (instantiated_scene is Node):
		flow_trace_mark(
			"after_scene_instantiate",
			{
				"ok": false,
				"instantiate_ms": instantiate_ms,
				"node_type": instantiated_scene.get_class(),
				"error": "instantiate_not_node",
			},
			resolved_route_id,
			target_scene
		)
		push_error(
			"[FlowTrace] flow_trace_change_scene instantiate returned non-Node for %s: %s"
			% [target_scene, instantiated_scene.get_class()]
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_CREATE,
			"reason": "instantiate_not_node",
			"route_id": resolved_route_id,
		}

	var new_scene := instantiated_scene as Node
	flow_trace_mark(
		"after_scene_instantiate",
		{
			"ok": true,
			"instantiate_ms": instantiate_ms,
			"node_type": new_scene.get_class(),
			"node_name": new_scene.name,
		},
		resolved_route_id,
		target_scene
	)
	return {
		"ok": true,
		"error_code": OK,
		"scene": new_scene,
		"route_id": resolved_route_id,
	}


func flow_trace_attach_prepared_scene(
	tree: SceneTree,
	prepared: Dictionary,
	target_scene: String,
	route_id: String = "",
	source: String = ""
) -> int:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = String(prepared.get("route_id", ""))
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()
	if not bool(prepared.get("ok", false)):
		var prepared_error_code := int(prepared.get("error_code", ERR_INVALID_DATA))
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": prepared_error_code,
				"attach_ms": 0,
				"error": "prepared_scene_invalid",
			},
			resolved_route_id,
			target_scene
		)
		return prepared_error_code
	var new_scene := prepared.get("scene", null) as Node
	if new_scene == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_INVALID_DATA,
				"attach_ms": 0,
				"error": "prepared_scene_missing",
			},
			resolved_route_id,
			target_scene
		)
		return ERR_INVALID_DATA
	var old_scene: Node = null
	var old_scene_name := ""
	var old_scene_path := ""
	if tree != null:
		old_scene = tree.current_scene
	if old_scene != null and is_instance_valid(old_scene):
		old_scene_name = old_scene.name
		if old_scene.is_inside_tree():
			old_scene_path = String(old_scene.get_path())

	flow_trace_mark(
		"before_scene_attach",
		{
			"source": source,
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
		},
		resolved_route_id,
		target_scene
	)

	if tree == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_UNAVAILABLE,
				"attach_ms": 0,
				"error": "scene_tree_null",
			},
			resolved_route_id,
			target_scene
		)
		new_scene.free()
		push_error("[FlowTrace] flow_trace_change_scene failed: SceneTree is null for %s" % target_scene)
		return ERR_UNAVAILABLE

	var tree_root := tree.root
	if tree_root == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_UNAVAILABLE,
				"attach_ms": 0,
				"error": "scene_tree_root_null",
			},
			resolved_route_id,
			target_scene
		)
		new_scene.free()
		push_error("[FlowTrace] flow_trace_change_scene failed: SceneTree root is null for %s" % target_scene)
		return ERR_UNAVAILABLE

	var attach_start_usec := Time.get_ticks_usec()
	tree_root.add_child(new_scene)
	tree.current_scene = new_scene
	var attach_ms := int((Time.get_ticks_usec() - attach_start_usec) / 1000.0)
	if tree.current_scene != new_scene:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_CANT_CREATE,
				"attach_ms": attach_ms,
				"error": "current_scene_not_updated",
			},
			resolved_route_id,
			target_scene
		)
		if is_instance_valid(new_scene):
			new_scene.queue_free()
		push_error("[FlowTrace] flow_trace_change_scene failed: current_scene assignment failed for %s" % target_scene)
		return ERR_CANT_CREATE

	var new_scene_path := ""
	if new_scene.is_inside_tree():
		new_scene_path = String(new_scene.get_path())
	flow_trace_mark(
		"after_scene_attach",
		{
			"ok": true,
			"error_code": OK,
			"attach_ms": attach_ms,
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
			"new_scene_name": new_scene.name,
			"new_scene_path": new_scene_path,
		},
		resolved_route_id,
		target_scene
	)

	if old_scene != null and is_instance_valid(old_scene) and old_scene != new_scene:
		flow_trace_mark(
			"before_old_scene_free",
			{
				"old_scene_name": old_scene_name,
				"old_scene_path": old_scene_path,
			},
			resolved_route_id,
			target_scene
		)
		old_scene.queue_free()

	return OK


func flow_trace_active_route_id() -> String:
	return _flow_trace_active_route_id


func _flow_trace_mark_internal(route_id: String, step: String, details: Dictionary, target_scene_override: String) -> void:
	var route_data: Dictionary = _flow_trace_routes.get(route_id, {})
	if route_data.is_empty():
		var now_missing := Time.get_ticks_usec()
		route_data = {
			"route_name": "unknown",
			"target_scene": target_scene_override,
			"start_usec": now_missing,
			"last_usec": now_missing,
		}
	var now := Time.get_ticks_usec()
	var start_usec := int(route_data.get("start_usec", now))
	var last_usec := int(route_data.get("last_usec", start_usec))
	var target_scene := String(route_data.get("target_scene", ""))
	if target_scene_override != "":
		target_scene = target_scene_override
	var elapsed_ms := int((now - start_usec) / 1000.0)
	var delta_ms := int((now - last_usec) / 1000.0)
	route_data["last_usec"] = now
	route_data["target_scene"] = target_scene
	_flow_trace_routes[route_id] = route_data

	var details_text := ""
	if not details.is_empty():
		details_text = " details=%s" % str(details)
	print(
		"[FlowTrace] route_id=%s route=%s target_scene=%s elapsed_ms=%d delta_ms=%d step=%s dungeon_level=%d run_active=%s current_step=%s%s"
		% [
			route_id,
			String(route_data.get("route_name", "unknown")),
			target_scene,
			elapsed_ms,
			delta_ms,
			step,
			dungeon_level,
			str(run_active),
			current_step_key,
			details_text,
		]
	)


func _step_display_name(step: String) -> String:
	match step:
		"enemy_1":
			return "Enemy 1"
		"enemy_2":
			return "Enemy 2"
		"boss":
			return "Boss"
		"shop":
			return "Shop"
		"boss_relic_reward":
			return "Boss Relic Reward"
		"advance":
			return "Advance"
		_:
			return "Unknown"


func _sync_player_gold_from_run() -> void:
	ensure_player_state().gold = run_gold


func _normalized_prototype_balance_levers(levers: Dictionary) -> Dictionary:
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


func _sync_prototype_balance_project_settings() -> void:
	for key in _prototype_balance_levers.keys():
		ProjectSettings.set_setting(
			PROTOTYPE_BALANCE_PROJECT_SETTINGS_PREFIX + String(key),
			_prototype_balance_levers[key]
		)


func _prototype_balance_apply_to_encounter(source: Dictionary) -> Dictionary:
	var encounter := source.duplicate(true)
	if encounter.is_empty():
		return encounter
	var encounter_level := clampi(int(encounter.get("dungeon_level", dungeon_level)), 1, MAX_DUNGEON_LEVELS)
	var encounter_is_boss := bool(encounter.get("is_boss", false))
	var hp_multiplier := float(_prototype_balance_levers.get("enemy_hp_multiplier", 1.0))
	hp_multiplier *= _prototype_balance_level_scoped_multiplier(encounter_level, encounter_is_boss, "hp")
	var damage_multiplier := float(_prototype_balance_levers.get("enemy_damage_multiplier", 1.0))
	damage_multiplier *= _prototype_balance_level_scoped_multiplier(encounter_level, encounter_is_boss, "damage")
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


func _prototype_balance_level_scoped_multiplier(level: int, is_boss: bool, stat: String) -> float:
	var clamped_level := clampi(level, 1, MAX_DUNGEON_LEVELS)
	var scope := "boss" if is_boss else "normal"
	var key := "level_%d_%s_%s_multiplier" % [clamped_level, scope, stat]
	return maxf(0.0, float(_prototype_balance_levers.get(key, 1.0)))


func _merge_combat_modifiers(target: Dictionary, source_data: Dictionary) -> void:
	var modifiers: Dictionary = source_data.get("combat_modifiers", {})
	var target_orb_bonus: Dictionary = target.get("orb_bonus_by_id", {})
	var source_orb_bonus: Dictionary = modifiers.get("orb_bonus_by_id", {})
	for orb_id in source_orb_bonus.keys():
		var orb_key := int(orb_id)
		target_orb_bonus[orb_key] = int(target_orb_bonus.get(orb_key, 0)) + int(source_orb_bonus.get(orb_id, 0))
	target["orb_bonus_by_id"] = target_orb_bonus
	target["combo_flat_bonus"] = int(target.get("combo_flat_bonus", 0)) + int(modifiers.get("combo_flat_bonus", 0))
	target["combo_multiplier_mult"] = float(target.get("combo_multiplier_mult", 1.0)) * float(modifiers.get("combo_multiplier_mult", 1.0))
	target["start_turn_armor"] = int(target.get("start_turn_armor", 0)) + int(modifiers.get("start_turn_armor", 0))
	target["flat_damage_bonus"] = int(target.get("flat_damage_bonus", 0)) + int(modifiers.get("flat_damage_bonus", 0))
	target["flat_heal_bonus"] = int(target.get("flat_heal_bonus", 0)) + int(modifiers.get("flat_heal_bonus", 0))
	target["flat_gold_bonus"] = int(target.get("flat_gold_bonus", 0)) + int(modifiers.get("flat_gold_bonus", 0))


func _append_combat_modifier_source(target: Dictionary, source_data: Dictionary, source_type: String) -> void:
	if source_data.is_empty():
		return
	var source_modifiers: Dictionary = source_data.get("combat_modifiers", {})
	if source_modifiers.is_empty():
		return
	var sources: Array = target.get("sources", [])
	sources.append({
		"source_type": source_type,
		"source_id": String(source_data.get("id", "")),
		"display_name": String(source_data.get("display_name", source_data.get("id", "unknown"))),
		"combat_modifiers": source_modifiers.duplicate(true),
	})
	target["sources"] = sources
