extends RefCounted
class_name LayoutSnapshotHarness

const COMBAT_LAYOUT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_layout_presenter.gd")
const SHOP_VIEW_SCRIPT := preload("res://scripts/shop/shop_view.gd")
const MAIN_MENU_VIEW_SCRIPT := preload("res://scripts/main_menu/main_menu_view.gd")

const GOLDEN_PATH := "res://tools/qa/layout_golden_rects.json"
const BASE_VIEWPORT := Vector2(1080, 1920)
const TOLERANCE_PX := 0.01


static func current_snapshots() -> Dictionary:
	return {
		"schema_version": 1,
		"tolerance_px": TOLERANCE_PX,
		"snapshots": {
			"combat_1080x1920": _combat_snapshot(BASE_VIEWPORT),
			"shop_1080x1920": _shop_snapshot(BASE_VIEWPORT),
			"main_menu_1080x1920": _main_menu_snapshot(BASE_VIEWPORT),
		},
	}


static func load_golden(golden_path: String = GOLDEN_PATH) -> Dictionary:
	if not FileAccess.file_exists(golden_path):
		return {"__error": "Expected layout golden file to exist: %s." % golden_path}
	var file := FileAccess.open(golden_path, FileAccess.READ)
	if file == null:
		return {"__error": "Expected layout golden file to open: %s." % golden_path}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"__error": "Expected layout golden file to parse as a Dictionary: %s." % golden_path}
	return parsed


static func compare_to_golden(golden_path: String = GOLDEN_PATH) -> Dictionary:
	var golden := load_golden(golden_path)
	if golden.has("__error"):
		return {
			"passed": false,
			"failures": [String(golden["__error"])],
			"actual": current_snapshots(),
			"golden": golden,
			"tolerance_px": TOLERANCE_PX,
		}
	var actual := current_snapshots()
	var failures: Array[String] = []
	var tolerance := float(golden.get("tolerance_px", TOLERANCE_PX))
	_compare_value("snapshots", actual.get("snapshots", {}), golden.get("snapshots", {}), tolerance, failures)
	return {
		"passed": failures.is_empty(),
		"failures": failures,
		"actual": actual,
		"golden": golden,
		"tolerance_px": tolerance,
	}


static func _combat_snapshot(viewport_size: Vector2) -> Dictionary:
	var probe: Dictionary = COMBAT_LAYOUT_PRESENTER_SCRIPT.build_layout_probe(viewport_size)
	var primary: Dictionary = Dictionary(probe.get("zone_rects", {})).get("primary", {})
	var readability: Dictionary = Dictionary(probe.get("zone_rects", {})).get("readability", {})
	return {
		"viewport_size": _vector_array(viewport_size),
		"layout_root_size": _vector_array(probe.get("layout_root_size", Vector2.ZERO)),
		"scale_factor": _round_number(float(probe.get("scale_factor", 0.0))),
		"rects": {
			"top_bar": _rect_array(primary.get("top_bar", Rect2())),
			"enemy_panel": _rect_array(primary.get("enemy_panel", Rect2())),
			"combat_strip": _rect_array(primary.get("combat_strip", Rect2())),
			"board_panel": _rect_array(primary.get("board_panel", Rect2())),
			"player_hud_section": _rect_array(primary.get("player_hud_section", Rect2())),
			"board": _rect_array(readability.get("board", Rect2())),
			"timer": _rect_array(readability.get("timer", Rect2())),
			"hero_vitals": _rect_array(readability.get("hero_vitals", Rect2())),
		},
	}


