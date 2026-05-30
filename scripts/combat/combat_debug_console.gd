extends RefCounted
class_name CombatDebugConsole

const CALLBACK_KEYS := preload("res://scripts/combat/combat_debug_callback_keys.gd")

const LOG_LEVEL_NORMAL := "normal"
const LOG_LEVEL_DETAILED := "detailed"
const COMBAT_TURN_LOG_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_turn_log_presenter.gd")

var _combat_log_text: RichTextLabel
var _console_input: LineEdit
var _command_output_log_color := Color(0.45, 0.95, 0.45, 1.0)
var _max_combat_log_lines := 120

var _combat_log_lines: Array[String] = []
var _combat_log_command_flags: Array[bool] = []
var _combat_log_level: String = LOG_LEVEL_NORMAL

var _callbacks: Dictionary = {}
var _turn_log_presenter: Variant


func bind(nodes: Dictionary, config: Dictionary = {}) -> void:
	_combat_log_text = nodes.get("combat_log_text") as RichTextLabel
	_console_input = nodes.get("console_input") as LineEdit
	_command_output_log_color = config.get("command_output_log_color", _command_output_log_color)
	_max_combat_log_lines = int(config.get("max_combat_log_lines", _max_combat_log_lines))
	_combat_log_level = String(config.get("initial_log_level", LOG_LEVEL_NORMAL))
	if _combat_log_level != LOG_LEVEL_DETAILED:
		_combat_log_level = LOG_LEVEL_NORMAL
	_callbacks = config.get("callbacks", {})
	var turn_log_presenter_candidate: Variant = config.get("turn_log_presenter", null)
	if turn_log_presenter_candidate != null and turn_log_presenter_candidate.has_method("build_state_snapshot_lines"):
		_turn_log_presenter = turn_log_presenter_candidate
	if _turn_log_presenter == null:
		_turn_log_presenter = COMBAT_TURN_LOG_PRESENTER_SCRIPT.new()


func log_level() -> String:
	return _combat_log_level


func set_overlay_visible(visible: bool) -> void:
	if _console_input == null:
		return
	if visible and _console_input.visible:
		_console_input.grab_focus()
	else:
		_console_input.release_focus()


func apply_theme(input_font_size: int, input_height: float) -> void:
	if _console_input == null:
		return
	_console_input.custom_minimum_size = Vector2(0.0, input_height)
	_console_input.add_theme_font_size_override("font_size", input_font_size)
	_console_input.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	_console_input.add_theme_color_override("font_placeholder_color", Color(0.72, 0.76, 0.82, 0.95))


func handle_submitted_text(text: String) -> void:
	var trimmed := text.strip_edges()
	if trimmed == "":
		if _console_input != null:
			_console_input.clear()
		return
	append_log("> " + trimmed)
	if _console_input != null:
		_console_input.clear()
	if not trimmed.begins_with("/"):
		return
	_handle_console_command(trimmed)


func append_log(message: String, is_command_output: bool = false) -> void:
	var timestamp := Time.get_time_string_from_system()
	_combat_log_lines.append("[%s] %s" % [timestamp, message])
	_combat_log_command_flags.append(is_command_output)
	if _combat_log_lines.size() > _max_combat_log_lines:
		_combat_log_lines = _combat_log_lines.slice(_combat_log_lines.size() - _max_combat_log_lines, _combat_log_lines.size())
		_combat_log_command_flags = _combat_log_command_flags.slice(_combat_log_command_flags.size() - _max_combat_log_lines, _combat_log_command_flags.size())
	refresh_display()


func clear_log() -> void:
	_combat_log_lines.clear()
	_combat_log_command_flags.clear()
	refresh_display()


func refresh_display() -> void:
	if _combat_log_text == null:
		return
	_combat_log_text.clear()
	var line_count := _combat_log_lines.size()
	for index in range(line_count):
		var line_text := _combat_log_lines[index]
		if index < line_count - 1:
			line_text += "\n"
		if index < _combat_log_command_flags.size() and _combat_log_command_flags[index]:
			_combat_log_text.push_color(_command_output_log_color)
			_combat_log_text.add_text(line_text)
			_combat_log_text.pop()
		else:
			_combat_log_text.add_text(line_text)
	_combat_log_text.scroll_to_line(maxi(0, line_count - 1))


