extends RefCounted
class_name CombatModelTest

const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")


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
	_run_case("combat_vfx_presenter_forces_max_mode", _test_combat_vfx_presenter_forces_max_mode, failures)
	_run_case("post_match_vfx_runtime_primitives_are_capped", _test_post_match_vfx_runtime_primitives_are_capped, failures)
	_run_case("post_match_vfx_speed_scale_slows_lifetime", _test_post_match_vfx_speed_scale_slows_lifetime, failures)
	_run_case("post_match_vfx_top_tier_becomes_screen_wide", _test_post_match_vfx_top_tier_becomes_screen_wide, failures)
	_run_case("board_lock_visual_state_captures_pointer_input", _test_board_lock_visual_state_captures_pointer_input, failures)

	return {
		"passed": failures.is_empty(),
		"total": 15,
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


func _test_combat_vfx_presenter_forces_max_mode() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	if not presenter.max_combat_vfx_forced():
		return "Expected Max combat VFX to be forced for this polish pass."
	return ""


func _test_post_match_vfx_runtime_primitives_are_capped() -> String:
	var presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	var caps := presenter.post_match_runtime_vfx_caps()
	if int(caps.get("max_particles_per_burst", 0)) > 72:
		return "Expected phone-first particle bursts to stay capped."
	if int(caps.get("max_screen_rays", 0)) > 18:
		return "Expected screen ray count to stay capped."
	var keys: Array = caps.get("texture_keys", [])
	for key in ["soft_glow", "ray", "spark", "smoke", "coin", "ripple", "shard", "shield"]:
		if not keys.has(key):
			return "Expected runtime VFX texture key %s." % key
		if presenter.post_match_runtime_texture(key) == null:
			return "Expected generated runtime VFX texture for %s." % key
	if presenter.post_match_runtime_particle_count(8, 2.0) > int(caps.get("max_particles_per_burst", 0)):
		return "Expected high multiplier particle request to obey the burst cap."
	return ""


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
