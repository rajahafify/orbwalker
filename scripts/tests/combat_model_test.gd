extends RefCounted
class_name CombatModelTest

const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const COMBAT_ARMOR_LINGER_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_armor_linger_vfx_presenter.gd")
const COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_attack_vfx_presenter.gd")
const COMBAT_POST_MATCH_VFX_POLICY_SCRIPT := preload("res://scripts/combat/combat_post_match_vfx_policy.gd")
const COMBAT_RESULT_LABEL_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_result_label_presenter.gd")
const COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_primitive_presenter.gd")
const COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_sprite_presenter.gd")
const COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_texture_factory.gd")
const COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_feedback_presenter.gd")
const COMBAT_SCREEN_WIDE_REPLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_wide_replay_presenter.gd")
const COMBAT_SPARK_BURST_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_spark_burst_presenter.gd")
const COMBAT_STYLIZED_REPLAY_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_stylized_replay_vfx_presenter.gd")
const COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_fill_vfx_presenter.gd")
const COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_cast_vfx_presenter.gd")
const COMBAT_VFX_PROFILE_SCRIPT := preload("res://scripts/combat/combat_vfx_profile.gd")
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
const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")


class FakeMasteryHud:
	extends RefCounted

	func get_combat_mastery_card(row: Control, orb_id: int) -> Control:
		return row.get_node_or_null("CombatMasteryCard%d" % orb_id) as Control


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("combat_speed_accepts_modes_and_defaults_invalid", _test_combat_speed_accepts_modes_and_defaults_invalid, failures)
	_run_case("pending_scene_path_set_take_clear", _test_pending_scene_path_set_take_clear, failures)
	_run_case("outcome_transition_queue_marks_once_until_cleared", _test_outcome_transition_queue_marks_once_until_cleared, failures)
	_run_case("hud_staging_enemy_damage_consumes_block_before_hp", _test_hud_staging_enemy_damage_consumes_block_before_hp, failures)
	_run_case("hud_staging_clamps_player_values", _test_hud_staging_clamps_player_values, failures)
	_run_case("mastery_preview_accumulates_releases_consumes_and_resets", _test_mastery_preview_accumulates_releases_consumes_and_resets, failures)
	_run_case("resolve_trace_begin_pass_end_state", _test_resolve_trace_begin_pass_end_state, failures)
	_run_case("post_match_vfx_registry_exposes_distinct_results", _test_post_match_vfx_registry_exposes_distinct_results, failures)
	_run_case("raw_pack_combat_vfx_scenes_are_available", _test_raw_pack_combat_vfx_scenes_are_available, failures)
	_run_case("new_raw_status_and_scene_vfx_assets_are_available", _test_new_raw_status_and_scene_vfx_assets_are_available, failures)
	_run_case("combat_vfx_presenter_quality_switches_max_and_low_modes", _test_combat_vfx_presenter_quality_switches_max_and_low_modes, failures)
	_run_case("combat_max_vfx_asset_catalog_exposes_required_paths", _test_combat_max_vfx_asset_catalog_exposes_required_paths, failures)
	_run_case("combat_max_vfx_flipbook_presenter_spawns_sprite3d", _test_combat_max_vfx_flipbook_presenter_spawns_sprite3d, failures)
	_run_case("combat_max_vfx_imported_scene_presenter_spawns_and_filters_scenes", _test_combat_max_vfx_imported_scene_presenter_spawns_and_filters_scenes, failures)
	_run_case("combat_max_vfx_sheet_flipbook_presenter_spawns_status_and_atmospheric_sprites", _test_combat_max_vfx_sheet_flipbook_presenter_spawns_status_and_atmospheric_sprites, failures)
	_run_case("combat_max_vfx_pack_scene_presenter_spawns_projected_effects", _test_combat_max_vfx_pack_scene_presenter_spawns_projected_effects, failures)
	_run_case("combat_max_vfx_elemental_scene_presenter_spawns_projected_effects", _test_combat_max_vfx_elemental_scene_presenter_spawns_projected_effects, failures)
	_run_case("combat_max_vfx_elemental_recipe_policy_tiers_and_sizes", _test_combat_max_vfx_elemental_recipe_policy_tiers_and_sizes, failures)
	_run_case("combat_max_vfx_fire_ambient_presenter_spawns_screen_and_sparks", _test_combat_max_vfx_fire_ambient_presenter_spawns_screen_and_sparks, failures)
	_run_case("combat_max_vfx_fire_impact_presenter_spawns_fireball_and_fragmented_layers", _test_combat_max_vfx_fire_impact_presenter_spawns_fireball_and_fragmented_layers, failures)
	_run_case("combat_max_vfx_fire_attack_presenter_spawns_fireball_and_meteor_layers", _test_combat_max_vfx_fire_attack_presenter_spawns_fireball_and_meteor_layers, failures)
	_run_case("combat_max_vfx_fire_recipe_presenter_routes_replay_cast_and_beam", _test_combat_max_vfx_fire_recipe_presenter_routes_replay_cast_and_beam, failures)
	_run_case("combat_max_vfx_ice_recipe_presenter_routes_replay_cast_and_travel", _test_combat_max_vfx_ice_recipe_presenter_routes_replay_cast_and_travel, failures)
	_run_case("combat_max_vfx_earth_recipe_presenter_routes_replay_cast_and_fracture", _test_combat_max_vfx_earth_recipe_presenter_routes_replay_cast_and_fracture, failures)
	_run_case("combat_max_vfx_pack_recipe_presenter_maps_keys_and_screen_wide", _test_combat_max_vfx_pack_recipe_presenter_maps_keys_and_screen_wide, failures)
	_run_case("combat_max_vfx_elemental_recipe_presenter_spawns_afterimage_and_screen_wide", _test_combat_max_vfx_elemental_recipe_presenter_spawns_afterimage_and_screen_wide, failures)
	_run_case("combat_max_vfx_atmospheric_recipe_presenter_spawns_replay_and_travel_layers", _test_combat_max_vfx_atmospheric_recipe_presenter_spawns_replay_and_travel_layers, failures)
	_run_case("combat_max_vfx_coin_rain_presenter_spawns_local_and_screen_wide_rain", _test_combat_max_vfx_coin_rain_presenter_spawns_local_and_screen_wide_rain, failures)
	_run_case("combat_max_vfx_status_recipe_presenter_spawns_afterimage_and_screen_wide", _test_combat_max_vfx_status_recipe_presenter_spawns_afterimage_and_screen_wide, failures)
	_run_case("combat_max_vfx_mastery_recipe_presenter_routes_cast_and_beam", _test_combat_max_vfx_mastery_recipe_presenter_routes_cast_and_beam, failures)
	_run_case("combat_max_vfx_burst_particles_presenter_spawns_flipbooks_and_gpu_particles", _test_combat_max_vfx_burst_particles_presenter_spawns_flipbooks_and_gpu_particles, failures)
	_run_case("combat_max_vfx_screen_wide_presenter_spawns_fallback_layers", _test_combat_max_vfx_screen_wide_presenter_spawns_fallback_layers, failures)
	_run_case("combat_max_vfx_gpu_particles_presenter_spawns_configured_particles", _test_combat_max_vfx_gpu_particles_presenter_spawns_configured_particles, failures)
	_run_case("combat_max_vfx_light_presenter_spawns_projected_light", _test_combat_max_vfx_light_presenter_spawns_projected_light, failures)
	_run_case("combat_max_vfx_cleanup_presenter_queues_without_timer_tree", _test_combat_max_vfx_cleanup_presenter_queues_without_timer_tree, failures)
	_run_case("combat_max_vfx_camera_kick_presenter_ignores_missing_tree", _test_combat_max_vfx_camera_kick_presenter_ignores_missing_tree, failures)
	_run_case("combat_max_vfx_projector_maps_screen_to_world_space", _test_combat_max_vfx_projector_maps_screen_to_world_space, failures)
	_run_case("post_match_vfx_policy_normalizes_tiers_and_caps", _test_post_match_vfx_policy_normalizes_tiers_and_caps, failures)
	_run_case("runtime_vfx_texture_factory_generates_and_caches_keys", _test_runtime_vfx_texture_factory_generates_and_caches_keys, failures)
	_run_case("combat_vfx_profile_maps_orbs_and_result_colors", _test_combat_vfx_profile_maps_orbs_and_result_colors, failures)
	_run_case("enemy_attack_vfx_presenter_spawns_fallback_cues", _test_enemy_attack_vfx_presenter_spawns_fallback_cues, failures)
	_run_case("result_label_presenter_spawns_scaled_labels", _test_result_label_presenter_spawns_scaled_labels, failures)
	_run_case("runtime_vfx_sprite_presenter_spawns_materialized_sprites", _test_runtime_vfx_sprite_presenter_spawns_materialized_sprites, failures)
	_run_case("runtime_vfx_primitive_presenter_maps_effects_and_spawns_primitives", _test_runtime_vfx_primitive_presenter_maps_effects_and_spawns_primitives, failures)
	_run_case("screen_wide_replay_presenter_spawns_offensive_and_support_events", _test_screen_wide_replay_presenter_spawns_offensive_and_support_events, failures)
	_run_case("screen_feedback_presenter_honors_flags_and_spawns_nudge", _test_screen_feedback_presenter_honors_flags_and_spawns_nudge, failures)
	_run_case("spark_burst_presenter_honors_flags_and_particle_caps", _test_spark_burst_presenter_honors_flags_and_particle_caps, failures)
	_run_case("mastery_fill_vfx_presenter_spawns_stream_and_reduced_motion", _test_mastery_fill_vfx_presenter_spawns_stream_and_reduced_motion, failures)
	_run_case("mastery_cast_vfx_presenter_spawns_spool_travel_and_source_pulse", _test_mastery_cast_vfx_presenter_spawns_spool_travel_and_source_pulse, failures)
	_run_case("armor_linger_vfx_presenter_spawns_hex_grid_snap", _test_armor_linger_vfx_presenter_spawns_hex_grid_snap, failures)
	_run_case("stylized_replay_vfx_presenter_spawns_signature_and_kind_layers", _test_stylized_replay_vfx_presenter_spawns_signature_and_kind_layers, failures)
	_run_case("post_match_vfx_runtime_primitives_are_capped", _test_post_match_vfx_runtime_primitives_are_capped, failures)
	_run_case("post_match_vfx_speed_scale_slows_lifetime", _test_post_match_vfx_speed_scale_slows_lifetime, failures)
	_run_case("post_match_vfx_second_tier_is_lowest", _test_post_match_vfx_second_tier_is_lowest, failures)
	_run_case("post_match_vfx_top_tier_becomes_screen_wide", _test_post_match_vfx_top_tier_becomes_screen_wide, failures)
	_run_case("low_quality_mastery_beam_spawns_pronounced_layers", _test_low_quality_mastery_beam_spawns_pronounced_layers, failures)
	_run_case("healing_replay_impact_uses_bar_infusion", _test_healing_replay_impact_uses_bar_infusion, failures)
	_run_case("armor_replay_impact_uses_hex_grid_without_legacy_texture", _test_armor_replay_impact_uses_hex_grid_without_legacy_texture, failures)
	_run_case("mastery_fill_stream_spawns_runtime_stream_and_impact", _test_mastery_fill_stream_spawns_runtime_stream_and_impact, failures)
	_run_case("mastery_fill_stream_reduced_motion_uses_static_pulse", _test_mastery_fill_stream_reduced_motion_uses_static_pulse, failures)
	_run_case("board_lock_visual_state_captures_pointer_input", _test_board_lock_visual_state_captures_pointer_input, failures)

	return {
		"passed": failures.is_empty(),
		"total": 60,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_combat_speed_accepts_modes_and_defaults_invalid() -> String:
	var model := CombatModel.new()
	var modes: Array[String] = ["slow", "normal", "fast", "instant"]
	for mode in modes:
		model.set_combat_speed(mode)
		if model.combat_speed() != mode:
			return "Expected combat_speed %s, got %s." % [mode, model.combat_speed()]
	model.set_combat_speed("  FAST  ")
	if model.combat_speed() != "fast":
		return "Expected normalized combat_speed fast."
	model.set_combat_speed("turbo")
	if model.combat_speed() != "normal":
		return "Expected invalid combat_speed to default to normal."
	return ""


func _test_pending_scene_path_set_take_clear() -> String:
	var model := CombatModel.new()
	if model.pending_next_scene_path() != "":
		return "Expected empty pending path by default."
	model.set_pending_next_scene_path("res://scenes/shop.tscn")
	if model.pending_next_scene_path() != "res://scenes/shop.tscn":
		return "Expected pending path to be stored."
	var taken := model.take_pending_next_scene_path()
	if taken != "res://scenes/shop.tscn":
		return "Expected take_pending_next_scene_path to return stored path."
	if model.pending_next_scene_path() != "":
		return "Expected take_pending_next_scene_path to clear stored path."
	model.set_pending_next_scene_path("res://scenes/run_summary.tscn")
	model.clear_pending_next_scene_path()
	if model.pending_next_scene_path() != "":
		return "Expected clear_pending_next_scene_path to clear stored path."
	return ""


func _test_outcome_transition_queue_marks_once_until_cleared() -> String:
	var model := CombatModel.new()
	if model.is_outcome_transition_queued():
		return "Expected outcome transition queue to start false."
	if not model.mark_outcome_transition_queued():
		return "Expected first mark_outcome_transition_queued to return true."
	if not model.is_outcome_transition_queued():
		return "Expected outcome transition queue to be true after mark."
	if model.mark_outcome_transition_queued():
		return "Expected second mark_outcome_transition_queued to return false."
	model.clear_outcome_transition_queued()
	if model.is_outcome_transition_queued():
		return "Expected clear_outcome_transition_queued to reset queue."
	if not model.mark_outcome_transition_queued():
		return "Expected mark to work again after clear."
	return ""


func _test_hud_staging_enemy_damage_consumes_block_before_hp() -> String:
	var model := CombatModel.new()
	model.begin_hud_staging({
		"enemy_hp": 100,
		"enemy_turn_block": 10,
	})
	model.stage_enemy_damage_step(15, 100, 10)
	if model.staged_hud_value("enemy_turn_block", -1) != 0:
		return "Expected enemy block to be fully consumed."
	if model.staged_hud_value("enemy_hp", -1) != 95:
		return "Expected only unblocked 5 damage to reach enemy HP."
	model.stage_enemy_damage_step(500, 100, 10)
	if model.staged_hud_value("enemy_hp", -1) != 0:
		return "Expected enemy HP to clamp at zero."
	return ""


func _test_hud_staging_clamps_player_values() -> String:
	var model := CombatModel.new()
	model.begin_hud_staging({})
	model.stage_player_hp(150, 100)
	model.stage_player_armor(-4)
	model.stage_gold(-8)
	if model.staged_hud_value("player_hp", -1) != 100:
		return "Expected player HP to clamp to max HP."
	if model.staged_hud_value("player_armor", -1) != 0:
		return "Expected player armor to clamp to zero."
	if model.staged_hud_value("player_gold", -1) != 0:
		return "Expected player gold to clamp to zero."
	model.stage_player_block_step(4, 10)
	if model.staged_hud_value("player_armor", -1) != 0:
		return "Expected block step to use staged armor when present."
	model.stage_player_final(42, 6)
	if model.staged_hud_value("player_hp", -1) != 42 or model.staged_hud_value("player_armor", -1) != 6:
		return "Expected stage_player_final to store final HP and armor."
	model.clear_hud_staging()
	if model.is_hud_staging_active():
		return "Expected clear_hud_staging to clear staged values."
	return ""


func _test_mastery_preview_accumulates_releases_consumes_and_resets() -> String:
	var model := CombatModel.new()
	var initial_token := model.combat_mastery_feedback_token()
	model.reset_combat_mastery_preview()
	if model.combat_mastery_feedback_token() != initial_token + 1:
		return "Expected reset_combat_mastery_preview to increment token."
	if not model.combat_mastery_preview_totals_snapshot().is_empty():
		return "Expected reset_combat_mastery_preview to clear totals."
	if model.add_combat_mastery_preview_total(OrbType.Id.FIRE, 3) != 3:
		return "Expected Fire preview total 3."
	if model.add_combat_mastery_preview_total(OrbType.Id.FIRE, 4) != 7:
		return "Expected Fire preview total to accumulate to 7."
	model.add_combat_mastery_preview_total(OrbType.Id.HEART, 2)
	model.release_combat_mastery_feedback(OrbType.Id.HEART)
	if model.combat_mastery_preview_total(OrbType.Id.HEART) != 0:
		return "Expected released Heart feedback to be removed."
	var released: Array[int] = model.consume_active_combat_mastery_feedback([
		OrbType.Id.ICE,
		OrbType.Id.FIRE,
		OrbType.Id.GOLD,
	])
	if released != [OrbType.Id.FIRE]:
		return "Expected ordered consume to release only active Fire feedback."
	if model.combat_mastery_preview_total(OrbType.Id.FIRE) != 0:
		return "Expected consumed Fire feedback to be removed."
	return ""


func _test_resolve_trace_begin_pass_end_state() -> String:
	var model := CombatModel.new()
	model.begin_resolve_trace(12345, true)
	if not model.resolve_trace_active():
		return "Expected resolve trace to be active."
	if model.resolve_trace_origin_usec() != 12345:
		return "Expected resolve trace origin to be stored."
	if model.resolve_trace_pass_index() != -1:
		return "Expected resolve trace pass index to start at -1."
	model.set_resolve_trace_pass_index(2)
	if model.resolve_trace_pass_index() != 2:
		return "Expected resolve trace pass index to update."
	model.end_resolve_trace()
	if model.resolve_trace_active():
		return "Expected end_resolve_trace to deactivate trace."
	if model.resolve_trace_pass_index() != -1:
		return "Expected end_resolve_trace to reset pass index."
	return ""


func _test_post_match_vfx_registry_exposes_distinct_results() -> String:
	var registry = VISUAL_REGISTRY_SCRIPT.new()
	var required_kinds: Array[String] = ["fire", "ice", "earth", "gold", "heart", "armor", "damage", "heal", "block"]
	var seen_rids := {}
	for kind in required_kinds:
		var texture := registry.mastery_impact_texture(kind)
		if texture == null:
			return "Expected post-match VFX texture for %s." % kind
		var rid := texture.get_rid()
		if kind in ["fire", "ice", "earth", "gold", "heart", "armor", "damage"] and seen_rids.has(rid):
			return "Expected %s post-match texture to be visually distinct." % kind
		seen_rids[rid] = kind
	return ""


func _test_raw_pack_combat_vfx_scenes_are_available() -> String:
	var scene_paths: Array[String] = [
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/hit/vfx_hit_01.tscn",
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/hit/vfx_hit_02.tscn",
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/impact/vfx_impact_01.tscn",
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/impact/vfx_impact_02.tscn",
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/big_impact/vfx_big_impact_01.tscn",
		"res://assets/BinbunVFX_Vol2/StylizedHitFX/effects/big_impact/vfx_big_impact_02.tscn",
		"res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/cast/vfx_fire_cast_01.tscn",
		"res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/projectile/vfx_fire_projectile_01.tscn",
		"res://assets/BinbunVFX_Vol2/ElementalMagicFX/effects/area/vfx_fire_area_01.tscn",
	]
	for path in scene_paths:
		if not ResourceLoader.exists(path):
			return "Expected raw VFX pack scene at %s." % path
		var scene := load(path) as PackedScene
		if scene == null:
			return "Expected raw VFX pack scene to load at %s." % path
	return ""


func _test_new_raw_status_and_scene_vfx_assets_are_available() -> String:
	var overlay = COMBAT_MAX_VFX_OVERLAY_SCRIPT.new()
	var status_paths: Dictionary = overlay.required_status_sheet_paths()
	for key in ["burn", "freeze", "poison", "heal", "shield", "blessed", "armor", "regen", "haste"]:
		var path := String(status_paths.get(key, ""))
		if path == "":
			return "Expected status sheet path for %s." % key
		var texture := load(path) as Texture2D
		var size := Vector2i.ZERO
		if texture != null:
			size = Vector2i(texture.get_width(), texture.get_height())
		else:
			var image := Image.new()
			if image.load(path) != OK:
				return "Expected Vivid status sheet to load at %s." % path
			size = Vector2i(image.get_width(), image.get_height())
		if size.x < 256 or size.y < 256:
			return "Expected Vivid status sheet to expose a 4x4 64px atlas at %s." % path
	var atmospheric_paths: Dictionary = overlay.required_atmospheric_sheet_paths()
	for key in ["embers", "snow", "wind", "magic_wind", "godrays", "meteor", "tornado", "frost"]:
		var atmospheric_path := String(atmospheric_paths.get(key, ""))
		if atmospheric_path == "":
			return "Expected atmospheric sheet path for %s." % key
		var atmospheric_texture := load(atmospheric_path) as Texture2D
		var atmospheric_size := Vector2i.ZERO
		if atmospheric_texture != null:
			atmospheric_size = Vector2i(atmospheric_texture.get_width(), atmospheric_texture.get_height())
		else:
			var atmospheric_image := Image.new()
			if atmospheric_image.load(atmospheric_path) != OK:
				return "Expected Alenia atmospheric sheet to load at %s." % atmospheric_path
			atmospheric_size = Vector2i(atmospheric_image.get_width(), atmospheric_image.get_height())
		if atmospheric_size.x < 15360 or atmospheric_size.y < 180:
			return "Expected Alenia atmospheric sheet to expose a 48x 320x180 atlas at %s." % atmospheric_path
	var scene_paths: Dictionary = overlay.external_scene_paths()
	for key in ["flame", "beam", "shield", "tornado"]:
		var path := String(scene_paths.get(key, ""))
		if path == "":
			return "Expected imported scene path for %s." % key
		if not ResourceLoader.exists(path):
			return "Expected imported VFX scene at %s." % path
		var scene := load(path) as PackedScene
		if scene == null:
			return "Expected imported VFX scene to load at %s." % path
	return ""


func _test_combat_vfx_presenter_quality_switches_max_and_low_modes() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	if presenter.post_match_vfx_quality() != "low":
		return "Expected Low combat VFX quality by default."
	if presenter.max_combat_vfx_forced():
		return "Expected default Low combat VFX to use the lightweight fallback path."
	presenter.set_post_match_vfx_quality("high")
	if presenter.post_match_vfx_quality() != "high":
		return "Expected High combat VFX quality to be accepted."
	if presenter.max_combat_vfx_forced():
		return "Expected High combat VFX quality to wait for master Game Juice before forcing Max overlay."
	presenter.set_game_juice_enabled(true)
	if not presenter.max_combat_vfx_forced():
		return "Expected High combat VFX quality with master Game Juice to use the Max overlay."
	presenter.set_post_match_vfx_quality("low")
	if presenter.post_match_vfx_quality() != "low":
		return "Expected Low combat VFX quality to be accepted."
	if presenter.post_match_vfx_quality_uses_max_overlay():
		return "Expected Low combat VFX quality to use the lightweight fallback path."
	presenter.set_post_match_vfx_quality("nonsense")
	if presenter.post_match_vfx_quality() != "low":
		return "Expected invalid combat VFX quality to normalize back to Low."
	return ""


func _test_combat_max_vfx_asset_catalog_exposes_required_paths() -> String:
	var catalog = COMBAT_MAX_VFX_ASSET_CATALOG_SCRIPT.new()
	var texture_keys: Array[String] = catalog.required_texture_keys()
	for key in ["fire_impact", "enemy_attack", "armor_shell", "stone_chunks"]:
		if not texture_keys.has(key):
			return "Expected max VFX texture catalog to include %s." % key
	var status_paths: Dictionary = catalog.status_sheet_paths()
	for key in ["burn", "freeze", "armor", "regen"]:
		if String(status_paths.get(key, "")) != catalog.status_sheet_path(key):
			return "Expected status path lookup to match exported catalog for %s." % key
	var atmospheric_paths: Dictionary = catalog.atmospheric_sheet_paths()
	for key in ["embers", "snow", "tornado", "frost"]:
		if String(atmospheric_paths.get(key, "")) != catalog.atmospheric_sheet_path(key):
			return "Expected atmospheric path lookup to match exported catalog for %s." % key
	var external_paths: Dictionary = catalog.external_scene_paths()
	for key in ["flame", "beam", "shield", "tornado"]:
		if String(external_paths.get(key, "")) != catalog.external_scene_path(key):
			return "Expected external scene path lookup to match exported catalog for %s." % key
	if catalog.pack_scene_path("impact_01") == "" or catalog.elemental_magic_scene_path("area") == "":
		return "Expected catalog to expose pack and elemental scene paths."
	if catalog.status_sheet_path("missing") != "" or catalog.external_scene_path("missing") != "":
		return "Expected missing catalog lookups to return empty paths."
	return ""


func _test_combat_max_vfx_flipbook_presenter_spawns_sprite3d() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Node.new()
	root.name = "MaxFlipbookRoot"
	tree.root.add_child(root)
	var root_3d := Node3D.new()
	root.add_child(root_3d)
	var image := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	var presenter = COMBAT_MAX_VFX_FLIPBOOK_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root_3d,
		"timer_owner": root,
		"texture_provider": func(key: String) -> Texture2D:
			return texture if key == "spark" else null,
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x, screen_position.y, z),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, screen_offset.y, 0.0),
		"screen_to_world_rotation": func(screen_rotation: float) -> float:
			return -screen_rotation,
	})
	var sprite := presenter.spawn_flipbook("spark", Vector2(32, 48), Vector2(128, 64), 0.2, Color(0.2, 0.4, 1.0, 0.8), 0.0, Vector2(6, -4), 1.2, 3.0, 0.25, 0.1)
	if sprite == null or not is_instance_valid(sprite):
		root.queue_free()
		return "Expected max flipbook presenter to spawn a Sprite3D."
	if sprite.name != "MaxVfx_spark" or sprite.texture != texture:
		root.queue_free()
		return "Expected max flipbook presenter to assign the requested texture."
	if sprite.hframes != 4 or sprite.vframes != 4:
		root.queue_free()
		return "Expected max flipbook presenter to configure 4x4 flipbook frames."
	if not is_equal_approx(sprite.scale.x, 8.0) or not is_equal_approx(sprite.scale.y, 4.0):
		root.queue_free()
		return "Expected max flipbook presenter to scale by frame cell size."
	if not is_equal_approx(sprite.position.x, 32.0) or not is_equal_approx(sprite.position.z, 3.0):
		root.queue_free()
		return "Expected max flipbook presenter to project screen position."
	if not is_equal_approx(sprite.rotation.z, -0.25):
		root.queue_free()
		return "Expected max flipbook presenter to project rotation."
	root.queue_free()
	return ""


