extends RefCounted
class_name ShopViewLayoutTest

const SHOP_VIEW_SCRIPT_PATH := "res://scripts/shop/shop_view.gd"
const SHOP_SCENE_SCRIPT_PATH := "res://scripts/scenes/shop.gd"
const COLLECTION_CARD_RENDERER := preload("res://scripts/ui/collection_card_renderer.gd")
const EPSILON := 0.001


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("native_tooltips_disabled", _test_native_tooltips_disabled, failures)
	_run_case("shop_header_controls_remain_readable", _test_shop_header_controls_remain_readable, failures)
	_run_case("shop_action_row_uses_two_primary_actions", _test_shop_action_row_uses_two_primary_actions, failures)
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


func _test_shop_action_row_uses_two_primary_actions() -> String:
	var probe := _probe_snapshot()
	var action_row: Rect2 = probe.get("action_row", Rect2())
	var content: Dictionary = probe.get("action_row_content", {})
	var reroll_button: Rect2 = content.get("reroll_button", Rect2())
	var continue_button: Rect2 = content.get("continue_button", Rect2())
	if action_row == Rect2() or reroll_button == Rect2() or continue_button == Rect2():
		return "Expected non-empty action row and two primary action button bounds."
	var action_row_local_bounds := Rect2(Vector2.ZERO, action_row.size)
	if not _rect_contains(action_row_local_bounds, reroll_button) or not _rect_contains(action_row_local_bounds, continue_button):
		return "Expected reroll and continue buttons to stay within the action row bounds."
	if reroll_button.intersects(continue_button):
		return "Expected reroll and continue buttons not to overlap."
	if reroll_button.size.y < 96.0 or continue_button.size.y < 96.0:
		return "Expected shop action buttons to be large readable targets."
	if Array(content.get("visible_primary_actions", [])) != ["reroll", "continue"]:
		return "Expected only reroll and continue as visible primary shop actions."
	if bool(content.get("sell_button_visible", true)):
		return "Expected permanent sell button to be hidden from the normal action row."
	if bool(content.get("action_hint_visible", true)):
		return "Expected sell-tip action hint to be hidden from the normal action row."
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
	var stock_panel: Rect2 = probe.get("stock_panel", Rect2())
	var offer_grid: Rect2 = probe.get("offer_grid", Rect2())
	if not _rect_contains(Rect2(Vector2.ZERO, stock_panel.size), offer_grid):
		return "Expected offer grid to stay inside the stock panel."
	var side_margins: Vector2 = probe.get("stock_grid_side_margins", Vector2.ZERO)
	if not is_equal_approx(side_margins.x, side_margins.y):
		return "Expected stock card row to have equal left and right margins."
	if side_margins.x < 12.0:
		return "Expected stock card row side margins to be large enough to avoid edge hover slabs."
	var offer_readability: Dictionary = probe.get("offer_card_readability", {})
	var card_size: Vector2 = offer_readability.get("card_size", Vector2.ZERO)
	var frame_rect: Rect2 = offer_readability.get("frame_rect", Rect2())
	var surface_rect: Rect2 = offer_readability.get("surface_rect", Rect2())
	var art_rect: Rect2 = offer_readability.get("art_rect", Rect2())
	var icon_rect: Rect2 = offer_readability.get("icon_rect", Rect2())
	var price_rect: Rect2 = offer_readability.get("price_rect", Rect2())
	var state_rect: Rect2 = offer_readability.get("state_rect", Rect2())
	var name_prefix_rect: Rect2 = offer_readability.get("name_prefix_rect", Rect2())
	var name_item_rect: Rect2 = offer_readability.get("name_item_rect", Rect2())
	var description_rect: Rect2 = offer_readability.get("description_rect", Rect2())
	var card_bounds := Rect2(Vector2.ZERO, card_size)
	if not bool(offer_readability.get("uses_collection_card_renderer", false)):
		return "Expected stock offers to be rendered by the shared collection card renderer."
	if not bool(offer_readability.get("uses_collection_card_frame", false)):
		return "Expected stock offers to use the shared collection card frame asset."
	if not bool(offer_readability.get("uses_collection_price_badge", false)):
		return "Expected stock offers to use the shared collection price badge asset."
	if not bool(offer_readability.get("uses_compact_shop_copy", false)):
		return "Expected shop offer cards to use compact effect copy instead of sentence descriptions."
	if bool(offer_readability.get("renders_rarity_tag", true)):
		return "Expected stock offers not to render rarity tag labels."
	if bool(offer_readability.get("button_hover_fill_visible", true)):
		return "Expected shared card hover to avoid a rectangular fill behind ornate card edges."
	if not bool(offer_readability.get("active_badge_pops", false)):
		return "Expected affordable stock offer badges to pop visually."
	if bool(offer_readability.get("active_badge_uses_external_shadow", true)):
		return "Expected affordable stock offer badges not to use an external glow or shadow."
	if bool(offer_readability.get("active_badge_rect_glow_visible", true)):
		return "Expected affordable stock offer badges not to use a rectangular glow panel."
	if bool(offer_readability.get("copy_uses_ellipsis", true)):
		return "Expected stock offer copy to wrap rather than trim with ellipsis."
	if String(offer_readability.get("price_text_when_affordable", "")) != "$9":
		return "Expected affordable stock offer price notation to be '$9'."
	if String(offer_readability.get("price_text_when_unaffordable", "")) != "$11":
		return "Expected unaffordable stock offer price notation to remain '$11'."
	if card_size != COLLECTION_CARD_RENDERER.CARD_SIZE:
		return "Expected stock offer card size to match collection card size."
	if surface_rect != COLLECTION_CARD_RENDERER.CARD_SURFACE_RECT:
		return "Expected stock offer surface rect to match collection card surface."
	if name_prefix_rect != COLLECTION_CARD_RENDERER.CARD_TITLE_PREFIX_RECT or name_item_rect != COLLECTION_CARD_RENDERER.CARD_TITLE_NAME_RECT:
		return "Expected stock offer title rects to match collection card title rects."
	if art_rect != COLLECTION_CARD_RENDERER.CARD_ART_RECT:
		return "Expected stock offer art rect to match collection card art rect."
	if description_rect != COLLECTION_CARD_RENDERER.CARD_COPY_RECT:
		return "Expected stock offer copy rect to match collection card copy rect."
	if price_rect != COLLECTION_CARD_RENDERER.CARD_BADGE_RECT:
		return "Expected stock offer badge rect to match collection card badge rect."
	if not _rect_contains(card_bounds, frame_rect) or not _rect_contains(card_bounds, surface_rect):
		return "Expected offer frame and surface regions to stay inside stock card bounds."
	if not _rect_contains(card_bounds, art_rect) or not _rect_contains(card_bounds, price_rect):
		return "Expected offer art and price regions to stay inside stock card bounds."
	if not _rect_contains(art_rect, Rect2(art_rect.position + icon_rect.position, icon_rect.size)):
		return "Expected offer item icon to stay inside the art region."
	if name_prefix_rect.intersects(art_rect) or name_item_rect.intersects(art_rect) or description_rect.intersects(price_rect):
		return "Expected offer title, art, copy, and price regions not to overlap."
	if bool(offer_readability.get("state_badge_visible", true)) or state_rect.position.x > -1000.0:
		return "Expected shop offer state to use the shared bottom badge instead of an extra in-card state badge."
	if int(offer_readability.get("copy_max_chars", 99)) > 24:
		return "Expected stock offer copy to pre-wrap before it can overflow horizontally."
	var shop_view = _shop_view_script().new()
	if shop_view._price_text(9, false, true, false) != "$9":
		return "Expected affordable price text to use compact dollar notation."
	if shop_view._price_text(11, false, false, false) != "$11":
		return "Expected unaffordable price text to keep compact dollar notation."
	var compact_attack: String = shop_view._shop_card_description({
		"type": "equipment",
		"content_id": "shortsword",
		"display_name": "Iron Shortsword",
		"description": "Deal +2 flat elemental damage each turn.",
	})
	if compact_attack != "+2 Attack":
		return "Expected shop equipment copy to compact to '+2 Attack'."
	var compact_mastery: String = shop_view._shop_card_description({
		"type": "mastery_card",
		"content_id": "fire_mastery",
		"display_name": "Fire Mastery",
		"description": "Increase Fire mastery by 1 (max 5).",
	})
	if compact_mastery != "+1 Fire\nMastery":
		return "Expected shop mastery copy to compact to a short two-line mastery label."
	var compact_chest: String = shop_view._shop_card_description({
		"type": "treasure_chest",
		"content_id": "fire_chest",
		"display_name": "Fire Chest",
		"description": "Choose 1 of 3 Fire-aligned treasures.",
	})
	if compact_chest != "Choose 1 of 3\nFire rewards":
		return "Expected shop treasure chest copy to compact to short choose/fire rewards copy."
	var relic_readability: Dictionary = probe.get("relic_card_readability", {})
	var relic_panel_size: Vector2 = relic_readability.get("panel_size", Vector2.ZERO)
	var relic_bounds := Rect2(Vector2.ZERO, relic_panel_size)
	var relic_title: Rect2 = relic_readability.get("title_strip_rect", Rect2())
	var relic_banner: Rect2 = relic_readability.get("banner_rect", Rect2())
	var relic_art: Rect2 = relic_readability.get("art_rect", Rect2())
	var relic_icon: Rect2 = relic_readability.get("icon_rect", Rect2())
	var relic_name: Rect2 = relic_readability.get("name_rect", Rect2())
	var relic_tier: Rect2 = relic_readability.get("tier_rect", Rect2())
	var relic_description: Rect2 = relic_readability.get("description_rect", Rect2())
	var relic_price: Rect2 = relic_readability.get("price_rect", Rect2())
	var relic_price_divider: Rect2 = relic_readability.get("price_divider_rect", Rect2())
	if not _rect_contains(relic_bounds, relic_title) or not _rect_contains(relic_bounds, relic_banner):
		return "Expected relic title strip and banner to stay inside relic panel."
	if not is_equal_approx(relic_title.end.y, relic_banner.position.y):
		return "Expected relic title strip to sit directly above the relic banner."
	if not bool(relic_readability.get("uses_collection_relic_banner_frame", false)):
		return "Expected relic banner to use the asset-backed collection relic frame."
	if not bool(relic_readability.get("uses_collection_price_badge", false)):
		return "Expected relic banner to use the shared price badge asset."
	if not bool(relic_readability.get("uses_compact_relic_copy", false)):
		return "Expected relic banner to use compact readable relic copy."
	if bool(relic_readability.get("native_button_chrome_visible", true)):
		return "Expected relic banner button to have no native hover/focus chrome."
	if bool(relic_readability.get("state_badge_visible", true)):
		return "Expected relic banner not to show a separate prototype state badge."
	if String(relic_readability.get("price_text_when_unaffordable", "")) != "$24":
		return "Expected unaffordable relic price to remain a compact price, not NEED text."
	var content_top_inset := float(relic_readability.get("content_top_inset", 0.0))
	if relic_name.position.y < relic_banner.position.y + content_top_inset:
		return "Expected relic name to stay below the simple banner top rail."
	if relic_art.position.y < relic_banner.position.y + content_top_inset:
		return "Expected relic art to stay below the simple banner top rail."
	if relic_art.size.x < 180.0 or relic_art.size.y < 110.0:
		return "Expected relic art region to be large enough while staying contained."
	if not _rect_contains(relic_bounds, relic_art) or not _rect_contains(relic_art, Rect2(relic_art.position + relic_icon.position, relic_icon.size)):
		return "Expected relic icon to stay inside the dedicated art region."
	if bool(relic_readability.get("art_backing_visible", true)):
		return "Expected relic art to integrate into the banner without a separate prototype backing."
	if relic_price.size.x < 200.0 or relic_price.size.y < 68.0:
		return "Expected relic price badge to be large and reference-like."
	if not _rect_contains(relic_bounds, relic_name) or not _rect_contains(relic_bounds, relic_tier) or not _rect_contains(relic_bounds, relic_description):
		return "Expected relic text regions to stay inside the banner."
	if relic_name.intersects(relic_art) or relic_description.intersects(relic_price) or relic_price_divider.intersects(relic_description):
		return "Expected relic art, copy, divider, and price regions not to overlap."
	var compact_relic: String = shop_view._shop_relic_description({
		"content_id": "crown_of_chains",
		"description": "Combo count +3 and +5 flat elemental damage each turn.",
	})
	if compact_relic != "Combo count +3\n+5 Attack each turn":
		return "Expected relic copy to be compact and readable."
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
		"action_row_content",
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
