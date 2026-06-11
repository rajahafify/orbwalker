extends RefCounted
class_name CombatTutorialDragFlow

const CALLBACK_END_DRAG := "end_drag"
const CALLBACK_SET_BOARD_SEED := "set_board_seed"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_BOARD_MODEL_CHANGED := "board_model_changed"

var _board_model: Variant = null
var _board_controller: Variant = null
var _tutorial_director: Variant = null
var _coachmark_coordinator: Variant = null
var _callbacks: Dictionary = {}
var _warning_status_color := Color.WHITE
var _tutorial_drag_board_snapshot: Variant = null


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_board_model = dependencies.get("board_model", null)
	_board_controller = dependencies.get("board_controller", null)
	_tutorial_director = dependencies.get("tutorial_director", null)
	_coachmark_coordinator = dependencies.get("coachmark_coordinator", null)
	_callbacks = callbacks.duplicate()
	_warning_status_color = config.get("warning_status_color", Color.WHITE)


func handle_start() -> void:
	var tutorial_start_path := active_drag_path()
	if not tutorial_start_path.is_empty() and _board_model != null:
		_tutorial_drag_board_snapshot = _board_model.clone()


func handle_end(result: Dictionary) -> void:
	var drag_path: Array = result.get("path", [])
	var tutorial_drag_path := active_drag_path()
	if not tutorial_drag_path.is_empty():
		if _tutorial_director == null or not _tutorial_director.did_complete_drag_path(drag_path, tutorial_drag_path):
			reset_incomplete_drag()
			_set_status_text(active_retry_status_text())
			_set_status_color(_warning_status_color)
			_sync_tutorial_coachmark()
			return
		clear_snapshot()
		_hide_tutorial_coachmark()
	_end_drag(bool(result.get("timed_out", false)))


func reset_incomplete_drag() -> void:
	if _board_controller == null:
		return
	if _tutorial_drag_board_snapshot != null:
		_board_controller.abort()
		_board_controller.set_board_model(_tutorial_drag_board_snapshot.clone())
		_board_model = _board_controller.current_board_model()
		clear_snapshot()
		_board_model_changed(_board_model)
		return
	var current_seed := int(_board_controller.board_seed()) if _board_controller.has_method("board_seed") else -1
	if current_seed > 0:
		_set_board_seed(current_seed)
	elif _board_controller.has_method("reset_visuals"):
		_board_controller.reset_visuals()


func clear_snapshot() -> void:
	_tutorial_drag_board_snapshot = null


func active_drag_path() -> Array[Vector2i]:
	if _coachmark_coordinator == null:
		return []
	return _coachmark_coordinator.active_drag_path()


func active_retry_status_text() -> String:
	if _coachmark_coordinator == null:
		return ""
	return String(_coachmark_coordinator.active_retry_status_text())


func _sync_tutorial_coachmark() -> void:
	if _coachmark_coordinator != null:
		_coachmark_coordinator.sync()


func _hide_tutorial_coachmark() -> void:
	if _coachmark_coordinator != null:
		_coachmark_coordinator.hide_coachmark()


func _end_drag(timed_out: bool) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_END_DRAG, Callable())
	if callback.is_valid():
		callback.call(timed_out)


func _set_board_seed(board_seed: int) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_SET_BOARD_SEED, Callable())
	if callback.is_valid():
		callback.call(board_seed)


func _set_status_text(value: String) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if callback.is_valid():
		callback.call(value)


func _set_status_color(value: Color) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_SET_STATUS_COLOR, Callable())
	if callback.is_valid():
		callback.call(value)


func _board_model_changed(board_model: Variant) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_BOARD_MODEL_CHANGED, Callable())
	if callback.is_valid():
		callback.call(board_model)
