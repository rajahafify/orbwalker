extends RefCounted
class_name BoardModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("initialize_is_deterministic_and_match_free", _test_initialize_is_deterministic_and_match_free, failures)
	_run_case("cell_bounds_set_clear_and_swap", _test_cell_bounds_set_clear_and_swap, failures)
	_run_case("clone_is_independent", _test_clone_is_independent, failures)
	_run_case("debug_string_marks_empty_cells", _test_debug_string_marks_empty_cells, failures)
	_run_case("board_view_drop_motion_overshoots_and_settles", _test_board_view_drop_motion_overshoots_and_settles, failures)

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


func _test_initialize_is_deterministic_and_match_free() -> String:
	var first := BoardModel.new()
	var second := BoardModel.new()
	first.initialize(12345)
	second.initialize(12345)
	if first.has_any_match():
		return "Expected generated board to start without automatic matches."
	if first.to_debug_string() != second.to_debug_string():
		return "Expected same seed to generate the same board."
	if first.to_debug_string().split("\n").size() != BoardModel.ROW_COUNT:
		return "Expected debug string to include one line per row."
	return ""


func _test_cell_bounds_set_clear_and_swap() -> String:
	var model := BoardModel.new()
	if not model.in_bounds(0, 0):
		return "Expected origin to be in bounds."
	if model.in_bounds(BoardModel.COLUMN_COUNT, 0):
		return "Expected column past edge to be out of bounds."
	model.set_cell(0, 0, OrbType.Id.FIRE)
	model.set_cell(1, 0, OrbType.Id.ICE)
	if model.get_cell(0, 0) != OrbType.Id.FIRE or model.get_cell(1, 0) != OrbType.Id.ICE:
		return "Expected set_cell to store orb ids."
	if not model.swap_cells(0, 0, 1, 0):
		return "Expected in-bounds swap to succeed."
	if model.get_cell(0, 0) != OrbType.Id.ICE or model.get_cell(1, 0) != OrbType.Id.FIRE:
		return "Expected swap_cells to exchange values."
	model.clear_cell(1, 0)
	if not model.is_cell_empty(1, 0):
		return "Expected clear_cell to mark the cell empty."
	return ""


func _test_clone_is_independent() -> String:
	var model := BoardModel.new()
	model.initialize(77)
	var copy: BoardModel = model.clone()
	if copy.to_debug_string() != model.to_debug_string():
		return "Expected clone to copy cell contents."
	copy.set_cell(0, 0, OrbType.Id.GOLD)
	if model.get_cell(0, 0) == OrbType.Id.GOLD:
		return "Expected clone mutation not to alter original board."
	return ""


func _test_debug_string_marks_empty_cells() -> String:
	var model := BoardModel.new()
	model.clear_cell(0, 0)
	var debug_text := model.to_debug_string()
	if not debug_text.begins_with("."):
		return "Expected empty origin to render as '.' in debug string."
	return ""


func _test_board_view_drop_motion_overshoots_and_settles() -> String:
	var board_view_script := ResourceLoader.load("res://scripts/board/board_view.gd", "", ResourceLoader.CACHE_MODE_IGNORE)
	var board_view = board_view_script.new()
	var from_pos := Vector2(0.0, 0.0)
	var to_pos := Vector2(0.0, 100.0)
	var linear_mid: Vector2 = board_view._overlay_orb_position(from_pos, to_pos, 0.5, "linear")
	var overshoot_peak: Vector2 = board_view._overlay_orb_position(from_pos, to_pos, 0.76, "drop_overshoot")
	var settled: Vector2 = board_view._overlay_orb_position(from_pos, to_pos, 1.0, "drop_overshoot")
	if not is_equal_approx(linear_mid.y, 50.0):
		board_view.free()
		return "Expected non-drop overlay motion to remain linear."
	if overshoot_peak.y <= to_pos.y:
		board_view.free()
		return "Expected drop overlay motion to overshoot past the target cell."
	if settled.distance_to(to_pos) > 0.01:
		board_view.free()
		return "Expected drop overlay motion to settle back on the target cell."
	board_view.free()
	return ""
