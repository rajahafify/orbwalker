extends RefCounted
class_name PlayerProgressionService


func equip_item(state: PlayerProgressionState, item_id: String, content: ContentRegistry) -> Dictionary:
	var item_data: Dictionary = content.get_equipment(item_id)
	if item_id == "":
		return _error(state, "invalid_item_id")
	if item_data.is_empty():
		return _error(state, "unknown_equipment_id")
	if state.equipped_item_ids.has(item_id):
		return _error(state, "equipment_already_equipped")

	var slot_index := _find_empty_slot(state.equipped_item_ids)
	if slot_index < 0:
		return _error(state, "equipment_slots_full")

	state.equipped_item_ids[slot_index] = item_id
	_rebuild_active_effects(state, content)
	return _ok(state, {
		"slot_index": slot_index,
		"item_id": item_id,
	})


func replace_equipment(state: PlayerProgressionState, slot_index: int, item_id: String, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.equipped_item_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_equipment_slot_index")
	if item_id == "":
		return _error(state, "invalid_item_id")
	var item_data: Dictionary = content.get_equipment(item_id)
	if item_data.is_empty():
		return _error(state, "unknown_equipment_id")
	if state.equipped_item_ids.has(item_id):
		return _error(state, "equipment_already_equipped")

	var replaced_item_id := String(state.equipped_item_ids[validated_index])
	if replaced_item_id == "":
		return _error(state, "equipment_slot_empty")
	state.equipped_item_ids[validated_index] = item_id
	_rebuild_active_effects(state, content)
	return _ok(state, {
		"slot_index": validated_index,
		"item_id": item_id,
		"replaced_item_id": replaced_item_id,
	})


func unequip_item(state: PlayerProgressionState, slot_index: int, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.equipped_item_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_equipment_slot_index")

	var item_id := state.equipped_item_ids[validated_index]
	if item_id == "":
		return _error(state, "equipment_slot_empty")

	state.equipped_item_ids[validated_index] = ""
	_rebuild_active_effects(state, content)
	return _ok(state, {
		"slot_index": validated_index,
		"item_id": item_id,
	})


func sell_equipment(state: PlayerProgressionState, slot_index: int, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.equipped_item_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_equipment_slot_index")

	var item_id := state.equipped_item_ids[validated_index]
	if item_id == "":
		return _error(state, "equipment_slot_empty")

	var item_data: Dictionary = content.get_equipment(item_id)
	var sell_value := int(item_data.get("sell_value", item_data.get("base_price", 0)))

	state.equipped_item_ids[validated_index] = ""
	_rebuild_active_effects(state, content)
	return _ok(state, {
		"slot_index": validated_index,
		"item_id": item_id,
		"gold_gained": maxi(0, sell_value),
	})


func grant_mastery(state: PlayerProgressionState, orb_id: int, amount: int = 1) -> Dictionary:
	if not OrbType.is_valid_id(orb_id):
		return _error(state, "invalid_mastery_track")
	if amount <= 0:
		return _error(state, "invalid_mastery_amount")

	var current_level := state.mastery_level(orb_id)
	var next_level := mini(PlayerProgressionState.MASTERY_CAP, current_level + amount)
	var granted := next_level - current_level
	state.mastery_levels[orb_id] = next_level
	return _ok(state, {
		"orb_id": orb_id,
		"new_level": next_level,
		"granted": granted,
		"capped": next_level >= PlayerProgressionState.MASTERY_CAP,
	})


func add_consumable(state: PlayerProgressionState, consumable_id: String, content: ContentRegistry) -> Dictionary:
	if consumable_id == "":
		return _error(state, "invalid_consumable_id")
	if content.get_consumable(consumable_id).is_empty():
		return _error(state, "unknown_consumable_id")

	var slot_index := _find_empty_slot(state.held_consumable_ids)
	if slot_index < 0:
		return _error(state, "consumable_slots_full")

	state.held_consumable_ids[slot_index] = consumable_id
	return _ok(state, {
		"slot_index": slot_index,
		"consumable_id": consumable_id,
	})


func replace_consumable(state: PlayerProgressionState, slot_index: int, consumable_id: String, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.held_consumable_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_consumable_slot_index")
	if consumable_id == "":
		return _error(state, "invalid_consumable_id")
	if content.get_consumable(consumable_id).is_empty():
		return _error(state, "unknown_consumable_id")
	var replaced_consumable_id := String(state.held_consumable_ids[validated_index])
	if replaced_consumable_id == "":
		return _error(state, "consumable_slot_empty")
	state.held_consumable_ids[validated_index] = consumable_id
	return _ok(state, {
		"slot_index": validated_index,
		"consumable_id": consumable_id,
		"replaced_consumable_id": replaced_consumable_id,
	})


func use_consumable(state: PlayerProgressionState, slot_index: int, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.held_consumable_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_consumable_slot_index")

	var consumable_id := state.held_consumable_ids[validated_index]
	if consumable_id == "":
		return _error(state, "consumable_slot_empty")

	var consumable_data := content.get_consumable(consumable_id)
	if consumable_data.is_empty():
		return _error(state, "unknown_consumable_id")

	state.held_consumable_ids[validated_index] = ""
	return _ok(state, {
		"slot_index": validated_index,
		"consumable_id": consumable_id,
		"effects": consumable_data.get("effects", []),
	})


func sell_consumable(state: PlayerProgressionState, slot_index: int, content: ContentRegistry) -> Dictionary:
	var validated_index := _validate_slot_index(slot_index, state.held_consumable_ids.size())
	if validated_index < 0:
		return _error(state, "invalid_consumable_slot_index")

	var consumable_id := state.held_consumable_ids[validated_index]
	if consumable_id == "":
		return _error(state, "consumable_slot_empty")

	var consumable_data: Dictionary = content.get_consumable(consumable_id)
	var sell_value := int(consumable_data.get("sell_value", consumable_data.get("base_price", 0)))
	state.held_consumable_ids[validated_index] = ""
	return _ok(state, {
		"slot_index": validated_index,
		"consumable_id": consumable_id,
		"gold_gained": maxi(0, sell_value),
	})


func add_relic(state: PlayerProgressionState, relic_id: String, content: ContentRegistry) -> Dictionary:
	if relic_id == "":
		return _error(state, "invalid_relic_id")
	if content.get_relic(relic_id).is_empty():
		return _error(state, "unknown_relic_id")
	if state.relic_ids.has(relic_id):
		return _error(state, "relic_already_owned")

	state.relic_ids.append(relic_id)
	_rebuild_active_effects(state, content)
	return _ok(state, {
		"relic_id": relic_id,
	})


func _rebuild_active_effects(state: PlayerProgressionState, content: ContentRegistry) -> void:
	state.active_effects_by_hook.clear()
	for item_id in state.equipped_item_ids:
		if item_id == "":
			continue
		_add_effects_to_hooks(state.active_effects_by_hook, item_id, content.get_equipment(item_id))
	for relic_id in state.relic_ids:
		_add_effects_to_hooks(state.active_effects_by_hook, relic_id, content.get_relic(relic_id))


func _add_effects_to_hooks(active_effects: Dictionary, source_id: String, source_data: Dictionary) -> void:
	var effects: Array = source_data.get("effects", [])
	for raw_effect in effects:
		var effect: Dictionary = raw_effect
		var hook_name := String(effect.get("hook", ""))
		if hook_name == "":
			continue
		if not active_effects.has(hook_name):
			active_effects[hook_name] = []
		var effect_with_source := effect.duplicate(true)
		effect_with_source["source_id"] = source_id
		active_effects[hook_name].append(effect_with_source)


func _find_empty_slot(slots: Array[String]) -> int:
	for index in slots.size():
		if slots[index] == "":
			return index
	return -1


func _validate_slot_index(slot_index: int, slot_count: int) -> int:
	if slot_index < 0 or slot_index >= slot_count:
		return -1
	return slot_index


func _ok(state: PlayerProgressionState, payload: Dictionary = {}) -> Dictionary:
	return {
		"ok": true,
		"reason": "",
		"result": payload,
		"state": state.to_snapshot(),
	}


func _error(state: PlayerProgressionState, reason: String) -> Dictionary:
	return {
		"ok": false,
		"reason": reason,
		"result": {},
		"state": state.to_snapshot(),
	}
