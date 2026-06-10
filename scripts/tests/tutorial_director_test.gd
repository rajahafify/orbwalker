extends RefCounted
class_name TutorialDirectorTest

const DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("first_combat_steps_are_scripted", _test_first_combat_steps_are_scripted, failures)
	_run_case("inactive_context_has_no_step", _test_inactive_context_has_no_step, failures)
	_run_case("post_shop_modal_state_advances_and_dismisses", _test_post_shop_modal_state_advances_and_dismisses, failures)
	_run_case("drag_paths_are_copied_and_validated", _test_drag_paths_are_copied_and_validated, failures)

	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_first_combat_steps_are_scripted() -> String:
	var director: Variant = DIRECTOR_SCRIPT.new()
	var expected_steps: Array[String] = [
		DIRECTOR_SCRIPT.STEP_FIRST_SWAP,
		DIRECTOR_SCRIPT.STEP_ARMOR_BLOCK,
		DIRECTOR_SCRIPT.STEP_HEART_HEAL,
		DIRECTOR_SCRIPT.STEP_COMBO_FINISHER,
	]
	for index in expected_steps.size():
		var turn_index := index + 1
		var step: String = director.active_step(_context("enemy_1", turn_index))
		if step != expected_steps[index]:
			return "Expected turn %d to use %s, got %s." % [turn_index, expected_steps[index], step]
		if director.drag_path_for_step(step).is_empty():
			return "Expected turn %d step %s to expose a drag path." % [turn_index, step]
		if director.prompt_message(step) == "":
			return "Expected turn %d step %s to expose a prompt." % [turn_index, step]
	if director.active_step(_context("enemy_1", 5)) != DIRECTOR_SCRIPT.STEP_NONE:
		return "Expected first combat turn 5 to have no scripted step."
	return ""


func _test_inactive_context_has_no_step() -> String:
	var director: Variant = DIRECTOR_SCRIPT.new()
	var non_tutorial := _context("enemy_1", 1)
	non_tutorial["tutorial_run_active"] = false
	if director.active_step(non_tutorial) != DIRECTOR_SCRIPT.STEP_NONE:
		return "Expected non-tutorial context to have no step."
	var locked := _context("enemy_1", 1)
	locked["input_is_player_input"] = false
	if director.active_step(locked) != DIRECTOR_SCRIPT.STEP_NONE:
		return "Expected locked input context to have no step."
	var fight_over := _context("enemy_1", 1)
	fight_over["fight_over"] = true
	if director.active_step(fight_over) != DIRECTOR_SCRIPT.STEP_NONE:
		return "Expected completed fight context to have no step."
	return ""


func _test_post_shop_modal_state_advances_and_dismisses() -> String:
	var director: Variant = DIRECTOR_SCRIPT.new()
	var context := _context("enemy_2", 1, ["shortsword"])
	if director.active_step(context) != DIRECTOR_SCRIPT.STEP_SHOP_DAMAGE:
		return "Expected shortsword post-shop combat to expose the shop damage step."
	if director.post_shop_step() != DIRECTOR_SCRIPT.POST_SHOP_SHORTSWORD:
		return "Expected first post-shop modal step to be shortsword."
	if director.end_modal_status_text(director.post_shop_step()).find("Iron Shortsword") < 0:
		return "Expected shortsword modal status text."
	if director.advance_post_shop_step() != DIRECTOR_SCRIPT.POST_SHOP_MASTERY:
		return "Expected first continue to advance to mastery."
	if director.advance_post_shop_step() != DIRECTOR_SCRIPT.POST_SHOP_END:
		return "Expected second continue to advance to end."
	if director.advance_post_shop_step() != "":
		return "Expected third continue to dismiss the tutorial choice."
	if not director.end_choice_dismissed():
		return "Expected director to record dismissed end choice."
	if director.active_step(context) != DIRECTOR_SCRIPT.STEP_NONE:
		return "Expected dismissed tutorial end choice to hide the shop damage step."
	return ""


func _test_drag_paths_are_copied_and_validated() -> String:
	var director: Variant = DIRECTOR_SCRIPT.new()
	var expected_path: Array[Vector2i] = director.drag_path_for_step(DIRECTOR_SCRIPT.STEP_FIRST_SWAP)
	if expected_path.size() != 2:
		return "Expected first swap path to contain two cells."
	var mutated_path: Array[Vector2i] = expected_path.duplicate()
	mutated_path[0] = Vector2i(9, 9)
	var fresh_path: Array[Vector2i] = director.drag_path_for_step(DIRECTOR_SCRIPT.STEP_FIRST_SWAP)
	if fresh_path[0] == Vector2i(9, 9):
		return "Expected drag paths to be returned as copies."
	if not director.did_complete_drag_path(fresh_path, fresh_path):
		return "Expected matching paths to complete."
	if director.did_complete_drag_path([fresh_path[0]], fresh_path):
		return "Expected incomplete paths to fail."
	var wrong_path: Array[Vector2i] = fresh_path.duplicate()
	wrong_path[1] = Vector2i(9, 9)
	if director.did_complete_drag_path(wrong_path, fresh_path):
		return "Expected wrong paths to fail."
	return ""


func _context(step_key: String, turn_index: int, equipment_slots: Array = []) -> Dictionary:
	return {
		"tutorial_run_active": true,
		"fight_over": false,
		"input_is_player_input": true,
		"dungeon_level": 1,
		"step_key": step_key,
		"turn_index": turn_index,
		"progression_snapshot": {
			"equipment_slots": equipment_slots,
		},
	}
