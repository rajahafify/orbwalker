extends Control

@onready var _board_view: BoardView = %BoardView
@onready var _status_label: Label = %StatusLabel
@onready var _seed_input: LineEdit = %SeedInput
@onready var _use_seed_check: CheckBox = %UseSeedCheckBox
@onready var _timer_label: Label = %TimerLabel
@onready var _run_tests_button: Button = %RunResolverTestsButton

const MOVE_TIMER_SECONDS := 5.0
const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_v3.gd")
const BOARD_RESOLVER_TEST_RUNNER_SCRIPT := preload("res://scripts/debug/board_resolver_test_runner.gd")

enum InputPhase {
	PLAYER_INPUT,
	RESOLVING,
	LOCKED_EXTERNAL,
}

var _settings := BoardGenerationSettings.new()
var _board_state := BoardState.new()
var _resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()
var _input_phase: InputPhase = InputPhase.PLAYER_INPUT
var _active_drag := false
var _drag_touch_index: int = -1
var _drag_selected_orb_id: int = -1
var _drag_current_cell: Vector2i = Vector2i(-1, -1)
var _drag_path: Array[Vector2i] = []
var _move_time_left: float = 0.0
var _external_lock_reason := ""
var _last_resolve_result: Dictionary = {}


func _ready() -> void:
	_seed_input.text = str(1337)
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_create_new_board()
	_board_view.gui_input.connect(_on_board_view_gui_input)
	set_process(true)


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
	_set_input_phase(InputPhase.PLAYER_INPUT)
	_status_label.text = "Seed: %d | Ready for drag movement." % board_seed


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
	_move_time_left = MOVE_TIMER_SECONDS
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
		_set_input_phase(InputPhase.PLAYER_INPUT)
		_status_label.text = _build_resolve_status_text(_last_resolve_result)


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

	# Let any remaining overlay finish before restoring input.
	while _board_view.has_active_animations():
		await get_tree().create_timer(0.02).timeout


func _build_resolve_status_text(result: Dictionary) -> String:
	if result.total_combos <= 0:
		return "No matches. Ready for next move."
	return "Resolved %d combo(s) over %d pass(es): %s" % [
		result.total_combos,
		result.passes.size(),
		_format_matched_counts(result.matched_counts),
	]


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


func _on_resolver_match_found(groups: Array) -> void:
	# Hook point for future match animations.
	_status_label.text = "Matches found: %d group(s)." % groups.size()


func _on_resolver_cells_cleared(_cells: Array) -> void:
	# Hook point for future clear animations.
	pass


func _on_resolver_gravity_applied(_fall_moves: Array) -> void:
	# Hook point for future gravity animations.
	pass


func _on_resolver_refill_applied(_refill_spawns: Array) -> void:
	# Hook point for future refill animations.
	pass


func _on_resolver_cascade_step_complete(_step_index: int, _total_combos: int) -> void:
	# Hook point for future cascade step transitions.
	pass


func _on_resolver_complete(_result: Dictionary) -> void:
	# Hook point for future "resolve finished" animation sequencing.
	pass
