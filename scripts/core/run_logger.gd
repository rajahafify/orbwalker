extends RefCounted
class_name RunLogger

const RUN_LOG_REPORTER_SCRIPT := preload("res://scripts/core/run_log_reporter.gd")

var _owner
var _rng := RandomNumberGenerator.new()
var _events: Array[Dictionary] = []
var _event_serial: int = 0
var _run_id: String = ""
var _started_unix: int = 0
var _started_iso: String = ""
var _current_fight_turns: int = 0
var _last_export_paths: Dictionary = {}
var _last_export_errors: Array[String] = []
var _last_export_unix: int = 0
var _generate_log_files := false


func _init(owner) -> void:
	_owner = owner
	_rng.randomize()


func run_log_snapshot() -> Dictionary:
	return {
		"run_id": _run_id,
		"started_unix": _started_unix,
		"started_iso": _started_iso,
		"event_count": _events.size(),
		"run_active": _owner.run_active,
		"run_victory": _owner.run_victory,
		"dungeon_level": _owner.dungeon_level,
		"current_step_key": _owner.current_step_key,
		"run_gold": _owner.run_gold,
		"run_score": _owner.run_score,
		"enemies_defeated": _owner.enemies_defeated,
		"bosses_defeated": _owner.bosses_defeated,
		"generate_log_files_enabled": _generate_log_files,
		"last_export": run_log_last_export_snapshot(),
		"summary": _owner.run_summary_snapshot(),
		"events": _events.duplicate(true),
	}


func run_log_export_json(pretty: bool = true) -> String:
	return JSON.stringify(run_log_snapshot(), "  " if pretty else "")


func run_log_export_text() -> String:
	var reporter = RUN_LOG_REPORTER_SCRIPT.new()
	return reporter.build_text_report(run_log_snapshot())


func run_log_export_markdown() -> String:
	var reporter = RUN_LOG_REPORTER_SCRIPT.new()
	return reporter.build_markdown_report(run_log_snapshot())


func run_log_last_export_snapshot() -> Dictionary:
	return {
		"paths": _last_export_paths.duplicate(true),
		"errors": _last_export_errors.duplicate(),
		"exported_unix": _last_export_unix,
	}


func run_log_last_export_paths() -> Dictionary:
	return _last_export_paths.duplicate(true)


func generate_run_log_files_enabled() -> bool:
	return _generate_log_files


func set_generate_run_log_files_enabled(enabled: bool) -> void:
	_generate_log_files = enabled


func load_user_settings(path: String, section: String, key: String) -> void:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error == OK:
		_generate_log_files = bool(config.get_value(section, key, false))
	else:
		_generate_log_files = false


func save_user_settings(path: String, section: String, key: String) -> void:
	var config := ConfigFile.new()
	config.set_value(section, key, _generate_log_files)
	var error := config.save(path)
	if error != OK:
		push_warning("Failed to save user settings at %s: %d" % [path, error])


func run_log_reset() -> void:
	_events.clear()
	_event_serial = 0
	_run_id = _run_log_create_run_id()
	_started_unix = int(Time.get_unix_time_from_system())
	_started_iso = Time.get_datetime_string_from_system()
	_current_fight_turns = 0
	_last_export_paths.clear()
	_last_export_errors.clear()
	_last_export_unix = 0


func run_log_append(event_type: String, payload: Dictionary) -> void:
	_event_serial += 1
	_events.append(
		{
			"seq": _event_serial,
			"event": event_type,
			"timestamp_unix": int(Time.get_unix_time_from_system()),
			"timestamp_iso": Time.get_datetime_string_from_system(),
			"run_id": _run_id,
			"dungeon_level": _owner.dungeon_level,
			"step_key": _owner.current_step_key,
			"run_gold": _owner.run_gold,
			"run_score": _owner.run_score,
			"run_active": _owner.run_active,
			"payload": payload.duplicate(true),
		}
	)


