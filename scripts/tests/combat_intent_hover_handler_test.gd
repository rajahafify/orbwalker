extends RefCounted
class_name CombatIntentHoverHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_intent_hover_handler.gd")
const WARNING_COLOR := Color(1.0, 0.86, 0.54, 1.0)


class FakeRunState:
	extends RefCounted

	func level_sequence_label() -> String:
		return "Depth 2"


class FakeCombat:
	extends RefCounted

	var fight_over := false

	func is_fight_over() -> bool:
		return fight_over


class FakeEnemyState:
	extends RefCounted

	var intent := {"attack": 12, "block": 4}

	func get_current_intent() -> Dictionary:
		return intent.duplicate(true)


class FakeModel:
	extends RefCounted

	var outcome_queued := false

	func is_outcome_transition_queued() -> bool:
		return outcome_queued


class FakeView:
	extends RefCounted

	var emphasis: Array[String] = []
	var stop_count := 0

	func start_enemy_intent_hover_emphasis(kind: String) -> void:
		emphasis.append(kind)

	func stop_enemy_intent_hover_emphasis() -> void:
		stop_count += 1


class CallbackRecorder:
	extends RefCounted

	var phase := 0
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []
	var summaries: Array[String] = []
	var formatted_intents: Array[Dictionary] = []

	func input_phase_value() -> int:
		return phase

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)

	func set_turn_summary_text(value: String) -> void:
		summaries.append(value)

	func format_intent(intent: Dictionary) -> String:
		formatted_intents.append(intent.duplicate(true))
		return "Intent: attack %d block %d" % [int(intent.get("attack", 0)), int(intent.get("block", 0))]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("damage_preview_sets_warning_summary_and_attack_emphasis", _test_damage_preview_sets_warning_summary_and_attack_emphasis, failures)
	_run_case("block_preview_sets_warning_and_block_emphasis", _test_block_preview_sets_warning_and_block_emphasis, failures)
	_run_case("enemy_block_preview_sets_warning_and_summary", _test_enemy_block_preview_sets_warning_and_summary, failures)
	_run_case("enemy_intent_bubble_formats_status_by_kind", _test_enemy_intent_bubble_formats_status_by_kind, failures)
	_run_case("hover_end_stops_enemy_intent_emphasis", _test_hover_end_stops_enemy_intent_emphasis, failures)
	_run_case("preview_gate_prevents_hover_side_effects", _test_preview_gate_prevents_hover_side_effects, failures)
	return {
		"passed": failures.is_empty(),
		"total": 6,
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


func _test_damage_preview_sets_warning_summary_and_attack_emphasis() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var view: FakeView = fixture["view"]
	handler.intent_damage_preview_hovered({"attack": 12, "blocked": 5, "hp_loss": 7})
	if recorder.status_texts != ["Depth 2 | Incoming 12 (Block 5, HP Loss 7)."]:
		return "Expected incoming damage status."
	if recorder.status_colors != [WARNING_COLOR]:
		return "Expected warning color."
	if recorder.summaries != ["Intent: attack 12 block 4"]:
		return "Expected formatted turn summary."
	if view.emphasis != ["attack"]:
		return "Expected attack emphasis."
	return ""


func _test_block_preview_sets_warning_and_block_emphasis() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var view: FakeView = fixture["view"]
	handler.intent_block_preview_hovered({"blocked": 6})
	if recorder.status_texts != ["Depth 2 | Incoming attack blocked by 6 armor."]:
		return "Expected blocked attack status."
	if recorder.status_colors != [WARNING_COLOR]:
		return "Expected warning color."
	if recorder.summaries != ["Intent: attack 12 block 4"]:
		return "Expected current intent summary."
	if view.emphasis != ["block"]:
		return "Expected block emphasis."
	return ""


func _test_enemy_block_preview_sets_warning_and_summary() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var view: FakeView = fixture["view"]
	handler.enemy_block_preview_hovered({"block": 9})
	if recorder.status_texts != ["Depth 2 | Enemy will gain 9 block."]:
		return "Expected enemy block preview status."
	if recorder.summaries != ["Intent: attack 12 block 4"]:
		return "Expected current intent summary."
	if view.emphasis != ["block"]:
		return "Expected block emphasis."
	return ""


func _test_enemy_intent_bubble_formats_status_by_kind() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var view: FakeView = fixture["view"]
	handler.enemy_intent_bubble_hovered("attack", {"amount": 7})
	handler.enemy_intent_bubble_hovered("block", {"amount": 3})
	handler.enemy_intent_bubble_hovered("buff", {"amount": 1, "label": "Focus"})
	if recorder.status_texts != [
		"Depth 2 | Enemy intent: Attack 7.",
		"Depth 2 | Enemy intent: Block 3.",
		"Depth 2 | Enemy intent: Focus.",
	]:
		return "Expected kind-specific bubble status text."
	if recorder.status_colors != [WARNING_COLOR, WARNING_COLOR, WARNING_COLOR]:
		return "Expected each bubble hover to set warning color."
	if view.emphasis != ["attack", "block", "buff"]:
		return "Expected bubble hover emphasis per kind."
	return ""


func _test_hover_end_stops_enemy_intent_emphasis() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	handler.intent_damage_preview_hover_ended()
	if view.stop_count != 1:
		return "Expected hover end to stop emphasis."
	return ""


func _test_preview_gate_prevents_hover_side_effects() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var model: FakeModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var view: FakeView = fixture["view"]
	recorder.phase = 2
	if handler.should_show_preview():
		return "Expected non-player input to hide preview."
	handler.intent_damage_preview_hovered({"attack": 12, "blocked": 5, "hp_loss": 7})
	recorder.phase = 0
	model.outcome_queued = true
	if handler.should_show_preview():
		return "Expected outcome transition to hide preview."
	handler.enemy_intent_bubble_hovered("attack", {"amount": 7})
	if not recorder.status_texts.is_empty() or not recorder.status_colors.is_empty() or not recorder.summaries.is_empty():
		return "Expected gated hover to avoid callback side effects."
	if not view.emphasis.is_empty():
		return "Expected gated hover to avoid view emphasis."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var combat := FakeCombat.new()
	var enemy_state := FakeEnemyState.new()
	var model := FakeModel.new()
	var view := FakeView.new()
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		{
			"run_state": run_state,
			"combat": combat,
			"enemy_state": enemy_state,
			"model": model,
			"view": view,
		},
		{
			HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(recorder, "input_phase_value"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
			HANDLER_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(recorder, "set_turn_summary_text"),
			HANDLER_SCRIPT.CALLBACK_FORMAT_INTENT: Callable(recorder, "format_intent"),
		},
		{
			"player_input_phase_value": 0,
			"warning_color": WARNING_COLOR,
		}
	)
	return {
		"handler": handler,
		"run_state": run_state,
		"combat": combat,
		"enemy_state": enemy_state,
		"model": model,
		"view": view,
		"recorder": recorder,
	}
