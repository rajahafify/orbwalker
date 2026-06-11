extends RefCounted
class_name CombatMaxVfxOverlay

const COMBAT_MAX_VFX_ASSET_CATALOG_SCRIPT := preload("res://scripts/combat/combat_max_vfx_asset_catalog.gd")
const COMBAT_MAX_VFX_FLIPBOOK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_flipbook_presenter.gd")
const COMBAT_MAX_VFX_IMPORTED_SCENE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_imported_scene_presenter.gd")
const COMBAT_MAX_VFX_SHEET_FLIPBOOK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_sheet_flipbook_presenter.gd")
const COMBAT_MAX_VFX_PACK_SCENE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_pack_scene_presenter.gd")
const COMBAT_MAX_VFX_ELEMENTAL_SCENE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_scene_presenter.gd")
const COMBAT_MAX_VFX_ELEMENTAL_RECIPE_POLICY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_policy.gd")
const COMBAT_MAX_VFX_FIRE_AMBIENT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_fire_ambient_presenter.gd")
const COMBAT_MAX_VFX_FIRE_IMPACT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_fire_impact_presenter.gd")
const COMBAT_MAX_VFX_FIRE_ATTACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_fire_attack_presenter.gd")
const COMBAT_MAX_VFX_FIRE_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_fire_recipe_presenter.gd")
const COMBAT_MAX_VFX_ICE_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_ice_recipe_presenter.gd")
const COMBAT_MAX_VFX_EARTH_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_earth_recipe_presenter.gd")
const COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_pack_recipe_presenter.gd")
const COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_presenter.gd")
const COMBAT_MAX_VFX_ATMOSPHERIC_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_atmospheric_recipe_presenter.gd")
const COMBAT_MAX_VFX_COIN_RAIN_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_coin_rain_presenter.gd")
const COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_status_recipe_presenter.gd")
const COMBAT_MAX_VFX_MASTERY_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_mastery_recipe_presenter.gd")
const COMBAT_MAX_VFX_BURST_PARTICLES_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_burst_particles_presenter.gd")
const COMBAT_MAX_VFX_SCREEN_WIDE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_screen_wide_presenter.gd")
const COMBAT_MAX_VFX_GPU_PARTICLES_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_gpu_particles_presenter.gd")
const COMBAT_MAX_VFX_LIGHT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_light_presenter.gd")
const COMBAT_MAX_VFX_CLEANUP_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_cleanup_presenter.gd")
const COMBAT_MAX_VFX_CAMERA_KICK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_camera_kick_presenter.gd")
const COMBAT_MAX_VFX_PROJECTOR_SCRIPT := preload("res://scripts/combat/combat_max_vfx_projector.gd")
const COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_impact_router.gd")
const OVERLAY_Z_INDEX := 122

var _vfx_layer: Control
var _visual_registry: Variant
var _timer_owner: Node
var _container: SubViewportContainer
var _sub_viewport: SubViewport
var _root_3d: Node3D
var _camera: Camera3D
var _ambient_light: DirectionalLight3D
var _texture_cache: Dictionary = {}
var _pack_scene_cache: Dictionary = {}
var _elemental_scene_cache: Dictionary = {}
var _status_texture_cache: Dictionary = {}
var _atmospheric_texture_cache: Dictionary = {}
var _external_scene_cache: Dictionary = {}
var _asset_catalog: Variant = COMBAT_MAX_VFX_ASSET_CATALOG_SCRIPT.new()
var _flipbook_presenter: Variant = COMBAT_MAX_VFX_FLIPBOOK_PRESENTER_SCRIPT.new()
var _imported_scene_presenter: Variant = COMBAT_MAX_VFX_IMPORTED_SCENE_PRESENTER_SCRIPT.new()
var _sheet_flipbook_presenter: Variant = COMBAT_MAX_VFX_SHEET_FLIPBOOK_PRESENTER_SCRIPT.new()
var _pack_scene_presenter: Variant = COMBAT_MAX_VFX_PACK_SCENE_PRESENTER_SCRIPT.new()
var _elemental_scene_presenter: Variant = COMBAT_MAX_VFX_ELEMENTAL_SCENE_PRESENTER_SCRIPT.new()
var _elemental_recipe_policy: Variant = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_POLICY_SCRIPT.new()
var _fire_ambient_presenter: Variant = COMBAT_MAX_VFX_FIRE_AMBIENT_PRESENTER_SCRIPT.new()
var _fire_impact_presenter: Variant = COMBAT_MAX_VFX_FIRE_IMPACT_PRESENTER_SCRIPT.new()
var _fire_attack_presenter: Variant = COMBAT_MAX_VFX_FIRE_ATTACK_PRESENTER_SCRIPT.new()
var _fire_recipe_presenter: Variant = COMBAT_MAX_VFX_FIRE_RECIPE_PRESENTER_SCRIPT.new()
var _ice_recipe_presenter: Variant = COMBAT_MAX_VFX_ICE_RECIPE_PRESENTER_SCRIPT.new()
var _earth_recipe_presenter: Variant = COMBAT_MAX_VFX_EARTH_RECIPE_PRESENTER_SCRIPT.new()
var _pack_recipe_presenter: Variant = COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT.new()
var _elemental_recipe_presenter: Variant = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT.new()
var _atmospheric_recipe_presenter: Variant = COMBAT_MAX_VFX_ATMOSPHERIC_RECIPE_PRESENTER_SCRIPT.new()
var _coin_rain_presenter: Variant = COMBAT_MAX_VFX_COIN_RAIN_PRESENTER_SCRIPT.new()
var _status_recipe_presenter: Variant = COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT.new()
var _mastery_recipe_presenter: Variant = COMBAT_MAX_VFX_MASTERY_RECIPE_PRESENTER_SCRIPT.new()
var _burst_particles_presenter: Variant = COMBAT_MAX_VFX_BURST_PARTICLES_PRESENTER_SCRIPT.new()
var _screen_wide_presenter: Variant = COMBAT_MAX_VFX_SCREEN_WIDE_PRESENTER_SCRIPT.new()
var _gpu_particles_presenter: Variant = COMBAT_MAX_VFX_GPU_PARTICLES_PRESENTER_SCRIPT.new()
var _light_presenter: Variant = COMBAT_MAX_VFX_LIGHT_PRESENTER_SCRIPT.new()
var _cleanup_presenter: Variant = COMBAT_MAX_VFX_CLEANUP_PRESENTER_SCRIPT.new()
var _camera_kick_presenter: Variant = COMBAT_MAX_VFX_CAMERA_KICK_PRESENTER_SCRIPT.new()
var _projector: Variant = COMBAT_MAX_VFX_PROJECTOR_SCRIPT.new()
var _replay_impact_router: Variant = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_timer_owner = dependencies.get("timer_owner") as Node
	_ensure_overlay()
	_bind_flipbook_presenter()
	_bind_imported_scene_presenter()
	_bind_sheet_flipbook_presenter()
	_bind_pack_scene_presenter()
	_bind_elemental_scene_presenter()
	_bind_fire_ambient_presenter()
	_bind_fire_impact_presenter()
	_bind_fire_attack_presenter()
	_bind_fire_recipe_presenter()
	_bind_ice_recipe_presenter()
	_bind_earth_recipe_presenter()
	_bind_pack_recipe_presenter()
	_bind_elemental_recipe_presenter()
	_bind_atmospheric_recipe_presenter()
	_bind_coin_rain_presenter()
	_bind_status_recipe_presenter()
	_bind_mastery_recipe_presenter()
	_bind_burst_particles_presenter()
	_bind_screen_wide_presenter()
	_bind_gpu_particles_presenter()
	_bind_light_presenter()
	_bind_cleanup_presenter()
	_bind_camera_kick_presenter()
	_bind_projector()
	_bind_replay_impact_router()


