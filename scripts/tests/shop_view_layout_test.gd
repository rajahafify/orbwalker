extends RefCounted
class_name ShopViewLayoutTest

const SHOP_VIEW_SCRIPT_PATH := "res://scripts/shop/shop_view.gd"
const SHOP_SCENE_SCRIPT_PATH := "res://scripts/scenes/shop.gd"
const EPSILON := 0.001


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("native_tooltips_disabled", _test_native_tooltips_disabled, failures)
	_run_case("shop_header_controls_remain_readable", _test_shop_header_controls_remain_readable, failures)
	_run_case("action_hint_bounds_fit_within_action_row", _test_action_hint_bounds_fit_within_action_row, failures)
	_run_case("merchant_header_uses_single_speech_panel", _test_merchant_header_uses_single_speech_panel, failures)
	_run_case("action_row_connected_to_hud", _test_action_row_connected_to_hud, failures)
	_run_case("stock_cards_fit", _test_stock_cards_fit, failures)
	_run_case("treasure_chest_labels_use_chest_copy", _test_treasure_chest_labels_use_chest_copy, failures)
	_run_case("scene_facade_matches_shop_view_probe", _test_scene_facade_matches_shop_view_probe, failures)

	return {
		"passed": failures.is_empty(),
		"total": 8,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_native_tooltips_disabled() -> String:
	var probe := _probe_snapshot()
	var flags: Dictionary = probe.get("native_tooltips_disabled", {})
	if not flags.get("offer_buttons", false):
		return "Expected native stock offer button tooltips to be disabled."
	if not flags.get("relic_button", false):
		return "Expected native relic button tooltip to be disabled."
	if not flags.get("card_icon_controls", false):
		return "Expected native card icon control tooltips to be disabled."
	return ""


func _test_shop_header_controls_remain_readable() -> String:
	var probe := _probe_snapshot()
	var top_bar: Rect2 = probe.get("top_bar", Rect2())
	var controls: Dictionary = probe.get("top_controls", {})
	var title: Rect2 = controls.get("title", Rect2())
	var gold_counter: Rect2 = controls.get("gold_counter", Rect2())
	var help_button: Rect2 = controls.get("help_button", Rect2())
	var settings_button: Rect2 = controls.get("settings_button", Rect2())
	var modal: Dictionary = probe.get("shop_help_modal", {})
	var modal_rect: Rect2 = modal.get("modal", Rect2())
	var modal_title: Rect2 = modal.get("title", Rect2())
	var modal_body: Rect2 = modal.get("body", Rect2())
	var modal_close: Rect2 = modal.get("close_button", Rect2())
	var top_bar_bounds := Rect2(Vector2.ZERO, top_bar.size)
	var modal_bounds := Rect2(Vector2.ZERO, modal_rect.size)
	if not _rect_contains(top_bar_bounds, title) or not _rect_contains(top_bar_bounds, gold_counter):
		return "Expected shop header title and gold counter to stay inside the top bar."
	if not _rect_contains(top_bar_bounds, help_button) or not _rect_contains(top_bar_bounds, settings_button):
		return "Expected shop header icon controls to stay inside the top bar."
	if title.intersects(gold_counter) or title.intersects(help_button) or title.intersects(settings_button):
		return "Expected shop header title not to overlap gold or icon controls."
	if gold_counter.intersects(help_button) or gold_counter.intersects(settings_button) or help_button.intersects(settings_button):
		return "Expected shop header right controls not to overlap each other."
	if gold_counter.size.y < 48.0:
		return "Expected shop header gold counter to remain at least 48px tall."
	if help_button.size.x < 48.0 or help_button.size.y < 48.0 or settings_button.size.x < 48.0 or settings_button.size.y < 48.0:
		return "Expected shop header icon controls to remain touch-sized."
	if bool(controls.get("menu_visible", true)):
		return "Expected menu button to be hidden from the shop header."
	if not bool(controls.get("settings_visible", false)):
		return "Expected visual-only settings button to stay visible in the shop header."
	if controls.get("help_label", "") != "?":
		return "Expected help button label '?'."
	if not controls.get("help_opens_modal", false):
		return "Expected help button to be marked as opening the shop help modal."
	if modal_rect.size.x < 700.0 or modal_rect.size.y < 380.0:
		return "Expected shop help modal to be large and readable over shop content."
	if not _rect_contains(modal_bounds, modal_title) or not _rect_contains(modal_bounds, modal_body):
		return "Expected shop help modal to contain title and body copy."
	if not _rect_contains(modal_bounds, modal_close):
		return "Expected shop help modal to contain its close target."
	if modal_close.size.x < 50.0 or modal_close.size.y < 50.0:
		return "Expected shop help modal close target to be touch-sized."
	return ""


func _test_action_hint_bounds_fit_within_action_row() -> String:
	var probe := _probe_snapshot()
	var action_row: Rect2 = probe.get("action_row", Rect2())
	var action_hint: Rect2 = probe.get("action_hint_bounds", Rect2())
	if action_row == Rect2() or action_hint == Rect2():
		return "Expected non-empty action row and action hint bounds in probe output."
	var action_row_local_bounds := Rect2(Vector2.ZERO, action_row.size)
	var action_hint_global := Rect2(action_row.position + action_hint.position, action_hint.size)
	if not _rect_contains(action_row_local_bounds, action_hint) and not _rect_contains(action_row, action_hint_global):
		return "Expected action hint bounds to stay within the action row bounds."
	return ""


func _test_merchant_header_uses_single_speech_panel() -> String:
	var probe := _probe_snapshot()
	var merchant_stage: Rect2 = probe.get("merchant_stage", Rect2())
	var stock_panel: Rect2 = probe.get("stock_panel", Rect2())
	var merchant_content: Dictionary = probe.get("merchant_stage_content", {})
	var speech_card: Rect2 = merchant_content.get("speech_card", Rect2())
	var bottom_rail: Rect2 = merchant_content.get("bottom_rail", Rect2())
	var merchant_bounds := Rect2(Vector2.ZERO, merchant_stage.size)
	if not _rect_contains(merchant_bounds, speech_card):
		return "Expected merchant speech card to stay inside the merchant header stage."
	if speech_card.size.x < 320.0 or speech_card.size.y < 140.0:
		return "Expected merchant speech card to remain readable."
	if bool(merchant_content.get("summary_detail_visible", true)):
		return "Expected merchant summary/detail panel not to be part of normal header."
	if bool(merchant_content.get("boss_preview_visible", true)):
		return "Expected boss preview not to be part of normal header."
	if not _rect_contains(merchant_bounds, bottom_rail):
		return "Expected merchant header bottom rail to stay inside merchant stage."
	if merchant_stage.intersects(stock_panel):
		return "Expected merchant header stage not to overlap stock panel."
	return ""


func _test_action_row_connected_to_hud() -> String:
	var probe := _probe_snapshot()
	if probe.get("action_row_overlaps_hud", true):
		return "Expected action row not to overlap the HUD section."
	if not probe.get("action_hud_connected", false):
		return "Expected action row to remain connected to HUD within target gap."
	var bottom_gap_before_hud: int = int(probe.get("bottom_gap_before_hud", 9999))
	var gap_target: int = int(probe.get("action_hud_connected_target_max", 0))
	if bottom_gap_before_hud > gap_target:
		return "Expected action/HUD gap (%d) to stay within target (%d)." % [bottom_gap_before_hud, gap_target]
	return ""


func _test_stock_cards_fit() -> String:
	var probe := _probe_snapshot()
	if not probe.get("stock_fits", false):
		return "Expected stock cards to fit available stock panel width."
	var stock_total_width: float = float(probe.get("stock_total_width", 0.0))
	var stock_content_width: float = float(probe.get("stock_content_width", 0.0))
	if stock_total_width > stock_content_width + EPSILON:
		return "Expected stock total width %.2f to be <= content width %.2f." % [stock_total_width, stock_content_width]
	return ""


func _test_treasure_chest_labels_use_chest_copy() -> String:
	var probe := _probe_snapshot()
	var terminology: Dictionary = probe.get("treasure_chest_terminology", {})
	if String(terminology.get("pending_state_badge", "")) != "CHEST FIRST":
		return "Expected pending stock/relic state badge to say CHEST FIRST."
	if String(terminology.get("pending_price_badge", "")) != "WAIT CHEST":
		return "Expected pending price badge to say WAIT CHEST."
	if String(terminology.get("overlay_title", "")) != "Choose One Treasure Chest Reward":
		return "Expected overlay title to use Treasure Chest wording."
	if String(terminology.get("overlay_hint", "")).findn("treasure_chest") >= 0:
		return "Expected overlay hint not to expose internal treasure_chest copy."
	if String(terminology.get("offer_type_label", "")) != "TREASURE CHEST":
		return "Expected offer type label to say TREASURE CHEST."
	if String(terminology.get("internal_offer_type", "")) != "treasure_chest":
		return "Expected internal shop offer type to be treasure_chest."
	return ""


func _test_scene_facade_matches_shop_view_probe() -> String:
	var view_probe: Dictionary = _shop_view_script().shop_layout_probe_snapshot()
	var facade_probe: Dictionary = _shop_scene_script().shop_layout_probe_snapshot()
	for key in [
		"native_tooltips_disabled",
		"top_controls",
		"shop_help_modal",
		"action_row",
		"action_hint_bounds",
		"merchant_stage_content",
		"action_row_overlaps_hud",
		"action_hud_connected",
		"stock_total_width",
		"stock_content_width",
		"stock_fits",
		"treasure_chest_terminology",
	]:
		if not facade_probe.has(key):
			return "Expected scene facade probe snapshot to include key '%s'." % key
		if facade_probe.get(key) != view_probe.get(key):
			return "Expected scene facade key '%s' to match ShopView snapshot." % key
	return ""


func _probe_snapshot() -> Dictionary:
	return _shop_view_script().shop_layout_probe_snapshot()


func _shop_view_script() -> GDScript:
	return ResourceLoader.load(SHOP_VIEW_SCRIPT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript


func _shop_scene_script() -> GDScript:
	return ResourceLoader.load(SHOP_SCENE_SCRIPT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	if inner.position.x < outer.position.x - EPSILON:
		return false
	if inner.position.y < outer.position.y - EPSILON:
		return false
	if inner.end.x > outer.end.x + EPSILON:
		return false
	if inner.end.y > outer.end.y + EPSILON:
		return false
	return true
