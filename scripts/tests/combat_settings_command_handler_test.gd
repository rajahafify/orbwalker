extends RefCounted
class_name CombatSettingsCommandHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_settings_command_handler.gd")


class FakeView:
	extends RefCounted

	var overlay_visible := false
	var shown_settings: Array[Dictionary] = []
	var hide_count := 0

	func show_settings_overlay(settings: Variant) -> void:
		overlay_visible = true
		if settings is Dictionary:
			shown_settings.append((settings as Dictionary).duplicate())
		else:
			shown_settings.append({"vfx_speed": String(settings)})

	func hide_settings_overlay() -> void:
		overlay_visible = false
		hide_count += 1


class FakeModel:
	extends RefCounted

	var speed := ""

	func set_combat_speed(value: String) -> void:
		speed = value

	func combat_speed() -> String:
		return speed


class FakeResolvePresenter:
	extends RefCounted

	var speed := ""

	func set_combat_speed(value: String) -> void:
		speed = value


class CallbackRecorder:
	extends RefCounted

	var phases: Array[int] = []
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []
	var routes: Array[Dictionary] = []
	var vfx_apply_count := 0
	var feedback_apply_count := 0
	var turn_index := 7
	var model: FakeModel

	func set_input_phase(value: int) -> void:
		phases.append(value)

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)

	func current_turn_index() -> int:
		return turn_index

	func trace_and_change_scene(scene_path: String, trace_source: String, trace_mark: String) -> void:
		routes.append({
			"scene_path": scene_path,
			"trace_source": trace_source,
			"trace_mark": trace_mark,
		})

	func combat_speed_value() -> String:
		if model == null:
			return ""
		return model.combat_speed()

	func apply_vfx_speed() -> void:
		vfx_apply_count += 1

	func apply_feedback_settings() -> void:
		feedback_apply_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	var previous_speed := RunState.vfx_speed()
	var previous_quality := RunState.combat_vfx_quality()
	var previous_reduced_motion := RunState.reduced_motion_enabled()
	_run_case("open_shows_overlay_and_locks_input", _test_open_shows_overlay_and_locks_input, failures)
	_run_case("continue_restores_player_input_status", _test_continue_restores_player_input_status, failures)
	_run_case("speed_selection_updates_runtime_dependencies", _test_speed_selection_updates_runtime_dependencies, failures)
	_run_case("quality_and_motion_selection_update_runtime_dependencies", _test_quality_and_motion_selection_update_runtime_dependencies, failures)
	_run_case("route_commands_hide_overlay_and_emit_scene_targets", _test_route_commands_hide_overlay_and_emit_scene_targets, failures)
	RunState.set_vfx_speed(previous_speed)
	RunState.set_combat_vfx_quality(previous_quality)
	RunState.set_reduced_motion_enabled(previous_reduced_motion)
	RunState.reset_run("combat_settings_command_handler_test_restore", false)

	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_open_shows_overlay_and_locks_input() -> String:
	RunState.set_vfx_speed("fast")
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.open()
	if not view.overlay_visible:
		return "Expected opening settings to show the overlay."
	if String(view.shown_settings.back().get("vfx_speed", "")) != "fast":
		return "Expected opening settings to pass the current RunState VFX speed."
	if recorder.phases != [2]:
		return "Expected opening settings to lock external input."
	if recorder.status_texts.back() != "Settings opened.":
		return "Expected opening settings to set status text."
	return ""


func _test_continue_restores_player_input_status() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	view.overlay_visible = true
	handler.continue_combat()
	if view.overlay_visible:
		return "Expected continue to hide the settings overlay."
	if recorder.phases != [0]:
		return "Expected continue to restore player input."
	if recorder.status_texts.is_empty() or recorder.status_texts.back().find("Turn 7") < 0:
		return "Expected continue to restore the combat turn status."
	if recorder.status_colors != [Color(1.0, 1.0, 1.0, 1.0)]:
		return "Expected continue to restore neutral status color."
	return ""


func _test_speed_selection_updates_runtime_dependencies() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var model: FakeModel = fixture["model"]
	var presenter: FakeResolvePresenter = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.select_speed("instant")
	if model.speed != "instant":
		return "Expected speed selection to update the combat model."
	if presenter.speed != "instant":
		return "Expected speed selection to update the resolve presenter."
	if recorder.vfx_apply_count != 1:
		return "Expected speed selection to reapply VFX speed scaling."
	if not view.overlay_visible or String(view.shown_settings.back().get("vfx_speed", "")) != "instant":
		return "Expected speed selection to refresh the overlay selection."
	if recorder.status_texts.back() != "VFX speed: Instant.":
		return "Expected speed selection to report the normalized speed."
	return ""


