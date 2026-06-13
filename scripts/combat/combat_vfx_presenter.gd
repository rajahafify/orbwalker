extends RefCounted
class_name CombatVfxPresenter

const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")
const COMBAT_VFX_PROFILE_SCRIPT := preload("res://scripts/combat/combat_vfx_profile.gd")
const COMBAT_SCREEN_WIDE_REPLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_wide_replay_presenter.gd")
const COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_texture_factory.gd")
const COMBAT_VFX_RUNTIME_SPAWNER_SCRIPT := preload("res://scripts/combat/combat_vfx_runtime_spawner.gd")
const COMBAT_RUNTIME_VFX_SPRITE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_sprite_presenter.gd")
const COMBAT_RUNTIME_VFX_PRIMITIVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_primitive_presenter.gd")
const COMBAT_POST_MATCH_VFX_POLICY_SCRIPT := preload("res://scripts/combat/combat_post_match_vfx_policy.gd")
const COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_attack_vfx_presenter.gd")
const COMBAT_VFX_ENEMY_ATTACK_ROUTER_SCRIPT := preload("res://scripts/combat/combat_vfx_enemy_attack_router.gd")
const COMBAT_RESULT_LABEL_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_result_label_presenter.gd")
const COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_screen_feedback_presenter.gd")
const COMBAT_SPARK_BURST_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_spark_burst_presenter.gd")
const COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_fill_vfx_presenter.gd")
const COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_mastery_cast_vfx_presenter.gd")
const COMBAT_VFX_REPLAY_RESULT_POLICY_SCRIPT := preload("res://scripts/combat/combat_vfx_replay_result_policy.gd")
const COMBAT_VFX_MASTERY_BEAM_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_mastery_beam_presenter.gd")
const COMBAT_VFX_MASTERY_ROUTER_SCRIPT := preload("res://scripts/combat/combat_vfx_mastery_router.gd")
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
var _runtime_spawner: Variant = COMBAT_VFX_RUNTIME_SPAWNER_SCRIPT.new()
var _post_match_policy: Variant = COMBAT_POST_MATCH_VFX_POLICY_SCRIPT.new()
var _enemy_attack_vfx_presenter: Variant = COMBAT_ENEMY_ATTACK_VFX_PRESENTER_SCRIPT.new()
var _enemy_attack_router: Variant = COMBAT_VFX_ENEMY_ATTACK_ROUTER_SCRIPT.new()
var _result_label_presenter: Variant = COMBAT_RESULT_LABEL_PRESENTER_SCRIPT.new()
var _screen_feedback_presenter: Variant = COMBAT_SCREEN_FEEDBACK_PRESENTER_SCRIPT.new()
var _spark_burst_presenter: Variant = COMBAT_SPARK_BURST_PRESENTER_SCRIPT.new()
var _mastery_fill_vfx_presenter: Variant = COMBAT_MASTERY_FILL_VFX_PRESENTER_SCRIPT.new()
var _mastery_cast_vfx_presenter: Variant = COMBAT_MASTERY_CAST_VFX_PRESENTER_SCRIPT.new()
var _replay_result_policy: Variant = COMBAT_VFX_REPLAY_RESULT_POLICY_SCRIPT.new()
var _mastery_beam_presenter: Variant = COMBAT_VFX_MASTERY_BEAM_PRESENTER_SCRIPT.new()
var _mastery_router: Variant = COMBAT_VFX_MASTERY_ROUTER_SCRIPT.new()
var _armor_linger_vfx_presenter: Variant = COMBAT_ARMOR_LINGER_VFX_PRESENTER_SCRIPT.new()
var _healing_bar_infusion_vfx_presenter: Variant = COMBAT_HEALING_BAR_INFUSION_VFX_PRESENTER_SCRIPT.new()
var _stylized_replay_vfx_presenter: Variant = COMBAT_STYLIZED_REPLAY_VFX_PRESENTER_SCRIPT.new()
var _post_match_vfx_speed_scale := DEFAULT_POST_MATCH_VFX_SPEED_SCALE
var _post_match_vfx_quality := DEFAULT_POST_MATCH_VFX_QUALITY
var _reduced_motion := false
var _game_juice_enabled := false
var _game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()

