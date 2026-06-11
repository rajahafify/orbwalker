extends RefCounted
class_name RunLogCoreEventRecorderTest

const RUN_LOG_CORE_EVENT_RECORDER_SCRIPT := preload("res://scripts/core/run_log_core_event_recorder.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("helper_records_turn_and_fight_payloads", _test_helper_records_turn_and_fight_payloads, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
		"failed": failures.size(),
		"failures": failures,
	}


class FakeLogger:
	var events: Array[Dictionary] = []
	var turn_count := 0
	var reset_count := 0

	func run_log_reset() -> void:
		events.clear()
		turn_count = 0

	func run_log_append(event_type: String, payload: Dictionary) -> void:
		events.append({"event": event_type, "payload": payload.duplicate(true)})

	func next_turn_index_for_fight() -> int:
		return turn_count + 1

	func advance_turn_counter() -> void:
		turn_count += 1

	func reset_fight_turn_counter() -> void:
		reset_count += 1
		turn_count = 0

	func current_fight_turn_count() -> int:
		return turn_count


class LoggerProvider:
	var logger := FakeLogger.new()

	func logger_instance() -> FakeLogger:
		return logger


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_helper_records_turn_and_fight_payloads() -> String:
	var provider := LoggerProvider.new()
	var recorder = RUN_LOG_CORE_EVENT_RECORDER_SCRIPT.new(Callable(provider, "logger_instance"))
	var encounter := {
		"dungeon_level": 2,
		"step_key": "boss",
		"is_boss": true,
		"enemy_id": "iron_gate",
		"display_name": "Iron Gate",
	}
	recorder.record_fight_start(encounter)
	(
		recorder
		. record_turn_result(
			{
				"enemy_damage_taken": 12,
				"enemy_blocked": 4,
				"healed": 3,
				"armor_gained": 5,
				"gold_gained": 2,
				"enemy_attack_resolution": {"hp_damage": 7},
				"matched_counts": {0: 3},
			},
			{"context_key": "context_value"}
		)
	)
	recorder.record_fight_end("defeat", encounter, "hp_zero", {"debug": true})

	var error_text := ""
	if provider.logger.reset_count != 1:
		error_text = "Expected fight start to reset the fight turn counter."
	elif provider.logger.events.size() != 3:
		error_text = "Expected helper to append fight_start, turn_result, and fight_end."
	else:
		var turn_payload: Dictionary = Dictionary(provider.logger.events[1].get("payload", {}))
		var end_payload: Dictionary = Dictionary(provider.logger.events[2].get("payload", {}))
		if int(turn_payload.get("turn_index_for_fight", 0)) != 1:
			error_text = "Expected first turn index to be 1."
		elif int(turn_payload.get("damage_to_player", 0)) != 7:
			error_text = "Expected damage_to_player to come from enemy_attack_resolution.hp_damage."
		elif String(turn_payload.get("context_key", "")) != "context_value":
			error_text = "Expected turn context to merge into payload."
		elif String(end_payload.get("outcome", "")) != "defeat":
			error_text = "Expected fight_end outcome to be preserved."
		elif int(end_payload.get("turn_count", 0)) != 1:
			error_text = "Expected fight_end to use current helper turn count."
		elif String(end_payload.get("enemy_id", "")) != "iron_gate":
			error_text = "Expected fight_end to copy encounter identity."
	return error_text
