extends RefCounted
class_name ShopCopyFormatterTest

const FORMATTER := preload("res://scripts/shop/shop_copy_formatter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("price_text_keeps_shop_badges_compact", _test_price_text_keeps_shop_badges_compact, failures)
	_run_case("equipment_copy_uses_known_compact_labels", _test_equipment_copy_uses_known_compact_labels, failures)
	_run_case("mastery_and_treasure_copy_stay_two_line", _test_mastery_and_treasure_copy_stay_two_line, failures)
	_run_case("consumable_copy_compacts_conversion_scrolls", _test_consumable_copy_compacts_conversion_scrolls, failures)
	_run_case("relic_copy_uses_known_labels_and_wraps_fallback", _test_relic_copy_uses_known_labels_and_wraps_fallback, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
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


func _test_price_text_keeps_shop_badges_compact() -> String:
	if FORMATTER.price_text(9, false, true, false) != "$9":
		return "Expected affordable price text to use compact dollar notation."
	if FORMATTER.price_text(11, false, false, false) != "$11":
		return "Expected unaffordable price text to keep compact dollar notation."
	if FORMATTER.price_text(11, true, false, false) != "SOLD OUT":
		return "Expected sold-out offers to use SOLD OUT."
	if FORMATTER.price_text(11, false, true, true) != "WAIT CHEST":
		return "Expected pending treasure chest state to block buying copy."
	return ""


func _test_equipment_copy_uses_known_compact_labels() -> String:
	var cases := {
		"shortsword": "+2 Attack",
		"buckler": "Gain +4 Armor\neach turn",
		"coin_purse": "Gain +3 Gold\non Gold matches",
		"healing_charm": "Heal +5 more\non Hearts",
		"leather_gloves": "+2 Combo count\nfor damage",
	}
	var descriptions := {
		"shortsword": "Deal +2 flat elemental damage each turn.",
		"buckler": "Gain +4 Armor each turn.",
		"coin_purse": "Gain +3 Gold on Gold matches.",
		"healing_charm": "Heal +5 more on Hearts.",
		"leather_gloves": "+2 Combo count for damage.",
	}
	for content_id in cases.keys():
		var compact := FORMATTER.shop_card_description({
			"type": "equipment",
			"content_id": content_id,
			"display_name": String(content_id).capitalize(),
			"description": descriptions.get(content_id, ""),
		})
		if compact != String(cases.get(content_id, "")):
			return "Expected %s copy '%s', got '%s'." % [content_id, cases.get(content_id, ""), compact]
	return ""


func _test_mastery_and_treasure_copy_stay_two_line() -> String:
	var mastery_copy := FORMATTER.shop_card_description({
		"type": "mastery_card",
		"content_id": "fire_mastery",
		"display_name": "Fire Mastery",
		"description": "Increase Fire mastery by 1 (max 5).",
	})
	if mastery_copy != "+1 Fire\nMastery":
		return "Expected mastery copy to stay compact and two-line."
	var fire_chest_copy := FORMATTER.shop_card_description({
		"type": "treasure_chest",
		"content_id": "fire_chest",
		"display_name": "Fire Chest",
		"description": "Choose 1 of 3 Fire-aligned treasures.",
	})
	if fire_chest_copy != "Choose 1 of 3\nFire rewards":
		return "Expected fire chest copy to use chest reward terminology."
	var generic_chest_copy := FORMATTER.shop_card_description({
		"type": "treasure_chest",
		"content_id": "mystery_chest",
		"display_name": "Mystery Chest",
		"description": "Choose 1 of 3 treasures.",
	})
	if generic_chest_copy != "Choose 1 of 3\nrewards":
		return "Expected generic treasure chest copy to stay short."
	return ""


func _test_consumable_copy_compacts_conversion_scrolls() -> String:
	var compact := FORMATTER.shop_card_description({
		"type": "consumable",
		"content_id": "fire_scroll",
		"display_name": "Fire Scroll",
		"description": "Convert +3 non-Fire orbs to Fire orbs.",
	})
	if compact != "Convert 3 non-Fire\norbs to Fire orbs":
		return "Expected conversion scroll copy to compact to two readable lines."
	var passthrough := FORMATTER.shop_card_description({
		"type": "consumable",
		"content_id": "healing_potion",
		"display_name": "Healing Potion",
		"description": "Heal 8 HP.",
	})
	if passthrough != "Heal 8 HP.":
		return "Expected non-conversion consumable copy to remain unchanged."
	return ""


func _test_relic_copy_uses_known_labels_and_wraps_fallback() -> String:
	var compact := FORMATTER.shop_relic_description({
		"content_id": "crown_of_chains",
		"description": "Combo count +3 and +5 flat elemental damage each turn.",
	})
	if compact != "Combo count +3\n+5 Attack each turn":
		return "Expected known relic copy to use its compact label."
	var fallback := FORMATTER.shop_relic_description({
		"content_id": "new_relic",
		"description": "Increase combo multiplier and grant extra gold after long chains.",
	})
	if fallback.split("\n").size() > 2:
		return "Expected fallback relic copy to wrap to at most two lines."
	if fallback.length() <= 0:
		return "Expected fallback relic copy to remain non-empty."
	if FORMATTER.relic_title_color("rare") != Color(0.92, 0.58, 1.0, 1.0):
		return "Expected rare relic title color to match the shop banner palette."
	return ""
