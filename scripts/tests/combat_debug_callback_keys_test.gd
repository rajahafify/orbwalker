extends RefCounted
class_name CombatDebugCallbackKeysTest

const ADAPTER_SCRIPT := preload("res://scripts/combat/combat_debug_command_adapter.gd")
const PROVIDER_SCRIPT := preload("res://scripts/combat/combat_debug_state_provider.gd")
const CALLBACK_KEYS := preload("res://scripts/combat/combat_debug_callback_keys.gd")


class FakeController:
	extends RefCounted

	func _console_set_status_text(_message: String) -> void:
		pass

	func _console_on_skip_success() -> void:
		pass

	func _create_new_board() -> void:
		pass

	func _set_board_seed(_board_seed: int) -> void:
		pass

	func _update_hud() -> void:
		pass

	func _debug_set_input_phase(_raw_phase: int) -> void:
		pass

	func _debug_set_pending_next_scene_path(_scene_path: String) -> void:
		pass

	func _show_outcome_summary(_title: String, _body: String, _show_next: bool, _button_text: String = "Continue") -> void:
		pass

	func _build_run_outcome_summary(_fallback_cause: String = "") -> String:
		return "summary"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("command_callback_catalog_matches_adapter", _test_command_callback_catalog_matches_adapter, failures)
	_run_case("state_callback_catalog_matches_provider", _test_state_callback_catalog_matches_provider, failures)
	_run_case("controller_action_catalog_builds_valid_callables", _test_controller_action_catalog_builds_valid_callables, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_command_callback_catalog_matches_adapter() -> String:
	var adapter: Variant = ADAPTER_SCRIPT.new()
	var callbacks: Dictionary = adapter.command_callbacks()
	return _expect_exact_keys(callbacks, CALLBACK_KEYS.COMMAND_CALLBACK_KEYS, "command callback")


func _test_state_callback_catalog_matches_provider() -> String:
	var provider: Variant = PROVIDER_SCRIPT.new()
	var callbacks: Dictionary = provider.callbacks()
	return _expect_exact_keys(callbacks, CALLBACK_KEYS.STATE_CALLBACK_KEYS, "state callback")


func _test_controller_action_catalog_builds_valid_callables() -> String:
	var controller := FakeController.new()
	var callbacks: Dictionary = ADAPTER_SCRIPT.controller_callbacks(controller)
	var error_text := _expect_exact_keys(callbacks, CALLBACK_KEYS.CONTROLLER_ACTION_METHODS.keys(), "controller action")
	if error_text != "":
		return error_text
	for key in CALLBACK_KEYS.CONTROLLER_ACTION_METHODS.keys():
		var method_name := String(CALLBACK_KEYS.CONTROLLER_ACTION_METHODS[key])
		if not controller.has_method(method_name):
			return "Expected fake controller to expose method for key %s: %s." % [String(key), method_name]
		if not (callbacks.get(key) is Callable):
			return "Expected controller action value to be a Callable for key: %s." % String(key)
	return ""


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
