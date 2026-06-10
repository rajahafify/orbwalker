extends RefCounted
class_name CombatSceneTransitionHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_scene_transition_handler.gd")
const NEGATIVE_COLOR := Color(1.0, 0.62, 0.62, 1.0)


class FakeRunState:
	extends RefCounted

	var begin_calls: Array[Dictionary] = []
	var marks: Array[Dictionary] = []
	var change_calls: Array[Dictionary] = []
	var change_result: Variant = {"ok": true}
	var next_route_id := "route-shop-2"

	func flow_trace_begin(route_name: String, target_scene: String, details: Dictionary = {}) -> String:
		begin_calls.append({
			"route_name": route_name,
			"target_scene": target_scene,
			"details": details.duplicate(true),
		})
		return next_route_id

	func flow_trace_mark(step: String, details: Dictionary = {}, route_id: String = "", target_scene_override: String = "") -> void:
		marks.append({
			"step": step,
			"details": details.duplicate(true),
			"route_id": route_id,
			"target_scene": target_scene_override,
		})

	func flow_trace_change_scene(tree, target_scene: String, route_id: String, source: String, before_step: String, rollback_callback: Callable) -> Variant:
		change_calls.append({
			"tree": tree,
			"target_scene": target_scene,
			"route_id": route_id,
			"source": source,
			"before_step": before_step,
			"rollback_valid": rollback_callback.is_valid(),
		})
		return change_result


class FakeModel:
	extends RefCounted

	var pending_scene := ""
	var clear_count := 0

	func set_pending_next_scene_path(scene_path: String) -> void:
		pending_scene = scene_path

	func clear_outcome_transition_queued() -> void:
		clear_count += 1


class CallbackRecorder:
	extends RefCounted

	var current_route := "route-current"
	var lock_count := 0
	var summaries: Array[Dictionary] = []
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []
	var log_lines: Array[String] = []

	func current_route_id() -> String:
		return current_route

	func lock_external_input() -> void:
		lock_count += 1

	func show_outcome_summary(title: String, body: String, show_next: bool, button_text: String) -> void:
		summaries.append({
			"title": title,
			"body": body,
			"show_next": show_next,
			"button_text": button_text,
		})

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)

	func append_combat_log(value: String) -> void:
		log_lines.append(value)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("shop_transition_starts_combat_to_shop_route", _test_shop_transition_starts_combat_to_shop_route, failures)
	_run_case("non_shop_transition_reuses_current_route", _test_non_shop_transition_reuses_current_route, failures)
	_run_case("failed_transition_restores_pending_scene_and_reports", _test_failed_transition_restores_pending_scene_and_reports, failures)
	_run_case("rollback_failure_uses_result_details_and_current_route_fallback", _test_rollback_failure_uses_result_details_and_current_route_fallback, failures)
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


func _test_shop_transition_starts_combat_to_shop_route() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	handler.trace_and_change_scene_to_target(
		"res://scenes/shop.tscn",
		"route-1",
		"boss_reward",
		"before_shop",
		{"reward": "relic"}
	)
	if run_state.begin_calls.size() != 1:
		return "Expected shop transition to begin a combat_to_shop route."
	var begin_call := run_state.begin_calls[0]
	if begin_call.get("route_name") != "combat_to_shop" or begin_call.get("target_scene") != "res://scenes/shop.tscn":
		return "Expected combat_to_shop begin call for shop scene."
	var details: Dictionary = begin_call.get("details", {})
	if details.get("source") != "boss_reward" or details.get("reward") != "relic":
		return "Expected begin payload to include source and extra details."
	if run_state.marks[0].get("route_id") != "route-shop-2":
		return "Expected before-change mark to use transition route."
	if run_state.change_calls[0].get("route_id") != "route-shop-2":
		return "Expected scene change to use transition route."
	if run_state.change_calls[0].get("rollback_valid") != true:
		return "Expected scene change to receive rollback callback."
	return ""


func _test_non_shop_transition_reuses_current_route() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	handler.trace_and_change_scene_to_target(
		"res://scenes/run_summary.tscn",
		"route-1",
		"combat_next_button",
		"before_summary"
	)
	if not run_state.begin_calls.is_empty():
		return "Expected non-shop transition not to begin a new combat_to_shop route."
	if run_state.marks[0].get("route_id") != "route-1":
		return "Expected before-change mark to reuse current route."
	if run_state.change_calls[0].get("route_id") != "route-1":
		return "Expected scene change to reuse current route."
	return ""


func _test_failed_transition_restores_pending_scene_and_reports() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var model: FakeModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	run_state.change_result = {"ok": false, "reason": "resource_missing"}
	handler.trace_and_change_scene_to_target(
		"res://scenes/run_summary.tscn",
		"route-1",
		"combat_next_button",
		"before_summary"
	)
	if model.pending_scene != "res://scenes/run_summary.tscn" or model.clear_count != 1:
		return "Expected failed transition to restore model scene state."
	if recorder.lock_count != 1:
		return "Expected failed transition to lock external input."
	if recorder.summaries.is_empty() or recorder.summaries[0].get("button_text") != "Run Summary":
		return "Expected run summary failure to show Run Summary button."
	if recorder.status_texts != ["Transition failed: resource_missing"]:
		return "Expected failure status text."
	if recorder.status_colors != [NEGATIVE_COLOR]:
		return "Expected negative status color."
	if recorder.log_lines.is_empty() or recorder.log_lines[0].find("resource_missing") < 0:
		return "Expected combat log failure reason."
	if run_state.marks.back().get("step") != "combat_scene_change_failed":
		return "Expected failure trace mark."
	return ""


func _test_rollback_failure_uses_result_details_and_current_route_fallback() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var model: FakeModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	recorder.current_route = "route-fallback"
	handler.on_scene_post_ready_rollback({
		"target_scene": "res://scenes/shop.tscn",
		"source": "post_ready_check",
		"reason": "post_ready_failed",
	})
	if model.pending_scene != "res://scenes/shop.tscn":
		return "Expected rollback to restore target scene."
	if recorder.summaries.is_empty() or recorder.summaries[0].get("button_text") != "Continue":
		return "Expected shop rollback failure to show Continue button."
	if run_state.marks.back().get("route_id") != "route-fallback":
		return "Expected rollback without route_id to use current route fallback."
	if run_state.marks.back().get("details").get("source") != "post_ready_check":
		return "Expected rollback source to be traced."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var model := FakeModel.new()
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		{
			"run_state": run_state,
			"scene_tree": "tree-sentinel",
			"model": model,
		},
		{
			HANDLER_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(recorder, "current_route_id"),
			HANDLER_SCRIPT.CALLBACK_LOCK_EXTERNAL_INPUT: Callable(recorder, "lock_external_input"),
			HANDLER_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(recorder, "show_outcome_summary"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
			HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(recorder, "append_combat_log"),
		},
		{
			"negative_color": NEGATIVE_COLOR,
			"push_error_on_failure": false,
		}
	)
	return {
		"handler": handler,
		"run_state": run_state,
		"model": model,
		"recorder": recorder,
	}
