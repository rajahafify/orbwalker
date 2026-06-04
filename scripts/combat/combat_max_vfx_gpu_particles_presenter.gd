extends RefCounted
class_name CombatMaxVfxGpuParticlesPresenter

var _root_3d: Node3D
var _texture_provider: Callable
var _screen_to_world_position: Callable
var _queue_free_after: Callable


func bind(dependencies: Dictionary) -> void:
	_root_3d = dependencies.get("root_3d") as Node3D
	_texture_provider = dependencies.get("texture_provider", Callable())
	_screen_to_world_position = dependencies.get("screen_to_world_position", Callable())
	_queue_free_after = dependencies.get("queue_free_after", Callable())


func spawn_gpu_particles(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> GPUParticles3D:
	if _root_3d == null or not is_instance_valid(_root_3d):
		return null
	var texture := _texture(texture_key)
	if texture == null:
		return null
	var particles := GPUParticles3D.new()
	particles.name = "MaxVfxParticles_%s" % texture_key
	particles.position = _project_position(center, 2.4)
	particles.amount = amount
	particles.lifetime = maxf(0.12, lifetime)
	particles.one_shot = true
	particles.explosiveness = 0.92
	particles.randomness = 0.62
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	process.emission_sphere_radius = maxf(8.0, radius)
	process.direction = Vector3(0.0, 1.0 if kind in ["fire", "heal", "gold"] else 0.0, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = radius * 0.32
	process.initial_velocity_max = radius * 0.92
	process.gravity = Vector3(0.0, -58.0 if kind == "gold" else 18.0, 0.0)
	process.scale_min = 0.18
	process.scale_max = 0.62
	particles.process_material = process
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color = Color(color.r, color.g, color.b, 0.70)
	var mesh := QuadMesh.new()
	mesh.size = Vector2(34, 34)
	mesh.material = material
	particles.draw_pass_1 = mesh
	_root_3d.add_child(particles)
	particles.emitting = true
	_queue_particles_free(particles, lifetime + 0.24)
	return particles


func _texture(texture_key: String) -> Texture2D:
	if _texture_provider.is_valid():
		return _texture_provider.call(texture_key)
	return null


func _project_position(center: Vector2, z: float) -> Vector3:
	if _screen_to_world_position.is_valid():
		return _screen_to_world_position.call(center, z)
	return Vector3(center.x, center.y, z)


func _queue_particles_free(particles: GPUParticles3D, delay: float) -> void:
	if _queue_free_after.is_valid():
		_queue_free_after.call(particles, delay)
