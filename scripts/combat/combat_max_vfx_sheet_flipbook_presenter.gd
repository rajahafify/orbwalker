extends RefCounted
class_name CombatMaxVfxSheetFlipbookPresenter

const STATUS_FRAMES := 16
const STATUS_GRID_COLUMNS := 4
const STATUS_GRID_ROWS := 4
const ATMOSPHERIC_FRAMES := 48

var _root_3d: Node3D
var _timer_owner: Node
var _status_texture_provider: Callable
var _atmospheric_texture_provider: Callable
var _screen_to_world_position: Callable
var _screen_to_world_offset: Callable
var _screen_to_world_rotation: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_status_texture_provider = dependencies.get("status_texture_provider", Callable())
	_atmospheric_texture_provider = dependencies.get("atmospheric_texture_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_screen_to_world_offset = dependencies.get("screen_to_world_offset", Callable())
	_screen_to_world_rotation = dependencies.get("screen_to_world_rotation", Callable())


func spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1) -> Sprite3D:
	if _root_3d == null or not is_instance_valid(_root_3d) or not _atmospheric_texture_provider.is_valid():
		return null
	var texture: Texture2D = _atmospheric_texture_provider.call(sheet_key)
	if texture == null:
		return null
	var sprite := _spawn_sprite("AtmosphericVfx_%s" % sheet_key, texture, ATMOSPHERIC_FRAMES, 1, center_local, draw_size, color, delay, z, rotation)
	_tween_sheet_sprite3d(sprite, lifetime, target_scale, delay, move_offset, 0.0, color.a, maxi(1, loops), ATMOSPHERIC_FRAMES, 0.08, 0.42)
	return sprite


func spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1, spin: float = 0.0) -> Sprite3D:
	if _root_3d == null or not is_instance_valid(_root_3d) or not _status_texture_provider.is_valid():
		return null
	var texture: Texture2D = _status_texture_provider.call(sheet_key)
	if texture == null:
		return null
	var sprite := _spawn_sprite("StatusVfx_%s" % sheet_key, texture, STATUS_GRID_COLUMNS, STATUS_GRID_ROWS, center_local, draw_size, color, delay, z, rotation)
	_tween_sheet_sprite3d(sprite, lifetime, target_scale, delay, move_offset, spin, color.a, maxi(1, loops), STATUS_FRAMES, 0.06, 0.44)
	return sprite


func _spawn_sprite(name: String, texture: Texture2D, hframes: int, vframes: int, center_local: Vector2, draw_size: Vector2, color: Color, delay: float, z: float, rotation: float) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.name = name
	sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = 0
	sprite.centered = true
	sprite.pixel_size = 1.0
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	var cell_size := Vector2(float(texture.get_width()) / float(hframes), float(texture.get_height()) / float(vframes))
	sprite.scale = Vector3(draw_size.x / cell_size.x, draw_size.y / cell_size.y, 1.0)
	sprite.position = _project_position(center_local, z)
	sprite.rotation = Vector3(0.0, 0.0, _project_rotation(rotation))
	_root_3d.add_child(sprite)
	return sprite


func _tween_sheet_sprite3d(sprite: Sprite3D, lifetime: float, target_scale: float, delay: float, move_offset: Vector2, spin: float, target_alpha: float, loops: int, frame_count: int, fade_in_seconds: float, fade_out_ratio: float) -> void:
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
		tween.tween_property(sprite, "modulate:a", target_alpha, fade_in_seconds).set_delay(delay)
	var total_frames := frame_count * maxi(1, loops) - 1
	tween.tween_method(func(value: float) -> void:
		if is_instance_valid(sprite):
			sprite.frame = int(floor(value)) % frame_count
	, 0.0, float(total_frames), duration).set_delay(delay)
	tween.tween_property(sprite, "scale", start_scale * target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(sprite, "position", start_position + _project_offset(move_offset), duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	if not is_zero_approx(spin):
		tween.tween_property(sprite, "rotation:z", start_rotation - spin, duration).set_delay(delay)
	tween.tween_property(sprite, "modulate:a", 0.0, duration * fade_out_ratio).set_delay(delay + duration * 0.58)
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
