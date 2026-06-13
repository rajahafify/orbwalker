extends RefCounted
class_name CombatControllerTutorialRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_tutorial_router.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeTutorialDirector:
	extends RefCounted

	func turn_summary_text() -> String:
		return "summary"

	func turn_status_text(turn_index: int) -> String:
		return "turn:%d" % turn_index


class FakeCombat:
	extends RefCounted

	var turn_index := 4


class FakePromptPresenter:
	extends RefCounted


class FakeCoachmarkCoordinator:
	extends RefCounted

	const CALLBACK_INPUT_PHASE_VALUE := &"input_phase_value"
	const CALLBACK_SET_STATUS_TEXT := &"set_status_text"
	const CALLBACK_SET_STATUS_COLOR := &"set_status_color"

	var bind_args: Array = []
	var sync_calls := 0

	func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> void:
		bind_args = [dependencies, callbacks, config]

	func sync() -> void:
		sync_calls += 1


class FakeTutorialDragFlow:
	extends RefCounted

	const CALLBACK_END_DRAG := &"end_drag"
	const CALLBACK_SET_BOARD_SEED := &"set_board_seed"
	const CALLBACK_SET_STATUS_TEXT := &"set_status_text"
	const CALLBACK_SET_STATUS_COLOR := &"set_status_color"
	const CALLBACK_BOARD_MODEL_CHANGED := &"board_model_changed"

	var bind_args: Array = []

	func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> void:
		bind_args = [dependencies, callbacks, config]


class FakeRuntimeBinder:
	extends RefCounted

	static func bind_tutorial_prompt_presenter(current: Variant, _script: Variant, _host: Variant) -> Variant:
		return current if current != null else FakePromptPresenter.new()


class FakeContract:
	extends RefCounted

	const COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT := FakeRuntimeBinder
	const COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT := FakePromptPresenter
	const COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT := FakeCoachmarkCoordinator
	const COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT := FakeTutorialDragFlow
	const STATUS_COLOR_WARNING := Color(1, 0, 0, 1)


class FakeViewActions:
	extends RefCounted

	func set_status_text(_text: String) -> void:
		pass

	func set_status_color(_color: Color) -> void:
		pass


class FakeBoardDebugRouter:
	extends RefCounted

	func set_board_seed(_seed: int) -> void:
		pass


class FakeOwner:
	extends RefCounted

	enum InputPhase { PLAYER_INPUT, RESOLVING, LOCKED_EXTERNAL }

	const CONTRACT := FakeContract

	var _tutorial_director: Variant = FakeTutorialDirector.new()
	var _combat: Variant = FakeCombat.new()
	var _tutorial_prompt_presenter: Variant = null
	var _tutorial_coachmark_coordinator: Variant = null
	var _tutorial_drag_flow: Variant = null
	var _host: Variant = "host"
	var _view_actions: Variant = FakeViewActions.new()
	var _board_debug_router: Variant = FakeBoardDebugRouter.new()
	var _board_model: Variant = "board_model"
	var _board_controller: Variant = "board_controller"
	var _view: Variant = "view"
	var _board_view: Variant = "board_view"
	var _input_phase := InputPhase.PLAYER_INPUT

	func _input_phase_value() -> int:
		return _input_phase

	func _end_drag(_drag_result: Dictionary) -> void:
		pass

	func _board_debug_callback(method_name: String) -> Callable:
		return Callable(_board_debug_router, method_name)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("text_callbacks_use_tutorial_director", _test_text_callbacks_use_tutorial_director, failures)
	_run_case("coachmark_and_drag_flow_bind_dependencies", _test_coachmark_and_drag_flow_bind_dependencies, failures)
	_run_case("drag_flow_can_write_board_model", _test_drag_flow_can_write_board_model, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_text_callbacks_use_tutorial_director() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	if router.turn_summary_text() != "summary":
		return "Expected tutorial summary text from director."
	if router.turn_status_text() != "turn:4":
		return "Expected tutorial status text with combat turn index."
	return ""


func _test_coachmark_and_drag_flow_bind_dependencies() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.sync_coachmark()
	router.bind_drag_flow()

	var coachmark: FakeCoachmarkCoordinator = owner._tutorial_coachmark_coordinator
	var drag_flow: FakeTutorialDragFlow = owner._tutorial_drag_flow
	if coachmark.sync_calls != 1:
		return "Expected sync_coachmark to sync the coordinator."
	if coachmark.bind_args.is_empty() or coachmark.bind_args[0].get("prompt_presenter") == null:
		return "Expected coachmark coordinator to receive prompt presenter dependency."
	if drag_flow.bind_args.is_empty() or drag_flow.bind_args[0].get("coachmark_coordinator") != coachmark:
		return "Expected drag flow to receive coachmark coordinator dependency."
	var callbacks: Dictionary = drag_flow.bind_args[1]
	if not (callbacks.get(CONTRACT.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_BOARD_MODEL_CHANGED) is Callable):
		return "Expected drag flow to receive board-model changed callback."
	return ""


func _test_drag_flow_can_write_board_model() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)
	var board_model := BoardModel.new()

	router.set_board_model_from_drag_flow(board_model)

	if owner._board_model != board_model:
		return "Expected tutorial router to write tutorial drag board model back to owner."
	return ""
