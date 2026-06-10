extends RefCounted
class_name LayoutSnapshotHarnessTest

const LAYOUT_SNAPSHOT_HARNESS := preload("res://tools/qa/layout_snapshot_harness.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("layout_golden_file_covers_key_screens", _test_layout_golden_file_covers_key_screens, failures)
	_run_case("layout_golden_rects_match_current_probes", _test_layout_golden_rects_match_current_probes, failures)

	return {
		"passed": failures.is_empty(),
		"total": 2,
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


func _test_layout_golden_file_covers_key_screens() -> String:
	var golden: Dictionary = LAYOUT_SNAPSHOT_HARNESS.load_golden()
	if golden.has("__error"):
		return String(golden["__error"])
	var snapshots: Dictionary = golden.get("snapshots", {})
	var required_rects := {
		"combat_1080x1920": ["top_bar", "enemy_panel", "combat_strip", "board_panel", "player_hud_section", "board", "timer", "hero_vitals"],
		"shop_1080x1920": ["top_bar", "merchant_stage", "stock_panel", "offer_grid", "relic_panel", "action_row", "player_hud_section"],
		"main_menu_1080x1920": ["safe_rect", "logo", "menu_button_column", "element_row", "stats_panel", "stats_row", "footer_actions", "status_label"],
	}
	for screen_name in required_rects.keys():
		if not snapshots.has(screen_name):
			return "Expected layout golden to include %s." % String(screen_name)
		var screen: Dictionary = snapshots.get(screen_name, {})
		var rects: Dictionary = screen.get("rects", {})
		for rect_name in Array(required_rects[screen_name]):
			if not rects.has(rect_name):
				return "Expected layout golden %s to include rect %s." % [String(screen_name), String(rect_name)]
			var rect_value: Array = rects.get(rect_name, [])
			if rect_value.size() != 4:
				return "Expected layout golden %s.%s to store [x, y, w, h]." % [String(screen_name), String(rect_name)]
	return ""


func _test_layout_golden_rects_match_current_probes() -> String:
	var comparison: Dictionary = LAYOUT_SNAPSHOT_HARNESS.compare_to_golden()
	if bool(comparison.get("passed", false)):
		return ""
	var messages: Array[String] = []
	for failure in Array(comparison.get("failures", [])):
		messages.append(String(failure))
	return "; ".join(messages)
