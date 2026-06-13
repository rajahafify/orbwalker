extends RefCounted
class_name CombatControllerInputRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_input_router.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeTimerService:
	extends RefCounted

	var process_calls: Array[Dictionary] = []
	var drag_is_active := false
	var process_result: Dictionary = {}

	func process(board_controller: Variant, view: Variant, player_state: Variant, delta: float, player_input: bool) -> Dictionary:
		(
			process_calls
			. append(
				{
					"board_controller": board_controller,
					"view": view,
					"player_state": player_state,
					"delta": delta,
					"player_input": player_input,
				}
			)
		)
		return process_result.duplicate(true)

	func drag_active(_board_controller: Variant) -> bool:
		return drag_is_active

	func move_time_left(_board_controller: Variant) -> float:
		return 2.5

	func ready_seconds(_player_state: Variant) -> float:
		return 8.0


class FakeViewActions:
	extends RefCounted

	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []

	func set_status_text(text: String) -> void:
		status_texts.append(text)

	func set_status_color(color: Color) -> void:
		status_colors.append(color)


class FakeView:
	extends RefCounted

	var timer_syncs: Array[Dictionary] = []

	func sync_timer_display(seconds_left: float, timer_state: String) -> void:
		timer_syncs.append({"seconds_left": seconds_left, "timer_state": timer_state})


class FakeMasteryPreviewCoordinator:
	extends RefCounted

	var cleared := 0
	var hovered_orbs: Array[int] = []

	func clear_hover_state() -> void:
		cleared += 1

	func set_hovered_board_orb_id(orb_id: int) -> void:
		hovered_orbs.append(orb_id)


class FakeTutorialDragFlow:
	extends RefCounted

	var start_calls := 0
	var end_results: Array[Dictionary] = []

	func handle_start() -> void:
		start_calls += 1

	func handle_end(result: Dictionary) -> void:
		end_results.append(result)


class FakeTutorialRouter:
	extends RefCounted

	var bind_drag_flow_calls := 0

	func bind_drag_flow() -> void:
		bind_drag_flow_calls += 1


class FakeDebugRuntime:
	extends RefCounted

	var toggled := 0

	func toggle_overlay() -> void:
		toggled += 1


class FakeHudUpdateRouter:
	extends RefCounted

	var update_calls := 0

	func update_hud() -> void:
		update_calls += 1


class FakeModel:
	extends RefCounted

	var pending_paths: Array[String] = []

	func set_pending_next_scene_path(scene_path: String) -> void:
		pending_paths.append(scene_path)


