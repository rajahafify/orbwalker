extends RefCounted
class_name ShopLayoutMetricsTest

const METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW := preload("res://scripts/shop/shop_view.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("base_layout_preserves_shop_sections", _test_base_layout_preserves_shop_sections, failures)
	_run_case("tall_layout_uses_extra_height", _test_tall_layout_uses_extra_height, failures)
	_run_case("player_hud_override_tracks_layout_section", _test_player_hud_override_tracks_layout_section, failures)
	_run_case("probe_snapshot_exports_layout_contract", _test_probe_snapshot_exports_layout_contract, failures)
	_run_case("shop_view_facade_delegates_to_metrics", _test_shop_view_facade_delegates_to_metrics, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_base_layout_preserves_shop_sections() -> String:
	var layout: Dictionary = METRICS.shop_layout_for_logical_height(METRICS.DESIGN_SIZE.y)
	if layout.get("top_bar", Rect2()) != METRICS.TOP_BAR_RECT:
		return "Expected base top bar rect to match the declared shop top bar."
	if layout.get("merchant_stage", Rect2()) != METRICS.MERCHANT_STAGE_RECT:
		return "Expected base merchant stage rect to match the declared shop stage."
	if layout.get("stock_panel", Rect2()) != METRICS.STOCK_PANEL_RECT:
		return "Expected base stock panel rect to match the declared stock panel."
	if layout.get("relic_panel", Rect2()) != METRICS.RELIC_PANEL_RECT:
		return "Expected base relic panel rect to match the declared relic panel."
	if layout.get("action_row", Rect2()) != METRICS.ACTION_ROW_RECT:
		return "Expected base action row rect to match the declared action row."
	if not bool(layout.get("uses_full_height", false)):
		return "Expected shop layout to opt into full-height placement."
	return ""


func _test_tall_layout_uses_extra_height() -> String:
	var layout: Dictionary = METRICS.shop_layout_for_logical_height(2400.0)
	var sample: Dictionary = METRICS.shop_layout_probe_for_layout(layout)
	if float(layout.get("logical_height", 0.0)) != 2400.0:
		return "Expected tall layout to preserve the requested logical height."
	if float(sample.get("merchant_height_delta", 0.0)) <= 0.0:
		return "Expected tall layout to enlarge the merchant stage."
	if float(sample.get("stock_height_delta", 0.0)) <= 0.0:
		return "Expected tall layout to enlarge the stock panel."
	if not bool(sample.get("hud_bottom_aligned", false)):
		return "Expected tall layout HUD to remain bottom aligned."
	if bool(sample.get("action_row_overlaps_hud", true)):
		return "Expected tall layout action row not to overlap the HUD."
	if int(sample.get("action_hud_gap", 9999)) > 16:
		return "Expected tall layout action row to stay visually connected to HUD."
	return ""


func _test_player_hud_override_tracks_layout_section() -> String:
	var layout: Dictionary = METRICS.shop_layout_for_logical_height(2200.0)
	var override: Dictionary = METRICS.shop_player_hud_layout_override_for(layout)
	if Rect2(override.get("section", Rect2())) != Rect2(layout.get("player_hud_section", Rect2())):
		return "Expected player HUD override section to come from the computed shop layout."
	return ""


func _test_probe_snapshot_exports_layout_contract() -> String:
	var probe: Dictionary = METRICS.shop_layout_probe_snapshot()
	for key in [
		"design_size",
		"adaptive_layout_samples",
		"top_controls",
		"action_row_content",
		"offer_card_readability",
		"relic_card_readability",
		"treasure_chest_terminology",
	]:
		if not probe.has(key):
			return "Expected shop layout metrics probe to include key '%s'." % key
	var action_content: Dictionary = probe.get("action_row_content", {})
	if action_content.get("visible_primary_actions", []) != ["reroll", "continue"]:
		return "Expected metrics probe to keep the two primary action contract."
	var offer_readability: Dictionary = probe.get("offer_card_readability", {})
	if not bool(offer_readability.get("uses_collection_card_renderer", false)):
		return "Expected metrics probe to report shared card renderer usage."
	var relic_readability: Dictionary = probe.get("relic_card_readability", {})
	if not bool(relic_readability.get("uses_compact_relic_copy", false)):
		return "Expected metrics probe to report compact relic copy usage."
	return ""


func _test_shop_view_facade_delegates_to_metrics() -> String:
	var metrics_probe: Dictionary = METRICS.shop_layout_probe_snapshot()
	var view_probe: Dictionary = SHOP_VIEW.shop_layout_probe_snapshot()
	for key in [
		"design_size",
		"top_bar",
		"action_row",
		"action_row_content",
		"offer_card_readability",
		"relic_card_readability",
		"treasure_chest_terminology",
	]:
		if view_probe.get(key) != metrics_probe.get(key):
			return "Expected ShopView facade key '%s' to match ShopLayoutMetrics." % key
	return ""
