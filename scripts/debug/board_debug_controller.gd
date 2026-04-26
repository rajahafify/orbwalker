extends Control

@onready var _board_view: BoardView = %BoardView
@onready var _status_label: Label = %StatusLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _player_label: Label = %PlayerStateLabel
@onready var _enemy_label: Label = %EnemyStateLabel
@onready var _intent_label: Label = %EnemyIntentLabel
@onready var _phase_label: Label = %CombatPhaseLabel
@onready var _combat_log_text: RichTextLabel = %CombatLogText
@onready var _console_input: LineEdit = %ConsoleInput
@onready var _next_button: Button = %NextButton

const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_v3.gd")
const BOARD_RESOLVER_TEST_RUNNER_SCRIPT := preload("res://scripts/debug/board_resolver_test_runner.gd")
const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const TEST_EQUIPMENT_IDS: Array[String] = [
	"debug_shortsword",
	"debug_buckler",
]
const TEST_CONSUMABLE_ID := "fire_scroll"

const COMBAT_PHASE_INTENT_PREVIEW := 0
const COMBAT_PHASE_VICTORY := 6
const COMBAT_PHASE_DEFEAT := 7
const MAX_COMBAT_LOG_LINES := 120
const COMMAND_OUTPUT_LOG_COLOR := Color(0.45, 0.95, 0.45, 1.0)

enum InputPhase {
	PLAYER_INPUT,
	RESOLVING,
	LOCKED_EXTERNAL,
}

var _settings := BoardGenerationSettings.new()
var _board_state := BoardState.new()
var _resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()
var _combat: Variant
var _player_state: PlayerState
var _enemy_state: EnemyState
var _progression_state: PlayerProgressionState

var _input_phase: InputPhase = InputPhase.PLAYER_INPUT
var _active_drag := false
var _drag_touch_index: int = -1
var _drag_selected_orb_id: int = -1
var _drag_current_cell: Vector2i = Vector2i(-1, -1)
var _drag_path: Array[Vector2i] = []
var _move_time_left: float = 0.0
var _external_lock_reason := ""
var _last_resolve_result: Dictionary = {}
var _outcome_transition_queued := false
var _pending_next_scene_path := ""
var _combat_log_lines: Array[String] = []
var _combat_log_command_flags: Array[bool] = []
var _consumable_rng := RandomNumberGenerator.new()


func _ready() -> void:
	_consumable_rng.randomize()
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_initialize_combat_state()
	_create_new_board()
	_board_view.gui_input.connect(_on_board_view_gui_input)
	_console_input.text_submitted.connect(_on_console_input_text_submitted)
	set_process(true)
	_begin_turn_preview()
	_console_input.grab_focus()


func _initialize_combat_state() -> void:
	if not RunState.run_active:
		RunState.start_new_run()
	if not RunState.is_current_step_fight():
		var redirect_scene := RunState.next_scene_path()
		if redirect_scene != "":
			get_tree().call_deferred("change_scene_to_file", redirect_scene)
		return

	_player_state = RunState.ensure_player_state()
	_progression_state = RunState.ensure_player_progression_state()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	_enemy_state = ENEMY_STATE_SCRIPT.new()
	_enemy_state.configure_from_blueprint(encounter)
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_outcome_transition_queued = false
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
	_update_hud()
	_combat_log_lines.clear()
	_combat_log_command_flags.clear()
	_append_combat_log("Run flow: %s" % RunState.level_sequence_label())
	if String(encounter.get("step_key", "")) == "enemy_1":
		_append_combat_log("Level %d boss preview: %s." % [RunState.dungeon_level, RunState.current_level_boss_name()])
	_append_combat_log("Fight started: %s HP %d." % [_enemy_state.display_name, _enemy_state.max_hp])
	_append_combat_log("Player start: HP %d/%d, Gold %d." % [_player_state.current_hp, _player_state.max_hp, _player_state.gold])
	if content_errors.is_empty():
		_append_combat_log("Milestone 5 content validation: OK.")
	else:
		_append_combat_log("Milestone 5 content validation: %d issue(s)." % content_errors.size())
		for error in content_errors:
			_append_combat_log("  - [%s] %s" % [String(error.get("item_id", "?")), String(error.get("reason", "unknown"))])


