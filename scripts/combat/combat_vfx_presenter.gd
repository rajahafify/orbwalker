extends RefCounted
class_name CombatVfxPresenter

const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")
const COMBAT_VFX_PROFILE_SCRIPT := preload("res://scripts/combat/combat_vfx_profile.gd")
const COMBAT_SCREEN_WIDE_REPLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_wide_replay_presenter.gd")
const COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_texture_factory.gd")
const COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_sprite_presenter.gd")
const COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_primitive_presenter.gd")
const COMBAT_POST_MATCH_VFX_POLICY_SCRIPT := preload("res://scripts/combat/combat_post_match_vfx_policy.gd")
const COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_attack_vfx_presenter.gd")
const COMBAT_RESULT_LABEL_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_result_label_presenter.gd")
const COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_feedback_presenter.gd")
const COMBAT_SPARK_BURST_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_spark_burst_presenter.gd")
const COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_fill_vfx_presenter.gd")
const COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_cast_vfx_presenter.gd")
const COMBAT_VFX_REPLAY_RESULT_POLICY_SCRIPT := preload("res://scripts/combat/combat_vfx_replay_result_policy.gd")
const COMBAT_VFX_MASTERY_BEAM_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_mastery_beam_presenter.gd")
const COMBAT_ARMOR_LINGER_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_armor_linger_vfx_presenter.gd")
const COMBAT_HEALING_BAR_INFUSION_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_healing_bar_infusion_vfx_presenter.gd")
const COMBAT_STYLIZED_REPLAY_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_stylized_replay_vfx_presenter.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

var _vfx_layer: Control
var _visual_registry: Variant
var _player_loadout_hud: Variant
var _elemental_mastery_cards: Control
var _timer_owner: Node
var _shake_target: Control
var _max_vfx_overlay: Variant
var _vfx_profile: Variant = COMBAT_VFX_PROFILE_SCRIPT.new()
var _screen_wide_replay_presenter: Variant = COMBAT_SCREEN_WIDE_REPLAY_PRESENTER_SCRIPT.new()
var _runtime_primitive_presenter: Variant = COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT.new()
var _runtime_sprite_presenter: Variant = COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT.new()
var _runtime_texture_factory: Variant = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
var _post_match_policy: Variant = COMBAT_POST_MATCH_VFX_POLICY_SCRIPT.new()
var _enemy_attack_vfx_presenter: Variant = COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT.new()
var _result_label_presenter: Variant = COMBAT_RESULT_LABEL_PRESENTER_SCRIPT.new()
var _screen_feedback_presenter: Variant = COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT.new()
var _spark_burst_presenter: Variant = COMBAT_SPARK_BURST_PRESENTER_SCRIPT.new()
var _mastery_fill_vfx_presenter: Variant = COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT.new()
var _mastery_cast_vfx_presenter: Variant = COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT.new()
var _replay_result_policy: Variant = COMBAT_VFX_REPLAY_RESULT_POLICY_SCRIPT.new()
var _mastery_beam_presenter: Variant = COMBAT_VFX_MASTERY_BEAM_PRESENTER_SCRIPT.new()
var _armor_linger_vfx_presenter: Variant = COMBAT_ARMOR_LINGER_VFX_PRESENTER_SCRIPT.new()
var _healing_bar_infusion_vfx_presenter: Variant = COMBAT_HEALING_BAR_INFUSION_VFX_PRESENTER_SCRIPT.new()
var _stylized_replay_vfx_presenter: Variant = COMBAT_STYLIZED_REPLAY_VFX_PRESENTER_SCRIPT.new()
var _post_match_vfx_speed_scale := DEFAULT_POST_MATCH_VFX_SPEED_SCALE
var _post_match_vfx_quality := DEFAULT_POST_MATCH_VFX_QUALITY
var _reduced_motion := false
var _game_juice_enabled := false
var _game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()

