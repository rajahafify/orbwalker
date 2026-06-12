extends RefCounted
class_name BoardViewGeometry


static func board_rect(view_size: Vector2, board_padding: float, cell_spacing: float) -> Rect2:
	var available := Rect2(Vector2(board_padding, board_padding), view_size - Vector2(board_padding * 2.0, board_padding * 2.0))
	var cell_size := cell_size_for_rect(available, cell_spacing)
	var board_size := Vector2(
		BoardModel.COLUMN_COUNT * cell_size + (BoardModel.COLUMN_COUNT - 1) * cell_spacing,
		BoardModel.ROW_COUNT * cell_size + (BoardModel.ROW_COUNT - 1) * cell_spacing
	)
	var board_pos := available.position + (available.size - board_size) * 0.5
	return Rect2(board_pos, board_size)


static func cell_size_for_rect(rect: Rect2, cell_spacing: float) -> float:
	var width_cell_size := (rect.size.x - (BoardModel.COLUMN_COUNT - 1) * cell_spacing) / BoardModel.COLUMN_COUNT
	var height_cell_size := (rect.size.y - (BoardModel.ROW_COUNT - 1) * cell_spacing) / BoardModel.ROW_COUNT
	return maxf(8.0, minf(width_cell_size, height_cell_size))


static func cell_rect(column: int, row: int, board_rect_value: Rect2, cell_size: float, cell_spacing: float) -> Rect2:
	var pos := board_rect_value.position + Vector2(column * (cell_size + cell_spacing), row * (cell_size + cell_spacing))
	return Rect2(pos, Vector2(cell_size, cell_size))


static func position_to_cell(board_local_position: Vector2, view_size: Vector2, board_padding: float, cell_spacing: float) -> Vector2i:
	var rect := board_rect(view_size, board_padding, cell_spacing)
	if not rect.has_point(board_local_position):
		return Vector2i(-1, -1)

	var cell_size := cell_size_for_rect(rect, cell_spacing)
	var stride := cell_size + cell_spacing
	var local := board_local_position - rect.position
	var column := int(floor(local.x / stride))
	var row := int(floor(local.y / stride))
	if not is_cell_index_valid(column, row):
		return Vector2i(-1, -1)

	var within_cell := cell_rect(column, row, rect, cell_size, cell_spacing)
	if not within_cell.has_point(board_local_position):
		return Vector2i(-1, -1)
	return Vector2i(column, row)


static func cell_center(cell: Vector2i, view_size: Vector2, board_padding: float, cell_spacing: float) -> Vector2:
	var rect := board_rect(view_size, board_padding, cell_spacing)
	var cell_size := cell_size_for_rect(rect, cell_spacing)
	return cell_center_from_float_row(cell.x, float(cell.y), rect, cell_size, cell_spacing)


static func float_row_cell_center(column: int, row: float, view_size: Vector2, board_padding: float, cell_spacing: float) -> Vector2:
	var rect := board_rect(view_size, board_padding, cell_spacing)
	var cell_size := cell_size_for_rect(rect, cell_spacing)
	return cell_center_from_float_row(column, row, rect, cell_size, cell_spacing)


static func cell_center_from_float_row(column: int, row: float, board_rect_value: Rect2, cell_size: float, cell_spacing: float) -> Vector2:
	var stride := cell_size + cell_spacing
	return board_rect_value.position + Vector2(column * stride + cell_size * 0.5, row * stride + cell_size * 0.5)


static func is_cell_index_valid(column: int, row: int) -> bool:
	return column >= 0 and column < BoardModel.COLUMN_COUNT and row >= 0 and row < BoardModel.ROW_COUNT


static func cell_index(column: int, row: int) -> int:
	return row * BoardModel.COLUMN_COUNT + column
