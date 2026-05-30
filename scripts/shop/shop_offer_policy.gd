extends RefCounted
class_name ShopOfferPolicy

const ITEM_TYPE_EQUIPMENT := "equipment"
const ITEM_TYPE_CONSUMABLE := "consumable"
const ITEM_TYPE_MASTERY_CARD := "mastery_card"
const ITEM_TYPE_TREASURE_CHEST := "treasure_chest"
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


func set_rng_seed(seed_value: int) -> void:
	_rng.seed = maxi(1, seed_value)
	_seeded = true


func randomize_rng() -> void:
	_rng.randomize()
	_seeded = true


func ensure_rng_seeded() -> void:
	if _seeded:
		return
	_rng.randomize()
	_seeded = true


func item_offers(run_state: Node, content: Variant, level: int) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	var equipped_ids := _equipped_equipment_ids(run_state)
	for entry in content.shop_item_pool(level, run_state):
		var entry_type := String(entry.get("type", ""))
		var content_id := String(entry.get("id", ""))
		if entry_type == ITEM_TYPE_EQUIPMENT and equipped_ids.has(content_id):
			continue
		pool.append(entry)
	var selected_entries: Array = []
	var guaranteed_entry := first_shop_guarantee_entry(run_state, content, level, pool)
	if not guaranteed_entry.is_empty():
		selected_entries.append(guaranteed_entry)
		pool = _pool_without_entry(pool, guaranteed_entry)
	if selected_entries.size() < 3 and _entries_include_type(pool, ITEM_TYPE_TREASURE_CHEST) and not _entries_include_type(selected_entries, ITEM_TYPE_TREASURE_CHEST):
		var guaranteed_treasure_chest := _pick_random_entry_of_type(pool, ITEM_TYPE_TREASURE_CHEST)
		if not guaranteed_treasure_chest.is_empty():
			selected_entries.append(guaranteed_treasure_chest)
			pool = _pool_without_entry(pool, guaranteed_treasure_chest)
	while selected_entries.size() < 3:
		var has_treasure_chest_selected := _entries_include_type(selected_entries, ITEM_TYPE_TREASURE_CHEST)
		var allow_treasure_chest := not has_treasure_chest_selected or not _entries_include_non_treasure_chest(pool)
		var weighted_entry := _pick_weighted_entry(
			pool,
			_count_entries_of_type(selected_entries, ITEM_TYPE_CONSUMABLE) < 1,
			allow_treasure_chest
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
		var content_data := content_by_type(content, entry_type, content_id)
		if content_data.is_empty():
			continue
		offers.append(
			offer_from_content(
				content,
				entry_type,
				content_data,
				level,
				run_state.ensure_shop_state().next_offer_id("item")
			)
		)
	return offers


func relic_offer(run_state: Node, content: Variant, level: int) -> Dictionary:
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
	var offer := offer_from_content(
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


func treasure_chest_options(run_state: Node, content: Variant, treasure_chest_data: Dictionary) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	var options: Array[Dictionary] = []
	var target_orb_id := int(treasure_chest_data.get("target_orb_id", -1))
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

	var selected := _pick_random_entries(candidates, int(treasure_chest_data.get("option_count", 3)))
	for item in selected:
		options.append(item)
	return options


func offer_from_content(content: Variant, entry_type: String, data: Dictionary, level: int, offer_id: String) -> Dictionary:
	var rarity := String(data.get("rarity", "common"))
	var price := offer_price(data, rarity, level, pricing(content))
	return {
		"offer_id": offer_id,
		"type": entry_type,
		"content_id": String(data.get("id", "")),
		"display_name": String(data.get("display_name", entry_type)),
		"description": String(data.get("description", "")),
		"icon_key": String(data.get("icon_key", "")),
		"rarity": rarity,
		"price": price,
		"dungeon_level": level,
		"sold_out": false,
		"available": true,
	}


func first_shop_guarantee_entry(run_state: Node, content: Variant, level: int, pool: Array[Dictionary]) -> Dictionary:
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
		var entry_price := entry_offer_price(content, entry, level)
		if entry_price > 0 and entry_price <= target_price:
			return entry.duplicate(true)
	return {}


func entry_offer_price(content: Variant, entry: Dictionary, level: int) -> int:
	var entry_type := String(entry.get("type", ""))
	var content_id := String(entry.get("id", ""))
	var content_data := content_by_type(content, entry_type, content_id)
	if content_data.is_empty():
		return -1
	return offer_price(content_data, String(content_data.get("rarity", "common")), level, pricing(content))


func content_by_type(content: Variant, entry_type: String, content_id: String) -> Dictionary:
	match entry_type:
		ITEM_TYPE_EQUIPMENT:
			return content.get_equipment(content_id)
		ITEM_TYPE_CONSUMABLE:
			return content.get_consumable(content_id)
		ITEM_TYPE_MASTERY_CARD:
			return content.get_mastery_card(content_id)
		ITEM_TYPE_TREASURE_CHEST:
			return content.get_treasure_chest(content_id)
		_:
			return {}


func pricing(content: Variant) -> Dictionary:
	if content == null or not content.has_method("shop_pricing_config"):
		return DEFAULT_PRICING.duplicate(true)
	var content_pricing: Dictionary = content.shop_pricing_config()
	if content_pricing.is_empty():
		return DEFAULT_PRICING.duplicate(true)
	return content_pricing


func offer_price(data: Dictionary, rarity: String, level: int, pricing_config: Dictionary) -> int:
	var base_price := int(data.get("base_price", 0))
	var default_rarity_base := int(DEFAULT_PRICING.get("rarity_base", {}).get("common", 10))
	var rarity_base := int(pricing_config.get("rarity_base", {}).get(rarity, default_rarity_base))
	var level_step := int(pricing_config.get("level_step", int(DEFAULT_PRICING.get("level_step", 2))))
	if base_price <= 0:
		base_price = rarity_base
	var prototype_balance: Dictionary = pricing_config.get("prototype_balance", {})
	var price_multiplier := maxf(SHOP_MULTIPLIER_MIN, float(prototype_balance.get("shop_price_multiplier", 1.0)))
	return maxi(1, int(round(float(base_price + (maxi(1, level) - 1) * level_step) * price_multiplier)))


func reroll_cost(content: Variant, reroll_count: int) -> int:
	return reroll_cost_for_pricing(reroll_count, pricing(content))


func reroll_cost_for_pricing(reroll_count: int, pricing_config: Dictionary) -> int:
	var reroll_base := int(pricing_config.get("reroll_base", int(DEFAULT_PRICING.get("reroll_base", 1))))
	var reroll_step := int(pricing_config.get("reroll_step", int(DEFAULT_PRICING.get("reroll_step", 1))))
	var reroll_max := int(pricing_config.get("reroll_max", int(DEFAULT_PRICING.get("reroll_max", 30))))
	var prototype_balance: Dictionary = pricing_config.get("prototype_balance", {})
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


func _available_relic_pool(run_state: Node, content: Variant, level: int) -> Array:
	var owned_relic_ids := _owned_relic_ids(run_state)
	var pool: Array = []
	for relic_data in content.shop_relic_pool(level):
		var relic_id := String(Dictionary(relic_data).get("id", ""))
		if relic_id == "" or owned_relic_ids.has(relic_id):
			continue
		pool.append(relic_data)
	return pool


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


func _entries_include_non_treasure_chest(entries: Array) -> bool:
	for raw_entry in entries:
		var entry: Dictionary = Dictionary(raw_entry)
		if String(entry.get("type", "")) != ITEM_TYPE_TREASURE_CHEST:
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


func _pick_weighted_entry(pool: Array[Dictionary], allow_consumable: bool, allow_treasure_chest: bool = true) -> Dictionary:
	var weighted_candidates: Array = []
	var total_weight := 0
	for entry in pool:
		var entry_type := String(entry.get("type", ""))
		if entry_type == ITEM_TYPE_CONSUMABLE and not allow_consumable:
			continue
		if entry_type == ITEM_TYPE_TREASURE_CHEST and not allow_treasure_chest:
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
		ITEM_TYPE_TREASURE_CHEST:
			return 1
		_:
			return 1


func _matching_pool_entry_with_price(content: Variant, candidate: Dictionary, level: int, target_price: int, pool: Array[Dictionary]) -> Dictionary:
	for entry in pool:
		if String(entry.get("type", "")) != String(candidate.get("type", "")):
			continue
		if String(entry.get("id", "")) != String(candidate.get("id", "")):
			continue
		if entry_offer_price(content, entry, level) == target_price:
			return entry.duplicate(true)
	return {}


func _first_affordable_damage_equipment(content: Variant, level: int, max_price: int, pool: Array[Dictionary]) -> Dictionary:
	var best_entry: Dictionary = {}
	var best_price := 2147483647
	for entry in pool:
		if String(entry.get("type", "")) != ITEM_TYPE_EQUIPMENT:
			continue
		if not _entry_is_damage_equipment(content, entry):
			continue
		var price := entry_offer_price(content, entry, level)
		if price <= 0 or price > max_price:
			continue
		if price < best_price:
			best_price = price
			best_entry = entry.duplicate(true)
	return best_entry


func _entry_is_damage_equipment(content: Variant, entry: Dictionary) -> bool:
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
