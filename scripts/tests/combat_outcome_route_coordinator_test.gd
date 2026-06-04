extends RefCounted
class_name CombatOutcomeRouteCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_outcome_route_coordinator.gd")
const VICTORY_PHASE := 6
const DEFEAT_PHASE := 7
const LOCKED_PHASE := 4
const SHOP_SCENE := "res://scenes/shop.tscn"
const RUN_SUMMARY_SCENE := "res://scenes/run_summary.tscn"


class FakeRunState:
	extends RefCounted

	const SCENE_RUN_SUMMARY := "res://scenes/run_summary.tscn"

	var boss_reward := false
	var victory_transition := {"next_scene": SHOP_SCENE, "step": "shop"}
	var defeat_transition := {"next_scene": RUN_SUMMARY_SCENE}
	var marks: Array[Dictionary] = []
	var victory_calls := 0
	var defeat_causes: Array[String] = []

	func mark_fight_victory() -> Dictionary:
		victory_calls += 1
		return victory_transition.duplicate()

	func is_current_step_boss_reward() -> bool:
		return boss_reward

	func mark_player_defeated(cause: String) -> Dictionary:
		defeat_causes.append(cause)
		return defeat_transition.duplicate()

	func flow_trace_mark(step: String, payload: Dictionary = {}, route_id: String = "", target_scene: String = "") -> void:
		marks.append({
			"step": step,
			"payload": payload.duplicate(),
			"route_id": route_id,
			"target_scene": target_scene,
		})


class FakeModel:
	extends RefCounted

	var pending := ""

	func set_pending_next_scene_path(path: String) -> void:
		pending = path

	func clear_pending_next_scene_path() -> void:
		pending = ""

	func pending_next_scene_path() -> String:
		return pending


class FakeEnemyState:
	extends RefCounted

	var display_name := "Test Enemy"


class FakeTurnLogPresenter:
	extends RefCounted

	func build_victory_gold_summary(_turn_log: Dictionary, transition: Dictionary) -> String:
		return "Victory body %s" % String(transition.get("step", ""))

	func build_victory_status(_turn_log: Dictionary, _transition: Dictionary) -> String:
		return "Victory status."

	func build_defeat_cause(enemy_name: String, _turn_log: Dictionary) -> String:
		return "%s defeated you" % enemy_name

	func build_defeat_status(_turn_log: Dictionary) -> String:
		return "Defeat status."

	func build_turn_summary_status(_turn_log: Dictionary) -> String:
		return "Turn status."


