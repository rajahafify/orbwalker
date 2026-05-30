extends RefCounted
class_name CombatTutorialCoachmarkCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_tutorial_coachmark_coordinator.gd")
const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const WARNING_COLOR := Color(1.0, 0.86, 0.54, 1.0)


class FakeRunState:
	extends RefCounted

	var tutorial_run_active := true
	var dungeon_level := 1
	var current_step_key := "enemy_1"
	var progression := {"equipment_slots": []}

	func is_tutorial_run() -> bool:
		return tutorial_run_active

	func progression_snapshot() -> Dictionary:
		return progression.duplicate(true)


class FakeCombat:
	extends RefCounted

	var turn_index := 1
	var fight_over := false

	func is_fight_over() -> bool:
		return fight_over


class FakeView:
	extends RefCounted

	var modal_visible := false
	var shown_modal_steps: Array[String] = []
	var hide_modal_count := 0
	var focus_kinds: Array[String] = []
	var clear_focus_count := 0
	var emphasis_kinds: Array[String] = []
	var stop_emphasis_count := 0

	func is_tutorial_end_modal_visible() -> bool:
		return modal_visible

	func hide_tutorial_end_modal() -> void:
		hide_modal_count += 1
		modal_visible = false

	func show_tutorial_end_modal(step: String) -> void:
		shown_modal_steps.append(step)
		modal_visible = true

	func set_tutorial_enemy_intent_focus(kind: String) -> void:
		focus_kinds.append(kind)

	func clear_tutorial_enemy_intent_focus() -> void:
		clear_focus_count += 1

	func start_enemy_intent_hover_emphasis(kind: String) -> void:
		emphasis_kinds.append(kind)

	func stop_enemy_intent_hover_emphasis() -> void:
		stop_emphasis_count += 1


class FakeBoardView:
	extends RefCounted

	var hints: Array[Dictionary] = []
	var clear_count := 0

	func set_tutorial_hint(from_cell: Vector2i, to_cell: Vector2i, cells: Array[Vector2i] = []) -> void:
		hints.append({
			"from": from_cell,
			"to": to_cell,
			"cells": cells.duplicate(),
		})

	func clear_tutorial_hint() -> void:
		clear_count += 1


class FakeBoardController:
	extends RefCounted

	var restricted_paths: Array[Array] = []
	var restricted_swaps: Array[Dictionary] = []
	var clear_path_count := 0
	var clear_swap_count := 0

	func set_restricted_drag_path(path: Array[Vector2i]) -> void:
		restricted_paths.append(path.duplicate())

	func set_restricted_swap(from_cell: Vector2i, to_cell: Vector2i) -> void:
		restricted_swaps.append({"from": from_cell, "to": to_cell})

	func clear_restricted_drag_path() -> void:
		clear_path_count += 1

	func clear_restricted_swap() -> void:
		clear_swap_count += 1


class FakePromptPresenter:
	extends RefCounted

	var show_calls: Array[Dictionary] = []
	var hide_count := 0

	func show(message: String, prompt_anchor: String) -> void:
		show_calls.append({
			"message": message,
			"anchor": prompt_anchor,
		})

	func hide() -> void:
		hide_count += 1


