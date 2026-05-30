extends RefCounted
class_name ShopTransitionHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/shop/shop_transition_handler.gd")


class FakeRunState:
	extends RefCounted

	var marks: Array[Dictionary] = []
	var begins: Array[Dictionary] = []
	var changes: Array[Dictionary] = []
	var next_scene_change_result: Variant = OK
	var transition_result := {"ok": true, "next_scene": "res://scenes/combat.tscn", "step": "enemy_2"}
	var snapshot := {"step": "shop"}
	var restored_snapshots: Array[Dictionary] = []

	func flow_trace_mark(step: String, payload: Dictionary, route_id: String, target_scene: String = "") -> void:
		marks.append({
			"step": step,
			"payload": payload,
			"route_id": route_id,
			"target_scene": target_scene,
		})

	func flow_trace_begin(kind: String, target_scene: String, payload: Dictionary) -> String:
		var route_id := "%s-route-%d" % [kind, begins.size() + 1]
		begins.append({
			"kind": kind,
			"target_scene": target_scene,
			"payload": payload,
			"route_id": route_id,
		})
		return route_id

	func flow_trace_change_scene(
		tree: SceneTree,
		target_scene: String,
		route_id: String,
		source: String,
		_load_token: String = "",
		rollback_callback: Callable = Callable(),
		rollback_payload: Dictionary = {}
	) -> Variant:
		changes.append({
			"tree": tree,
			"target_scene": target_scene,
			"route_id": route_id,
			"source": source,
			"rollback_callback_valid": rollback_callback.is_valid(),
			"rollback_payload": rollback_payload,
		})
		return next_scene_change_result

	func snapshot_run_transition_state() -> Dictionary:
		return snapshot.duplicate()

	func restore_run_transition_state(value: Dictionary) -> void:
		restored_snapshots.append(value.duplicate())

	func advance_after_shop(_skip: bool) -> Dictionary:
		return transition_result.duplicate()


class FakeModel:
	extends RefCounted

	var transition_locked := false
	var begin_count := 0
	var end_count := 0

	func begin_transition_lock() -> void:
		transition_locked = true
		begin_count += 1

	func end_transition_lock() -> void:
		transition_locked = false
		end_count += 1


class FakeView:
	extends RefCounted

	var locks: Array[bool] = []

	func lock_transitions(locked: bool) -> void:
		locks.append(locked)


class CallbackRecorder:
	extends RefCounted

	var statuses: Array[Dictionary] = []
	var clear_count := 0
	var refresh_count := 0
	var tutorial_phase := ""
	var tutorial_status := "Tutorial: continue to the next fight."

	func set_status(message: String, positive: bool) -> void:
		statuses.append({
			"message": message,
			"positive": positive,
		})

	func clear_inventory_focus() -> void:
		clear_count += 1

	func tutorial_shop_phase() -> String:
		return tutorial_phase

	func tutorial_shop_status() -> String:
		return tutorial_status

	func refresh_ui() -> void:
		refresh_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("continue_blocks_on_tutorial_phase", _test_continue_blocks_on_tutorial_phase, failures)
	_run_case("continue_routes_to_combat_with_new_route", _test_continue_routes_to_combat_with_new_route, failures)
	_run_case("continue_failure_restores_snapshot_and_unlocks", _test_continue_failure_restores_snapshot_and_unlocks, failures)
	_run_case("main_menu_routes_with_current_route", _test_main_menu_routes_with_current_route, failures)
	_run_case("post_ready_rollback_reports_failure_and_unlocks", _test_post_ready_rollback_reports_failure_and_unlocks, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_continue_blocks_on_tutorial_phase() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var model: FakeModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	recorder.tutorial_phase = "reroll"

	handler.continue_pressed()
	if recorder.statuses.size() != 1 or String(recorder.statuses[0].get("message", "")) != recorder.tutorial_status:
		return "Expected tutorial-blocked continue to show the tutorial status."
	if bool(recorder.statuses[0].get("positive", true)):
		return "Expected tutorial-blocked continue to report a negative status."
	if recorder.refresh_count != 1:
		return "Expected tutorial-blocked continue to refresh the UI."
	if model.begin_count != 0:
		return "Expected tutorial-blocked continue not to begin a transition."
	return ""


func _test_continue_routes_to_combat_with_new_route() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var model: FakeModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]

	handler.continue_pressed()
	if model.begin_count != 1 or not model.transition_locked:
		return "Expected continue to lock transitions while changing scene."
	if view.locks != [true]:
		return "Expected continue to lock the view."
	if recorder.clear_count != 1:
		return "Expected continue to clear inventory focus."
	if run_state.begins.size() != 1 or String(run_state.begins[0].get("kind", "")) != "shop_to_combat":
		return "Expected combat transition to begin a shop_to_combat route."
	if run_state.changes.size() != 1:
		return "Expected continue to dispatch one scene change."
	var change := run_state.changes[0]
	if String(change.get("target_scene", "")) != "res://scenes/combat.tscn":
		return "Expected continue to target combat."
	if String(change.get("route_id", "")) != String(run_state.begins[0].get("route_id", "")):
		return "Expected continue to use the new combat route id."
	if String(change.get("source", "")) != "shop_continue_button":
		return "Expected continue to preserve its trace source."
	if Dictionary(change.get("rollback_payload", {})).get("step", "") != "shop":
		return "Expected continue to pass the pre-transition snapshot as rollback payload."
	return ""


