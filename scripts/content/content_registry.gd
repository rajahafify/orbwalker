extends RefCounted
class_name ContentRegistry

const CONTENT_REGISTRY_ENTRY_FACTORY_SCRIPT := preload("res://scripts/content/content_registry_entry_factory.gd")
const CONTENT_REGISTRY_DEFAULT_CONTENT_SCRIPT := preload("res://scripts/content/content_registry_default_content.gd")
const CONTENT_REGISTRY_SHOP_PRICING_SCRIPT := preload("res://scripts/content/content_registry_shop_pricing.gd")
const CONTENT_REGISTRY_CONTRACT_SNAPSHOT_SCRIPT := preload("res://scripts/content/content_registry_contract_snapshot.gd")

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const MASTERY_CARDS := "mastery_cards"
const TREASURE_CHESTS := "treasure_chests"
const RELICS := "relics"
const ENEMIES := "enemies"
const BOSSES := "bosses"

var _player_state_content: Dictionary = {}
var _index := {}
var _entry_factory: RefCounted = CONTENT_REGISTRY_ENTRY_FACTORY_SCRIPT.new()
var _default_content: RefCounted = CONTENT_REGISTRY_DEFAULT_CONTENT_SCRIPT.new()
var _shop_pricing: RefCounted = CONTENT_REGISTRY_SHOP_PRICING_SCRIPT.new()
var _contract_snapshot: RefCounted = CONTENT_REGISTRY_CONTRACT_SNAPSHOT_SCRIPT.new()


func _init() -> void:
	_player_state_content = _build_default_content()
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


func get_treasure_chest(treasure_chest_id: String) -> Dictionary:
	return _get_indexed(TREASURE_CHESTS, treasure_chest_id)


func get_relic(relic_id: String) -> Dictionary:
	return _get_indexed(RELICS, relic_id)


func list_equipment() -> Array[Dictionary]:
	return _collection_index_values(EQUIPMENT)


func list_consumables() -> Array[Dictionary]:
	return _collection_index_values(CONSUMABLES)


func list_mastery_cards() -> Array[Dictionary]:
	return _collection_index_values(MASTERY_CARDS)


func list_treasure_chests() -> Array[Dictionary]:
	return _collection_index_values(TREASURE_CHESTS)


func list_relics() -> Array[Dictionary]:
	return _collection_index_values(RELICS)


func list_enemies() -> Array[Dictionary]:
	return _collection_index_values(ENEMIES)


func list_bosses() -> Array[Dictionary]:
	return _collection_index_values(BOSSES)


func shop_item_pool(dungeon_level: int, run_state: Variant = null) -> Array[Dictionary]:
	var level := maxi(1, dungeon_level)
	var pool: Array[Dictionary] = []
	for item in list_equipment():
		if _is_level_allowed(item, level) and _is_equipment_available_for_run(item, run_state):
			pool.append({"type": "equipment", "id": String(item.get("id", ""))})
	for item in list_consumables():
		if _is_level_allowed(item, level):
			pool.append({"type": "consumable", "id": String(item.get("id", ""))})
	for item in list_mastery_cards():
		if _is_level_allowed(item, level):
			pool.append({"type": "mastery_card", "id": String(item.get("id", ""))})
	for item in list_treasure_chests():
		if _is_level_allowed(item, level):
			pool.append({"type": "treasure_chest", "id": String(item.get("id", ""))})
	return pool


func _is_equipment_available_for_run(item: Dictionary, run_state: Variant) -> bool:
	var equipment_id := String(item.get("id", ""))
	if equipment_id == "":
		return false
	if run_state == null:
		return true
	if not run_state.has_method("is_equipment_unlocked"):
		return true
	return bool(run_state.is_equipment_unlocked(equipment_id))


func shop_relic_pool(dungeon_level: int) -> Array[Dictionary]:
	var level := maxi(1, dungeon_level)
	var pool: Array[Dictionary] = []
	for relic in list_relics():
		if _is_level_allowed(relic, level):
			pool.append(relic)
	return pool


