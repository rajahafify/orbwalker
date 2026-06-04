extends RefCounted
class_name CombatMaxVfxProjector

var _layer_size_provider: Callable


func bind(dependencies: Dictionary) -> void:
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())


func screen_to_world_position(screen_position: Vector2, z: float) -> Vector3:
	var layer_size := _vfx_layer_size()
	return Vector3(screen_position.x, layer_size.y - screen_position.y, z)


func screen_to_world_offset(screen_offset: Vector2) -> Vector3:
	return Vector3(screen_offset.x, -screen_offset.y, 0.0)


func screen_to_world_rotation(screen_rotation: float) -> float:
	return -screen_rotation


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO
