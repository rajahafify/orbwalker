extends Control

@onready var _title_label: Label = %TitleLabel
@onready var _run_progress_label: Label = %RunProgressLabel
@onready var _boss_preview_label: Label = %BossPreviewLabel
@onready var _summary_label: Label = %SummaryLabel
@onready var _detail_label: Label = %DetailLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _inventory_label: Label = %InventoryLabel
@onready var _mastery_label: Label = %MasteryLabel
@onready var _reroll_button: Button = %RerollButton
@onready var _relic_offer_button: Button = %RelicOfferButton
@onready var _item_offer_buttons: Array[Button] = [
	%ItemOfferButton1,
	%ItemOfferButton2,
	%ItemOfferButton3,
]
@onready var _booster_panel: VBoxContainer = %BoosterOptionsPanel
@onready var _booster_option_buttons: Array[Button] = [
	%BoosterOptionButton1,
	%BoosterOptionButton2,
	%BoosterOptionButton3,
]
@onready var _sell_slot_spin_box: SpinBox = %SellSlotSpinBox


func _ready() -> void:
	if not RunState.run_active:
		_title_label.text = "Shop"
		_summary_label.text = "No active run. Returning to main menu."
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		return
	if not RunState.is_current_step_shop():
		get_tree().call_deferred("change_scene_to_file", RunState.next_scene_path())
		return

	_title_label.text = "Shop - %s" % RunState.level_sequence_label()
	var open_result: Dictionary = RunState.open_shop_for_current_level()
	if bool(open_result.get("ok", false)):
		_summary_label.text = "Shop opened. Buy, reroll, sell, or skip."
	else:
		_summary_label.text = "Failed to open shop: %s" % String(open_result.get("reason", "unknown"))
	_refresh_ui()


func _refresh_ui() -> void:
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	_title_label.text = "Shop - %s" % RunState.level_sequence_label()
	_run_progress_label.text = "Run: %s" % RunState.level_sequence_label()
	_boss_preview_label.text = "Boss preview: %s" % RunState.current_level_boss_name()
	_gold_label.text = "Gold: %d" % RunState.run_gold
	_reroll_button.text = "Reroll (%d)" % int(shop_snapshot.get("reroll_cost", 0))
	_reroll_button.disabled = not bool(shop_snapshot.get("active", false))

	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for index in _item_offer_buttons.size():
		var button := _item_offer_buttons[index]
		if index >= item_offers.size():
			button.text = "Empty slot"
			button.disabled = true
			continue
		var offer: Dictionary = item_offers[index]
		button.text = _offer_button_text(offer)
		button.disabled = bool(offer.get("sold_out", false))

	var relic_offer: Dictionary = shop_snapshot.get("relic_offer", {})
	if relic_offer.is_empty():
		_relic_offer_button.text = "Relic offer unavailable"
		_relic_offer_button.disabled = true
	else:
		_relic_offer_button.text = "Relic: %s" % _offer_button_text(relic_offer)
		_relic_offer_button.disabled = bool(relic_offer.get("sold_out", false))

	var pending_options: Array = shop_snapshot.get("pending_booster_options", [])
	_booster_panel.visible = not pending_options.is_empty()
	for index in _booster_option_buttons.size():
		var option_button := _booster_option_buttons[index]
		if index >= pending_options.size():
			option_button.text = "Option %d" % (index + 1)
			option_button.disabled = true
			continue
		var option: Dictionary = pending_options[index]
		option_button.text = "Pick: %s (%s)" % [
			String(option.get("display_name", "Option")),
			String(option.get("type", "")),
		]
		option_button.disabled = false

	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	var relic_ids: Array = progression_snapshot.get("relic_ids", [])
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	_inventory_label.text = "Equipment: %s\nConsumables: %s\nRelics: %s" % [
		_format_slot_line(equipment_slots),
		_format_slot_line(consumable_slots),
		_format_id_line(relic_ids),
	]
	_mastery_label.text = "Mastery: %s" % _format_mastery_line(mastery_levels)


func _offer_button_text(offer: Dictionary) -> String:
	var display_name := String(offer.get("display_name", "Offer"))
	var description := String(offer.get("description", ""))
	var offer_type := String(offer.get("type", ""))
	var price := int(offer.get("price", 0))
	var sold_out := bool(offer.get("sold_out", false))
	var status := "SOLD" if sold_out else "Buy"
	if description == "":
		return "%s [%s] - %dg (%s)" % [display_name, offer_type, price, status]
	return "%s [%s] - %dg (%s)\n%s" % [display_name, offer_type, price, status, description]


