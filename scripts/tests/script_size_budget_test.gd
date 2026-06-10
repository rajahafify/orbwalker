extends RefCounted
class_name ScriptSizeBudgetTest

const SCRIPT_SIZE_BUDGET_PATH := "res://tools/quality/script_size_budget.gd"

const EXPECTED_RATCHET_BASELINES := {
	"res://scripts/combat/combat_controller.gd": 1958,
	"res://scripts/ui/player_loadout_hud.gd": 1924,
	"res://scripts/ui/visual_registry.gd": 1722,
	"res://scripts/core/run_state.gd": 1538,
	"res://scripts/combat/combat_max_vfx_overlay.gd": 1088,
	"res://scripts/main_menu/main_menu_view.gd": 1007,
	"res://scripts/content/content_registry.gd": 807,
	"res://scripts/debug/vfx_gallery_show.gd": 761,
	"res://scripts/combat/combat_layout_presenter.gd": 732,
	"res://scripts/combat/combat_chrome_styler.gd": 701,
	"res://scripts/board/board_view.gd": 598,
	"res://scripts/combat/combat_view.gd": 549,
}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	var script_size_budget: Variant = ResourceLoader.load(SCRIPT_SIZE_BUDGET_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	var report: Dictionary = script_size_budget.run_report()
	_run_case("budget_report_has_no_undocumented_exceptions", _test_budget_report_has_no_undocumented_exceptions.bind(report), failures)
	_run_case("combat_scripts_are_scanned", _test_combat_scripts_are_scanned.bind(report), failures)
	_run_case("production_script_directories_are_scanned", _test_production_script_directories_are_scanned.bind(report), failures)
	_run_case("documented_exceptions_have_ratchet_baselines", _test_documented_exceptions_have_ratchet_baselines.bind(script_size_budget, report), failures)
	_run_case("ratchet_baselines_match_current_sizes", _test_ratchet_baselines_match_current_sizes.bind(report), failures)
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


func _test_budget_report_has_no_undocumented_exceptions(report: Dictionary) -> String:
	if not bool(report.get("passed", false)):
		return "Expected documented script-size exceptions only: %s" % [", ".join(Array(report.get("failures", [])))]
	if int(report.get("undocumented", -1)) != 0:
		return "Expected no undocumented over-budget scripts."
	if int(report.get("documented_exceptions", 0)) < 5:
		return "Expected current combat exceptions to be visible in the report."
	return ""


func _test_combat_scripts_are_scanned(report: Dictionary) -> String:
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
	if bool(view_entry.get("over_budget", false)) and not bool(view_entry.get("documented_exception", false)):
		return "Expected combat_view.gd to stay under budget or carry a documented exception."
	return ""


func _test_production_script_directories_are_scanned(report: Dictionary) -> String:
	var scanned_dirs := {}
	for raw_entry in Array(report.get("entries", [])):
		var entry: Dictionary = raw_entry
		var path := String(entry.get("path", ""))
		if path != "":
			scanned_dirs[path.get_base_dir()] = true

	var expected_dirs := {}
	_collect_production_script_dirs("res://scripts", expected_dirs)
	var missing_dirs: Array[String] = []
	for dir_path in expected_dirs.keys():
		if not scanned_dirs.has(String(dir_path)):
			missing_dirs.append(String(dir_path))
	missing_dirs.sort()
	if not missing_dirs.is_empty():
		return "Expected every production script directory to be scanned; missing: %s" % ", ".join(missing_dirs)
	return ""


func _test_documented_exceptions_have_ratchet_baselines(script_size_budget: Variant, report: Dictionary) -> String:
	if script_size_budget.DOCUMENTED_EXCEPTIONS.size() != EXPECTED_RATCHET_BASELINES.size():
		return "Expected documented exception inventory to match the ratchet baseline inventory."
	for path in EXPECTED_RATCHET_BASELINES.keys():
		if not script_size_budget.DOCUMENTED_EXCEPTIONS.has(path):
			return "Expected documented exception for %s." % path
		var exception: Dictionary = script_size_budget.DOCUMENTED_EXCEPTIONS.get(path, {})
		var expected_baseline := int(EXPECTED_RATCHET_BASELINES.get(path, 0))
		if int(exception.get("baseline", 0)) != expected_baseline:
			return "Expected %s ratchet baseline to be %d." % [path, expected_baseline]
		var entry := _entry_for_path(report, path)
		if entry.is_empty():
			return "Expected ratcheted exception to be scanned: %s." % path
		if not bool(entry.get("documented_exception", false)):
			return "Expected ratcheted path to remain a documented exception: %s." % path
		if int(entry.get("ratchet_baseline", 0)) != expected_baseline:
			return "Expected report baseline for %s to be %d." % [path, expected_baseline]
	return ""


func _test_ratchet_baselines_match_current_sizes(report: Dictionary) -> String:
	for path in EXPECTED_RATCHET_BASELINES.keys():
		var entry := _entry_for_path(report, path)
		if entry.is_empty():
			return "Expected ratcheted path to be scanned: %s." % path
		var expected_baseline := int(EXPECTED_RATCHET_BASELINES.get(path, 0))
		var line_count := int(entry.get("line_count", -1))
		if line_count != expected_baseline:
			return "%s measured %d lines; update the ratchet baseline from %d in the same PR." % [path, line_count, expected_baseline]
	return ""


func _entry_for_path(report: Dictionary, path: String) -> Dictionary:
	for raw_entry in Array(report.get("entries", [])):
		var entry: Dictionary = raw_entry
		if String(entry.get("path", "")) == path:
			return entry
	return {}


func _collect_production_script_dirs(root_path: String, dirs: Dictionary) -> void:
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
			_collect_production_script_dirs(entry_path, dirs)
		elif _is_production_script(entry_name):
			dirs[root_path] = true
	dir.list_dir_end()


func _is_production_script(file_name: String) -> bool:
	if not file_name.ends_with(".gd"):
		return false
	if file_name.ends_with("_test.gd") or file_name.ends_with("_probe.gd"):
		return false
	return true
