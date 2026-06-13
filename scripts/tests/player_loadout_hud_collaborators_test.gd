extends RefCounted
class_name PlayerLoadoutHudCollaboratorsTest

const HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const HUD_LAYOUT_SCRIPT := preload("res://scripts/ui/player_loadout_hud_layout.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("facade_lazily_binds_typed_collaborators", _test_facade_lazily_binds_typed_collaborators, failures)
	_run_case("slot_detail_probe_stays_public", _test_slot_detail_probe_stays_public, failures)
	_run_case("intent_preview_reads_visible_armor", _test_intent_preview_reads_visible_armor, failures)
	_run_case("compact_footer_keeps_readable_label_floors", _test_compact_footer_keeps_readable_label_floors, failures)
	_run_case("facade_layout_helpers_convert_parent_space", _test_facade_layout_helpers_convert_parent_space, failures)
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


func _test_facade_lazily_binds_typed_collaborators() -> String:
	var hud: Variant = HUD_SCRIPT.new()
	if hud._mastery_panel() == null:
		return "Expected PlayerLoadoutHud to bind a typed mastery panel collaborator."
	if hud._intent_preview() == null:
		return "Expected PlayerLoadoutHud to bind a typed intent preview collaborator."
	if hud._slot_detail_popover() == null:
		return "Expected PlayerLoadoutHud to bind a typed slot detail popover collaborator."
	return ""


func _test_slot_detail_probe_stays_public() -> String:
	var snapshot: Dictionary = HUD_SCRIPT.slot_detail_popover_probe_snapshot()
	if int(snapshot.get("min_width", 0)) != 440:
		return "Expected slot detail min width probe to remain unchanged."
	if int(snapshot.get("max_width", 0)) != 640:
		return "Expected slot detail max width probe to remain unchanged."
	return ""


func _test_intent_preview_reads_visible_armor() -> String:
	var hud: Variant = HUD_SCRIPT.new()
	hud._player_data = {"display_values": {"current_armor": 7}}
	if hud._current_visible_armor() != 7:
		return "Expected intent collaborator to read display armor through the facade."
	return ""


func _test_compact_footer_keeps_readable_label_floors() -> String:
	var nodes := {
		"footer_panel": Control.new(),
		"equipment_label": Label.new(),
		"consumable_label": Label.new(),
		"relic_label": Label.new(),
		"hp_label": Label.new(),
	}
	(nodes["footer_panel"] as Control).size = HUD_LAYOUT_SCRIPT.COMPACT_COMBAT_PLAYER_PANEL_SIZE

	HUD_LAYOUT_SCRIPT.apply_player_footer_layout(nodes)

	var expected: Dictionary = HUD_LAYOUT_SCRIPT.player_footer_font_probe(true)
	for key in expected.keys():
		var label := nodes.get(key) as Label
		if label == null:
			_free_nodes(nodes)
			return "Expected label fixture for %s." % key
		var font_size := label.get_theme_font_size("font_size")
		if font_size < int(expected.get(key, 0)):
			_free_nodes(nodes)
			return "Expected %s font size to stay readable, got %d." % [key, font_size]
	_free_nodes(nodes)
	return ""


func _test_facade_layout_helpers_convert_parent_space() -> String:
	var hud: Variant = HUD_SCRIPT.new()
	var root := Control.new()
	root.position = Vector2(70.0, 90.0)
	root.size = Vector2(640.0, 480.0)
	var parent := Control.new()
	parent.position = Vector2(50.0, 60.0)
	parent.size = Vector2(400.0, 300.0)
	root.add_child(parent)

	var local_rect: Rect2 = hud._to_parent_rect(Rect2(Vector2(130.0, 170.0), Vector2(80.0, 40.0)), parent)
	if not _rect_equal(local_rect, Rect2(Vector2(10.0, 20.0), Vector2(80.0, 40.0))):
		root.free()
		return "Expected HUD facade to convert global popover anchors into parent-local coordinates."

	var target := Control.new()
	hud._apply_rect(target, Rect2(Vector2(12.0, 14.0), Vector2(160.0, 36.0)))
	if target.position != Vector2(12.0, 14.0) or target.size != Vector2(160.0, 36.0) or target.custom_minimum_size != Vector2(160.0, 36.0):
		root.free()
		target.free()
		return "Expected HUD facade to apply popover child rects through the layout helper."
	root.free()
	target.free()
	return ""


func _free_nodes(nodes: Dictionary) -> void:
	for value in nodes.values():
		if value is Node:
			(value as Node).free()


func _rect_equal(left: Rect2, right: Rect2) -> bool:
	return left.position.is_equal_approx(right.position) and left.size.is_equal_approx(right.size)