func _buy_offer_at(index: int) -> void:
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var item_offers: Array = shop_snapshot.get("item_offers", [])
	if index < 0 or index >= item_offers.size():
		return
	var offer_id := String(Dictionary(item_offers[index]).get("offer_id", ""))
	var result: Dictionary = RunState.buy_shop_offer(offer_id)
	_summary_label.text = _result_message("Buy offer", result)
	_detail_label.text = "Details: %s" % _lookup_offer_details(offer_id, shop_snapshot)
	_refresh_ui()


func _buy_relic_offer() -> void:
	var relic_offer: Dictionary = RunState.ensure_shop_state().relic_offer
	if relic_offer.is_empty():
		return
	var result: Dictionary = RunState.buy_shop_offer(String(relic_offer.get("offer_id", "")))
	_summary_label.text = _result_message("Buy relic", result)
	_detail_label.text = "Details: %s" % String(relic_offer.get("description", "No additional details."))
	_refresh_ui()


func _on_item_offer_button_1_pressed() -> void:
	_buy_offer_at(0)


func _on_item_offer_button_2_pressed() -> void:
	_buy_offer_at(1)


func _on_item_offer_button_3_pressed() -> void:
	_buy_offer_at(2)


func _on_relic_offer_button_pressed() -> void:
	_buy_relic_offer()


func _on_reroll_button_pressed() -> void:
	var result: Dictionary = RunState.reroll_shop_items()
	_summary_label.text = _result_message("Reroll", result)
	_detail_label.text = "Details: Shop offers rerolled."
	_refresh_ui()


func _on_sell_equipment_button_pressed() -> void:
	var slot_index := int(_sell_slot_spin_box.value)
	var result: Dictionary = RunState.sell_equipped_item(slot_index)
	_summary_label.text = _result_message("Sell equipment", result)
	_detail_label.text = "Details: Sold equipment slot %d." % slot_index
	_refresh_ui()


func _choose_booster_option(index: int) -> void:
	var result: Dictionary = RunState.choose_booster_option(index)
	_summary_label.text = _result_message("Booster pick", result)
	_detail_label.text = "Details: Booster option %d selected." % (index + 1)
	_refresh_ui()


func _on_booster_option_button_1_pressed() -> void:
	_choose_booster_option(0)


func _on_booster_option_button_2_pressed() -> void:
	_choose_booster_option(1)


func _on_booster_option_button_3_pressed() -> void:
	_choose_booster_option(2)


func _on_skip_shop_button_pressed() -> void:
	var transition: Dictionary = RunState.advance_after_shop(true)
	get_tree().change_scene_to_file(String(transition.get("next_scene", "res://scenes/main.tscn")))


func _on_next_fight_button_pressed() -> void:
	var transition: Dictionary = RunState.advance_after_shop(false)
	get_tree().change_scene_to_file(String(transition.get("next_scene", "res://scenes/main.tscn")))


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _result_message(action: String, result: Dictionary) -> String:
	var ok := bool(result.get("ok", false))
	var reason := String(result.get("reason", ""))
	if ok:
		return "%s: OK (Gold %d)" % [action, RunState.run_gold]
	return "%s: FAILED (%s)" % [action, reason]


func _format_slot_line(slot_values: Array) -> String:
	var parts: Array[String] = []
	for value in slot_values:
		var text := String(value)
		parts.append(text if text != "" else "-")
	return "[" + ", ".join(parts) + "]"


func _format_id_line(values: Array) -> String:
	if values.is_empty():
		return "-"
	var parts: Array[String] = []
	for value in values:
		parts.append(String(value))
	return "[" + ", ".join(parts) + "]"


func _format_mastery_line(levels: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		parts.append("%s:%d" % [OrbType.debug_symbol(orb_id), int(levels.get(orb_id, 0))])
	return "[" + ", ".join(parts) + "]"


func _lookup_offer_details(offer_id: String, shop_snapshot: Dictionary) -> String:
	var item_offers: Array = shop_snapshot.get("item_offers", [])
	for raw_offer in item_offers:
		var offer: Dictionary = raw_offer
		if String(offer.get("offer_id", "")) == offer_id:
			var description := String(offer.get("description", "No additional details."))
			return "%s" % description
	var relic_offer: Dictionary = shop_snapshot.get("relic_offer", {})
	if String(relic_offer.get("offer_id", "")) == offer_id:
		return String(relic_offer.get("description", "No additional details."))
	return "No additional details."
