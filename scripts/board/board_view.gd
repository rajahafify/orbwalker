extends Control
class_name BoardView

@export var cell_spacing: float = 6.0
@export var board_padding: float = 12.0
@export var cell_background: Color = Color("#1e232b")
@export var board_background: Color = Color("#12161c")
@export var cell_frame_texture: Texture2D
@export var cell_frame_tint: Color = Color(1.0, 1.0, 1.0, 0.88)
@export var orb_scale_in_cell: float = 0.74
@export var selected_cell_color: Color = Color("#f7f2a6")
@export var path_cell_color: Color = Color("#cfd7ff")
@export var drag_cell_socket_color: Color = Color(1.0, 0.86, 0.34, 0.16)
@export var drag_path_socket_color: Color = Color(0.78, 0.84, 1.0, 0.08)
@export var match_flash_color: Color = Color(1.0, 0.94, 0.48, 0.0)
@export var matched_orb_pulse_period: float = 1.35
@export var matched_orb_edge_glow_scale: float = 1.10
@export var matched_orb_glow_alpha: float = 1.0
@export var matched_orb_glow_brightness: float = 1.25
@export var locked_overlay_color: Color = Color(0.0, 0.0, 0.0, 0.72)
@export var locked_overlay_border_color: Color = Color(0.72, 0.86, 1.0, 0.58)
@export var falling_orb_overshoot_pixels: float = 18.0
@export var falling_orb_stretch: float = 0.12

const OVERLAY_MOTION_LINEAR := "linear"
const OVERLAY_MOTION_DROP_OVERSHOOT := "drop_overshoot"

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

var board_model: BoardModel = null:
	set(value):
		board_model = value
		queue_redraw()

var orb_texture_map: Dictionary = {}:
	set(value):
		orb_texture_map = value
		queue_redraw()

var _flash_cells: Dictionary = {}
var _glow_cells: Dictionary = {} # cell index -> true
var _tutorial_hint_cells: Array[Vector2i] = []
var _tutorial_hint_from: Vector2i = Vector2i(-1, -1)
var _tutorial_hint_to: Vector2i = Vector2i(-1, -1)
var _overlay_orbs: Array[Dictionary] = []
var _suppressed_cells: Dictionary = {}
var _glow_pulse_time: float = 0.0
var _input_enabled := true


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	resized.connect(queue_redraw)
	set_input_enabled(_input_enabled)
	set_process(true)


func _process(delta: float) -> void:
	var changed: bool = false

	if not _glow_cells.is_empty() or not _tutorial_hint_cells.is_empty():
		_glow_pulse_time += delta
		changed = true

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

	if board_model == null:
		return

	var cell_size := _cell_size_for_rect(board_rect)
	var cell_radius := cell_size * 0.5 * clampf(orb_scale_in_cell, 0.35, 1.0)
	for row in BoardModel.ROW_COUNT:
		for column in BoardModel.COLUMN_COUNT:
			var pos := board_rect.position + Vector2(
				column * (cell_size + cell_spacing),
				row * (cell_size + cell_spacing)
			)
			var rect := Rect2(pos, Vector2(cell_size, cell_size))
			draw_rect(rect, cell_background)
			if cell_frame_texture != null:
				draw_texture_rect(cell_frame_texture, rect, false, cell_frame_tint)

	for row in BoardModel.ROW_COUNT:
		for column in BoardModel.COLUMN_COUNT:
			var pos := board_rect.position + Vector2(
				column * (cell_size + cell_spacing),
				row * (cell_size + cell_spacing)
			)
			var rect := Rect2(pos, Vector2(cell_size, cell_size))
			var orb_id := board_model.get_cell(column, row)
			var cell_index: int = _cell_index(column, row)
			var is_selected_cell := selected_cell == Vector2i(column, row) and drag_orb_id >= 0
			var is_suppressed: bool = _suppressed_cells.has(cell_index)
			var is_glowing := _glow_cells.has(cell_index)
			if not is_selected_cell and not is_suppressed and OrbType.is_valid_id(orb_id):
				_draw_orb_sprite(rect.get_center(), cell_radius, orb_id, 1.0, is_glowing)

			if selected_cell == Vector2i(column, row):
				_draw_drag_cell_socket(rect.get_center(), cell_radius, drag_cell_socket_color)
			elif Vector2i(column, row) in path_cells:
				_draw_drag_cell_socket(rect.get_center(), cell_radius * 0.86, drag_path_socket_color)

			if _flash_cells.has(cell_index) and match_flash_color.a > 0.0:
				draw_rect(rect.grow(-4.0), match_flash_color)

	for overlay in _overlay_orbs:
		var duration: float = maxf(0.001, float(overlay.duration))
		var elapsed: float = float(overlay.elapsed)
		var t: float = clampf(elapsed / duration, 0.0, 1.0)
		var from_pos: Vector2 = overlay.from_pos
		var to_pos: Vector2 = overlay.to_pos
		var motion: String = String(overlay.get("motion", OVERLAY_MOTION_LINEAR))
		var orb_pos: Vector2 = _overlay_orb_position(from_pos, to_pos, t, motion)
		var start_alpha: float = float(overlay.start_alpha)
		var end_alpha: float = float(overlay.end_alpha)
		var alpha: float = lerpf(start_alpha, end_alpha, t)
		var start_scale: float = float(overlay.start_scale)
		var end_scale: float = float(overlay.end_scale)
		var orb_scale: float = lerpf(start_scale, end_scale, t)
		var stretch := _overlay_orb_stretch(t, motion)
		var orb_id: int = int(overlay.orb_id)
		if not OrbType.is_valid_id(orb_id):
			continue
		_draw_orb_sprite(orb_pos, cell_radius * orb_scale, orb_id, alpha, false, stretch)

	if drag_orb_id >= 0:
		_draw_orb_sprite(drag_pointer_position, cell_radius, drag_orb_id, 1.0, false)

	if not _input_enabled:
		_draw_locked_overlay(board_rect.grow(board_padding * 0.35))

	_draw_tutorial_focus_mask(board_rect, cell_size)
	_draw_tutorial_hint()


