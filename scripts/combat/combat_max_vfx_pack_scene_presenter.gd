extends RefCounted
class_name CombatMaxVfxPackScenePresenter

var _root_3d: Node3D
var _timer_owner: Node
var _pack_scene_provider: Callable
var _kind_colors_provider: Callable
var _screen_to_world_position: Callable
var _screen_to_world_offset: Callable
var _screen_to_world_rotation: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_pack_scene_provider = dependencies.get("pack_scene_provider", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())
	_screen_to_world_rotation = dependencies.get("screen_to_world_rotation", Callable())


func spawn_pack_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if _root_3d == null or not is_instance_valid(_root_3d) or not _pack_scene_provider.is_valid():
		return null
	var scene: PackedScene = _pack_scene_provider.call(scene_key)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "PackVfx_%s_%s" % [kind, scene_key]
	effect.position = _project_position(center_local, z)
	effect.rotation = Vector3(0.0, 0.0, _project_rotation(rotation))
	effect.scale = Vector3.ONE * pack_scale_from_size(draw_size, intensity)
	effect.visible = delay <= 0.0
	_configure_pack_effect(effect, kind, intensity, alpha)
	_root_3d.add_child(effect)
	if effect.has_signal("finished"):
		effect.finished.connect(func() -> void:
			if is_instance_valid(effect):
				effect.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		_queue_free_after(effect, delay + maxf(0.35, lifetime) + 0.40)
	_schedule_pack_play(effect, delay)
	if move_offset != Vector2.ZERO and _timer_owner != null and is_instance_valid(_timer_owner) and _timer_owner.is_inside_tree():
		var tween := _timer_owner.create_tween()
		tween.tween_property(effect, "position", effect.position + _project_offset(move_offset), maxf(0.10, lifetime)).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	return effect


func stretch_effect(effect: Node3D, stretch: Vector3) -> void:
	if is_instance_valid(effect):
		effect.scale = Vector3(effect.scale.x * stretch.x, effect.scale.y * stretch.y, effect.scale.z * stretch.z)


func pack_scale_from_size(draw_size: Vector2, intensity: int) -> float:
	var longest := maxf(draw_size.x, draw_size.y)
	return maxf(12.0, longest / 6.0) * (1.0 + float(intensity) * 0.025)


func _schedule_pack_play(effect: Node3D, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		_play_pack_effect(effect)
		return
	if delay <= 0.0:
		_play_pack_effect(effect)
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func() -> void:
		_play_pack_effect(effect)
	)


func _play_pack_effect(effect: Node3D) -> void:
	if not is_instance_valid(effect):
		return
	effect.visible = true
	if effect.has_method("play"):
		effect.call("play")


func _configure_pack_effect(effect: Node3D, kind: String, intensity: int, alpha: float) -> void:
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var primary := Color(core.r, core.g, core.b, alpha)
	var secondary := Color(accent.r, accent.g, accent.b, alpha)
	_set_node_property_if_present(effect, "one_shot", true)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "speed_scale", 0.86 + float(intensity) * 0.025)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "light_color", primary)
	_set_node_property_if_present(effect, "emission", 2.5 + float(intensity) * 0.25)
	_set_node_property_if_present(effect, "light_energy", 3.0 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_indirect_energy", 0.3)
	_set_node_property_if_present(effect, "light_volumetric_fog_energy", 0.15)
	_set_node_property_if_present(effect, "volume_db", -80.0)


func _set_node_property_if_present(node: Object, property_name: String, value: Variant) -> void:
	if node == null:
		return
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			node.set(property_name, value)
			return


func _queue_free_after(node: Node, delay: float) -> void:
	if node == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		node.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(maxf(0.05, delay))
	tween.finished.connect(func() -> void:
		if is_instance_valid(node):
			node.queue_free()
	)


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _project_position(screen_position: Vector2, z: float) -> Vector3:
	if _screen_to_world_position.is_valid():
		return _screen_to_world_position.call(screen_position, z)
	return Vector3(screen_position.x, screen_position.y, z)


func _project_offset(screen_offset: Vector2) -> Vector3:
	if _screen_to_world_offset.is_valid():
		return _screen_to_world_offset.call(screen_offset)
	return Vector3(screen_offset.x, screen_offset.y, 0.0)


func _project_rotation(screen_rotation: float) -> float:
	if _screen_to_world_rotation.is_valid():
		return _screen_to_world_rotation.call(screen_rotation)
	return screen_rotation