func _handle_console_command(raw_text: String) -> void:
	var body := raw_text.substr(1).strip_edges()
	if body == "":
		_command_error("missing command")
		return
	var parts: PackedStringArray = body.split(" ", false)
	if parts.is_empty():
		_command_error("missing command")
		return

	var command := String(parts[0]).to_lower()
	match command:
		"commands", "help":
			_print_command_list()
		"state":
			_print_state_snapshot()
		"clear":
			clear_log()
			_set_status_text("Console cleared.")
		"log_level":
			_handle_log_level_command(parts)
		"skip":
			_handle_skip_command(parts)
		"board":
			_handle_board_command(parts)
		"gold":
			_handle_gold_command(parts)
		"mastery":
			_handle_mastery_command(parts)
		"consumable":
			_handle_consumable_command(parts)
		"equipment":
			_handle_equipment_command(parts)
		"relic":
			_handle_relic_command(parts)
		"fight":
			_handle_fight_command(parts)
		_:
			_command_error("unknown command '%s'" % command)


func _print_command_list() -> void:
	append_log("Available commands:", true)
	append_log("/commands (/help) - Show command list", true)
	append_log("/state - Show current run/combat snapshot", true)
	append_log("/clear - Clear console log", true)
	append_log("/log_level [normal|detailed] - Show or set turn log verbosity", true)
	append_log("/skip <level> <fight> - Jump to fight 1, 2, or boss 3 at level", true)
	append_log("/board print - Print current board", true)
	append_log("/board reroll - Regenerate board with random seed", true)
	append_log("/board seed <number> - Regenerate board with fixed seed", true)
	append_log("/gold add <amount> - Add run gold", true)
	append_log("/gold set <amount> - Set run gold", true)
	append_log("/mastery add <orb> <amount> - Grant mastery", true)
	append_log("/mastery list - List mastery IDs", true)
	append_log("/consumable add <id> - Add consumable by content id", true)
	append_log("/consumable list - List consumable IDs", true)
	append_log("/equipment list - List equipment IDs", true)
	append_log("/equipment show <id> - Show equipment details", true)
	append_log("/equipment add <id> - Equip item into leftmost free slot", true)
	append_log("/relic list - List relic IDs", true)
	append_log("/relic show <id> - Show relic details", true)
	append_log("/relic add <id> - Add relic if not already owned", true)
	append_log("/fight win - Queue victory flow", true)
	append_log("/fight lose - Queue defeat flow", true)


func _command_error(msg: String) -> void:
	append_log("Command error: %s. Type /commands." % msg)


func _handle_log_level_command(parts: PackedStringArray) -> void:
	if parts.size() == 1:
		append_log("Combat log level: %s." % _combat_log_level)
		return
	if parts.size() != 2:
		_command_error("usage: /log_level normal|detailed")
		return

	var requested_level := String(parts[1]).to_lower()
	if requested_level != LOG_LEVEL_NORMAL and requested_level != LOG_LEVEL_DETAILED:
		_command_error("usage: /log_level normal|detailed")
		return

	_combat_log_level = requested_level
	append_log("Combat log level set to %s." % _combat_log_level)


func _handle_skip_command(parts: PackedStringArray) -> void:
	if parts.size() != 3:
		_command_error("usage: /skip <level> <fight>")
		return
	var level_text := String(parts[1])
	var fight_text := String(parts[2])
	if not level_text.is_valid_int() or not fight_text.is_valid_int():
		_command_error("usage: /skip <level> <fight>")
		return
	var level := level_text.to_int()
	var fight := fight_text.to_int()
	var result: Dictionary = _callback_dict(CALLBACK_KEYS.SKIP_TO_FIGHT, [level, fight])
	if not bool(result.get("ok", false)):
		_command_error("skip failed: %s" % String(result.get("reason", "unknown_error")))
		return
	append_log("Debug skip: jumped to %s." % String(result.get("label", "unknown")))