func _test_combat_max_vfx_imported_scene_presenter_spawns_and_filters_scenes() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Node.new()
	root.name = "ImportedSceneRoot"
	tree.root.add_child(root)
	var root_3d := Node3D.new()
	root.add_child(root_3d)
	var flame_scene := _packed_scene_from_node(Node3D.new())
	var shield_root := Node3D.new()
	var camera := Camera3D.new()
	camera.name = "CameraNoise"
	shield_root.add_child(camera)
	var particles := GPUParticles3D.new()
	particles.name = "ShieldParticles"
	shield_root.add_child(particles)
	var tornado_root := Node3D.new()
	var keep_child := Node3D.new()
	keep_child.name = "tornado poison"
	tornado_root.add_child(keep_child)
	var hide_child := Node3D.new()
	hide_child.name = "tornado dust"
	tornado_root.add_child(hide_child)
	var presenter = COMBAT_MAX_VFX_IMPORTED_SCENE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root_3d,
		"timer_owner": root,
		"flame_scene_provider": func() -> PackedScene:
			return flame_scene,
		"shield_scene_provider": func() -> PackedScene:
			return _packed_scene_from_node(shield_root),
		"tornado_scene_provider": func() -> PackedScene:
			return _packed_scene_from_node(tornado_root),
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x, screen_position.y, z),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, screen_offset.y, 0.0),
	})
	var flame := presenter.spawn_flame_scene(Vector2(12, 24), Vector2(120, 80), 0.2, 4, 0.0, Vector2.ZERO, 2.0, 0.7)
	if flame == null or flame.name != "FlamePackVfx" or not is_equal_approx(flame.position.z, 2.0):
		root.queue_free()
		return "Expected imported scene presenter to spawn positioned flame scene."
	var shield := presenter.spawn_shield_scene(Vector2(60, 90), Vector2(160, 100), 0.2, 5, 0.0, Vector2.ZERO, 3.0)
	var queued_camera := shield.get_node_or_null("CameraNoise") if shield != null else null
	if shield == null or shield.name != "ShieldPackVfx" or queued_camera == null or not queued_camera.is_queued_for_deletion():
		root.queue_free()
		return "Expected imported scene presenter to queue imported camera noise for removal."
	var spawned_particles := shield.get_node_or_null("ShieldParticles") as GPUParticles3D
	if spawned_particles == null or spawned_particles.amount != 28 or not spawned_particles.emitting:
		root.queue_free()
		return "Expected imported scene presenter to scale shield particles."
	var tornado := presenter.spawn_tornado_scene(Vector2(80, 100), Vector2(180, 120), 0.2, 6, 0.0, Vector2.ZERO, 4.0, "tornado poison")
	if tornado == null or tornado.name != "TornadoPackVfx_tornado poison":
		root.queue_free()
		return "Expected imported scene presenter to spawn named tornado scene."
	var kept := tornado.get_node_or_null("tornado poison") as Node3D
	var hidden := tornado.get_node_or_null("tornado dust") as Node3D
	if kept == null or hidden == null or not kept.visible or hidden.visible:
		root.queue_free()
		return "Expected imported scene presenter to keep only the requested tornado child visible."
	root.queue_free()
	return ""


func _test_combat_max_vfx_sheet_flipbook_presenter_spawns_status_and_atmospheric_sprites() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Node.new()
	root.name = "SheetFlipbookRoot"
	tree.root.add_child(root)
	var root_3d := Node3D.new()
	root.add_child(root_3d)
	var status_texture := _solid_texture(64, 64, Color.WHITE)
	var atmospheric_texture := _solid_texture(480, 20, Color.WHITE)
	var presenter = COMBAT_MAX_VFX_SHEET_FLIPBOOK_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root_3d,
		"timer_owner": root,
		"status_texture_provider": func(key: String) -> Texture2D:
			return status_texture if key == "burn" else null,
		"atmospheric_texture_provider": func(key: String) -> Texture2D:
			return atmospheric_texture if key == "embers" else null,
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x, screen_position.y, z),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, screen_offset.y, 0.0),
		"screen_to_world_rotation": func(screen_rotation: float) -> float:
			return -screen_rotation,
	})
	var status_sprite := presenter.spawn_status_flipbook("burn", Vector2(20, 30), Vector2(80, 40), 0.2, Color(1, 0.4, 0.2, 0.7), 0.0, Vector2(4, 0), 1.1, 2.0, 0.3, 2, 0.12)
	if status_sprite == null or status_sprite.name != "StatusVfx_burn":
		root.queue_free()
		return "Expected sheet flipbook presenter to spawn status sprite."
	if status_sprite.hframes != 4 or status_sprite.vframes != 4:
		root.queue_free()
		return "Expected status sheet sprite to use 4x4 frames."
	if not is_equal_approx(status_sprite.scale.x, 5.0) or not is_equal_approx(status_sprite.scale.y, 2.5):
		root.queue_free()
		return "Expected status sheet sprite to scale from 16x16 cells."
	if not is_equal_approx(status_sprite.rotation.z, -0.3):
		root.queue_free()
		return "Expected status sheet sprite rotation to be projected."
	var atmospheric_sprite := presenter.spawn_atmospheric_flipbook("embers", Vector2(50, 60), Vector2(96, 30), 0.2, Color(0.8, 0.9, 1.0, 0.5), 0.0, Vector2.ZERO, 0.9, 1.0, 0.15, 1)
	if atmospheric_sprite == null or atmospheric_sprite.name != "AtmosphericVfx_embers":
		root.queue_free()
		return "Expected sheet flipbook presenter to spawn atmospheric sprite."
	if atmospheric_sprite.hframes != 48 or atmospheric_sprite.vframes != 1:
		root.queue_free()
		return "Expected atmospheric sheet sprite to use 48x1 frames."
	if not is_equal_approx(atmospheric_sprite.scale.x, 9.6) or not is_equal_approx(atmospheric_sprite.scale.y, 1.5):
		root.queue_free()
		return "Expected atmospheric sheet sprite to scale from 10x20 cells."
	root.queue_free()
	return ""


func _test_combat_max_vfx_pack_scene_presenter_spawns_projected_effects() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Node.new()
	root.name = "PackSceneRoot"
	tree.root.add_child(root)
	var root_3d := Node3D.new()
	root.add_child(root_3d)
	var pack_node := Node3D.new()
	var pack_scene := _packed_scene_from_node(pack_node)
	var presenter = COMBAT_MAX_VFX_PACK_SCENE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root_3d,
		"timer_owner": root,
		"pack_scene_provider": func(key: String) -> PackedScene:
			return pack_scene if key == "impact_01" else null,
		"kind_colors_provider": func(_kind: String) -> Dictionary:
			return {
				"core": Color(0.2, 0.4, 1.0, 1.0),
				"accent": Color(1.0, 0.8, 0.2, 1.0),
			},
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x, screen_position.y, z),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, screen_offset.y, 0.0),
		"screen_to_world_rotation": func(screen_rotation: float) -> float:
			return -screen_rotation,
	})
	var effect: Node3D = presenter.spawn_pack_effect("impact_01", Vector2(40, 50), "fire", Vector2(120, 80), 0.2, 4, 0.0, Vector2(8, -6), 0.25, 2.0, 0.7)
	if effect == null or effect.name != "PackVfx_fire_impact_01":
		root.queue_free()
		return "Expected pack scene presenter to spawn named pack effect."
	if not is_equal_approx(effect.position.x, 40.0) or not is_equal_approx(effect.position.y, 50.0) or not is_equal_approx(effect.position.z, 2.0):
		root.queue_free()
		return "Expected pack scene presenter to project screen position."
	if not is_equal_approx(effect.rotation.z, -0.25):
		root.queue_free()
		return "Expected pack scene presenter to project rotation."
	if not is_equal_approx(effect.scale.x, 22.0) or not is_equal_approx(effect.scale.y, 22.0):
		root.queue_free()
		return "Expected pack scene presenter to scale from draw size and intensity."
	presenter.stretch_effect(effect, Vector3(2.0, 0.5, 1.0))
	if not is_equal_approx(effect.scale.x, 44.0) or not is_equal_approx(effect.scale.y, 11.0):
		root.queue_free()
		return "Expected pack scene presenter to stretch spawned effect."
	root.queue_free()
	return ""


func _test_combat_max_vfx_elemental_scene_presenter_spawns_projected_effects() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Node.new()
	root.name = "ElementalSceneRoot"
	tree.root.add_child(root)
	var root_3d := Node3D.new()
	root.add_child(root_3d)
	var elemental_node := Node3D.new()
	var elemental_scene := _packed_scene_from_node(elemental_node)
	var presenter = COMBAT_MAX_VFX_ELEMENTAL_SCENE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root_3d,
		"timer_owner": root,
		"elemental_scene_provider": func(key: String) -> PackedScene:
			return elemental_scene if key == "projectile" else null,
		"elemental_kind_colors_provider": func(_kind: String) -> Dictionary:
			return {
				"primary": Color(0.2, 0.6, 1.0, 1.0),
				"secondary": Color(0.9, 0.8, 0.3, 1.0),
				"tertiary": Color(0.4, 1.0, 0.8, 1.0),
			},
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x, screen_position.y, z),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, screen_offset.y, 0.0),
		"screen_to_world_rotation": func(screen_rotation: float) -> float:
			return -screen_rotation,
	})
	var effect: Node3D = presenter.spawn_elemental_effect("projectile", Vector2(32, 44), "ice", Vector2(104, 52), 0.3, 5, 0.0, Vector2(6, 0), 0.35, 1.5, 0.8)
	if effect == null or effect.name != "ElementalVfx_ice_projectile":
		root.queue_free()
		return "Expected elemental scene presenter to spawn named elemental effect."
	if not is_equal_approx(effect.position.x, 32.0) or not is_equal_approx(effect.position.y, 44.0) or not is_equal_approx(effect.position.z, 1.5):
		root.queue_free()
		return "Expected elemental scene presenter to project screen position."
	if not is_equal_approx(effect.rotation.z, -0.35):
		root.queue_free()
		return "Expected elemental scene presenter to project rotation."
	if not is_equal_approx(effect.scale.x, 23.0) or not is_equal_approx(effect.scale.y, 23.0):
		root.queue_free()
		return "Expected elemental scene presenter to scale projectile from draw size and intensity."
	root.queue_free()
	return ""


func _test_combat_max_vfx_elemental_recipe_policy_tiers_and_sizes() -> String:
	var policy = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_POLICY_SCRIPT.new()
	if policy.fire_tier(2, false) != 1 or policy.fire_tier(3, false) != 2 or policy.fire_tier(5, false) != 3:
		return "Expected fire recipe tiers to use 3 and 5 intensity thresholds."
	if policy.ice_tier(5, false) != 2 or policy.ice_tier(6, false) != 3:
		return "Expected ice recipe tiers to use 6 as tier-three threshold."
	if policy.earth_tier(2, true) != 3:
		return "Expected screen-wide earth recipe to force tier three."
	var fallback := 180.0
	if not is_equal_approx(policy.replay_impact_basis_size("ice", Vector2(420, 120), fallback), fallback):
		return "Expected non-fire replay basis to preserve fallback size."
	if not is_equal_approx(policy.replay_impact_basis_size("fire", Vector2(120, 110), fallback), fallback):
		return "Expected compact fire replay basis to preserve fallback size."
	var wide_basis := policy.replay_impact_basis_size("fire", Vector2(420, 120), fallback)
	if not is_equal_approx(wide_basis, sqrt(420.0 * 120.0) * 0.64):
		return "Expected wide fire replay basis to use geometric size when larger than short-side size."
	var minimum_basis := policy.replay_impact_basis_size("fire", Vector2(80, 24), 40.0)
	if not is_equal_approx(minimum_basis, 96.0):
		return "Expected wide fire replay basis to respect minimum visual size."
	return ""