const DEFAULT_POST_MATCH_VFX_SPEED_SCALE := 0.55
const POST_MATCH_EFFECT_Z_INDEX := 124
const FORCE_MAX_COMBAT_VFX := true
const POST_MATCH_VFX_QUALITY_HIGH := "high"
const POST_MATCH_VFX_QUALITY_LOW := "low"
const POST_MATCH_VFX_QUALITY_OPTIONS: Array[String] = [
	POST_MATCH_VFX_QUALITY_HIGH,
	POST_MATCH_VFX_QUALITY_LOW,
]
const DEFAULT_POST_MATCH_VFX_QUALITY := POST_MATCH_VFX_QUALITY_LOW
const POST_MATCH_VFX_QUALITY_SETTING_PATH := "matchatro/combat/post_match_vfx_quality"
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_MAX_SCREEN_RAYS := 18
const POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS := 10
const POST_MATCH_RUNTIME_TEXTURE_KEYS: Array[String] = [
	"soft_glow",
	"ray",
	"spark",
	"smoke",
	"coin",
	"ripple",
	"shard",
	"shield",
	"hex_cell",
]
const MASTERY_FILL_STREAM_SECONDS := 0.46


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_elemental_mastery_cards = dependencies.get("elemental_mastery_cards") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_shake_target = dependencies.get("shake_target") as Control
	_max_vfx_overlay = COMBAT_MAX_VFX_OVERLAY_SCRIPT.new()
	_max_vfx_overlay.bind(dependencies)
	var runtime_dependencies := dependencies.duplicate()
	runtime_dependencies["runtime_texture_factory"] = _runtime_texture_factory
	_runtime_sprite_presenter.bind(runtime_dependencies)
	var enemy_attack_dependencies := dependencies.duplicate()
	enemy_attack_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	_enemy_attack_vfx_presenter.bind(enemy_attack_dependencies)
	_result_label_presenter.bind(dependencies)
	_screen_feedback_presenter.bind(dependencies)
	_spark_burst_presenter.bind(dependencies)
	var mastery_fill_dependencies := dependencies.duplicate()
	mastery_fill_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	mastery_fill_dependencies["vfx_profile"] = _vfx_profile
	_mastery_fill_vfx_presenter.bind(mastery_fill_dependencies)
	var primitive_dependencies := dependencies.duplicate()
	primitive_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	_runtime_primitive_presenter.bind(primitive_dependencies)
	var armor_linger_dependencies := dependencies.duplicate()
	armor_linger_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	armor_linger_dependencies["runtime_primitive_presenter"] = _runtime_primitive_presenter
	_armor_linger_vfx_presenter.bind(armor_linger_dependencies)
	_healing_bar_infusion_vfx_presenter.bind(dependencies)
	var mastery_cast_dependencies := dependencies.duplicate()
	mastery_cast_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	mastery_cast_dependencies["runtime_primitive_presenter"] = _runtime_primitive_presenter
	mastery_cast_dependencies["vfx_profile"] = _vfx_profile
	_mastery_cast_vfx_presenter.bind(mastery_cast_dependencies)
	var mastery_beam_dependencies := dependencies.duplicate()
	mastery_beam_dependencies["max_vfx_overlay"] = _max_vfx_overlay
	mastery_beam_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	mastery_beam_dependencies["mastery_cast_vfx_presenter"] = _mastery_cast_vfx_presenter
	_mastery_beam_presenter.bind(mastery_beam_dependencies)
	var screen_wide_dependencies := dependencies.duplicate()
	screen_wide_dependencies["post_match_policy"] = _post_match_policy
	screen_wide_dependencies["runtime_primitive_presenter"] = _runtime_primitive_presenter
	screen_wide_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	screen_wide_dependencies["vfx_profile"] = _vfx_profile
	_screen_wide_replay_presenter.bind(screen_wide_dependencies)
	var stylized_replay_dependencies := dependencies.duplicate()
	stylized_replay_dependencies["vfx_profile"] = _vfx_profile
	stylized_replay_dependencies["runtime_sprite_presenter"] = _runtime_sprite_presenter
	stylized_replay_dependencies["runtime_primitive_presenter"] = _runtime_primitive_presenter
	stylized_replay_dependencies["screen_wide_replay_presenter"] = _screen_wide_replay_presenter
	stylized_replay_dependencies["global_to_local"] = Callable(self, "_global_to_vfx_local")
	_stylized_replay_vfx_presenter.bind(stylized_replay_dependencies)
	if dependencies.has("post_match_vfx_quality"):
		set_post_match_vfx_quality(String(dependencies.get("post_match_vfx_quality", DEFAULT_POST_MATCH_VFX_QUALITY)))
	else:
		set_post_match_vfx_quality(_project_post_match_vfx_quality())
	set_reduced_motion_enabled(bool(dependencies.get("reduced_motion", _reduced_motion)))
	set_game_juice_enabled(bool(dependencies.get("game_juice", _game_juice_enabled)))
	if dependencies.has("game_juice_flags"):
		set_game_juice_flags(Dictionary(dependencies.get("game_juice_flags", _game_juice_flags)))


