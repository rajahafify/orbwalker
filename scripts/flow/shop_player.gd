extends Control

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")

const DESIGN_SIZE := Vector2(1080, 1920)
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 86))
const MERCHANT_STAGE_RECT := Rect2(Vector2(16, 108), Vector2(1048, 220))
const STOCK_PANEL_RECT := Rect2(Vector2(16, 342), Vector2(1048, 454))
const RELIC_PANEL_RECT := Rect2(Vector2(16, 810), Vector2(1048, 168))
const ACTION_ROW_RECT := Rect2(Vector2(16, 992), Vector2(1048, 84))
const OFFER_CARD_SIZE := Vector2(320, 370)
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
var _hero_portrait: TextureRect
var _vitals_panel: Control
var _vitals_frame: Panel
var _hp_bar: ProgressBar
var _hp_label: Label
var _equipment_label: Label
var _equipment_slots_root: Control
var _consumable_label: Label
var _consumable_slots_root: Control
var _relic_label: Label
var _relic_icons_root: Control
var _loadout_frame: Panel
var _loadout_root: Control
var _booster_overlay: ColorRect
var _booster_modal: Panel
var _booster_title_label: Label
var _booster_hint_label: Label
var _booster_option_buttons: Array[Button] = []
var _skip_booster_button: Button

var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
var _selected_equipment_slot := -1
var _selected_consumable_slot := -1
var _flow_trace_route_id := ""
var _is_transitioning := false
var _shop_action_guard_frame := -1


func _enter_tree() -> void:
	_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"shop_scene_load",
			"res://scenes/flow/shop_player.tscn",
			{"source": "shop_player._enter_tree"}
		)
	RunState.flow_trace_mark("shop_enter_tree", {}, _flow_trace_route_id)


func _ready() -> void:
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"shop_scene_load",
			"res://scenes/flow/shop_player.tscn",
			{"source": "shop_player._ready"}
		)
	RunState.flow_trace_mark("shop_ready_start", {}, _flow_trace_route_id)
	_audio_play_music("shop")
	RunState.flow_trace_mark("shop_after_music", {}, _flow_trace_route_id)
	_background.texture = _visuals.shop_background()
	_backdrop_tint.color = Color(0.0, 0.0, 0.0, 0.33)
	RunState.flow_trace_mark("shop_after_background", {}, _flow_trace_route_id)
	_create_ui()
	RunState.flow_trace_mark("shop_after_create_ui", {}, _flow_trace_route_id)
	_player_loadout_hud.bind_player_hud(_shop_player_hud_nodes().merged({
		"popover_parent": _hud_overlay,
		"popover_z_index": 51,
	}, true))
	RunState.flow_trace_mark("shop_after_hud_bind", {}, _flow_trace_route_id)
	_apply_visual_chrome()
	RunState.flow_trace_mark("shop_after_chrome", {}, _flow_trace_route_id)
	_connect_signals()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_apply_shop_layout()
	RunState.flow_trace_mark("shop_after_layout", {}, _flow_trace_route_id)

	if not RunState.run_active:
		_title_label.text = "Shop"
		_set_status("No active run. Returning to main menu.", false)
		RunState.flow_trace_mark(
			"shop_ready_redirect_before_change_scene",
			{"source": "no_active_run"},
			_flow_trace_route_id,
			"res://scenes/main.tscn"
		)
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		return
	if not RunState.is_current_step_shop():
		var redirect_scene := RunState.next_scene_path()
		RunState.flow_trace_mark(
			"shop_ready_redirect_before_change_scene",
			{"source": "wrong_step"},
			_flow_trace_route_id,
			redirect_scene
		)
		get_tree().call_deferred("change_scene_to_file", redirect_scene)
		return

	RunState.flow_trace_mark("shop_before_open_shop", {}, _flow_trace_route_id)
	var open_result: Dictionary = RunState.open_shop_for_current_level()
	RunState.flow_trace_mark(
		"shop_after_open_shop",
		{"ok": bool(open_result.get("ok", false))},
		_flow_trace_route_id
	)
	_set_status("Shop opened. Buy, reroll, sell, or continue." if bool(open_result.get("ok", false)) else "Failed to open shop: %s" % String(open_result.get("reason", "unknown")), bool(open_result.get("ok", false)))
	_refresh_ui()
	RunState.flow_trace_mark("shop_after_refresh_ui", {}, _flow_trace_route_id)
	call_deferred("_trace_flow_first_usable_frame")


