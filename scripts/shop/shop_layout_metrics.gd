extends RefCounted
class_name ShopLayoutMetrics

const TOP_HEADER_SCRIPT := preload("res://scripts/ui/top_header.gd")
const COLLECTION_CARD_RENDERER := preload("res://scripts/ui/collection_card_renderer.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")

const DESIGN_SIZE := Vector2(1080, 1920)
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 116))
const MERCHANT_STAGE_RECT := Rect2(Vector2(16, 132), Vector2(1048, 338))
const STOCK_PANEL_RECT := Rect2(Vector2(16, 484), Vector2(1048, 556))
const RELIC_PANEL_RECT := Rect2(Vector2(16, 1054), Vector2(1048, 218))
const ACTION_ROW_RECT := Rect2(Vector2(16, 1282), Vector2(1048, 134))
const SHOP_HEADER_SPEECH_RECT := Rect2(Vector2(42, 52), Vector2(352, 150))
const SHOP_HEADER_BOTTOM_RAIL_RECT := Rect2(Vector2(0, MERCHANT_STAGE_RECT.size.y - 18.0), Vector2(MERCHANT_STAGE_RECT.size.x, 18))
const SHOP_HELP_MODAL_OVERLAY_RECT := Rect2(Vector2.ZERO, DESIGN_SIZE)
const SHOP_HELP_MODAL_RECT := Rect2(Vector2(170, 560), Vector2(740, 420))
const SHOP_HELP_MODAL_TITLE_RECT := Rect2(Vector2(58, 60), Vector2(620, 116))
const SHOP_HELP_MODAL_BODY_RECT := Rect2(Vector2(58, 198), Vector2(620, 142))
const SHOP_HELP_MODAL_CLOSE_RECT := Rect2(Vector2(662, 24), Vector2(56, 56))
const ACTION_HINT_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const ACTION_BUTTON_SIZE := Vector2(516, 108)
const ACTION_BUTTON_TEXTURE_MARGIN := 68
const ACTION_BUTTON_CONTENT_MARGIN := 42.0
const ACTION_BUTTON_FONT_SIZE := 32
const ACTION_BUTTON_COST_FONT_SIZE := 32
const RELIC_PRICE_FONT_SIZE := COLLECTION_CARD_RENDERER.CARD_BADGE_FONT_SIZE
const ACTION_REROLL_RECT := Rect2(Vector2(0, 14), ACTION_BUTTON_SIZE)
const ACTION_CONTINUE_RECT := Rect2(Vector2(532, 14), ACTION_BUTTON_SIZE)
const OFFER_CARD_SIZE := COLLECTION_CARD_RENDERER.CARD_SIZE
const OFFER_CARD_GAP := 0.0
const OFFER_GRID_WIDTH := OFFER_CARD_SIZE.x * 3.0 + OFFER_CARD_GAP * 2.0
const OFFER_GRID_RECT := Rect2(Vector2((STOCK_PANEL_RECT.size.x - OFFER_GRID_WIDTH) * 0.5, 62), Vector2(OFFER_GRID_WIDTH, OFFER_CARD_SIZE.y))
const OFFER_SURFACE_RECT := COLLECTION_CARD_RENDERER.CARD_SURFACE_RECT
const OFFER_RARITY_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const OFFER_NAME_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_RECT
const OFFER_NAME_PREFIX_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_PREFIX_RECT
const OFFER_NAME_ITEM_RECT := COLLECTION_CARD_RENDERER.CARD_TITLE_NAME_RECT
const OFFER_TYPE_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const OFFER_ART_FRAME_RECT := COLLECTION_CARD_RENDERER.CARD_ART_RECT
const OFFER_ICON_RECT := Rect2(Vector2.ZERO, COLLECTION_CARD_RENDERER.CARD_ART_RECT.size)
const OFFER_DESC_RECT := COLLECTION_CARD_RENDERER.CARD_COPY_RECT
const OFFER_STATE_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const OFFER_PRICE_RECT := COLLECTION_CARD_RENDERER.CARD_BADGE_RECT
const OFFER_COPY_MAX_CHARS := COLLECTION_CARD_RENDERER.CARD_COPY_MAX_CHARS
const RELIC_TITLE_STRIP_RECT := Rect2(Vector2(0, 0), Vector2(RELIC_PANEL_RECT.size.x, 40))
const RELIC_TITLE_TEXT_RECT := Rect2(Vector2(344, 0), Vector2(360, 42))
const RELIC_TITLE_LEFT_RAIL_RECT := Rect2(Vector2(42, 20), Vector2(282, 2))
const RELIC_TITLE_RIGHT_RAIL_RECT := Rect2(Vector2(724, 20), Vector2(282, 2))
const RELIC_BANNER_RECT := Rect2(Vector2(8, 40), Vector2(1032, 178))
const RELIC_BANNER_FRAME_RECT := Rect2(Vector2.ZERO, RELIC_BANNER_RECT.size)
const RELIC_CONTENT_TOP_INSET := 31.0
const RELIC_ART_FRAME_RECT := Rect2(Vector2(83, 71), Vector2(184, 118))
const RELIC_ART_GLOW_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const RELIC_ICON_RECT := Rect2(Vector2(36, 14), Vector2(112, 90))
const RELIC_NAME_RECT := Rect2(Vector2(330, 72), Vector2(410, 36))
const RELIC_TIER_RECT := Rect2(Vector2(330, 111), Vector2(410, 22))
const RELIC_DESC_RECT := Rect2(Vector2(330, 141), Vector2(410, 54))
const RELIC_PRICE_RECT := Rect2(Vector2(768, 91), Vector2(214, 78))
const RELIC_PRICE_DIVIDER_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const RELIC_STATE_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))