class Recorder:
	extends RefCounted

	var sfx: Array[String] = []
	var input_phases: Array[int] = []
	var turn_logs: Array[Dictionary] = []
	var status_texts: Array[String] = []
	var status_colors: Array = []
	var combat_logs: Array[String] = []
	var boss_summaries: Array[String] = []
	var turn_summaries: Array[String] = []
	var route_id := "route-1"
	var hidden_summaries := 0
	var scene_changes: Array[Dictionary] = []
	var outcome_summaries: Array[Dictionary] = []
	var pulses: Array = []
	var preview_calls := 0

	func play_sfx(cue: String) -> void:
		sfx.append(cue)

	func set_input_phase(phase: int) -> void:
		input_phases.append(phase)

	func append_turn_log(turn_log: Dictionary) -> void:
		turn_logs.append(turn_log.duplicate())

	func set_status_text(text: String) -> void:
		status_texts.append(text)

	func set_status_color(color) -> void:
		status_colors.append(color)

	func append_combat_log(text: String) -> void:
		combat_logs.append(text)

	func show_boss_reward_summary(text: String) -> void:
		boss_summaries.append(text)

	func set_turn_summary_text(text: String) -> void:
		turn_summaries.append(text)

	func current_route_id() -> String:
		return route_id

	func hide_outcome_summary() -> void:
		hidden_summaries += 1

	func trace_and_change_scene(target_scene: String, route: String, source: String, before_change_step: String, extra: Dictionary = {}) -> void:
		scene_changes.append({
			"target_scene": target_scene,
			"route_id": route,
			"source": source,
			"before_change_step": before_change_step,
			"extra": extra,
		})

	func show_outcome_summary(title: String, body: String, show_button: bool, button_text: String = "Continue") -> void:
		outcome_summaries.append({
			"title": title,
			"body": body,
			"show_button": show_button,
			"button_text": button_text,
		})

	func pulse_turn_summary(color) -> void:
		pulses.append(color)

	func begin_turn_preview() -> void:
		preview_calls += 1

	func build_run_outcome_summary(cause: String) -> String:
		return "Run outcome: %s" % cause


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("victory_continue_sets_pending_route_and_summary", _test_victory_continue_sets_pending_route_and_summary, failures)
	_run_case("boss_reward_holds_pending_route", _test_boss_reward_holds_pending_route, failures)
	_run_case("final_victory_auto_routes_to_summary", _test_final_victory_auto_routes_to_summary, failures)
	_run_case("defeat_sets_run_summary_pending", _test_defeat_sets_run_summary_pending, failures)
	_run_case("normal_turn_updates_summary_and_begins_next_preview", _test_normal_turn_updates_summary_and_begins_next_preview, failures)
	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_victory_continue_sets_pending_route_and_summary() -> String:
	var fixture := _new_fixture()
	var result: Dictionary = fixture.coordinator.handle_turn_outcome(VICTORY_PHASE, {"gold_gained": 7})
	if result.get("route") != "victory_continue":
		return "Expected victory_continue route."
	if fixture.model.pending != SHOP_SCENE:
		return "Expected shop scene to become pending next scene."
	if fixture.recorder.sfx != ["victory"] or fixture.recorder.input_phases != [LOCKED_PHASE]:
		return "Expected victory SFX and external input lock."
	if fixture.recorder.outcome_summaries.is_empty() or fixture.recorder.outcome_summaries[0].get("title") != "Victory":
		return "Expected victory outcome summary."
	return _expect_mark(fixture.run_state, "combat_continue_available", SHOP_SCENE)


func _test_boss_reward_holds_pending_route() -> String:
	var fixture := _new_fixture()
	fixture.model.pending = SHOP_SCENE
	fixture.run_state.boss_reward = true
	var result: Dictionary = fixture.coordinator.handle_turn_outcome(VICTORY_PHASE, {})
	if result.get("route") != "boss_reward":
		return "Expected boss_reward route."
	if fixture.model.pending != "":
		return "Expected boss reward to clear pending scene."
	if fixture.recorder.boss_summaries.is_empty():
		return "Expected boss reward summary callback."
	if not fixture.recorder.status_texts.has("Boss defeated. Choose one boss relic before continuing."):
		return "Expected boss reward status text."
	return _expect_mark(fixture.run_state, "combat_boss_reward_available", "")


func _test_final_victory_auto_routes_to_summary() -> String:
	var fixture := _new_fixture()
	fixture.run_state.victory_transition = {"next_scene": RUN_SUMMARY_SCENE, "step": "summary"}
	var result: Dictionary = fixture.coordinator.handle_turn_outcome(VICTORY_PHASE, {})
	if result.get("route") != "final_summary":
		return "Expected final_summary route."
	if fixture.recorder.hidden_summaries != 1:
		return "Expected outcome summary to hide before auto route."
	if fixture.recorder.scene_changes.is_empty():
		return "Expected final victory scene change."
	var change: Dictionary = fixture.recorder.scene_changes[0]
	if change.get("target_scene") != RUN_SUMMARY_SCENE or change.get("source") != "combat_final_summary_auto":
		return "Expected final summary scene-change metadata."
	return ""