func transition_snapshot() -> Dictionary:
	return {
		"run_log_events": _events.duplicate(true),
		"run_log_event_serial": _event_serial,
		"run_log_run_id": _run_id,
		"run_log_started_unix": _started_unix,
		"run_log_started_iso": _started_iso,
		"run_log_current_fight_turns": _current_fight_turns,
		"run_log_last_export_paths": _last_export_paths.duplicate(true),
		"run_log_last_export_errors": _last_export_errors.duplicate(),
		"run_log_last_export_unix": _last_export_unix,
	}


func restore_transition_snapshot(snapshot: Dictionary) -> void:
	_events = Array(snapshot.get("run_log_events", _events)).duplicate(true)
	_event_serial = int(snapshot.get("run_log_event_serial", _event_serial))
	_run_id = String(snapshot.get("run_log_run_id", _run_id))
	_started_unix = int(snapshot.get("run_log_started_unix", _started_unix))
	_started_iso = String(snapshot.get("run_log_started_iso", _started_iso))
	_current_fight_turns = maxi(0, int(snapshot.get("run_log_current_fight_turns", _current_fight_turns)))
	_last_export_paths = Dictionary(snapshot.get("run_log_last_export_paths", _last_export_paths)).duplicate(true)
	_last_export_errors = Array(snapshot.get("run_log_last_export_errors", _last_export_errors)).duplicate()
	_last_export_unix = int(snapshot.get("run_log_last_export_unix", _last_export_unix))


func next_turn_index_for_fight() -> int:
	return _current_fight_turns + 1


func advance_turn_counter() -> void:
	_current_fight_turns += 1


func reset_fight_turn_counter() -> void:
	_current_fight_turns = 0


func should_export_run_log_files() -> bool:
	return _generate_log_files


func run_log_export_to_disk(export_dir: String) -> void:
	_last_export_paths.clear()
	_last_export_errors.clear()
	_last_export_unix = int(Time.get_unix_time_from_system())

	var absolute_dir := ProjectSettings.globalize_path(export_dir)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_dir)
	if mkdir_error != OK:
		_last_export_errors.append("mkdir_failed:%s:%d" % [absolute_dir, mkdir_error])
		return

	var run_slug := _run_log_safe_filename_fragment(_run_id)
	var started_slug := _run_log_safe_filename_fragment(_started_iso)
	if started_slug == "":
		started_slug = str(_started_unix)
	var base_name := "%s_%s" % [run_slug, started_slug]

	_run_log_write_export_file(base_name + ".json", run_log_export_json(true), "json", export_dir)
	_run_log_write_export_file(base_name + ".md", run_log_export_markdown(), "markdown", export_dir)
	_run_log_write_export_file(base_name + ".txt", run_log_export_text(), "text", export_dir)


func _run_log_write_export_file(file_name: String, contents: String, kind: String, export_dir: String) -> void:
	var resource_path := export_dir.path_join(file_name)
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		_last_export_errors.append("write_failed:%s:%d" % [absolute_path, open_error])
		return
	file.store_string(contents)
	file.flush()
	file.close()
	_last_export_paths[kind] = {
		"resource_path": resource_path,
		"absolute_path": absolute_path,
	}


func _run_log_create_run_id() -> String:
	return "run_%d_%06d" % [int(Time.get_unix_time_from_system()), _rng.randi_range(0, 999999)]


func _run_log_safe_filename_fragment(value: String) -> String:
	var source := value.strip_edges().to_lower()
	if source == "":
		return "run"
	var out := ""
	var underscore_pending := false
	for i in source.length():
		var c := source.unicode_at(i)
		var is_alpha := c >= 97 and c <= 122
		var is_digit := c >= 48 and c <= 57
		if is_alpha or is_digit:
			if underscore_pending and out != "":
				out += "_"
			underscore_pending = false
			out += String.chr(c)
		elif c == 45:
			if underscore_pending and out != "":
				out += "_"
			underscore_pending = false
			out += "-"
		elif c == 95:
			underscore_pending = true
		elif c == 32 or c == 46 or c == 58 or c == 47 or c == 92:
			underscore_pending = true
		else:
			underscore_pending = true
	if out == "":
		return "run"
	return out


