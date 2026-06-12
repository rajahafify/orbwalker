extends RefCounted
class_name BoardViewOverlayMotion

const MOTION_DROP_OVERSHOOT := "drop_overshoot"


static func overlay_position(from_pos: Vector2, to_pos: Vector2, t: float, motion: String, overshoot_pixels: float) -> Vector2:
	if motion != MOTION_DROP_OVERSHOOT:
		return from_pos.lerp(to_pos, clampf(t, 0.0, 1.0))
	var delta := to_pos - from_pos
	if delta.length_squared() <= 0.01:
		return to_pos
	var direction := delta.normalized()
	var overshoot_distance := minf(maxf(0.0, overshoot_pixels), delta.length() * 0.28 + 10.0)
	var overshoot_pos := to_pos + direction * overshoot_distance
	if t < 0.76:
		var drop_t := _ease_out_cubic(t / 0.76)
		return from_pos.lerp(overshoot_pos, drop_t)
	var settle_t := _ease_out_back((t - 0.76) / 0.24)
	return overshoot_pos.lerp(to_pos, settle_t)


static func overlay_stretch(t: float, motion: String, stretch: float) -> Vector2:
	if motion != MOTION_DROP_OVERSHOOT:
		return Vector2.ONE
	var stretch_amount := clampf(stretch, 0.0, 0.30)
	if t < 0.76:
		var pulse := sin(clampf(t / 0.76, 0.0, 1.0) * PI)
		return Vector2(1.0 - stretch_amount * 0.42 * pulse, 1.0 + stretch_amount * pulse)
	var settle := sin(clampf((t - 0.76) / 0.24, 0.0, 1.0) * PI)
	return Vector2(1.0 + stretch_amount * 0.72 * settle, 1.0 - stretch_amount * 0.52 * settle)


static func _ease_out_cubic(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	return 1.0 - pow(1.0 - clamped, 3.0)


static func _ease_out_back(t: float) -> float:
	var clamped := clampf(t, 0.0, 1.0)
	var c1 := 1.70158
	var c3 := c1 + 1.0
	return 1.0 + c3 * pow(clamped - 1.0, 3.0) + c1 * pow(clamped - 1.0, 2.0)
