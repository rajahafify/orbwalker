extends RefCounted
class_name OrbType

enum Id {
	FIRE,
	ICE,
	EARTH,
	HEART,
	ARMOR,
	GOLD,
}

const ALL_TYPES: Array[int] = [
	Id.FIRE,
	Id.ICE,
	Id.EARTH,
	Id.HEART,
	Id.ARMOR,
	Id.GOLD,
]

const _DISPLAY_NAMES := {
	Id.FIRE: "Fire",
	Id.ICE: "Ice",
	Id.EARTH: "Earth",
	Id.HEART: "Heart",
	Id.ARMOR: "Armor",
	Id.GOLD: "Gold",
}

const _DEBUG_SYMBOLS := {
	Id.FIRE: "F",
	Id.ICE: "I",
	Id.EARTH: "E",
	Id.HEART: "H",
	Id.ARMOR: "A",
	Id.GOLD: "G",
}

const _COLORS := {
	Id.FIRE: Color("#e45538"),
	Id.ICE: Color("#45b6ff"),
	Id.EARTH: Color("#78a54b"),
	Id.HEART: Color("#e05487"),
	Id.ARMOR: Color("#8b98a8"),
	Id.GOLD: Color("#d5a43d"),
}


static func is_valid_id(orb_id: int) -> bool:
	return orb_id in _DISPLAY_NAMES


static func display_name(orb_id: int) -> String:
	return _DISPLAY_NAMES.get(orb_id, "Unknown")


static func debug_symbol(orb_id: int) -> String:
	return _DEBUG_SYMBOLS.get(orb_id, "?")


static func color(orb_id: int) -> Color:
	return _COLORS.get(orb_id, Color.MAGENTA)
