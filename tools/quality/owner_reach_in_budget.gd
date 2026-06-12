extends SceneTree

const SCAN_ROOTS := [
	"res://scripts",
]
const DOC_PATH := "res://docs/refactor_progress_report_2026-06-12.html"
const REACH_IN_PATTERNS := [
	"_owner._",
	"owner._",
	"_hud._",
]

const DOCUMENTED_REACH_INS := {
	"res://scripts/combat/combat_controller_lifecycle.gd": 40,
	"res://scripts/combat/combat_controller_binding_coordinator.gd": 63,
	"res://scripts/ui/player_loadout_mastery_panel.gd": 84,
	"res://scripts/core/run_outcome_service.gd": 35,
	"res://scripts/core/run_transition_state_store.gd": 26,
	"res://scripts/core/run_profile_facade.gd": 14,
}


func _initialize() -> void:
	var report := run_report()
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var paths := _discover_script_paths()
	var entries: Array[Dictionary] = []
	var failures: Array[String] = []
	var scanned_paths := {}
	var total_reach_in_lines := 0
	var documented_count := 0
	var undocumented_count := 0
	var ratchet_failure_count := 0
	var stale_count := 0

	for path in paths:
		scanned_paths[path] = true
		var count := _reach_in_line_count(path)
		if count <= 0:
			continue
		total_reach_in_lines += count
		var documented := DOCUMENTED_REACH_INS.has(path)
		var baseline := int(DOCUMENTED_REACH_INS.get(path, 0))
		if documented:
			documented_count += 1
			var ratchet_failure := _ratchet_failure_message(path, count, baseline)
			if ratchet_failure != "":
				ratchet_failure_count += 1
				failures.append(ratchet_failure)
				_print_warning(path, count, baseline, ratchet_failure)
			else:
				_print_documented(path, count, baseline)
		else:
			undocumented_count += 1
			var message := "Undocumented owner-private reach-in file: %s lines=%d. See %s" % [path, count, DOC_PATH]
			failures.append(message)
			_print_warning(path, count, baseline, message)
		entries.append({"path": path, "reach_in_lines": count, "baseline": baseline, "documented": documented})

	for documented_path in DOCUMENTED_REACH_INS.keys():
		if not scanned_paths.has(documented_path):
			failures.append("Documented reach-in path was not scanned: %s" % documented_path)
			continue
		var current := _reach_in_line_count(String(documented_path))
		if current <= 0:
			stale_count += 1
			failures.append("Documented reach-in path has no remaining reach-ins and can be removed: %s" % documented_path)

	return {
		"passed": failures.is_empty(),
		"entries": entries,
		"failures": failures,
		"documented_reach_in_files": documented_count,
		"undocumented_reach_in_files": undocumented_count,
		"ratchet_failures": ratchet_failure_count,
		"stale_reach_in_files": stale_count,
		"total_reach_in_lines": total_reach_in_lines,
	}


static func _ratchet_failure_message(path: String, count: int, baseline: int) -> String:
	if baseline <= 0:
		return "Documented reach-in path is missing a baseline: %s" % path
	if count > baseline:
		return "Owner-private reach-ins exceed ratchet baseline: %s lines=%d baseline=%d" % [path, count, baseline]
	if count < baseline:
		return "Owner-private reach-ins are below ratchet baseline; lower the checked-in baseline: %s lines=%d baseline=%d" % [path, count, baseline]
	return ""


static func _discover_script_paths() -> Array[String]:
	var paths: Array[String] = []
	for root in SCAN_ROOTS:
		_collect_script_paths(root, paths)
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
			if entry_name == "tests":
				continue
			_collect_script_paths(entry_path, paths)
		elif _is_production_script(entry_name):
			paths.append(entry_path)
	dir.list_dir_end()


static func _is_production_script(file_name: String) -> bool:
	return file_name.ends_with(".gd") and not file_name.ends_with("_test.gd") and not file_name.ends_with("_probe.gd")


static func _reach_in_line_count(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var count := 0
	while not file.eof_reached():
		var line := file.get_line()
		if _line_has_reach_in(line):
			count += 1
	return count


static func _line_has_reach_in(line: String) -> bool:
	var trimmed := line.strip_edges()
	if trimmed == "" or trimmed.begins_with("#"):
		return false
	for pattern in REACH_IN_PATTERNS:
		if line.find(pattern) >= 0:
			return true
	return false


static func _print_warning(path: String, count: int, baseline: int, message: String) -> void:
	var file_path := path.replace("res://", "")
	print("::warning file=%s,line=1,title=Owner reach-in budget::%s" % [file_path, message])
	print("[OwnerReachInBudget][failure] %s lines=%d baseline=%d message=%s" % [path, count, baseline, message])


static func _print_documented(path: String, count: int, baseline: int) -> void:
	print("[OwnerReachInBudget][documented] %s lines=%d baseline=%d" % [path, count, baseline])