func _test_defeat_sets_run_summary_pending() -> String:
	var fixture := _new_fixture()
	var result: Dictionary = fixture.coordinator.handle_turn_outcome(DEFEAT_PHASE, {})
	if result.get("route") != "defeat_summary":
		return "Expected defeat_summary route."
	if fixture.model.pending != RUN_SUMMARY_SCENE:
		return "Expected run summary pending scene."
	if fixture.run_state.defeat_causes != ["Test Enemy defeated you"]:
		return "Expected defeat cause to use enemy display name."
	if fixture.recorder.outcome_summaries.is_empty() or fixture.recorder.outcome_summaries[0].get("button_text") != "Run Summary":
		return "Expected defeat summary button text."
	return _expect_mark(fixture.run_state, "combat_continue_available", RUN_SUMMARY_SCENE)


func _test_normal_turn_updates_summary_and_begins_next_preview() -> String:
	var fixture := _new_fixture()
	var result: Dictionary = fixture.coordinator.handle_turn_outcome(0, {"enemy_damage_taken": 2})
	if result.get("route") != "continue_turn":
		return "Expected continue_turn route."
	if fixture.recorder.status_texts != ["Turn status."]:
		return "Expected normal turn status text."
	if fixture.recorder.turn_summaries != ["Turn Summary: Turn status."]:
		return "Expected normal turn summary text."
	if fixture.recorder.preview_calls != 1:
		return "Expected next turn preview to begin."
	return ""


func _new_fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var model := FakeModel.new()
	var recorder := Recorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(
		{
			"run_state": run_state,
			"model": model,
			"enemy_state": FakeEnemyState.new(),
			"turn_log_presenter": FakeTurnLogPresenter.new(),
		},
		{
			COORDINATOR_SCRIPT.CALLBACK_PLAY_SFX: Callable(recorder, "play_sfx"),
			COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(recorder, "set_input_phase"),
			COORDINATOR_SCRIPT.CALLBACK_APPEND_TURN_LOG: Callable(recorder, "append_turn_log"),
			COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
			COORDINATOR_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(recorder, "append_combat_log"),
			COORDINATOR_SCRIPT.CALLBACK_SHOW_BOSS_REWARD_SUMMARY: Callable(recorder, "show_boss_reward_summary"),
			COORDINATOR_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(recorder, "set_turn_summary_text"),
			COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(recorder, "current_route_id"),
			COORDINATOR_SCRIPT.CALLBACK_HIDE_OUTCOME_SUMMARY: Callable(recorder, "hide_outcome_summary"),
			COORDINATOR_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(recorder, "trace_and_change_scene"),
			COORDINATOR_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(recorder, "show_outcome_summary"),
			COORDINATOR_SCRIPT.CALLBACK_PULSE_TURN_SUMMARY: Callable(recorder, "pulse_turn_summary"),
			COORDINATOR_SCRIPT.CALLBACK_BEGIN_TURN_PREVIEW: Callable(recorder, "begin_turn_preview"),
			COORDINATOR_SCRIPT.CALLBACK_BUILD_RUN_OUTCOME_SUMMARY: Callable(recorder, "build_run_outcome_summary"),
		},
		{
			"victory_phase_value": VICTORY_PHASE,
			"defeat_phase_value": DEFEAT_PHASE,
			"locked_input_phase_value": LOCKED_PHASE,
			"positive_color": Color.GREEN,
			"negative_color": Color.RED,
			"default_victory_scene": "res://scenes/main_menu.tscn",
			"run_summary_scene": RUN_SUMMARY_SCENE,
		}
	)
	return {
		"coordinator": coordinator,
		"run_state": run_state,
		"model": model,
		"recorder": recorder,
	}


func _expect_mark(run_state: FakeRunState, step: String, target_scene: String) -> String:
	for mark in run_state.marks:
		if mark.get("step") == step and String(mark.get("target_scene", "")) == target_scene:
			return ""
	return "Expected trace mark %s for target %s." % [step, target_scene]
