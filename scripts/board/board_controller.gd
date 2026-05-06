extends RefCounted
class_name BoardController

const ACTION_NONE := ""
const ACTION_START := "start"
const ACTION_END := "end"

var _board_view: BoardView
var _board_model: BoardModel
var _swap_sound_callback: Callable
var _match_groups_callback: Callable
var _move_timer_seconds_callback: Callable
var _swap_animation_seconds: float = 0.08

var _active_drag := false
var _drag_touch_index: int = -1
var _drag_selected_orb_id: int = -1
var _drag_current_cell: Vector2i = Vector2i(-1, -1)
var _drag_path: Array[Vector2i] = []
var _move_time_left: float = 0.0


func bind(dependencies: Dictionary, config: Dictionary = {}) -> void:
	_board_view = dependencies.get("board_view") as BoardView
	_board_model = dependencies.get("board_model") as BoardModel
	_swap_sound_callback = config.get("swap_sound_callback", Callable())
	_match_groups_callback = config.get("match_groups_callback", Callable())
	_move_timer_seconds_callback = config.get("move_timer_seconds_callback", Callable())
	_swap_animation_seconds = float(config.get("swap_animation_seconds", _swap_animation_seconds))


func set_board_model(board_model: BoardModel) -> void:
	_board_model = board_model


func handle_pointer_input(event: InputEvent, input_enabled: bool) -> Dictionary:
	if not input_enabled and not _active_drag:
		return {"handled": false, "action": ACTION_NONE}

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			return _start_drag(event.position, input_enabled)
		if _active_drag:
			return _end_drag(false, true)
		return {"handled": false, "action": ACTION_NONE}

	if event is InputEventMouseMotion and _active_drag and _drag_touch_index == -1:
		_update_drag(event.position)
		return {"handled": true, "action": ACTION_NONE}

	if event is InputEventScreenTouch:
		var touch_pos: Vector2 = event.position
		if event.pressed:
			if _drag_touch_index != -1:
				return {"handled": false, "action": ACTION_NONE}
			var drag_started := _start_drag(touch_pos, input_enabled)
			if bool(drag_started.get("handled", false)):
				_drag_touch_index = event.index
			return drag_started
		if _active_drag and event.index == _drag_touch_index:
			return _end_drag(false, true)

	if event is InputEventScreenDrag and _active_drag and event.index == _drag_touch_index:
		_update_drag(event.position)
		return {"handled": true, "action": ACTION_NONE}

	return {"handled": false, "action": ACTION_NONE}


func update(delta: float, _input_enabled: bool) -> Dictionary:
	if not _active_drag:
		return {"action": ACTION_NONE}
	_refresh_drag_match_glow()
	_move_time_left = maxf(0.0, _move_time_left - delta)
	if _move_time_left <= 0.0:
		return _end_drag(true, false)
	return {"action": ACTION_NONE}


func reset_visuals() -> void:
	_drag_selected_orb_id = -1
	_drag_current_cell = Vector2i(-1, -1)
	_drag_path.clear()
	if not _has_valid_board_view():
		return
	_board_view.clear_match_glow()
	_board_view.selected_cell = Vector2i(-1, -1)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_orb_id = -1
	_board_view.drag_pointer_position = Vector2.ZERO


func abort() -> void:
	_active_drag = false
	_drag_touch_index = -1
	_move_time_left = 0.0
	reset_visuals()


func refresh_match_glow() -> void:
	if not _active_drag:
		if _has_valid_board_view():
			_board_view.clear_match_glow()
		return
	_refresh_drag_match_glow()


func active_drag() -> bool:
	return _active_drag


func move_time_left() -> float:
	return _move_time_left


func _start_drag(board_local_position: Vector2, input_enabled: bool) -> Dictionary:
	if not input_enabled:
		return {"handled": false, "action": ACTION_NONE}
	if not _has_valid_board_view() or _board_model == null:
		return {"handled": false, "action": ACTION_NONE}

	var start_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(start_cell):
		return {"handled": false, "action": ACTION_NONE}

	_active_drag = true
	_move_time_left = _resolve_move_timer_seconds()
	_drag_current_cell = start_cell
	_drag_selected_orb_id = _board_model.get_cell(start_cell.x, start_cell.y)
	_drag_path.clear()
	_drag_path.append(start_cell)
	_board_view.selected_cell = start_cell
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_pointer_position = board_local_position
	_board_view.drag_orb_id = _drag_selected_orb_id
	return {
		"handled": true,
		"action": ACTION_START,
		"selected_orb_id": _drag_selected_orb_id,
		"move_time_left": _move_time_left,
	}


func _update_drag(board_local_position: Vector2) -> void:
	if not _active_drag or not _has_valid_board_view() or _board_model == null:
		return

	_board_view.drag_pointer_position = board_local_position
	var target_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(target_cell):
		return
	if target_cell == _drag_current_cell:
		return
	if not _is_orthogonally_adjacent(_drag_current_cell, target_cell):
		return

	var from_cell := _drag_current_cell
	var moving_orb_id := _board_model.get_cell(from_cell.x, from_cell.y)
	var displaced_orb_id := _board_model.get_cell(target_cell.x, target_cell.y)
	_board_model.swap_cells(_drag_current_cell.x, _drag_current_cell.y, target_cell.x, target_cell.y)
	if _swap_sound_callback.is_valid():
		_swap_sound_callback.call()
	_drag_current_cell = target_cell
	_drag_path.append(target_cell)
	_board_view.animate_swap(from_cell, target_cell, moving_orb_id, displaced_orb_id, _swap_animation_seconds)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.selected_cell = _drag_current_cell
	_board_view.board_model = _board_model


func _end_drag(timed_out: bool, handled: bool) -> Dictionary:
	_active_drag = false
	_drag_touch_index = -1
	return {
		"handled": handled,
		"action": ACTION_END,
		"timed_out": timed_out,
	}


func _resolve_move_timer_seconds() -> float:
	if _move_timer_seconds_callback.is_valid():
		return maxf(0.0, float(_move_timer_seconds_callback.call()))
	return 0.0


func _is_orthogonally_adjacent(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var delta := to_cell - from_cell
	return abs(delta.x) + abs(delta.y) == 1


func _refresh_drag_match_glow() -> void:
	if not _has_valid_board_view():
		return
	if _match_groups_callback.is_valid():
		var groups: Variant = _match_groups_callback.call()
		if groups is Array:
			_board_view.set_live_match_glow(groups)
			return
	_board_view.clear_match_glow()


func _has_valid_board_view() -> bool:
	return _board_view != null and is_instance_valid(_board_view)
