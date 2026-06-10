extends RefCounted
class_name ContentRegistryTerminologyTest

const CONTENT_REGISTRY_SCRIPT_PATH := "res://scripts/content/content_registry.gd"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("treasure_chest_content_displays_as_treasure_chests", _test_treasure_chest_content_displays_as_treasure_chests, failures)
	_run_case("shop_pool_keeps_internal_treasure_chest_type", _test_shop_pool_keeps_internal_treasure_chest_type, failures)

	return {
		"passed": failures.is_empty(),
		"total": 2,
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


func _test_treasure_chest_content_displays_as_treasure_chests() -> String:
	var registry: RefCounted = _content_registry_script().new()
	var treasure_chests: Array[Dictionary] = registry.list_treasure_chests()
	if treasure_chests.is_empty():
		return "Expected default content to include treasure chest entries."
	for treasure_chest in treasure_chests:
		var display_name := String(treasure_chest.get("display_name", ""))
		var description := String(treasure_chest.get("description", ""))
		if display_name.findn("treasure_chest") >= 0 or description.findn("treasure_chest") >= 0:
			return "Expected public content copy to avoid internal treasure_chest wording for %s." % String(treasure_chest.get("id", ""))
		if display_name.findn("chest") < 0:
			return "Expected public display name to use chest wording for %s." % String(treasure_chest.get("id", ""))
	return ""


func _test_shop_pool_keeps_internal_treasure_chest_type() -> String:
	var registry: RefCounted = _content_registry_script().new()
	var pool: Array[Dictionary] = registry.shop_item_pool(1)
	for entry in pool:
		if String(entry.get("type", "")) == "treasure_chest":
			return ""
	return "Expected shop pool to include at least one treasure_chest type entry."


func _content_registry_script() -> GDScript:
	return ResourceLoader.load(CONTENT_REGISTRY_SCRIPT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
