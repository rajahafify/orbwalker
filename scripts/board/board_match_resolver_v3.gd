extends RefCounted
class_name BoardMatchResolverV3

signal match_found(groups: Array)
signal cells_cleared(cells: Array)
signal gravity_applied(fall_moves: Array)
signal refill_applied(refill_spawns: Array)
signal cascade_step_complete(step_index: int, total_combos: int)
signal resolve_complete(result: Dictionary)


func get_match_groups(board_model: BoardModel) -> Array[Dictionary]:
	return _find_match_groups(board_model)


func resolve_all(board_model: BoardModel, max_steps: int = 64) -> Dictionary:
	var result := {
		"total_combos": 0,
		"matched_counts": {},
		"passes": [],
	}

	for orb_id in OrbType.ALL_TYPES:
		result.matched_counts[orb_id] = 0

	for step_index in max_steps:
		var groups: Array[Dictionary] = _find_match_groups(board_model)
		if groups.is_empty():
			break

		match_found.emit(groups)
		result.total_combos += groups.size()
		for group in groups:
			result.matched_counts[group.orb_id] += group.cells.size()

		var cleared_cells: Array[Vector2i] = _clear_groups(board_model, groups)
		cells_cleared.emit(cleared_cells)

		var fall_moves: Array[Dictionary] = _apply_gravity(board_model)
		gravity_applied.emit(fall_moves)

		var refill_spawns: Array[Dictionary] = _refill_empty_cells(board_model)
		refill_applied.emit(refill_spawns)

		result.passes.append({
			"step_index": step_index,
			"groups": groups,
			"cleared_cells": cleared_cells,
			"fall_moves": fall_moves,
			"refill_spawns": refill_spawns,
		})

		cascade_step_complete.emit(step_index, result.total_combos)

	if result.passes.size() >= max_steps:
		push_warning("BoardMatchResolverV3 hit max_steps=%d before stabilizing." % max_steps)

	resolve_complete.emit(result)
	return result


func _find_match_groups(board_model: BoardModel) -> Array[Dictionary]:
	var line_cells_by_orb: Dictionary = _collect_line_match_cells(board_model)
	var groups: Array[Dictionary] = []

	for orb_id in OrbType.ALL_TYPES:
		var orb_line_cells: Dictionary = line_cells_by_orb.get(orb_id, {})
		if orb_line_cells.is_empty():
			continue

		var visited := {}
		for cell_index_variant in orb_line_cells.keys():
			var cell_index: int = int(cell_index_variant)
			if visited.has(cell_index):
				continue

			var component_indices: PackedInt32Array = _collect_component_indices(
				orb_line_cells,
				cell_index,
				visited
			)
			if component_indices.size() < 3:
				continue

			var component_cells: Array[Vector2i] = []
			for index in component_indices:
				component_cells.append(_coords(index))

			groups.append({
				"orb_id": orb_id,
				"cells": component_cells,
			})

	return groups


func _collect_line_match_cells(board_model: BoardModel) -> Dictionary:
	var line_cells_by_orb := {}
	for orb_id in OrbType.ALL_TYPES:
		line_cells_by_orb[orb_id] = {}

	for row in BoardModel.ROW_COUNT:
		var run_orb := board_model.get_cell(0, row)
		var run_start := 0
		var run_length := 1
		for column in range(1, BoardModel.COLUMN_COUNT):
			var next_orb := board_model.get_cell(column, row)
			if next_orb == run_orb and OrbType.is_valid_id(run_orb):
				run_length += 1
				continue
			_add_horizontal_run_if_match(line_cells_by_orb, run_orb, row, run_start, run_length)
			run_orb = next_orb
			run_start = column
			run_length = 1
		_add_horizontal_run_if_match(line_cells_by_orb, run_orb, row, run_start, run_length)

	for column in BoardModel.COLUMN_COUNT:
		var run_orb := board_model.get_cell(column, 0)
		var run_start := 0
		var run_length := 1
		for row in range(1, BoardModel.ROW_COUNT):
			var next_orb := board_model.get_cell(column, row)
			if next_orb == run_orb and OrbType.is_valid_id(run_orb):
				run_length += 1
				continue
			_add_vertical_run_if_match(line_cells_by_orb, run_orb, column, run_start, run_length)
			run_orb = next_orb
			run_start = row
			run_length = 1
		_add_vertical_run_if_match(line_cells_by_orb, run_orb, column, run_start, run_length)

	return line_cells_by_orb


