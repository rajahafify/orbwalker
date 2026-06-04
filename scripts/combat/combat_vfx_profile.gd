extends RefCounted
class_name CombatVfxProfile


func mastery_impact_kind(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.FIRE:
			return "fire"
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.ARMOR:
			return "armor"
		OrbType.Id.GOLD:
			return "gold"
		_:
			return "fire"


func result_effect_colors(clean_kind: String) -> Dictionary:
	match _result_kind_key(clean_kind):
		"fire":
			return _colors(Color(1.0, 0.24, 0.04, 1.0), Color(1.0, 0.88, 0.36, 1.0), Color(0.65, 0.07, 0.01, 1.0))
		"ice":
			return _colors(Color(0.42, 0.88, 1.0, 1.0), Color(0.88, 1.0, 1.0, 1.0), Color(0.08, 0.38, 0.70, 1.0))
		"earth":
			return _colors(Color(0.56, 0.94, 0.30, 1.0), Color(0.88, 1.0, 0.42, 1.0), Color(0.22, 0.38, 0.14, 1.0))
		"heart":
			return _colors(Color(0.32, 1.0, 0.52, 1.0), Color(0.82, 1.0, 0.78, 1.0), Color(0.08, 0.44, 0.18, 1.0))
		"armor":
			return _colors(Color(0.58, 0.82, 1.0, 1.0), Color(0.92, 0.98, 1.0, 1.0), Color(0.12, 0.28, 0.56, 1.0))
		"gold":
			return _colors(Color(1.0, 0.72, 0.12, 1.0), Color(1.0, 0.96, 0.48, 1.0), Color(0.62, 0.34, 0.04, 1.0))
		"damage":
			return _colors(Color(1.0, 0.22, 0.16, 1.0), Color(1.0, 0.58, 0.44, 1.0), Color(0.54, 0.04, 0.02, 1.0))
	return _colors(Color.WHITE, Color.WHITE, Color(0.35, 0.35, 0.35, 1.0))


func mastery_cast_colors(orb_id: int) -> Dictionary:
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH, OrbType.Id.HEART, OrbType.Id.ARMOR, OrbType.Id.GOLD:
			return result_effect_colors(mastery_impact_kind(orb_id))
	var fallback := OrbType.color(orb_id)
	return _colors(fallback, fallback.lightened(0.35), fallback.darkened(0.45))


func result_label_color(kind: String, high_contrast: bool = false) -> Color:
	var clean_kind := _result_kind_key(kind)
	if high_contrast and clean_kind in ["fire", "ice", "earth", "damage"]:
		return Color.WHITE
	match clean_kind:
		"fire":
			return Color(1.0, 0.37, 0.16, 1.0)
		"ice":
			return Color(0.46, 0.85, 1.0, 1.0)
		"earth":
			return Color(0.68, 0.95, 0.42, 1.0)
		"heart":
			return Color(0.44, 1.0, 0.58, 1.0)
		"armor":
			return Color(0.78, 0.9, 1.0, 1.0)
		"gold":
			return Color(1.0, 0.83, 0.2, 1.0)
		"damage":
			return Color(1.0, 0.22, 0.22, 1.0)
	return Color.WHITE


func _result_kind_key(kind: String) -> String:
	var clean_kind := kind.strip_edges().to_lower()
	if clean_kind == "heal":
		return "heart"
	if clean_kind == "block":
		return "armor"
	return clean_kind


func _colors(accent: Color, core: Color, dark: Color) -> Dictionary:
	return {
		"accent": accent,
		"core": core,
		"dark": dark,
	}
