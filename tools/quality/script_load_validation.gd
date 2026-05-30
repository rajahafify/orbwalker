extends SceneTree

const SCAN_ROOTS := [
	"res://scripts",
]


func _initialize() -> void:
	var report := run_report()
	_print_report(report)
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var paths := _discover_script_paths()
	var failures: Array[String] = []
	var loaded_count := 0

	for path in paths:
		var script := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Script
		if script == null:
			failures.append("Failed to load script: %s" % path)
			continue
		loaded_count += 1

	return {
		"passed": failures.is_empty(),
		"scanned": paths.size(),
		"loaded": loaded_count,
		"failed": failures.size(),
		"failures": failures,
	}


static func _discover_script_paths() -> Array[String]:
	var paths: Array[String] = []
	for root_path in SCAN_ROOTS:
		_collect_script_paths(root_path, paths)
	paths.sort()
	return paths


static func _collect_script_paths(root_path: String, paths: Array[String]) -> void:
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
			_collect_script_paths(entry_path, paths)
		elif entry_name.ends_with(".gd"):
			paths.append(entry_path)
	dir.list_dir_end()


static func _print_report(report: Dictionary) -> void:
	print("[ScriptLoadValidation] scanned=%d loaded=%d failed=%d" % [
		int(report.get("scanned", 0)),
		int(report.get("loaded", 0)),
		int(report.get("failed", 0)),
	])
	for failure in Array(report.get("failures", [])):
		printerr("[ScriptLoadValidation][FAIL] %s" % String(failure))
