extends RefCounted
class_name CombatControllerSetupBinder


func bind_debug_console(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> Variant:
	var debug_runtime: Variant = dependencies.get("debug_runtime")
	if debug_runtime == null:
		var runtime_script: Variant = dependencies.get("debug_runtime_script")
		debug_runtime = runtime_script.new() if runtime_script != null else null
	if debug_runtime == null:
		return null
	_call(callbacks.get("bind_debug_state_provider"))
	(
		debug_runtime
		. bind_for_combat_controller(
			dependencies.get("view"),
			dependencies.get("turn_log_presenter"),
			dependencies.get("action_callbacks", {}),
			int(config.get("locked_external_phase_value", 0)),
			{
				"command_output_log_color": config.get("command_output_log_color", Color.WHITE),
				"max_combat_log_lines": int(config.get("max_combat_log_lines", 0)),
				"initial_log_level": String(config.get("initial_log_level", "")),
			},
			dependencies.get("debug_state_callbacks", {})
		)
	)
	return {"debug_runtime": debug_runtime, "debug_console": debug_runtime.console()}


func bind_settings_command_handler(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> Variant:
	var settings_command_handler: Variant = dependencies.get("settings_command_handler")
	if settings_command_handler == null:
		var handler_script: Variant = dependencies.get("settings_command_handler_script")
		settings_command_handler = handler_script.new() if handler_script != null else null
	if settings_command_handler == null:
		return null
	settings_command_handler.bind_for_combat_controller(
		dependencies.get("view"),
		dependencies.get("model"),
		dependencies.get("resolve_presenter"),
		dependencies.get("settings_owner"),
		callbacks.get("current_turn_index_provider", Callable()),
		callbacks.get("trace_and_change_scene", Callable()),
		int(config.get("player_input_phase_value", 0)),
		int(config.get("locked_external_phase_value", 0)),
		config.get("status_color_neutral", Color.WHITE)
	)
	return settings_command_handler


func bind_board_controller(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> void:
	var board_controller: Variant = dependencies.get("board_controller")
	if board_controller == null:
		return
	(
		board_controller
		. bind(
			{
				"board_view": dependencies.get("board_view"),
				"board_model": dependencies.get("board_model"),
			},
			{
				"swap_animation_seconds": float(config.get("swap_animation_seconds", 0.0)),
				"swap_sound_callback": callbacks.get("swap_sound", Callable()),
				"match_groups_callback": callbacks.get("match_groups", Callable()),
				"move_timer_seconds_callback": callbacks.get("move_timer_seconds", Callable()),
				"drag_input_result_callback": callbacks.get("drag_input_result", Callable()),
				"hovered_orb_changed_callback": callbacks.get("hovered_orb_changed", Callable()),
			}
		)
	)
	_call(callbacks.get("apply_feedback_settings"))


func _call(callback: Variant) -> Variant:
	if not (callback is Callable):
		return null
	if not callback.is_valid():
		return null
	return callback.call()
