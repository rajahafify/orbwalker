extends RefCounted
class_name RunTransitionStateStore

const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")

var _owner
var _hooks: Dictionary = {}


func _init(owner, hooks: Dictionary = {}) -> void:
	_owner = owner
	_hooks = hooks


func snapshot() -> Dictionary:
	var snapshot_value := {
		"player_state": _snapshot_player_state(),
		"player_progression_state": _snapshot_player_progression_state(),
		"shop_state": _snapshot_shop_state(),
		"run_active": _owner.run_active,
		"run_victory": _owner.run_victory,
		"tutorial_run_active": _owner.tutorial_run_active,
		"tutorial_seed": _owner.tutorial_seed,
		"run_gold": _owner.run_gold,
		"run_score": _owner.run_score,
		"run_score_banked": _call_hook("run_score_banked", []),
		"dungeon_level": _owner.dungeon_level,
		"current_step_key": _owner.current_step_key,
		"step_index": _call_hook("step_index", []),
		"enemies_defeated": _owner.enemies_defeated,
		"bosses_defeated": _owner.bosses_defeated,
		"total_gold_earned": _owner.total_gold_earned,
		"current_encounter": Dictionary(_call_hook("current_encounter", [])).duplicate(true),
		"boss_relic_reward_options": Array(_call_hook("boss_relic_reward_options", [])).duplicate(true),
		"boss_reward_claimed_relic_id": String(_call_hook("boss_reward_claimed_relic_id", [])),
		"relic_offer_ids_by_level": Dictionary(_call_hook("relic_offer_ids_by_level", [])).duplicate(true),
		"run_summary": Dictionary(_call_hook("run_summary", [])).duplicate(true),
	}
	snapshot_value.merge(Dictionary(_call_hook("run_logger_transition_snapshot", [])), true)
	snapshot_value.merge(Dictionary(_call_hook("scene_router_transition_snapshot", [])), true)
	return snapshot_value


func restore(snapshot_value: Dictionary) -> bool:
	if snapshot_value.is_empty():
		return false
	var signal_before: Dictionary = _call_hook("capture_run_signal_state", [])
	_owner.run_active = bool(snapshot_value.get("run_active", _owner.run_active))
	_owner.run_victory = bool(snapshot_value.get("run_victory", _owner.run_victory))
	_owner.tutorial_run_active = bool(snapshot_value.get("tutorial_run_active", _owner.tutorial_run_active))
	_owner.tutorial_seed = maxi(1, int(snapshot_value.get("tutorial_seed", _owner.tutorial_seed)))
	_call_hook("set_run_score_banked", [bool(snapshot_value.get("run_score_banked", _call_hook("run_score_banked", [])))])
	_owner.ensure_wallet_service().restore_from_snapshot(_owner, snapshot_value)
	_owner.dungeon_level = maxi(1, int(snapshot_value.get("dungeon_level", _owner.dungeon_level)))
	_restore_step(snapshot_value)
	_owner.enemies_defeated = maxi(0, int(snapshot_value.get("enemies_defeated", _owner.enemies_defeated)))
	_owner.bosses_defeated = maxi(0, int(snapshot_value.get("bosses_defeated", _owner.bosses_defeated)))
	_call_hook("set_current_encounter", [Dictionary(snapshot_value.get("current_encounter", {})).duplicate(true)])
	_call_hook("set_boss_relic_reward_options", [Array(snapshot_value.get("boss_relic_reward_options", [])).duplicate(true)])
	_call_hook("set_boss_reward_claimed_relic_id", [String(snapshot_value.get("boss_reward_claimed_relic_id", ""))])
	_call_hook("set_relic_offer_ids_by_level", [Dictionary(snapshot_value.get("relic_offer_ids_by_level", {})).duplicate(true)])
	_call_hook("set_run_summary", [Dictionary(snapshot_value.get("run_summary", {})).duplicate(true)])
	_call_hook("restore_run_logger_transition_snapshot", [snapshot_value])
	_call_hook("restore_scene_router_transition_snapshot", [snapshot_value])
	_restore_player_state(Dictionary(snapshot_value.get("player_state", {})))
	_restore_player_progression_state(Dictionary(snapshot_value.get("player_progression_state", {})))
	_restore_shop_state(Dictionary(snapshot_value.get("shop_state", {})))
	_call_hook("sync_player_gold_from_run", [])
	_call_hook("emit_run_state_signals", [signal_before, "restore_run_transition_state", "restore_run_transition_state"])
	return true