func set_post_match_vfx_speed_scale(speed_scale: float) -> void:
	_post_match_vfx_speed_scale = clampf(speed_scale, 0.25, 2.0)


func set_post_match_vfx_quality(quality: String) -> void:
	_post_match_vfx_quality = _normalized_post_match_vfx_quality(quality)


func set_reduced_motion_enabled(enabled: bool) -> void:
	_reduced_motion = enabled
	_screen_feedback_presenter.set_reduced_motion_enabled(enabled)
	_spark_burst_presenter.set_reduced_motion_enabled(enabled)


func reduced_motion_enabled() -> bool:
	return _reduced_motion


func set_game_juice_enabled(enabled: bool) -> void:
	_game_juice_enabled = enabled
	_screen_feedback_presenter.set_game_juice_enabled(enabled)
	_spark_burst_presenter.set_game_juice_enabled(enabled)


func set_game_juice_flags(flags: Dictionary) -> void:
	_game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	_screen_feedback_presenter.set_game_juice_flags(_game_juice_flags)
	_spark_burst_presenter.set_game_juice_flags(_game_juice_flags)


func game_juice_enabled() -> bool:
	return _game_juice_enabled


func post_match_vfx_quality() -> String:
	return _post_match_vfx_quality


func post_match_vfx_quality_options() -> Array[String]:
	return POST_MATCH_VFX_QUALITY_OPTIONS.duplicate()


func post_match_vfx_quality_uses_max_overlay() -> bool:
	return _post_match_vfx_quality == POST_MATCH_VFX_QUALITY_HIGH


func spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _visual_registry == null:
		return
	var texture: Texture2D = _visual_registry.vfx_texture(effect_name)
	if texture == null:
		return
	spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func spawn_vfx_texture(
	texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
) -> void:
	if texture == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	if (
		_use_max_combat_vfx()
		and _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
		and _max_vfx_overlay.spawn_generic(global_center, draw_size, lifetime, modulate_color)
	):
		return
	var sprite := TextureRect.new()
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.modulate = modulate_color
	sprite.z_index = POST_MATCH_EFFECT_Z_INDEX
	_vfx_layer.add_child(sprite)
	var local_center := _global_to_vfx_local(global_center)
	sprite.position = local_center - draw_size * 0.5
	_tween_fade_cleanup(sprite, lifetime)
	_spawn_visible_spark_burst(global_center, draw_size, modulate_color, lifetime)


func spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if global_center == Vector2.ZERO:
		return
	var clean_kind: String = _replay_result_policy.result_vfx_kind_key(impact_kind)
	if _visual_registry == null and not ["armor", "heart"].has(clean_kind):
		return
	var impact_juice_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
	var profile := (
		replay_result_impact_profile(impact_kind, result_amount, draw_size, lifetime)
		if impact_juice_enabled
		else {
			"draw_size": draw_size,
			"lifetime": _post_match_vfx_lifetime(lifetime),
			"modulate_color": Color(1.0, 1.0, 1.0, 0.86),
			"tier_index": 0,
		}
	)
	var profile_size: Vector2 = profile.get("draw_size", draw_size)
	var profile_lifetime := float(profile.get("lifetime", lifetime))
	var profile_color: Color = profile.get("modulate_color", Color(1.0, 1.0, 1.0, 0.92))
	var tier_index := int(profile.get("tier_index", 0))
	var intensity: int = _stylized_replay_vfx_presenter.replay_effect_intensity(result_amount, tier_index)
	if clean_kind == "armor":
		if impact_juice_enabled:
			_spawn_stylized_replay_effect(global_center, clean_kind, profile_size, profile_lifetime, result_amount, tier_index)
		else:
			_spawn_armor_bar_linger_effect(global_center, profile_size, profile_lifetime, intensity)
		return
	if clean_kind == "heart":
		_healing_bar_infusion_vfx_presenter.spawn_bar_infusion(
			global_center, draw_size, profile_lifetime, result_amount, intensity, _reduced_motion or not impact_juice_enabled
		)
		return
	if (
		_use_max_combat_vfx()
		and impact_juice_enabled
		and _max_vfx_overlay.spawn_replay_impact(
			global_center, clean_kind, profile_size, profile_lifetime, result_amount, intensity, replay_result_is_screen_wide(clean_kind, result_amount)
		)
	):
		return
	var impact_texture: Texture2D = _visual_registry.mastery_impact_texture(impact_kind)
	if impact_texture == null:
		impact_texture = _visual_registry.vfx_texture("orb_clear")
	spawn_vfx_texture(impact_texture, global_center, profile_size, profile_lifetime, profile_color)
	if impact_juice_enabled:
		_spawn_stylized_replay_effect(global_center, clean_kind, profile_size, profile_lifetime, result_amount, tier_index)


func spawn_armor_bar_linger(global_center: Vector2, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS):
		return
	if global_center == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var tier_index: int = _replay_result_policy.result_vfx_tier_index(replay_result_vfx_tier("armor", result_amount))
	var intensity: int = _stylized_replay_vfx_presenter.replay_effect_intensity(result_amount, tier_index)
	var duration := _post_match_vfx_lifetime(maxf(0.60, lifetime) * (1.70 + float(tier_index) * 0.16))
	_spawn_armor_bar_linger_effect(global_center, draw_size, duration, intensity)


func replay_result_impact_profile(impact_kind: String, result_amount: int, base_draw_size: Vector2, base_lifetime: float) -> Dictionary:
	return _replay_result_policy.replay_result_impact_profile(impact_kind, result_amount, base_draw_size, base_lifetime, _post_match_vfx_speed_scale)


func replay_result_vfx_tier(impact_kind: String, result_amount: int) -> int:
	return _replay_result_policy.replay_result_vfx_tier(impact_kind, result_amount)


func result_vfx_size_scale(impact_kind: String, result_amount: int) -> float:
	return _replay_result_policy.result_vfx_size_scale(impact_kind, result_amount)


func replay_result_is_screen_wide(impact_kind: String, result_amount: int) -> bool:
	return _replay_result_policy.replay_result_is_screen_wide(impact_kind, result_amount)


func post_match_runtime_vfx_caps() -> Dictionary:
	return {
		"max_particles_per_burst": POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST,
		"max_screen_rays": POST_MATCH_MAX_SCREEN_RAYS,
		"max_simultaneous_emitters": POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS,
		"texture_keys": POST_MATCH_RUNTIME_TEXTURE_KEYS.duplicate(),
	}


func post_match_runtime_texture(key: String) -> Texture2D:
	return _runtime_texture_factory.texture(key)


func screen_nudge(intensity: int = 1, source_global: Vector2 = Vector2.ZERO) -> void:
	_screen_feedback_presenter.screen_nudge(intensity, source_global)


func hit_stop(seconds: float = 0.04) -> void:
	await _screen_feedback_presenter.hit_stop(seconds)


func _spawn_visible_spark_burst(global_center: Vector2, draw_size: Vector2, color: Color, lifetime: float) -> void:
	_spark_burst_presenter.spawn_visible_spark_burst(global_center, draw_size, color, lifetime)