static func _shop_snapshot(viewport_size: Vector2) -> Dictionary:
	var probe: Dictionary = SHOP_VIEW_SCRIPT.shop_layout_probe_snapshot()
	return {
		"viewport_size": _vector_array(viewport_size),
		"layout_mode": String(probe.get("layout_mode", "")),
		"rects": {
			"top_bar": _rect_array(probe.get("top_bar", Rect2())),
			"merchant_stage": _rect_array(probe.get("merchant_stage", Rect2())),
			"stock_panel": _rect_array(probe.get("stock_panel", Rect2())),
			"offer_grid": _rect_array(probe.get("offer_grid", Rect2())),
			"relic_panel": _rect_array(probe.get("relic_panel", Rect2())),
			"action_row": _rect_array(probe.get("action_row", Rect2())),
			"player_hud_section": _rect_array(probe.get("player_hud_section", Rect2())),
		},
	}


static func _main_menu_snapshot(viewport_size: Vector2) -> Dictionary:
	var probe: Dictionary = MAIN_MENU_VIEW_SCRIPT.layout_probe_snapshot(viewport_size)
	return {
		"viewport_size": _vector_array(viewport_size),
		"rects": {
			"safe_rect": _rect_array(probe.get("safe_rect", Rect2())),
			"logo": _rect_array(probe.get("logo", Rect2())),
			"menu_button_column": _rect_array(probe.get("menu_button_column", Rect2())),
			"element_row": _rect_array(probe.get("element_row", Rect2())),
			"stats_panel": _rect_array(probe.get("stats_panel", Rect2())),
			"stats_row": _rect_array(probe.get("stats_row", Rect2())),
			"footer_actions": _rect_array(probe.get("footer_actions", Rect2())),
			"status_label": _rect_array(probe.get("status_label", Rect2())),
		},
		"metrics": {
			"menu_button_min_height": int(probe.get("menu_button_min_height", 0)),
			"element_icon_size": int(probe.get("element_icon_size", 0)),
			"stat_icon_size": int(probe.get("stat_icon_size", 0)),
			"footer_icon_max_width": int(probe.get("footer_icon_max_width", 0)),
		},
	}


static func _compare_value(path: String, actual: Variant, golden: Variant, tolerance: float, failures: Array[String]) -> void:
	if actual is Dictionary and golden is Dictionary:
		_compare_dictionaries(path, actual, golden, tolerance, failures)
	elif actual is Array and golden is Array:
		_compare_arrays(path, actual, golden, tolerance, failures)
	elif _is_number(actual) and _is_number(golden):
		if absf(float(actual) - float(golden)) > tolerance:
			failures.append("%s expected %.3f, got %.3f" % [path, float(golden), float(actual)])
	elif actual != golden:
		failures.append("%s expected %s, got %s" % [path, str(golden), str(actual)])


static func _compare_dictionaries(path: String, actual: Dictionary, golden: Dictionary, tolerance: float, failures: Array[String]) -> void:
	for key in golden.keys():
		if not actual.has(key):
			failures.append("%s.%s missing from current snapshot" % [path, String(key)])
			continue
		_compare_value("%s.%s" % [path, String(key)], actual[key], golden[key], tolerance, failures)
	for key in actual.keys():
		if not golden.has(key):
			failures.append("%s.%s missing from golden snapshot" % [path, String(key)])


static func _compare_arrays(path: String, actual: Array, golden: Array, tolerance: float, failures: Array[String]) -> void:
	if actual.size() != golden.size():
		failures.append("%s expected %d values, got %d" % [path, golden.size(), actual.size()])
		return
	for index in range(golden.size()):
		_compare_value("%s[%d]" % [path, index], actual[index], golden[index], tolerance, failures)


static func _rect_array(rect_value: Variant) -> Array:
	if not (rect_value is Rect2):
		return []
	var rect: Rect2 = rect_value
	return [
		_round_number(rect.position.x),
		_round_number(rect.position.y),
		_round_number(rect.size.x),
		_round_number(rect.size.y),
	]


static func _vector_array(vector_value: Variant) -> Array:
	if not (vector_value is Vector2):
		return []
	var value: Vector2 = vector_value
	return [
		_round_number(value.x),
		_round_number(value.y),
	]


static func _round_number(value: float) -> float:
	return round(value * 1000.0) / 1000.0


static func _is_number(value: Variant) -> bool:
	return value is int or value is float
