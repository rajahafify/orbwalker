extends RefCounted
class_name ShopService

const ITEM_TYPE_EQUIPMENT := "equipment"
const ITEM_TYPE_CONSUMABLE := "consumable"
const ITEM_TYPE_MASTERY_CARD := "mastery_card"
const ITEM_TYPE_BOOSTER := "booster"
const ITEM_TYPE_RELIC := "relic"

const DEFAULT_PRICING := {
	"rarity_base": {
		"common": 10,
		"uncommon": 16,
		"rare": 24,
	},
	"level_step": 2,
	"reroll_base": 1,
	"reroll_step": 1,
}

var _rng := RandomNumberGenerator.new()
var _seeded: bool = false


func open_shop(run_state: Node, level: int = -1) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	var shop_level := maxi(1, level if level > 0 else run_state.dungeon_level)
	_ensure_rng_seeded()
	shop.open_for_level(shop_level)
	shop.item_offers = _generate_item_offers(run_state, content, shop_level)
	shop.reroll_cost = _compute_reroll_cost(shop.reroll_count, _pricing(content))
	shop.relic_offer = _resolve_relic_offer(run_state, content, shop_level)
	return _result(shop, run_state.run_gold, true, "")


func reroll_shop_items(run_state: Node) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if not shop.pending_booster_options.is_empty():
		return _result(shop, run_state.run_gold, false, "booster_pick_required")
	if not run_state.spend_gold(shop.reroll_cost):
		return _result(shop, run_state.run_gold, false, "insufficient_gold")

	shop.reroll_count += 1
	shop.item_offers = _generate_item_offers(run_state, content, shop.dungeon_level)
	shop.reroll_cost = _compute_reroll_cost(shop.reroll_count, _pricing(content))
	return _result(shop, run_state.run_gold, true, "")


func buy_offer(run_state: Node, offer_id: String) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if not shop.pending_booster_options.is_empty():
		return _result(shop, run_state.run_gold, false, "booster_pick_required")

	var item_index := _find_offer_index(shop.item_offers, offer_id)
	if item_index >= 0:
		var item_offer: Dictionary = shop.item_offers[item_index]
		if bool(item_offer.get("sold_out", false)):
			return _result(shop, run_state.run_gold, false, "offer_already_bought")
		if not run_state.spend_gold(int(item_offer.get("price", 0))):
			return _result(shop, run_state.run_gold, false, "insufficient_gold")
		var apply_result := _apply_offer(run_state, content, shop, item_offer)
		if not bool(apply_result.get("ok", false)):
			run_state.add_gold(int(item_offer.get("price", 0)))
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
			run_state.add_gold(int(shop.relic_offer.get("price", 0)))
			return _result(shop, run_state.run_gold, false, String(relic_apply.get("reason", "offer_apply_failed")))
		shop.relic_offer["sold_out"] = true
		shop.relic_offer["available"] = false
		run_state.set_relic_offer_id_for_level(shop.dungeon_level, "")
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
	run_state.add_gold(gold_gained)
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
	run_state.add_gold(gold_gained)
	return {
		"ok": true,
		"reason": "",
		"gold": run_state.run_gold,
		"result": sell_result.get("result", {}),
	}


func choose_booster_option(run_state: Node, option_index: int) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if shop.pending_booster_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_booster_options")
	if option_index < 0 or option_index >= shop.pending_booster_options.size():
		return _result(shop, run_state.run_gold, false, "invalid_booster_option")
	var option: Dictionary = shop.pending_booster_options[option_index]
	var apply_result := _apply_booster_option(run_state, content, option)
	if not bool(apply_result.get("ok", false)):
		return _result(shop, run_state.run_gold, false, String(apply_result.get("reason", "booster_apply_failed")))
	shop.pending_booster_options.clear()
	shop.pending_booster_offer_id = ""
	return _result(shop, run_state.run_gold, true, "", {
		"granted": option,
	})