func _test_quality_and_motion_selection_update_runtime_dependencies() -> String:
	RunState.set_combat_vfx_quality("low")
	RunState.set_reduced_motion_enabled(false)
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.select_quality("high")
	if RunState.combat_vfx_quality() != "high":
		return "Expected quality selection to update RunState."
	if recorder.feedback_apply_count != 1:
		return "Expected quality selection to apply feedback settings."
	if String(view.shown_settings.back().get("combat_vfx_quality", "")) != "high":
		return "Expected quality selection to refresh the overlay state."
	handler.toggle_reduced_motion()
	if not RunState.reduced_motion_enabled():
		return "Expected reduced motion toggle to update RunState."
	if recorder.feedback_apply_count != 2:
		return "Expected reduced motion toggle to apply feedback settings."
	if not bool(view.shown_settings.back().get("reduced_motion", false)):
		return "Expected reduced motion toggle to refresh the overlay state."
	return ""


func _test_route_commands_hide_overlay_and_emit_scene_targets() -> String:
	var new_run_fixture := _fixture()
	var new_run_handler: Variant = new_run_fixture["handler"]
	var new_run_view: FakeView = new_run_fixture["view"]
	var new_run_recorder: CallbackRecorder = new_run_fixture["recorder"]
	new_run_view.overlay_visible = true
	new_run_handler.start_new_run()
	if new_run_view.overlay_visible:
		return "Expected new-run command to hide the settings overlay."
	if new_run_recorder.routes.size() != 1:
		return "Expected new-run command to emit one route change."
	if String(new_run_recorder.routes[0].get("scene_path", "")) != HANDLER_SCRIPT.SCENE_COMBAT:
		return "Expected new-run command to route to combat."
	if String(new_run_recorder.routes[0].get("trace_source", "")) != HANDLER_SCRIPT.TRACE_SOURCE_NEW_RUN:
		return "Expected new-run command to preserve its trace source."

	var main_menu_fixture := _fixture()
	var main_menu_handler: Variant = main_menu_fixture["handler"]
	var main_menu_view: FakeView = main_menu_fixture["view"]
	var main_menu_recorder: CallbackRecorder = main_menu_fixture["recorder"]
	main_menu_view.overlay_visible = true
	main_menu_handler.return_to_main_menu()
	if main_menu_view.overlay_visible:
		return "Expected main-menu command to hide the settings overlay."
	if main_menu_recorder.routes.size() != 1:
		return "Expected main-menu command to emit one route change."
	if String(main_menu_recorder.routes[0].get("scene_path", "")) != HANDLER_SCRIPT.SCENE_MAIN_MENU:
		return "Expected main-menu command to route to main menu."
	if String(main_menu_recorder.routes[0].get("trace_source", "")) != HANDLER_SCRIPT.TRACE_SOURCE_MAIN_MENU:
		return "Expected main-menu command to preserve its trace source."
	return ""


func _fixture() -> Dictionary:
	var view := FakeView.new()
	var model := FakeModel.new()
	var presenter := FakeResolvePresenter.new()
	var recorder := CallbackRecorder.new()
	recorder.model = model
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		view,
		model,
		presenter,
		{
			HANDLER_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(recorder, "set_input_phase"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
			HANDLER_SCRIPT.CALLBACK_CURRENT_TURN_INDEX: Callable(recorder, "current_turn_index"),
			HANDLER_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(recorder, "trace_and_change_scene"),
			HANDLER_SCRIPT.CALLBACK_COMBAT_SPEED_VALUE: Callable(recorder, "combat_speed_value"),
			HANDLER_SCRIPT.CALLBACK_APPLY_VFX_SPEED: Callable(recorder, "apply_vfx_speed"),
			HANDLER_SCRIPT.CALLBACK_APPLY_FEEDBACK_SETTINGS: Callable(recorder, "apply_feedback_settings"),
		},
		{
			"player_input_phase_value": 0,
			"locked_input_phase_value": 2,
			"neutral_status_color": Color(1.0, 1.0, 1.0, 1.0),
		}
	)
	return {
		"handler": handler,
		"view": view,
		"model": model,
		"presenter": presenter,
		"recorder": recorder,
	}
