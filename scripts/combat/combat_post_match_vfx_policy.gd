extends RefCounted
class_name CombatPostMatchVfxPolicy

const RESULT_VFX_TIER_THRESHOLDS := {
	"fire": [6, 10, 16],
	"ice": [6, 10, 16],
	"earth": [6, 10, 16],
	"damage": [6, 10, 16],
	"heart": [4, 8, 12],
	"armor": [4, 8, 12],
	"gold": [3, 6, 10],
}
const RESULT_VFX_DEFAULT_THRESHOLDS := [6, 10, 16]
const RESULT_VFX_TIER_SIZE_SCALES := [1.85, 2.25, 3.0]
const RESULT_VFX_TIER_LIFETIME_SCALES := [1.18, 1.24, 1.30]
const RESULT_VFX_TIER_ALPHA := [0.98, 1.0, 1.0]
const RESULT_VFX_TIER_BRIGHTNESS := [1.20, 1.28, 1.36]
const DEFAULT_POST_MATCH_VFX_SPEED_SCALE := 0.55
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
const POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS := [0, 12, 16, 20, 24, 29, 34, 39, 44]

var _speed_scale := DEFAULT_POST_MATCH_VFX_SPEED_SCALE
var _quality := DEFAULT_POST_MATCH_VFX_QUALITY


func set_speed_scale(speed_scale: float) -> void:
	_speed_scale = clampf(speed_scale, 0.25, 2.0)


func set_quality(quality: String) -> void:
	_quality = normalized_quality(quality)


func quality() -> String:
	return _quality


func quality_options() -> Array[String]:
	return POST_MATCH_VFX_QUALITY_OPTIONS.duplicate()


func quality_uses_max_overlay() -> bool:
	return _quality == POST_MATCH_VFX_QUALITY_HIGH


func apply_project_quality() -> void:
	set_quality(String(ProjectSettings.get_setting(POST_MATCH_VFX_QUALITY_SETTING_PATH, DEFAULT_POST_MATCH_VFX_QUALITY)))


func normalized_quality(quality_value: String) -> String:
	var normalized := quality_value.strip_edges().to_lower()
	if POST_MATCH_VFX_QUALITY_OPTIONS.has(normalized):
		return normalized
	return DEFAULT_POST_MATCH_VFX_QUALITY


func adjusted_lifetime(lifetime: float) -> float:
	return lifetime / maxf(0.25, _speed_scale)


func impact_profile(impact_kind: String, result_amount: int, base_draw_size: Vector2, base_lifetime: float) -> Dictionary:
	var tier := result_tier(impact_kind, result_amount)
	var tier_index := result_tier_index(tier)
	var size_scale: float = RESULT_VFX_TIER_SIZE_SCALES[tier_index]
	var lifetime_scale: float = RESULT_VFX_TIER_LIFETIME_SCALES[tier_index]
	return {
		"tier": tier,
		"tier_index": tier_index,
		"draw_size": base_draw_size * size_scale,
		"lifetime": adjusted_lifetime(base_lifetime * lifetime_scale),
		"modulate_color": impact_modulate_color(impact_kind, tier),
	}


func result_tier(impact_kind: String, result_amount: int) -> int:
	if result_amount <= 0:
		return 0
	var clean_kind := kind_key(impact_kind)
	var thresholds: Array = RESULT_VFX_TIER_THRESHOLDS.get(clean_kind, RESULT_VFX_DEFAULT_THRESHOLDS)
	var medium_threshold := int(thresholds[0]) if thresholds.size() > 0 else int(RESULT_VFX_DEFAULT_THRESHOLDS[0])
	var high_threshold := int(thresholds[1]) if thresholds.size() > 1 else int(RESULT_VFX_DEFAULT_THRESHOLDS[1])
	var signature_threshold := int(thresholds[2]) if thresholds.size() > 2 else int(RESULT_VFX_DEFAULT_THRESHOLDS[2])
	if result_amount >= signature_threshold:
		return 3
	if result_amount >= high_threshold:
		return 2
	if result_amount >= medium_threshold:
		return 1
	return 1


