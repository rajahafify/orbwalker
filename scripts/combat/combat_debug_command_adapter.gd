# gdlint: disable=max-public-methods

extends RefCounted
class_name CombatDebugCommandAdapter

const CALLBACK_KEYS := preload("res://scripts/combat/combat_debug_callback_keys.gd")
const CONTROLLER_CALLBACK_METHODS := CALLBACK_KEYS.CONTROLLER_ACTION_METHODS

var _callbacks: Dictionary = {}
var _locked_input_phase_value := 2
var _default_victory_scene := "res://scenes/main_menu.tscn"


static func controller_callbacks(controller: Object) -> Dictionary:
	var callbacks := {}
	for key in CONTROLLER_CALLBACK_METHODS.keys():
		callbacks[key] = Callable(controller, String(CONTROLLER_CALLBACK_METHODS[key]))
	return callbacks


func bind(config: Dictionary) -> void:
	_callbacks = config.get("callbacks", {})
	_locked_input_phase_value = int(config.get("locked_input_phase_value", _locked_input_phase_value))
	_default_victory_scene = String(config.get("default_victory_scene", _default_victory_scene))


func command_callbacks() -> Dictionary:
	return {
		CALLBACK_KEYS.SET_STATUS_TEXT: Callable(self, "set_status_text"),
		CALLBACK_KEYS.STATE_SNAPSHOT_DATA: Callable(self, "state_snapshot_data"),
		CALLBACK_KEYS.SKIP_TO_FIGHT: Callable(self, "skip_to_fight"),
		CALLBACK_KEYS.BOARD_PRINT_DATA: Callable(self, "board_print_data"),
		CALLBACK_KEYS.BOARD_REROLL: Callable(self, "board_reroll"),
		CALLBACK_KEYS.BOARD_SEED: Callable(self, "board_seed"),
		CALLBACK_KEYS.GOLD_ADD: Callable(self, "gold_add"),
		CALLBACK_KEYS.GOLD_SET: Callable(self, "gold_set"),
		CALLBACK_KEYS.MASTERY_ADD: Callable(self, "mastery_add"),
		CALLBACK_KEYS.MASTERY_LIST: Callable(self, "mastery_list"),
		CALLBACK_KEYS.CONSUMABLE_ADD: Callable(self, "consumable_add"),
		CALLBACK_KEYS.CONSUMABLE_LIST: Callable(self, "consumable_list"),
		CALLBACK_KEYS.EQUIPMENT_LIST: Callable(self, "equipment_list"),
		CALLBACK_KEYS.EQUIPMENT_DETAILS: Callable(self, "equipment_details"),
		CALLBACK_KEYS.EQUIPMENT_ADD: Callable(self, "equipment_add"),
		CALLBACK_KEYS.RELIC_LIST: Callable(self, "relic_list"),
		CALLBACK_KEYS.RELIC_DETAILS: Callable(self, "relic_details"),
		CALLBACK_KEYS.RELIC_ADD: Callable(self, "relic_add"),
		CALLBACK_KEYS.FIGHT_WIN: Callable(self, "fight_win"),
		CALLBACK_KEYS.FIGHT_LOSE: Callable(self, "fight_lose"),
	}


func set_status_text(message: String) -> void:
	_call(CALLBACK_KEYS.SET_STATUS_TEXT, [message])


