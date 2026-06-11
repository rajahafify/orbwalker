extends RefCounted
class_name CombatTurnResolutionCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_resolution_coordinator.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("callback_catalog_exposes_required_turn_resolution_seams", _test_callback_catalog_exposes_required_turn_resolution_seams, failures)
	_run_case("resolved_board_routes_only_while_resolving", _test_resolved_board_routes_only_while_resolving, failures)
	_run_case("post_turn_stop_guard_uses_continue_callback", _test_post_turn_stop_guard_uses_continue_callback, failures)
	_run_case("resolved_board_flow_skips_when_phase_changed", _test_resolved_board_flow_skips_when_phase_changed, failures)
	_run_case("resolved_board_flow_routes_and_reports_outcome", _test_resolved_board_flow_routes_and_reports_outcome, failures)
	_run_case("missing_continue_callback_stops_safely", _test_missing_continue_callback_stops_safely, failures)
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


func _test_callback_catalog_exposes_required_turn_resolution_seams() -> String:
	var expected := [
		"can_continue",
		"replay_turn_resolution",
		"sync_mastery_totals",
		"update_hud",
		"current_route_id",
	]
	var actual := [
		COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE,
		COORDINATOR_SCRIPT.CALLBACK_REPLAY_TURN_RESOLUTION,
		COORDINATOR_SCRIPT.CALLBACK_SYNC_MASTERY_TOTALS,
		COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD,
		COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID,
	]
	if actual != expected:
		return "Expected turn-resolution callback catalog to stay stable."
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind({}, {}, {})
	return ""


func _test_resolved_board_routes_only_while_resolving() -> String:
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind({}, {}, {COORDINATOR_SCRIPT.CONFIG_RESOLVING_INPUT_PHASE_VALUE: 42})
	if not coordinator.should_route_resolved_board_to_combat(42):
		return "Expected resolved board output to route into combat while the configured resolving phase is active."
	if coordinator.should_route_resolved_board_to_combat(0):
		return "Expected player-input phase to skip combat turn routing after board resolve."
	if coordinator.should_route_resolved_board_to_combat(7):
		return "Expected externally changed phases to skip combat turn routing after board resolve."
	return ""


func _test_post_turn_stop_guard_uses_continue_callback() -> String:
	var blocked_recorder := ContinueRecorder.new(false)
	var blocked_coordinator: Variant = COORDINATOR_SCRIPT.new()
	blocked_coordinator.bind({}, {COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: Callable(blocked_recorder, "can_continue")}, {})
	if not blocked_coordinator.should_stop_after_turn_resolution():
		return "Expected post-turn guard to stop when the continue callback rejects the async state."
	if blocked_recorder.calls != 1:
		return "Expected post-turn guard to call the continue callback once."

	var allowed_recorder := ContinueRecorder.new(true)
	var allowed_coordinator: Variant = COORDINATOR_SCRIPT.new()
	allowed_coordinator.bind({}, {COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: Callable(allowed_recorder, "can_continue")}, {})
	if allowed_coordinator.should_stop_after_turn_resolution():
		return "Expected post-turn guard to continue when the callback accepts the async state."
	if allowed_recorder.calls != 1:
		return "Expected allowed post-turn guard to call the continue callback once."
	return ""


func _test_resolved_board_flow_skips_when_phase_changed() -> String:
	var fixture := FlowFixture.new()
	var coordinator: Variant = fixture.coordinator
	var result: Dictionary = await coordinator.handle_resolved_board_turn(7, {"total_combos": 3})
	if bool(result.get("routed", true)):
		return "Expected changed input phase to skip combat turn resolution."
	if bool(result.get("stop", true)):
		return "Expected skipped combat turn route to let controller finish resolve cleanup."
	if fixture.combat.resolve_calls != 0:
		return "Expected skipped combat turn route not to resolve player turn."
	return ""


