extends RefCounted
class_name ShopOfferPolicyTest

const POLICY_SCRIPT := preload("res://scripts/shop/shop_offer_policy.gd")


class FakeProgressionState:
	extends RefCounted

	var equipped_item_ids: Array[String] = []
	var relic_ids: Array[String] = []


class FakeShopState:
	extends RefCounted

	var counters := {}

	func next_offer_id(prefix: String) -> String:
		var next_index := int(counters.get(prefix, 0)) + 1
		counters[prefix] = next_index
		return "%s_%d" % [prefix, next_index]


class FakeRunState:
	extends Node

	var progression := FakeProgressionState.new()
	var shop := FakeShopState.new()
	var relic_offer_by_level := {}
	var unlocked_equipment := {}
	var current_shop_ordinal := 1
	var first_enemy_gold := 10

	func ensure_player_progression_state() -> FakeProgressionState:
		return progression

	func ensure_shop_state() -> FakeShopState:
		return shop

	func current_shop_ordinal_in_level() -> int:
		return current_shop_ordinal

	func prototype_fight_gold_reward_for(_level: int, _step_key: String) -> int:
		return first_enemy_gold

	func relic_offer_id_for_level(level: int) -> String:
		return String(relic_offer_by_level.get(level, ""))

	func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
		relic_offer_by_level[level] = relic_id

	func is_equipment_unlocked(item_id: String) -> bool:
		if unlocked_equipment.is_empty():
			return true
		return bool(unlocked_equipment.get(item_id, false))