const DEFAULT_POST_MATCH_VFX_SPEED_SCALE := 0.55
const FORCE_MAX_COMBAT_VFX := true
const POST_MATCH_VFX_QUALITY_HIGH := "high"
const POST_MATCH_VFX_QUALITY_LOW := "low"
const POST_MATCH_VFX_QUALITY_OPTIONS: Array[String] = [
	POST_MATCH_VFX_QUALITY_HIGH,
	POST_MATCH_VFX_QUALITY_LOW,
]
const DEFAULT_POST_MATCH_VFX_QUALITY := POST_MATCH_VFX_QUALITY_LOW
const POST_MATCH_VFX_QUALITY_SETTING_PATH := "matchatro/combat/post_match_vfx_quality"
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
	_enemy_attack_router.bind(
		{"max_vfx_overlay": _max_vfx_overlay, "enemy_attack_vfx_presenter": _enemy_attack_vfx_presenter},
		{"use_max_combat_vfx": Callable(self, "_use_max_combat_vfx"), "spawn_replay_impact": Callable(self, "spawn_replay_impact")}
	)
	_result_label_presenter.bind(dependencies)
	_screen_feedback_presenter.bind(dependencies)
	_spark_burst_presenter.bind(dependencies)
	var runtime_spawner_dependencies := dependencies.duplicate()
	runtime_spawner_dependencies["max_vfx_overlay"] = _max_vfx_overlay
	runtime_spawner_dependencies["runtime_texture_factory"] = _runtime_texture_factory
	runtime_spawner_dependencies["spark_burst_presenter"] = _spark_burst_presenter
	(
		_runtime_spawner
		. bind(
			runtime_spawner_dependencies,
			{
				"use_max_combat_vfx": Callable(self, "_use_max_combat_vfx"),
				"juice_enabled": Callable(self, "_juice_enabled"),
			}
		)
	)
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
	var mastery_router_dependencies := dependencies.duplicate()
	mastery_router_dependencies["max_vfx_overlay"] = _max_vfx_overlay
	mastery_router_dependencies["mastery_fill_vfx_presenter"] = _mastery_fill_vfx_presenter
	mastery_router_dependencies["mastery_cast_vfx_presenter"] = _mastery_cast_vfx_presenter
	mastery_router_dependencies["replay_result_policy"] = _replay_result_policy
	mastery_router_dependencies["stylized_replay_vfx_presenter"] = _stylized_replay_vfx_presenter
	mastery_router_dependencies["mastery_beam_presenter"] = _mastery_beam_presenter
	(
		_mastery_router
		. bind(
			mastery_router_dependencies,
			{
				"mastery_impact_kind": Callable(self, "mastery_impact_kind"),
				"use_max_combat_vfx": Callable(self, "_use_max_combat_vfx"),
				"juice_enabled": Callable(self, "_juice_enabled"),
			}
		)
	)
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


func set_game_juice_enabled(enabled: bool) -> void:
	_game_juice_enabled = enabled
	_screen_feedback_presenter.set_game_juice_enabled(enabled)
	_spark_burst_presenter.set_game_juice_enabled(enabled)


func set_game_juice_flags(flags: Dictionary) -> void:
	_game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	_screen_feedback_presenter.set_game_juice_flags(_game_juice_flags)
	_spark_burst_presenter.set_game_juice_flags(_game_juice_flags)


func post_match_vfx_quality_uses_max_overlay() -> bool:
	return _post_match_vfx_quality == POST_MATCH_VFX_QUALITY_HIGH


func spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	_runtime_spawner.spawn_vfx(effect_name, global_center, draw_size, lifetime, modulate_color)


