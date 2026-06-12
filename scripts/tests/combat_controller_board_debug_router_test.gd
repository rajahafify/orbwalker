extends RefCounted
class_name CombatControllerBoardDebugRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_board_debug_router.gd")


class FakeBoardDebugCommandHandler:
	extends RefCounted

	var create_calls := 0
	var print_calls := 0
	var set_seed_calls: Array[int] = []
	var create_result := {"board_model": "created-board"}
	var set_seed_result := {"board_model": "seeded-board"}

	func create_new_board() -> Dictionary:
		create_calls += 1
		return create_result

	func print_board_model() -> Dictionary:
		print_calls += 1
		return {}

	func set_board_seed(board_seed: int) -> Dictionary:
		set_seed_calls.append(board_seed)
		return set_seed_result


class FakeBoardController:
	extends RefCounted

	var abort_calls := 0

	func abort() -> void:
		abort_calls += 1


class FakeLifecycle:
	extends RefCounted

	var initialize_calls := 0

	func initialize_combat_state() -> void:
		initialize_calls += 1


class FakeOwner:
	extends RefCounted

	var _board_debug_command_handler: Variant = FakeBoardDebugCommandHandler.new()
	var _board_controller: Variant = FakeBoardController.new()
	var _lifecycle: Variant = FakeLifecycle.new()
	var _board_model: Variant = null
	var _last_resolve_result := {"stale": true}
	var bind_handler_calls := 0
	var bind_debug_state_provider_calls := 0
	var bind_lifecycle_calls := 0
	var begin_turn_preview_calls := 0

	func _bind_board_debug_command_handler() -> void:
		bind_handler_calls += 1

	func _bind_debug_state_provider() -> void:
		bind_debug_state_provider_calls += 1

	func _bind_lifecycle() -> void:
		bind_lifecycle_calls += 1

	func _begin_turn_preview() -> void:
		begin_turn_preview_calls += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("create_new_board_syncs_result", _test_create_new_board_syncs_result, failures)
	_run_case("set_board_seed_forwards_seed_and_syncs_result", _test_set_board_seed_forwards_seed_and_syncs_result, failures)
	_run_case("print_board_model_keeps_controller_state_unchanged", _test_print_board_model_keeps_controller_state_unchanged, failures)
	_run_case("console_skip_success_reinitializes_board_and_preview", _test_console_skip_success_reinitializes_board_and_preview, failures)
	return {"passed": failures.is_empty(), "total": 4, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_create_new_board_syncs_result() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.create_new_board()

	var handler: FakeBoardDebugCommandHandler = owner._board_debug_command_handler
	if owner.bind_handler_calls != 1:
		return "Expected create_new_board to bind the board debug command handler."
	if handler.create_calls != 1:
		return "Expected create_new_board to call the command handler."
	if owner._board_model != "created-board":
		return "Expected create_new_board to copy the returned board model onto the owner."
	if owner.bind_debug_state_provider_calls != 1:
		return "Expected create_new_board to refresh the debug state provider."
	return ""


func _test_set_board_seed_forwards_seed_and_syncs_result() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.set_board_seed(12345)

	var handler: FakeBoardDebugCommandHandler = owner._board_debug_command_handler
	if handler.set_seed_calls != [12345]:
		return "Expected set_board_seed to forward the seed to the command handler."
	if owner._board_model != "seeded-board":
		return "Expected set_board_seed to copy the returned board model onto the owner."
	if owner.bind_debug_state_provider_calls != 1:
		return "Expected set_board_seed to refresh the debug state provider."
	return ""


func _test_print_board_model_keeps_controller_state_unchanged() -> String:
	var owner := FakeOwner.new()
	owner._board_model = "existing-board"
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.print_board_model()

	var handler: FakeBoardDebugCommandHandler = owner._board_debug_command_handler
	if owner.bind_handler_calls != 1:
		return "Expected print_board_model to bind the board debug command handler."
	if handler.print_calls != 1:
		return "Expected print_board_model to call the command handler."
	if owner._board_model != "existing-board":
		return "Expected print_board_model to leave the controller board model unchanged."
	if owner.bind_debug_state_provider_calls != 0:
		return "Expected print_board_model not to refresh debug state directly."
	return ""


func _test_console_skip_success_reinitializes_board_and_preview() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.console_on_skip_success()

	var board_controller: FakeBoardController = owner._board_controller
	var lifecycle: FakeLifecycle = owner._lifecycle
	var handler: FakeBoardDebugCommandHandler = owner._board_debug_command_handler
	if board_controller.abort_calls != 1:
		return "Expected console skip success to abort the active board interaction."
	if not owner._last_resolve_result.is_empty():
		return "Expected console skip success to clear the previous resolve result."
	if owner.bind_lifecycle_calls != 1 or lifecycle.initialize_calls != 1:
		return "Expected console skip success to reinitialize combat state through lifecycle."
	if handler.create_calls != 1 or owner._board_model != "created-board":
		return "Expected console skip success to create and sync a new debug board."
	if owner.begin_turn_preview_calls != 1:
		return "Expected console skip success to restart turn preview."
	return ""
