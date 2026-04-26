extends RefCounted
class_name ContentRegistry

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const MASTERY_CARDS := "mastery_cards"
const BOOSTERS := "boosters"
const RELICS := "relics"

var _player_state_content := {
	EQUIPMENT: [
		{
			"id": "debug_shortsword",
			"display_name": "Debug Shortsword",
			"rarity": "common",
			"target_orb_id": OrbType.Id.FIRE,
			"base_price": 12,
			"sell_value": 12,
			"effects": [
				{
					"hook": EffectHooks.ON_ITEM_EQUIPPED,
					"operation": "log",
					"value": "debug_shortsword_equipped",
				},
			],
		},
		{
			"id": "debug_buckler",
			"display_name": "Debug Buckler",
			"rarity": "common",
			"target_orb_id": OrbType.Id.ARMOR,
			"base_price": 10,
			"sell_value": 10,
			"effects": [
				{
					"hook": EffectHooks.ON_ITEM_EQUIPPED,
					"operation": "log",
					"value": "debug_buckler_equipped",
				},
			],
		},
	],
	CONSUMABLES: [
		{
			"id": "debug_fire_scroll",
			"display_name": "Debug Fire Scroll",
			"rarity": "common",
			"target_orb_id": OrbType.Id.FIRE,
			"base_price": 8,
			"effects": [
				{
					"hook": EffectHooks.ON_CONSUMABLE_USED,
					"operation": "convert_random_orbs",
					"value": {
						"target_orb_id": OrbType.Id.FIRE,
						"count": 2,
					},
				},
			],
		},
		{
			"id": "debug_heart_scroll",
			"display_name": "Debug Heart Scroll",
			"rarity": "common",
			"target_orb_id": OrbType.Id.HEART,
			"base_price": 8,
			"effects": [
				{
					"hook": EffectHooks.ON_CONSUMABLE_USED,
					"operation": "convert_random_orbs",
					"value": {
						"target_orb_id": OrbType.Id.HEART,
						"count": 2,
					},
				},
			],
		},
	],
	MASTERY_CARDS: [
		{
			"id": "debug_fire_mastery",
			"display_name": "Debug Fire Mastery",
			"rarity": "common",
			"target_orb_id": OrbType.Id.FIRE,
			"amount": 1,
			"base_price": 11,
			"effects": [],
		},
		{
			"id": "debug_gold_mastery",
			"display_name": "Debug Gold Mastery",
			"rarity": "uncommon",
			"target_orb_id": OrbType.Id.GOLD,
			"amount": 1,
			"base_price": 16,
			"effects": [],
		},
	],
	BOOSTERS: [
		{
			"id": "debug_elemental_booster",
			"display_name": "Debug Elemental Booster",
			"rarity": "common",
			"target_orb_id": -1,
			"option_count": 3,
			"base_price": 9,
			"effects": [],
		},
		{
			"id": "debug_fire_booster",
			"display_name": "Debug Fire Booster",
			"rarity": "common",
			"target_orb_id": OrbType.Id.FIRE,
			"option_count": 3,
			"base_price": 10,
			"effects": [],
		},
	],
	RELICS: [
		{
			"id": "debug_stalwart_mantle",
			"display_name": "Debug Stalwart Mantle",
			"rarity": "rare",
			"base_price": 25,
			"effects": [
				{
					"hook": EffectHooks.ON_RELIC_ADDED,
					"operation": "log",
					"value": "debug_relic_added",
				},
			],
		},
	],
}

var _index := {}
var _shop_pricing_config := {
	"rarity_base": {
		"common": 10,
		"uncommon": 16,
		"rare": 24,
	},
	"level_step": 2,
	"reroll_base": 1,
	"reroll_step": 1,
}


func _init() -> void:
	_rebuild_index()


func set_player_state_content(content: Dictionary) -> void:
	_player_state_content = content.duplicate(true)
	_rebuild_index()


func get_equipment(item_id: String) -> Dictionary:
	return _get_indexed(EQUIPMENT, item_id)


func get_consumable(consumable_id: String) -> Dictionary:
	return _get_indexed(CONSUMABLES, consumable_id)


func get_mastery_card(card_id: String) -> Dictionary:
	return _get_indexed(MASTERY_CARDS, card_id)


func get_booster(booster_id: String) -> Dictionary:
	return _get_indexed(BOOSTERS, booster_id)


func get_relic(relic_id: String) -> Dictionary:
	return _get_indexed(RELICS, relic_id)


func list_equipment() -> Array[Dictionary]:
	return _collection_index_values(EQUIPMENT)


func list_consumables() -> Array[Dictionary]:
	return _collection_index_values(CONSUMABLES)


func list_mastery_cards() -> Array[Dictionary]:
	return _collection_index_values(MASTERY_CARDS)


func list_boosters() -> Array[Dictionary]:
	return _collection_index_values(BOOSTERS)


func list_relics() -> Array[Dictionary]:
	return _collection_index_values(RELICS)


func shop_item_pool(_dungeon_level: int) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for item in list_equipment():
		pool.append({"type": "equipment", "id": String(item.get("id", ""))})
	for item in list_consumables():
		pool.append({"type": "consumable", "id": String(item.get("id", ""))})
	for item in list_mastery_cards():
		pool.append({"type": "mastery_card", "id": String(item.get("id", ""))})
	for item in list_boosters():
		pool.append({"type": "booster", "id": String(item.get("id", ""))})
	return pool


func shop_relic_pool(_dungeon_level: int) -> Array[Dictionary]:
	return list_relics()


func shop_pricing_config() -> Dictionary:
	return _shop_pricing_config.duplicate(true)


func validate_player_state_content() -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, BOOSTERS, RELICS]:
		var entries: Array = _player_state_content.get(collection_name, [])
		var seen_ids := {}
		for raw_entry in entries:
			var entry: Dictionary = raw_entry
			var item_id := String(entry.get("id", ""))
			if item_id == "":
				errors.append(_validation_error("<missing_id>", "%s entry missing id" % collection_name))
				continue
			if seen_ids.has(item_id):
				errors.append(_validation_error(item_id, "duplicate_id"))
			else:
				seen_ids[item_id] = true

			if String(entry.get("display_name", "")).strip_edges() == "":
				errors.append(_validation_error(item_id, "missing_display_name"))

			var effects: Array = entry.get("effects", [])
			for raw_effect in effects:
				var effect: Dictionary = raw_effect
				var hook_name := String(effect.get("hook", ""))
				if hook_name == "":
					errors.append(_validation_error(item_id, "missing_effect_hook"))
					continue
				if not EffectHooks.is_valid_hook(hook_name):
					errors.append(_validation_error(item_id, "invalid_effect_hook:%s" % hook_name))

	return errors


func _rebuild_index() -> void:
	_index.clear()
	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, BOOSTERS, RELICS]:
		_index[collection_name] = {}
		var entries: Array = _player_state_content.get(collection_name, [])
		for raw_entry in entries:
			var entry: Dictionary = raw_entry
			var item_id := String(entry.get("id", ""))
			if item_id == "":
				continue
			_index[collection_name][item_id] = entry.duplicate(true)


func _get_indexed(collection_name: String, item_id: String) -> Dictionary:
	var collection_index: Dictionary = _index.get(collection_name, {})
	return collection_index.get(item_id, {})


func _collection_index_values(collection_name: String) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	var collection_index: Dictionary = _index.get(collection_name, {})
	for value in collection_index.values():
		values.append(Dictionary(value).duplicate(true))
	return values


func _validation_error(item_id: String, reason: String) -> Dictionary:
	return {
		"item_id": item_id,
		"reason": reason,
	}
