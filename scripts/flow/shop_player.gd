extends Control

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")

const DESIGN_SIZE := Vector2(1080, 1920)
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 86))
const MERCHANT_STAGE_RECT := Rect2(Vector2(16, 108), Vector2(1048, 330))
const STOCK_PANEL_RECT := Rect2(Vector2(16, 452), Vector2(1048, 552))
const RELIC_PANEL_RECT := Rect2(Vector2(16, 1018), Vector2(1048, 208))
const ACTION_ROW_RECT := Rect2(Vector2(16, 1240), Vector2(1048, 112))
const PLAYER_HUD_PANEL_RECT := Rect2(Vector2(0, 1366), Vector2(1080, 468))
const PLAYER_RELIC_LABEL_RECT := Rect2(Vector2(52, 206), Vector2(120, 24))
const PLAYER_RELIC_ICONS_RECT := Rect2(Vector2(176, 190), Vector2(560, 58))
const OFFER_CARD_SIZE := Vector2(320, 468)
const OFFER_CARD_GAP := 18.0
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

@onready var _background: TextureRect = %Background
@onready var _backdrop_tint: ColorRect = %BackdropTint
@onready var _layout_root: Control = %ShopLayoutRoot

var _top_bar: Panel
var _crest_panel: Panel
var _crest_label: Label
var _title_label: Label
var _run_progress_label: Label
var _gold_pill: Panel
var _gold_label: Label
var _main_menu_button: Button
var _merchant_stage: Panel
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
var _build_panel: Panel
var _player_panel_root: Control
var _hero_card: Panel
var _hero_card_root: Control
var _hero_portrait: TextureRect
var _vitals_panel: Control
var _vitals_frame: Panel
var _hp_bar: ProgressBar
var _hp_label: Label
var _build_gold_label: Label
var _gold_badge: Panel
var _equipment_label: Label
var _equipment_slots_root: Control
var _consumable_label: Label
var _consumable_slots_root: Control
var _relic_label: Label
var _relic_slots_root: Control
var _loadout_frame: Panel
var _loadout_root: Control
var _mastery_strip: Panel
var _mastery_root: Control
var _mastery_title_label: Label
var _mastery_cells_root: Control
var _booster_overlay: ColorRect
var _booster_modal: Panel
var _booster_title_label: Label
var _booster_hint_label: Label
var _booster_option_buttons: Array[Button] = []

var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
var _selected_equipment_slot := -1


func _ready() -> void:
	_background.texture = _visuals.shop_background()
	_backdrop_tint.color = Color(0.0, 0.0, 0.0, 0.33)
	_create_ui()
	_apply_visual_chrome()
	_connect_signals()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_shop_layout()

	if not RunState.run_active:
		_title_label.text = "Shop"
		_set_status("No active run. Returning to main menu.", false)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		return
	if not RunState.is_current_step_shop():
		get_tree().call_deferred("change_scene_to_file", RunState.next_scene_path())
		return

	var open_result: Dictionary = RunState.open_shop_for_current_level()
	_set_status("Shop opened. Buy, reroll, sell, or continue." if bool(open_result.get("ok", false)) else "Failed to open shop: %s" % String(open_result.get("reason", "unknown")), bool(open_result.get("ok", false)))
	_refresh_ui()


