extends RefCounted
class_name CombatSettingsOverlayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")


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
	_run_case("show_creates_overlay_and_updates_speed_selection", _test_show_creates_overlay_and_updates_speed_selection, failures)
	_run_case("hide_clears_overlay_visibility", _test_hide_clears_overlay_visibility, failures)
	_run_case("buttons_emit_bound_callbacks", _test_buttons_emit_bound_callbacks, failures)
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


func _test_show_creates_overlay_and_updates_speed_selection() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("fast")
	if not presenter.is_visible():
		root.free()
		return "Expected show() to make the overlay visible."
	if root.get_node_or_null("CombatSettingsOverlay") == null:
		root.free()
		return "Expected show() to create CombatSettingsOverlay under the bound parent."
	var buttons: Array[Button] = presenter.speed_buttons()
	if buttons.size() != 4:
		root.free()
		return "Expected four speed buttons."
	if buttons[0].text != "SLOW" or buttons[1].text != "NORMAL" or buttons[2].text != "FAST *" or buttons[3].text != "INSTANT":
		root.free()
		return "Expected selected speed text to match the existing star suffix convention."
	presenter.show("instant")
	if buttons[2].text != "FAST" or buttons[3].text != "INSTANT *":
		root.free()
		return "Expected repeated show() calls to refresh the selected speed text."
	root.free()
	return ""


func _test_hide_clears_overlay_visibility() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("normal")
	presenter.hide()
	if presenter.is_visible():
		root.free()
		return "Expected hide() to make the overlay invisible."
	root.free()
	return ""


func _test_buttons_emit_bound_callbacks() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	presenter.show("normal")
	var buttons: Array[Button] = presenter.speed_buttons()
	buttons[0].emit_signal("pressed")
	presenter.continue_button().emit_signal("pressed")
	presenter.new_run_button().emit_signal("pressed")
	presenter.main_menu_button().emit_signal("pressed")
	if recorder.speeds != ["slow"]:
		root.free()
		return "Expected speed button to emit selected speed."
	if recorder.continue_count != 1 or recorder.new_run_count != 1 or recorder.main_menu_count != 1:
		root.free()
		return "Expected menu buttons to emit their bound callbacks."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var recorder := CallbackRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(
		root,
		{
			PRESENTER_SCRIPT.CALLBACK_CONTINUE: Callable(recorder, "continue_pressed"),
			PRESENTER_SCRIPT.CALLBACK_NEW_RUN: Callable(recorder, "new_run_pressed"),
			PRESENTER_SCRIPT.CALLBACK_MAIN_MENU: Callable(recorder, "main_menu_pressed"),
			PRESENTER_SCRIPT.CALLBACK_SPEED_SELECTED: Callable(recorder, "speed_selected"),
		}
	)
	return {
		"root": root,
		"presenter": presenter,
		"recorder": recorder,
	}
