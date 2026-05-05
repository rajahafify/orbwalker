extends RefCounted
class_name MetaProfileState

var total_score: int = 0
var unlocked_equipment_ids: Dictionary = {}
var recent_equipment_unlocks: Array[Dictionary] = []


func load_from_config(config: ConfigFile, section: String) -> void:
	total_score = maxi(0, int(config.get_value(section, "total_score", 0)))
	unlocked_equipment_ids.clear()
	for raw_id in Array(config.get_value(section, "unlocked_equipment_ids", [])):
		var item_id := String(raw_id).strip_edges()
		if item_id != "":
			unlocked_equipment_ids[item_id] = true
	recent_equipment_unlocks.clear()
	var loaded_unlocks: Array = Array(config.get_value(section, "recent_equipment_unlocks", []))
	for raw_unlock in loaded_unlocks:
		var unlock_data := Dictionary(raw_unlock)
		if unlock_data.is_empty():
			continue
		recent_equipment_unlocks.append(unlock_data.duplicate(true))


func save_to_config(config: ConfigFile, section: String) -> void:
	config.set_value(section, "total_score", total_score)
	config.set_value(section, "unlocked_equipment_ids", _sorted_unlocked_equipment_ids())
	config.set_value(section, "recent_equipment_unlocks", recent_equipment_unlocks.duplicate(true))


func to_snapshot() -> Dictionary:
	return {
		"total_score": total_score,
		"unlocked_equipment_ids": _sorted_unlocked_equipment_ids(),
		"recent_equipment_unlocks": recent_equipment_unlocks.duplicate(true),
	}


func is_equipment_unlocked(item_id: String) -> bool:
	return unlocked_equipment_ids.has(item_id)


func unlock_equipment(item_id: String) -> bool:
	if item_id == "" or unlocked_equipment_ids.has(item_id):
		return false
	unlocked_equipment_ids[item_id] = true
	return true


func mark_default_unlocked(item_ids: Array[String]) -> bool:
	var changed := false
	for raw_id in item_ids:
		var item_id := String(raw_id).strip_edges()
		if item_id == "":
			continue
		if unlocked_equipment_ids.has(item_id):
			continue
		unlocked_equipment_ids[item_id] = true
		changed = true
	return changed


func add_recent_equipment_unlock(unlock_data: Dictionary) -> void:
	if unlock_data.is_empty():
		return
	recent_equipment_unlocks.append(unlock_data.duplicate(true))


func consume_recent_equipment_unlocks() -> Array[Dictionary]:
	var payload := recent_equipment_unlocks.duplicate(true)
	recent_equipment_unlocks.clear()
	return payload


func add_total_score(amount: int) -> int:
	if amount <= 0:
		return 0
	total_score += amount
	return amount


func spend_total_score(amount: int) -> bool:
	if amount < 0:
		return false
	if total_score < amount:
		return false
	total_score -= amount
	return true


func _sorted_unlocked_equipment_ids() -> Array[String]:
	var ids: Array[String] = []
	for raw_id in unlocked_equipment_ids.keys():
		var item_id := String(raw_id)
		if item_id != "":
			ids.append(item_id)
	ids.sort()
	return ids