func is_available() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	if not _ensure_overlay():
		return false
	if _status_vfx_available():
		return true
	if _elemental_magic_available() or _pack_vfx_available():
		return true
	if _visual_registry == null:
		return false
	for key in _asset_catalog.required_texture_keys():
		if _max_texture(key) == null:
			return false
	return true


func required_texture_keys() -> Array[String]:
	return _asset_catalog.required_texture_keys()


func required_status_sheet_paths() -> Dictionary:
	return _asset_catalog.status_sheet_paths()


func required_atmospheric_sheet_paths() -> Dictionary:
	return _asset_catalog.atmospheric_sheet_paths()


func external_scene_paths() -> Dictionary:
	return _asset_catalog.external_scene_paths()


func spawn_replay_impact(global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, _result_amount: int, intensity: int, screen_wide: bool) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var kind := _clean_kind(clean_kind)
	var center := _global_to_overlay_local(global_center)
	var colors := _kind_colors(kind)
	var accent: Color = colors.get("accent", Color.WHITE)
	var core: Color = colors.get("core", Color.WHITE)
	var max_size := maxf(draw_size.x, draw_size.y)
	var basis_size := _replay_impact_basis_size(kind, draw_size, max_size)
	var base_size := basis_size * (2.25 + float(intensity) * 0.22)
	var duration := maxf(0.32, lifetime * 1.10)
	if kind == "armor" and not _status_vfx_available():
		_spawn_max_armor_grid_snap(center, base_size * 0.74, duration, intensity)
		_spawn_light(center, core, 2.5 + float(intensity) * 0.30, base_size * 1.10, duration * 0.72)
		return true
	if _replay_impact_router.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide):
		return true
	_spawn_light(center, core, 2.4 + float(intensity) * 0.34, base_size * 1.15, duration * 0.65)
	_spawn_flipbook(_impact_key(kind), center, Vector2(base_size, base_size), duration, Color(1, 1, 1, 0.95), 0.0, Vector2.ZERO, 1.12 + float(intensity) * 0.04, 0.0, 0.18)
	_spawn_flipbook("shockwave_ring", center, Vector2(base_size * 0.92, base_size * 0.92), duration * 0.78, Color(core.r, core.g, core.b, 0.82), 0.03, Vector2.ZERO, 1.52 + float(intensity) * 0.07, -0.8, 0.0)
	_spawn_flipbook(_mist_key(kind), center + Vector2(0.0, max_size * 0.08), Vector2(base_size * 1.10, base_size * 0.78), duration * 1.08, Color(accent.r, accent.g, accent.b, 0.36), 0.04, Vector2(0.0, -max_size * 0.10), 1.18, -1.2, 0.08)
	_spawn_burst_particles(kind, center, max_size, duration, intensity)
	if screen_wide:
		_spawn_screen_wide(kind, center, duration, intensity)
	if kind == "gold":
		_spawn_coin_rain(center, max_size, duration, intensity, false)
	return true


func spawn_armor_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var width := maxf(draw_size.x * 1.34, 260.0)
	var height := maxf(draw_size.y * 3.1, 150.0)
	if _status_vfx_available():
		_spawn_status_armor_linger(center, Vector2(width, height), lifetime, intensity)
		return true
	_spawn_max_armor_grid_snap(center, maxf(width, height) * 0.82, lifetime, intensity)
	_spawn_light(center, Color(0.78, 0.92, 1.0, 1.0), 2.1 + float(intensity) * 0.24, maxf(width, height) * 0.78, lifetime)
	return true


