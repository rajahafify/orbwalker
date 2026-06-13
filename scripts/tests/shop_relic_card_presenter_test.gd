extends RefCounted
class_name ShopRelicCardPresenterTest

const PRESENTER := preload("res://scripts/shop/shop_relic_card_presenter.gd")


class FakeVisuals:
	extends RefCounted

	var requested_banner_rarities: Array[String] = []
	var requested_icon_keys: Array[String] = []

	func collection_relic_banner_frame(rarity: String) -> Texture2D:
		requested_banner_rarities.append(rarity)
		return ImageTexture.new()

	func collection_price_badge() -> Texture2D:
		return ImageTexture.new()

	func icon_for_key(icon_key: String) -> Texture2D:
		requested_icon_keys.append(icon_key)
		return ImageTexture.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("empty_relic_card_renders_unavailable_copy", _test_empty_relic_card_renders_unavailable_copy, failures)
	_run_case("active_relic_card_renders_banner_icon_copy_and_price", _test_active_relic_card_renders_banner_icon_copy_and_price, failures)
	_run_case("blocked_relic_card_uses_disabled_visual_state", _test_blocked_relic_card_uses_disabled_visual_state, failures)
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


func _test_empty_relic_card_renders_unavailable_copy() -> String:
	var button := Button.new()
	PRESENTER.render(button, FakeVisuals.new(), {}, false)
	var result := ""
	if not button.disabled:
		result = "Expected empty relic card to be disabled."
	elif button.text != "":
		result = "Expected empty relic card to clear native button text."
	elif not (button.get_theme_stylebox("normal") is StyleBoxEmpty):
		result = "Expected empty relic card to use transparent button chrome."
	elif _find_label(button, "DUNGEON RELIC") == null:
		result = "Expected empty relic card title label."
	elif _find_label(button, "Relic offer unavailable.") == null:
		result = "Expected empty relic unavailable copy."
	button.free()
	return result


func _test_active_relic_card_renders_banner_icon_copy_and_price() -> String:
	var button := Button.new()
	var visuals := FakeVisuals.new()
	PRESENTER.render(button, visuals, _relic_offer({"affordable": true}), false)
	var banner_frame := button.find_child("RelicBannerFrame", true, false) as TextureRect
	var icon := button.find_child("RelicIcon", true, false) as TextureRect
	var result := ""
	if button.disabled:
		result = "Expected affordable relic card to be active."
	elif button.mouse_default_cursor_shape != Control.CURSOR_POINTING_HAND:
		result = "Expected active relic card to use the pointing-hand cursor."
	elif banner_frame == null or banner_frame.modulate != Color.WHITE:
		result = "Expected active relic card banner frame without disabled modulation."
	elif icon == null or icon.modulate != Color.WHITE:
		result = "Expected active relic icon without disabled modulation."
	elif _find_label(button, "Ancient Coin") == null:
		result = "Expected active relic name label."
	var tier_label := _find_label(button, "RARE RELIC - DUNGEON 2")
	if result == "" and tier_label == null:
		result = "Expected active relic tier label."
	elif result == "" and tier_label.get_theme_font_size("font_size") < PRESENTER.RELIC_TIER_FONT_SIZE:
		result = "Expected active relic tier label to keep the readable font floor."
	elif result == "" and _find_label(button, "$24") == null:
		result = "Expected active relic compact price label."
	elif result == "" and visuals.requested_banner_rarities != ["rare"]:
		result = "Expected relic banner frame to use the offer rarity."
	elif result == "" and visuals.requested_icon_keys != ["coin"]:
		result = "Expected relic icon lookup to use the offer icon key."
	button.free()
	return result


func _test_blocked_relic_card_uses_disabled_visual_state() -> String:
	var button := Button.new()
	PRESENTER.render(button, FakeVisuals.new(), _relic_offer({"affordable": true}), true)
	var banner_frame := button.find_child("RelicBannerFrame", true, false) as TextureRect
	var icon := button.find_child("RelicIcon", true, false) as TextureRect
	var result := ""
	if not button.disabled:
		result = "Expected treasure-pending relic card to be disabled."
	elif button.mouse_default_cursor_shape != Control.CURSOR_ARROW:
		result = "Expected disabled relic card to use the arrow cursor."
	elif banner_frame == null or banner_frame.modulate != PRESENTER.RELIC_UNAVAILABLE_BANNER_MODULATE:
		result = "Expected disabled relic card to dim the banner frame."
	elif icon == null or icon.modulate != PRESENTER.RELIC_UNAVAILABLE_ICON_MODULATE:
		result = "Expected disabled relic card to dim the relic icon."
	elif _find_label(button, "WAIT CHEST") == null:
		result = "Expected treasure-pending relic card to show WAIT CHEST price text."
	button.free()
	return result


func _relic_offer(overrides: Dictionary = {}) -> Dictionary:
	var offer := {
		"display_name": "Ancient Coin",
		"rarity": "rare",
		"price": 24,
		"affordable": false,
		"sold_out": false,
		"dungeon_level": 2,
		"icon_key": "coin",
		"description": "Gain +1 gold after each combat.",
	}
	offer.merge(overrides, true)
	return offer


func _find_label(node: Node, text: String) -> Label:
	if node is Label and (node as Label).text == text:
		return node as Label
	for child in node.get_children():
		var label := _find_label(child, text)
		if label != null:
			return label
	return null