func _test_combat_max_vfx_fire_ambient_presenter_spawns_screen_and_sparks() -> String:
	var atmospheric_calls: Array[Dictionary] = []
	var flipbook_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_FIRE_AMBIENT_PRESENTER_SCRIPT.new()
	presenter.bind({
		"atmospheric_available_provider": func() -> bool:
			return true,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			atmospheric_calls.append({
				"key": sheet_key,
				"center": center_local,
				"size": draw_size,
				"lifetime": lifetime,
				"color": color,
				"delay": delay,
				"move_offset": move_offset,
				"target_scale": target_scale,
				"z": z,
				"rotation": rotation,
				"loops": loops,
			}),
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
			flipbook_calls.append({
				"key": key,
				"center": center_local,
				"size": draw_size,
				"lifetime": lifetime,
				"color": color,
				"delay": delay,
				"move_offset": move_offset,
				"target_scale": target_scale,
				"z": z,
				"rotation": rotation,
			}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({
				"center": center,
				"color": color,
				"energy": energy,
				"radius": radius,
				"lifetime": lifetime,
			}),
	})
	presenter.spawn_screen_ember_field(Vector2(200, 360), 1.0, 4, 0.2, 0.5)
	if atmospheric_calls.size() != 5 or light_calls.size() != 1:
		return "Expected fire ambient presenter to spawn five screen atmospheric layers and one light."
	if String(atmospheric_calls[0].get("key", "")) != "fog" or String(atmospheric_calls[1].get("key", "")) != "embers":
		return "Expected fire screen ember field to lead with fog and embers."
	var first_size: Vector2 = atmospheric_calls[0].get("size", Vector2.ZERO)
	if not is_equal_approx(first_size.x, 1438.4) or not is_equal_approx(first_size.y, 948.48):
		return "Expected fire screen ember field to scale from layer size."
	var first_light: Dictionary = light_calls[0]
	if not is_equal_approx(float(first_light.get("energy", 0.0)), 3.3) or not is_equal_approx(float(first_light.get("radius", 0.0)), 1050.0):
		return "Expected fire screen ember field light to scale with intensity and width."
	atmospheric_calls.clear()
	presenter.spawn_spark_spray(Vector2(10, 20), 100.0, 0.8, 3, 0.1, 2)
	if atmospheric_calls.size() != 18:
		return "Expected fire spark spray count to follow intensity and tier caps."
	var first_spark: Dictionary = atmospheric_calls[0]
	if String(first_spark.get("key", "")) != "embers":
		return "Expected fire spark spray to use ember sheets."
	var spark_size: Vector2 = first_spark.get("size", Vector2.ZERO)
	if not is_equal_approx(spark_size.x, 77.72) or not is_equal_approx(spark_size.y, 49.88):
		return "Expected fire spark spray size to scale with intensity and tier."
	atmospheric_calls.clear()
	presenter.spawn_ember_lane(Vector2(10, 20), Vector2(300, 0), 0.15, 0.8, 4, 0.25, 3)
	if atmospheric_calls.size() != 3:
		return "Expected tier-three ember lane to spawn three atmospheric layers."
	var lane: Dictionary = atmospheric_calls[0]
	if String(lane.get("key", "")) != "embers":
		return "Expected fire ember lane to use ember sheets."
	var lane_center: Vector2 = lane.get("center", Vector2.ZERO)
	var lane_size: Vector2 = lane.get("size", Vector2.ZERO)
	if not is_equal_approx(lane_center.x, 160.0) or not is_equal_approx(lane_center.y, 20.0):
		return "Expected fire ember lane to center along travel delta."
	if not is_equal_approx(lane_size.x, 319.5) or not is_equal_approx(lane_size.y, 148.0):
		return "Expected fire ember lane size to scale with delta, intensity, and tier."
	presenter.spawn_aurora_layer(Vector2(300, 240), 1.2, 6, 0.0, 0.75)
	if flipbook_calls.size() != 10:
		return "Expected fire aurora to add one light-ray flipbook per ray."
	return ""


func _test_combat_max_vfx_fire_impact_presenter_spawns_fireball_and_fragmented_layers() -> String:
	var atmospheric_calls: Array[Dictionary] = []
	var status_calls: Array[Dictionary] = []
	var elemental_calls: Array[Dictionary] = []
	var pack_calls: Array[Dictionary] = []
	var spark_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_FIRE_IMPACT_PRESENTER_SCRIPT.new()
	presenter.bind({
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			atmospheric_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "delay": delay, "move_offset": move_offset, "z": z, "loops": loops}),
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			status_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "delay": delay, "z": z, "loops": loops}),
		"elemental_effect_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
			elemental_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "z": z, "alpha": alpha}),
		"pack_layer_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "z": z, "alpha": alpha}),
		"spark_spray_spawner": func(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
			spark_calls.append({"center": center, "radius": radius, "lifetime": lifetime, "intensity": intensity, "delay": delay, "tier": tier}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
	})
	presenter.spawn_fireball_impact_layers(Vector2(50, 60), Vector2(200, 120), 1.0, 4, 80.0)
	if elemental_calls.size() != 1 or atmospheric_calls.size() != 1 or status_calls.size() != 1 or spark_calls.size() != 1 or light_calls.size() != 1:
		return "Expected fireball impact to spawn one layer through each dependency."
	var elemental: Dictionary = elemental_calls[0]
	if String(elemental.get("key", "")) != "area" or int(elemental.get("intensity", 0)) != 5:
		return "Expected fireball impact elemental area to increment intensity."
	var atmospheric: Dictionary = atmospheric_calls[0]
	var atmospheric_center: Vector2 = atmospheric.get("center", Vector2.ZERO)
	if String(atmospheric.get("key", "")) != "embers" or not is_equal_approx(atmospheric_center.y, 55.2):
		return "Expected fireball impact ember layer to offset from max size."
	var spark: Dictionary = spark_calls[0]
	if not is_equal_approx(float(spark.get("radius", 0.0)), 144.0) or int(spark.get("tier", 0)) != 2:
		return "Expected fireball impact spark spray to scale from impact extent."
	atmospheric_calls.clear()
	status_calls.clear()
	elemental_calls.clear()
	pack_calls.clear()
	spark_calls.clear()
	light_calls.clear()
	presenter.spawn_fragmented_impact_cluster(Vector2(100, 120), Vector2(300, 200), 1.0, 6, 0.2, 0.5, 0.1)
	if pack_calls.size() != 10 or status_calls.size() != 6 or atmospheric_calls.size() != 1:
		return "Expected fragmented impact to spawn five pack pairs, six status layers, and one atmospheric layer."
	var first_pack: Dictionary = pack_calls[0]
	if String(first_pack.get("key", "")) != "impact_01" or not is_equal_approx(float(first_pack.get("alpha", 0.0)), 0.23):
		return "Expected fragmented impact pack alpha to scale from alpha_scale."
	var final_status: Dictionary = status_calls[5]
	if String(final_status.get("key", "")) != "rage":
		return "Expected fragmented impact to end status sequence with rage."
	return ""


func _test_combat_max_vfx_fire_attack_presenter_spawns_fireball_and_meteor_layers() -> String:
	var atmospheric_calls: Array[Dictionary] = []
	var status_calls: Array[Dictionary] = []
	var elemental_calls: Array[Dictionary] = []
	var pack_calls: Array[Dictionary] = []
	var spark_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var meteor_impact_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_FIRE_ATTACK_PRESENTER_SCRIPT.new()
	presenter.bind({
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			atmospheric_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "delay": delay, "z": z, "loops": loops}),
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			status_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "delay": delay, "move_offset": move_offset, "z": z, "loops": loops}),
		"elemental_effect_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
			elemental_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "move_offset": move_offset, "z": z, "alpha": alpha}),
		"pack_layer_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "z": z, "alpha": alpha}),
		"spark_spray_spawner": func(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
			spark_calls.append({"center": center, "radius": radius, "lifetime": lifetime, "intensity": intensity, "delay": delay, "tier": tier}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		"meteor_impact_spawner": func(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool) -> void:
			meteor_impact_calls.append({"center": center, "size": impact_size, "duration": duration, "intensity": intensity, "delay": delay, "fragmented": fragmented_wide}),
	})
	presenter.spawn_fireball_spell_layers(Vector2(10, 20), Vector2(310, 220), Vector2(300, 200), Vector2(120, 90), Vector2(180, 160), 0.2, 0.8, 4, 0.45)
	if atmospheric_calls.size() != 1 or status_calls.size() != 2 or elemental_calls.size() != 2 or pack_calls.size() != 2 or spark_calls.size() != 1 or light_calls.size() != 1:
		return "Expected fireball spell to spawn atmospheric, status, elemental, pack, spark, and light layers."
	var fireball_status: Dictionary = status_calls[0]
	var fireball_size: Vector2 = fireball_status.get("size", Vector2.ZERO)
	if String(fireball_status.get("key", "")) != "burn" or not is_equal_approx(fireball_size.x, 230.0) or not is_equal_approx(fireball_size.y, 150.0):
		return "Expected fireball spell burn layer to use minimum fireball size."
	var impact_pack: Dictionary = pack_calls[1]
	if String(impact_pack.get("key", "")) != "impact_01" or int(impact_pack.get("intensity", 0)) != 5:
		return "Expected fireball spell impact pack layer to increment intensity."
	var spell_light: Dictionary = light_calls[0]
	if not is_equal_approx(float(spell_light.get("energy", 0.0)), 5.28) or not is_equal_approx(float(spell_light.get("radius", 0.0)), 216.0):
		return "Expected fireball spell light to scale with intensity and impact size."
	atmospheric_calls.clear()
	status_calls.clear()
	elemental_calls.clear()
	pack_calls.clear()
	spark_calls.clear()
	light_calls.clear()
	presenter.spawn_meteor_attack_layers(Vector2(400, 360), 0.1, 0.9, 5, Vector2(200, 140))
	if elemental_calls.size() != 3 or status_calls.size() != 3 or meteor_impact_calls.size() != 1:
		return "Expected meteor attack to spawn three descent streaks and delegate one impact."
	var first_streak: Dictionary = elemental_calls[0]
	var first_start: Vector2 = first_streak.get("center", Vector2.ZERO)
	if String(first_streak.get("key", "")) != "projectile" or not is_equal_approx(first_start.x, 308.0) or not is_equal_approx(first_start.y, 171.0):
		return "Expected meteor attack first streak to start above and offset from target."
	var impact: Dictionary = meteor_impact_calls[0]
	var delegated_size: Vector2 = impact.get("size", Vector2.ZERO)
	if not bool(impact.get("fragmented", false)) or int(impact.get("intensity", 0)) != 7:
		return "Expected meteor attack to delegate fragmented impact with raised intensity."
	if not is_equal_approx(delegated_size.x, 252.0) or not is_equal_approx(delegated_size.y, 176.4):
		return "Expected meteor attack delegated impact size to scale from input size."
	return ""


func _test_combat_max_vfx_fire_recipe_presenter_routes_replay_cast_and_beam() -> String:
	var calls: Dictionary = {
		"atmospheric": [],
		"status": [],
		"flame": [],
		"pack": [],
		"burst": [],
		"spark": [],
		"light": [],
		"fireball_impact": [],
		"meteor_impact": [],
		"fragmented": [],
		"aurora": [],
		"screen_ember": [],
		"ember_lane": [],
		"status_path": [],
		"beam": [],
		"fireball_spell": [],
		"meteor_attack": [],
		"camera": [],
	}
	var presenter = COMBAT_MAX_VFX_FIRE_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"tier_provider": func(intensity: int, screen_wide: bool = false) -> int:
			if screen_wide or intensity >= 6:
				return 3
			if intensity >= 3:
				return 2
			return 1,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			calls["atmospheric"].append({"key": sheet_key, "center": center_local, "size": draw_size, "delay": delay}),
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			calls["status"].append({"key": sheet_key, "center": center_local, "size": draw_size, "move_offset": move_offset}),
		"flame_scene_spawner": func(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float, alpha: float) -> void:
			calls["flame"].append({"center": center_local, "size": draw_size, "intensity": intensity}),
		"pack_layer_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			calls["pack"].append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "intensity": intensity}),
		"burst_particles_spawner": func(kind: String, center: Vector2, radius: float, lifetime: float, intensity: int) -> void:
			calls["burst"].append({"kind": kind, "center": center, "radius": radius, "intensity": intensity}),
		"spark_spray_spawner": func(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
			calls["spark"].append({"center": center, "radius": radius, "intensity": intensity, "tier": tier}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			calls["light"].append({"center": center, "energy": energy, "radius": radius}),
		"fireball_impact_spawner": func(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
			calls["fireball_impact"].append({"center": center, "size": impact_size, "intensity": intensity, "max_size": max_size}),
		"meteor_impact_spawner": func(center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool) -> void:
			calls["meteor_impact"].append({"center": center, "size": impact_size, "intensity": intensity, "fragmented": fragmented_wide}),
		"fragmented_impact_spawner": func(center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float, rotation: float = 0.0) -> void:
			calls["fragmented"].append({"center": center, "size": draw_size, "intensity": intensity, "alpha": alpha_scale, "rotation": rotation}),
		"aurora_layer_spawner": func(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
			calls["aurora"].append({"center": center, "intensity": intensity, "alpha": alpha_scale}),
		"screen_ember_field_spawner": func(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
			calls["screen_ember"].append({"center": center, "intensity": intensity, "alpha": alpha_scale}),
		"ember_lane_spawner": func(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
			calls["ember_lane"].append({"source": source, "delta": delta, "intensity": intensity, "tier": tier}),
		"status_path_afterimage_spawner": func(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
			calls["status_path"].append({"kind": kind, "source": source, "delta": delta, "intensity": intensity}),
		"beam_effect_spawner": func(source_local: Vector2, delta: Vector2, kind: String, lifetime: float, intensity: int, delay: float, radius_scale: float) -> void:
			calls["beam"].append({"source": source_local, "delta": delta, "kind": kind, "intensity": intensity, "radius_scale": radius_scale}),
		"fireball_spell_spawner": func(source: Vector2, target: Vector2, delta: Vector2, source_size: Vector2, impact_size: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
			calls["fireball_spell"].append({"source": source, "target": target, "source_size": source_size, "impact_size": impact_size, "intensity": intensity}),
		"meteor_attack_spawner": func(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
			calls["meteor_attack"].append({"target": target, "intensity": intensity, "size": impact_size}),
		"camera_kick_spawner": func(offset: Vector2, delay: float) -> void:
			calls["camera"].append({"offset": offset, "delay": delay}),
	})
	presenter.spawn_replay_layers(Vector2(200, 180), Vector2(220, 160), 120.0, 180.0, 1.0, 1, false)
	if calls["fireball_impact"].size() != 1 or calls["meteor_impact"].size() != 0:
		return "Expected tier-one fire replay to delegate fireball impact only."
	var replay_impact: Dictionary = calls["fireball_impact"][0]
	if int(replay_impact.get("intensity", 0)) != 1 or not is_equal_approx(float(replay_impact.get("max_size", 0.0)), 120.0):
		return "Expected fire replay impact to preserve tier-one intensity and max size."
	calls["fireball_impact"].clear()
	presenter.spawn_replay_layers(Vector2(260, 220), Vector2(420, 260), 180.0, 260.0, 1.2, 6, true)
	if calls["meteor_impact"].size() != 1 or calls["fragmented"].size() != 1:
		return "Expected wide tier-three fire replay to delegate meteor and fragmented impacts."
	var wide_impact: Dictionary = calls["meteor_impact"][0]
	if not bool(wide_impact.get("fragmented", false)):
		return "Expected wide tier-three replay meteor impact to request fragmented handling."
	presenter.spawn_cast_layers(Vector2(40, 50), Vector2(340, 210), Vector2(300, 160), Vector2(140, 100), 0.7, 0.8, 0.5, 1, Color(1, 0.4, 0.1))
	if calls["fireball_spell"].size() != 1 or calls["meteor_attack"].size() != 0:
		return "Expected tier-one fire cast to delegate fireball spell and skip meteor attack."
	presenter.spawn_cast_layers(Vector2(40, 50), Vector2(340, 210), Vector2(300, 160), Vector2(140, 100), 0.7, 0.8, 0.5, 6, Color(1, 0.4, 0.1))
	if calls["meteor_attack"].size() != 1 or calls["camera"].size() < 2:
		return "Expected tier-three fire cast to delegate meteor attack and camera kick."
	var meteor_attack: Dictionary = calls["meteor_attack"][0]
	if int(meteor_attack.get("intensity", 0)) != 6:
		return "Expected tier-three fire cast meteor attack to preserve layer intensity."
	calls["beam"].clear()
	presenter.spawn_beam_layers(Vector2(50, 60), Vector2(240, 0), 0.9, 6, 0.0)
	if calls["beam"].size() != 3 or calls["aurora"].size() == 0 or calls["screen_ember"].size() == 0:
		return "Expected tier-three fire beam to spawn main, lane, aurora, and ember field routes."
	return ""


func _test_combat_max_vfx_ice_recipe_presenter_routes_replay_cast_and_travel() -> String:
	var calls: Dictionary = {
		"atmospheric": [],
		"status": [],
		"flipbook": [],
		"pack": [],
		"burst": [],
		"light": [],
		"status_path": [],
		"camera": [],
	}
	var presenter = COMBAT_MAX_VFX_ICE_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"tier_provider": func(intensity: int, screen_wide: bool = false) -> int:
			if screen_wide or intensity >= 6:
				return 3
			if intensity >= 3:
				return 2
			return 1,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			calls["atmospheric"].append({"key": sheet_key, "center": center_local, "size": draw_size, "z": z, "loops": loops}),
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int, spin: float = 0.0) -> void:
			calls["status"].append({"key": sheet_key, "center": center_local, "size": draw_size, "z": z, "spin": spin}),
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float = 0.0) -> void:
			calls["flipbook"].append({"key": key, "center": center_local, "size": draw_size, "z": z, "spin": spin}),
		"pack_layer_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			calls["pack"].append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "intensity": intensity}),
		"burst_particles_spawner": func(kind: String, center: Vector2, radius: float, lifetime: float, intensity: int) -> void:
			calls["burst"].append({"kind": kind, "center": center, "radius": radius, "intensity": intensity}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
			calls["light"].append({"center": center, "energy": energy, "radius": radius, "delay": delay}),
		"status_path_afterimage_spawner": func(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
			calls["status_path"].append({"kind": kind, "source": source, "delta": delta, "intensity": intensity}),
		"camera_kick_spawner": func(offset: Vector2, delay: float) -> void:
			calls["camera"].append({"offset": offset, "delay": delay}),
	})
	presenter.spawn_replay_layers(Vector2(200, 180), Vector2(220, 160), 120.0, 180.0, 1.0, 1, false)
	if calls["flipbook"].size() < 2 or calls["pack"].size() != 1 or calls["burst"].size() != 1:
		return "Expected tier-one ice replay to spawn iceball impact, pack, and burst routes."
	var replay_pack: Dictionary = calls["pack"][0]
	if String(replay_pack.get("key", "")) != "impact_02" or String(replay_pack.get("kind", "")) != "ice":
		return "Expected tier-one ice replay to use ice impact pack route."
	calls["atmospheric"].clear()
	calls["status"].clear()
	calls["flipbook"].clear()
	calls["pack"].clear()
	calls["burst"].clear()
	presenter.spawn_replay_layers(Vector2(260, 220), Vector2(420, 260), 180.0, 260.0, 1.2, 6, true)
	if calls["atmospheric"].size() < 5 or calls["pack"].size() < 2:
		return "Expected wide tier-three ice replay to spawn blizzard atmosphere and impact pack routes."
	var first_blizzard: Dictionary = calls["atmospheric"][1]
	var first_blizzard_size: Vector2 = first_blizzard.get("size", Vector2.ZERO)
	if String(first_blizzard.get("key", "")) != "snow" or not is_equal_approx(first_blizzard_size.x, 1160.0):
		return "Expected tier-three ice replay to use layer-wide snow sheet."
	presenter.spawn_cast_layers(Vector2(40, 50), Vector2(340, 210), Vector2(300, 160), Vector2(140, 100), 0.7, 0.8, 0.5, 1, Color(0.7, 0.95, 1.0))
	if calls["status_path"].size() != 1 or calls["camera"].size() != 1:
		return "Expected tier-one ice cast to spawn status path and camera kick."
	calls["atmospheric"].clear()
	calls["status"].clear()
	calls["flipbook"].clear()
	calls["pack"].clear()
	calls["status_path"].clear()
	presenter.spawn_windy_block_travel_layers(Vector2(10, 20), Vector2(210, 120), Vector2(200, 100), Vector2(-0.4, 0.9).normalized(), Vector2(120, 90), 0.8, 0.2, 4, 0.25)
	if calls["atmospheric"].size() != 2 or calls["status"].size() != 4 or calls["flipbook"].size() != 5 or calls["pack"].size() != 1 or calls["status_path"].size() != 1:
		return "Expected windy ice travel to preserve atmospheric, status, flipbook, pack, and afterimage routes."
	return ""


func _test_combat_max_vfx_earth_recipe_presenter_routes_replay_cast_and_fracture() -> String:
	var calls: Dictionary = {
		"atmospheric": [],
		"status": [],
		"flipbook": [],
		"pack": [],
		"burst": [],
		"light": [],
		"tornado": [],
		"camera": [],
	}
	var presenter = COMBAT_MAX_VFX_EARTH_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"tier_provider": func(intensity: int, screen_wide: bool = false) -> int:
			if screen_wide or intensity >= 6:
				return 3
			if intensity >= 3:
				return 2
			return 1,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			calls["atmospheric"].append({"key": sheet_key, "center": center_local, "size": draw_size, "z": z, "loops": loops}),
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			calls["status"].append({"key": sheet_key, "center": center_local, "size": draw_size, "z": z}),
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float = 0.0) -> void:
			calls["flipbook"].append({"key": key, "center": center_local, "size": draw_size, "z": z, "spin": spin}),
		"pack_layer_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			calls["pack"].append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "intensity": intensity, "alpha": alpha}),
		"burst_particles_spawner": func(kind: String, center: Vector2, radius: float, lifetime: float, intensity: int) -> void:
			calls["burst"].append({"kind": kind, "center": center, "radius": radius, "intensity": intensity}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float, delay: float = 0.0) -> void:
			calls["light"].append({"center": center, "energy": energy, "radius": radius, "delay": delay}),
		"tornado_scene_spawner": func(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float, variant_hint: String) -> void:
			calls["tornado"].append({"center": center_local, "size": draw_size, "intensity": intensity, "variant": variant_hint}),
		"camera_kick_spawner": func(offset: Vector2, delay: float) -> void:
			calls["camera"].append({"offset": offset, "delay": delay}),
	})
	presenter.spawn_replay_layers(Vector2(200, 180), Vector2(220, 160), 120.0, 180.0, 1.0, 1, false)
	if calls["pack"].size() < 1 or calls["flipbook"].size() < 1 or calls["burst"].size() != 1 or calls["light"].size() < 1:
		return "Expected tier-one earth replay routes; got pack=%d flipbook=%d burst=%d light=%d." % [calls["pack"].size(), calls["flipbook"].size(), calls["burst"].size(), calls["light"].size()]
	var first_pack: Dictionary = calls["pack"][0]
	if String(first_pack.get("key", "")) != "impact_01" or String(first_pack.get("kind", "")) != "earth":
		return "Expected earth replay quake to start with impact_01 pack route."
	calls["atmospheric"].clear()
	calls["status"].clear()
	calls["flipbook"].clear()
	calls["pack"].clear()
	calls["burst"].clear()
	calls["light"].clear()
	calls["tornado"].clear()
	presenter.spawn_replay_layers(Vector2(260, 220), Vector2(420, 260), 180.0, 260.0, 1.2, 6, true)
	if calls["atmospheric"].size() < 13 or calls["tornado"].size() != 0 or calls["burst"].size() < 2:
		return "Expected wide tier-three earth replay to spawn quake plus tornado atmosphere layers."
	var found_tornado_atmosphere := false
	for atmospheric_call in calls["atmospheric"]:
		if String(atmospheric_call.get("key", "")) == "tornado":
			found_tornado_atmosphere = true
			break
	if not found_tornado_atmosphere:
		return "Expected tier-three earth replay to include tornado atmosphere."
	calls["atmospheric"].clear()
	calls["status"].clear()
	calls["flipbook"].clear()
	calls["pack"].clear()
	calls["burst"].clear()
	calls["light"].clear()
	calls["tornado"].clear()
	calls["camera"].clear()
	presenter.spawn_cast_layers(Vector2(40, 50), Vector2(340, 210), Vector2(300, 160), Vector2(140, 100), 0.7, 0.8, 0.5, 6, Color(0.8, 0.7, 0.4))
	if calls["tornado"].size() < 2 or calls["camera"].size() != 1 or calls["pack"].size() < 8:
		return "Expected tier-three earth cast to spawn spool tornadoes, quake packs, and camera kick."
	calls["atmospheric"].clear()
	calls["status"].clear()
	calls["flipbook"].clear()
	calls["pack"].clear()
	presenter.spawn_fracture_travel_layers(Vector2(20, 30), Vector2(220, 140), Vector2(200, 110), Vector2(-0.4, 0.9).normalized(), Vector2(130, 90), 0.8, 0.1, 4, 0.3, 2)
	if calls["atmospheric"].size() != 3 or calls["status"].size() < 4 or calls["flipbook"].size() < 11 or calls["pack"].size() != 1:
		return "Expected earth fracture travel to preserve atmosphere, vein, chunk, and pack routes."
	return ""


func _test_combat_max_vfx_pack_recipe_presenter_maps_keys_and_screen_wide() -> String:
	var pack_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"kind_cleaner": func(kind: String) -> String:
			var clean_kind := kind.strip_edges().to_lower()
			if clean_kind == "heal":
				return "heart"
			if clean_kind == "block":
				return "armor"
			return clean_kind,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"pack_effect_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "rotation": rotation, "z": z, "alpha": alpha}),
	})
	if presenter.impact_scene_key(" ice ", 2, false) != "impact_02":
		return "Expected ice pack impact key to use impact_02."
	if presenter.impact_scene_key("earth", 7, false) != "big_impact_01":
		return "Expected high-intensity earth pack impact key to use big_impact_01."
	if presenter.impact_scene_key("heal", 1, true) != "big_impact_02":
		return "Expected screen-wide heal alias to use big_impact_02."
	if presenter.hit_scene_key("block") != "hit_02" or presenter.hit_scene_key("gold") != "hit_01":
		return "Expected pack hit key aliases to map support kinds."
	presenter.spawn_screen_wide("heal", Vector2(300, 700), 1.0, 5)
	if pack_calls.size() != 3:
		return "Expected screen-wide pack recipe to spawn three pack layers."
	var impact: Dictionary = pack_calls[0]
	var impact_center: Vector2 = impact.get("center", Vector2.ZERO)
	var impact_size: Vector2 = impact.get("size", Vector2.ZERO)
	if String(impact.get("key", "")) != "big_impact_02" or String(impact.get("kind", "")) != "heart":
		return "Expected screen-wide support impact to use normalized heart big impact."
	if not is_equal_approx(impact_center.x, 500.0) or not is_equal_approx(impact_center.y, 688.0):
		return "Expected support screen-wide pack focus to clamp into lower band."
	if not is_equal_approx(impact_size.x, 920.0) or not is_equal_approx(impact_size.y, 352.0):
		return "Expected support screen-wide pack size to scale from layer size."
	var left_hit: Dictionary = pack_calls[1]
	if String(left_hit.get("key", "")) != "hit_01" or not is_equal_approx(float(left_hit.get("delay", 0.0)), 0.10):
		return "Expected first screen-wide hit layer to use hit_01 with lifetime-scaled delay."
	return ""


