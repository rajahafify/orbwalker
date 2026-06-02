extends Node

signal gold_changed(payload: Dictionary)
signal run_step_changed(payload: Dictionary)
signal run_state_changed(payload: Dictionary)
signal profile_changed(payload: Dictionary)
signal run_summary_changed(payload: Dictionary)

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")
const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const SHOP_STATE_SCRIPT := preload("res://scripts/shop/shop_state.gd")
const SHOP_SERVICE_SCRIPT := preload("res://scripts/shop/shop_service.gd")
const RUN_LOGGER_SCRIPT := preload("res://scripts/core/run_logger.gd")
const SCENE_ROUTER_SCRIPT := preload("res://scripts/core/scene_router.gd")
const PROFILE_REPOSITORY_SCRIPT := preload("res://scripts/core/profile_repository.gd")
const BALANCE_MANAGER_SCRIPT := preload("res://scripts/core/balance_manager.gd")
const RUN_LOG_EXPORT_DIR := "res://logs"
const USER_SETTINGS_PATH := "user://matchatro_settings.cfg"
const USER_SETTINGS_SECTION := "run_log"
const USER_SETTINGS_GENERATE_LOG_KEY := "generate_log"
const USER_SETTINGS_GAMEPLAY_SECTION := "gameplay"
const USER_SETTINGS_VFX_SPEED_KEY := "vfx_speed"
const USER_SETTINGS_COMBAT_VFX_QUALITY_KEY := "combat_vfx_quality"
const USER_SETTINGS_REDUCED_MOTION_KEY := "reduced_motion"
const VFX_SPEED_SLOW := "slow"
const VFX_SPEED_NORMAL := "normal"
const VFX_SPEED_FAST := "fast"
const VFX_SPEED_INSTANT := "instant"
const COMBAT_VFX_QUALITY_LOW := "low"
const COMBAT_VFX_QUALITY_HIGH := "high"
const SCENE_MAIN := "res://scenes/main_menu.tscn"
const SCENE_COMBAT := "res://scenes/combat.tscn"
const SCENE_SHOP := "res://scenes/shop.tscn"
const SCENE_RUN_SUMMARY := "res://scenes/run_summary.tscn"
const MAX_DUNGEON_LEVELS := 3
const TUTORIAL_SEED := 271828
const FLOW_TRACE_ENABLED := true
const FLOW_TRACE_ROUTE_RETENTION_MAX := 50
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
var tutorial_run_active: bool = false
var tutorial_seed: int = TUTORIAL_SEED
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
var _run_logger
var _scene_router
var _profile_repository
var _balance_manager
var _vfx_speed := VFX_SPEED_NORMAL
var _combat_vfx_quality := COMBAT_VFX_QUALITY_LOW
var _reduced_motion := false

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
	_ensure_balance_manager().sync_content_registry(content_registry)
	return content_registry


func ensure_shop_state():
	if shop_state == null:
		shop_state = SHOP_STATE_SCRIPT.new()
	return shop_state


func ensure_shop_service():
	if shop_service == null:
		shop_service = SHOP_SERVICE_SCRIPT.new()
	return shop_service


func _ensure_run_logger():
	if _run_logger == null:
		_run_logger = RUN_LOGGER_SCRIPT.new(self)
	return _run_logger


func _ensure_scene_router():
	if _scene_router == null:
		_scene_router = SCENE_ROUTER_SCRIPT.new(self, FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX)
	return _scene_router


func _ensure_profile_repository():
	if _profile_repository == null:
		_profile_repository = PROFILE_REPOSITORY_SCRIPT.new()
	return _profile_repository


func _ensure_balance_manager():
	if _balance_manager == null:
		_balance_manager = BALANCE_MANAGER_SCRIPT.new()
	return _balance_manager


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
			"_balance_manager",
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
			"run_log_export_html",
			"run_log_last_export_snapshot",
			"run_log_last_export_paths",
			"log_turn_result",
			"prototype_balance_levers_snapshot",
			"set_prototype_balance_levers",
			"reset_prototype_balance_levers",
			"prototype_fight_gold_reward_for",
			"current_shop_ordinal_in_level",
			"finish_tutorial_guidance",
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
	return _ensure_balance_manager().levers_snapshot()


