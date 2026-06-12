extends RefCounted
class_name RunOutcomeService

var _owner
var _hooks: Dictionary = {}


func _init(owner, hooks: Dictionary = {}) -> void:
	_owner = owner
	_hooks = hooks


func boss_relic_reward_options_snapshot() -> Array[Dictionary]:
	return _boss_relic_reward_options().duplicate(true)


func claim_boss_relic_reward(option_index: int) -> Dictionary:
	if not _owner.run_active:
		return {"ok": false, "reason": "run_not_active"}
	if not _owner.is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step"}
	if option_index < 0 or option_index >= _boss_relic_reward_options().size():
		return {"ok": false, "reason": "invalid_option_index"}

	var option: Dictionary = _boss_relic_reward_options()[option_index]
	var relic_id := String(option.get("relic_id", ""))
	var result: Dictionary = _owner.ensure_player_progression_service().add_relic(
		_owner.ensure_player_progression_state(), relic_id, _owner.ensure_content_registry()
	)
	var already_owned := String(result.get("reason", "")) == "relic_already_owned"
	if not bool(result.get("ok", false)) and not already_owned:
		return {"ok": false, "reason": String(result.get("reason", "relic_grant_failed"))}

	_call_hook("set_boss_reward_claimed_relic_id", [relic_id])
	_boss_relic_reward_options().clear()
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
		"result":
		{
			"relic_id": relic_id,
			"display_name": String(option.get("display_name", relic_id)),
			"already_owned": already_owned,
		},
	}


func skip_boss_relic_reward() -> Dictionary:
	if not _owner.run_active:
		return {"ok": false, "reason": "run_not_active"}
	if not _owner.is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step"}
	_call_hook("set_boss_reward_claimed_relic_id", [""])
	_boss_relic_reward_options().clear()
	_run_log_append("boss_reward_skip", {})
	return {"ok": true, "reason": ""}


func advance_after_boss_reward() -> Dictionary:
	if not _owner.run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": _owner.SCENE_MAIN}
	if not _owner.is_current_step_boss_reward():
		return {"ok": false, "reason": "not_boss_reward_step", "next_scene": _owner.SCENE_MAIN}
	_advance_sequence("advance_after_boss_reward")
	return _transition_result()


func mark_fight_victory() -> Dictionary:
	if not _owner.run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": _owner.SCENE_MAIN}
	if not _owner.is_current_step_fight():
		return {"ok": false, "reason": "not_fight_step", "next_scene": _owner.SCENE_MAIN}
	var base_gold_reward: int = _owner.add_gold(_owner.prototype_fight_gold_reward_for(_owner.dungeon_level, _owner.current_step_key), "fight_base_reward")
	(
		_run_log_core_event_recorder()
		. record_fight_end(
			"victory",
			_current_encounter(),
			"",
			{
				"base_gold_reward": base_gold_reward,
			}
		)
	)

	_owner.enemies_defeated += 1
	if bool(_current_encounter().get("is_boss", false)):
		_owner.bosses_defeated += 1
		if _owner.dungeon_level >= _owner.MAX_DUNGEON_LEVELS:
			finalize_run(true, "Final boss defeated.")
			return _transition_result({"base_gold_reward": base_gold_reward})
		prepare_boss_relic_reward_options()
	_advance_sequence("mark_fight_victory")
	return _transition_result({"base_gold_reward": base_gold_reward})


func mark_player_defeated(cause: String) -> Dictionary:
	if _owner.run_active and _owner.is_current_step_fight():
		_run_log_core_event_recorder().record_fight_end("defeat", _current_encounter(), cause)
	finalize_run(false, cause)
	return _transition_result()


func advance_after_shop(mark_skipped: bool) -> Dictionary:
	var shop_before_close: Dictionary = _owner.ensure_shop_state().to_snapshot()
	_owner.close_shop(mark_skipped)
	_run_log_append(
		"shop_leave",
		{
			"mark_skipped": mark_skipped,
			"shop_before": _run_log_shop_event_recorder().sanitize_shop_snapshot(shop_before_close, _owner.run_gold),
			"shop_after": _run_log_shop_event_recorder().sanitize_shop_snapshot(_owner.ensure_shop_state().to_snapshot(), _owner.run_gold),
		}
	)
	if not _owner.run_active:
		return {"ok": false, "reason": "run_not_active", "next_scene": _owner.SCENE_MAIN}
	if not _owner.is_current_step_shop():
		return {"ok": false, "reason": "not_shop_step", "next_scene": _owner.SCENE_MAIN}
	_advance_sequence("advance_after_shop")
	return _transition_result()