func spawn_vfx_texture(
	texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
) -> void:
	_runtime_spawner.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if global_center == Vector2.ZERO:
		return
	var clean_kind: String = _replay_result_policy.result_vfx_kind_key(impact_kind)
	if _visual_registry == null and not ["armor", "heart"].has(clean_kind):
		return
	var impact_juice_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
	var profile: Dictionary = (
		_replay_result_policy.replay_result_impact_profile(impact_kind, result_amount, draw_size, lifetime, _post_match_vfx_speed_scale)
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
			global_center,
			clean_kind,
			profile_size,
			profile_lifetime,
			result_amount,
			intensity,
			_replay_result_policy.replay_result_is_screen_wide(clean_kind, result_amount)
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
	var tier_index: int = _replay_result_policy.result_vfx_tier_index(_replay_result_policy.replay_result_vfx_tier("armor", result_amount))
	var intensity: int = _stylized_replay_vfx_presenter.replay_effect_intensity(result_amount, tier_index)
	var duration := _post_match_vfx_lifetime(maxf(0.60, lifetime) * (1.70 + float(tier_index) * 0.16))
	_spawn_armor_bar_linger_effect(global_center, draw_size, duration, intensity)


func result_vfx_size_scale(impact_kind: String, result_amount: int) -> float:
	return _replay_result_policy.result_vfx_size_scale(impact_kind, result_amount)


func replay_result_is_screen_wide(impact_kind: String, result_amount: int) -> bool:
	return _replay_result_policy.replay_result_is_screen_wide(impact_kind, result_amount)


func screen_nudge(intensity: int = 1, source_global: Vector2 = Vector2.ZERO) -> void:
	_screen_feedback_presenter.screen_nudge(intensity, source_global)


func hit_stop(seconds: float = 0.04) -> void:
	await _screen_feedback_presenter.hit_stop(seconds)


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


func _post_match_vfx_lifetime(lifetime: float) -> float:
	return _replay_result_policy.post_match_vfx_lifetime(lifetime, _post_match_vfx_speed_scale)


func spawn_result_label(text: String, global_center: Vector2, kind: String, lifetime: float, offset: Vector2 = Vector2.ZERO, result_amount: int = 0) -> Label:
	if text.strip_edges() == "" or global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var impact_juice_enabled := _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
	var clean_kind := kind.strip_edges().to_lower()
	var label_scale: float = _replay_result_policy.result_vfx_size_scale(kind, result_amount) if impact_juice_enabled else 1.0
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


func enemy_attack_router() -> Variant:
	return _enemy_attack_router


func mastery_impact_kind(orb_id: int) -> String:
	return _vfx_profile.mastery_impact_kind(orb_id)


func _spawn_stylized_replay_effect(
	global_center: Vector2, clean_kind: String, draw_size: Vector2, lifetime: float, result_amount: int, tier_index: int
) -> void:
	var screen_wide: bool = _replay_result_policy.replay_result_is_screen_wide(clean_kind, result_amount)
	_stylized_replay_vfx_presenter.spawn_stylized_replay_effect(global_center, clean_kind, draw_size, lifetime, result_amount, tier_index, screen_wide)


func _spawn_armor_bar_linger_effect(global_center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var center_local := _global_to_vfx_local(global_center)
	_armor_linger_vfx_presenter.spawn_armor_linger(center_local, draw_size, lifetime, intensity)


func spawn_mastery_cast_sequence(orb_id: int, target_global: Vector2, spool_lifetime: float, travel_lifetime: float, result_amount: int = 0) -> void:
	_mastery_router.spawn_mastery_cast_sequence(orb_id, target_global, spool_lifetime, travel_lifetime, result_amount)


func spawn_mastery_fill_stream(orb_id: int, source_global: Vector2, amount: int, lifetime: float = MASTERY_FILL_STREAM_SECONDS) -> void:
	_mastery_router.spawn_mastery_fill_stream(orb_id, source_global, amount, lifetime, _reduced_motion)


func spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	_mastery_router.spawn_mastery_beam(source_orb_or_node, target_or_start, orb_or_target, lifetime)


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	return _runtime_spawner.global_to_vfx_local(global_position)