func run_log_result_brief(result: Dictionary) -> Dictionary:
	return {
		"ok": bool(result.get("ok", false)),
		"reason": String(result.get("reason", "")),
		"gold": int(result.get("gold", _owner.run_gold)),
		"result": Dictionary(result.get("result", {})).duplicate(true),
	}


func run_log_shop_action(action: String, result: Dictionary, request: Dictionary = {}, shop_before_snapshot: Dictionary = {}, gold_before: int = -1) -> void:
	if gold_before < 0:
		gold_before = _owner.run_gold
	var raw_before: Dictionary = shop_before_snapshot.duplicate(true)
	if raw_before.is_empty():
		raw_before = _owner.ensure_shop_state().to_snapshot()
	var raw_after: Dictionary = Dictionary(result.get("shop", {})).duplicate(true)
	if raw_after.is_empty():
		raw_after = _owner.ensure_shop_state().to_snapshot()
	var gold_after := int(result.get("gold", _owner.run_gold))
	var action_details := _run_log_shop_action_details(action, request, result, raw_before, gold_before)
	var payload := {
		"action": action,
		"request": request.duplicate(true),
		"result": run_log_result_brief(result),
		"gold_before": gold_before,
		"gold_after": gold_after,
		"shop_before": run_log_sanitize_shop_snapshot(raw_before, gold_before),
		"shop_after": run_log_sanitize_shop_snapshot(raw_after, gold_after),
	}
	if not action_details.is_empty():
		payload["details"] = action_details
	run_log_append("shop_action", payload)


func _run_log_shop_action_details(action: String, request: Dictionary, result: Dictionary, shop_before_snapshot: Dictionary, gold_before: int) -> Dictionary:
	var details := {}
	var selected_offer := _run_log_find_selected_offer(request, shop_before_snapshot, gold_before)
	if not selected_offer.is_empty():
		details["selected_offer"] = selected_offer
	var selected_option := _run_log_find_selected_booster_option(request, shop_before_snapshot)
	if not selected_option.is_empty():
		details["selected_booster_option"] = selected_option

	var result_payload: Dictionary = Dictionary(result.get("result", {}))
	var granted := run_log_sanitize_booster_option(Dictionary(result_payload.get("granted", {})))
	if not granted.is_empty():
		details["granted"] = granted
	var replacement: Dictionary = Dictionary(result_payload.get("replacement", {}))
	if not replacement.is_empty():
		details["replacement"] = replacement.duplicate(true)
	if bool(result_payload.get("discarded", false)):
		details["discarded"] = true

	if action == "buy_offer" and bool(result.get("ok", false)) and not selected_offer.is_empty():
		details["purchased_offer"] = selected_offer
	return details


