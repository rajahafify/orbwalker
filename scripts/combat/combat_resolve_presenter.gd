extends RefCounted
class_name CombatResolvePresenter

const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const COMBO_POPUP_FALLBACK_SIZE := Vector2(420.0, 280.0)
const COMBO_POPUP_WORD_BASE_FONT_SIZE := 58
const COMBO_POPUP_WORD_MAX_FONT_SIZE := 104
const COMBO_POPUP_VALUE_BASE_FONT_SIZE := 112
const COMBO_POPUP_VALUE_MAX_FONT_SIZE := 236
const COMBO_COUNT_STEP_SECONDS := 0.22
const CASCADE_PASS_HOLD_SECONDS := 0.16
const ANIMATION_DRAIN_MAX_ITERATIONS := 600
const ANIMATION_DRAIN_MAX_SECONDS := 8.0
const COMBAT_SPEED_SLOW := "slow"
const COMBAT_SPEED_NORMAL := "normal"
const COMBAT_SPEED_FAST := "fast"
const COMBAT_SPEED_INSTANT := "instant"

var _board: Control
var _board_view: BoardView
var _board_panel: Control
var _board_controller: BoardController
var _timer_owner: Node
var _spawn_vfx_texture_callback: Callable
var _combo_sound_callback: Callable
var _combat_speed := COMBAT_SPEED_NORMAL

var _resolve_combo_running := 0
var _match_clear_burst_texture: Texture2D
var _combo_popup_panel: Control
var _combo_popup_word_label: Label
var _combo_popup_label: Label
var _combo_popup_fade_tween: Tween
var _reduced_motion := false


func bind(nodes: Dictionary) -> void:
	_board = nodes.get("board") as Control
	_board_view = nodes.get("board_view") as BoardView
	_board_panel = nodes.get("board_panel") as Control
	_board_controller = nodes.get("board_controller") as BoardController
	_timer_owner = nodes.get("timer_owner") as Node
	_spawn_vfx_texture_callback = nodes.get("spawn_vfx_texture_callback", Callable())
	_combo_sound_callback = nodes.get("combo_sound_callback", Callable())


func set_combat_speed(speed: String) -> void:
	match speed:
		COMBAT_SPEED_INSTANT, COMBAT_SPEED_FAST, COMBAT_SPEED_NORMAL, COMBAT_SPEED_SLOW:
			_combat_speed = speed
		_:
			_combat_speed = COMBAT_SPEED_NORMAL


func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion = enabled


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
	visual_board_model: BoardModel = null,
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
			visual_board_model,
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
		_apply_visual_fall_moves(visual_board_model, pass_result.fall_moves)
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
		_apply_visual_refill_spawns(visual_board_model, pass_result.refill_spawns)
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
	visual_board_model: BoardModel,
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
		_apply_visual_clear_groups(visual_board_model, one_group)
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
		return Vector2i(BoardModel.COLUMN_COUNT, BoardModel.ROW_COUNT)

	var min_row := BoardModel.ROW_COUNT
	var min_column := BoardModel.COLUMN_COUNT
	for cell in cells:
		var typed_cell: Vector2i = cell
		if typed_cell.y < min_row:
			min_row = typed_cell.y
			min_column = typed_cell.x
		elif typed_cell.y == min_row:
			min_column = mini(min_column, typed_cell.x)
	return Vector2i(min_column, min_row)


func _apply_visual_clear_groups(visual_board_model: BoardModel, groups: Array) -> void:
	if visual_board_model == null or _board_controller == null:
		return
	_board_controller.apply_visual_clear_groups(visual_board_model, groups)


func _apply_visual_fall_moves(visual_board_model: BoardModel, fall_moves: Array) -> void:
	if visual_board_model == null or _board_controller == null:
		return
	_board_controller.apply_visual_fall_moves(visual_board_model, fall_moves)


