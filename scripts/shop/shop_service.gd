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
	"reroll_max": 30,
}
const SHOP_MULTIPLIER_MIN := 0.1

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


func _resolve_relic_offer(run_state: Node, content, level: int) -> Dictionary:
	var owned_relic_ids := _owned_relic_ids(run_state)
	var relic_id: String = run_state.relic_offer_id_for_level(level)
	var cached_offer_owned := false
	if relic_id != "" and owned_relic_ids.has(relic_id):
		cached_offer_owned = true
	if relic_id != "" and content.get_relic(relic_id).is_empty():
		relic_id = ""
		run_state.set_relic_offer_id_for_level(level, "")
	if relic_id == "":
		var relic_pool: Array = _available_relic_pool(run_state, content, level)
		if relic_pool.is_empty():
			return {}
		var chosen: Dictionary = relic_pool[_rng.randi_range(0, relic_pool.size() - 1)]
		relic_id = String(chosen.get("id", ""))
		run_state.set_relic_offer_id_for_level(level, relic_id)
		cached_offer_owned = false
	var relic_data: Dictionary = content.get_relic(relic_id)
	if relic_data.is_empty():
		return {}
	var offer := _offer_from_content(
		content,
		ITEM_TYPE_RELIC,
		relic_data,
		level,
		run_state.ensure_shop_state().next_offer_id("relic")
	)
	if cached_offer_owned:
		offer["sold_out"] = true
		offer["available"] = false
	return offer


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
	for entry in content.shop_item_pool(level, run_state):
		var entry_type := String(entry.get("type", ""))
		var content_id := String(entry.get("id", ""))
		if entry_type == ITEM_TYPE_EQUIPMENT and equipped_ids.has(content_id):
			continue
		pool.append(entry)
	var selected_entries: Array = []
	var guaranteed_entry := _first_shop_guarantee_entry(run_state, content, level, pool)
	if not guaranteed_entry.is_empty():
		selected_entries.append(guaranteed_entry)
		pool = _pool_without_entry(pool, guaranteed_entry)
	if selected_entries.size() < 3 and _entries_include_type(pool, ITEM_TYPE_BOOSTER) and not _entries_include_type(selected_entries, ITEM_TYPE_BOOSTER):
		var guaranteed_booster := _pick_random_entry_of_type(pool, ITEM_TYPE_BOOSTER)
		if not guaranteed_booster.is_empty():
			selected_entries.append(guaranteed_booster)
			pool = _pool_without_entry(pool, guaranteed_booster)
	while selected_entries.size() < 3:
		var has_booster_selected := _entries_include_type(selected_entries, ITEM_TYPE_BOOSTER)
		var allow_booster := not has_booster_selected or not _entries_include_non_booster(pool)
		var weighted_entry := _pick_weighted_entry(
			pool,
			_count_entries_of_type(selected_entries, ITEM_TYPE_CONSUMABLE) < 1,
			allow_booster
		)
		if weighted_entry.is_empty():
			break
		selected_entries.append(weighted_entry)
		pool = _pool_without_entry(pool, weighted_entry)
	if selected_entries.size() < 3:
		selected_entries.append_array(_pick_random_entries(pool, 3 - selected_entries.size()))
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


func _first_shop_guarantee_entry(run_state: Node, content, level: int, pool: Array[Dictionary]) -> Dictionary:
	if level != 1:
		return {}
	if not run_state.has_method("current_shop_ordinal_in_level") or int(run_state.current_shop_ordinal_in_level()) != 1:
		return {}
	var target_price := 10
	if run_state.has_method("prototype_fight_gold_reward_for"):
		target_price = int(run_state.prototype_fight_gold_reward_for(level, "enemy_1"))
	var preferred_shortsword := _matching_pool_entry_with_price(
		content,
		{"type": ITEM_TYPE_EQUIPMENT, "id": "shortsword"},
		level,
		target_price,
		pool
	)
	if not preferred_shortsword.is_empty() and _entry_is_damage_equipment(content, preferred_shortsword):
		return preferred_shortsword
	var fallback_damage := _first_affordable_damage_equipment(content, level, target_price, pool)
	if not fallback_damage.is_empty():
		return fallback_damage
	for entry in pool:
		var entry_price := _entry_offer_price(content, entry, level)
		if entry_price > 0 and entry_price <= target_price:
			return entry.duplicate(true)
	return {}


