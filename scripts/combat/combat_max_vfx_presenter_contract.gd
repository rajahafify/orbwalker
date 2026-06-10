extends RefCounted
class_name CombatMaxVfxPresenterContract


func bind(_dependencies: Dictionary) -> void:
	pass


func supports_replay_impact(_kind: String, _screen_wide: bool = false) -> bool:
	return false


func spawn_replay_impact(
	_center: Vector2, _kind: String, _draw_size: Vector2, _max_size: float, _base_size: float, _duration: float, _intensity: int, _screen_wide: bool
) -> bool:
	return false
