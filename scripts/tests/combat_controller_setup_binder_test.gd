extends RefCounted
class_name CombatControllerSetupBinderTest

const BINDER_SCRIPT := preload("res://scripts/combat/combat_controller_setup_binder.gd")


class FakeDebugRuntime:
	extends RefCounted

	var bind_args: Array = []
	var console_ref := RefCounted.new()

	func bind_for_combat_controller(
		view: Variant, turn_log_presenter: Variant, action_callbacks: Dictionary, locked_phase: int, config: Dictionary, state_callbacks: Dictionary
	) -> void:
		bind_args = [view, turn_log_presenter, action_callbacks, locked_phase, config, state_callbacks]

	func console() -> Variant:
		return console_ref


class FakeDebugRuntimeScript:
	extends RefCounted

	func new() -> FakeDebugRuntime:
		return FakeDebugRuntime.new()


class FakeSettingsCommandHandler:
	extends RefCounted

	var bind_args: Array = []

	func bind_for_combat_controller(
		view: Variant,
		model: Variant,
		resolve_presenter: Variant,
		settings_owner: Variant,
		current_turn_index_provider: Callable,
		trace_and_change_scene: Callable,
		player_input_phase: int,
		locked_phase: int,
		neutral_color: Color
	) -> void:
		bind_args = [
			view, model, resolve_presenter, settings_owner, current_turn_index_provider, trace_and_change_scene, player_input_phase, locked_phase, neutral_color
		]


class FakeSettingsCommandHandlerScript:
	extends RefCounted

	func new() -> FakeSettingsCommandHandler:
		return FakeSettingsCommandHandler.new()


class FakeBoardController:
	extends RefCounted

	var bind_args: Array = []

	func bind(dependencies: Dictionary, callbacks: Dictionary) -> void:
		bind_args = [dependencies, callbacks]


class Recorder:
	extends RefCounted

	var bind_debug_calls := 0
	var feedback_calls := 0

	func bind_debug_state_provider() -> void:
		bind_debug_calls += 1

	func apply_feedback_settings() -> void:
		feedback_calls += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("bind_debug_console_creates_runtime_and_returns_console", _test_bind_debug_console_creates_runtime_and_returns_console, failures)
	_run_case("bind_settings_command_handler_creates_and_binds_handler", _test_bind_settings_command_handler_creates_and_binds_handler, failures)
	_run_case("bind_board_controller_binds_dependencies_and_feedback", _test_bind_board_controller_binds_dependencies_and_feedback, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_bind_debug_console_creates_runtime_and_returns_console() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var recorder := Recorder.new()
	var view := RefCounted.new()
	var turn_log := RefCounted.new()
	var result: Dictionary = (
		binder
		. bind_debug_console(
			{
				"debug_runtime": null,
				"debug_runtime_script": FakeDebugRuntimeScript.new(),
				"view": view,
				"turn_log_presenter": turn_log,
				"action_callbacks": {"skip": Callable()},
				"debug_state_callbacks": {"snapshot": Callable()},
			},
			{"bind_debug_state_provider": Callable(recorder, "bind_debug_state_provider")},
			{"locked_external_phase_value": 3, "command_output_log_color": Color.ORANGE, "max_combat_log_lines": 8, "initial_log_level": "detailed"}
		)
	)
	var runtime: FakeDebugRuntime = result.get("debug_runtime")
	if runtime == null or result.get("debug_console") != runtime.console_ref:
		return "Expected created debug runtime and returned console reference."
	if recorder.bind_debug_calls != 1:
		return "Expected debug-state provider callback before runtime bind."
	if runtime.bind_args[0] != view or runtime.bind_args[1] != turn_log or int(runtime.bind_args[3]) != 3:
		return "Expected debug runtime dependencies and locked phase."
	if int(runtime.bind_args[4].get("max_combat_log_lines")) != 8:
		return "Expected debug runtime config to be forwarded."
	if String(runtime.bind_args[4].get("initial_log_level", "")) != "detailed":
		return "Expected debug runtime log level to stay string-typed."
	return ""


func _test_bind_settings_command_handler_creates_and_binds_handler() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var turn_provider := func() -> int: return 4
	var trace_callback := func(_scene_path: String, _source: String, _mark: String) -> void: pass
	var handler: FakeSettingsCommandHandler = (
		binder
		. bind_settings_command_handler(
			{
				"settings_command_handler": null,
				"settings_command_handler_script": FakeSettingsCommandHandlerScript.new(),
				"view": "view",
				"model": "model",
				"resolve_presenter": "resolve",
				"settings_owner": "owner",
			},
			{"current_turn_index_provider": turn_provider, "trace_and_change_scene": trace_callback},
			{"player_input_phase_value": 5, "locked_external_phase_value": 6, "status_color_neutral": Color.CYAN}
		)
	)
	if handler == null:
		return "Expected settings handler to be created."
	if handler.bind_args[0] != "view" or handler.bind_args[2] != "resolve" or handler.bind_args[3] != "owner":
		return "Expected settings dependencies to be forwarded."
	if int(handler.bind_args[4].call()) != 4 or int(handler.bind_args[6]) != 5 or int(handler.bind_args[7]) != 6:
		return "Expected settings callbacks and phase config."
	if handler.bind_args[8] != Color.CYAN:
		return "Expected settings neutral color config."
	return ""


func _test_bind_board_controller_binds_dependencies_and_feedback() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var recorder := Recorder.new()
	var board_controller := FakeBoardController.new()
	(
		binder
		. bind_board_controller(
			{"board_controller": board_controller, "board_view": "view", "board_model": "model"},
			{
				"swap_sound": Callable(),
				"match_groups": Callable(),
				"move_timer_seconds": Callable(),
				"drag_input_result": Callable(),
				"hovered_orb_changed": Callable(),
				"apply_feedback_settings": Callable(recorder, "apply_feedback_settings"),
			},
			{"swap_animation_seconds": 0.12}
		)
	)
	var dependencies: Dictionary = board_controller.bind_args[0]
	var callbacks: Dictionary = board_controller.bind_args[1]
	if dependencies.get("board_view") != "view" or dependencies.get("board_model") != "model":
		return "Expected board dependencies to be forwarded."
	if not callbacks.has("swap_sound_callback") or absf(float(callbacks.get("swap_animation_seconds")) - 0.12) > 0.001:
		return "Expected board callback/config map."
	if recorder.feedback_calls != 1:
		return "Expected feedback settings callback after board bind."
	return ""