func _test_combat_max_vfx_elemental_recipe_presenter_spawns_afterimage_and_screen_wide() -> String:
	var elemental_calls: Array[Dictionary] = []
	var pack_calls: Array[Dictionary] = []
	var coin_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var camera_calls: Array[Dictionary] = []
	var stretch_calls: Array[Vector3] = []
	var presenter = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"kind_cleaner": func(kind: String) -> String:
			var clean_kind := kind.strip_edges().to_lower()
			if clean_kind == "heal":
				return "heart"
			if clean_kind == "block":
				return "armor"
			return clean_kind,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"elemental_effect_spawner": func(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> Node3D:
			elemental_calls.append({"key": scene_key, "center": center_local, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "move_offset": move_offset, "rotation": rotation, "z": z, "alpha": alpha})
			return Node3D.new(),
		"effect_stretcher": func(_effect: Node3D, stretch: Vector3) -> void:
			stretch_calls.append(stretch),
		"pack_impact_scene_key_provider": func(kind: String, intensity: int, screen_wide: bool) -> String:
			return "wide_%s_%d" % [kind, intensity] if screen_wide else "impact_%s_%d" % [kind, intensity],
		"pack_layer_spawner": func(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"key": scene_key, "center": center, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "rotation": rotation, "z": z, "alpha": alpha}),
		"coin_rain_spawner": func(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
			coin_calls.append({"center": center, "base_size": base_size, "lifetime": lifetime, "intensity": intensity, "screen_wide": screen_wide}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		"camera_kick_spawner": func(direction: Vector2, delay: float) -> void:
			camera_calls.append({"direction": direction, "delay": delay}),
	})
	presenter.spawn_replay_recipe("fire", Vector2(100, 160), 140.0, 180.0, 1.0, 4, true)
	if elemental_calls.size() != 8 or pack_calls.size() != 2:
		return "Expected fire elemental replay to spawn replay layers, screen-wide layers, and pack accents."
	var replay_area: Dictionary = elemental_calls[0]
	var replay_area_size: Vector2 = replay_area.get("size", Vector2.ZERO)
	if String(replay_area.get("key", "")) != "area" or String(replay_area.get("kind", "")) != "fire":
		return "Expected fire elemental replay to begin with fire area layer."
	if not is_equal_approx(replay_area_size.x, 267.3) or not is_equal_approx(replay_area_size.y, 267.3):
		return "Expected fire elemental replay area to scale from screen-wide base size."
	if String(pack_calls[0].get("key", "")) != "wide_fire_4":
		return "Expected fire elemental replay to use provided pack impact key."
	elemental_calls.clear()
	pack_calls.clear()
	stretch_calls.clear()
	presenter.spawn_replay_recipe("earth", Vector2(100, 160), 140.0, 180.0, 1.0, 4, false)
	if elemental_calls.size() != 10 or pack_calls.size() != 1:
		return "Expected earth elemental replay to spawn ground plus intensity-scaled cracks and one pack accent."
	if stretch_calls.size() != 10:
		return "Expected earth elemental replay to stretch ground and crack layers."
	elemental_calls.clear()
	pack_calls.clear()
	coin_calls.clear()
	presenter.spawn_replay_recipe("gold", Vector2(100, 160), 140.0, 180.0, 1.0, 4, false)
	if coin_calls.size() != 1 or pack_calls.size() != 1:
		return "Expected gold elemental replay to spawn coin rain and pack accent."
	var coin: Dictionary = coin_calls[0]
	if bool(coin.get("screen_wide", true)) or not is_equal_approx(float(coin.get("base_size", 0.0)), 140.0):
		return "Expected gold elemental replay coin rain to use local max-size basis."
	elemental_calls.clear()
	pack_calls.clear()
	coin_calls.clear()
	light_calls.clear()
	camera_calls.clear()
	stretch_calls.clear()
	presenter.spawn_cast_recipe("gold", Vector2(20, 40), Vector2(220, 120), Vector2(200, 80), Vector2(100, 80), 0.5, 0.4, 4, Color(1.0, 0.8, 0.2, 1.0))
	if elemental_calls.size() != 3 or coin_calls.size() != 1 or pack_calls.size() != 1 or light_calls.size() != 1 or camera_calls.size() != 1:
		return "Expected gold elemental cast to spawn elemental layers, coin rain, pack accent, light, and camera kick."
	var cast_coin: Dictionary = coin_calls[0]
	if bool(cast_coin.get("screen_wide", true)) or not is_equal_approx(float(cast_coin.get("base_size", 0.0)), 100.0):
		return "Expected gold elemental cast coin rain to use spool size basis."
	var cast_light: Dictionary = light_calls[0]
	if not is_equal_approx(float(cast_light.get("energy", 0.0)), 2.88) or not is_equal_approx(float(cast_light.get("lifetime", 0.0)), 0.6825):
		return "Expected elemental cast light to scale by intensity and spool duration."
	var cast_camera: Dictionary = camera_calls[0]
	if not is_equal_approx(float(cast_camera.get("delay", 0.0)), 0.9924):
		return "Expected elemental cast camera kick to delay near impact."
	elemental_calls.clear()
	pack_calls.clear()
	coin_calls.clear()
	light_calls.clear()
	camera_calls.clear()
	stretch_calls.clear()
	presenter.spawn_cast_recipe("earth", Vector2(20, 40), Vector2(220, 120), Vector2(200, 80), Vector2(100, 80), 0.5, 0.4, 4, Color(0.4, 0.8, 0.2, 1.0))
	if elemental_calls.size() != 9 or pack_calls.size() != 1 or stretch_calls.size() != 3 or light_calls.size() != 1 or camera_calls.size() != 1:
		return "Expected earth elemental cast to spawn rumble, afterimage, crawl, impact, pack, light, and camera kick."
	elemental_calls.clear()
	pack_calls.clear()
	coin_calls.clear()
	light_calls.clear()
	camera_calls.clear()
	stretch_calls.clear()
	presenter.spawn_path_afterimage("earth", Vector2(10, 20), Vector2(300, 120), 0.2, 0.8, 4, 0.3)
	if elemental_calls.size() != 5:
		return "Expected earth elemental afterimage to emit five area layers."
	var first: Dictionary = elemental_calls[0]
	var first_size: Vector2 = first.get("size", Vector2.ZERO)
	if String(first.get("key", "")) != "area" or String(first.get("kind", "")) != "earth":
		return "Expected elemental afterimage to spawn earth area effects."
	if not is_equal_approx(first_size.x, 115.2) or not is_equal_approx(first_size.y, 59.04) or not is_equal_approx(float(first.get("alpha", 0.0)), 0.48):
		return "Expected earth afterimage to stretch size and alpha."
	elemental_calls.clear()
	presenter.spawn_screen_wide("heal", Vector2(300, 700), 1.0, 5)
	if elemental_calls.size() != 6:
		return "Expected support screen-wide elemental route to emit area plus five cast bursts."
	var area: Dictionary = elemental_calls[0]
	var area_center: Vector2 = area.get("center", Vector2.ZERO)
	var area_size: Vector2 = area.get("size", Vector2.ZERO)
	if String(area.get("kind", "")) != "heart" or String(area.get("key", "")) != "area":
		return "Expected screen-wide heal alias to normalize to heart area effect."
	if not is_equal_approx(area_center.x, 500.0) or not is_equal_approx(area_center.y, 688.0):
		return "Expected support elemental screen-wide focus to clamp into lower band."
	if not is_equal_approx(area_size.x, 920.0) or not is_equal_approx(area_size.y, 336.0):
		return "Expected support elemental screen-wide size to scale from layer size."
	elemental_calls.clear()
	stretch_calls.clear()
	presenter.spawn_beam_layers("ice", Vector2(40, 50), Vector2(200, 0), 0.9, 4, 0.0)
	if elemental_calls.size() != 3:
		return "Expected ice elemental beam to spawn central and side projectile lanes."
	var first_beam: Dictionary = elemental_calls[0]
	var first_beam_size: Vector2 = first_beam.get("size", Vector2.ZERO)
	if String(first_beam.get("key", "")) != "projectile" or String(first_beam.get("kind", "")) != "ice":
		return "Expected ice elemental beam to use projectile effects."
	if not is_equal_approx(first_beam_size.x, 234.0) or not is_equal_approx(first_beam_size.y, 92.0):
		return "Expected ice elemental beam size to scale with intensity."
	if not stretch_calls.is_empty():
		return "Expected ice elemental beam to avoid stretching effects."
	elemental_calls.clear()
	stretch_calls.clear()
	presenter.spawn_beam_layers("earth", Vector2(40, 50), Vector2(200, 0), 0.9, 4, 0.0)
	if elemental_calls.size() != 6:
		return "Expected earth elemental beam to spawn afterimage layers plus crawl projectile."
	if stretch_calls.size() != 1 or stretch_calls[0] != Vector3(1.35, 0.68, 1.0):
		return "Expected earth elemental beam to stretch the crawl projectile."
	return ""


func _test_combat_max_vfx_atmospheric_recipe_presenter_spawns_replay_and_travel_layers() -> String:
	var availability := {"value": true}
	var atmospheric_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_ATMOSPHERIC_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"atmospheric_available_provider": func() -> bool:
			return bool(availability.get("value", false)),
		"kind_cleaner": func(kind: String) -> String:
			var clean_kind := kind.strip_edges().to_lower()
			if clean_kind == "heal":
				return "heart"
			if clean_kind == "block":
				return "armor"
			return clean_kind,
		"kind_colors_provider": func(kind: String) -> Dictionary:
			return {"core": Color(0.2, 0.4, 0.8, 1.0), "accent": Color(0.7, 0.9, 1.0, 1.0), "kind": kind},
		"atmospheric_travel_key_provider": func(kind: String) -> String:
			return "travel_%s" % kind,
		"atmospheric_impact_key_provider": func(kind: String) -> String:
			return "impact_%s" % kind,
		"atmospheric_secondary_key_provider": func(kind: String) -> String:
			return "secondary_%s" % kind,
		"atmospheric_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			atmospheric_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation, "loops": loops}),
	})
	presenter.spawn_replay_layer("heal", Vector2(100, 160), 140.0, 180.0, 1.0, 5, false)
	if atmospheric_calls.size() != 2:
		return "Expected high-intensity support replay atmosphere to spawn primary and secondary layers."
	var replay_primary: Dictionary = atmospheric_calls[0]
	var replay_size: Vector2 = replay_primary.get("size", Vector2.ZERO)
	if String(replay_primary.get("key", "")) != "impact_heart" or not is_equal_approx(replay_size.x, 129.6) or not is_equal_approx(replay_size.y, 111.6):
		return "Expected support replay atmosphere to normalize kind and use support sizing."
	var replay_secondary: Dictionary = atmospheric_calls[1]
	var replay_secondary_center: Vector2 = replay_secondary.get("center", Vector2.ZERO)
	if String(replay_secondary.get("key", "")) != "secondary_heart" or not is_equal_approx(replay_secondary_center.y, 146.0):
		return "Expected high-intensity replay atmosphere to offset secondary layer from max size."
	atmospheric_calls.clear()
	presenter.spawn_travel("block", Vector2(20, 40), Vector2(200, 80), 0.2, 0.5, 4, 0.25)
	if atmospheric_calls.size() != 2:
		return "Expected intensity-four atmospheric travel to spawn primary and secondary lanes."
	var travel_primary: Dictionary = atmospheric_calls[0]
	var travel_center: Vector2 = travel_primary.get("center", Vector2.ZERO)
	var travel_size: Vector2 = travel_primary.get("size", Vector2.ZERO)
	if String(travel_primary.get("key", "")) != "travel_armor" or not is_equal_approx(travel_center.x, 120.0) or not is_equal_approx(travel_center.y, 80.0):
		return "Expected armor travel atmosphere to normalize kind and center on the travel path."
	if not is_equal_approx(travel_size.x, 228.33099) or not is_equal_approx(travel_size.y, 136.08):
		return "Expected armor travel atmosphere to scale lane size from path length and intensity."
	atmospheric_calls.clear()
	availability["value"] = false
	presenter.spawn_replay_layer("earth", Vector2(100, 160), 140.0, 180.0, 1.0, 6, true)
	presenter.spawn_travel("earth", Vector2(20, 40), Vector2(200, 80), 0.2, 0.5, 6, 0.25)
	if not atmospheric_calls.is_empty():
		return "Expected atmospheric presenter to skip spawning when assets are unavailable."
	return ""


func _test_combat_max_vfx_coin_rain_presenter_spawns_local_and_screen_wide_rain() -> String:
	var flipbook_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_COIN_RAIN_PRESENTER_SCRIPT.new()
	presenter.bind({
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float) -> void:
			flipbook_calls.append({"key": key, "center": center_local, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation, "spin": spin}),
	})
	presenter.spawn_coin_rain(Vector2(500, 400), 120.0, 1.0, 3, false)
	if flipbook_calls.size() != 39:
		return "Expected local coin rain to scale count by intensity."
	var local_coin: Dictionary = flipbook_calls[0]
	var local_center: Vector2 = local_coin.get("center", Vector2.ZERO)
	var local_move: Vector2 = local_coin.get("move_offset", Vector2.ZERO)
	if String(local_coin.get("key", "")) != "coin_spin":
		return "Expected coin rain to use the coin spin flipbook."
	if not is_equal_approx(local_center.x, 374.0) or not is_equal_approx(local_center.y, 311.2):
		return "Expected local coin rain to spread from the impact center."
	if not is_equal_approx(local_move.y, 150.0):
		return "Expected local coin rain to fall relative to base size."
	flipbook_calls.clear()
	presenter.spawn_coin_rain(Vector2(500, 400), 120.0, 1.0, 3, true)
	if flipbook_calls.size() != 48:
		return "Expected screen-wide coin rain to use the wider intensity count."
	var screen_coin: Dictionary = flipbook_calls[0]
	var screen_center: Vector2 = screen_coin.get("center", Vector2.ZERO)
	var screen_move: Vector2 = screen_coin.get("move_offset", Vector2.ZERO)
	if not is_equal_approx(screen_center.x, 60.0) or not is_equal_approx(screen_center.y, -40.0):
		return "Expected screen-wide coin rain to start above the screen across the layer."
	if not is_equal_approx(screen_move.y, 600.0):
		return "Expected screen-wide coin rain to fall through most of the layer."
	return ""


