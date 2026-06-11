extends SceneTree

const SCAN_ROOTS := [
	"res://scripts",
]
const CONTROLLER_BUDGET := 400
const VIEW_BUDGET := 500
const DEFAULT_BUDGET := 650
const DOC_PATH := "res://docs/script_size_budget.html"

const DOCUMENTED_EXCEPTIONS := {
	"res://scripts/combat/combat_controller.gd":
	{
		"baseline": 1962,
		"owner": "P1-1",
		"reason":
		"Combat orchestration is still being decomposed; keep state-machine, input-phase, replay, and route authority here until smaller collaborators are covered.",
	},
	"res://scripts/combat/combat_chrome_styler.gd":
	{
		"baseline": 701,
		"owner": "P1-2",
		"reason":
		"Combat chrome styling is centralized while the view split is still settling; split HUD, board, debug, and outcome chrome into focused stylers.",
	},
	"res://scripts/combat/combat_layout_presenter.gd":
	{
		"baseline": 732,
		"owner": "P1-2",
		"reason":
		"Combat layout rules are centralized during view decomposition; split board, HUD, overlay, and debug layout surfaces after screenshot guards cover them.",
	},
	"res://scripts/combat/combat_view.gd":
	{
		"baseline": 549,
		"owner": "P1-2/P5-2",
		"reason":
		"Combat view now routes settings overlays, enemy stage reactions, tutorial overlays, HUD snapshots, and VFX bindings while view decomposition is in progress.",
	},
	"res://scripts/combat/combat_max_vfx_overlay.gd":
	{
		"baseline": 1088,
		"owner": "P1-2/P5-2",
		"reason":
		"Max-combat VFX owns several effect families and asset path catalogs; split effect-family emitters and move static asset catalogs to resources.",
	},
	"res://scripts/ui/player_loadout_hud.gd":
	{
		"baseline": 1924,
		"owner": "R-P1-3",
		"reason":
		"Player loadout HUD owns equipment, consumable, mastery, tooltip, and input surfaces; split visible rails into presenters before enforcing the default budget.",
	},
	"res://scripts/ui/visual_registry.gd":
	{
		"baseline": 1561,
		"owner": "R-P1-3",
		"reason":
		"Visual registry is still a code-backed art catalog; move static paths and texture maps into resources or generated data behind a thin lookup API.",
	},
	"res://scripts/core/run_state.gd":
	{
		"baseline": 1532,
		"owner": "R-P1-2",
		"reason":
		"RunState still owns run progression, settings persistence, routing constants, tracing, and logging; extract settings/routing stores and type collaborators.",
	},
	"res://scripts/main_menu/main_menu_view.gd":
	{
		"baseline": 1007,
		"owner": "R-P1-3",
		"reason":
		"Main menu view combines layout, profile/log controls, debug affordances, and button wiring; split focused presenters and accessibility focus setup.",
	},
	"res://scripts/content/content_registry.gd":
	{
		"baseline": 807,
		"owner": "R-P1-3",
		"reason":
		"Content registry remains a large code-backed catalog; move static records into resources or generated data while preserving typed lookup methods.",
	},
	"res://scripts/debug/vfx_gallery_show.gd":
	{
		"baseline": 761,
		"owner": "R-P4-2",
		"reason":
		"Developer VFX gallery script owns catalog loading, preview construction, controls, and presentation; split gallery UI presenters as the tool stabilizes.",
	},
	"res://scripts/board/board_view.gd":
	{
		"baseline": 598,
		"owner": "R-P1-3",
		"reason":
		"Board view still owns grid layout, cell rendering, touch projection, selection state, and animation surfaces; split render and input helpers.",
	},
}


