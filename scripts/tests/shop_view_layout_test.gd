extends RefCounted
class_name ShopViewLayoutTest

const SHOP_VIEW_SCRIPT_PATH := "res://scripts/shop/shop_view.gd"
const SHOP_SCENE_SCRIPT_PATH := "res://scripts/scenes/shop.gd"
const EPSILON := 0.001


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("native_tooltips_disabled", _test_native_tooltips_disabled, failures)
	_run_case("top_controls_use_compact_help_settings_labels", _test_top_controls_use_compact_help_settings_labels, failures)
	_run_case("action_hint_bounds_fit_within_action_row", _test_action_hint_bounds_fit_within_action_row, failures)
	_run_case("merchant_backdrop_covers_summary_and_detail", _test_merchant_backdrop_covers_summary_and_detail, failures)
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


func _test_top_controls_use_compact_help_settings_labels() -> String:
	var probe := _probe_snapshot()
	var controls: Dictionary = probe.get("top_controls", {})
	if controls.get("menu_label", "") != "Menu":
		return "Expected menu button label to remain text 'Menu'."
	if controls.get("help_label", "") != "?":
		return "Expected help button compact label '?'."
	if controls.get("settings_label", "") != "S":
		return "Expected settings button compact label 'S'."
	if not controls.get("help_settings_visual_only", false):
		return "Expected help/settings controls to be marked visual-only compact labels."
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


func _test_merchant_backdrop_covers_summary_and_detail() -> String:
	var probe := _probe_snapshot()
	var merchant_content: Dictionary = probe.get("merchant_stage_content", {})
	var backdrop: Rect2 = merchant_content.get("summary_detail_backdrop", Rect2())
	var summary_label: Rect2 = merchant_content.get("summary_label", Rect2())
	var detail_label: Rect2 = merchant_content.get("detail_label", Rect2())
	if backdrop == Rect2() or summary_label == Rect2() or detail_label == Rect2():
		return "Expected merchant backdrop and summary/detail label bounds in probe output."
	if not _rect_contains(backdrop, summary_label):
		return "Expected merchant summary/detail backdrop to cover summary label bounds."
	if not _rect_contains(backdrop, detail_label):
		return "Expected merchant summary/detail backdrop to cover detail label bounds."
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