func replace_pending_booster_option(run_state: Node, option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	var content = run_state.ensure_content_registry()
	var shop = run_state.ensure_shop_state()
	if not shop.active:
		return _result(shop, run_state.run_gold, false, "shop_not_active")
	if shop.pending_booster_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_booster_options")
	if option_index < 0 or option_index >= shop.pending_booster_options.size():
		return _result(shop, run_state.run_gold, false, "invalid_booster_option")
	var option: Dictionary = shop.pending_booster_options[option_index]
	var option_type := String(option.get("type", ""))
	if option_type != ITEM_TYPE_EQUIPMENT and option_type != ITEM_TYPE_CONSUMABLE:
		return _result(shop, run_state.run_gold, false, "unsupported_replacement_option")
	var apply_result := _apply_booster_option_to_slot(run_state, content, option, slot_index, sell_replaced)
	if not bool(apply_result.get("ok", false)):
		return _result(shop, run_state.run_gold, false, String(apply_result.get("reason", "booster_replace_failed")))
	shop.pending_booster_options.clear()
	shop.pending_booster_offer_id = ""
	return _result(shop, run_state.run_gold, true, "", {
		"granted": option,
		"replacement": apply_result.get("result", {}),
	})


func discard_pending_booster_options(run_state: Node) -> Dictionary:
	var shop = run_state.ensure_shop_state()
	if shop.pending_booster_options.is_empty():
		return _result(shop, run_state.run_gold, false, "no_pending_booster_options")
	shop.pending_booster_options.clear()
	shop.pending_booster_offer_id = ""
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
		ITEM_TYPE_BOOSTER:
			var booster_data: Dictionary = content.get_booster(content_id)
			shop.pending_booster_offer_id = String(offer.get("offer_id", ""))
			shop.pending_booster_options = _generate_booster_options(run_state, content, booster_data)
			return {
				"ok": not shop.pending_booster_options.is_empty(),
				"reason": "" if not shop.pending_booster_options.is_empty() else "booster_generated_no_options",
			}
		ITEM_TYPE_RELIC:
			return progression_service.add_relic(progression_state, content_id, content)
		_:
			return {
				"ok": false,
				"reason": "unsupported_offer_type",
			}


func _apply_booster_option(run_state: Node, content, option: Dictionary) -> Dictionary:
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
				"reason": "unsupported_booster_option",
			}


func _apply_booster_option_to_slot(run_state: Node, content, option: Dictionary, slot_index: int, sell_replaced: bool) -> Dictionary:
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
				run_state.add_gold(gold_gained)
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


func _resolve_relic_offer(run_state: Node, content, level: int) -> Dictionary:
	var owned_relic_ids := _owned_relic_ids(run_state)
	var relic_id: String = run_state.relic_offer_id_for_level(level)
	if relic_id != "" and owned_relic_ids.has(relic_id):
		relic_id = ""
		run_state.set_relic_offer_id_for_level(level, "")
	if relic_id == "":
		var relic_pool: Array = _available_relic_pool(run_state, content, level)
		if relic_pool.is_empty():
			return {}
		var chosen: Dictionary = relic_pool[_rng.randi_range(0, relic_pool.size() - 1)]
		relic_id = String(chosen.get("id", ""))
		run_state.set_relic_offer_id_for_level(level, relic_id)
	var relic_data: Dictionary = content.get_relic(relic_id)
	if relic_data.is_empty():
		return {}
	return _offer_from_content(
		content,
		ITEM_TYPE_RELIC,
		relic_data,
		level,
		run_state.ensure_shop_state().next_offer_id("relic")
	)


func _available_relic_pool(run_state: Node, content, level: int) -> Array:
	var owned_relic_ids := _owned_relic_ids(run_state)
	var pool: Array = []
	for relic_data in content.shop_relic_pool(level):
		var relic_id := String(Dictionary(relic_data).get("id", ""))
		if relic_id == "" or owned_relic_ids.has(relic_id):
			continue
		pool.append(relic_data)
	return pool


func _generate_item_offers(run_state: Node, content, level: int) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	var equipped_ids := _equipped_equipment_ids(run_state)
	for entry in content.shop_item_pool(level):
		var entry_type := String(entry.get("type", ""))
		var content_id := String(entry.get("id", ""))
		if entry_type == ITEM_TYPE_EQUIPMENT and equipped_ids.has(content_id):
			continue
		pool.append(entry)
	var selected_entries := _pick_random_entries(pool, 3)
	var offers: Array[Dictionary] = []
	for entry in selected_entries:
		var entry_type := String(entry.get("type", ""))
		var content_id := String(entry.get("id", ""))
		var content_data := _content_by_type(content, entry_type, content_id)
		if content_data.is_empty():
			continue
		offers.append(
			_offer_from_content(
				content,
				entry_type,
				content_data,
				level,
				run_state.ensure_shop_state().next_offer_id("item")
			)
		)
	return offers


