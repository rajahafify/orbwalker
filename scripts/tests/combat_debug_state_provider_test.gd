extends RefCounted
class_name CombatDebugStateProviderTest

const PROVIDER_SCRIPT := preload("res://scripts/combat/combat_debug_state_provider.gd")


class FakeCombat:
	extends RefCounted

	var turn_index := 4


class FakePlayerState:
	extends RefCounted

	var current_hp := 17
	var max_hp := 30
	var armor := 5


class FakeEnemyState:
	extends RefCounted

	var display_name := "Vault Guard"
	var current_hp := 11
	var max_hp := 24
	var current_turn_block := 3


class FakeBoardModel:
	extends RefCounted

	var rng_seed := 123

	func to_debug_string() -> String:
		return "model-board"


class FakeBoardController:
	extends RefCounted

	func board_seed() -> int:
		return 456

	func board_debug_string() -> String:
		return "controller-board"


class FakeIntentFormatter:
	extends RefCounted

	func format_intent(intent: Dictionary) -> String:
		return "Formatted %s" % String(intent.get("label", ""))


class InputPhaseRecorder:
	extends RefCounted

	var value := 2

	func input_phase() -> int:
		return value


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("state_callbacks_return_bound_values", _test_state_callbacks_return_bound_values, failures)
	_run_case("board_values_prefer_controller_over_model", _test_board_values_prefer_controller_over_model, failures)
	_run_case("format_intent_uses_presenter_or_fallback", _test_format_intent_uses_presenter_or_fallback, failures)
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


func _test_state_callbacks_return_bound_values() -> String:
	var recorder := InputPhaseRecorder.new()
	var provider: Variant = PROVIDER_SCRIPT.new()
	(
		provider
		. bind(
			{
				"combat": FakeCombat.new(),
				"enemy_state": FakeEnemyState.new(),
				"player_state": FakePlayerState.new(),
				"input_phase_value": Callable(recorder, "input_phase"),
			}
		)
	)
	var callbacks: Dictionary = provider.callbacks()
	if int(callbacks["player_hp"].call()) != 17:
		return "Expected player HP callback to use the bound player state."
	if int(callbacks["player_max_hp"].call()) != 30:
		return "Expected player max HP callback to use the bound player state."
	if int(callbacks["player_armor"].call()) != 5:
		return "Expected player armor callback to use the bound player state."
	if String(callbacks["enemy_display_name"].call()) != "Vault Guard":
		return "Expected enemy display name callback to use the bound enemy state."
	if int(callbacks["enemy_hp"].call()) != 11 or int(callbacks["enemy_max_hp"].call()) != 24:
		return "Expected enemy HP callbacks to use the bound enemy state."
	if int(callbacks["enemy_turn_block"].call()) != 3:
		return "Expected enemy block callback to use the bound enemy state."
	if int(callbacks["input_phase_value"].call()) != 2:
		return "Expected input phase callback to call the injected getter."
	if callbacks["combat_state"].call() == null or callbacks["enemy_state"].call() == null:
		return "Expected state callbacks to expose combat and enemy objects."
	return ""


func _test_board_values_prefer_controller_over_model() -> String:
	var provider: Variant = PROVIDER_SCRIPT.new()
	(
		provider
		. bind(
			{
				"board_model": FakeBoardModel.new(),
				"board_controller": FakeBoardController.new(),
			}
		)
	)
	if provider.board_seed() != 456:
		return "Expected provider to prefer board controller seed."
	if provider.board_debug_text() != "controller-board":
		return "Expected provider to prefer board controller debug text."
	provider.bind({"board_model": FakeBoardModel.new()})
	if provider.board_seed() != 123:
		return "Expected provider to fall back to board model seed."
	if provider.board_debug_text() != "model-board":
		return "Expected provider to fall back to board model debug text."
	return ""


func _test_format_intent_uses_presenter_or_fallback() -> String:
	var provider: Variant = PROVIDER_SCRIPT.new()
	provider.bind({"turn_log_presenter": FakeIntentFormatter.new()})
	if provider.format_intent({"label": "Strike"}) != "Formatted Strike":
		return "Expected provider to use the injected intent formatter."
	provider.bind({})
	if provider.format_intent({"label": "Strike", "attack": 7, "block": 2}) != "Strike (Atk 7 / Block 2)":
		return "Expected provider to keep the legacy fallback intent text."
	return ""
