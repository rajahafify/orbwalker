extends RefCounted
class_name CombatDebugCallbackKeysTest

const PROVIDER_SCRIPT := preload("res://scripts/combat/combat_debug_state_provider.gd")
const CALLBACK_KEYS := preload("res://scripts/combat/combat_debug_callback_keys.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("command_callback_catalog_matches_adapter", _test_command_callback_catalog_matches_adapter, failures)
	_run_case("state_callback_catalog_matches_provider", _test_state_callback_catalog_matches_provider, failures)
	_run_case("controller_action_catalog_is_explicit_key_surface", _test_controller_action_catalog_is_explicit_key_surface, failures)
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


func _test_command_callback_catalog_matches_adapter() -> String:
	var adapter: Variant = load("res://scripts/combat/combat_debug_command_adapter.gd").new()
	var callbacks: Dictionary = adapter.command_callbacks()
	return _expect_exact_keys(callbacks, CALLBACK_KEYS.COMMAND_CALLBACK_KEYS, "command callback")


func _test_state_callback_catalog_matches_provider() -> String:
	var provider: Variant = PROVIDER_SCRIPT.new()
	var callbacks: Dictionary = provider.callbacks()
	return _expect_exact_keys(callbacks, CALLBACK_KEYS.STATE_CALLBACK_KEYS, "state callback")


func _test_controller_action_catalog_is_explicit_key_surface() -> String:
	var error_text := _expect_exact_keys(
		_key_array_to_dictionary(CALLBACK_KEYS.CONTROLLER_ACTION_CALLBACK_KEYS), CALLBACK_KEYS.CONTROLLER_ACTION_CALLBACK_KEYS, "controller action"
	)
	if error_text != "":
		return error_text
	if CALLBACK_KEYS.CONTROLLER_ACTION_CALLBACK_KEYS.has(CALLBACK_KEYS.COMBAT_STATE):
		return "Expected controller action keys to stay disjoint from state provider keys."
	for key in CALLBACK_KEYS.CONTROLLER_ACTION_CALLBACK_KEYS:
		if CALLBACK_KEYS.STATE_CALLBACK_KEYS.has(key):
			return "Expected controller action key to stay out of state callback keys: %s." % String(key)
	return ""


func _key_array_to_dictionary(keys: Array) -> Dictionary:
	var result := {}
	for key in keys:
		result[key] = true
	return result


func _expect_exact_keys(actual: Dictionary, expected: Array, label: String) -> String:
	var missing: Array[String] = []
	var extra: Array[String] = []
	for key in expected:
		if not actual.has(key):
			missing.append(String(key))
	for key in actual.keys():
		if not expected.has(key):
			extra.append(String(key))
	if not missing.is_empty():
		return "Expected %s keys to include: %s." % [label, ", ".join(missing)]
	if not extra.is_empty():
		return "Expected %s keys not to include extras: %s." % [label, ", ".join(extra)]
	return ""
