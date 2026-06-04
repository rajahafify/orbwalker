extends RefCounted
class_name CombatMaxVfxImportedScenePresenter

var _root_3d: Node3D
var _timer_owner: Node
var _flame_scene_provider: Callable
var _beam_scene_provider: Callable
var _shield_scene_provider: Callable
var _tornado_scene_provider: Callable
var _kind_colors_provider: Callable
var _screen_to_world_position: Callable
var _screen_to_world_offset: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_flame_scene_provider = dependencies.get("flame_scene_provider", Callable())
	_beam_scene_provider = dependencies.get("beam_scene_provider", Callable())
	_shield_scene_provider = dependencies.get("shield_scene_provider", Callable())
	_tornado_scene_provider = dependencies.get("tornado_scene_provider", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())


func spawn_flame_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	var scene := _provided_scene(_flame_scene_provider)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "FlamePackVfx"
	effect.position = _project_position(center_local, z)
	var longest := maxf(draw_size.x, draw_size.y)
	effect.scale = Vector3.ONE * maxf(18.0, longest / 4.4)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_set_node_property_if_present(effect, "autoplay", false)
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "primary_color", Color(1.0, 0.78, 0.28, alpha))
	_set_node_property_if_present(effect, "secondary_color", Color(1.0, 0.20, 0.04, alpha))
	_set_node_property_if_present(effect, "light_color", Color(1.0, 0.58, 0.18, alpha))
	_set_node_property_if_present(effect, "emission", 5.2 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "light_energy", 3.6 + float(intensity) * 0.34)
	_set_node_property_if_present(effect, "particles_amount", mini(96, 34 + intensity * 8))
	_set_node_property_if_present(effect, "lifetime", maxf(0.35, lifetime * 0.58))
	_set_node_property_if_present(effect, "speed_scale", 0.72 + float(intensity) * 0.025)
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.06, 0.0)
	return effect


func spawn_beam_effect(source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float = 0.0, radius_scale: float = 1.0) -> Node3D:
	var scene := _provided_scene(_beam_scene_provider)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "BeamPackVfx_%s" % kind
	effect.position = _project_position(source_local, 2.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	var world_delta := _project_offset(delta)
	if world_delta.length() > 0.1:
		effect.look_at(effect.position + world_delta.normalized(), Vector3.UP)
	var colors := _kind_colors(kind)
	var primary: Color = colors.get("primary", Color.WHITE)
	var secondary: Color = colors.get("secondary", primary)
	var tertiary: Color = colors.get("tertiary", secondary)
	_set_node_property_if_present(effect, "primary_color", primary)
	_set_node_property_if_present(effect, "secondary_color", secondary)
	_set_node_property_if_present(effect, "tertiary_color", tertiary)
	_set_node_property_if_present(effect, "emission", 3.0 + float(intensity) * 0.28)
	_set_node_property_if_present(effect, "beam_length", maxf(4.0, delta.length()))
	_set_node_property_if_present(effect, "beam_radius", (3.0 + float(intensity) * 0.42) * radius_scale)
	_set_node_property_if_present(effect, "start_radius", (10.0 + float(intensity) * 1.4) * radius_scale)
	_set_node_property_if_present(effect, "start_flare", 0.62 + float(intensity) * 0.025)
	_set_node_property_if_present(effect, "pulse_strength", 0.08 + float(intensity) * 0.014)
	_set_node_property_if_present(effect, "start_amount", mini(96, 28 + intensity * 8))
	_set_node_property_if_present(effect, "end_amount", mini(96, 24 + intensity * 7))
	_set_node_property_if_present(effect, "audio_playing", false)
	_set_node_property_if_present(effect, "audio_autoplay", false)
	_set_node_property_if_present(effect, "volume_db", -80.0)
	_set_node_property_if_present(effect, "open_amount", 0.0)
	_animate_beam_node(effect, lifetime, delay)
	return effect


func spawn_shield_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0) -> Node3D:
	var scene := _provided_scene(_shield_scene_provider)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "ShieldPackVfx"
	effect.position = _project_position(center_local, z)
	effect.scale = Vector3(maxf(32.0, draw_size.x * 0.50), maxf(28.0, draw_size.y * 0.50), 1.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_prepare_imported_scene(effect, "")
	_scale_imported_particles(effect, mini(48, 8 + intensity * 4))
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.08, 0.0)
	return effect


func spawn_tornado_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, keep_child_name: String = "") -> Node3D:
	var scene := _provided_scene(_tornado_scene_provider)
	if scene == null:
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	effect.name = "TornadoPackVfx_%s" % keep_child_name
	effect.position = _project_position(center_local, z)
	var longest := maxf(draw_size.x, draw_size.y)
	effect.scale = Vector3.ONE * maxf(10.0, longest / 8.0)
	effect.visible = delay <= 0.0
	_root_3d.add_child(effect)
	_prepare_imported_scene(effect, keep_child_name)
	_scale_imported_particles(effect, mini(70, 18 + intensity * 6))
	_animate_imported_node(effect, lifetime, delay, move_offset, 1.12, 0.0)
	return effect


func _provided_scene(provider: Callable) -> PackedScene:
	if _root_3d == null or not is_instance_valid(_root_3d) or not provider.is_valid():
		return null
	return provider.call() as PackedScene


func _prepare_imported_scene(root: Node3D, keep_child_name: String) -> void:
	for child in root.get_children():
		if child is Camera3D or child is WorldEnvironment:
			child.queue_free()
			continue
		if keep_child_name != "" and child is Node3D:
			child.visible = child.name == keep_child_name
			if child.name == keep_child_name:
				child.position += Vector3(-5.6, 1.0, 3.9)


func _scale_imported_particles(root: Node, amount: int) -> void:
	if root is GPUParticles3D:
		root.amount = amount
		root.emitting = true
	for child in root.get_children():
		_scale_imported_particles(child, amount)


func _animate_imported_node(effect: Node3D, lifetime: float, delay: float, move_offset: Vector2, target_scale: float, spin: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		effect.queue_free()
		return
	var duration := maxf(0.14, lifetime)
	var start_scale := effect.scale
	var start_position := effect.position
	var start_rotation := effect.rotation.z
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_callback(func() -> void:
			if is_instance_valid(effect):
				effect.visible = true
		).set_delay(delay)
	tween.tween_property(effect, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(effect, "position", start_position + _project_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(effect, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.finished.connect(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free()
	)


func _animate_beam_node(effect: Node3D, lifetime: float, delay: float) -> void:
	if effect == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		effect.queue_free()
		return
	var duration := maxf(0.16, lifetime)
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_callback(func() -> void:
			if is_instance_valid(effect):
				effect.visible = true
		).set_delay(delay)
	tween.tween_property(effect, "open_amount", 1.0, duration * 0.28).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(effect, "open_amount", 0.0, duration * 0.34).set_delay(delay + duration * 0.66).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN as Tween.EaseType)
	tween.finished.connect(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free()
	)


func _set_node_property_if_present(node: Object, property_name: String, value: Variant) -> void:
	if node == null:
		return
	for property in node.get_property_list():
		if String(property.get("name", "")) == property_name:
			node.set(property_name, value)
			return


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
