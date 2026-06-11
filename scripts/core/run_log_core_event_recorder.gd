extends RefCounted
class_name RunLogCoreEventRecorder

var _logger_provider: Callable


func _init(logger_provider: Callable) -> void:
	_logger_provider = logger_provider


func reset_run_log() -> void:
	_logger().run_log_reset()


func append_event(event_type: String, payload: Dictionary) -> void:
	_logger().run_log_append(event_type, payload)


func record_run_start(dungeon_level: int, step_key: String, extra: Dictionary = {}) -> void:
	var payload := {
		"dungeon_level": dungeon_level,
		"step": step_key,
	}
	for key in extra.keys():
		payload[key] = extra[key]
	append_event("run_start", payload)


func record_fight_start(encounter: Dictionary) -> void:
	_logger().reset_fight_turn_counter()
	append_event(
		"fight_start",
		{
			"encounter": encounter.duplicate(true),
		}
	)


func record_turn_result(turn_log: Dictionary, context: Dictionary = {}) -> void:
	var logger = _logger()
	var payload := {
		"turn_index_for_fight": logger.next_turn_index_for_fight(),
		"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", 0)),
		"enemy_blocked": int(turn_log.get("enemy_blocked", 0)),
		"healed": int(turn_log.get("healed", 0)),
		"armor_gained": int(turn_log.get("armor_gained", 0)),
		"gold_gained": int(turn_log.get("gold_gained", 0)),
		"damage_to_player": int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0)),
		"matches": Dictionary(turn_log.get("matched_counts", {})).duplicate(true),
		"raw_turn_log": turn_log.duplicate(true),
	}
	for key in context.keys():
		payload[key] = context[key]
	logger.advance_turn_counter()
	append_event("turn_result", payload)


func record_fight_end(outcome: String, encounter: Dictionary, cause: String = "", extra: Dictionary = {}) -> void:
	append_event("fight_end", fight_outcome_payload(outcome, encounter, cause, extra))


func record_run_end(victory: bool, cause: String, summary: Dictionary) -> void:
	append_event(
		"run_end",
		{
			"victory": victory,
			"cause": cause,
			"summary": summary.duplicate(true),
		}
	)


func fight_outcome_payload(outcome: String, encounter: Dictionary, cause: String = "", extra: Dictionary = {}) -> Dictionary:
	var payload := {
		"outcome": outcome,
		"dungeon_level": int(encounter.get("dungeon_level", 0)),
		"step_key": String(encounter.get("step_key", "")),
		"is_boss": bool(encounter.get("is_boss", false)),
		"enemy_id": String(encounter.get("enemy_id", "")),
		"enemy_name": String(encounter.get("display_name", "")),
		"turn_count": _logger().current_fight_turn_count(),
	}
	if cause != "":
		payload["cause"] = cause
	for key in extra.keys():
		payload[key] = extra[key]
	return payload


func _logger():
	return _logger_provider.call()
