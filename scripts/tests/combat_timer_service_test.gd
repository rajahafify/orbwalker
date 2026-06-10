extends RefCounted
class_name CombatTimerServiceTest

const TIMER_SERVICE_SCRIPT := preload("res://scripts/combat/combat_timer_service.gd")


class FakePlayerState:
	extends RefCounted

	var move_timer_seconds := 3.25


class FakeBoardController:
	extends RefCounted

	var active := false
	var time_left := 2.0
	var updates: Array[Dictionary] = []

	func active_drag() -> bool:
		return active

	func move_time_left() -> float:
		return time_left

	func update(delta: float, player_input_active: bool) -> Dictionary:
		time_left = maxf(0.0, time_left - delta)
		var payload := {
			"action": "tick",
			"delta": delta,
			"player_input_active": player_input_active,
		}
		updates.append(payload)
		return payload


class FakeView:
	extends RefCounted

	var displays: Array[Dictionary] = []

	func sync_timer_display(seconds_left: float, state: String) -> void:
		displays.append({
			"seconds_left": seconds_left,
			"state": state,
		})


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("ready_seconds_uses_player_or_default", _test_ready_seconds_uses_player_or_default, failures)
	_run_case("idle_process_syncs_ready_or_locked_state", _test_idle_process_syncs_ready_or_locked_state, failures)
	_run_case("active_process_updates_board_and_syncs_active_state", _test_active_process_updates_board_and_syncs_active_state, failures)
	_run_case("layout_helpers_report_active_or_ready", _test_layout_helpers_report_active_or_ready, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_ready_seconds_uses_player_or_default() -> String:
	var service: Variant = TIMER_SERVICE_SCRIPT.new()
	var player := FakePlayerState.new()
	if not is_equal_approx(service.ready_seconds(player), 3.25):
		return "Expected ready seconds to use player move_timer_seconds."
	if not is_equal_approx(service.ready_seconds(null), TIMER_SERVICE_SCRIPT.MOVE_TIMER_MAX_SECONDS):
		return "Expected null player state to use the move timer default."
	return ""


func _test_idle_process_syncs_ready_or_locked_state() -> String:
	var service: Variant = TIMER_SERVICE_SCRIPT.new()
	var player := FakePlayerState.new()
	var board := FakeBoardController.new()
	var view := FakeView.new()
	service.process(board, view, player, 0.5, true)
	service.process(board, view, player, 0.5, false)
	if view.displays.size() != 2:
		return "Expected idle processing to sync timer display twice."
	if String(view.displays[0].get("state", "")) != TIMER_SERVICE_SCRIPT.TIMER_STATE_READY:
		return "Expected player-input idle display to be ready."
	if not is_equal_approx(float(view.displays[0].get("seconds_left", 0.0)), 3.25):
		return "Expected ready display to use player move timer seconds."
	if String(view.displays[1].get("state", "")) != TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED:
		return "Expected locked idle display outside player input."
	if not is_equal_approx(float(view.displays[1].get("seconds_left", -1.0)), 0.0):
		return "Expected locked display to show zero seconds."
	return ""


func _test_active_process_updates_board_and_syncs_active_state() -> String:
	var service: Variant = TIMER_SERVICE_SCRIPT.new()
	var player := FakePlayerState.new()
	var board := FakeBoardController.new()
	board.active = true
	board.time_left = 2.0
	var view := FakeView.new()
	var result: Dictionary = service.process(board, view, player, 0.5, true)
	if board.updates.size() != 1:
		return "Expected active processing to update the board controller."
	if not bool(result.get("player_input_active", false)):
		return "Expected process result to preserve board update payload."
	if view.displays.size() != 1:
		return "Expected active processing to sync timer display once."
	if String(view.displays[0].get("state", "")) != TIMER_SERVICE_SCRIPT.TIMER_STATE_ACTIVE:
		return "Expected active drag display state."
	if not is_equal_approx(float(view.displays[0].get("seconds_left", 0.0)), 1.5):
		return "Expected active display to use updated board time left."
	return ""


func _test_layout_helpers_report_active_or_ready() -> String:
	var service: Variant = TIMER_SERVICE_SCRIPT.new()
	var player := FakePlayerState.new()
	var board := FakeBoardController.new()
	if service.layout_timer_state(board) != TIMER_SERVICE_SCRIPT.TIMER_STATE_READY:
		return "Expected idle layout state to be ready."
	if not is_equal_approx(service.layout_timer_seconds(board, player), 3.25):
		return "Expected idle layout seconds to be player ready seconds."
	board.active = true
	board.time_left = 1.25
	if service.layout_timer_state(board) != TIMER_SERVICE_SCRIPT.TIMER_STATE_ACTIVE:
		return "Expected active layout state."
	if not is_equal_approx(service.layout_timer_seconds(board, player), 1.25):
		return "Expected active layout seconds to be board time left."
	return ""
