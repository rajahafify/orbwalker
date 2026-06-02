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
var _drag_input_result_callback: Callable
var _hovered_orb_changed_callback: Callable
var _swap_animation_seconds: float = 0.08
var _input_enabled := true
var _restricted_drag_path: Array[Vector2i] = []

var _active_drag := false
var _drag_touch_index: int = -1
var _drag_selected_orb_id: int = -1
var _drag_current_cell: Vector2i = Vector2i(-1, -1)
var _drag_path: Array[Vector2i] = []
var _move_time_left: float = 0.0
var _hovered_orb_id: int = -1


func bind(dependencies: Dictionary, config: Dictionary = {}) -> void:
	var previous_board_view := _board_view
	_disconnect_board_view_signals(previous_board_view)
	_board_view = dependencies.get("board_view") as BoardView
	_board_model = dependencies.get("board_model") as BoardModel
	_swap_sound_callback = config.get("swap_sound_callback", Callable())
	_match_groups_callback = config.get("match_groups_callback", Callable())
	_move_timer_seconds_callback = config.get("move_timer_seconds_callback", Callable())
	_drag_input_result_callback = config.get("drag_input_result_callback", Callable())
	_hovered_orb_changed_callback = config.get("hovered_orb_changed_callback", Callable())
	_swap_animation_seconds = float(config.get("swap_animation_seconds", _swap_animation_seconds))
	bind_view_model()
	_connect_board_view_signals()
	set_input_enabled(_input_enabled)


func set_board_model(board_model: BoardModel) -> void:
	_board_model = board_model
	bind_view_model()


func current_board_model() -> BoardModel:
	return _board_model


func initialize_board(rng_seed: int, settings: BoardGenerationSettings = null) -> int:
	if _board_model == null:
		_board_model = BoardModel.new()
	_board_model.initialize(rng_seed, settings)
	bind_view_model()
	return _board_model.rng_seed


func bind_view_model() -> void:
	if not _has_valid_board_view():
		return
	_board_view.set_board_presentation_model(_board_model)


func set_refill_overshoot_enabled(enabled: bool) -> void:
	if not _has_valid_board_view():
		return
	if _board_view.has_method("set_refill_overshoot_enabled"):
		_board_view.set_refill_overshoot_enabled(enabled)


func board_seed() -> int:
	if _board_model == null:
		return -1
	return _board_model.rng_seed


func board_debug_string() -> String:
	if _board_model == null:
		return ""
	return _board_model.to_debug_string()


func force_cell_orb(cell: Vector2i, orb_id: int) -> bool:
	if _board_model == null:
		return false
	if not _board_model.in_bounds(cell.x, cell.y):
		return false
	if not OrbType.is_valid_id(orb_id):
		return false
	_board_model.set_cell(cell.x, cell.y, orb_id)
	bind_view_model()
	return true


func set_debug_cell_orb(column: int, row: int, orb_id: int) -> bool:
	return force_cell_orb(Vector2i(column, row), orb_id)


func convert_random_non_target_orbs(target_orb_id: int, count: int, rng: RandomNumberGenerator) -> int:
	if _board_model == null:
		return 0
	if count <= 0 or not OrbType.is_valid_id(target_orb_id):
		return 0
	if rng == null:
		return 0

	var candidates: Array[Vector2i] = []
	for row in BoardModel.ROW_COUNT:
		for column in BoardModel.COLUMN_COUNT:
			var orb_id := _board_model.get_cell(column, row)
			if orb_id == target_orb_id:
				continue
			candidates.append(Vector2i(column, row))
	if candidates.is_empty():
		return 0

	var converted := 0
	var picks := mini(count, candidates.size())
	for _i in picks:
		var pick_index := rng.randi_range(0, candidates.size() - 1)
		var cell := candidates[pick_index]
		if force_cell_orb(cell, target_orb_id):
			converted += 1
		candidates.remove_at(pick_index)
	return converted


func prepare_visual_model_for_resolve() -> Dictionary:
	if _board_model == null:
		return {}
	var visual_board_model: BoardModel = _board_model.clone()
	var simulation_board_model: BoardModel = _board_model.clone()
	if _has_valid_board_view():
		_board_view.set_board_presentation_model(visual_board_model)
	return {
		"visual_board_model": visual_board_model,
		"simulation_board_model": simulation_board_model,
	}


func apply_visual_clear_groups(visual_board_model: BoardModel, groups: Array) -> void:
	if visual_board_model == null or not _has_valid_board_view():
		return
	for group in groups:
		var group_cells: Array = group.get("cells", [])
		for cell in group_cells:
			var typed_cell: Vector2i = cell
			visual_board_model.clear_cell(typed_cell.x, typed_cell.y)
	_board_view.queue_redraw()