static func shop_layout_for_logical_height(logical_height: float) -> Dictionary:
	var height := maxf(DESIGN_SIZE.y, logical_height)
	var hud_layout := PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset()
	var base_hud_rect: Rect2 = hud_layout.get("section", Rect2(Vector2(0, 1428), Vector2(1080, 492)))
	var hud_rect := Rect2(Vector2(base_hud_rect.position.x, height - base_hud_rect.size.y), base_hud_rect.size)
	var action_rect := ACTION_ROW_RECT
	action_rect.position.y = hud_rect.position.y - 12.0 - ACTION_ROW_RECT.size.y

	var extra_main := maxf(0.0, action_rect.position.y - ACTION_ROW_RECT.position.y)
	var merchant_extra := minf(extra_main * 0.35, 180.0)
	var stock_extra := minf(extra_main * 0.30, 160.0)
	var relic_extra := minf(extra_main * 0.10, 48.0)
	var remaining_extra := maxf(0.0, extra_main - merchant_extra - stock_extra - relic_extra)

	var merchant_stock_gap := 14.0 + remaining_extra * 0.45
	var stock_relic_gap := 14.0 + remaining_extra * 0.35

	var merchant_rect := MERCHANT_STAGE_RECT
	merchant_rect.size.y += merchant_extra
	var stock_rect := STOCK_PANEL_RECT
	stock_rect.position.y = merchant_rect.end.y + merchant_stock_gap
	stock_rect.size.y += stock_extra
	var relic_rect := RELIC_PANEL_RECT
	relic_rect.position.y = stock_rect.end.y + stock_relic_gap
	relic_rect.size.y += relic_extra

	var offer_grid_rect := OFFER_GRID_RECT
	offer_grid_rect.position.y = OFFER_GRID_RECT.position.y + (stock_rect.size.y - STOCK_PANEL_RECT.size.y) * 0.5
	var merchant_bottom_rail_rect := Rect2(
		Vector2(0, merchant_rect.size.y - SHOP_HEADER_BOTTOM_RAIL_RECT.size.y),
		Vector2(merchant_rect.size.x, SHOP_HEADER_BOTTOM_RAIL_RECT.size.y)
	)
	return {
		"logical_height": height,
		"extra_height": height - DESIGN_SIZE.y,
		"uses_full_height": true,
		"top_unused_gap": 0.0,
		"bottom_unused_gap": 0.0,
		"top_bar": TOP_BAR_RECT,
		"merchant_stage": merchant_rect,
		"merchant_bottom_rail": merchant_bottom_rail_rect,
		"stock_panel": stock_rect,
		"offer_grid": offer_grid_rect,
		"relic_panel": relic_rect,
		"action_row": action_rect,
		"player_hud_section": hud_rect,
	}


