extends RefCounted
class_name RunSummaryModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("victory_and_defeat_text", _test_victory_and_defeat_text, failures)
	_run_case("stats_rows_clamp_monsters_and_format_gold", _test_stats_rows_clamp_monsters_and_format_gold, failures)
	_run_case("equipment_and_relic_lines_format_empty_values", _test_equipment_and_relic_lines_format_empty_values, failures)
	_run_case("snapshot_is_deep_copy", _test_snapshot_is_deep_copy, failures)
	_run_case("normalize_unlock_entries_accepts_arrays_and_nested_payloads", _test_normalize_unlock_entries_accepts_arrays_and_nested_payloads, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
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


func _test_victory_and_defeat_text() -> String:
	var model := RunSummaryModel.new()
	model._summary = {"victory": true}
	model._victory = true
	if not model.is_victory() or model.title_text() != "VICTORY":
		return "Expected victory title/state."
	if model.subtitle_text() != "Final boss defeated. Prototype run cleared.":
		return "Expected fixed victory subtitle."
	model._summary = {"victory": false, "cause": "Player defeated."}
	model._victory = false
	if model.is_victory() or model.title_text() != "DEFEAT":
		return "Expected defeat title/state."
	if model.subtitle_text() != "Player defeated.":
		return "Expected defeat subtitle to use summary cause."
	return ""


func _test_stats_rows_clamp_monsters_and_format_gold() -> String:
	var model := RunSummaryModel.new()
	model._summary = {
		"victory": false,
		"level_reached": 2,
		"enemies_defeated": 1,
		"bosses_defeated": 3,
		"gold_earned": 14,
		"final_gold": 9,
	}
	model._victory = false
	var rows := model.stats_rows()
	if rows.size() != 6:
		return "Expected six stat rows."
	if String(Dictionary(rows[0]).get("value", "")) != "2 / %d" % RunState.MAX_DUNGEON_LEVELS:
		return "Expected level row to include max dungeon levels."
	if String(Dictionary(rows[1]).get("value", "")) != "0":
		return "Expected monster kills to clamp below zero."
	if String(Dictionary(rows[3]).get("value", "")) != "+14":
		return "Expected gold earned row to include plus prefix."
	if String(Dictionary(rows[5]).get("value", "")) != "FALLEN":
		return "Expected defeat result row."
	model._victory = true
	if String(Dictionary(model.stats_rows()[5]).get("value", "")) != "CLEAR":
		return "Expected victory result row."
	return ""


func _test_equipment_and_relic_lines_format_empty_values() -> String:
	var model := RunSummaryModel.new()
	model._summary = {
		"equipment_slots": ["shortsword", "", "buckler"],
		"relic_ids": ["merchant_compass"],
	}
	var equipment := model.equipment_lines()
	if equipment != ["1. shortsword", "2. Empty", "3. buckler"]:
		return "Expected equipment slots to be numbered and empty slots labelled."
	if model.relic_lines() != ["Merchant Compass"]:
		return "Expected relic ids to be title-cased."
	model._summary = {"relic_ids": []}
	if model.relic_lines() != ["None claimed"]:
		return "Expected empty relic list fallback."
	return ""


func _test_snapshot_is_deep_copy() -> String:
	var model := RunSummaryModel.new()
	model._summary = {"victory": true, "nested": {"value": 1}}
	model._victory = true
	var snapshot := model.snapshot()
	Dictionary(snapshot["summary"])["victory"] = false
	if not model.is_victory():
		return "Expected snapshot mutation not to alter victory state."
	return ""


func _test_normalize_unlock_entries_accepts_arrays_and_nested_payloads() -> String:
	var model := RunSummaryModel.new()
	var from_array := model._normalize_unlock_entries(["iron_sword", {"item_id": "buckler", "display_name": "Buckler"}])
	if from_array.size() != 2:
		return "Expected string and dictionary unlock entries to normalize."
	if String(Dictionary(from_array[0]).get("display_name", "")) != "Iron Sword":
		return "Expected string unlock entry to receive title-cased display name."
	var nested := model._normalize_unlock_entries({"unlocks": ["coin_purse"]})
	if nested.size() != 1 or String(Dictionary(nested[0]).get("item_id", "")) != "coin_purse":
		return "Expected nested unlock payload to normalize."
	return ""
