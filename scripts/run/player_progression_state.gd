extends RefCounted
class_name PlayerProgressionState

const EQUIPMENT_SLOT_COUNT := 5
const CONSUMABLE_SLOT_COUNT := 3
const MASTERY_CAP := 5

var equipped_item_ids: Array[String] = []
var held_consumable_ids: Array[String] = []
var relic_ids: Array[String] = []
var mastery_levels: Dictionary = {}
var active_effects_by_hook: Dictionary = {}


func _init() -> void:
	reset_for_new_run()


func reset_for_new_run() -> void:
	equipped_item_ids = _build_empty_slots(EQUIPMENT_SLOT_COUNT)
	held_consumable_ids = _build_empty_slots(CONSUMABLE_SLOT_COUNT)
	relic_ids.clear()
	mastery_levels.clear()
	for orb_id in OrbType.ALL_TYPES:
		mastery_levels[orb_id] = 0
	active_effects_by_hook.clear()


func equipment_count() -> int:
	return _count_filled_slots(equipped_item_ids)


func consumable_count() -> int:
	return _count_filled_slots(held_consumable_ids)


func has_relic(relic_id: String) -> bool:
	return relic_ids.has(relic_id)


func mastery_level(orb_id: int) -> int:
	return int(mastery_levels.get(orb_id, 0))


func to_snapshot() -> Dictionary:
	return {
		"equipment_slots": equipped_item_ids.duplicate(),
		"consumable_slots": held_consumable_ids.duplicate(),
		"relic_ids": relic_ids.duplicate(),
		"mastery_levels": mastery_levels.duplicate(true),
		"equipment_slot_count": EQUIPMENT_SLOT_COUNT,
		"consumable_slot_count": CONSUMABLE_SLOT_COUNT,
		"mastery_cap": MASTERY_CAP,
		"active_effects_by_hook": active_effects_by_hook.duplicate(true),
	}


func _build_empty_slots(slot_count: int) -> Array[String]:
	var slots: Array[String] = []
	slots.resize(slot_count)
	for index in slot_count:
		slots[index] = ""
	return slots


func _count_filled_slots(slots: Array[String]) -> int:
	var total := 0
	for slot_value in slots:
		if slot_value != "":
			total += 1
	return total
