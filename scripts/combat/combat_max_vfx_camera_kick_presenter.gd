extends RefCounted
class_name CombatMaxVfxCameraKickPresenter

var _camera: Camera3D
var _timer_owner: Node
var _layer_size_provider: Callable
var _screen_to_world_offset: Callable


func bind(dependencies: Dictionary) -> void:
	_camera = dependencies.get("camera") as Camera3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())


func spawn_camera_kick(direction: Vector2, delay: float) -> void:
	if _camera == null or not is_instance_valid(_camera):
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		return
	var layer_size := _vfx_layer_size()
	var base_position := Vector3(layer_size.x * 0.5, layer_size.y * 0.5, 1000.0)
	var clamped_direction := Vector2(clampf(direction.x, -10.0, 10.0), clampf(direction.y, -10.0, 10.0))
	var kick := _project_offset(clamped_direction)
	var tween := _timer_owner.create_tween()
	tween.tween_property(_camera, "position", base_position + kick, 0.045).set_delay(delay)
	tween.tween_property(_camera, "position", base_position, 0.18).set_trans(Tween.TRANS_ELASTIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _project_offset(screen_offset: Vector2) -> Vector3:
	if _screen_to_world_offset.is_valid():
		return _screen_to_world_offset.call(screen_offset)
	return Vector3(screen_offset.x, screen_offset.y, 0.0)
