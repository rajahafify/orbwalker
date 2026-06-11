extends RefCounted
class_name PlayerLoadoutMasterySourceHighlighterTest

const HIGHLIGHTER_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_source_highlighter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("highlights_matching_equipment_and_lists_sources", _test_highlights_matching_equipment_and_lists_sources, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
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


func _test_highlights_matching_equipment_and_lists_sources() -> String:
	var equipment_row := Control.new()
	var relic_row := Control.new()
	var equipment_slot := Control.new()
	equipment_slot.set_meta("content_type", "equipment")
	equipment_slot.set_meta("content_id", "ember_ring")
	equipment_row.add_child(equipment_slot)

	var highlighter = HIGHLIGHTER_SCRIPT.new()
	highlighter.bind_hud_nodes({"equipment_icons": equipment_row, "relic_icons": relic_row})
	highlighter.add_highlight(equipment_slot, Vector2(98, 98))
	(
		highlighter
		. set_hover_payload(
			{
				"combat_modifiers":
				{
					"sources":
					[
						{
							"source_type": "equipment",
							"source_id": "ember_ring",
							"display_name": "Ember Ring",
							"combat_modifiers": {"flat_damage_bonus": 2},
						},
					],
				},
			}
		)
	)
	highlighter.set_highlights_for_orb(OrbType.Id.FIRE)
	var highlight := equipment_slot.get_node_or_null("MasterySourceHighlight") as Panel
	if highlight == null or not highlight.visible:
		return "Expected matching equipment source highlight to become visible."
	if highlighter.source_lines(OrbType.Id.FIRE) != ["Ember Ring"]:
		return "Expected matching source display name in mastery source lines."
	highlighter.clear_highlights()
	if highlight.visible:
		return "Expected clear_highlights to hide the source highlight."
	return ""
