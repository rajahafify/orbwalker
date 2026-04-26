extends Control
class_name BoardView

@export var cell_spacing: float = 6.0
@export var board_padding: float = 12.0
@export var cell_background: Color = Color("#1e232b")
@export var board_background: Color = Color("#12161c")
@export var selected_cell_color: Color = Color("#f7f2a6")
@export var path_cell_color: Color = Color("#cfd7ff")
@export var match_flash_color: Color = Color(1.0, 1.0, 1.0, 0.28)
@export var glow_halo_scale: float = 1.42
@export var glow_halo_alpha: float = 0.30
@export var glow_core_alpha: float = 0.20
@export var glow_core_brightness_add: float = 0.30

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

var _flash_cells: Dictionary = {}
var _glow_cells: Dictionary = {} # cell index -> true
var _overlay_orbs: Array[Dictionary] = []
var _suppressed_cells: Dictionary = {}


func _ready() -> void:
	resized.connect(queue_redraw)
	set_process(true)


func _process(delta: float) -> void:
	var changed: bool = false

	var flash_keys: Array = _flash_cells.keys()
	for cell_index_variant in flash_keys:
		var cell_index: int = int(cell_index_variant)
		var remaining: float = float(_flash_cells[cell_index]) - delta
		if remaining <= 0.0:
			_flash_cells.erase(cell_index)
		else:
			_flash_cells[cell_index] = remaining
		changed = true

	var overlay_index: int = _overlay_orbs.size() - 1
	while overlay_index >= 0:
		var overlay: Dictionary = _overlay_orbs[overlay_index]
		var elapsed: float = float(overlay.elapsed) + delta
		overlay.elapsed = elapsed
		_overlay_orbs[overlay_index] = overlay
		if elapsed >= float(overlay.duration):
			_release_suppressed_cells(PackedInt32Array(overlay.suppress_indices))
			_overlay_orbs.remove_at(overlay_index)
		changed = true
		overlay_index -= 1

	if changed:
		queue_redraw()


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
			var cell_index: int = _cell_index(column, row)
			var is_selected_cell := selected_cell == Vector2i(column, row) and drag_orb_id >= 0
			var is_suppressed: bool = _suppressed_cells.has(cell_index)
			if not is_selected_cell and not is_suppressed and OrbType.is_valid_id(orb_id):
				var orb_color := OrbType.color(orb_id)
				draw_circle(rect.get_center(), cell_radius, orb_color)

			if selected_cell == Vector2i(column, row):
				draw_rect(rect.grow(-2.0), selected_cell_color, false, 2.0)
			elif Vector2i(column, row) in path_cells:
				draw_rect(rect.grow(-3.0), path_cell_color, false, 1.0)

			if _flash_cells.has(cell_index):
				draw_rect(rect.grow(-4.0), match_flash_color)

			if _glow_cells.has(cell_index):
				# Shiny orb-specific glow: soft colored halo + brighter core tint.
				var base_glow_color := OrbType.color(orb_id)
				var halo_color := base_glow_color
				halo_color.a = glow_halo_alpha
				draw_circle(rect.get_center(), cell_radius * glow_halo_scale, halo_color)

				var core_glow_color := Color(
					clampf(base_glow_color.r + glow_core_brightness_add, 0.0, 1.0),
					clampf(base_glow_color.g + glow_core_brightness_add, 0.0, 1.0),
					clampf(base_glow_color.b + glow_core_brightness_add, 0.0, 1.0),
					glow_core_alpha
				)
				draw_circle(rect.get_center(), cell_radius * 1.02, core_glow_color)

	for overlay in _overlay_orbs:
		var duration: float = maxf(0.001, float(overlay.duration))
		var elapsed: float = float(overlay.elapsed)
		var t: float = clampf(elapsed / duration, 0.0, 1.0)
		var from_pos: Vector2 = overlay.from_pos
		var to_pos: Vector2 = overlay.to_pos
		var orb_pos: Vector2 = from_pos.lerp(to_pos, t)
		var start_alpha: float = float(overlay.start_alpha)
		var end_alpha: float = float(overlay.end_alpha)
		var alpha: float = lerpf(start_alpha, end_alpha, t)
		var start_scale: float = float(overlay.start_scale)
		var end_scale: float = float(overlay.end_scale)
		var orb_scale: float = lerpf(start_scale, end_scale, t)
		var orb_id: int = int(overlay.orb_id)
		if not OrbType.is_valid_id(orb_id):
			continue
		var orb_color := OrbType.color(orb_id)
		orb_color.a = alpha
		draw_circle(orb_pos, cell_radius * orb_scale, orb_color)

	if drag_orb_id >= 0:
		draw_circle(drag_pointer_position, cell_radius, OrbType.color(drag_orb_id))


func clear_animations() -> void:
	_flash_cells.clear()
	_glow_cells.clear()
	_overlay_orbs.clear()
	_suppressed_cells.clear()
	queue_redraw()


func has_active_animations() -> bool:
	return not _overlay_orbs.is_empty() or not _flash_cells.is_empty()


func set_live_match_glow(groups: Array) -> void:
	_glow_cells.clear()
	for group in groups:
		for cell in group.cells:
			if not _is_cell_index_valid(cell.x, cell.y):
				continue
			var cell_index: int = _cell_index(cell.x, cell.y)
			_glow_cells[cell_index] = true
	queue_redraw()