func _matching_pool_entry_with_price(content, candidate: Dictionary, level: int, target_price: int, pool: Array[Dictionary]) -> Dictionary:
	for entry in pool:
		if String(entry.get("type", "")) != String(candidate.get("type", "")):
			continue
		if String(entry.get("id", "")) != String(candidate.get("id", "")):
			continue
		if _entry_offer_price(content, entry, level) == target_price:
			return entry.duplicate(true)
	return {}


func _entry_offer_price(content, entry: Dictionary, level: int) -> int:
	var entry_type := String(entry.get("type", ""))
	var content_id := String(entry.get("id", ""))
	var content_data := _content_by_type(content, entry_type, content_id)
	if content_data.is_empty():
		return -1
	return _compute_offer_price(content_data, String(content_data.get("rarity", "common")), level, _pricing(content))


func _pool_without_entry(pool: Array[Dictionary], entry_to_remove: Dictionary) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	var remove_type := String(entry_to_remove.get("type", ""))
	var remove_id := String(entry_to_remove.get("id", ""))
	for entry in pool:
		if String(entry.get("type", "")) == remove_type and String(entry.get("id", "")) == remove_id:
			continue
		filtered.append(entry)
	return filtered


func _entries_include_type(entries: Array, target_type: String) -> bool:
	for raw_entry in entries:
		var entry: Dictionary = Dictionary(raw_entry)
		if String(entry.get("type", "")) == target_type:
			return true
	return false


func _entries_include_non_booster(entries: Array) -> bool:
	for raw_entry in entries:
		var entry: Dictionary = Dictionary(raw_entry)
		if String(entry.get("type", "")) != ITEM_TYPE_BOOSTER:
			return true
	return false


func _count_entries_of_type(entries: Array, target_type: String) -> int:
	var count := 0
	for raw_entry in entries:
		var entry: Dictionary = Dictionary(raw_entry)
		if String(entry.get("type", "")) == target_type:
			count += 1
	return count


func _pick_random_entry_of_type(pool: Array[Dictionary], target_type: String) -> Dictionary:
	var candidates: Array = []
	for entry in pool:
		if String(entry.get("type", "")) != target_type:
			continue
		candidates.append(entry)
	if candidates.is_empty():
		return {}
	return Dictionary(candidates[_rng.randi_range(0, candidates.size() - 1)]).duplicate(true)


func _pick_weighted_entry(pool: Array[Dictionary], allow_consumable: bool, allow_booster: bool = true) -> Dictionary:
	var weighted_candidates: Array = []
	var total_weight := 0
	for entry in pool:
		var entry_type := String(entry.get("type", ""))
		if entry_type == ITEM_TYPE_CONSUMABLE and not allow_consumable:
			continue
		if entry_type == ITEM_TYPE_BOOSTER and not allow_booster:
			continue
		var weight := _entry_type_weight(entry_type)
		if weight <= 0:
			continue
		total_weight += weight
		weighted_candidates.append({
			"entry": entry,
			"weight": weight,
		})
	if total_weight <= 0:
		return {}
	var roll := _rng.randi_range(1, total_weight)
	var cumulative := 0
	for candidate in weighted_candidates:
		cumulative += int(candidate.get("weight", 0))
		if roll <= cumulative:
			return Dictionary(candidate.get("entry", {})).duplicate(true)
	return {}


