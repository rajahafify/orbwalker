extends RefCounted
class_name BoardResolverIntegrationTest

const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_service.gd")
var _resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("horizontal_line_detection", _test_horizontal_line_detection, failures)
	_run_case("vertical_line_detection", _test_vertical_line_detection, failures)
	_run_case("l_shape_detection", _test_l_shape_detection, failures)
	_run_case("t_shape_detection_and_clear_once", _test_t_shape_detection_and_clear_once, failures)
	_run_case("no_diagonal_match", _test_no_diagonal_match, failures)
	_run_case("gravity_preserves_column_order", _test_gravity_preserves_column_order, failures)
	_run_case("refill_fills_all_empties", _test_refill_fills_all_empties, failures)
	_run_case("cascade_generates_multiple_passes", _test_cascade_generates_multiple_passes, failures)

	return {
		"passed": failures.is_empty(),
		"total": 8,
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


func _test_horizontal_line_detection() -> String:
	var board := _board_from_rows([
		"FFFIA",
		"IAEHG",
		"EHGIA",
		"GAEHI",
		"HIAEG",
		"AEGIH",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.total_combos < 1:
		return "Expected at least 1 combo in first pass."
	var first_group: Dictionary = result.passes[0].groups[0]
	if first_group.orb_id != OrbType.Id.FIRE:
		return "Expected first group orb type Fire."
	if first_group.cells.size() < 3:
		return "Expected horizontal line to include at least 3 cells."
	return ""


func _test_vertical_line_detection() -> String:
	var board := _board_from_rows([
		"FIAGE",
		"FIHAE",
		"FGEAI",
		"AHIEG",
		"EGAHI",
		"IAEHG",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.total_combos < 1:
		return "Expected at least 1 combo for vertical line."
	var has_fire_column := false
	for group in result.passes[0].groups:
		if group.orb_id == OrbType.Id.FIRE and group.cells.size() >= 3:
			has_fire_column = true
			break
	if not has_fire_column:
		return "Expected a vertical Fire match."
	return ""


func _test_l_shape_detection() -> String:
	var board := _board_from_rows([
		"FFFIA",
		"FIAEH",
		"FGEAI",
		"AHIEG",
		"EGAHI",
		"IAEHG",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.total_combos < 1:
		return "Expected at least 1 combo for L shape."
	var found_l_group := false
	for group in result.passes[0].groups:
		if group.orb_id == OrbType.Id.FIRE and group.cells.size() == 5:
			found_l_group = true
			break
	if not found_l_group:
		return "Expected a merged Fire L-shape group of 5 cells."
	return ""


func _test_t_shape_detection_and_clear_once() -> String:
	var board := _board_from_rows([
		"IFIAE",
		"FFFHG",
		"IFGAH",
		"AEHIG",
		"HIAEG",
		"EGAHI",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.total_combos < 1:
		return "Expected at least 1 combo for T shape."

	var first_pass: Dictionary = result.passes[0]
	var found_t_group := false
	for group in first_pass.groups:
		if group.orb_id == OrbType.Id.FIRE and group.cells.size() == 5:
			found_t_group = true
			break
	if not found_t_group:
		return "Expected merged Fire T-shape group with 5 cells."
	if first_pass.cleared_cells.size() < 5:
		return "Expected at least 5 cleared cells in first pass."
	return ""


func _test_no_diagonal_match() -> String:
	var board := _board_from_rows([
		"FAEHG",
		"IFAEH",
		"EIAGH",
		"HEGIA",
		"AGEHI",
		"GHAEI",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.total_combos != 0:
		return "Diagonal-only alignment should not produce a combo."
	return ""


func _test_gravity_preserves_column_order() -> String:
	var board := _board_from_rows([
		"AIEHG",
		"HAGEI",
		"IFAHG",
		"FGAEI",
		"FHIAG",
		"FGEHA",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.passes.is_empty():
		return "Expected a pass to test gravity."

	# Column 0 starts as A,H,I,F,F,F and clears bottom FFF. Remaining A,H,I must
	# appear in that same order after gravity at rows 3,4,5 respectively.
	var expected_after_gravity := [OrbType.Id.ARMOR, OrbType.Id.HEART, OrbType.Id.ICE]
	var actual := [
		board.get_cell(0, 3),
		board.get_cell(0, 4),
		board.get_cell(0, 5),
	]
	if actual[0] != expected_after_gravity[0] or actual[1] != expected_after_gravity[1] or actual[2] != expected_after_gravity[2]:
		return "Gravity did not preserve column order (expected A,H,I at rows 3..5)."
	return ""


func _test_refill_fills_all_empties() -> String:
	var board := _board_from_rows([
		"FFFIA",
		"HAGEI",
		"IFAHG",
		"EGAIH",
		"AHIGE",
		"GEAHI",
	])
	var result: Dictionary = _resolver.resolve_all(board, 1, false)
	if result.passes.is_empty():
		return "Expected at least one pass."
	if result.passes[0].refill_spawns.is_empty():
		return "Expected refill spawns after clear."
	for row in BoardModel.ROW_COUNT:
		for column in BoardModel.COLUMN_COUNT:
			if board.get_cell(column, row) == BoardModel.EMPTY_ORB_ID:
				return "Board contains empty cell after refill."
	return ""


func _test_cascade_generates_multiple_passes() -> String:
	var board := _board_from_rows([
		"HAGEI",
		"AHGEF",
		"IGAHE",
		"FIIAG",
		"FAHGF",
		"FIIEA",
	])
	var result: Dictionary = _resolver.resolve_all(board, 8)
	if result.passes.size() < 2:
		return "Expected cascade to produce at least 2 passes."
	return ""


func _board_from_rows(rows: Array[String]) -> BoardModel:
	if rows.size() != BoardModel.ROW_COUNT:
		push_error("BoardResolverIntegrationTest expected %d rows, got %d." % [BoardModel.ROW_COUNT, rows.size()])

	var board := BoardModel.new()
	board.initialize(123456)
	for row in rows.size():
		var row_text := rows[row]
		if row_text.length() != BoardModel.COLUMN_COUNT:
			push_error("BoardResolverIntegrationTest row %d has invalid width %d." % [row, row_text.length()])
			continue
		for column in BoardModel.COLUMN_COUNT:
			var symbol := row_text.substr(column, 1)
			var orb_id := _char_to_orb_id(symbol)
			if orb_id == BoardModel.EMPTY_ORB_ID:
				board.clear_cell(column, row)
			else:
				board.set_cell(column, row, orb_id)
	return board


func _char_to_orb_id(symbol: String) -> int:
	match symbol:
		"F":
			return OrbType.Id.FIRE
		"I":
			return OrbType.Id.ICE
		"E":
			return OrbType.Id.EARTH
		"H":
			return OrbType.Id.HEART
		"A":
			return OrbType.Id.ARMOR
		"G":
			return OrbType.Id.GOLD
		".":
			return BoardModel.EMPTY_ORB_ID
		_:
			push_error("Unsupported board test character: %s" % symbol)
			return OrbType.Id.FIRE