func run_summary_snapshot() -> Dictionary:
	if _run_summary().is_empty():
		var meta_snapshot: Dictionary = _owner.meta_profile_snapshot()
		return {
			"victory": false,
			"level_reached": _owner.dungeon_level,
			"levels_cleared": maxi(0, _owner.dungeon_level - 1),
			"enemies_defeated": _owner.enemies_defeated,
			"bosses_defeated": _owner.bosses_defeated,
			"gold_earned": _owner.total_gold_earned,
			"final_gold": _owner.run_gold,
			"run_score": _owner.run_score,
			"total_score": int(meta_snapshot.get("total_score", 0)),
			"cause": "Run not finished.",
			"equipment_slots": _owner.progression_snapshot().get("equipment_slots", []),
			"relic_ids": _owner.progression_snapshot().get("relic_ids", []),
		}
	return _run_summary().duplicate(true)


func prepare_boss_relic_reward_options() -> void:
	_boss_relic_reward_options().clear()
	_call_hook("set_boss_reward_claimed_relic_id", [""])

	var progression = _owner.ensure_player_progression_state()
	var candidates: Array[Dictionary] = []
	for relic_data in _owner.ensure_content_registry().list_relics():
		var relic_id := String(relic_data.get("id", ""))
		if relic_id == "" or progression.has_relic(relic_id):
			continue
		candidates.append(Dictionary(relic_data))
	if candidates.is_empty():
		for relic_data in _owner.ensure_content_registry().list_relics():
			candidates.append(Dictionary(relic_data))
	if candidates.is_empty():
		return

	var pick_count := mini(3, candidates.size())
	for _i in pick_count:
		var index: int = _reward_rng().randi_range(0, candidates.size() - 1)
		var chosen: Dictionary = candidates[index]
		(
			_boss_relic_reward_options()
			. append(
				{
					"relic_id": String(chosen.get("id", "")),
					"display_name": String(chosen.get("display_name", "Relic")),
					"rarity": String(chosen.get("rarity", "common")),
				}
			)
		)
		candidates.remove_at(index)


func finalize_run(victory: bool, cause: String) -> void:
	var signal_before: Dictionary = _call_hook("capture_run_signal_state", [])
	_owner.run_active = false
	_owner.run_victory = victory
	var level_reached: int = _owner.dungeon_level
	var levels_cleared: int = _owner.dungeon_level - 1
	var victory_unlocks: Array[Dictionary] = []
	if victory:
		levels_cleared = _owner.MAX_DUNGEON_LEVELS
		level_reached = _owner.MAX_DUNGEON_LEVELS
		victory_unlocks = _profile_unlock_service().grant_victory_equipment_unlocks()
	elif _owner.is_current_step_fight():
		levels_cleared = _owner.dungeon_level - 1

	var score_added := 0
	if not bool(_call_hook("run_score_banked", [])):
		score_added = _owner.add_total_score(_owner.run_score)
		_call_hook("set_run_score_banked", [true])
	var meta_snapshot: Dictionary = _owner.meta_profile_snapshot()
	var progression: Dictionary = _owner.progression_snapshot()
	var summary := {
		"victory": victory,
		"level_reached": level_reached,
		"levels_cleared": maxi(0, levels_cleared),
		"enemies_defeated": _owner.enemies_defeated,
		"bosses_defeated": _owner.bosses_defeated,
		"gold_earned": _owner.total_gold_earned,
		"final_gold": _owner.run_gold,
		"run_score": _owner.run_score,
		"score_added_to_total": score_added,
		"total_score": int(meta_snapshot.get("total_score", 0)),
		"victory_equipment_unlocks": victory_unlocks,
		"cause": cause,
		"equipment_slots": progression.get("equipment_slots", []),
		"relic_ids": progression.get("relic_ids", []),
	}
	_call_hook("set_run_summary", [summary])
	_run_log_core_event_recorder().record_run_end(victory, cause, _run_summary())
	if bool(_call_hook("should_export_run_log_files", [])):
		_call_hook("run_log_export_to_disk", [])
	_call_hook("emit_run_state_signals", [signal_before, "finalize_run", ""])


func _boss_relic_reward_options() -> Array:
	return Array(_call_hook("boss_relic_reward_options", []))


func _current_encounter() -> Dictionary:
	return Dictionary(_call_hook("current_encounter", []))


func _run_summary() -> Dictionary:
	return Dictionary(_call_hook("run_summary", []))


func _reward_rng() -> RandomNumberGenerator:
	return _call_hook("reward_rng", []) as RandomNumberGenerator


func _run_log_core_event_recorder() -> Variant:
	return _call_hook("run_log_core_event_recorder", [])


func _run_log_shop_event_recorder() -> Variant:
	return _call_hook("run_log_shop_event_recorder", [])


func _profile_unlock_service() -> Variant:
	return _call_hook("profile_unlock_service", [])


func _run_log_append(event_type: String, payload: Dictionary) -> void:
	_call_hook("run_log_append", [event_type, payload])


func _advance_sequence(reason: String) -> void:
	_call_hook("advance_sequence", [reason])


func _transition_result(extra: Dictionary = {}) -> Dictionary:
	return Dictionary(_call_hook("transition_result", [extra]))


func _call_hook(key: String, args: Array) -> Variant:
	var hook: Callable = _hooks.get(key, Callable())
	if not hook.is_valid():
		push_error("RunOutcomeService missing required hook: %s" % key)
		return null
	return hook.callv(args)
