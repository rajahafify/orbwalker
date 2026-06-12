extends RefCounted
class_name RunTransitionStateStoreTest

const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const RUN_TRANSITION_STATE_STORE_SCRIPT := preload("res://scripts/core/run_transition_state_store.gd")


class FakeWalletService:
	func restore_from_snapshot(owner, snapshot: Dictionary) -> void:
		owner.run_gold = maxi(0, int(snapshot.get("run_gold", owner.run_gold)))


class FakeShopSession:
	func snapshot_for_transition(owner) -> Dictionary:
		return Dictionary(owner.shop_snapshot).duplicate(true)

	func restore_for_transition(owner, snapshot: Dictionary) -> void:
		owner.shop_snapshot = snapshot.duplicate(true)


class FakeOwner:
	const LEVEL_SEQUENCE: Array[String] = ["enemy_1", "shop", "boss"]

	var run_active := true
	var run_victory := false
	var tutorial_run_active := false
	var tutorial_seed := 271828
	var run_gold := 0
	var run_score := 10
	var dungeon_level := 1
	var current_step_key := "enemy_1"
	var enemies_defeated := 0
	var bosses_defeated := 0
	var total_gold_earned := 0
	var shop_snapshot := {"offers": [{"id": "spark"}]}

	var player_state = PLAYER_STATE_SCRIPT.new()
	var progression_state = PLAYER_PROGRESSION_STATE_SCRIPT.new()
	var wallet_service := FakeWalletService.new()
	var shop_session := FakeShopSession.new()

	func ensure_player_state():
		return player_state

	func ensure_player_progression_state():
		return progression_state

	func ensure_wallet_service():
		return wallet_service

	func ensure_shop_session():
		return shop_session


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("snapshot_restore_uses_injected_transition_hooks", _test_snapshot_restore_uses_injected_transition_hooks, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_snapshot_restore_uses_injected_transition_hooks() -> String:
	var owner := FakeOwner.new()
	owner.player_state.gold = 7
	owner.progression_state.relic_ids.append("starter_relic")
	var private_state := {
		"run_score_banked": true,
		"step_index": 1,
		"current_encounter": {"step_key": "shop"},
		"boss_relic_reward_options": [{"relic_id": "ember"}],
		"boss_reward_claimed_relic_id": "ember",
		"relic_offer_ids_by_level": {1: ["ember"]},
		"run_summary": {"victory": false},
		"run_logger_snapshot": {"run_log_events": [{"type": "shop_open"}]},
		"scene_router_snapshot": {"next_scene": "res://scenes/shop.tscn"},
		"signals": [],
		"gold_synced": false,
	}
	var store = RUN_TRANSITION_STATE_STORE_SCRIPT.new(owner, _hooks(private_state))

	var snapshot: Dictionary = store.snapshot()
	if not bool(snapshot.get("run_score_banked", false)):
		return "Expected snapshot to read run_score_banked through hooks."
	if int(snapshot.get("step_index", -1)) != 1:
		return "Expected snapshot to read step_index through hooks."
	if Dictionary(snapshot.get("current_encounter", {})).get("step_key", "") != "shop":
		return "Expected snapshot to include hooked encounter state."

	snapshot["current_step_key"] = "boss"
	snapshot["step_index"] = 2
	snapshot["run_score_banked"] = false
	snapshot["current_encounter"] = {"step_key": "boss"}
	snapshot["boss_reward_claimed_relic_id"] = "frost"
	snapshot["run_summary"] = {"victory": true}
	snapshot["run_gold"] = 22
	var restored: bool = store.restore(snapshot)
	if not restored:
		return "Expected restore to accept a non-empty snapshot."
	if int(private_state.get("step_index", -1)) != 2 or owner.current_step_key != "boss":
		return "Expected restore to update hooked step state."
	if bool(private_state.get("run_score_banked", true)):
		return "Expected restore to update hooked score-banked state."
	if String(private_state.get("boss_reward_claimed_relic_id", "")) != "frost":
		return "Expected restore to update hooked boss reward state."
	if not bool(Dictionary(private_state.get("run_summary", {})).get("victory", false)):
		return "Expected restore to update hooked run summary."
	if int(owner.run_gold) != 22:
		return "Expected restore to route wallet state through the public wallet service."
	if not bool(private_state.get("gold_synced", false)):
		return "Expected restore to call the injected gold sync hook."
	if Array(private_state.get("signals", [])).is_empty():
		return "Expected restore to call the injected signal hook."
	return ""


func _hooks(state: Dictionary) -> Dictionary:
	return {
		"run_score_banked": func() -> bool: return bool(state.get("run_score_banked", false)),
		"set_run_score_banked": func(value: bool) -> void: state["run_score_banked"] = value,
		"step_index": func() -> int: return int(state.get("step_index", 0)),
		"set_step_index": func(value: int) -> void: state["step_index"] = value,
		"current_encounter": func() -> Dictionary: return Dictionary(state.get("current_encounter", {})),
		"set_current_encounter": func(value: Dictionary) -> void: state["current_encounter"] = value,
		"boss_relic_reward_options": func() -> Array: return Array(state.get("boss_relic_reward_options", [])),
		"set_boss_relic_reward_options": func(value: Array) -> void: state["boss_relic_reward_options"] = value,
		"boss_reward_claimed_relic_id": func() -> String: return String(state.get("boss_reward_claimed_relic_id", "")),
		"set_boss_reward_claimed_relic_id": func(value: String) -> void: state["boss_reward_claimed_relic_id"] = value,
		"relic_offer_ids_by_level": func() -> Dictionary: return Dictionary(state.get("relic_offer_ids_by_level", {})),
		"set_relic_offer_ids_by_level": func(value: Dictionary) -> void: state["relic_offer_ids_by_level"] = value,
		"run_summary": func() -> Dictionary: return Dictionary(state.get("run_summary", {})),
		"set_run_summary": func(value: Dictionary) -> void: state["run_summary"] = value,
		"run_logger_transition_snapshot": func() -> Dictionary: return Dictionary(state.get("run_logger_snapshot", {})),
		"restore_run_logger_transition_snapshot": func(value: Dictionary) -> void: state["run_logger_snapshot"] = value,
		"scene_router_transition_snapshot": func() -> Dictionary: return Dictionary(state.get("scene_router_snapshot", {})),
		"restore_scene_router_transition_snapshot": func(value: Dictionary) -> void: state["scene_router_snapshot"] = value,
		"capture_run_signal_state": func() -> Dictionary: return {"before": true},
		"sync_player_gold_from_run": func() -> void: state["gold_synced"] = true,
		"emit_run_state_signals":
		func(before: Dictionary, reason: String, step_reason: String) -> void:
			Array(state["signals"]).append({"before": before, "reason": reason, "step_reason": step_reason}),
	}
