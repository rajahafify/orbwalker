extends RefCounted
class_name CombatResolvePresenter

const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const COMBO_POPUP_SIZE := Vector2(420.0, 96.0)
const COMBO_POPUP_BASE_FONT_SIZE := 42
const COMBO_POPUP_MAX_FONT_SIZE := 78
const COMBO_COUNT_STEP_SECONDS := 0.22
const CASCADE_PASS_HOLD_SECONDS := 0.16
const ANIMATION_DRAIN_MAX_ITERATIONS := 600
const ANIMATION_DRAIN_MAX_SECONDS := 8.0
const COMBAT_SPEED_SLOW := "slow"
const COMBAT_SPEED_NORMAL := "normal"
const COMBAT_SPEED_FAST := "fast"
const COMBAT_SPEED_INSTANT := "instant"

var _board_surface: Control
var _board_view: BoardView
var _board_panel: Control
var _timer_owner: Node
var _spawn_vfx_texture_callback: Callable
var _combo_sound_callback: Callable
var _combat_speed := COMBAT_SPEED_NORMAL

var _resolve_combo_running := 0
var _match_clear_burst_texture: Texture2D
var _combo_popup_panel: PanelContainer
var _combo_popup_label: Label
var _combo_popup_fade_tween: Tween


func bind(nodes: Dictionary) -> void:
	_board_surface = nodes.get("board_surface") as Control
	_board_view = nodes.get("board_view") as BoardView
	_board_panel = nodes.get("board_panel") as Control
	_timer_owner = nodes.get("timer_owner") as Node
	_spawn_vfx_texture_callback = nodes.get("spawn_vfx_texture_callback", Callable())
	_combo_sound_callback = nodes.get("combo_sound_callback", Callable())


func set_combat_speed(speed: String) -> void:
	match speed:
		COMBAT_SPEED_INSTANT, COMBAT_SPEED_FAST, COMBAT_SPEED_NORMAL, COMBAT_SPEED_SLOW:
			_combat_speed = speed
		_:
			_combat_speed = COMBAT_SPEED_NORMAL


func combat_speed_duration(base_seconds: float) -> float:
	match _combat_speed:
		COMBAT_SPEED_INSTANT:
			return 0.01
		COMBAT_SPEED_FAST:
			return base_seconds * 0.55
		COMBAT_SPEED_NORMAL:
			return base_seconds
		COMBAT_SPEED_SLOW:
			return base_seconds * 2.35
		_:
			return base_seconds


func wait_combat_speed(base_seconds: float) -> void:
	var wait_seconds := combat_speed_duration(base_seconds)
	await _wait_duration(wait_seconds)


