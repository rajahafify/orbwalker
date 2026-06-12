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
const COMBAT_MAX_VFX_EFFECT_KEY_CATALOG_SCRIPT := preload("res://scripts/combat/combat_max_vfx_effect_key_catalog.gd")
const COMBAT_MAX_VFX_OVERLAY_LIFECYCLE_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay_lifecycle.gd")
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
var _effect_key_catalog: Variant = COMBAT_MAX_VFX_EFFECT_KEY_CATALOG_SCRIPT.new()
var _lifecycle: Variant = COMBAT_MAX_VFX_OVERLAY_LIFECYCLE_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_timer_owner = dependencies.get("timer_owner") as Node
	_ensure_overlay()


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


func spawn_replay_impact(
	global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, _result_amount: int, intensity: int, screen_wide: bool
) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var kind: String = _effect_key_catalog.clean_kind(clean_kind)
	var center := _global_to_overlay_local(global_center)
	var max_size := maxf(draw_size.x, draw_size.y)
	var basis_size := _replay_impact_basis_size(kind, draw_size, max_size)
	var base_size := basis_size * (2.25 + float(intensity) * 0.22)
	var duration := maxf(0.32, lifetime * 1.10)
	return _replay_impact_router.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_armor_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var width := maxf(draw_size.x * 1.34, 260.0)
	var height := maxf(draw_size.y * 3.1, 150.0)
	if _status_vfx_available():
		_spawn_status_armor_linger(center, Vector2(width, height), lifetime, intensity)
		return true
	return _replay_impact_router.spawn_armor_linger(center, Vector2(width, height), lifetime, intensity)


func spawn_mastery_cast_sequence(
	orb_id: int, source_global: Vector2, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int
) -> bool:
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
	_spawn_flipbook(
		"light_rays", source + delta * 0.5, Vector2(delta.length(), 34.0), lifetime * 0.74, Color(1.0, 0.35, 0.52, 0.56), 0.0, Vector2.ZERO, 0.50, 0.3, angle
	)
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
	_lifecycle.bind({"overlay": self})
	return _lifecycle.ensure_overlay()


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


func _spawn_status_replay_recipe(
	kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_status_recipe_presenter.spawn_replay_recipe(kind, center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _fire_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.fire_tier(intensity, screen_wide)


func _ice_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.ice_tier(intensity, screen_wide)


func _earth_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.earth_tier(intensity, screen_wide)


func _replay_impact_basis_size(kind: String, draw_size: Vector2, fallback_size: float) -> float:
	return _elemental_recipe_policy.replay_impact_basis_size(kind, draw_size, fallback_size)


func _spawn_fire_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_fire_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_fire_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_fire_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	_fire_recipe_presenter.spawn_beam_layers(source, delta, duration, intensity, angle)


func _spawn_fire_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	_fire_ambient_presenter.spawn_ember_lane(source, delta, launch_delay, travel_duration, intensity, angle, tier)


func _spawn_fireball_spell_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	source_size: Vector2,
	impact_size: Vector2,
	launch_delay: float,
	travel_duration: float,
	intensity: int,
	angle: float
) -> void:
	_fire_attack_presenter.spawn_fireball_spell_layers(source, target, delta, source_size, impact_size, launch_delay, travel_duration, intensity, angle)


func _spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	_fire_impact_presenter.spawn_fireball_impact_layers(center, impact_size, duration, intensity, max_size)


func _spawn_fire_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	_fire_attack_presenter.spawn_meteor_attack_layers(target, launch_delay, travel_duration, intensity, impact_size)


func _spawn_fire_meteor_impact_layers(
	center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool = false
) -> void:
	_fire_impact_presenter.spawn_meteor_impact_layers(center, impact_size, duration, intensity, delay, fragmented_wide)


func _spawn_fire_fragmented_impact_cluster(
	center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float = 1.0, rotation: float = 0.0
) -> void:
	_fire_impact_presenter.spawn_fragmented_impact_cluster(center, draw_size, duration, intensity, delay, alpha_scale, rotation)


func _spawn_fire_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_fire_ambient_presenter.spawn_screen_ember_field(center, lifetime, intensity, delay, alpha_scale)


func _spawn_fire_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	_fire_ambient_presenter.spawn_spark_spray(center, radius, lifetime, intensity, delay, tier)


func _spawn_fire_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_fire_ambient_presenter.spawn_aurora_layer(center, lifetime, intensity, delay, alpha_scale)


func _spawn_ice_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_ice_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_ice_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_ice_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_windy_ice_block_travel_layers(
	source: Vector2,
	_target: Vector2,
	delta: Vector2,
	normal: Vector2,
	source_size: Vector2,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	angle: float
) -> void:
	_ice_recipe_presenter.spawn_windy_block_travel_layers(source, _target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle)


func _spawn_earth_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_earth_recipe_presenter.spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func _spawn_earth_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_earth_recipe_presenter.spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func _spawn_earth_fracture_travel_layers(
	source: Vector2,
	_target: Vector2,
	delta: Vector2,
	normal: Vector2,
	source_size: Vector2,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	angle: float,
	tier: int
) -> void:
	_earth_recipe_presenter.spawn_fracture_travel_layers(source, _target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle, tier)


func _spawn_status_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_status_recipe_presenter.spawn_armor_linger(center, draw_size, lifetime, intensity)


func _spawn_status_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color,
	accent: Color
) -> void:
	_status_recipe_presenter.spawn_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)


