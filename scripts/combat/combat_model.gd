extends RefCounted
class_name CombatModel

const COMBAT_SPEED_SLOW := "slow"
const COMBAT_SPEED_NORMAL := "normal"
const COMBAT_SPEED_FAST := "fast"
const COMBAT_SPEED_INSTANT := "instant"

var _flow_trace_route_id: String = ""
var _input_phase: int = 0
var _external_lock_reason: String = ""
var _combat_speed: String = COMBAT_SPEED_NORMAL
var _pending_next_scene_path: String = ""
var _outcome_transition_queued: bool = false
var _hovered_board_orb_id: int = -1
var _staged_hud_values: Dictionary = {}
var _combat_mastery_feedback_token: int = 0
var _combat_mastery_preview_totals: Dictionary = {}
var _resolve_trace_origin_usec: int = 0
var _resolve_trace_active: bool = false
var _resolve_trace_pass_index: int = -1


func set_input_phase(phase: int) -> void:
	_input_phase = phase


func input_phase() -> int:
	return _input_phase


func is_player_input_phase() -> bool:
	return _input_phase == 0


func is_resolving_phase() -> bool:
	return _input_phase == 1


func set_external_lock_reason(reason: String) -> void:
	_external_lock_reason = reason


func external_lock_reason() -> String:
	return _external_lock_reason


func clear_external_lock_reason() -> void:
	_external_lock_reason = ""


func set_flow_trace_route_id(route_id: String) -> void:
	_flow_trace_route_id = route_id


func flow_trace_route_id() -> String:
	return _flow_trace_route_id


func has_flow_trace_route() -> bool:
	return _flow_trace_route_id != ""


func set_combat_speed(speed: String) -> void:
	var normalized := speed.strip_edges().to_lower()
	match normalized:
		COMBAT_SPEED_SLOW, COMBAT_SPEED_NORMAL, COMBAT_SPEED_FAST, COMBAT_SPEED_INSTANT:
			_combat_speed = normalized
		_:
			_combat_speed = COMBAT_SPEED_NORMAL


func combat_speed() -> String:
	return _combat_speed


func set_pending_next_scene_path(path: String) -> void:
	_pending_next_scene_path = path


func pending_next_scene_path() -> String:
	return _pending_next_scene_path


func take_pending_next_scene_path() -> String:
	var path := _pending_next_scene_path
	_pending_next_scene_path = ""
	return path


func clear_pending_next_scene_path() -> void:
	_pending_next_scene_path = ""


func mark_outcome_transition_queued() -> bool:
	if _outcome_transition_queued:
		return false
	_outcome_transition_queued = true
	return true


func clear_outcome_transition_queued() -> void:
	_outcome_transition_queued = false


func is_outcome_transition_queued() -> bool:
	return _outcome_transition_queued


func set_hovered_board_orb_id(orb_id: int) -> void:
	_hovered_board_orb_id = orb_id


func hovered_board_orb_id() -> int:
	return _hovered_board_orb_id


func clear_hovered_board_orb_id() -> void:
	_hovered_board_orb_id = -1


func begin_hud_staging(values: Dictionary) -> void:
	_staged_hud_values = {}
	stage_hud_values(values)


func stage_hud_values(values: Dictionary) -> void:
	for key in values.keys():
		_staged_hud_values[key] = int(values[key])


func clear_hud_staging() -> void:
	_staged_hud_values.clear()


func is_hud_staging_active() -> bool:
	return not _staged_hud_values.is_empty()


func staged_hud_value(key: String, fallback: int) -> int:
	return int(_staged_hud_values.get(key, fallback))


func staged_hud_values_snapshot() -> Dictionary:
	return _staged_hud_values.duplicate(true)


func reset_combat_mastery_preview() -> void:
	_combat_mastery_feedback_token += 1
	_combat_mastery_preview_totals.clear()


func add_combat_mastery_preview_total(orb_id: int, amount: int) -> int:
	var current_total := int(_combat_mastery_preview_totals.get(orb_id, 0))
	var next_total := current_total + amount
	_combat_mastery_preview_totals[orb_id] = next_total
	return next_total


func release_combat_mastery_feedback(orb_id: int) -> void:
	_combat_mastery_preview_totals.erase(orb_id)


func combat_mastery_preview_total(orb_id: int) -> int:
	return int(_combat_mastery_preview_totals.get(orb_id, 0))


func combat_mastery_preview_totals_snapshot() -> Dictionary:
	return _combat_mastery_preview_totals.duplicate(true)


func combat_mastery_feedback_token() -> int:
	return _combat_mastery_feedback_token


func begin_resolve_trace(origin_usec: int, active: bool) -> void:
	_resolve_trace_origin_usec = origin_usec
	_resolve_trace_active = active
	_resolve_trace_pass_index = -1


func end_resolve_trace() -> void:
	_resolve_trace_active = false
	_resolve_trace_pass_index = -1


func resolve_trace_active() -> bool:
	return _resolve_trace_active


func resolve_trace_origin_usec() -> int:
	return _resolve_trace_origin_usec


func set_resolve_trace_pass_index(pass_index: int) -> void:
	_resolve_trace_pass_index = pass_index


func resolve_trace_pass_index() -> int:
	return _resolve_trace_pass_index
