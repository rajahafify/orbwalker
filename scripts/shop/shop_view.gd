extends RefCounted
class_name ShopView

signal offer_pressed(index: int)
signal relic_pressed
signal reroll_pressed
signal sell_pressed
signal continue_pressed
signal main_menu_pressed
signal booster_option_pressed(index: int)
signal skip_booster_pressed
signal equipment_slot_selected(index: int)
signal consumable_slot_selected(index: int)
signal hud_sell_slot_requested(slot_type: String, slot_index: int)

const PLAYER_HUD_SCENE := preload("res://scenes/ui/player_hud.tscn")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const DESIGN_SIZE := Vector2(1080, 1920)
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 94))
const MERCHANT_STAGE_RECT := Rect2(Vector2(16, 110), Vector2(1048, 154))
const STOCK_PANEL_RECT := Rect2(Vector2(16, 278), Vector2(1048, 600))
const RELIC_PANEL_RECT := Rect2(Vector2(16, 892), Vector2(1048, 200))
const ACTION_ROW_RECT := Rect2(Vector2(16, 1106), Vector2(1048, 104))
const OFFER_CARD_SIZE := Vector2(336, 492)
const OFFER_CARD_GAP := 4.0
const OFFER_RARITY_RECT := Rect2(Vector2(50, 12), Vector2(236, 30))
const OFFER_NAME_RECT := Rect2(Vector2(18, 48), Vector2(300, 86))
const OFFER_TYPE_RECT := Rect2(Vector2(18, 136), Vector2(300, 30))
const OFFER_ART_FRAME_RECT := Rect2(Vector2(46, 170), Vector2(244, 154))
const OFFER_DESC_RECT := Rect2(Vector2(22, 328), Vector2(292, 58))
const OFFER_STATE_RECT := Rect2(Vector2(22, 392), Vector2(292, 34))
const OFFER_PRICE_RECT := Rect2(Vector2(48, 432), Vector2(240, 48))
const RELIC_TITLE_RECT := Rect2(Vector2(24, 12), Vector2(1000, 34))
const RELIC_ART_FRAME_RECT := Rect2(Vector2(28, 52), Vector2(188, 132))
const RELIC_TIER_RECT := Rect2(Vector2(238, 52), Vector2(480, 30))
const RELIC_NAME_RECT := Rect2(Vector2(238, 80), Vector2(508, 40))
const RELIC_DESC_RECT := Rect2(Vector2(238, 122), Vector2(560, 58))
const RELIC_PRICE_RECT := Rect2(Vector2(806, 56), Vector2(218, 68))
const RELIC_STATE_RECT := Rect2(Vector2(806, 132), Vector2(218, 52))
const GOLD_COLOR := Color(0.92, 0.68, 0.27, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const POSITIVE_COLOR := Color(0.60, 0.88, 0.42, 1.0)
const NEGATIVE_COLOR := Color(1.0, 0.45, 0.38, 1.0)
const RARITY_COLORS := {
	"common": Color(0.82, 0.75, 0.62, 1.0),
	"uncommon": Color(0.47, 0.86, 0.34, 1.0),
	"rare": Color(0.96, 0.40, 0.30, 1.0),
}

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
var _merchant_stage: Panel
var _merchant_backdrop: TextureRect
var _merchant_scrim: ColorRect
var _merchant_counter: ColorRect
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
var _booster_overlay: ColorRect
var _booster_modal: Panel
var _booster_title_label: Label
var _booster_hint_label: Label
var _booster_option_buttons: Array[Button] = []
var _skip_booster_button: Button

var _visuals
var _player_loadout_hud

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
	_hud_overlay = _make_root("HudOverlay", _layout_root)
	_hud_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_hud_overlay.z_index = 50
	_hud_overlay.clip_contents = false

	_top_bar = _make_panel("TopBar", _layout_root)
	_crest_panel = _make_panel("CrestPanel", _top_bar)
	_crest_label = _make_label("CrestLabel", _crest_panel, "M", 28, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_run_progress_label = _make_label("RunProgressLabel", _top_bar, "Dungeon -", 20, MUTED_COLOR)
	_title_label = _make_label("TitleLabel", _top_bar, "Shop", 44, GOLD_COLOR)
	_gold_pill = _make_panel("GoldPill", _top_bar)
	_gold_label = _make_label("GoldLabel", _gold_pill, "G 0", 36, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_main_menu_button = _make_button("MainMenuButton", _top_bar, "Menu")

	_merchant_stage = _make_panel("MerchantStage", _layout_root)
	_merchant_backdrop = _make_texture("MerchantBackdrop", _merchant_stage)
	_merchant_backdrop.texture = _visuals.shop_background()
	_merchant_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_merchant_scrim = _make_color_rect("MerchantScrim", _merchant_stage, Color(0.0, 0.0, 0.0, 0.30))
	_merchant_counter = _make_color_rect("MerchantCounter", _merchant_stage, Color(0.08, 0.045, 0.025, 0.88))
	_speech_card = _make_panel("SpeechCard", _merchant_stage)
	_speech_label = _make_label("SpeechLabel", _speech_card, "Well met. New stock, fresh from the depths.", 23, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_boss_preview_label = _make_label("BossPreviewLabel", _speech_card, "Boss preview: -", 16, MUTED_COLOR)
	_summary_label = _make_label("SummaryLabel", _merchant_stage, "-", 21, POSITIVE_COLOR)
	_detail_label = _make_label("DetailLabel", _merchant_stage, "Select a stock card or relic card to buy.", 19, MUTED_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)

	_stock_panel = _make_panel("StockPanel", _layout_root)
	_stock_title_label = _make_label("StockTitleLabel", _stock_panel, "SHOP STOCK", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_offer_grid = Control.new()
	_offer_grid.name = "OfferGrid"
	_stock_panel.add_child(_offer_grid)
	for index in 3:
		var card := _make_button("OfferCard%d" % (index + 1), _offer_grid, "")
		_offer_cards.append(card)

	_relic_card = _make_button("RelicCard", _layout_root, "")
	_action_row = Control.new()
	_action_row.name = "ActionRow"
	_layout_root.add_child(_action_row)
	_reroll_button = _make_button("RerollButton", _action_row, "Reroll")
	_sell_equipment_button = _make_button("SellEquipmentButton", _action_row, "Sell Selected")
	_continue_button = _make_button("ContinueButton", _action_row, "Continue")

	_bind_shared_player_hud_scene()
	_booster_overlay = ColorRect.new()
	_booster_overlay.name = "BoosterOverlay"
	_booster_overlay.visible = false
	_booster_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_layout_root.add_child(_booster_overlay)
	_booster_modal = _make_panel("BoosterModal", _booster_overlay)
	_booster_modal.mouse_filter = Control.MOUSE_FILTER_PASS as Control.MouseFilter
	_booster_title_label = _make_label("BoosterTitleLabel", _booster_modal, "Choose One Booster Reward", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_booster_hint_label = _make_label("BoosterHintLabel", _booster_modal, "Pick one option now, or press Skip to continue shopping.", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	for index in 3:
		var button := _make_button("BoosterOptionButton%d" % (index + 1), _booster_modal, "")
		_booster_option_buttons.append(button)
	_skip_booster_button = _make_button("SkipBoosterButton", _booster_modal, "Skip")
	_skip_booster_button.visible = false


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
	for index in _booster_option_buttons.size():
		_booster_option_buttons[index].pressed.connect(func(): emit_signal("booster_option_pressed", index))
	_skip_booster_button.pressed.connect(_emit_skip_booster_pressed)
	_player_loadout_hud.equipment_slot_selected.connect(_emit_equipment_slot_selected)
	_player_loadout_hud.consumable_slot_selected.connect(_emit_consumable_slot_selected)
	_player_loadout_hud.sell_slot_requested.connect(_emit_hud_sell_slot_requested)


func render(snapshot: Dictionary) -> void:
	var shop_snapshot: Dictionary = snapshot.get("shop", {})
	var progression_snapshot: Dictionary = snapshot.get("progression", {})
	var pending_options: Array = snapshot.get("pending_booster_options", [])
	var booster_pending := bool(snapshot.get("booster_pending", false))

	_run_progress_label.text = "Dungeon %d-%d Shop" % [int(snapshot.get("dungeon_level", 1)), int(snapshot.get("shop_ordinal", 1))]
	_boss_preview_label.text = "Boss preview: %s" % String(snapshot.get("boss_preview", "-"))
	_gold_label.text = "G  %d" % int(snapshot.get("gold", 0))
	_detail_label.text = "Select a stock card or relic card to buy. Select an equipped or consumable slot before selling."
	set_status(String(snapshot.get("status_message", "")), bool(snapshot.get("status_positive", true)))

	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for index in _offer_cards.size():
		if index >= item_offers.size():
			_render_empty_offer_card(_offer_cards[index])
		else:
			_render_offer_card(_offer_cards[index], Dictionary(item_offers[index]), booster_pending)

	_render_relic_card(Dictionary(shop_snapshot.get("relic_offer", {})), booster_pending)
	_render_action_row(shop_snapshot, booster_pending)
	_render_build_panel(snapshot)
	_render_elemental_mastery_panel(Dictionary(progression_snapshot.get("mastery_levels", {})))
	_render_booster_overlay(pending_options)
	apply_layout()


func _render_offer_card(card: Button, offer: Dictionary, booster_pending: bool) -> void:
	_clear_children(card)
	card.text = ""
	var rarity := String(offer.get("rarity", "common")).to_lower()
	var sold_out := bool(offer.get("sold_out", false))
	var price := int(offer.get("price", 0))
	var affordable := bool(offer.get("affordable", false))
	var disabled := sold_out or booster_pending or not affordable
	card.disabled = disabled
	card.modulate = Color(0.58, 0.58, 0.58, 0.92) if disabled else Color.WHITE
	card.tooltip_text = _offer_tooltip(offer)
	_apply_button_chrome(card, _card_bg_color(rarity, disabled), _rarity_color(rarity), Color(0.18, 0.13, 0.08, 1.0))

	var root := _make_child_root(card)
	_make_dynamic_label(root, rarity.to_upper(), OFFER_RARITY_RECT, _rarity_color(rarity), 21, HORIZONTAL_ALIGNMENT_CENTER)
	_make_dynamic_label(root, String(offer.get("display_name", "Offer")), OFFER_NAME_RECT, _rarity_color(rarity), 31, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_dynamic_label(root, String(offer.get("type", "offer")).replace("_", " ").to_upper(), OFFER_TYPE_RECT, MUTED_COLOR, 18, HORIZONTAL_ALIGNMENT_CENTER)

	var art_frame := _make_dynamic_panel(root, OFFER_ART_FRAME_RECT, UI_UTILS.panel_style(Color(0.04, 0.04, 0.05, 0.94), _rarity_color(rarity), 2, 8, Vector4(8, 6, 8, 6)))
	var icon := _make_texture("OfferIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(offer.get("icon_key", "")))
	icon.position = Vector2(22, 14)
	icon.size = Vector2(200, 118)
	_make_dynamic_label(root, String(offer.get("description", "No details available.")), OFFER_DESC_RECT, INK_COLOR, 18, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_price_badge(root, OFFER_PRICE_RECT, _price_text(price, sold_out, affordable, booster_pending), disabled)
	var state_text := ""
	var state_color := NEGATIVE_COLOR
	if sold_out:
		state_text = "SOLD OUT"
		state_color = NEGATIVE_COLOR
	elif booster_pending:
		state_text = "BOOSTER FIRST"
		state_color = GOLD_COLOR
	elif not affordable:
		state_text = "NOT ENOUGH GOLD"
		state_color = NEGATIVE_COLOR
	if state_text != "":
		_make_state_badge(root, OFFER_STATE_RECT, state_text, state_color)


func _render_empty_offer_card(card: Button) -> void:
	_clear_children(card)
	card.text = ""
	card.disabled = true
	card.modulate = Color(0.65, 0.65, 0.70, 0.75)
	_apply_button_chrome(card, Color(0.05, 0.06, 0.08, 0.90), Color(0.24, 0.27, 0.34, 0.95), Color(0.05, 0.06, 0.08, 0.98))
	var root := _make_child_root(card)
	_make_dynamic_label(root, "EMPTY", Rect2(Vector2(20, 190), Vector2(280, 50)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
	_make_dynamic_label(root, "No offer in this slot.", Rect2(Vector2(28, 250), Vector2(264, 46)), MUTED_COLOR, 18, HORIZONTAL_ALIGNMENT_CENTER, true)


func _render_relic_card(relic_offer: Dictionary, booster_pending: bool) -> void:
	_clear_children(_relic_card)
	_relic_card.text = ""
	if relic_offer.is_empty():
		_relic_card.disabled = true
		_relic_card.modulate = Color(0.65, 0.65, 0.70, 0.75)
		_apply_button_chrome(_relic_card, Color(0.05, 0.06, 0.08, 0.90), Color(0.24, 0.27, 0.34, 0.95), Color(0.05, 0.06, 0.08, 0.98))
		var empty_root := _make_child_root(_relic_card)
		_make_dynamic_label(empty_root, "DUNGEON RELIC", Rect2(Vector2(24, 24), Vector2(1000, 30)), GOLD_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
		_make_dynamic_label(empty_root, "Relic offer unavailable.", Rect2(Vector2(24, 86), Vector2(1000, 42)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
		return

	var rarity := String(relic_offer.get("rarity", "rare")).to_lower()
	var price := int(relic_offer.get("price", 0))
	var sold_out := bool(relic_offer.get("sold_out", false))
	var affordable := bool(relic_offer.get("affordable", false))
	var disabled := sold_out or booster_pending or not affordable
	_relic_card.disabled = disabled
	_relic_card.modulate = Color(0.58, 0.58, 0.58, 0.92) if disabled else Color.WHITE
	_relic_card.tooltip_text = _offer_tooltip(relic_offer)
	_apply_button_chrome(_relic_card, Color(0.13, 0.06, 0.15, 0.94), _rarity_color(rarity), Color(0.19, 0.08, 0.20, 0.98))

	var root := _make_child_root(_relic_card)
	_make_dynamic_label(root, "DUNGEON RELIC", RELIC_TITLE_RECT, GOLD_COLOR, 28, HORIZONTAL_ALIGNMENT_CENTER)
	var art_frame := _make_dynamic_panel(root, RELIC_ART_FRAME_RECT, UI_UTILS.panel_style(Color(0.05, 0.04, 0.08, 0.92), _rarity_color(rarity), 2, 8, Vector4(8, 6, 8, 6)))
	var icon := _make_texture("RelicIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(relic_offer.get("icon_key", "")))
	icon.position = Vector2(20, 14)
	icon.size = Vector2(148, 104)
	_make_dynamic_label(root, "%s RELIC" % rarity.to_upper(), RELIC_TIER_RECT, _rarity_color(rarity), 20)
	_make_dynamic_label(root, String(relic_offer.get("display_name", "Relic")), RELIC_NAME_RECT, _rarity_color(rarity), 30, HORIZONTAL_ALIGNMENT_LEFT, true)
	_make_dynamic_label(root, String(relic_offer.get("description", "No details available.")), RELIC_DESC_RECT, INK_COLOR, 20, HORIZONTAL_ALIGNMENT_LEFT, true)
	_make_price_badge(root, RELIC_PRICE_RECT, _price_text(price, sold_out, affordable, booster_pending), disabled)
	if sold_out:
		_make_state_badge(root, RELIC_STATE_RECT, "SOLD OUT", NEGATIVE_COLOR, 18)
	elif booster_pending:
		_make_state_badge(root, RELIC_STATE_RECT, "BOOSTER FIRST", GOLD_COLOR, 18)
	elif not affordable:
		_make_state_badge(root, RELIC_STATE_RECT, "NOT ENOUGH GOLD", NEGATIVE_COLOR, 18)


func _render_action_row(shop_snapshot: Dictionary, booster_pending: bool) -> void:
	var active := bool(shop_snapshot.get("active", false))
	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.text = "REROLL\nCost %d G" % reroll_cost
	_reroll_button.disabled = booster_pending or not active or not bool(shop_snapshot.get("reroll_enabled", false))
	_sell_equipment_button.visible = false
	_sell_equipment_button.disabled = true
	_continue_button.text = "CONTINUE\nLeave Shop"
	_continue_button.disabled = booster_pending

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


func _render_booster_overlay(pending_options: Array) -> void:
	var overlay_visible := not pending_options.is_empty()
	_booster_overlay.visible = overlay_visible
	_booster_modal.visible = overlay_visible
	if not overlay_visible:
		_skip_booster_button.visible = false
		return
	_booster_title_label.text = "Choose One Booster Reward"
	_booster_hint_label.text = "Pick one option now, or press Skip to continue shopping."
	for button in _booster_option_buttons:
		button.visible = true
	for index in _booster_option_buttons.size():
		var button := _booster_option_buttons[index]
		_clear_children(button)
		button.text = ""
		if index >= pending_options.size():
			button.visible = false
			button.disabled = true
			continue
		button.visible = true
		button.disabled = false
		var option: Dictionary = pending_options[index]
		_apply_button_chrome(button, Color(0.10, 0.08, 0.13, 0.98), GOLD_COLOR, Color(0.18, 0.13, 0.08, 1.0))
		var root := _make_child_root(button)
		_make_dynamic_label(root, String(option.get("type", "option")).replace("_", " ").to_upper(), Rect2(Vector2(14, 8), Vector2(180, 22)), MUTED_COLOR, 14, HORIZONTAL_ALIGNMENT_CENTER)
		_make_dynamic_label(root, String(option.get("display_name", "Option")), Rect2(Vector2(14, 36), Vector2(180, 54)), INK_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER, true)
		var content := _lookup_content_definition(String(option.get("content_id", "")))
		var icon := _make_texture("BoosterOptionIcon", root)
		icon.texture = _visuals.icon_for_key(String(content.get("icon_key", "")))
		icon.position = Vector2(58, 98)
		icon.size = Vector2(92, 86)
		_make_dynamic_label(root, "PICK", Rect2(Vector2(22, 196), Vector2(164, 42)), GOLD_COLOR, 22, HORIZONTAL_ALIGNMENT_CENTER)
	_skip_booster_button.visible = true
	_skip_booster_button.disabled = false



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


func handle_global_input(event: InputEvent) -> bool:
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


func _emit_skip_booster_pressed() -> void:
	emit_signal("skip_booster_pressed")


func _emit_equipment_slot_selected(index: int) -> void:
	emit_signal("equipment_slot_selected", index)


func _emit_consumable_slot_selected(index: int) -> void:
	emit_signal("consumable_slot_selected", index)


func _emit_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	emit_signal("hud_sell_slot_requested", slot_type, slot_index)


func _lookup_content_definition(content_id: String) -> Dictionary:
	return _player_loadout_hud.lookup_content_definition(content_id)


func _offer_tooltip(offer: Dictionary) -> String:
	return "%s\n%s\nPrice: %d gold" % [String(offer.get("display_name", "Offer")), String(offer.get("description", "")), int(offer.get("price", 0))]


func _price_text(price: int, sold_out: bool, affordable: bool, booster_pending: bool) -> String:
	if sold_out:
		return "SOLD OUT"
	if booster_pending:
		return "WAIT BOOSTER"
	if not affordable:
		return "NEED %dG" % price
	return "PRICE %dG" % price


func _is_full_slot_reason(reason: String) -> bool:
	return reason == "equipment_slots_full" or reason == "consumable_slots_full"


func _rarity_color(rarity: String) -> Color:
	return RARITY_COLORS.get(rarity.to_lower(), RARITY_COLORS["common"])


func _card_bg_color(rarity: String, disabled: bool) -> Color:
	if disabled:
		return Color(0.06, 0.06, 0.07, 0.94)
	match rarity.to_lower():
		"rare":
			return Color(0.15, 0.06, 0.04, 0.96)
		"uncommon":
			return Color(0.05, 0.13, 0.08, 0.96)
		_:
			return Color(0.13, 0.09, 0.06, 0.96)


func apply_layout() -> void:
	var viewport_size := _layout_root.get_viewport_rect().size
	if viewport_size.y <= 0.0:
		return
	var scale_factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var scaled_size := DESIGN_SIZE * scale_factor
	_layout_root.position = (viewport_size - scaled_size) * 0.5
	_layout_root.size = DESIGN_SIZE
	_layout_root.scale = Vector2(scale_factor, scale_factor)

	_apply_rect(_top_bar, TOP_BAR_RECT)
	_apply_rect(_merchant_stage, MERCHANT_STAGE_RECT)
	_apply_rect(_stock_panel, STOCK_PANEL_RECT)
	_apply_rect(_relic_card, RELIC_PANEL_RECT)
	_apply_rect(_action_row, ACTION_ROW_RECT)

	_apply_rect(_crest_panel, Rect2(Vector2(18, 15), Vector2(58, 58)))
	_apply_rect(_crest_label, Rect2(Vector2.ZERO, Vector2(58, 58)))
	_apply_rect(_run_progress_label, Rect2(Vector2(100, 12), Vector2(560, 28)))
	_apply_rect(_title_label, Rect2(Vector2(100, 36), Vector2(560, 46)))
	_apply_rect(_gold_pill, Rect2(Vector2(714, 13), Vector2(202, 62)))
	_apply_rect(_gold_label, Rect2(Vector2.ZERO, Vector2(202, 62)))
	_apply_rect(_main_menu_button, Rect2(Vector2(928, 15), Vector2(96, 58)))

	_apply_rect(_merchant_backdrop, Rect2(Vector2.ZERO, MERCHANT_STAGE_RECT.size))
	_apply_rect(_merchant_scrim, Rect2(Vector2.ZERO, MERCHANT_STAGE_RECT.size))
	_apply_rect(_merchant_counter, Rect2(Vector2(0, 116), Vector2(MERCHANT_STAGE_RECT.size.x, 38)))
	_apply_rect(_speech_card, Rect2(Vector2(24, 16), Vector2(420, 108)))
	_apply_rect(_speech_label, Rect2(Vector2(18, 10), Vector2(384, 62)))
	_apply_rect(_boss_preview_label, Rect2(Vector2(18, 76), Vector2(384, 24)))
	_apply_rect(_summary_label, Rect2(Vector2(462, 24), Vector2(562, 38)))
	_apply_rect(_detail_label, Rect2(Vector2(462, 66), Vector2(562, 56)))

	_apply_rect(_stock_title_label, Rect2(Vector2(0, 16), Vector2(STOCK_PANEL_RECT.size.x, 46)))
	_apply_rect(_offer_grid, Rect2(Vector2(14, 82), Vector2(STOCK_PANEL_RECT.size.x - 28.0, OFFER_CARD_SIZE.y)))
	for index in _offer_cards.size():
		_apply_rect(_offer_cards[index], Rect2(Vector2(float(index) * (OFFER_CARD_SIZE.x + OFFER_CARD_GAP), 0.0), OFFER_CARD_SIZE))

	_apply_rect(_reroll_button, Rect2(Vector2.ZERO, Vector2(516, ACTION_ROW_RECT.size.y)))
	_apply_rect(_continue_button, Rect2(Vector2(532, 0), Vector2(516, ACTION_ROW_RECT.size.y)))
	_apply_rect(_sell_equipment_button, Rect2(Vector2(-9999, -9999), Vector2(1, 1)))
	_apply_rect(_hud_overlay, Rect2(Vector2.ZERO, DESIGN_SIZE))

	_player_loadout_hud.update_player_hud_layout()

	_apply_rect(_booster_overlay, Rect2(Vector2.ZERO, Vector2(DESIGN_SIZE.x, 1080.0)))
	_apply_rect(_booster_modal, Rect2(Vector2(152, 382), Vector2(776, 420)))
	_apply_rect(_booster_title_label, Rect2(Vector2(0, 30), Vector2(776, 42)))
	_apply_rect(_booster_hint_label, Rect2(Vector2(80, 82), Vector2(616, 42)))
	for index in _booster_option_buttons.size():
		_apply_rect(_booster_option_buttons[index], Rect2(Vector2(46 + float(index) * 238.0, 150), Vector2(208, 236)))
	_apply_rect(_skip_booster_button, Rect2(Vector2(302, 340), Vector2(172, 54)))


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


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
	for panel in [_top_bar, _stock_panel]:
		(panel as Panel).add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8, Vector4(8, 6, 8, 6)))
	_merchant_stage.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.03, 0.04, 0.05, 0.60), Color(0.66, 0.48, 0.21, 0.98), 2, 8, Vector4(8, 6, 8, 6)))
	_speech_card.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.04, 0.04, 0.04, 0.84), Color(0.74, 0.55, 0.28, 0.98), 2, 8, Vector4(8, 6, 8, 6)))
	_crest_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.30, 0.18, 0.06, 0.98), GOLD_COLOR, 2, 32, Vector4(8, 6, 8, 6)))
	_gold_pill.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.22, 0.13, 0.04, 0.96), GOLD_COLOR, 2, 8, Vector4(8, 6, 8, 6)))
	_booster_modal.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.05, 0.06, 0.08, 0.98), GOLD_COLOR, 3, 12, Vector4(8, 6, 8, 6)))
	_booster_overlay.color = Color(0.0, 0.0, 0.0, 0.44)

	_apply_button_chrome(_main_menu_button, Color(0.13, 0.09, 0.05, 0.95), GOLD_COLOR, Color(0.23, 0.15, 0.07, 0.98))
	_apply_button_chrome(_reroll_button, Color(0.05, 0.17, 0.27, 0.96), Color(0.31, 0.62, 0.84, 1.0), Color(0.08, 0.24, 0.36, 0.98))
	_apply_button_chrome(_sell_equipment_button, Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0), Color(0.28, 0.18, 0.09, 0.98))
	_apply_button_chrome(_continue_button, Color(0.12, 0.30, 0.06, 0.96), Color(0.54, 0.78, 0.24, 1.0), Color(0.18, 0.40, 0.08, 0.98))
	_apply_button_chrome(_skip_booster_button, Color(0.20, 0.07, 0.06, 0.96), Color(0.90, 0.36, 0.30, 1.0), Color(0.30, 0.10, 0.08, 0.98))

	for label in [_title_label, _gold_label, _stock_title_label, _booster_title_label]:
		(label as Label).add_theme_color_override("font_color", GOLD_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for label in [_run_progress_label, _boss_preview_label, _detail_label, _equipment_label, _consumable_label, _relic_label, _elemental_mastery_title, _booster_hint_label]:
		(label as Label).add_theme_color_override("font_color", MUTED_COLOR)
	for label in [_speech_label, _hp_label, _crest_label]:
		(label as Label).add_theme_color_override("font_color", INK_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for button in [_main_menu_button, _reroll_button, _sell_equipment_button, _continue_button, _skip_booster_button]:
		(button as Button).add_theme_color_override("font_color", INK_COLOR)
		(button as Button).add_theme_font_size_override("font_size", 24)
	_reroll_button.add_theme_font_size_override("font_size", 27)
	_continue_button.add_theme_font_size_override("font_size", 27)
	_player_loadout_hud.apply_player_hud_chrome(_shop_player_hud_nodes())


func _shop_player_hud_layout_override() -> Dictionary:
	return PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset()


static func shop_layout_probe_snapshot() -> Dictionary:
	var hud_layout := PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset()
	var hud_section := Rect2(hud_layout.get("section", Rect2()))
	var hud_footer := Rect2(hud_layout.get("footer_panel", Rect2()))
	var action_bottom := ACTION_ROW_RECT.position.y + ACTION_ROW_RECT.size.y
	var hud_bottom := hud_section.position.y + hud_section.size.y
	var stock_total_width := OFFER_CARD_SIZE.x * 3.0 + OFFER_CARD_GAP * 2.0
	var stock_content_width := STOCK_PANEL_RECT.size.x - 28.0
	var stock_bottom := STOCK_PANEL_RECT.position.y + STOCK_PANEL_RECT.size.y
	var relic_bottom := RELIC_PANEL_RECT.position.y + RELIC_PANEL_RECT.size.y
	var hud_slot_popover_probe := PLAYER_LOADOUT_HUD_SCRIPT.slot_detail_popover_probe_snapshot()
	return {
		"design_size": DESIGN_SIZE,
		"top_bar": TOP_BAR_RECT,
		"merchant_stage": MERCHANT_STAGE_RECT,
		"stock_panel": STOCK_PANEL_RECT,
		"relic_panel": RELIC_PANEL_RECT,
		"action_row": ACTION_ROW_RECT,
		"stock_card_size": OFFER_CARD_SIZE,
		"stock_card_gap": OFFER_CARD_GAP,
		"stock_total_width": stock_total_width,
		"stock_content_width": stock_content_width,
		"stock_fits": stock_total_width <= stock_content_width,
		"stock_relic_gap": int(RELIC_PANEL_RECT.position.y - stock_bottom),
		"relic_action_gap": int(ACTION_ROW_RECT.position.y - relic_bottom),
		"offer_card_readability": {
			"card_size": OFFER_CARD_SIZE,
			"rarity_rect": OFFER_RARITY_RECT,
			"name_rect": OFFER_NAME_RECT,
			"type_rect": OFFER_TYPE_RECT,
			"description_rect": OFFER_DESC_RECT,
			"state_rect": OFFER_STATE_RECT,
			"price_rect": OFFER_PRICE_RECT,
		},
		"relic_card_readability": {
			"panel_size": RELIC_PANEL_RECT.size,
			"title_rect": RELIC_TITLE_RECT,
			"name_rect": RELIC_NAME_RECT,
			"description_rect": RELIC_DESC_RECT,
			"state_rect": RELIC_STATE_RECT,
			"price_rect": RELIC_PRICE_RECT,
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
		"bottom_gap_before_hud": maxi(0, int(hud_section.position.y - action_bottom)),
	}


func layout_probe_snapshot() -> Dictionary:
	return shop_layout_probe_snapshot()


func _apply_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(bg_color, border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(hover_color, border_color.lightened(0.16), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(hover_color.darkened(0.10), border_color, 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_stylebox_override("disabled", UI_UTILS.panel_style(Color(0.05, 0.06, 0.07, 0.88), Color(0.24, 0.25, 0.29, 0.92), 2, 8, Vector4(8, 6, 8, 6)))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.56, 0.60, 1.0))


func _make_panel(node_name: String, parent: Node) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(panel)
	return panel


func _make_button(node_name: String, parent: Node, button_text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = button_text
	button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	parent.add_child(button)
	return button


func _make_root(node_name: String, parent: Node) -> Control:
	var control := Control.new()
	control.name = node_name
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(control)
	return control


func _make_texture(node_name: String, parent: Node) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = node_name
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(texture)
	return texture


func _make_color_rect(node_name: String, parent: Node, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(rect)
	return rect


func _make_label(node_name: String, parent: Node, text: String, font_size: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	label.name = node_name
	_configure_label(label, text, font_size, color, align, enable_wrap)
	parent.add_child(label)
	return label


func _make_child_root(parent: Control) -> Control:
	var root := Control.new()
	root.name = "CardRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.position = Vector2.ZERO
	root.size = parent.size
	parent.add_child(root)
	return root


func _make_dynamic_panel(parent: Node, rect: Rect2, style: StyleBox) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _make_dynamic_label(parent: Node, text: String, rect: Rect2, color: Color, font_size: int, align: int = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	_configure_label(label, text, font_size, color, align, enable_wrap)
	label.position = rect.position
	label.size = rect.size
	parent.add_child(label)
	return label


func _configure_label(label: Label, text: String, font_size: int, color: Color, align: int, enable_wrap: bool) -> void:
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = align as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART if enable_wrap else TextServer.AUTOWRAP_OFF
	) as TextServer.AutowrapMode
	label.clip_text = true
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))


func _make_price_badge(parent: Node, rect: Rect2, text: String, disabled: bool) -> void:
	var disabled_affordability := text.begins_with("NEED")
	var sold_or_blocked := text == "SOLD OUT" or text == "WAIT BOOSTER"
	var bg := Color(0.32, 0.18, 0.04, 0.96)
	var border := GOLD_COLOR
	var label_color := GOLD_COLOR
	if disabled:
		if disabled_affordability:
			bg = Color(0.20, 0.07, 0.06, 0.96)
			border = NEGATIVE_COLOR
			label_color = NEGATIVE_COLOR
		elif sold_or_blocked:
			bg = Color(0.11, 0.08, 0.05, 0.96)
			border = GOLD_COLOR if text == "WAIT BOOSTER" else NEGATIVE_COLOR
			label_color = GOLD_COLOR if text == "WAIT BOOSTER" else NEGATIVE_COLOR
		else:
			bg = Color(0.07, 0.07, 0.08, 0.94)
			border = Color(0.28, 0.28, 0.30, 0.92)
			label_color = MUTED_COLOR
	var badge := _make_dynamic_panel(parent, rect, UI_UTILS.panel_style(bg, border, 2, 6, Vector4(8, 6, 8, 6)))
	_make_dynamic_label(badge, text, Rect2(Vector2.ZERO, rect.size), label_color, 25, HORIZONTAL_ALIGNMENT_CENTER)


func _make_state_badge(parent: Node, rect: Rect2, text: String, color: Color, font_size: int = 17) -> void:
	var bg := Color(0.09, 0.06, 0.04, 0.94)
	var border := color.darkened(0.18)
	if color == NEGATIVE_COLOR:
		bg = Color(0.18, 0.05, 0.05, 0.96)
	elif color == GOLD_COLOR:
		bg = Color(0.24, 0.15, 0.04, 0.96)
	var badge := _make_dynamic_panel(parent, rect, UI_UTILS.panel_style(bg, border, 2, 6, Vector4(8, 6, 8, 6)))
	_make_dynamic_label(badge, text, Rect2(Vector2.ZERO, rect.size), color, font_size, HORIZONTAL_ALIGNMENT_CENTER)


func _clear_children(node: Node) -> void:
	UI_UTILS.clear_children(node)
