extends SceneTree
class_name TestSurfaceCoverage

const PRODUCTION_ROOTS := [
	"res://scripts/board",
	"res://scripts/collection",
	"res://scripts/combat",
	"res://scripts/content",
	"res://scripts/core",
	"res://scripts/main_menu",
	"res://scripts/run",
	"res://scripts/run_summary",
	"res://scripts/scenes",
	"res://scripts/shop",
	"res://scripts/ui",
]
const TEST_SURFACE_ROOTS := [
	"res://scripts/debug",
	"res://scripts/tests",
	"res://tools/qa",
]
const RES_PATH_PATTERN := "res://[A-Za-z0-9_./-]+\\.(gd|tscn)"
const CLASS_NAME_PATTERN := "class_name\\s+([A-Za-z_][A-Za-z0-9_]*)"
const IDENTIFIER_PATTERN := "[A-Za-z_][A-Za-z0-9_]*"
const COVERAGE_FLOOR_PERCENT := 71.0
const UNCOVERED_PRINT_LIMIT := 16


func _initialize() -> void:
	var report := run_report()
	_print_report(report)
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var production_paths := _discover_script_paths(PRODUCTION_ROOTS)
	var production_set := _path_set(production_paths)
	var referenced_paths := _discover_referenced_paths(TEST_SURFACE_ROOTS, production_set)
	var covered_paths: Array[String] = []
	var uncovered_paths: Array[String] = []

	for path in production_paths:
		if referenced_paths.has(path):
			covered_paths.append(path)
		else:
			uncovered_paths.append(path)

	var coverage_percent := _percent(covered_paths.size(), production_paths.size())
	var failures: Array[String] = []
	if production_paths.is_empty():
		failures.append("No production scripts found for test surface coverage.")
	if coverage_percent + 0.001 < COVERAGE_FLOOR_PERCENT:
		failures.append("Test surface coverage %.2f%% is below the %.2f%% floor." % [
			coverage_percent,
			COVERAGE_FLOOR_PERCENT,
		])

	return {
		"passed": failures.is_empty(),
		"production": production_paths.size(),
		"covered": covered_paths.size(),
		"uncovered": uncovered_paths.size(),
		"coverage_percent": coverage_percent,
		"floor_percent": COVERAGE_FLOOR_PERCENT,
		"covered_paths": covered_paths,
		"uncovered_paths": uncovered_paths,
		"referenced_paths": referenced_paths.keys(),
		"failures": failures,
	}


static func _discover_script_paths(root_paths: Array) -> Array[String]:
	var paths: Array[String] = []
	for root_path in root_paths:
		_collect_paths(String(root_path), [".gd"], paths)
	paths.sort()
	return paths


static func _discover_referenced_paths(root_paths: Array, production_set: Dictionary) -> Dictionary:
	var source_paths: Array[String] = []
	for root_path in root_paths:
		_collect_paths(String(root_path), [".gd"], source_paths)
	source_paths.sort()
	var class_name_paths := _discover_production_class_name_paths(production_set.keys())

	var referenced := {}
	var path_regex := RegEx.new()
	var class_regex := RegEx.new()
	var path_compile_error := path_regex.compile(RES_PATH_PATTERN)
	var class_compile_error := class_regex.compile(IDENTIFIER_PATTERN)
	if path_compile_error != OK or class_compile_error != OK:
		push_error("Failed to compile test surface coverage regex.")
		return referenced

	for source_path in source_paths:
		_collect_references_from_source(source_path, path_regex, production_set, referenced)
		_collect_class_name_references(source_path, class_regex, class_name_paths, referenced)
	return referenced


static func _discover_production_class_name_paths(production_paths: Array) -> Dictionary:
	var class_name_paths := {}
	var regex := RegEx.new()
	if regex.compile(CLASS_NAME_PATTERN) != OK:
		push_error("Failed to compile class_name regex.")
		return class_name_paths
	for path_value in production_paths:
		var path := String(path_value)
		var source := FileAccess.get_file_as_string(path)
		var result := regex.search(source)
		if result == null:
			continue
		var class_id := result.get_string(1)
		if class_id != "":
			class_name_paths[class_id] = path
	return class_name_paths


static func _collect_references_from_source(source_path: String, regex: RegEx, production_set: Dictionary, referenced: Dictionary) -> void:
	var source := FileAccess.get_file_as_string(source_path)
	for result in regex.search_all(source):
		var path := _normalize_res_path(result.get_string())
		if path.ends_with(".gd"):
			_record_reference(path, production_set, referenced)
		elif path.ends_with(".tscn"):
			_collect_scene_script_references(path, regex, production_set, referenced)


static func _collect_class_name_references(source_path: String, regex: RegEx, class_name_paths: Dictionary, referenced: Dictionary) -> void:
	var source := FileAccess.get_file_as_string(source_path)
	for result in regex.search_all(source):
		var identifier := result.get_string()
		if class_name_paths.has(identifier):
			referenced[class_name_paths[identifier]] = true


static func _collect_scene_script_references(scene_path: String, regex: RegEx, production_set: Dictionary, referenced: Dictionary) -> void:
	if not FileAccess.file_exists(scene_path):
		return
	var scene_source := FileAccess.get_file_as_string(scene_path)
	for result in regex.search_all(scene_source):
		var path := _normalize_res_path(result.get_string())
		if path.ends_with(".gd"):
			_record_reference(path, production_set, referenced)


static func _record_reference(path: String, production_set: Dictionary, referenced: Dictionary) -> void:
	if production_set.has(path):
		referenced[path] = true


static func _collect_paths(root_path: String, suffixes: Array[String], paths: Array[String]) -> void:
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
		var entry_path := _normalize_res_path(root_path.path_join(entry_name))
		if dir.current_is_dir():
			_collect_paths(entry_path, suffixes, paths)
		elif _has_suffix(entry_name, suffixes):
			paths.append(entry_path)
	dir.list_dir_end()


static func _has_suffix(file_name: String, suffixes: Array[String]) -> bool:
	for suffix in suffixes:
		if file_name.ends_with(String(suffix)):
			return true
	return false


static func _path_set(paths: Array[String]) -> Dictionary:
	var set := {}
	for path in paths:
		set[path] = true
	return set


static func _normalize_res_path(path: String) -> String:
	return path.replace("\\", "/")


static func _percent(value: int, total: int) -> float:
	if total <= 0:
		return 0.0
	return round(float(value) * 10000.0 / float(total)) / 100.0


static func _print_report(report: Dictionary) -> void:
	print("[TestSurfaceCoverage] production=%d covered=%d uncovered=%d coverage=%.2f%% floor=%.2f%%" % [
		int(report.get("production", 0)),
		int(report.get("covered", 0)),
		int(report.get("uncovered", 0)),
		float(report.get("coverage_percent", 0.0)),
		float(report.get("floor_percent", COVERAGE_FLOOR_PERCENT)),
	])
	for failure in Array(report.get("failures", [])):
		printerr("[TestSurfaceCoverage][FAIL] %s" % String(failure))
	var uncovered_paths := Array(report.get("uncovered_paths", []))
	if uncovered_paths.is_empty():
		return
	var visible: Array[String] = []
	for index in mini(uncovered_paths.size(), UNCOVERED_PRINT_LIMIT):
		visible.append(String(uncovered_paths[index]))
	if uncovered_paths.size() > UNCOVERED_PRINT_LIMIT:
		visible.append("... +%d more" % (uncovered_paths.size() - UNCOVERED_PRINT_LIMIT))
	print("[TestSurfaceCoverage] uncovered=%s" % ", ".join(visible))