func clear_animations() -> void:
	_flash_cells.clear()
	_glow_cells.clear()
	_glow_pulse_time = 0.0
	_overlay_orbs.clear()
	_suppressed_cells.clear()
	queue_redraw()


func set_tutorial_hint(from_cell: Vector2i, to_cell: Vector2i, cells: Array[Vector2i] = []) -> void:
	_tutorial_hint_from = from_cell
	_tutorial_hint_to = to_cell
	_tutorial_hint_cells = cells.duplicate()
	if _tutorial_hint_cells.is_empty():
		_tutorial_hint_cells = [from_cell, to_cell]
	queue_redraw()


func clear_tutorial_hint() -> void:
	_tutorial_hint_cells.clear()
	_tutorial_hint_from = Vector2i(-1, -1)
	_tutorial_hint_to = Vector2i(-1, -1)
	queue_redraw()


func set_board_presentation_model(model: BoardModel) -> void:
	board_model = model


func bind_board_model(model: BoardModel) -> void:
	set_board_presentation_model(model)


func reset_drag_visual_state() -> void:
	selected_cell = Vector2i(-1, -1)
	path_cells = []
	drag_orb_id = -1
	drag_pointer_position = Vector2.ZERO


func update_drag_visual_state(selected: Vector2i, path: Array[Vector2i], pointer_position: Vector2, selected_orb_id: int) -> void:
	selected_cell = selected
	path_cells = path
	drag_pointer_position = pointer_position
	drag_orb_id = selected_orb_id


func clear_board_presentation() -> void:
	clear_animations()
	clear_match_glow()
	clear_tutorial_hint()
	reset_drag_visual_state()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	reset_drag_visual_state()
	queue_redraw()


func is_input_enabled() -> bool:
	return _input_enabled


func get_hover_orb_id(board_local_position: Vector2) -> int:
	return get_orb_id_at_position(board_local_position)


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
	_glow_pulse_time = 0.0
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
			PackedInt32Array([_cell_index(from_cell.x, from_cell.y), _cell_index(to_cell.x, to_cell.y)]),
			OVERLAY_MOTION_DROP_OVERSHOOT
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
			PackedInt32Array([_cell_index(to_cell.x, to_cell.y)]),
			OVERLAY_MOTION_DROP_OVERSHOOT
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


func get_orb_id_at_position(board_local_position: Vector2) -> int:
	var cell := board_position_to_cell(board_local_position)
	return get_orb_id_at_cell(cell)