func _spawn_status_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_status_recipe_presenter.spawn_beam_recipe(kind, source, delta, lifetime, intensity, angle)


func _spawn_status_path_afterimage(
	kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float
) -> void:
	_status_recipe_presenter.spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_status_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_status_recipe_presenter.spawn_screen_wide(kind, center, lifetime, intensity)


func _spawn_atmospheric_replay_layer(
	kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool
) -> void:
	_atmospheric_recipe_presenter.spawn_replay_layer(kind, center, max_size, base_size, lifetime, intensity, screen_wide)


func _spawn_atmospheric_travel(
	kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float
) -> void:
	_atmospheric_recipe_presenter.spawn_travel(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func _spawn_atmospheric_flipbook(
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
	if not _ensure_overlay():
		return null
	return _sheet_flipbook_presenter.spawn_atmospheric_flipbook(
		sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops
	)


func _spawn_status_flipbook(
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
	if not _ensure_overlay():
		return null
	return _sheet_flipbook_presenter.spawn_status_flipbook(
		sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops, spin
	)


func _spawn_flame_scene(
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	z: float = 0.0,
	alpha: float = 1.0
) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_flame_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, alpha)


func _spawn_beam_effect(
	source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float = 0.0, radius_scale: float = 1.0
) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_beam_effect(source_local, delta, kind, lifetime, intensity, delay, radius_scale)


func _spawn_shield_scene(
	center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, z: float = 0.0
) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_shield_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z)


func _spawn_tornado_scene(
	center_local: Vector2,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float = 0.0,
	move_offset: Vector2 = Vector2.ZERO,
	z: float = 0.0,
	keep_child_name: String = ""
) -> Node3D:
	if not _ensure_overlay():
		return null
	return _imported_scene_presenter.spawn_tornado_scene(center_local, draw_size, lifetime, intensity, delay, move_offset, z, keep_child_name)


func _spawn_elemental_replay_recipe(
	kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_elemental_recipe_presenter.spawn_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)


func _spawn_elemental_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color
) -> void:
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


func _spawn_elemental_effect(
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
	if not _ensure_overlay():
		return null
	return _elemental_scene_presenter.spawn_elemental_effect(
		scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha
	)


func _spawn_elemental_path_afterimage(
	kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float
) -> void:
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


func _spawn_pack_effect(
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
	if not _ensure_overlay():
		return null
	return _pack_scene_presenter.spawn_pack_effect(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_pack_layer(
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


func _spawn_flipbook(
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
