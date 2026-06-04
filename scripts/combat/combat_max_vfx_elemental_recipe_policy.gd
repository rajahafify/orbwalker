extends RefCounted
class_name CombatMaxVfxElementalRecipePolicy


func fire_tier(intensity: int, screen_wide: bool = false) -> int:
	return _tier_for_thresholds(intensity, screen_wide, 5, 3)


func ice_tier(intensity: int, screen_wide: bool = false) -> int:
	return _tier_for_thresholds(intensity, screen_wide, 6, 3)


func earth_tier(intensity: int, screen_wide: bool = false) -> int:
	return _tier_for_thresholds(intensity, screen_wide, 6, 3)


func replay_impact_basis_size(kind: String, draw_size: Vector2, fallback_size: float) -> float:
	if _clean_kind(kind) != "fire":
		return fallback_size
	if draw_size.x <= 1.0 or draw_size.y <= 1.0:
		return fallback_size
	var wide_ratio := maxf(draw_size.x, draw_size.y) / maxf(1.0, minf(draw_size.x, draw_size.y))
	if wide_ratio < 1.45:
		return fallback_size
	var geometric_size := sqrt(draw_size.x * draw_size.y) * 0.64
	var short_side_size := minf(draw_size.x, draw_size.y) * 1.18
	return maxf(96.0, maxf(geometric_size, short_side_size))


func _tier_for_thresholds(intensity: int, screen_wide: bool, tier_three_threshold: int, tier_two_threshold: int) -> int:
	if screen_wide or intensity >= tier_three_threshold:
		return 3
	if intensity >= tier_two_threshold:
		return 2
	return 1


func _clean_kind(kind: String) -> String:
	var cleaned := kind.strip_edges().to_lower()
	match cleaned:
		"heal":
			return "heart"
		"block":
			return "armor"
	return cleaned