func _test_combat_max_vfx_status_recipe_presenter_spawns_afterimage_and_screen_wide() -> String:
	var status_calls: Array[Dictionary] = []
	var shield_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var coin_calls: Array[Dictionary] = []
	var pack_calls: Array[Dictionary] = []
	var burst_calls: Array[Dictionary] = []
	var fire_replay_calls: Array[Dictionary] = []
	var atmospheric_replay_calls: Array[Dictionary] = []
	var atmospheric_travel_calls: Array[Dictionary] = []
	var beam_calls: Array[Dictionary] = []
	var fire_cast_calls: Array[Dictionary] = []
	var earth_fracture_calls: Array[Dictionary] = []
	var camera_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"kind_cleaner": func(kind: String) -> String:
			var clean_kind := kind.strip_edges().to_lower()
			if clean_kind == "heal":
				return "heart"
			if clean_kind == "block":
				return "armor"
			return clean_kind,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"kind_colors_provider": func(kind: String) -> Dictionary:
			return {"core": Color(0.8, 0.6, 0.2, 1.0), "accent": Color(0.9, 0.7, 0.3, 1.0), "kind": kind},
		"status_sheet_key_provider": func(kind: String) -> String:
			return "sheet_%s" % kind,
		"status_trail_key_provider": func(kind: String) -> String:
			return "trail_%s" % kind,
		"status_flipbook_spawner": func(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
			status_calls.append({"key": sheet_key, "center": center_local, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation, "loops": loops}),
		"shield_scene_spawner": func(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, z: float) -> void:
			shield_calls.append({"center": center_local, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "move_offset": move_offset, "z": z}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		"coin_rain_spawner": func(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
			coin_calls.append({"center": center, "base_size": base_size, "lifetime": lifetime, "intensity": intensity, "screen_wide": screen_wide}),
		"fire_replay_layers_spawner": func(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
			fire_replay_calls.append({"center": center, "draw_size": draw_size, "max_size": max_size, "base_size": base_size, "duration": duration, "intensity": intensity, "screen_wide": screen_wide}),
		"fire_cast_layers_spawner": func(source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_duration: float, travel_duration: float, launch_delay: float, intensity: int, core: Color) -> void:
			fire_cast_calls.append({"source": source, "target": target, "delta": delta, "spool_size": spool_size, "spool_duration": spool_duration, "travel_duration": travel_duration, "launch_delay": launch_delay, "intensity": intensity, "core": core}),
		"earth_fracture_travel_spawner": func(source: Vector2, target: Vector2, delta: Vector2, normal: Vector2, travel_size: Vector2, duration: float, launch_delay: float, intensity: int, angle: float, tier: int) -> void:
			earth_fracture_calls.append({"source": source, "target": target, "delta": delta, "normal": normal, "travel_size": travel_size, "duration": duration, "launch_delay": launch_delay, "intensity": intensity, "angle": angle, "tier": tier}),
		"earth_tier_provider": func(intensity: int) -> int:
			return intensity + 2,
		"pack_impact_scene_key_provider": func(kind: String, intensity: int, screen_wide: bool) -> String:
			return "wide_%s_%d" % [kind, intensity] if screen_wide else "impact_%s_%d" % [kind, intensity],
		"atmospheric_replay_layer_spawner": func(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
			atmospheric_replay_calls.append({"kind": kind, "center": center, "max_size": max_size, "base_size": base_size, "lifetime": lifetime, "intensity": intensity, "screen_wide": screen_wide}),
		"atmospheric_travel_spawner": func(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
			atmospheric_travel_calls.append({"kind": kind, "source": source, "delta": delta, "launch_delay": launch_delay, "travel_duration": travel_duration, "intensity": intensity, "angle": angle}),
		"beam_effect_spawner": func(source: Vector2, delta: Vector2, kind: String, duration: float, intensity: int, delay: float, radius_scale: float) -> void:
			beam_calls.append({"source": source, "delta": delta, "kind": kind, "duration": duration, "intensity": intensity, "delay": delay, "radius_scale": radius_scale}),
		"pack_layer_spawner": func(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"key": scene_key, "center": center, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "rotation": rotation, "z": z, "alpha": alpha}),
		"burst_particles_spawner": func(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void:
			burst_calls.append({"kind": kind, "center": center, "base_size": base_size, "lifetime": lifetime, "intensity": intensity}),
		"camera_kick_spawner": func(direction: Vector2, delay: float) -> void:
			camera_calls.append({"direction": direction, "delay": delay}),
	})
	presenter.spawn_armor_linger(Vector2(100, 160), Vector2(200, 120), 1.0, 4)
	if shield_calls.size() != 0 or status_calls.size() != 14 or light_calls.size() != 1:
		return "Expected status armor linger to spawn grid snap status layers and one light without shield scenes."
	var linger_hex_count := 0
	var linger_bar_count := 0
	for call in status_calls:
		var entry: Dictionary = call
		var size: Vector2 = entry.get("size", Vector2.ZERO)
		if String(entry.get("key", "")) != "armor":
			return "Expected status armor grid snap to use armor status layers."
		if size.x > size.y * 2.0:
			linger_bar_count += 1
		elif is_equal_approx(size.y, size.x * 1.10):
			linger_hex_count += 1
	if linger_hex_count != 9 or linger_bar_count != 4:
		return "Expected status armor linger to spawn nine hex cells and four snap bars."
	status_calls.clear()
	shield_calls.clear()
	light_calls.clear()
	pack_calls.clear()
	burst_calls.clear()
	atmospheric_replay_calls.clear()
	presenter.spawn_replay_recipe("block", Vector2(100, 160), Vector2(200, 120), 140.0, 180.0, 1.0, 4, false)
	if status_calls.size() != 14 or shield_calls.size() != 0 or pack_calls.size() != 0 or burst_calls.size() != 1 or light_calls.size() != 1 or atmospheric_replay_calls.size() != 1:
		return "Expected armor status replay to spawn grid snap, burst, light, and atmosphere routes without shield or pack armor routes."
	var replay_hex_count := 0
	var replay_bar_count := 0
	for call in status_calls:
		var entry: Dictionary = call
		var size: Vector2 = entry.get("size", Vector2.ZERO)
		if size.x > size.y * 2.0:
			replay_bar_count += 1
		elif is_equal_approx(size.y, size.x * 1.10):
			replay_hex_count += 1
	if replay_hex_count != 9 or replay_bar_count != 4:
		return "Expected armor status replay to spawn nine hex cells and four snap bars."
	status_calls.clear()
	shield_calls.clear()
	light_calls.clear()
	pack_calls.clear()
	burst_calls.clear()
	atmospheric_replay_calls.clear()
	fire_replay_calls.clear()
	presenter.spawn_replay_recipe("fire", Vector2(100, 160), Vector2(200, 120), 140.0, 180.0, 1.0, 4, true)
	if fire_replay_calls.size() != 1 or status_calls.size() != 0 or pack_calls.size() != 0 or burst_calls.size() != 0 or light_calls.size() != 0 or atmospheric_replay_calls.size() != 0:
		return "Expected fire status replay to delegate to fire replay layers without generic status replay routes."
	var fire_replay: Dictionary = fire_replay_calls[0]
	if not bool(fire_replay.get("screen_wide", false)) or not is_equal_approx(float(fire_replay.get("base_size", 0.0)), 180.0):
		return "Expected fire status replay delegation to preserve screen-wide replay inputs."
	status_calls.clear()
	shield_calls.clear()
	light_calls.clear()
	pack_calls.clear()
	burst_calls.clear()
	atmospheric_replay_calls.clear()
	presenter.spawn_path_afterimage("heart", Vector2(10, 20), Vector2(300, 120), 0.2, 0.8, 4, 0.3)
	if status_calls.size() != 8:
		return "Expected heart status afterimage to emit eight trail flipbooks."
	var first: Dictionary = status_calls[0]
	var first_size: Vector2 = first.get("size", Vector2.ZERO)
	var first_color: Color = first.get("color", Color.TRANSPARENT)
	if String(first.get("key", "")) != "trail_heart":
		return "Expected status afterimage to use normalized trail key."
	if not is_equal_approx(first_size.x, 65.36) or not is_equal_approx(first_size.y, 88.56) or not is_equal_approx(first_color.a, 0.40):
		return "Expected heart status afterimage to apply support sizing and alpha."
	status_calls.clear()
	presenter.spawn_screen_wide("gold", Vector2(300, 700), 1.0, 5)
	if status_calls.size() != 10:
		return "Expected gold status screen-wide route to emit area plus nine bursts."
	if light_calls.size() != 1:
		return "Expected status screen-wide route to spawn one light."
	if coin_calls.size() != 1:
		return "Expected gold status screen-wide route to spawn coin rain."
	var wide: Dictionary = status_calls[0]
	var wide_center: Vector2 = wide.get("center", Vector2.ZERO)
	var wide_size: Vector2 = wide.get("size", Vector2.ZERO)
	if String(wide.get("key", "")) != "sheet_gold":
		return "Expected status screen-wide route to use status sheet key."
	if not is_equal_approx(wide_center.x, 500.0) or not is_equal_approx(wide_center.y, 688.0):
		return "Expected support status screen-wide focus to clamp into lower band."
	if not is_equal_approx(wide_size.x, 780.0) or not is_equal_approx(wide_size.y, 336.0):
		return "Expected support status screen-wide size to scale from layer size."
	var coin: Dictionary = coin_calls[0]
	if not bool(coin.get("screen_wide", false)) or not is_equal_approx(float(coin.get("base_size", 0.0)), 340.0):
		return "Expected gold status screen-wide coin rain to use wide mode and layer-scaled base size."
	status_calls.clear()
	light_calls.clear()
	coin_calls.clear()
	presenter.spawn_screen_wide("block", Vector2(300, 700), 1.0, 5)
	if light_calls.size() != 1:
		return "Expected armor status screen-wide route to spawn one light."
	var armor_wide_hex_count := 0
	var armor_wide_bar_count := 0
	for call in status_calls:
		var entry: Dictionary = call
		var size: Vector2 = entry.get("size", Vector2.ZERO)
		if String(entry.get("key", "")) != "armor":
			return "Expected armor status screen-wide route to use armor status layers instead of shield."
		if size.x > size.y * 2.0:
			armor_wide_bar_count += 1
		elif is_equal_approx(size.y, size.x * 1.10):
			armor_wide_hex_count += 1
	if armor_wide_hex_count != 9 or armor_wide_bar_count != 4:
		return "Expected armor status screen-wide route to use grid snap cells and bars."
	status_calls.clear()
	light_calls.clear()
	atmospheric_travel_calls.clear()
	beam_calls.clear()
	presenter.spawn_beam_recipe("block", Vector2(20, 40), Vector2(200, 80), 0.5, 4, 0.25)
	if atmospheric_travel_calls.size() != 1 or beam_calls.size() != 1 or status_calls.size() != 9:
		return "Expected support status beam to spawn atmosphere, beam, afterimage, and endpoint status."
	var beam: Dictionary = beam_calls[0]
	if String(beam.get("kind", "")) != "armor" or not is_equal_approx(float(beam.get("duration", 0.0)), 0.624) or not is_equal_approx(float(beam.get("radius_scale", 0.0)), 1.05):
		return "Expected status beam recipe to normalize kind and scale beam duration."
	var endpoint_status: Dictionary = status_calls[8]
	var endpoint_size: Vector2 = endpoint_status.get("size", Vector2.ZERO)
	if String(endpoint_status.get("key", "")) != "sheet_armor" or not is_equal_approx(endpoint_size.x, 198.0) or not is_equal_approx(endpoint_size.y, 136.0):
		return "Expected status beam endpoint layer to use the armor status sheet and scaled size."
	status_calls.clear()
	atmospheric_travel_calls.clear()
	beam_calls.clear()
	earth_fracture_calls.clear()
	presenter.spawn_beam_recipe("earth", Vector2(20, 40), Vector2(200, 80), 0.5, 4, 0.25)
	if earth_fracture_calls.size() != 1 or atmospheric_travel_calls.size() != 0 or beam_calls.size() != 0 or status_calls.size() != 0:
		return "Expected earth status beam to delegate to earth fracture travel without generic beam layers."
	var fracture: Dictionary = earth_fracture_calls[0]
	var fracture_size: Vector2 = fracture.get("travel_size", Vector2.ZERO)
	if int(fracture.get("tier", 0)) != 6 or not is_equal_approx(fracture_size.x, 276.0) or not is_equal_approx(fracture_size.y, 180.0):
		return "Expected earth status beam to pass tiered fracture travel sizing."
	status_calls.clear()
	shield_calls.clear()
	light_calls.clear()
	atmospheric_travel_calls.clear()
	beam_calls.clear()
	camera_calls.clear()
	presenter.spawn_cast_recipe("block", Vector2(20, 40), Vector2(220, 120), Vector2(200, 80), Vector2(100, 80), 0.5, 0.4, 4, Color(0.2, 0.4, 0.8, 1.0), Color(0.7, 0.9, 1.0, 1.0))
	if status_calls.size() != 16 or shield_calls.size() != 0 or light_calls.size() != 1 or atmospheric_travel_calls.size() != 1 or beam_calls.size() != 1 or camera_calls.size() != 1:
		return "Expected armor status cast to compose source/travel status, target grid snap, light, atmosphere, beam, and camera kick without shield scenes."
	var cast_beam: Dictionary = beam_calls[0]
	if String(cast_beam.get("kind", "")) != "armor" or not is_equal_approx(float(cast_beam.get("duration", 0.0)), 0.46096) or not is_equal_approx(float(cast_beam.get("delay", 0.0)), 0.584):
		return "Expected armor status cast to scale beam duration and launch delay."
	var cast_hex_count := 0
	var cast_bar_count := 0
	for call in status_calls:
		var entry: Dictionary = call
		var size: Vector2 = entry.get("size", Vector2.ZERO)
		if size.x > size.y * 2.0:
			cast_bar_count += 1
		elif is_equal_approx(size.y, size.x * 1.10):
			cast_hex_count += 1
	if cast_hex_count != 9 or cast_bar_count != 4:
		return "Expected armor status cast target to spawn nine hex cells and four snap bars."
	var camera: Dictionary = camera_calls[0]
	if not is_equal_approx(float(camera.get("delay", 0.0)), 1.0664):
		return "Expected armor status cast camera kick to land near travel impact."
	status_calls.clear()
	light_calls.clear()
	atmospheric_travel_calls.clear()
	beam_calls.clear()
	fire_cast_calls.clear()
	camera_calls.clear()
	presenter.spawn_cast_recipe("fire", Vector2(20, 40), Vector2(220, 120), Vector2(200, 80), Vector2(100, 80), 0.5, 0.4, 4, Color(0.2, 0.4, 0.8, 1.0), Color(0.7, 0.9, 1.0, 1.0))
	if fire_cast_calls.size() != 1 or status_calls.size() != 0 or light_calls.size() != 0 or atmospheric_travel_calls.size() != 0 or beam_calls.size() != 0 or camera_calls.size() != 0:
		return "Expected fire status cast to delegate to fire recipe without generic status cast layers."
	var fire_cast: Dictionary = fire_cast_calls[0]
	if not is_equal_approx(float(fire_cast.get("spool_duration", 0.0)), 0.73) or not is_equal_approx(float(fire_cast.get("travel_duration", 0.0)), 0.536):
		return "Expected fire status cast delegation to pass scaled cast timings."
	return ""


func _test_combat_max_vfx_mastery_recipe_presenter_routes_cast_and_beam() -> String:
	var availability := {
		"status": false,
		"elemental": false,
		"pack": false,
	}
	var status_cast_calls: Array[Dictionary] = []
	var elemental_cast_calls: Array[Dictionary] = []
	var pack_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var camera_calls: Array[Dictionary] = []
	var flipbook_calls: Array[Dictionary] = []
	var status_beam_calls: Array[Dictionary] = []
	var elemental_beam_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_MASTERY_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"status_available_provider": func() -> bool:
			return bool(availability.get("status", false)),
		"elemental_available_provider": func() -> bool:
			return bool(availability.get("elemental", false)),
		"pack_available_provider": func() -> bool:
			return bool(availability.get("pack", false)),
		"should_use_elemental_provider": func(kind: String) -> bool:
			return kind in ["fire", "ice", "earth", "gold"],
		"kind_for_orb_provider": func(orb_id: int) -> String:
			if orb_id == OrbType.Id.FIRE:
				return "fire"
			if orb_id == OrbType.Id.ICE:
				return "ice"
			if orb_id == OrbType.Id.EARTH:
				return "earth"
			if orb_id == OrbType.Id.GOLD:
				return "gold"
			return "heart",
		"kind_colors_provider": func(kind: String) -> Dictionary:
			return {"core": Color(0.2, 0.4, 0.8, 1.0), "accent": Color(0.7, 0.9, 1.0, 1.0), "kind": kind},
		"status_cast_spawner": func(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color, accent: Color) -> void:
			status_cast_calls.append({"kind": kind, "source": source, "target": target, "delta": delta, "spool_size": spool_size, "spool_lifetime": spool_lifetime, "travel_lifetime": travel_lifetime, "intensity": intensity, "core": core, "accent": accent}),
		"elemental_cast_spawner": func(kind: String, source: Vector2, target: Vector2, delta: Vector2, spool_size: Vector2, spool_lifetime: float, travel_lifetime: float, intensity: int, core: Color) -> void:
			elemental_cast_calls.append({"kind": kind, "source": source, "target": target, "delta": delta, "spool_size": spool_size, "spool_lifetime": spool_lifetime, "travel_lifetime": travel_lifetime, "intensity": intensity, "core": core}),
		"pack_hit_scene_key_provider": func(kind: String) -> String:
			return "hit_%s" % kind,
		"pack_impact_scene_key_provider": func(kind: String, intensity: int, screen_wide: bool) -> String:
			return "impact_%s_%d_%s" % [kind, intensity, str(screen_wide)],
		"pack_effect_spawner": func(scene_key: String, center: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
			pack_calls.append({"scene_key": scene_key, "center": center, "kind": kind, "size": draw_size, "lifetime": lifetime, "intensity": intensity, "delay": delay, "move_offset": move_offset, "rotation": rotation, "z": z, "alpha": alpha}),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		"camera_kick_spawner": func(direction: Vector2, delay: float) -> void:
			camera_calls.append({"direction": direction, "delay": delay}),
		"impact_key_provider": func(kind: String) -> String:
			return "impact_%s" % kind,
		"projectile_key_provider": func(kind: String) -> String:
			return "projectile_%s" % kind,
		"trail_key_provider": func(kind: String) -> String:
			return "trail_%s" % kind,
		"flipbook_spawner": func(key: String, center: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
			flipbook_calls.append({"key": key, "center": center, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation}),
		"status_beam_spawner": func(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
			status_beam_calls.append({"kind": kind, "source": source, "delta": delta, "lifetime": lifetime, "intensity": intensity, "angle": angle}),
		"elemental_beam_spawner": func(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
			elemental_beam_calls.append({"kind": kind, "source": source, "delta": delta, "lifetime": lifetime, "intensity": intensity, "angle": angle}),
	})
	var source := Vector2(20, 40)
	var target := Vector2(220, 120)
	availability["status"] = true
	if not presenter.spawn_cast_sequence(OrbType.Id.FIRE, source, target, 0.5, 0.4, 24):
		return "Expected mastery presenter to accept valid cast sequence inputs."
	if status_cast_calls.size() != 1 or elemental_cast_calls.size() != 0 or pack_calls.size() != 0 or flipbook_calls.size() != 0:
		return "Expected mastery cast to prefer status recipe delegation."
	var status_cast: Dictionary = status_cast_calls[0]
	var status_spool: Vector2 = status_cast.get("spool_size", Vector2.ZERO)
	if String(status_cast.get("kind", "")) != "fire" or int(status_cast.get("intensity", 0)) != 5:
		return "Expected status mastery cast route to resolve orb kind and result intensity."
	if not is_equal_approx(status_spool.x, 210.0) or not is_equal_approx(status_spool.y, 210.0):
		return "Expected status mastery cast route to pass computed spool size."
	availability["status"] = false
	availability["elemental"] = true
	status_cast_calls.clear()
	presenter.spawn_cast_sequence(OrbType.Id.EARTH, source, target, 0.5, 0.4, 8)
	if elemental_cast_calls.size() != 1 or status_cast_calls.size() != 0 or pack_calls.size() != 0:
		return "Expected mastery cast to prefer elemental recipe when status VFX is unavailable."
	var elemental_cast: Dictionary = elemental_cast_calls[0]
	if String(elemental_cast.get("kind", "")) != "earth" or int(elemental_cast.get("intensity", 0)) != 3:
		return "Expected elemental mastery cast route to pass kind and intensity."
	availability["elemental"] = false
	availability["pack"] = true
	elemental_cast_calls.clear()
	presenter.spawn_cast_sequence(OrbType.Id.ICE, source, target, 0.5, 0.4, 16)
	if pack_calls.size() != 3 or light_calls.size() != 1 or camera_calls.size() != 1:
		return "Expected pack mastery cast fallback to emit charge, travel, impact, light, and camera kick."
	var pack_impact: Dictionary = pack_calls[2]
	if String(pack_impact.get("scene_key", "")) != "impact_ice_4_false" or not is_equal_approx(float(pack_impact.get("delay", 0.0)), 0.844):
		return "Expected pack mastery cast fallback to use impact key provider and impact delay."
	var pack_camera: Dictionary = camera_calls[0]
	if not is_equal_approx(float(pack_camera.get("delay", 0.0)), 0.84):
		return "Expected pack mastery cast camera kick to align with travel impact."
	availability["pack"] = false
	pack_calls.clear()
	light_calls.clear()
	camera_calls.clear()
	presenter.spawn_cast_sequence(OrbType.Id.GOLD, source, target, 0.5, 0.4, 8)
	if flipbook_calls.size() != 25 or light_calls.size() != 1 or camera_calls.size() != 1:
		return "Expected fallback mastery cast to emit spool, projectile, trail flipbooks, light, and camera kick."
	var projectile: Dictionary = flipbook_calls[2]
	if String(projectile.get("key", "")) != "projectile_gold" or not is_equal_approx(float(projectile.get("delay", 0.0)), 0.5):
		return "Expected fallback mastery cast projectile to launch after spool lifetime."
	availability["status"] = true
	flipbook_calls.clear()
	light_calls.clear()
	camera_calls.clear()
	if not presenter.spawn_beam(OrbType.Id.FIRE, source, target, 0.42):
		return "Expected mastery presenter to accept valid beam inputs."
	if status_beam_calls.size() != 1 or elemental_beam_calls.size() != 0 or pack_calls.size() != 0 or flipbook_calls.size() != 0:
		return "Expected mastery beam to prefer status recipe delegation."
	var status_beam: Dictionary = status_beam_calls[0]
	if String(status_beam.get("kind", "")) != "fire" or int(status_beam.get("intensity", 0)) != 4:
		return "Expected status mastery beam route to compute beam intensity from length."
	availability["status"] = false
	availability["elemental"] = true
	status_beam_calls.clear()
	presenter.spawn_beam(OrbType.Id.EARTH, source, target, 0.42)
	if elemental_beam_calls.size() != 1 or status_beam_calls.size() != 0:
		return "Expected mastery beam to route elemental kinds to elemental beam recipe."
	availability["elemental"] = false
	availability["pack"] = true
	elemental_beam_calls.clear()
	presenter.spawn_beam(OrbType.Id.ICE, source, target, 0.42)
	if pack_calls.size() != 1 or flipbook_calls.size() != 0:
		return "Expected mastery beam pack fallback to emit a single pack beam layer."
	availability["pack"] = false
	pack_calls.clear()
	presenter.spawn_beam(OrbType.Id.GOLD, source, target, 0.42)
	if flipbook_calls.size() != 2:
		return "Expected mastery beam fallback to emit ray and projectile flipbooks."
	if presenter.spawn_cast_sequence(OrbType.Id.FIRE, source, source + Vector2(0.5, 0.0), 0.5, 0.4, 8):
		return "Expected mastery cast to reject near-zero travel delta."
	if presenter.spawn_beam(OrbType.Id.FIRE, source, source + Vector2(0.5, 0.0), 0.42):
		return "Expected mastery beam to reject near-zero travel delta."
	return ""


func _test_combat_max_vfx_burst_particles_presenter_spawns_flipbooks_and_gpu_particles() -> String:
	var flipbook_calls: Array[Dictionary] = []
	var gpu_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_BURST_PARTICLES_PRESENTER_SCRIPT.new()
	presenter.bind({
		"kind_colors_provider": func(kind: String) -> Dictionary:
			return {
				"core": Color(0.2, 0.4, 0.8, 1.0),
				"accent": Color(0.7, 0.9, 1.0, 1.0),
				"kind": kind,
			},
		"particle_key_provider": func(kind: String) -> String:
			return "ice_shards" if kind == "ice" else "spark",
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float) -> void:
			flipbook_calls.append({"key": key, "center": center_local, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation, "spin": spin}),
		"gpu_particles_spawner": func(texture_key: String, center: Vector2, amount: int, color: Color, radius: float, lifetime: float, kind: String) -> void:
			gpu_calls.append({"key": texture_key, "center": center, "amount": amount, "color": color, "radius": radius, "lifetime": lifetime, "kind": kind}),
	})
	presenter.spawn_burst_particles("ice", Vector2(100, 120), 80.0, 1.0, 3)
	if flipbook_calls.size() != 39:
		return "Expected burst particles to spawn intensity-scaled flipbooks."
	if gpu_calls.size() != 1:
		return "Expected burst particles to delegate one GPU particle burst."
	var first: Dictionary = flipbook_calls[0]
	var first_center: Vector2 = first.get("center", Vector2.ZERO)
	var first_size: Vector2 = first.get("size", Vector2.ZERO)
	var first_color: Color = first.get("color", Color.TRANSPARENT)
	if String(first.get("key", "")) != "ice_shards":
		return "Expected burst particles to use the provided particle key."
	if not is_equal_approx(first_center.x, 108.0) or not is_equal_approx(first_center.y, 120.0):
		return "Expected first burst particle to start on the radial edge."
	if first_size != Vector2(57, 94):
		return "Expected shard particle key to use tall particle sizing."
	if not is_equal_approx(first_color.r, 0.2) or not is_equal_approx(first_color.a, 0.78):
		return "Expected first burst particle to use core color with visual alpha."
	var gpu: Dictionary = gpu_calls[0]
	if String(gpu.get("key", "")) != "ice_shards" or int(gpu.get("amount", 0)) != 52:
		return "Expected GPU particle burst to use particle key and capped intensity amount."
	if not is_equal_approx(float(gpu.get("radius", 0.0)), 22.4) or not is_equal_approx(float(gpu.get("lifetime", 0.0)), 0.66):
		return "Expected GPU particle burst to scale radius and lifetime from recipe inputs."
	flipbook_calls.clear()
	gpu_calls.clear()
	presenter.spawn_burst_particles("gold", Vector2(100, 120), 80.0, 1.0, 12)
	if flipbook_calls.size() != 102:
		return "Expected high-intensity burst particles to keep uncapped flipbook count."
	var gold_first: Dictionary = flipbook_calls[0]
	var gold_travel: Vector2 = gold_first.get("move_offset", Vector2.ZERO)
	if gold_travel.y >= 0.0:
		return "Expected gold burst particles to bias travel upward before falling GPU gravity."
	if int(gpu_calls[0].get("amount", 0)) != 96:
		return "Expected high-intensity GPU particle burst to cap at 96."
	return ""


func _test_combat_max_vfx_screen_wide_presenter_spawns_fallback_layers() -> String:
	var flipbook_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var coin_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_SCREEN_WIDE_PRESENTER_SCRIPT.new()
	presenter.bind({
		"kind_colors_provider": func(kind: String) -> Dictionary:
			return {"core": Color(0.3, 0.6, 0.9, 1.0), "accent": Color(0.7, 0.8, 1.0, 1.0), "kind": kind},
		"impact_key_provider": func(kind: String) -> String:
			return "impact_%s" % kind,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
			light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		"flipbook_spawner": func(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
			flipbook_calls.append({"key": key, "center": center_local, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "move_offset": move_offset, "target_scale": target_scale, "z": z, "rotation": rotation}),
		"coin_rain_spawner": func(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
			coin_calls.append({"center": center, "base_size": base_size, "lifetime": lifetime, "intensity": intensity, "screen_wide": screen_wide}),
	})
	presenter.spawn_screen_wide("fire", Vector2(300, 700), 1.0, 4)
	if flipbook_calls.size() != 12:
		return "Expected fallback screen-wide fire to emit impact plus eleven ray flipbooks."
	if light_calls.size() != 1:
		return "Expected fallback screen-wide fire to emit one light."
	if not coin_calls.is_empty():
		return "Expected fallback screen-wide fire to avoid coin rain."
	var impact: Dictionary = flipbook_calls[0]
	var impact_center: Vector2 = impact.get("center", Vector2.ZERO)
	var impact_size: Vector2 = impact.get("size", Vector2.ZERO)
	if String(impact.get("key", "")) != "impact_fire":
		return "Expected fallback screen-wide to use impact key provider."
	if not is_equal_approx(impact_center.x, 500.0) or not is_equal_approx(impact_center.y, 368.0):
		return "Expected offensive fallback screen-wide focus to clamp into upper band."
	if not is_equal_approx(impact_size.x, 1150.0) or not is_equal_approx(impact_size.y, 368.0):
		return "Expected offensive fallback screen-wide size to scale from layer."
	var first_ray: Dictionary = flipbook_calls[1]
	var first_ray_center: Vector2 = first_ray.get("center", Vector2.ZERO)
	var first_ray_size: Vector2 = first_ray.get("size", Vector2.ZERO)
	if String(first_ray.get("key", "")) != "light_rays":
		return "Expected fallback screen-wide to emit light ray flipbooks."
	if not is_equal_approx(first_ray_center.y, 260.0) or not is_equal_approx(first_ray_size.x, 720.0):
		return "Expected first fallback ray to be positioned and sized from focus and layer."
	flipbook_calls.clear()
	light_calls.clear()
	coin_calls.clear()
	presenter.spawn_screen_wide("gold", Vector2(300, 700), 1.0, 5)
	if flipbook_calls.size() != 13 or light_calls.size() != 1 or coin_calls.size() != 1:
		return "Expected fallback gold screen-wide to emit support layers, light, and coin rain."
	var gold_impact: Dictionary = flipbook_calls[0]
	var gold_center: Vector2 = gold_impact.get("center", Vector2.ZERO)
	if not is_equal_approx(gold_center.y, 688.0):
		return "Expected support fallback screen-wide focus to clamp into lower band."
	var coin: Dictionary = coin_calls[0]
	if not bool(coin.get("screen_wide", false)) or not is_equal_approx(float(coin.get("base_size", 0.0)), 340.0):
		return "Expected fallback gold screen-wide to delegate wide coin rain."
	return ""


func _test_combat_max_vfx_gpu_particles_presenter_spawns_configured_particles() -> String:
	var root := Node3D.new()
	var queue_calls: Array[Dictionary] = []
	var texture := ImageTexture.create_from_image(Image.create(8, 8, false, Image.FORMAT_RGBA8))
	var presenter = COMBAT_MAX_VFX_GPU_PARTICLES_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root,
		"texture_provider": func(key: String) -> Texture2D:
			return texture if key == "spark" else null,
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x + 1.0, 800.0 - screen_position.y, z),
		"queue_free_after": func(node: Node, delay: float) -> void:
			queue_calls.append({"node": node, "delay": delay}),
	})
	var particles: GPUParticles3D = presenter.spawn_gpu_particles("spark", Vector2(20, 30), 64, Color(0.2, 0.4, 0.8, 1.0), 25.0, 0.5, "gold")
	if particles == null:
		root.free()
		return "Expected GPU particle presenter to create particles when texture is available."
	if root.get_child_count() != 1 or root.get_child(0) != particles:
		root.free()
		return "Expected GPU particle presenter to attach particles to root."
	if particles.position != Vector3(21.0, 770.0, 2.4) or particles.amount != 64:
		root.free()
		return "Expected GPU particles to project position and preserve amount."
	if not is_equal_approx(particles.lifetime, 0.5) or not particles.one_shot or not particles.emitting:
		root.free()
		return "Expected GPU particles to configure lifetime and one-shot emission."
	var process := particles.process_material as ParticleProcessMaterial
	if process == null:
		root.free()
		return "Expected GPU particles to use process material."
	if not is_equal_approx(process.emission_sphere_radius, 25.0) or process.gravity != Vector3(0.0, -58.0, 0.0):
		root.free()
		return "Expected gold GPU particles to use radius and gold gravity."
	if not is_equal_approx(process.initial_velocity_min, 8.0) or not is_equal_approx(process.initial_velocity_max, 23.0):
		root.free()
		return "Expected GPU particle velocity to scale from radius."
	var mesh := particles.draw_pass_1 as QuadMesh
	if mesh == null or mesh.size != Vector2(34, 34):
		root.free()
		return "Expected GPU particles to use quad mesh draw pass."
	var material := mesh.material as StandardMaterial3D
	if material == null or material.albedo_texture != texture or not is_equal_approx(material.albedo_color.a, 0.70):
		root.free()
		return "Expected GPU particle material to use texture and alpha."
	if queue_calls.size() != 1 or queue_calls[0].get("node") != particles or not is_equal_approx(float(queue_calls[0].get("delay", 0.0)), 0.74):
		root.free()
		return "Expected GPU particle presenter to queue cleanup after lifetime padding."
	var missing := presenter.spawn_gpu_particles("missing", Vector2.ZERO, 1, Color.WHITE, 2.0, 0.1, "ice")
	if missing != null or root.get_child_count() != 1:
		root.free()
		return "Expected missing particle texture to skip spawning."
	root.free()
	return ""


func _test_combat_max_vfx_light_presenter_spawns_projected_light() -> String:
	var root := Node3D.new()
	var presenter = COMBAT_MAX_VFX_LIGHT_PRESENTER_SCRIPT.new()
	presenter.bind({
		"root_3d": root,
		"screen_to_world_position": func(screen_position: Vector2, z: float) -> Vector3:
			return Vector3(screen_position.x + 2.0, 800.0 - screen_position.y, z),
	})
	var light: OmniLight3D = presenter.spawn_light(Vector2(40, 50), Color(0.2, 0.5, 0.9, 1.0), 2.4, 32.0, 0.6)
	if light == null:
		root.free()
		return "Expected light presenter to create a light with a valid root."
	if root.get_child_count() != 1 or root.get_child(0) != light:
		root.free()
		return "Expected light presenter to attach light to root."
	if light.position != Vector3(42.0, 750.0, 90.0):
		root.free()
		return "Expected light presenter to project screen center into world position."
	if not _color_equal(light.light_color, Color(0.2, 0.5, 0.9, 1.0)):
		root.free()
		return "Expected light presenter to preserve light color."
	if not is_equal_approx(light.light_energy, 2.4) or not is_equal_approx(light.omni_range, 64.0):
		root.free()
		return "Expected light presenter to preserve energy and floor omni range."
	root.free()
	var missing_root_presenter = COMBAT_MAX_VFX_LIGHT_PRESENTER_SCRIPT.new()
	missing_root_presenter.bind({})
	if missing_root_presenter.spawn_light(Vector2.ZERO, Color.WHITE, 1.0, 1.0, 0.1) != null:
		return "Expected light presenter to skip spawning without a root."
	return ""


func _test_combat_max_vfx_cleanup_presenter_queues_without_timer_tree() -> String:
	var presenter = COMBAT_MAX_VFX_CLEANUP_PRESENTER_SCRIPT.new()
	presenter.bind({})
	presenter.queue_free_after(null, 1.0)
	var node := Node.new()
	presenter.queue_free_after(node, 0.8)
	if not node.is_queued_for_deletion():
		node.free()
		return "Expected cleanup presenter to queue free immediately without timer owner."
	var owner := Node.new()
	var detached_node := Node.new()
	presenter.bind({"timer_owner": owner})
	presenter.queue_free_after(detached_node, 0.8)
	if not detached_node.is_queued_for_deletion():
		owner.free()
		detached_node.free()
		return "Expected cleanup presenter to queue free immediately without timer tree."
	owner.free()
	return ""


func _test_combat_max_vfx_camera_kick_presenter_ignores_missing_tree() -> String:
	var camera := Camera3D.new()
	camera.position = Vector3(100.0, 200.0, 300.0)
	var owner := Node.new()
	var presenter = COMBAT_MAX_VFX_CAMERA_KICK_PRESENTER_SCRIPT.new()
	presenter.bind({
		"camera": camera,
		"timer_owner": owner,
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
		"screen_to_world_offset": func(screen_offset: Vector2) -> Vector3:
			return Vector3(screen_offset.x, -screen_offset.y, 0.0),
	})
	presenter.spawn_camera_kick(Vector2(40.0, -40.0), 0.2)
	if camera.position != Vector3(100.0, 200.0, 300.0):
		camera.free()
		owner.free()
		return "Expected detached camera kick presenter to leave camera unchanged."
	camera.free()
	owner.free()
	var missing_camera_presenter = COMBAT_MAX_VFX_CAMERA_KICK_PRESENTER_SCRIPT.new()
	missing_camera_presenter.bind({})
	missing_camera_presenter.spawn_camera_kick(Vector2.ONE, 0.0)
	return ""


func _test_combat_max_vfx_projector_maps_screen_to_world_space() -> String:
	var projector = COMBAT_MAX_VFX_PROJECTOR_SCRIPT.new()
	projector.bind({
		"layer_size_provider": func() -> Vector2:
			return Vector2(1000, 800),
	})
	if projector.screen_to_world_position(Vector2(120, 250), 9.0) != Vector3(120, 550, 9.0):
		return "Expected projector to flip screen y into world y using layer height."
	if projector.screen_to_world_offset(Vector2(16, -20)) != Vector3(16, 20, 0):
		return "Expected projector to flip screen offset y."
	if not is_equal_approx(projector.screen_to_world_rotation(0.75), -0.75):
		return "Expected projector to invert screen rotation."
	var fallback_projector = COMBAT_MAX_VFX_PROJECTOR_SCRIPT.new()
	fallback_projector.bind({})
	if fallback_projector.screen_to_world_position(Vector2(12, 5), 2.0) != Vector3(12, -5, 2.0):
		return "Expected projector fallback to use zero layer height."
	return ""


func _test_post_match_vfx_policy_normalizes_tiers_and_caps() -> String:
	var policy = COMBAT_POST_MATCH_VFX_POLICY_SCRIPT.new()
	if policy.quality() != "low":
		return "Expected policy to default to Low quality."
	policy.set_quality(" HIGH ")
	if policy.quality() != "high" or not policy.quality_uses_max_overlay():
		return "Expected quality to normalize and enable max-overlay mode."
	policy.set_quality("invalid")
	if policy.quality() != "low":
		return "Expected invalid quality to normalize back to Low."
	var heal_profile: Dictionary = policy.impact_profile("heal", 4, Vector2(100, 100), 1.0)
	if int(heal_profile.get("tier", -1)) != 1:
		return "Expected heal alias to use heart thresholds."
	var block_profile: Dictionary = policy.impact_profile("block", 12, Vector2(100, 100), 1.0)
	if int(block_profile.get("tier", -1)) != 3:
		return "Expected block alias to use armor screen-wide thresholds."
	if not policy.result_is_screen_wide("gold", 10):
		return "Expected policy to mark Gold 10 as screen-wide."
	var caps: Dictionary = policy.runtime_caps()
	if int(caps.get("max_particles_per_burst", 0)) != 72 or int(caps.get("max_screen_rays", 0)) != 18:
		return "Expected policy runtime caps to preserve phone-first limits."
	if policy.runtime_particle_count(8, 2.0) > int(caps.get("max_particles_per_burst", 0)):
		return "Expected policy particle counts to obey caps."
	var default_lifetime := float(policy.impact_profile("fire", 0, Vector2(100, 100), 1.0).get("lifetime", 0.0))
	policy.set_speed_scale(1.0)
	var baseline_lifetime := float(policy.impact_profile("fire", 0, Vector2(100, 100), 1.0).get("lifetime", 0.0))
	if default_lifetime <= baseline_lifetime:
		return "Expected default policy speed to extend post-match VFX lifetime."
	var layer_size := Vector2(1000, 800)
	if not policy.screen_replay_is_offensive("damage") or policy.screen_replay_is_offensive("gold"):
		return "Expected screen replay policy to classify offensive result kinds."
	var offensive_focus := policy.screen_replay_focus(layer_size, Vector2(900, 700), "fire")
	if not is_equal_approx(offensive_focus.x, 880.0) or not is_equal_approx(offensive_focus.y, 336.0):
		return "Expected offensive screen replay focus to clamp into the upper combat band."
	var support_focus := policy.screen_replay_focus(layer_size, Vector2.ZERO, "heal")
	if not is_equal_approx(support_focus.x, 500.0) or not is_equal_approx(support_focus.y, 496.0):
		return "Expected support screen replay focus to use the lower combat band and heal alias."
	return ""


func _test_runtime_vfx_texture_factory_generates_and_caches_keys() -> String:
	var factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	var keys: Array = factory.texture_keys()
	for key in ["soft_glow", "ray", "spark", "smoke", "coin", "ripple", "shard", "shield", "hex_cell"]:
		if not keys.has(key):
			return "Expected runtime texture factory key %s." % key
		var texture: Texture2D = factory.texture(key)
		if texture == null:
			return "Expected runtime texture factory to generate %s." % key
		if texture != factory.texture(" %s " % key.to_upper()):
			return "Expected runtime texture factory to cache normalized key %s." % key
	var fallback_texture: Texture2D = factory.texture("missing-key")
	if fallback_texture == null or fallback_texture != factory.texture("soft_glow"):
		return "Expected missing runtime texture key to fall back to cached soft_glow."
	return ""


func _test_combat_vfx_profile_maps_orbs_and_result_colors() -> String:
	var profile = COMBAT_VFX_PROFILE_SCRIPT.new()
	if profile.mastery_impact_kind(OrbType.Id.FIRE) != "fire":
		return "Expected Fire orb to map to fire impact kind."
	if profile.mastery_impact_kind(OrbType.Id.GOLD) != "gold":
		return "Expected Gold orb to map to gold impact kind."
	var fire_colors: Dictionary = profile.result_effect_colors("fire")
	var fire_mastery_colors: Dictionary = profile.mastery_cast_colors(OrbType.Id.FIRE)
	if not _color_equal(fire_colors.get("accent", Color.BLACK), fire_mastery_colors.get("accent", Color.WHITE)):
		return "Expected Fire result and mastery palettes to share the same accent."
	var heal_colors: Dictionary = profile.result_effect_colors("heal")
	var heart_colors: Dictionary = profile.result_effect_colors("heart")
	if not _color_equal(heal_colors.get("core", Color.BLACK), heart_colors.get("core", Color.WHITE)):
		return "Expected heal result colors to alias heart colors."
	if not _color_equal(profile.result_label_color("block"), profile.result_label_color("armor")):
		return "Expected block label color to alias armor label color."
	var heal_label := profile.result_label_color("heal")
	if heal_label.g >= 0.9 or heal_label.r < heal_label.g:
		return "Expected heal result label color to use the warm HP palette instead of bright green."
	if not _color_equal(profile.result_label_color("damage", true), Color.WHITE):
		return "Expected high-contrast offensive labels to use white."
	return ""


func _test_enemy_attack_vfx_presenter_spawns_fallback_cues() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(320, 240)
	tree.root.add_child(root)
	root.add_child(layer)
	var presenter = COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({"vfx_layer": layer, "timer_owner": root})
	presenter.spawn_cue(Vector2.ZERO)
	if layer.get_child_count() != 0:
		root.free()
		return "Expected zero-position enemy cue to no-op."
	presenter.spawn_cue(Vector2(40, 50), 0.2)
	if layer.get_child_count() != 1 or String(layer.get_child(0).name) != "EnemyAttackPulse":
		root.free()
		return "Expected enemy cue to spawn one pulse."
	presenter.spawn_travel(Vector2(40, 50), Vector2(180, 90), 0.2)
	if layer.get_child_count() < 3:
		root.free()
		return "Expected enemy travel to spawn beam and bolt fallback nodes."
	presenter.spawn_block_impact(Vector2(120, 90), 0.2)
	var block_hex_count := _count_children_named(layer, "EnemyAttackArmorHexCell")
	var block_bar_count := _count_children_named(layer, "EnemyAttackArmorSnapBar")
	if block_hex_count != 9 or block_bar_count != 4:
		var block_child_count := layer.get_child_count()
		root.free()
		return "Expected blocked enemy attack fallback to use armor hex snap cells and bars; got hex=%d bars=%d children=%d." % [block_hex_count, block_bar_count, block_child_count]
	presenter.spawn_hit_impact(Vector2(160, 100), 0.2)
	if layer.get_child_count() < 17:
		root.free()
		return "Expected enemy impact fallbacks to spawn snap armor and hit pulse nodes."
	root.free()
	return ""


func _test_result_label_presenter_spawns_scaled_labels() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(320, 240)
	root.add_child(layer)
	var presenter = COMBAT_RESULT_LABEL_PRESENTER_SCRIPT.new()
	presenter.bind({"vfx_layer": layer, "timer_owner": root})
	if presenter.spawn_result_label("", Vector2(80, 90), 0.2, Vector2.ZERO, 1.0, Color.WHITE) != null:
		root.free()
		return "Expected empty result label text to no-op."
	if presenter.spawn_result_label("+4", Vector2.ZERO, 0.2, Vector2.ZERO, 1.0, Color.WHITE) != null:
		root.free()
		return "Expected zero-position result label to no-op."
	var label: Label = presenter.spawn_result_label("+12", Vector2(80, 90), 0.2, Vector2(10, -5), 1.5, Color.RED)
	if label == null or layer.get_child_count() != 1:
		root.free()
		return "Expected result label presenter to spawn one label."
	if label.text != "+12" or label.z_index != 500 or not label.z_as_relative == false:
		root.free()
		return "Expected result label text and draw ordering to be applied."
	if not is_equal_approx(label.size.x, 360.0) or not is_equal_approx(label.size.y, 105.0):
		root.free()
		return "Expected result label size to scale from the base dimensions."
	if int(label.get_theme_font_size("font_size")) != 63:
		root.free()
		return "Expected result label font size to scale."
	root.free()
	return ""


func _test_runtime_vfx_sprite_presenter_spawns_materialized_sprites() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(320, 240)
	root.add_child(layer)
	var missing_factory_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	missing_factory_presenter.bind({"vfx_layer": layer, "timer_owner": root})
	if missing_factory_presenter.spawn_sprite_local("NoTexture", "soft_glow", Vector2(80, 80), Vector2(40, 40), Color.WHITE, 0.2, Vector2.ONE) != null:
		root.free()
		return "Expected runtime sprite presenter without a texture factory to no-op."
	var presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	var factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	presenter.bind({"vfx_layer": layer, "timer_owner": root, "runtime_texture_factory": factory})
	var sprite: TextureRect = presenter.spawn_sprite_local("RuntimeSpark", "spark", Vector2(80, 90), Vector2(48, 36), Color.RED, 0.2, Vector2(0.5, 0.5), 0.1, Vector2(8, 0), 0.25, 127, 0.4)
	if sprite == null or layer.get_child_count() != 1:
		root.free()
		return "Expected runtime sprite presenter to add one sprite."
	if sprite.name != "RuntimeSpark" or String(sprite.get_meta("effect_name", "")) != "RuntimeSpark":
		root.free()
		return "Expected runtime sprite metadata to be set."
	if sprite.texture == null or not sprite.material is ShaderMaterial:
		root.free()
		return "Expected runtime sprite texture and additive shader material."
	if not is_equal_approx(sprite.size.x, 48.0) or not is_equal_approx(sprite.position.x, 56.0) or sprite.z_index != 127:
		root.free()
		return "Expected runtime sprite size, centered position, and z-index."
	if presenter.spawn_texture_local("NullTexture", null, Vector2(80, 90), Vector2(48, 36), Color.WHITE, 0.2, Vector2.ONE) != null:
		root.free()
		return "Expected runtime sprite presenter to ignore null explicit textures."
	root.free()
	return ""


func _test_runtime_vfx_primitive_presenter_maps_effects_and_spawns_primitives() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(320, 240)
	root.add_child(layer)
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	var factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	sprite_presenter.bind({"vfx_layer": layer, "timer_owner": root, "runtime_texture_factory": factory})
	var presenter = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
	presenter.bind({"vfx_layer": layer, "runtime_sprite_presenter": sprite_presenter})
	if presenter.runtime_texture_key_for_effect("CoinBurst", Vector2(20, 20), 999) != "coin":
		root.free()
		return "Expected coin-named effects to use coin texture."
	if presenter.runtime_texture_key_for_effect("TallSlash", Vector2(6, 48), 999) != "ray":
		root.free()
		return "Expected tall primitive effects to use ray texture."
	if presenter.runtime_texture_key_for_effect("ArmorPulse", Vector2(64, 48), 999) != "hex_cell":
		root.free()
		return "Expected armor-named primitives to avoid the old shield texture."
	presenter.spawn_replay_ring(Vector2(80, 90), Vector2(40, 40), Color.BLUE, Color.WHITE, 2, 0.2, Vector2.ONE, 0.0)
	if layer.get_child_count() != 2:
		root.free()
		return "Expected replay ring primitive to spawn glow and ring sprites."
	presenter.spawn_replay_particle(Vector2(80, 90), Vector2.ZERO, Vector2(0, 24), Vector2(8, 24), Color.RED, 0.2, 0.0, 4)
	var particle := layer.get_child(layer.get_child_count() - 1) as TextureRect
	if particle == null or particle.name != "PostMatchParticle" or particle.texture == null:
		root.free()
		return "Expected replay particle primitive to spawn a materialized sprite."
	presenter.spawn_local_effect_panel("ArmorPulse", Vector2(90, 90), Vector2(64, 48), Color(0.1, 0.2, 1.0, 0.20), Color.WHITE, 2, 999, 140, 0.2, Vector2.ONE)
	if layer.get_child_count() != 5:
		root.free()
		return "Expected armor local panel to spawn glow and hex-cell sprites."
	root.free()
	return ""


func _test_screen_wide_replay_presenter_spawns_offensive_and_support_events() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(1000, 800)
	root.add_child(layer)
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	var factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	sprite_presenter.bind({"vfx_layer": layer, "timer_owner": root, "runtime_texture_factory": factory})
	var primitive_presenter = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
	primitive_presenter.bind({"vfx_layer": layer, "runtime_sprite_presenter": sprite_presenter})
	var presenter = COMBAT_SCREEN_WIDE_REPLAY_PRESENTER_SCRIPT.new()
	presenter.bind({
		"vfx_layer": layer,
		"post_match_policy": COMBAT_POST_MATCH_VFX_POLICY_SCRIPT.new(),
		"runtime_primitive_presenter": primitive_presenter,
		"runtime_sprite_presenter": sprite_presenter,
		"vfx_profile": COMBAT_VFX_PROFILE_SCRIPT.new(),
	})
	presenter.spawn_screen_wide_replay_event(Vector2(900, 700), "fire", 0.8, 4)
	var offensive_count := layer.get_child_count()
	if offensive_count < 18:
		root.free()
		return "Expected offensive screen-wide replay event to spawn layered screen primitives."
	if _count_children_named(layer, "PostMatchScreenFireColumn") <= 0:
		root.free()
		return "Expected fire screen-wide replay event to spawn fire columns."
	presenter.spawn_screen_wide_replay_event(Vector2.ZERO, "heal", 0.8, 3)
	if layer.get_child_count() <= offensive_count:
		root.free()
		return "Expected support screen-wide replay event to add more primitives."
	if _count_children_named(layer, "PostMatchScreenHealStream") <= 0:
		root.free()
		return "Expected heal screen-wide replay event to spawn heal streams."
	presenter.spawn_screen_wide_replay_event(Vector2(520, 620), "armor", 0.8, 4)
	if _count_children_named(layer, "PostMatchScreenArmorShell") != 0:
		root.free()
		return "Expected armor screen-wide replay to avoid the old shell layer."
	if _count_children_named(layer, "PostMatchScreenArmorHexCell") != 9 or _count_children_named(layer, "PostMatchScreenArmorSnapBar") != 4:
		root.free()
		return "Expected armor screen-wide replay to spawn a focused hex grid snap."
	root.free()
	return ""


func _test_screen_feedback_presenter_honors_flags_and_spawns_nudge() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Control.new()
	root.name = "ScreenFeedbackRoot"
	root.size = Vector2(320, 240)
	tree.root.add_child(root)
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = root.size
	root.add_child(layer)
	var shake_target := Control.new()
	shake_target.name = "ShakeTarget"
	shake_target.position = Vector2(20, 30)
	root.add_child(shake_target)
	var presenter = COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT.new()
	presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"shake_target": shake_target,
		"game_juice": false,
	})
	presenter.screen_nudge(3, Vector2(300, 120))
	if presenter.get("_screen_nudge_tween") != null:
		root.queue_free()
		return "Expected screen nudge to no-op while game juice is disabled."
	presenter.set_game_juice_enabled(true)
	presenter.set_game_juice_flags({
		GameJuiceFlags.SCREEN_NUDGE: true,
		GameJuiceFlags.HIT_STOP: true,
	})
	presenter.screen_nudge(3, Vector2(300, 120))
	var active_tween: Tween = presenter.get("_screen_nudge_tween") as Tween
	if active_tween == null or not is_instance_valid(active_tween):
		root.queue_free()
		return "Expected screen nudge to create a tween for the shake target."
	presenter.set_reduced_motion_enabled(true)
	active_tween.kill()
	presenter.set("_screen_nudge_tween", null)
	presenter.screen_nudge(3, Vector2(300, 120))
	if presenter.get("_screen_nudge_tween") != null:
		root.queue_free()
		return "Expected reduced motion to block additional screen nudge."
	root.queue_free()
	return ""


func _test_spark_burst_presenter_honors_flags_and_particle_caps() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Control.new()
	root.name = "SparkBurstRoot"
	tree.root.add_child(root)
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(320, 240)
	root.add_child(layer)
	var presenter = COMBAT_SPARK_BURST_PRESENTER_SCRIPT.new()
	presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"game_juice": false,
	})
	presenter.spawn_visible_spark_burst(Vector2(120, 90), Vector2(120, 80), Color.RED, 0.3)
	if layer.get_child_count() != 0:
		root.queue_free()
		return "Expected spark burst to no-op while game juice is disabled."
	presenter.set_game_juice_enabled(true)
	presenter.set_game_juice_flags({GameJuiceFlags.IMPACT_RINGS_RESULT_LABELS: true})
	presenter.spawn_visible_spark_burst(Vector2(120, 90), Vector2(420, 260), Color.RED, 0.3)
	var spawned_count := layer.get_child_count()
	if spawned_count != 28:
		root.queue_free()
		return "Expected spark burst particles to clamp at 28, got %d." % spawned_count
	var first_particle := layer.get_child(0) as ColorRect
	if first_particle == null or first_particle.name != "JuiceSpark" or first_particle.z_index != 144:
		root.queue_free()
		return "Expected spark burst to create named particles with the expected draw order."
	presenter.set_reduced_motion_enabled(true)
	presenter.spawn_visible_spark_burst(Vector2(120, 90), Vector2(120, 80), Color.RED, 0.3)
	if layer.get_child_count() != spawned_count:
		root.queue_free()
		return "Expected reduced motion to block additional spark burst particles."
	root.queue_free()
	return ""


