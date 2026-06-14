extends RefCounted
class_name BoardControllerTest

const BOARD_CONTROLLER_SCRIPT := preload("res://scripts/board/board_controller.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("timer_expiry_returns_handled_end_drag", _test_timer_expiry_returns_handled_end_drag, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_timer_expiry_returns_handled_end_drag() -> String:
	var controller: Variant = BOARD_CONTROLLER_SCRIPT.new()
	var drag_path: Array[Vector2i] = [Vector2i(1, 1), Vector2i(1, 2)]
	controller._active_drag = true
	controller._move_time_left = 0.1
	controller._drag_path = drag_path
	var result: Dictionary = controller.update(0.2, true)
	if not bool(result.get("handled", false)):
		return "Expected timer expiry to be a handled drag end so combat resolve runs."
	if String(result.get("action", "")) != "end":
		return "Expected timer expiry to emit an end action."
	if not bool(result.get("timed_out", false)):
		return "Expected timer expiry to mark the drag result as timed out."
	if Array(result.get("path", [])) != drag_path:
		return "Expected timer expiry to preserve the dragged path."
	return ""
