extends RefCounted
class_name CombatTimerDisplayPresenter

const MOVE_TIMER_MAX_SECONDS := 5.0
const TIMER_WARNING_SECONDS := 2.0
const TIMER_CRITICAL_SECONDS := 1.0
const TIMER_SAFE_COLOR := Color(0.60, 0.90, 1.0, 1.0)
const TIMER_WARNING_COLOR := Color(1.0, 0.82, 0.36, 1.0)
const TIMER_CRITICAL_COLOR := Color(1.0, 0.42, 0.38, 1.0)
const TIMER_READY_COLOR := Color(0.30, 0.56, 0.72, 1.0)
const TIMER_LOCKED_COLOR := Color(0.22, 0.24, 0.28, 1.0)
const TIMER_TEXT_COLOR := Color(0.96, 0.98, 1.0, 1.0)
const TIMER_TEXT_WARNING_COLOR := Color(1.0, 0.94, 0.68, 1.0)
const TIMER_TEXT_CRITICAL_COLOR := Color(1.0, 0.88, 0.84, 1.0)
const TIMER_TEXT_LOCKED_COLOR := Color(0.68, 0.72, 0.78, 1.0)
const TIMER_TRACK_SIZE := Vector2(720, 36)
const TIMER_TRACK_PADDING := 5.0
const STATE_ACTIVE := "active"
const STATE_LOCKED := "locked"


static func display_snapshot(seconds_left: float, state: String, track_size: Vector2 = Vector2.ZERO, ticks_msec: int = -1) -> Dictionary:
	var clamped_seconds := clampf(seconds_left, 0.0, MOVE_TIMER_MAX_SECONDS)
	var time_ratio := 0.0
	if MOVE_TIMER_MAX_SECONDS > 0.0:
		time_ratio = clamped_seconds / MOVE_TIMER_MAX_SECONDS

	var label_text := "READY"
	var state_text := "READY"
	var timer_color := TIMER_READY_COLOR
	var text_color := TIMER_TEXT_COLOR
	var fill_ratio := 0.0
	var show_fill := false
	var text_alpha := 1.0
	if state == STATE_ACTIVE:
		show_fill = true
		fill_ratio = time_ratio
		state_text = "MOVE"
		if clamped_seconds > 0.0 and clamped_seconds < TIMER_WARNING_SECONDS:
			label_text = "%.1f SEC" % clamped_seconds
		else:
			label_text = "%d SEC" % int(ceil(clamped_seconds))
		timer_color = TIMER_SAFE_COLOR
		if clamped_seconds <= TIMER_CRITICAL_SECONDS:
			state_text = "CRIT"
			var blink := 0.70 + 0.30 * sin(_resolved_ticks_msec(ticks_msec) * 0.024)
			timer_color = TIMER_CRITICAL_COLOR.lerp(Color(1.0, 1.0, 1.0, 1.0), blink)
			text_color = TIMER_TEXT_CRITICAL_COLOR
			text_alpha = blink
		elif clamped_seconds <= TIMER_WARNING_SECONDS:
			state_text = "WARN"
			var warning_t := inverse_lerp(TIMER_WARNING_SECONDS, TIMER_CRITICAL_SECONDS, clamped_seconds)
			timer_color = TIMER_WARNING_COLOR.lerp(TIMER_CRITICAL_COLOR, warning_t)
			text_color = TIMER_TEXT_WARNING_COLOR
	elif state == STATE_LOCKED:
		label_text = "LOCK"
		state_text = ""
		timer_color = TIMER_LOCKED_COLOR
		text_color = TIMER_TEXT_LOCKED_COLOR
		text_alpha = 0.72

	var resolved_track_size := track_size
	if resolved_track_size.x <= 0.0 or resolved_track_size.y <= 0.0:
		resolved_track_size = TIMER_TRACK_SIZE
	var fill_width := maxf(0.0, (resolved_track_size.x - TIMER_TRACK_PADDING * 2.0) * fill_ratio)
	var final_text_color := Color(text_color.r, text_color.g, text_color.b, text_alpha)
	return {
		"label_text": label_text,
		"state_text": state_text,
		"fill_position": Vector2(TIMER_TRACK_PADDING, TIMER_TRACK_PADDING),
		"fill_size": Vector2(fill_width, maxf(0.0, resolved_track_size.y - TIMER_TRACK_PADDING * 2.0)),
		"fill_color": Color(timer_color.r, timer_color.g, timer_color.b, 0.72 if show_fill else 0.0),
		"fill_visible": show_fill,
		"text_color": final_text_color,
	}


static func apply_to_nodes(nodes: Dictionary, seconds_left: float, state: String) -> void:
	var timer_track := nodes.get("timer_track") as Control
	var track_size := timer_track.size if timer_track != null else TIMER_TRACK_SIZE
	var snapshot := display_snapshot(seconds_left, state, track_size)
	var timer_fill := nodes.get("timer_fill") as ColorRect
	if timer_fill != null:
		timer_fill.position = snapshot.get("fill_position", Vector2.ZERO)
		timer_fill.size = snapshot.get("fill_size", Vector2.ZERO)
		timer_fill.color = snapshot.get("fill_color", Color.TRANSPARENT)
		timer_fill.visible = bool(snapshot.get("fill_visible", false))
	var timer_label := nodes.get("timer_label") as Label
	if timer_label != null:
		timer_label.text = String(snapshot.get("label_text", ""))
		timer_label.add_theme_color_override("font_color", snapshot.get("text_color", TIMER_TEXT_COLOR))
	var timer_state_label := nodes.get("timer_state_label") as Label
	if timer_state_label != null:
		timer_state_label.text = String(snapshot.get("state_text", ""))
		timer_state_label.add_theme_color_override("font_color", snapshot.get("text_color", TIMER_TEXT_COLOR))
	var timer_icon := nodes.get("timer_icon") as CanvasItem
	if timer_icon != null:
		timer_icon.modulate = snapshot.get("text_color", TIMER_TEXT_COLOR)


static func _resolved_ticks_msec(ticks_msec: int) -> int:
	if ticks_msec >= 0:
		return ticks_msec
	return Time.get_ticks_msec()
