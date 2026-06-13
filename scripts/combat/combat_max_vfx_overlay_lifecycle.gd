extends RefCounted
class_name CombatMaxVfxOverlayLifecycle

const OVERLAY_Z_INDEX := 122
const PRESENTER_BINDER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay_presenter_binder.gd")

var _vfx_layer: Control
var _timer_owner: Node
var _container: SubViewportContainer
var _sub_viewport: SubViewport
var _root_3d: Node3D
var _camera: Camera3D
var _ambient_light: DirectionalLight3D
var _effect_key_catalog: Variant
var _callback_owner: Object
var _presenters: Dictionary = {}
var _callbacks: Dictionary = {}
var _presenter_binder: Variant = PRESENTER_BINDER_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	var overlay := dependencies.get("overlay") as Object
	if overlay != null:
		_bind_overlay(overlay)
		return
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_effect_key_catalog = dependencies.get("effect_key_catalog")
	_callback_owner = dependencies.get("callback_owner") as Object
	_presenters = dependencies.get("presenters", {})
	_callbacks = dependencies.get("callbacks", {})


func _bind_overlay(overlay: Object) -> void:
	_vfx_layer = overlay.get("_vfx_layer") as Control
	_timer_owner = overlay.get("_timer_owner") as Node
	_effect_key_catalog = overlay.get("_effect_key_catalog")
	var asset_store: Variant = overlay.get("_asset_store")
	var spawn_gateway: Variant = overlay.get("_spawn_gateway")
	var recipe_gateway: Variant = overlay.get("_recipe_gateway")
	var elemental_recipe_gateway: Variant = overlay.get("_elemental_recipe_gateway")
	_callback_owner = overlay
	_callbacks = _asset_store_callbacks(asset_store)
	_callbacks.merge(_spawn_gateway_callbacks(spawn_gateway), true)
	_callbacks.merge(_recipe_gateway_callbacks(recipe_gateway), true)
	_callbacks.merge(_recipe_gateway_callbacks(elemental_recipe_gateway), true)
	_presenters = {
		"flipbook": overlay.get("_flipbook_presenter"),
		"imported_scene": overlay.get("_imported_scene_presenter"),
		"sheet_flipbook": overlay.get("_sheet_flipbook_presenter"),
		"pack_scene": overlay.get("_pack_scene_presenter"),
		"elemental_scene": overlay.get("_elemental_scene_presenter"),
		"fire_ambient": overlay.get("_fire_ambient_presenter"),
		"fire_impact": overlay.get("_fire_impact_presenter"),
		"fire_attack": overlay.get("_fire_attack_presenter"),
		"fire_recipe": overlay.get("_fire_recipe_presenter"),
		"ice_recipe": overlay.get("_ice_recipe_presenter"),
		"earth_recipe": overlay.get("_earth_recipe_presenter"),
		"pack_recipe": overlay.get("_pack_recipe_presenter"),
		"elemental_recipe": overlay.get("_elemental_recipe_presenter"),
		"atmospheric_recipe": overlay.get("_atmospheric_recipe_presenter"),
		"coin_rain": overlay.get("_coin_rain_presenter"),
		"status_recipe": overlay.get("_status_recipe_presenter"),
		"mastery_recipe": overlay.get("_mastery_recipe_presenter"),
		"burst_particles": overlay.get("_burst_particles_presenter"),
		"screen_wide": overlay.get("_screen_wide_presenter"),
		"gpu_particles": overlay.get("_gpu_particles_presenter"),
		"light": overlay.get("_light_presenter"),
		"cleanup": overlay.get("_cleanup_presenter"),
		"camera_kick": overlay.get("_camera_kick_presenter"),
		"projector": overlay.get("_projector"),
		"replay_impact_router": overlay.get("_replay_impact_router"),
	}


func _asset_store_callbacks(asset_store: Variant) -> Dictionary:
	if asset_store == null:
		return {}
	return {
		"max_texture": Callable(asset_store, "max_texture"),
		"flame_scene": Callable(asset_store, "flame_scene"),
		"beam_scene": Callable(asset_store, "beam_scene"),
		"shield_scene": Callable(asset_store, "shield_scene"),
		"tornado_scene": Callable(asset_store, "tornado_scene"),
		"status_texture": Callable(asset_store, "status_texture"),
		"atmospheric_texture": Callable(asset_store, "atmospheric_texture"),
		"pack_scene": Callable(asset_store, "pack_scene"),
		"elemental_scene": Callable(asset_store, "elemental_scene"),
		"atmospheric_vfx_available": Callable(asset_store, "atmospheric_vfx_available"),
		"status_vfx_available": Callable(asset_store, "status_vfx_available"),
		"elemental_magic_available": Callable(asset_store, "elemental_magic_available"),
		"pack_vfx_available": Callable(asset_store, "pack_vfx_available"),
	}


func _spawn_gateway_callbacks(spawn_gateway: Variant) -> Dictionary:
	if spawn_gateway == null:
		return {}
	return spawn_gateway.callbacks()


func _recipe_gateway_callbacks(recipe_gateway: Variant) -> Dictionary:
	if recipe_gateway == null:
		return {}
	return recipe_gateway.callbacks()


func ensure_overlay() -> bool:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return false
	var layer_size: Vector2 = _layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return false
	if _container != null and is_instance_valid(_container):
		_sync_overlay_size(layer_size)
		bind_presenters()
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
	bind_presenters()
	return true


func bind_presenters() -> void:
	(
		_presenter_binder
		. bind(
			{
				"presenters": _presenters,
				"callbacks": _callbacks,
				"callback_owner": _callback_owner,
				"effect_key_catalog": _effect_key_catalog,
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"camera": _camera,
			}
		)
	)
	_presenter_binder.bind_presenters()


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


func _layer_size() -> Vector2:
	var provider := _callback("vfx_layer_size")
	if provider.is_valid():
		return provider.call()
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	return _vfx_layer.size


func _presenter(key: String) -> Variant:
	return _presenters.get(key)


func _callback(key: String) -> Callable:
	if _callbacks.has(key):
		return _callbacks.get(key, Callable())
	var method_name := StringName("_" + key)
	if _callback_owner != null and _callback_owner.has_method(method_name):
		return Callable(_callback_owner, method_name)
	return Callable()
