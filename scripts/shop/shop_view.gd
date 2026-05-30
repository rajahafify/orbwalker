extends RefCounted
class_name ShopView

signal offer_pressed(index: int)
signal relic_pressed
signal reroll_pressed
signal sell_pressed
signal continue_pressed
signal main_menu_pressed
signal treasure_chest_option_pressed(index: int)
signal skip_treasure_chest_pressed
signal equipment_slot_selected(index: int)
signal consumable_slot_selected(index: int)
signal hud_sell_slot_requested(slot_type: String, slot_index: int)

const PLAYER_HUD_SCENE := preload("res://scenes/ui/player_hud.tscn")
const TOP_HEADER_SCENE := preload("res://scenes/ui/top_header.tscn")
const TOP_HEADER_SCRIPT := preload("res://scripts/ui/top_header.gd")
const COLLECTION_CARD_RENDERER := preload("res://scripts/ui/collection_card_renderer.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const SHOP_COPY_FORMATTER := preload("res://scripts/shop/shop_copy_formatter.gd")
const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const DESIGN_SIZE := SHOP_LAYOUT_METRICS.DESIGN_SIZE
const TOP_BAR_RECT := SHOP_LAYOUT_METRICS.TOP_BAR_RECT
const MERCHANT_STAGE_RECT := SHOP_LAYOUT_METRICS.MERCHANT_STAGE_RECT
const STOCK_PANEL_RECT := SHOP_LAYOUT_METRICS.STOCK_PANEL_RECT
const RELIC_PANEL_RECT := SHOP_LAYOUT_METRICS.RELIC_PANEL_RECT
const ACTION_ROW_RECT := SHOP_LAYOUT_METRICS.ACTION_ROW_RECT
const SHOP_HEADER_SPEECH_RECT := SHOP_LAYOUT_METRICS.SHOP_HEADER_SPEECH_RECT
const SHOP_HEADER_BOTTOM_RAIL_RECT := SHOP_LAYOUT_METRICS.SHOP_HEADER_BOTTOM_RAIL_RECT
const SHOP_HELP_MODAL_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_RECT
const SHOP_HELP_MODAL_TITLE_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_TITLE_RECT
const SHOP_HELP_MODAL_BODY_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_BODY_RECT
const SHOP_HELP_MODAL_CLOSE_RECT := SHOP_LAYOUT_METRICS.SHOP_HELP_MODAL_CLOSE_RECT
const ACTION_HINT_RECT := SHOP_LAYOUT_METRICS.ACTION_HINT_RECT
const ACTION_BUTTON_TEXTURE_MARGIN := SHOP_LAYOUT_METRICS.ACTION_BUTTON_TEXTURE_MARGIN
const ACTION_BUTTON_CONTENT_MARGIN := SHOP_LAYOUT_METRICS.ACTION_BUTTON_CONTENT_MARGIN
const ACTION_BUTTON_FONT_SIZE := SHOP_LAYOUT_METRICS.ACTION_BUTTON_FONT_SIZE
const RELIC_PRICE_FONT_SIZE := SHOP_LAYOUT_METRICS.RELIC_PRICE_FONT_SIZE
const ACTION_REROLL_RECT := SHOP_LAYOUT_METRICS.ACTION_REROLL_RECT
const ACTION_CONTINUE_RECT := SHOP_LAYOUT_METRICS.ACTION_CONTINUE_RECT
const OFFER_CARD_SIZE := SHOP_LAYOUT_METRICS.OFFER_CARD_SIZE
const OFFER_CARD_GAP := SHOP_LAYOUT_METRICS.OFFER_CARD_GAP
const OFFER_GRID_RECT := SHOP_LAYOUT_METRICS.OFFER_GRID_RECT
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
const RELIC_UNAVAILABLE_PRICE_FRAME_MODULATE := Color(0.34, 0.28, 0.21, 0.52)
const RELIC_UNAVAILABLE_PRICE_TEXT_COLOR := Color(0.52, 0.42, 0.30, 0.70)
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const POSITIVE_COLOR := Color(0.60, 0.88, 0.42, 1.0)
const NEGATIVE_COLOR := Color(1.0, 0.45, 0.38, 1.0)
var _background: TextureRect
var _backdrop_tint: ColorRect
var _layout_root: Control

var _hud_overlay: Control
var _top_bar: Panel
var _crest_panel: Panel
var _crest_label: Label
var _title_label: Label
var _run_progress_label: Label
var _gold_pill: Panel
var _gold_label: Label
var _main_menu_button: Button
var _help_button: Button
var _settings_button: Button
var _shop_help_overlay: ColorRect
var _shop_help_modal: Panel
var _shop_help_title_label: Label
var _shop_help_body_label: Label
var _shop_help_close_button: Button
var _merchant_stage: Panel
var _merchant_backdrop: TextureRect
var _merchant_scrim: ColorRect
var _merchant_counter: ColorRect
var _merchant_info_backdrop: ColorRect
var _merchant_header_label: Label
var _speech_card: Panel
var _speech_label: Label
var _boss_preview_label: Label
var _summary_label: Label
var _detail_label: Label
var _stock_panel: Panel
var _stock_title_label: Label
var _offer_grid: Control
var _offer_cards: Array[Button] = []
var _relic_card: Button
var _action_row: Control
var _action_hint_label: Label
var _reroll_button: Button
var _sell_equipment_button: Button
var _continue_button: Button
var _player_hud_section: Panel
var _build_panel: Panel
var _elemental_mastery_panel: Panel
var _elemental_mastery_title: Label
var _elemental_mastery_cards: Control
var _player_panel_root: Control
var _hero_card: Panel
var _hero_card_root: Control
var _hero_level_badge: PanelContainer
var _hero_portrait: TextureRect
var _vitals_panel: Control
var _vitals_frame: Panel
var _hp_bar: ProgressBar
var _hp_label: Label
var _armor_bar: ProgressBar
var _armor_label: Label
var _armor_badge: PanelContainer
var _armor_badge_label: Label
var _stat_chip_row: HBoxContainer
var _attack_stat_label: Label
var _armor_stat_label: Label
var _heart_stat_label: Label
var _gold_stat_label: Label
var _combat_meta_row: HBoxContainer
var _combat_phase_label: Label
var _turn_summary_label: Label
var _equipment_label: Label
var _equipment_slots_root: Control
var _consumable_label: Label
var _consumable_slots_root: Control
var _relic_label: Label
var _relic_icons_root: Control
var _relic_row: HBoxContainer
var _loadout_frame: Panel
var _loadout_root: Control
var _mastery_strip: Panel
var _mastery_root: Control
var _mastery_label: Label
var _mastery_icons: Control
var _treasure_chest_overlay: ColorRect
var _treasure_chest_modal: Panel
var _treasure_chest_title_label: Label
var _treasure_chest_hint_label: Label
var _treasure_chest_option_buttons: Array[Button] = []
var _skip_treasure_chest_button: Button
var _tutorial_overlay: Control
var _tutorial_focus_frame: Panel
var _tutorial_prompt_panel: Panel
var _tutorial_prompt_label: Label

var _visuals
var _player_loadout_hud
var _current_shop_layout: Dictionary = {}
var _current_player_hud_layout_override: Dictionary = {}
var _current_tutorial_shop_phase := ""

func bind(root_nodes: Dictionary, visuals, player_loadout_hud) -> void:
	_background = root_nodes.get("background") as TextureRect
	_backdrop_tint = root_nodes.get("backdrop_tint") as ColorRect
	_layout_root = root_nodes.get("layout_root") as Control
	_visuals = visuals
	_player_loadout_hud = player_loadout_hud
	if _background != null:
		_background.texture = _visuals.shop_background()
	if _backdrop_tint != null:
		_backdrop_tint.color = Color(0.0, 0.0, 0.0, 0.33)
	_create_ui()
	_player_loadout_hud.bind_player_hud(_shop_player_hud_nodes().merged({
		"popover_parent": _hud_overlay,
		"popover_z_index": 51,
	}, true))
	_player_loadout_hud.set_player_hud_layout_override(_shop_player_hud_layout_override())
	_apply_visual_chrome()
	_connect_signals()
	apply_layout()

func _create_ui() -> void:
	_layout_root.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_hud_overlay = SHOP_VIEW_NODE_FACTORY.make_root("HudOverlay", _layout_root)
	_hud_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_hud_overlay.z_index = 50
	_hud_overlay.clip_contents = false

	_top_bar = TOP_HEADER_SCENE.instantiate() as Panel
	_top_bar.name = "TopBar"
	_layout_root.add_child(_top_bar)
	_crest_panel = _top_bar.get_node("%CrestPanel") as Panel
	_crest_label = _top_bar.get_node("%CrestLabel") as Label
	_run_progress_label = _top_bar.get_node("%RunProgressLabel") as Label
	_title_label = _top_bar.get_node("%TitleLabel") as Label
	_gold_pill = _top_bar.get_node("%GoldPill") as Panel
	_gold_label = _top_bar.get_node("%GoldLabel") as Label
	_main_menu_button = _top_bar.get_node("%MainMenuButton") as Button
	_help_button = _top_bar.get_node("%HelpButton") as Button
	_settings_button = _top_bar.get_node("%SettingsButton") as Button
	_help_button.tooltip_text = "Shop help"
	_settings_button.tooltip_text = "Settings (visual-only in this prototype build)."
	_crest_panel.visible = false
	_crest_label.visible = false
	_run_progress_label.visible = false
	_main_menu_button.visible = false
	_settings_button.visible = true

	_merchant_stage = SHOP_VIEW_NODE_FACTORY.make_panel("MerchantStage", _layout_root)
	_merchant_backdrop = SHOP_VIEW_NODE_FACTORY.make_texture("MerchantBackdrop", _merchant_stage)
	_merchant_backdrop.texture = _visuals.shop_merchant_header()
	_merchant_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_merchant_scrim = SHOP_VIEW_NODE_FACTORY.make_color_rect("MerchantScrim", _merchant_stage, Color(0.0, 0.0, 0.0, 0.30))
	_merchant_counter = SHOP_VIEW_NODE_FACTORY.make_color_rect("MerchantCounter", _merchant_stage, Color(0.08, 0.045, 0.025, 0.88))
	_merchant_info_backdrop = SHOP_VIEW_NODE_FACTORY.make_color_rect("MerchantInfoBackdrop", _merchant_stage, Color(0.02, 0.03, 0.04, 0.70))
	_merchant_header_label = SHOP_VIEW_NODE_FACTORY.make_label("MerchantHeaderLabel", _merchant_stage, "", 32, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_merchant_header_label.visible = false
	_speech_card = SHOP_VIEW_NODE_FACTORY.make_panel("SpeechCard", _merchant_stage)
	_speech_label = SHOP_VIEW_NODE_FACTORY.make_label("SpeechLabel", _speech_card, "Well met, adventurer. New stock, fresh from the depths.", 25, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_boss_preview_label = SHOP_VIEW_NODE_FACTORY.make_label("BossPreviewLabel", _speech_card, "Boss preview: -", 16, MUTED_COLOR)
	_summary_label = SHOP_VIEW_NODE_FACTORY.make_label("SummaryLabel", _merchant_stage, "-", 21, POSITIVE_COLOR)
	_detail_label = SHOP_VIEW_NODE_FACTORY.make_label("DetailLabel", _merchant_stage, "Tap stock or relic cards to buy. Sell: tap a filled loadout slot, then press Sell in the slot popover.", 19, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_merchant_info_backdrop.visible = false
	_boss_preview_label.visible = false
	_summary_label.visible = false
	_detail_label.visible = false

	_stock_panel = SHOP_VIEW_NODE_FACTORY.make_panel("StockPanel", _layout_root)
	_stock_title_label = SHOP_VIEW_NODE_FACTORY.make_label("StockTitleLabel", _stock_panel, "SHOP STOCK", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_offer_grid = Control.new()
	_offer_grid.name = "OfferGrid"
	_stock_panel.add_child(_offer_grid)
	for index in 3:
		var card := SHOP_VIEW_NODE_FACTORY.make_button("OfferCard%d" % (index + 1), _offer_grid, "")
		_offer_cards.append(card)

	_relic_card = SHOP_VIEW_NODE_FACTORY.make_button("RelicCard", _layout_root, "")
	_action_row = Control.new()
	_action_row.name = "ActionRow"
	_layout_root.add_child(_action_row)
	_action_hint_label = SHOP_VIEW_NODE_FACTORY.make_label("ActionHintLabel", _action_row, "SELL TIP: Tap a filled loadout slot, then press Sell in the slot popover.", 20, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	_action_hint_label.visible = false
	_reroll_button = SHOP_VIEW_NODE_FACTORY.make_button("RerollButton", _action_row, "Reroll")
	_sell_equipment_button = SHOP_VIEW_NODE_FACTORY.make_button("SellEquipmentButton", _action_row, "Sell Selected")
	_continue_button = SHOP_VIEW_NODE_FACTORY.make_button("ContinueButton", _action_row, "Continue")

	_bind_shared_player_hud_scene()
	_treasure_chest_overlay = ColorRect.new()
	_treasure_chest_overlay.name = "TreasureChestOverlay"
	_treasure_chest_overlay.visible = false
	_treasure_chest_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_layout_root.add_child(_treasure_chest_overlay)
	_treasure_chest_modal = SHOP_VIEW_NODE_FACTORY.make_panel("TreasureChestModal", _treasure_chest_overlay)
	_treasure_chest_modal.mouse_filter = Control.MOUSE_FILTER_PASS as Control.MouseFilter
	_treasure_chest_title_label = SHOP_VIEW_NODE_FACTORY.make_label("TreasureChestTitleLabel", _treasure_chest_modal, "Choose One Treasure Chest Reward", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_treasure_chest_hint_label = SHOP_VIEW_NODE_FACTORY.make_label("TreasureChestHintLabel", _treasure_chest_modal, "Pick one option now, or press Skip to continue shopping.", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	for index in 3:
		var button := SHOP_VIEW_NODE_FACTORY.make_button("TreasureChestOptionButton%d" % (index + 1), _treasure_chest_modal, "")
		_treasure_chest_option_buttons.append(button)
	_skip_treasure_chest_button = SHOP_VIEW_NODE_FACTORY.make_button("SkipTreasureChestButton", _treasure_chest_modal, "Skip")
	_skip_treasure_chest_button.visible = false

	_shop_help_overlay = SHOP_VIEW_NODE_FACTORY.make_color_rect("ShopHelpOverlay", _layout_root, Color(0.0, 0.0, 0.0, 0.54))
	_shop_help_overlay.visible = false
	_shop_help_overlay.z_index = 70
	_shop_help_overlay.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_shop_help_modal = SHOP_VIEW_NODE_FACTORY.make_panel("ShopHelpModal", _shop_help_overlay)
	_shop_help_modal.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	_shop_help_title_label = SHOP_VIEW_NODE_FACTORY.make_label("ShopHelpTitleLabel", _shop_help_modal, "Shop opened. Buy, reroll, sell, or continue.", 34, POSITIVE_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_shop_help_body_label = SHOP_VIEW_NODE_FACTORY.make_label("ShopHelpBodyLabel", _shop_help_modal, "Tap stock or relic cards to buy. Sell filled loadout slots from the slot popover.", 26, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_shop_help_close_button = SHOP_VIEW_NODE_FACTORY.make_button("ShopHelpCloseButton", _shop_help_modal, "x")
	_create_tutorial_overlay()


func _bind_shared_player_hud_scene() -> void:
	_player_hud_section = PLAYER_HUD_SCENE.instantiate() as Panel
	_player_hud_section.name = "PlayerHudSection"
	_player_hud_section.clip_contents = false
	_layout_root.add_child(_player_hud_section)

	_elemental_mastery_panel = _shared_player_hud_node("ElementalMasteryPanel") as Panel
	_elemental_mastery_title = _shared_player_hud_node("ElementalMasteryTitle") as Label
	_elemental_mastery_cards = _shared_player_hud_node("ElementalMasteryCards") as Control
	_build_panel = _shared_player_hud_node("PlayerPanel") as Panel
	_player_panel_root = _shared_player_hud_node("PlayerPanelRoot") as Control
	_hero_card = _shared_player_hud_node("HeroCard") as Panel
	_hero_card_root = _shared_player_hud_node("HeroCardRoot") as Control
	_hero_level_badge = _shared_player_hud_node("HeroLevelBadge") as PanelContainer
	_hero_portrait = _shared_player_hud_node("PlayerPortrait") as TextureRect
	_vitals_panel = _shared_player_hud_node("VitalsPanel") as Control
	_vitals_frame = _shared_player_hud_node("VitalsFrame") as Panel
	_hp_bar = _shared_player_hud_node("PlayerHpBar") as ProgressBar
	_hp_label = _shared_player_hud_node("PlayerHpLabel") as Label
	_armor_bar = _shared_player_hud_node("PlayerArmorBar") as ProgressBar
	_armor_label = _shared_player_hud_node("PlayerArmorLabel") as Label
	_armor_badge = _shared_player_hud_node("ArmorBadge") as PanelContainer
	_armor_badge_label = _shared_player_hud_node("ArmorBadgeLabel") as Label
	_stat_chip_row = _shared_player_hud_node("StatChipRow") as HBoxContainer
	_attack_stat_label = _shared_player_hud_node("AttackStatLabel") as Label
	_armor_stat_label = _shared_player_hud_node("ArmorStatLabel") as Label
	_heart_stat_label = _shared_player_hud_node("HeartStatLabel") as Label
	_gold_stat_label = _shared_player_hud_node("GoldStatLabel") as Label
	_combat_meta_row = _shared_player_hud_node("CombatMetaRow") as HBoxContainer
	_combat_phase_label = _shared_player_hud_node("CombatPhaseLabel") as Label
	_turn_summary_label = _shared_player_hud_node("TurnSummaryLabel") as Label
	_loadout_frame = _shared_player_hud_node("LoadoutFrame") as Panel
	_loadout_root = _shared_player_hud_node("LoadoutRoot") as Control
	_equipment_label = _shared_player_hud_node("EquipmentLabel") as Label
	_equipment_slots_root = _shared_player_hud_node("EquipmentIcons") as Control
	_consumable_label = _shared_player_hud_node("ConsumableLabel") as Label
	_consumable_slots_root = _shared_player_hud_node("ConsumableIcons") as Control
	_relic_label = _shared_player_hud_node("RelicLabel") as Label
	_relic_icons_root = _shared_player_hud_node("RelicIcons") as Control
	_relic_row = _shared_player_hud_node("RelicRow") as HBoxContainer
	_mastery_strip = _shared_player_hud_node("MasteryStrip") as Panel
	_mastery_root = _shared_player_hud_node("MasteryRoot") as Control
	_mastery_label = _shared_player_hud_node("MasteryLabel") as Label
	_mastery_icons = _shared_player_hud_node("MasteryIcons") as Control


func _shared_player_hud_node(unique_name: String) -> Node:
	if _player_hud_section == null:
		return null
	return _player_hud_section.get_node_or_null("%s%s" % ["%", unique_name])


func _connect_signals() -> void:
	for index in _offer_cards.size():
		_offer_cards[index].pressed.connect(func(): emit_signal("offer_pressed", index))
	_relic_card.pressed.connect(_emit_relic_pressed)
	_reroll_button.pressed.connect(_emit_reroll_pressed)
	_sell_equipment_button.pressed.connect(_emit_sell_pressed)
	_continue_button.pressed.connect(_emit_continue_pressed)
	_main_menu_button.pressed.connect(_emit_main_menu_pressed)
	_help_button.pressed.connect(_on_help_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_shop_help_overlay.gui_input.connect(_on_shop_help_overlay_gui_input)
	_shop_help_close_button.pressed.connect(_hide_shop_help_modal)
	for index in _treasure_chest_option_buttons.size():
		_treasure_chest_option_buttons[index].pressed.connect(func(): emit_signal("treasure_chest_option_pressed", index))
	_skip_treasure_chest_button.pressed.connect(_emit_skip_treasure_chest_pressed)
	_player_loadout_hud.equipment_slot_selected.connect(_emit_equipment_slot_selected)
	_player_loadout_hud.consumable_slot_selected.connect(_emit_consumable_slot_selected)
	_player_loadout_hud.sell_slot_requested.connect(_emit_hud_sell_slot_requested)


func render(snapshot: Dictionary) -> void:
	var shop_snapshot: Dictionary = snapshot.get("shop", {})
	var progression_snapshot: Dictionary = snapshot.get("progression", {})
	var pending_options: Array = snapshot.get("pending_treasure_chest_options", [])
	var treasure_chest_pending := bool(snapshot.get("treasure_chest_pending", false))
	_current_tutorial_shop_phase = String(snapshot.get("tutorial_shop_phase", ""))

	_title_label.text = "Dungeon %d-%d" % [int(snapshot.get("dungeon_level", 1)), int(snapshot.get("shop_ordinal", 1))]
	_boss_preview_label.text = "Boss preview: %s" % String(snapshot.get("boss_preview", "-"))
	_gold_label.text = "$%d" % int(snapshot.get("gold", 0))
	_detail_label.text = "Tap stock or relic cards to buy. Sell: tap a filled loadout slot, then press Sell in the slot popover."
	set_status(String(snapshot.get("status_message", "")), bool(snapshot.get("status_positive", true)))

	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for index in _offer_cards.size():
		if index >= item_offers.size():
			_render_empty_offer_card(_offer_cards[index])
		else:
			_render_offer_card(_offer_cards[index], Dictionary(item_offers[index]), treasure_chest_pending)

	_render_relic_card(Dictionary(shop_snapshot.get("relic_offer", {})), treasure_chest_pending)
	_render_action_row(shop_snapshot, treasure_chest_pending)
	_render_build_panel(snapshot)
	_render_elemental_mastery_panel(Dictionary(progression_snapshot.get("mastery_levels", {})))
	_render_treasure_chest_overlay(pending_options)
	_render_tutorial_overlay()
	apply_layout()


func _render_offer_card(card: Button, offer: Dictionary, treasure_chest_pending: bool) -> void:
	var rarity := String(offer.get("rarity", "common")).to_lower()
	var sold_out := bool(offer.get("sold_out", false))
	var price := int(offer.get("price", 0))
	var affordable := bool(offer.get("affordable", false))
	var disabled := bool(offer.get("disabled", sold_out or treasure_chest_pending or not affordable))
	var card_data := offer.duplicate(true)
	card_data["display_name"] = String(offer.get("display_name", "Offer"))
	card_data["rarity"] = rarity
	card_data["description"] = SHOP_COPY_FORMATTER.shop_card_description(offer)
	card_data["badge_text"] = SHOP_COPY_FORMATTER.price_text(price, sold_out, affordable, treasure_chest_pending)
	card_data["badge_enabled"] = bool(offer.get("badge_enabled", not disabled))
	COLLECTION_CARD_RENDERER.render_card(card, _visuals, card_data, {
		"disabled": disabled,
		"tooltip_text": "",
		"mouse_cursor": Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND,
		"modulate": Color(0.45, 0.45, 0.48, 0.52) if disabled and _current_tutorial_shop_phase != "" else Color(0.58, 0.58, 0.60, 0.72) if disabled else Color.WHITE,
	})


func _render_empty_offer_card(card: Button) -> void:
	SHOP_VIEW_NODE_FACTORY.clear_children(card)
	card.text = ""
	card.disabled = true
	card.modulate = Color(0.65, 0.65, 0.70, 0.75)
	card.tooltip_text = ""
	_apply_card_chrome(card, Color(0.05, 0.06, 0.08, 0.90), Color(0.24, 0.27, 0.34, 0.95), Color(0.05, 0.06, 0.08, 0.98))
	var root := SHOP_VIEW_NODE_FACTORY.make_child_root(card)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "EMPTY", Rect2(Vector2(20, 190), Vector2(280, 50)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "No offer in this slot.", Rect2(Vector2(28, 250), Vector2(264, 46)), MUTED_COLOR, 18, HORIZONTAL_ALIGNMENT_CENTER, true)


func _render_relic_card(relic_offer: Dictionary, treasure_chest_pending: bool) -> void:
	SHOP_VIEW_NODE_FACTORY.clear_children(_relic_card)
	_relic_card.text = ""
	if relic_offer.is_empty():
		_relic_card.disabled = true
		_relic_card.modulate = Color(0.65, 0.65, 0.70, 0.75)
		_relic_card.tooltip_text = ""
		_apply_transparent_button_chrome(_relic_card)
		var empty_root := SHOP_VIEW_NODE_FACTORY.make_child_root(_relic_card)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(empty_root, "DUNGEON RELIC", Rect2(Vector2(24, 24), Vector2(1000, 30)), GOLD_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(empty_root, "Relic offer unavailable.", Rect2(Vector2(24, 86), Vector2(1000, 42)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
		return

	var rarity := String(relic_offer.get("rarity", "rare")).to_lower()
	var price := int(relic_offer.get("price", 0))
	var sold_out := bool(relic_offer.get("sold_out", false))
	var affordable := bool(relic_offer.get("affordable", false))
	var disabled := bool(relic_offer.get("disabled", sold_out or treasure_chest_pending or not affordable))
	_relic_card.disabled = disabled
	_relic_card.modulate = Color.WHITE
	_relic_card.tooltip_text = ""
	_relic_card.mouse_default_cursor_shape = Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND
	_apply_transparent_button_chrome(_relic_card)

	var root := SHOP_VIEW_NODE_FACTORY.make_child_root(_relic_card)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(root, RELIC_TITLE_STRIP_RECT, UI_UTILS.panel_style(Color(0.02, 0.02, 0.018, 0.58), Color(0, 0, 0, 0), 0, 0, Vector4.ZERO))
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(root, RELIC_TITLE_LEFT_RAIL_RECT, UI_UTILS.panel_style(GOLD_COLOR.darkened(0.10), GOLD_COLOR.darkened(0.10), 0, 0, Vector4.ZERO))
	SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(root, RELIC_TITLE_RIGHT_RAIL_RECT, UI_UTILS.panel_style(GOLD_COLOR.darkened(0.10), GOLD_COLOR.darkened(0.10), 0, 0, Vector4.ZERO))
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "DUNGEON RELIC", RELIC_TITLE_TEXT_RECT, GOLD_COLOR, 34, HORIZONTAL_ALIGNMENT_CENTER)

	var banner_root := SHOP_VIEW_NODE_FACTORY.make_root("RelicBannerRoot", root)
	banner_root.position = RELIC_BANNER_RECT.position
	banner_root.size = RELIC_BANNER_RECT.size
	var banner_frame := SHOP_VIEW_NODE_FACTORY.make_texture("RelicBannerFrame", banner_root)
	banner_frame.texture = _visuals.collection_relic_banner_frame(rarity)
	banner_frame.position = RELIC_BANNER_FRAME_RECT.position
	banner_frame.size = RELIC_BANNER_FRAME_RECT.size
	banner_frame.custom_minimum_size = RELIC_BANNER_FRAME_RECT.size
	banner_frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	banner_frame.modulate = RELIC_UNAVAILABLE_BANNER_MODULATE if disabled else Color.WHITE
	if disabled:
		SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(root, RELIC_BANNER_RECT, UI_UTILS.panel_style(RELIC_UNAVAILABLE_VEIL_COLOR, Color(0, 0, 0, 0), 0, 0, Vector4.ZERO))

	var art_frame := SHOP_VIEW_NODE_FACTORY.make_dynamic_panel(root, RELIC_ART_FRAME_RECT, UI_UTILS.panel_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0, Vector4.ZERO))
	art_frame.clip_contents = true
	var icon := SHOP_VIEW_NODE_FACTORY.make_texture("RelicIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(relic_offer.get("icon_key", "")))
	icon.tooltip_text = ""
	icon.position = RELIC_ICON_RECT.position
	icon.size = RELIC_ICON_RECT.size
	icon.custom_minimum_size = RELIC_ICON_RECT.size
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	icon.modulate = RELIC_UNAVAILABLE_ICON_MODULATE if disabled else Color.WHITE
	var title_color := SHOP_COPY_FORMATTER.relic_title_color(rarity)
	if disabled:
		title_color = RELIC_UNAVAILABLE_TITLE_COLOR
	var name_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, String(relic_offer.get("display_name", "Relic")), RELIC_NAME_RECT, title_color, 34, HORIZONTAL_ALIGNMENT_LEFT)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	var tier_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "%s RELIC - DUNGEON %d" % [rarity.to_upper(), int(relic_offer.get("dungeon_level", 1))], RELIC_TIER_RECT, title_color, 18)
	tier_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	var copy_label := SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, SHOP_COPY_FORMATTER.shop_relic_description(relic_offer), RELIC_DESC_RECT, RELIC_UNAVAILABLE_COPY_COLOR if disabled else INK_COLOR, 21, HORIZONTAL_ALIGNMENT_LEFT, true)
	copy_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	copy_label.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
	_make_price_badge(root, RELIC_PRICE_RECT, SHOP_COPY_FORMATTER.price_text(price, sold_out, affordable, treasure_chest_pending), disabled)


func _render_action_row(shop_snapshot: Dictionary, treasure_chest_pending: bool) -> void:
	var active := bool(shop_snapshot.get("active", false))
	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.disabled = treasure_chest_pending or not active or not bool(shop_snapshot.get("reroll_enabled", false))
	_render_action_button_label(
		_reroll_button,
		"REROLL",
		"(FREE)" if reroll_cost <= 0 else "($%d)" % reroll_cost,
		_reroll_button.disabled
	)
	_action_hint_label.visible = false
	_sell_equipment_button.visible = false
	_sell_equipment_button.disabled = true
	_continue_button.disabled = not bool(shop_snapshot.get("continue_enabled", not treasure_chest_pending))
	_render_action_button_label(_continue_button, "CONTINUE", "", _continue_button.disabled)


func _render_action_button_label(button: Button, action_text: String, cost_text: String, disabled: bool) -> void:
	button.text = action_text if cost_text == "" else "%s %s" % [action_text, cost_text]
	button.tooltip_text = ""
	button.modulate = Color(0.62, 0.62, 0.64, 0.78) if disabled else Color.WHITE


func _render_build_panel(snapshot: Dictionary) -> void:
	var progression_snapshot: Dictionary = snapshot.get("progression", {})
	var player_state = snapshot.get("player_state")
	_player_loadout_hud.set_selected_equipment_slot(int(snapshot.get("selected_equipment_slot", -1)))
	_player_loadout_hud.set_selected_consumable_slot(int(snapshot.get("selected_consumable_slot", -1)))
	_player_loadout_hud.update_player_data({
		"player_state": player_state,
		"progression": progression_snapshot,
		"hero_portrait": _visuals.hero_portrait(),
		"max_visible_relics": 2,
		"selectable_equipment": true,
		"selectable_consumables": true,
	})


func _render_elemental_mastery_panel(mastery_levels: Dictionary) -> void:
	_player_loadout_hud.populate_combat_mastery_panel(_elemental_mastery_cards, mastery_levels)


func _render_treasure_chest_overlay(pending_options: Array) -> void:
	var overlay_visible := not pending_options.is_empty()
	_treasure_chest_overlay.visible = overlay_visible
	_treasure_chest_modal.visible = overlay_visible
	if not overlay_visible:
		_skip_treasure_chest_button.visible = false
		return
	_treasure_chest_title_label.text = "Choose One Treasure Chest Reward"
	_treasure_chest_hint_label.text = "Pick one option now, or press Skip to continue shopping."
	for button in _treasure_chest_option_buttons:
		button.visible = true
	for index in _treasure_chest_option_buttons.size():
		var button := _treasure_chest_option_buttons[index]
		SHOP_VIEW_NODE_FACTORY.clear_children(button)
		button.text = ""
		if index >= pending_options.size():
			button.visible = false
			button.disabled = true
			continue
		button.visible = true
		button.disabled = false
		var option: Dictionary = pending_options[index]
		_apply_button_chrome(button, Color(0.10, 0.08, 0.13, 0.98), GOLD_COLOR, Color(0.18, 0.13, 0.08, 1.0))
		var root := SHOP_VIEW_NODE_FACTORY.make_child_root(button)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, String(option.get("type", "option")).replace("_", " ").to_upper(), Rect2(Vector2(14, 8), Vector2(180, 22)), MUTED_COLOR, 14, HORIZONTAL_ALIGNMENT_CENTER)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, String(option.get("display_name", "Option")), Rect2(Vector2(14, 36), Vector2(180, 54)), INK_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER, true)
		var content := _lookup_content_definition(String(option.get("content_id", "")))
		var icon := SHOP_VIEW_NODE_FACTORY.make_texture("TreasureChestOptionIcon", root)
		icon.texture = _visuals.icon_for_key(String(content.get("icon_key", "")))
		icon.position = Vector2(42, 92)
		icon.size = Vector2(124, 104)
		SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "PICK", Rect2(Vector2(22, 196), Vector2(164, 42)), GOLD_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER)
	_skip_treasure_chest_button.visible = true
	_skip_treasure_chest_button.disabled = false



func set_status(message: String, positive: bool) -> void:
	if _summary_label == null:
		return
	_summary_label.text = message
	_summary_label.add_theme_color_override("font_color", POSITIVE_COLOR if positive else NEGATIVE_COLOR)


func lock_transitions(enabled: bool) -> void:
	if _continue_button != null:
		_continue_button.disabled = enabled
	if _main_menu_button != null:
		_main_menu_button.disabled = enabled
	if _help_button != null:
		_help_button.disabled = enabled
	if _settings_button != null:
		_settings_button.disabled = enabled


func _create_tutorial_overlay() -> void:
	_tutorial_overlay = SHOP_VIEW_NODE_FACTORY.make_root("TutorialShopOverlay", _hud_overlay)
	_tutorial_overlay.visible = false
	_tutorial_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_tutorial_overlay.z_index = 80
	_tutorial_focus_frame = SHOP_VIEW_NODE_FACTORY.make_panel("TutorialShopFocusFrame", _tutorial_overlay)
	_tutorial_focus_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_tutorial_focus_frame.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(1.0, 0.82, 0.12, 0.08), Color(1.0, 0.85, 0.18, 1.0), 5, 8, Vector4(8, 6, 8, 6)))
	_tutorial_prompt_panel = SHOP_VIEW_NODE_FACTORY.make_panel("TutorialShopPrompt", _tutorial_overlay)
	_tutorial_prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_tutorial_prompt_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.045, 0.065, 0.085, 0.96), Color(1.0, 0.72, 0.16, 0.98), 3, 8, Vector4(12, 10, 12, 10)))
	_tutorial_prompt_label = SHOP_VIEW_NODE_FACTORY.make_label("TutorialShopPromptLabel", _tutorial_prompt_panel, "", 30, Color(1.0, 0.92, 0.68, 1.0), HORIZONTAL_ALIGNMENT_CENTER, true)
	_tutorial_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


func _render_tutorial_overlay() -> void:
	if _tutorial_overlay == null:
		return
	_tutorial_overlay.visible = _current_tutorial_shop_phase != ""
	if not _tutorial_overlay.visible:
		return
	var message := ""
	match _current_tutorial_shop_phase:
		"buy_shortsword":
			message = "Buy Iron Shortsword.\nEquipment makes future fights easier."
		"reroll":
			message = "Reroll changes shop stock.\nTap Reroll now."
		"continue":
			message = "Continue leaves the shop.\nTap Continue to enter the next fight."
		_:
			message = ""
	_tutorial_prompt_label.text = message


func _tutorial_focus_rect() -> Rect2:
	match _current_tutorial_shop_phase:
		"buy_shortsword":
			if _offer_cards.size() > 0:
				return _control_rect_in_overlay(_offer_cards[0]).grow(10.0)
		"reroll":
			return _control_rect_in_overlay(_reroll_button).grow(10.0)
		"continue":
			return _control_rect_in_overlay(_continue_button).grow(10.0)
	return Rect2(Vector2(-9999, -9999), Vector2(1, 1))


func _control_rect_in_overlay(control: Control) -> Rect2:
	if control == null or _tutorial_overlay == null:
		return Rect2(Vector2(-9999, -9999), Vector2(1, 1))
	var inverse := _tutorial_overlay.get_global_transform().affine_inverse()
	var rect := control.get_global_rect()
	return Rect2(inverse * rect.position, rect.size)


func handle_global_input(event: InputEvent) -> bool:
	if _shop_help_overlay != null and _shop_help_overlay.visible:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK:
				_hide_shop_help_modal()
				return true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return _player_loadout_hud.handle_global_click((event as InputEventMouseButton).position)
	if event is InputEventScreenTouch and event.pressed:
		return _player_loadout_hud.handle_global_click((event as InputEventScreenTouch).position)
	return false


func clear_inventory_focus() -> void:
	_player_loadout_hud.set_selected_equipment_slot(-1)
	_player_loadout_hud.set_selected_consumable_slot(-1)
	_player_loadout_hud.hide_slot_detail_popover()


func _emit_relic_pressed() -> void:
	emit_signal("relic_pressed")


func _emit_reroll_pressed() -> void:
	emit_signal("reroll_pressed")


func _emit_sell_pressed() -> void:
	emit_signal("sell_pressed")


func _emit_continue_pressed() -> void:
	emit_signal("continue_pressed")


func _emit_main_menu_pressed() -> void:
	emit_signal("main_menu_pressed")


func _on_help_pressed() -> void:
	_show_shop_help_modal()


func _on_settings_pressed() -> void:
	set_status("Settings is visual-only in this prototype build.", true)


func _show_shop_help_modal() -> void:
	if _shop_help_overlay == null:
		return
	_shop_help_overlay.visible = true


func _hide_shop_help_modal() -> void:
	if _shop_help_overlay == null:
		return
	_shop_help_overlay.visible = false


func _on_shop_help_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_hide_shop_help_modal()
		(_shop_help_overlay as Control).accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		_hide_shop_help_modal()
		(_shop_help_overlay as Control).accept_event()


func _emit_skip_treasure_chest_pressed() -> void:
	emit_signal("skip_treasure_chest_pressed")


func _emit_equipment_slot_selected(index: int) -> void:
	emit_signal("equipment_slot_selected", index)


func _emit_consumable_slot_selected(index: int) -> void:
	emit_signal("consumable_slot_selected", index)


func _emit_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	emit_signal("hud_sell_slot_requested", slot_type, slot_index)


func _lookup_content_definition(content_id: String) -> Dictionary:
	return _player_loadout_hud.lookup_content_definition(content_id)


func _price_text(price: int, sold_out: bool, _affordable: bool, treasure_chest_pending: bool) -> String:
	return SHOP_COPY_FORMATTER.price_text(price, sold_out, _affordable, treasure_chest_pending)


func _shop_card_description(offer: Dictionary) -> String:
	return SHOP_COPY_FORMATTER.shop_card_description(offer)


func _shop_relic_description(relic_offer: Dictionary) -> String:
	return SHOP_COPY_FORMATTER.shop_relic_description(relic_offer)


static func _shop_layout_for_logical_height(logical_height: float) -> Dictionary:
	return SHOP_LAYOUT_METRICS.shop_layout_for_logical_height(logical_height)


static func _shop_player_hud_layout_override_for(layout: Dictionary) -> Dictionary:
	return SHOP_LAYOUT_METRICS.shop_player_hud_layout_override_for(layout)


static func _shop_layout_probe_for_layout(layout: Dictionary) -> Dictionary:
	return SHOP_LAYOUT_METRICS.shop_layout_probe_for_layout(layout)


func apply_layout() -> void:
	var viewport_size := _layout_root.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var scale_factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var logical_height := viewport_size.y / scale_factor
	var logical_size := Vector2(DESIGN_SIZE.x, maxf(DESIGN_SIZE.y, logical_height))
	var scaled_size := logical_size * scale_factor
	_current_shop_layout = _shop_layout_for_logical_height(logical_size.y)
	_current_player_hud_layout_override = _shop_player_hud_layout_override_for(_current_shop_layout)
	_player_loadout_hud.set_player_hud_layout_override(_current_player_hud_layout_override)
	_layout_root.position = Vector2((viewport_size.x - scaled_size.x) * 0.5, 0.0)
	_layout_root.size = logical_size
	_layout_root.scale = Vector2(scale_factor, scale_factor)

	var top_bar_rect: Rect2 = _current_shop_layout.get("top_bar", TOP_BAR_RECT)
	var merchant_rect: Rect2 = _current_shop_layout.get("merchant_stage", MERCHANT_STAGE_RECT)
	var stock_rect: Rect2 = _current_shop_layout.get("stock_panel", STOCK_PANEL_RECT)
	var relic_rect: Rect2 = _current_shop_layout.get("relic_panel", RELIC_PANEL_RECT)
	var action_rect: Rect2 = _current_shop_layout.get("action_row", ACTION_ROW_RECT)
	var offer_grid_rect: Rect2 = _current_shop_layout.get("offer_grid", OFFER_GRID_RECT)
	var merchant_content_rect := Rect2(Vector2.ZERO, merchant_rect.size)
	var merchant_bottom_rail_rect: Rect2 = _current_shop_layout.get("merchant_bottom_rail", SHOP_HEADER_BOTTOM_RAIL_RECT)

	_apply_rect(_top_bar, top_bar_rect)
	_apply_rect(_merchant_stage, merchant_rect)
	_apply_rect(_stock_panel, stock_rect)
	_apply_rect(_relic_card, relic_rect)
	_apply_rect(_action_row, action_rect)

	if _top_bar.has_method("apply_header_layout"):
		_top_bar.call("apply_header_layout")

	_apply_rect(_merchant_backdrop, merchant_content_rect)
	_apply_rect(_merchant_scrim, merchant_content_rect)
	_apply_rect(_merchant_counter, merchant_bottom_rail_rect)
	_apply_rect(_merchant_info_backdrop, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_merchant_header_label, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_speech_card, SHOP_HEADER_SPEECH_RECT)
	_apply_rect(_speech_label, Rect2(Vector2(20, 18), SHOP_HEADER_SPEECH_RECT.size - Vector2(40, 36)))
	_apply_rect(_boss_preview_label, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_summary_label, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_detail_label, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))

	_apply_rect(_stock_title_label, Rect2(Vector2(0, 12), Vector2(stock_rect.size.x, 44)))
	_apply_rect(_offer_grid, offer_grid_rect)
	for index in _offer_cards.size():
		_apply_rect(_offer_cards[index], Rect2(Vector2(float(index) * (OFFER_CARD_SIZE.x + OFFER_CARD_GAP), 0.0), OFFER_CARD_SIZE))

	_apply_rect(_action_hint_label, ACTION_HINT_RECT)
	_apply_rect(_reroll_button, ACTION_REROLL_RECT)
	_apply_rect(_continue_button, ACTION_CONTINUE_RECT)
	_apply_rect(_sell_equipment_button, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_hud_overlay, Rect2(Vector2.ZERO, logical_size))

	_player_loadout_hud.update_player_hud_layout()

	_apply_rect(_treasure_chest_overlay, Rect2(Vector2.ZERO, logical_size))
	_apply_rect(_treasure_chest_modal, Rect2(Vector2(152, 382), Vector2(776, 420)))
	_apply_rect(_treasure_chest_title_label, Rect2(Vector2(0, 30), Vector2(776, 42)))
	_apply_rect(_treasure_chest_hint_label, Rect2(Vector2(80, 82), Vector2(616, 42)))
	for index in _treasure_chest_option_buttons.size():
		_apply_rect(_treasure_chest_option_buttons[index], Rect2(Vector2(46 + float(index) * 238.0, 150), Vector2(208, 236)))
	_apply_rect(_skip_treasure_chest_button, Rect2(Vector2(302, 340), Vector2(172, 54)))
	_apply_rect(_shop_help_overlay, Rect2(Vector2.ZERO, logical_size))
	_apply_rect(_shop_help_modal, SHOP_HELP_MODAL_RECT)
	_apply_rect(_shop_help_title_label, SHOP_HELP_MODAL_TITLE_RECT)
	_apply_rect(_shop_help_body_label, SHOP_HELP_MODAL_BODY_RECT)
	_apply_rect(_shop_help_close_button, SHOP_HELP_MODAL_CLOSE_RECT)
	_apply_tutorial_overlay_layout(logical_size)


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _apply_tutorial_overlay_layout(logical_size: Vector2) -> void:
	if _tutorial_overlay == null or _tutorial_focus_frame == null or _tutorial_prompt_panel == null or _tutorial_prompt_label == null:
		return
	_apply_rect(_tutorial_overlay, Rect2(Vector2.ZERO, logical_size))
	if not _tutorial_overlay.visible:
		return
	var focus_rect := _tutorial_focus_rect()
	_apply_rect(_tutorial_focus_frame, focus_rect)
	var prompt_size := Vector2(720.0, 148.0)
	var prompt_x := clampf(focus_rect.get_center().x - prompt_size.x * 0.5, 28.0, maxf(28.0, logical_size.x - prompt_size.x - 28.0))
	var prompt_y := focus_rect.position.y - prompt_size.y - 18.0
	if prompt_y < 140.0:
		prompt_y = focus_rect.end.y + 18.0
	prompt_y = clampf(prompt_y, 28.0, maxf(28.0, logical_size.y - prompt_size.y - 28.0))
	_apply_rect(_tutorial_prompt_panel, Rect2(Vector2(prompt_x, prompt_y), prompt_size))
	_apply_rect(_tutorial_prompt_label, Rect2(Vector2(22.0, 12.0), prompt_size - Vector2(44.0, 24.0)))


func _shop_player_hud_nodes() -> Dictionary:
	return {
		"section": _player_hud_section,
		"mastery_panel": _elemental_mastery_panel,
		"mastery_title": _elemental_mastery_title,
		"mastery_cards": _elemental_mastery_cards,
		"footer_panel": _build_panel,
		"footer_root": _player_panel_root,
		"root": _player_panel_root,
		"hero_card": _hero_card,
		"hero_card_root": _hero_card_root,
		"hero_portrait": _hero_portrait,
		"hero_level_badge": _hero_level_badge,
		"vitals_panel": _vitals_panel,
		"vitals_frame": _vitals_frame,
		"hp_bar": _hp_bar,
		"hp_label": _hp_label,
		"armor_bar": _armor_bar,
		"armor_label": _armor_label,
		"armor_badge": _armor_badge,
		"armor_badge_label": _armor_badge_label,
		"loadout_frame": _loadout_frame,
		"loadout_root": _loadout_root,
		"equipment_label": _equipment_label,
		"equipment_icons": _equipment_slots_root,
		"consumable_label": _consumable_label,
		"consumable_icons": _consumable_slots_root,
		"relic_label": _relic_label,
		"relic_icons": _relic_icons_root,
		"relic_row": _relic_row,
		"mastery_strip": _mastery_strip,
		"mastery_root": _mastery_root,
		"mastery_label": _mastery_label,
		"mastery_icons": _mastery_icons,
		"stat_chip_row": _stat_chip_row,
		"combat_meta_row": _combat_meta_row,
		"combat_phase_label": _combat_phase_label,
		"turn_summary_label": _turn_summary_label,
	}


func _apply_visual_chrome() -> void:
	for panel in [_stock_panel]:
		(panel as Panel).add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8, Vector4(8, 6, 8, 6)))
	_merchant_stage.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.03, 0.04, 0.05, 0.55), Color(0.70, 0.50, 0.22, 0.98), 2, 8, Vector4(8, 6, 8, 6)))
	_speech_card.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.04, 0.04, 0.04, 0.84), Color(0.74, 0.55, 0.28, 0.98), 2, 8, Vector4(8, 6, 8, 6)))
	_treasure_chest_modal.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.05, 0.06, 0.08, 0.98), GOLD_COLOR, 3, 12, Vector4(8, 6, 8, 6)))
	_treasure_chest_overlay.color = Color(0.0, 0.0, 0.0, 0.44)
	_shop_help_modal.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.05, 0.06, 0.07, 0.98), GOLD_COLOR, 3, 12, Vector4(8, 6, 8, 6)))
	_shop_help_overlay.color = Color(0.0, 0.0, 0.0, 0.54)

	_apply_round_button_chrome(_shop_help_close_button, Color(0.13, 0.09, 0.05, 0.96), GOLD_COLOR, Color(0.23, 0.15, 0.07, 0.98))
	_apply_action_button_chrome(_reroll_button, "reroll")
	_apply_button_chrome(_sell_equipment_button, Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0), Color(0.28, 0.18, 0.09, 0.98))
	_apply_action_button_chrome(_continue_button, "continue")
	_apply_button_chrome(_skip_treasure_chest_button, Color(0.20, 0.07, 0.06, 0.96), Color(0.90, 0.36, 0.30, 1.0), Color(0.30, 0.10, 0.08, 0.98))

	for label in [_stock_title_label, _treasure_chest_title_label, _merchant_header_label]:
		(label as Label).add_theme_color_override("font_color", GOLD_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for label in [_boss_preview_label, _equipment_label, _consumable_label, _relic_label, _elemental_mastery_title, _treasure_chest_hint_label]:
		(label as Label).add_theme_color_override("font_color", MUTED_COLOR)
	_detail_label.add_theme_color_override("font_color", INK_COLOR)
	_action_hint_label.add_theme_color_override("font_color", GOLD_COLOR)
	_shop_help_title_label.add_theme_color_override("font_color", POSITIVE_COLOR)
	_shop_help_body_label.add_theme_color_override("font_color", INK_COLOR)
	for label in [_speech_label, _hp_label]:
		(label as Label).add_theme_color_override("font_color", INK_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for button in [_reroll_button, _sell_equipment_button, _continue_button, _skip_treasure_chest_button, _shop_help_close_button]:
		(button as Button).add_theme_color_override("font_color", INK_COLOR)
		(button as Button).add_theme_font_size_override("font_size", 24)
	_shop_help_close_button.add_theme_font_size_override("font_size", 30)
	_reroll_button.add_theme_color_override("font_color", Color(1.0, 0.90, 0.62, 1.0))
	_continue_button.add_theme_color_override("font_color", Color(0.96, 0.91, 0.80, 1.0))
	_reroll_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	_continue_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	_player_loadout_hud.apply_player_hud_chrome(_shop_player_hud_nodes())


func _shop_player_hud_layout_override() -> Dictionary:
	if _current_player_hud_layout_override.is_empty():
		return _shop_player_hud_layout_override_for(_shop_layout_for_logical_height(DESIGN_SIZE.y))
	return _current_player_hud_layout_override.duplicate(true)


static func shop_layout_probe_snapshot() -> Dictionary:
	return SHOP_LAYOUT_METRICS.shop_layout_probe_snapshot()


func layout_probe_snapshot() -> Dictionary:
	return shop_layout_probe_snapshot()


static func top_header_scene_path() -> String:
	return TOP_HEADER_SCENE.resource_path


static func player_hud_scene_path() -> String:
	return PLAYER_HUD_SCENE.resource_path


func _apply_card_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.18), 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 3, 4, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


func _apply_transparent_button_chrome(button: Button) -> void:
	button.flat = true
	for state in ["normal", "hover", "pressed", "hover_pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())


func _apply_action_button_chrome(button: Button, kind: String) -> void:
	var texture: Texture2D = _visuals.shop_action_button_frame(kind)
	var normal := _action_button_stylebox(texture, Color(1.0, 1.0, 1.0, 1.0))
	var hover := _action_button_stylebox(texture, Color(1.08, 1.06, 0.98, 1.0))
	var pressed := _action_button_stylebox(texture, Color(0.88, 0.86, 0.82, 1.0))
	var disabled := _action_button_stylebox(texture, Color(0.52, 0.52, 0.54, 0.70))
	button.flat = false
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", hover)
	button.add_theme_color_override("font_color", INK_COLOR)
	button.add_theme_color_override("font_hover_color", Color(1.0, 0.96, 0.86, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.88, 0.84, 0.74, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.66, 0.66, 0.68, 0.82))
	button.add_theme_constant_override("outline_size", 3)
	button.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.90))
	button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)


