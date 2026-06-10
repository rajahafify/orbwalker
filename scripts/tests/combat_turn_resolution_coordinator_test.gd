extends RefCounted
class_name CombatTurnResolutionCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_resolution_coordinator.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("callback_catalog_exposes_required_turn_resolution_seams", _test_callback_catalog_exposes_required_turn_resolution_seams, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
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


func _test_callback_catalog_exposes_required_turn_resolution_seams() -> String:
	var expected := [
		"can_continue",
		"replay_turn_resolution",
		"sync_mastery_totals",
		"update_hud",
		"current_route_id",
	]
	var actual := [
		COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE,
		COORDINATOR_SCRIPT.CALLBACK_REPLAY_TURN_RESOLUTION,
		COORDINATOR_SCRIPT.CALLBACK_SYNC_MASTERY_TOTALS,
		COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD,
		COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID,
	]
	if actual != expected:
		return "Expected turn-resolution callback catalog to stay stable."
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind({}, {}, {})
	return ""
