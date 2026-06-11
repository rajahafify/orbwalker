extends RefCounted
class_name CombatTurnReplayCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_replay_coordinator.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("dominant_damage_prefers_largest_elemental_damage", _test_dominant_damage_prefers_largest_elemental_damage, failures)
	_run_case("dominant_damage_falls_back_to_elemental_match_counts", _test_dominant_damage_falls_back_to_elemental_match_counts, failures)
	_run_case("dominant_match_uses_mastery_resolution_order_for_ties", _test_dominant_match_uses_mastery_resolution_order_for_ties, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
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


func _test_dominant_damage_prefers_largest_elemental_damage() -> String:
	var coordinator := COORDINATOR_SCRIPT.new()
	var turn_log := {
		"fire_damage": 8,
		"ice_damage": 14,
		"earth_damage": 9,
		"matched_counts":
		{
			OrbType.Id.FIRE: 9,
			OrbType.Id.EARTH: 12,
		},
	}
	var selected := int(coordinator.call("_dominant_damage_orb_for_turn", turn_log))
	return "" if selected == OrbType.Id.ICE else "Expected ICE, got %d." % selected


func _test_dominant_damage_falls_back_to_elemental_match_counts() -> String:
	var coordinator := COORDINATOR_SCRIPT.new()
	var turn_log := {
		"fire_damage": 0,
		"ice_damage": 0,
		"earth_damage": 0,
		"matched_counts":
		{
			OrbType.Id.FIRE: 2,
			OrbType.Id.ICE: 3,
			OrbType.Id.EARTH: 5,
		},
	}
	var selected := int(coordinator.call("_dominant_damage_orb_for_turn", turn_log))
	return "" if selected == OrbType.Id.EARTH else "Expected EARTH, got %d." % selected


func _test_dominant_match_uses_mastery_resolution_order_for_ties() -> String:
	var coordinator := COORDINATOR_SCRIPT.new()
	var matched_counts := {
		OrbType.Id.HEART: 4,
		OrbType.Id.FIRE: 4,
		OrbType.Id.GOLD: 4,
	}
	var selected := int(coordinator.call("_dominant_orb_for_matches", matched_counts))
	return "" if selected == OrbType.Id.HEART else "Expected HEART tie-breaker, got %d." % selected