func _test_resolved_board_flow_routes_and_reports_outcome() -> String:
	var fixture := FlowFixture.new()
	fixture.recorder.continue_results = [true, true]
	var coordinator: Variant = fixture.coordinator
	var result: Dictionary = await coordinator.handle_resolved_board_turn(42, {"total_combos": 3, "passes": [{}, {}]})
	if not bool(result.get("routed", false)):
		return "Expected resolving input phase to route combat turn resolution."
	if bool(result.get("stop", true)):
		return "Expected successful async continuation to keep controller cleanup moving."
	if String(result.get("route", "")) != "normal_turn":
		return "Expected routed flow to expose the outcome route."
	if fixture.combat.resolve_calls != 1:
		return "Expected combat player turn to resolve once."
	if fixture.run_state.logged_metadata != [{"total_combos": 3, "resolve_pass_count": 2}]:
		return "Expected routed flow to preserve turn-log metadata."
	if fixture.recorder.continue_calls != 2:
		return "Expected routed flow to preserve both async continuation checks."
	return ""


func _test_missing_continue_callback_stops_safely() -> String:
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind({}, {}, {})
	if not coordinator.should_stop_after_turn_resolution():
		return "Expected missing continue callback to stop safely."
	return ""


class ContinueRecorder:
	extends RefCounted

	var calls := 0
	var result := true

	func _init(initial_result: bool) -> void:
		result = initial_result

	func can_continue() -> bool:
		calls += 1
		return result


class FlowFixture:
	extends RefCounted

	var combat := FakeCombat.new()
	var model := FakeModel.new()
	var run_state := FakeRunState.new()
	var hud_stage := FakeHudStage.new()
	var outcome := FakeOutcomeRoute.new()
	var recorder := FlowCallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()

	func _init() -> void:
		(
			coordinator
			. bind(
				{
					"combat": combat,
					"model": model,
					"run_state": run_state,
					"hud_stage_coordinator": hud_stage,
					"outcome_route_coordinator": outcome,
				},
				{
					COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: Callable(recorder, "can_continue"),
					COORDINATOR_SCRIPT.CALLBACK_REPLAY_TURN_RESOLUTION: Callable(recorder, "replay_turn_resolution"),
					COORDINATOR_SCRIPT.CALLBACK_SYNC_MASTERY_TOTALS: Callable(recorder, "sync_mastery_totals"),
					COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
					COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(recorder, "current_route_id"),
				},
				{COORDINATOR_SCRIPT.CONFIG_RESOLVING_INPUT_PHASE_VALUE: 42}
			)
		)


class FakeCombat:
	extends RefCounted

	var phase := 5
	var resolve_calls := 0

	func resolve_player_turn(_resolve_result: Dictionary) -> Dictionary:
		resolve_calls += 1
		return {"enemy_damage_taken": 4, "healed": 1, "armor_gained": 2, "gold_gained": 3}


class FakeModel:
	extends RefCounted

	var staging_begun := 0
	var staging_cleared := 0

	func begin_hud_staging(_values: Dictionary) -> void:
		staging_begun += 1

	func clear_hud_staging() -> void:
		staging_cleared += 1


class FakeRunState:
	extends RefCounted

	var logged_metadata: Array[Dictionary] = []
	var trace_steps: Array[String] = []

	func log_turn_result(_turn_log: Dictionary, metadata: Dictionary) -> void:
		logged_metadata.append(metadata.duplicate())

	func flow_trace_mark(step: String, _payload: Dictionary = {}, _route_id: String = "") -> void:
		trace_steps.append(step)


class FakeHudStage:
	extends RefCounted

	func capture_values() -> Dictionary:
		return {"hp": 10}


class FakeOutcomeRoute:
	extends RefCounted

	func handle_turn_outcome(_phase: int, _turn_log: Dictionary) -> Dictionary:
		return {"route": "normal_turn"}


class FlowCallbackRecorder:
	extends RefCounted

	var continue_results: Array[bool] = [true, true]
	var continue_calls := 0
	var replay_calls := 0
	var sync_calls := 0
	var update_calls := 0

	func can_continue() -> bool:
		var result := true
		if continue_calls < continue_results.size():
			result = bool(continue_results[continue_calls])
		continue_calls += 1
		return result

	func replay_turn_resolution(_turn_log: Dictionary) -> void:
		replay_calls += 1

	func sync_mastery_totals() -> void:
		sync_calls += 1

	func update_hud() -> void:
		update_calls += 1

	func current_route_id() -> String:
		return "route-test"