func _initialize() -> void:
	var report := run_report()
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var paths := _discover_script_paths()
	var entries: Array[Dictionary] = []
	var over_budget_count := 0
	var undocumented_count := 0
	var documented_count := 0
	var stale_exception_count := 0
	var ratchet_failure_count := 0
	var failures: Array[String] = []
	var scanned_paths := {}

	for path in paths:
		scanned_paths[path] = true
		var line_count := _line_count(path)
		var budget := _budget_for_path(path)
		var over_budget := line_count > budget
		var documented_exception := DOCUMENTED_EXCEPTIONS.has(path)
		var ratchet_baseline := _ratchet_baseline_for_path(path)
		if documented_exception:
			var ratchet_failure := _ratchet_failure_message(path, line_count, ratchet_baseline)
			if ratchet_failure != "":
				ratchet_failure_count += 1
				failures.append(ratchet_failure)
				_print_warning(path, line_count, budget, ratchet_failure)
		if over_budget:
			over_budget_count += 1
			if documented_exception:
				documented_count += 1
				_print_documented_exception(path, line_count, budget)
			else:
				undocumented_count += 1
				failures.append("Undocumented oversized script: %s" % path)
				_print_warning(path, line_count, budget, "Script exceeds size budget without a documented exception.")
		elif documented_exception:
			stale_exception_count += 1
			failures.append("Documented exception is now under budget and can be removed: %s" % path)
			_print_warning(path, line_count, budget, "Documented exception is now under budget and can be removed.")

		var entry := {
			"path": path,
			"line_count": line_count,
			"budget": budget,
			"ratchet_baseline": ratchet_baseline,
			"over_budget": over_budget,
			"documented_exception": documented_exception,
		}
		entries.append(entry)

	for exception_path in DOCUMENTED_EXCEPTIONS.keys():
		if not scanned_paths.has(exception_path):
			failures.append("Documented exception path was not scanned: %s" % exception_path)
			_print_warning(exception_path, 0, _budget_for_path(exception_path), "Documented exception path was not scanned.")
	failures.append_array(_check_exception_doc())

	print(
		(
			"[ScriptBudget] scanned=%d over_budget=%d documented_exceptions=%d undocumented=%d stale_exceptions=%d ratchet_failures=%d"
			% [
				entries.size(),
				over_budget_count,
				documented_count,
				undocumented_count,
				stale_exception_count,
				ratchet_failure_count,
			]
		)
	)
	return {
		"passed": failures.is_empty(),
		"scanned": entries.size(),
		"over_budget": over_budget_count,
		"documented_exceptions": documented_count,
		"undocumented": undocumented_count,
		"stale_exceptions": stale_exception_count,
		"ratchet_failures": ratchet_failure_count,
		"entries": entries,
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
			if _should_skip_directory(entry_name):
				continue
			_collect_script_paths(entry_path, paths)
		elif _should_scan_script(entry_name):
			paths.append(entry_path)
	dir.list_dir_end()


static func _should_skip_directory(directory_name: String) -> bool:
	return directory_name == "tests"


static func _should_scan_script(file_name: String) -> bool:
	if not file_name.ends_with(".gd"):
		return false
	if file_name.ends_with("_test.gd") or file_name.ends_with("_probe.gd"):
		return false
	return true


static func _line_count(path: String) -> int:
	var source := FileAccess.get_file_as_string(path)
	if source.is_empty():
		return 0
	var count := 0
	for line in source.split("\n"):
		var trimmed_line := String(line).strip_edges()
		if trimmed_line == "" or trimmed_line.begins_with("#"):
			continue
		count += 1
	return count


static func _budget_for_path(path: String) -> int:
	var file_name := path.get_file()
	if file_name.ends_with("_controller.gd"):
		return CONTROLLER_BUDGET
	if file_name.ends_with("_view.gd"):
		return VIEW_BUDGET
	return DEFAULT_BUDGET


static func _ratchet_baseline_for_path(path: String) -> int:
	var exception: Dictionary = DOCUMENTED_EXCEPTIONS.get(path, {})
	return int(exception.get("baseline", 0))


static func _ratchet_failure_message(path: String, line_count: int, baseline: int) -> String:
	if baseline <= 0:
		return "Documented exception is missing a ratchet baseline: %s" % path
	if line_count > baseline:
		return "Script exceeds ratchet baseline: %s lines=%d baseline=%d" % [path, line_count, baseline]
	if line_count < baseline:
		return "Script is below ratchet baseline; lower the checked-in baseline: %s lines=%d baseline=%d" % [path, line_count, baseline]
	return ""


static func _check_exception_doc() -> Array[String]:
	var failures: Array[String] = []
	var doc_source := FileAccess.get_file_as_string(DOC_PATH)
	if doc_source.is_empty():
		_print_warning(DOC_PATH, 0, 0, "Script size exception document is missing or empty.")
		failures.append("Script size exception document is missing or empty: %s" % DOC_PATH)
		return failures
	for exception_path in DOCUMENTED_EXCEPTIONS.keys():
		var repo_path := String(exception_path).trim_prefix("res://")
		if not doc_source.contains(repo_path):
			_print_warning(exception_path, 0, _budget_for_path(exception_path), "Documented exception is missing from %s." % DOC_PATH)
			failures.append("Documented exception is missing from %s: %s" % [DOC_PATH, repo_path])
	return failures


static func _print_documented_exception(path: String, line_count: int, budget: int) -> void:
	var exception: Dictionary = DOCUMENTED_EXCEPTIONS.get(path, {})
	var baseline := int(exception.get("baseline", 0))
	var message := (
		"Documented exception: lines=%d budget=%d baseline=%d. %s"
		% [
			line_count,
			budget,
			baseline,
			String(exception.get("reason", "")),
		]
	)
	print("::warning file=%s,line=1,title=Script size budget::%s" % [path.trim_prefix("res://"), message])
	print(
		(
			"[ScriptBudget][exception] %s lines=%d budget=%d baseline=%d owner=%s reason=%s"
			% [
				path,
				line_count,
				budget,
				baseline,
				String(exception.get("owner", "")),
				String(exception.get("reason", "")),
			]
		)
	)


static func _print_warning(path: String, line_count: int, budget: int, message: String) -> void:
	var warning := "%s lines=%d budget=%d. See %s" % [message, line_count, budget, DOC_PATH]
	print("::warning file=%s,line=1,title=Script size budget::%s" % [path.trim_prefix("res://"), warning])
	push_warning("%s %s" % [path, warning])
