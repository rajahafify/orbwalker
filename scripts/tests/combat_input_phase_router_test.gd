extends RefCounted
class_name CombatInputPhaseRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_input_phase_router.gd")


class FakeModel:
	extends RefCounted

	var phase := ROUTER_SCRIPT.PHASE_PLAYER_INPUT
	var reason := ""

	func set_input_phase(value: int) -> void:
		phase = value

	func input_phase() -> int:
		return phase

	func external_lock_reason() -> String:
		return reason


class FakeBoardController:
	extends RefCounted

	var input_enabled_values: Array[bool] = []

	func set_input_enabled(enabled: bool) -> void:
		input_enabled_values.append(enabled)


class CallbackRecorder:
	extends RefCounted

	var clear_hover_count := 0
	var sync_count := 0
	var statuses: Array[String] = []

	func clear_hover_state() -> void:
		clear_hover_count += 1

	func set_status_text(text: String) -> void:
		statuses.append(text)

	func sync_model_state() -> void:
		sync_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("player_input_enables_board_without_hover_clear", _test_player_input_enables_board_without_hover_clear, failures)
	_run_case("resolving_disables_board_and_clears_hover", _test_resolving_disables_board_and_clears_hover, failures)
	_run_case("locked_external_disables_board_and_reports_reason", _test_locked_external_disables_board_and_reports_reason, failures)
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


func _test_player_input_enables_board_without_hover_clear() -> String:
	var fixture := _fixture()
	var router: Variant = fixture["router"]
	var model: FakeModel = fixture["model"]
	var board_controller: FakeBoardController = fixture["board_controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	router.set_phase(ROUTER_SCRIPT.PHASE_PLAYER_INPUT)
	if model.phase != ROUTER_SCRIPT.PHASE_PLAYER_INPUT:
		return "Expected model phase to be player input."
	if board_controller.input_enabled_values != [true]:
		return "Expected board input to be enabled for player input."
	if recorder.clear_hover_count != 0:
		return "Expected player input phase to preserve hover state."
	if recorder.sync_count != 1:
		return "Expected model sync after phase routing."
	return ""


func _test_resolving_disables_board_and_clears_hover() -> String:
	var fixture := _fixture()
	var router: Variant = fixture["router"]
	var model: FakeModel = fixture["model"]
	var board_controller: FakeBoardController = fixture["board_controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	router.set_phase(ROUTER_SCRIPT.PHASE_RESOLVING)
	if model.phase != ROUTER_SCRIPT.PHASE_RESOLVING:
		return "Expected model phase to be resolving."
	if board_controller.input_enabled_values != [false]:
		return "Expected board input to be disabled during resolving."
	if recorder.clear_hover_count != 1:
		return "Expected resolving phase to clear combat mastery hover state."
	if recorder.sync_count != 1:
		return "Expected model sync after phase routing."
	return ""


func _test_locked_external_disables_board_and_reports_reason() -> String:
	var fixture := _fixture("Settings open")
	var router: Variant = fixture["router"]
	var model: FakeModel = fixture["model"]
	var board_controller: FakeBoardController = fixture["board_controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	router.set_phase(ROUTER_SCRIPT.PHASE_LOCKED_EXTERNAL)
	if model.phase != ROUTER_SCRIPT.PHASE_LOCKED_EXTERNAL:
		return "Expected model phase to be locked external."
	if board_controller.input_enabled_values != [false]:
		return "Expected board input to be disabled while externally locked."
	if recorder.clear_hover_count != 1:
		return "Expected locked phase to clear combat mastery hover state."
	if recorder.statuses != ["Input locked: Settings open"]:
		return "Expected locked phase to report the model external lock reason."
	if recorder.sync_count != 1:
		return "Expected model sync after phase routing."
	return ""


func _fixture(reason: String = "") -> Dictionary:
	var model := FakeModel.new()
	model.reason = reason
	var board_controller := FakeBoardController.new()
	var recorder := CallbackRecorder.new()
	var router: Variant = ROUTER_SCRIPT.new()
	(
		router
		. bind(
			{"model": model, "board_controller": board_controller},
			{
				ROUTER_SCRIPT.CALLBACK_CLEAR_HOVER_STATE: Callable(recorder, "clear_hover_state"),
				ROUTER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
				ROUTER_SCRIPT.CALLBACK_SYNC_MODEL_STATE: Callable(recorder, "sync_model_state"),
			}
		)
	)
	return {
		"router": router,
		"model": model,
		"board_controller": board_controller,
		"recorder": recorder,
	}
