extends RefCounted
class_name ScriptSizeBudgetTest

const SCRIPT_SIZE_BUDGET := preload("res://tools/quality/script_size_budget.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("budget_report_has_no_undocumented_exceptions", _test_budget_report_has_no_undocumented_exceptions, failures)
	_run_case("combat_scripts_are_scanned", _test_combat_scripts_are_scanned, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_budget_report_has_no_undocumented_exceptions() -> String:
	var report: Dictionary = SCRIPT_SIZE_BUDGET.run_report()
	if not bool(report.get("passed", false)):
		return "Expected documented script-size exceptions only: %s" % [", ".join(Array(report.get("failures", [])))]
	if int(report.get("undocumented", -1)) != 0:
		return "Expected no undocumented over-budget scripts."
	if int(report.get("documented_exceptions", 0)) < 5:
		return "Expected current combat exceptions to be visible in the report."
	return ""


func _test_combat_scripts_are_scanned() -> String:
	var report: Dictionary = SCRIPT_SIZE_BUDGET.run_report()
	var controller_entry := _entry_for_path(report, "res://scripts/combat/combat_controller.gd")
	if controller_entry.is_empty():
		return "Expected combat_controller.gd to be scanned by the size budget."
	if not bool(controller_entry.get("over_budget", false)):
		return "Expected combat_controller.gd to remain visible as over budget."
	if not bool(controller_entry.get("documented_exception", false)):
		return "Expected combat_controller.gd to have a documented exception."
	var view_entry := _entry_for_path(report, "res://scripts/combat/combat_view.gd")
	if view_entry.is_empty():
		return "Expected combat_view.gd to be scanned by the size budget."
	if bool(view_entry.get("over_budget", true)):
		return "Expected combat_view.gd to stay under the measured-line view budget."
	return ""


func _entry_for_path(report: Dictionary, path: String) -> Dictionary:
	for raw_entry in Array(report.get("entries", [])):
		var entry: Dictionary = raw_entry
		if String(entry.get("path", "")) == path:
			return entry
	return {}
