extends RefCounted
class_name ShopOfferTypeHandlers

const ITEM_TYPE_EQUIPMENT := "equipment"
const ITEM_TYPE_CONSUMABLE := "consumable"
const ITEM_TYPE_MASTERY_CARD := "mastery_card"
const ITEM_TYPE_TREASURE_CHEST := "treasure_chest"
const ITEM_TYPE_RELIC := "relic"


class EquipmentHandler:
	extends RefCounted

	func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
		return _progression_service(context).equip_item(_progression_state(context), String(offer.get("content_id", "")), context.get("content"))

	func apply_treasure_chest_option(context: Dictionary, option: Dictionary) -> Dictionary:
		return apply_offer(context, option)

	func replace_treasure_chest_option(context: Dictionary, option: Dictionary, slot_index: int, sell_replaced: bool) -> Dictionary:
		var progression_state = _progression_state(context)
		var content = context.get("content")
		var replaced_item_id := ""
		if slot_index >= 0 and slot_index < progression_state.equipped_item_ids.size():
			replaced_item_id = String(progression_state.equipped_item_ids[slot_index])
		if replaced_item_id == "":
			return {"ok": false, "reason": "replacement_slot_empty"}
		var replace_result: Dictionary = _progression_service(context).replace_equipment(
			progression_state, slot_index, String(option.get("content_id", "")), content
		)
		if not bool(replace_result.get("ok", false)):
			return replace_result
		var payload: Dictionary = replace_result.get("result", {})
		if sell_replaced and replaced_item_id != "":
			var replaced_data: Dictionary = content.get_equipment(replaced_item_id)
			var gold_gained := maxi(0, int(replaced_data.get("sell_value", replaced_data.get("base_price", 0))))
			context.get("run_state").add_gold(gold_gained, "replacement_sell_refund")
			payload["gold_gained"] = gold_gained
		return {"ok": true, "reason": "", "result": payload}

	func _progression_state(context: Dictionary) -> Variant:
		return context.get("progression_state")

	func _progression_service(context: Dictionary) -> Variant:
		return context.get("progression_service")


class ConsumableHandler:
	extends RefCounted

	func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
		return _progression_service(context).add_consumable(_progression_state(context), String(offer.get("content_id", "")), context.get("content"))

	func apply_treasure_chest_option(context: Dictionary, option: Dictionary) -> Dictionary:
		return apply_offer(context, option)

	func replace_treasure_chest_option(context: Dictionary, option: Dictionary, slot_index: int, _sell_replaced: bool) -> Dictionary:
		var progression_state = _progression_state(context)
		if slot_index < 0 or slot_index >= progression_state.held_consumable_ids.size():
			return {"ok": false, "reason": "invalid_consumable_slot_index"}
		if String(progression_state.held_consumable_ids[slot_index]) == "":
			return {"ok": false, "reason": "replacement_slot_empty"}
		return _progression_service(context).replace_consumable(progression_state, slot_index, String(option.get("content_id", "")), context.get("content"))

	func _progression_state(context: Dictionary) -> Variant:
		return context.get("progression_state")

	func _progression_service(context: Dictionary) -> Variant:
		return context.get("progression_service")


class MasteryCardHandler:
	extends RefCounted

	func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
		var content = context.get("content")
		var mastery_data: Dictionary = content.get_mastery_card(String(offer.get("content_id", "")))
		return context.get("progression_service").grant_mastery(
			context.get("progression_state"), int(mastery_data.get("target_orb_id", -1)), int(mastery_data.get("amount", 1))
		)

	func apply_treasure_chest_option(context: Dictionary, option: Dictionary) -> Dictionary:
		return apply_offer(context, option)


class TreasureChestHandler:
	extends RefCounted

	func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
		var content = context.get("content")
		var shop = context.get("shop")
		var treasure_chest_data: Dictionary = content.get_treasure_chest(String(offer.get("content_id", "")))
		shop.pending_treasure_chest_offer_id = String(offer.get("offer_id", ""))
		shop.pending_treasure_chest_options = context.get("offer_policy").treasure_chest_options(context.get("run_state"), content, treasure_chest_data)
		return {
			"ok": not shop.pending_treasure_chest_options.is_empty(),
			"reason": "" if not shop.pending_treasure_chest_options.is_empty() else "treasure_chest_generated_no_options",
		}


class RelicHandler:
	extends RefCounted

	func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
		return context.get("progression_service").add_relic(context.get("progression_state"), String(offer.get("content_id", "")), context.get("content"))


static func default_handlers() -> Dictionary:
	return {
		ITEM_TYPE_EQUIPMENT: EquipmentHandler.new(),
		ITEM_TYPE_CONSUMABLE: ConsumableHandler.new(),
		ITEM_TYPE_MASTERY_CARD: MasteryCardHandler.new(),
		ITEM_TYPE_TREASURE_CHEST: TreasureChestHandler.new(),
		ITEM_TYPE_RELIC: RelicHandler.new(),
	}
