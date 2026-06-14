extends RefCounted
class_name ShopView

signal offer_pressed(index: int)
signal relic_pressed
signal reroll_pressed
signal sell_pressed
signal continue_pressed
signal main_menu_pressed
signal settings_pressed
signal treasure_chest_option_pressed(index: int)
signal skip_treasure_chest_pressed
signal equipment_slot_selected(index: int)
signal consumable_slot_selected(index: int)
signal hud_sell_slot_requested(slot_type: String, slot_index: int)

const TOP_HEADER_SCENE := preload("res://scenes/ui/top_header.tscn")
const COLLECTION_CARD_RENDERER := preload("res://scripts/ui/collection_card_renderer.gd")
const SHOP_ACTION_ROW_PRESENTER := preload("res://scripts/shop/shop_action_row_presenter.gd")
const SHOP_COPY_FORMATTER := preload("res://scripts/shop/shop_copy_formatter.gd")
const SHOP_LAYOUT_METRICS := preload("res://scripts/shop/shop_layout_metrics.gd")
const SHOP_HELP_MODAL_PRESENTER := preload("res://scripts/shop/shop_help_modal_presenter.gd")
const SHOP_PLAYER_HUD_PRESENTER := preload("res://scripts/shop/shop_player_hud_presenter.gd")
const SHOP_RELIC_CARD_PRESENTER := preload("res://scripts/shop/shop_relic_card_presenter.gd")
const SHOP_TREASURE_CHEST_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_treasure_chest_overlay_presenter.gd")
const SHOP_TUTORIAL_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_tutorial_overlay_presenter.gd")
const SHOP_VIEW_CHROME_STYLER := preload("res://scripts/shop/shop_view_chrome_styler.gd")
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
const OFFER_CARD_SIZE := SHOP_LAYOUT_METRICS.OFFER_CARD_SIZE
const OFFER_CARD_GAP := SHOP_LAYOUT_METRICS.OFFER_CARD_GAP
const OFFER_GRID_RECT := SHOP_LAYOUT_METRICS.OFFER_GRID_RECT
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
var _shop_help_modal_presenter: Variant = null
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
var _action_row_presenter: Variant = null
var _player_hud_presenter: Variant = null
var _treasure_chest_overlay_presenter: Variant = null
var _tutorial_overlay_presenter: Variant = null

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
	_player_hud_presenter.bind_player_hud(_hud_overlay, 51)
	_player_hud_presenter.set_layout_override(_shop_player_hud_layout_override())
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
	_settings_button.tooltip_text = "Settings"
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
	_speech_label = SHOP_VIEW_NODE_FACTORY.make_label(
		"SpeechLabel", _speech_card, "Well met, adventurer. New stock, fresh from the depths.", 25, INK_COLOR, HORIZONTAL_ALIGNMENT_LEFT, true
	)
	_boss_preview_label = SHOP_VIEW_NODE_FACTORY.make_label("BossPreviewLabel", _speech_card, "Boss preview: -", 20, MUTED_COLOR)
	_summary_label = SHOP_VIEW_NODE_FACTORY.make_label("SummaryLabel", _merchant_stage, "-", 21, POSITIVE_COLOR)
	_detail_label = SHOP_VIEW_NODE_FACTORY.make_label(
		"DetailLabel",
		_merchant_stage,
		"Tap stock or relic cards to buy. Sell: tap a filled loadout slot, then press Sell in the slot popover.",
		20,
		INK_COLOR,
		HORIZONTAL_ALIGNMENT_LEFT,
		true
	)
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
	_action_row_presenter = SHOP_ACTION_ROW_PRESENTER.new()
	_action_row_presenter.bind(_layout_root, _visuals)
	_action_row_presenter.ensure_row()

	_player_hud_presenter = SHOP_PLAYER_HUD_PRESENTER.new()
	_player_hud_presenter.bind(_layout_root, _player_loadout_hud, _visuals)
	_player_hud_presenter.ensure_scene()
	_treasure_chest_overlay_presenter = SHOP_TREASURE_CHEST_OVERLAY_PRESENTER.new()
	_treasure_chest_overlay_presenter.bind(_layout_root, _visuals, Callable(self, "_lookup_content_definition"))
	_treasure_chest_overlay_presenter.ensure_overlay()

	_shop_help_modal_presenter = SHOP_HELP_MODAL_PRESENTER.new()
	_shop_help_modal_presenter.bind(_layout_root)
	_shop_help_modal_presenter.ensure_modal()
	_tutorial_overlay_presenter = SHOP_TUTORIAL_OVERLAY_PRESENTER.new()
	(
		_tutorial_overlay_presenter
		. bind(
			_hud_overlay,
			{
				"offer_cards": _offer_cards,
				"reroll_button": _action_row_presenter.reroll_button(),
				"continue_button": _action_row_presenter.continue_button(),
			}
		)
	)
	_tutorial_overlay_presenter.ensure_overlay()


