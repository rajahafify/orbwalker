extends RefCounted
class_name CombatInputCommandHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_input_command_handler.gd")


class FakeView:
	extends RefCounted

	var zone_guide_states: Array[bool] = []
	var click_positions: Array[Vector2] = []
	var click_result := false

	func set_zone_guides_enabled(enabled: bool) -> void:
		zone_guide_states.append(enabled)

	func handle_player_hud_global_click(position: Vector2) -> bool:
		click_positions.append(position)
		return click_result


class CallbackRecorder:
	extends RefCounted

	var debug_toggle_count := 0
	var board_create_count := 0
	var board_print_count := 0
	var consumable_use_count := 0
	var handled_count := 0

	func toggle_debug_overlay() -> void:
		debug_toggle_count += 1

	func create_new_board() -> void:
		board_create_count += 1

	func print_board_model() -> void:
		board_print_count += 1

	func try_use_first_consumable() -> void:
		consumable_use_count += 1

	func set_input_handled() -> void:
		handled_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("keyboard_commands_route_to_callbacks", _test_keyboard_commands_route_to_callbacks, failures)
	_run_case("ignored_key_events_do_not_fire_callbacks", _test_ignored_key_events_do_not_fire_callbacks, failures)
	_run_case("mouse_click_marks_input_only_when_hud_handles_it", _test_mouse_click_marks_input_only_when_hud_handles_it, failures)
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


func _test_keyboard_commands_route_to_callbacks() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	var handled_results: Array[bool] = []
	for keycode in [KEY_F1, KEY_F2, KEY_R, KEY_P, KEY_C]:
		handled_results.append(bool(handler.handle_unhandled_input(_key_event(keycode))))
	if handled_results != [true, true, true, true, true]:
		return "Expected every configured debug/input key to be handled."
	if recorder.debug_toggle_count != 1:
		return "Expected F1 to toggle the debug overlay."
	if view.zone_guide_states != [true] or not bool(handler.zone_guides_enabled()):
		return "Expected F2 to toggle zone guides on."
	if recorder.board_create_count != 1:
		return "Expected R to create a new board."
	if recorder.board_print_count != 1:
		return "Expected P to print board debug output."
	if recorder.consumable_use_count != 1:
		return "Expected C to use the first consumable."
	if recorder.handled_count != 5:
		return "Expected handled input to be marked for every configured key."
	return ""


func _test_ignored_key_events_do_not_fire_callbacks() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.handle_unhandled_input(_key_event(KEY_R, false, false))
	handler.handle_unhandled_input(_key_event(KEY_R, true, true))
	handler.handle_unhandled_input(_key_event(KEY_A))
	if recorder.board_create_count != 0:
		return "Expected released, echo, and unknown keys to avoid board creation."
	if recorder.handled_count != 0:
		return "Expected ignored key events to leave input unhandled."
	return ""


func _test_mouse_click_marks_input_only_when_hud_handles_it() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	view.click_result = true
	var first_result := bool(handler.handle_unhandled_input(_mouse_event(Vector2(12.0, 34.0))))
	view.click_result = false
	var second_result := bool(handler.handle_unhandled_input(_mouse_event(Vector2(56.0, 78.0))))
	if not first_result or second_result:
		return "Expected mouse event result to mirror the PlayerHUD click handler."
	if view.click_positions != [Vector2(12.0, 34.0), Vector2(56.0, 78.0)]:
		return "Expected mouse clicks to be delegated to the view with global positions."
	if recorder.handled_count != 1:
		return "Expected only handled HUD clicks to mark the viewport input handled."
	return ""


func _fixture() -> Dictionary:
	var view := FakeView.new()
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	(
		handler
		. bind(
			{"view": view},
			{
				HANDLER_SCRIPT.CALLBACK_TOGGLE_DEBUG_OVERLAY: Callable(recorder, "toggle_debug_overlay"),
				HANDLER_SCRIPT.CALLBACK_CREATE_NEW_BOARD: Callable(recorder, "create_new_board"),
				HANDLER_SCRIPT.CALLBACK_PRINT_BOARD_MODEL: Callable(recorder, "print_board_model"),
				HANDLER_SCRIPT.CALLBACK_TRY_USE_FIRST_CONSUMABLE: Callable(recorder, "try_use_first_consumable"),
				HANDLER_SCRIPT.CALLBACK_SET_INPUT_HANDLED: Callable(recorder, "set_input_handled"),
			}
		)
	)
	return {"handler": handler, "view": view, "recorder": recorder}


func _key_event(keycode: int, pressed: bool = true, echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = pressed
	event.echo = echo
	return event


func _mouse_event(position: Vector2, pressed: bool = true, button_index: int = MOUSE_BUTTON_LEFT) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.pressed = pressed
	event.button_index = button_index
	return event
