extends RefCounted
class_name ShopHelpModalPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/shop/shop_help_modal_presenter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("show_hide_and_close_button", _test_show_hide_and_close_button, failures)
	_run_case("escape_and_back_consume_when_visible", _test_escape_and_back_consume_when_visible, failures)
	_run_case("layout_and_chrome_match_shop_contract", _test_layout_and_chrome_match_shop_contract, failures)
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


func _test_show_hide_and_close_button() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show()
	var result := ""
	if not presenter.is_visible():
		result = "Expected show() to reveal the help modal overlay."
	elif presenter.title_label().text != "Shop opened. Buy, reroll, sell, or continue.":
		result = "Expected shop help title copy."
	elif presenter.body_label().text.find("Sell filled loadout slots") < 0:
		result = "Expected shop help body copy."
	else:
		presenter.close_button().emit_signal("pressed")
		if presenter.is_visible():
			result = "Expected close button to hide the help modal."
	root.free()
	return result


func _test_escape_and_back_consume_when_visible() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var result := ""
	if presenter.handle_global_input(_key_event(KEY_ESCAPE)):
		result = "Expected hidden help modal not to consume Escape."
	else:
		presenter.show()
		if not presenter.handle_global_input(_key_event(KEY_ESCAPE)):
			result = "Expected visible help modal to consume Escape."
		elif presenter.is_visible():
			result = "Expected Escape to hide the help modal."
		else:
			presenter.show()
			if not presenter.handle_global_input(_key_event(KEY_BACK)):
				result = "Expected visible help modal to consume Back."
	root.free()
	return result


func _test_layout_and_chrome_match_shop_contract() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.ensure_modal()
	presenter.layout(Vector2(1080.0, 1920.0))
	presenter.apply_chrome()
	var result := ""
	if not _vector_equal(presenter.overlay().size, Vector2(1080.0, 1920.0)):
		result = "Expected help overlay layout to fill the shop logical size."
	elif not _vector_equal(presenter.modal().position, PRESENTER_SCRIPT.SHOP_HELP_MODAL_RECT.position):
		result = "Expected help modal position to match layout metrics."
	elif not _vector_equal(presenter.modal().size, PRESENTER_SCRIPT.SHOP_HELP_MODAL_RECT.size):
		result = "Expected help modal size to match layout metrics."
	elif not presenter.modal().has_theme_stylebox_override("panel"):
		result = "Expected help modal panel chrome override."
	elif not presenter.close_button().has_theme_stylebox_override("normal"):
		result = "Expected help close button chrome override."
	elif presenter.close_button().get_theme_font_size("font_size") != 30:
		result = "Expected help close button font size override."
	root.free()
	return result


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "ShopRoot"
	root.size = Vector2(1080.0, 1920.0)
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root)
	return {
		"root": root,
		"presenter": presenter,
	}


func _key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	event.echo = false
	return event


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