static func shop_player_hud_layout_override_for(layout: Dictionary) -> Dictionary:
	var override := PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset()
	override["section"] = layout.get("player_hud_section", override.get("section", Rect2()))
	return override


static func shop_layout_probe_for_layout(layout: Dictionary) -> Dictionary:
	var logical_height := float(layout.get("logical_height", DESIGN_SIZE.y))
	var action_row: Rect2 = layout.get("action_row", ACTION_ROW_RECT)
	var hud_section: Rect2 = layout.get("player_hud_section", PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset().get("section", Rect2()))
	return {
		"logical_height": logical_height,
		"extra_height": float(layout.get("extra_height", 0.0)),
		"uses_full_height": bool(layout.get("uses_full_height", false)),
		"top_unused_gap": float(layout.get("top_unused_gap", 9999.0)),
		"bottom_unused_gap": float(layout.get("bottom_unused_gap", 9999.0)),
		"top_bar": layout.get("top_bar", TOP_BAR_RECT),
		"merchant_stage": layout.get("merchant_stage", MERCHANT_STAGE_RECT),
		"merchant_bottom_rail": layout.get("merchant_bottom_rail", SHOP_HEADER_BOTTOM_RAIL_RECT),
		"stock_panel": layout.get("stock_panel", STOCK_PANEL_RECT),
		"offer_grid": layout.get("offer_grid", OFFER_GRID_RECT),
		"relic_panel": layout.get("relic_panel", RELIC_PANEL_RECT),
		"action_row": action_row,
		"player_hud_section": hud_section,
		"merchant_height_delta": Rect2(layout.get("merchant_stage", MERCHANT_STAGE_RECT)).size.y - MERCHANT_STAGE_RECT.size.y,
		"stock_height_delta": Rect2(layout.get("stock_panel", STOCK_PANEL_RECT)).size.y - STOCK_PANEL_RECT.size.y,
		"relic_height_delta": Rect2(layout.get("relic_panel", RELIC_PANEL_RECT)).size.y - RELIC_PANEL_RECT.size.y,
		"action_hud_gap": int(hud_section.position.y - action_row.end.y),
		"hud_bottom_aligned": is_equal_approx(hud_section.end.y, logical_height),
		"action_row_overlaps_hud": (
			hud_section.position.y < action_row.end.y
			and action_row.position.y < hud_section.end.y
		),
	}


