extends RefCounted
class_name ShopRelicCardPresenter

const SHOP_COPY_FORMATTER := preload("res://scripts/shop/shop_copy_formatter.gd")
const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW_CHROME_STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const RELIC_TITLE_STRIP_RECT := SHOP_LAYOUT_METRICS.RELIC_TITLE_STRIP_RECT
const RELIC_TITLE_TEXT_RECT := SHOP_LAYOUT_METRICS.RELIC_TITLE_TEXT_RECT
const RELIC_TITLE_LEFT_RAIL_RECT := SHOP_LAYOUT_METRICS.RELIC_TITLE_LEFT_RAIL_RECT
const RELIC_TITLE_RIGHT_RAIL_RECT := SHOP_LAYOUT_METRICS.RELIC_TITLE_RIGHT_RAIL_RECT
const RELIC_BANNER_RECT := SHOP_LAYOUT_METRICS.RELIC_BANNER_RECT
const RELIC_BANNER_FRAME_RECT := SHOP_LAYOUT_METRICS.RELIC_BANNER_FRAME_RECT
const RELIC_ART_FRAME_RECT := SHOP_LAYOUT_METRICS.RELIC_ART_FRAME_RECT
const RELIC_ICON_RECT := SHOP_LAYOUT_METRICS.RELIC_ICON_RECT
const RELIC_NAME_RECT := SHOP_LAYOUT_METRICS.RELIC_NAME_RECT
const RELIC_TIER_RECT := SHOP_LAYOUT_METRICS.RELIC_TIER_RECT
const RELIC_DESC_RECT := SHOP_LAYOUT_METRICS.RELIC_DESC_RECT
const RELIC_PRICE_RECT := SHOP_LAYOUT_METRICS.RELIC_PRICE_RECT
const RELIC_UNAVAILABLE_BANNER_MODULATE := Color(0.36, 0.32, 0.40, 0.58)
const RELIC_UNAVAILABLE_VEIL_COLOR := Color(0.010, 0.008, 0.014, 0.60)
const RELIC_UNAVAILABLE_ICON_MODULATE := Color(0.40, 0.38, 0.44, 0.58)
const RELIC_UNAVAILABLE_TITLE_COLOR := Color(0.46, 0.40, 0.52, 0.84)
const RELIC_UNAVAILABLE_COPY_COLOR := Color(0.50, 0.47, 0.52, 0.78)
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const RELIC_TIER_FONT_SIZE := 20