func _restore_step(snapshot_value: Dictionary) -> void:
	_owner.current_step_key = String(snapshot_value.get("current_step_key", _owner.current_step_key))
	var saved_step_index := int(snapshot_value.get("step_index", -1))
	var saved_step_index_valid: bool = saved_step_index >= 0 and saved_step_index < _owner.LEVEL_SEQUENCE.size()
	if saved_step_index_valid and String(_owner.LEVEL_SEQUENCE[saved_step_index]) == _owner.current_step_key:
		_call_hook("set_step_index", [saved_step_index])
	elif _owner.LEVEL_SEQUENCE.has(_owner.current_step_key):
		_call_hook("set_step_index", [_owner.LEVEL_SEQUENCE.find(_owner.current_step_key)])
	elif saved_step_index_valid:
		_call_hook("set_step_index", [saved_step_index])
		_owner.current_step_key = String(_owner.LEVEL_SEQUENCE[int(_call_hook("step_index", []))])
	else:
		_call_hook("set_step_index", [0])
		_owner.current_step_key = String(_owner.LEVEL_SEQUENCE[int(_call_hook("step_index", []))])


func _snapshot_player_state() -> Dictionary:
	var state = _owner.ensure_player_state()
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


func _restore_player_state(snapshot_value: Dictionary) -> void:
	if snapshot_value.is_empty():
		return
	var state = _owner.ensure_player_state()
	state.max_hp = maxi(1, int(snapshot_value.get("max_hp", state.max_hp)))
	state.current_hp = clampi(int(snapshot_value.get("current_hp", state.current_hp)), 0, state.max_hp)
	state.armor = maxi(0, int(snapshot_value.get("armor", state.armor)))
	state.gold = maxi(0, int(snapshot_value.get("gold", state.gold)))
	state.equipment_slots = maxi(0, int(snapshot_value.get("equipment_slots", state.equipment_slots)))
	state.consumable_slots = maxi(0, int(snapshot_value.get("consumable_slots", state.consumable_slots)))
	state.move_timer_seconds = maxf(0.0, float(snapshot_value.get("move_timer_seconds", state.move_timer_seconds)))
	state.increase_combo_modifier = int(snapshot_value.get("increase_combo_modifier", state.increase_combo_modifier))
	state.more_combo_modifier = maxf(0.0, float(snapshot_value.get("more_combo_modifier", state.more_combo_modifier)))


func _snapshot_player_progression_state() -> Dictionary:
	var progression = _owner.ensure_player_progression_state()
	return {
		"equipped_item_ids": progression.equipped_item_ids.duplicate(),
		"held_consumable_ids": progression.held_consumable_ids.duplicate(),
		"relic_ids": progression.relic_ids.duplicate(),
		"mastery_levels": progression.mastery_levels.duplicate(true),
		"active_effects_by_hook": progression.active_effects_by_hook.duplicate(true),
	}


func _restore_player_progression_state(snapshot_value: Dictionary) -> void:
	if snapshot_value.is_empty():
		return
	var progression = _owner.ensure_player_progression_state()
	progression.equipped_item_ids = _string_array_from_snapshot(
		snapshot_value.get("equipped_item_ids", []), PLAYER_PROGRESSION_STATE_SCRIPT.EQUIPMENT_SLOT_COUNT
	)
	progression.held_consumable_ids = _string_array_from_snapshot(
		snapshot_value.get("held_consumable_ids", []), PLAYER_PROGRESSION_STATE_SCRIPT.CONSUMABLE_SLOT_COUNT
	)
	progression.relic_ids = _string_array_from_snapshot(snapshot_value.get("relic_ids", []), -1)
	progression.mastery_levels = Dictionary(snapshot_value.get("mastery_levels", {})).duplicate(true)
	progression.active_effects_by_hook = Dictionary(snapshot_value.get("active_effects_by_hook", {})).duplicate(true)


func _snapshot_shop_state() -> Dictionary:
	return _owner.ensure_shop_session().snapshot_for_transition(_owner)


func _restore_shop_state(snapshot_value: Dictionary) -> void:
	_owner.ensure_shop_session().restore_for_transition(_owner, snapshot_value)


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


func _call_hook(key: String, args: Array) -> Variant:
	var hook: Callable = _hooks.get(key, Callable())
	if not hook.is_valid():
		push_error("RunTransitionStateStore missing required hook: %s" % key)
		return null
	return hook.callv(args)