func _handle_board_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /board print|reroll|seed <number>")
		return
	var board_sub := String(parts[1]).to_lower()
	match board_sub:
		"print":
			var board_data: Dictionary = _callback_dict(CALLBACK_KEYS.BOARD_PRINT_DATA)
			_append_board_model_snapshot(board_data)
		"reroll":
			var reroll_data: Dictionary = _callback_dict(CALLBACK_KEYS.BOARD_REROLL)
			append_log("Board rerolled (seed %d)." % int(reroll_data.get("seed", 0)))
		"seed":
			if parts.size() < 3:
				_command_error("usage: /board seed <number>")
				return
			var seed_token := String(parts[2])
			if not seed_token.is_valid_int():
				_command_error("seed must be an integer")
				return
			var seed_value := seed_token.to_int()
			var set_result: Dictionary = _callback_dict(CALLBACK_KEYS.BOARD_SEED, [seed_value])
			if not bool(set_result.get("ok", true)):
				_command_error(String(set_result.get("reason", "seed must be an integer")))
				return
			append_log("Board set to seed %d." % int(set_result.get("seed", seed_value)))
		_:
			_command_error("unknown /board subcommand: %s" % board_sub)


func _handle_gold_command(parts: PackedStringArray) -> void:
	if parts.size() < 3:
		_command_error("usage: /gold add <amount> | /gold set <amount>")
		return
	var gold_sub := String(parts[1]).to_lower()
	var amount_token := String(parts[2])
	if not amount_token.is_valid_int():
		_command_error("amount must be an integer")
		return
	var amount := amount_token.to_int()
	match gold_sub:
		"add":
			if amount <= 0:
				_command_error("gold add requires a positive amount")
				return
			var add_result: Dictionary = _callback_dict(CALLBACK_KEYS.GOLD_ADD, [amount])
			if not bool(add_result.get("ok", false)):
				_command_error(String(add_result.get("reason", "unknown_error")))
				return
			append_log("Gold added: +%d (now %d)." % [int(add_result.get("added", 0)), int(add_result.get("current", 0))])
		"set":
			var set_result: Dictionary = _callback_dict(CALLBACK_KEYS.GOLD_SET, [amount])
			if not bool(set_result.get("ok", false)):
				_command_error(String(set_result.get("reason", "unknown_error")))
				return
			append_log("Gold set to %d." % int(set_result.get("current", 0)))
		_:
			_command_error("unknown /gold subcommand: %s" % gold_sub)


func _handle_mastery_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /mastery add <orb> <amount> | /mastery list")
		return
	var mastery_sub := String(parts[1]).to_lower()
	match mastery_sub:
		"add":
			if parts.size() < 4:
				_command_error("usage: /mastery add <orb> <amount>")
				return
			var orb_token := String(parts[2]).to_lower()
			var orb_id := _orb_id_from_token(orb_token)
			if orb_id < 0:
				_command_error("invalid orb '%s'" % orb_token)
				return
			var mastery_amount_token := String(parts[3])
			if not mastery_amount_token.is_valid_int():
				_command_error("mastery amount must be an integer")
				return
			var mastery_amount := mastery_amount_token.to_int()
			if mastery_amount <= 0:
				_command_error("mastery amount must be positive")
				return
			var mastery_result: Dictionary = _callback_dict(CALLBACK_KEYS.MASTERY_ADD, [orb_id, mastery_amount])
			if not bool(mastery_result.get("ok", false)):
				_command_error("mastery add failed: %s" % String(mastery_result.get("reason", "unknown_error")))
				return
			append_log(
				(
					"Mastery added: %s +%d (new level %d)."
					% [
						OrbType.display_name(orb_id),
						int(mastery_result.get("granted", 0)),
						int(mastery_result.get("new_level", 0)),
					]
				)
			)
		"list":
			_print_content_id_list("Mastery IDs", _callback_array(CALLBACK_KEYS.MASTERY_LIST))
		_:
			_command_error("unknown /mastery subcommand: %s" % mastery_sub)


func _handle_consumable_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /consumable add <id> | /consumable list")
		return
	var consumable_sub := String(parts[1]).to_lower()
	match consumable_sub:
		"add":
			if parts.size() < 3:
				_command_error("usage: /consumable add <id>")
				return
			var consumable_id := String(parts[2])
			var add_result: Dictionary = _callback_dict(CALLBACK_KEYS.CONSUMABLE_ADD, [consumable_id])
			if not bool(add_result.get("ok", false)):
				_command_error("consumable add failed: %s" % String(add_result.get("reason", "unknown_error")))
				return
			append_log("Consumable added: %s." % consumable_id)
		"list":
			_print_content_id_list("Consumable IDs", _callback_array(CALLBACK_KEYS.CONSUMABLE_LIST))
		_:
			_command_error("unknown /consumable subcommand: %s" % consumable_sub)


