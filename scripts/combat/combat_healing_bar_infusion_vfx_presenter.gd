extends RefCounted
class_name CombatHealingBarInfusionVfxPresenter

const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_EFFECT_FRONT_Z_INDEX := 132
const PANEL_FADE_IN_RATIO := 0.24
const PANEL_FADE_OUT_DELAY_RATIO := 0.62
const PANEL_FADE_OUT_RATIO := 0.38

var _vfx_layer: Control
var _timer_owner: Node


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node


func spawn_bar_infusion(global_center: Vector2, draw_size: Vector2, lifetime: float, result_amount: int, intensity: int, reduced_motion: bool = false) -> void:
	if global_center == Vector2.ZERO:
		return
	var center_local := _global_to_vfx_local(global_center)
	var duration := maxf(0.20, lifetime)
	var bar_width := clampf(draw_size.x, 180.0, 440.0)
	var bar_height := clampf(draw_size.y * 0.24, 22.0, 34.0)
	var lift := Vector2(0.0, -bar_height * 0.03)
	var pulse_size := Vector2(bar_width * 0.96, bar_height * 0.98)
	var soft_line_size := Vector2(bar_width * 0.82, maxf(5.0, bar_height * 0.18))
	_spawn_panel("HealingBarInfusionVisibleBand", center_local + lift, pulse_size, Color(1.0, 0.16, 0.14, 0.32), duration * 0.76, 0.0, Vector2.ZERO, POST_MATCH_EFFECT_FRONT_Z_INDEX + 4)
	_spawn_panel("HealingBarInfusionInnerLine", center_local + lift + Vector2(0.0, -bar_height * 0.10), soft_line_size, Color(1.0, 0.64, 0.46, 0.34), duration * 0.68, duration * 0.02, Vector2.ZERO, POST_MATCH_EFFECT_FRONT_Z_INDEX + 5)
	if reduced_motion:
		return
	var glint_width := clampf(bar_width * 0.25, 64.0, 108.0)
	var glint_travel := Vector2(bar_width * 0.64, 0.0)
	_spawn_panel("HealingBarInfusionGlint", center_local + lift + Vector2(-bar_width * 0.34, -bar_height * 0.02), Vector2(glint_width, maxf(7.0, bar_height * 0.24)), Color(1.0, 0.86, 0.62, 0.56), duration * 0.54, duration * 0.03, glint_travel, POST_MATCH_EFFECT_FRONT_Z_INDEX + 8, Tween.EASE_IN_OUT as Tween.EaseType)


func _spawn_panel(name: String, center_local: Vector2, size: Vector2, color: Color, lifetime: float, delay: float, move_offset: Vector2, z_index: int, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var panel := ColorRect.new()
	panel.name = name
	panel.set_meta("effect_name", name)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	panel.color = color
	panel.size = size
	panel.pivot_offset = size * 0.5
	panel.position = center_local - size * 0.5
	panel.z_index = z_index
	panel.modulate.a = 0.0
	_vfx_layer.add_child(panel)
	_tween_panel_cleanup(panel, maxf(0.12, lifetime), delay, move_offset, move_ease)


func _tween_panel_cleanup(control: Control, lifetime: float, delay: float, move_offset: Vector2, move_ease: Tween.EaseType) -> void:
	if control == null or _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	var fade_in := clampf(lifetime * PANEL_FADE_IN_RATIO, 0.06, 0.16)
	var fade_out := maxf(0.08, lifetime * PANEL_FADE_OUT_RATIO)
	var fade_out_delay := delay + maxf(fade_in, lifetime * PANEL_FADE_OUT_DELAY_RATIO)
	tween.tween_property(control, "modulate:a", 1.0, fade_in).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(control, "position", control.position + move_offset, lifetime).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(move_ease)
	tween.tween_property(control, "modulate:a", 0.0, fade_out).set_delay(fade_out_delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer != null and is_instance_valid(_vfx_layer):
		var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
		return inverse_canvas * global_position
	return global_position