func get_orb_id_at_cell(cell: Vector2i) -> int:
	if board_model == null:
		return -1
	if not is_cell_valid(cell):
		return -1
	return int(board_model.get_cell(cell.x, cell.y))


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
		BoardModel.COLUMN_COUNT * cell_size + (BoardModel.COLUMN_COUNT - 1) * cell_spacing,
		BoardModel.ROW_COUNT * cell_size + (BoardModel.ROW_COUNT - 1) * cell_spacing
	)
	var board_pos := available.position + (available.size - board_size) * 0.5
	return Rect2(board_pos, board_size)


func _cell_size_for_rect(rect: Rect2) -> float:
	var width_cell_size := (rect.size.x - (BoardModel.COLUMN_COUNT - 1) * cell_spacing) / BoardModel.COLUMN_COUNT
	var height_cell_size := (rect.size.y - (BoardModel.ROW_COUNT - 1) * cell_spacing) / BoardModel.ROW_COUNT
	return maxf(8.0, minf(width_cell_size, height_cell_size))


func _is_cell_index_valid(column: int, row: int) -> bool:
	return column >= 0 and column < BoardModel.COLUMN_COUNT and row >= 0 and row < BoardModel.ROW_COUNT


func _cell_center_from_float_row(column: int, row: float) -> Vector2:
	var board_rect := _calculate_board_rect()
	var cell_size := _cell_size_for_rect(board_rect)
	var stride := cell_size + cell_spacing
	return board_rect.position + Vector2(
		column * stride + cell_size * 0.5,
		row * stride + cell_size * 0.5
	)


func _cell_index(column: int, row: int) -> int:
	return row * BoardModel.COLUMN_COUNT + column


func set_orb_texture_map(texture_map: Dictionary) -> void:
	orb_texture_map = texture_map
	queue_redraw()


func _draw_orb_sprite(center: Vector2, radius: float, orb_id: int, alpha: float = 1.0, glowing: bool = false, stretch: Vector2 = Vector2.ONE) -> void:
	var texture: Texture2D = orb_texture_map.get(orb_id, null)
	var draw_radius_x := radius * maxf(0.1, stretch.x)
	var draw_radius_y := radius * maxf(0.1, stretch.y)
	if texture == null:
		var orb_color := OrbType.color(orb_id)
		orb_color.a = alpha
		draw_circle(center, minf(draw_radius_x, draw_radius_y), orb_color)
		return

	var sprite_size := Vector2(draw_radius_x * 2.0, draw_radius_y * 2.0)
	var rect := Rect2(center - sprite_size * 0.5, sprite_size)
	if glowing:
		var pulse_period: float = maxf(0.2, matched_orb_pulse_period)
		var pulse: float = 0.5 + 0.5 * sin((_glow_pulse_time / pulse_period) * TAU)

		var edge_scale: float = 1.0 + (matched_orb_edge_glow_scale - 1.0) * (0.35 + 0.65 * pulse)
		var edge_size := sprite_size * edge_scale
		var edge_rect := Rect2(center - edge_size * 0.5, edge_size)
		var edge_glow := OrbType.color(orb_id).lightened(0.82)
		edge_glow.a = matched_orb_glow_alpha * (0.34 + 0.46 * pulse) * alpha
		draw_texture_rect(texture, edge_rect, false, edge_glow)

		var brightness := 1.08 + matched_orb_glow_brightness * (0.35 + 0.65 * pulse)
		draw_texture_rect(texture, rect, false, Color(brightness, brightness, brightness, alpha))
		var inner_glow := OrbType.color(orb_id).lightened(0.86)
		inner_glow.a = matched_orb_glow_alpha * (0.34 + 0.50 * pulse) * alpha
		draw_texture_rect(texture, rect, false, inner_glow)
		var hot_core := Color(1.0, 0.96, 0.82, matched_orb_glow_alpha * (0.10 + 0.18 * pulse) * alpha)
		draw_texture_rect(texture, rect, false, hot_core)
	else:
		draw_texture_rect(texture, rect, false, Color(1.04, 1.03, 1.01, alpha))


func _draw_drag_cell_socket(center: Vector2, radius: float, fill_color: Color) -> void:
	if fill_color.a > 0.0:
		draw_circle(center, radius * 0.70, fill_color)


