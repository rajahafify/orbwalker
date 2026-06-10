extends RefCounted
class_name ShopActionRowPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/shop/shop_action_row_presenter.gd")


class FakeVisuals:
	extends RefCounted

	var requested_frames: Array[String] = []

	func shop_action_button_frame(kind: String) -> Texture2D:
		requested_frames.append(kind)
		return ImageTexture.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("render_sets_shop_action_state", _test_render_sets_shop_action_state, failures)
	_run_case("layout_and_chrome_match_shop_contract", _test_layout_and_chrome_match_shop_contract, failures)
	_run_case("button_presses_emit_presenter_signals", _test_button_presses_emit_presenter_signals, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
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


func _test_render_sets_shop_action_state() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.render({
		"active": true,
		"reroll_enabled": true,
		"reroll_cost": 1,
		"continue_enabled": true,
	}, false)
	var result := ""
	if presenter.reroll_button().disabled:
		result = "Expected enabled shop reroll to stay interactive."
	elif presenter.reroll_button().text != "REROLL ($1)":
		result = "Expected reroll cost to render inline."
	elif presenter.continue_button().disabled:
		result = "Expected enabled continue action to stay interactive."
	elif presenter.continue_button().text != "CONTINUE":
		result = "Expected continue label to use native button text."
	elif presenter.sell_equipment_button().visible:
		result = "Expected permanent sell action to stay hidden."
	elif presenter.action_hint_label().visible:
		result = "Expected sell hint to stay hidden during normal action row rendering."
	else:
		presenter.render({
			"active": false,
			"reroll_enabled": true,
			"reroll_cost": 0,
		}, true)
		if not presenter.reroll_button().disabled:
			result = "Expected treasure-pending reroll to be disabled."
		elif presenter.reroll_button().text != "REROLL (FREE)":
			result = "Expected free reroll copy for zero-cost rerolls."
		elif not presenter.continue_button().disabled:
			result = "Expected default continue state to block while a treasure chest is pending."
	root.free()
	return result


func _test_layout_and_chrome_match_shop_contract() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var visuals: FakeVisuals = fixture["visuals"]
	var action_rect := Rect2(Vector2(16, 1282), Vector2(1048, 134))
	presenter.layout(action_rect)
	presenter.apply_chrome()
	var result := ""
	if presenter.row().position != action_rect.position or presenter.row().size != action_rect.size:
		result = "Expected action row rect to match the supplied layout rect."
	elif presenter.reroll_button().position != PRESENTER_SCRIPT.ACTION_REROLL_RECT.position:
		result = "Expected reroll button to use action-row metrics."
	elif presenter.continue_button().position != PRESENTER_SCRIPT.ACTION_CONTINUE_RECT.position:
		result = "Expected continue button to use action-row metrics."
	elif presenter.sell_equipment_button().position.x > -1000.0:
		result = "Expected hidden sell button to be parked offscreen."
	elif not (presenter.reroll_button().get_theme_stylebox("normal") is StyleBoxTexture):
		result = "Expected reroll action to use texture chrome."
	elif presenter.reroll_button().get_theme_font_size("font_size") != PRESENTER_SCRIPT.ACTION_BUTTON_FONT_SIZE:
		result = "Expected reroll action font size to match layout metrics."
	elif presenter.sell_equipment_button().get_theme_font_size("font_size") != 24:
		result = "Expected hidden sell action to keep compact legacy font size."
	elif visuals.requested_frames != ["reroll", "continue"]:
		result = "Expected action row chrome to request reroll and continue frame assets."
	root.free()
	return result


func _test_button_presses_emit_presenter_signals() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var counters := {
		"reroll": 0,
		"sell": 0,
		"continue": 0,
	}
	presenter.reroll_pressed.connect(func(): counters["reroll"] += 1)
	presenter.sell_pressed.connect(func(): counters["sell"] += 1)
	presenter.continue_pressed.connect(func(): counters["continue"] += 1)
	presenter.reroll_button().emit_signal("pressed")
	presenter.sell_equipment_button().emit_signal("pressed")
	presenter.continue_button().emit_signal("pressed")
	var result := ""
	if counters["reroll"] != 1:
		result = "Expected reroll button press to emit reroll_pressed."
	elif counters["sell"] != 1:
		result = "Expected sell button press to emit sell_pressed."
	elif counters["continue"] != 1:
		result = "Expected continue button press to emit continue_pressed."
	root.free()
	return result


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "ShopRoot"
	var visuals := FakeVisuals.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root, visuals)
	presenter.ensure_row()
	return {
		"root": root,
		"visuals": visuals,
		"presenter": presenter,
	}