func _connect_signals() -> void:
	for index in _offer_cards.size():
		_offer_cards[index].pressed.connect(func(): emit_signal("offer_pressed", index))
	_relic_card.pressed.connect(_emit_relic_pressed)
	_action_row_presenter.reroll_pressed.connect(_emit_reroll_pressed)
	_action_row_presenter.sell_pressed.connect(_emit_sell_pressed)
	_action_row_presenter.continue_pressed.connect(_emit_continue_pressed)
	_main_menu_button.pressed.connect(_emit_main_menu_pressed)
	_help_button.pressed.connect(_on_help_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_treasure_chest_overlay_presenter.option_pressed.connect(_emit_treasure_chest_option_pressed)
	_treasure_chest_overlay_presenter.skip_pressed.connect(_emit_skip_treasure_chest_pressed)
	_player_hud_presenter.equipment_slot_selected.connect(_emit_equipment_slot_selected)
	_player_hud_presenter.consumable_slot_selected.connect(_emit_consumable_slot_selected)
	_player_hud_presenter.sell_slot_requested.connect(_emit_hud_sell_slot_requested)


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

	SHOP_RELIC_CARD_PRESENTER.render(_relic_card, _visuals, Dictionary(shop_snapshot.get("relic_offer", {})), treasure_chest_pending)
	_render_action_row(shop_snapshot, treasure_chest_pending)
	_render_build_panel(snapshot)
	_render_elemental_mastery_panel(Dictionary(progression_snapshot.get("mastery_levels", {})))
	_treasure_chest_overlay_presenter.render(pending_options)
	_tutorial_overlay_presenter.render(_current_tutorial_shop_phase)
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
	(
		COLLECTION_CARD_RENDERER
		. render_card(
			card,
			_visuals,
			card_data,
			{
				"disabled": disabled,
				"tooltip_text": "",
				"mouse_cursor": Control.CURSOR_ARROW if disabled else Control.CURSOR_POINTING_HAND,
				"modulate":
				(
					Color(0.45, 0.45, 0.48, 0.52)
					if disabled and _current_tutorial_shop_phase != ""
					else Color(0.58, 0.58, 0.60, 0.72) if disabled else Color.WHITE
				),
			}
		)
	)


func _render_empty_offer_card(card: Button) -> void:
	SHOP_VIEW_NODE_FACTORY.clear_children(card)
	card.text = ""
	card.disabled = true
	card.modulate = Color(0.65, 0.65, 0.70, 0.75)
	card.tooltip_text = ""
	SHOP_VIEW_CHROME_STYLER.apply_card_chrome(card, Color(0.05, 0.06, 0.08, 0.90), Color(0.24, 0.27, 0.34, 0.95), Color(0.05, 0.06, 0.08, 0.98))
	var root := SHOP_VIEW_NODE_FACTORY.make_child_root(card)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(root, "EMPTY", Rect2(Vector2(20, 190), Vector2(280, 50)), MUTED_COLOR, 24, HORIZONTAL_ALIGNMENT_CENTER)
	SHOP_VIEW_NODE_FACTORY.make_dynamic_label(
		root, "No offer in this slot.", Rect2(Vector2(28, 250), Vector2(264, 50)), MUTED_COLOR, 20, HORIZONTAL_ALIGNMENT_CENTER, true
	)


func _render_action_row(shop_snapshot: Dictionary, treasure_chest_pending: bool) -> void:
	_action_row_presenter.render(shop_snapshot, treasure_chest_pending)


func _render_build_panel(snapshot: Dictionary) -> void:
	_player_hud_presenter.render_player_build(snapshot)


func _render_elemental_mastery_panel(mastery_levels: Dictionary) -> void:
	_player_hud_presenter.render_elemental_mastery_panel(mastery_levels)


func set_status(message: String, positive: bool) -> void:
	if _summary_label == null:
		return
	_summary_label.text = message
	_summary_label.add_theme_color_override("font_color", POSITIVE_COLOR if positive else NEGATIVE_COLOR)


func lock_transitions(enabled: bool) -> void:
	if _action_row_presenter != null and _action_row_presenter.continue_button() != null:
		_action_row_presenter.continue_button().disabled = enabled
	if _main_menu_button != null:
		_main_menu_button.disabled = enabled
	if _help_button != null:
		_help_button.disabled = enabled
	if _settings_button != null:
		_settings_button.disabled = enabled


func play_purchase_feedback(kind: String, index: int = -1) -> void:
	var target: Control = null
	match kind:
		"offer":
			if index >= 0 and index < _offer_cards.size():
				target = _offer_cards[index]
		"relic":
			target = _relic_card
	if target == null or not is_instance_valid(target):
		return
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2.ONE
	var tween := target.create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2(0.94, 0.94), 0.07).set_trans(Tween.TRANS_BACK as Tween.TransitionType).set_ease(
		Tween.EASE_IN as Tween.EaseType
	)
	tween.tween_property(target, "modulate", Color(1.0, 0.92, 0.58, 1.0), 0.07)
	tween.chain().tween_property(target, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_BACK as Tween.TransitionType).set_ease(
		Tween.EASE_OUT as Tween.EaseType
	)
	tween.parallel().tween_property(target, "modulate", Color.WHITE, 0.12)
	tween.chain().tween_property(target, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(
		Tween.EASE_OUT as Tween.EaseType
	)
	_flash_purchase_stat_targets()
	_spawn_purchase_confirmation_label(target.get_global_rect())


func handle_global_input(event: InputEvent) -> bool:
	if _shop_help_modal_presenter != null and _shop_help_modal_presenter.handle_global_input(event):
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		return _player_hud_presenter.handle_global_click((event as InputEventMouseButton).position)
	if event is InputEventScreenTouch and event.pressed:
		return _player_hud_presenter.handle_global_click((event as InputEventScreenTouch).position)
	return false


func clear_inventory_focus() -> void:
	_player_hud_presenter.clear_inventory_focus()


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
	_shop_help_modal_presenter.show()


func _on_settings_pressed() -> void:
	emit_signal("settings_pressed")


func _emit_skip_treasure_chest_pressed() -> void:
	emit_signal("skip_treasure_chest_pressed")


func _emit_treasure_chest_option_pressed(index: int) -> void:
	emit_signal("treasure_chest_option_pressed", index)


func _emit_equipment_slot_selected(index: int) -> void:
	emit_signal("equipment_slot_selected", index)


func _emit_consumable_slot_selected(index: int) -> void:
	emit_signal("consumable_slot_selected", index)


func _emit_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	emit_signal("hud_sell_slot_requested", slot_type, slot_index)


func _flash_purchase_stat_targets() -> void:
	for target in [_gold_pill, _gold_label, _summary_label]:
		var control := target as Control
		if control == null or not is_instance_valid(control):
			continue
		control.modulate = Color.WHITE
		var tween := control.create_tween()
		tween.tween_property(control, "modulate", Color(1.0, 0.88, 0.46, 1.0), 0.08)
		tween.tween_property(control, "modulate", Color.WHITE, 0.20)


func _spawn_purchase_confirmation_label(target_global_rect: Rect2) -> void:
	if _hud_overlay == null or not is_instance_valid(_hud_overlay):
		return
	var label := Label.new()
	label.text = "BOUGHT"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.38, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.02, 0.01, 1.0))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.size = Vector2(180, 44)
	label.pivot_offset = label.size * 0.5
	label.z_index = 80
	_hud_overlay.add_child(label)
	var target_center := target_global_rect.get_center()
	var local_center := _hud_overlay.get_global_transform_with_canvas().affine_inverse() * target_center
	label.position = local_center + Vector2(-label.size.x * 0.5, -target_global_rect.size.y * 0.58)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 34.0, 0.52).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(
		Tween.EASE_OUT as Tween.EaseType
	)
	tween.tween_property(label, "modulate:a", 0.0, 0.36).set_delay(0.18)
	tween.finished.connect(
		func() -> void:
			if is_instance_valid(label):
				label.queue_free()
	)


