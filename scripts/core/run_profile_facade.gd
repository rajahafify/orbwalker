extends RefCounted
class_name RunProfileFacade

var _owner


func _init(owner) -> void:
	_owner = owner


func progression_snapshot() -> Dictionary:
	return _owner.ensure_player_progression_state().to_snapshot()


func profile_snapshot() -> Dictionary:
	return _owner.ensure_player_profile_state().to_snapshot()


func meta_profile_snapshot() -> Dictionary:
	return _owner.ensure_meta_profile_state().to_snapshot()


func reset_profile() -> Dictionary:
	var signal_before: Dictionary = _owner._capture_run_signal_state()
	var profile = _owner.ensure_player_profile_state()
	profile.reset_to_default()
	_owner.meta_profile_state = profile.meta_profile
	_owner._sync_meta_profile_default_unlocks()
	_owner._save_profile()
	_owner.reset_run("reset_profile", false)
	_owner._emit_run_state_signals(signal_before, "reset_profile", "reset_profile")
	_owner._emit_profile_changed("reset_profile")
	return {
		"ok": true,
		"reason": "",
		"profile": profile_snapshot(),
		"meta_profile": meta_profile_snapshot(),
	}


func is_equipment_unlocked(item_id: String) -> bool:
	if item_id == "":
		return false
	return _owner.ensure_meta_profile_state().is_equipment_unlocked(item_id)


func unlock_equipment(item_id: String, source: String, emit_profile_signal: bool = true) -> Dictionary:
	var equipment: Dictionary = _owner.ensure_content_registry().get_equipment(item_id)
	if item_id == "":
		return {"ok": false, "reason": "invalid_item_id"}
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown_equipment_id"}
	if is_equipment_unlocked(item_id):
		return {"ok": false, "reason": "equipment_already_unlocked", "meta_profile": meta_profile_snapshot()}
	if not _owner.ensure_meta_profile_state().unlock_equipment(item_id):
		return {"ok": false, "reason": "unlock_failed", "meta_profile": meta_profile_snapshot()}

	var unlock_payload := {
		"item_id": item_id,
		"display_name": String(equipment.get("display_name", item_id)),
		"family_id": String(equipment.get("family_id", "")),
		"rarity": String(equipment.get("rarity", "common")),
		"rarity_color": String(equipment.get("rarity_color", "white")),
		"source": source,
		"unlock_cost": int(equipment.get("unlock_cost", 0)),
	}
	if source == "victory":
		_owner.ensure_meta_profile_state().add_recent_equipment_unlock(unlock_payload)
	_owner._save_meta_profile()
	if emit_profile_signal:
		_owner._emit_profile_changed("unlock_equipment", 0, unlock_payload)
	return {
		"ok": true,
		"reason": "",
		"unlock": unlock_payload,
		"meta_profile": meta_profile_snapshot(),
	}


func claim_equipment_unlock(item_id: String) -> Dictionary:
	var equipment: Dictionary = _owner.ensure_content_registry().get_equipment(item_id)
	if item_id == "":
		return {"ok": false, "reason": "invalid_item_id"}
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown_equipment_id"}
	if is_equipment_unlocked(item_id):
		return {"ok": false, "reason": "equipment_already_unlocked", "meta_profile": meta_profile_snapshot()}

	var unlock_cost := maxi(0, int(equipment.get("unlock_cost", 0)))
	if not _owner._ensure_profile_unlock_service().can_claim_equipment_unlock(equipment):
		return {"ok": false, "reason": "unlock_prerequisite_not_met", "meta_profile": meta_profile_snapshot()}
	if not _owner.ensure_meta_profile_state().spend_total_score(unlock_cost):
		return {"ok": false, "reason": "insufficient_total_score", "meta_profile": meta_profile_snapshot()}

	var unlock_result: Dictionary = unlock_equipment(item_id, "score_claim", false)
	if not bool(unlock_result.get("ok", false)):
		_owner.ensure_meta_profile_state().add_total_score(unlock_cost)
		_owner._save_meta_profile()
		return unlock_result
	_owner._emit_profile_changed("claim_equipment_unlock", -unlock_cost, Dictionary(unlock_result.get("unlock", {})))
	unlock_result["score_spent"] = unlock_cost
	return unlock_result


func consume_recent_equipment_unlocks() -> Array[Dictionary]:
	var unlocks: Array[Dictionary] = _owner.ensure_meta_profile_state().consume_recent_equipment_unlocks()
	_owner._save_meta_profile()
	_owner._emit_profile_changed("consume_recent_equipment_unlocks", 0, {"consumed": unlocks.duplicate(true)})
	return unlocks


func add_total_score(amount: int) -> int:
	var added: int = _owner.ensure_meta_profile_state().add_total_score(amount)
	if added > 0:
		_owner._save_meta_profile()
		_owner._emit_profile_changed("add_total_score", added)
	return added


func current_combat_modifiers() -> Dictionary:
	var modifiers := {
		"orb_bonus_by_id": {},
		"combo_flat_bonus": 0,
		"combo_multiplier_mult": 1.0,
		"start_turn_armor": 0,
		"flat_damage_bonus": 0,
		"flat_heal_bonus": 0,
		"flat_gold_bonus": 0,
		"sources": [],
	}
	var progression = _owner.ensure_player_progression_state()
	var content = _owner.ensure_content_registry()
	for item_id in progression.equipped_item_ids:
		var equipment: Dictionary = content.get_equipment(String(item_id))
		_merge_combat_modifiers(modifiers, equipment)
		_append_combat_modifier_source(modifiers, equipment, "equipment")
	for relic_id in progression.relic_ids:
		var relic: Dictionary = content.get_relic(String(relic_id))
		_merge_combat_modifiers(modifiers, relic)
		_append_combat_modifier_source(modifiers, relic, "relic")
	return modifiers


func _merge_combat_modifiers(target: Dictionary, source_data: Dictionary) -> void:
	var modifiers: Dictionary = source_data.get("combat_modifiers", {})
	var target_orb_bonus: Dictionary = target.get("orb_bonus_by_id", {})
	var source_orb_bonus: Dictionary = modifiers.get("orb_bonus_by_id", {})
	for orb_id in source_orb_bonus.keys():
		var orb_key := int(orb_id)
		target_orb_bonus[orb_key] = int(target_orb_bonus.get(orb_key, 0)) + int(source_orb_bonus.get(orb_id, 0))
	target["orb_bonus_by_id"] = target_orb_bonus
	target["combo_flat_bonus"] = int(target.get("combo_flat_bonus", 0)) + int(modifiers.get("combo_flat_bonus", 0))
	target["combo_multiplier_mult"] = float(target.get("combo_multiplier_mult", 1.0)) * float(modifiers.get("combo_multiplier_mult", 1.0))
	target["start_turn_armor"] = int(target.get("start_turn_armor", 0)) + int(modifiers.get("start_turn_armor", 0))
	target["flat_damage_bonus"] = int(target.get("flat_damage_bonus", 0)) + int(modifiers.get("flat_damage_bonus", 0))
	target["flat_heal_bonus"] = int(target.get("flat_heal_bonus", 0)) + int(modifiers.get("flat_heal_bonus", 0))
	target["flat_gold_bonus"] = int(target.get("flat_gold_bonus", 0)) + int(modifiers.get("flat_gold_bonus", 0))


func _append_combat_modifier_source(target: Dictionary, source_data: Dictionary, source_type: String) -> void:
	if source_data.is_empty():
		return
	var source_modifiers: Dictionary = source_data.get("combat_modifiers", {})
	if source_modifiers.is_empty():
		return
	var sources: Array = target.get("sources", [])
	(
		sources
		. append(
			{
				"source_type": source_type,
				"source_id": String(source_data.get("id", "")),
				"display_name": String(source_data.get("display_name", source_data.get("id", "unknown"))),
				"combat_modifiers": source_modifiers.duplicate(true),
			}
		)
	)
	target["sources"] = sources
