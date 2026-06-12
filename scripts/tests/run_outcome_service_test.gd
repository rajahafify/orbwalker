extends RefCounted
class_name RunOutcomeServiceTest

const RUN_OUTCOME_SERVICE_SCRIPT := preload("res://scripts/core/run_outcome_service.gd")


class FakeRunLogCoreEventRecorder:
	var run_end_events: Array[Dictionary] = []

	func record_run_end(victory: bool, cause: String, summary: Dictionary) -> void:
		run_end_events.append({"victory": victory, "cause": cause, "summary": summary.duplicate(true)})


class FakeProfileUnlockService:
	func grant_victory_equipment_unlocks() -> Array[Dictionary]:
		return [{"item_id": "ember_blade"}]


class FakeOwner:
	const MAX_DUNGEON_LEVELS := 3
	const SCENE_MAIN := "res://scenes/main_menu.tscn"

	var run_active := true
	var run_victory := false
	var dungeon_level := 2
	var current_step_key := "boss"
	var enemies_defeated := 4
	var bosses_defeated := 1
	var total_gold_earned := 55
	var run_gold := 12
	var run_score := 40
	var total_score := 100
	var score_added := 0

	func add_total_score(amount: int) -> int:
		score_added += amount
		total_score += amount
		return amount

	func meta_profile_snapshot() -> Dictionary:
		return {"total_score": total_score}

	func progression_snapshot() -> Dictionary:
		return {"equipment_slots": ["sword"], "relic_ids": ["spark"]}

	func is_current_step_fight() -> bool:
		return current_step_key == "boss"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("finalize_run_uses_injected_state_and_logging_hooks", _test_finalize_run_uses_injected_state_and_logging_hooks, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_finalize_run_uses_injected_state_and_logging_hooks() -> String:
	var owner := FakeOwner.new()
	var recorder := FakeRunLogCoreEventRecorder.new()
	var state := {
		"run_score_banked": false,
		"run_summary": {},
		"core_recorder": recorder,
		"profile_unlock_service": FakeProfileUnlockService.new(),
		"signals": [],
		"exports": 0,
	}
	var service = RUN_OUTCOME_SERVICE_SCRIPT.new(owner, _hooks(state))

	service.finalize_run(true, "victory")
	var summary := Dictionary(state.get("run_summary", {}))
	if owner.run_active:
		return "Expected finalize_run to deactivate the run."
	if not owner.run_victory:
		return "Expected finalize_run to set victory state."
	if int(owner.score_added) != 40:
		return "Expected finalize_run to bank run score through public owner API."
	if not bool(state.get("run_score_banked", false)):
		return "Expected finalize_run to update score-banked state through hooks."
	if not bool(summary.get("victory", false)) or String(summary.get("cause", "")) != "victory":
		return "Expected hooked summary state to include victory outcome."
	if Array(summary.get("victory_equipment_unlocks", [])).is_empty():
		return "Expected victory unlocks from the injected profile unlock service."
	if recorder.run_end_events.size() != 1:
		return "Expected injected run-log recorder to capture run end."
	if int(state.get("exports", 0)) != 1:
		return "Expected injected export hook to run when export is enabled."
	if Array(state.get("signals", [])).is_empty():
		return "Expected injected signal hook to run."
	return ""


func _hooks(state: Dictionary) -> Dictionary:
	return {
		"boss_relic_reward_options": func() -> Array: return [],
		"set_boss_reward_claimed_relic_id": func(_value: String) -> void: pass,
		"current_encounter": func() -> Dictionary: return {"is_boss": true},
		"reward_rng": func() -> RandomNumberGenerator: return RandomNumberGenerator.new(),
		"run_score_banked": func() -> bool: return bool(state.get("run_score_banked", false)),
		"set_run_score_banked": func(value: bool) -> void: state["run_score_banked"] = value,
		"run_summary": func() -> Dictionary: return Dictionary(state.get("run_summary", {})),
		"set_run_summary": func(value: Dictionary) -> void: state["run_summary"] = value,
		"run_log_core_event_recorder": func() -> Variant: return state.get("core_recorder"),
		"run_log_shop_event_recorder": func() -> Variant: return null,
		"profile_unlock_service": func() -> Variant: return state.get("profile_unlock_service"),
		"run_log_append": func(_event_type: String, _payload: Dictionary) -> void: pass,
		"advance_sequence": func(_reason: String) -> void: pass,
		"transition_result": _transition_result,
		"capture_run_signal_state": func() -> Dictionary: return {"before": true},
		"should_export_run_log_files": func() -> bool: return true,
		"run_log_export_to_disk": func() -> void: state["exports"] = int(state.get("exports", 0)) + 1,
		"emit_run_state_signals":
		func(before: Dictionary, reason: String, gold_source: String) -> void:
			Array(state["signals"]).append({"before": before, "reason": reason, "gold_source": gold_source}),
	}


func _transition_result(extra: Dictionary = {}) -> Dictionary:
	var result := {"ok": true, "next_scene": "test"}
	result.merge(extra, true)
	return result