func _handle_equipment_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /equipment list|show <id>|add <id>")
		return
	var equipment_sub := String(parts[1]).to_lower()
	match equipment_sub:
		"list":
			_print_content_id_list("Equipment IDs", _callback_array(CALLBACK_KEYS.EQUIPMENT_LIST))
		"show":
			if parts.size() < 3:
				_command_error("usage: /equipment show <id>")
				return
			var equipment_id := String(parts[2]).strip_edges()
			_show_equipment_details(equipment_id)
		"add":
			if parts.size() < 3:
				_command_error("usage: /equipment add <id>")
				return
			var equipment_id := String(parts[2]).strip_edges()
			var add_result: Dictionary = _callback_dict(CALLBACK_KEYS.EQUIPMENT_ADD, [equipment_id])
			if not bool(add_result.get("ok", false)):
				_command_error("equipment add failed: %s" % String(add_result.get("reason", "unknown_error")))
				return
			append_log("Equipment added: %s -> slot %d." % [equipment_id, int(add_result.get("slot_index", -1))])
		_:
			_command_error("unknown /equipment subcommand: %s" % equipment_sub)


func _handle_relic_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /relic list|show <id>|add <id>")
		return
	var relic_sub := String(parts[1]).to_lower()
	match relic_sub:
		"list":
			_print_content_id_list("Relic IDs", _callback_array(CALLBACK_KEYS.RELIC_LIST))
		"show":
			if parts.size() < 3:
				_command_error("usage: /relic show <id>")
				return
			var relic_id := String(parts[2]).strip_edges()
			_show_relic_details(relic_id)
		"add":
			if parts.size() < 3:
				_command_error("usage: /relic add <id>")
				return
			var relic_id := String(parts[2]).strip_edges()
			var add_result: Dictionary = _callback_dict(CALLBACK_KEYS.RELIC_ADD, [relic_id])
			if not bool(add_result.get("ok", false)):
				_command_error("relic add failed: %s" % String(add_result.get("reason", "unknown_error")))
				return
			append_log("Relic added: %s." % relic_id)
		_:
			_command_error("unknown /relic subcommand: %s" % relic_sub)


