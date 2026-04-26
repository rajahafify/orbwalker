extends RefCounted
class_name ContentRegistry

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const RELICS := "relics"

var _player_state_content := {
	EQUIPMENT: [
		{
			"id": "debug_shortsword",
			"display_name": "Debug Shortsword",
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
	],
	RELICS: [
		{
			"id": "debug_stalwart_mantle",
			"display_name": "Debug Stalwart Mantle",
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


func _init() -> void:
	_rebuild_index()


func set_player_state_content(content: Dictionary) -> void:
	_player_state_content = content.duplicate(true)
	_rebuild_index()


func get_equipment(item_id: String) -> Dictionary:
	return _get_indexed(EQUIPMENT, item_id)


func get_consumable(consumable_id: String) -> Dictionary:
	return _get_indexed(CONSUMABLES, consumable_id)


func get_relic(relic_id: String) -> Dictionary:
	return _get_indexed(RELICS, relic_id)


func validate_player_state_content() -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	for collection_name in [EQUIPMENT, CONSUMABLES, RELICS]:
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
	for collection_name in [EQUIPMENT, CONSUMABLES, RELICS]:
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


func _validation_error(item_id: String, reason: String) -> Dictionary:
	return {
		"item_id": item_id,
		"reason": reason,
	}