func _run_log_find_selected_offer(request: Dictionary, shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	var offer_id := String(request.get("offer_id", ""))
	if offer_id == "":
		return {}
	for raw_offer in Array(shop_snapshot.get("item_offers", [])):
		var offer: Dictionary = Dictionary(raw_offer)
		if String(offer.get("offer_id", "")) == offer_id:
			return run_log_sanitize_shop_offer(offer, gold_value)
	var relic_offer := Dictionary(shop_snapshot.get("relic_offer", {}))
	if String(relic_offer.get("offer_id", "")) == offer_id:
		return run_log_sanitize_shop_relic_offer(relic_offer, gold_value)
	return {}


func _run_log_find_selected_booster_option(request: Dictionary, shop_snapshot: Dictionary) -> Dictionary:
	if not request.has("option_index"):
		return {}
	var option_index := int(request.get("option_index", -1))
	var options: Array = Array(shop_snapshot.get("pending_booster_options", []))
	if option_index < 0 or option_index >= options.size():
		return {}
	return run_log_sanitize_booster_option(Dictionary(options[option_index]), option_index)


func run_log_sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	var item_offers: Array[Dictionary] = []
	var item_type_counts := {}
	var has_booster_offer := false
	for raw_offer in Array(shop_snapshot.get("item_offers", [])):
		var offer := run_log_sanitize_shop_offer(Dictionary(raw_offer), gold_value)
		if offer.is_empty():
			continue
		item_offers.append(offer)
		var offer_type := String(offer.get("type", ""))
		item_type_counts[offer_type] = int(item_type_counts.get(offer_type, 0)) + 1
		if offer_type == "booster":
			has_booster_offer = true

	var relic_offer := run_log_sanitize_shop_relic_offer(Dictionary(shop_snapshot.get("relic_offer", {})), gold_value)
	var booster_options: Array[Dictionary] = []
	var option_index := 0
	for raw_option in Array(shop_snapshot.get("pending_booster_options", [])):
		booster_options.append(run_log_sanitize_booster_option(Dictionary(raw_option), option_index))
		option_index += 1

	var reroll_cost := int(shop_snapshot.get("reroll_cost", 0))
	return {
		"active": bool(shop_snapshot.get("active", false)),
		"dungeon_level": int(shop_snapshot.get("dungeon_level", _owner.dungeon_level)),
		"item_offers": item_offers,
		"item_type_counts": item_type_counts,
		"has_booster_offer": has_booster_offer,
		"has_relic_offer": not relic_offer.is_empty(),
		"relic_offer": relic_offer,
		"reroll_count": int(shop_snapshot.get("reroll_count", 0)),
		"reroll_cost": reroll_cost,
		"can_afford_reroll": gold_value >= reroll_cost,
		"pending_booster_option_count": booster_options.size(),
		"pending_booster_options": booster_options,
		"pending_booster_offer_id": String(shop_snapshot.get("pending_booster_offer_id", "")),
		"skipped": bool(shop_snapshot.get("skipped", false)),
	}


func run_log_sanitize_shop_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	if offer.is_empty():
		return {}
	var price := int(offer.get("price", 0))
	var sold_out := bool(offer.get("sold_out", false))
	var available := bool(offer.get("available", not sold_out))
	return {
		"offer_id": String(offer.get("offer_id", "")),
		"content_id": String(offer.get("content_id", "")),
		"display_name": String(offer.get("display_name", "")),
		"type": String(offer.get("type", "")),
		"rarity": String(offer.get("rarity", "")),
		"price": price,
		"available": available,
		"sold_out": sold_out,
		"can_afford": gold_value >= price,
	}


func run_log_sanitize_shop_relic_offer(offer: Dictionary, gold_value: int) -> Dictionary:
	if offer.is_empty():
		return {}
	var relic_offer := run_log_sanitize_shop_offer(offer, gold_value)
	var relic_id := String(relic_offer.get("content_id", ""))
	relic_offer["owned"] = _run_log_owned_relic_ids().has(relic_id)
	return relic_offer


func run_log_sanitize_booster_option(option: Dictionary, option_index: int = -1) -> Dictionary:
	if option.is_empty():
		return {}
	var out := {
		"type": String(option.get("type", "")),
		"content_id": String(option.get("content_id", "")),
		"display_name": String(option.get("display_name", "")),
	}
	if option_index >= 0:
		out["option_index"] = option_index
	return out


func _run_log_owned_relic_ids() -> Dictionary:
	var owned_ids := {}
	for raw_id in _owner.ensure_player_progression_state().relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			owned_ids[relic_id] = true
	return owned_ids


func run_log_next_shop_ordinal() -> int:
	var count := 0
	for entry in _events:
		if String(entry.get("event", "")) == "shop_open":
			count += 1
	return count + 1


func run_log_capture_fight_outcome_payload(outcome: String, cause: String = "", extra: Dictionary = {}) -> Dictionary:
	var payload := {
		"outcome": outcome,
		"dungeon_level": _owner.dungeon_level,
		"step_key": _owner.current_step_key,
		"is_boss": bool(_owner._current_encounter.get("is_boss", false)),
		"enemy_id": String(_owner._current_encounter.get("enemy_id", "")),
		"enemy_name": String(_owner._current_encounter.get("display_name", "")),
		"turn_count": _current_fight_turns,
	}
	if cause != "":
		payload["cause"] = cause
	for key in extra.keys():
		payload[key] = extra[key]
	return payload
