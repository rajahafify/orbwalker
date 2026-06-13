extends RefCounted
class_name ElementalMasteryHudVariantsTest

const VARIANTS_SCRIPT := preload("res://scripts/ui/elemental_mastery_hud_variants.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("variant_preview_text_keeps_readable_floors", _test_variant_preview_text_keeps_readable_floors, failures)
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


func _test_variant_preview_text_keeps_readable_floors() -> String:
	var probe: Dictionary = VARIANTS_SCRIPT.readability_font_probe()
	var minimums := {
		"page_subtitle": 22,
		"section_title": 25,
		"section_note": 20,
		"card_name_min": 24,
		"card_level_min": 22,
		"feedback_min": 22,
	}
	for key in minimums.keys():
		if int(probe.get(key, 0)) < int(minimums[key]):
			return "Expected elemental mastery variant %s text to keep a readable floor." % key
	return ""