func _begin_turn_preview() -> void:
	if _combat == null:
		return
	if _combat.is_fight_over():
		return
	_combat.phase = COMBAT_PHASE_INTENT_PREVIEW
	_combat.begin_player_input()
	_set_input_phase(InputPhase.PLAYER_INPUT)
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
	_status_label.text = "%s | Turn %d." % [
		RunState.level_sequence_label(),
		_combat.turn_index,
	]
	_update_hud()
	_append_combat_log(
		"Turn %d intent: %s." % [
			_combat.turn_index,
			_format_intent(_enemy_state.get_current_intent()),
		]
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_create_new_board()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_P:
			_print_board_state()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_try_use_first_consumable()
			get_viewport().set_input_as_handled()


func _on_regenerate_button_pressed() -> void:
	_create_new_board()


func _on_print_board_button_pressed() -> void:
	_print_board_state()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_run_tests_button_pressed() -> void:
	var runner: Variant = BOARD_RESOLVER_TEST_RUNNER_SCRIPT.new()
	var report: Dictionary = runner.run_all()
	if report.passed:
		_status_label.text = "Resolver tests passed (%d/%d)." % [report.total, report.total]
		print("[Board Resolver Tests] Passed %d/%d." % [report.total, report.total])
		return

	_status_label.text = "Resolver tests failed (%d/%d). See output." % [report.failed, report.total]
	push_warning("Board resolver tests failed:\n%s" % "\n".join(report.failures))


func _on_add_test_equipment_button_pressed() -> void:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var candidate_item_id := ""
	for item_id in TEST_EQUIPMENT_IDS:
		if not progression_state.equipped_item_ids.has(item_id):
			candidate_item_id = item_id
			break
	if candidate_item_id == "":
		candidate_item_id = TEST_EQUIPMENT_IDS[0]

	var result: Dictionary = progression_service.equip_item(progression_state, candidate_item_id, content)
	if bool(result.get("ok", false)):
		_status_label.text = "Added test equipment: %s" % candidate_item_id
		_append_combat_log("Debug add equipment OK: %s" % candidate_item_id)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_status_label.text = "Add test equipment failed: %s" % reason
		_append_combat_log("Debug add equipment failed: %s" % reason)
	_update_hud()


func _on_add_test_consumable_button_pressed() -> void:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var result: Dictionary = progression_service.add_consumable(progression_state, TEST_CONSUMABLE_ID, content)
	if bool(result.get("ok", false)):
		_status_label.text = "Added test consumable: %s" % TEST_CONSUMABLE_ID
		_append_combat_log("Debug add consumable OK: %s" % TEST_CONSUMABLE_ID)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_status_label.text = "Add test consumable failed: %s" % reason
		_append_combat_log("Debug add consumable failed: %s" % reason)
	_update_hud()


func _try_use_first_consumable() -> void:
	if _combat == null or _combat.is_fight_over():
		return
	if _input_phase != InputPhase.PLAYER_INPUT:
		_status_label.text = "Consumables can only be used during player input."
		return

	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var use_result: Dictionary = progression_service.use_consumable(progression_state, 0, content)
	if not bool(use_result.get("ok", false)):
		var reason := String(use_result.get("reason", "unknown_error"))
		_status_label.text = "Use consumable failed: %s" % reason
		_append_combat_log("Use consumable failed: %s" % reason)
		_update_hud()
		return

	var payload: Dictionary = use_result.get("result", {})
	var consumable_id := String(payload.get("consumable_id", ""))
	var effects: Array = payload.get("effects", [])
	var conversion_total := _apply_consumable_effects(effects)
	_board_view.board_state = _board_state
	_refresh_drag_match_glow()
	_status_label.text = "Used %s. Converted %d orbs." % [consumable_id, conversion_total]
	_append_combat_log("Consumable used: %s. Converted %d orbs." % [consumable_id, conversion_total])
	_update_hud()


func _apply_consumable_effects(effects: Array) -> int:
	var total_converted := 0
	for raw_effect in effects:
		var effect: Dictionary = raw_effect
		var operation := String(effect.get("operation", ""))
		if operation != "convert_random_orbs":
			continue
		var value: Dictionary = effect.get("value", {})
		var target_orb_id := int(value.get("target_orb_id", -1))
		var count := int(value.get("count", 0))
		total_converted += _convert_random_non_target_orbs(target_orb_id, count)
	return total_converted


func _convert_random_non_target_orbs(target_orb_id: int, count: int) -> int:
	if count <= 0 or not OrbType.is_valid_id(target_orb_id):
		return 0

	var candidates: Array[Vector2i] = []
	for row in BoardState.ROW_COUNT:
		for column in BoardState.COLUMN_COUNT:
			var orb_id := _board_state.get_cell(column, row)
			if orb_id == target_orb_id:
				continue
			candidates.append(Vector2i(column, row))
	if candidates.is_empty():
		return 0

	var converted := 0
	var picks := mini(count, candidates.size())
	for _i in picks:
		var pick_index := _consumable_rng.randi_range(0, candidates.size() - 1)
		var cell := candidates[pick_index]
		_board_state.set_cell(cell.x, cell.y, target_orb_id)
		candidates.remove_at(pick_index)
		converted += 1
	return converted


func _process(delta: float) -> void:
	if not _active_drag:
		_update_timer_label(0.0)
		return

	_refresh_drag_match_glow()
	_move_time_left = maxf(0.0, _move_time_left - delta)
	_update_timer_label(_move_time_left)
	if _move_time_left <= 0.0:
		_end_drag(true)


func _handle_pointer_input(event: InputEvent) -> bool:
	if _input_phase != InputPhase.PLAYER_INPUT and not _active_drag:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			return _start_drag(event.position)
		if _active_drag:
			_end_drag(false)
			return true
		return false

	if event is InputEventMouseMotion and _active_drag and _drag_touch_index == -1:
		_update_drag(event.position)
		return true

	if event is InputEventScreenTouch:
		var touch_pos: Vector2 = _screen_to_board_local(event.position)
		if event.pressed:
			if _drag_touch_index != -1:
				return false
			var started := _start_drag(touch_pos)
			if started:
				_drag_touch_index = event.index
			return started
		if _active_drag and event.index == _drag_touch_index:
			_end_drag(false)
			return true

	if event is InputEventScreenDrag and _active_drag and event.index == _drag_touch_index:
		var drag_pos: Vector2 = _screen_to_board_local(event.position)
		_update_drag(drag_pos)
		return true

	return false


func _on_board_view_gui_input(event: InputEvent) -> void:
	if _handle_pointer_input(event):
		_board_view.accept_event()


func _create_new_board() -> void:
	var board_seed := _resolve_seed()
	_set_board_seed(board_seed)
	if _combat != null and not _combat.is_fight_over():
		_status_label.text = "Seed: %d | Turn %d ready." % [board_seed, _combat.turn_index]
	else:
		_status_label.text = "Seed: %d | Fight complete." % board_seed


func _resolve_seed() -> int:
	return int(Time.get_ticks_usec())


func _print_board_state() -> void:
	var debug_text := _board_state.to_debug_string()
	print("\n[Board Debug] Seed=", _board_state.rng_seed)
	print(debug_text)
	_print_board_state_to_console()
	_status_label.text = "Printed board for seed %d to output." % _board_state.rng_seed


func _set_board_seed(board_seed: int) -> void:
	_reset_drag_visuals()
	_board_view.clear_animations()
	_board_state.initialize(board_seed, _settings)
	_board_view.board_state = _board_state
	if _combat != null and not _combat.is_fight_over():
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _print_board_state_to_console() -> void:
	_append_combat_log("Board seed: %d" % _board_state.rng_seed)
	var lines: PackedStringArray = _board_state.to_debug_string().split("\n", false)
	for line in lines:
		_append_combat_log("  %s" % line)


func _on_console_input_text_submitted(text: String) -> void:
	var trimmed := text.strip_edges()
	if trimmed == "":
		_console_input.clear()
		return
	_append_combat_log("> " + trimmed)
	_console_input.clear()
	if not trimmed.begins_with("/"):
		return
	_handle_console_command(trimmed)


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
			_combat_log_lines.clear()
			_combat_log_command_flags.clear()
			_refresh_combat_log_display()
			_status_label.text = "Console cleared."
		"board":
			if parts.size() < 2:
				_command_error("usage: /board print|reroll|seed <number>")
				return
			var board_sub := String(parts[1]).to_lower()
			match board_sub:
				"print":
					_print_board_state_to_console()
				"reroll":
					_create_new_board()
					_append_combat_log("Board rerolled (seed %d)." % _board_state.rng_seed)
				"seed":
					if parts.size() < 3:
						_command_error("usage: /board seed <number>")
						return
					var seed_token := String(parts[2])
					if not seed_token.is_valid_int():
						_command_error("seed must be an integer")
						return
					var seed_value := seed_token.to_int()
					_set_board_seed(seed_value)
					_append_combat_log("Board set to seed %d." % _board_state.rng_seed)
				_:
					_command_error("unknown /board subcommand: %s" % board_sub)
		"gold":
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
					var added := RunState.add_gold(amount)
					_update_hud()
					_append_combat_log("Gold added: +%d (now %d)." % [added, RunState.run_gold])
				"set":
					RunState.set_gold(amount)
					_update_hud()
					_append_combat_log("Gold set to %d." % RunState.run_gold)
				_:
					_command_error("unknown /gold subcommand: %s" % gold_sub)
		"mastery":
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
					var progression_state: Variant = RunState.ensure_player_progression_state()
					var progression_service: Variant = RunState.ensure_player_progression_service()
					var mastery_result: Dictionary = progression_service.grant_mastery(progression_state, orb_id, mastery_amount)
					if not bool(mastery_result.get("ok", false)):
						_command_error("mastery add failed: %s" % String(mastery_result.get("reason", "unknown_error")))
						return
					var mastery_payload: Dictionary = mastery_result.get("result", {})
					_update_hud()
					_append_combat_log(
						"Mastery added: %s +%d (new level %d)." % [
							OrbType.display_name(orb_id),
							int(mastery_payload.get("granted", 0)),
							int(mastery_payload.get("new_level", 0)),
						]
					)
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Mastery IDs", content.list_mastery_cards())
				_:
					_command_error("unknown /mastery subcommand: %s" % mastery_sub)
		"consumable":
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
					var progression_state: Variant = RunState.ensure_player_progression_state()
					var progression_service: Variant = RunState.ensure_player_progression_service()
					var content: Variant = RunState.ensure_content_registry()
					var consumable_result: Dictionary = progression_service.add_consumable(progression_state, consumable_id, content)
					if not bool(consumable_result.get("ok", false)):
						_command_error("consumable add failed: %s" % String(consumable_result.get("reason", "unknown_error")))
						return
					_update_hud()
					_append_combat_log("Consumable added: %s." % consumable_id)
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Consumable IDs", content.list_consumables())
				_:
					_command_error("unknown /consumable subcommand: %s" % consumable_sub)
		"equipment":
			if parts.size() < 2:
				_command_error("usage: /equipment list")
				return
			var equipment_sub := String(parts[1]).to_lower()
			match equipment_sub:
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Equipment IDs", content.list_equipment())
				_:
					_command_error("unknown /equipment subcommand: %s" % equipment_sub)
		"fight":
			if parts.size() < 2:
				_command_error("usage: /fight win|lose")
				return
			var fight_sub := String(parts[1]).to_lower()
			match fight_sub:
				"win":
					var win_transition: Dictionary = RunState.mark_fight_victory()
					if not bool(win_transition.get("ok", false)):
						_command_error("fight win failed: %s" % String(win_transition.get("reason", "unknown_error")))
						return
					_set_input_phase(InputPhase.LOCKED_EXTERNAL)
					_pending_next_scene_path = String(win_transition.get("next_scene", "res://scenes/main.tscn"))
					_next_button.visible = true
					_next_button.disabled = false
					_update_hud()
					_status_label.text = "Debug victory queued. Press Next."
					_append_combat_log("Fight win queued. Press Next to continue.")
				"lose":
					var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
					_set_input_phase(InputPhase.LOCKED_EXTERNAL)
					_pending_next_scene_path = ""
					_next_button.visible = false
					_next_button.disabled = true
					_update_hud()
					_status_label.text = "Debug defeat queued. Transitioning..."
					_append_combat_log("Fight lose queued. Transitioning to run summary.")
					_queue_outcome_transition(String(lose_transition.get("next_scene", "res://scenes/flow/run_summary_placeholder.tscn")))
				_:
					_command_error("unknown /fight subcommand: %s" % fight_sub)
		_:
			_command_error("unknown command '%s'" % command)


func _print_command_list() -> void:
	_append_combat_log("Available commands:", true)
	_append_combat_log("/commands (/help) - Show command list", true)
	_append_combat_log("/state - Show current run/combat snapshot", true)
	_append_combat_log("/clear - Clear console log", true)
	_append_combat_log("/board print - Print current board", true)
	_append_combat_log("/board reroll - Regenerate board with random seed", true)
	_append_combat_log("/board seed <number> - Regenerate board with fixed seed", true)
	_append_combat_log("/gold add <amount> - Add run gold", true)
	_append_combat_log("/gold set <amount> - Set run gold", true)
	_append_combat_log("/mastery add <orb> <amount> - Grant mastery", true)
	_append_combat_log("/mastery list - List mastery IDs", true)
	_append_combat_log("/consumable add <id> - Add consumable by content id", true)
	_append_combat_log("/consumable list - List consumable IDs", true)
	_append_combat_log("/equipment list - List equipment IDs", true)
	_append_combat_log("/fight win - Queue victory flow", true)
	_append_combat_log("/fight lose - Queue defeat flow", true)


func _command_error(msg: String) -> void:
	_append_combat_log("Command error: %s. Type /commands." % msg)


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


func _print_state_snapshot() -> void:
	var progression: Dictionary = RunState.progression_snapshot()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	var intent_text := "-"
	if _enemy_state != null:
		intent_text = _format_intent(_enemy_state.get_current_intent())

	_append_combat_log("State snapshot:")
	_append_combat_log(
		"Run: active=%s, level=%d, step=%s, label=%s" % [
			str(RunState.run_active),
			int(RunState.dungeon_level),
			String(RunState.current_step_key),
			RunState.level_sequence_label(),
		]
	)
	_append_combat_log(
		"Combat: turn=%d, phase=%s, input_phase=%s" % [
			int(_combat.turn_index if _combat != null else 0),
			(_combat.phase_name() if _combat != null else "N/A"),
			_input_phase,
		]
	)
	_append_combat_log(
		"Player: HP %d/%d, Armor %d, Gold %d" % [
			int(_player_state.current_hp if _player_state != null else 0),
			int(_player_state.max_hp if _player_state != null else 0),
			int(_player_state.armor if _player_state != null else 0),
			int(RunState.run_gold),
		]
	)
	_append_combat_log(
		"Enemy: %s HP %d/%d, TurnBlock %d, Intent %s" % [
			String(encounter.get("display_name", _enemy_state.display_name if _enemy_state != null else "Unknown")),
			int(_enemy_state.current_hp if _enemy_state != null else 0),
			int(_enemy_state.max_hp if _enemy_state != null else 0),
			int(_enemy_state.current_turn_block if _enemy_state != null else 0),
			intent_text,
		]
	)
	_append_combat_log("Eq: %s" % _format_slot_line(progression.get("equipment_slots", [])))
	_append_combat_log("Cons: %s" % _format_slot_line(progression.get("consumable_slots", [])))
	_append_combat_log("Relics: %s" % _format_id_line(progression.get("relic_ids", [])))
	_append_combat_log("Mastery: %s" % _format_mastery_line(progression.get("mastery_levels", {})))


func _print_content_id_list(label: String, entries: Array) -> void:
	var ids: Array[String] = []
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		var entry_id := String(entry.get("id", "")).strip_edges()
		if entry_id != "":
			ids.append(entry_id)
	if ids.is_empty():
		_append_combat_log("%s: (none)." % label)
		return
	_append_combat_log("%s (%d): %s" % [label, ids.size(), ", ".join(ids)])


func _start_drag(board_local_position: Vector2) -> bool:
	if _input_phase != InputPhase.PLAYER_INPUT:
		return false

	var start_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(start_cell):
		return false

	_active_drag = true
	_move_time_left = _player_state.move_timer_seconds
	_drag_current_cell = start_cell
	_drag_selected_orb_id = _board_state.get_cell(start_cell.x, start_cell.y)
	_drag_path.clear()
	_drag_path.append(start_cell)
	_board_view.selected_cell = start_cell
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_pointer_position = board_local_position
	_board_view.drag_orb_id = _drag_selected_orb_id
	_update_timer_label(_move_time_left)
	_status_label.text = "Dragging %s orb. Move timer running." % OrbType.display_name(_drag_selected_orb_id)
	return true


func _update_drag(board_local_position: Vector2) -> void:
	if not _active_drag:
		return

	_board_view.drag_pointer_position = board_local_position
	var target_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(target_cell):
		return
	if target_cell == _drag_current_cell:
		return
	if not _is_orthogonally_adjacent(_drag_current_cell, target_cell):
		return

	var from_cell := _drag_current_cell
	var moving_orb_id := _board_state.get_cell(from_cell.x, from_cell.y)
	var displaced_orb_id := _board_state.get_cell(target_cell.x, target_cell.y)
	_board_state.swap_cells(_drag_current_cell.x, _drag_current_cell.y, target_cell.x, target_cell.y)
	_drag_current_cell = target_cell
	_drag_path.append(target_cell)
	_board_view.animate_swap(from_cell, target_cell, moving_orb_id, displaced_orb_id, SWAP_ANIMATION_SECONDS)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.selected_cell = _drag_current_cell
	_board_view.board_state = _board_state


func _end_drag(timed_out: bool) -> void:
	if not _active_drag:
		return

	_active_drag = false
	_drag_touch_index = -1
	_update_timer_label(0.0)
	var move_end_reason := "released"
	if timed_out:
		move_end_reason = "timer expired"
	_status_label.text = "Move ended: %s. Locking input for resolve phase." % move_end_reason

	_reset_drag_visuals()
	_set_input_phase(InputPhase.RESOLVING)
	_last_resolve_result = _resolver.resolve_all(_board_state)
	_board_view.board_state = _board_state
	await _play_resolve_animations(_last_resolve_result)
	if _input_phase == InputPhase.RESOLVING:
		_resolve_combat_turn_from_board(_last_resolve_result)


func _resolve_combat_turn_from_board(resolve_result: Dictionary) -> void:
	if _combat == null:
		return
	var turn_log: Dictionary = _combat.resolve_player_turn(resolve_result)
	_update_hud()

	if _combat.phase == COMBAT_PHASE_VICTORY:
		var transition: Dictionary = RunState.mark_fight_victory()
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_victory_status(turn_log, transition) + " Press Next."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
		_pending_next_scene_path = String(transition.get("next_scene", "res://scenes/main.tscn"))
		_next_button.visible = true
		_next_button.disabled = false
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		var defeat_cause := _build_defeat_cause(turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_defeat_status(turn_log)
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Transitioning to run summary.")
		_pending_next_scene_path = ""
		_next_button.visible = false
		_next_button.disabled = true
		_queue_outcome_transition(String(defeat_transition.get("next_scene", "res://scenes/flow/run_summary_placeholder.tscn")))
		return

	_status_label.text = _build_turn_summary_status(turn_log)
	_append_turn_log(turn_log)
	_begin_turn_preview()


func _on_next_button_pressed() -> void:
	if _pending_next_scene_path == "":
		return
	var target_scene := _pending_next_scene_path
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
	get_tree().change_scene_to_file(target_scene)


func _queue_outcome_transition(scene_path: String) -> void:
	if _outcome_transition_queued:
		return
	_outcome_transition_queued = true
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(scene_path)


func set_external_input_locked(locked: bool, reason: String = "") -> void:
	_external_lock_reason = reason
	if locked:
		if _active_drag:
			_abort_active_drag()
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	else:
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _set_input_phase(phase: InputPhase) -> void:
	_input_phase = phase

	match _input_phase:
		InputPhase.PLAYER_INPUT:
			_board_view.mouse_filter = Control.MOUSE_FILTER_STOP
		InputPhase.RESOLVING:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		InputPhase.LOCKED_EXTERNAL:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if _external_lock_reason != "":
				_status_label.text = "Input locked: %s" % _external_lock_reason


func _update_timer_label(seconds_left: float) -> void:
	_timer_label.text = "Timer: %.2f s" % seconds_left


func _reset_drag_visuals() -> void:
	_drag_selected_orb_id = -1
	_drag_current_cell = Vector2i(-1, -1)
	_drag_path.clear()
	_board_view.clear_match_glow()
	_board_view.selected_cell = Vector2i(-1, -1)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_orb_id = -1
	_board_view.drag_pointer_position = Vector2.ZERO


func _is_orthogonally_adjacent(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var delta := to_cell - from_cell
	return abs(delta.x) + abs(delta.y) == 1


func _abort_active_drag() -> void:
	_active_drag = false
	_drag_touch_index = -1
	_update_timer_label(0.0)
	_reset_drag_visuals()


func _screen_to_board_local(screen_position: Vector2) -> Vector2:
	var inverse_canvas_transform: Transform2D = _board_view.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas_transform * screen_position


func _refresh_drag_match_glow() -> void:
	if not _active_drag:
		_board_view.clear_match_glow()
		return
	var predicted_groups: Array[Dictionary] = _resolver.get_match_groups(_board_state)
	_board_view.set_live_match_glow(predicted_groups)


func _play_resolve_animations(result: Dictionary) -> void:
	if result.total_combos <= 0:
		return

	for pass_result in result.passes:
		_board_view.flash_match_groups(pass_result.groups, MATCH_FLASH_SECONDS)
		await get_tree().create_timer(MATCH_FLASH_SECONDS).timeout

		_board_view.animate_clear_groups(pass_result.groups, CLEAR_ANIMATION_SECONDS)
		await get_tree().create_timer(CLEAR_ANIMATION_SECONDS).timeout

		_board_view.animate_fall_moves(pass_result.fall_moves, GRAVITY_ANIMATION_SECONDS)
		await get_tree().create_timer(GRAVITY_ANIMATION_SECONDS).timeout

		_board_view.animate_refill_spawns(pass_result.refill_spawns, REFILL_ANIMATION_SECONDS)
		await get_tree().create_timer(REFILL_ANIMATION_SECONDS).timeout

	while _board_view.has_active_animations():
		await get_tree().create_timer(0.02).timeout


func _build_turn_summary_status(turn_log: Dictionary) -> String:
	return "Turn resolved: +%d HP, +%d Armor, +%d Gold, dealt %d (%d blocked)." % [
		int(turn_log.healed),
		int(turn_log.armor_gained),
		int(turn_log.gold_gained),
		int(turn_log.enemy_damage_taken),
		int(turn_log.enemy_blocked),
	]


func _build_victory_status(turn_log: Dictionary, transition: Dictionary) -> String:
	var next_scene := String(transition.get("next_scene", ""))
	var next_label := "Next scene"
	if next_scene.find("shop") >= 0:
		next_label = "shop"
	elif next_scene.find("boss_relic_reward") >= 0:
		next_label = "boss relic reward"
	elif next_scene.find("run_summary") >= 0:
		next_label = "run summary"
	elif next_scene.find("board_debug") >= 0:
		next_label = "next fight"
	return "Victory. Enemy defeated before intent (%s). Continue to %s." % [
		"skipped" if bool(turn_log.enemy_intent_skipped) else "resolved",
		next_label,
	]


func _build_defeat_status(turn_log: Dictionary) -> String:
	var hp_damage := int(turn_log.enemy_attack_resolution.get("hp_damage", 0))
	return "Defeat. Enemy intent dealt %d HP damage. Transitioning to run summary." % hp_damage


func _build_defeat_cause(turn_log: Dictionary) -> String:
	var enemy_label := String(_enemy_state.display_name if _enemy_state != null else "Enemy")
	var intent_label := String(Dictionary(turn_log.get("enemy_intent", {})).get("label", "Unknown intent"))
	var hp_damage := int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0))
	return "%s defeated the hero with %s for %d HP." % [enemy_label, intent_label, hp_damage]


func _update_hud() -> void:
	if _player_state == null or _enemy_state == null or _combat == null:
		return

	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	var relic_ids: Array = progression_snapshot.get("relic_ids", [])
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	var validation_errors: Array[Dictionary] = RunState.player_state_content_errors()

	_player_label.text = "Player  HP %d/%d  Armor %d  Gold %d\nEq: %s\nCons: %s\nRelics: %s\nMastery: %s\nContent Validation: %s" % [
		_player_state.current_hp,
		_player_state.max_hp,
		_player_state.armor,
		_player_state.gold,
		_format_slot_line(equipment_slots),
		_format_slot_line(consumable_slots),
		_format_id_line(relic_ids),
		_format_mastery_line(mastery_levels),
		"OK" if validation_errors.is_empty() else ("%d issue(s)" % validation_errors.size()),
	]

	_enemy_label.text = "%s  HP %d/%d  Turn Block %d" % [
		_enemy_state.display_name,
		_enemy_state.current_hp,
		_enemy_state.max_hp,
		_enemy_state.current_turn_block,
	]

	var intent := _enemy_state.get_current_intent()
	_intent_label.text = "Enemy Intent: %s" % _format_intent(intent)
	_phase_label.text = "Run: %s\nCombat Phase: %s" % [RunState.level_sequence_label(), _combat.phase_name()]


func _format_intent(intent: Dictionary) -> String:
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func _append_turn_log(turn_log: Dictionary) -> void:
	var resolved_turn := int(turn_log.get("resolved_turn_index", 0))
	var combo_count := int(turn_log.get("combo_count", 0))
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	var fire_orbs := int(matched_counts.get(OrbType.Id.FIRE, 0))
	var ice_orbs := int(matched_counts.get(OrbType.Id.ICE, 0))
	var earth_orbs := int(matched_counts.get(OrbType.Id.EARTH, 0))
	var heart_orbs := int(matched_counts.get(OrbType.Id.HEART, 0))
	var armor_orbs := int(matched_counts.get(OrbType.Id.ARMOR, 0))
	var gold_orbs := int(matched_counts.get(OrbType.Id.GOLD, 0))
	var fire_mastery_level := _player_state.orb_value(OrbType.Id.FIRE) - 1
	var ice_mastery_level := _player_state.orb_value(OrbType.Id.ICE) - 1
	var earth_mastery_level := _player_state.orb_value(OrbType.Id.EARTH) - 1
	var heart_mastery_level := _player_state.orb_value(OrbType.Id.HEART) - 1
	var armor_mastery_level := _player_state.orb_value(OrbType.Id.ARMOR) - 1
	var gold_mastery_level := _player_state.orb_value(OrbType.Id.GOLD) - 1
	var fire_base := int(turn_log.get("fire_base", 0))
	var ice_base := int(turn_log.get("ice_base", 0))
	var earth_base := int(turn_log.get("earth_base", 0))
	var damage_combo_multiplier := float(turn_log.get("damage_combo_multiplier", 0.0))
	var increase_combo_modifier := int(turn_log.get("increase_combo_modifier", 0))
	var more_combo_modifier := float(turn_log.get("more_combo_modifier", 1.0))

	_append_combat_log("---- Turn %d ----" % resolved_turn)
	_append_combat_log("Matches: combos=%d | %s" % [combo_count, _format_matched_counts(matched_counts)])
	_append_combat_log(
		"Damage combo multiplier: (%d + %d) * %.2f = %.2f" % [
			increase_combo_modifier,
			combo_count,
			more_combo_modifier,
			damage_combo_multiplier,
		]
	)
	_append_combat_log(
		"Heart = %d x (%d + 1) = %d # {orb_count: %d, heart_mastery_level: %d}" % [
			heart_orbs,
			heart_mastery_level,
			int(turn_log.get("heart_base", 0)),
			heart_orbs,
			heart_mastery_level,
		]
	)
	_append_combat_log(
		"Armor gain: base %d (%d * (%d+1)) * %.2f = +%d Armor" % [
			int(turn_log.get("armor_base", 0)),
			armor_orbs,
			armor_mastery_level,
			damage_combo_multiplier,
			int(turn_log.armor_gained),
		]
	)
	_append_combat_log("Elemental calculation:")
	_append_combat_log(
		"Fire = %d x (%d + 1) = %d # {orb_count: %d, fire_mastery_level: %d}" % [
			fire_orbs,
			fire_mastery_level,
			fire_base,
			fire_orbs,
			fire_mastery_level,
		]
	)
	_append_combat_log(
		"Ice = %d x (%d + 1) = %d # {orb_count: %d, ice_mastery_level: %d}" % [
			ice_orbs,
			ice_mastery_level,
			ice_base,
			ice_orbs,
			ice_mastery_level,
		]
	)
	_append_combat_log(
		"Earth = %d x (%d + 1) = %d # {orb_count: %d, earth_mastery_level: %d}" % [
			earth_orbs,
			earth_mastery_level,
			earth_base,
			earth_orbs,
			earth_mastery_level,
		]
	)
	_append_combat_log("Damage combo multiplier applied to elemental base: %.2f" % damage_combo_multiplier)
	_append_combat_log("Total Elemental Damage = %d" % int(turn_log.total_elemental_damage))
	_append_combat_log(
		"Enemy block reduced damage by %d. Enemy took %d." % [
			int(turn_log.enemy_blocked),
			int(turn_log.enemy_damage_taken),
		]
	)
	_append_combat_log(
		"Gold = %d x (%d + 1) = %d # {orb_count: %d, gold_mastery_level: %d}" % [
			gold_orbs,
			gold_mastery_level,
			int(turn_log.get("gold_base", 0)),
			gold_orbs,
			gold_mastery_level,
		]
	)

	if bool(turn_log.enemy_intent_skipped):
		_append_combat_log("Enemy intent skipped because enemy was defeated first.")
	else:
		var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
		_append_combat_log(
			"Enemy attack: incoming %d, blocked by armor %d, HP damage %d." % [
				int(enemy_attack.get("incoming", 0)),
				int(enemy_attack.get("blocked_by_armor", 0)),
				int(enemy_attack.get("hp_damage", 0)),
			]
		)

	_append_combat_log("Armor expired after enemy action: %d." % int(turn_log.expired_armor))
	_append_combat_log(
		"End state: Player HP %d/%d Armor %d Gold %d | Enemy HP %d/%d" % [
			_player_state.current_hp,
			_player_state.max_hp,
			_player_state.armor,
			_player_state.gold,
			_enemy_state.current_hp,
			_enemy_state.max_hp,
		]
	)


func _format_matched_counts(matched_counts: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count <= 0:
			continue
		parts.append("%s=%d" % [OrbType.debug_symbol(orb_id), count])
	if parts.is_empty():
		return "none"
	return ", ".join(parts)


func _append_combat_log(message: String, is_command_output: bool = false) -> void:
	var timestamp := Time.get_time_string_from_system()
	_combat_log_lines.append("[%s] %s" % [timestamp, message])
	_combat_log_command_flags.append(is_command_output)
	if _combat_log_lines.size() > MAX_COMBAT_LOG_LINES:
		_combat_log_lines = _combat_log_lines.slice(_combat_log_lines.size() - MAX_COMBAT_LOG_LINES, _combat_log_lines.size())
		_combat_log_command_flags = _combat_log_command_flags.slice(
			_combat_log_command_flags.size() - MAX_COMBAT_LOG_LINES,
			_combat_log_command_flags.size()
		)
	_refresh_combat_log_display()


func _refresh_combat_log_display() -> void:
	if _combat_log_text == null:
		return
	_combat_log_text.clear()
	var line_count := _combat_log_lines.size()
	for index in range(line_count):
		var line_text := _combat_log_lines[index]
		if index < line_count - 1:
			line_text += "\n"
		if index < _combat_log_command_flags.size() and _combat_log_command_flags[index]:
			_combat_log_text.push_color(COMMAND_OUTPUT_LOG_COLOR)
			_combat_log_text.add_text(line_text)
			_combat_log_text.pop()
		else:
			_combat_log_text.add_text(line_text)
	_combat_log_text.scroll_to_line(maxi(0, line_count - 1))


func debug_console_log(message: String) -> void:
	_append_combat_log(message)


func _format_slot_line(slot_values: Array) -> String:
	var parts: Array[String] = []
	for value in slot_values:
		var text := String(value)
		parts.append(text if text != "" else "-")
	return "[" + ", ".join(parts) + "]"


func _format_id_line(values: Array) -> String:
	if values.is_empty():
		return "-"
	var rendered: Array[String] = []
	for value in values:
		rendered.append(String(value))
	return "[" + ", ".join(rendered) + "]"


func _format_mastery_line(levels: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		parts.append("%s:%d" % [OrbType.debug_symbol(orb_id), int(levels.get(orb_id, 0))])
	return "[" + ", ".join(parts) + "]"


func _on_resolver_match_found(groups: Array) -> void:
	_status_label.text = "Matches found: %d group(s)." % groups.size()


func _on_resolver_cells_cleared(_cells: Array) -> void:
	pass


func _on_resolver_gravity_applied(_fall_moves: Array) -> void:
	pass


func _on_resolver_refill_applied(_refill_spawns: Array) -> void:
	pass


func _on_resolver_cascade_step_complete(_step_index: int, _total_combos: int) -> void:
	pass


func _on_resolver_complete(_result: Dictionary) -> void:
	pass
