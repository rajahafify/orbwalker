extends RefCounted
class_name RunSummaryModel

var _summary: Dictionary = {}
var _victory: bool = false

func load_from_run_state() -> void:
	_summary = RunState.run_summary_snapshot().duplicate(true)
	_victory = bool(_summary.get("victory", false))


func summary_snapshot() -> Dictionary:
	return _summary.duplicate(true)


func is_victory() -> bool:
	return _victory


func title_text() -> String:
	return "VICTORY" if _victory else "DEFEAT"


func subtitle_text() -> String:
	if _victory:
		return "Final boss defeated. Prototype run cleared."
	return String(_summary.get("cause", "Run ended."))


func stats_rows() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var bosses_killed := int(_summary.get("bosses_defeated", 0))
	var monsters_killed := maxi(0, int(_summary.get("enemies_defeated", 0)) - bosses_killed)
	rows.append({"label": "LEVEL", "value": "%d / %d" % [int(_summary.get("level_reached", 1)), RunState.MAX_DUNGEON_LEVELS]})
	rows.append({"label": "MONSTERS", "value": str(monsters_killed)})
	rows.append({"label": "BOSSES", "value": str(bosses_killed)})
	rows.append({"label": "GOLD EARNED", "value": "+%d" % int(_summary.get("gold_earned", 0)), "accent": "gold"})
	rows.append({"label": "FINAL GOLD", "value": str(int(_summary.get("final_gold", 0))), "accent": "gold"})
	rows.append({"label": "RESULT", "value": "CLEAR" if _victory else "FALLEN"})
	return rows


func equipment_lines() -> Array[String]:
	return _format_named_slots(Array(_summary.get("equipment_slots", [])))


func relic_lines() -> Array[String]:
	return _format_named_ids(Array(_summary.get("relic_ids", [])))


func consume_recent_unlock_entries() -> Array[Dictionary]:
	return _normalize_unlock_entries(_consume_recent_unlock_payload())


func discard_recent_unlocks() -> void:
	_consume_recent_unlock_payload()


func snapshot() -> Dictionary:
	return {
		"summary": _summary.duplicate(true),
		"victory": _victory,
	}


func _consume_recent_unlock_payload() -> Variant:
	for method_name in ["consume_recent_equipment_unlocks", "consume_recent_unlocks", "consume_recent_meta_unlocks"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name)
	return []


func _normalize_unlock_entries(payload: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if payload is Array:
		for entry in payload as Array:
			if entry is Dictionary:
				out.append((entry as Dictionary).duplicate(true))
			elif entry is String:
				out.append({"item_id": String(entry), "display_name": _title_case_id(String(entry))})
		return out
	if payload is Dictionary:
		var typed_payload := payload as Dictionary
		for key in ["unlocks", "recent_unlocks", "recent_equipment_unlocks"]:
			if typed_payload.has(key):
				return _normalize_unlock_entries(typed_payload.get(key, []))
	return out


func _format_named_slots(values: Array) -> Array[String]:
	var parts: Array[String] = []
	for index in values.size():
		var value := String(values[index])
		parts.append("%d. %s" % [index + 1, value if value != "" else "Empty"])
	return parts


func _format_named_ids(values: Array) -> Array[String]:
	if values.is_empty():
		return ["None claimed"]
	var parts: Array[String] = []
	for value in values:
		parts.append(_title_case_id(String(value)))
	return parts


func _title_case_id(value: String) -> String:
	var words := value.replace("_", " ").split(" ", false)
	for index in words.size():
		words[index] = String(words[index]).capitalize()
	return " ".join(words)
