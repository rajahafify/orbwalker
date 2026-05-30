extends RefCounted
class_name CombatSettingsOverlayCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_coordinator.gd")


class CallbackRecorder:
	extends RefCounted

	var continue_count := 0
	var new_run_count := 0
	var main_menu_count := 0
	var speeds: Array[String] = []

	func continue_pressed() -> void:
		continue_count += 1

	func new_run_pressed() -> void:
		new_run_count += 1

	func main_menu_pressed() -> void:
		main_menu_count += 1

	func speed_selected(speed: String) -> void:
		speeds.append(speed)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("show_hide_and_visibility_delegate_to_overlay_presenter", _test_show_hide_and_visibility_delegate_to_overlay_presenter, failures)
	_run_case("settings_callbacks_are_bound_through_coordinator", _test_settings_callbacks_are_bound_through_coordinator, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_show_hide_and_visibility_delegate_to_overlay_presenter() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var coordinator: Variant = fixture["coordinator"]
	coordinator.show("fast")
	if not coordinator.is_visible():
		root.free()
		return "Expected show() to make settings overlay visible."
	if root.get_node_or_null("CombatSettingsOverlay") == null:
		root.free()
		return "Expected coordinator to create the settings overlay."
	var buttons: Array[Button] = coordinator.speed_buttons()
	if buttons.size() != 4 or buttons[2].text != "FAST *":
		root.free()
		return "Expected selected speed button text to update through the presenter."
	coordinator.hide()
	if coordinator.is_visible():
		root.free()
		return "Expected hide() to make settings overlay invisible."
	root.free()
	return ""


func _test_settings_callbacks_are_bound_through_coordinator() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var coordinator: Variant = fixture["coordinator"]
	var recorder: CallbackRecorder = fixture["recorder"]
	coordinator.ensure_overlay()
	coordinator.speed_buttons()[0].emit_signal("pressed")
	coordinator.continue_button().emit_signal("pressed")
	coordinator.new_run_button().emit_signal("pressed")
	coordinator.main_menu_button().emit_signal("pressed")
	if recorder.speeds != ["slow"]:
		root.free()
		return "Expected speed callback to route through coordinator."
	if recorder.continue_count != 1 or recorder.new_run_count != 1 or recorder.main_menu_count != 1:
		root.free()
		return "Expected menu callbacks to route through coordinator."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var recorder := CallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(
		root,
		{
			"continue": Callable(recorder, "continue_pressed"),
			"new_run": Callable(recorder, "new_run_pressed"),
			"main_menu": Callable(recorder, "main_menu_pressed"),
			"speed_selected": Callable(recorder, "speed_selected"),
		}
	)
	return {
		"root": root,
		"coordinator": coordinator,
		"recorder": recorder,
	}