func _test_mastery_fill_vfx_presenter_spawns_stream_and_reduced_motion() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(420, 320)
	root.add_child(layer)
	var texture_factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	sprite_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_texture_factory": texture_factory,
	})
	var presenter = COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({
		"runtime_sprite_presenter": sprite_presenter,
		"vfx_profile": COMBAT_VFX_PROFILE_SCRIPT.new(),
	})
	presenter.spawn_fill_stream(Vector2(40, 240), Vector2(340, 64), OrbType.Id.FIRE, 0.34, 4, true, true)
	var ray_count := _count_children_named(layer, "MasteryFillStreamRay")
	var spark_count := _count_children_named(layer, "MasteryFillSpark")
	var impact_count := _count_children_named(layer, "MasteryFillImpactRing")
	if ray_count < 3 or spark_count <= 0 or impact_count != 1:
		root.free()
		return "Expected mastery fill presenter to spawn stream rays, sparks, and one impact ring."
	var stream_child_count := layer.get_child_count()
	presenter.spawn_fill_stream(Vector2(40, 240), Vector2(340, 64), OrbType.Id.ICE, 0.34, 4, false, true)
	var reduced_impact_count := _count_children_named(layer, "MasteryFillReducedImpactRing")
	var new_ray_count := _count_children_named(layer, "MasteryFillStreamRay")
	if reduced_impact_count != 1:
		root.free()
		return "Expected reduced-motion mastery fill presenter path to spawn one compact impact ring."
	if new_ray_count != ray_count:
		root.free()
		return "Expected reduced-motion mastery fill presenter path to skip additional stream rays."
	if layer.get_child_count() <= stream_child_count:
		root.free()
		return "Expected reduced-motion mastery fill presenter path to add compact pulse sprites."
	root.free()
	return ""