func play_resolve_animations(
	result: Dictionary,
	visual_board_state: BoardState = null,
	resolve_trace_origin_usec: int = 0,
	callbacks: Dictionary = {}
) -> void:
	if not _can_continue_after_wait() or result.get("total_combos", 0) <= 0:
		return

	var trace_callback: Callable = callbacks.get("trace_callback", Callable())
	var combo_preview_callback: Callable = callbacks.get("combo_preview_callback", Callable())
	var combo_feedback_callback: Callable = callbacks.get("combo_feedback_callback", Callable())
	var set_pass_index_callback: Callable = callbacks.get("set_pass_index_callback", Callable())
	var pass_results: Array = result.get("passes", [])
	_resolve_combo_running = 0

	for pass_index in range(pass_results.size()):
		if set_pass_index_callback.is_valid():
			set_pass_index_callback.call(pass_index)
		var pass_result: Dictionary = pass_results[pass_index]
		var presented_groups := _sorted_match_groups_for_presentation(pass_result.get("groups", []))
		var group_count := presented_groups.size()
		var fall_count := Array(pass_result.get("fall_moves", [])).size()
		var refill_count := Array(pass_result.get("refill_spawns", [])).size()
		var step_index := int(pass_result.get("step_index", pass_index))
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=pass_start step_index=%d groups=%d fall=%d refill=%d" % [
				pass_index,
				step_index,
				group_count,
				fall_count,
				refill_count,
			]
		)
		await _play_match_groups_for_pass(
			presented_groups,
			visual_board_state,
			resolve_trace_origin_usec,
			pass_index,
			trace_callback,
			combo_preview_callback,
			combo_feedback_callback
		)
		if not _can_continue_after_wait():
			return
		await wait_combat_speed(CASCADE_PASS_HOLD_SECONDS)
		if not _can_continue_after_wait():
			return

		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=gravity_start moves=%d gravity_ms=%d" % [
				pass_index,
				fall_count,
				int(round(combat_speed_duration(GRAVITY_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		if not _can_continue_after_wait():
			return
		var gravity_animation_seconds := combat_speed_duration(GRAVITY_ANIMATION_SECONDS)
		_board_view.animate_fall_moves(pass_result.fall_moves, gravity_animation_seconds)
		await wait_combat_speed(GRAVITY_ANIMATION_SECONDS)
		if not _can_continue_after_wait():
			return
		_apply_visual_fall_moves(visual_board_state, pass_result.fall_moves)
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=gravity_visual_commit moves=%d" % [pass_index, fall_count]
		)

		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=refill_start spawns=%d refill_ms=%d" % [
				pass_index,
				refill_count,
				int(round(combat_speed_duration(REFILL_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		if not _can_continue_after_wait():
			return
		var refill_animation_seconds := combat_speed_duration(REFILL_ANIMATION_SECONDS)
		_board_view.animate_refill_spawns(pass_result.refill_spawns, refill_animation_seconds)
		await wait_combat_speed(REFILL_ANIMATION_SECONDS)
		if not _can_continue_after_wait():
			return
		_apply_visual_refill_spawns(visual_board_state, pass_result.refill_spawns)
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=refill_visual_commit spawns=%d" % [pass_index, refill_count]
		)
		await wait_combat_speed(CASCADE_PASS_HOLD_SECONDS)
		if not _can_continue_after_wait():
			return
		_call_trace(trace_callback, resolve_trace_origin_usec, "pass=%d phase=pass_complete" % pass_index)

	if set_pass_index_callback.is_valid():
		set_pass_index_callback.call(-1)
	_call_trace(trace_callback, resolve_trace_origin_usec, "phase=animations_drain_start")
	var drain_iterations := 0
	var drain_start_usec := Time.get_ticks_usec()
	while _can_continue_after_wait() and _board_view.has_active_animations():
		drain_iterations += 1
		var elapsed_seconds := float(Time.get_ticks_usec() - drain_start_usec) / 1000000.0
		if drain_iterations > ANIMATION_DRAIN_MAX_ITERATIONS or elapsed_seconds >= ANIMATION_DRAIN_MAX_SECONDS:
			_call_trace(
				trace_callback,
				resolve_trace_origin_usec,
				"phase=animations_drain_timeout iterations=%d elapsed_ms=%d" % [
					drain_iterations,
					int(round(elapsed_seconds * 1000.0)),
				]
			)
			break
		await _wait_duration(0.02)
	if not _can_continue_after_wait():
		return
	_finish_combo_popup()
	_call_trace(trace_callback, resolve_trace_origin_usec, "phase=animations_drain_complete")


func _play_match_groups_for_pass(
	groups: Array,
	visual_board_state: BoardState,
	resolve_trace_origin_usec: int,
	pass_index: int,
	trace_callback: Callable,
	combo_preview_callback: Callable,
	combo_feedback_callback: Callable
) -> void:
	for group_index in range(groups.size()):
		if not _can_continue_after_wait():
			return
		var typed_group: Dictionary = groups[group_index]
		var one_group: Array[Dictionary] = [typed_group]
		var match_flash_seconds := combat_speed_duration(MATCH_FLASH_SECONDS)
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=match_flash_start group_index=%d flash_ms=%d" % [
				pass_index,
				group_index,
				int(round(match_flash_seconds * 1000.0)),
			]
		)
		await _trigger_match_feedback(one_group, match_flash_seconds)
		if not _can_continue_after_wait():
			return
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=match_flash_end group_index=%d" % [pass_index, group_index]
		)

		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=clear_start group_index=%d clear_ms=%d" % [
				pass_index,
				group_index,
				int(round(combat_speed_duration(CLEAR_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		_spawn_match_clear_bursts(one_group)
		var clear_animation_seconds := combat_speed_duration(CLEAR_ANIMATION_SECONDS)
		_board_view.animate_clear_groups(one_group, clear_animation_seconds)
		await wait_combat_speed(CLEAR_ANIMATION_SECONDS)
		if not _can_continue_after_wait():
			return
		_apply_visual_clear_groups(visual_board_state, one_group)
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=clear_visual_commit group_index=%d" % [pass_index, group_index]
		)

		_resolve_combo_running += 1
		var orb_id := int(typed_group.get("orb_id", -1))
		var orb_symbol := "?"
		var orb_name := "unknown"
		if OrbType.is_valid_id(orb_id):
			orb_symbol = OrbType.debug_symbol(orb_id)
			orb_name = OrbType.display_name(orb_id)
		var cell_count := Array(typed_group.get("cells", [])).size()
		var preview_amount := 0
		if combo_preview_callback.is_valid():
			preview_amount = int(combo_preview_callback.call(typed_group, _resolve_combo_running))
		_call_trace(
			trace_callback,
			resolve_trace_origin_usec,
			"pass=%d phase=combo_tick group_index=%d combo_value=%d orb=%s orb_name=\"%s\" cells=%d preview=%d" % [
				pass_index,
				group_index,
				_resolve_combo_running,
				orb_symbol,
				orb_name,
				cell_count,
				preview_amount,
			]
		)
		_spawn_combo_floating_text(typed_group, _resolve_combo_running)
		if combo_feedback_callback.is_valid():
			combo_feedback_callback.call(typed_group, _resolve_combo_running)
		await wait_combat_speed(COMBO_COUNT_STEP_SECONDS)
		if not _can_continue_after_wait():
			return


func _trigger_match_feedback(groups: Array, flash_seconds: float) -> void:
	if not _can_continue_after_wait():
		return
	_board_view.flash_match_groups(groups, flash_seconds)
	if flash_seconds <= 0.01:
		await _wait_duration(0.0)
		return
	await _wait_duration(flash_seconds)


func _sorted_match_groups_for_presentation(groups: Array) -> Array:
	var sorted_groups := groups.duplicate()
	sorted_groups.sort_custom(_compare_match_groups_for_presentation)
	return sorted_groups


func _compare_match_groups_for_presentation(left: Dictionary, right: Dictionary) -> bool:
	var left_anchor := _match_group_anchor(left)
	var right_anchor := _match_group_anchor(right)
	if left_anchor.y == right_anchor.y:
		return left_anchor.x < right_anchor.x
	return left_anchor.y < right_anchor.y


func _match_group_anchor(group: Dictionary) -> Vector2i:
	var cells: Array = group.get("cells", [])
	if cells.is_empty():
		return Vector2i(BoardState.COLUMN_COUNT, BoardState.ROW_COUNT)

	var min_row := BoardState.ROW_COUNT
	var min_column := BoardState.COLUMN_COUNT
	for cell in cells:
		var typed_cell: Vector2i = cell
		if typed_cell.y < min_row:
			min_row = typed_cell.y
			min_column = typed_cell.x
		elif typed_cell.y == min_row:
			min_column = mini(min_column, typed_cell.x)
	return Vector2i(min_column, min_row)


func _apply_visual_clear_groups(visual_board_state: BoardState, groups: Array) -> void:
	if visual_board_state == null or _board_view == null:
		return
	for group in groups:
		for cell in group.cells:
			var typed_cell: Vector2i = cell
			visual_board_state.clear_cell(typed_cell.x, typed_cell.y)
	_board_view.queue_redraw()


func _apply_visual_fall_moves(visual_board_state: BoardState, fall_moves: Array) -> void:
	if visual_board_state == null or _board_view == null:
		return
	for move in fall_moves:
		var from_cell: Vector2i = move.from
		visual_board_state.clear_cell(from_cell.x, from_cell.y)
	for move in fall_moves:
		var to_cell: Vector2i = move.to
		var orb_id := int(move.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_state.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func _apply_visual_refill_spawns(visual_board_state: BoardState, refill_spawns: Array) -> void:
	if visual_board_state == null or _board_view == null:
		return
	for spawn in refill_spawns:
		var to_cell: Vector2i = spawn.to
		var orb_id := int(spawn.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_state.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func _spawn_match_clear_bursts(groups: Array) -> void:
	if not _can_continue_after_wait():
		return
	for raw_group in groups:
		var group: Dictionary = raw_group
		var cells: Array = group.get("cells", [])
		var matched_count: int = cells.size()
		var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
		var burst_size := Vector2(60.0, 60.0)
		if matched_count >= 5:
			burst_size = Vector2(78.0, 78.0)
		elif matched_count >= 4:
			burst_size = Vector2(68.0, 68.0)
		for raw_cell in cells:
			var cell: Vector2i = raw_cell
			if not _board_view.is_cell_valid(cell):
				continue
			var board_center: Vector2 = _board_view.get_cell_center(cell)
			var global_center: Vector2 = _board_view.get_global_transform_with_canvas() * board_center
			_spawn_match_clear_burst(global_center, burst_size, orb_id)


func _spawn_match_clear_burst(global_center: Vector2, draw_size: Vector2, orb_id: int) -> void:
	if not _spawn_vfx_texture_callback.is_valid():
		return
	var burst_texture := _match_clear_burst()
	var orb_tint := OrbType.color(orb_id)
	orb_tint = orb_tint.lerp(Color.WHITE, 0.42)
	orb_tint.a = 0.72
	_spawn_vfx_texture_callback.call(burst_texture, global_center, draw_size, 0.22, orb_tint)


func _match_clear_burst() -> Texture2D:
	if _match_clear_burst_texture != null:
		return _match_clear_burst_texture
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 0.0))
	var center := Vector2(47.5, 47.5)
	for y in 96:
		for x in 96:
			var point := Vector2(float(x), float(y))
			var offset := point - center
			var distance := offset.length()
			var radial_alpha: float = clampf(1.0 - distance / 44.0, 0.0, 1.0)
			var ring_alpha: float = maxf(0.0, 1.0 - absf(distance - 24.0) / 7.0) * 0.38
			var axis_alpha: float = 0.0
			if absf(offset.x) < 2.0 or absf(offset.y) < 2.0:
				axis_alpha = clampf(1.0 - distance / 43.0, 0.0, 1.0) * 0.74
			if absf(absf(offset.x) - absf(offset.y)) < 1.7:
				axis_alpha = maxf(axis_alpha, clampf(1.0 - distance / 39.0, 0.0, 1.0) * 0.44)
			var alpha: float = maxf(radial_alpha * radial_alpha * 0.34, maxf(ring_alpha, axis_alpha))
			if alpha > 0.01:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	_match_clear_burst_texture = ImageTexture.create_from_image(image)
	return _match_clear_burst_texture


func _spawn_combo_floating_text(group: Dictionary, combo_value: int) -> void:
	if not _can_continue_after_wait():
		return
	var cells: Array = group.get("cells", [])
	if cells.is_empty():
		return
	if _combo_sound_callback.is_valid():
		_combo_sound_callback.call()
	var combo_text := "COMBO x%d" % combo_value
	var font_size := mini(COMBO_POPUP_MAX_FONT_SIZE, COMBO_POPUP_BASE_FONT_SIZE + maxi(0, combo_value - 1) * 6)

	var combo_panel := _ensure_combo_popup_panel()
	if combo_panel == null or _combo_popup_label == null:
		return
	combo_panel.position = _center_combo_popup_position()
	combo_panel.modulate.a = 1.0
	_combo_popup_label.text = combo_text
	_combo_popup_label.add_theme_font_size_override("font_size", font_size)
	_combo_popup_label.size = COMBO_POPUP_SIZE
	if _combo_popup_fade_tween != null and _combo_popup_fade_tween.is_valid():
		_combo_popup_fade_tween.kill()

	combo_panel.pivot_offset = combo_panel.size * 0.5
	combo_panel.scale = Vector2(1.0, 1.0)
	var pulse_scale := 1.0 + minf(0.22, float(combo_value) * 0.018)
	if _timer_owner != null and is_instance_valid(_timer_owner):
		var pop_tween := _timer_owner.create_tween()
		pop_tween.tween_property(combo_panel, "scale", Vector2(pulse_scale, pulse_scale), 0.07)
		pop_tween.tween_property(combo_panel, "scale", Vector2(1.0, 1.0), 0.10)


func _ensure_combo_popup_panel() -> PanelContainer:
	if is_instance_valid(_combo_popup_panel):
		return _combo_popup_panel
	if not _can_continue_after_wait() or _board_panel == null:
		return null
	var combo_panel := PanelContainer.new()
	combo_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combo_panel.size = COMBO_POPUP_SIZE
	combo_panel.custom_minimum_size = COMBO_POPUP_SIZE
	combo_panel.z_index = 80
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	panel_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	panel_style.set_border_width_all(0)
	combo_panel.add_theme_stylebox_override("panel", panel_style)

	var combo_label := Label.new()
	combo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", COMBO_POPUP_BASE_FONT_SIZE)
	combo_label.add_theme_constant_override("outline_size", 7)
	combo_label.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.00, 0.96))
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.28, 1.0))
	combo_label.position = Vector2.ZERO
	combo_label.size = COMBO_POPUP_SIZE
	combo_panel.add_child(combo_label)
	_board_panel.add_child(combo_panel)
	_combo_popup_panel = combo_panel
	_combo_popup_label = combo_label
	return combo_panel