static func render(card: Button, visuals: Variant, relic_offer: Dictionary, treasure_chest_pending: bool) -> void:
	SHOP_VIEW_NODE_FACTORY.clear_children(card)
	card.text = ""
	if relic_offer.is_empty():
		_render_empty(card)
		return

	var rarity := String(relic_offer.get("rarity", "rare")).to_lower()
	var price := int(relic_offer.get("price", 0))
	var sold_out := bool(relic_offer.get("sold_out", false))
	var affordable := bool(relic_offer.get("affordable", false))
	var disabled := bool(relic_offer.get("disabled", sold_out or treasure_chest_pending or not affordable))
	card.disabled = disabled
	card.modulate = Color.WHITE
	card.tooltip_text = ""
	card.mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	SHOP_VIEW_CHROME_STYLER.apply_transparent_button_chrome(card)

	var root := SHOP_VIEW_NODE_FACTORY.make_child_root(card)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(
		root, RELIC_TITLE_STRIP_RECT, UI_UTILS.panel_style(Color(0.02, 0.02, 0.018, 0.58), Color(0, 0, 0, 0), 0, 0, Vector4.ZERO)
	)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(
		root, RELIC_TITLE_LEFT_RAIL_RECT, UI_UTILS.panel_style(GOLD_COLOR.darkened(0.10), GOLD_COLOR.darkened(0.10), 0, 0, Vector4.ZERO)
	)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(
		root, RELIC_TITLE_RIGHT_RAIL_RECT, UI_UTILS.panel_style(GOLD_COLOR.darkened(0.10), GOLD_COLOR.darkened(0.10), 0, 0, Vector4.ZERO)
	)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "DUNGEON RELIC", RELIC_TITLE_TEXT_RECT, GOLD_COLOR, 34, HORIZONTAL_ALIGNMENT_CENTER)

	var banner_root := SHOP_VIEW_NODE_FACTORY.make_root("RelicBannerRoot", root)
	banner_root.position = RELIC_BANNER_RECT.position
	banner_root.size = RELIC_BANNER_RECT.size
	var banner_frame := SHOP_VIEW_NODE_FACTORY.make_texture("RelicBannerFrame", banner_root)
	banner_frame.texture = visuals.collection_relic_banner_frame(rarity)
	banner_frame.position = RELIC_BANNER_FRAME_RECT.position
	banner_frame.size = RELIC_BANNER_FRAME_RECT.size
	banner_frame.custom_minimum_size = RELIC_BANNER_FRAME_RECT.size
	banner_frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	banner_frame.modulate = RELIC_UNAVAILABLE_BANNER_MODULATE if disabled else Color.WHITE
	if disabled:
		SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(
			root, RELIC_BANNER_RECT, UI_UTILS.panel_style(RELIC_UNAVAILABLE_VEIL_COLOR, Color(0, 0, 0, 0), 0, 0, Vector4.ZERO)
		)

	var art_frame := SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(
		root, RELIC_ART_FRAME_RECT, UI_UTILS.panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0, Vector4.ZERO)
	)
	art_frame.clip_contents = true
	var icon := SHOP_VIEW_NODE_FACTORY.make_texture("RelicIcon", art_frame)
	icon.texture = visuals.icon_for_key(String(relic_offer.get("icon_key", "")))
	icon.tooltip_text = ""
	icon.position = RELIC_ICON_RECT.position
	icon.size = RELIC_ICON_RECT.size
	icon.custom_minimum_size = RELIC_ICON_RECT.size
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	icon.modulate = RELIC_UNAVAILABLE_ICON_MODULATE if disabled else Color.WHITE
	var title_color := SHOP_COPY_FORMATTER.relic_title_color(rarity)
	if disabled:
		title_color = RELIC_UNAVAILABLE_TITLE_COLOR
	var name_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		root, String(relic_offer.get("display_name", "Relic")), RELIC_NAME_RECT, title_color, 34, HORIZONTAL_ALIGNMENT_LEFT
	)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	var tier_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		root, "%s RELIC - DUNGEON %d" % [rarity.to_upper(), int(relic_offer.get("dungeon_level", 1))], RELIC_TIER_RECT, title_color, RELIC_TIER_FONT_SIZE
	)
	tier_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	var copy_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		root,
		SHOP_COPY_FORMATTER.shop_relic_description(relic_offer),
		RELIC_DESC_RECT,
		RELIC_UNAVAILABLE_COPY_COLOR if disabled else INK_COLOR,
		21,
		HORIZONTAL_ALIGNMENT_LEFT,
		true
	)
	copy_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	copy_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	SHOP_VIEW_CHROME_STYLER.make_price_badge(
		root, visuals, RELIC_PRICE_RECT, SHOP_COPY_FORMATTER.price_text(price, sold_out, affordable, treasure_chest_pending), disabled
	)


static func _render_empty(card: Button) -> void:
	card.disabled = true
	card.modulate = Color(0.65, 0.65, 0.70, 0.75)
	card.tooltip_text = ""
	SHOP_VIEW_CHROME_STYLER.apply_transparent_button_chrome(card)
	var empty_root := SHOP_VIEW_NODE_FACTORY.make_child_root(card)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		empty_root, "DUNGEON RELIC", Rect2(Vector2(24, 24), Vector2(1000, 30)), GOLD_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER
	)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		empty_root, "Relic offer unavailable.", Rect2(Vector2(24, 86), Vector2(1000, 42)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER
	)
