extends RefCounted
class_name ShopService

const SHOP_OFFER_POLICY_SCRIPT := preload("res://scripts/shop/shop_offer_policy.gd")

const ITEM_TYPE_EQUIPMENT := "equipment"
const ITEM_TYPE_CONSUMABLE := "consumable"
const ITEM_TYPE_MASTERY_CARD := "mastery_card"
const ITEM_TYPE_TREASURE_CHEST := "treasure_chest"
const ITEM_TYPE_RELIC := "relic"

var _offer_policy: Variant = SHOP_OFFER_POLICY_SCRIPT.new()


func set_rng_seed(seed_value: int) -> void:
	_offer_policy.set_rng_seed(seed_value)


func randomize_rng() -> void:
	_offer_policy.randomize_rng()


func open_shop(run_state: Node, level: int = -1) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	var shop_level := maxi(1, level if level > 0 else run_state.dungeon_level)
	_offer_policy.ensure_rng_seeded()
	shop.open_for_level(shop_level)
	shop.item_offers = _offer_policy.item_offers(run_state, content, shop_level)
	shop.reroll_cost = _offer_policy.reroll_cost(content, shop.reroll_count)
	shop.relic_offer = _offer_policy.relic_offer(run_state, content, shop_level)
	return _result(shop, run_state.run_gold, true, "")


func reroll_shop_items(run_state: Node) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if not shop.pending_treasure_chest_options.is_empty():
		return _result(shop, run_state.run_gold, false, "treasure_chest_pick_required")
	if not run_state.spend_gold(shop.reroll_cost):
		return _result(shop, run_state.run_gold, false, "insufficient_gold")

	shop.reroll_count += 1
	shop.item_offers = _offer_policy.item_offers(run_state, content, shop.dungeon_level)
	shop.reroll_cost = _offer_policy.reroll_cost(content, shop.reroll_count)
	return _result(shop, run_state.run_gold, true, "")


func buy_offer(run_state: Node, offer_id: String) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if not shop.pending_treasure_chest_options.is_empty():
		return _result(shop, run_state.run_gold, false, "treasure_chest_pick_required")

	var item_index := _find_offer_index(shop.item_offers, offer_id)
	if item_index >= 0:
		var item_offer: Dictionary = shop.item_offers[item_index]
		if bool(item_offer.get("sold_out", false)):
			return _result(shop, run_state.run_gold, false, "offer_already_bought")
		if not run_state.spend_gold(int(item_offer.get("price", 0))):
			return _result(shop, run_state.run_gold, false, "insufficient_gold")
		var apply_result := _apply_offer(run_state, content, shop, item_offer)
		if not bool(apply_result.get("ok", false)):
			run_state.add_gold(int(item_offer.get("price", 0)), "shop_refund")
			return _result(shop, run_state.run_gold, false, String(apply_result.get("reason", "offer_apply_failed")))

		item_offer["sold_out"] = true
		shop.item_offers[item_index] = item_offer
		return _result(shop, run_state.run_gold, true, "", {
			"offer_id": offer_id,
			"type": String(item_offer.get("type", "")),
		})

	if String(shop.relic_offer.get("offer_id", "")) == offer_id:
		if bool(shop.relic_offer.get("sold_out", false)):
			return _result(shop, run_state.run_gold, false, "offer_already_bought")
		if not run_state.spend_gold(int(shop.relic_offer.get("price", 0))):
			return _result(shop, run_state.run_gold, false, "insufficient_gold")
		var relic_apply := _apply_offer(run_state, content, shop, shop.relic_offer)
		if not bool(relic_apply.get("ok", false)):
			run_state.add_gold(int(shop.relic_offer.get("price", 0)), "shop_refund")
			return _result(shop, run_state.run_gold, false, String(relic_apply.get("reason", "offer_apply_failed")))
		shop.relic_offer["sold_out"] = true
		shop.relic_offer["available"] = false
		run_state.set_relic_offer_id_for_level(shop.dungeon_level, String(shop.relic_offer.get("content_id", "")))
		return _result(shop, run_state.run_gold, true, "", {
			"offer_id": offer_id,
			"type": ITEM_TYPE_RELIC,
		})

	return _result(shop, run_state.run_gold, false, "offer_not_found")