func max_combat_vfx_forced() -> bool:
	return _game_juice_enabled and FORCE_MAX_COMBAT_VFX and post_match_vfx_quality_uses_max_overlay() and _any_max_overlay_flag_enabled()


func max_combat_vfx_available() -> bool:
	return _use_max_combat_vfx()


func _use_max_combat_vfx() -> bool:
	return (
		_game_juice_enabled
		and FORCE_MAX_COMBAT_VFX
		and post_match_vfx_quality_uses_max_overlay()
		and _any_max_overlay_flag_enabled()
		and _max_vfx_overlay != null
		and _max_vfx_overlay.is_available()
	)


func _any_max_overlay_flag_enabled() -> bool:
	return (
		_juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
		or _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_FILL_STREAMS)
		or _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_CARD_INTAKE_FLARE)
	)


func _juice_enabled(flag_key: String) -> bool:
	return _game_juice_enabled and bool(_game_juice_flags.get(flag_key, true))


func _project_post_match_vfx_quality() -> String:
	return _normalized_post_match_vfx_quality(String(ProjectSettings.get_setting(POST_MATCH_VFX_QUALITY_SETTING_PATH, DEFAULT_POST_MATCH_VFX_QUALITY)))


func _normalized_post_match_vfx_quality(quality: String) -> String:
	var normalized := quality.strip_edges().to_lower()
	if POST_MATCH_VFX_QUALITY_OPTIONS.has(normalized):
		return normalized
	return DEFAULT_POST_MATCH_VFX_QUALITY


func post_match_runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	return _stylized_replay_vfx_presenter.runtime_particle_count(intensity, multiplier)


func _post_match_vfx_lifetime(lifetime: float) -> float:
	return _replay_result_policy.post_match_vfx_lifetime(lifetime, _post_match_vfx_speed_scale)


func spawn_result_label(text: String, global_center: Vector2, kind: String, lifetime: float, offset: Vector2 = Vector2.ZERO, result_amount: int = 0) -> Label:
	if text.strip_edges() == "" or global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var impact_juice_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
	var clean_kind := kind.strip_edges().to_lower()
	var label_scale := result_vfx_size_scale(kind, result_amount) if impact_juice_enabled else 1.0
	if clean_kind == "heal":
		label_scale = 1.16
	return _result_label_presenter.spawn_result_label(
		text,
		global_center,
		lifetime,
		Vector2(offset.x, -26.0) if clean_kind == "heal" else offset,
		label_scale,
		_vfx_profile.result_label_color(kind, impact_juice_enabled),
		22.0 if clean_kind == "heal" else 54.0
	)


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float = 0.26) -> void:
	if source_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_cue(source_global, lifetime):
		return
	_enemy_attack_vfx_presenter.spawn_cue(source_global, lifetime)


func spawn_enemy_attack_travel(source_global: Vector2, target_global: Vector2, lifetime: float = 0.28) -> void:
	if source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_travel(source_global, target_global, lifetime):
		return
	_enemy_attack_vfx_presenter.spawn_travel(source_global, target_global, lifetime)


func spawn_enemy_attack_block_impact(target_global: Vector2, lifetime: float = 0.32, blocked_amount: int = 0) -> void:
	spawn_replay_impact(target_global, "armor", Vector2(90, 90), lifetime, blocked_amount)
	_enemy_attack_vfx_presenter.spawn_block_impact(target_global, lifetime)


func spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float = 0.32, hp_damage: int = 0) -> void:
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_impact(target_global, false, hp_damage, lifetime):
		return
	spawn_replay_impact(target_global, "damage", Vector2(90, 90), lifetime, hp_damage)
	_enemy_attack_vfx_presenter.spawn_hit_impact(target_global, lifetime)


func mastery_impact_kind(orb_id: int) -> String:
	return _vfx_profile.mastery_impact_kind(orb_id)


func _spawn_stylized_replay_effect(
	global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, result_amount: int, tier_index: int
) -> void:
	var screen_wide := replay_result_is_screen_wide(clean_kind, result_amount)
	_stylized_replay_vfx_presenter.spawn_stylized_replay_effect(global_center, clean_kind, draw_size, lifetime, result_amount, tier_index, screen_wide)


