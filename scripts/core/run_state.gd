extends Node

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const SHOP_STATE_SCRIPT := preload("res://scripts/shop/shop_state.gd")
const SHOP_SERVICE_SCRIPT := preload("res://scripts/shop/shop_service.gd")
const SCENE_MAIN := "res://scenes/main.tscn"
const SCENE_COMBAT := "res://scenes/combat/combat_player.tscn"
const SCENE_SHOP := "res://scenes/flow/shop_player.tscn"
const SCENE_RUN_SUMMARY := "res://scenes/flow/final_run_summary.tscn"
const MAX_DUNGEON_LEVELS := 3
const FLOW_TRACE_ENABLED := true
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
var run_gold: int = 0
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

var _normal_encounters_by_level := {
	1: [
		{
			"enemy_id": "cavern_striker",
			"display_name": "Cavern Striker",
			"max_hp": 76,
			"is_boss": false,
			"intent_cycle": [
				{"type": 0, "attack": 12, "block": 0, "label": "Slash 12"},
				{"type": 2, "attack": 8, "block": 4, "label": "Shield Bash 8 + Guard 4"},
				{"type": 0, "attack": 13, "block": 0, "label": "Heavy Slash 13"},
			],
		},
		{
			"enemy_id": "cavern_defender",
			"display_name": "Cavern Defender",
			"max_hp": 82,
			"is_boss": false,
			"intent_cycle": [
				{"type": 1, "attack": 0, "block": 10, "label": "Fortify 10"},
				{"type": 2, "attack": 10, "block": 6, "label": "Counter 10 + Guard 6"},
				{"type": 0, "attack": 11, "block": 0, "label": "Crush 11"},
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
				{"type": 2, "attack": 11, "block": 6, "label": "Flare Cut 11 + Guard 6"},
				{"type": 0, "attack": 15, "block": 0, "label": "Torch Combo 15"},
				{"type": 1, "attack": 0, "block": 12, "label": "Ash Guard 12"},
			],
		},
		{
			"enemy_id": "ruin_lancer",
			"display_name": "Ruin Lancer",
			"max_hp": 98,
			"is_boss": false,
			"intent_cycle": [
				{"type": 0, "attack": 16, "block": 0, "label": "Pierce 16"},
				{"type": 2, "attack": 10, "block": 8, "label": "Brace 8 + Jab 10"},
				{"type": 0, "attack": 14, "block": 0, "label": "Thrust 14"},
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
			{"type": 1, "attack": 0, "block": 16, "label": "Fortress Stance 16"},
			{"type": 0, "attack": 20, "block": 0, "label": "Gate Slam 20"},
			{"type": 2, "attack": 14, "block": 10, "label": "Wall Bash 14 + Guard 10"},
		],
	},
	2: {
		"enemy_id": "burning_knight",
		"display_name": "Burning Knight",
		"max_hp": 158,
		"is_boss": true,
		"intent_cycle": [
			{"type": 0, "attack": 21, "block": 0, "label": "Inferno Cleave 21"},
			{"type": 2, "attack": 15, "block": 10, "label": "Blazing Guard 10 + Slash 15"},
			{"type": 0, "attack": 19, "block": 0, "label": "Scorching Lunge 19"},
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
	return content_registry


func ensure_shop_state():
	if shop_state == null:
		shop_state = SHOP_STATE_SCRIPT.new()
	return shop_state


func ensure_shop_service():
	if shop_service == null:
		shop_service = SHOP_SERVICE_SCRIPT.new()
	return shop_service


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


func progression_snapshot() -> Dictionary:
	return ensure_player_progression_state().to_snapshot()


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


func add_gold(amount: int) -> int:
	if amount <= 0:
		return 0
	run_gold += amount
	total_gold_earned += amount
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
	return ensure_shop_service().open_shop(self, dungeon_level)


func reroll_shop_items() -> Dictionary:
	return ensure_shop_service().reroll_shop_items(self)


func buy_shop_offer(offer_id: String) -> Dictionary:
	return ensure_shop_service().buy_offer(self, offer_id)


func sell_equipped_item(slot_index: int) -> Dictionary:
	return ensure_shop_service().sell_equipped_item(self, slot_index)


func sell_consumable_item(slot_index: int) -> Dictionary:
	return ensure_shop_service().sell_consumable_item(self, slot_index)


func choose_booster_option(option_index: int) -> Dictionary:
	return ensure_shop_service().choose_booster_option(self, option_index)


func replace_pending_booster_option(option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	return ensure_shop_service().replace_pending_booster_option(self, option_index, slot_index, sell_replaced)


func discard_pending_booster_options() -> Dictionary:
	return ensure_shop_service().discard_pending_booster_options(self)


func close_shop(mark_skipped: bool = false) -> void:
	ensure_shop_state().close_shop(mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return String(_relic_offer_ids_by_level.get(maxi(1, level), ""))


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_relic_offer_ids_by_level[maxi(1, level)] = relic_id


func reset_run() -> void:
	ensure_player_state().reset_for_new_run()
	run_gold = ensure_player_state().gold
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
	validate_player_state_content()


func start_new_run() -> void:
	reset_run()
	run_active = true
	_assign_current_fight()


func is_current_step_fight() -> bool:
	return current_step_key == "enemy_1" or current_step_key == "enemy_2" or current_step_key == "boss"


func is_current_step_shop() -> bool:
	return current_step_key == "shop"


func is_current_step_boss_reward() -> bool:
	return current_step_key == "boss_relic_reward"


func level_sequence_label() -> String:
	var step_label := _step_display_name(current_step_key)
	return "Level %d/%d | %s" % [dungeon_level, MAX_DUNGEON_LEVELS, step_label]


func current_level_boss_preview() -> Dictionary:
	return Dictionary(_boss_encounters_by_level.get(dungeon_level, {})).duplicate(true)


func current_level_boss_name() -> String:
	return String(current_level_boss_preview().get("display_name", "Unknown Boss"))


func skip_to_fight(level: int, fight: int) -> Dictionary:
	if level < 1 or level > MAX_DUNGEON_LEVELS:
		return {"ok": false, "reason": "level_must_be_1_to_%d" % MAX_DUNGEON_LEVELS, "next_scene": SCENE_COMBAT}
	if fight < 1 or fight > 3:
		return {"ok": false, "reason": "fight_must_be_1_to_3", "next_scene": SCENE_COMBAT}

	if not run_active:
		start_new_run()
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

	enemies_defeated += 1
	if bool(_current_encounter.get("is_boss", false)):
		bosses_defeated += 1
		if dungeon_level >= MAX_DUNGEON_LEVELS:
			_finalize_run(true, "Final boss defeated.")
			return _transition_result()
		_prepare_boss_relic_reward_options()
	_advance_sequence()
	return _transition_result()


func mark_player_defeated(cause: String) -> Dictionary:
	_finalize_run(false, cause)
	return _transition_result()


func advance_after_shop(mark_skipped: bool) -> Dictionary:
	close_shop(mark_skipped)
	if not run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": SCENE_MAIN}
	if not is_current_step_shop():
		return {"ok": false, "reason": "not_shop_step", "next_scene": SCENE_MAIN}
	_advance_sequence()
	return _transition_result()


func run_summary_snapshot() -> Dictionary:
	if _run_summary.is_empty():
		return {
			"victory": false,
			"level_reached": dungeon_level,
			"levels_cleared": maxi(0, dungeon_level - 1),
			"enemies_defeated": enemies_defeated,
			"bosses_defeated": bosses_defeated,
			"gold_earned": total_gold_earned,
			"final_gold": run_gold,
			"cause": "Run not finished.",
			"equipment_slots": progression_snapshot().get("equipment_slots", []),
			"relic_ids": progression_snapshot().get("relic_ids", []),
		}
	return _run_summary.duplicate(true)


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

	encounter["dungeon_level"] = dungeon_level
	encounter["step_key"] = current_step_key
	encounter["boss_preview_name"] = current_level_boss_name()
	_current_encounter = encounter


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
	if victory:
		levels_cleared = MAX_DUNGEON_LEVELS
		level_reached = MAX_DUNGEON_LEVELS
	elif is_current_step_fight():
		levels_cleared = dungeon_level - 1

	var progression := progression_snapshot()
	_run_summary = {
		"victory": victory,
		"level_reached": level_reached,
		"levels_cleared": maxi(0, levels_cleared),
		"enemies_defeated": enemies_defeated,
		"bosses_defeated": bosses_defeated,
		"gold_earned": total_gold_earned,
		"final_gold": run_gold,
		"cause": cause,
		"equipment_slots": progression.get("equipment_slots", []),
		"relic_ids": progression.get("relic_ids", []),
	}


func _transition_result() -> Dictionary:
	return {
		"ok": true,
		"reason": "",
		"next_scene": next_scene_path(),
		"step": current_step_key,
		"dungeon_level": dungeon_level,
	}


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
		return ERR_CANT_OPEN

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
		return ERR_CANT_OPEN
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
		return ERR_INVALID_DATA

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
		return ERR_CANT_CREATE
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
		return ERR_CANT_CREATE

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
