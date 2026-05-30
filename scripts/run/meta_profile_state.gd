extends RefCounted
class_name MetaProfileState

const TOTAL_SCORE_KEY := "total_score"
const STATS_KEY := "stats"
const UNLOCKED_EQUIPMENT_IDS_KEY := "unlocked_equipment_ids"
const LEGACY_UNLOCKED_EQUIPMENT_ID_KEYS := [
	"unlocked_equipment_item_ids",
	"equipment_unlock_ids",
]
const RECENT_EQUIPMENT_UNLOCKS_KEY := "recent_equipment_unlocks"
const LEGACY_RECENT_EQUIPMENT_UNLOCK_KEYS := [
	"recent_unlocks",
	"unlocks",
]

var total_score: int = 0
var unlocked_equipment_ids: Dictionary = {}
var recent_equipment_unlocks: Array[Dictionary] = []


func load_from_config(config: ConfigFile, section: String) -> void:
	migrate_config_to_current(config, section)
	total_score = maxi(0, int(config.get_value(section, TOTAL_SCORE_KEY, 0)))
	unlocked_equipment_ids.clear()
	for item_id in _string_entries(config.get_value(section, UNLOCKED_EQUIPMENT_IDS_KEY, [])):
		unlocked_equipment_ids[item_id] = true
	recent_equipment_unlocks.clear()
	for unlock_data in _unlock_entries(config.get_value(section, RECENT_EQUIPMENT_UNLOCKS_KEY, [])):
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


