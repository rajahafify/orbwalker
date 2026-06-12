extends RefCounted
class_name RunProfileFacadeTest

const RUN_PROFILE_FACADE_SCRIPT := preload("res://scripts/core/run_profile_facade.gd")
const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")


class FakeMetaProfile:
	var saved := false
	var emitted: Array[Dictionary] = []
	var total_score := 0

	func to_snapshot() -> Dictionary:
		return {"total_score": total_score}

	func add_total_score(amount: int) -> int:
		var added := maxi(0, amount)
		total_score += added
		return added

	func is_equipment_unlocked(_item_id: String) -> bool:
		return false


class FakeProgression:
	var equipped_item_ids: Array[String] = []
	var relic_ids: Array[String] = []

	func to_snapshot() -> Dictionary:
		return {}


class FakeOwner:
	var meta_profile_state := FakeMetaProfile.new()
	var player_profile_state = PLAYER_PROFILE_STATE_SCRIPT.new()
	var progression := FakeProgression.new()

	func ensure_player_profile_state() -> Variant:
		return player_profile_state

	func ensure_meta_profile_state() -> Variant:
		return meta_profile_state

	func ensure_player_progression_state() -> Variant:
		return progression

	func ensure_content_registry() -> Variant:
		return null


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("add_total_score_uses_injected_save_and_signal_hooks", _test_add_total_score_uses_injected_save_and_signal_hooks, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_add_total_score_uses_injected_save_and_signal_hooks() -> String:
	var owner := FakeOwner.new()
	var state := {"saved": false}
	var emitted: Array[Dictionary] = []
	var facade = RUN_PROFILE_FACADE_SCRIPT.new(
		owner,
		{
			"save_meta_profile": func() -> void: state["saved"] = true,
			"emit_profile_changed":
			func(reason: String, delta: int = 0, payload: Dictionary = {}) -> void: emitted.append({"reason": reason, "delta": delta, "payload": payload}),
		}
	)
	if facade.add_total_score(7) != 7:
		return "Expected facade to return the added score."
	if not bool(state.get("saved", false)):
		return "Expected facade to use the injected save hook."
	if emitted.size() != 1:
		return "Expected facade to emit one profile-changed event."
	if String(emitted[0].get("reason", "")) != "add_total_score" or int(emitted[0].get("delta", 0)) != 7:
		return "Expected profile-changed hook to receive add_total_score and delta."
	if owner.meta_profile_state.total_score != 7:
		return "Expected facade to keep using the owner meta-profile public API."
	return ""
