extends RefCounted
class_name CombatMaxVfxSpawnGateway

var _presenters: Dictionary = {}
var _ensure_overlay: Callable
var _pack_available: Callable


func bind(presenters: Dictionary, ensure_overlay: Callable, pack_available: Callable) -> void:
	_presenters = presenters
	_ensure_overlay = ensure_overlay
	_pack_available = pack_available


func callbacks() -> Dictionary:
	return {
		"spawn_atmospheric_flipbook": Callable(self, "spawn_atmospheric_flipbook"),
		"spawn_status_flipbook": Callable(self, "spawn_status_flipbook"),
		"spawn_flame_scene": Callable(self, "spawn_flame_scene"),
		"spawn_beam_effect": Callable(self, "spawn_beam_effect"),
		"spawn_shield_scene": Callable(self, "spawn_shield_scene"),
		"spawn_tornado_scene": Callable(self, "spawn_tornado_scene"),
		"spawn_elemental_effect": Callable(self, "spawn_elemental_effect"),
		"spawn_pack_effect": Callable(self, "spawn_pack_effect"),
		"spawn_pack_layer": Callable(self, "spawn_pack_layer"),
		"stretch_effect": Callable(self, "stretch_effect"),
		"spawn_flipbook": Callable(self, "spawn_flipbook"),
		"spawn_burst_particles": Callable(self, "spawn_burst_particles"),
		"spawn_screen_wide": Callable(self, "spawn_screen_wide"),
		"spawn_coin_rain": Callable(self, "spawn_coin_rain"),
		"spawn_gpu_particles": Callable(self, "spawn_gpu_particles"),
		"spawn_light": Callable(self, "spawn_light"),
		"spawn_camera_kick": Callable(self, "spawn_camera_kick"),
		"queue_free_after": Callable(self, "queue_free_after"),
		"screen_to_world_position": Callable(self, "screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "screen_to_world_offset"),
		"screen_to_world_rotation": Callable(self, "screen_to_world_rotation"),
	}


func spawn_atmospheric_flipbook(
	sheet_key: String,
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	color: Color,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	target_scale: float = 1.0,
	z: float = 0.0,
	rotation: float = 0.0,
	loops: int = 1
) -> Sprite3D:
	if not _overlay_ready():
		return null
	return _presenter("sheet_flipbook").spawn_atmospheric_flipbook(
		sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops
	)


func spawn_status_flipbook(
	sheet_key: String,
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	color: Color,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	target_scale: float = 1.0,
	z: float = 0.0,
	rotation: float = 0.0,
	loops: int = 1,
	spin: float = 0.0
) -> Sprite3D:
	if not _overlay_ready():
		return null
	return _presenter("sheet_flipbook").spawn_status_flipbook(
		sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops, spin
	)


func spawn_flame_scene(
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	z: float = 0.0,
	alpha: float = 1.0
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("imported_scene").spawn_flame_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, alpha)


func spawn_beam_effect(
	source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float = 0.0, radius_scale: float = 1.0
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("imported_scene").spawn_beam_effect(source_local, delta, kind, lifetime, intensity, delay, radius_scale)


func spawn_shield_scene(
	center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("imported_scene").spawn_shield_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z)


func spawn_tornado_scene(
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	z: float = 0.0,
	keep_child_name: String = ""
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("imported_scene").spawn_tornado_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, keep_child_name)


func spawn_elemental_effect(
	scene_key: String,
	center_local: Vector2,
	kind: String,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0,
	z: float = 0.0,
	alpha: float = 1.0
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("elemental_scene").spawn_elemental_effect(
		scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha
	)


func spawn_pack_effect(
	scene_key: String,
	center_local: Vector2,
	kind: String,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	rotation: float = 0.0,
	z: float = 0.0,
	alpha: float = 1.0
) -> Node3D:
	if not _overlay_ready():
		return null
	return _presenter("pack_scene").spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func spawn_pack_layer(
	scene_key: String,
	center_local: Vector2,
	kind: String,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float,
	rotation: float,
	z: float,
	alpha: float
) -> Node3D:
	if _pack_available.is_valid() and not bool(_pack_available.call()):
		return null
	return spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, Vector2.ZERO, rotation, z, alpha)


func stretch_effect(effect: Node3D, stretch: Vector3) -> void:
	_presenter("pack_scene").stretch_effect(effect, stretch)


func spawn_flipbook(
	key: String,
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	color: Color,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	target_scale: float = 1.0,
	z: float = 0.0,
	rotation: float = 0.0,
	spin: float = 0.0
) -> Sprite3D:
	if not _overlay_ready():
		return null
	return _presenter("flipbook").spawn_flipbook(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, spin)


func spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	_presenter("burst_particles").spawn_burst_particles(kind, center, base_size, lifetime, intensity)


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_presenter("screen_wide").spawn_screen_wide(kind, center, lifetime, intensity)


func spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	_presenter("coin_rain").spawn_coin_rain(center, base_size, lifetime, intensity, screen_wide)


func spawn_gpu_particles(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> void:
	_presenter("gpu_particles").spawn_gpu_particles(texture_key, center, amount, color, radius, lifetime, kind)


func spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
	_presenter("light").spawn_light(center, color, energy, radius, lifetime, delay)


func spawn_camera_kick(direction: Vector2, delay: float) -> void:
	_presenter("camera_kick").spawn_camera_kick(direction, delay)


func queue_free_after(node: Node, delay: float) -> void:
	_presenter("cleanup").queue_free_after(node, delay)


func screen_to_world_position(screen_position: Vector2, z: float) -> Vector3:
	return _presenter("projector").screen_to_world_position(screen_position, z)


func screen_to_world_offset(screen_offset: Vector2) -> Vector3:
	return _presenter("projector").screen_to_world_offset(screen_offset)


func screen_to_world_rotation(screen_rotation: float) -> float:
	return _presenter("projector").screen_to_world_rotation(screen_rotation)


func _overlay_ready() -> bool:
	return _ensure_overlay.is_valid() and bool(_ensure_overlay.call())


func _presenter(key: String) -> Variant:
	return _presenters.get(key)