func prototype_balance_defaults_snapshot() -> Dictionary:
	return _ensure_balance_manager().defaults_snapshot()


func set_prototype_balance_levers(levers: Dictionary) -> Dictionary:
	var snapshot: Dictionary = _ensure_balance_manager().set_levers(levers)
	if content_registry != null:
		_ensure_balance_manager().sync_content_registry(content_registry)
	return snapshot


func reset_prototype_balance_levers() -> Dictionary:
	var snapshot: Dictionary = _ensure_balance_manager().reset_levers()
	if content_registry != null:
		_ensure_balance_manager().sync_content_registry(content_registry)
	return snapshot


func prototype_fight_gold_reward_for(level: int, _step_key: String = "") -> int:
	return _ensure_balance_manager().fight_gold_reward_for(level, MAX_DUNGEON_LEVELS)


func progression_snapshot() -> Dictionary:
	return ensure_player_progression_state().to_snapshot()


func profile_snapshot() -> Dictionary:
	return ensure_player_profile_state().to_snapshot()


func meta_profile_snapshot() -> Dictionary:
	return ensure_meta_profile_state().to_snapshot()


func reset_profile() -> Dictionary:
	var signal_before := _capture_run_signal_state()
	var profile: PlayerProfileState = ensure_player_profile_state()
	profile.reset_to_default()
	meta_profile_state = profile.meta_profile
	_sync_meta_profile_default_unlocks()
	_save_profile()
	reset_run("reset_profile", false)
	_emit_run_state_signals(signal_before, "reset_profile", "reset_profile")
	_emit_profile_changed("reset_profile")
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


func unlock_equipment(item_id: String, source: String, emit_profile_signal: bool = true) -> Dictionary:
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
	if emit_profile_signal:
		_emit_profile_changed("unlock_equipment", 0, unlock_payload)
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

	var unlock_result := unlock_equipment(item_id, "score_claim", false)
	if not bool(unlock_result.get("ok", false)):
		ensure_meta_profile_state().add_total_score(unlock_cost)
		_save_meta_profile()
		return unlock_result
	_emit_profile_changed("claim_equipment_unlock", -unlock_cost, Dictionary(unlock_result.get("unlock", {})))
	unlock_result["score_spent"] = unlock_cost
	return unlock_result


func consume_recent_equipment_unlocks() -> Array[Dictionary]:
	var unlocks: Array[Dictionary] = ensure_meta_profile_state().consume_recent_equipment_unlocks()
	_save_meta_profile()
	_emit_profile_changed("consume_recent_equipment_unlocks", 0, {"consumed": unlocks.duplicate(true)})
	return unlocks


func add_total_score(amount: int) -> int:
	var added: int = ensure_meta_profile_state().add_total_score(amount)
	if added > 0:
		_save_meta_profile()
		_emit_profile_changed("add_total_score", added)
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
	var signal_before := _capture_run_signal_state()
	run_gold = maxi(0, amount)
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "set_gold", "set_gold")


func add_gold(amount: int, source: String = "combat_gain") -> int:
	if amount <= 0:
		return 0
	var signal_before := _capture_run_signal_state()
	run_gold += amount
	total_gold_earned += amount
	if _gold_source_counts_for_run_score(source):
		run_score += amount
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "add_gold", source)
	return amount


func spend_gold(amount: int) -> bool:
	if amount < 0:
		return false
	if run_gold < amount:
		return false
	var signal_before := _capture_run_signal_state()
	run_gold -= amount
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "spend_gold", "spend_gold")
	return true


func can_afford(amount: int) -> bool:
	return amount >= 0 and run_gold >= amount


func open_shop_for_current_level() -> Dictionary:
	_apply_tutorial_shop_seed(0)
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
	_apply_tutorial_shop_seed(100 + ensure_shop_state().reroll_count)
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


func choose_treasure_chest_option(option_index: int) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().choose_treasure_chest_option(self, option_index)
	_run_log_shop_action("choose_treasure_chest", result, {"option_index": option_index}, shop_before, gold_before)
	return result