func shop_pricing_config() -> Dictionary:
	return _shop_pricing.shop_pricing_config()


func set_prototype_balance_levers(levers: Dictionary) -> void:
	_shop_pricing.set_prototype_balance_levers(levers)


func content_contract_snapshot() -> Dictionary:
	return _contract_snapshot.snapshot()


func validate_player_state_content() -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var known_equipment_ids := {}
	var equipment_entries: Array = _player_state_content.get(EQUIPMENT, [])
	for raw_equipment_entry in equipment_entries:
		if not (raw_equipment_entry is Dictionary):
			continue
		var equipment_entry = raw_equipment_entry
		var equipment_id := String(equipment_entry.get("id", ""))
		if equipment_id != "":
			known_equipment_ids[equipment_id] = true

	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, TREASURE_CHESTS, RELICS, ENEMIES, BOSSES]:
		var entries: Array = _player_state_content.get(collection_name, [])
		var seen_ids := {}
		for raw_entry in entries:
			if not (raw_entry is Dictionary):
				errors.append(_validation_error("<invalid_entry>", "%s entry is not a Dictionary" % collection_name))
				continue
			var entry = raw_entry
			var entry_id := String(entry.get("id", ""))
			if entry_id == "":
				errors.append(_validation_error("<missing_id>", "%s entry missing id" % collection_name))
				continue
			if seen_ids.has(entry_id):
				errors.append(_validation_error(entry_id, "duplicate_id"))
			else:
				seen_ids[entry_id] = true

			if String(entry.get("display_name", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_display_name"))
			if String(entry.get("description", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_description"))
			if String(entry.get("icon_key", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_icon_key"))
			if collection_name == EQUIPMENT:
				var next_tier_item_id := String(entry.get("next_tier_item_id", ""))
				if next_tier_item_id != "" and not known_equipment_ids.has(next_tier_item_id):
					errors.append(_validation_error(entry_id, "missing_next_tier_item_id:%s" % next_tier_item_id))

			var effects: Array = entry.get("effects", [])
			for raw_effect in effects:
				if not (raw_effect is Dictionary):
					errors.append(_validation_error(entry_id, "effect_entry_not_dictionary"))
					continue
				var effect = raw_effect
				var hook_name := String(effect.get("hook", ""))
				if hook_name == "":
					errors.append(_validation_error(entry_id, "missing_effect_hook"))
					continue
				if not EffectHooks.is_valid_hook(hook_name):
					errors.append(_validation_error(entry_id, "invalid_effect_hook:%s" % hook_name))

	return errors


func _rebuild_index() -> void:
	_index.clear()
	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, TREASURE_CHESTS, RELICS, ENEMIES, BOSSES]:
		_index[collection_name] = {}
		var entries: Array = _player_state_content.get(collection_name, [])
		for raw_entry in entries:
			if not (raw_entry is Dictionary):
				continue
			var entry = raw_entry
			var indexed_entry_id := String(entry.get("id", ""))
			if indexed_entry_id == "":
				continue
			_index[collection_name][indexed_entry_id] = entry.duplicate(true)


func _get_indexed(collection_name: String, lookup_entry_id: String) -> Dictionary:
	var collection_index: Dictionary = _index.get(collection_name, {})
	if not collection_index.has(lookup_entry_id):
		return {}
	return Dictionary(collection_index[lookup_entry_id]).duplicate(true)


func _collection_index_values(collection_name: String) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	var collection_index: Dictionary = _index.get(collection_name, {})
	for value in collection_index.values():
		values.append(Dictionary(value).duplicate(true))
	return values


func _is_level_allowed(entry: Dictionary, level: int) -> bool:
	var min_level := int(entry.get("min_level", 1))
	var max_level := int(entry.get("max_level", 999))
	return level >= min_level and level <= max_level


func _validation_error(item_id: String, reason: String) -> Dictionary:
	return {
		"item_id": item_id,
		"reason": reason,
	}


func _build_default_content() -> Dictionary:
	_default_content.bind(_entry_factory)
	return _default_content.build()