func _entry_type_weight(entry_type: String) -> int:
	match entry_type:
		ITEM_TYPE_EQUIPMENT:
			return 6
		ITEM_TYPE_MASTERY_CARD:
			return 3
		ITEM_TYPE_CONSUMABLE:
			return 1
		ITEM_TYPE_BOOSTER:
			return 1
		_:
			return 1


func _first_affordable_damage_equipment(content, level: int, max_price: int, pool: Array[Dictionary]) -> Dictionary:
	var best_entry: Dictionary = {}
	var best_price := 2147483647
	for entry in pool:
		if String(entry.get("type", "")) != ITEM_TYPE_EQUIPMENT:
			continue
		if not _entry_is_damage_equipment(content, entry):
			continue
		var price := _entry_offer_price(content, entry, level)
		if price <= 0 or price > max_price:
			continue
		if price < best_price:
			best_price = price
			best_entry = entry.duplicate(true)
	return best_entry


func _entry_is_damage_equipment(content, entry: Dictionary) -> bool:
	if String(entry.get("type", "")) != ITEM_TYPE_EQUIPMENT:
		return false
	var item_id := String(entry.get("id", ""))
	if item_id == "":
		return false
	var equipment_data: Dictionary = content.get_equipment(item_id)
	if equipment_data.is_empty():
		return false
	var modifiers: Dictionary = equipment_data.get("combat_modifiers", {})
	if int(modifiers.get("flat_damage_bonus", 0)) > 0:
		return true
	var orb_bonus: Dictionary = modifiers.get("orb_bonus_by_id", {})
	for raw_key in orb_bonus.keys():
		var orb_id := int(raw_key)
		if orb_id != OrbType.Id.FIRE and orb_id != OrbType.Id.ICE and orb_id != OrbType.Id.EARTH:
			continue
		if int(orb_bonus.get(raw_key, 0)) > 0:
			return true
	return false


func _generate_booster_options(run_state: Node, content, booster_data: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var options: Array[Dictionary] = []
	var target_orb_id := int(booster_data.get("target_orb_id", -1))
	var equipped_ids := _equipped_equipment_ids(run_state)

	for item in content.list_equipment():
		var item_id := String(item.get("id", ""))
		if item_id == "" or equipped_ids.has(item_id):
			continue
		if run_state.has_method("is_equipment_unlocked") and not bool(run_state.is_equipment_unlocked(item_id)):
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
	var prototype_balance: Dictionary = pricing.get("prototype_balance", {})
	var price_multiplier := maxf(SHOP_MULTIPLIER_MIN, float(prototype_balance.get("shop_price_multiplier", 1.0)))
	return maxi(1, int(round(float(base_price + (maxi(1, level) - 1) * level_step) * price_multiplier)))


func _compute_reroll_cost(reroll_count: int, pricing: Dictionary) -> int:
	var reroll_base := int(pricing.get("reroll_base", int(DEFAULT_PRICING.get("reroll_base", 1))))
	var reroll_step := int(pricing.get("reroll_step", int(DEFAULT_PRICING.get("reroll_step", 1))))
	var reroll_max := int(pricing.get("reroll_max", int(DEFAULT_PRICING.get("reroll_max", 30))))
	var prototype_balance: Dictionary = pricing.get("prototype_balance", {})
	var reroll_multiplier := maxf(SHOP_MULTIPLIER_MIN, float(prototype_balance.get("reroll_cost_multiplier", 1.0)))
	var unscaled_cost := reroll_base + reroll_count * reroll_step
	var scaled_cost := int(round(float(unscaled_cost) * reroll_multiplier))
	if unscaled_cost > 0:
		scaled_cost = maxi(1, scaled_cost)
	else:
		scaled_cost = maxi(0, scaled_cost)
	var clamped_max := maxi(0, maxi(reroll_base, reroll_max))
	if unscaled_cost > 0:
		clamped_max = maxi(1, clamped_max)
	return mini(scaled_cost, clamped_max)


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