func _add_horizontal_run_if_match(
	line_cells_by_orb: Dictionary,
	orb_id: int,
	row: int,
	start_column: int,
	run_length: int
) -> void:
	if run_length < 3 or not OrbType.is_valid_id(orb_id):
		return

	var target_cells: Dictionary = line_cells_by_orb[orb_id]
	for column in range(start_column, start_column + run_length):
		target_cells[_index(column, row)] = true


func _add_vertical_run_if_match(
	line_cells_by_orb: Dictionary,
	orb_id: int,
	column: int,
	start_row: int,
	run_length: int
) -> void:
	if run_length < 3 or not OrbType.is_valid_id(orb_id):
		return

	var target_cells: Dictionary = line_cells_by_orb[orb_id]
	for row in range(start_row, start_row + run_length):
		target_cells[_index(column, row)] = true


func _collect_component_indices(cells: Dictionary, start_index: int, visited: Dictionary) -> PackedInt32Array:
	var stack := PackedInt32Array([start_index])
	var component := PackedInt32Array()
	var cursor := 0
	visited[start_index] = true

	while cursor < stack.size():
		var current: int = stack[cursor]
		cursor += 1
		component.append(current)

		var x: int = current % BoardModel.COLUMN_COUNT
		var y: int = floori(float(current) / float(BoardModel.COLUMN_COUNT))
		_try_push_neighbor_index(cells, _index(x - 1, y), x > 0, visited, stack)
		_try_push_neighbor_index(cells, _index(x + 1, y), x < BoardModel.COLUMN_COUNT - 1, visited, stack)
		_try_push_neighbor_index(cells, _index(x, y - 1), y > 0, visited, stack)
		_try_push_neighbor_index(cells, _index(x, y + 1), y < BoardModel.ROW_COUNT - 1, visited, stack)

	return component


func _try_push_neighbor_index(
	cells: Dictionary,
	neighbor_index: int,
	is_valid: bool,
	visited: Dictionary,
	stack: PackedInt32Array
) -> void:
	if not is_valid or not cells.has(neighbor_index) or visited.has(neighbor_index):
		return
	visited[neighbor_index] = true
	stack.append(neighbor_index)


func _clear_groups(board_model: BoardModel, groups: Array[Dictionary]) -> Array[Vector2i]:
	var unique_cells := {}
	for group in groups:
		for cell in group.cells:
			unique_cells[_index(cell.x, cell.y)] = true

	var cleared_cells: Array[Vector2i] = []
	for index_variant in unique_cells.keys():
		var index: int = int(index_variant)
		var cell := _coords(index)
		board_model.clear_cell(cell.x, cell.y)
		cleared_cells.append(cell)
	return cleared_cells


func _apply_gravity(board_model: BoardModel) -> Array[Dictionary]:
	var fall_moves: Array[Dictionary] = []

	for column in BoardModel.COLUMN_COUNT:
		var write_row := BoardModel.ROW_COUNT - 1
		for row in range(BoardModel.ROW_COUNT - 1, -1, -1):
			var orb_id := board_model.get_cell(column, row)
			if orb_id == BoardModel.EMPTY_ORB_ID:
				continue

			if write_row != row:
				board_model.set_cell(column, write_row, orb_id)
				board_model.clear_cell(column, row)
				fall_moves.append({
					"orb_id": orb_id,
					"from": Vector2i(column, row),
					"to": Vector2i(column, write_row),
				})
			write_row -= 1

		for clear_row in range(write_row, -1, -1):
			board_model.clear_cell(column, clear_row)

	return fall_moves


func _refill_empty_cells(board_model: BoardModel) -> Array[Dictionary]:
	var refill_spawns: Array[Dictionary] = []

	for column in BoardModel.COLUMN_COUNT:
		for row in BoardModel.ROW_COUNT:
			if board_model.get_cell(column, row) != BoardModel.EMPTY_ORB_ID:
				continue

			var spawned_orb := board_model.roll_random_orb()
			board_model.set_cell(column, row, spawned_orb)
			refill_spawns.append({
				"orb_id": spawned_orb,
				"to": Vector2i(column, row),
			})

	return refill_spawns


func _index(column: int, row: int) -> int:
	return row * BoardModel.COLUMN_COUNT + column


func _coords(index: int) -> Vector2i:
	return Vector2i(
		index % BoardModel.COLUMN_COUNT,
		floori(float(index) / float(BoardModel.COLUMN_COUNT))
	)
