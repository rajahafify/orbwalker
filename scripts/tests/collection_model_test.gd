extends RefCounted
class_name CollectionModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("score_text_and_snapshot", _test_score_text_and_snapshot, failures)
	_run_case("family_view_models_unlock_and_claimable_progression", _test_family_view_models_unlock_and_claimable_progression, failures)
	_run_case("family_view_models_include_card_asset_fields", _test_family_view_models_include_card_asset_fields, failures)
	_run_case("validate_claim_rejects_missing_previous_and_score", _test_validate_claim_rejects_missing_previous_and_score, failures)
	_run_case("normalize_unlock_entries_accepts_arrays_and_nested_payloads", _test_normalize_unlock_entries_accepts_arrays_and_nested_payloads, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
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


func _test_family_view_models_include_card_asset_fields() -> String:
	var model := CollectionModel.new()
	model._profile_snapshot = {"unlocked_equipment_ids": ["shortsword", "buckler", "coin_purse", "healing_charm", "leather_gloves"]}
	model._unlocked_item_ids = {
		"shortsword": true,
		"buckler": true,
		"coin_purse": true,
		"healing_charm": true,
		"leather_gloves": true,
	}
	model._total_score = 300
	var families := model.family_view_models()
	if families.size() != 5:
		return "Expected five equipment families."
	for family in families:
		var family_dict := Dictionary(family)
		var tiers := Array(family_dict.get("tiers", []))
		if tiers.size() != 3:
			return "Expected family %s to expose three tiers." % String(family_dict.get("family_id", "unknown"))
		for tier in tiers:
			var tier_dict := Dictionary(tier)
			var tier_id := String(tier_dict.get("tier_id", ""))
			if String(tier_dict.get("description", "")) == "":
				return "Expected %s to expose description for card copy." % String(tier_dict.get("item_id", "unknown"))
			if String(tier_dict.get("icon_key", "")) == "":
				return "Expected %s to expose icon_key for card art." % String(tier_dict.get("item_id", "unknown"))
			if String(tier_dict.get("rarity", "")) != tier_id:
				return "Expected %s rarity to match its tier id." % String(tier_dict.get("item_id", "unknown"))
			if String(tier_dict.get("card_badge_text", "")) == "":
				return "Expected %s to expose compact card badge text." % String(tier_dict.get("item_id", "unknown"))
			if not tier_dict.has("card_claim_enabled"):
				return "Expected %s to expose card_claim_enabled." % String(tier_dict.get("item_id", "unknown"))
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
