extends RefCounted
class_name CollectionModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("score_text_and_snapshot", _test_score_text_and_snapshot, failures)
	_run_case("family_view_models_unlock_and_claimable_progression", _test_family_view_models_unlock_and_claimable_progression, failures)
	_run_case("validate_claim_rejects_missing_previous_and_score", _test_validate_claim_rejects_missing_previous_and_score, failures)
	_run_case("normalize_unlock_entries_accepts_arrays_and_nested_payloads", _test_normalize_unlock_entries_accepts_arrays_and_nested_payloads, failures)

	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_score_text_and_snapshot() -> String:
	var model := CollectionModel.new()
	model._profile_snapshot = {"unlocked_equipment_ids": ["shortsword"]}
	model._unlocked_item_ids = {"shortsword": true}
	model._total_score = 42
	if model.score_text() != "Total Score: 42":
		return "Expected score_text to use total score."
	var snapshot := model.snapshot()
	if int(snapshot.get("total_score", -1)) != 42:
		return "Expected snapshot to include total score."
	Dictionary(snapshot["profile_snapshot"])["unlocked_equipment_ids"] = []
	if not model._unlocked_item_ids.has("shortsword"):
		return "Expected snapshot mutation not to alter model unlocked ids."
	return ""


func _test_family_view_models_unlock_and_claimable_progression() -> String:
	var model := CollectionModel.new()
	model._profile_snapshot = {"unlocked_equipment_ids": ["shortsword"]}
	model._unlocked_item_ids = {"shortsword": true}
	model._total_score = 120
	var families := model.family_view_models()
	var shortsword := Dictionary(families[0])
	var tiers := Array(shortsword.get("tiers", []))
	var common := Dictionary(tiers[0])
	var uncommon := Dictionary(tiers[1])
	var rare := Dictionary(tiers[2])
	if not bool(common.get("unlocked", false)) or bool(common.get("claimable", true)):
		return "Expected common shortsword to be unlocked and not claimable."
	if bool(uncommon.get("unlocked", true)) or not bool(uncommon.get("previous_unlocked", false)):
		return "Expected uncommon shortsword to be locked with previous tier unlocked."
	if not bool(uncommon.get("claimable", false)):
		return "Expected uncommon shortsword to be claimable when score requirement is met."
	if bool(rare.get("claimable", false)):
		return "Expected rare shortsword not to be claimable before uncommon unlock and score requirement."
	return ""


func _test_validate_claim_rejects_missing_previous_and_score() -> String:
	var model := CollectionModel.new()
	model._total_score = 50
	if bool(model.validate_claim({}).get("ok", true)):
		return "Expected missing item id to be rejected."
	if bool(model.validate_claim({"item_id": "x", "previous_unlocked": false, "required_score": 0}).get("ok", true)):
		return "Expected locked previous tier to be rejected."
	if bool(model.validate_claim({"item_id": "x", "previous_unlocked": true, "required_score": 100}).get("ok", true)):
		return "Expected insufficient score to be rejected."
	if not bool(model.validate_claim({"item_id": "x", "previous_unlocked": true, "required_score": 50}).get("ok", false)):
		return "Expected valid claim payload to pass."
	return ""


func _test_normalize_unlock_entries_accepts_arrays_and_nested_payloads() -> String:
	var model := CollectionModel.new()
	var from_array := model._normalize_unlock_entries(["iron_sword", {"item_id": "buckler", "display_name": "Buckler"}])
	if from_array.size() != 2:
		return "Expected string and dictionary unlock entries to normalize."
	if String(Dictionary(from_array[0]).get("display_name", "")) != "Iron Sword":
		return "Expected string unlock entry to receive title-cased display name."
	var nested := model._normalize_unlock_entries({"recent_unlocks": ["coin_purse"]})
	if nested.size() != 1 or String(Dictionary(nested[0]).get("item_id", "")) != "coin_purse":
		return "Expected nested recent unlock payload to normalize."
	return ""
