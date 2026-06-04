extends RefCounted
class_name CombatMaxVfxElementalScenePresenter

var _root_3d: Node3D
var _timer_owner: Node
var _elemental_scene_provider: Callable
var _elemental_kind_colors_provider: Callable
var _screen_to_world_position: Callable
var _screen_to_world_offset: Callable
var _screen_to_world_rotation: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_elemental_scene_provider = dependencies.get("elemental_scene_provider", Callable())
	_elemental_kind_colors_provider = dependencies.get("elemental_kind_colors_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())
	_screen_to_world_rotation = dependencies.get("screen_to_world_rotation", Callable())


func spawn_elemental_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if _root_3d == null or not is_instance_valid(_root_3d) or not _elemental_scene_provider.is_valid():
		return null
	var scene: PackedScene = _elemental_scene_provider.call(scene_key)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "ElementalVfx_%s_%s" % [kind, scene_key]
	effect.position = _project_position(center_local, z)
	effect.rotation = Vector3(0.0, 0.0, _project_rotation(rotation))
	effect.scale = Vector3.ONE * elemental_scale_from_size(draw_size, scene_key, intensity)
	effect.visible = delay <= 0.0
	_configure_elemental_effect(effect, scene_key, kind, intensity, alpha, lifetime)
	_root_3d.add_child(effect)
	if effect.has_signal("finished"):
		effect.finished.connect(func() -> void:
			if is_instance_valid(effect):
				effect.queue_free()
		, CONNECT_ONE_SHOT)
	else:
		_queue_free_after(effect, delay + maxf(0.35, lifetime) + 0.55)
	if scene_key != "cast":
		_schedule_elemental_stop(effect, delay + maxf(0.18, lifetime * 0.78))
	_schedule_elemental_play(effect, scene_key, delay)
	if move_offset != Vector2.ZERO and _timer_owner != null and is_instance_valid(_timer_owner) and _timer_owner.is_inside_tree():
		var tween := _timer_owner.create_tween()
		tween.tween_property(effect, "position", effect.position + _project_offset(move_offset), maxf(0.10, lifetime)).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	return effect


func elemental_scale_from_size(draw_size: Vector2, scene_key: String, intensity: int) -> float:
	var longest := maxf(draw_size.x, draw_size.y)
	var divisor := 6.4
	match scene_key:
		"projectile":
			divisor = 5.2
		"area":
			divisor = 5.0
		"cast":
			divisor = 7.0
	return maxf(8.0, longest / divisor) * (1.0 + float(intensity) * 0.030)


func _configure_elemental_effect(effect: Node3D, scene_key: String, kind: String, intensity: int, alpha: float, lifetime: float) -> void:
	var colors := _elemental_kind_colors(kind)
	var primary_base: Color = colors.get("primary", Color.WHITE)
	var secondary_base: Color = colors.get("secondary", Color.WHITE)
	var tertiary_base: Color = colors.get("tertiary", secondary_base)
	var primary := Color(primary_base.r, primary_base.g, primary_base.b, alpha)
	var secondary := Color(secondary_base.r, secondary_base.g, secondary_base.b, alpha)
	var tertiary := Color(tertiary_base.r, tertiary_base.g, tertiary_base.b, alpha)
	_set_node_property_if_present(effect, "one_shot", true)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "audio_autoplay", false)
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "speed_scale", 0.68 + float(intensity) * 0.018)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "tertiary_color", tertiary)
	_set_node_property_if_present(effect, "light_color", primary)
	_set_node_property_if_present(effect, "emission", 2.6 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_energy", 3.2 + float(intensity) * 0.42)
	_set_node_property_if_present(effect, "light_indirect_energy", 0.42)
	_set_node_property_if_present(effect, "light_volumetric_fog_energy", 0.16)
	_set_node_property_if_present(effect, "particles_amount", mini(144, 48 + intensity * 11))
	_set_node_property_if_present(effect, "lifetime", maxf(0.22, lifetime * 0.55))
	if scene_key == "area":
		_set_node_property_if_present(effect, "area_radius", 1.34 + float(intensity) * 0.10)
		_set_node_property_if_present(effect, "explosiveness", 0.18 + float(intensity) * 0.035)
	elif scene_key == "projectile":
		_set_node_property_if_present(effect, "tail_length", 0.74 + float(intensity) * 0.018)
		_set_node_property_if_present(effect, "spiral_amount", 0.32 + float(intensity) * 0.025)
		_set_node_property_if_present(effect, "spiral_count", 5 + mini(intensity, 6))
		_set_node_property_if_present(effect, "wave_speed", 0.72 + float(intensity) * 0.06)
	if scene_key != "cast":
		_set_node_property_if_present(effect, "emitting", false)


func _schedule_elemental_play(effect: Node3D, scene_key: String, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		_play_elemental_effect(effect, scene_key)
		return
	if delay <= 0.0:
		_play_elemental_effect(effect, scene_key)
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(delay)
	tween.tween_callback(func() -> void:
		_play_elemental_effect(effect, scene_key)
	)


func _play_elemental_effect(effect: Node3D, scene_key: String) -> void:
	if not is_instance_valid(effect):
		return
	effect.visible = true
	if scene_key == "cast" and effect.has_method("play"):
		effect.call("play")
		return
	_set_node_property_if_present(effect, "emitting", true)
	if effect.has_method("open"):
		effect.call("open")


func _schedule_elemental_stop(effect: Node3D, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(maxf(0.05, delay))
	tween.tween_callback(func() -> void:
		if is_instance_valid(effect):
			_set_node_property_if_present(effect, "emitting", false)
	)


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


func _elemental_kind_colors(kind: String) -> Dictionary:
	if _elemental_kind_colors_provider.is_valid():
		return _elemental_kind_colors_provider.call(kind)
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