func replace_pending_treasure_chest_option(option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().replace_pending_treasure_chest_option(self, option_index, slot_index, sell_replaced)
	_run_log_shop_action(
		"replace_treasure_chest_option",
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


func discard_pending_treasure_chest_options() -> Dictionary:
	var shop_before: Dictionary = ensure_shop_state().to_snapshot()
	var gold_before := run_gold
	var result: Dictionary = ensure_shop_service().discard_pending_treasure_chest_options(self)
	_run_log_shop_action("skip_treasure_chest", result, {}, shop_before, gold_before)
	return result


func close_shop(mark_skipped: bool = false) -> void:
	ensure_shop_state().close_shop(mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return String(_relic_offer_ids_by_level.get(maxi(1, level), ""))


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_relic_offer_ids_by_level[maxi(1, level)] = relic_id


func _apply_tutorial_shop_seed(action_offset: int) -> void:
	if not tutorial_run_active:
		return
	var shop_seed := tutorial_seed + 50000 + dungeon_level * 1000 + _step_index * 100 + maxi(0, action_offset)
	ensure_shop_service().set_rng_seed(shop_seed)


func reset_run(reason: String = "reset_run", emit_signals: bool = true) -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	ensure_player_state().reset_for_new_run()
	_sync_meta_profile_default_unlocks()
	run_gold = _ensure_balance_manager().starting_gold()
	run_score = 0
	_run_score_banked = false
	ensure_player_state().gold = run_gold
	dungeon_level = 1
	_relic_offer_ids_by_level.clear()
	ensure_player_progression_state().reset_for_new_run()
	ensure_shop_state().reset_for_new_run()
	run_active = false
	run_victory = false
	tutorial_run_active = false
	tutorial_seed = TUTORIAL_SEED
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
	if emit_signals:
		_emit_run_state_signals(signal_before, reason, reason)


func start_new_run() -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	reset_run("start_new_run", false)
	tutorial_run_active = false
	_reward_rng.randomize()
	ensure_shop_service().randomize_rng()
	run_active = true
	_run_log_append(
		"run_start",
		{
			"dungeon_level": dungeon_level,
			"step": current_step_key,
		}
	)
	_assign_current_fight()
	_emit_run_state_signals(signal_before, "start_new_run", "start_new_run")


func start_tutorial_run(seed_value: int = TUTORIAL_SEED) -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	reset_run("start_tutorial_run", false)
	tutorial_run_active = true
	tutorial_seed = maxi(1, seed_value)
	run_active = true
	_reward_rng.seed = tutorial_seed + 9000
	_run_log_append(
		"run_start",
		{
			"source": "tutorial",
			"tutorial": true,
			"seed": tutorial_seed,
			"dungeon_level": dungeon_level,
			"step": current_step_key,
		}
	)
	_assign_current_fight()
	_emit_run_state_signals(signal_before, "start_tutorial_run", "start_tutorial_run")


func snapshot_run_transition_state() -> Dictionary:
	var snapshot := {
		"player_state": _snapshot_player_state_for_transition(),
		"player_progression_state": _snapshot_player_progression_state_for_transition(),
		"shop_state": _snapshot_shop_state_for_transition(),
		"run_active": run_active,
		"run_victory": run_victory,
		"tutorial_run_active": tutorial_run_active,
		"tutorial_seed": tutorial_seed,
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
	}
	snapshot.merge(_ensure_run_logger().transition_snapshot(), true)
	snapshot.merge(_ensure_scene_router().transition_snapshot(), true)
	return snapshot


func restore_run_transition_state(snapshot: Dictionary) -> bool:
	if snapshot.is_empty():
		return false
	var signal_before := _capture_run_signal_state()
	run_active = bool(snapshot.get("run_active", run_active))
	run_victory = bool(snapshot.get("run_victory", run_victory))
	tutorial_run_active = bool(snapshot.get("tutorial_run_active", tutorial_run_active))
	tutorial_seed = maxi(1, int(snapshot.get("tutorial_seed", tutorial_seed)))
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
	_ensure_run_logger().restore_transition_snapshot(snapshot)
	_ensure_scene_router().restore_transition_snapshot(snapshot)
	_restore_player_state_for_transition(Dictionary(snapshot.get("player_state", {})))
	_restore_player_progression_state_for_transition(Dictionary(snapshot.get("player_progression_state", {})))
	_restore_shop_state_for_transition(Dictionary(snapshot.get("shop_state", {})))
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "restore_run_transition_state", "restore_run_transition_state")
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
	state.pending_treasure_chest_options = Array(snapshot.get("pending_treasure_chest_options", [])).duplicate(true)
	state.pending_treasure_chest_offer_id = String(snapshot.get("pending_treasure_chest_offer_id", state.pending_treasure_chest_offer_id))
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


func is_tutorial_run() -> bool:
	return tutorial_run_active


func finish_tutorial_guidance() -> void:
	if not tutorial_run_active:
		return
	var signal_before := _capture_run_signal_state()
	tutorial_run_active = false
	_run_log_append("tutorial_end", {
		"dungeon_level": dungeon_level,
		"step": current_step_key,
	})
	_emit_run_state_signals(signal_before, "finish_tutorial_guidance", "")


func tutorial_board_seed_for_turn(turn_index: int) -> int:
	if not tutorial_run_active:
		return -1
	var step_seed := (_step_index + 1) * 1000
	var level_seed := dungeon_level * 10000
	var turn_seed := maxi(1, turn_index) * 37
	return tutorial_seed + level_seed + step_seed + turn_seed


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
	return _ensure_balance_manager().apply_to_encounter(
		Dictionary(_boss_encounters_by_level.get(dungeon_level, {})),
		dungeon_level,
		MAX_DUNGEON_LEVELS
	)


func current_level_boss_name() -> String:
	return String(current_level_boss_preview().get("display_name", "Unknown Boss"))


func skip_to_fight(level: int, fight: int) -> Dictionary:
	if level < 1 or level > MAX_DUNGEON_LEVELS:
		return {"ok": false, "reason": "level_must_be_1_to_%d" % MAX_DUNGEON_LEVELS, "next_scene": SCENE_COMBAT}
	if fight < 1 or fight > 3:
		return {"ok": false, "reason": "fight_must_be_1_to_3", "next_scene": SCENE_COMBAT}

	var signal_before := _capture_run_signal_state()
	if not run_active:
		reset_run("skip_to_fight_reset", false)
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
	_emit_run_state_signals(signal_before, "skip_to_fight", "skip_to_fight")
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
	_advance_sequence("advance_after_boss_reward")
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
	_advance_sequence("mark_fight_victory")
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
	_advance_sequence("advance_after_shop")
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
	return _ensure_run_logger().run_log_snapshot()


func run_log_export_json(pretty: bool = true) -> String:
	return _ensure_run_logger().run_log_export_json(pretty)


func run_log_export_text() -> String:
	return _ensure_run_logger().run_log_export_text()


func run_log_export_html() -> String:
	return _ensure_run_logger().run_log_export_html()


func run_log_last_export_snapshot() -> Dictionary:
	return _ensure_run_logger().run_log_last_export_snapshot()


func run_log_last_export_paths() -> Dictionary:
	return _ensure_run_logger().run_log_last_export_paths()


func generate_run_log_files_enabled() -> bool:
	return _ensure_run_logger().generate_run_log_files_enabled()


func set_generate_run_log_files_enabled(enabled: bool) -> void:
	_ensure_run_logger().set_generate_run_log_files_enabled(enabled)
	_save_user_settings()


func load_user_settings() -> void:
	_ensure_run_logger().load_user_settings(USER_SETTINGS_PATH, USER_SETTINGS_SECTION, USER_SETTINGS_GENERATE_LOG_KEY)
	var config := ConfigFile.new()
	var error := config.load(USER_SETTINGS_PATH)
	if error == OK:
		_vfx_speed = _normalized_vfx_speed(String(config.get_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_VFX_SPEED_KEY, _vfx_speed)))
		_combat_vfx_quality = _normalized_combat_vfx_quality(String(config.get_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_COMBAT_VFX_QUALITY_KEY, _combat_vfx_quality)))
		_reduced_motion = bool(config.get_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_REDUCED_MOTION_KEY, _reduced_motion))


