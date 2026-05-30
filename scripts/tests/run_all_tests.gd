extends SceneTree
class_name RunAllTests

const SUITE_ROOTS := [
	"res://scripts/tests",
	"res://scripts/debug",
]
const SUITE_SUFFIXES := [
	"_test.gd",
	"_probe.gd",
]


func _initialize() -> void:
	var report := run_all()
	_print_report(report)
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_all() -> Dictionary:
	var suite_paths := _discover_suite_paths()
	var suite_reports: Array[Dictionary] = []
	var failures: Array[String] = []
	var total := 0
	var failed := 0

	if suite_paths.is_empty():
		failures.append("No test suites discovered under %s" % ", ".join(SUITE_ROOTS))

	for path in suite_paths:
		var suite_report := _run_suite(path)
		suite_reports.append(suite_report)
		total += int(suite_report.get("total", 0))
		failed += int(suite_report.get("failed", 0))
		for failure in Array(suite_report.get("failures", [])):
			failures.append("%s: %s" % [path, String(failure)])

	return {
		"passed": failures.is_empty(),
		"suite_count": suite_reports.size(),
		"total": total,
		"failed": failed,
		"failures": failures,
		"suites": suite_reports,
	}


static func _discover_suite_paths() -> Array[String]:
	var paths: Array[String] = []
	for root_path in SUITE_ROOTS:
		_collect_suite_paths(root_path, paths)
	paths.sort()
	return paths


static func _collect_suite_paths(root_path: String, paths: Array[String]) -> void:
	var dir := DirAccess.open(root_path)
	if dir == null:
		return
	dir.list_dir_begin()
	while true:
		var entry_name := dir.get_next()
		if entry_name == "":
			break
		if entry_name.begins_with("."):
			continue
		var entry_path := root_path.path_join(entry_name)
		if dir.current_is_dir():
			_collect_suite_paths(entry_path, paths)
		elif _is_suite_file(entry_name):
			paths.append(entry_path)
	dir.list_dir_end()


static func _is_suite_file(file_name: String) -> bool:
	for suffix in SUITE_SUFFIXES:
		if file_name.ends_with(suffix):
			return true
	return false


static func _run_suite(path: String) -> Dictionary:
	var script := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Script
	if script == null:
		return _suite_failure(path, "Failed to load script")
	var suite: Variant = script.new()
	if suite == null:
		return _suite_failure(path, "Failed to instantiate script")
	if not suite.has_method("run_all"):
		return _suite_failure(path, "Missing run_all()")
	var result: Variant = suite.call("run_all")
	if not (result is Dictionary):
		return _suite_failure(path, "run_all() must return a Dictionary")
	return _normalize_suite_report(path, result)


static func _normalize_suite_report(path: String, result: Dictionary) -> Dictionary:
	var failures: Array[String] = []
	for failure in Array(result.get("failures", [])):
		failures.append(String(failure))
	var failed := int(result.get("failed", failures.size()))
	var total := int(result.get("total", failures.size()))
	if not bool(result.get("passed", failed == 0 and failures.is_empty())) and failures.is_empty():
		failures.append("Suite reported passed=false without failure details")
		failed = maxi(failed, 1)
	failed = maxi(failed, failures.size())
	return {
		"path": path,
		"passed": failed == 0 and failures.is_empty(),
		"total": total,
		"failed": failed,
		"failures": failures,
	}


static func _suite_failure(path: String, message: String) -> Dictionary:
	return {
		"path": path,
		"passed": false,
		"total": 1,
		"failed": 1,
		"failures": [message],
	}


static func _print_report(report: Dictionary) -> void:
	var suite_reports := Array(report.get("suites", []))
	print("[TestRunner] suites=%d cases=%d failed=%d" % [
		int(report.get("suite_count", suite_reports.size())),
		int(report.get("total", 0)),
		int(report.get("failed", 0)),
	])
	for suite_report in suite_reports:
		var path := String(suite_report.get("path", "unknown"))
		var total := int(suite_report.get("total", 0))
		var failed := int(suite_report.get("failed", 0))
		if failed == 0:
			print("[PASS] %s (%d)" % [path, total])
		else:
			printerr("[FAIL] %s (%d failed of %d)" % [path, failed, total])
			for failure in Array(suite_report.get("failures", [])):
				printerr("  - %s" % String(failure))