func _test_mastery_cast_vfx_presenter_spawns_spool_travel_and_source_pulse() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(420, 320)
	root.add_child(layer)
	var texture_factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	sprite_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_texture_factory": texture_factory,
	})
	var primitive_presenter = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
	primitive_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_sprite_presenter": sprite_presenter,
	})
	var presenter = COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({
		"runtime_sprite_presenter": sprite_presenter,
		"runtime_primitive_presenter": primitive_presenter,
		"vfx_profile": COMBAT_VFX_PROFILE_SCRIPT.new(),
	})
	presenter.spawn_cast_spool(Vector2(80, 220), OrbType.Id.FIRE, 0.28, 4)
	presenter.spawn_cast_travel(Vector2(80, 220), Vector2(330, 70), OrbType.Id.FIRE, 0.32, 0.08, 4)
	presenter.spawn_cast_travel(Vector2(80, 180), Vector2(340, 120), OrbType.Id.ICE, 0.32, 0.09, 4)
	presenter.spawn_cast_travel(Vector2(70, 260), Vector2(350, 240), OrbType.Id.EARTH, 0.32, 0.10, 4)
	presenter.spawn_source_pulse(Vector2(80, 220), OrbType.Id.FIRE, 0.22)
	var spool_count := _count_children_named(layer, "MasteryCastSpool")
	var fire_projectile_count := _count_children_named(layer, "MasteryFireProjectile")
	var source_pulse_count := _count_children_named(layer, "MasterySourcePulseRing")
	var fire_wide_beam := _first_child_named(layer, "MasteryFireLaunchWideBeam") as Control
	var fire_hot_band := _first_child_named(layer, "MasteryFireLaunchHotBand") as Control
	var ice_wide_beam := _first_child_named(layer, "MasteryIceLaunchWideBeam") as Control
	var ice_cold_band := _first_child_named(layer, "MasteryIceLaunchColdBand") as Control
	var earth_wide_beam := _first_child_named(layer, "MasteryEarthLaunchWideBeam") as Control
	var earth_runic_band := _first_child_named(layer, "MasteryEarthLaunchRunicBand") as Control
	if spool_count < 3:
		root.free()
		return "Expected mastery cast presenter to spawn charge spool rings."
	if fire_projectile_count != 1:
		root.free()
		return "Expected mastery cast presenter to spawn one fire projectile."
	if source_pulse_count != 1:
		root.free()
		return "Expected mastery cast presenter to spawn one source pulse ring."
	if fire_wide_beam == null or fire_wide_beam.size.y < 240.0:
		root.free()
		return "Expected low-quality fire mastery travel to include a pronounced wide beam."
	if fire_hot_band == null or fire_hot_band.size.y < 90.0:
		root.free()
		return "Expected low-quality fire mastery travel to include a readable hot beam band."
	if ice_wide_beam == null or ice_wide_beam.size.y < 240.0:
		root.free()
		return "Expected low-quality ice mastery travel to include a pronounced wide beam."
	if ice_cold_band == null or ice_cold_band.size.y < 90.0:
		root.free()
		return "Expected low-quality ice mastery travel to include a readable cold beam band."
	if earth_wide_beam == null or earth_wide_beam.size.y < 220.0:
		root.free()
		return "Expected low-quality earth mastery travel to include a pronounced wide beam."
	if earth_runic_band == null or earth_runic_band.size.y < 90.0:
		root.free()
		return "Expected low-quality earth mastery travel to include a readable runic beam band."
	root.free()
	return ""


func _test_armor_linger_vfx_presenter_spawns_hex_grid_snap() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(420, 320)
	root.add_child(layer)
	var texture_factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	sprite_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_texture_factory": texture_factory,
	})
	var primitive_presenter = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
	primitive_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_sprite_presenter": sprite_presenter,
	})
	var presenter = COMBAT_ARMOR_LINGER_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({
		"runtime_sprite_presenter": sprite_presenter,
		"runtime_primitive_presenter": primitive_presenter,
	})
	presenter.spawn_armor_linger(Vector2(220, 160), Vector2(180, 60), 0.44, 4)
	var hex_count := _count_children_named(layer, "ArmorGridHexCell")
	var snap_bar_count := _count_children_named(layer, "ArmorGridSnapBar")
	var bloom_count := _count_children_named(layer, "ArmorGridSnapBloom")
	if hex_count != 9:
		root.free()
		return "Expected armor linger presenter to spawn a 3x3 hex grid."
	if snap_bar_count != 4:
		root.free()
		return "Expected armor linger presenter to spawn four board-edge snap bars."
	if bloom_count != 0:
		root.free()
		return "Expected armor linger presenter to avoid circular bloom layers."
	root.free()
	return ""


