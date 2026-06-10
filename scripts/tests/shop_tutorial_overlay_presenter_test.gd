extends RefCounted
class_name ShopTutorialOverlayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/shop/shop_tutorial_overlay_presenter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("empty_phase_hides_overlay", _test_empty_phase_hides_overlay, failures)
	_run_case("buy_phase_focuses_first_offer_and_sets_message", _test_buy_phase_focuses_first_offer_and_sets_message, failures)
	_run_case("action_phases_focus_their_buttons", _test_action_phases_focus_their_buttons, failures)
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


func _test_empty_phase_hides_overlay() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.render("")
	presenter.layout(Vector2(1080.0, 1920.0))
	var result := ""
	if presenter.overlay() == null:
		result = "Expected render to create the tutorial overlay."
	elif presenter.overlay().visible:
		result = "Expected empty phase to hide the tutorial overlay."
	root.free()
	return result


func _test_buy_phase_focuses_first_offer_and_sets_message() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.render("buy_shortsword")
	presenter.layout(Vector2(1080.0, 1920.0))
	var result := ""
	if not presenter.overlay().visible:
		result = "Expected buy tutorial phase to show the overlay."
	elif presenter.prompt_label().text != PRESENTER_SCRIPT.message_for_phase("buy_shortsword"):
		result = "Expected buy tutorial prompt text."
	elif not _vector_equal(presenter.focus_frame().position, Vector2(90.0, 190.0)):
		result = "Expected focus frame to grow around first offer card."
	elif not _vector_equal(presenter.focus_frame().size, Vector2(340.0, 470.0)):
		result = "Expected focus frame size to grow around first offer card."
	elif not _vector_equal(presenter.prompt_panel().size, PRESENTER_SCRIPT.PROMPT_SIZE):
		result = "Expected prompt panel to use the shop tutorial prompt size."
	root.free()
	return result


func _test_action_phases_focus_their_buttons() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.render("reroll")
	presenter.layout(Vector2(1080.0, 1920.0))
	var result := ""
	if presenter.prompt_label().text != PRESENTER_SCRIPT.message_for_phase("reroll"):
		result = "Expected reroll tutorial prompt text."
	elif not _vector_equal(presenter.focus_frame().position, Vector2(110.0, 1390.0)):
		result = "Expected reroll phase to focus the reroll button."
	elif not _vector_equal(presenter.focus_frame().size, Vector2(300.0, 120.0)):
		result = "Expected reroll focus to grow around the reroll button."
	else:
		presenter.render("continue")
		presenter.layout(Vector2(1080.0, 1920.0))
		if presenter.prompt_label().text != PRESENTER_SCRIPT.message_for_phase("continue"):
			result = "Expected continue tutorial prompt text."
		elif not _vector_equal(presenter.focus_frame().position, Vector2(670.0, 1390.0)):
			result = "Expected continue phase to focus the continue button."
	root.free()
	return result


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "TutorialRoot"
	root.size = Vector2(1080.0, 1920.0)
	var first_offer := Button.new()
	first_offer.name = "OfferCard1"
	first_offer.position = Vector2(100.0, 200.0)
	first_offer.size = Vector2(320.0, 450.0)
	root.add_child(first_offer)
	var reroll_button := Button.new()
	reroll_button.name = "RerollButton"
	reroll_button.position = Vector2(120.0, 1400.0)
	reroll_button.size = Vector2(280.0, 100.0)
	root.add_child(reroll_button)
	var continue_button := Button.new()
	continue_button.name = "ContinueButton"
	continue_button.position = Vector2(680.0, 1400.0)
	continue_button.size = Vector2(280.0, 100.0)
	root.add_child(continue_button)
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root, {
		"offer_cards": [first_offer],
		"reroll_button": reroll_button,
		"continue_button": continue_button,
	})
	return {
		"root": root,
		"presenter": presenter,
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