func _finish_combo_popup() -> void:
	if not is_instance_valid(_combo_popup_panel):
		return
	var combo_panel := _combo_popup_panel
	if _timer_owner == null or not is_instance_valid(_timer_owner):
		combo_panel.queue_free()
		_combo_popup_panel = null
		_combo_popup_label = null
		return
	_combo_popup_fade_tween = _timer_owner.create_tween()
	_combo_popup_fade_tween.tween_interval(0.18)
	_combo_popup_fade_tween.tween_property(combo_panel, "modulate:a", 0.0, 0.36)
	_combo_popup_fade_tween.finished.connect(func() -> void:
		if is_instance_valid(combo_panel):
			combo_panel.queue_free()
		_combo_popup_panel = null
		_combo_popup_label = null
	)


func _center_combo_popup_position() -> Vector2:
	if _board_surface == null:
		return Vector2.ZERO
	return _board_surface.position + (_board_surface.size - COMBO_POPUP_SIZE) * 0.5


func _wait_duration(seconds: float) -> void:
	if not _can_continue_after_wait():
		return
	var tree := _timer_owner.get_tree()
	if seconds <= 0.01:
		await tree.process_frame
		return
	await tree.create_timer(seconds).timeout


func _can_continue_after_wait() -> bool:
	if _timer_owner == null or not is_instance_valid(_timer_owner):
		return false
	if _timer_owner.get_tree() == null:
		return false
	if _board_view == null or not is_instance_valid(_board_view):
		return false
	return true


func _call_trace(trace_callback: Callable, start_ticks_usec: int, message: String) -> void:
	if trace_callback.is_valid():
		trace_callback.call(start_ticks_usec, message)