func vfx_speed() -> String:
	return _vfx_speed


func set_vfx_speed(speed: String) -> void:
	_vfx_speed = _normalized_vfx_speed(speed)
	_save_user_settings()


func combat_vfx_quality() -> String:
	return _combat_vfx_quality


func set_combat_vfx_quality(quality: String) -> void:
	_combat_vfx_quality = _normalized_combat_vfx_quality(quality)
	_save_user_settings()


func reduced_motion_enabled() -> bool:
	return _reduced_motion


func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion = enabled
	_save_user_settings()


func combat_feedback_settings() -> Dictionary:
	return {
		"vfx_speed": _vfx_speed,
		"combat_vfx_quality": _combat_vfx_quality,
		"reduced_motion": _reduced_motion,
	}


func _save_user_settings() -> void:
	var config := ConfigFile.new()
	config.load(USER_SETTINGS_PATH)
	config.set_value(USER_SETTINGS_SECTION, USER_SETTINGS_GENERATE_LOG_KEY, generate_run_log_files_enabled())
	config.set_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_VFX_SPEED_KEY, _vfx_speed)
	config.set_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_COMBAT_VFX_QUALITY_KEY, _combat_vfx_quality)
	config.set_value(USER_SETTINGS_GAMEPLAY_SECTION, USER_SETTINGS_REDUCED_MOTION_KEY, _reduced_motion)
	var error := config.save(USER_SETTINGS_PATH)
	if error != OK:
		push_warning("Failed to save user settings at %s: %d" % [USER_SETTINGS_PATH, error])


