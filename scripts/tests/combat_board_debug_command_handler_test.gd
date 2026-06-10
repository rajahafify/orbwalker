extends RefCounted
class_name CombatBoardDebugCommandHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_board_debug_command_handler.gd")


class FakeBoardModel:
	extends RefCounted

	var rng_seed := 0
	var debug_text := ""

	func _init(seed_value: int = 0, debug_value: String = "") -> void:
		rng_seed = seed_value
		debug_text = debug_value

	func to_debug_string() -> String:
		return debug_text


class FakeBoardController:
	extends RefCounted

	var aborted := 0
	var cleared := 0
	var initialized_seed := 0
	var initialized_settings: Variant = null
	var model := FakeBoardModel.new(11, "controller-board")

	func abort() -> void:
		aborted += 1

	func clear_board_presentation() -> void:
		cleared += 1

	func initialize_board(board_seed: int, settings: Variant) -> void:
		initialized_seed = board_seed
		initialized_settings = settings
		model = FakeBoardModel.new(board_seed, "seed-%d" % board_seed)

	func current_board_model() -> FakeBoardModel:
		return model

	func board_seed() -> int:
		return int(model.rng_seed)

	func board_debug_string() -> String:
		return String(model.debug_text)


class FakeCombat:
	extends RefCounted

	var turn_index := 4
	var fight_over := false

	func is_fight_over() -> bool:
		return fight_over


class FakeRunState:
	extends RefCounted

	var tutorial := true
	var tutorial_seed := 333

	func is_tutorial_run() -> bool:
		return tutorial

	func tutorial_board_seed_for_turn(_turn_index: int) -> int:
		return tutorial_seed


class CallbackRecorder:
	extends RefCounted

	var input_phases: Array[int] = []
	var statuses: Array[String] = []
	var logs: Array[String] = []
	var sync_count := 0

	func set_input_phase(value: int) -> void:
		input_phases.append(value)

	func set_status_text(value: String) -> void:
		statuses.append(value)

	func append_combat_log(value: String) -> void:
		logs.append(value)

	func sync_tutorial_coachmark() -> void:
		sync_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("set_board_seed_initializes_controller", _test_set_board_seed_initializes_controller, failures)
	_run_case("create_new_board_uses_tutorial_seed", _test_create_new_board_uses_tutorial_seed, failures)
	_run_case("print_board_model_logs_seed_and_rows", _test_print_board_model_logs_seed_and_rows, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_set_board_seed_initializes_controller() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var controller: FakeBoardController = fixture["controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var settings: Variant = fixture["settings"]
	var result: Dictionary = handler.set_board_seed(90210)
	if not bool(result.get("ok", false)):
		return "Expected set_board_seed to return ok."
	if controller.aborted != 1 or controller.cleared != 1:
		return "Expected set_board_seed to abort and clear the current board presentation."
	if controller.initialized_seed != 90210 or controller.initialized_settings != settings:
		return "Expected set_board_seed to initialize the board with the requested seed/settings."
	if result.get("board_model") != controller.model:
		return "Expected set_board_seed to return the current board model."
	if recorder.input_phases != [2]:
		return "Expected active combat to return input phase to player input."
	return ""


func _test_create_new_board_uses_tutorial_seed() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var result: Dictionary = handler.create_new_board()
	if int(result.get("seed", 0)) != 333:
		return "Expected tutorial run seed to override random seed generation."
	if recorder.statuses != ["Seed: 333 | Turn 4 ready."]:
		return "Expected create_new_board to report ready status for active combat."
	if recorder.sync_count != 1:
		return "Expected create_new_board to sync the tutorial coachmark."
	return ""


func _test_print_board_model_logs_seed_and_rows() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var controller: FakeBoardController = fixture["controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	controller.model = FakeBoardModel.new(77, "A\nB")
	var result: Dictionary = handler.print_board_model()
	if int(result.get("seed", 0)) != 77 or String(result.get("debug_text", "")) != "A\nB":
		return "Expected print_board_model to return the current board debug data."
	if recorder.logs != ["Board seed: 77", "  A", "  B"]:
		return "Expected print_board_model to append the seed and board rows to the combat log."
	if recorder.statuses != ["Printed board for seed 77 to output."]:
		return "Expected print_board_model to update status text."
	return ""


func _fixture() -> Dictionary:
	var handler: Variant = HANDLER_SCRIPT.new()
	var controller := FakeBoardController.new()
	var combat := FakeCombat.new()
	var run_state := FakeRunState.new()
	var recorder := CallbackRecorder.new()
	var settings := {"size": Vector2i(6, 7)}
	(
		handler
		. bind(
			{
				"board_controller": controller,
				"board_model": controller.model,
				"settings": settings,
				"combat": combat,
				"run_state": run_state,
				"player_input_phase_value": 2,
				"print_to_stdout": false,
			},
			{
				HANDLER_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(recorder, "set_input_phase"),
				HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
				HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(recorder, "append_combat_log"),
				HANDLER_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: Callable(recorder, "sync_tutorial_coachmark"),
			}
		)
	)
	return {
		"handler": handler,
		"controller": controller,
		"combat": combat,
		"run_state": run_state,
		"recorder": recorder,
		"settings": settings,
	}
