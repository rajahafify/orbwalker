extends RefCounted
class_name CombatMaxVfxLightPresenter

var _root_3d: Node3D
var _timer_owner: Node
var _screen_to_world_position: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())


func spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> OmniLight3D:
	if _root_3d == null or not is_instance_valid(_root_3d):
		return null
	if delay > 0.0:
		if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
			return null
		var delayed_tween := _timer_owner.create_tween()
		delayed_tween.tween_interval(delay)
		delayed_tween.finished.connect(func() -> void:
			spawn_light(center, color, energy, radius, lifetime)
		)
		return null
	var light := OmniLight3D.new()
	light.name = "MaxVfxLight"
	light.position = _project_position(center, 90.0)
	light.light_color = color
	light.light_energy = energy
	light.omni_range = maxf(64.0, radius)
	_root_3d.add_child(light)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or _timer_owner.get_tree() == null:
		light.queue_free()
		return light
	var tween := _timer_owner.create_tween()
	tween.tween_property(light, "light_energy", 0.0, maxf(0.08, lifetime)).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.finished.connect(func() -> void:
		if is_instance_valid(light):
			light.queue_free()
	)
	return light


func _project_position(center: Vector2, z: float) -> Vector3:
	if _screen_to_world_position.is_valid():
		return _screen_to_world_position.call(center, z)
	return Vector3(center.x, center.y, z)
