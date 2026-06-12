extends RefCounted
class_name RunProfileUnlockServiceTest

const SERVICE_SCRIPT := preload("res://scripts/core/run_profile_unlock_service.gd")


class FakeMetaProfile:
	var unlocked: Dictionary = {}
	var saved_count := 0

	func mark_default_unlocked(item_ids: Array[String]) -> bool:
		var changed := false
		for item_id in item_ids:
			if not unlocked.has(item_id):
				unlocked[item_id] = true
				changed = true
		return changed


class FakeProgression:
	var equipped_item_ids: Array[String] = ["starter_sword", ""]


class FakeContentRegistry:
	var equipment_by_id := {
		"starter_sword":
		{
			"id": "starter_sword",
			"display_name": "Starter Sword",
			"rarity": "common",
			"next_tier_item_id": "sharp_sword",
		},
		"sharp_sword":
		{
			"id": "sharp_sword",
			"display_name": "Sharp Sword",
			"rarity": "uncommon",
			"next_tier_item_id": "",
		},
	}

	func list_equipment() -> Array[Dictionary]:
		return [equipment_by_id["starter_sword"].duplicate(true), equipment_by_id["sharp_sword"].duplicate(true)]

	func get_equipment(item_id: String) -> Dictionary:
		return Dictionary(equipment_by_id.get(item_id, {})).duplicate(true)


class FakeOwner:
	var content := FakeContentRegistry.new()
	var meta := FakeMetaProfile.new()
	var progression := FakeProgression.new()
	var unlock_calls: Array[Dictionary] = []

	func ensure_content_registry():
		return content

	func ensure_meta_profile_state():
		return meta

	func ensure_player_progression_state():
		return progression

	func is_equipment_unlocked(item_id: String) -> bool:
		return bool(meta.unlocked.get(item_id, false))

	func unlock_equipment(item_id: String, source: String, _emit_profile_signal: bool = true) -> Dictionary:
		meta.unlocked[item_id] = true
		var unlock := {"item_id": item_id, "source": source}
		unlock_calls.append(unlock.duplicate(true))
		return {"ok": true, "reason": "", "unlock": unlock}

	func save_meta_profile() -> void:
		meta.saved_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("sync_defaults_saves_when_common_unlocks_change", _test_sync_defaults_saves_when_common_unlocks_change, failures)
	_run_case("victory_unlocks_next_equipped_tier", _test_victory_unlocks_next_equipped_tier, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_sync_defaults_saves_when_common_unlocks_change() -> String:
	var owner := FakeOwner.new()
	var service = SERVICE_SCRIPT.new(owner, Callable(owner, "save_meta_profile"))
	service.sync_default_unlocks()
	if not owner.is_equipment_unlocked("starter_sword"):
		return "Expected common starter equipment to be default unlocked."
	if owner.meta.saved_count != 1:
		return "Expected changed default unlock sync to save meta profile once."
	service.sync_default_unlocks()
	if owner.meta.saved_count != 1:
		return "Expected unchanged default unlock sync not to save again."
	return ""


func _test_victory_unlocks_next_equipped_tier() -> String:
	var owner := FakeOwner.new()
	owner.meta.unlocked["starter_sword"] = true
	var service = SERVICE_SCRIPT.new(owner)
	var unlocks: Array[Dictionary] = service.grant_victory_equipment_unlocks()
	if unlocks.size() != 1:
		return "Expected one victory unlock for the equipped starter item."
	var unlock := unlocks[0]
	if String(unlock.get("item_id", "")) != "sharp_sword":
		return "Expected sharp_sword to unlock from starter_sword victory."
	if String(unlock.get("source_item_id", "")) != "starter_sword":
		return "Expected victory unlock payload to include source item id."
	if int(unlock.get("slot_index", -1)) != 0:
		return "Expected victory unlock payload to include equipped slot index."
	return ""