func state_snapshot_data() -> Dictionary:
	var progression: Dictionary = RunState.progression_snapshot()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	var enemy_state: Variant = _call(CALLBACK_KEYS.ENEMY_STATE)
	var combat: Variant = _call(CALLBACK_KEYS.COMBAT_STATE)
	var intent_text := "-"
	if enemy_state != null and _has_method(enemy_state, "get_current_intent"):
		var formatter: Callable = _callback(CALLBACK_KEYS.FORMAT_INTENT)
		if formatter.is_valid():
			intent_text = String(formatter.call(enemy_state.get_current_intent()))
	return {
		"run":
		{
			"active": RunState.run_active,
			"level": int(RunState.dungeon_level),
			"step": String(RunState.current_step_key),
			"label": RunState.level_sequence_label(),
		},
		"combat":
		{
			"turn": int(combat.turn_index if combat != null else 0),
			"phase": combat.phase_name() if combat != null and _has_method(combat, "phase_name") else "N/A",
			"input_phase": int(_call(CALLBACK_KEYS.INPUT_PHASE_VALUE)),
		},
		"player":
		{
			"hp": int(_call(CALLBACK_KEYS.PLAYER_HP)),
			"max_hp": int(_call(CALLBACK_KEYS.PLAYER_MAX_HP)),
			"armor": int(_call(CALLBACK_KEYS.PLAYER_ARMOR)),
			"gold": int(RunState.run_gold),
		},
		"enemy":
		{
			"display_name": String(encounter.get("display_name", _call(CALLBACK_KEYS.ENEMY_DISPLAY_NAME))),
			"hp": int(_call(CALLBACK_KEYS.ENEMY_HP)),
			"max_hp": int(_call(CALLBACK_KEYS.ENEMY_MAX_HP)),
			"turn_block": int(_call(CALLBACK_KEYS.ENEMY_TURN_BLOCK)),
			"intent": intent_text,
		},
		"progression":
		{
			"equipment_slots": progression.get("equipment_slots", []),
			"consumable_slots": progression.get("consumable_slots", []),
			"relic_ids": progression.get("relic_ids", []),
			"mastery_levels": progression.get("mastery_levels", {}),
		},
	}


func skip_to_fight(level: int, fight: int) -> Dictionary:
	var result: Dictionary = RunState.skip_to_fight(level, fight)
	if not bool(result.get("ok", false)):
		return result
	_call(CALLBACK_KEYS.ON_SKIP_SUCCESS)
	var label := RunState.level_sequence_label()
	set_status_text("Skipped to %s." % label)
	return {
		"ok": true,
		"label": label,
	}


func board_print_data() -> Dictionary:
	return {
		"seed": int(_call(CALLBACK_KEYS.BOARD_SEED)),
		"debug_text": String(_call(CALLBACK_KEYS.BOARD_DEBUG_TEXT)),
	}


func board_reroll() -> Dictionary:
	_call(CALLBACK_KEYS.CREATE_NEW_BOARD)
	return {"seed": int(_call(CALLBACK_KEYS.BOARD_SEED))}


func board_seed(seed_value: int) -> Dictionary:
	_call(CALLBACK_KEYS.SET_BOARD_SEED, [seed_value])
	return {
		"ok": true,
		"seed": int(_call(CALLBACK_KEYS.BOARD_SEED)),
	}


func gold_add(amount: int) -> Dictionary:
	var added := RunState.add_gold(amount)
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {
		"ok": true,
		"added": added,
		"current": RunState.run_gold,
	}


func gold_set(amount: int) -> Dictionary:
	RunState.set_gold(amount)
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {
		"ok": true,
		"current": RunState.run_gold,
	}


func mastery_add(orb_id: int, mastery_amount: int) -> Dictionary:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var mastery_result: Dictionary = progression_service.grant_mastery(progression_state, orb_id, mastery_amount)
	if not bool(mastery_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(mastery_result.get("reason", "unknown_error")),
		}
	var mastery_payload: Dictionary = mastery_result.get("result", {})
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {
		"ok": true,
		"granted": int(mastery_payload.get("granted", 0)),
		"new_level": int(mastery_payload.get("new_level", 0)),
	}


func mastery_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_mastery_cards()


func consumable_add(consumable_id: String) -> Dictionary:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var consumable_result: Dictionary = progression_service.add_consumable(progression_state, consumable_id, content)
	if not bool(consumable_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(consumable_result.get("reason", "unknown_error")),
		}
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {"ok": true}


