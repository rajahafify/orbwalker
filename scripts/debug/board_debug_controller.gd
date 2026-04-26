extends Control

@onready var _board_view: BoardView = %BoardView
@onready var _status_label: Label = %StatusLabel
@onready var _seed_input: LineEdit = %SeedInput
@onready var _use_seed_check: CheckBox = %UseSeedCheckBox
@onready var _timer_label: Label = %TimerLabel
@onready var _run_tests_button: Button = %RunResolverTestsButton
@onready var _player_label: Label = %PlayerStateLabel
@onready var _enemy_label: Label = %EnemyStateLabel
@onready var _intent_label: Label = %EnemyIntentLabel
@onready var _phase_label: Label = %CombatPhaseLabel
@onready var _combat_log_text: RichTextLabel = %CombatLogText
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

const VICTORY_SCENE_PATH := "res://scenes/flow/shop_placeholder.tscn"
const DEFEAT_SCENE_PATH := "res://scenes/flow/run_summary_placeholder.tscn"
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


func _ready() -> void:
	_seed_input.text = str(1337)
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_initialize_combat_state()
	_create_new_board()
	_board_view.gui_input.connect(_on_board_view_gui_input)
	set_process(true)
	_begin_turn_preview()


func _initialize_combat_state() -> void:
	_player_state = RunState.ensure_player_state()
	_enemy_state = ENEMY_STATE_SCRIPT.new()
	_enemy_state.reset_for_fight()
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	_outcome_transition_queued = false
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
	_update_hud()
	_combat_log_lines.clear()
	_append_combat_log("Fight started: %s HP %d." % [_enemy_state.display_name, _enemy_state.max_hp])
	_append_combat_log("Player start: HP %d/%d, Gold %d." % [_player_state.current_hp, _player_state.max_hp, _player_state.gold])


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
	_status_label.text = "Turn %d. Enemy intent shown. Drag to make your move." % _combat.turn_index
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
	if _use_seed_check.button_pressed:
		var parsed := _seed_input.text.to_int()
		return parsed
	return int(Time.get_ticks_usec())


func _print_board_state() -> void:
	var debug_text := _board_state.to_debug_string()
	print("\n[Board Debug] Seed=", _board_state.rng_seed)
	print(debug_text)
	_status_label.text = "Printed board for seed %d to output." % _board_state.rng_seed


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
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_victory_status(turn_log) + " Press Next."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Victory. Waiting for Next button.")
		_pending_next_scene_path = VICTORY_SCENE_PATH
		_next_button.visible = true
		_next_button.disabled = false
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_defeat_status(turn_log)
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Transitioning to run summary.")
		_pending_next_scene_path = ""
		_next_button.visible = false
		_next_button.disabled = true
		_queue_outcome_transition(DEFEAT_SCENE_PATH)
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
			_run_tests_button.disabled = false
		InputPhase.RESOLVING:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_run_tests_button.disabled = true
		InputPhase.LOCKED_EXTERNAL:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_run_tests_button.disabled = true
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


func _build_victory_status(turn_log: Dictionary) -> String:
	return "Victory. Enemy defeated before intent (%s). Transitioning to shop reward." % (
		"skipped" if bool(turn_log.enemy_intent_skipped) else "resolved"
	)


func _build_defeat_status(turn_log: Dictionary) -> String:
	var hp_damage := int(turn_log.enemy_attack_resolution.get("hp_damage", 0))
	return "Defeat. Enemy intent dealt %d HP damage. Transitioning to run summary." % hp_damage


func _update_hud() -> void:
	if _player_state == null or _enemy_state == null or _combat == null:
		return

	_player_label.text = "Player  HP %d/%d  Armor %d  Gold %d" % [
		_player_state.current_hp,
		_player_state.max_hp,
		_player_state.armor,
		_player_state.gold,
	]

	_enemy_label.text = "%s  HP %d/%d  Turn Block %d" % [
		_enemy_state.display_name,
		_enemy_state.current_hp,
		_enemy_state.max_hp,
		_enemy_state.current_turn_block,
	]

	var intent := _enemy_state.get_current_intent()
	_intent_label.text = "Enemy Intent: %s" % _format_intent(intent)
	_phase_label.text = "Combat Phase: %s" % _combat.phase_name()


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
	var combo_scale := maxi(1, combo_count)

	_append_combat_log("---- Turn %d ----" % resolved_turn)
	_append_combat_log("Matches: combos=%d | %s" % [combo_count, _format_matched_counts(matched_counts)])
	_append_combat_log(
		"Heart heal: %d * %d = +%d HP" % [
			heart_orbs,
			_player_state.orb_value(OrbType.Id.HEART),
			int(turn_log.healed),
		]
	)
	_append_combat_log(
		"Armor gain: %d * %d = +%d Armor" % [
			armor_orbs,
			_player_state.orb_value(OrbType.Id.ARMOR),
			int(turn_log.armor_gained),
		]
	)
	_append_combat_log(
		"Elemental (%dx combo): F %d*%d*%d=%d, I %d*%d*%d=%d, E %d*%d*%d=%d => total %d" % [
			combo_scale,
			fire_orbs, _player_state.orb_value(OrbType.Id.FIRE), combo_scale, int(turn_log.fire_damage),
			ice_orbs, _player_state.orb_value(OrbType.Id.ICE), combo_scale, int(turn_log.ice_damage),
			earth_orbs, _player_state.orb_value(OrbType.Id.EARTH), combo_scale, int(turn_log.earth_damage),
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
		"Gold gain: %d * %d = +%d Gold" % [
			gold_orbs,
			_player_state.orb_value(OrbType.Id.GOLD),
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
