extends RefCounted
class_name CombatSceneTransitionHandler

const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")

const CALLBACK_CURRENT_ROUTE_ID := "current_route_id"
const CALLBACK_LOCK_EXTERNAL_INPUT := "lock_external_input"
const CALLBACK_SHOW_OUTCOME_SUMMARY := "show_outcome_summary"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_APPEND_COMBAT_LOG := "append_combat_log"

const DEFAULT_RUN_SUMMARY_SCENE := "res://scenes/run_summary.tscn"

var _run_state: Variant = null
var _scene_tree: Variant = null
var _model: Variant = null
var _callbacks: Dictionary = {}
var _negative_color := Color.WHITE
var _run_summary_scene := DEFAULT_RUN_SUMMARY_SCENE
var _push_error_on_failure := true


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_scene_tree = dependencies.get("scene_tree", null)
	_model = dependencies.get("model", null)
	_callbacks = callbacks.duplicate()
	_negative_color = config.get("negative_color", Color.WHITE)
	_run_summary_scene = String(config.get("run_summary_scene", DEFAULT_RUN_SUMMARY_SCENE))
	_push_error_on_failure = bool(config.get("push_error_on_failure", true))


func trace_and_change_scene_to_target(
	target_scene: String,
	current_route_id: String,
	source: String,
	before_change_step: String,
	begin_payload_extra: Dictionary = {}
) -> void:
	if _run_state == null:
		return
	var transition_route_id := current_route_id
	if target_scene.find("shop.tscn") >= 0:
		var begin_payload := {"source": source}
		for key in begin_payload_extra.keys():
			begin_payload[key] = begin_payload_extra[key]
		transition_route_id = String(_run_state.flow_trace_begin(
			"combat_to_shop",
			target_scene,
			begin_payload
		))
	_run_state.flow_trace_mark(
		before_change_step,
		{"source": source},
		transition_route_id,
		target_scene
	)
	var scene_change_result: Variant = _run_state.flow_trace_change_scene(
		_scene_tree,
		target_scene,
		transition_route_id,
		source,
		"",
		Callable(self, "on_scene_post_ready_rollback")
	)
	if not FLOW_RESULT_UTILS.scene_change_succeeded(scene_change_result):
		handle_scene_change_failure(target_scene, transition_route_id, source, scene_change_result)


func on_scene_post_ready_rollback(result: Dictionary) -> void:
	handle_scene_change_failure(
		String(result.get("target_scene", _run_summary_scene)),
		String(result.get("route_id", _current_route_id())),
		String(result.get("source", "combat_post_ready_rollback")),
		result
	)


func handle_scene_change_failure(target_scene: String, route_id: String, source: String, result: Variant) -> void:
	if _run_state == null:
		return
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(result)
	if _model != null:
		if _model.has_method("set_pending_next_scene_path"):
			_model.set_pending_next_scene_path(target_scene)
		if _model.has_method("clear_outcome_transition_queued"):
			_model.clear_outcome_transition_queued()
	_lock_external_input()
	var button_text := "Run Summary" if target_scene.find("run_summary") >= 0 else "Continue"
	_show_outcome_summary("Transition Failed", "Could not open the next scene.\n%s" % failure_reason, true, button_text)
	_set_status_text("Transition failed: %s" % failure_reason)
	_set_status_color(_negative_color)
	_append_combat_log("Scene transition failed from %s to %s: %s" % [source, target_scene, failure_reason])
	_run_state.flow_trace_mark(
		"combat_scene_change_failed",
		{
			"source": source,
			"reason": failure_reason,
		},
		route_id,
		target_scene
	)
	if _push_error_on_failure:
		push_error("Combat scene transition failed: %s -> %s (%s)" % [source, target_scene, failure_reason])


func _current_route_id() -> String:
	var current_route_id: Callable = _callbacks.get(CALLBACK_CURRENT_ROUTE_ID, Callable())
	if current_route_id.is_valid():
		return String(current_route_id.call())
	return ""


func _lock_external_input() -> void:
	var lock_external_input: Callable = _callbacks.get(CALLBACK_LOCK_EXTERNAL_INPUT, Callable())
	if lock_external_input.is_valid():
		lock_external_input.call()


func _show_outcome_summary(title: String, body: String, show_next: bool, button_text: String) -> void:
	var show_outcome_summary: Callable = _callbacks.get(CALLBACK_SHOW_OUTCOME_SUMMARY, Callable())
	if show_outcome_summary.is_valid():
		show_outcome_summary.call(title, body, show_next, button_text)


func _set_status_text(value: String) -> void:
	var set_status_text: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if set_status_text.is_valid():
		set_status_text.call(value)


func _set_status_color(value: Color) -> void:
	var set_status_color: Callable = _callbacks.get(CALLBACK_SET_STATUS_COLOR, Callable())
	if set_status_color.is_valid():
		set_status_color.call(value)


func _append_combat_log(value: String) -> void:
	var append_combat_log: Callable = _callbacks.get(CALLBACK_APPEND_COMBAT_LOG, Callable())
	if append_combat_log.is_valid():
		append_combat_log.call(value)
