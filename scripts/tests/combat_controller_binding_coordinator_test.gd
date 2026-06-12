extends RefCounted
class_name CombatControllerBindingCoordinatorTest

const BINDING_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_controller_binding_coordinator.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeViewActions:
	extends RefCounted

	func set_status_text(_text: String) -> void:
		pass


class FakeInputPhaseRouter:
	extends RefCounted

	var bind_args: Array = []

	func bind(dependencies: Dictionary, callbacks: Dictionary) -> void:
		bind_args = [dependencies, callbacks]


class FakeInputRouter:
	extends RefCounted

	func clear_combat_mastery_hover_state() -> void:
		pass

	func drag_active() -> bool:
		return false

	func abort_active_drag() -> void:
		pass


class FakeOwner:
	extends RefCounted

	enum InputPhase { PLAYER_INPUT, RESOLVING, LOCKED_EXTERNAL }

	const CONTRACT := CombatControllerBindingCoordinatorTest.CONTRACT

	var _view_actions := FakeViewActions.new()
	var _input_phase_router: Variant = FakeInputPhaseRouter.new()
	var _input_router: Variant = FakeInputRouter.new()
	var _model: Variant = "model"
	var _board_controller: Variant = "board"
	var ensured_model_calls := 0

	func _ensure_model() -> Variant:
		ensured_model_calls += 1
		return _model

	func _sync_model_state() -> void:
		pass

	func _bind_input_router() -> void:
		pass


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("bind_input_phase_router_uses_owner_access_surface", _test_bind_input_phase_router_uses_owner_access_surface, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_bind_input_phase_router_uses_owner_access_surface() -> String:
	var owner := FakeOwner.new()
	var coordinator: Variant = BINDING_COORDINATOR_SCRIPT.new()
	coordinator.bind(owner)
	coordinator.bind_input_phase_router()

	if owner.ensured_model_calls != 1:
		return "Expected input router bind to use owner model provider callback."
	var router: FakeInputPhaseRouter = owner._input_phase_router
	var dependencies: Dictionary = router.bind_args[0]
	var callbacks: Dictionary = router.bind_args[1]
	if dependencies.get("model") != "model" or dependencies.get("board_controller") != owner._board_controller:
		return "Expected input router dependencies to be forwarded."
	if not callbacks.has(CONTRACT.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_CLEAR_HOVER_STATE):
		return "Expected input router clear-hover callback key."
	if not callbacks.has(CONTRACT.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_ABORT_ACTIVE_DRAG):
		return "Expected input router abort-drag callback key."
	return ""