func _draw_tutorial_hint() -> void:
	if _tutorial_hint_cells.is_empty():
		return
	var pulse_period := 1.1
	var pulse := 0.5 + 0.5 * sin((_glow_pulse_time / pulse_period) * TAU)
	var board_rect := _calculate_board_rect()
	var cell_size := _cell_size_for_rect(board_rect)
	for cell in _tutorial_hint_cells:
		if not is_cell_valid(cell):
			continue
		var center := get_cell_center(cell)
		var cell_rect := Rect2(center - Vector2(cell_size, cell_size) * 0.5, Vector2(cell_size, cell_size))
		draw_rect(cell_rect.grow(7.0 + pulse * 4.0), Color(1.0, 0.82, 0.06, 0.18 + pulse * 0.10), false, 8.0)
		draw_rect(cell_rect.grow(2.0), Color(1.0, 0.90, 0.22, 0.92), false, 5.0)
	if not is_cell_valid(_tutorial_hint_from) or not is_cell_valid(_tutorial_hint_to):
		return
	var path_points: Array[Vector2] = []
	for cell in _tutorial_hint_cells:
		if is_cell_valid(cell):
			path_points.append(get_cell_center(cell))
	if path_points.size() < 2:
		return
	for index in range(path_points.size() - 1):
		_draw_tutorial_arrow_segment(path_points[index], path_points[index + 1])
	_draw_tutorial_moving_arrow(path_points)


func _draw_tutorial_arrow_segment(start: Vector2, end: Vector2) -> void:
	var raw_direction := end - start
	if raw_direction.length_squared() <= 0.01:
		return
	var direction := raw_direction.normalized()
	var segment_start := start + direction * 28.0
	var segment_end := end - direction * 34.0
	draw_line(segment_start, segment_end, Color(1.0, 0.88, 0.04, 1.0), 12.0, true)
	draw_line(segment_start, segment_end, Color(1.0, 0.55, 0.0, 1.0), 6.0, true)
	_draw_tutorial_arrow_head(segment_end + direction * 18.0, direction, Color(1.0, 0.78, 0.02, 1.0), 0.92)


func _draw_tutorial_arrow_head(tip: Vector2, direction: Vector2, color: Color, arrow_scale: float) -> void:
	var normal := Vector2(-direction.y, direction.x)
	var arrow_back := tip - direction * 28.0 * arrow_scale
	draw_colored_polygon(
		PackedVector2Array([
			tip,
			arrow_back + normal * 18.0 * arrow_scale,
			arrow_back - normal * 18.0 * arrow_scale,
		]),
		color
	)
	draw_polyline(
		PackedVector2Array([
			tip,
			arrow_back + normal * 18.0 * arrow_scale,
			arrow_back - normal * 18.0 * arrow_scale,
			tip,
		]),
		Color(1.0, 0.96, 0.36, color.a),
		3.0 * arrow_scale,
		true
	)


func _draw_tutorial_moving_arrow(path_points: Array[Vector2]) -> void:
	var total_length := 0.0
	for index in range(path_points.size() - 1):
		total_length += path_points[index].distance_to(path_points[index + 1])
	if total_length <= 0.0:
		return
	var travel_period := 1.45
	var travel_ratio := fmod(_glow_pulse_time, travel_period) / travel_period
	var sample := _sample_tutorial_path(path_points, total_length * travel_ratio)
	var arrow_position: Vector2 = sample.get("position", path_points[0])
	var direction: Vector2 = sample.get("direction", Vector2.DOWN)
	var glow_origin := arrow_position - direction * 12.0
	draw_circle(glow_origin, 20.0, Color(1.0, 0.90, 0.03, 0.20))
	draw_circle(glow_origin, 10.0, Color(1.0, 0.55, 0.0, 0.28))
	_draw_tutorial_arrow_head(arrow_position + direction * 20.0, direction, Color(1.0, 0.97, 0.05, 1.0), 1.25)


func _sample_tutorial_path(path_points: Array[Vector2], distance: float) -> Dictionary:
	var remaining_distance := distance
	for index in range(path_points.size() - 1):
		var segment_start: Vector2 = path_points[index]
		var segment_end: Vector2 = path_points[index + 1]
		var segment := segment_end - segment_start
		var segment_length := segment.length()
		if segment_length <= 0.01:
			continue
		var segment_direction := segment / segment_length
		if remaining_distance <= segment_length:
			return {
				"position": segment_start + segment_direction * remaining_distance,
				"direction": segment_direction,
			}
		remaining_distance -= segment_length
	var final_start: Vector2 = path_points[path_points.size() - 2]
	var final_end: Vector2 = path_points[path_points.size() - 1]
	return {
		"position": final_end,
		"direction": (final_end - final_start).normalized(),
	}