func consumable_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_consumables()


func equipment_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_equipment()


func equipment_details(equipment_id: String) -> Dictionary:
	if equipment_id == "":
		return {"ok": false, "reason": "equipment id is required"}
	var content: Variant = RunState.ensure_content_registry()
	var equipment: Dictionary = content.get_equipment(equipment_id)
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown equipment id '%s'" % equipment_id}
	return {
		"ok": true,
		"equipment": equipment,
	}


func equipment_add(equipment_id: String) -> Dictionary:
	if equipment_id == "":
		return {"ok": false, "reason": "equipment id is required"}
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var equip_result: Dictionary = progression_service.equip_item(progression_state, equipment_id, content)
	if not bool(equip_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(equip_result.get("reason", "unknown_error")),
		}
	var payload: Dictionary = equip_result.get("result", {})
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {
		"ok": true,
		"slot_index": int(payload.get("slot_index", -1)),
	}


func relic_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_relics()


func relic_details(relic_id: String) -> Dictionary:
	if relic_id == "":
		return {"ok": false, "reason": "relic id is required"}
	var content: Variant = RunState.ensure_content_registry()
	var relic: Dictionary = content.get_relic(relic_id)
	if relic.is_empty():
		return {"ok": false, "reason": "unknown relic id '%s'" % relic_id}
	return {
		"ok": true,
		"relic": relic,
	}


func relic_add(relic_id: String) -> Dictionary:
	if relic_id == "":
		return {"ok": false, "reason": "relic id is required"}
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var relic_result: Dictionary = progression_service.add_relic(progression_state, relic_id, content)
	if not bool(relic_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(relic_result.get("reason", "unknown_error")),
		}
	_call(CALLBACK_KEYS.UPDATE_HUD)
	return {"ok": true}


func fight_win() -> Dictionary:
	var win_transition: Dictionary = RunState.mark_fight_victory()
	if not bool(win_transition.get("ok", false)):
		return {
			"ok": false,
			"reason": String(win_transition.get("reason", "unknown_error")),
		}
	_call(CALLBACK_KEYS.SET_INPUT_PHASE, [_locked_input_phase_value])
	_call(CALLBACK_KEYS.SET_PENDING_NEXT_SCENE_PATH, [String(win_transition.get("next_scene", _default_victory_scene))])
	_call(CALLBACK_KEYS.UPDATE_HUD)
	_call(CALLBACK_KEYS.SHOW_OUTCOME_SUMMARY, ["Victory", String(_call(CALLBACK_KEYS.BUILD_RUN_OUTCOME_SUMMARY, ["Debug command."])), true, "Continue"])
	set_status_text("Debug victory queued. Press Continue.")
	return {"ok": true}


func fight_lose() -> Dictionary:
	var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
	_call(CALLBACK_KEYS.SET_INPUT_PHASE, [_locked_input_phase_value])
	_call(CALLBACK_KEYS.SET_PENDING_NEXT_SCENE_PATH, [String(lose_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY))])
	_call(CALLBACK_KEYS.UPDATE_HUD)
	_call(CALLBACK_KEYS.SHOW_OUTCOME_SUMMARY, ["Defeat", String(_call(CALLBACK_KEYS.BUILD_RUN_OUTCOME_SUMMARY, ["Debug command."])), true, "Run Summary"])
	set_status_text("Debug defeat queued. Run Summary available.")
	return {"ok": true}


func _callback(name: String) -> Callable:
	if not _callbacks.has(name):
		return Callable()
	var raw_callback: Variant = _callbacks[name]
	if raw_callback is Callable:
		return raw_callback as Callable
	return Callable()


func _call(name: String, args: Array = []) -> Variant:
	var callback := _callback(name)
	if callback.is_valid():
		return callback.callv(args)
	return null


func _has_method(candidate: Variant, method_name: String) -> bool:
	return candidate != null and candidate.has_method(method_name)