func _spawn_max_armor_grid_snap(center: Vector2, max_size: float, lifetime: float, intensity: int) -> void:
	var shell_size := maxf(96.0, max_size)
	_spawn_flipbook("armor_impact", center, Vector2(shell_size * 0.96, shell_size * 0.96), lifetime * 0.78, Color(0.36, 0.76, 1.0, 0.20), 0.0, Vector2.ZERO, 1.10, 0.8, 0.0)
	var cell_size := maxf(28.0, shell_size * (0.17 + float(intensity) * 0.004))
	var gap := cell_size * 0.92
	var start := Vector2(-gap, -gap)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.24 if row % 2 == 1 else 0.0), float(row) * gap)
			var distance: int = absi(row - 1) + absi(column - 1)
			var delay := lifetime * (0.03 + float(distance) * 0.035 + float(index % 2) * 0.012)
			var alpha := 0.52 if distance == 0 else 0.38
			_spawn_flipbook("armor_impact", center + offset, Vector2(cell_size, cell_size * 1.10), lifetime * 0.62, Color(0.70, 0.92, 1.0, alpha), delay, Vector2.ZERO, 1.08, 2.2, PI / 6.0)
	var bar_length := shell_size * (0.60 + float(intensity) * 0.01)
	var bar_thickness := maxf(8.0, shell_size * 0.035)
	var half := shell_size * 0.50
	var specs := [
		{"offset": Vector2(0.0, -half), "rotation": 0.0, "move": Vector2(0.0, shell_size * 0.08)},
		{"offset": Vector2(0.0, half), "rotation": 0.0, "move": Vector2(0.0, -shell_size * 0.08)},
		{"offset": Vector2(-half, 0.0), "rotation": PI * 0.5, "move": Vector2(shell_size * 0.08, 0.0)},
		{"offset": Vector2(half, 0.0), "rotation": PI * 0.5, "move": Vector2(-shell_size * 0.08, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		_spawn_flipbook(
			"light_rays",
			center + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			lifetime * 0.44,
			Color(0.88, 0.98, 1.0, 0.78),
			lifetime * (0.04 + float(i) * 0.022),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.72,
			2.8,
			float(spec.get("rotation", 0.0))
		)


func spawn_mastery_cast_sequence(orb_id: int, source_global: Vector2, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	return _mastery_recipe_presenter.spawn_cast_sequence(orb_id, source, target, spool_lifetime, travel_lifetime, result_amount)


func spawn_mastery_beam(orb_id: int, source_global: Vector2, target_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	return _mastery_recipe_presenter.spawn_beam(orb_id, source, target, lifetime)


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	if _pack_vfx_available():
		_spawn_pack_effect("hit_02", source, "damage", Vector2(150, 150), lifetime * 1.10, 3, 0.0, Vector2.ZERO, -0.12, 1.0, 0.80)
		_spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
		return true
	_spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
	_spawn_flipbook("enemy_attack", source, Vector2(180, 180), lifetime * 1.15, Color(1, 1, 1, 0.88), 0.0, Vector2.ZERO, 1.04, 1.0, -0.12)
	return true


func spawn_enemy_attack_travel(source_global: Vector2, target_global: Vector2, lifetime: float) -> bool:
	if not is_available() or source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return false
	var source := _global_to_overlay_local(source_global)
	var target := _global_to_overlay_local(target_global)
	var delta := target - source
	if delta.length() <= 1.0:
		return false
	var angle := delta.angle()
	if _pack_vfx_available():
		var intensity := clampi(int(round(delta.length() / 120.0)), 2, 8)
		_spawn_pack_effect("hit_01", source, "damage", Vector2(112 + intensity * 7, 68 + intensity * 5), lifetime, intensity, 0.0, delta, angle, 1.3, 0.66)
		return true
	_spawn_flipbook("enemy_attack", source, Vector2(150, 88), lifetime, Color(1, 1, 1, 0.94), 0.0, delta, 0.78, 1.5, angle)
	_spawn_flipbook("light_rays", source + delta * 0.5, Vector2(delta.length(), 34.0), lifetime * 0.74, Color(1.0, 0.35, 0.52, 0.56), 0.0, Vector2.ZERO, 0.50, 0.3, angle)
	return true


func spawn_enemy_attack_impact(global_center: Vector2, blocked: bool, amount: int, lifetime: float) -> bool:
	if blocked:
		return spawn_replay_impact(global_center, "armor", Vector2(92, 92), lifetime, amount, 4, false)
	return spawn_replay_impact(global_center, "damage", Vector2(96, 96), lifetime, amount, 4, false)


func spawn_generic(global_center: Vector2, draw_size: Vector2, lifetime: float, color: Color = Color.WHITE) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var size := Vector2(maxf(draw_size.x, draw_size.y), maxf(draw_size.x, draw_size.y)) * 1.8
	if _pack_vfx_available():
		_spawn_pack_effect("hit_01", center, "generic", size, lifetime * 1.10, 3, 0.0, Vector2.ZERO, 0.0, 0.0, color.a)
		return true
	_spawn_flipbook("orb_clear", center, size, lifetime * 1.15, color, 0.0, Vector2.ZERO, 1.12, 0.0, 0.0)
	return true


func _ensure_overlay() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return false
	if _container != null and is_instance_valid(_container):
		_sync_overlay_size(layer_size)
		_bind_flipbook_presenter()
		_bind_imported_scene_presenter()
		_bind_sheet_flipbook_presenter()
		_bind_pack_scene_presenter()
		_bind_elemental_scene_presenter()
		_bind_fire_ambient_presenter()
		_bind_fire_impact_presenter()
		_bind_fire_attack_presenter()
		_bind_fire_recipe_presenter()
		_bind_ice_recipe_presenter()
		_bind_earth_recipe_presenter()
		_bind_pack_recipe_presenter()
		_bind_elemental_recipe_presenter()
		_bind_atmospheric_recipe_presenter()
		_bind_coin_rain_presenter()
		_bind_status_recipe_presenter()
		_bind_mastery_recipe_presenter()
		_bind_burst_particles_presenter()
		_bind_screen_wide_presenter()
		_bind_gpu_particles_presenter()
		_bind_light_presenter()
		_bind_cleanup_presenter()
		_bind_camera_kick_presenter()
		_bind_projector()
		return true
	_container = SubViewportContainer.new()
	_container.name = "CombatMaxVfx3DOverlay"
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_container.z_index = OVERLAY_Z_INDEX
	_container.anchor_left = 0.0
	_container.anchor_top = 0.0
	_container.anchor_right = 0.0
	_container.anchor_bottom = 0.0
	_container.position = Vector2.ZERO
	_container.size = layer_size
	_container.stretch = true
	_vfx_layer.add_child(_container)

	_sub_viewport = SubViewport.new()
	_sub_viewport.name = "CombatMaxVfxViewport"
	_sub_viewport.transparent_bg = true
	_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_sub_viewport.size = Vector2i(int(layer_size.x), int(layer_size.y))
	_container.add_child(_sub_viewport)

	_root_3d = Node3D.new()
	_root_3d.name = "CombatMaxVfxRoot3D"
	_sub_viewport.add_child(_root_3d)

	_camera = Camera3D.new()
	_camera.name = "CombatMaxVfxCamera"
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_camera.current = true
	_root_3d.add_child(_camera)

	_ambient_light = DirectionalLight3D.new()
	_ambient_light.name = "CombatMaxVfxKeyLight"
	_ambient_light.light_color = Color(0.74, 0.82, 1.0, 1.0)
	_ambient_light.light_energy = 0.18
	_ambient_light.rotation_degrees = Vector3(-58.0, 18.0, 0.0)
	_root_3d.add_child(_ambient_light)
	_sync_overlay_size(layer_size)
	_bind_flipbook_presenter()
	_bind_imported_scene_presenter()
	_bind_sheet_flipbook_presenter()
	_bind_pack_scene_presenter()
	_bind_elemental_scene_presenter()
	_bind_fire_ambient_presenter()
	_bind_fire_impact_presenter()
	_bind_fire_attack_presenter()
	_bind_fire_recipe_presenter()
	_bind_ice_recipe_presenter()
	_bind_earth_recipe_presenter()
	_bind_pack_recipe_presenter()
	_bind_elemental_recipe_presenter()
	_bind_atmospheric_recipe_presenter()
	_bind_coin_rain_presenter()
	_bind_status_recipe_presenter()
	_bind_mastery_recipe_presenter()
	_bind_burst_particles_presenter()
	_bind_screen_wide_presenter()
	_bind_gpu_particles_presenter()
	_bind_light_presenter()
	_bind_cleanup_presenter()
	_bind_camera_kick_presenter()
	_bind_projector()
	return true


func _bind_flipbook_presenter() -> void:
	_flipbook_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"texture_provider": Callable(self, "_max_texture"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
		"screen_to_world_rotation": Callable(self, "_screen_to_world_rotation"),
	})


func _bind_imported_scene_presenter() -> void:
	_imported_scene_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"flame_scene_provider": Callable(self, "_flame_scene"),
		"beam_scene_provider": Callable(self, "_beam_scene"),
		"shield_scene_provider": Callable(self, "_shield_scene"),
		"tornado_scene_provider": Callable(self, "_tornado_scene"),
		"kind_colors_provider": Callable(self, "_elemental_kind_colors"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
	})


func _bind_sheet_flipbook_presenter() -> void:
	_sheet_flipbook_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"status_texture_provider": Callable(self, "_status_texture"),
		"atmospheric_texture_provider": Callable(self, "_atmospheric_texture"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
		"screen_to_world_rotation": Callable(self, "_screen_to_world_rotation"),
	})


func _bind_pack_scene_presenter() -> void:
	_pack_scene_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"pack_scene_provider": Callable(self, "_pack_scene"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
		"screen_to_world_rotation": Callable(self, "_screen_to_world_rotation"),
	})


func _bind_elemental_scene_presenter() -> void:
	_elemental_scene_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"elemental_scene_provider": Callable(self, "_elemental_scene"),
		"elemental_kind_colors_provider": Callable(self, "_elemental_kind_colors"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
		"screen_to_world_rotation": Callable(self, "_screen_to_world_rotation"),
	})