class CallbackRecorder:
	extends RefCounted

	var phase := 0
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []

	func input_phase_value() -> int:
		return phase

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("sync_applies_first_swap_hint_and_prompt", _test_sync_applies_first_swap_hint_and_prompt, failures)
	_run_case("sync_focuses_attack_intent_for_armor_step", _test_sync_focuses_attack_intent_for_armor_step, failures)
	_run_case("shop_damage_step_shows_modal_status", _test_shop_damage_step_shows_modal_status, failures)
	_run_case("inactive_step_clears_modal_hints_and_restrictions", _test_inactive_step_clears_modal_hints_and_restrictions, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_sync_applies_first_swap_hint_and_prompt() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var board_view: FakeBoardView = fixture["board_view"]
	var board_controller: FakeBoardController = fixture["board_controller"]
	var prompt: FakePromptPresenter = fixture["prompt"]
	coordinator.sync()
	var expected_path: Array[Vector2i] = TUTORIAL_DIRECTOR_SCRIPT.FIRST_SWAP_PATH
	if board_view.hints.size() != 1:
		return "Expected tutorial hint to be applied."
	if board_view.hints[0].get("from") != expected_path[0] or board_view.hints[0].get("to") != expected_path[1]:
		return "Expected first swap hint endpoints."
	if board_controller.restricted_paths.size() != 1 or board_controller.restricted_paths[0] != expected_path:
		return "Expected restricted drag path to match first swap path."
	if prompt.show_calls.size() != 1 or String(prompt.show_calls[0].get("message", "")).find("Swap") < 0:
		return "Expected first swap prompt."
	if prompt.show_calls[0].get("anchor") != TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD:
		return "Expected first swap prompt anchor."
	return ""


func _test_sync_focuses_attack_intent_for_armor_step() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var combat: FakeCombat = fixture["combat"]
	var view: FakeView = fixture["view"]
	var prompt: FakePromptPresenter = fixture["prompt"]
	combat.turn_index = 2
	coordinator.sync()
	if view.focus_kinds != ["attack"] or view.emphasis_kinds != ["attack"]:
		return "Expected armor step to focus attack intent."
	if prompt.show_calls.is_empty() or prompt.show_calls[0].get("anchor") != TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM:
		return "Expected armor step to use bottom prompt anchor."
	return ""


func _test_shop_damage_step_shows_modal_status() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var run_state: FakeRunState = fixture["run_state"]
	var view: FakeView = fixture["view"]
	var prompt: FakePromptPresenter = fixture["prompt"]
	var recorder: CallbackRecorder = fixture["recorder"]
	run_state.current_step_key = "enemy_2"
	run_state.progression = {"equipment_slots": ["shortsword"]}
	coordinator.sync()
	if view.shown_modal_steps != [TUTORIAL_DIRECTOR_SCRIPT.POST_SHOP_SHORTSWORD]:
		return "Expected shop damage step to show first tutorial end modal."
	if prompt.hide_count != 1:
		return "Expected modal path to hide any active coachmark prompt first."
	if recorder.status_texts != ["Tutorial: Iron Shortsword adds +2 Attack."]:
		return "Expected shop damage modal status text."
	if recorder.status_colors != [WARNING_COLOR]:
		return "Expected warning color for tutorial modal."
	return ""


func _test_inactive_step_clears_modal_hints_and_restrictions() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var run_state: FakeRunState = fixture["run_state"]
	var view: FakeView = fixture["view"]
	var board_view: FakeBoardView = fixture["board_view"]
	var board_controller: FakeBoardController = fixture["board_controller"]
	var prompt: FakePromptPresenter = fixture["prompt"]
	view.modal_visible = true
	run_state.tutorial_run_active = false
	coordinator.sync()
	if view.hide_modal_count != 1:
		return "Expected inactive tutorial to hide visible tutorial modal."
	if prompt.hide_count != 1:
		return "Expected inactive tutorial to hide coachmark prompt."
	if board_view.clear_count != 1:
		return "Expected inactive tutorial to clear board hint."
	if board_controller.clear_path_count != 1:
		return "Expected inactive tutorial to clear restricted drag path."
	if view.clear_focus_count != 1:
		return "Expected inactive tutorial to clear enemy intent focus."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var combat := FakeCombat.new()
	var director: Variant = TUTORIAL_DIRECTOR_SCRIPT.new()
	var view := FakeView.new()
	var board_view := FakeBoardView.new()
	var board_controller := FakeBoardController.new()
	var prompt := FakePromptPresenter.new()
	var recorder := CallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(
		{
			"run_state": run_state,
			"combat": combat,
			"tutorial_director": director,
			"view": view,
			"board_view": board_view,
			"board_controller": board_controller,
			"prompt_presenter": prompt,
		},
		{
			COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(recorder, "input_phase_value"),
			COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
		},
		{
			"player_input_phase_value": 0,
			"warning_status_color": WARNING_COLOR,
		}
	)
	return {
		"coordinator": coordinator,
		"run_state": run_state,
		"combat": combat,
		"director": director,
		"view": view,
		"board_view": board_view,
		"board_controller": board_controller,
		"prompt": prompt,
		"recorder": recorder,
	}
