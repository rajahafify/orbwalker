extends Control
class_name BoardView

@export var cell_spacing: float = 6.0
@export var board_padding: float = 12.0
@export var cell_background: Color = Color("#1e232b")
@export var board_background: Color = Color("#12161c")
@export var selected_cell_color: Color = Color("#f7f2a6")
@export var path_cell_color: Color = Color("#cfd7ff")

var selected_cell: Vector2i = Vector2i(-1, -1):
	set(value):
		selected_cell = value
		queue_redraw()

var path_cells: Array[Vector2i] = []:
	set(value):
		path_cells = value
		queue_redraw()

var drag_pointer_position: Vector2 = Vector2.ZERO:
	set(value):
		drag_pointer_position = value
		queue_redraw()

var drag_orb_id: int = -1:
	set(value):
		drag_orb_id = value
		queue_redraw()

var board_state: BoardState = null:
	set(value):
		board_state = value
		queue_redraw()


func _ready() -> void:
	resized.connect(queue_redraw)


func _draw() -> void:
	var board_rect := _calculate_board_rect()
	draw_rect(board_rect.grow(board_padding), board_background)

	if board_state == null:
		return

	var cell_size := _cell_size_for_rect(board_rect)
	var cell_radius := cell_size * 0.33
	for row in BoardState.ROW_COUNT:
		for column in BoardState.COLUMN_COUNT:
			var pos := board_rect.position + Vector2(
				column * (cell_size + cell_spacing),
				row * (cell_size + cell_spacing)
			)
			var rect := Rect2(pos, Vector2(cell_size, cell_size))
			draw_rect(rect, cell_background)

			var orb_id := board_state.get_cell(column, row)
			var orb_color := OrbType.color(orb_id)
			var is_selected_cell := selected_cell == Vector2i(column, row) and drag_orb_id >= 0
			if not is_selected_cell:
				draw_circle(rect.get_center(), cell_radius, orb_color)

			if selected_cell == Vector2i(column, row):
				draw_rect(rect.grow(-2.0), selected_cell_color, false, 2.0)
			elif Vector2i(column, row) in path_cells:
				draw_rect(rect.grow(-3.0), path_cell_color, false, 1.0)

	if drag_orb_id >= 0:
		draw_circle(drag_pointer_position, cell_radius, OrbType.color(drag_orb_id))


func board_position_to_cell(board_local_position: Vector2) -> Vector2i:
	var board_rect := _calculate_board_rect()
	if not board_rect.has_point(board_local_position):
		return Vector2i(-1, -1)

	var cell_size := _cell_size_for_rect(board_rect)
	var stride := cell_size + cell_spacing
	var local := board_local_position - board_rect.position
	var column := int(floor(local.x / stride))
	var row := int(floor(local.y / stride))

	if not _is_cell_index_valid(column, row):
		return Vector2i(-1, -1)

	var cell_origin := board_rect.position + Vector2(column * stride, row * stride)
	var within_cell := Rect2(cell_origin, Vector2(cell_size, cell_size))
	if not within_cell.has_point(board_local_position):
		return Vector2i(-1, -1)

	return Vector2i(column, row)


func is_cell_valid(cell: Vector2i) -> bool:
	return _is_cell_index_valid(cell.x, cell.y)


func get_cell_center(cell: Vector2i) -> Vector2:
	var board_rect := _calculate_board_rect()
	var cell_size := _cell_size_for_rect(board_rect)
	var stride := cell_size + cell_spacing
	return board_rect.position + Vector2(
		cell.x * stride + cell_size * 0.5,
		cell.y * stride + cell_size * 0.5
	)


func _calculate_board_rect() -> Rect2:
	var available := Rect2(
		Vector2(board_padding, board_padding),
		size - Vector2(board_padding * 2.0, board_padding * 2.0)
	)
	var cell_size := _cell_size_for_rect(available)
	var board_size := Vector2(
		BoardState.COLUMN_COUNT * cell_size + (BoardState.COLUMN_COUNT - 1) * cell_spacing,
		BoardState.ROW_COUNT * cell_size + (BoardState.ROW_COUNT - 1) * cell_spacing
	)
	var board_pos := available.position + (available.size - board_size) * 0.5
	return Rect2(board_pos, board_size)


func _cell_size_for_rect(rect: Rect2) -> float:
	var width_cell_size := (rect.size.x - (BoardState.COLUMN_COUNT - 1) * cell_spacing) / BoardState.COLUMN_COUNT
	var height_cell_size := (rect.size.y - (BoardState.ROW_COUNT - 1) * cell_spacing) / BoardState.ROW_COUNT
	return maxf(8.0, minf(width_cell_size, height_cell_size))


func _is_cell_index_valid(column: int, row: int) -> bool:
	return column >= 0 and column < BoardState.COLUMN_COUNT and row >= 0 and row < BoardState.ROW_COUNT
