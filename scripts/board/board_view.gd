extends Control
class_name BoardView

@export var cell_spacing: float = 6.0
@export var board_padding: float = 12.0
@export var cell_background: Color = Color("#1e232b")
@export var board_background: Color = Color("#12161c")

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
			draw_circle(rect.get_center(), cell_size * 0.33, orb_color)


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