class FakeContent:
	extends RefCounted

	var pricing := {}
	var equipment := {}
	var consumables := {}
	var mastery_cards := {}
	var treasure_chests := {}
	var relics := {}
	var item_pool: Array[Dictionary] = []
	var relic_pool: Array[Dictionary] = []

	func shop_pricing_config() -> Dictionary:
		return pricing.duplicate(true)

	func shop_item_pool(_level: int, _run_state: Node) -> Array[Dictionary]:
		return item_pool.duplicate(true)

	func shop_relic_pool(_level: int) -> Array[Dictionary]:
		return relic_pool.duplicate(true)

	func get_equipment(item_id: String) -> Dictionary:
		return Dictionary(equipment.get(item_id, {})).duplicate(true)

	func get_consumable(item_id: String) -> Dictionary:
		return Dictionary(consumables.get(item_id, {})).duplicate(true)

	func get_mastery_card(item_id: String) -> Dictionary:
		return Dictionary(mastery_cards.get(item_id, {})).duplicate(true)

	func get_treasure_chest(item_id: String) -> Dictionary:
		return Dictionary(treasure_chests.get(item_id, {})).duplicate(true)

	func get_relic(item_id: String) -> Dictionary:
		return Dictionary(relics.get(item_id, {})).duplicate(true)

	func list_equipment() -> Array:
		return equipment.values()

	func list_consumables() -> Array:
		return consumables.values()

	func list_mastery_cards() -> Array:
		return mastery_cards.values()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("offer_price_uses_config_level_and_multiplier", _test_offer_price_uses_config_level_and_multiplier, failures)
	_run_case("reroll_cost_scales_and_clamps", _test_reroll_cost_scales_and_clamps, failures)
	_run_case("first_shop_guarantee_prefers_affordable_damage", _test_first_shop_guarantee_prefers_affordable_damage, failures)
	_run_case("item_offers_skip_equipped_and_include_treasure_chest", _test_item_offers_skip_equipped_and_include_treasure_chest, failures)
	_run_case("treasure_chest_options_filter_equipped_locked_and_orb", _test_treasure_chest_options_filter_equipped_locked_and_orb, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_offer_price_uses_config_level_and_multiplier() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	var pricing := {
		"rarity_base": {"common": 10, "rare": 30},
		"level_step": 3,
		"prototype_balance": {"shop_price_multiplier": 1.5},
	}
	var rare_price: int = policy.offer_price({"base_price": 0}, "rare", 3, pricing)
	if rare_price != 54:
		return "Expected rarity fallback plus level step and multiplier to produce price 54, got %d." % rare_price
	var explicit_price: int = policy.offer_price({"base_price": 8}, "common", 2, pricing)
	if explicit_price != 17:
		return "Expected explicit base price plus level step and multiplier to produce price 17, got %d." % explicit_price
	var floor_price: int = policy.offer_price({"base_price": 1}, "common", 1, {"prototype_balance": {"shop_price_multiplier": 0.0}})
	if floor_price != 1:
		return "Expected low multipliers to stay at the minimum positive offer price."
	return ""


func _test_reroll_cost_scales_and_clamps() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	var pricing := {
		"reroll_base": 2,
		"reroll_step": 3,
		"reroll_max": 10,
		"prototype_balance": {"reroll_cost_multiplier": 2.0},
	}
	var scaled_cost: int = policy.reroll_cost_for_pricing(2, pricing)
	if scaled_cost != 10:
		return "Expected scaled reroll cost to clamp at 10, got %d." % scaled_cost
	var free_cost: int = policy.reroll_cost_for_pricing(0, {"reroll_base": 0, "reroll_step": 0, "reroll_max": 0})
	if free_cost != 0:
		return "Expected zero-cost rerolls to stay free, got %d." % free_cost
	return ""


func _test_first_shop_guarantee_prefers_affordable_damage() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	var fixture := _fixture()
	var run_state: FakeRunState = fixture["run_state"]
	var content: FakeContent = fixture["content"]
	content.pricing = {"rarity_base": {"common": 10}, "level_step": 2}
	content.equipment = {
		"shortsword": _equipment("shortsword", 10, {"flat_damage_bonus": 2}),
		"expensive_blade": _equipment("expensive_blade", 14, {"flat_damage_bonus": 4}),
	}
	var pool: Array[Dictionary] = [
		{"type": POLICY_SCRIPT.ITEM_TYPE_EQUIPMENT, "id": "expensive_blade"},
		{"type": POLICY_SCRIPT.ITEM_TYPE_EQUIPMENT, "id": "shortsword"},
	]
	var guarantee: Dictionary = policy.first_shop_guarantee_entry(run_state, content, 1, pool)
	run_state.free()
	if String(guarantee.get("id", "")) != "shortsword":
		return "Expected first shop guarantee to prefer affordable Shortsword."
	return ""


func _test_item_offers_skip_equipped_and_include_treasure_chest() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	policy.set_rng_seed(7)
	var fixture := _fixture()
	var run_state: FakeRunState = fixture["run_state"]
	var content: FakeContent = fixture["content"]
	run_state.progression.equipped_item_ids = ["owned_sword"]
	content.equipment = {
		"owned_sword": _equipment("owned_sword", 10, {"flat_damage_bonus": 2}),
		"shortsword": _equipment("shortsword", 10, {"flat_damage_bonus": 2}),
		"buckler": _equipment("buckler", 9, {}),
	}
	content.consumables = {
		"potion": _consumable("potion", 6),
	}
	content.treasure_chests = {
		"fire_chest": _treasure_chest("fire_chest", 12),
	}
	content.item_pool = [
		{"type": POLICY_SCRIPT.ITEM_TYPE_EQUIPMENT, "id": "owned_sword"},
		{"type": POLICY_SCRIPT.ITEM_TYPE_EQUIPMENT, "id": "shortsword"},
		{"type": POLICY_SCRIPT.ITEM_TYPE_EQUIPMENT, "id": "buckler"},
		{"type": POLICY_SCRIPT.ITEM_TYPE_CONSUMABLE, "id": "potion"},
		{"type": POLICY_SCRIPT.ITEM_TYPE_TREASURE_CHEST, "id": "fire_chest"},
	]
	var offers: Array[Dictionary] = policy.item_offers(run_state, content, 1)
	run_state.free()
	if offers.size() != 3:
		return "Expected item offer policy to emit three offers, got %d." % offers.size()
	if _offers_include_content(offers, "owned_sword"):
		return "Expected item offers to skip already equipped equipment."
	if not _offers_include_content(offers, "shortsword"):
		return "Expected item offers to include the first-shop damage guarantee."
	if not _offers_include_type(offers, POLICY_SCRIPT.ITEM_TYPE_TREASURE_CHEST):
		return "Expected item offers to guarantee one treasure chest when available."
	return ""


func _test_treasure_chest_options_filter_equipped_locked_and_orb() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	policy.set_rng_seed(3)
	var fixture := _fixture()
	var run_state: FakeRunState = fixture["run_state"]
	var content: FakeContent = fixture["content"]
	run_state.progression.equipped_item_ids = ["owned_fire"]
	run_state.unlocked_equipment = {
		"owned_fire": true,
		"locked_fire": false,
		"ice_spear": true,
		"fire_axe": true,
	}
	content.equipment = {
		"owned_fire": _equipment("owned_fire", 8, {"flat_damage_bonus": 1}, OrbType.Id.FIRE),
		"locked_fire": _equipment("locked_fire", 8, {"flat_damage_bonus": 1}, OrbType.Id.FIRE),
		"ice_spear": _equipment("ice_spear", 8, {"flat_damage_bonus": 1}, OrbType.Id.ICE),
		"fire_axe": _equipment("fire_axe", 8, {"flat_damage_bonus": 1}, OrbType.Id.FIRE),
	}
	content.consumables = {
		"fire_potion": _consumable("fire_potion", 5, OrbType.Id.FIRE),
		"ice_potion": _consumable("ice_potion", 5, OrbType.Id.ICE),
	}
	content.mastery_cards = {
		"fire_mastery": _mastery("fire_mastery", 7, OrbType.Id.FIRE),
	}
	var options: Array[Dictionary] = policy.treasure_chest_options(run_state, content, {
		"target_orb_id": OrbType.Id.FIRE,
		"option_count": 3,
	})
	run_state.free()
	if options.size() != 3:
		return "Expected three fire treasure chest options, got %d." % options.size()
	if _options_include_content(options, "owned_fire") or _options_include_content(options, "locked_fire") or _options_include_content(options, "ice_spear") or _options_include_content(options, "ice_potion"):
		return "Expected treasure chest options to skip equipped, locked, and off-orb candidates."
	if not _options_include_content(options, "fire_axe") or not _options_include_content(options, "fire_potion") or not _options_include_content(options, "fire_mastery"):
		return "Expected treasure chest options to include eligible fire equipment, consumable, and mastery."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var content := FakeContent.new()
	content.pricing = POLICY_SCRIPT.DEFAULT_PRICING.duplicate(true)
	return {
		"run_state": run_state,
		"content": content,
	}


func _equipment(item_id: String, base_price: int, modifiers: Dictionary, target_orb_id: int = -1) -> Dictionary:
	return {
		"id": item_id,
		"display_name": item_id.capitalize(),
		"rarity": "common",
		"base_price": base_price,
		"target_orb_id": target_orb_id,
		"combat_modifiers": modifiers,
	}


func _consumable(item_id: String, base_price: int, target_orb_id: int = -1) -> Dictionary:
	return {
		"id": item_id,
		"display_name": item_id.capitalize(),
		"rarity": "common",
		"base_price": base_price,
		"target_orb_id": target_orb_id,
	}


func _mastery(item_id: String, base_price: int, target_orb_id: int = -1) -> Dictionary:
	return {
		"id": item_id,
		"display_name": item_id.capitalize(),
		"rarity": "common",
		"base_price": base_price,
		"target_orb_id": target_orb_id,
	}


func _treasure_chest(item_id: String, base_price: int) -> Dictionary:
	return {
		"id": item_id,
		"display_name": item_id.capitalize(),
		"rarity": "common",
		"base_price": base_price,
	}


func _offers_include_content(offers: Array[Dictionary], content_id: String) -> bool:
	for offer in offers:
		if String(offer.get("content_id", "")) == content_id:
			return true
	return false


func _offers_include_type(offers: Array[Dictionary], offer_type: String) -> bool:
	for offer in offers:
		if String(offer.get("type", "")) == offer_type:
			return true
	return false


func _options_include_content(options: Array[Dictionary], content_id: String) -> bool:
	for option in options:
		if String(option.get("content_id", "")) == content_id:
			return true
	return false
