extends RefCounted
class_name CombatSettingsOverlayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")


class CallbackRecorder:
	extends RefCounted

	var continue_count := 0
	var new_run_count := 0
	var main_menu_count := 0
	var speeds: Array[String] = []
	var qualities: Array[String] = []
	var reduced_motion_count := 0
	var game_juice_count := 0
	var flag_keys: Array[String] = []
	var reset_count := 0

	func continue_pressed() -> void:
		continue_count += 1

	func new_run_pressed() -> void:
		new_run_count += 1

	func main_menu_pressed() -> void:
		main_menu_count += 1

	func speed_selected(speed: String) -> void:
		speeds.append(speed)

	func quality_selected(quality: String) -> void:
		qualities.append(quality)

	func reduced_motion_toggled() -> void:
		reduced_motion_count += 1

	func game_juice_toggled() -> void:
		game_juice_count += 1

	func game_juice_flag_toggled(flag_key: String) -> void:
		flag_keys.append(flag_key)

	func reset_defaults() -> void:
		reset_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("show_creates_overlay_and_updates_speed_selection", _test_show_creates_overlay_and_updates_speed_selection, failures)
	_run_case("show_updates_quality_and_reduced_motion_selection", _test_show_updates_quality_and_reduced_motion_selection, failures)
	_run_case("show_renders_individual_game_juice_flags", _test_show_renders_individual_game_juice_flags, failures)
	_run_case("show_uses_large_mobile_settings_sheet", _test_show_uses_large_mobile_settings_sheet, failures)
	_run_case("hide_clears_overlay_visibility", _test_hide_clears_overlay_visibility, failures)
	_run_case("buttons_emit_bound_callbacks", _test_buttons_emit_bound_callbacks, failures)
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


func _test_show_updates_quality_and_reduced_motion_selection() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show({"vfx_speed": "normal", "combat_vfx_quality": "high", "reduced_motion": true, "game_juice": true})
	var quality_buttons: Array[Button] = presenter.quality_buttons()
	if quality_buttons.size() != 2:
		root.free()
		return "Expected two quality buttons."
	if quality_buttons[0].text != "LOW" or quality_buttons[1].text != "HIGH *":
		root.free()
		return "Expected selected quality text to match the star suffix convention."
	if presenter.reduced_motion_button().text != "ON" or not presenter.reduced_motion_button().button_pressed:
		root.free()
		return "Expected reduced motion button to show enabled state."
	if presenter.game_juice_button().text != "ON" or not presenter.game_juice_button().button_pressed:
		root.free()
		return "Expected game juice button to show enabled state."
	root.free()
	return ""


func _test_show_renders_individual_game_juice_flags() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var flags := GAME_JUICE_FLAGS_SCRIPT.default_flags()
	flags[GAME_JUICE_FLAGS_SCRIPT.SCREEN_NUDGE] = false
	presenter.show({"vfx_speed": "normal", "combat_vfx_quality": "low", "reduced_motion": false, "game_juice": true, "game_juice_flags": flags})
	var buttons: Dictionary = presenter.game_juice_flag_buttons()
	if buttons.size() != GAME_JUICE_FLAGS_SCRIPT.all_keys().size():
		root.free()
		return "Expected one button for every game juice flag."
	var screen_button := buttons.get(GAME_JUICE_FLAGS_SCRIPT.SCREEN_NUDGE, null) as Button
	if screen_button == null:
		root.free()
		return "Expected screen nudge flag button to exist."
	if screen_button.text != "OFF" or screen_button.button_pressed:
		root.free()
		return "Expected screen nudge flag state to render OFF."
	root.free()
	return ""


func _test_show_uses_large_mobile_settings_sheet() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("normal")
	var panel := root.get_node_or_null("CombatSettingsOverlay/SettingsPanel") as Panel
	if panel == null:
		root.free()
		return "Expected combat settings panel to exist."
	if panel.position.x > 48.0 or panel.position.y > 80.0:
		root.free()
		return "Expected combat settings panel to use small mobile margins."
	if panel.size.x < 1000.0 or panel.size.y < 1700.0:
		root.free()
		return "Expected combat settings panel to fill most of the design viewport."
	if presenter.continue_button().custom_minimum_size.y < 66.0:
		root.free()
		return "Expected combat settings action buttons to be larger touch targets."
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
	presenter.quality_buttons()[1].emit_signal("pressed")
	presenter.reduced_motion_button().emit_signal("pressed")
	presenter.game_juice_button().emit_signal("pressed")
	var flag_buttons: Dictionary = presenter.game_juice_flag_buttons()
	var first_flag := GAME_JUICE_FLAGS_SCRIPT.all_keys()[0]
	(flag_buttons[first_flag] as Button).emit_signal("pressed")
	presenter.reset_defaults_button().emit_signal("pressed")
	presenter.continue_button().emit_signal("pressed")
	presenter.new_run_button().emit_signal("pressed")
	presenter.main_menu_button().emit_signal("pressed")
	if recorder.speeds != ["slow"]:
		root.free()
		return "Expected speed button to emit selected speed."
	if recorder.qualities != ["high"]:
		root.free()
		return "Expected quality button to emit selected quality."
	if recorder.reduced_motion_count != 1:
		root.free()
		return "Expected reduced motion button to emit toggle callback."
	if recorder.game_juice_count != 1:
		root.free()
		return "Expected game juice button to emit toggle callback."
	if recorder.flag_keys != [first_flag]:
		root.free()
		return "Expected game juice flag button to emit its flag key."
	if recorder.reset_count != 1:
		root.free()
		return "Expected reset defaults button to emit reset callback."
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
			PRESENTER_SCRIPT.CALLBACK_QUALITY_SELECTED: Callable(recorder, "quality_selected"),
			PRESENTER_SCRIPT.CALLBACK_REDUCED_MOTION_TOGGLED: Callable(recorder, "reduced_motion_toggled"),
			PRESENTER_SCRIPT.CALLBACK_GAME_JUICE_TOGGLED: Callable(recorder, "game_juice_toggled"),
			PRESENTER_SCRIPT.CALLBACK_GAME_JUICE_FLAG_TOGGLED: Callable(recorder, "game_juice_flag_toggled"),
			PRESENTER_SCRIPT.CALLBACK_RESET_DEFAULTS: Callable(recorder, "reset_defaults"),
		}
	)
	return {
		"root": root,
		"presenter": presenter,
		"recorder": recorder,
	}
