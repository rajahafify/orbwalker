extends RefCounted

const LAYOUT_PRESENTER_PATH := "res://scripts/combat/combat_layout_presenter.gd"


static func run_probe(print_summary: bool = true) -> Dictionary:
	var layout_presenter_script: Variant = _load_layout_presenter_script()
	if layout_presenter_script == null or not layout_presenter_script.has_method("build_layout_probe"):
		return {
			"probe_id": "mobile-combat-layout-probe",
			"result_count": 0,
			"results": [],
			"error": "layout_presenter_script_unavailable",
		}
	var cases := [
		{"name": "mobile_1080x1920", "viewport": Vector2(1080, 1920)},
		{"name": "tall_portrait_1080x2400", "viewport": Vector2(1080, 2400)},
		{"name": "smaller_portrait_900x1600", "viewport": Vector2(900, 1600)},
	]
	var results: Array = []
	for case_entry in cases:
		var case_name := String(case_entry.get("name", "unknown"))
		var viewport: Vector2 = case_entry.get("viewport", Vector2.ZERO)
		var probe: Dictionary = layout_presenter_script.build_layout_probe(viewport)
		var zone_rects: Dictionary = probe.get("zone_rects", {})
		var readability: Dictionary = probe.get("readability", {})
		(
			results
			. append(
				{
					"name": case_name,
					"viewport": viewport,
					"layout_root_size": probe.get("layout_root_size", Vector2.ZERO),
					"scale_factor": float(probe.get("scale_factor", 0.0)),
					"board_size": probe.get("board_size", Vector2.ZERO),
					"zone_rects": zone_rects,
					"overlap_count": int(probe.get("overlap_count", int(Array(probe.get("overlaps", [])).size()))),
					"overlaps": probe.get("overlaps", []),
					"overlaps_primary": probe.get("overlaps_primary", []),
					"overlaps_player_hud_internals": probe.get("overlaps_player_hud_internals", []),
					"overlaps_readability": probe.get("overlaps_readability", []),
					"overlaps_readability_actionable": probe.get("overlaps_readability_actionable", []),
					"readability": readability,
					"readability_all_pass": bool(readability.get("all_pass", false)),
					"readability_passing_count": int(readability.get("passing_count", 0)),
					"readability_required_count": int(readability.get("required_count", 0)),
					"readability_font_all_pass": bool(readability.get("font_all_pass", false)),
					"readability_font_passing_count": int(readability.get("font_passing_count", 0)),
					"readability_font_required_count": int(readability.get("font_required_count", 0)),
					"primary_zones": zone_rects.get("primary", {}),
					"readability_zones": zone_rects.get("readability", {}),
					"mobile_focus_zones":
					{
						"top_segments": zone_rects.get("readability", {}).get("top_segments", Rect2()),
						"enemy_name": zone_rects.get("readability", {}).get("enemy_name", Rect2()),
						"enemy_hp": zone_rects.get("readability", {}).get("enemy_hp", Rect2()),
						"primary_intent_badge": zone_rects.get("readability", {}).get("primary_intent_badge", Rect2()),
						"timer": zone_rects.get("readability", {}).get("timer", Rect2()),
						"board": zone_rects.get("readability", {}).get("board", Rect2()),
						"mastery_rail": zone_rects.get("readability", {}).get("mastery_rail", Rect2()),
						"hero_vitals": zone_rects.get("readability", {}).get("hero_vitals", Rect2()),
						"relic_rail": zone_rects.get("readability", {}).get("relic_rail", Rect2()),
						"equipment_rail": zone_rects.get("readability", {}).get("equipment_rail", Rect2()),
						"consumable_rail": zone_rects.get("readability", {}).get("consumable_rail", Rect2()),
						"outcome_overlay": zone_rects.get("readability", {}).get("outcome_overlay", Rect2()),
					},
				}
			)
		)
	var summary := {
		"probe_id": "mobile-combat-layout-probe",
		"result_count": results.size(),
		"results": results,
	}
	if print_summary:
		print("[Mobile Layout Probe] %s" % JSON.stringify(summary))
	return summary


static func run_all() -> Dictionary:
	var report := run_probe(false)
	var failures: Array[String] = []
	if report.has("error"):
		failures.append("Mobile combat layout probe error: %s" % String(report.get("error", "")))
	var results := Array(report.get("results", []))
	if results.size() != 3:
		failures.append("Expected 3 mobile combat layout probe cases, got %d" % results.size())
	for result in results:
		var case_name := String(result.get("name", "unknown"))
		if int(result.get("overlap_count", -1)) != 0:
			failures.append("%s reported primary overlaps" % case_name)
		if not Array(result.get("overlaps_readability_actionable", [])).is_empty():
			failures.append("%s reported actionable readability overlaps" % case_name)
		if not bool(result.get("readability_all_pass", false)):
			failures.append("%s failed readability minimums" % case_name)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


static func _load_layout_presenter_script() -> Variant:
	return ResourceLoader.load(LAYOUT_PRESENTER_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