func _generate_booster_options(run_state: Node, content, booster_data: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var options: Array[Dictionary] = []
	var target_orb_id := int(booster_data.get("target_orb_id", -1))
	var equipped_ids := _equipped_equipment_ids(run_state)

	for item in content.list_equipment():
		var item_id := String(item.get("id", ""))
		if item_id == "" or equipped_ids.has(item_id):
			continue
		if target_orb_id >= 0 and int(item.get("target_orb_id", -1)) != target_orb_id:
			continue
		candidates.append({
			"type": ITEM_TYPE_EQUIPMENT,
			"content_id": item_id,
			"display_name": String(item.get("display_name", "Equipment")),
		})
	for item in content.list_consumables():
		if target_orb_id >= 0 and int(item.get("target_orb_id", -1)) != target_orb_id:
			continue
		candidates.append({
			"type": ITEM_TYPE_CONSUMABLE,
			"content_id": String(item.get("id", "")),
			"display_name": String(item.get("display_name", "Consumable")),
		})
	for item in content.list_mastery_cards():
		if target_orb_id >= 0 and int(item.get("target_orb_id", -1)) != target_orb_id:
			continue
		candidates.append({
			"type": ITEM_TYPE_MASTERY_CARD,
			"content_id": String(item.get("id", "")),
			"display_name": String(item.get("display_name", "Mastery")),
		})

	if candidates.is_empty():
		return options

	var selected := _pick_random_entries(candidates, int(booster_data.get("option_count", 3)))
	for item in selected:
		options.append(item)
	return options


func _equipped_equipment_ids(run_state: Node) -> Dictionary:
	var equipped_ids := {}
	var progression_state = run_state.ensure_player_progression_state()
	for raw_id in progression_state.equipped_item_ids:
		var item_id := String(raw_id)
		if item_id != "":
			equipped_ids[item_id] = true
	return equipped_ids


func _owned_relic_ids(run_state: Node) -> Dictionary:
	var owned_ids := {}
	var progression_state = run_state.ensure_player_progression_state()
	for raw_id in progression_state.relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			owned_ids[relic_id] = true
	return owned_ids


func _offer_from_content(content, entry_type: String, data: Dictionary, level: int, offer_id: String) -> Dictionary:
	var rarity := String(data.get("rarity", "common"))
	var price := _compute_offer_price(data, rarity, level, _pricing(content))
	return {
		"offer_id": offer_id,
		"type": entry_type,
		"content_id": String(data.get("id", "")),
		"display_name": String(data.get("display_name", entry_type)),
		"description": String(data.get("description", "")),
		"icon_key": String(data.get("icon_key", "")),
		"rarity": rarity,
		"price": price,
		"sold_out": false,
		"available": true,
	}


func _content_by_type(content, entry_type: String, content_id: String) -> Dictionary:
	match entry_type:
		ITEM_TYPE_EQUIPMENT:
			return content.get_equipment(content_id)
		ITEM_TYPE_CONSUMABLE:
			return content.get_consumable(content_id)
		ITEM_TYPE_MASTERY_CARD:
			return content.get_mastery_card(content_id)
		ITEM_TYPE_BOOSTER:
			return content.get_booster(content_id)
		_:
			return {}


func _pick_random_entries(pool: Array, count: int) -> Array:
	var result: Array = []
	if pool.is_empty() or count <= 0:
		return result
	var mutable_pool := pool.duplicate(true)
	var picks := mini(count, mutable_pool.size())
	for _i in picks:
		var idx := _rng.randi_range(0, mutable_pool.size() - 1)
		result.append(mutable_pool[idx])
		mutable_pool.remove_at(idx)
	return result


func _find_offer_index(offers: Array[Dictionary], offer_id: String) -> int:
	for index in offers.size():
		if String(offers[index].get("offer_id", "")) == offer_id:
			return index
	return -1


func _pricing(content) -> Dictionary:
	var pricing: Dictionary = content.shop_pricing_config()
	if pricing.is_empty():
		return DEFAULT_PRICING
	return pricing


func _compute_offer_price(data: Dictionary, rarity: String, level: int, pricing: Dictionary) -> int:
	var base_price := int(data.get("base_price", 0))
	var default_rarity_base := int(DEFAULT_PRICING.get("rarity_base", {}).get("common", 10))
	var rarity_base := int(pricing.get("rarity_base", {}).get(rarity, default_rarity_base))
	var level_step := int(pricing.get("level_step", int(DEFAULT_PRICING.get("level_step", 2))))
	if base_price <= 0:
		base_price = rarity_base
	return maxi(1, base_price + (maxi(1, level) - 1) * level_step)


func _compute_reroll_cost(reroll_count: int, pricing: Dictionary) -> int:
	var reroll_base := int(pricing.get("reroll_base", int(DEFAULT_PRICING.get("reroll_base", 1))))
	var reroll_step := int(pricing.get("reroll_step", int(DEFAULT_PRICING.get("reroll_step", 1))))
	return maxi(0, reroll_base + reroll_count * reroll_step)


func _ensure_rng_seeded() -> void:
	if _seeded:
		return
	_rng.randomize()
	_seeded = true


func _result(shop, gold: int, ok: bool, reason: String, extra: Dictionary = {}) -> Dictionary:
	return {
		"ok": ok,
		"reason": reason,
		"gold": gold,
		"shop": shop.to_snapshot(),
		"result": extra,
	}
