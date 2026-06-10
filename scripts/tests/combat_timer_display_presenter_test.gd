extends RefCounted
class_name CombatTimerDisplayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_timer_display_presenter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("ready_snapshot_hides_fill", _test_ready_snapshot_hides_fill, failures)
	_run_case("locked_snapshot_dims_text", _test_locked_snapshot_dims_text, failures)
	_run_case("warning_snapshot_uses_decimal_time_and_warning_color", _test_warning_snapshot_uses_decimal_time_and_warning_color, failures)
	_run_case("critical_snapshot_uses_deterministic_blink", _test_critical_snapshot_uses_deterministic_blink, failures)
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


func _test_ready_snapshot_hides_fill() -> String:
	var snapshot: Dictionary = PRESENTER_SCRIPT.display_snapshot(5.0, "ready", Vector2(720.0, 36.0), 0)
	if String(snapshot.get("label_text", "")) != "READY":
		return "Expected ready label text."
	if String(snapshot.get("state_text", "")) != "READY":
		return "Expected ready state text."
	if bool(snapshot.get("fill_visible", true)):
		return "Expected ready timer to hide fill."
	if not _color_equal(snapshot.get("text_color", Color.TRANSPARENT), PRESENTER_SCRIPT.TIMER_TEXT_COLOR):
		return "Expected ready text color."
	return ""


func _test_locked_snapshot_dims_text() -> String:
	var snapshot: Dictionary = PRESENTER_SCRIPT.display_snapshot(0.0, "locked", Vector2(720.0, 36.0), 0)
	if String(snapshot.get("label_text", "")) != "LOCK":
		return "Expected locked label text."
	if String(snapshot.get("state_text", "not-empty")) != "":
		return "Expected locked state text to be empty."
	if bool(snapshot.get("fill_visible", true)):
		return "Expected locked timer to hide fill."
	var text_color: Color = snapshot.get("text_color", Color.TRANSPARENT)
	if not is_equal_approx(text_color.a, 0.72):
		return "Expected locked text alpha to be dimmed."
	return ""


func _test_warning_snapshot_uses_decimal_time_and_warning_color() -> String:
	var snapshot: Dictionary = PRESENTER_SCRIPT.display_snapshot(1.5, "active", Vector2(720.0, 36.0), 0)
	if String(snapshot.get("label_text", "")) != "1.5 SEC":
		return "Expected warning timer to use decimal seconds."
	if String(snapshot.get("state_text", "")) != "WARN":
		return "Expected warning state text."
	if not bool(snapshot.get("fill_visible", false)):
		return "Expected active timer to show fill."
	var expected_width := (720.0 - PRESENTER_SCRIPT.TIMER_TRACK_PADDING * 2.0) * (1.5 / PRESENTER_SCRIPT.MOVE_TIMER_MAX_SECONDS)
	var fill_size: Vector2 = snapshot.get("fill_size", Vector2.ZERO)
	if not is_equal_approx(fill_size.x, expected_width):
		return "Expected warning fill width %.2f, got %.2f." % [expected_width, fill_size.x]
	if not _color_equal(snapshot.get("text_color", Color.TRANSPARENT), PRESENTER_SCRIPT.TIMER_TEXT_WARNING_COLOR):
		return "Expected warning text color."
	return ""


func _test_critical_snapshot_uses_deterministic_blink() -> String:
	var snapshot: Dictionary = PRESENTER_SCRIPT.display_snapshot(0.5, "active", Vector2(720.0, 36.0), 0)
	if String(snapshot.get("state_text", "")) != "CRIT":
		return "Expected critical state text."
	var text_color: Color = snapshot.get("text_color", Color.TRANSPARENT)
	if not is_equal_approx(text_color.a, 0.70):
		return "Expected critical text alpha to use deterministic blink value at tick 0."
	var fill_color: Color = snapshot.get("fill_color", Color.TRANSPARENT)
	var expected_color: Color = PRESENTER_SCRIPT.TIMER_CRITICAL_COLOR.lerp(Color.WHITE, 0.70)
	if not _color_equal(Color(fill_color.r, fill_color.g, fill_color.b, 1.0), expected_color):
		return "Expected critical fill color to lerp toward white by blink value."
	return ""


func _color_equal(left: Color, right: Color) -> bool:
	return (
		is_equal_approx(left.r, right.r)
		and is_equal_approx(left.g, right.g)
		and is_equal_approx(left.b, right.b)
		and is_equal_approx(left.a, right.a)
	)