func _bind_fire_ambient_presenter() -> void:
	_fire_ambient_presenter.bind({
		"atmospheric_available_provider": Callable(self, "_atmospheric_vfx_available"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"light_spawner": Callable(self, "_spawn_light"),
	})


func _bind_fire_impact_presenter() -> void:
	_fire_impact_presenter.bind({
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"elemental_effect_spawner": Callable(self, "_spawn_elemental_effect"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"spark_spray_spawner": Callable(self, "_spawn_fire_spark_spray"),
		"light_spawner": Callable(self, "_spawn_light"),
	})


func _bind_fire_attack_presenter() -> void:
	_fire_attack_presenter.bind({
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"elemental_effect_spawner": Callable(self, "_spawn_elemental_effect"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"spark_spray_spawner": Callable(self, "_spawn_fire_spark_spray"),
		"light_spawner": Callable(self, "_spawn_light"),
		"meteor_impact_spawner": Callable(self, "_spawn_fire_meteor_impact_layers"),
	})


func _bind_fire_recipe_presenter() -> void:
	_fire_recipe_presenter.bind({
		"tier_provider": Callable(self, "_fire_vfx_tier"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"flame_scene_spawner": Callable(self, "_spawn_flame_scene"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"burst_particles_spawner": Callable(self, "_spawn_burst_particles"),
		"spark_spray_spawner": Callable(self, "_spawn_fire_spark_spray"),
		"light_spawner": Callable(self, "_spawn_light"),
		"fireball_impact_spawner": Callable(self, "_spawn_fireball_impact_layers"),
		"meteor_impact_spawner": Callable(self, "_spawn_fire_meteor_impact_layers"),
		"fragmented_impact_spawner": Callable(self, "_spawn_fire_fragmented_impact_cluster"),
		"aurora_layer_spawner": Callable(self, "_spawn_fire_aurora_layer"),
		"screen_ember_field_spawner": Callable(self, "_spawn_fire_screen_ember_field"),
		"ember_lane_spawner": Callable(self, "_spawn_fire_ember_lane"),
		"status_path_afterimage_spawner": Callable(self, "_spawn_status_path_afterimage"),
		"beam_effect_spawner": Callable(self, "_spawn_beam_effect"),
		"fireball_spell_spawner": Callable(self, "_spawn_fireball_spell_layers"),
		"meteor_attack_spawner": Callable(self, "_spawn_fire_meteor_attack_layers"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
	})


func _bind_ice_recipe_presenter() -> void:
	_ice_recipe_presenter.bind({
		"tier_provider": Callable(self, "_ice_vfx_tier"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"burst_particles_spawner": Callable(self, "_spawn_burst_particles"),
		"light_spawner": Callable(self, "_spawn_light"),
		"status_path_afterimage_spawner": Callable(self, "_spawn_status_path_afterimage"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
	})


func _bind_earth_recipe_presenter() -> void:
	_earth_recipe_presenter.bind({
		"tier_provider": Callable(self, "_earth_vfx_tier"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"burst_particles_spawner": Callable(self, "_spawn_burst_particles"),
		"light_spawner": Callable(self, "_spawn_light"),
		"tornado_scene_spawner": Callable(self, "_spawn_tornado_scene"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
	})


func _bind_pack_recipe_presenter() -> void:
	_pack_recipe_presenter.bind({
		"kind_cleaner": Callable(self, "_clean_kind"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"pack_effect_spawner": Callable(self, "_spawn_pack_effect"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"light_spawner": Callable(self, "_spawn_light"),
		"coin_rain_spawner": Callable(self, "_spawn_coin_rain"),
	})


func _bind_elemental_recipe_presenter() -> void:
	_elemental_recipe_presenter.bind({
		"kind_cleaner": Callable(self, "_clean_kind"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"elemental_effect_spawner": Callable(self, "_spawn_elemental_effect"),
		"effect_stretcher": Callable(self, "_stretch_effect"),
		"pack_impact_scene_key_provider": Callable(self, "_pack_impact_scene_key"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"coin_rain_spawner": Callable(self, "_spawn_coin_rain"),
		"light_spawner": Callable(self, "_spawn_light"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
	})


func _bind_atmospheric_recipe_presenter() -> void:
	_atmospheric_recipe_presenter.bind({
		"atmospheric_available_provider": Callable(self, "_atmospheric_vfx_available"),
		"kind_cleaner": Callable(self, "_clean_kind"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"atmospheric_travel_key_provider": Callable(self, "_atmospheric_travel_key"),
		"atmospheric_impact_key_provider": Callable(self, "_atmospheric_impact_key"),
		"atmospheric_secondary_key_provider": Callable(self, "_atmospheric_secondary_key"),
		"atmospheric_flipbook_spawner": Callable(self, "_spawn_atmospheric_flipbook"),
	})


func _bind_coin_rain_presenter() -> void:
	_coin_rain_presenter.bind({
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
	})


func _bind_status_recipe_presenter() -> void:
	_status_recipe_presenter.bind({
		"kind_cleaner": Callable(self, "_clean_kind"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"status_sheet_key_provider": Callable(self, "_status_sheet_key"),
		"status_trail_key_provider": Callable(self, "_status_trail_key"),
		"status_flipbook_spawner": Callable(self, "_spawn_status_flipbook"),
		"shield_scene_spawner": Callable(self, "_spawn_shield_scene"),
		"light_spawner": Callable(self, "_spawn_light"),
		"coin_rain_spawner": Callable(self, "_spawn_coin_rain"),
		"fire_replay_layers_spawner": Callable(self, "_spawn_fire_replay_layers"),
		"ice_replay_layers_spawner": Callable(self, "_spawn_ice_replay_layers"),
		"earth_replay_layers_spawner": Callable(self, "_spawn_earth_replay_layers"),
		"fire_cast_layers_spawner": Callable(self, "_spawn_fire_cast_layers"),
		"ice_cast_layers_spawner": Callable(self, "_spawn_ice_cast_layers"),
		"earth_cast_layers_spawner": Callable(self, "_spawn_earth_cast_layers"),
		"fire_beam_layers_spawner": Callable(self, "_spawn_fire_beam_layers"),
		"windy_ice_block_travel_spawner": Callable(self, "_spawn_windy_ice_block_travel_layers"),
		"earth_fracture_travel_spawner": Callable(self, "_spawn_earth_fracture_travel_layers"),
		"earth_tier_provider": Callable(self, "_earth_vfx_tier"),
		"pack_impact_scene_key_provider": Callable(self, "_pack_impact_scene_key"),
		"atmospheric_replay_layer_spawner": Callable(self, "_spawn_atmospheric_replay_layer"),
		"atmospheric_travel_spawner": Callable(self, "_spawn_atmospheric_travel"),
		"beam_effect_spawner": Callable(self, "_spawn_beam_effect"),
		"pack_layer_spawner": Callable(self, "_spawn_pack_layer"),
		"burst_particles_spawner": Callable(self, "_spawn_burst_particles"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
	})


func _bind_mastery_recipe_presenter() -> void:
	_mastery_recipe_presenter.bind({
		"status_available_provider": Callable(self, "_status_vfx_available"),
		"elemental_available_provider": Callable(self, "_elemental_magic_available"),
		"pack_available_provider": Callable(self, "_pack_vfx_available"),
		"should_use_elemental_provider": Callable(self, "_should_use_elemental_magic"),
		"kind_for_orb_provider": Callable(self, "_kind_for_orb"),
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"status_cast_spawner": Callable(self, "_spawn_status_cast_recipe"),
		"elemental_cast_spawner": Callable(self, "_spawn_elemental_cast_recipe"),
		"pack_hit_scene_key_provider": Callable(self, "_pack_hit_scene_key"),
		"pack_impact_scene_key_provider": Callable(self, "_pack_impact_scene_key"),
		"pack_effect_spawner": Callable(self, "_spawn_pack_effect"),
		"light_spawner": Callable(self, "_spawn_light"),
		"camera_kick_spawner": Callable(self, "_spawn_camera_kick"),
		"impact_key_provider": Callable(self, "_impact_key"),
		"projectile_key_provider": Callable(self, "_projectile_key"),
		"trail_key_provider": Callable(self, "_trail_key"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"status_beam_spawner": Callable(self, "_spawn_status_beam_recipe"),
		"elemental_beam_spawner": Callable(self, "_spawn_elemental_beam_recipe"),
	})


func _bind_burst_particles_presenter() -> void:
	_burst_particles_presenter.bind({
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"particle_key_provider": Callable(self, "_particle_key"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"gpu_particles_spawner": Callable(self, "_spawn_gpu_particles"),
	})


func _bind_screen_wide_presenter() -> void:
	_screen_wide_presenter.bind({
		"kind_colors_provider": Callable(self, "_kind_colors"),
		"impact_key_provider": Callable(self, "_impact_key"),
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"light_spawner": Callable(self, "_spawn_light"),
		"flipbook_spawner": Callable(self, "_spawn_flipbook"),
		"coin_rain_spawner": Callable(self, "_spawn_coin_rain"),
	})


func _bind_gpu_particles_presenter() -> void:
	_gpu_particles_presenter.bind({
		"root_3d": _root_3d,
		"texture_provider": Callable(self, "_max_texture"),
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
		"queue_free_after": Callable(self, "_queue_free_after"),
	})


func _bind_light_presenter() -> void:
	_light_presenter.bind({
		"root_3d": _root_3d,
		"timer_owner": _timer_owner,
		"screen_to_world_position": Callable(self, "_screen_to_world_position"),
	})


func _bind_cleanup_presenter() -> void:
	_cleanup_presenter.bind({
		"timer_owner": _timer_owner,
	})


func _bind_camera_kick_presenter() -> void:
	_camera_kick_presenter.bind({
		"camera": _camera,
		"timer_owner": _timer_owner,
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
		"screen_to_world_offset": Callable(self, "_screen_to_world_offset"),
	})


func _bind_projector() -> void:
	_projector.bind({
		"layer_size_provider": Callable(self, "_vfx_layer_size"),
	})


func _bind_replay_impact_router() -> void:
	# Rebind after swapping presenter instances so routes hold the current presenters.
	_replay_impact_router.bind({
		"routes": [
			{"presenter": _status_recipe_presenter, "available": Callable(self, "_status_vfx_available")},
			{"presenter": _elemental_recipe_presenter, "available": Callable(self, "_elemental_magic_available"), "kind_filter": Callable(self, "_should_use_elemental_magic")},
			{"presenter": _pack_recipe_presenter, "available": Callable(self, "_pack_vfx_available")},
		],
	})


func _sync_overlay_size(layer_size: Vector2) -> void:
	if _container != null and is_instance_valid(_container):
		_container.size = layer_size
	if _sub_viewport != null and is_instance_valid(_sub_viewport):
		var next_size := Vector2i(maxi(1, int(layer_size.x)), maxi(1, int(layer_size.y)))
		if _sub_viewport.size != next_size:
			_sub_viewport.size = next_size
	if _camera != null and is_instance_valid(_camera):
		_camera.size = layer_size.y
		_camera.position = Vector3(layer_size.x * 0.5, layer_size.y * 0.5, 1000.0)
		_camera.rotation = Vector3.ZERO


func _status_vfx_available() -> bool:
	for key in ["burn", "freeze", "poison", "heal", "shield", "blessed"]:
		if _status_texture(key) == null:
			return false
	return true


func _atmospheric_vfx_available() -> bool:
	for key in ["embers", "snow", "wind", "magic_wind", "godrays"]:
		if _atmospheric_texture(key) == null:
			return false
	return true


func _status_texture(key: String) -> Texture2D:
	if _status_texture_cache.has(key):
		return _status_texture_cache[key]
	var path: String = _asset_catalog.status_sheet_path(key)
	if path == "":
		return null
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		_status_texture_cache[key] = imported_texture
		return imported_texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture != null:
		_status_texture_cache[key] = texture
	return texture


func _atmospheric_texture(key: String) -> Texture2D:
	if _atmospheric_texture_cache.has(key):
		return _atmospheric_texture_cache[key]
	var path: String = _asset_catalog.atmospheric_sheet_path(key)
	if path == "":
		return null
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		_atmospheric_texture_cache[key] = imported_texture
		return imported_texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	var texture := ImageTexture.create_from_image(image)
	if texture != null:
		_atmospheric_texture_cache[key] = texture
	return texture


func _external_scene(key: String, path: String) -> PackedScene:
	if _external_scene_cache.has(key):
		return _external_scene_cache[key]
	var scene := load(path) as PackedScene
	if scene != null:
		_external_scene_cache[key] = scene
	return scene


func _flame_scene() -> PackedScene:
	return _external_scene("flame", _asset_catalog.external_scene_path("flame"))


func _beam_scene() -> PackedScene:
	return _external_scene("beam", _asset_catalog.external_scene_path("beam"))


func _shield_scene() -> PackedScene:
	return _external_scene("shield", _asset_catalog.external_scene_path("shield"))


func _tornado_scene() -> PackedScene:
	return _external_scene("tornado", _asset_catalog.external_scene_path("tornado"))


func _spawn_status_replay_recipe(kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_status_recipe_presenter.spawn_replay_recipe(kind, center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _fire_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.fire_tier(intensity, screen_wide)


func _ice_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.ice_tier(intensity, screen_wide)


func _earth_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.earth_tier(intensity, screen_wide)


func _replay_impact_basis_size(kind: String, draw_size: Vector2, fallback_size: float) -> float:
	return _elemental_recipe_policy.replay_impact_basis_size(kind, draw_size, fallback_size)


func _spawn_fire_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_fire_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_fire_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	_fire_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	_fire_recipe_presenter.spawn_beam_layers(source, delta, duration, intensity, angle)


func _spawn_fire_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	_fire_ambient_presenter.spawn_ember_lane(source, delta, launch_delay, travel_duration, intensity, angle, tier)


func _spawn_fireball_spell_layers(source: Vector2, target: Vector2, delta: Vector2, source_size: Vector2, impact_size: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_fire_attack_presenter.spawn_fireball_spell_layers(source, target, delta, source_size, impact_size, launch_delay, travel_duration, intensity, angle)


func _spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	_fire_impact_presenter.spawn_fireball_impact_layers(center, impact_size, duration, intensity, max_size)


func _spawn_fire_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	_fire_attack_presenter.spawn_meteor_attack_layers(target, launch_delay, travel_duration, intensity, impact_size)


func _spawn_fire_meteor_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool = false) -> void:
	_fire_impact_presenter.spawn_meteor_impact_layers(center, impact_size, duration, intensity, delay, fragmented_wide)


func _spawn_fire_fragmented_impact_cluster(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float = 1.0, rotation: float = 0.0) -> void:
	_fire_impact_presenter.spawn_fragmented_impact_cluster(center, draw_size, duration, intensity, delay, alpha_scale, rotation)


func _spawn_fire_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_fire_ambient_presenter.spawn_screen_ember_field(center, lifetime, intensity, delay, alpha_scale)


func _spawn_fire_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	_fire_ambient_presenter.spawn_spark_spray(center, radius, lifetime, intensity, delay, tier)


func _spawn_fire_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_fire_ambient_presenter.spawn_aurora_layer(center, lifetime, intensity, delay, alpha_scale)


func _spawn_ice_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_ice_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_ice_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	_ice_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_windy_ice_block_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float) -> void:
	_ice_recipe_presenter.spawn_windy_block_travel_layers(source, _target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle)


func _spawn_earth_replay_layers(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_earth_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_earth_cast_layers(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
	_earth_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_earth_fracture_travel_layers(source: Vector2, _target: Vector2, delta: Vector2, normal: Vector2, source_size: Vector2, travel_duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
	_earth_recipe_presenter.spawn_fracture_travel_layers(source, _target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle, tier)


func _spawn_status_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_status_recipe_presenter.spawn_armor_linger(center, draw_size, lifetime, intensity)


func _spawn_status_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
	_status_recipe_presenter.spawn_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)


func _spawn_status_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_status_recipe_presenter.spawn_beam_recipe(kind, source, delta, lifetime, intensity, angle)


func _spawn_status_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_status_recipe_presenter.spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_status_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_status_recipe_presenter.spawn_screen_wide(kind, center, lifetime, intensity)


func _spawn_atmospheric_replay_layer(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	_atmospheric_recipe_presenter.spawn_replay_layer(kind, center, max_size, base_size, lifetime, intensity, screen_wide)


func _spawn_atmospheric_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_atmospheric_recipe_presenter.spawn_travel(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1) -> Sprite3D:
	if not _ensure_overlay():
		return null
	return _sheet_flipbook_presenter.spawn_atmospheric_flipbook(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func _spawn_status_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, loops: int = 1, spin: float = 0.0) -> Sprite3D:
	if not _ensure_overlay():
		return null
	return _sheet_flipbook_presenter.spawn_status_flipbook(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops, spin)

func _spawn_flame_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_flame_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, alpha)


func _spawn_beam_effect(source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float = 0.0, radius_scale: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_beam_effect(source_local, delta, kind, lifetime, intensity, delay, radius_scale)


func _spawn_shield_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_shield_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z)


func _spawn_tornado_scene(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0, keep_child_name: String = "") -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_tornado_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, keep_child_name)

func _status_sheet_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "burn"
		"ice":
			return "freeze"
		"earth":
			return "poison"
		"heart":
			return "heal"
		"armor":
			return "armor"
		"gold":
			return "blessed"
		"damage":
			return "bleed"
	return "shock"


func _status_trail_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "rage"
		"ice":
			return "slow"
		"earth":
			return "weaken"
		"heart":
			return "regen"
		"armor":
			return "armor"
		"gold":
			return "haste"
		"damage":
			return "stun"
	return _status_sheet_key(kind)


func _atmospheric_travel_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "snow"
		"earth":
			return "caustics"
		"heart":
			return "magic_wind"
		"armor":
			return "godrays"
		"gold":
			return "meteor"
		"damage":
			return "storm"
	return "magic_wind"


func _atmospheric_impact_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "frost"
		"earth":
			return "rain_splash"
		"heart":
			return "fireflies"
		"armor":
			return "godrays"
		"gold":
			return "fireflies"
		"damage":
			return "storm"
	return "fog"


func _atmospheric_secondary_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "meteor"
		"ice":
			return "frost"
		"earth":
			return "bubbles"
		"heart":
			return "godrays"
		"armor":
			return "caustics"
		"gold":
			return "godrays"
		"damage":
			return "embers"
	return "fog"


func _spawn_elemental_replay_recipe(kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	_elemental_recipe_presenter.spawn_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)


func _spawn_elemental_cast_recipe(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
	_elemental_recipe_presenter.spawn_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)


func _spawn_elemental_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_elemental_recipe_presenter.spawn_beam_layers(kind, source, delta, lifetime, intensity, angle)


func _elemental_magic_available() -> bool:
	return _elemental_scene("cast") != null and _elemental_scene("projectile") != null and _elemental_scene("area") != null


func _elemental_scene(key: String) -> PackedScene:
	if _elemental_scene_cache.has(key):
		return _elemental_scene_cache[key]
	var path: String = _asset_catalog.elemental_magic_scene_path(key)
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_elemental_scene_cache[key] = scene
	return scene


func _spawn_elemental_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	return _elemental_scene_presenter.spawn_elemental_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_elemental_path_afterimage(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_elemental_recipe_presenter.spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_elemental_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_elemental_recipe_presenter.spawn_screen_wide(kind, center, lifetime, intensity)


func _pack_vfx_available() -> bool:
	return _pack_scene("hit_01") != null and _pack_scene("impact_01") != null and _pack_scene("big_impact_01") != null


func _pack_scene(key: String) -> PackedScene:
	if _pack_scene_cache.has(key):
		return _pack_scene_cache[key]
	var path: String = _asset_catalog.pack_scene_path(key)
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_pack_scene_cache[key] = scene
	return scene


func _spawn_pack_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, rotation: float = 0.0, z: float = 0.0, alpha: float = 1.0) -> Node3D:
	if not _ensure_overlay():
		return null
	return _pack_scene_presenter.spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_pack_layer(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> Node3D:
	if not _pack_vfx_available():
		return null
	return _spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, Vector2.ZERO, rotation, z, alpha)


func _stretch_effect(effect: Node3D, stretch: Vector3) -> void:
	_pack_scene_presenter.stretch_effect(effect, stretch)


func _pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	return _pack_recipe_presenter.impact_scene_key(kind, intensity, screen_wide)


func _pack_hit_scene_key(kind: String) -> String:
	return _pack_recipe_presenter.hit_scene_key(kind)


func _spawn_pack_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_pack_recipe_presenter.spawn_screen_wide(kind, center, lifetime, intensity)


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, target_scale: float = 1.0, z: float = 0.0, rotation: float = 0.0, spin: float = 0.0) -> Sprite3D:
	if not _ensure_overlay():
		return null
	return _flipbook_presenter.spawn_flipbook(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, spin)


func _spawn_burst_particles(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
	_burst_particles_presenter.spawn_burst_particles(kind, center, base_size, lifetime, intensity)


func _spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_screen_wide_presenter.spawn_screen_wide(kind, center, lifetime, intensity)


func _spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	_coin_rain_presenter.spawn_coin_rain(center, base_size, lifetime, intensity, screen_wide)


func _spawn_gpu_particles(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> void:
	_gpu_particles_presenter.spawn_gpu_particles(texture_key, center, amount, color, radius, lifetime, kind)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
	_light_presenter.spawn_light(center, color, energy, radius, lifetime, delay)


func _spawn_camera_kick(direction: Vector2, delay: float) -> void:
	_camera_kick_presenter.spawn_camera_kick(direction, delay)


func _queue_free_after(node: Node, delay: float) -> void:
	_cleanup_presenter.queue_free_after(node, delay)


func _screen_to_world_position(screen_position: Vector2, z: float) -> Vector3:
	return _projector.screen_to_world_position(screen_position, z)


func _screen_to_world_offset(screen_offset: Vector2) -> Vector3:
	return _projector.screen_to_world_offset(screen_offset)


func _screen_to_world_rotation(screen_rotation: float) -> float:
	return _projector.screen_to_world_rotation(screen_rotation)


func _max_texture(key: String) -> Texture2D:
	if _texture_cache.has(key):
		return _texture_cache[key]
	if _visual_registry == null or not _visual_registry.has_method("max_combat_vfx_texture"):
		return null
	var texture: Texture2D = _visual_registry.max_combat_vfx_texture(key)
	if texture != null:
		_texture_cache[key] = texture
	return texture


func _impact_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "fire_impact"
		"ice":
			return "ice_impact"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
		"damage":
			return "damage_impact"
	return "orb_clear"


func _projectile_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "fire_projectile"
		"ice":
			return "ice_projectile"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
	return "orb_clear"


func _trail_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
		"gold":
			return "spark_particles"
	return "smoke_puff"


func _mist_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
	return "smoke_puff"


func _particle_key(kind: String) -> String:
	match _clean_kind(kind):
		"fire":
			return "spark_particles"
		"ice":
			return "ice_shards"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
		"gold":
			return "coin_spin"
		"damage":
			return "spark_particles"
	return "spark_particles"


func _clean_kind(kind: String) -> String:
	var clean := kind.strip_edges().to_lower()
	if clean == "heal" or clean == "healing":
		return "heart"
	if clean == "block" or clean == "shield":
		return "armor"
	return clean


func _should_use_elemental_magic(kind: String) -> bool:
	return _clean_kind(kind) in ["fire", "ice", "earth", "heart", "armor", "gold"]


func _kind_for_orb(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.FIRE:
			return "fire"
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.ARMOR:
			return "armor"
		OrbType.Id.GOLD:
			return "gold"
	return "damage"


func _elemental_kind_colors(kind: String) -> Dictionary:
	match _clean_kind(kind):
		"fire":
			return {"primary": Color(1.0, 0.76, 0.20, 1.0), "secondary": Color(1.0, 0.22, 0.03, 1.0), "tertiary": Color(0.34, 0.02, 0.00, 1.0)}
		"ice":
			return {"primary": Color(0.90, 1.0, 1.0, 1.0), "secondary": Color(0.28, 0.84, 1.0, 1.0), "tertiary": Color(0.04, 0.18, 0.68, 1.0)}
		"earth":
			return {"primary": Color(0.66, 1.0, 0.26, 1.0), "secondary": Color(0.28, 0.58, 0.14, 1.0), "tertiary": Color(0.12, 0.16, 0.06, 1.0)}
		"heart":
			return {"primary": Color(0.86, 1.0, 0.78, 1.0), "secondary": Color(0.30, 1.0, 0.58, 1.0), "tertiary": Color(0.06, 0.35, 0.18, 1.0)}
		"armor":
			return {"primary": Color(0.94, 0.99, 1.0, 1.0), "secondary": Color(0.46, 0.78, 1.0, 1.0), "tertiary": Color(0.06, 0.16, 0.46, 1.0)}
		"gold":
			return {"primary": Color(1.0, 0.96, 0.44, 1.0), "secondary": Color(1.0, 0.58, 0.10, 1.0), "tertiary": Color(0.48, 0.18, 0.02, 1.0)}
	return {"primary": Color(1.0, 1.0, 1.0, 1.0), "secondary": Color(0.78, 0.86, 1.0, 1.0), "tertiary": Color(0.18, 0.24, 0.38, 1.0)}


func _kind_colors(kind: String) -> Dictionary:
	match _clean_kind(kind):
		"fire":
			return {"accent": Color(1.0, 0.25, 0.04, 1.0), "core": Color(1.0, 0.88, 0.35, 1.0)}
		"ice":
			return {"accent": Color(0.35, 0.86, 1.0, 1.0), "core": Color(0.88, 1.0, 1.0, 1.0)}
		"earth":
			return {"accent": Color(0.36, 0.62, 0.18, 1.0), "core": Color(0.78, 1.0, 0.34, 1.0)}
		"heart":
			return {"accent": Color(0.32, 1.0, 0.50, 1.0), "core": Color(0.84, 1.0, 0.76, 1.0)}
		"armor":
			return {"accent": Color(0.54, 0.80, 1.0, 1.0), "core": Color(0.92, 0.98, 1.0, 1.0)}
		"gold":
			return {"accent": Color(1.0, 0.68, 0.12, 1.0), "core": Color(1.0, 0.96, 0.42, 1.0)}
		"damage":
			return {"accent": Color(1.0, 0.18, 0.12, 1.0), "core": Color(1.0, 0.58, 0.44, 1.0)}
	return {"accent": Color(0.86, 0.90, 1.0, 1.0), "core": Color(1.0, 1.0, 1.0, 1.0)}


func _vfx_layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var layer_size := _vfx_layer.size
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			layer_size = viewport.get_visible_rect().size
	return layer_size


func _global_to_overlay_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position
