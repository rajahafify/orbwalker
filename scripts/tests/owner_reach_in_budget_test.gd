extends RefCounted
class_name OwnerReachInBudgetTest

const OWNER_REACH_IN_BUDGET_PATH := "res://tools/quality/owner_reach_in_budget.gd"

const EXPECTED_REACH_IN_BASELINES := {
	"res://scripts/combat/combat_controller_lifecycle.gd": 40,
	"res://scripts/combat/combat_controller_binding_coordinator.gd": 63,
	"res://scripts/ui/player_loadout_mastery_panel.gd": 84,
	"res://scripts/core/run_outcome_service.gd": 35,
}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	var reach_in_budget: Variant = ResourceLoader.load(OWNER_REACH_IN_BUDGET_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	var report: Dictionary = reach_in_budget.run_report()
	_run_case("reach_in_report_has_no_new_or_grown_offenders", _test_reach_in_report_has_no_new_or_grown_offenders.bind(report), failures)
	_run_case("documented_reach_ins_have_ratchet_baselines", _test_documented_reach_ins_have_ratchet_baselines.bind(reach_in_budget, report), failures)
	_run_case("reach_in_baselines_match_current_counts", _test_reach_in_baselines_match_current_counts.bind(report), failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_reach_in_report_has_no_new_or_grown_offenders(report: Dictionary) -> String:
	if not bool(report.get("passed", false)):
		return "Expected only ratcheted owner-private reach-ins: %s" % ", ".join(Array(report.get("failures", [])))
	if int(report.get("undocumented_reach_in_files", -1)) != 0:
		return "Expected no undocumented owner-private reach-in files."
	if int(report.get("ratchet_failures", -1)) != 0:
		return "Expected no owner-private reach-in ratchet failures."
	return ""


func _test_documented_reach_ins_have_ratchet_baselines(reach_in_budget: Variant, report: Dictionary) -> String:
	if reach_in_budget.DOCUMENTED_REACH_INS.size() != EXPECTED_REACH_IN_BASELINES.size():
		return "Expected documented reach-in inventory to match the ratchet baseline inventory."
	for path in EXPECTED_REACH_IN_BASELINES.keys():
		if not reach_in_budget.DOCUMENTED_REACH_INS.has(path):
			return "Expected documented reach-in baseline for %s." % path
		var expected_baseline := int(EXPECTED_REACH_IN_BASELINES.get(path, 0))
		if int(reach_in_budget.DOCUMENTED_REACH_INS.get(path, 0)) != expected_baseline:
			return "Expected %s reach-in baseline to be %d." % [path, expected_baseline]
		var entry := _entry_for_path(report, path)
		if entry.is_empty():
			return "Expected ratcheted reach-in path to be scanned: %s." % path
		if not bool(entry.get("documented", false)):
			return "Expected %s to remain a documented reach-in file." % path
	return ""


func _test_reach_in_baselines_match_current_counts(report: Dictionary) -> String:
	for path in EXPECTED_REACH_IN_BASELINES.keys():
		var entry := _entry_for_path(report, path)
		if entry.is_empty():
			return "Expected ratcheted reach-in path to be scanned: %s." % path
		var expected_baseline := int(EXPECTED_REACH_IN_BASELINES.get(path, 0))
		var reach_in_lines := int(entry.get("reach_in_lines", -1))
		if reach_in_lines != expected_baseline:
			return "%s measured %d reach-in lines; update the baseline from %d in the same PR." % [path, reach_in_lines, expected_baseline]
	return ""


func _entry_for_path(report: Dictionary, path: String) -> Dictionary:
	for raw_entry in Array(report.get("entries", [])):
		var entry: Dictionary = raw_entry
		if String(entry.get("path", "")) == path:
			return entry
	return {}
