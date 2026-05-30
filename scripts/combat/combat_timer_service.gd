extends RefCounted
class_name CombatTimerService

const MOVE_TIMER_MAX_SECONDS := 5.0
const TIMER_STATE_READY := "ready"
const TIMER_STATE_ACTIVE := "active"
const TIMER_STATE_LOCKED := "locked"


func process(
	board_controller: Variant,
	view: Variant,
	player_state: Variant,
	delta: float,
	player_input_active: bool
) -> Dictionary:
	if player_state == null or board_controller == null:
		return {}
	if not drag_active(board_controller):
		_sync_idle_display(view, player_state, player_input_active)
		return {}

	var drag_update := _update_board_controller(board_controller, delta, player_input_active)
	_sync_display(view, move_time_left(board_controller), TIMER_STATE_ACTIVE)
	return drag_update


func ready_seconds(player_state: Variant) -> float:
	if player_state == null:
		return MOVE_TIMER_MAX_SECONDS
	return float(player_state.move_timer_seconds)


func drag_active(board_controller: Variant) -> bool:
	return board_controller != null and board_controller.has_method("active_drag") and bool(board_controller.active_drag())


func move_time_left(board_controller: Variant) -> float:
	if board_controller == null or not board_controller.has_method("move_time_left"):
		return 0.0
	return float(board_controller.move_time_left())


func layout_timer_seconds(board_controller: Variant, player_state: Variant) -> float:
	if drag_active(board_controller):
		return move_time_left(board_controller)
	return ready_seconds(player_state)


func layout_timer_state(board_controller: Variant) -> String:
	return TIMER_STATE_ACTIVE if drag_active(board_controller) else TIMER_STATE_READY


func sync_locked(view: Variant) -> void:
	_sync_display(view, 0.0, TIMER_STATE_LOCKED)


func _sync_idle_display(view: Variant, player_state: Variant, player_input_active: bool) -> void:
	if player_input_active:
		_sync_display(view, ready_seconds(player_state), TIMER_STATE_READY)
	else:
		sync_locked(view)


func _sync_display(view: Variant, seconds_left: float, state: String) -> void:
	if view != null and view.has_method("sync_timer_display"):
		view.sync_timer_display(seconds_left, state)


func _update_board_controller(board_controller: Variant, delta: float, player_input_active: bool) -> Dictionary:
	if board_controller == null or not board_controller.has_method("update"):
		return {}
	var result: Variant = board_controller.update(delta, player_input_active)
	if result is Dictionary:
		return result
	return {}
