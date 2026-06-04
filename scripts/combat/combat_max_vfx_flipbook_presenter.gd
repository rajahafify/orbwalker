extends RefCounted
class_name CombatMaxVfxFlipbookPresenter

const PRIMARY_FRAMES := 16
const GRID_COLUMNS := 4
const GRID_ROWS := 4

var _root_3d: Node3D
var _timer_owner: Node
var _texture_provider: Callable
var _screen_to_world_position: Callable
var _screen_to_world_offset: Callable
var _screen_to_world_rotation: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_texture_provider = dependencies.get("texture_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())
	_screen_to_world_rotation = dependencies.get("screen_to_world_rotation", Callable())


func spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, spin: float = 0.0) -> Sprite3D:
	if _root_3d == null or not is_instance_valid(_root_3d):
		return null
	if not _texture_provider.is_valid():
		return null
	var texture: Texture2D = _texture_provider.call(key)
	if texture == null:
		return null
	var sprite := Sprite3D.new()
	sprite.name = "MaxVfx_%s" % key
	sprite.texture = texture
	sprite.hframes = GRID_COLUMNS
	sprite.vframes = GRID_ROWS
	sprite.frame = 0
	sprite.centered = true
	sprite.pixel_size = 1.0
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	var cell_size := Vector2(float(texture.get_width()) / float(GRID_COLUMNS), float(texture.get_height()) / float(GRID_ROWS))
	sprite.scale = Vector3(draw_size.x / cell_size.x, draw_size.y / cell_size.y, 1.0)
	sprite.position = _project_position(center_local, z)
	sprite.rotation = Vector3(0.0, 0.0, _project_rotation(rotation))
	_root_3d.add_child(sprite)
	_tween_sprite3d(sprite, lifetime, target_scale, delay, move_offset, spin, color.a)
	return sprite


func _tween_sprite3d(sprite: Sprite3D, lifetime: float, target_scale: float, delay: float, move_offset: Vector2, spin: float, target_alpha: float) -> void:
	if sprite == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		sprite.queue_free()
		return
	var start_scale := sprite.scale
	var start_position := sprite.position
	var start_rotation := sprite.rotation.z
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(sprite, "modulate:a", target_alpha, 0.04).set_delay(delay)
	tween.tween_method(func(value: float) -> void:
		if is_instance_valid(sprite):
			sprite.frame = clampi(int(round(value)), 0, PRIMARY_FRAMES - 1)
	, 0.0, float(PRIMARY_FRAMES - 1), duration).set_delay(delay)
	tween.tween_property(sprite, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(sprite, "position", start_position + _project_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(sprite, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 0.0, duration * 0.45).set_delay(delay + duration * 0.55)
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


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