func _test_continue_failure_restores_snapshot_and_unlocks() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var model: FakeModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	run_state.next_scene_change_result = ERR_CANT_OPEN

	handler.continue_pressed()
	if run_state.restored_snapshots != [{"step": "shop"}]:
		return "Expected failed continue to restore the pre-transition snapshot."
	if model.end_count != 1 or model.transition_locked:
		return "Expected failed continue to unlock transitions."
	if view.locks != [true, false]:
		return "Expected failed continue to unlock the view."
	if recorder.statuses.is_empty() or String(recorder.statuses.back().get("message", "")).find("Continue failed:") != 0:
		return "Expected failed continue to report a continue failure."
	return ""


func _test_main_menu_routes_with_current_route() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]

	handler.main_menu_pressed()
	if recorder.clear_count != 1:
		return "Expected main-menu command to clear inventory focus."
	if not run_state.begins.is_empty():
		return "Expected main-menu command to reuse the current route."
	if run_state.changes.size() != 1:
		return "Expected main-menu command to dispatch one scene change."
	var change := run_state.changes[0]
	if String(change.get("target_scene", "")) != HANDLER_SCRIPT.SCENE_MAIN_MENU:
		return "Expected main-menu command to target the main menu scene."
	if String(change.get("route_id", "")) != "shop-route":
		return "Expected main-menu command to preserve the current route id."
	if String(change.get("source", "")) != "shop_main_menu_button":
		return "Expected main-menu command to preserve its trace source."
	return ""


func _test_post_ready_rollback_reports_failure_and_unlocks() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var model: FakeModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	model.begin_transition_lock()
	view.lock_transitions(true)

	handler.on_scene_change_post_ready_rollback({
		"reason": "post_ready_failed",
		"source": "test_source",
		"route_id": "rollback-route",
		"target_scene": "res://scenes/combat.tscn",
	})
	if recorder.statuses.size() != 1 or String(recorder.statuses[0].get("message", "")) != "Transition failed: post_ready_failed":
		return "Expected rollback to report the failure reason."
	if model.end_count != 1 or model.transition_locked:
		return "Expected rollback to unlock transitions."
	if view.locks != [true, false]:
		return "Expected rollback to unlock the view."
	if run_state.marks.is_empty() or String(run_state.marks.back().get("route_id", "")) != "rollback-route":
		return "Expected rollback to mark the supplied route id."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var model := FakeModel.new()
	var view := FakeView.new()
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		{
			"run_state": run_state,
			"host": null,
			"model": model,
			"view": view,
		},
		{
			HANDLER_SCRIPT.CALLBACK_SET_STATUS: Callable(recorder, "set_status"),
			HANDLER_SCRIPT.CALLBACK_CLEAR_INVENTORY_FOCUS: Callable(recorder, "clear_inventory_focus"),
			HANDLER_SCRIPT.CALLBACK_TUTORIAL_SHOP_PHASE: Callable(recorder, "tutorial_shop_phase"),
			HANDLER_SCRIPT.CALLBACK_TUTORIAL_SHOP_STATUS: Callable(recorder, "tutorial_shop_status"),
			HANDLER_SCRIPT.CALLBACK_REFRESH_UI: Callable(recorder, "refresh_ui"),
		},
		{"route_id": "shop-route"}
	)
	return {
		"handler": handler,
		"run_state": run_state,
		"model": model,
		"view": view,
		"recorder": recorder,
	}