func _apply_visual_refill_spawns(visual_board_model: BoardModel, refill_spawns: Array) -> void:
	if visual_board_model == null or _board_controller == null:
		return
	_board_controller.apply_visual_refill_spawns(visual_board_model, refill_spawns)


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
		if not _reduced_motion:
			var combo_scale := 1.0 + float(maxi(0, _resolve_combo_running)) * 0.08
			var group_scale := 1.0 + float(maxi(0, matched_count - 3)) * 0.05
			burst_size *= minf(1.55, combo_scale * group_scale)
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
	var combo_text := "x%d" % combo_value

	var combo_panel := _ensure_combo_popup_panel()
	if combo_panel == null or _combo_popup_word_label == null or _combo_popup_label == null:
		return
	var popup_rect := _combo_popup_rect()
	combo_panel.position = popup_rect.position
	combo_panel.size = popup_rect.size
	combo_panel.custom_minimum_size = popup_rect.size
	combo_panel.modulate.a = 1.0
	_combo_popup_word_label.text = "COMBO"
	_combo_popup_label.text = combo_text
	_layout_combo_popup_labels(combo_value, popup_rect.size)
	if _combo_popup_fade_tween != null and _combo_popup_fade_tween.is_valid():
		_combo_popup_fade_tween.kill()

	combo_panel.pivot_offset = combo_panel.size * 0.5
	combo_panel.scale = Vector2(1.0, 1.0)
	var pulse_scale := 1.0 if _reduced_motion else 1.0 + minf(0.22, float(combo_value) * 0.018)
	if _timer_owner != null and is_instance_valid(_timer_owner):
		var pop_tween := _timer_owner.create_tween()
		pop_tween.tween_property(combo_panel, "scale", Vector2(pulse_scale, pulse_scale), 0.07).set_trans(Tween.TRANS_BACK as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
		pop_tween.tween_property(combo_panel, "scale", Vector2(1.0, 1.0), 0.10).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)


func _ensure_combo_popup_panel() -> Control:
	if is_instance_valid(_combo_popup_panel):
		return _combo_popup_panel
	if not _can_continue_after_wait() or _board_panel == null:
		return null
	var combo_panel := Control.new()
	combo_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	combo_panel.size = _combo_popup_rect().size
	combo_panel.custom_minimum_size = combo_panel.size
	combo_panel.z_index = 80

	var combo_word_label := Label.new()
	combo_word_label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	combo_word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	combo_word_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	combo_word_label.add_theme_font_size_override("font_size", COMBO_POPUP_WORD_BASE_FONT_SIZE)
	combo_word_label.add_theme_constant_override("outline_size", 8)
	combo_word_label.add_theme_color_override("font_outline_color", Color(0.05, 0.015, 0.0, 0.98))
	combo_word_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.18, 1.0))
	combo_word_label.position = Vector2.ZERO
	combo_word_label.size = combo_panel.size

	var combo_label := Label.new()
	combo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	combo_label.add_theme_font_size_override("font_size", COMBO_POPUP_VALUE_BASE_FONT_SIZE)
	combo_label.add_theme_constant_override("outline_size", 12)
	combo_label.add_theme_color_override("font_outline_color", Color(0.06, 0.018, 0.0, 1.0))
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.48, 1.0))
	combo_label.position = Vector2.ZERO
	combo_label.size = combo_panel.size
	combo_panel.add_child(combo_word_label)
	combo_panel.add_child(combo_label)
	_board_panel.add_child(combo_panel)
	_combo_popup_panel = combo_panel
	_combo_popup_word_label = combo_word_label
	_combo_popup_label = combo_label
	return combo_panel


