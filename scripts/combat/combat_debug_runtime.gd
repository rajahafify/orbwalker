extends RefCounted
class_name CombatDebugRuntime

const COMBAT_DEBUG_CONSOLE_SCRIPT := preload("res://scripts/combat/combat_debug_console.gd")
const COMBAT_DEBUG_COMMAND_ADAPTER_SCRIPT := preload("res://scripts/combat/combat_debug_command_adapter.gd")

const DEFAULT_VICTORY_SCENE := "res://scenes/main_menu.tscn"

var _view: Variant = null
var _console: CombatDebugConsole = null
var _command_adapter: Variant = null


func bind_for_combat_controller(
	view: Variant, turn_log_presenter: Variant, controller: Object, locked_input_phase_value: int, config: Dictionary = {}, state_callbacks: Dictionary = {}
) -> void:
	var merged_config := config.duplicate()
	merged_config["locked_input_phase_value"] = locked_input_phase_value
	var callbacks: Dictionary = COMBAT_DEBUG_COMMAND_ADAPTER_SCRIPT.controller_callbacks(controller)
	for key in state_callbacks.keys():
		callbacks[key] = state_callbacks[key]
	bind(view, turn_log_presenter, callbacks, merged_config)


func bind(view: Variant, turn_log_presenter: Variant, controller_callbacks: Dictionary, config: Dictionary = {}) -> void:
	_ensure_instances()
	_view = view
	(
		_command_adapter
		. bind(
			{
				"locked_input_phase_value": int(config.get("locked_input_phase_value", 2)),
				"default_victory_scene": String(config.get("default_victory_scene", DEFAULT_VICTORY_SCENE)),
				"callbacks": controller_callbacks,
			}
		)
	)

	var console_nodes: Dictionary = {}
	if _view != null and _view.has_method("debug_console_nodes"):
		var raw_nodes: Variant = _view.debug_console_nodes()
		if raw_nodes is Dictionary:
			console_nodes = raw_nodes

	(
		_console
		. bind(
			console_nodes,
			{
				"command_output_log_color": config.get("command_output_log_color", Color(0.45, 0.95, 0.45, 1.0)),
				"max_combat_log_lines": int(config.get("max_combat_log_lines", 120)),
				"initial_log_level": String(config.get("initial_log_level", CombatDebugConsole.LOG_LEVEL_NORMAL)),
				"turn_log_presenter": turn_log_presenter,
				"callbacks": _command_adapter.command_callbacks(),
			}
		)
	)


func console() -> CombatDebugConsole:
	_ensure_instances()
	return _console


func bootstrap_hidden(submit_callback: Callable = Callable()) -> void:
	_ensure_instances()
	if _view != null:
		if _view.has_method("set_debug_overlay_visible"):
			_view.set_debug_overlay_visible(false)
		if _view.has_method("set_debug_toggle_button_visible"):
			_view.set_debug_toggle_button_visible(false)
		if submit_callback.is_valid() and _view.has_method("connect_debug_console_submit"):
			_view.connect_debug_console_submit(submit_callback)
	else:
		_console.set_overlay_visible(false)


func toggle_overlay() -> void:
	if _view != null and _view.has_method("toggle_debug_overlay"):
		_view.toggle_debug_overlay()


func handle_submitted_text(text: String) -> void:
	_ensure_instances()
	_console.handle_submitted_text(text)


func append_log(message: String, is_command_output: bool = false) -> void:
	_ensure_instances()
	_console.append_log(message, is_command_output)


func clear_log() -> void:
	_ensure_instances()
	_console.clear_log()


func log_level() -> String:
	_ensure_instances()
	return _console.log_level()


func _ensure_instances() -> void:
	if _console == null:
		_console = COMBAT_DEBUG_CONSOLE_SCRIPT.new()
	if _command_adapter == null:
		_command_adapter = COMBAT_DEBUG_COMMAND_ADAPTER_SCRIPT.new()
