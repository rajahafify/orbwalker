extends RefCounted
class_name RunEncounterCatalogTest

const CATALOG_SCRIPT := preload("res://scripts/core/run_encounter_catalog.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("catalog_preserves_level_fight_and_label_contracts", _test_catalog_preserves_level_fight_and_label_contracts, failures)
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


func _test_catalog_preserves_level_fight_and_label_contracts() -> String:
	var catalog = CATALOG_SCRIPT.new()
	var first_enemy: Dictionary = catalog.normal_encounter(1, "enemy_1")
	var second_enemy: Dictionary = catalog.normal_encounter(1, "enemy_2")
	var boss: Dictionary = catalog.boss_encounter(3)
	var tutorial: Dictionary = catalog.tutorial_encounter_for(1, "enemy_1")
	var no_tutorial: Dictionary = catalog.tutorial_encounter_for(2, "enemy_1")
	var fallback_boss: Dictionary = catalog.fallback_encounter("boss")
	if String(first_enemy.get("enemy_id", "")) != "cavern_striker":
		return "Expected level 1 enemy_1 to remain cavern_striker."
	if String(second_enemy.get("enemy_id", "")) != "cavern_defender":
		return "Expected level 1 enemy_2 to remain cavern_defender."
	if String(boss.get("enemy_id", "")) != "prism_warden":
		return "Expected level 3 boss to remain prism_warden."
	if String(tutorial.get("enemy_id", "")) != "training_striker":
		return "Expected tutorial first fight to use training_striker."
	if not no_tutorial.is_empty():
		return "Expected tutorial encounter to be gated to level 1 enemy_1."
	if not bool(fallback_boss.get("is_boss", false)):
		return "Expected fallback boss encounter to preserve boss flag."
	if catalog.step_display_name("boss_relic_reward") != "Boss Relic Reward":
		return "Expected boss reward step label to be preserved."
	return ""