func _finish_combo_popup() -> void:
	if not is_instance_valid(_combo_popup_panel):
		return
	var combo_panel := _combo_popup_panel
	if _timer_owner == null or not is_instance_valid(_timer_owner):
		combo_panel.queue_free()
		_combo_popup_panel = null
		_combo_popup_word_label = null
		_combo_popup_label = null
		return
	_combo_popup_fade_tween = _timer_owner.create_tween()
	_combo_popup_fade_tween.tween_interval(0.18)
	_combo_popup_fade_tween.tween_property(combo_panel, "modulate:a", 0.0, 0.36)
	_combo_popup_fade_tween.finished.connect(func() -> void:
		if is_instance_valid(combo_panel):
			combo_panel.queue_free()
		_combo_popup_panel = null
		_combo_popup_word_label = null
		_combo_popup_label = null
	)


func _combo_popup_rect() -> Rect2:
	if _board == null:
		return Rect2(Vector2.ZERO, COMBO_POPUP_FALLBACK_SIZE)
	return Rect2(_board.position, _board.size)


func _layout_combo_popup_labels(combo_value: int, popup_size: Vector2) -> void:
	if _combo_popup_word_label == null or _combo_popup_label == null:
		return
	var safe_size := Vector2(maxf(1.0, popup_size.x), maxf(1.0, popup_size.y))
	var word_font_size := _fit_combo_font_size(
		"COMBO",
		Vector2(safe_size.x * 0.92, safe_size.y * 0.26),
		mini(COMBO_POPUP_WORD_MAX_FONT_SIZE, COMBO_POPUP_WORD_BASE_FONT_SIZE + maxi(0, combo_value - 1) * 4),
		34
	)
	var value_text := "x%d" % combo_value
	var value_font_size := _fit_combo_font_size(
		value_text,
		Vector2(safe_size.x * 0.94, safe_size.y * 0.42),
		mini(COMBO_POPUP_VALUE_MAX_FONT_SIZE, COMBO_POPUP_VALUE_BASE_FONT_SIZE + maxi(0, combo_value - 1) * 12),
		64
	)
	var word_height := _combo_line_height(word_font_size)
	var value_height := _combo_line_height(value_font_size)
	var label_overlap := minf(value_height * 0.34, maxf(24.0, safe_size.y * 0.12))
	var stack_height := word_height + value_height - label_overlap
	var stack_top := safe_size.y * 0.52 - stack_height * 0.5
	var word_rect := Rect2(Vector2(0.0, stack_top), Vector2(safe_size.x, word_height))
	var value_rect := Rect2(Vector2(0.0, stack_top + word_height - label_overlap), Vector2(safe_size.x, value_height))
	_combo_popup_word_label.position = word_rect.position
	_combo_popup_word_label.size = word_rect.size
	_combo_popup_word_label.add_theme_font_size_override("font_size", word_font_size)
	_combo_popup_label.position = value_rect.position
	_combo_popup_label.size = value_rect.size
	_combo_popup_label.add_theme_font_size_override("font_size", value_font_size)


func _fit_combo_font_size(text: String, target_size: Vector2, desired_size: int, minimum_size: int) -> int:
	var font := _combo_popup_font()
	if font == null:
		return desired_size
	var target_width := maxf(1.0, target_size.x)
	var target_height := maxf(1.0, target_size.y)
	for font_size in range(maxi(minimum_size, desired_size), minimum_size - 1, -2):
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1.0, font_size)
		var text_height := font.get_height(font_size)
		if text_size.x <= target_width and text_height <= target_height:
			return font_size
	return minimum_size


func _combo_line_height(font_size: int) -> float:
	var font := _combo_popup_font()
	if font == null:
		return float(font_size) * 1.2
	return maxf(float(font_size), font.get_height(font_size))


func _combo_popup_font() -> Font:
	if _combo_popup_label != null and is_instance_valid(_combo_popup_label):
		var label_font := _combo_popup_label.get_theme_font("font")
		if label_font != null:
			return label_font
	if _board_panel != null and is_instance_valid(_board_panel):
		return _board_panel.get_theme_default_font()
	if _board != null and is_instance_valid(_board):
		return _board.get_theme_default_font()
	return null


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
