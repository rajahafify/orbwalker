extends RefCounted
class_name CombatControllerLifecycleTest

const LIFECYCLE_SCRIPT := preload("res://scripts/combat/combat_controller_lifecycle.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeStateInitializer:
	extends RefCounted

	var bind_args: Array = []
	var initialize_calls := 0

	func bind(dependencies: Dictionary, callbacks: Dictionary) -> void:
		bind_args = [dependencies, callbacks]

	func initialize() -> void:
		initialize_calls += 1


class FakePresentationRouter:
	extends RefCounted

	func refresh_character_portraits() -> void:
		pass


class FakeInputRouter:
	extends RefCounted

	func clear_combat_mastery_hover_state() -> void:
		pass


class FakeOwner:
	extends RefCounted

	const CONTRACT := CombatControllerLifecycleTest.CONTRACT

	var _hud_update_router := FakeHudUpdateRouter.new()
	var _presentation_router := FakePresentationRouter.new()
	var _input_router := FakeInputRouter.new()
	var _view_actions := RefCounted.new()
	var _state_initializer := FakeStateInitializer.new()
	var _model: Variant = "model"
	var _host: Variant = "host"
	var _debug_runtime: Variant = "debug_runtime"
	var _player_state: Variant = null
	var _progression_state: Variant = null
	var _enemy_state: Variant = null
	var _combat: Variant = null
	var _board_model: Variant = null
	var _last_resolve_result: Dictionary = {}
	var bind_hud_stage_calls := 0

	func _bind_hud_stage_coordinator() -> void:
		bind_hud_stage_calls += 1

	func _bind_hud_update_router() -> void:
		pass

	func _bind_presentation_router() -> void:
		pass

	func _bind_input_router() -> void:
		pass

	func _refresh_build_icon_rows() -> void:
		pass

	func _update_hud() -> void:
		pass

	func _bind_debug_state_provider() -> void:
		pass

	func _flow_trace_route_id_value() -> String:
		return "route"

	func _on_combat_scene_post_ready_rollback() -> void:
		pass

	func _handle_combat_scene_change_failure() -> void:
		pass


class FakeHudUpdateRouter:
	extends RefCounted

	var update_calls := 0
	var refresh_calls: Array[Dictionary] = []

	func update_hud() -> void:
		update_calls += 1

	func refresh_build_icon_rows(snapshot: Dictionary) -> void:
		refresh_calls.append(snapshot)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("state_initializer_binds_and_applies_state", _test_state_initializer_binds_and_applies_state, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_state_initializer_binds_and_applies_state() -> String:
	var owner := FakeOwner.new()
	var lifecycle: Variant = LIFECYCLE_SCRIPT.new()
	lifecycle.bind(owner)

	lifecycle._bind_state_initializer()
	var initializer: FakeStateInitializer = owner._state_initializer
	var dependencies: Dictionary = initializer.bind_args[0]
	var callbacks: Dictionary = initializer.bind_args[1]
	if dependencies.get("model") != "model" or dependencies.get("host") != "host":
		return "Expected state initializer dependencies to come from owner access helpers."
	if callbacks.get("debug_runtime") != "debug_runtime":
		return "Expected debug runtime to be forwarded through callback map."
	var apply_callback: Callable = callbacks.get(CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_APPLY_STATE)
	if not apply_callback.is_valid():
		return "Expected apply-state callback to be bound."
	apply_callback.call({"player_state": "player", "progression_state": "progression", "enemy_state": "enemy", "combat": "combat"})
	if owner._player_state != "player" or owner._progression_state != "progression" or owner._enemy_state != "enemy" or owner._combat != "combat":
		return "Expected initialized combat state to be written back to owner."

	lifecycle.initialize_combat_state()
	if initializer.initialize_calls != 1:
		return "Expected initialize_combat_state to call the bound initializer."

	var board_model := BoardModel.new()
	lifecycle._apply_committed_board_model(board_model)
	lifecycle._store_last_resolve_result({"ok": true})
	if owner._board_model != board_model or not bool(owner._last_resolve_result.get("ok", false)):
		return "Expected lifecycle setter callbacks to update owner state."
	return ""
