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
	_reset_drag_visuals()
	_board_view.clear_animations()
	var board_seed := _resolve_seed()
	_board_state.initialize(board_seed, _settings)
	_board_view.board_state = _board_state
	if _combat != null and not _combat.is_fight_over():
		_set_input_phase(InputPhase.PLAYER_INPUT)
		_status_label.text = "Seed: %d | Turn %d ready." % [board_seed, _combat.turn_index]
	else:
		_status_label.text = "Seed: %d | Fight complete." % board_seed


func _resolve_seed() -> int:
	return int(Time.get_ticks_usec())


func _print_board_state() -> void:
	var debug_text := _board_state.to_debug_string()
	print("\n[Board Debug] Seed=", _board_state.rng_seed)
	print(debug_text)
	_status_label.text = "Printed board for seed %d to output." % _board_state.rng_seed


func _on_console_input_text_submitted(text: String) -> void:
	var trimmed := text.strip_edges()
	if trimmed == "":
		_console_input.clear()
		return
	_append_combat_log("> " + trimmed)
	_console_input.clear()


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
	var heart_orbs := int(matched_counts.get(OrbType.Id.HEART, 0))
	var armor_orbs := int(matched_counts.get(OrbType.Id.ARMOR, 0))
	var gold_orbs := int(matched_counts.get(OrbType.Id.GOLD, 0))
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
		"Heart heal: base %d from %d * (%d+1) = +%d HP (no combo scaling)" % [
			int(turn_log.get("heart_base", 0)),
			heart_orbs,
			_player_state.orb_value(OrbType.Id.HEART) - 1,
			int(turn_log.healed),
		]
	)
	_append_combat_log(
		"Armor gain: base %d (%d * (%d+1)) * %.2f = +%d Armor" % [
			int(turn_log.get("armor_base", 0)),
			armor_orbs,
			_player_state.orb_value(OrbType.Id.ARMOR) - 1,
			damage_combo_multiplier,
			int(turn_log.armor_gained),
		]
	)
	_append_combat_log(
		"Elemental: F base %d -> %d, I base %d -> %d, E base %d -> %d => total %d" % [
			int(turn_log.get("fire_base", 0)), int(turn_log.fire_damage),
			int(turn_log.get("ice_base", 0)), int(turn_log.ice_damage),
			int(turn_log.get("earth_base", 0)), int(turn_log.earth_damage),
			int(turn_log.total_elemental_damage),
		]
	)
	_append_combat_log(
		"Enemy block reduced damage by %d. Enemy took %d." % [
			int(turn_log.enemy_blocked),
			int(turn_log.enemy_damage_taken),
		]
	)
	_append_combat_log(
		"Gold gain: base %d from %d * (%d+1) = +%d Gold (no combo scaling)" % [
			int(turn_log.get("gold_base", 0)),
			gold_orbs,
			_player_state.orb_value(OrbType.Id.GOLD) - 1,
			int(turn_log.gold_gained),
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


func _append_combat_log(message: String) -> void:
	var timestamp := Time.get_time_string_from_system()
	_combat_log_lines.append("[%s] %s" % [timestamp, message])
	if _combat_log_lines.size() > MAX_COMBAT_LOG_LINES:
		_combat_log_lines = _combat_log_lines.slice(_combat_log_lines.size() - MAX_COMBAT_LOG_LINES, _combat_log_lines.size())
	if _combat_log_text != null:
		_combat_log_text.text = "\n".join(_combat_log_lines)
		_combat_log_text.scroll_to_line(maxi(0, _combat_log_lines.size() - 1))


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
