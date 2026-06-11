extends RefCounted
class_name CombatMaxVfxOverlayLifecycle

const OVERLAY_Z_INDEX := 122


func ensure_overlay(owner: Variant) -> bool:
	if owner._vfx_layer == null or not is_instance_valid(owner._vfx_layer):
		return false
	var layer_size: Vector2 = owner._vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return false
	if owner._container != null and is_instance_valid(owner._container):
		_sync_overlay_size(owner, layer_size)
		bind_presenters(owner)
		return true
	owner._container = SubViewportContainer.new()
	owner._container.name = "CombatMaxVfx3DOverlay"
	owner._container.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	owner._container.z_index = OVERLAY_Z_INDEX
	owner._container.anchor_left = 0.0
	owner._container.anchor_top = 0.0
	owner._container.anchor_right = 0.0
	owner._container.anchor_bottom = 0.0
	owner._container.position = Vector2.ZERO
	owner._container.size = layer_size
	owner._container.stretch = true
	owner._vfx_layer.add_child(owner._container)

	owner._sub_viewport = SubViewport.new()
	owner._sub_viewport.name = "CombatMaxVfxViewport"
	owner._sub_viewport.transparent_bg = true
	owner._sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	owner._sub_viewport.size = Vector2i(int(layer_size.x), int(layer_size.y))
	owner._container.add_child(owner._sub_viewport)

	owner._root_3d = Node3D.new()
	owner._root_3d.name = "CombatMaxVfxRoot3D"
	owner._sub_viewport.add_child(owner._root_3d)

	owner._camera = Camera3D.new()
	owner._camera.name = "CombatMaxVfxCamera"
	owner._camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	owner._camera.current = true
	owner._root_3d.add_child(owner._camera)

	owner._ambient_light = DirectionalLight3D.new()
	owner._ambient_light.name = "CombatMaxVfxKeyLight"
	owner._ambient_light.light_color = Color(0.74, 0.82, 1.0, 1.0)
	owner._ambient_light.light_energy = 0.18
	owner._ambient_light.rotation_degrees = Vector3(-58.0, 18.0, 0.0)
	owner._root_3d.add_child(owner._ambient_light)
	_sync_overlay_size(owner, layer_size)
	bind_presenters(owner)
	return true


