extends RefCounted
class_name CombatResolveFlowCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_resolve_flow_coordinator.gd")


class FakeModel:
	extends RefCounted

	var begin_trace_calls := 0
	var end_trace_calls := 0

	func begin_resolve_trace(_origin_usec: int, _active: bool) -> void:
		begin_trace_calls += 1

	func end_resolve_trace() -> void:
		end_trace_calls += 1


class FakeBoardController:
	extends RefCounted

	var handled := true
	var end_drag_calls := 0
	var reset_calls := 0
	var clear_calls := 0
	var commit_calls := 0
	var committed_model: BoardModel = null
	var visual_model := BoardModel.new()
	var simulation_model := BoardModel.new()

	func _init() -> void:
		visual_model.initialize(10)
		simulation_model.initialize(20)

	func end_drag(_timed_out: bool) -> Dictionary:
		end_drag_calls += 1
		return {"handled": handled}

	func reset_visuals() -> void:
		reset_calls += 1

	func clear_board_presentation() -> void:
		clear_calls += 1

	func prepare_visual_model_for_resolve() -> Dictionary:
		return {"visual_board_model": visual_model, "simulation_board_model": simulation_model}

	func commit_model_after_resolve(board_model: BoardModel) -> void:
		commit_calls += 1
		committed_model = board_model

	func current_board_model() -> BoardModel:
		return committed_model


class FakeResolver:
	extends RefCounted

	var calls := 0

	func resolve_all(_board_model: BoardModel) -> Dictionary:
		calls += 1
		return {"total_combos": 2, "passes": [{}, {}]}


class FakeMasteryPreview:
	extends RefCounted

	var reset_payload: Dictionary = {}

	func reset(payload: Dictionary) -> void:
		reset_payload = payload


class FakeTurnResolution:
	extends RefCounted

	var calls := 0

	func handle_resolved_board_turn(_phase: int, _resolve_result: Dictionary) -> Dictionary:
		calls += 1
		return {"stop": false, "route": "normal_turn"}


class Recorder:
	extends RefCounted

	var input_phase := 0
	var sfx: Array[String] = []
	var status_text := ""
	var status_color := Color.TRANSPARENT
	var phase_values: Array[int] = []
	var animations := 0
	var continues := 0
	var bound_mastery := 0
	var bound_turn_resolution := 0
	var committed_model: BoardModel = null
	var stored_result: Dictionary = {}
	var traces: Array[String] = []

	func play_sfx(key: String) -> void:
		sfx.append(key)

	func sync_timer_display(_seconds_left: float, _state: int) -> void:
		pass

	func set_status_text(text: String) -> void:
		status_text = text

	func set_status_color(color: Color) -> void:
		status_color = color

	func set_input_phase(value: int) -> void:
		input_phase = value
		phase_values.append(value)

	func bind_mastery_preview() -> void:
		bound_mastery += 1

	func play_resolve_animations(_result: Dictionary, _visual_model: BoardModel, _origin_usec: int) -> void:
		animations += 1

	func can_continue(_after_async: bool) -> bool:
		continues += 1
		return true

	func bind_turn_resolution() -> void:
		bound_turn_resolution += 1

	func input_phase_value() -> int:
		return input_phase

	func apply_board_model(board_model: BoardModel) -> void:
		committed_model = board_model

	func resolve_trace(_origin_usec: int, message: String) -> void:
		traces.append(message)

	func store_last_resolve_result(result: Dictionary) -> void:
		stored_result = result


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("handled_drag_runs_resolve_flow", _test_handled_drag_runs_resolve_flow, failures)
	_run_case("unhandled_drag_skips_resolve_flow", _test_unhandled_drag_skips_resolve_flow, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_handled_drag_runs_resolve_flow() -> String:
	var fixture := _fixture()
	fixture.recorder.input_phase = 10
	await fixture.coordinator.end_drag(false)
	if fixture.board_controller.commit_calls != 1:
		return "Expected handled drag to commit the resolved board model."
	if fixture.resolver.calls != 1 or fixture.turn_resolution.calls != 1:
		return "Expected handled drag to resolve board and route turn resolution."
	if fixture.recorder.stored_result.get("total_combos") != 2:
		return "Expected resolve result to be stored through callback."
	if fixture.recorder.committed_model != fixture.board_controller.simulation_model:
		return "Expected committed board model callback to receive controller model."
	if not fixture.recorder.traces.has("phase=final_board_commit board_seed=20"):
		return "Expected final board commit trace."
	return ""


func _test_unhandled_drag_skips_resolve_flow() -> String:
	var fixture := _fixture()
	fixture.recorder.input_phase = 10
	fixture.board_controller.handled = false
	await fixture.coordinator.end_drag(false)
	if fixture.resolver.calls != 0 or fixture.board_controller.commit_calls != 0:
		return "Expected unhandled drag to skip resolve and commit."
	if fixture.model.begin_trace_calls != 0:
		return "Expected unhandled drag not to begin resolve trace."
	return ""


func _fixture() -> Dictionary:
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	var model := FakeModel.new()
	var board_controller := FakeBoardController.new()
	var board_view := RefCounted.new()
	var board_model := BoardModel.new()
	board_model.initialize(5)
	var resolver := FakeResolver.new()
	var mastery_preview := FakeMasteryPreview.new()
	var turn_resolution := FakeTurnResolution.new()
	var recorder := Recorder.new()
	(
		coordinator
		. bind(
			{
				"model": model,
				"board_controller": board_controller,
				"board_view": board_view,
				"board_model": board_model,
				"resolver": resolver,
				"mastery_preview_coordinator": mastery_preview,
				"turn_resolution_coordinator": turn_resolution,
				"combat_modifiers": {"fire": 1},
			},
			{
				COORDINATOR_SCRIPT.CALLBACK_PLAY_SFX: Callable(recorder, "play_sfx"),
				COORDINATOR_SCRIPT.CALLBACK_SYNC_TIMER_DISPLAY: Callable(recorder, "sync_timer_display"),
				COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
				COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
				COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(recorder, "set_input_phase"),
				COORDINATOR_SCRIPT.CALLBACK_BIND_MASTERY_PREVIEW: Callable(recorder, "bind_mastery_preview"),
				COORDINATOR_SCRIPT.CALLBACK_PLAY_RESOLVE_ANIMATIONS: Callable(recorder, "play_resolve_animations"),
				COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: Callable(recorder, "can_continue"),
				COORDINATOR_SCRIPT.CALLBACK_BIND_TURN_RESOLUTION: Callable(recorder, "bind_turn_resolution"),
				COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(recorder, "input_phase_value"),
				COORDINATOR_SCRIPT.CALLBACK_APPLY_BOARD_MODEL: Callable(recorder, "apply_board_model"),
				COORDINATOR_SCRIPT.CALLBACK_RESOLVE_TRACE: Callable(recorder, "resolve_trace"),
				COORDINATOR_SCRIPT.CALLBACK_STORE_LAST_RESOLVE_RESULT: Callable(recorder, "store_last_resolve_result"),
			},
			{"player_input_phase_value": 10, "resolving_input_phase_value": 11, "timer_state_locked": 4, "status_color_warning": Color.YELLOW}
		)
	)
	return {
		"coordinator": coordinator,
		"model": model,
		"board_controller": board_controller,
		"resolver": resolver,
		"turn_resolution": turn_resolution,
		"recorder": recorder,
	}
