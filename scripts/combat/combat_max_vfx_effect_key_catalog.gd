extends RefCounted
class_name CombatMaxVfxEffectKeyCatalog

const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")


func status_sheet_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "burn"
		"ice":
			return "freeze"
		"earth":
			return "poison"
		"heart":
			return "heal"
		"armor":
			return "armor"
		"gold":
			return "blessed"
		"damage":
			return "bleed"
	return "shock"


func status_trail_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "rage"
		"ice":
			return "slow"
		"earth":
			return "weaken"
		"heart":
			return "regen"
		"armor":
			return "armor"
		"gold":
			return "haste"
		"damage":
			return "stun"
	return status_sheet_key(kind)


func atmospheric_travel_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "snow"
		"earth":
			return "caustics"
		"heart":
			return "magic_wind"
		"armor":
			return "godrays"
		"gold":
			return "meteor"
		"damage":
			return "storm"
	return "magic_wind"


func atmospheric_impact_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "embers"
		"ice":
			return "frost"
		"earth":
			return "rain_splash"
		"heart":
			return "fireflies"
		"armor":
			return "godrays"
		"gold":
			return "fireflies"
		"damage":
			return "storm"
	return "fog"


func atmospheric_secondary_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "meteor"
		"ice":
			return "frost"
		"earth":
			return "bubbles"
		"heart":
			return "godrays"
		"armor":
			return "caustics"
		"gold":
			return "godrays"
		"damage":
			return "embers"
	return "fog"


func impact_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "fire_impact"
		"ice":
			return "ice_impact"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
		"damage":
			return "damage_impact"
	return "orb_clear"


func projectile_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "fire_projectile"
		"ice":
			return "ice_projectile"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_impact"
		"armor":
			return "armor_impact"
		"gold":
			return "gold_reward"
	return "orb_clear"


func trail_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
		"gold":
			return "spark_particles"
	return "smoke_puff"


func mist_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "flame_trail"
		"ice":
			return "frost_mist"
		"earth":
			return "dust_puff"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
	return "smoke_puff"


func particle_key(kind: String) -> String:
	match clean_kind(kind):
		"fire":
			return "spark_particles"
		"ice":
			return "ice_shards"
		"earth":
			return "stone_chunks"
		"heart":
			return "heal_motes"
		"armor":
			return "armor_impact"
		"gold":
			return "coin_spin"
		"damage":
			return "spark_particles"
	return "spark_particles"


func clean_kind(kind: String) -> String:
	var clean := kind.strip_edges().to_lower()
	if clean == "heal" or clean == "healing":
		return "heart"
	if clean == "block" or clean == "shield":
		return "armor"
	return clean


func should_use_elemental_magic(kind: String) -> bool:
	return clean_kind(kind) in ["fire", "ice", "earth", "heart", "armor", "gold"]


func kind_for_orb(orb_id: int) -> String:
	match orb_id:
		ORB_TYPE_SCRIPT.Id.FIRE:
			return "fire"
		ORB_TYPE_SCRIPT.Id.ICE:
			return "ice"
		ORB_TYPE_SCRIPT.Id.EARTH:
			return "earth"
		ORB_TYPE_SCRIPT.Id.HEART:
			return "heart"
		ORB_TYPE_SCRIPT.Id.ARMOR:
			return "armor"
		ORB_TYPE_SCRIPT.Id.GOLD:
			return "gold"
	return "damage"


func elemental_kind_colors(kind: String) -> Dictionary:
	match clean_kind(kind):
		"fire":
			return {"primary": Color(1.0, 0.76, 0.20, 1.0), "secondary": Color(1.0, 0.22, 0.03, 1.0), "tertiary": Color(0.34, 0.02, 0.00, 1.0)}
		"ice":
			return {"primary": Color(0.90, 1.0, 1.0, 1.0), "secondary": Color(0.28, 0.84, 1.0, 1.0), "tertiary": Color(0.04, 0.18, 0.68, 1.0)}
		"earth":
			return {"primary": Color(0.66, 1.0, 0.26, 1.0), "secondary": Color(0.28, 0.58, 0.14, 1.0), "tertiary": Color(0.12, 0.16, 0.06, 1.0)}
		"heart":
			return {"primary": Color(0.86, 1.0, 0.78, 1.0), "secondary": Color(0.30, 1.0, 0.58, 1.0), "tertiary": Color(0.06, 0.35, 0.18, 1.0)}
		"armor":
			return {"primary": Color(0.94, 0.99, 1.0, 1.0), "secondary": Color(0.46, 0.78, 1.0, 1.0), "tertiary": Color(0.06, 0.16, 0.46, 1.0)}
		"gold":
			return {"primary": Color(1.0, 0.96, 0.44, 1.0), "secondary": Color(1.0, 0.58, 0.10, 1.0), "tertiary": Color(0.48, 0.18, 0.02, 1.0)}
	return {"primary": Color(1.0, 1.0, 1.0, 1.0), "secondary": Color(0.78, 0.86, 1.0, 1.0), "tertiary": Color(0.18, 0.24, 0.38, 1.0)}


func kind_colors(kind: String) -> Dictionary:
	match clean_kind(kind):
		"fire":
			return {"accent": Color(1.0, 0.25, 0.04, 1.0), "core": Color(1.0, 0.88, 0.35, 1.0)}
		"ice":
			return {"accent": Color(0.35, 0.86, 1.0, 1.0), "core": Color(0.88, 1.0, 1.0, 1.0)}
		"earth":
			return {"accent": Color(0.36, 0.62, 0.18, 1.0), "core": Color(0.78, 1.0, 0.34, 1.0)}
		"heart":
			return {"accent": Color(0.32, 1.0, 0.50, 1.0), "core": Color(0.84, 1.0, 0.76, 1.0)}
		"armor":
			return {"accent": Color(0.54, 0.80, 1.0, 1.0), "core": Color(0.92, 0.98, 1.0, 1.0)}
		"gold":
			return {"accent": Color(1.0, 0.68, 0.12, 1.0), "core": Color(1.0, 0.96, 0.42, 1.0)}
		"damage":
			return {"accent": Color(1.0, 0.18, 0.12, 1.0), "core": Color(1.0, 0.58, 0.44, 1.0)}
	return {"accent": Color(0.86, 0.90, 1.0, 1.0), "core": Color(1.0, 1.0, 1.0, 1.0)}
