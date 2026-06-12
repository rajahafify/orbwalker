extends RefCounted
class_name RunProfileUnlockService

var _owner
var _save_meta_profile: Callable


func _init(owner, save_meta_profile: Callable = Callable()) -> void:
	_owner = owner
	_save_meta_profile = save_meta_profile


func sync_default_unlocks() -> void:
	var common_item_ids: Array[String] = []
	for equipment in _owner.ensure_content_registry().list_equipment():
		var data := Dictionary(equipment)
		if String(data.get("rarity", "")) != "common":
			continue
		var item_id := String(data.get("id", ""))
		if item_id != "":
			common_item_ids.append(item_id)
	if _owner.ensure_meta_profile_state().mark_default_unlocked(common_item_ids):
		if _save_meta_profile.is_valid():
			_save_meta_profile.call()


func can_claim_equipment_unlock(equipment: Dictionary) -> bool:
	var rarity := String(equipment.get("rarity", "common"))
	if rarity == "common":
		return true
	var previous_tier_item_id := previous_tier_item_id(String(equipment.get("id", "")))
	if previous_tier_item_id == "":
		return false
	return _owner.is_equipment_unlocked(previous_tier_item_id)


func previous_tier_item_id(target_item_id: String) -> String:
	if target_item_id == "":
		return ""
	for raw_equipment in _owner.ensure_content_registry().list_equipment():
		var equipment := Dictionary(raw_equipment)
		if String(equipment.get("next_tier_item_id", "")) == target_item_id:
			return String(equipment.get("id", ""))
	return ""


func grant_victory_equipment_unlocks() -> Array[Dictionary]:
	var unlocks: Array[Dictionary] = []
	var progression = _owner.ensure_player_progression_state()
	for slot_index in range(progression.equipped_item_ids.size()):
		var item_id := String(progression.equipped_item_ids[slot_index])
		if item_id == "":
			continue
		var equipment: Dictionary = _owner.ensure_content_registry().get_equipment(item_id)
		if equipment.is_empty():
			continue
		var next_tier_item_id := String(equipment.get("next_tier_item_id", ""))
		if next_tier_item_id == "" or _owner.is_equipment_unlocked(next_tier_item_id):
			continue
		var unlock_result: Dictionary = _owner.unlock_equipment(next_tier_item_id, "victory")
		if not bool(unlock_result.get("ok", false)):
			continue
		var unlock_payload := Dictionary(unlock_result.get("unlock", {}))
		unlock_payload["source_item_id"] = item_id
		unlock_payload["slot_index"] = slot_index
		unlocks.append(unlock_payload)
	return unlocks
