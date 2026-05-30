extends RefCounted
class_name CombatTutorialEndCommandHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_command_handler.gd")


class FakeRunState:
	extends RefCounted

	var finish_count := 0
	var sequence_label := "Training 1-2"

	func finish_tutorial_guidance() -> void:
		finish_count += 1

	func level_sequence_label() -> String:
		return sequence_label


class FakeTutorialDirector:
	extends RefCounted

	var advance_results: Array[String] = []
	var dismiss_count := 0

	func advance_post_shop_step() -> String:
		if advance_results.is_empty():
			return ""
		return advance_results.pop_front()

	func dismiss_end_choice() -> void:
		dismiss_count += 1


class FakeView:
	extends RefCounted

	var hide_count := 0

	func hide_tutorial_end_modal() -> void:
		hide_count += 1


class CallbackRecorder:
	extends RefCounted

	var route_id := "route-123"
	var turn_index := 4
	var show_modal_count := 0
	var played_sfx: Array[String] = []
	var status_texts: Array[String] = []
	var status_colors: Array[Color] = []
	var update_hud_count := 0
	var routes: Array[Dictionary] = []

	func current_route_id() -> String:
		return route_id

	func current_turn_index() -> int:
		return turn_index

	func show_shop_damage_modal() -> void:
		show_modal_count += 1

	func play_sfx(key: String) -> void:
		played_sfx.append(key)

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func set_status_color(value: Color) -> void:
		status_colors.append(value)

	func update_hud() -> void:
		update_hud_count += 1

	func trace_and_change_scene(scene_path: String, route_id_value: String, source: String, trace_mark: String) -> void:
		routes.append({
			"scene_path": scene_path,
			"route_id": route_id_value,
			"source": source,
			"trace_mark": trace_mark,
		})


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("continue_advances_post_shop_modal", _test_continue_advances_post_shop_modal, failures)
	_run_case("continue_finishes_tutorial_guidance", _test_continue_finishes_tutorial_guidance, failures)
	_run_case("main_menu_finishes_and_routes", _test_main_menu_finishes_and_routes, failures)

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


func _test_continue_advances_post_shop_modal() -> String:
	var fixture := _fixture(["mastery"])
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]

	handler.continue_pressed()
	if recorder.show_modal_count != 1:
		return "Expected continue to hand off to the shop-damage modal when another post-shop step exists."
	if recorder.played_sfx != ["ui_accept"]:
		return "Expected modal progression to play the accept SFX."
	if run_state.finish_count != 0:
		return "Expected modal progression to leave tutorial guidance active."
	if view.hide_count != 0:
		return "Expected modal progression to keep the modal lifecycle with the coachmark coordinator."
	if recorder.update_hud_count != 0:
		return "Expected modal progression to skip final HUD refresh."
	if not recorder.status_texts.is_empty() or not recorder.status_colors.is_empty():
		return "Expected modal progression not to restore final combat status."
	return ""


func _test_continue_finishes_tutorial_guidance() -> String:
	var fixture := _fixture([""])
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]

	handler.continue_pressed()
	if run_state.finish_count != 1:
		return "Expected final continue to finish tutorial guidance."
	if view.hide_count != 1:
		return "Expected final continue to hide the tutorial end modal."
	if recorder.played_sfx != ["ui_accept"]:
		return "Expected final continue to play the accept SFX."
	if recorder.status_texts != ["Training 1-2 | Turn 4."]:
		return "Expected final continue to restore the combat turn status."
	if recorder.status_colors != [Color(1.0, 1.0, 1.0, 1.0)]:
		return "Expected final continue to restore the neutral status color."
	if recorder.update_hud_count != 1:
		return "Expected final continue to refresh HUD state."
	if recorder.show_modal_count != 0:
		return "Expected final continue not to show another modal step."
	return ""


func _test_main_menu_finishes_and_routes() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var director: FakeTutorialDirector = fixture["director"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]

	handler.main_menu_pressed()
	if director.dismiss_count != 1:
		return "Expected main-menu command to dismiss the tutorial end choice."
	if run_state.finish_count != 1:
		return "Expected main-menu command to finish tutorial guidance."
	if view.hide_count != 1:
		return "Expected main-menu command to hide the tutorial end modal."
	if recorder.played_sfx != ["ui_accept"]:
		return "Expected main-menu command to play the accept SFX."
	if recorder.routes.size() != 1:
		return "Expected main-menu command to emit one scene route."
	var route := recorder.routes[0]
	if String(route.get("scene_path", "")) != HANDLER_SCRIPT.SCENE_MAIN_MENU:
		return "Expected main-menu command to target the main menu scene."
	if String(route.get("route_id", "")) != recorder.route_id:
		return "Expected main-menu command to preserve the current route id."
	if String(route.get("source", "")) != HANDLER_SCRIPT.TRACE_SOURCE_MAIN_MENU:
		return "Expected main-menu command to preserve the trace source."
	if String(route.get("trace_mark", "")) != HANDLER_SCRIPT.TRACE_MARK_MAIN_MENU:
		return "Expected main-menu command to preserve the trace mark."
	return ""


func _fixture(advance_results: Array[String] = []) -> Dictionary:
	var run_state := FakeRunState.new()
	var director := FakeTutorialDirector.new()
	director.advance_results = advance_results.duplicate()
	var view := FakeView.new()
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		{
			"run_state": run_state,
			"tutorial_director": director,
			"view": view,
		},
		{
			HANDLER_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(recorder, "current_route_id"),
			HANDLER_SCRIPT.CALLBACK_CURRENT_TURN_INDEX: Callable(recorder, "current_turn_index"),
			HANDLER_SCRIPT.CALLBACK_SHOW_SHOP_DAMAGE_MODAL: Callable(recorder, "show_shop_damage_modal"),
			HANDLER_SCRIPT.CALLBACK_PLAY_SFX: Callable(recorder, "play_sfx"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(recorder, "set_status_color"),
			HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
			HANDLER_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(recorder, "trace_and_change_scene"),
		},
		{
			"neutral_status_color": Color(1.0, 1.0, 1.0, 1.0),
		}
	)
	return {
		"handler": handler,
		"run_state": run_state,
		"director": director,
		"view": view,
		"recorder": recorder,
	}