func _lookup_content_definition(content_id: String) -> Dictionary:
	return _player_hud_presenter.lookup_content_definition(content_id)


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
	_player_hud_presenter.set_layout_override(_current_player_hud_layout_override)
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
	_action_row_presenter.layout(action_rect)

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

	_apply_rect(_hud_overlay, Rect2(Vector2.ZERO, logical_size))

	_player_hud_presenter.update_layout()

	_treasure_chest_overlay_presenter.layout(logical_size)
	_shop_help_modal_presenter.layout(logical_size)
	_tutorial_overlay_presenter.layout(logical_size)


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _shop_player_hud_nodes() -> Dictionary:
	if _player_hud_presenter == null:
		return SHOP_PLAYER_HUD_PRESENTER.empty_hud_nodes()
	return _player_hud_presenter.hud_nodes()


func _apply_visual_chrome() -> void:
	for panel in [_stock_panel]:
		(panel as Panel).add_theme_stylebox_override(
			"panel", UI_UTILS.panel_style(Color(0.04, 0.06, 0.08, 0.92), Color(0.58, 0.43, 0.20, 0.96), 2, 8, Vector4(8, 6, 8, 6))
		)
	_merchant_stage.add_theme_stylebox_override(
		"panel", UI_UTILS.panel_style(Color(0.03, 0.04, 0.05, 0.55), Color(0.70, 0.50, 0.22, 0.98), 2, 8, Vector4(8, 6, 8, 6))
	)
	_speech_card.add_theme_stylebox_override(
		"panel", UI_UTILS.panel_style(Color(0.04, 0.04, 0.04, 0.84), Color(0.74, 0.55, 0.28, 0.98), 2, 8, Vector4(8, 6, 8, 6))
	)
	_treasure_chest_overlay_presenter.apply_chrome()
	_shop_help_modal_presenter.apply_chrome()
	_action_row_presenter.apply_chrome()

	for label in [_stock_title_label, _merchant_header_label]:
		(label as Label).add_theme_color_override("font_color", GOLD_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	for label in [_boss_preview_label]:
		(label as Label).add_theme_color_override("font_color", MUTED_COLOR)
	_detail_label.add_theme_color_override("font_color", INK_COLOR)
	for label in [_speech_label]:
		(label as Label).add_theme_color_override("font_color", INK_COLOR)
		(label as Label).add_theme_constant_override("outline_size", 2)
		(label as Label).add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	_player_hud_presenter.apply_chrome()


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
	return SHOP_PLAYER_HUD_PRESENTER.player_hud_scene_path()
