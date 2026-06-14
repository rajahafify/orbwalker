extends RefCounted
class_name ShopTransitionHandler

const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")

const CALLBACK_SET_STATUS := "set_status"
const CALLBACK_CLEAR_INVENTORY_FOCUS := "clear_inventory_focus"
const CALLBACK_TUTORIAL_SHOP_PHASE := "tutorial_shop_phase"
const CALLBACK_TUTORIAL_SHOP_STATUS := "tutorial_shop_status"
const CALLBACK_REFRESH_UI := "refresh_ui"

const SCENE_COMBAT := "res://scenes/combat.tscn"
const SCENE_MAIN_MENU := "res://scenes/main_menu.tscn"

var _run_state: Variant = null
var _host: Control = null
var _model: Variant = null
var _view: Variant = null
var _callbacks: Dictionary = {}
var _route_id := ""


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_host = dependencies.get("host", null)
	_model = dependencies.get("model", null)
	_view = dependencies.get("view", null)
	_callbacks = callbacks.duplicate()
	_route_id = String(config.get("route_id", ""))


func queue_ready_redirect(target_scene: String, source: String) -> void:
	_flow_trace_mark("shop_ready_redirect_before_change_scene", {"source": source}, _route_id, target_scene)
	Callable(self, "_deferred_ready_redirect").bind(target_scene, source).call_deferred()


func continue_pressed() -> void:
	if _transition_locked():
		return
	if _tutorial_shop_phase() != "" and _tutorial_shop_phase() != "continue":
		_set_status(_tutorial_shop_status(), false)
		_refresh_ui()
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	_flow_trace_mark("shop_continue_button_pressed", {"button_text": "Continue"}, _route_id)
	var pre_transition_state := _snapshot_run_transition_state()
	_flow_trace_mark("shop_before_advance_after_shop", {}, _route_id)
	var transition: Dictionary = _run_state.advance_after_shop(false) if _run_state != null else {"ok": false, "reason": "missing_run_state"}
	var next_scene := String(transition.get("next_scene", SCENE_MAIN_MENU))
	_flow_trace_mark(
		"shop_after_advance_after_shop",
		{
			"ok": bool(transition.get("ok", false)),
			"step": String(transition.get("step", "")),
		},
		_route_id,
		next_scene
	)
	if not bool(transition.get("ok", false)):
		_set_status("Continue failed: %s" % String(transition.get("reason", "unknown")), false)
		_restore_transition_snapshot(pre_transition_state)
		_end_transition_lock()
		return
	var route_id := _route_id
	if next_scene.find("combat.tscn") >= 0 and _run_state != null:
		route_id = String(_run_state.flow_trace_begin("shop_to_combat", next_scene, {"source": "shop_continue_button"}))
	_flow_trace_mark("shop_before_change_scene_to_file", {"source": "shop_continue_button"}, route_id, next_scene)
	var scene_change_result: Variant = _flow_trace_change_scene(
		next_scene, route_id, "shop_continue_button", Callable(self, "on_scene_change_post_ready_rollback"), pre_transition_state
	)
	if scene_change_result != OK:
		_set_status("Continue failed: %s" % FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result), false)
		_restore_transition_snapshot(pre_transition_state)
		_end_transition_lock()


func main_menu_pressed() -> void:
	if _transition_locked():
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	_flow_trace_mark("shop_main_menu_button_pressed", {"button_text": "Menu"}, _route_id, SCENE_MAIN_MENU)
	_flow_trace_mark("shop_before_change_scene_to_file_main_menu", {"source": "shop_main_menu_button"}, _route_id, SCENE_MAIN_MENU)
	var scene_change_result: Variant = _flow_trace_change_scene(
		SCENE_MAIN_MENU, _route_id, "shop_main_menu_button", Callable(self, "on_scene_change_post_ready_rollback")
	)
	if scene_change_result != OK:
		_set_status("Main menu failed: %s" % FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result), false)
		_end_transition_lock()


func new_run_pressed() -> void:
	if _transition_locked():
		return
	if _run_state == null:
		_set_status("New run failed: missing_run_state.", false)
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	var route_id := String(_run_state.flow_trace_begin("shop_settings_new_run", SCENE_COMBAT, {"source": "shop.settings_new_run"}))
	_flow_trace_mark("shop_settings_new_run_pressed", {"button_text": "New Run"}, route_id, SCENE_COMBAT)
	var pre_transition_state := _snapshot_run_transition_state()
	_run_state.start_new_run()
	_flow_trace_mark("shop_settings_before_change_scene_to_file", {"source": "shop.settings_new_run"}, route_id, SCENE_COMBAT)
	var scene_change_result: Variant = _flow_trace_change_scene(
		SCENE_COMBAT, route_id, "shop.settings_new_run", Callable(self, "on_scene_change_post_ready_rollback"), pre_transition_state
	)
	if scene_change_result != OK:
		_set_status("New run failed: %s" % FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result), false)
		_restore_transition_snapshot(pre_transition_state)
		_end_transition_lock()


