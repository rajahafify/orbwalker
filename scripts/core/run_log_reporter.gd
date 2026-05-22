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


func build_html_report(snapshot: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("<!doctype html>")
	lines.append("<html lang=\"en\">")
	lines.append("<head>")
	lines.append("<meta charset=\"utf-8\">")
	lines.append("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">")
	lines.append("<title>Run Log Report</title>")
	lines.append("<style>")
	lines.append("body{margin:0;background:#f7f8fb;color:#18202a;font:16px/1.6 system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif}")
	lines.append("main{max-width:960px;margin:32px auto;padding:32px;background:#fff;border:1px solid #d9dee7;border-radius:12px}")
	lines.append("h1{margin-top:0}.summary{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin:20px 0}.card{padding:12px;border:1px solid #d9dee7;border-radius:8px;background:#eef4ff}.event{padding:10px 0;border-bottom:1px solid #d9dee7}code{background:#eef1f5;padding:.12em .35em;border-radius:4px}")
	lines.append("</style>")
	lines.append("</head>")
	lines.append("<body><main>")
	lines.append("<h1>Run Log Report</h1>")
	lines.append("<section class=\"summary\">")
	lines.append(_html_summary_card("Run ID", String(snapshot.get("run_id", ""))))
	lines.append(_html_summary_card("Started", String(snapshot.get("started_iso", ""))))
	lines.append(_html_summary_card("Result", _result_label(snapshot)))
	lines.append(_html_summary_card("Level Reached", str(int(snapshot.get("dungeon_level", 0)))))
	lines.append(_html_summary_card("Gold", str(int(snapshot.get("run_gold", 0)))))
	lines.append(_html_summary_card("Events", str(int(snapshot.get("event_count", 0)))))
	lines.append("</section>")
	lines.append("<h2>Timeline</h2>")
	var events: Array = snapshot.get("events", [])
	if events.is_empty():
		lines.append("<p>(none)</p>")
	else:
		for entry in events:
			lines.append("<div class=\"event\"><code>%s</code></div>" % _html_escape(_event_text_line(Dictionary(entry))))
	lines.append("</main></body></html>")
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


func _html_summary_card(label: String, value: String) -> String:
	return "<div class=\"card\"><strong>%s</strong><br><code>%s</code></div>" % [
		_html_escape(label),
		_html_escape(value),
	]


func _html_escape(value: String) -> String:
	return value.xml_escape()


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
		"shop_open":
			var shop_ordinal := int(payload.get("shop_ordinal", 0))
			var shop: Dictionary = payload.get("shop", {})
			var prefix := "shop_open"
			if shop_ordinal > 0:
				prefix = "shop_open#%d" % shop_ordinal
			return "%s %s" % [prefix, _shop_snapshot_summary(shop)]
		"shop_action":
			var result: Dictionary = payload.get("result", {})
			var details: Dictionary = payload.get("details", {})
			var line_parts: Array[String] = []
			line_parts.append("action=%s" % String(payload.get("action", "")))
			line_parts.append("ok=%s" % ("true" if bool(result.get("ok", false)) else "false"))
			var reason := String(result.get("reason", ""))
			if reason != "":
				line_parts.append("reason=%s" % reason)
			line_parts.append("gold=%d->%d" % [
				int(payload.get("gold_before", int(result.get("gold", 0)))),
				int(payload.get("gold_after", int(result.get("gold", 0)))),
			])
			var details_summary := _shop_action_details_summary(details)
			if details_summary != "":
				line_parts.append(details_summary)
			line_parts.append("before{%s}" % _shop_snapshot_summary(payload.get("shop_before", {})))
			line_parts.append("after{%s}" % _shop_snapshot_summary(payload.get("shop_after", {})))
			return " | ".join(line_parts)
		"shop_leave":
			var leave_parts: Array[String] = []
			leave_parts.append("skipped=%s" % ("true" if bool(payload.get("mark_skipped", false)) else "false"))
			leave_parts.append("before{%s}" % _shop_snapshot_summary(payload.get("shop_before", {})))
			leave_parts.append("after{%s}" % _shop_snapshot_summary(payload.get("shop_after", {})))
			return " | ".join(leave_parts)
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


func _shop_action_details_summary(details: Dictionary) -> String:
	if details.is_empty():
		return ""
	var parts: Array[String] = []
	var selected_offer: Dictionary = details.get("selected_offer", {})
	if not selected_offer.is_empty():
		parts.append("selected=%s" % _shop_offer_summary(selected_offer, bool(selected_offer.get("owned", false))))
	var selected_option: Dictionary = details.get("selected_treasure_chest_option", {})
	if not selected_option.is_empty():
		parts.append("selected_treasure_chest=%s" % _treasure_chest_option_summary(selected_option))
	var granted: Dictionary = details.get("granted", {})
	if not granted.is_empty():
		parts.append("granted=%s" % _treasure_chest_option_summary(granted))
	var purchased_offer: Dictionary = details.get("purchased_offer", {})
	if not purchased_offer.is_empty():
		parts.append("purchased=%s" % _shop_offer_summary(purchased_offer, bool(purchased_offer.get("owned", false))))
	var replacement: Dictionary = details.get("replacement", {})
	if not replacement.is_empty():
		parts.append("replacement=%s" % JSON.stringify(replacement))
	if bool(details.get("discarded", false)):
		parts.append("discarded=true")
	return " ".join(parts)


func _shop_snapshot_summary(shop: Dictionary) -> String:
	if shop.is_empty():
		return "n/a"
	var parts: Array[String] = []
	var offers: Array = shop.get("item_offers", [])
	parts.append("items=%s" % _shop_offer_list_summary(offers))
	parts.append("types=%s" % _dict_count_summary(shop.get("item_type_counts", {})))
	var relic_offer: Dictionary = shop.get("relic_offer", {})
	if relic_offer.is_empty():
		parts.append("relic=none")
	else:
		parts.append("relic=%s" % _shop_offer_summary(relic_offer, bool(relic_offer.get("owned", false))))
	parts.append("reroll=%d@$%d afford=%s" % [
		int(shop.get("reroll_count", 0)),
		int(shop.get("reroll_cost", 0)),
		"yes" if bool(shop.get("can_afford_reroll", false)) else "no",
	])
	var pending_count := int(shop.get("pending_treasure_chest_option_count", 0))
	parts.append("treasure_chest_opts=%d" % pending_count)
	if pending_count > 0:
		parts.append("treasure_chest_list=%s" % _treasure_chest_option_list_summary(shop.get("pending_treasure_chest_options", [])))
	return "; ".join(parts)


func _shop_offer_list_summary(offers: Array) -> String:
	if offers.is_empty():
		return "none"
	var parts: Array[String] = []
	var limit := mini(offers.size(), 4)
	for idx in range(limit):
		parts.append(_shop_offer_summary(Dictionary(offers[idx])))
	if offers.size() > limit:
		parts.append("+%d more" % (offers.size() - limit))
	return ", ".join(parts)


func _treasure_chest_option_list_summary(options: Array) -> String:
	if options.is_empty():
		return "none"
	var parts: Array[String] = []
	var limit := mini(options.size(), 4)
	for idx in range(limit):
		parts.append(_treasure_chest_option_summary(Dictionary(options[idx])))
	if options.size() > limit:
		parts.append("+%d more" % (options.size() - limit))
	return ", ".join(parts)


func _shop_offer_summary(offer: Dictionary, include_owned: bool = false) -> String:
	if offer.is_empty():
		return "none"
	var sold_out := bool(offer.get("sold_out", false))
	var available := bool(offer.get("available", not sold_out))
	var state := "sold" if sold_out else ("open" if available else "closed")
	var id_label := String(offer.get("content_id", ""))
	if id_label == "":
		id_label = String(offer.get("offer_id", ""))
	var suffix := ""
	if include_owned:
		suffix = " owned=%s" % ("yes" if bool(offer.get("owned", false)) else "no")
	return "%s/%s $%d %s afford=%s%s" % [
		id_label,
		String(offer.get("type", "")),
		int(offer.get("price", 0)),
		state,
		"yes" if bool(offer.get("can_afford", false)) else "no",
		suffix,
	]


func _treasure_chest_option_summary(option: Dictionary) -> String:
	if option.is_empty():
		return "none"
	var content_id := String(option.get("content_id", ""))
	if content_id == "":
		content_id = String(option.get("display_name", ""))
	return "%s/%s" % [content_id, String(option.get("type", ""))]


func _dict_count_summary(raw_counts: Dictionary) -> String:
	if raw_counts.is_empty():
		return "none"
	var keys: Array = raw_counts.keys()
	keys.sort()
	var entries: Array[String] = []
	for raw_key in keys:
		var key := String(raw_key)
		entries.append("%s:%d" % [key, int(raw_counts.get(raw_key, 0))])
	return "{%s}" % ", ".join(entries)