func result_size_scale(impact_kind: String, result_amount: int) -> float:
	var tier := result_tier(impact_kind, result_amount)
	return RESULT_VFX_TIER_SIZE_SCALES[result_tier_index(tier)]


func result_is_screen_wide(impact_kind: String, result_amount: int) -> bool:
	var tier := result_tier(impact_kind, result_amount)
	return result_tier_index(tier) >= RESULT_VFX_TIER_SIZE_SCALES.size() - 1


func screen_replay_is_offensive(impact_kind: String) -> bool:
	return kind_key(impact_kind) in ["fire", "ice", "earth", "damage"]


func screen_replay_focus(layer_size: Vector2, impact_local: Vector2, impact_kind: String) -> Vector2:
	var focus := impact_local
	if focus == Vector2.ZERO:
		focus = layer_size * 0.5
	var clean_kind := kind_key(impact_kind)
	focus.x = clampf(focus.x, layer_size.x * 0.12, layer_size.x * 0.88)
	if screen_replay_is_offensive(clean_kind):
		focus.y = clampf(focus.y, layer_size.y * 0.12, layer_size.y * 0.42)
	elif clean_kind in ["heart", "armor"]:
		focus.y = clampf(focus.y, layer_size.y * 0.62, layer_size.y * 0.88)
	elif clean_kind == "gold":
		focus.y = clampf(focus.y, layer_size.y * 0.42, layer_size.y * 0.82)
	else:
		focus.y = clampf(focus.y, layer_size.y * 0.18, layer_size.y * 0.82)
	return focus


func runtime_caps() -> Dictionary:
	return {
		"max_particles_per_burst": POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST,
		"max_screen_rays": POST_MATCH_MAX_SCREEN_RAYS,
		"max_simultaneous_emitters": POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS,
		"texture_keys": POST_MATCH_RUNTIME_TEXTURE_KEYS.duplicate(),
	}


func runtime_particle_count(intensity: int, multiplier: float = 1.0) -> int:
	var index := clampi(intensity, 1, POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS.size() - 1)
	var base_count := int(POST_MATCH_RUNTIME_PARTICLE_BASE_COUNTS[index])
	var count := int(round(float(base_count) * maxf(0.1, multiplier)))
	return clampi(count, 1, POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST)


func impact_modulate_color(impact_kind: String, tier: int) -> Color:
	var clean_kind := kind_key(impact_kind)
	var base := Color(1.0, 1.0, 1.0, 1.0)
	match clean_kind:
		"fire":
			base = Color(1.0, 0.66, 0.42, 1.0)
		"ice":
			base = Color(0.68, 0.92, 1.0, 1.0)
		"earth":
			base = Color(0.72, 0.94, 0.58, 1.0)
		"heart":
			base = Color(0.72, 1.0, 0.78, 1.0)
		"armor":
			base = Color(0.82, 0.92, 1.0, 1.0)
		"gold":
			base = Color(1.0, 0.92, 0.5, 1.0)
		"damage":
			base = Color(1.0, 0.48, 0.38, 1.0)
	var tier_index := result_tier_index(tier)
	var alpha: float = RESULT_VFX_TIER_ALPHA[tier_index]
	var brightness: float = RESULT_VFX_TIER_BRIGHTNESS[tier_index]
	return Color(
		clampf(base.r * brightness, 0.0, 1.0),
		clampf(base.g * brightness, 0.0, 1.0),
		clampf(base.b * brightness, 0.0, 1.0),
		alpha
	)


func result_tier_index(tier: int) -> int:
	if tier <= 0:
		return 0
	return clampi(tier - 1, 0, RESULT_VFX_TIER_SIZE_SCALES.size() - 1)


func kind_key(impact_kind: String) -> String:
	var clean_kind := impact_kind.strip_edges().to_lower()
	if clean_kind == "heal":
		return "heart"
	if clean_kind == "block":
		return "armor"
	if clean_kind == "damage":
		return "damage"
	return clean_kind