func _create_ui() -> void:
	_layout_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_bar = _make_panel("TopBar", _layout_root)
	_crest_panel = _make_panel("CrestPanel", _top_bar)
	_crest_label = _make_label("CrestLabel", _crest_panel, "M", 28, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_run_progress_label = _make_label("RunProgressLabel", _top_bar, "Dungeon -", 17, MUTED_COLOR)
	_title_label = _make_label("TitleLabel", _top_bar, "Shop", 38, GOLD_COLOR)
	_gold_pill = _make_panel("GoldPill", _top_bar)
	_gold_label = _make_label("GoldLabel", _gold_pill, "G 0", 32, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_main_menu_button = _make_button("MainMenuButton", _top_bar, "Menu")

	_merchant_stage = _make_panel("MerchantStage", _layout_root)
	_speech_card = _make_panel("SpeechCard", _merchant_stage)
	_speech_label = _make_label("SpeechLabel", _speech_card, "Well met. New stock, fresh from the depths.", 26, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true)
	_boss_preview_label = _make_label("BossPreviewLabel", _speech_card, "Boss preview: -", 15, MUTED_COLOR)
	_summary_label = _make_label("SummaryLabel", _merchant_stage, "-", 22, POSITIVE_COLOR)
	_detail_label = _make_label("DetailLabel", _merchant_stage, "Select a stock card or relic card to buy.", 18, MUTED_COLOR)

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

	_build_panel = _make_panel("PlayerPanel", _layout_root)
	_player_panel_root = _make_root("PlayerPanelRoot", _build_panel)
	_hero_card = _make_panel("HeroCard", _player_panel_root)
	_hero_card_root = _make_root("HeroCardRoot", _hero_card)
	_hero_portrait = _make_texture("PlayerPortrait", _hero_card_root)
	_vitals_panel = _make_root("VitalsPanel", _player_panel_root)
	_vitals_frame = _make_panel("VitalsFrame", _vitals_panel)
	_hp_bar = ProgressBar.new()
	_hp_bar.name = "PlayerHpBar"
	_hp_bar.show_percentage = false
	_vitals_panel.add_child(_hp_bar)
	_hp_label = _make_label("PlayerHpLabel", _vitals_panel, "HP -", 24, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_gold_badge = _make_panel("GoldBadge", _vitals_panel)
	_build_gold_label = _make_label("GoldBadgeLabel", _gold_badge, "GOLD 0", 18, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_loadout_frame = _make_panel("LoadoutFrame", _player_panel_root)
	_loadout_root = _make_root("LoadoutRoot", _loadout_frame)
	_equipment_label = _make_label("EquipmentLabel", _loadout_root, "EQUIPMENT", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_equipment_slots_root = _make_root("EquipmentIcons", _loadout_root)
	_consumable_label = _make_label("ConsumableLabel", _loadout_root, "CONSUMABLES", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_consumable_slots_root = _make_root("ConsumableIcons", _loadout_root)
	_relic_label = _make_label("RelicLabel", _player_panel_root, "RELICS", 18, MUTED_COLOR)
	_relic_slots_root = _make_root("RelicIcons", _player_panel_root)

	_mastery_strip = _make_panel("MasteryStrip", _player_panel_root)
	_mastery_root = _make_root("MasteryRoot", _mastery_strip)
	_mastery_title_label = _make_label("MasteryLabel", _mastery_root, "MASTERY", 24, GOLD_COLOR)
	_mastery_cells_root = _make_root("MasteryIcons", _mastery_root)

	_booster_overlay = ColorRect.new()
	_booster_overlay.name = "BoosterOverlay"
	_booster_overlay.visible = false
	_booster_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_layout_root.add_child(_booster_overlay)
	_booster_modal = _make_panel("BoosterModal", _booster_overlay)
	_booster_title_label = _make_label("BoosterTitleLabel", _booster_modal, "Choose One Booster Reward", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_booster_hint_label = _make_label("BoosterHintLabel", _booster_modal, "Pick one option to finish opening the booster.", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	for index in 3:
		var button := _make_button("BoosterOptionButton%d" % (index + 1), _booster_modal, "")
		_booster_option_buttons.append(button)

func _connect_signals() -> void:
	for index in _offer_cards.size():
		_offer_cards[index].pressed.connect(_buy_offer_at.bind(index))
	_relic_card.pressed.connect(_buy_relic_offer)
	_reroll_button.pressed.connect(_on_reroll_button_pressed)
	_sell_equipment_button.pressed.connect(_on_sell_equipment_button_pressed)
	_continue_button.pressed.connect(_on_continue_button_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	for index in _booster_option_buttons.size():
		_booster_option_buttons[index].pressed.connect(_choose_booster_option.bind(index))
	_player_loadout_hud.equipment_slot_selected.connect(_select_equipment_slot)


func _refresh_ui() -> void:
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var pending_options: Array = shop_snapshot.get("pending_booster_options", [])
	var booster_pending := not pending_options.is_empty()

	_run_progress_label.text = "Dungeon %d / %d | %s" % [RunState.dungeon_level, RunState.MAX_DUNGEON_LEVELS, RunState.level_sequence_label()]
	_boss_preview_label.text = "Boss preview: %s" % RunState.current_level_boss_name()
	_gold_label.text = "G  %d" % RunState.run_gold
	_build_gold_label.text = "Gold %d" % RunState.run_gold
	_detail_label.text = "Select a stock card or relic card to buy. Select an equipment slot before selling."

	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for index in _offer_cards.size():
		if index >= item_offers.size():
			_render_empty_offer_card(_offer_cards[index])
		else:
			_render_offer_card(_offer_cards[index], Dictionary(item_offers[index]), booster_pending)

	_render_relic_card(Dictionary(shop_snapshot.get("relic_offer", {})), booster_pending)
	_render_action_row(shop_snapshot, progression_snapshot, booster_pending)
	_render_build_panel(progression_snapshot)
	_render_mastery_strip(Dictionary(progression_snapshot.get("mastery_levels", {})))
	_render_booster_overlay(pending_options)
	_apply_shop_layout()


func _render_offer_card(card: Button, offer: Dictionary, booster_pending: bool) -> void:
	_clear_children(card)
	card.text = ""
	var rarity := String(offer.get("rarity", "common")).to_lower()
	var sold_out := bool(offer.get("sold_out", false))
	var price := int(offer.get("price", 0))
	var affordable := RunState.can_afford(price)
	var disabled := sold_out or booster_pending or not affordable
	card.disabled = disabled
	card.modulate = Color(0.58, 0.58, 0.58, 0.92) if disabled else Color.WHITE
	card.tooltip_text = _offer_tooltip(offer)
	_apply_button_chrome(card, _card_bg_color(rarity, disabled), _rarity_color(rarity), Color(0.18, 0.13, 0.08, 1.0))

	var root := _make_child_root(card)
	_make_dynamic_label(root, String(offer.get("type", "offer")).replace("_", " ").to_upper(), Rect2(Vector2(18, 12), Vector2(284, 24)), MUTED_COLOR, 15, HORIZONTAL_ALIGNMENT_CENTER)
	_make_dynamic_label(root, String(offer.get("display_name", "Offer")), Rect2(Vector2(18, 38), Vector2(284, 78)), _rarity_color(rarity), 28, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_dynamic_label(root, rarity.to_upper(), Rect2(Vector2(70, 110), Vector2(180, 28)), _rarity_color(rarity), 17, HORIZONTAL_ALIGNMENT_CENTER)

	var art_frame := _make_dynamic_panel(root, Rect2(Vector2(62, 144), Vector2(196, 138)), _panel_style(Color(0.05, 0.06, 0.08, 0.92), _rarity_color(rarity), 2, 8))
	var icon := _make_texture("OfferIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(offer.get("icon_key", "")))
	icon.position = Vector2(24, 14)
	icon.size = Vector2(148, 110)
	_make_dynamic_label(root, String(offer.get("description", "No details available.")), Rect2(Vector2(24, 300), Vector2(272, 82)), INK_COLOR, 18, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_price_badge(root, Rect2(Vector2(48, 400), Vector2(224, 54)), _price_text(price, sold_out, affordable, booster_pending), disabled)


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
	var affordable := RunState.can_afford(price)
	var disabled := sold_out or booster_pending or not affordable
	_relic_card.disabled = disabled
	_relic_card.modulate = Color(0.58, 0.58, 0.58, 0.92) if disabled else Color.WHITE
	_relic_card.tooltip_text = _offer_tooltip(relic_offer)
	_apply_button_chrome(_relic_card, Color(0.13, 0.06, 0.15, 0.94), _rarity_color(rarity), Color(0.19, 0.08, 0.20, 0.98))

	var root := _make_child_root(_relic_card)
	_make_dynamic_label(root, "DUNGEON RELIC", Rect2(Vector2(24, 10), Vector2(1000, 30)), GOLD_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
	var art_frame := _make_dynamic_panel(root, Rect2(Vector2(30, 48), Vector2(160, 136)), _panel_style(Color(0.05, 0.04, 0.08, 0.92), _rarity_color(rarity), 2, 8))
	var icon := _make_texture("RelicIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(relic_offer.get("icon_key", "")))
	icon.position = Vector2(12, 10)
	icon.size = Vector2(136, 116)
	_make_dynamic_label(root, "%s RELIC" % rarity.to_upper(), Rect2(Vector2(220, 50), Vector2(560, 26)), _rarity_color(rarity), 18)
	_make_dynamic_label(root, String(relic_offer.get("display_name", "Relic")), Rect2(Vector2(220, 78), Vector2(560, 44)), _rarity_color(rarity), 30)
	_make_dynamic_label(root, String(relic_offer.get("description", "No details available.")), Rect2(Vector2(220, 126), Vector2(560, 54)), INK_COLOR, 20, HORIZONTAL_ALIGNMENT_LEFT, true)
	_make_price_badge(root, Rect2(Vector2(810, 80), Vector2(196, 66)), _price_text(price, sold_out, affordable, booster_pending), disabled)


func _render_action_row(shop_snapshot: Dictionary, progression_snapshot: Dictionary, booster_pending: bool) -> void:
	var active := bool(shop_snapshot.get("active", false))
	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.text = "Reroll\nCost %d" % reroll_cost
	_reroll_button.disabled = booster_pending or not active or not RunState.can_afford(reroll_cost)
	_sell_equipment_button.text = "Sell Selected\n%s" % _selected_slot_sell_text(progression_snapshot)
	_sell_equipment_button.disabled = booster_pending or not _selected_slot_has_equipment(progression_snapshot)
	_continue_button.text = "Continue\nLeave Shop"
	_continue_button.disabled = booster_pending

func _render_build_panel(progression_snapshot: Dictionary) -> void:
	var player_state = RunState.ensure_player_state()
	_hp_label.text = "HP %d / %d" % [int(player_state.current_hp), int(player_state.max_hp)]
	_hp_bar.max_value = float(maxi(1, int(player_state.max_hp)))
	_hp_bar.value = float(maxi(0, int(player_state.current_hp)))
	_hero_portrait.texture = _visuals.hero_portrait()
	_build_gold_label.text = "GOLD %d" % RunState.run_gold
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if _selected_equipment_slot >= equipment_slots.size() or (_selected_equipment_slot >= 0 and String(equipment_slots[_selected_equipment_slot]) == ""):
		_selected_equipment_slot = -1
	_player_loadout_hud.set_selected_equipment_slot(_selected_equipment_slot)
	_player_loadout_hud.populate_loadout_slot_row(_equipment_slots_root, equipment_slots, "equipment", 5, true)
	_player_loadout_hud.populate_loadout_slot_row(_consumable_slots_root, Array(progression_snapshot.get("consumable_slots", [])), "consumable", 3)
	var relic_ids: Array = progression_snapshot.get("relic_ids", [])
	_player_loadout_hud.populate_relic_row(_relic_slots_root, relic_ids, 4)
	var has_relic := false
	for relic_id in relic_ids:
		if String(relic_id) != "":
			has_relic = true
			break
	_relic_label.visible = has_relic
	_relic_slots_root.visible = has_relic


func _render_mastery_strip(mastery_levels: Dictionary) -> void:
	_player_loadout_hud.populate_mastery_row(_mastery_cells_root, mastery_levels)


func _render_booster_overlay(pending_options: Array) -> void:
	var overlay_visible := not pending_options.is_empty()
	_booster_overlay.visible = overlay_visible
	_booster_modal.visible = overlay_visible
	if not overlay_visible:
		return
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


func _buy_offer_at(index: int) -> void:
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var item_offers: Array = shop_snapshot.get("item_offers", [])
	if index < 0 or index >= item_offers.size():
		return
	var offer: Dictionary = item_offers[index]
	var result: Dictionary = RunState.buy_shop_offer(String(offer.get("offer_id", "")))
	_set_status(_result_message("Buy %s" % String(offer.get("display_name", "offer")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _buy_relic_offer() -> void:
	var relic_offer: Dictionary = RunState.ensure_shop_state().relic_offer
	if relic_offer.is_empty():
		return
	var result: Dictionary = RunState.buy_shop_offer(String(relic_offer.get("offer_id", "")))
	_set_status(_result_message("Buy %s" % String(relic_offer.get("display_name", "relic")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_reroll_button_pressed() -> void:
	var result: Dictionary = RunState.reroll_shop_items()
	_set_status(_result_message("Reroll", result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_sell_equipment_button_pressed() -> void:
	if _selected_equipment_slot < 0:
		_set_status("Sell failed: select an occupied equipment slot first.", false)
		return
	var slot_index := _selected_equipment_slot
	var result: Dictionary = RunState.sell_equipped_item(slot_index)
	_set_status(_result_message("Sell equipment slot %d" % slot_index, result), bool(result.get("ok", false)))
	if bool(result.get("ok", false)):
		_selected_equipment_slot = -1
	_refresh_ui()


func _choose_booster_option(index: int) -> void:
	var result: Dictionary = RunState.choose_booster_option(index)
	_set_status(_result_message("Booster pick", result), bool(result.get("ok", false)))
	_refresh_ui()


func _select_equipment_slot(index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if index < 0 or index >= equipment_slots.size() or String(equipment_slots[index]) == "":
		_selected_equipment_slot = -1
		_set_status("Select a filled equipment slot before selling.", false)
	else:
		_selected_equipment_slot = index
		var content := _lookup_content_definition(String(equipment_slots[index]))
		_set_status("Selected %s for selling." % String(content.get("display_name", equipment_slots[index])), true)
	_refresh_ui()

func _on_continue_button_pressed() -> void:
	var transition: Dictionary = RunState.advance_after_shop(false)
	get_tree().change_scene_to_file(String(transition.get("next_scene", "res://scenes/main.tscn")))


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _result_message(action: String, result: Dictionary) -> String:
	if bool(result.get("ok", false)):
		return "%s: OK. Gold %d." % [action, RunState.run_gold]
	return "%s: failed (%s)." % [action, String(result.get("reason", "unknown"))]


func _set_status(message: String, positive: bool) -> void:
	if _summary_label == null:
		return
	_summary_label.text = message
	_summary_label.add_theme_color_override("font_color", POSITIVE_COLOR if positive else NEGATIVE_COLOR)


func _selected_slot_sell_text(progression_snapshot: Dictionary) -> String:
	if not _selected_slot_has_equipment(progression_snapshot):
		return "Select gear slot"
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	var item_id := String(equipment_slots[_selected_equipment_slot])
	var content := _lookup_content_definition(item_id)
	return "+%d gold" % int(content.get("sell_value", content.get("base_price", 0)))


func _selected_slot_has_equipment(progression_snapshot: Dictionary) -> bool:
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if _selected_equipment_slot < 0 or _selected_equipment_slot >= equipment_slots.size():
		return false
	return String(equipment_slots[_selected_equipment_slot]) != ""


func _lookup_content_definition(content_id: String) -> Dictionary:
	var registry = RunState.ensure_content_registry()
	var value: Dictionary = registry.get_equipment(content_id)
	if not value.is_empty():
		return value
	value = registry.get_consumable(content_id)
	if not value.is_empty():
		return value
	value = registry.get_relic(content_id)
	if not value.is_empty():
		return value
	value = registry.get_mastery_card(content_id)
	if not value.is_empty():
		return value
	value = registry.get_booster(content_id)
	if not value.is_empty():
		return value
	return {"display_name": content_id, "description": "", "icon_key": ""}


func _offer_tooltip(offer: Dictionary) -> String:
	return "%s\n%s\nPrice: %d gold" % [String(offer.get("display_name", "Offer")), String(offer.get("description", "")), int(offer.get("price", 0))]


func _price_text(price: int, sold_out: bool, affordable: bool, booster_pending: bool) -> String:
	if sold_out:
		return "SOLD"
	if booster_pending:
		return "PICK BOOSTER"
	if not affordable:
		return "NEED %d G" % price
	return "G  %d" % price


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


func _on_viewport_size_changed() -> void:
	_apply_shop_layout()


func _apply_shop_layout() -> void:
	var viewport_size := get_viewport_rect().size
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
	_apply_rect(_build_panel, PLAYER_HUD_PANEL_RECT)

	_apply_rect(_crest_panel, Rect2(Vector2(18, 15), Vector2(58, 58)))
	_apply_rect(_crest_label, Rect2(Vector2.ZERO, Vector2(58, 58)))
	_apply_rect(_run_progress_label, Rect2(Vector2(100, 12), Vector2(560, 24)))
	_apply_rect(_title_label, Rect2(Vector2(100, 34), Vector2(560, 42)))
	_apply_rect(_gold_pill, Rect2(Vector2(726, 15), Vector2(190, 58)))
	_apply_rect(_gold_label, Rect2(Vector2.ZERO, Vector2(190, 58)))
	_apply_rect(_main_menu_button, Rect2(Vector2(928, 15), Vector2(96, 58)))

	_apply_rect(_speech_card, Rect2(Vector2(34, 42), Vector2(380, 150)))
	_apply_rect(_speech_label, Rect2(Vector2(20, 18), Vector2(340, 90)))
	_apply_rect(_boss_preview_label, Rect2(Vector2(20, 116), Vector2(340, 22)))
	_apply_rect(_summary_label, Rect2(Vector2(34, 218), Vector2(680, 34)))
	_apply_rect(_detail_label, Rect2(Vector2(34, 258), Vector2(830, 34)))

	_apply_rect(_stock_title_label, Rect2(Vector2.ZERO + Vector2(0, 14), Vector2(STOCK_PANEL_RECT.size.x, 40)))
	_apply_rect(_offer_grid, Rect2(Vector2(22, 68), Vector2(STOCK_PANEL_RECT.size.x - 44.0, OFFER_CARD_SIZE.y)))
	for index in _offer_cards.size():
		_apply_rect(_offer_cards[index], Rect2(Vector2(float(index) * (OFFER_CARD_SIZE.x + OFFER_CARD_GAP), 0.0), OFFER_CARD_SIZE))

	_apply_rect(_reroll_button, Rect2(Vector2.ZERO, Vector2(316, ACTION_ROW_RECT.size.y)))
	_apply_rect(_sell_equipment_button, Rect2(Vector2(342, 0), Vector2(316, ACTION_ROW_RECT.size.y)))
	_apply_rect(_continue_button, Rect2(Vector2(684, 0), Vector2(364, ACTION_ROW_RECT.size.y)))

	_player_loadout_hud.apply_combat_player_panel_layout(_shop_player_hud_nodes())
	_apply_rect(_gold_badge, Rect2(Vector2(474, 112), Vector2(222, 34)))
	_apply_rect(_build_gold_label, Rect2(Vector2.ZERO, Vector2(222, 34)))
	_apply_rect(_relic_label, PLAYER_RELIC_LABEL_RECT)
	_apply_rect(_relic_slots_root, PLAYER_RELIC_ICONS_RECT)

	_apply_rect(_booster_overlay, Rect2(Vector2.ZERO, DESIGN_SIZE))
	_apply_rect(_booster_modal, Rect2(Vector2(152, 610), Vector2(776, 420)))
	_apply_rect(_booster_title_label, Rect2(Vector2(0, 30), Vector2(776, 42)))
	_apply_rect(_booster_hint_label, Rect2(Vector2(80, 82), Vector2(616, 42)))
	for index in _booster_option_buttons.size():
		_apply_rect(_booster_option_buttons[index], Rect2(Vector2(46 + float(index) * 238.0, 150), Vector2(208, 236)))


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _shop_player_hud_nodes() -> Dictionary:
	return {
		"root": _player_panel_root,
		"hero_card": _hero_card,
		"hero_portrait": _hero_portrait,
		"vitals_panel": _vitals_panel,
		"vitals_frame": _vitals_frame,
		"hp_bar": _hp_bar,
		"hp_label": _hp_label,
		"armor_badge": _gold_badge,
		"armor_badge_label": _build_gold_label,
		"loadout_frame": _loadout_frame,
		"loadout_root": _loadout_root,
		"equipment_label": _equipment_label,
		"equipment_icons": _equipment_slots_root,
		"consumable_label": _consumable_label,
		"consumable_icons": _consumable_slots_root,
		"mastery_strip": _mastery_strip,
		"mastery_root": _mastery_root,
		"mastery_label": _mastery_title_label,
		"mastery_icons": _mastery_cells_root,
	}


func _apply_visual_chrome() -> void:
	for panel in [_top_bar, _merchant_stage, _stock_panel, _build_panel]:
		(panel as Panel).add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8))
	_speech_card.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.05, 0.06, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8))
	_crest_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.30, 0.18, 0.06, 0.98), GOLD_COLOR, 2, 32))
	_gold_pill.add_theme_stylebox_override("panel", _panel_style(Color(0.22, 0.13, 0.04, 0.96), GOLD_COLOR, 2, 8))
	for panel in [_hero_card, _vitals_frame, _loadout_frame, _mastery_strip]:
		(panel as Panel).add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.08, 0.12, 0.98), Color(0.21, 0.26, 0.33, 0.95), 2, 6))
	_gold_badge.add_theme_stylebox_override("panel", _panel_style(Color(0.14, 0.09, 0.04, 0.96), GOLD_COLOR, 2, 5))
	_apply_progressbar_flat_style(_hp_bar, Color(0.78, 0.16, 0.17, 1.0))
	_booster_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.06, 0.08, 0.98), GOLD_COLOR, 3, 12))
	_booster_overlay.color = Color(0.0, 0.0, 0.0, 0.68)

	_apply_button_chrome(_main_menu_button, Color(0.13, 0.09, 0.05, 0.95), GOLD_COLOR, Color(0.23, 0.15, 0.07, 0.98))
	_apply_button_chrome(_reroll_button, Color(0.05, 0.17, 0.27, 0.96), Color(0.31, 0.62, 0.84, 1.0), Color(0.08, 0.24, 0.36, 0.98))
	_apply_button_chrome(_sell_equipment_button, Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0), Color(0.28, 0.18, 0.09, 0.98))
	_apply_button_chrome(_continue_button, Color(0.12, 0.30, 0.06, 0.96), Color(0.54, 0.78, 0.24, 1.0), Color(0.18, 0.40, 0.08, 0.98))

	for label in [_title_label, _gold_label, _stock_title_label, _mastery_title_label, _booster_title_label]:
		(label as Label).add_theme_color_override("font_color", GOLD_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for label in [_run_progress_label, _boss_preview_label, _detail_label, _equipment_label, _consumable_label, _relic_label, _booster_hint_label]:
		(label as Label).add_theme_color_override("font_color", MUTED_COLOR)
	for label in [_speech_label, _hp_label, _build_gold_label, _crest_label]:
		(label as Label).add_theme_color_override("font_color", INK_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_build_gold_label.add_theme_color_override("font_color", GOLD_COLOR)
	for button in [_main_menu_button, _reroll_button, _sell_equipment_button, _continue_button]:
		(button as Button).add_theme_color_override("font_color", INK_COLOR)
		(button as Button).add_theme_font_size_override("font_size", 23)


func _apply_button_chrome(button: Button, bg_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", _panel_style(bg_color, border_color, 2, 8))
	button.add_theme_stylebox_override("hover", _panel_style(hover_color, border_color.lightened(0.16), 2, 8))
	button.add_theme_stylebox_override("pressed", _panel_style(hover_color.darkened(0.10), border_color, 2, 8))
	button.add_theme_stylebox_override("disabled", _panel_style(Color(0.05, 0.06, 0.07, 0.88), Color(0.24, 0.25, 0.29, 0.92), 2, 8))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.56, 0.60, 1.0))


func _panel_style(bg_color: Color, border_color: Color, border_width: int = 2, radius: int = 6) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _apply_progressbar_flat_style(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.07, 0.10, 0.95)
	bg.border_color = Color(0.52, 0.40, 0.19, 0.85)
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(6)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _make_panel(node_name: String, parent: Node) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(panel)
	return panel


func _make_button(node_name: String, parent: Node, button_text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = button_text
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	return button


func _make_root(node_name: String, parent: Node) -> Control:
	var control := Control.new()
	control.name = node_name
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(control)
	return control


func _make_texture(node_name: String, parent: Node) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = node_name
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _make_label(node_name: String, parent: Node, text: String, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	label.name = node_name
	_configure_label(label, text, font_size, color, align, enable_wrap)
	parent.add_child(label)
	return label


func _make_child_root(parent: Control) -> Control:
	var root := Control.new()
	root.name = "CardRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = Vector2.ZERO
	root.size = parent.size
	parent.add_child(root)
	return root


func _make_dynamic_panel(parent: Node, rect: Rect2, style: StyleBox) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _make_dynamic_label(parent: Node, text: String, rect: Rect2, color: Color, font_size: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	_configure_label(label, text, font_size, color, align, enable_wrap)
	label.position = rect.position
	label.size = rect.size
	parent.add_child(label)
	return label


func _configure_label(label: Label, text: String, font_size: int, color: Color, align: HorizontalAlignment, enable_wrap: bool) -> void:
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = align
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if enable_wrap else TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))


func _make_price_badge(parent: Node, rect: Rect2, text: String, disabled: bool) -> void:
	var bg := Color(0.32, 0.18, 0.04, 0.96) if not disabled else Color(0.07, 0.07, 0.08, 0.94)
	var border := GOLD_COLOR if not disabled else Color(0.28, 0.28, 0.30, 0.92)
	var badge := _make_dynamic_panel(parent, rect, _panel_style(bg, border, 2, 6))
	_make_dynamic_label(badge, text, Rect2(Vector2.ZERO, rect.size), GOLD_COLOR if not disabled else MUTED_COLOR, 26, HORIZONTAL_ALIGNMENT_CENTER)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
