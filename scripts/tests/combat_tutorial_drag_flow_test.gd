extends RefCounted
class_name CombatTutorialDragFlowTest

const FLOW_SCRIPT := preload("res://scripts/combat/combat_tutorial_drag_flow.gd")
const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const WARNING_COLOR := Color(1.0, 0.86, 0.54, 1.0)


class FakeBoardModel:
	extends RefCounted

	var cell_value := 0

	func clone() -> FakeBoardModel:
		var copied := FakeBoardModel.new()
		copied.cell_value = cell_value
		return copied

	func get_cell(_column: int, _row: int) -> int:
		return cell_value

	func set_cell(_column: int, _row: int, value: int) -> void:
		cell_value = value


class FakeBoardController:
	extends RefCounted

	var model: Variant = null
	var seed := -1
	var abort_count := 0
	var reset_visuals_count := 0

	func abort() -> void:
		abort_count += 1

	func set_board_model(board_model: Variant) -> void:
		model = board_model

	func current_board_model() -> Variant:
		return model

	func board_seed() -> int:
		return seed

	func reset_visuals() -> void:
		reset_visuals_count += 1


class FakeCoachmarkCoordinator:
	extends RefCounted

	var path: Array[Vector2i] = []
	var retry_text := "Retry tutorial path."
	var sync_count := 0
	var hide_count := 0

	func active_drag_path() -> Array[Vector2i]:
		var copied: Array[Vector2i] = []
		copied.append_array(path)
		return copied

	func active_retry_status_text() -> String:
		return retry_text

	func sync() -> void:
		sync_count += 1

	func hide_coachmark() -> void:
		hide_count += 1


class CallbackRecorder:
	extends RefCounted

	var ended_drags: Array[bool] = []
	var board_seeds: Array[int] = []
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []
	var changed_models: Array[Variant] = []

	func end_drag(timed_out: bool) -> void:
		ended_drags.append(timed_out)

	func set_board_seed(board_seed: int) -> void:
		board_seeds.append(board_seed)

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)

	func board_model_changed(board_model: Variant) -> void:
		changed_models.append(board_model)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("failed_tutorial_drag_restores_snapshot", _test_failed_tutorial_drag_restores_snapshot, failures)
	_run_case("successful_tutorial_drag_hides_hint_and_ends_drag", _test_successful_tutorial_drag_hides_hint_and_ends_drag, failures)
	_run_case("reset_without_snapshot_uses_seed_fallback", _test_reset_without_snapshot_uses_seed_fallback, failures)
	_run_case("non_tutorial_drag_ends_directly", _test_non_tutorial_drag_ends_directly, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_failed_tutorial_drag_restores_snapshot() -> String:
	var fixture := _fixture(TUTORIAL_DIRECTOR_SCRIPT.FIRST_SWAP_PATH)
	var flow: Variant = fixture["flow"]
	var controller: FakeBoardController = fixture["board_controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var coachmark: FakeCoachmarkCoordinator = fixture["coachmark"]
	var initial_model: Variant = fixture["board_model"]
	initial_model.set_cell(0, 0, 10)
	flow.handle_start()
	initial_model.set_cell(0, 0, 20)
	flow.handle_end({"path": [Vector2i(4, 4)], "timed_out": false})
	if controller.abort_count != 1:
		return "Expected failed tutorial drag to abort active board controller drag."
	if controller.model == null or controller.model.get_cell(0, 0) != 10:
		return "Expected board controller model to restore the snapshot taken at drag start."
	if recorder.changed_models.size() != 1 or recorder.changed_models[0] != controller.model:
		return "Expected restored board model callback."
	if recorder.ended_drags.size() != 0:
		return "Expected failed tutorial drag to stop before ending the drag."
	if recorder.status_texts != [coachmark.retry_text] or recorder.status_colors != [WARNING_COLOR]:
		return "Expected retry status text and warning color."
	if coachmark.sync_count != 1:
		return "Expected failed tutorial drag to resync the coachmark."
	return ""


func _test_successful_tutorial_drag_hides_hint_and_ends_drag() -> String:
	var expected_path: Array[Vector2i] = TUTORIAL_DIRECTOR_SCRIPT.FIRST_SWAP_PATH
	var fixture := _fixture(expected_path)
	var flow: Variant = fixture["flow"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var coachmark: FakeCoachmarkCoordinator = fixture["coachmark"]
	flow.handle_start()
	flow.handle_end({"path": expected_path, "timed_out": true})
	if coachmark.hide_count != 1:
		return "Expected successful tutorial drag to hide coachmark."
	if recorder.ended_drags != [true]:
		return "Expected successful tutorial drag to forward timed_out to end drag."
	if not recorder.status_texts.is_empty():
		return "Expected no retry status on success."
	return ""


func _test_reset_without_snapshot_uses_seed_fallback() -> String:
	var fixture := _fixture(TUTORIAL_DIRECTOR_SCRIPT.FIRST_SWAP_PATH)
	var flow: Variant = fixture["flow"]
	var controller: FakeBoardController = fixture["board_controller"]
	var recorder: CallbackRecorder = fixture["recorder"]
	controller.seed = 4567
	flow.reset_incomplete_drag()
	if recorder.board_seeds != [4567]:
		return "Expected reset without snapshot to restore the current board seed."
	if controller.reset_visuals_count != 0:
		return "Expected seed fallback to avoid visual-only reset."
	return ""


func _test_non_tutorial_drag_ends_directly() -> String:
	var fixture := _fixture([])
	var flow: Variant = fixture["flow"]
	var recorder: CallbackRecorder = fixture["recorder"]
	flow.handle_end({"path": [], "timed_out": false})
	if recorder.ended_drags != [false]:
		return "Expected non-tutorial drag to end directly."
	return ""


func _fixture(path: Array[Vector2i]) -> Dictionary:
	var board_model := FakeBoardModel.new()
	var board_controller := FakeBoardController.new()
	board_controller.model = board_model
	var director: Variant = TUTORIAL_DIRECTOR_SCRIPT.new()
	var coachmark := FakeCoachmarkCoordinator.new()
	coachmark.path = path
	var recorder := CallbackRecorder.new()
	var flow: Variant = FLOW_SCRIPT.new()
	(
		flow
		. bind(
			{
				"board_model": board_model,
				"board_controller": board_controller,
				"tutorial_director": director,
				"coachmark_coordinator": coachmark,
			},
			{
				FLOW_SCRIPT.CALLBACK_END_DRAG: Callable(recorder, "end_drag"),
				FLOW_SCRIPT.CALLBACK_SET_BOARD_SEED: Callable(recorder, "set_board_seed"),
				FLOW_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
				FLOW_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
				FLOW_SCRIPT.CALLBACK_BOARD_MODEL_CHANGED: Callable(recorder, "board_model_changed"),
			},
			{"warning_status_color": WARNING_COLOR}
		)
	)
	return {
		"flow": flow,
		"board_model": board_model,
		"board_controller": board_controller,
		"director": director,
		"coachmark": coachmark,
		"recorder": recorder,
	}
