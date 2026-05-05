extends RefCounted


func build_text_report(snapshot: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append(_title_line(snapshot))
	lines.append(_summary_line(snapshot))
	lines.append("")
	lines.append("Events:")
	var events: Array = snapshot.get("events", [])
	if events.is_empty():
		lines.append("- (none)")
	else:
		for entry in events:
			lines.append(_event_text_line(Dictionary(entry)))
	return "\n".join(lines)


func build_markdown_report(snapshot: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("# Run Log Report")
	lines.append("")
	lines.append("- Run ID: `%s`" % String(snapshot.get("run_id", "")))
	lines.append("- Started: `%s`" % String(snapshot.get("started_iso", "")))
	lines.append("- Result: `%s`" % _result_label(snapshot))
	lines.append("- Level Reached: `%d`" % int(snapshot.get("dungeon_level", 0)))
	lines.append("- Gold: `%d`" % int(snapshot.get("run_gold", 0)))
	lines.append("- Events: `%d`" % int(snapshot.get("event_count", 0)))
	lines.append("")
	lines.append("## Timeline")
	lines.append("")
	var events: Array = snapshot.get("events", [])
	if events.is_empty():
		lines.append("- (none)")
	else:
		for entry in events:
			lines.append("- %s" % _event_text_line(Dictionary(entry)))
	return "\n".join(lines)


func _title_line(snapshot: Dictionary) -> String:
	return "Run Log Report | Run %s | Started %s" % [
		String(snapshot.get("run_id", "")),
		String(snapshot.get("started_iso", "")),
	]


func _summary_line(snapshot: Dictionary) -> String:
	return "Result: %s | Level: %d | Gold: %d | Events: %d" % [
		_result_label(snapshot),
		int(snapshot.get("dungeon_level", 0)),
		int(snapshot.get("run_gold", 0)),
		int(snapshot.get("event_count", 0)),
	]


func _result_label(snapshot: Dictionary) -> String:
	var summary: Dictionary = snapshot.get("summary", {})
	if summary.is_empty():
		if bool(snapshot.get("run_active", false)):
			return "Active"
		return "Not started"
	return "Victory" if bool(summary.get("victory", false)) else "Defeat"


func _event_text_line(entry: Dictionary) -> String:
	var seq := int(entry.get("seq", 0))
	var ts := String(entry.get("timestamp_iso", ""))
	var event_name := String(entry.get("event", "event"))
	var level := int(entry.get("dungeon_level", 0))
	var step := String(entry.get("step_key", ""))
	var payload: Dictionary = entry.get("payload", {})
	var payload_text := _payload_summary(event_name, payload)
	return "#%d [%s] %s | L%d %s%s" % [
		seq,
		ts,
		event_name,
		level,
		step,
		" | %s" % payload_text if payload_text != "" else "",
	]


func _payload_summary(event_name: String, payload: Dictionary) -> String:
	match event_name:
		"fight_start":
			var encounter: Dictionary = payload.get("encounter", {})
			return "enemy=%s boss=%s" % [
				String(encounter.get("display_name", encounter.get("enemy_id", ""))),
				"yes" if bool(encounter.get("is_boss", false)) else "no",
			]
		"fight_end":
			return "outcome=%s turns=%d enemy=%s" % [
				String(payload.get("outcome", "")),
				int(payload.get("turn_count", 0)),
				String(payload.get("enemy_name", payload.get("enemy_id", ""))),
			]
		"turn_result":
			return "enemy_damage=%d heal=%d armor=%d gold=%d player_damage=%d" % [
				int(payload.get("enemy_damage_taken", 0)),
				int(payload.get("healed", 0)),
				int(payload.get("armor_gained", 0)),
				int(payload.get("gold_gained", 0)),
				int(payload.get("damage_to_player", 0)),
			]
		"shop_action":
			var result: Dictionary = payload.get("result", {})
			return "action=%s ok=%s reason=%s" % [
				String(payload.get("action", "")),
				"true" if bool(result.get("ok", false)) else "false",
				String(result.get("reason", "")),
			]
		"boss_reward_choice":
			return "relic=%s option=%d" % [
				String(payload.get("display_name", payload.get("relic_id", ""))),
				int(payload.get("option_index", -1)),
			]
		"run_end":
			return "victory=%s cause=%s" % [
				"true" if bool(payload.get("victory", false)) else "false",
				String(payload.get("cause", "")),
			]
		_:
			if payload.is_empty():
				return ""
			return JSON.stringify(payload)
