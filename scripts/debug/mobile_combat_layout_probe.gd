extends RefCounted

const LAYOUT_MANAGER_SCRIPT := preload("res://scripts/combat/combat_layout_manager.gd")


static func run_probe() -> Dictionary:
	var cases := [
		{"name": "mobile_1080x1920", "viewport": Vector2(1080, 1920)},
		{"name": "tall_portrait_1080x2400", "viewport": Vector2(1080, 2400)},
		{"name": "smaller_portrait_900x1600", "viewport": Vector2(900, 1600)},
	]
	var results: Array = []
	for case_entry in cases:
		var case_name := String(case_entry.get("name", "unknown"))
		var viewport: Vector2 = case_entry.get("viewport", Vector2.ZERO)
		var probe: Dictionary = LAYOUT_MANAGER_SCRIPT.build_layout_probe(viewport)
		results.append({
			"name": case_name,
			"viewport": viewport,
			"layout_root_size": probe.get("layout_root_size", Vector2.ZERO),
			"scale_factor": float(probe.get("scale_factor", 0.0)),
			"board_surface_size": probe.get("board_surface_size", Vector2.ZERO),
			"zone_rects": probe.get("zone_rects", {}),
			"overlap_count": int(probe.get("overlap_count", int(Array(probe.get("overlaps", [])).size()))),
			"overlaps": probe.get("overlaps", []),
			"overlaps_primary": probe.get("overlaps_primary", []),
			"overlaps_player_hud_internals": probe.get("overlaps_player_hud_internals", []),
		})
	var summary := {
		"probe_id": "mobile-combat-layout-probe",
		"result_count": results.size(),
		"results": results,
	}
	print("[Mobile Layout Probe] %s" % JSON.stringify(summary))
	return summary