class FakeOwner:
	extends RefCounted

	enum InputPhase { PLAYER_INPUT, RESOLVING, LOCKED_EXTERNAL }

	const CONTRACT := CombatControllerInputRouterTest.CONTRACT

	var _combat_timer_service: Variant = FakeTimerService.new()
	var _board_controller: Variant = "board_controller"
	var _view: Variant = FakeView.new()
	var _player_state: Variant = "player"
	var _view_actions: Variant = FakeViewActions.new()
	var _mastery_preview_coordinator: Variant = FakeMasteryPreviewCoordinator.new()
	var _tutorial_drag_flow: Variant = FakeTutorialDragFlow.new()
	var _tutorial_router: Variant = FakeTutorialRouter.new()
	var _debug_runtime: Variant = FakeDebugRuntime.new()
	var _hud_update_router: Variant = FakeHudUpdateRouter.new()
	var _model: Variant = FakeModel.new()
	var bind_view_actions_calls := 0
	var bind_mastery_calls := 0
	var bind_tutorial_router_calls := 0
	var bind_hud_calls := 0
	var set_input_phase_calls: Array[int] = []
	var input_phase := InputPhase.PLAYER_INPUT

	func _input_phase_value() -> int:
		return input_phase

	func _bind_view_actions() -> void:
		bind_view_actions_calls += 1

	func _bind_mastery_preview_coordinator() -> void:
		bind_mastery_calls += 1

	func _bind_tutorial_router() -> void:
		bind_tutorial_router_calls += 1

	func _bind_hud_update_router() -> void:
		bind_hud_calls += 1

	func _set_input_phase(raw_phase: int) -> void:
		set_input_phase_calls.append(raw_phase)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("process_forwards_timer_updates", _test_process_forwards_timer_updates, failures)
	_run_case("process_routes_timer_expiry_end_drag", _test_process_routes_timer_expiry_end_drag, failures)
	_run_case("start_and_end_drag_routes_to_tutorial_flow", _test_start_and_end_drag_routes_to_tutorial_flow, failures)
	_run_case("toggle_debug_overlay_refreshes_hud", _test_toggle_debug_overlay_refreshes_hud, failures)
	_run_case("debug_callbacks_forward_to_model_and_phase_router", _test_debug_callbacks_forward_to_model_and_phase_router, failures)
	return {"passed": failures.is_empty(), "total": 5, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_process_forwards_timer_updates() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.process(0.25)

	var timer: FakeTimerService = owner._combat_timer_service
	if timer.process_calls.size() != 1:
		return "Expected process to call the combat timer service."
	if not bool(timer.process_calls[0].get("player_input")):
		return "Expected process to mark player input phase as active."
	return ""


func _test_process_routes_timer_expiry_end_drag() -> String:
	var owner := FakeOwner.new()
	owner._combat_timer_service.process_result = {"handled": true, "action": "end", "timed_out": true, "path": [Vector2i(2, 2)]}
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.process(0.25)

	var tutorial: FakeTutorialDragFlow = owner._tutorial_drag_flow
	if tutorial.end_results != [{"handled": true, "action": "end", "timed_out": true, "path": [Vector2i(2, 2)]}]:
		return "Expected timer-expiry end result to route through tutorial drag flow."
	return ""


func _test_start_and_end_drag_routes_to_tutorial_flow() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.handle_drag_input_result({"action": "start", "selected_orb_id": OrbType.Id.FIRE})
	router.handle_drag_input_result({"action": "end", "ok": true})

	var tutorial: FakeTutorialDragFlow = owner._tutorial_drag_flow
	var tutorial_router: FakeTutorialRouter = owner._tutorial_router
	var mastery: FakeMasteryPreviewCoordinator = owner._mastery_preview_coordinator
	var view: FakeView = owner._view
	if mastery.cleared != 1:
		return "Expected start-drag to clear mastery hover state."
	if tutorial.start_calls != 1:
		return "Expected start-drag to notify the tutorial drag flow."
	if tutorial.end_results != [{"action": "end", "ok": true}]:
		return "Expected end-drag to forward the drag result."
	if owner.bind_tutorial_router_calls != 2 or tutorial_router.bind_drag_flow_calls != 2:
		return "Expected drag start/end to bind tutorial flow through the tutorial router."
	if view.timer_syncs.size() != 1 or view.timer_syncs[0].get("seconds_left") != 2.5:
		return "Expected start-drag to refresh the timer display with remaining drag time."
	return ""


func _test_toggle_debug_overlay_refreshes_hud() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.toggle_debug_overlay()

	if owner._debug_runtime.toggled != 1:
		return "Expected toggle_debug_overlay to toggle debug runtime overlay state."
	if owner._hud_update_router.update_calls != 1:
		return "Expected toggle_debug_overlay to refresh HUD through the HUD update router."
	return ""


func _test_debug_callbacks_forward_to_model_and_phase_router() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.debug_set_input_phase(FakeOwner.InputPhase.LOCKED_EXTERNAL)
	router.debug_set_pending_next_scene_path("res://scenes/main_menu.tscn")

	var model: FakeModel = owner._model
	if owner.set_input_phase_calls != [FakeOwner.InputPhase.LOCKED_EXTERNAL]:
		return "Expected debug_set_input_phase to forward the raw phase to the owner phase setter."
	if model.pending_paths != ["res://scenes/main_menu.tscn"]:
		return "Expected debug_set_pending_next_scene_path to update the combat model."
	return ""
