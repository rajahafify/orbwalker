extends RefCounted
class_name CombatControllerHudUpdateRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_hud_update_router.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeHudPresenter:
	extends RefCounted

	var build_inputs: Array[Dictionary] = []

	func build_hud_snapshot(data: Dictionary) -> Dictionary:
		build_inputs.append(data)
		return {"from_presenter": true, "data": data}


class FakeSnapshotProvider:
	extends RefCounted

	var bind_args: Array = []
	var snapshot := {"from_provider": true}

	func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
		bind_args = [dependencies, callbacks, config]

	func build_snapshot() -> Dictionary:
		return snapshot


class FakeView:
	extends RefCounted

	var applied_snapshots: Array[Dictionary] = []
	var applied_callbacks: Array[Dictionary] = []

	func apply_hud_snapshot(snapshot: Dictionary, callbacks: Dictionary = {}) -> void:
		applied_snapshots.append(snapshot)
		applied_callbacks.append(callbacks)


class FakeRefreshCoordinator:
	extends RefCounted

	var snapshots: Array[Dictionary] = []

	func refresh_build_icon_rows(progression_snapshot: Dictionary) -> void:
		snapshots.append(progression_snapshot)


class FakeInputRouter:
	extends RefCounted

	func drag_active() -> bool:
		return false

	func drag_move_time_left() -> float:
		return 0.0

	func timer_ready_seconds() -> float:
		return 12.0


class FakeOwner:
	extends RefCounted

	enum InputPhase { PLAYER_INPUT, RESOLVING, LOCKED_EXTERNAL }

	const CONTRACT := CombatControllerHudUpdateRouterTest.CONTRACT

	var _hud_presenter: Variant = FakeHudPresenter.new()
	var _hud_snapshot_provider: Variant = FakeSnapshotProvider.new()
	var _player_hud_refresh_coordinator: Variant = FakeRefreshCoordinator.new()
	var _input_router: Variant = FakeInputRouter.new()
	var _player_state: Variant = "player"
	var _enemy_state: Variant = "enemy"
	var _combat: Variant = "combat"
	var _model: Variant = "model"
	var _view: Variant = FakeView.new()
	var _visuals: Variant = "visuals"
	var _turn_log_presenter: Variant = "turn_log"
	var bind_refresh_calls := 0

	func _input_phase_value() -> int:
		return InputPhase.PLAYER_INPUT

	func _should_show_intent_damage_preview() -> bool:
		return true

	func _bind_input_router() -> void:
		pass

	func _bind_player_hud_refresh_coordinator() -> void:
		bind_refresh_calls += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("update_hud_builds_and_applies_snapshot", _test_update_hud_builds_and_applies_snapshot, failures)
	_run_case("refresh_build_icon_rows_uses_refresh_coordinator", _test_refresh_build_icon_rows_uses_refresh_coordinator, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_update_hud_builds_and_applies_snapshot() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.update_hud()

	var presenter: FakeHudPresenter = owner._hud_presenter
	var provider: FakeSnapshotProvider = owner._hud_snapshot_provider
	var view: FakeView = owner._view
	if provider.bind_args.is_empty():
		return "Expected update_hud to bind the snapshot provider."
	if presenter.build_inputs != [provider.snapshot]:
		return "Expected update_hud to pass provider snapshot into HUD presenter."
	if view.applied_snapshots.size() != 1 or not bool(view.applied_snapshots[0].get("from_presenter", false)):
		return "Expected update_hud to apply the presenter snapshot to the view."
	var callbacks: Dictionary = view.applied_callbacks[0]
	if not (callbacks.get("refresh_build_icon_rows") is Callable):
		return "Expected update_hud to provide the refresh_build_icon_rows callback."
	return ""


func _test_refresh_build_icon_rows_uses_refresh_coordinator() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.refresh_build_icon_rows({"mastery_levels": {"fire": 2}})

	var coordinator: FakeRefreshCoordinator = owner._player_hud_refresh_coordinator
	if owner.bind_refresh_calls != 1:
		return "Expected refresh_build_icon_rows to ensure the refresh coordinator is bound."
	if coordinator.snapshots != [{"mastery_levels": {"fire": 2}}]:
		return "Expected refresh_build_icon_rows to forward the progression snapshot."
	return ""