func on_scene_change_post_ready_rollback(result: Dictionary) -> void:
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_set_status("Transition failed: %s" % failure_reason, false)
	_flow_trace_mark(
		"shop_post_ready_scene_change_failed",
		{
			"source": String(result.get("source", "shop")),
			"reason": failure_reason,
		},
		String(result.get("route_id", _route_id)),
		String(result.get("target_scene", ""))
	)
	_end_transition_lock()


func _deferred_ready_redirect(target_scene: String, source: String) -> void:
	if _transition_locked():
		return
	_begin_transition_lock()
	var transition_source := "shop_ready_redirect_%s" % source
	var scene_change_result: Variant = _flow_trace_change_scene(
		target_scene, _route_id, transition_source, Callable(self, "on_scene_change_post_ready_rollback")
	)
	if scene_change_result == OK:
		return
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result)
	_set_status("Redirect failed: %s" % failure_reason, false)
	_flow_trace_mark(
		"shop_ready_redirect_change_scene_failed",
		{
			"source": source,
			"reason": failure_reason,
		},
		_route_id,
		target_scene
	)
	_end_transition_lock()


func _flow_trace_change_scene(
	target_scene: String, route_id: String, source: String, rollback_callback: Callable, rollback_payload: Dictionary = {}
) -> Variant:
	if _run_state == null:
		return ERR_UNCONFIGURED
	if rollback_payload.is_empty():
		return _run_state.flow_trace_change_scene(_scene_tree(), target_scene, route_id, source, "", rollback_callback)
	return _run_state.flow_trace_change_scene(_scene_tree(), target_scene, route_id, source, "", rollback_callback, rollback_payload)


func _flow_trace_mark(step: String, payload: Dictionary, route_id: String, target_scene: String = "") -> void:
	if _run_state != null:
		_run_state.flow_trace_mark(step, payload, route_id, target_scene)


func _snapshot_run_transition_state() -> Dictionary:
	if _run_state != null and _run_state.has_method("snapshot_run_transition_state"):
		return _run_state.snapshot_run_transition_state()
	return {}


func _restore_transition_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty() or _run_state == null:
		return
	if _run_state.has_method("restore_run_transition_state"):
		_run_state.restore_run_transition_state(snapshot)


func _scene_tree() -> SceneTree:
	if _host == null:
		return null
	return _host.get_tree()


func _transition_locked() -> bool:
	return _model != null and bool(_model.transition_locked)


func _begin_transition_lock() -> void:
	if _model != null and _model.has_method("begin_transition_lock"):
		_model.begin_transition_lock()
	if _view != null and _view.has_method("lock_transitions"):
		_view.lock_transitions(true)


func _end_transition_lock() -> void:
	if _model != null and _model.has_method("end_transition_lock"):
		_model.end_transition_lock()
	if _view != null and _view.has_method("lock_transitions"):
		_view.lock_transitions(false)


func _set_status(message: String, positive: bool) -> void:
	var set_status: Callable = _callbacks.get(CALLBACK_SET_STATUS, Callable())
	if set_status.is_valid():
		set_status.call(message, positive)


func _clear_inventory_focus() -> void:
	var clear_inventory_focus: Callable = _callbacks.get(CALLBACK_CLEAR_INVENTORY_FOCUS, Callable())
	if clear_inventory_focus.is_valid():
		clear_inventory_focus.call()


func _tutorial_shop_phase() -> String:
	var tutorial_shop_phase: Callable = _callbacks.get(CALLBACK_TUTORIAL_SHOP_PHASE, Callable())
	if tutorial_shop_phase.is_valid():
		return String(tutorial_shop_phase.call())
	return ""


func _tutorial_shop_status() -> String:
	var tutorial_shop_status: Callable = _callbacks.get(CALLBACK_TUTORIAL_SHOP_STATUS, Callable())
	if tutorial_shop_status.is_valid():
		return String(tutorial_shop_status.call())
	return ""


func _refresh_ui() -> void:
	var refresh_ui: Callable = _callbacks.get(CALLBACK_REFRESH_UI, Callable())
	if refresh_ui.is_valid():
		refresh_ui.call()