static func migrate_config_to_current(config: ConfigFile, section: String) -> Dictionary:
	var steps: Array[String] = []
	if _migrate_total_score(config, section):
		steps.append("stats_total_score_to_total_score")
	if _migrate_unlocked_equipment_ids(config, section):
		steps.append("equipment_unlock_aliases_to_unlocked_equipment_ids")
	if _migrate_recent_equipment_unlocks(config, section):
		steps.append("recent_unlock_aliases_to_recent_equipment_unlocks")
	return {
		"ok": true,
		"migrated": not steps.is_empty(),
		"steps": steps,
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


static func _migrate_total_score(config: ConfigFile, section: String) -> bool:
	if _has_config_value(config, section, TOTAL_SCORE_KEY):
		return false
	var stats_value: Variant = config.get_value(section, STATS_KEY, {})
	if not (stats_value is Dictionary):
		return false
	var stats := Dictionary(stats_value)
	if not stats.has(TOTAL_SCORE_KEY):
		return false
	config.set_value(section, TOTAL_SCORE_KEY, maxi(0, int(stats.get(TOTAL_SCORE_KEY, 0))))
	return true


static func _migrate_unlocked_equipment_ids(config: ConfigFile, section: String) -> bool:
	var keys := [UNLOCKED_EQUIPMENT_IDS_KEY]
	keys.append_array(LEGACY_UNLOCKED_EQUIPMENT_ID_KEYS)
	var merged := _merged_string_entries(config, section, keys)
	if merged.is_empty():
		return false
	var current_value: Variant = config.get_value(section, UNLOCKED_EQUIPMENT_IDS_KEY, [])
	var current := _string_entries(current_value)
	var alias_present := _has_any_config_value(config, section, LEGACY_UNLOCKED_EQUIPMENT_ID_KEYS)
	var canonical_needs_normalization := _has_config_value(config, section, UNLOCKED_EQUIPMENT_IDS_KEY) and not (current_value is Array)
	if merged == current and not alias_present and not canonical_needs_normalization:
		return false
	config.set_value(section, UNLOCKED_EQUIPMENT_IDS_KEY, merged)
	return true


static func _migrate_recent_equipment_unlocks(config: ConfigFile, section: String) -> bool:
	var keys := [RECENT_EQUIPMENT_UNLOCKS_KEY]
	keys.append_array(LEGACY_RECENT_EQUIPMENT_UNLOCK_KEYS)
	var merged := _merged_unlock_entries(config, section, keys)
	if merged.is_empty():
		return false
	var current_value: Variant = config.get_value(section, RECENT_EQUIPMENT_UNLOCKS_KEY, [])
	var current := _unlock_entries(current_value)
	var alias_present := _has_any_config_value(config, section, LEGACY_RECENT_EQUIPMENT_UNLOCK_KEYS)
	var canonical_needs_normalization := _has_config_value(config, section, RECENT_EQUIPMENT_UNLOCKS_KEY) and _recent_unlocks_need_normalization(current_value)
	if _unlock_entries_equal(merged, current) and not alias_present and not canonical_needs_normalization:
		return false
	config.set_value(section, RECENT_EQUIPMENT_UNLOCKS_KEY, merged)
	return true


static func _merged_string_entries(config: ConfigFile, section: String, keys: Array) -> Array[String]:
	var seen := {}
	var entries: Array[String] = []
	for key_value in keys:
		var key := String(key_value)
		if not _has_config_value(config, section, key):
			continue
		for entry in _string_entries(config.get_value(section, key, [])):
			if seen.has(entry):
				continue
			seen[entry] = true
			entries.append(entry)
	entries.sort()
	return entries


static func _string_entries(value: Variant) -> Array[String]:
	var entries: Array[String] = []
	if value is Array:
		for raw_entry in Array(value):
			var entry := String(raw_entry).strip_edges()
			if entry != "":
				entries.append(entry)
	elif value is Dictionary:
		for raw_key in Dictionary(value).keys():
			var entry := String(raw_key).strip_edges()
			if entry != "" and bool(Dictionary(value).get(raw_key, false)):
				entries.append(entry)
	else:
		var entry := String(value).strip_edges()
		if entry != "":
			entries.append(entry)
	return entries


static func _merged_unlock_entries(config: ConfigFile, section: String, keys: Array) -> Array[Dictionary]:
	var seen := {}
	var entries: Array[Dictionary] = []
	for key_value in keys:
		var key := String(key_value)
		if not _has_config_value(config, section, key):
			continue
		for entry in _unlock_entries(config.get_value(section, key, [])):
			var fingerprint := _unlock_entry_fingerprint(entry)
			if seen.has(fingerprint):
				continue
			seen[fingerprint] = true
			entries.append(entry)
	return entries


static func _unlock_entries(value: Variant) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if value is Array:
		for raw_entry in Array(value):
			var entry := _normalized_unlock_entry(raw_entry)
			if not entry.is_empty():
				entries.append(entry)
	else:
		var entry := _normalized_unlock_entry(value)
		if not entry.is_empty():
			entries.append(entry)
	return entries


static func _normalized_unlock_entry(raw_unlock: Variant) -> Dictionary:
	if raw_unlock is Dictionary:
		var data: Dictionary = Dictionary(raw_unlock).duplicate(true)
		var item_id := String(data.get("item_id", data.get("id", ""))).strip_edges()
		if item_id != "":
			data["item_id"] = item_id
		if String(data.get("display_name", "")).strip_edges() == "" and item_id != "":
			data["display_name"] = _title_case_id(item_id)
		return data
	var item_id := String(raw_unlock).strip_edges()
	if item_id == "":
		return {}
	return {
		"item_id": item_id,
		"display_name": _title_case_id(item_id),
	}


static func _unlock_entry_fingerprint(entry: Dictionary) -> String:
	return "%s|%s|%s" % [
		String(entry.get("item_id", "")),
		String(entry.get("display_name", "")),
		String(entry.get("source", "")),
	]


static func _unlock_entries_equal(left: Array[Dictionary], right: Array[Dictionary]) -> bool:
	if left.size() != right.size():
		return false
	for index in left.size():
		if left[index] != right[index]:
			return false
	return true


static func _recent_unlocks_need_normalization(value: Variant) -> bool:
	if not (value is Array):
		return true
	for raw_entry in Array(value):
		if not (raw_entry is Dictionary):
			return true
		if String(Dictionary(raw_entry).get("item_id", "")).strip_edges() == "":
			return true
	return false


static func _has_any_config_value(config: ConfigFile, section: String, keys: Array) -> bool:
	for key_value in keys:
		if _has_config_value(config, section, String(key_value)):
			return true
	return false


static func _has_config_value(config: ConfigFile, section: String, key: String) -> bool:
	return config.has_section(section) and config.has_section_key(section, key)


static func _title_case_id(item_id: String) -> String:
	return item_id.replace("_", " ").capitalize()
