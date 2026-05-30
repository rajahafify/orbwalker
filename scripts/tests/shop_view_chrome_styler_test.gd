extends RefCounted
class_name ShopViewChromeStylerTest

const STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")


class FakeVisuals:
	extends RefCounted

	func shop_action_button_frame(_kind: String) -> Texture2D:
		return ImageTexture.new()

	func collection_price_badge() -> Texture2D:
		return ImageTexture.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("transparent_button_chrome_uses_empty_styleboxes", _test_transparent_button_chrome_uses_empty_styleboxes, failures)
	_run_case("action_button_chrome_uses_texture_styleboxes", _test_action_button_chrome_uses_texture_styleboxes, failures)
	_run_case("standard_button_chrome_sets_disabled_color", _test_standard_button_chrome_sets_disabled_color, failures)
	_run_case("price_badge_builds_frame_and_label", _test_price_badge_builds_frame_and_label, failures)

	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_transparent_button_chrome_uses_empty_styleboxes() -> String:
	var button := Button.new()
	STYLER.apply_transparent_button_chrome(button)
	var result := ""
	if not button.flat:
		result = "Expected transparent button chrome to enable flat mode."
	elif not (button.get_theme_stylebox("normal") is StyleBoxEmpty):
		result = "Expected transparent button normal stylebox to be empty."
	button.free()
	return result


func _test_action_button_chrome_uses_texture_styleboxes() -> String:
	var button := Button.new()
	STYLER.apply_action_button_chrome(button, FakeVisuals.new(), "reroll")
	var normal_style := button.get_theme_stylebox("normal") as StyleBoxTexture
	var result := ""
	if normal_style == null:
		result = "Expected action button normal state to use a texture stylebox."
	elif normal_style.texture_margin_left != STYLER.ACTION_BUTTON_TEXTURE_MARGIN:
		result = "Expected action button texture margins to match shop layout metrics."
	elif normal_style.content_margin_left != STYLER.ACTION_BUTTON_CONTENT_MARGIN:
		result = "Expected action button content margins to match shop layout metrics."
	elif button.get_theme_font_size("font_size") != STYLER.ACTION_BUTTON_FONT_SIZE:
		result = "Expected action button font size override."
	button.free()
	return result


func _test_standard_button_chrome_sets_disabled_color() -> String:
	var button := Button.new()
	STYLER.apply_button_chrome(button, Color.BLACK, Color.WHITE, Color.GRAY)
	var result := ""
	if button.get_theme_color("font_disabled_color") != Color(0.70, 0.72, 0.78, 1.0):
		result = "Expected standard button disabled font color override."
	elif not button.has_theme_stylebox_override("hover"):
		result = "Expected standard button hover stylebox override."
	button.free()
	return result


func _test_price_badge_builds_frame_and_label() -> String:
	var root := Control.new()
	STYLER.make_price_badge(root, FakeVisuals.new(), Rect2(Vector2(10, 20), Vector2(120, 50)), "$9", false)
	var result := ""
	if root.get_child_count() != 2:
		result = "Expected price badge to add a frame texture and label."
	else:
		var frame := root.get_child(0) as TextureRect
		var label := root.get_child(1) as Label
		if frame == null or label == null:
			result = "Expected price badge children to be frame then label."
		elif label.text != "$9":
			result = "Expected price badge label text to match price."
		elif label.get_theme_font_size("font_size") != STYLER.RELIC_PRICE_FONT_SIZE:
			result = "Expected price badge font size to match relic price font."
	root.free()
	return result
