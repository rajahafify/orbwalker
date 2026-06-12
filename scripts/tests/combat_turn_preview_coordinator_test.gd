extends RefCounted
class_name CombatTurnPreviewCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_preview_coordinator.gd")


class FakeCombat:
	extends RefCounted

	var turn_index := 3
	var fight_over := false
	var reset_calls := 0
	var begin_input_calls := 0

	func is_fight_over() -> bool:
		return fight_over

	func reset_to_intent_preview() -> void:
		reset_calls += 1

	func begin_player_input() -> void:
		begin_input_calls += 1


class FakeEnemyState:
	extends RefCounted

	func get_current_intent() -> Dictionary:
		return {"kind": "attack", "amount": 7}


class FakeModel:
	extends RefCounted

	var clear_pending_calls := 0

	func clear_pending_next_scene_path() -> void:
		clear_pending_calls += 1


class FakeViewActions:
	extends RefCounted

	var hidden_outcome_calls := 0
	var summary_text := ""
	var status_text := ""
	var status_color := Color.TRANSPARENT
	var log_lines: Array[String] = []

	func hide_outcome_summary() -> void:
		hidden_outcome_calls += 1

	func set_turn_summary_text(text: String) -> void:
		summary_text = text

	func set_status_text(text: String) -> void:
		status_text = text

	func set_status_color(color: Color) -> void:
		status_color = color

	func append_combat_log(text: String) -> void:
		log_lines.append(text)


class FakeRunState:
	extends RefCounted

	var tutorial := false

	func is_tutorial_run() -> bool:
		return tutorial

	func level_sequence_label() -> String:
		return "Level 2-1"


class Recorder:
	extends RefCounted

	var input_phase := -1
	var update_hud_calls := 0
	var clear_hover_calls := 0
	var sync_coachmark_calls := 0

	func set_input_phase(value: int) -> void:
		input_phase = value

	func update_hud() -> void:
		update_hud_calls += 1

	func clear_mastery_hover() -> void:
		clear_hover_calls += 1

	func sync_tutorial_coachmark() -> void:
		sync_coachmark_calls += 1

	func format_intent(intent: Dictionary) -> String:
		return "%s %d" % [String(intent.get("kind", "")), int(intent.get("amount", 0))]

	func tutorial_turn_summary_text() -> String:
		return "Tutorial summary"

	func tutorial_turn_status_text() -> String:
		return "Tutorial status"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("begin_turn_preview_updates_normal_turn_state", _test_begin_turn_preview_updates_normal_turn_state, failures)
	_run_case("tutorial_mode_uses_tutorial_text_callbacks", _test_tutorial_mode_uses_tutorial_text_callbacks, failures)
	_run_case("fight_over_skips_preview_updates", _test_fight_over_skips_preview_updates, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_begin_turn_preview_updates_normal_turn_state() -> String:
	var fixture := _fixture()
	fixture.coordinator.begin_turn_preview()
	if fixture.combat.reset_calls != 1 or fixture.combat.begin_input_calls != 1:
		return "Expected combat intent preview reset and player input begin."
	if fixture.recorder.input_phase != 6:
		return "Expected coordinator to set configured player input phase."
	if fixture.model.clear_pending_calls != 1 or fixture.view_actions.hidden_outcome_calls != 1:
		return "Expected pending scene and outcome summary to be cleared."
	if fixture.view_actions.summary_text != "Turn Summary: Awaiting move.":
		return "Expected normal turn summary text."
	if fixture.view_actions.status_text != "Level 2-1 | Turn 3.":
		return "Expected level and turn status text."
	if fixture.view_actions.status_color != Color.CYAN:
		return "Expected configured neutral status color."
	if fixture.recorder.update_hud_calls != 1 or fixture.recorder.clear_hover_calls != 1 or fixture.recorder.sync_coachmark_calls != 1:
		return "Expected HUD, mastery hover, and tutorial coachmark callbacks."
	if fixture.view_actions.log_lines != ["Turn 3 intent: attack 7."]:
		return "Expected formatted intent combat log line."
	return ""


func _test_tutorial_mode_uses_tutorial_text_callbacks() -> String:
	var fixture := _fixture()
	fixture.run_state.tutorial = true
	fixture.coordinator.begin_turn_preview()
	if fixture.view_actions.summary_text != "Tutorial summary":
		return "Expected tutorial summary callback text."
	if fixture.view_actions.status_text != "Tutorial status":
		return "Expected tutorial status callback text."
	return ""


func _test_fight_over_skips_preview_updates() -> String:
	var fixture := _fixture()
	fixture.combat.fight_over = true
	fixture.coordinator.begin_turn_preview()
	if fixture.combat.reset_calls != 0 or fixture.recorder.update_hud_calls != 0:
		return "Expected fight-over preview to skip state updates."
	if not fixture.view_actions.log_lines.is_empty():
		return "Expected fight-over preview not to append combat log."
	return ""


func _fixture() -> Dictionary:
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	var combat := FakeCombat.new()
	var enemy_state := FakeEnemyState.new()
	var model := FakeModel.new()
	var view_actions := FakeViewActions.new()
	var run_state := FakeRunState.new()
	var recorder := Recorder.new()
	(
		coordinator
		. bind(
			{"combat": combat, "enemy_state": enemy_state, "model": model, "view_actions": view_actions, "run_state": run_state},
			{
				COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(recorder, "set_input_phase"),
				COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
				COORDINATOR_SCRIPT.CALLBACK_CLEAR_MASTERY_HOVER: Callable(recorder, "clear_mastery_hover"),
				COORDINATOR_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: Callable(recorder, "sync_tutorial_coachmark"),
				COORDINATOR_SCRIPT.CALLBACK_FORMAT_INTENT: Callable(recorder, "format_intent"),
				COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_SUMMARY_TEXT: Callable(recorder, "tutorial_turn_summary_text"),
				COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_STATUS_TEXT: Callable(recorder, "tutorial_turn_status_text"),
			},
			{"player_input_phase_value": 6, "status_color_neutral": Color.CYAN}
		)
	)
	return {
		"coordinator": coordinator,
		"combat": combat,
		"model": model,
		"view_actions": view_actions,
		"run_state": run_state,
		"recorder": recorder,
	}