static func shop_layout_probe_snapshot() -> Dictionary:
	var layout := shop_layout_for_logical_height(DESIGN_SIZE.y)
	var tall_layout := shop_layout_for_logical_height(2400.0)
	var layout_sample := shop_layout_probe_for_layout(layout)
	var tall_layout_sample := shop_layout_probe_for_layout(tall_layout)
	var hud_section: Rect2 = layout.get("player_hud_section", Rect2())
	var action_row: Rect2 = layout.get("action_row", ACTION_ROW_RECT)
	var merchant_stage: Rect2 = layout.get("merchant_stage", MERCHANT_STAGE_RECT)
	var merchant_bottom_rail: Rect2 = layout.get("merchant_bottom_rail", SHOP_HEADER_BOTTOM_RAIL_RECT)
	var stock_panel: Rect2 = layout.get("stock_panel", STOCK_PANEL_RECT)
	var offer_grid: Rect2 = layout.get("offer_grid", OFFER_GRID_RECT)
	var relic_panel: Rect2 = layout.get("relic_panel", RELIC_PANEL_RECT)
	var hud_layout := shop_player_hud_layout_override_for(layout)
	var hud_footer := Rect2(hud_layout.get("footer_panel", Rect2()))
	var action_bottom := action_row.position.y + action_row.size.y
	var hud_bottom := hud_section.position.y + hud_section.size.y
	var stock_total_width := OFFER_CARD_SIZE.x * 3.0 + OFFER_CARD_GAP * 2.0
	var stock_content_width := offer_grid.size.x
	var stock_bottom := stock_panel.position.y + stock_panel.size.y
	var relic_bottom := relic_panel.position.y + relic_panel.size.y
	var bottom_gap_before_hud := maxi(0, int(hud_section.position.y - action_bottom))
	var action_hud_connected_target_max := 16
	var hud_slot_popover_probe := PLAYER_LOADOUT_HUD_SCRIPT.slot_detail_popover_probe_snapshot()
	return {
		"design_size": DESIGN_SIZE,
		"logical_height": layout_sample.get("logical_height", DESIGN_SIZE.y),
		"layout_mode": "adaptive_full_height_larger_shop",
		"uses_full_viewport_height": true,
		"top_unused_gap": layout_sample.get("top_unused_gap", 0.0),
		"bottom_unused_gap": layout_sample.get("bottom_unused_gap", 0.0),
		"adaptive_layout_samples": {
			"1080x1920": layout_sample,
			"1080x2400": tall_layout_sample,
		},
		"merchant_header_asset_path": "res://resources/art/first_pass/derived/shop_ui/shop_merchant_header_v1.png",
		"top_bar": layout.get("top_bar", TOP_BAR_RECT),
		"top_controls": TOP_HEADER_SCRIPT.layout_snapshot_for(Rect2(Vector2.ZERO, Rect2(layout.get("top_bar", TOP_BAR_RECT)).size)),
		"merchant_stage": merchant_stage,
		"merchant_stage_content": {
			"speech_card": SHOP_HEADER_SPEECH_RECT,
			"bottom_rail": merchant_bottom_rail,
			"summary_detail_visible": false,
			"boss_preview_visible": false,
		},
		"shop_help_modal": {
			"overlay": SHOP_HELP_MODAL_OVERLAY_RECT,
			"modal": SHOP_HELP_MODAL_RECT,
			"title": SHOP_HELP_MODAL_TITLE_RECT,
			"body": SHOP_HELP_MODAL_BODY_RECT,
			"close_button": SHOP_HELP_MODAL_CLOSE_RECT,
			"title_text": "Shop opened. Buy, reroll, sell, or continue.",
			"body_text": "Tap stock or relic cards to buy. Sell filled loadout slots from the slot popover.",
		},
		"stock_panel": stock_panel,
		"offer_grid": offer_grid,
		"relic_panel": relic_panel,
		"action_row": action_row,
		"action_row_content": {
			"hint_label": ACTION_HINT_RECT,
			"reroll_button": ACTION_REROLL_RECT,
			"continue_button": ACTION_CONTINUE_RECT,
			"reroll_label": "REROLL ($1)",
			"continue_label": "CONTINUE",
			"reroll_cost_inline": true,
			"continue_subtitle_visible": false,
			"labels_use_native_button_text": true,
			"uses_long_ui_strip_assets": true,
			"reroll_button_asset": "res://resources/art/assetgen/runtime/shop_ui/shop_action_button_reroll.png",
			"continue_button_asset": "res://resources/art/assetgen/runtime/shop_ui/shop_action_button_continue.png",
			"texture_margin": ACTION_BUTTON_TEXTURE_MARGIN,
			"content_margin": ACTION_BUTTON_CONTENT_MARGIN,
			"button_font_size": ACTION_BUTTON_FONT_SIZE,
			"cost_font_size": ACTION_BUTTON_COST_FONT_SIZE,
			"sell_button": Rect2(Vector2(-9999, -9999), Vector2(1, 1)),
			"visible_primary_actions": ["reroll", "continue"],
			"sell_button_visible": false,
			"action_hint_visible": false,
		},
		"action_hint_bounds": ACTION_HINT_RECT,
		"native_tooltips_disabled": {
			"offer_buttons": true,
			"relic_button": true,
			"card_icon_controls": true,
		},
		"stock_card_size": OFFER_CARD_SIZE,
		"stock_card_gap": OFFER_CARD_GAP,
		"stock_total_width": stock_total_width,
		"stock_content_width": stock_content_width,
		"stock_grid_side_margins": Vector2(offer_grid.position.x, stock_panel.size.x - offer_grid.end.x),
		"stock_fits": stock_total_width <= stock_content_width,
		"treasure_chest_terminology": {
			"pending_state_badge": "CHEST FIRST",
			"pending_price_badge": "WAIT CHEST",
			"overlay_title": "Choose One Treasure Chest Reward",
			"overlay_hint": "Pick one option now, or press Skip to continue shopping.",
			"offer_type_label": "TREASURE CHEST",
			"internal_offer_type": "treasure_chest",
		},
		"stock_relic_gap": int(relic_panel.position.y - stock_bottom),
		"relic_action_gap": int(action_row.position.y - relic_bottom),
		"offer_desc_state_gap": int(OFFER_STATE_RECT.position.y - (OFFER_DESC_RECT.position.y + OFFER_DESC_RECT.size.y)),
		"offer_state_price_gap": int(OFFER_PRICE_RECT.position.y - (OFFER_STATE_RECT.position.y + OFFER_STATE_RECT.size.y)),
		"offer_card_readability": {
			"card_size": OFFER_CARD_SIZE,
			"uses_collection_card_renderer": true,
			"uses_collection_card_frame": true,
			"uses_collection_price_badge": true,
			"uses_compact_shop_copy": true,
			"button_hover_fill_visible": false,
			"active_badge_pops": true,
			"active_badge_uses_external_shadow": false,
			"active_badge_rect_glow_visible": false,
			"renders_rarity_tag": false,
			"frame_rect": Rect2(Vector2.ZERO, OFFER_CARD_SIZE),
			"surface_rect": OFFER_SURFACE_RECT,
			"rarity_rect": OFFER_RARITY_RECT,
			"name_rect": OFFER_NAME_RECT,
			"name_prefix_rect": OFFER_NAME_PREFIX_RECT,
			"name_item_rect": OFFER_NAME_ITEM_RECT,
			"type_rect": OFFER_TYPE_RECT,
			"art_rect": OFFER_ART_FRAME_RECT,
			"icon_rect": OFFER_ICON_RECT,
			"description_rect": OFFER_DESC_RECT,
			"state_rect": OFFER_STATE_RECT,
			"state_badge_visible": false,
			"price_rect": OFFER_PRICE_RECT,
			"copy_max_chars": OFFER_COPY_MAX_CHARS,
			"copy_uses_ellipsis": false,
			"price_text_when_affordable": "$9",
			"price_text_when_unaffordable": "$11",
		},
		"relic_card_readability": {
			"panel_size": relic_panel.size,
			"title_strip_rect": RELIC_TITLE_STRIP_RECT,
			"title_text_rect": RELIC_TITLE_TEXT_RECT,
			"banner_rect": RELIC_BANNER_RECT,
			"banner_frame_rect": RELIC_BANNER_FRAME_RECT,
			"uses_collection_relic_banner_frame": true,
			"uses_collection_price_badge": true,
			"uses_compact_relic_copy": true,
			"has_unavailable_state": true,
			"unavailable_state_dims_banner": true,
			"unavailable_state_dims_art": true,
			"unavailable_state_dims_text": true,
			"unavailable_state_keeps_price_text": true,
			"unavailable_price_badge_inactive": true,
			"unavailable_price_badge_strong_dim": true,
			"price_font_size": RELIC_PRICE_FONT_SIZE,
			"price_font_matches_offer_badge": true,
			"native_button_chrome_visible": false,
			"content_top_inset": RELIC_CONTENT_TOP_INSET,
			"art_rect": RELIC_ART_FRAME_RECT,
			"art_glow_rect": RELIC_ART_GLOW_RECT,
			"art_backing_visible": false,
			"icon_rect": RELIC_ICON_RECT,
			"name_rect": RELIC_NAME_RECT,
			"tier_rect": RELIC_TIER_RECT,
			"description_rect": RELIC_DESC_RECT,
			"state_rect": RELIC_STATE_RECT,
			"state_badge_visible": false,
			"price_rect": RELIC_PRICE_RECT,
			"price_divider_rect": RELIC_PRICE_DIVIDER_RECT,
			"price_text_when_unaffordable": "$24",
		},
		"slot_detail_popover_probe": hud_slot_popover_probe,
		"player_hud_section": hud_section,
		"hud_override_footer": hud_footer,
		"hud_bottom_gap_after_section": maxi(0, int(DESIGN_SIZE.y - hud_bottom)),
		"hud_bottom_aligned": is_equal_approx(hud_bottom, DESIGN_SIZE.y),
		"action_row_overlaps_hud": (
			hud_section.position.y < action_bottom
			and ACTION_ROW_RECT.position.y < hud_bottom
		),
		"bottom_gap_before_hud": bottom_gap_before_hud,
		"action_hud_connected_target_max": action_hud_connected_target_max,
		"action_hud_connected": bottom_gap_before_hud <= action_hud_connected_target_max,
	}
