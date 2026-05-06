extends RefCounted
class_name RunSummaryController

var _host: Control
var _model
var _view
var _is_transitioning := false


func bind(host: Control, root_nodes: Dictionary, model, view) -> void:
	_host = host
	_model = model
	_view = view
	_view.bind(root_nodes)


func ready() -> void:
	_model.load_from_run_state()
	_view.apply_static_layout(_host)
	_view.render_summary(
		_model.title_text(),
		_model.subtitle_text(),
		_model.is_victory(),
		_model.stats_rows(),
		_model.equipment_lines(),
		_model.relic_lines()
	)
	if _model.is_victory():
		_view.enqueue_unlock_entries(_model.consume_recent_unlock_entries())
	else:
		_model.discard_recent_unlocks()


func _on_main_menu_button_pressed() -> void:
	_route_from_summary(false)


func _on_new_run_button_pressed() -> void:
	_route_from_summary(true)


func _route_from_summary(start_new_run: bool) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_view.set_action_buttons_disabled(true)

	var source := "run_summary.main_menu"
	var route_name := "final_summary_to_main_menu"
	var target_scene := "res://scenes/main_menu.tscn"
	var pre_run_state: Dictionary = {}
	var prepared_scene: Dictionary = {}
	if start_new_run:
		source = "run_summary.new_run"
		route_name = "final_summary_to_combat"
		target_scene = "res://scenes/combat.tscn"
	var route_id := RunState.flow_trace_begin(route_name, target_scene, {"source": source})

	if start_new_run:
		prepared_scene = RunState.flow_trace_prepare_scene(target_scene, route_id, source)
		if not bool(prepared_scene.get("ok", false)):
			var prepare_failure := _scene_change_failure_reason(prepared_scene)
			push_error("Final summary prepare failed: %s -> %s (%s)" % [source, target_scene, prepare_failure])
			_view.set_transition_error(prepare_failure)
			_is_transitioning = false
			_view.set_action_buttons_disabled(false)
			return
		pre_run_state = RunState.snapshot_run_transition_state()
		if not pre_run_state.is_empty():
			prepared_scene["rollback_snapshot"] = pre_run_state
		prepared_scene["post_ready_failure_callback"] = _on_new_run_post_ready_rollback
		RunState.flow_trace_mark("final_summary_before_start_new_run", {"source": source}, route_id, target_scene)
		RunState.start_new_run()
		RunState.flow_trace_mark("final_summary_after_start_new_run", {"source": source}, route_id, target_scene)
		target_scene = RunState.next_scene_path()

	RunState.flow_trace_mark("final_summary_before_change_scene", {"source": source}, route_id, target_scene)
	var transition_result: Variant
	if start_new_run:
		transition_result = RunState.flow_trace_attach_prepared_scene(_host.get_tree(), prepared_scene, target_scene, route_id, source)
	else:
		transition_result = RunState.flow_trace_change_scene(
			_host.get_tree(),
			target_scene,
			route_id,
			source,
			"",
			_on_summary_post_ready_rollback
		)
	if _scene_change_succeeded(transition_result):
		return
	if start_new_run and not pre_run_state.is_empty():
		RunState.restore_run_transition_state(pre_run_state)
	var failure := _scene_change_failure_reason(transition_result)
	push_error("Final summary transition failed: %s -> %s (%s)" % [source, target_scene, failure])
	_view.set_transition_error(failure)
	_is_transitioning = false
	_view.set_action_buttons_disabled(false)


func _on_new_run_post_ready_rollback(result: Dictionary) -> void:
	_on_post_ready_rollback(result)


func _on_summary_post_ready_rollback(result: Dictionary) -> void:
	_on_post_ready_rollback(result)


func _on_post_ready_rollback(result: Dictionary) -> void:
	_is_transitioning = false
	_view.set_action_buttons_disabled(false)
	_view.set_transition_error(String(result.get("reason", "prepared_scene_post_ready_check_failed")))


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	return int(result) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	return "error_code_%d" % int(result)
