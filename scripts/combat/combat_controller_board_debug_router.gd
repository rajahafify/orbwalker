extends RefCounted
class_name CombatControllerBoardDebugRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func create_new_board() -> void:
	_owner.call("_bind_board_debug_command_handler")
	var handler: Variant = _owner.get("_board_debug_command_handler")
	if handler == null:
		return
	_sync_command_result(handler.create_new_board())


func print_board_model() -> void:
	_owner.call("_bind_board_debug_command_handler")
	var handler: Variant = _owner.get("_board_debug_command_handler")
	if handler != null:
		handler.print_board_model()


func set_board_seed(board_seed: int) -> void:
	_owner.call("_bind_board_debug_command_handler")
	var handler: Variant = _owner.get("_board_debug_command_handler")
	if handler == null:
		return
	_sync_command_result(handler.set_board_seed(board_seed))


func console_on_skip_success() -> void:
	var board_controller: Variant = _owner.get("_board_controller")
	if board_controller != null:
		board_controller.abort()
	_owner.get("_last_resolve_result").clear()
	_owner.call("_bind_lifecycle")
	_owner.get("_lifecycle").initialize_combat_state()
	create_new_board()
	_owner.call("_begin_turn_preview")


func _sync_command_result(result: Dictionary) -> void:
	if result.has("board_model") and result.get("board_model") != null:
		_owner.set("_board_model", result["board_model"])
	_owner.call("_bind_debug_state_provider")