func _normalized_vfx_speed(speed: String) -> String:
	var normalized := speed.strip_edges().to_lower()
	match normalized:
		VFX_SPEED_SLOW, VFX_SPEED_NORMAL, VFX_SPEED_FAST, VFX_SPEED_INSTANT:
			return normalized
		_:
			return VFX_SPEED_NORMAL


func _normalized_combat_vfx_quality(quality: String) -> String:
	var normalized := quality.strip_edges().to_lower()
	match normalized:
		COMBAT_VFX_QUALITY_LOW, COMBAT_VFX_QUALITY_HIGH:
			return normalized
		_:
			return COMBAT_VFX_QUALITY_LOW


func _load_meta_profile() -> void:
	_load_profile()


func _load_profile() -> void:
	var profile: PlayerProfileState = ensure_player_profile_state()
	_ensure_profile_repository().load_profile(profile)
	meta_profile_state = profile.meta_profile


func _save_meta_profile() -> void:
	_save_profile()


func _save_profile() -> void:
	var profile: PlayerProfileState = ensure_player_profile_state()
	_ensure_profile_repository().save_profile(profile)
	meta_profile_state = profile.meta_profile


func log_turn_result(turn_log: Dictionary, context: Dictionary = {}) -> void:
	var payload := {
		"turn_index_for_fight": _ensure_run_logger().next_turn_index_for_fight(),
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
	_ensure_run_logger().advance_turn_counter()
	_run_log_append("turn_result", payload)


func _advance_sequence(reason: String = "advance_sequence") -> void:
	var signal_before := _capture_run_signal_state()
	_step_index += 1
	if _step_index >= LEVEL_SEQUENCE.size():
		_step_index = LEVEL_SEQUENCE.size() - 1
	current_step_key = LEVEL_SEQUENCE[_step_index]

	if current_step_key != "advance":
		if is_current_step_fight():
			_assign_current_fight()
		_emit_run_state_signals(signal_before, reason, "")
		return

	if dungeon_level >= MAX_DUNGEON_LEVELS:
		_emit_run_state_signals(signal_before, reason, "")
		_finalize_run(true, "Final boss defeated.")
		return

	dungeon_level += 1
	_step_index = 0
	current_step_key = LEVEL_SEQUENCE[_step_index]
	_assign_current_fight()
	_emit_run_state_signals(signal_before, reason, "")


func _assign_current_fight() -> void:
	if not is_current_step_fight():
		_current_encounter.clear()
		return

	var encounter: Dictionary = {}
	var uses_tutorial_encounter := false
	if tutorial_run_active:
		encounter = _tutorial_encounter_for_current_step()
		uses_tutorial_encounter = not encounter.is_empty()
	if encounter.is_empty():
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

	if not uses_tutorial_encounter:
		encounter = _ensure_balance_manager().apply_to_encounter(encounter, dungeon_level, MAX_DUNGEON_LEVELS)
	encounter["dungeon_level"] = dungeon_level
	encounter["step_key"] = current_step_key
	encounter["boss_preview_name"] = current_level_boss_name()
	_current_encounter = encounter
	_ensure_run_logger().reset_fight_turn_counter()
	_run_log_append(
		"fight_start",
		{
			"encounter": _current_encounter.duplicate(true),
		}
	)


func _tutorial_encounter_for_current_step() -> Dictionary:
	if dungeon_level != 1 or current_step_key != "enemy_1":
		return {}
	return {
		"enemy_id": "training_striker",
		"display_name": "Training Striker",
		"max_hp": 15,
		"is_boss": false,
		"intent_cycle": [
			{"type": 1, "attack": 0, "block": 8, "label": "Brace"},
			{"type": 2, "attack": 30, "block": 6, "label": "Punishing Bash"},
			{"type": 1, "attack": 0, "block": 10, "label": "Guard"},
			{"type": 0, "attack": 20, "block": 0, "label": "Heavy Slash"},
		],
	}


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
	var signal_before := _capture_run_signal_state()
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
	if _ensure_run_logger().should_export_run_log_files():
		_run_log_export_to_disk()
	_emit_run_state_signals(signal_before, "finalize_run", "")


func _run_log_reset() -> void:
	_ensure_run_logger().run_log_reset()


func _run_log_append(event_type: String, payload: Dictionary) -> void:
	_ensure_run_logger().run_log_append(event_type, payload)


func _run_log_export_to_disk() -> void:
	_ensure_run_logger().run_log_export_to_disk(RUN_LOG_EXPORT_DIR)


func _run_log_result_brief(result: Dictionary) -> Dictionary:
	return _ensure_run_logger().run_log_result_brief(result)


func _run_log_shop_action(
	action: String,
	result: Dictionary,
	request: Dictionary = {},
	shop_before_snapshot: Dictionary = {},
	gold_before: int = -1
) -> void:
	_ensure_run_logger().run_log_shop_action(action, result, request, shop_before_snapshot, gold_before)


func _run_log_sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	return _ensure_run_logger().run_log_sanitize_shop_snapshot(shop_snapshot, gold_value)


func _run_log_sanitize_shop_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	return _ensure_run_logger().run_log_sanitize_shop_offer(offer, gold_value)


func _run_log_sanitize_shop_relic_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	return _ensure_run_logger().run_log_sanitize_shop_relic_offer(offer, gold_value)


func _run_log_sanitize_treasure_chest_option(option: Dictionary, option_index: int = -1) -> Dictionary:
	return _ensure_run_logger().run_log_sanitize_treasure_chest_option(option, option_index)


func _run_log_next_shop_ordinal() -> int:
	return _ensure_run_logger().run_log_next_shop_ordinal()


func _run_log_capture_fight_outcome_payload(outcome: String, cause: String = "", extra: Dictionary = {}) -> Dictionary:
	return _ensure_run_logger().run_log_capture_fight_outcome_payload(outcome, cause, extra)


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
	return _ensure_scene_router().flow_trace_begin(route_name, target_scene, details)


func flow_trace_mark(step: String, details: Dictionary = {}, route_id: String = "", target_scene_override: String = "") -> void:
	_ensure_scene_router().flow_trace_mark(step, details, route_id, target_scene_override)


func flow_trace_change_scene(
	tree: SceneTree,
	target_scene: String,
	route_id: String = "",
	source: String = "",
	before_step: String = "",
	post_ready_failure_callback: Callable = Callable(),
	rollback_snapshot: Dictionary = {}
) -> int:
	return _ensure_scene_router().flow_trace_change_scene(
		tree,
		target_scene,
		route_id,
		source,
		before_step,
		post_ready_failure_callback,
		rollback_snapshot
	)


func flow_trace_prepare_scene(
	target_scene: String,
	route_id: String = "",
	source: String = ""
) -> Dictionary:
	return _ensure_scene_router().flow_trace_prepare_scene(target_scene, route_id, source)


func flow_trace_attach_prepared_scene(
	tree: SceneTree,
	prepared: Dictionary,
	target_scene: String,
	route_id: String = "",
	source: String = ""
) -> int:
	return _ensure_scene_router().flow_trace_attach_prepared_scene(tree, prepared, target_scene, route_id, source)


func flow_trace_active_route_id() -> String:
	return _ensure_scene_router().flow_trace_active_route_id()


func flow_trace_debug_snapshot() -> Dictionary:
	return _ensure_scene_router().flow_trace_debug_snapshot()


func _flow_trace_bump_transition_generation() -> void:
	_ensure_scene_router().flow_trace_bump_transition_generation()


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


func _capture_run_signal_state() -> Dictionary:
	return {
		"run_gold": run_gold,
		"dungeon_level": dungeon_level,
		"step_key": current_step_key,
		"step_index": _step_index,
		"run_active": run_active,
		"run_victory": run_victory,
		"summary_available": not _run_summary.is_empty(),
		"run_summary": _run_summary.duplicate(true),
	}


func _emit_run_state_signals(previous: Dictionary, reason: String, gold_source: String) -> void:
	var source := gold_source if gold_source != "" else reason
	_emit_gold_changed_if_needed(previous, source)
	_emit_run_step_changed_if_needed(previous, reason)
	_emit_run_summary_changed_if_needed(previous, reason)
	_emit_run_state_changed_if_needed(previous, reason)


func _emit_gold_changed_if_needed(previous: Dictionary, source: String) -> void:
	var previous_gold := int(previous.get("run_gold", run_gold))
	if previous_gold == run_gold:
		return
	gold_changed.emit(
		{
			"gold": run_gold,
			"previous_gold": previous_gold,
			"delta": run_gold - previous_gold,
			"source": source,
			"run_score": run_score,
			"total_gold_earned": total_gold_earned,
		}
	)


func _emit_run_step_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_level := int(previous.get("dungeon_level", dungeon_level))
	var previous_step_key := String(previous.get("step_key", current_step_key))
	var previous_step_index := int(previous.get("step_index", _step_index))
	if previous_level == dungeon_level and previous_step_key == current_step_key and previous_step_index == _step_index:
		return
	run_step_changed.emit(
		{
			"dungeon_level": dungeon_level,
			"previous_dungeon_level": previous_level,
			"step_key": current_step_key,
			"previous_step_key": previous_step_key,
			"step_index": _step_index,
			"run_active": run_active,
			"next_scene": next_scene_path(),
			"reason": reason,
		}
	)


func _emit_run_state_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_run_active := bool(previous.get("run_active", run_active))
	var previous_run_victory := bool(previous.get("run_victory", run_victory))
	var summary_available := not _run_summary.is_empty()
	var previous_summary_available := bool(previous.get("summary_available", summary_available))
	if (
		previous_run_active == run_active
		and previous_run_victory == run_victory
		and previous_summary_available == summary_available
	):
		return
	run_state_changed.emit(
		{
			"run_active": run_active,
			"previous_run_active": previous_run_active,
			"run_victory": run_victory,
			"previous_run_victory": previous_run_victory,
			"summary_available": summary_available,
			"reason": reason,
			"next_scene": next_scene_path(),
		}
	)


func _emit_run_summary_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_summary := Dictionary(previous.get("run_summary", {}))
	if previous_summary == _run_summary:
		return
	run_summary_changed.emit(
		{
			"summary": _run_summary.duplicate(true),
			"available": not _run_summary.is_empty(),
			"reason": reason,
		}
	)


func _emit_profile_changed(reason: String, score_delta: int = 0, unlock: Dictionary = {}) -> void:
	profile_changed.emit(
		{
			"reason": reason,
			"profile": profile_snapshot(),
			"meta_profile": meta_profile_snapshot(),
			"score_delta": score_delta,
			"unlock": unlock.duplicate(true),
		}
	)


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
