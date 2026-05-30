extends RefCounted
class_name MainMenuAccessibilityTest

const MAIN_MENU_VIEW := preload("res://scripts/main_menu/main_menu_view.gd")
const MAIN_MENU_ACCESSIBILITY_AUDIT := preload("res://tools/quality/main_menu_accessibility_audit.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("main_menu_accessibility_audit_passes", _test_main_menu_accessibility_audit_passes, failures)
	_run_case("main_menu_accessibility_snapshot_has_contracts", _test_main_menu_accessibility_snapshot_has_contracts, failures)

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


func _test_main_menu_accessibility_audit_passes() -> String:
	var report: Dictionary = MAIN_MENU_ACCESSIBILITY_AUDIT.run_report()
	if bool(report.get("passed", false)):
		return ""
	return "; ".join(Array(report.get("failures", [])))


func _test_main_menu_accessibility_snapshot_has_contracts() -> String:
	var snapshot: Dictionary = MAIN_MENU_VIEW.accessibility_audit_snapshot()
	if Array(snapshot.get("contrast_pairs", [])).size() < 10:
		return "Expected main-menu accessibility snapshot to cover text and non-text contrast pairs."
	if Array(snapshot.get("touch_targets", [])).size() < 3:
		return "Expected main-menu accessibility snapshot to cover menu, footer, and profile touch targets."
	if Array(snapshot.get("keyboard_focus_controls", [])).size() < 8:
		return "Expected main-menu accessibility snapshot to list keyboard-focusable controls."
	if float(snapshot.get("min_text_contrast_ratio", 0.0)) < 4.5:
		return "Expected text contrast floor to stay at least 4.5."
	return ""