func bind_presenters(owner: Variant) -> void:
	var catalog: Variant = owner._effect_key_catalog
	(
		owner
		. _flipbook_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"texture_provider": Callable(owner, "_max_texture"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
				"screen_to_world_rotation": Callable(owner, "_screen_to_world_rotation"),
			}
		)
	)
	(
		owner
		. _imported_scene_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"flame_scene_provider": Callable(owner, "_flame_scene"),
				"beam_scene_provider": Callable(owner, "_beam_scene"),
				"shield_scene_provider": Callable(owner, "_shield_scene"),
				"tornado_scene_provider": Callable(owner, "_tornado_scene"),
				"kind_colors_provider": Callable(catalog, "elemental_kind_colors"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
			}
		)
	)
	(
		owner
		. _sheet_flipbook_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"status_texture_provider": Callable(owner, "_status_texture"),
				"atmospheric_texture_provider": Callable(owner, "_atmospheric_texture"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
				"screen_to_world_rotation": Callable(owner, "_screen_to_world_rotation"),
			}
		)
	)
	(
		owner
		. _pack_scene_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"pack_scene_provider": Callable(owner, "_pack_scene"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
				"screen_to_world_rotation": Callable(owner, "_screen_to_world_rotation"),
			}
		)
	)
	(
		owner
		. _elemental_scene_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"elemental_scene_provider": Callable(owner, "_elemental_scene"),
				"elemental_kind_colors_provider": Callable(catalog, "elemental_kind_colors"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
				"screen_to_world_rotation": Callable(owner, "_screen_to_world_rotation"),
			}
		)
	)
	(
		owner
		. _fire_ambient_presenter
		. bind(
			{
				"atmospheric_available_provider": Callable(owner, "_atmospheric_vfx_available"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"light_spawner": Callable(owner, "_spawn_light"),
			}
		)
	)
	(
		owner
		. _fire_impact_presenter
		. bind(
			{
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"elemental_effect_spawner": Callable(owner, "_spawn_elemental_effect"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"spark_spray_spawner": Callable(owner, "_spawn_fire_spark_spray"),
				"light_spawner": Callable(owner, "_spawn_light"),
			}
		)
	)
	(
		owner
		. _fire_attack_presenter
		. bind(
			{
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"elemental_effect_spawner": Callable(owner, "_spawn_elemental_effect"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"spark_spray_spawner": Callable(owner, "_spawn_fire_spark_spray"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"meteor_impact_spawner": Callable(owner, "_spawn_fire_meteor_impact_layers"),
			}
		)
	)
	(
		owner
		. _fire_recipe_presenter
		. bind(
			{
				"tier_provider": Callable(owner, "_fire_vfx_tier"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"flame_scene_spawner": Callable(owner, "_spawn_flame_scene"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"burst_particles_spawner": Callable(owner, "_spawn_burst_particles"),
				"spark_spray_spawner": Callable(owner, "_spawn_fire_spark_spray"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"fireball_impact_spawner": Callable(owner, "_spawn_fireball_impact_layers"),
				"meteor_impact_spawner": Callable(owner, "_spawn_fire_meteor_impact_layers"),
				"fragmented_impact_spawner": Callable(owner, "_spawn_fire_fragmented_impact_cluster"),
				"aurora_layer_spawner": Callable(owner, "_spawn_fire_aurora_layer"),
				"screen_ember_field_spawner": Callable(owner, "_spawn_fire_screen_ember_field"),
				"ember_lane_spawner": Callable(owner, "_spawn_fire_ember_lane"),
				"status_path_afterimage_spawner": Callable(owner, "_spawn_status_path_afterimage"),
				"beam_effect_spawner": Callable(owner, "_spawn_beam_effect"),
				"fireball_spell_spawner": Callable(owner, "_spawn_fireball_spell_layers"),
				"meteor_attack_spawner": Callable(owner, "_spawn_fire_meteor_attack_layers"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
			}
		)
	)
	(
		owner
		. _ice_recipe_presenter
		. bind(
			{
				"tier_provider": Callable(owner, "_ice_vfx_tier"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"burst_particles_spawner": Callable(owner, "_spawn_burst_particles"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"status_path_afterimage_spawner": Callable(owner, "_spawn_status_path_afterimage"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
			}
		)
	)
	(
		owner
		. _earth_recipe_presenter
		. bind(
			{
				"tier_provider": Callable(owner, "_earth_vfx_tier"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"burst_particles_spawner": Callable(owner, "_spawn_burst_particles"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"tornado_scene_spawner": Callable(owner, "_spawn_tornado_scene"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
			}
		)
	)
	(
		owner
		. _pack_recipe_presenter
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"pack_effect_spawner": Callable(owner, "_spawn_pack_effect"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"coin_rain_spawner": Callable(owner, "_spawn_coin_rain"),
			}
		)
	)
	(
		owner
		. _elemental_recipe_presenter
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"elemental_effect_spawner": Callable(owner, "_spawn_elemental_effect"),
				"effect_stretcher": Callable(owner, "_stretch_effect"),
				"pack_impact_scene_key_provider": Callable(owner, "_pack_impact_scene_key"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"coin_rain_spawner": Callable(owner, "_spawn_coin_rain"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
			}
		)
	)
	(
		owner
		. _atmospheric_recipe_presenter
		. bind(
			{
				"atmospheric_available_provider": Callable(owner, "_atmospheric_vfx_available"),
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"atmospheric_travel_key_provider": Callable(catalog, "atmospheric_travel_key"),
				"atmospheric_impact_key_provider": Callable(catalog, "atmospheric_impact_key"),
				"atmospheric_secondary_key_provider": Callable(catalog, "atmospheric_secondary_key"),
				"atmospheric_flipbook_spawner": Callable(owner, "_spawn_atmospheric_flipbook"),
			}
		)
	)
	(
		owner
		. _coin_rain_presenter
		. bind(
			{
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
			}
		)
	)
	(
		owner
		. _status_recipe_presenter
		. bind(
			{
				"kind_cleaner": Callable(catalog, "clean_kind"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"status_sheet_key_provider": Callable(catalog, "status_sheet_key"),
				"status_trail_key_provider": Callable(catalog, "status_trail_key"),
				"status_flipbook_spawner": Callable(owner, "_spawn_status_flipbook"),
				"shield_scene_spawner": Callable(owner, "_spawn_shield_scene"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"coin_rain_spawner": Callable(owner, "_spawn_coin_rain"),
				"fire_replay_layers_spawner": Callable(owner, "_spawn_fire_replay_layers"),
				"ice_replay_layers_spawner": Callable(owner, "_spawn_ice_replay_layers"),
				"earth_replay_layers_spawner": Callable(owner, "_spawn_earth_replay_layers"),
				"fire_cast_layers_spawner": Callable(owner, "_spawn_fire_cast_layers"),
				"ice_cast_layers_spawner": Callable(owner, "_spawn_ice_cast_layers"),
				"earth_cast_layers_spawner": Callable(owner, "_spawn_earth_cast_layers"),
				"fire_beam_layers_spawner": Callable(owner, "_spawn_fire_beam_layers"),
				"windy_ice_block_travel_spawner": Callable(owner, "_spawn_windy_ice_block_travel_layers"),
				"earth_fracture_travel_spawner": Callable(owner, "_spawn_earth_fracture_travel_layers"),
				"earth_tier_provider": Callable(owner, "_earth_vfx_tier"),
				"pack_impact_scene_key_provider": Callable(owner, "_pack_impact_scene_key"),
				"atmospheric_replay_layer_spawner": Callable(owner, "_spawn_atmospheric_replay_layer"),
				"atmospheric_travel_spawner": Callable(owner, "_spawn_atmospheric_travel"),
				"beam_effect_spawner": Callable(owner, "_spawn_beam_effect"),
				"pack_layer_spawner": Callable(owner, "_spawn_pack_layer"),
				"burst_particles_spawner": Callable(owner, "_spawn_burst_particles"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
			}
		)
	)
	(
		owner
		. _mastery_recipe_presenter
		. bind(
			{
				"status_available_provider": Callable(owner, "_status_vfx_available"),
				"elemental_available_provider": Callable(owner, "_elemental_magic_available"),
				"pack_available_provider": Callable(owner, "_pack_vfx_available"),
				"should_use_elemental_provider": Callable(catalog, "should_use_elemental_magic"),
				"kind_for_orb_provider": Callable(catalog, "kind_for_orb"),
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"status_cast_spawner": Callable(owner, "_spawn_status_cast_recipe"),
				"elemental_cast_spawner": Callable(owner, "_spawn_elemental_cast_recipe"),
				"pack_hit_scene_key_provider": Callable(owner, "_pack_hit_scene_key"),
				"pack_impact_scene_key_provider": Callable(owner, "_pack_impact_scene_key"),
				"pack_effect_spawner": Callable(owner, "_spawn_pack_effect"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"camera_kick_spawner": Callable(owner, "_spawn_camera_kick"),
				"impact_key_provider": Callable(catalog, "impact_key"),
				"projectile_key_provider": Callable(catalog, "projectile_key"),
				"trail_key_provider": Callable(catalog, "trail_key"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"status_beam_spawner": Callable(owner, "_spawn_status_beam_recipe"),
				"elemental_beam_spawner": Callable(owner, "_spawn_elemental_beam_recipe"),
			}
		)
	)
	(
		owner
		. _burst_particles_presenter
		. bind(
			{
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"particle_key_provider": Callable(catalog, "particle_key"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"gpu_particles_spawner": Callable(owner, "_spawn_gpu_particles"),
			}
		)
	)
	(
		owner
		. _screen_wide_presenter
		. bind(
			{
				"kind_colors_provider": Callable(catalog, "kind_colors"),
				"impact_key_provider": Callable(catalog, "impact_key"),
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"coin_rain_spawner": Callable(owner, "_spawn_coin_rain"),
			}
		)
	)
	(
		owner
		. _gpu_particles_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"texture_provider": Callable(owner, "_max_texture"),
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
				"queue_free_after": Callable(owner, "_queue_free_after"),
			}
		)
	)
	(
		owner
		. _light_presenter
		. bind(
			{
				"root_3d": owner._root_3d,
				"timer_owner": owner._timer_owner,
				"screen_to_world_position": Callable(owner, "_screen_to_world_position"),
			}
		)
	)
	owner._cleanup_presenter.bind({"timer_owner": owner._timer_owner})
	(
		owner
		. _camera_kick_presenter
		. bind(
			{
				"camera": owner._camera,
				"timer_owner": owner._timer_owner,
				"layer_size_provider": Callable(owner, "_vfx_layer_size"),
				"screen_to_world_offset": Callable(owner, "_screen_to_world_offset"),
			}
		)
	)
	owner._projector.bind({"layer_size_provider": Callable(owner, "_vfx_layer_size")})
	(
		owner
		. _replay_impact_router
		. bind(
			{
				"status_presenter": owner._status_recipe_presenter,
				"elemental_presenter": owner._elemental_recipe_presenter,
				"pack_presenter": owner._pack_recipe_presenter,
				"status_available": Callable(owner, "_status_vfx_available"),
				"elemental_available": Callable(owner, "_elemental_magic_available"),
				"pack_available": Callable(owner, "_pack_vfx_available"),
				"should_use_elemental": Callable(catalog, "should_use_elemental_magic"),
				"kind_colors": Callable(catalog, "kind_colors"),
				"impact_key": Callable(catalog, "impact_key"),
				"mist_key": Callable(catalog, "mist_key"),
				"armor_grid_snap_spawner": Callable(owner, "_spawn_max_armor_grid_snap"),
				"light_spawner": Callable(owner, "_spawn_light"),
				"flipbook_spawner": Callable(owner, "_spawn_flipbook"),
				"burst_particles_spawner": Callable(owner, "_spawn_burst_particles"),
				"screen_wide_spawner": Callable(owner, "_spawn_screen_wide"),
				"coin_rain_spawner": Callable(owner, "_spawn_coin_rain"),
			}
		)
	)


func _sync_overlay_size(owner: Variant, layer_size: Vector2) -> void:
	if owner._container != null and is_instance_valid(owner._container):
		owner._container.size = layer_size
	if owner._sub_viewport != null and is_instance_valid(owner._sub_viewport):
		var next_size := Vector2i(maxi(1, int(layer_size.x)), maxi(1, int(layer_size.y)))
		if owner._sub_viewport.size != next_size:
			owner._sub_viewport.size = next_size
	if owner._camera != null and is_instance_valid(owner._camera):
		owner._camera.size = layer_size.y
		owner._camera.position = Vector3(layer_size.x * 0.5, layer_size.y * 0.5, 1000.0)
		owner._camera.rotation = Vector3.ZERO