func clear_match_glow() -> void:
	_glow_cells.clear()
	queue_redraw()


func animate_swap(from_cell: Vector2i, to_cell: Vector2i, from_orb_id: int, to_orb_id: int, duration: float = 0.08) -> void:
	if not _is_cell_index_valid(from_cell.x, from_cell.y) or not _is_cell_index_valid(to_cell.x, to_cell.y):
		return
	if OrbType.is_valid_id(from_orb_id):
		_add_overlay_orb(
			from_orb_id,
			get_cell_center(from_cell),
			get_cell_center(to_cell),
			duration,
			1.0,
			1.0,
			1.0,
			1.0,
			PackedInt32Array([_cell_index(from_cell.x, from_cell.y), _cell_index(to_cell.x, to_cell.y)])
		)
	if OrbType.is_valid_id(to_orb_id):
		_add_overlay_orb(
			to_orb_id,
			get_cell_center(to_cell),
			get_cell_center(from_cell),
			duration,
			1.0,
			1.0,
			1.0,
			1.0,
			PackedInt32Array([_cell_index(from_cell.x, from_cell.y), _cell_index(to_cell.x, to_cell.y)])
		)


func flash_match_groups(groups: Array, duration: float = 0.12) -> void:
	for group in groups:
		for cell in group.cells:
			if not _is_cell_index_valid(cell.x, cell.y):
				continue
			var cell_index: int = _cell_index(cell.x, cell.y)
			var previous: float = float(_flash_cells.get(cell_index, 0.0))
			_flash_cells[cell_index] = maxf(previous, duration)
	queue_redraw()


func animate_clear_groups(groups: Array, duration: float = 0.12) -> void:
	for group in groups:
		var orb_id: int = int(group.orb_id)
		if not OrbType.is_valid_id(orb_id):
			continue
		for cell in group.cells:
			if not _is_cell_index_valid(cell.x, cell.y):
				continue
			var center: Vector2 = get_cell_center(cell)
			_add_overlay_orb(
				orb_id,
				center,
				center,
				duration,
				1.0,
				0.0,
				1.0,
				0.25,
				PackedInt32Array([_cell_index(cell.x, cell.y)])
			)


func animate_fall_moves(fall_moves: Array, duration: float = 0.14) -> void:
	for move in fall_moves:
		var orb_id: int = int(move.orb_id)
		if not OrbType.is_valid_id(orb_id):
			continue
		var from_cell: Vector2i = move.from
		var to_cell: Vector2i = move.to
		if not _is_cell_index_valid(from_cell.x, from_cell.y) or not _is_cell_index_valid(to_cell.x, to_cell.y):
			continue
		_add_overlay_orb(
			orb_id,
			get_cell_center(from_cell),
			get_cell_center(to_cell),
			duration,
			1.0,
			1.0,
			1.0,
			1.0,
			PackedInt32Array([_cell_index(from_cell.x, from_cell.y), _cell_index(to_cell.x, to_cell.y)])
		)


func animate_refill_spawns(refill_spawns: Array, duration: float = 0.14) -> void:
	for spawn in refill_spawns:
		var orb_id: int = int(spawn.orb_id)
		if not OrbType.is_valid_id(orb_id):
			continue
		var to_cell: Vector2i = spawn.to
		if not _is_cell_index_valid(to_cell.x, to_cell.y):
			continue
		_add_overlay_orb(
			orb_id,
			_cell_center_from_float_row(to_cell.x, -1.0),
			get_cell_center(to_cell),
			duration,
			1.0,
			1.0,
			1.0,
			1.0,
			PackedInt32Array([_cell_index(to_cell.x, to_cell.y)])
		)


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


func _cell_center_from_float_row(column: int, row: float) -> Vector2:
	var board_rect := _calculate_board_rect()
	var cell_size := _cell_size_for_rect(board_rect)
	var stride := cell_size + cell_spacing
	return board_rect.position + Vector2(
		column * stride + cell_size * 0.5,
		row * stride + cell_size * 0.5
	)


func _cell_index(column: int, row: int) -> int:
	return row * BoardState.COLUMN_COUNT + column


func _add_overlay_orb(
	orb_id: int,
	from_pos: Vector2,
	to_pos: Vector2,
	duration: float,
	start_alpha: float,
	end_alpha: float,
	start_scale: float,
	end_scale: float,
	suppress_indices: PackedInt32Array
) -> void:
	for cell_index in suppress_indices:
		var previous_count: int = int(_suppressed_cells.get(cell_index, 0))
		_suppressed_cells[cell_index] = previous_count + 1

	_overlay_orbs.append({
		"orb_id": orb_id,
		"from_pos": from_pos,
		"to_pos": to_pos,
		"duration": maxf(0.01, duration),
		"elapsed": 0.0,
		"start_alpha": start_alpha,
		"end_alpha": end_alpha,
		"start_scale": start_scale,
		"end_scale": end_scale,
		"suppress_indices": suppress_indices,
	})
	queue_redraw()


func _release_suppressed_cells(suppress_indices: PackedInt32Array) -> void:
	for cell_index in suppress_indices:
		if not _suppressed_cells.has(cell_index):
			continue
		var remaining: int = int(_suppressed_cells[cell_index]) - 1
		if remaining <= 0:
			_suppressed_cells.erase(cell_index)
		else:
			_suppressed_cells[cell_index] = remaining
