extends RefCounted
class_name MainMenuAccessibilityTest

const MAIN_MENU_VIEW := preload("res://scripts/main_menu/main_menu_view.gd")
const MAIN_MENU_ACCESSIBILITY_AUDIT := preload("res://tools/quality/main_menu_accessibility_audit.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("main_menu_accessibility_audit_passes", _test_main_menu_accessibility_audit_passes, failures)
	_run_case("main_menu_accessibility_snapshot_has_contracts", _test_main_menu_accessibility_snapshot_has_contracts, failures)
	_run_case("main_menu_scaled_text_keeps_readable_floors", _test_main_menu_scaled_text_keeps_readable_floors, failures)
	_run_case("main_menu_focus_navigation_links_runtime_controls", _test_main_menu_focus_navigation_links_runtime_controls, failures)

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


func _test_main_menu_accessibility_audit_passes() -> String:
	var report: Dictionary = MAIN_MENU_ACCESSIBILITY_AUDIT.run_report()
	if bool(report.get("passed", false)):
		return ""
	return "; ".join(Array(report.get("failures", [])))


func _test_main_menu_accessibility_snapshot_has_contracts() -> String:
	var snapshot: Dictionary = MAIN_MENU_VIEW.accessibility_audit_snapshot()
	if Array(snapshot.get("contrast_pairs", [])).size() < 10:
		return "Expected main-menu accessibility snapshot to cover text and non-text contrast pairs."
	if Array(snapshot.get("touch_targets", [])).size() < 3:
		return "Expected main-menu accessibility snapshot to cover menu, footer, and profile touch targets."
	if Array(snapshot.get("keyboard_focus_controls", [])).size() < 8:
		return "Expected main-menu accessibility snapshot to list keyboard-focusable controls."
	if String(snapshot.get("initial_focus_control", "")) != "start_run_button":
		return "Expected Start Run to receive initial keyboard focus."
	var focus_chain := Array(snapshot.get("main_menu_focus_chain", []))
	if focus_chain.size() < 5:
		return "Expected main-menu focus chain to cover the primary command buttons."
	if String(focus_chain.front()) != "start_run_button":
		return "Expected main-menu focus chain to start at Start Run."
	if not focus_chain.has("tutorial_button") or not focus_chain.has("quit_button"):
		return "Expected main-menu focus chain to include Tutorial and Quit."
	if float(snapshot.get("min_text_contrast_ratio", 0.0)) < 4.5:
		return "Expected text contrast floor to stay at least 4.5."
	return ""


func _test_main_menu_scaled_text_keeps_readable_floors() -> String:
	var probe: Dictionary = MAIN_MENU_VIEW.font_probe_snapshot(Vector2(540.0, 960.0))
	var minimums := {
		"menu": 22,
		"element": 20,
		"stat_title": 20,
		"stat_value": 20,
		"footer": 20,
		"profile_action": 22,
		"version": 20,
		"status": 20,
	}
	for key in minimums.keys():
		if int(probe.get(key, 0)) < int(minimums[key]):
			return "Expected main-menu %s font to stay readable on narrow viewports." % key
	return ""


func _test_main_menu_focus_navigation_links_runtime_controls() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected main-menu focus navigation test to run inside a SceneTree."
	var root := Control.new()
	root.name = "MainMenuFocusNavigationTestRoot"
	tree.root.add_child(root)

	var profile_overlay := Control.new()
	profile_overlay.name = "ProfileOverlay"
	profile_overlay.visible = true
	root.add_child(profile_overlay)

	var start_run_button := _focus_test_button("StartRunButton")
	var continue_button := _focus_test_button("ContinueButton")
	var tutorial_button := _focus_test_button("TutorialButton")
	var settings_button := _focus_test_button("SettingsButton")
	var profile_button := _focus_test_button("ProfileButton")
	var quit_button := _focus_test_button("QuitButton")
	var reset_profile_button := _focus_test_button("ResetProfileButton")
	var close_profile_button := _focus_test_button("CloseProfileButton")
	continue_button.disabled = true
	for button in [
		start_run_button,
		continue_button,
		tutorial_button,
		settings_button,
		profile_button,
		quit_button,
		reset_profile_button,
		close_profile_button,
	]:
		root.add_child(button)

	var view = MAIN_MENU_VIEW.new()
	(
		view
		. bind(
			{
				"start_run_button": start_run_button,
				"continue_button": continue_button,
				"tutorial_button": tutorial_button,
				"settings_button": settings_button,
				"profile_button": profile_button,
				"quit_button": quit_button,
				"profile_overlay": profile_overlay,
				"reset_profile_button": reset_profile_button,
				"close_profile_button": close_profile_button,
			}
		)
	)
	view.configure_focus_navigation()

	var expected_chain: Array[Button] = [
		start_run_button,
		tutorial_button,
		settings_button,
		profile_button,
		quit_button,
	]
	var chain_error := _assert_focus_cycle(expected_chain)
	var overlay_error := ""
	if bool(view.call("_can_grab_main_menu_focus")):
		overlay_error = "Expected visible profile overlay to suppress the initial Start Run focus grab."
	root.free()
	if chain_error != "":
		return chain_error
	return overlay_error


func _focus_test_button(node_name: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = node_name
	button.custom_minimum_size = Vector2(96.0, 48.0)
	return button


func _assert_focus_cycle(expected_chain: Array[Button]) -> String:
	if expected_chain.is_empty():
		return "Expected a non-empty focus chain."
	var current: Button = expected_chain.front() as Button
	for expected_button in expected_chain:
		if current != expected_button:
			return "Expected focus chain to visit %s, got %s." % [String(expected_button.name), String(current.name) if current != null else "<null>"]
		if current.focus_mode != Control.FOCUS_ALL:
			return "Expected %s to accept keyboard focus." % String(current.name)
		var next_path: NodePath = current.focus_next
		if String(next_path) == "":
			return "Expected %s to define focus_next." % String(current.name)
		current = current.get_node_or_null(next_path) as Button
	if current != expected_chain.front():
		return "Expected focus_next chain to wrap from Quit back to Start Run."

	var first_button: Button = expected_chain.front() as Button
	var previous_path: NodePath = first_button.focus_previous
	if String(previous_path) == "":
		return "Expected Start Run to define focus_previous."
	var previous_button := first_button.get_node_or_null(previous_path) as Button
	if previous_button != expected_chain.back():
		return "Expected Start Run focus_previous to wrap to Quit."
	return ""
