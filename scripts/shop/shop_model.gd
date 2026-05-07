extends RefCounted
class_name ShopModel

const DEFAULT_STATUS := "Shop opened. Buy, reroll, sell, or continue."

var selected_equipment_slot := -1
var selected_consumable_slot := -1
var status_message := DEFAULT_STATUS
var status_positive := true
var transition_locked := false
var action_guard_frame := -1


func reset_status() -> void:
	status_message = DEFAULT_STATUS
	status_positive = true


func set_status(message: String, positive: bool) -> void:
	status_message = message
	status_positive = positive


func clear_inventory_focus() -> void:
	selected_equipment_slot = -1
	selected_consumable_slot = -1


func try_begin_shop_action() -> bool:
	var frame := Engine.get_process_frames()
	if action_guard_frame == frame:
		return false
	action_guard_frame = frame
	return true


func selected_slot_kind(progression_snapshot: Dictionary) -> String:
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if selected_equipment_slot >= 0 and selected_equipment_slot < equipment_slots.size() and String(equipment_slots[selected_equipment_slot]) != "":
		return "equipment"
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if selected_consumable_slot >= 0 and selected_consumable_slot < consumable_slots.size() and String(consumable_slots[selected_consumable_slot]) != "":
		return "consumable"
	return ""


func snapshot() -> Dictionary:
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var pending_options: Array = shop_snapshot.get("pending_treasure_chest_options", [])
	var treasure_chest_pending := not pending_options.is_empty()
	_validate_selected_slots(progression_snapshot)
	_enrich_shop_snapshot(shop_snapshot, treasure_chest_pending)
	return {
		"shop": shop_snapshot,
		"progression": progression_snapshot,
		"player_state": RunState.ensure_player_state(),
		"gold": RunState.run_gold,
		"dungeon_level": RunState.dungeon_level,
		"shop_ordinal": maxi(1, RunState.current_shop_ordinal_in_level()),
		"boss_preview": RunState.current_level_boss_name(),
		"pending_treasure_chest_options": pending_options,
		"treasure_chest_pending": treasure_chest_pending,
		"selected_equipment_slot": selected_equipment_slot,
		"selected_consumable_slot": selected_consumable_slot,
		"status_message": status_message,
		"status_positive": status_positive,
		"transition_locked": transition_locked,
	}


func offer_enabled_state(offer: Dictionary, treasure_chest_pending: bool) -> Dictionary:
	var sold_out := bool(offer.get("sold_out", false))
	var price := int(offer.get("price", 0))
	var affordable := RunState.can_afford(price)
	return {
		"sold_out": sold_out,
		"price": price,
		"affordable": affordable,
		"disabled": sold_out or treasure_chest_pending or not affordable,
	}


func reroll_enabled(shop_snapshot: Dictionary, treasure_chest_pending: bool) -> bool:
	return (
		bool(shop_snapshot.get("active", false))
		and not treasure_chest_pending
		and RunState.can_afford(int(shop_snapshot.get("reroll_cost", 0)))
	)


func begin_transition_lock() -> void:
	transition_locked = true


func end_transition_lock() -> void:
	transition_locked = false


func _validate_selected_slots(progression_snapshot: Dictionary) -> void:
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if selected_equipment_slot >= equipment_slots.size() or (selected_equipment_slot >= 0 and String(equipment_slots[selected_equipment_slot]) == ""):
		selected_equipment_slot = -1
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if selected_consumable_slot >= consumable_slots.size() or (selected_consumable_slot >= 0 and String(consumable_slots[selected_consumable_slot]) == ""):
		selected_consumable_slot = -1


func _enrich_shop_snapshot(shop_snapshot: Dictionary, treasure_chest_pending: bool) -> void:
	var item_offers: Array = []
	for raw_offer in shop_snapshot.get("item_offers", []):
		var offer := Dictionary(raw_offer).duplicate(true)
		offer.merge(offer_enabled_state(offer, treasure_chest_pending), true)
		item_offers.append(offer)
	shop_snapshot["item_offers"] = item_offers

	var relic_offer := Dictionary(shop_snapshot.get("relic_offer", {})).duplicate(true)
	if not relic_offer.is_empty():
		relic_offer.merge(offer_enabled_state(relic_offer, treasure_chest_pending), true)
	shop_snapshot["relic_offer"] = relic_offer
	shop_snapshot["reroll_enabled"] = reroll_enabled(shop_snapshot, treasure_chest_pending)
