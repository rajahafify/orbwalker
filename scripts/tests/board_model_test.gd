extends RefCounted
class_name BoardModelTest

const BOARD_VIEW_GEOMETRY := preload("res://scripts/board/board_view_geometry.gd")
const BOARD_VIEW_OVERLAY_MOTION := preload("res://scripts/board/board_view_overlay_motion.gd")
const BOARD_VIEW_TUTORIAL_PATH_SAMPLER := preload("res://scripts/board/board_view_tutorial_path_sampler.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("initialize_is_deterministic_and_match_free", _test_initialize_is_deterministic_and_match_free, failures)
	_run_case("cell_bounds_set_clear_and_swap", _test_cell_bounds_set_clear_and_swap, failures)
	_run_case("clone_is_independent", _test_clone_is_independent, failures)
	_run_case("debug_string_marks_empty_cells", _test_debug_string_marks_empty_cells, failures)
	_run_case("board_view_geometry_projects_cells_and_gaps", _test_board_view_geometry_projects_cells_and_gaps, failures)
	_run_case("board_view_drop_motion_overshoots_and_settles", _test_board_view_drop_motion_overshoots_and_settles, failures)
	_run_case("board_view_tutorial_path_sampler_skips_zero_segments", _test_board_view_tutorial_path_sampler_skips_zero_segments, failures)

	return {
		"passed": failures.is_empty(),
		"total": 7,
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


func _test_board_view_geometry_projects_cells_and_gaps() -> String:
	var view_size := Vector2(700.0, 620.0)
	var padding := 12.0
	var spacing := 6.0
	var rect: Rect2 = BOARD_VIEW_GEOMETRY.board_rect(view_size, padding, spacing)
	var cell_size: float = BOARD_VIEW_GEOMETRY.cell_size_for_rect(rect, spacing)
	var center: Vector2 = BOARD_VIEW_GEOMETRY.cell_center(Vector2i(2, 3), view_size, padding, spacing)
	if BOARD_VIEW_GEOMETRY.position_to_cell(center, view_size, padding, spacing) != Vector2i(2, 3):
		return "Expected cell center to project back to the same board cell."
	var gap_position := center + Vector2(cell_size * 0.5 + spacing * 0.5, 0.0)
	if BOARD_VIEW_GEOMETRY.position_to_cell(gap_position, view_size, padding, spacing) != Vector2i(-1, -1):
		return "Expected spacing gap between cells not to project to a cell."
	if BOARD_VIEW_GEOMETRY.cell_index(2, 3) != 3 * BoardModel.COLUMN_COUNT + 2:
		return "Expected stable row-major board cell index."
	return ""


func _test_board_view_drop_motion_overshoots_and_settles() -> String:
	var from_pos := Vector2(0.0, 0.0)
	var to_pos := Vector2(0.0, 100.0)
	var linear_mid: Vector2 = BOARD_VIEW_OVERLAY_MOTION.overlay_position(from_pos, to_pos, 0.5, "linear", 18.0)
	var overshoot_peak: Vector2 = BOARD_VIEW_OVERLAY_MOTION.overlay_position(from_pos, to_pos, 0.76, "drop_overshoot", 18.0)
	var settled: Vector2 = BOARD_VIEW_OVERLAY_MOTION.overlay_position(from_pos, to_pos, 1.0, "drop_overshoot", 18.0)
	if not is_equal_approx(linear_mid.y, 50.0):
		return "Expected non-drop overlay motion to remain linear."
	if overshoot_peak.y <= to_pos.y:
		return "Expected drop overlay motion to overshoot past the target cell."
	if settled.distance_to(to_pos) > 0.01:
		return "Expected drop overlay motion to settle back on the target cell."
	return ""


func _test_board_view_tutorial_path_sampler_skips_zero_segments() -> String:
	var points: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO, Vector2(0.0, 20.0), Vector2(20.0, 20.0)]
	var sample: Dictionary = BOARD_VIEW_TUTORIAL_PATH_SAMPLER.sample_path(points, 25.0)
	var position: Vector2 = sample.get("position", Vector2.ZERO)
	var direction: Vector2 = sample.get("direction", Vector2.ZERO)
	if position.distance_to(Vector2(5.0, 20.0)) > 0.01:
		return "Expected sampler to advance across non-zero path segments."
	if direction.distance_to(Vector2.RIGHT) > 0.01:
		return "Expected sampler direction to match the active segment."
	return ""
