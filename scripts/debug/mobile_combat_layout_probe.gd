extends RefCounted

const LAYOUT_MANAGER_PATH := "res://scripts/combat/combat_layout_manager.gd"


static func run_probe() -> Dictionary:
	var layout_manager_script: Variant = _load_layout_manager_script()
	if layout_manager_script == null or not layout_manager_script.has_method("build_layout_probe"):
		return {
			"probe_id": "mobile-combat-layout-probe",
			"result_count": 0,
			"results": [],
			"error": "layout_manager_script_unavailable",
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
		var probe: Dictionary = layout_manager_script.build_layout_probe(viewport)
		var zone_rects: Dictionary = probe.get("zone_rects", {})
		var readability: Dictionary = probe.get("readability", {})
		results.append({
			"name": case_name,
			"viewport": viewport,
			"layout_root_size": probe.get("layout_root_size", Vector2.ZERO),
			"scale_factor": float(probe.get("scale_factor", 0.0)),
			"board_surface_size": probe.get("board_surface_size", Vector2.ZERO),
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
			"primary_zones": zone_rects.get("primary", {}),
			"readability_zones": zone_rects.get("readability", {}),
			"mobile_focus_zones": {
				"top_segments": zone_rects.get("readability", {}).get("top_segments", Rect2()),
				"enemy_name": zone_rects.get("readability", {}).get("enemy_name", Rect2()),
				"enemy_hp": zone_rects.get("readability", {}).get("enemy_hp", Rect2()),
				"primary_intent_badge": zone_rects.get("readability", {}).get("primary_intent_badge", Rect2()),
				"timer": zone_rects.get("readability", {}).get("timer", Rect2()),
				"board_surface": zone_rects.get("readability", {}).get("board_surface", Rect2()),
				"mastery_rail": zone_rects.get("readability", {}).get("mastery_rail", Rect2()),
				"hero_vitals": zone_rects.get("readability", {}).get("hero_vitals", Rect2()),
				"relic_rail": zone_rects.get("readability", {}).get("relic_rail", Rect2()),
				"equipment_rail": zone_rects.get("readability", {}).get("equipment_rail", Rect2()),
				"consumable_rail": zone_rects.get("readability", {}).get("consumable_rail", Rect2()),
				"outcome_overlay": zone_rects.get("readability", {}).get("outcome_overlay", Rect2()),
			},
		})
	var summary := {
		"probe_id": "mobile-combat-layout-probe",
		"result_count": results.size(),
		"results": results,
	}
	print("[Mobile Layout Probe] %s" % JSON.stringify(summary))
	return summary


static func _load_layout_manager_script() -> Variant:
	return ResourceLoader.load(
		LAYOUT_MANAGER_PATH,
		"",
		ResourceLoader.CACHE_MODE_IGNORE
	)