func sell_equipped_item(run_state: Node, slot_index: int) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var progression_state = run_state.ensure_player_progression_state()
	var progression_service = run_state.ensure_player_progression_service()
	var sell_result: Dictionary = progression_service.sell_equipment(progression_state, slot_index, content)
	if not bool(sell_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(sell_result.get("reason", "sell_failed")),
			"gold": run_state.run_gold,
		}
	var gold_gained := int(sell_result.get("result", {}).get("gold_gained", 0))
	run_state.add_gold(gold_gained, "sell_refund")
	return {
		"ok": true,
		"reason": "",
		"gold": run_state.run_gold,
		"result": sell_result.get("result", {}),
	}


func sell_consumable_item(run_state: Node, slot_index: int) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var progression_state = run_state.ensure_player_progression_state()
	var progression_service = run_state.ensure_player_progression_service()
	var sell_result: Dictionary = progression_service.sell_consumable(progression_state, slot_index, content)
	if not bool(sell_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(sell_result.get("reason", "sell_failed")),
			"gold": run_state.run_gold,
		}
	var gold_gained := int(sell_result.get("result", {}).get("gold_gained", 0))
	run_state.add_gold(gold_gained, "sell_refund")
	return {
		"ok": true,
		"reason": "",
		"gold": run_state.run_gold,
		"result": sell_result.get("result", {}),
	}


func choose_treasure_chest_option(run_state: Node, option_index: int) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if shop.pending_treasure_chest_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_treasure_chest_options")
	if option_index < 0 or option_index >= shop.pending_treasure_chest_options.size():
		return _result(shop, run_state.run_gold, false, "invalid_treasure_chest_option")
	var option: Dictionary = shop.pending_treasure_chest_options[option_index]
	var apply_result := _apply_treasure_chest_option(run_state, content, option)
	if not bool(apply_result.get("ok", false)):
		return _result(shop, run_state.run_gold, false, String(apply_result.get("reason", "treasure_chest_apply_failed")))
	shop.pending_treasure_chest_options.clear()
	shop.pending_treasure_chest_offer_id = ""
	return _result(shop, run_state.run_gold, true, "", {
		"granted": option,
	})


