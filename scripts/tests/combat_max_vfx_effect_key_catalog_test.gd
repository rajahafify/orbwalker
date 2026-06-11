extends RefCounted
class_name CombatMaxVfxEffectKeyCatalogTest

const CATALOG_SCRIPT := preload("res://scripts/combat/combat_max_vfx_effect_key_catalog.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("effect_key_catalog_preserves_overlay_mappings", _test_effect_key_catalog_preserves_overlay_mappings, failures)
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


func _test_effect_key_catalog_preserves_overlay_mappings() -> String:
	var catalog = CATALOG_SCRIPT.new()
	if catalog.clean_kind(" Healing ") != "heart":
		return "Expected healing aliases to normalize to heart."
	if catalog.clean_kind("shield") != "armor":
		return "Expected shield alias to normalize to armor."
	if catalog.status_sheet_key("earth") != "poison":
		return "Expected earth status sheet key to remain poison."
	if catalog.status_trail_key("damage") != "stun":
		return "Expected damage status trail key to remain stun."
	if catalog.atmospheric_impact_key("gold") != "fireflies":
		return "Expected gold atmospheric impact key to remain fireflies."
	if catalog.impact_key("armor") != "armor_impact":
		return "Expected armor impact key to remain armor_impact."
	if catalog.particle_key("gold") != "coin_spin":
		return "Expected gold particle key to remain coin_spin."
	if catalog.kind_for_orb(OrbType.Id.ICE) != "ice":
		return "Expected ice orb id to route to ice VFX."
	if catalog.kind_for_orb(9999) != "damage":
		return "Expected unknown orb ids to route to damage VFX."
	if not catalog.should_use_elemental_magic("heal"):
		return "Expected heal alias to support elemental magic."
	var fire_colors: Dictionary = catalog.kind_colors("fire")
	if fire_colors.get("accent") != Color(1.0, 0.25, 0.04, 1.0):
		return "Expected fire accent color to remain unchanged."
	var ice_elemental_colors: Dictionary = catalog.elemental_kind_colors("ice")
	if ice_elemental_colors.get("secondary") != Color(0.28, 0.84, 1.0, 1.0):
		return "Expected ice elemental secondary color to remain unchanged."
	return ""
