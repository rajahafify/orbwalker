extends RefCounted
class_name PlayerLoadoutHudCollaboratorsTest

const HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("facade_lazily_binds_typed_collaborators", _test_facade_lazily_binds_typed_collaborators, failures)
	_run_case("slot_detail_probe_stays_public", _test_slot_detail_probe_stays_public, failures)
	_run_case("intent_preview_reads_visible_armor", _test_intent_preview_reads_visible_armor, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
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
