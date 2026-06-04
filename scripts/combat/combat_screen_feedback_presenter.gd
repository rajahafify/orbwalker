extends RefCounted
class_name CombatScreenFeedbackPresenter

const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const SCREEN_NUDGE_MAX_PIXELS := 24.0
const SCREEN_NUDGE_SECONDS := 0.18
const HIT_STOP_MAX_SECONDS := 0.06

var _vfx_layer: Control
var _timer_owner: Node
var _shake_target: Control
var _reduced_motion := false
var _game_juice_enabled := false
var _game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()
var _screen_nudge_tween: Tween = null


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_shake_target = dependencies.get("shake_target") as Control
	set_reduced_motion_enabled(bool(dependencies.get("reduced_motion", _reduced_motion)))
	set_game_juice_enabled(bool(dependencies.get("game_juice", _game_juice_enabled)))
	if dependencies.has("game_juice_flags"):
		set_game_juice_flags(Dictionary(dependencies.get("game_juice_flags", _game_juice_flags)))


func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion = enabled


func set_game_juice_enabled(enabled: bool) -> void:
	_game_juice_enabled = enabled


func set_game_juice_flags(flags: Dictionary) -> void:
	_game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)


func screen_nudge(intensity: int = 1, source_global: Vector2 = Vector2.ZERO) -> void:
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.SCREEN_NUDGE) or _reduced_motion or _timer_owner == null or not is_instance_valid(_timer_owner):
		return
	var target := _shake_target if _shake_target != null and is_instance_valid(_shake_target) else _vfx_layer
	if target == null or not is_instance_valid(target):
		target = _timer_owner
	if not target is Control:
		return
	var control := target as Control
	var distance := clampf(10.0 + float(maxi(0, intensity)) * 2.4, 0.0, SCREEN_NUDGE_MAX_PIXELS)
	var direction := Vector2.RIGHT
	if source_global != Vector2.ZERO and _vfx_layer != null and is_instance_valid(_vfx_layer):
		var focus := _global_to_vfx_local(source_global)
		var layer_size := _vfx_layer_size()
		var delta := focus - layer_size * 0.5
		if delta.length() > 0.01:
			direction = delta.normalized()
	var start_position := control.position
	if _screen_nudge_tween != null and is_instance_valid(_screen_nudge_tween):
		_screen_nudge_tween.kill()
		control.position = start_position
	_screen_nudge_tween = _timer_owner.create_tween()
	_screen_nudge_tween.tween_property(control, "position", start_position + direction * distance, SCREEN_NUDGE_SECONDS * 0.25).set_trans(Tween.TRANS_SINE as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	_screen_nudge_tween.tween_property(control, "position", start_position - direction * distance * 0.45, SCREEN_NUDGE_SECONDS * 0.28).set_trans(Tween.TRANS_SINE as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	_screen_nudge_tween.tween_property(control, "position", start_position, SCREEN_NUDGE_SECONDS * 0.47).set_trans(Tween.TRANS_SINE as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)


func hit_stop(seconds: float = 0.04) -> void:
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.HIT_STOP) or _reduced_motion:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		return
	var duration := clampf(seconds, 0.0, HIT_STOP_MAX_SECONDS)
	if duration <= 0.0:
		return
	await _timer_owner.get_tree().create_timer(duration).timeout


func _juice_enabled(flag_key: String) -> bool:
	return _game_juice_enabled and bool(_game_juice_flags.get(flag_key, true))


func _vfx_layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var layer_size := _vfx_layer.size
	if layer_size == Vector2.ZERO:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			layer_size = viewport.get_visible_rect().size
	return layer_size


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
