extends RefCounted
class_name CombatMaxVfxBurstParticlesPresenter

var _kind_colors_provider: Callable
var _particle_key_provider: Callable
var _flipbook_spawner: Callable
var _gpu_particles_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_particle_key_provider = dependencies.get("particle_key_provider", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_gpu_particles_spawner = dependencies.get("gpu_particles_spawner", Callable())


func spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var particle_key := _particle_key(kind)
	var count := 18 + intensity * 7
	for i in range(count):
		var angle := TAU * float(i) / float(count) + sin(float(i) * 1.37) * 0.32
		var dist := base_size * (0.34 + float(i % 5) * 0.045 + float(intensity) * 0.025)
		var start := center + Vector2(cos(angle), sin(angle)) * base_size * 0.10
		var travel := Vector2(cos(angle), sin(angle) - (0.20 if kind in ["fire", "heal", "gold"] else 0.0)) * dist
		var color := core if i % 3 == 0 else accent
		var size := Vector2(34 + intensity * 3, 34 + intensity * 3)
		if particle_key in ["ice_shards", "stone_chunks", "light_rays"]:
			size = Vector2(42 + intensity * 5, 76 + intensity * 6)
		_spawn_flipbook(particle_key, start, size, lifetime * (0.54 + float(i % 4) * 0.035), Color(color.r, color.g, color.b, 0.78), float(i % 6) * lifetime * 0.014, travel, 0.42, 1.8, angle + PI * 0.5, 0.55)
	_spawn_gpu_particles(particle_key, center, mini(96, 28 + intensity * 8), accent, base_size * 0.28, lifetime * 0.66, kind)


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _particle_key(kind: String) -> String:
	if _particle_key_provider.is_valid():
		return String(_particle_key_provider.call(kind))
	return kind


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, spin)


func _spawn_gpu_particles(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> void:
	if _gpu_particles_spawner.is_valid():
		_gpu_particles_spawner.call(texture_key, center, amount, color, radius, lifetime, kind)