func _trace_flow_first_usable_frame() -> void:
	await get_tree().process_frame
	RunState.flow_trace_mark(
		"shop_first_usable_frame",
		{"source": "shop_player._ready_deferred"},
		_flow_trace_route_id
	)


func _create_ui() -> void:
	_layout_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_overlay = _make_root("HudOverlay", _layout_root)
	_hud_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_overlay.z_index = 50
	_hud_overlay.clip_contents = false

	_top_bar = _make_panel("TopBar", _layout_root)
	_crest_panel = _make_panel("CrestPanel", _top_bar)
	_crest_label = _make_label("CrestLabel", _crest_panel, "M", 28, INK_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_run_progress_label = _make_label("RunProgressLabel", _top_bar, "Dungeon -", 17, MUTED_COLOR)
	_title_label = _make_label("TitleLabel", _top_bar, "Shop", 38, GOLD_COLOR)
	_gold_pill = _make_panel("GoldPill", _top_bar)
	_gold_label = _make_label("GoldLabel", _gold_pill, "G 0", 32, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_main_menu_button = _make_button("MainMenuButton", _top_bar, "Menu")

	_merchant_stage = _make_panel("MerchantStage", _layout_root)
	_merchant_backdrop = _make_texture("MerchantBackdrop", _merchant_stage)
	_merchant_backdrop.texture = _visuals.shop_background()
	_merchant_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_merchant_scrim = _make_color_rect("MerchantScrim", _merchant_stage, Color(0.0, 0.0, 0.0, 0.30))
	_merchant_counter = _make_color_rect("MerchantCounter", _merchant_stage, Color(0.08, 0.045, 0.025, 0.88))
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

	_player_hud_section = _make_panel("PlayerHudSection", _layout_root)
	_player_hud_section.clip_contents = false
	_elemental_mastery_panel = _make_panel("ElementalMasteryPanel", _player_hud_section)
	_elemental_mastery_title = _make_label("ElementalMasteryTitle", _elemental_mastery_panel, "ELEMENTAL MASTERY", 22, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_elemental_mastery_cards = _make_root("ElementalMasteryCards", _elemental_mastery_panel)
	_build_panel = _make_panel("PlayerPanel", _player_hud_section)
	_build_panel.clip_contents = false
	_player_panel_root = _make_root("PlayerPanelRoot", _build_panel)
	_player_panel_root.clip_contents = false
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
	_loadout_frame = _make_panel("LoadoutFrame", _player_panel_root)
	_loadout_root = _make_root("LoadoutRoot", _loadout_frame)
	_loadout_frame.clip_contents = false
	_loadout_root.clip_contents = false
	_equipment_label = _make_label("EquipmentLabel", _loadout_root, "EQUIPMENT", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_equipment_slots_root = _make_root("EquipmentIcons", _loadout_root)
	_equipment_slots_root.clip_contents = false
	_consumable_label = _make_label("ConsumableLabel", _loadout_root, "CONSUMABLES", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_consumable_slots_root = _make_root("ConsumableIcons", _loadout_root)
	_consumable_slots_root.clip_contents = false
	_relic_label = _make_label("RelicLabel", _loadout_root, "RELICS", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_relic_icons_root = _make_root("RelicIcons", _loadout_root)
	_relic_icons_root.clip_contents = false
	_booster_overlay = ColorRect.new()
	_booster_overlay.name = "BoosterOverlay"
	_booster_overlay.visible = false
	_booster_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_layout_root.add_child(_booster_overlay)
	_booster_modal = _make_panel("BoosterModal", _booster_overlay)
	_booster_modal.mouse_filter = Control.MOUSE_FILTER_PASS
	_booster_title_label = _make_label("BoosterTitleLabel", _booster_modal, "Choose One Booster Reward", 30, GOLD_COLOR, HORIZONTAL_ALIGNMENT_CENTER)
	_booster_hint_label = _make_label("BoosterHintLabel", _booster_modal, "Pick one option now, or press Skip to continue shopping.", 18, MUTED_COLOR, HORIZONTAL_ALIGNMENT_CENTER, true)
	for index in 3:
		var button := _make_button("BoosterOptionButton%d" % (index + 1), _booster_modal, "")
		_booster_option_buttons.append(button)
	_skip_booster_button = _make_button("SkipBoosterButton", _booster_modal, "Skip")
	_skip_booster_button.visible = false

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
	_skip_booster_button.pressed.connect(_skip_pending_booster)
	_player_loadout_hud.equipment_slot_selected.connect(_select_equipment_slot)
	_player_loadout_hud.consumable_slot_selected.connect(_select_consumable_slot)
	_player_loadout_hud.sell_slot_requested.connect(_on_player_hud_sell_slot_requested)


func _refresh_ui() -> void:
	_player_loadout_hud.hide_slot_detail_popover()
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var pending_options: Array = shop_snapshot.get("pending_booster_options", [])
	var booster_pending := not pending_options.is_empty()

	_run_progress_label.text = "Dungeon %d / %d | %s" % [RunState.dungeon_level, RunState.MAX_DUNGEON_LEVELS, RunState.level_sequence_label()]
	_boss_preview_label.text = "Boss preview: %s" % RunState.current_level_boss_name()
	_gold_label.text = "G  %d" % RunState.run_gold
	_detail_label.text = "Select a stock card or relic card to buy. Select an equipped or consumable slot before selling."

	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for index in _offer_cards.size():
		if index >= item_offers.size():
			_render_empty_offer_card(_offer_cards[index])
		else:
			_render_offer_card(_offer_cards[index], Dictionary(item_offers[index]), booster_pending)

	_render_relic_card(Dictionary(shop_snapshot.get("relic_offer", {})), booster_pending)
	_render_action_row(shop_snapshot, booster_pending)
	_render_build_panel(progression_snapshot)
	_render_elemental_mastery_panel(Dictionary(progression_snapshot.get("mastery_levels", {})))
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
	_make_dynamic_label(root, rarity.to_upper(), Rect2(Vector2(70, 8), Vector2(180, 24)), _rarity_color(rarity), 16, HORIZONTAL_ALIGNMENT_CENTER)
	_make_dynamic_label(root, String(offer.get("display_name", "Offer")), Rect2(Vector2(22, 36), Vector2(276, 64)), _rarity_color(rarity), 25, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_dynamic_label(root, String(offer.get("type", "offer")).replace("_", " ").to_upper(), Rect2(Vector2(18, 102), Vector2(284, 22)), MUTED_COLOR, 13, HORIZONTAL_ALIGNMENT_CENTER)

	var art_frame := _make_dynamic_panel(root, Rect2(Vector2(62, 134), Vector2(196, 116)), _panel_style(Color(0.04, 0.04, 0.05, 0.94), _rarity_color(rarity), 2, 8))
	var icon := _make_texture("OfferIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(offer.get("icon_key", "")))
	icon.position = Vector2(18, 10)
	icon.size = Vector2(160, 96)
	_make_dynamic_label(root, String(offer.get("description", "No details available.")), Rect2(Vector2(26, 262), Vector2(268, 52)), INK_COLOR, 15, HORIZONTAL_ALIGNMENT_CENTER, true)
	_make_price_badge(root, Rect2(Vector2(56, 326), Vector2(208, 40)), _price_text(price, sold_out, affordable, booster_pending), disabled)


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
	var art_frame := _make_dynamic_panel(root, Rect2(Vector2(30, 44), Vector2(150, 104)), _panel_style(Color(0.05, 0.04, 0.08, 0.92), _rarity_color(rarity), 2, 8))
	var icon := _make_texture("RelicIcon", art_frame)
	icon.texture = _visuals.icon_for_key(String(relic_offer.get("icon_key", "")))
	icon.position = Vector2(15, 8)
	icon.size = Vector2(120, 88)
	_make_dynamic_label(root, "%s RELIC" % rarity.to_upper(), Rect2(Vector2(210, 42), Vector2(560, 24)), _rarity_color(rarity), 16)
	_make_dynamic_label(root, String(relic_offer.get("display_name", "Relic")), Rect2(Vector2(210, 66), Vector2(560, 38)), _rarity_color(rarity), 26)
	_make_dynamic_label(root, String(relic_offer.get("description", "No details available.")), Rect2(Vector2(210, 108), Vector2(560, 42)), INK_COLOR, 17, HORIZONTAL_ALIGNMENT_LEFT, true)
	_make_price_badge(root, Rect2(Vector2(812, 58), Vector2(194, 54)), _price_text(price, sold_out, affordable, booster_pending), disabled)


func _render_action_row(shop_snapshot: Dictionary, booster_pending: bool) -> void:
	var active := bool(shop_snapshot.get("active", false))
	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.text = "Reroll\nCost %d" % reroll_cost
	_reroll_button.disabled = booster_pending or not active or not RunState.can_afford(reroll_cost)
	_sell_equipment_button.visible = false
	_sell_equipment_button.disabled = true
	_continue_button.text = "Continue\nLeave Shop"
	_continue_button.disabled = booster_pending

func _render_build_panel(progression_snapshot: Dictionary) -> void:
	var player_state = RunState.ensure_player_state()
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if _selected_equipment_slot >= equipment_slots.size() or (_selected_equipment_slot >= 0 and String(equipment_slots[_selected_equipment_slot]) == ""):
		_selected_equipment_slot = -1
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if _selected_consumable_slot >= consumable_slots.size() or (_selected_consumable_slot >= 0 and String(consumable_slots[_selected_consumable_slot]) == ""):
		_selected_consumable_slot = -1
	_player_loadout_hud.set_selected_equipment_slot(_selected_equipment_slot)
	_player_loadout_hud.set_selected_consumable_slot(_selected_consumable_slot)
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


func _buy_offer_at(index: int) -> void:
	if not _try_begin_shop_action():
		return
	_clear_inventory_focus()
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var item_offers: Array = shop_snapshot.get("item_offers", [])
	if index < 0 or index >= item_offers.size():
		return
	var offer: Dictionary = item_offers[index]
	var result: Dictionary = RunState.buy_shop_offer(String(offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	_set_status(_result_message("Buy %s" % String(offer.get("display_name", "offer")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _buy_relic_offer() -> void:
	if not _try_begin_shop_action():
		return
	_clear_inventory_focus()
	var relic_offer: Dictionary = RunState.ensure_shop_state().relic_offer
	if relic_offer.is_empty():
		return
	var result: Dictionary = RunState.buy_shop_offer(String(relic_offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	_set_status(_result_message("Buy %s" % String(relic_offer.get("display_name", "relic")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_reroll_button_pressed() -> void:
	if not _try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.reroll_shop_items()
	_play_shop_result_sfx(result, "ui_accept")
	_set_status(_result_message("Reroll", result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_sell_equipment_button_pressed() -> void:
	if not _try_begin_shop_action():
		return
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var selected_kind := _selected_slot_kind(progression_snapshot)
	if selected_kind == "":
		_set_status("Sell failed: select an occupied equipment or consumable slot first.", false)
		return
	var slot_index := _selected_equipment_slot if selected_kind == "equipment" else _selected_consumable_slot
	var result: Dictionary = RunState.sell_equipped_item(slot_index) if selected_kind == "equipment" else RunState.sell_consumable_item(slot_index)
	_play_shop_result_sfx(result, "gold")
	var action := "Sell equipment slot %d" % slot_index if selected_kind == "equipment" else "Sell consumable slot %d" % slot_index
	_set_status(_result_message(action, result), bool(result.get("ok", false)))
	if bool(result.get("ok", false)):
		if selected_kind == "equipment":
			_selected_equipment_slot = -1
		else:
			_selected_consumable_slot = -1
	_refresh_ui()


func _on_player_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	if not _try_begin_shop_action():
		return
	var result: Dictionary = RunState.sell_equipped_item(slot_index) if slot_type == "equipment" else RunState.sell_consumable_item(slot_index)
	_play_shop_result_sfx(result, "gold")
	var action := "Sell equipment slot %d" % slot_index if slot_type == "equipment" else "Sell consumable slot %d" % slot_index
	_set_status(_result_message(action, result), bool(result.get("ok", false)))
	if bool(result.get("ok", false)):
		_selected_equipment_slot = -1
		_selected_consumable_slot = -1
		_player_loadout_hud.hide_slot_detail_popover()
	_refresh_ui()


func _choose_booster_option(index: int) -> void:
	if not _try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.choose_booster_option(index)
	_play_shop_result_sfx(result, "purchase")
	if not bool(result.get("ok", false)) and _is_full_slot_reason(String(result.get("reason", ""))):
		_set_status("No free slot for this reward. Sell from the loadout HUD, then pick again, or press Skip.", false)
	else:
		_set_status(_result_message("Booster pick", result), bool(result.get("ok", false)))
	_refresh_ui()


func _skip_pending_booster() -> void:
	if not _try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.discard_pending_booster_options()
	_play_shop_result_sfx(result, "ui_cancel")
	var message := _result_message("Skip booster reward", result)
	if bool(result.get("ok", false)):
		message = "Skipped booster reward. Gold %d." % RunState.run_gold
	_set_status(message, bool(result.get("ok", false)))
	_refresh_ui()


func _play_shop_result_sfx(result: Dictionary, success_key: String) -> void:
	_audio_play_sfx(success_key if bool(result.get("ok", false)) else "error")


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		return audio
	var script: GDScript = load("res://scripts/core/audio_manager.gd")
	if script == null:
		return null
	audio = script.new()
	audio.name = "AudioManager"
	get_tree().root.add_child(audio)
	return audio


func _select_equipment_slot(index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if index < 0 or index >= equipment_slots.size() or String(equipment_slots[index]) == "":
		_selected_equipment_slot = -1
		_set_status("Select a filled equipment slot before selling.", false)
	else:
		_selected_equipment_slot = index
		_selected_consumable_slot = -1
		var content := _lookup_content_definition(String(equipment_slots[index]))
		_set_status("Selected %s for selling." % String(content.get("display_name", equipment_slots[index])), true)
	_refresh_ui()


func _select_consumable_slot(index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if index < 0 or index >= consumable_slots.size() or String(consumable_slots[index]) == "":
		_selected_consumable_slot = -1
		_set_status("Select a filled consumable slot before selling.", false)
	else:
		_selected_consumable_slot = index
		_selected_equipment_slot = -1
		var content := _lookup_content_definition(String(consumable_slots[index]))
		_set_status("Selected %s for selling." % String(content.get("display_name", consumable_slots[index])), true)
	_refresh_ui()


func _clear_inventory_focus() -> void:
	_selected_equipment_slot = -1
	_selected_consumable_slot = -1
	_player_loadout_hud.set_selected_equipment_slot(-1)
	_player_loadout_hud.set_selected_consumable_slot(-1)
	_player_loadout_hud.hide_slot_detail_popover()


func _try_begin_shop_action() -> bool:
	var frame := Engine.get_process_frames()
	if _shop_action_guard_frame == frame:
		return false
	_shop_action_guard_frame = frame
	return true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player_loadout_hud.handle_global_click((event as InputEventMouseButton).position):
			_clear_inventory_focus()
			_refresh_ui()
	elif event is InputEventScreenTouch and event.pressed:
		if _player_loadout_hud.handle_global_click((event as InputEventScreenTouch).position):
			_clear_inventory_focus()
			_refresh_ui()


func _on_continue_button_pressed() -> void:
	if _is_transitioning:
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	RunState.flow_trace_mark(
		"shop_continue_button_pressed",
		{"button_text": _continue_button.text},
		_flow_trace_route_id
	)
	RunState.flow_trace_mark("shop_before_advance_after_shop", {}, _flow_trace_route_id)
	var transition: Dictionary = RunState.advance_after_shop(false)
	var next_scene := String(transition.get("next_scene", "res://scenes/main.tscn"))
	RunState.flow_trace_mark(
		"shop_after_advance_after_shop",
		{
			"ok": bool(transition.get("ok", false)),
			"step": String(transition.get("step", "")),
		},
		_flow_trace_route_id,
		next_scene
	)
	if not bool(transition.get("ok", false)):
		_set_status("Continue failed: %s" % String(transition.get("reason", "unknown")), false)
		_end_transition_lock()
		return
	var route_id := _flow_trace_route_id
	if next_scene.find("combat_player.tscn") >= 0:
		route_id = RunState.flow_trace_begin(
			"shop_to_combat",
			next_scene,
			{"source": "shop_continue_button"}
		)
	RunState.flow_trace_mark(
		"shop_before_change_scene_to_file",
		{"source": "shop_continue_button"},
		route_id,
		next_scene
	)
	RunState.flow_trace_change_scene(
		get_tree(),
		next_scene,
		route_id,
		"shop_continue_button"
	)


func _on_main_menu_button_pressed() -> void:
	if _is_transitioning:
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	RunState.flow_trace_mark(
		"shop_main_menu_button_pressed",
		{"button_text": _main_menu_button.text},
		_flow_trace_route_id,
		"res://scenes/main.tscn"
	)
	RunState.flow_trace_mark(
		"shop_before_change_scene_to_file_main_menu",
		{"source": "shop_main_menu_button"},
		_flow_trace_route_id,
		"res://scenes/main.tscn"
	)
	RunState.flow_trace_change_scene(
		get_tree(),
		"res://scenes/main.tscn",
		_flow_trace_route_id,
		"shop_main_menu_button"
	)


func _result_message(action: String, result: Dictionary) -> String:
	if bool(result.get("ok", false)):
		return "%s: OK. Gold %d." % [action, RunState.run_gold]
	return "%s: failed (%s)." % [action, String(result.get("reason", "unknown"))]


func _set_status(message: String, positive: bool) -> void:
	if _summary_label == null:
		return
	_summary_label.text = message
	_summary_label.add_theme_color_override("font_color", POSITIVE_COLOR if positive else NEGATIVE_COLOR)


func _begin_transition_lock() -> void:
	_is_transitioning = true
	if _continue_button != null:
		_continue_button.disabled = true
	if _main_menu_button != null:
		_main_menu_button.disabled = true


func _end_transition_lock() -> void:
	_is_transitioning = false
	if _continue_button != null:
		_continue_button.disabled = false
	if _main_menu_button != null:
		_main_menu_button.disabled = false


func _selected_slot_kind(progression_snapshot: Dictionary) -> String:
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if _selected_equipment_slot >= 0 and _selected_equipment_slot < equipment_slots.size() and String(equipment_slots[_selected_equipment_slot]) != "":
		return "equipment"
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if _selected_consumable_slot >= 0 and _selected_consumable_slot < consumable_slots.size() and String(consumable_slots[_selected_consumable_slot]) != "":
		return "consumable"
	return ""


func _lookup_content_definition(content_id: String) -> Dictionary:
	return _player_loadout_hud.lookup_content_definition(content_id)


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

	_apply_rect(_crest_panel, Rect2(Vector2(18, 15), Vector2(58, 58)))
	_apply_rect(_crest_label, Rect2(Vector2.ZERO, Vector2(58, 58)))
	_apply_rect(_run_progress_label, Rect2(Vector2(100, 12), Vector2(560, 24)))
	_apply_rect(_title_label, Rect2(Vector2(100, 34), Vector2(560, 42)))
	_apply_rect(_gold_pill, Rect2(Vector2(726, 15), Vector2(190, 58)))
	_apply_rect(_gold_label, Rect2(Vector2.ZERO, Vector2(190, 58)))
	_apply_rect(_main_menu_button, Rect2(Vector2(928, 15), Vector2(96, 58)))

	_apply_rect(_merchant_backdrop, Rect2(Vector2.ZERO, MERCHANT_STAGE_RECT.size))
	_apply_rect(_merchant_scrim, Rect2(Vector2.ZERO, MERCHANT_STAGE_RECT.size))
	_apply_rect(_merchant_counter, Rect2(Vector2(0, 166), Vector2(MERCHANT_STAGE_RECT.size.x, 54)))
	_apply_rect(_speech_card, Rect2(Vector2(34, 32), Vector2(380, 122)))
	_apply_rect(_speech_label, Rect2(Vector2(20, 14), Vector2(340, 72)))
	_apply_rect(_boss_preview_label, Rect2(Vector2(20, 92), Vector2(340, 22)))
	_apply_rect(_summary_label, Rect2(Vector2(34, 162), Vector2(704, 26)))
	_apply_rect(_detail_label, Rect2(Vector2(34, 190), Vector2(858, 24)))

	_apply_rect(_stock_title_label, Rect2(Vector2.ZERO + Vector2(0, 14), Vector2(STOCK_PANEL_RECT.size.x, 40)))
	_apply_rect(_offer_grid, Rect2(Vector2(22, 68), Vector2(STOCK_PANEL_RECT.size.x - 44.0, OFFER_CARD_SIZE.y)))
	for index in _offer_cards.size():
		_apply_rect(_offer_cards[index], Rect2(Vector2(float(index) * (OFFER_CARD_SIZE.x + OFFER_CARD_GAP), 0.0), OFFER_CARD_SIZE))

	_apply_rect(_reroll_button, Rect2(Vector2.ZERO, Vector2(512, ACTION_ROW_RECT.size.y)))
	_apply_rect(_continue_button, Rect2(Vector2(536, 0), Vector2(512, ACTION_ROW_RECT.size.y)))
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
		"vitals_panel": _vitals_panel,
		"vitals_frame": _vitals_frame,
		"hp_bar": _hp_bar,
		"hp_label": _hp_label,
		"loadout_frame": _loadout_frame,
		"loadout_root": _loadout_root,
		"equipment_label": _equipment_label,
		"equipment_icons": _equipment_slots_root,
		"consumable_label": _consumable_label,
		"consumable_icons": _consumable_slots_root,
		"relic_label": _relic_label,
		"relic_icons": _relic_icons_root,
	}


func _apply_visual_chrome() -> void:
	for panel in [_top_bar, _stock_panel]:
		(panel as Panel).add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8))
	_merchant_stage.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.04, 0.05, 0.60), Color(0.66, 0.48, 0.21, 0.98), 2, 8))
	_speech_card.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.04, 0.04, 0.84), Color(0.74, 0.55, 0.28, 0.98), 2, 8))
	_crest_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.30, 0.18, 0.06, 0.98), GOLD_COLOR, 2, 32))
	_gold_pill.add_theme_stylebox_override("panel", _panel_style(Color(0.22, 0.13, 0.04, 0.96), GOLD_COLOR, 2, 8))
	_booster_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.06, 0.08, 0.98), GOLD_COLOR, 3, 12))
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
		(button as Button).add_theme_font_size_override("font_size", 23)
	_player_loadout_hud.apply_player_hud_chrome(_shop_player_hud_nodes())


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


func _make_color_rect(node_name: String, parent: Node, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


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