func _handle_fight_command(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		_command_error("usage: /fight win|lose")
		return
	var fight_sub := String(parts[1]).to_lower()
	match fight_sub:
		"win":
			var win_result: Dictionary = _callback_dict(CALLBACK_KEYS.FIGHT_WIN)
			if not bool(win_result.get("ok", false)):
				_command_error("fight win failed: %s" % String(win_result.get("reason", "unknown_error")))
				return
			append_log("Fight win queued. Press Next to continue.")
		"lose":
			var lose_result: Dictionary = _callback_dict(CALLBACK_KEYS.FIGHT_LOSE)
			if not bool(lose_result.get("ok", false)):
				_command_error("fight lose failed: %s" % String(lose_result.get("reason", "unknown_error")))
				return
			append_log("Fight lose queued. Press Run Summary.")
		_:
			_command_error("unknown /fight subcommand: %s" % fight_sub)


func _print_state_snapshot() -> void:
	var snapshot: Dictionary = _callback_dict(CALLBACK_KEYS.STATE_SNAPSHOT_DATA)
	for line in _turn_log_presenter.build_state_snapshot_lines(snapshot):
		append_log(line)


func _append_board_model_snapshot(board_data: Dictionary) -> void:
	append_log("Board seed: %d" % int(board_data.get("seed", 0)))
	var debug_text := String(board_data.get("debug_text", ""))
	var lines: PackedStringArray = debug_text.split("\n", false)
	for line in lines:
		append_log("  %s" % line)


func _print_content_id_list(label: String, entries: Array) -> void:
	var ids: Array[String] = []
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		var entry_id := String(entry.get("id", "")).strip_edges()
		if entry_id != "":
			ids.append(entry_id)
	if ids.is_empty():
		append_log("%s: (none)." % label)
		return
	append_log("%s (%d): %s" % [label, ids.size(), ", ".join(ids)])


func _show_equipment_details(equipment_id: String) -> void:
	if equipment_id == "":
		_command_error("equipment id is required")
		return
	var result: Dictionary = _callback_dict(CALLBACK_KEYS.EQUIPMENT_DETAILS, [equipment_id])
	if not bool(result.get("ok", false)):
		_command_error(String(result.get("reason", "unknown_error")))
		return

	var equipment: Dictionary = result.get("equipment", {})
	var target_orb_id := int(equipment.get("target_orb_id", -1))
	var target_orb := "Any"
	if OrbType.is_valid_id(target_orb_id):
		target_orb = OrbType.display_name(target_orb_id)
	var modifiers: Dictionary = equipment.get("combat_modifiers", {})

	append_log("Equipment %s" % equipment_id)
	append_log("  Name: %s" % String(equipment.get("display_name", equipment_id)))
	append_log("  Rarity: %s | Target: %s" % [String(equipment.get("rarity", "common")), target_orb])
	append_log(
		(
			"  Price: %d | Sell: %d | Levels: %d-%d"
			% [
				int(equipment.get("base_price", 0)),
				int(equipment.get("sell_value", equipment.get("base_price", 0))),
				int(equipment.get("min_level", 1)),
				int(equipment.get("max_level", 3)),
			]
		)
	)
	append_log("  Icon: %s" % String(equipment.get("icon_key", "")))
	append_log("  Description: %s" % String(equipment.get("description", "")))
	if modifiers.is_empty():
		append_log("  Combat Modifiers: none")
	else:
		append_log("  Combat Modifiers: %s" % JSON.stringify(modifiers))


func _show_relic_details(relic_id: String) -> void:
	if relic_id == "":
		_command_error("relic id is required")
		return
	var result: Dictionary = _callback_dict(CALLBACK_KEYS.RELIC_DETAILS, [relic_id])
	if not bool(result.get("ok", false)):
		_command_error(String(result.get("reason", "unknown_error")))
		return

	var relic: Dictionary = result.get("relic", {})
	var modifiers: Dictionary = relic.get("combat_modifiers", {})
	append_log("Relic %s" % relic_id)
	append_log("  Name: %s" % String(relic.get("display_name", relic_id)))
	append_log("  Rarity: %s" % String(relic.get("rarity", "common")))
	append_log(
		(
			"  Price: %d | Levels: %d-%d"
			% [
				int(relic.get("base_price", 0)),
				int(relic.get("min_level", 1)),
				int(relic.get("max_level", 3)),
			]
		)
	)
	append_log("  Icon: %s" % String(relic.get("icon_key", "")))
	append_log("  Description: %s" % String(relic.get("description", "")))
	if modifiers.is_empty():
		append_log("  Combat Modifiers: none")
	else:
		append_log("  Combat Modifiers: %s" % JSON.stringify(modifiers))


func _orb_id_from_token(token: String) -> int:
	match token:
		"fire", "f":
			return OrbType.Id.FIRE
		"ice", "i":
			return OrbType.Id.ICE
		"earth", "e":
			return OrbType.Id.EARTH
		"heart", "h":
			return OrbType.Id.HEART
		"armor", "a":
			return OrbType.Id.ARMOR
		"gold", "g":
			return OrbType.Id.GOLD
		_:
			return -1


func _set_status_text(message: String) -> void:
	var callback: Callable = _get_callback(CALLBACK_KEYS.SET_STATUS_TEXT)
	if callback.is_valid():
		callback.call(message)


func _callback_dict(name: String, args: Array = []) -> Dictionary:
	var callback: Callable = _get_callback(name)
	if callback.is_valid():
		var result: Variant = callback.callv(args)
		if result is Dictionary:
			return result
	return {}


func _callback_array(name: String, args: Array = []) -> Array:
	var callback: Callable = _get_callback(name)
	if callback.is_valid():
		var result: Variant = callback.callv(args)
		if result is Array:
			return result
	return []


func _get_callback(name: String) -> Callable:
	if not _callbacks.has(name):
		return Callable()
	var raw_callback: Variant = _callbacks[name]
	if raw_callback is Callable:
		return raw_callback as Callable
	return Callable()
