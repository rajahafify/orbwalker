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
const COMBAT_MAX_VFX_ASSET_STORE_SCRIPT := preload("res://scripts/combat/combat_max_vfx_asset_store.gd")
const COMBAT_MAX_VFX_SPAWN_GATEWAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_spawn_gateway.gd")
const COMBAT_MAX_VFX_RECIPE_GATEWAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_recipe_gateway.gd")
const COMBAT_MAX_VFX_ELEMENTAL_RECIPE_GATEWAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_gateway.gd")

var _vfx_layer: Control
var _visual_registry: Variant
var _timer_owner: Node
var _asset_catalog: Variant = COMBAT_MAX_VFX_ASSET_CATALOG_SCRIPT.new()
var _asset_store: Variant = COMBAT_MAX_VFX_ASSET_STORE_SCRIPT.new()
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
var _spawn_gateway: Variant = COMBAT_MAX_VFX_SPAWN_GATEWAY_SCRIPT.new()
var _recipe_gateway: Variant = COMBAT_MAX_VFX_RECIPE_GATEWAY_SCRIPT.new()
var _elemental_recipe_gateway: Variant = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_GATEWAY_SCRIPT.new()


func _init() -> void:
	_asset_store.bind(_asset_catalog, _visual_registry)


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_timer_owner = dependencies.get("timer_owner") as Node
	_asset_store.bind(_asset_catalog, _visual_registry)
	_ensure_overlay()


func is_available() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	if not _ensure_overlay():
		return false
	if _asset_store.status_vfx_available():
		return true
	if _asset_store.elemental_magic_available() or _asset_store.pack_vfx_available():
		return true
	if _visual_registry == null:
		return false
	for key in _asset_catalog.required_texture_keys():
		if _asset_store.max_texture(key) == null:
			return false
	return true


func required_texture_keys() -> Array[String]:
	return _asset_store.required_texture_keys()


func required_status_sheet_paths() -> Dictionary:
	return _asset_store.required_status_sheet_paths()


func required_atmospheric_sheet_paths() -> Dictionary:
	return _asset_store.required_atmospheric_sheet_paths()


func external_scene_paths() -> Dictionary:
	return _asset_store.external_scene_paths()


func spawn_replay_impact(
	global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, _result_amount: int, intensity: int, screen_wide: bool
) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var kind: String = _effect_key_catalog.clean_kind(clean_kind)
	var center := _global_to_overlay_local(global_center)
	var max_size := maxf(draw_size.x, draw_size.y)
	var basis_size: float = _elemental_recipe_gateway.replay_impact_basis_size(kind, draw_size, max_size)
	var base_size: float = basis_size * (2.25 + float(intensity) * 0.22)
	var duration := maxf(0.32, lifetime * 1.10)
	return _replay_impact_router.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_armor_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> bool:
	if not is_available() or global_center == Vector2.ZERO:
		return false
	var center := _global_to_overlay_local(global_center)
	var width := maxf(draw_size.x * 1.34, 260.0)
	var height := maxf(draw_size.y * 3.1, 150.0)
	if _asset_store.status_vfx_available():
		_recipe_gateway.spawn_status_armor_linger(center, Vector2(width, height), lifetime, intensity)
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
	if _asset_store.pack_vfx_available():
		_spawn_gateway.spawn_pack_effect("hit_02", source, "damage", Vector2(150, 150), lifetime * 1.10, 3, 0.0, Vector2.ZERO, -0.12, 1.0, 0.80)
		_spawn_gateway.spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
		return true
	_spawn_gateway.spawn_light(source, Color(1.0, 0.34, 0.48, 1.0), 1.5, 160.0, lifetime)
	_spawn_gateway.spawn_flipbook("enemy_attack", source, Vector2(180, 180), lifetime * 1.15, Color(1, 1, 1, 0.88), 0.0, Vector2.ZERO, 1.04, 1.0, -0.12)
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
	if _asset_store.pack_vfx_available():
		var intensity := clampi(int(round(delta.length() / 120.0)), 2, 8)
		_spawn_gateway.spawn_pack_effect(
			"hit_01", source, "damage", Vector2(112 + intensity * 7, 68 + intensity * 5), lifetime, intensity, 0.0, delta, angle, 1.3, 0.66
		)
		return true
	_spawn_gateway.spawn_flipbook("enemy_attack", source, Vector2(150, 88), lifetime, Color(1, 1, 1, 0.94), 0.0, delta, 0.78, 1.5, angle)
	_spawn_gateway.spawn_flipbook(
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
	if _asset_store.pack_vfx_available():
		_spawn_gateway.spawn_pack_effect("hit_01", center, "generic", size, lifetime * 1.10, 3, 0.0, Vector2.ZERO, 0.0, 0.0, color.a)
		return true
	_spawn_gateway.spawn_flipbook("orb_clear", center, size, lifetime * 1.15, color, 0.0, Vector2.ZERO, 1.12, 0.0, 0.0)
	return true


func _ensure_overlay() -> bool:
	_bind_elemental_recipe_gateway()
	_bind_recipe_gateway()
	_bind_spawn_gateway()
	_lifecycle.bind({"overlay": self})
	return _lifecycle.ensure_overlay()


func _bind_recipe_gateway() -> void:
	_recipe_gateway.bind(_presenter_map())


func _bind_elemental_recipe_gateway() -> void:
	_elemental_recipe_gateway.bind(_presenter_map(), _elemental_recipe_policy)


func _bind_spawn_gateway() -> void:
	_spawn_gateway.bind(_presenter_map(), Callable(self, "_ensure_overlay"), Callable(_asset_store, "pack_vfx_available"))


func _presenter_map() -> Dictionary:
	return {
		"flipbook": _flipbook_presenter,
		"imported_scene": _imported_scene_presenter,
		"sheet_flipbook": _sheet_flipbook_presenter,
		"pack_scene": _pack_scene_presenter,
		"elemental_scene": _elemental_scene_presenter,
		"burst_particles": _burst_particles_presenter,
		"screen_wide": _screen_wide_presenter,
		"coin_rain": _coin_rain_presenter,
		"gpu_particles": _gpu_particles_presenter,
		"light": _light_presenter,
		"camera_kick": _camera_kick_presenter,
		"cleanup": _cleanup_presenter,
		"projector": _projector,
	}


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
