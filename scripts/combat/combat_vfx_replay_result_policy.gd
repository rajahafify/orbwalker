extends RefCounted
class_name CombatVfxReplayResultPolicy

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


func replay_result_impact_profile(impact_kind: String, result_amount: int, base_draw_size: Vector2, base_lifetime: float, speed_scale: float) -> Dictionary:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	var tier_index := result_vfx_tier_index(tier)
	var size_scale: float = RESULT_VFX_TIER_SIZE_SCALES[tier_index]
	var lifetime_scale: float = RESULT_VFX_TIER_LIFETIME_SCALES[tier_index]
	return {
		"tier": tier,
		"tier_index": tier_index,
		"draw_size": base_draw_size * size_scale,
		"lifetime": post_match_vfx_lifetime(base_lifetime * lifetime_scale, speed_scale),
		"modulate_color": result_impact_modulate_color(impact_kind, tier),
	}


func replay_result_vfx_tier(impact_kind: String, result_amount: int) -> int:
	if result_amount <= 0:
		return 0
	var clean_kind := result_vfx_kind_key(impact_kind)
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


func result_vfx_size_scale(impact_kind: String, result_amount: int) -> float:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	return RESULT_VFX_TIER_SIZE_SCALES[result_vfx_tier_index(tier)]


func replay_result_is_screen_wide(impact_kind: String, result_amount: int) -> bool:
	var tier := replay_result_vfx_tier(impact_kind, result_amount)
	return result_vfx_tier_index(tier) >= RESULT_VFX_TIER_SIZE_SCALES.size() - 1


func post_match_vfx_lifetime(lifetime: float, speed_scale: float) -> float:
	return lifetime / maxf(0.25, speed_scale)


func result_impact_modulate_color(impact_kind: String, tier: int) -> Color:
	var clean_kind := result_vfx_kind_key(impact_kind)
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
	var tier_index := result_vfx_tier_index(tier)
	var alpha: float = RESULT_VFX_TIER_ALPHA[tier_index]
	var brightness: float = RESULT_VFX_TIER_BRIGHTNESS[tier_index]
	return Color(clampf(base.r * brightness, 0.0, 1.0), clampf(base.g * brightness, 0.0, 1.0), clampf(base.b * brightness, 0.0, 1.0), alpha)


func result_vfx_tier_index(tier: int) -> int:
	if tier <= 0:
		return 0
	return clampi(tier - 1, 0, RESULT_VFX_TIER_SIZE_SCALES.size() - 1)


func result_vfx_kind_key(impact_kind: String) -> String:
	var clean_kind := impact_kind.strip_edges().to_lower()
	if clean_kind == "heal":
		return "heart"
	if clean_kind == "block":
		return "armor"
	if clean_kind == "damage":
		return "damage"
	return clean_kind