func _action_button_stylebox(texture: Texture2D, modulate_color: Color) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = ACTION_BUTTON_TEXTURE_MARGIN
	style.texture_margin_right = ACTION_BUTTON_TEXTURE_MARGIN
	style.texture_margin_top = 28
	style.texture_margin_bottom = 28
	style.content_margin_left = ACTION_BUTTON_CONTENT_MARGIN
	style.content_margin_right = ACTION_BUTTON_CONTENT_MARGIN
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	style.modulate_color = modulate_color
	return style


func _apply_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.16), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


func _apply_round_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.16), 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.04, 0.05, 0.06, 0.90), Color(0.38, 0.40, 0.46, 0.96), 2, 32, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.70, 0.72, 0.78, 1.0))


func _make_price_badge(parent: Node, rect: Rect2, text: String, disabled: bool) -> void:
	var disabled_affordability := disabled and text.begins_with("$")
	var sold_or_blocked := text == "SOLD OUT" or text == "WAIT CHEST"
	var label_color := GOLD_COLOR
	if disabled:
		if disabled_affordability:
			label_color = RELIC_UNAVAILABLE_PRICE_TEXT_COLOR
		elif sold_or_blocked:
			label_color = GOLD_COLOR if text == "WAIT CHEST" else NEGATIVE_COLOR
		else:
			label_color = MUTED_COLOR
	var badge_texture_value: Texture2D = _visuals.collection_price_badge()
	var badge_rect := rect.grow_individual(2, 1, 2, 1) if not disabled else rect
	var badge_frame := SHOP_VIEW_NODE_FACTORY.make_texture("PriceBadgeFrame", parent)
	badge_frame.position = badge_rect.position
	badge_frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	badge_frame.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	badge_frame.texture = badge_texture_value
	badge_frame.custom_minimum_size = badge_rect.size
	badge_frame.size = badge_rect.size
	badge_frame.modulate = Color(1.08, 1.04, 0.94, 1.0) if not disabled else RELIC_UNAVAILABLE_PRICE_FRAME_MODULATE
	var font_size := RELIC_PRICE_FONT_SIZE if text.begins_with("$") else 20
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(parent, text, badge_rect, label_color, font_size, HORIZONTAL_ALIGNMENT_CENTER)