func _test_post_match_vfx_runtime_primitives_are_capped() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	var caps := presenter.post_match_runtime_vfx_caps()
	if int(caps.get("max_particles_per_burst", 0)) > 72:
		return "Expected phone-first particle bursts to stay capped."
	if int(caps.get("max_screen_rays", 0)) > 18:
		return "Expected screen ray count to stay capped."
	var keys: Array = caps.get("texture_keys", [])
	for key in ["soft_glow", "ray", "spark", "smoke", "coin", "ripple", "shard", "shield", "hex_cell"]:
		if not keys.has(key):
			return "Expected runtime VFX texture key %s." % key
		if presenter.post_match_runtime_texture(key) == null:
			return "Expected generated runtime VFX texture for %s." % key
	if presenter.post_match_runtime_particle_count(8, 2.0) > int(caps.get("max_particles_per_burst", 0)):
		return "Expected high multiplier particle request to obey the burst cap."
	return ""


func _test_stylized_replay_vfx_presenter_spawns_signature_and_kind_layers() -> String:
	var root := Control.new()
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(420, 320)
	root.add_child(layer)
	var texture_factory = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
	var sprite_presenter = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
	sprite_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_texture_factory": texture_factory,
	})
	var primitive_presenter = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
	primitive_presenter.bind({
		"vfx_layer": layer,
		"timer_owner": root,
		"runtime_sprite_presenter": sprite_presenter,
	})
	var presenter = COMBAT_STYLIZED_REPLAY_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({
		"vfx_layer": layer,
		"visual_registry": VISUAL_REGISTRY_SCRIPT.new(),
		"vfx_profile": COMBAT_VFX_PROFILE_SCRIPT.new(),
		"runtime_sprite_presenter": sprite_presenter,
		"runtime_primitive_presenter": primitive_presenter,
		"global_to_local": func(global_position: Vector2) -> Vector2:
			return global_position,
	})
	presenter.spawn_stylized_replay_effect(Vector2(210, 150), "fire", Vector2(90, 90), 0.48, 18, 2, false)
	var signature_count := _count_children_named(layer, "PostMatchSignature")
	var fire_bloom_count := _count_children_named(layer, "PostMatchFireHeatBloom")
	var ray_count := _count_children_named(layer, "PostMatchRuntimeImpactRay")
	var particle_count := _count_children_named(layer, "PostMatchParticle")
	if signature_count != 2:
		root.free()
		return "Expected stylized replay presenter to spawn signature glow and sprite."
	if fire_bloom_count != 1:
		root.free()
		return "Expected stylized replay presenter to spawn fire-specific bloom."
	if ray_count < 4:
		root.free()
		return "Expected stylized replay presenter to spawn runtime impact rays."
	if particle_count <= 0:
		root.free()
		return "Expected stylized replay presenter to spawn fire particles."
	for child in layer.get_children():
		child.free()
	presenter.spawn_stylized_replay_effect(Vector2(210, 150), "armor", Vector2(160, 160), 0.48, 12, 2, false)
	if _count_children_named(layer, "PostMatchSignature") != 0:
		root.free()
		return "Expected stylized armor replay to skip the old signature sprite."
	if _count_children_named(layer, "PostMatchRing") != 0 or _count_children_named(layer, "PostMatchBaseline") != 0 or _count_children_named(layer, "PostMatchRuntimeShockwave") != 0:
		root.free()
		return "Expected stylized armor replay to avoid circular replay ring layers."
	var armor_hex_count := _count_children_with_effect_name(layer, "PostMatchArmorHexCell")
	var armor_bar_count := _count_children_named(layer, "PostMatchArmorGridSnapBar")
	if armor_hex_count != 9 or armor_bar_count != 4:
		var armor_child_count := layer.get_child_count()
		root.free()
		return "Expected stylized armor replay to spawn the hex grid snap cells and bars; got hex=%d bars=%d children=%d." % [armor_hex_count, armor_bar_count, armor_child_count]
	root.free()
	return ""


func _color_equal(left: Color, right: Color) -> bool:
	return (
		is_equal_approx(left.r, right.r)
		and is_equal_approx(left.g, right.g)
		and is_equal_approx(left.b, right.b)
		and is_equal_approx(left.a, right.a)
	)


func _test_post_match_vfx_speed_scale_slows_lifetime() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	var slowed := presenter.replay_result_impact_profile("fire", 0, Vector2(100, 100), 1.0)
	presenter.set_post_match_vfx_speed_scale(1.0)
	var baseline := presenter.replay_result_impact_profile("fire", 0, Vector2(100, 100), 1.0)
	var slowed_lifetime := float(slowed.get("lifetime", 0.0))
	var baseline_lifetime := float(baseline.get("lifetime", 0.0))
	if slowed_lifetime <= baseline_lifetime:
		return "Expected default post-match VFX lifetime to be slower than baseline speed."
	if slowed_lifetime < baseline_lifetime * 1.6:
		return "Expected default post-match VFX lifetime to be noticeably slower."
	return ""


func _test_post_match_vfx_second_tier_is_lowest() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	var small := presenter.replay_result_impact_profile("fire", 1, Vector2(100, 100), 1.0)
	var medium := presenter.replay_result_impact_profile("fire", 6, Vector2(100, 100), 1.0)
	var high := presenter.replay_result_impact_profile("fire", 10, Vector2(100, 100), 1.0)
	if not is_equal_approx(float(small.get("draw_size", Vector2.ZERO).x), 185.0):
		return "Expected small positive results to use the pumped first-tier size scale."
	if not is_equal_approx(float(medium.get("draw_size", Vector2.ZERO).x), 185.0):
		return "Expected medium-threshold results to remain at the new first tier."
	if not is_equal_approx(float(high.get("draw_size", Vector2.ZERO).x), 225.0):
		return "Expected old third tier to become the pumped second tier."
	return ""


func _test_post_match_vfx_top_tier_becomes_screen_wide() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	if presenter.replay_result_is_screen_wide("fire", 15):
		return "Expected Fire 15 to stay below the screen-wide tier."
	if not presenter.replay_result_is_screen_wide("fire", 16):
		return "Expected Fire 16 to become screen-wide."
	if not presenter.replay_result_is_screen_wide("gold", 10):
		return "Expected Gold 10 to become screen-wide."
	if presenter.replay_result_is_screen_wide("heart", 3):
		return "Expected small Heart healing to stay local."
	return ""


func _test_mastery_fill_stream_spawns_runtime_stream_and_impact() -> String:
	var fixture := _vfx_fixture(false)
	var presenter: Variant = fixture["presenter"]
	var layer: Control = fixture["layer"]
	presenter.spawn_mastery_fill_stream(OrbType.Id.FIRE, Vector2(120, 420), 18, 0.34)
	var ray_count := _count_children_named(layer, "MasteryFillStreamRay")
	var spark_count := _count_children_named(layer, "MasteryFillSpark")
	var impact_count := _count_children_named(layer, "MasteryFillImpactRing")
	_cleanup_vfx_fixture(fixture)
	if ray_count < 2:
		return "Expected mastery fill stream to spawn multiple traveling rays."
	if spark_count <= 0:
		return "Expected mastery fill stream to spawn traveling sparks."
	if impact_count != 1:
		return "Expected mastery fill stream to spawn a mastery card impact ring."
	return ""


func _test_low_quality_mastery_beam_spawns_pronounced_layers() -> String:
	for orb_id in [OrbType.Id.FIRE, OrbType.Id.EARTH]:
		var result := _assert_low_quality_mastery_beam_layers(int(orb_id))
		if result != "":
			return result
	return ""


func _assert_low_quality_mastery_beam_layers(orb_id: int) -> String:
	var fixture := _vfx_fixture(false)
	var presenter: Variant = fixture["presenter"]
	var layer: Control = fixture["layer"]
	presenter.spawn_mastery_beam(orb_id, Vector2(760, 720), 0.45)
	var aura_count := _count_children_named(layer, "MasteryBeamLowQualityAura")
	var target_bloom_count := _count_children_named(layer, "MasteryBeamLowQualityTargetBloom")
	var bolt_count := _count_children_named(layer, "MasteryBeamLowQualityBolt")
	var solid_band := _first_child_named(layer, "MasteryBeamLowQualitySolidBand") as ColorRect
	var white_band := _first_child_named(layer, "MasteryBeamLowQualityWhiteBand") as ColorRect
	var glow := _first_child_named(layer, "MasteryBeamLowQualityGlow") as TextureRect
	var core := _first_child_named(layer, "MasteryBeamLowQualityCore") as TextureRect
	var hot_core := _first_child_named(layer, "MasteryBeamLowQualityHotCore") as TextureRect
	_cleanup_vfx_fixture(fixture)
	if aura_count != 1 or target_bloom_count != 1 or bolt_count != 1:
		return "Expected low-quality mastery beam for orb %d to spawn aura, target bloom, and moving bolt layers." % orb_id
	if solid_band == null or white_band == null:
		return "Expected low-quality mastery beam for orb %d to spawn solid colored and white-hot bands." % orb_id
	if solid_band.size.y < 216.0 or white_band.size.y < 80.0:
		return "Expected low-quality mastery beam solid bands for orb %d to be doubled in thickness." % orb_id
	if glow == null or core == null or hot_core == null:
		return "Expected low-quality mastery beam for orb %d to spawn named glow, core, and hot-core strips." % orb_id
	if glow.size.y < 344.0 or core.size.y < 216.0 or hot_core.size.y < 80.0:
		return "Expected low-quality mastery beam strips for orb %d to be doubled in thickness." % orb_id
	return ""


func _test_healing_replay_impact_uses_bar_infusion() -> String:
	var fixture := _vfx_fixture(false)
	var presenter: Variant = fixture["presenter"]
	var layer: Control = fixture["layer"]
	presenter.spawn_replay_impact(Vector2(540, 960), "heart", Vector2(348, 130), 0.45, 3)
	var visible_band := _first_child_named(layer, "HealingBarInfusionVisibleBand") as ColorRect
	var inner_line := _first_child_named(layer, "HealingBarInfusionInnerLine") as ColorRect
	var glint := _first_child_named(layer, "HealingBarInfusionGlint") as ColorRect
	var chunky_count := _count_children_named(layer, "HealingBarInfusionSnapBlock") + _count_children_named(layer, "HealingBarInfusionSnapFill") + _count_children_named(layer, "HealingBarInfusionTick") + _count_children_named(layer, "HealingBarInfusionTickBlock")
	var texture_strip_count := _count_children_named(layer, "HealingBarInfusionSweep") + _count_children_named(layer, "HealingBarInfusionRoseSweep") + _count_children_named(layer, "HealingBarInfusionRailGlow")
	var legacy_count := _count_children_named(layer, "PostMatchHeal") + _count_children_named(layer, "PostMatchRing") + _count_children_named(layer, "PostMatchSignature")
	var child_count_before_heart_beam := layer.get_child_count()
	presenter.spawn_mastery_beam(OrbType.Id.HEART, Vector2(540, 960), 0.45)
	var child_count_after_heart_beam := layer.get_child_count()
	var visible_band_size := visible_band.size if visible_band != null else Vector2.ZERO
	var inner_line_size := inner_line.size if inner_line != null else Vector2.ZERO
	var glint_size := glint.size if glint != null else Vector2.ZERO
	var visible_band_alpha := visible_band.modulate.a if visible_band != null else -1.0
	var visible_band_color := visible_band.color if visible_band != null else Color.TRANSPARENT
	var inner_line_color := inner_line.color if inner_line != null else Color.TRANSPARENT
	var glint_color := glint.color if glint != null else Color.TRANSPARENT
	var inner_line_alpha := inner_line.modulate.a if inner_line != null else -1.0
	var glint_alpha := glint.modulate.a if glint != null else -1.0
	_cleanup_vfx_fixture(fixture)
	if visible_band == null or visible_band_size.x < 170.0:
		return "Expected healing replay impact to spawn a guaranteed-visible HP bar band."
	if visible_band_alpha > 0.01:
		return "Expected healing HP bar band to tween in from transparent alpha."
	if visible_band_size.y > 38.0:
		return "Expected healing HP bar band to stay flat and native to the HP bar."
	if visible_band_color.g > visible_band_color.r:
		return "Expected healing bar infusion to use a warm HP palette instead of detached mint-green."
	if visible_band_color.a < 0.30:
		return "Expected healing HP bar band to be noticeable, not whisper-subtle."
	if inner_line == null or inner_line_size.y > 10.0 or inner_line_color.a < 0.30 or inner_line_alpha > 0.01:
		return "Expected healing replay impact to use a readable inner HP-bar line."
	if glint == null or glint_size.y > 10.0 or glint_color.a < 0.50 or glint_alpha > 0.01:
		return "Expected healing replay impact to use a readable native HP-bar glint."
	if chunky_count != 0 or texture_strip_count != 0:
		return "Expected healing replay impact to avoid chunky detached bars, ticks, and texture strips."
	if legacy_count != 0:
		return "Expected healing replay impact to avoid old heal rings/signatures."
	if child_count_after_heart_beam != child_count_before_heart_beam:
		return "Expected Heart mastery beam to no-op so healing stays HP-bar-owned."
	return ""


func _test_armor_replay_impact_uses_hex_grid_without_legacy_texture() -> String:
	var fixture := _vfx_fixture(false)
	var presenter: Variant = fixture["presenter"]
	var layer: Control = fixture["layer"]
	presenter.spawn_replay_impact(Vector2(540, 960), "armor", Vector2(220, 220), 0.45, 12)
	var hex_count := _count_children_with_effect_name(layer, "PostMatchArmorHexCell")
	var snap_bar_count := _count_children_named(layer, "PostMatchArmorGridSnapBar")
	var signature_count := _count_children_named(layer, "PostMatchSignature")
	var unnamed_texture_count := _count_texture_rects_without_effect_meta(layer)
	var circle_count := _count_children_named(layer, "PostMatchRing") + _count_children_named(layer, "PostMatchBaseline") + _count_children_named(layer, "PostMatchRuntimeShockwave") + _count_children_named(layer, "PostMatchScreen")
	var count_before_armor_beam := layer.get_child_count()
	presenter.spawn_mastery_beam(OrbType.Id.ARMOR, Vector2(540, 960), 0.45)
	var count_after_armor_beam := layer.get_child_count()
	_cleanup_vfx_fixture(fixture)
	if hex_count != 9 or snap_bar_count != 4:
		return "Expected armor replay impact to use the hex grid snap effect; got hex=%d bars=%d." % [hex_count, snap_bar_count]
	if signature_count != 0:
		return "Expected armor replay impact to skip the old armor signature sprite."
	if unnamed_texture_count != 0:
		return "Expected armor replay impact to skip the legacy base impact texture."
	if circle_count != 0:
		return "Expected armor replay impact to avoid circular replay layers."
	if count_after_armor_beam != count_before_armor_beam:
		return "Expected armor mastery beam to no-op so the mockup grid snap remains the only armor gain VFX."
	return ""


func _test_mastery_fill_stream_reduced_motion_uses_static_pulse() -> String:
	var fixture := _vfx_fixture(true)
	var presenter: Variant = fixture["presenter"]
	var layer: Control = fixture["layer"]
	presenter.spawn_mastery_fill_stream(OrbType.Id.ICE, Vector2(120, 420), 18, 0.34)
	var ray_count := _count_children_named(layer, "MasteryFillStreamRay")
	var spark_count := _count_children_named(layer, "MasteryFillSpark")
	var reduced_impact_count := _count_children_named(layer, "MasteryFillReducedImpactRing")
	_cleanup_vfx_fixture(fixture)
	if ray_count != 0 or spark_count != 0:
		return "Expected reduced motion mastery fill to skip traveling stream rays and sparks."
	if reduced_impact_count != 1:
		return "Expected reduced motion mastery fill to use a compact card pulse."
	return ""


func _test_board_lock_visual_state_captures_pointer_input() -> String:
	var board_view_script := ResourceLoader.load("res://scripts/board/board_view.gd", "", ResourceLoader.CACHE_MODE_IGNORE)
	var board_view = board_view_script.new()
	board_view.set_input_enabled(false)
	if board_view.is_input_enabled():
		return "Expected board view input state to be locked."
	if board_view.mouse_filter != Control.MOUSE_FILTER_STOP:
		return "Expected locked board view to capture pointer input."
	if board_view.locked_overlay_color.a < 0.70:
		return "Expected locked board view overlay to be extra dark."
	var board_controller_script := ResourceLoader.load("res://scripts/board/board_controller.gd", "", ResourceLoader.CACHE_MODE_IGNORE)
	var board_controller = board_controller_script.new()
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	var locked_result: Dictionary = board_controller.handle_pointer_input(click, false)
	if not bool(locked_result.get("handled", false)):
		return "Expected locked board controller to swallow pointer input."
	if String(locked_result.get("action", "")) != "":
		return "Expected locked board pointer input to have no drag action."
	board_view.set_input_enabled(true)
	if not board_view.is_input_enabled():
		return "Expected board view input state to unlock."
	return ""


func _vfx_fixture(reduced_motion: bool) -> Dictionary:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Control.new()
	root.name = "CombatVfxPresenterTestRoot"
	root.size = Vector2(1080, 1920)
	tree.root.add_child(root)

	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = root.size
	root.add_child(layer)

	var mastery_cards := Control.new()
	mastery_cards.name = "MasteryCards"
	mastery_cards.size = Vector2(420, 96)
	mastery_cards.position = Vector2(330, 120)
	root.add_child(mastery_cards)

	for orb_id in OrbType.ALL_TYPES:
		var card := Control.new()
		card.name = "CombatMasteryCard%d" % int(orb_id)
		card.size = Vector2(56, 56)
		card.position = Vector2(float(int(orb_id)) * 62.0, 0.0)
		var panel := Control.new()
		panel.name = "CardPanel"
		panel.size = card.size
		var icon := Control.new()
		icon.name = "MasteryIcon"
		icon.size = Vector2(34, 34)
		icon.position = Vector2(11, 11)
		panel.add_child(icon)
		card.add_child(panel)
		mastery_cards.add_child(card)

	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	presenter.bind({
		"vfx_layer": layer,
		"visual_registry": VISUAL_REGISTRY_SCRIPT.new(),
		"player_loadout_hud": FakeMasteryHud.new(),
		"elemental_mastery_cards": mastery_cards,
		"timer_owner": root,
		"post_match_vfx_quality": "low",
		"reduced_motion": reduced_motion,
		"game_juice": true,
	})
	return {
		"root": root,
		"layer": layer,
		"presenter": presenter,
	}


func _cleanup_vfx_fixture(fixture: Dictionary) -> void:
	var root := fixture.get("root") as Node
	if root != null and is_instance_valid(root):
		root.queue_free()


func _packed_scene_from_node(node: Node) -> PackedScene:
	_own_packed_scene_children(node, node)
	var scene := PackedScene.new()
	scene.pack(node)
	return scene


func _solid_texture(width: int, height: int, color: Color) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func _own_packed_scene_children(root: Node, current: Node) -> void:
	for child in current.get_children():
		child.owner = root
		_own_packed_scene_children(root, child)


func _count_children_named(parent: Node, node_name: String) -> int:
	if parent == null:
		return 0
	var count := 0
	for child in parent.get_children():
		if String(child.get_meta("effect_name", child.name)).begins_with(node_name):
			count += 1
	return count


func _first_child_named(parent: Node, node_name: String) -> Node:
	if parent == null:
		return null
	for child in parent.get_children():
		if String(child.get_meta("effect_name", child.name)).begins_with(node_name):
			return child
	return null


func _count_children_with_effect_name(parent: Node, effect_name: String) -> int:
	if parent == null:
		return 0
	var count := 0
	for child in parent.get_children():
		if String(child.get_meta("effect_name", child.name)) == effect_name:
			count += 1
	return count


func _count_texture_rects_without_effect_meta(parent: Node) -> int:
	if parent == null:
		return 0
	var count := 0
	for child in parent.get_children():
		if child is TextureRect and not child.has_meta("effect_name"):
			count += 1
	return count