func replace_pending_treasure_chest_option(run_state: Node, option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if shop.pending_treasure_chest_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_treasure_chest_options")
	if option_index < 0 or option_index >= shop.pending_treasure_chest_options.size():
		return _result(shop, run_state.run_gold, false, "invalid_treasure_chest_option")
	var option: Dictionary = shop.pending_treasure_chest_options[option_index]
	var option_type := String(option.get("type", ""))
	if option_type != ITEM_TYPE_EQUIPMENT and option_type != ITEM_TYPE_CONSUMABLE:
		return _result(shop, run_state.run_gold, false, "unsupported_replacement_option")
	var apply_result := _apply_treasure_chest_option_to_slot(run_state, content, option, slot_index, sell_replaced)
	if not bool(apply_result.get("ok", false)):
		return _result(shop, run_state.run_gold, false, String(apply_result.get("reason", "treasure_chest_replace_failed")))
	shop.pending_treasure_chest_options.clear()
	shop.pending_treasure_chest_offer_id = ""
	return _result(shop, run_state.run_gold, true, "", {
		"granted": option,
		"replacement": apply_result.get("result", {}),
	})


func discard_pending_treasure_chest_options(run_state: Node) -> Dictionary:
	var shop = run_state.ensure_shop_state()
	if shop.pending_treasure_chest_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_treasure_chest_options")
	shop.pending_treasure_chest_options.clear()
	shop.pending_treasure_chest_offer_id = ""
	return _result(shop, run_state.run_gold, true, "", {
		"discarded": true,
	})


func _apply_offer(run_state: Node, content, shop, offer: Dictionary) -> Dictionary:
	var offer_type := String(offer.get("type", ""))
	var content_id := String(offer.get("content_id", ""))
	var progression_state = run_state.ensure_player_progression_state()
	var progression_service = run_state.ensure_player_progression_service()

	match offer_type:
		ITEM_TYPE_EQUIPMENT:
			return progression_service.equip_item(progression_state, content_id, content)
		ITEM_TYPE_CONSUMABLE:
			return progression_service.add_consumable(progression_state, content_id, content)
		ITEM_TYPE_MASTERY_CARD:
			var mastery_data: Dictionary = content.get_mastery_card(content_id)
			return progression_service.grant_mastery(
				progression_state,
				int(mastery_data.get("target_orb_id", -1)),
				int(mastery_data.get("amount", 1))
			)
		ITEM_TYPE_TREASURE_CHEST:
			var treasure_chest_data: Dictionary = content.get_treasure_chest(content_id)
			shop.pending_treasure_chest_offer_id = String(offer.get("offer_id", ""))
			shop.pending_treasure_chest_options = _offer_policy.treasure_chest_options(run_state, content, treasure_chest_data)
			return {
				"ok": not shop.pending_treasure_chest_options.is_empty(),
				"reason": "" if not shop.pending_treasure_chest_options.is_empty() else "treasure_chest_generated_no_options",
			}
		ITEM_TYPE_RELIC:
			return progression_service.add_relic(progression_state, content_id, content)
		_:
			return {
				"ok": false,
				"reason": "unsupported_offer_type",
			}


func _apply_treasure_chest_option(run_state: Node, content, option: Dictionary) -> Dictionary:
	var progression_state = run_state.ensure_player_progression_state()
	var progression_service = run_state.ensure_player_progression_service()
	var option_type := String(option.get("type", ""))
	var content_id := String(option.get("content_id", ""))
	match option_type:
		ITEM_TYPE_EQUIPMENT:
			return progression_service.equip_item(progression_state, content_id, content)
		ITEM_TYPE_CONSUMABLE:
			return progression_service.add_consumable(progression_state, content_id, content)
		ITEM_TYPE_MASTERY_CARD:
			var mastery_data: Dictionary = content.get_mastery_card(content_id)
			return progression_service.grant_mastery(
				progression_state,
				int(mastery_data.get("target_orb_id", -1)),
				int(mastery_data.get("amount", 1))
			)
		_:
			return {
				"ok": false,
				"reason": "unsupported_treasure_chest_option",
			}


func _apply_treasure_chest_option_to_slot(run_state: Node, content, option: Dictionary, slot_index: int, sell_replaced: bool) -> Dictionary:
	var progression_state = run_state.ensure_player_progression_state()
	var progression_service = run_state.ensure_player_progression_service()
	var option_type := String(option.get("type", ""))
	var content_id := String(option.get("content_id", ""))
	match option_type:
		ITEM_TYPE_EQUIPMENT:
			var replaced_item_id := ""
			if slot_index >= 0 and slot_index < progression_state.equipped_item_ids.size():
				replaced_item_id = String(progression_state.equipped_item_ids[slot_index])
			if replaced_item_id == "":
				return {
					"ok": false,
					"reason": "replacement_slot_empty",
				}
			var replace_result: Dictionary = progression_service.replace_equipment(progression_state, slot_index, content_id, content)
			if not bool(replace_result.get("ok", false)):
				return replace_result
			var payload: Dictionary = replace_result.get("result", {})
			if sell_replaced and replaced_item_id != "":
				var replaced_data: Dictionary = content.get_equipment(replaced_item_id)
				var gold_gained := maxi(0, int(replaced_data.get("sell_value", replaced_data.get("base_price", 0))))
				run_state.add_gold(gold_gained, "replacement_sell_refund")
				payload["gold_gained"] = gold_gained
			return {
				"ok": true,
				"reason": "",
				"result": payload,
			}
		ITEM_TYPE_CONSUMABLE:
			if slot_index < 0 or slot_index >= progression_state.held_consumable_ids.size():
				return {
					"ok": false,
					"reason": "invalid_consumable_slot_index",
				}
			if String(progression_state.held_consumable_ids[slot_index]) == "":
				return {
					"ok": false,
					"reason": "replacement_slot_empty",
				}
			return progression_service.replace_consumable(progression_state, slot_index, content_id, content)
		_:
			return {
				"ok": false,
				"reason": "unsupported_replacement_option",
			}


func _find_offer_index(offers: Array[Dictionary], offer_id: String) -> int:
	for index in offers.size():
		if String(offers[index].get("offer_id", "")) == offer_id:
			return index
	return -1


func _result(shop, gold: int, ok: bool, reason: String, extra: Dictionary = {}) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"gold": gold,
		"shop": shop.to_snapshot(),
		"result": extra,
	}
