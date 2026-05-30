extends RefCounted
class_name TestSurfaceCoverageTest

const TEST_SURFACE_COVERAGE := preload("res://tools/quality/test_surface_coverage.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("test_surface_report_has_current_baseline", _test_surface_report_has_current_baseline, failures)
	_run_case("test_surface_floor_is_active", _test_surface_floor_is_active, failures)

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


func _test_surface_report_has_current_baseline() -> String:
	var report: Dictionary = TEST_SURFACE_COVERAGE.run_report()
	var production_count := int(report.get("production", 0))
	var covered_count := int(report.get("covered", 0))
	var coverage_percent := float(report.get("coverage_percent", 0.0))
	if production_count <= 0:
		return "Expected production scripts to be discovered."
	if covered_count <= 0:
		return "Expected tests/probes to reference production scripts."
	if coverage_percent < float(report.get("floor_percent", 0.0)):
		return "Expected current test surface coverage to meet the configured floor."
	return ""


func _test_surface_floor_is_active() -> String:
	var report: Dictionary = TEST_SURFACE_COVERAGE.run_report()
	if float(report.get("floor_percent", 0.0)) <= 0.0:
		return "Expected test surface coverage floor to be greater than zero."
	if not bool(report.get("passed", false)):
		return "; ".join(Array(report.get("failures", [])))
	return ""
