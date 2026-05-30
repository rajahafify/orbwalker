extends RefCounted
class_name CombatDebugRuntimeTest

const RUNTIME_SCRIPT := preload("res://scripts/combat/combat_debug_runtime.gd")


class FakeView:
	extends RefCounted

	var overlay_visible := true
	var debug_toggle_visible := true
	var toggle_count := 0
	var connect_count := 0
	var connected_callback := Callable()
	var debug_nodes_requested := 0

	func debug_console_nodes() -> Dictionary:
		debug_nodes_requested += 1
		return {}

	func set_debug_overlay_visible(visible: bool) -> void:
		overlay_visible = visible

	func set_debug_toggle_button_visible(visible: bool) -> void:
		debug_toggle_visible = visible

	func connect_debug_console_submit(on_submitted: Callable) -> void:
		connect_count += 1
		connected_callback = on_submitted

	func toggle_debug_overlay() -> bool:
		toggle_count += 1
		overlay_visible = not overlay_visible
		return overlay_visible


class FakeController:
	extends RefCounted

	var status_texts: Array[String] = []
	var submitted_texts: Array[String] = []

	func _console_set_status_text(message: String) -> void:
		status_texts.append(message)

	func submit_callback(text: String) -> void:
		submitted_texts.append(text)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("bind_and_bootstrap_wires_view", _test_bind_and_bootstrap_wires_view, failures)
	_run_case("clear_command_routes_status_through_adapter", _test_clear_command_routes_status_through_adapter, failures)
	_run_case("toggle_and_log_level_delegate_to_console", _test_toggle_and_log_level_delegate_to_console, failures)
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


func _test_bind_and_bootstrap_wires_view() -> String:
	var fixture := _fixture()
	var runtime: Variant = fixture["runtime"]
	var view: FakeView = fixture["view"]
	var controller: FakeController = fixture["controller"]
	runtime.bootstrap_hidden(Callable(controller, "submit_callback"))
	if view.debug_nodes_requested != 1:
		return "Expected runtime bind to request debug console nodes once."
	if view.overlay_visible:
		return "Expected bootstrap to hide the debug overlay."
	if view.debug_toggle_visible:
		return "Expected bootstrap to hide the debug toggle button."
	if view.connect_count != 1 or not view.connected_callback.is_valid():
		return "Expected bootstrap to connect the console submit callback."
	return ""


func _test_clear_command_routes_status_through_adapter() -> String:
	var fixture := _fixture()
	var runtime: Variant = fixture["runtime"]
	var controller: FakeController = fixture["controller"]
	runtime.handle_submitted_text("/clear")
	if controller.status_texts != ["Console cleared."]:
		return "Expected /clear to route status text through the debug command adapter."
	return ""


func _test_toggle_and_log_level_delegate_to_console() -> String:
	var fixture := _fixture()
	var runtime: Variant = fixture["runtime"]
	var view: FakeView = fixture["view"]
	runtime.toggle_overlay()
	if view.toggle_count != 1:
		return "Expected runtime toggle to delegate to the view."
	runtime.handle_submitted_text("/log_level detailed")
	if runtime.log_level() != "detailed":
		return "Expected runtime log_level to reflect the console setting."
	return ""


func _fixture() -> Dictionary:
	var view := FakeView.new()
	var controller := FakeController.new()
	var runtime: Variant = RUNTIME_SCRIPT.new()
	runtime.bind_for_combat_controller(
		view,
		null,
		controller,
		2,
		{
			"max_combat_log_lines": 10,
			"initial_log_level": "normal",
		}
	)
	return {
		"runtime": runtime,
		"view": view,
		"controller": controller,
	}