func apply_visual_fall_moves(visual_board_model: BoardModel, fall_moves: Array) -> void:
	if visual_board_model == null or not _has_valid_board_view():
		return
	for move in fall_moves:
		var from_cell: Vector2i = move.from
		visual_board_model.clear_cell(from_cell.x, from_cell.y)
	for move in fall_moves:
		var to_cell: Vector2i = move.to
		var orb_id := int(move.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_model.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func apply_visual_refill_spawns(visual_board_model: BoardModel, refill_spawns: Array) -> void:
	if visual_board_model == null or not _has_valid_board_view():
		return
	for spawn in refill_spawns:
		var to_cell: Vector2i = spawn.to
		var orb_id := int(spawn.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_model.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func commit_model_after_resolve(resolved_board_model: BoardModel) -> void:
	if resolved_board_model == null:
		return
	_board_model = resolved_board_model
	bind_view_model()


func clear_board_presentation() -> void:
	if not _has_valid_board_view():
		return
	_board_view.clear_board_presentation()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled
	if _has_valid_board_view():
		_board_view.set_input_enabled(enabled)
	if not enabled:
		_emit_hovered_orb_id(-1)


func set_restricted_swap(from_cell: Vector2i, to_cell: Vector2i) -> void:
	set_restricted_drag_path([from_cell, to_cell])


func clear_restricted_swap() -> void:
	clear_restricted_drag_path()


func set_restricted_drag_path(path: Array[Vector2i]) -> void:
	_restricted_drag_path = path.duplicate()


func clear_restricted_drag_path() -> void:
	_restricted_drag_path.clear()


func handle_pointer_input(event: InputEvent, input_enabled: bool) -> Dictionary:
	if not input_enabled and not _active_drag:
		return {"handled": _is_pointer_event(event), "action": ACTION_NONE}

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


func _is_pointer_event(event: InputEvent) -> bool:
	return event is InputEventMouseButton \
			or event is InputEventMouseMotion \
			or event is InputEventScreenTouch \
			or event is InputEventScreenDrag


func update(delta: float, _input_active: bool) -> Dictionary:
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
	_board_view.reset_drag_visual_state()


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
	if _is_drag_restricted() and start_cell != _restricted_drag_path[0]:
		return {"handled": true, "action": ACTION_NONE}

	_active_drag = true
	_move_time_left = _resolve_move_timer_seconds()
	_drag_current_cell = start_cell
	_drag_selected_orb_id = _board_model.get_cell(start_cell.x, start_cell.y)
	_drag_path.clear()
	_drag_path.append(start_cell)
	_board_view.update_drag_visual_state(start_cell, _drag_path.duplicate(), board_local_position, _drag_selected_orb_id)
	return {
		"handled": true,
		"action": ACTION_START,
		"selected_orb_id": _drag_selected_orb_id,
		"move_time_left": _move_time_left,
	}


func _update_drag(board_local_position: Vector2) -> void:
	if not _active_drag or not _has_valid_board_view() or _board_model == null:
		return

	_board_view.update_drag_visual_state(_drag_current_cell, _drag_path.duplicate(), board_local_position, _drag_selected_orb_id)
	var target_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(target_cell):
		return
	if target_cell == _drag_current_cell:
		return
	if not _is_orthogonally_adjacent(_drag_current_cell, target_cell):
		return
	if _is_drag_restricted():
		var next_path_index := _drag_path.size()
		if next_path_index >= _restricted_drag_path.size():
			return
		if target_cell != _restricted_drag_path[next_path_index]:
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
	_board_view.update_drag_visual_state(_drag_current_cell, _drag_path.duplicate(), board_local_position, _drag_selected_orb_id)


func _end_drag(timed_out: bool, handled: bool) -> Dictionary:
	_active_drag = false
	_drag_touch_index = -1
	return {
		"handled": handled,
		"action": ACTION_END,
		"timed_out": timed_out,
		"path": _drag_path.duplicate(),
	}


func _resolve_move_timer_seconds() -> float:
	if _move_timer_seconds_callback.is_valid():
		return maxf(0.0, float(_move_timer_seconds_callback.call()))
	return 0.0


func _is_orthogonally_adjacent(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var delta := to_cell - from_cell
	return abs(delta.x) + abs(delta.y) == 1


func _is_drag_restricted() -> bool:
	return not _restricted_drag_path.is_empty()


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


func _connect_board_view_signals() -> void:
	if not _has_valid_board_view():
		return
	if not _board_view.gui_input.is_connected(_on_board_view_gui_input):
		_board_view.gui_input.connect(_on_board_view_gui_input)
	if not _board_view.mouse_exited.is_connected(_on_board_view_mouse_exited):
		_board_view.mouse_exited.connect(_on_board_view_mouse_exited)


func _disconnect_board_view_signals(board_view: BoardView) -> void:
	if board_view == null or not is_instance_valid(board_view):
		return
	if board_view.gui_input.is_connected(_on_board_view_gui_input):
		board_view.gui_input.disconnect(_on_board_view_gui_input)
	if board_view.mouse_exited.is_connected(_on_board_view_mouse_exited):
		board_view.mouse_exited.disconnect(_on_board_view_mouse_exited)


func _on_board_view_gui_input(event: InputEvent) -> void:
	_emit_hovered_orb_id(_resolve_hovered_orb_id_from_gui_input(event))
	var drag_result: Dictionary = handle_pointer_input(event, _input_enabled)
	if _drag_input_result_callback.is_valid():
		_drag_input_result_callback.call(drag_result)
	if bool(drag_result.get("handled", false)) and _has_valid_board_view():
		_board_view.accept_event()


func _on_board_view_mouse_exited() -> void:
	_emit_hovered_orb_id(-1)


func _resolve_hovered_orb_id_from_gui_input(event: InputEvent) -> int:
	if not _input_enabled:
		return -1
	if _active_drag:
		return -1
	if not _has_valid_board_view() or _board_model == null:
		return -1
	if event is InputEventMouseMotion:
		return _board_view.get_hover_orb_id((event as InputEventMouseMotion).position)
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if not button_event.pressed:
			return _board_view.get_hover_orb_id(button_event.position)
	return -1


func _emit_hovered_orb_id(orb_id: int) -> void:
	if _hovered_orb_id == orb_id:
		return
	_hovered_orb_id = orb_id
	if _hovered_orb_changed_callback.is_valid():
		_hovered_orb_changed_callback.call(_hovered_orb_id)