func _draw_tutorial_focus_mask(board_rect: Rect2, cell_size: float) -> void:
	if _tutorial_hint_cells.is_empty():
		return
	var focus_cells := {}
	for cell in _tutorial_hint_cells:
		if is_cell_valid(cell):
			focus_cells[_cell_index(cell.x, cell.y)] = true
	for row in BoardModel.ROW_COUNT:
		for column in BoardModel.COLUMN_COUNT:
			if focus_cells.has(_cell_index(column, row)):
				continue
			var pos := board_rect.position + Vector2(
				column * (cell_size + cell_spacing),
				row * (cell_size + cell_spacing)
			)
			var rect := Rect2(pos, Vector2(cell_size, cell_size))
			draw_rect(rect.grow(-2.0), Color(0.0, 0.0, 0.0, 0.58), true)
			draw_rect(rect.grow(-2.0), Color(0.05, 0.08, 0.11, 0.82), false, 2.0)


func _draw_locked_overlay(rect: Rect2) -> void:
	if locked_overlay_color.a <= 0.0 and locked_overlay_border_color.a <= 0.0:
		return
	draw_rect(rect, locked_overlay_color, true)
	if locked_overlay_border_color.a > 0.0:
		draw_rect(rect.grow(-2.0), locked_overlay_border_color, false, 3.0)


func _add_overlay_orb(
	orb_id: int,
	from_pos: Vector2,
	to_pos: Vector2,
	duration: float,
	start_alpha: float,
	end_alpha: float,
	start_scale: float,
	end_scale: float,
	suppress_indices: PackedInt32Array,
	motion: String = OVERLAY_MOTION_LINEAR
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
		"motion": motion,
	})
	queue_redraw()


func _overlay_orb_position(from_pos: Vector2, to_pos: Vector2, t: float, motion: String) -> Vector2:
	if motion != OVERLAY_MOTION_DROP_OVERSHOOT:
		return from_pos.lerp(to_pos, clampf(t, 0.0, 1.0))
	var delta := to_pos - from_pos
	if delta.length_squared() <= 0.01:
		return to_pos
	var direction := delta.normalized()
	var overshoot_distance := minf(maxf(0.0, falling_orb_overshoot_pixels), delta.length() * 0.28 + 10.0)
	var overshoot_pos := to_pos + direction * overshoot_distance
	if t < 0.76:
		var drop_t := _ease_out_cubic(t / 0.76)
		return from_pos.lerp(overshoot_pos, drop_t)
	var settle_t := _ease_out_back((t - 0.76) / 0.24)
	return overshoot_pos.lerp(to_pos, settle_t)


func _overlay_orb_stretch(t: float, motion: String) -> Vector2:
	if motion != OVERLAY_MOTION_DROP_OVERSHOOT:
		return Vector2.ONE
	var stretch_amount := clampf(falling_orb_stretch, 0.0, 0.30)
	if t < 0.76:
		var pulse := sin(clampf(t / 0.76, 0.0, 1.0) * PI)
		return Vector2(1.0 - stretch_amount * 0.42 * pulse, 1.0 + stretch_amount * pulse)
	var settle := sin(clampf((t - 0.76) / 0.24, 0.0, 1.0) * PI)
	return Vector2(1.0 + stretch_amount * 0.72 * settle, 1.0 - stretch_amount * 0.52 * settle)


func _ease_out_cubic(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	return 1.0 - pow(1.0 - clamped, 3.0)


func _ease_out_back(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(clamped - 1.0, 3.0) + c1 * pow(clamped - 1.0, 2.0)


func _release_suppressed_cells(suppress_indices: PackedInt32Array) -> void:
	for cell_index in suppress_indices:
		if not _suppressed_cells.has(cell_index):
			continue
		var remaining: int = int(_suppressed_cells[cell_index]) - 1
		if remaining <= 0:
			_suppressed_cells.erase(cell_index)
		else:
			_suppressed_cells[cell_index] = remaining