func _spawn_armor_bar_linger_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_armor_linger_vfx_presenter.spawn_armor_linger(center_local, draw_size, lifetime, intensity)


func control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(rect.position.x + rect.size.x * 0.5, rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0))


func spawn_mastery_cast_sequence(orb_id: int, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int = 0) -> void:
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_FILL_STREAMS):
		return
	if target_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var source := _mastery_card_source(orb_id)
	if source == null:
		return
	var source_point := control_global_center(source, 0.5)
	if source_point == Vector2.ZERO:
		return
	var source_local := _global_to_vfx_local(source_point)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	if delta.length() <= 1.0:
		return
	var clean_kind := mastery_impact_kind(orb_id)
	var tier_index: int = _replay_result_policy.result_vfx_tier_index(replay_result_vfx_tier(clean_kind, result_amount))
	var intensity: int = _stylized_replay_vfx_presenter.replay_effect_intensity(result_amount, tier_index)
	if (
		_use_max_combat_vfx()
		and _max_vfx_overlay.spawn_mastery_cast_sequence(orb_id, source_point, target_global, spool_lifetime, travel_lifetime, result_amount)
	):
		return
	_mastery_cast_vfx_presenter.spawn_cast_spool(source_local, orb_id, spool_lifetime, intensity)
	_mastery_cast_vfx_presenter.spawn_cast_travel(source_local, target_local, orb_id, travel_lifetime, spool_lifetime, intensity)


func spawn_mastery_fill_stream(orb_id: int, source_global: Vector2, amount: int, lifetime: float = MASTERY_FILL_STREAM_SECONDS) -> void:
	var streams_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_FILL_STREAMS) and not _reduced_motion
	var flare_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_CARD_INTAKE_FLARE)
	if not streams_enabled and not flare_enabled:
		return
	if not OrbType.is_valid_id(orb_id) or amount <= 0 or source_global == Vector2.ZERO:
		return
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	var target := _mastery_card_source(orb_id)
	if target == null:
		return
	var target_global := control_global_center(target, 0.5)
	if target_global == Vector2.ZERO:
		return
	var source_local := _global_to_vfx_local(source_global)
	var target_local := _global_to_vfx_local(target_global)
	var delta := target_local - source_local
	var distance := delta.length()
	if distance <= 1.0:
		return
	var clean_lifetime := maxf(0.18, lifetime)
	var intensity := clampi(2 + int(floor(float(amount) / 4.0)), 2, 8)
	_mastery_fill_vfx_presenter.spawn_fill_stream(source_local, target_local, orb_id, clean_lifetime, intensity, streams_enabled, flare_enabled)


func spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	_mastery_beam_presenter.spawn_mastery_beam(
		source_orb_or_node, target_or_start, orb_or_target, lifetime, _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.MASTERY_FILL_STREAMS), _use_max_combat_vfx()
	)


func _vfx_layer_size() -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return Vector2.ZERO
	var layer_size := _vfx_layer.size
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		var viewport := _vfx_layer.get_viewport()
		if viewport != null:
			layer_size = viewport.get_visible_rect().size
	return layer_size


func _mastery_card_source(orb_id: int) -> Control:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return null
	var card: Variant = _player_loadout_hud.get_combat_mastery_card(_elemental_mastery_cards, orb_id)
	if card == null:
		var fallback_name := "CombatMasteryCard%d" % orb_id
		card = _elemental_mastery_cards.get_node_or_null(fallback_name) as Control
	if card == null:
		return null

	var slot := card.get_node_or_null("CardPanel") as Control
	if slot == null:
		return card
	var icon := slot.get_node_or_null("MasteryIcon")
	if icon == null and card.get_node_or_null("MasteryIconSlot") is Control:
		slot = card.get_node_or_null("MasteryIconSlot") as Control
		icon = slot.get_node_or_null("MasteryIcon")
	return icon if icon is Control else slot


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _tween_fade_cleanup(control: Control, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	tween.finished.connect(
		func() -> void:
			if is_instance_valid(control):
				control.queue_free()
	)
