extends Resource
class_name VisualRegistryOrbCatalog

const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")

const RUNTIME_ORB_KEY_BY_ID := {
	ORB_TYPE_SCRIPT.Id.FIRE: "fire",
	ORB_TYPE_SCRIPT.Id.ICE: "ice",
	ORB_TYPE_SCRIPT.Id.EARTH: "earth",
	ORB_TYPE_SCRIPT.Id.HEART: "heart",
	ORB_TYPE_SCRIPT.Id.ARMOR: "armor",
	ORB_TYPE_SCRIPT.Id.GOLD: "gold",
}

const DERIVED_ORB_FILENAME_BY_ID := {
	ORB_TYPE_SCRIPT.Id.FIRE: "orb_fire_clean.png",
	ORB_TYPE_SCRIPT.Id.ICE: "orb_ice_clean.png",
	ORB_TYPE_SCRIPT.Id.EARTH: "orb_earth_clean.png",
	ORB_TYPE_SCRIPT.Id.HEART: "orb_heart_clean.png",
	ORB_TYPE_SCRIPT.Id.ARMOR: "orb_armor_clean.png",
	ORB_TYPE_SCRIPT.Id.GOLD: "orb_gold_clean.png",
}


static func runtime_orb_key_by_id() -> Dictionary:
	return RUNTIME_ORB_KEY_BY_ID


static func derived_orb_filename_by_id() -> Dictionary:
	return DERIVED_ORB_FILENAME_BY_ID


static func derived_orb_filename_count() -> int:
	return DERIVED_ORB_FILENAME_BY_ID.size()
