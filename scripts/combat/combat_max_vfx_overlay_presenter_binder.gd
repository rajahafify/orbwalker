extends RefCounted
class_name CombatMaxVfxOverlayPresenterBinder

var _presenters: Dictionary = {}
var _callbacks: Dictionary = {}
var _callback_owner: Object
var _effect_key_catalog: Variant
var _root_3d: Node3D
var _timer_owner: Node
var _camera: Camera3D


func bind(dependencies: Dictionary) -> void:
	_presenters = dependencies.get("presenters", {})
	_callbacks = dependencies.get("callbacks", {})
	_callback_owner = dependencies.get("callback_owner") as Object
	_effect_key_catalog = dependencies.get("effect_key_catalog")
	_root_3d = dependencies.get("root_3d") as Node3D
	_timer_owner = dependencies.get("timer_owner") as Node
	_camera = dependencies.get("camera") as Camera3D


func bind_presenters() -> void:
	var catalog: Variant = _effect_key_catalog
	(
		_presenter("flipbook")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"texture_provider": _callback("max_texture"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
				"screen_to_world_rotation": _callback("screen_to_world_rotation"),
			}
		)
	)
	(
		_presenter("imported_scene")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"flame_scene_provider": _callback("flame_scene"),
				"beam_scene_provider": _callback("beam_scene"),
				"shield_scene_provider": _callback("shield_scene"),
				"tornado_scene_provider": _callback("tornado_scene"),
				"kind_colors_provider": Callable(catalog, "elemental_kind_colors"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
			}
		)
	)
	(
		_presenter("sheet_flipbook")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"status_texture_provider": _callback("status_texture"),
				"atmospheric_texture_provider": _callback("atmospheric_texture"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
				"screen_to_world_rotation": _callback("screen_to_world_rotation"),
			}
		)
	)
	(
		_presenter("pack_scene")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"pack_scene_provider": _callback("pack_scene"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
				"screen_to_world_rotation": _callback("screen_to_world_rotation"),
			}
		)
	)
	(
		_presenter("elemental_scene")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"elemental_scene_provider": _callback("elemental_scene"),
				"elemental_kind_colors_provider": Callable(catalog, "elemental_kind_colors"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
				"screen_to_world_rotation": _callback("screen_to_world_rotation"),
			}
		)
	)
	(
		_presenter("fire_ambient")
		. bind(
			{
				"atmospheric_available_provider": _callback("atmospheric_vfx_available"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"light_spawner": _callback("spawn_light"),
			}
		)
	)
	(
		_presenter("fire_impact")
		. bind(
			{
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"elemental_effect_spawner": _callback("spawn_elemental_effect"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"spark_spray_spawner": _callback("spawn_fire_spark_spray"),
				"light_spawner": _callback("spawn_light"),
			}
		)
	)
	(
		_presenter("fire_attack")
		. bind(
			{
				"layer_size_provider": _callback("vfx_layer_size"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"elemental_effect_spawner": _callback("spawn_elemental_effect"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"spark_spray_spawner": _callback("spawn_fire_spark_spray"),
				"light_spawner": _callback("spawn_light"),
				"meteor_impact_spawner": _callback("spawn_fire_meteor_impact_layers"),
			}
		)
	)
	(
		_presenter("fire_recipe")
		. bind(
			{
				"tier_provider": _callback("fire_vfx_tier"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"flame_scene_spawner": _callback("spawn_flame_scene"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"burst_particles_spawner": _callback("spawn_burst_particles"),
				"spark_spray_spawner": _callback("spawn_fire_spark_spray"),
				"light_spawner": _callback("spawn_light"),
				"fireball_impact_spawner": _callback("spawn_fireball_impact_layers"),
				"meteor_impact_spawner": _callback("spawn_fire_meteor_impact_layers"),
				"fragmented_impact_spawner": _callback("spawn_fire_fragmented_impact_cluster"),
				"aurora_layer_spawner": _callback("spawn_fire_aurora_layer"),
				"screen_ember_field_spawner": _callback("spawn_fire_screen_ember_field"),
				"ember_lane_spawner": _callback("spawn_fire_ember_lane"),
				"status_path_afterimage_spawner": _callback("spawn_status_path_afterimage"),
				"beam_effect_spawner": _callback("spawn_beam_effect"),
				"fireball_spell_spawner": _callback("spawn_fireball_spell_layers"),
				"meteor_attack_spawner": _callback("spawn_fire_meteor_attack_layers"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
			}
		)
	)
	(
		_presenter("ice_recipe")
		. bind(
			{
				"tier_provider": _callback("ice_vfx_tier"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"burst_particles_spawner": _callback("spawn_burst_particles"),
				"light_spawner": _callback("spawn_light"),
				"status_path_afterimage_spawner": _callback("spawn_status_path_afterimage"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
			}
		)
	)
	(
		_presenter("earth_recipe")
		. bind(
			{
				"tier_provider": _callback("earth_vfx_tier"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"burst_particles_spawner": _callback("spawn_burst_particles"),
				"light_spawner": _callback("spawn_light"),
				"tornado_scene_spawner": _callback("spawn_tornado_scene"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
			}
		)
	)
	(
		_presenter("pack_recipe")
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"pack_effect_spawner": _callback("spawn_pack_effect"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"light_spawner": _callback("spawn_light"),
				"coin_rain_spawner": _callback("spawn_coin_rain"),
			}
		)
	)
	(
		_presenter("elemental_recipe")
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"elemental_effect_spawner": _callback("spawn_elemental_effect"),
				"effect_stretcher": _callback("stretch_effect"),
				"pack_impact_scene_key_provider": _callback("pack_impact_scene_key"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"coin_rain_spawner": _callback("spawn_coin_rain"),
				"light_spawner": _callback("spawn_light"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
			}
		)
	)
	(
		_presenter("atmospheric_recipe")
		. bind(
			{
				"atmospheric_available_provider": _callback("atmospheric_vfx_available"),
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"atmospheric_travel_key_provider": Callable(catalog, "atmospheric_travel_key"),
				"atmospheric_impact_key_provider": Callable(catalog, "atmospheric_impact_key"),
				"atmospheric_secondary_key_provider": Callable(catalog, "atmospheric_secondary_key"),
				"atmospheric_flipbook_spawner": _callback("spawn_atmospheric_flipbook"),
			}
		)
	)
	(
		_presenter("coin_rain")
		. bind(
			{
				"layer_size_provider": _callback("vfx_layer_size"),
				"flipbook_spawner": _callback("spawn_flipbook"),
			}
		)
	)
	(
		_presenter("status_recipe")
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"status_sheet_key_provider": Callable(catalog, "status_sheet_key"),
				"status_trail_key_provider": Callable(catalog, "status_trail_key"),
				"status_flipbook_spawner": _callback("spawn_status_flipbook"),
				"shield_scene_spawner": _callback("spawn_shield_scene"),
				"light_spawner": _callback("spawn_light"),
				"coin_rain_spawner": _callback("spawn_coin_rain"),
				"fire_replay_layers_spawner": _callback("spawn_fire_replay_layers"),
				"ice_replay_layers_spawner": _callback("spawn_ice_replay_layers"),
				"earth_replay_layers_spawner": _callback("spawn_earth_replay_layers"),
				"fire_cast_layers_spawner": _callback("spawn_fire_cast_layers"),
				"ice_cast_layers_spawner": _callback("spawn_ice_cast_layers"),
				"earth_cast_layers_spawner": _callback("spawn_earth_cast_layers"),
				"fire_beam_layers_spawner": _callback("spawn_fire_beam_layers"),
				"windy_ice_block_travel_spawner": _callback("spawn_windy_ice_block_travel_layers"),
				"earth_fracture_travel_spawner": _callback("spawn_earth_fracture_travel_layers"),
				"earth_tier_provider": _callback("earth_vfx_tier"),
				"pack_impact_scene_key_provider": _callback("pack_impact_scene_key"),
				"atmospheric_replay_layer_spawner": _callback("spawn_atmospheric_replay_layer"),
				"atmospheric_travel_spawner": _callback("spawn_atmospheric_travel"),
				"beam_effect_spawner": _callback("spawn_beam_effect"),
				"pack_layer_spawner": _callback("spawn_pack_layer"),
				"burst_particles_spawner": _callback("spawn_burst_particles"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
			}
		)
	)
	(
		_presenter("mastery_recipe")
		. bind(
			{
				"status_available_provider": _callback("status_vfx_available"),
				"elemental_available_provider": _callback("elemental_magic_available"),
				"pack_available_provider": _callback("pack_vfx_available"),
				"should_use_elemental_provider": Callable(catalog, "should_use_elemental_magic"),
				"kind_for_orb_provider": Callable(catalog, "kind_for_orb"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"status_cast_spawner": _callback("spawn_status_cast_recipe"),
				"elemental_cast_spawner": _callback("spawn_elemental_cast_recipe"),
				"pack_hit_scene_key_provider": _callback("pack_hit_scene_key"),
				"pack_impact_scene_key_provider": _callback("pack_impact_scene_key"),
				"pack_effect_spawner": _callback("spawn_pack_effect"),
				"light_spawner": _callback("spawn_light"),
				"camera_kick_spawner": _callback("spawn_camera_kick"),
				"impact_key_provider": Callable(catalog, "impact_key"),
				"projectile_key_provider": Callable(catalog, "projectile_key"),
				"trail_key_provider": Callable(catalog, "trail_key"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"status_beam_spawner": _callback("spawn_status_beam_recipe"),
				"elemental_beam_spawner": _callback("spawn_elemental_beam_recipe"),
			}
		)
	)
	(
		_presenter("burst_particles")
		. bind(
			{
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"particle_key_provider": Callable(catalog, "particle_key"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"gpu_particles_spawner": _callback("spawn_gpu_particles"),
			}
		)
	)
	(
		_presenter("screen_wide")
		. bind(
			{
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"impact_key_provider": Callable(catalog, "impact_key"),
				"layer_size_provider": _callback("vfx_layer_size"),
				"light_spawner": _callback("spawn_light"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"coin_rain_spawner": _callback("spawn_coin_rain"),
			}
		)
	)
	(
		_presenter("gpu_particles")
		. bind(
			{
				"root_3d": _root_3d,
				"texture_provider": _callback("max_texture"),
				"screen_to_world_position": _callback("screen_to_world_position"),
				"queue_free_after": _callback("queue_free_after"),
			}
		)
	)
	(
		_presenter("light")
		. bind(
			{
				"root_3d": _root_3d,
				"timer_owner": _timer_owner,
				"screen_to_world_position": _callback("screen_to_world_position"),
			}
		)
	)
	_presenter("cleanup").bind({"timer_owner": _timer_owner})
	(
		_presenter("camera_kick")
		. bind(
			{
				"camera": _camera,
				"timer_owner": _timer_owner,
				"layer_size_provider": _callback("vfx_layer_size"),
				"screen_to_world_offset": _callback("screen_to_world_offset"),
			}
		)
	)
	_presenter("projector").bind({"layer_size_provider": _callback("vfx_layer_size")})
	(
		_presenter("replay_impact_router")
		. bind(
			{
				"status_presenter": _presenter("status_recipe"),
				"elemental_presenter": _presenter("elemental_recipe"),
				"pack_presenter": _presenter("pack_recipe"),
				"status_available": _callback("status_vfx_available"),
				"elemental_available": _callback("elemental_magic_available"),
				"pack_available": _callback("pack_vfx_available"),
				"should_use_elemental": Callable(catalog, "should_use_elemental_magic"),
				"kind_colors": Callable(catalog, "kind_colors"),
				"impact_key": Callable(catalog, "impact_key"),
				"mist_key": Callable(catalog, "mist_key"),
				"light_spawner": _callback("spawn_light"),
				"flipbook_spawner": _callback("spawn_flipbook"),
				"burst_particles_spawner": _callback("spawn_burst_particles"),
				"screen_wide_spawner": _callback("spawn_screen_wide"),
				"coin_rain_spawner": _callback("spawn_coin_rain"),
			}
		)
	)


func _presenter(key: String) -> Variant:
	return _presenters.get(key)


func _callback(key: String) -> Callable:
	if _callbacks.has(key):
		return _callbacks.get(key, Callable())
	var method_name := StringName("_" + key)
	if _callback_owner != null and _callback_owner.has_method(method_name):
		return Callable(_callback_owner, method_name)
	return Callable()
