extends RefCounted
class_name CollectionController

const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

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
	_view.apply_static_chrome()
	_reload_and_render()
	_consume_recent_unlocks_for_toast()


func _on_back_button_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_view.set_back_button_locked(true)
	var route_id := RunState.flow_trace_begin("collection_to_main_menu", MAIN_MENU_SCENE_PATH, {"source": "collection.back_button"})
	RunState.flow_trace_mark("collection_before_change_scene", {"source": "collection.back_button"}, route_id, MAIN_MENU_SCENE_PATH)
	var transition_result: Variant = RunState.flow_trace_change_scene(
		_host.get_tree(),
		MAIN_MENU_SCENE_PATH,
		route_id,
		"collection.back_button",
		"",
		_on_back_post_ready_rollback
	)
	if _scene_change_succeeded(transition_result):
		return
	_is_transitioning = false
	_view.set_back_button_locked(false)
	_view.show_status("Main Menu failed: %s" % _scene_change_failure_reason(transition_result), true)


func _on_back_post_ready_rollback(result: Dictionary) -> void:
	_is_transitioning = false
	_view.set_back_button_locked(false)
	_view.show_status(
		"Main Menu failed: %s" % String(result.get("reason", "prepared_scene_post_ready_check_failed")),
		true
	)


func _on_claim_pressed(payload: Dictionary) -> void:
	var validation: Dictionary = _model.validate_claim(payload)
	if not bool(validation.get("ok", false)):
		_view.show_status("Claim failed: %s" % String(validation.get("reason", "unknown")), true)
		return
	var item_id := String(payload.get("item_id", ""))
	var item_display_name := String(payload.get("item_display_name", item_id))
	var claim_result: Variant = _claim_equipment_unlock(item_id)
	if not _result_ok(claim_result):
		_view.show_status("Claim failed: %s" % _result_failure_reason(claim_result), true)
		return
	_view.show_status("Claimed %s." % item_display_name, false)
	_view.enqueue_unlock(item_display_name)
	_reload_and_render()


func _reload_and_render() -> void:
	_model.refresh_from_run_state()
	_view.set_score_text(_model.score_text())
	_view.render_families(_model.family_view_models(), _on_claim_pressed)


func _consume_recent_unlocks_for_toast() -> void:
	_view.enqueue_unlock_entries(_model.consume_recent_unlock_entries())


func _claim_equipment_unlock(item_id: String) -> Variant:
	for method_name in ["claim_equipment_unlock", "claim_meta_equipment_unlock"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name, item_id)
	return {
		"ok": false,
		"reason": "missing_claim_equipment_unlock_api",
	}


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	return (int(result) as Error) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is bool:
		return "unknown"
	return "error_code_%d" % int(result)


func _result_ok(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	if result is int:
		return (int(result) as Error) == OK
	return false


func _result_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is int:
		return "error_code_%d" % int(result)
	return "unknown"
