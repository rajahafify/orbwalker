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


func _sync_command_result(result: Dictionary) -> void:
	if result.has("board_model") and result.get("board_model") != null:
		_owner.set("_board_model", result["board_model"])
	_owner.call("_bind_debug_state_provider")
