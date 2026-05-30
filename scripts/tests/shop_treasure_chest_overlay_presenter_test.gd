extends RefCounted
class_name ShopTreasureChestOverlayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/shop/shop_treasure_chest_overlay_presenter.gd")


class FakeVisuals:
	extends RefCounted

	func icon_for_key(_key: String) -> Texture2D:
		return ImageTexture.new()


class ContentLookup:
	extends RefCounted

	var requested_ids: Array[String] = []

	func lookup(content_id: String) -> Dictionary:
		requested_ids.append(content_id)
		return {"icon_key": "icon/%s" % content_id}


class SignalRecorder:
	extends RefCounted

	var option_indices: Array[int] = []
	var skip_count := 0

	func option_pressed(index: int) -> void:
		option_indices.append(index)

	func skip_pressed() -> void:
		skip_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("empty_options_hide_overlay_and_skip", _test_empty_options_hide_overlay_and_skip, failures)
	_run_case("pending_options_render_buttons_and_forward_signals", _test_pending_options_render_buttons_and_forward_signals, failures)
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


func _test_empty_options_hide_overlay_and_skip() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.ensure_overlay()
	presenter.render([])
	var result := ""
	if presenter.overlay() == null or presenter.overlay().visible:
		result = "Expected empty treasure options to keep overlay hidden."
	elif presenter.skip_button().visible:
		result = "Expected empty treasure options to hide the skip button."
	root.free()
	return result


func _test_pending_options_render_buttons_and_forward_signals() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: SignalRecorder = fixture["recorder"]
	var lookup: ContentLookup = fixture["lookup"]
	presenter.render([
		{"type": "equipment", "display_name": "Iron Shortsword", "content_id": "iron_shortsword"},
		{"type": "relic", "display_name": "Lucky Coin", "content_id": "lucky_coin"},
	])
	var buttons: Array[Button] = presenter.option_buttons()
	var result := ""
	if not presenter.overlay().visible or not presenter.modal().visible:
		result = "Expected pending treasure options to show the overlay."
	elif buttons.size() != 3:
		result = "Expected three option buttons."
	elif not buttons[0].visible or buttons[0].disabled:
		result = "Expected first populated option button to be active."
	elif not buttons[1].visible or buttons[1].disabled:
		result = "Expected second populated option button to be active."
	elif buttons[2].visible or not buttons[2].disabled:
		result = "Expected missing third option to be hidden and disabled."
	elif lookup.requested_ids != ["iron_shortsword", "lucky_coin"]:
		result = "Expected content lookup to receive rendered content ids."
	else:
		buttons[1].emit_signal("pressed")
		presenter.skip_button().emit_signal("pressed")
		if recorder.option_indices != [1] or recorder.skip_count != 1:
			result = "Expected option and skip signals to forward."
	root.free()
	return result


func _test_layout_and_chrome_match_shop_contract() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.ensure_overlay()
	presenter.apply_chrome()
	presenter.layout(Vector2(1080.0, 1920.0))
	var result := ""
	if not _vector_equal(presenter.overlay().size, Vector2(1080.0, 1920.0)):
		result = "Expected overlay layout to fill the shop logical size."
	elif not _vector_equal(presenter.modal().position, PRESENTER_SCRIPT.MODAL_RECT.position):
		result = "Expected modal position to match the shop layout contract."
	elif not _vector_equal(presenter.modal().size, PRESENTER_SCRIPT.MODAL_RECT.size):
		result = "Expected modal size to match the shop layout contract."
	elif not presenter.modal().has_theme_stylebox_override("panel"):
		result = "Expected modal chrome style override."
	elif not presenter.skip_button().has_theme_stylebox_override("normal"):
		result = "Expected skip button chrome style override."
	root.free()
	return result


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "ShopRoot"
	root.size = Vector2(1080.0, 1920.0)
	var lookup := ContentLookup.new()
	var recorder := SignalRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root, FakeVisuals.new(), Callable(lookup, "lookup"))
	presenter.option_pressed.connect(Callable(recorder, "option_pressed"))
	presenter.skip_pressed.connect(Callable(recorder, "skip_pressed"))
	return {
		"root": root,
		"presenter": presenter,
		"lookup": lookup,
		"recorder": recorder,
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
