extends RefCounted
class_name VfxDebugCatalog

const ENTRY_POINT_MASTERY_SEQUENCE := "mastery_sequence"
const ENTRY_POINT_MASTERY_RESULT := "mastery_result"
const ENTRY_POINT_IMPACT := "impact"
const ENTRY_POINT_ARMOR_LINGER := "armor_linger"
const ENTRY_POINT_ENEMY_ATTACK := "enemy_attack"
const ENTRY_POINT_GENERIC_VFX := "generic_vfx"

const TARGET_ENEMY := "enemy"
const TARGET_BOARD := "board"
const TARGET_HP_BAR := "hp_bar"
const TARGET_GOLD := "gold"

const PHASE_FULL := "full"
const PHASE_CAST_TRAVEL := "cast_travel"
const PHASE_SPOOL := "spool"
const PHASE_TRAVEL := "travel"
const PHASE_IMPACT := "impact"
const PHASE_LABEL := "label"


static func entries() -> Array[Dictionary]:
	return [
		_mastery_entry("fire_full_sequence", "Fire - Full Sequence", "Fire", OrbType.Id.FIRE, "fire", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_impact_entry("fire_impact", "Fire - Impact Only", "Fire", "fire", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_mastery_entry("ice_full_sequence", "Ice - Full Sequence", "Ice", OrbType.Id.ICE, "ice", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_impact_entry("ice_impact", "Ice - Impact Only", "Ice", "ice", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_mastery_entry("earth_full_sequence", "Earth - Full Sequence", "Earth", OrbType.Id.EARTH, "earth", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_impact_entry("earth_impact", "Earth - Impact Only", "Earth", "earth", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		_mastery_result_entry("heart_full_sequence", "Heart - Heal Sequence", "Heal", OrbType.Id.HEART, "heart", TARGET_HP_BAR, 8, [3, 8, 14, 24]),
		_impact_entry("heart_impact", "Heart - Heal Impact", "Heal", "heart", TARGET_HP_BAR, 8, [3, 8, 14, 24]),
		_mastery_result_entry("armor_full_sequence", "Armor - Shield Sequence", "Armor", OrbType.Id.ARMOR, "armor", TARGET_HP_BAR, 8, [3, 8, 14, 24]),
		{
			"id": "armor_linger",
			"name": "Armor - Lingering Shield",
			"category": "Armor",
			"entry_point": ENTRY_POINT_ARMOR_LINGER,
			"kind": "armor",
			"target": TARGET_HP_BAR,
			"default_amount": 8,
			"amount_presets": [3, 8, 14, 24],
			"description": "Plays the HP-bar shield linger used after armor gain.",
		},
		_mastery_result_entry("gold_full_sequence", "Gold - Reward Sequence", "Gold", OrbType.Id.GOLD, "gold", TARGET_GOLD, 6, [2, 6, 12, 24]),
		_impact_entry("gold_reward", "Gold - Coin Rain Impact", "Gold", "gold", TARGET_GOLD, 6, [2, 6, 12, 24]),
		_impact_entry("damage_impact", "Damage - Generic Impact", "Damage", "damage", TARGET_ENEMY, 12, [4, 12, 25, 50]),
		{
			"id": "enemy_attack_full",
			"name": "Enemy - Attack Sequence",
			"category": "Enemy",
			"entry_point": ENTRY_POINT_ENEMY_ATTACK,
			"kind": "damage",
			"target": TARGET_HP_BAR,
			"default_amount": 10,
			"amount_presets": [4, 10, 18, 32],
			"description": "Plays cue, travel, impact, and result label for incoming enemy damage.",
		},
		{
			"id": "orb_clear_generic",
			"name": "Orb Clear - Generic Burst",
			"category": "Orb Clear",
			"entry_point": ENTRY_POINT_GENERIC_VFX,
			"kind": "generic",
			"effect_name": "orb_clear",
			"target": TARGET_BOARD,
			"default_amount": 6,
			"amount_presets": [3, 6, 12, 24],
			"description": "Plays the generic orb-clear VFX path.",
		},
	]


static func entry_by_id(entry_id: String) -> Dictionary:
	for entry in entries():
		if String(entry.get("id", "")) == entry_id:
			return entry.duplicate(true)
	return {}


static func categories() -> Array[String]:
	var seen := {}
	var result: Array[String] = []
	for entry in entries():
		var category := String(entry.get("category", "Other"))
		if seen.has(category):
			continue
		seen[category] = true
		result.append(category)
	return result


static func entries_for_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in entries():
		if String(entry.get("category", "Other")) == category:
			result.append(entry.duplicate(true))
	return result


static func phases_for_entry(entry: Dictionary) -> Array[Dictionary]:
	var entry_point := String(entry.get("entry_point", ""))
	match entry_point:
		ENTRY_POINT_MASTERY_SEQUENCE:
			return [
				{"id": PHASE_FULL, "name": "Full Sequence"},
				{"id": PHASE_CAST_TRAVEL, "name": "Cast + Travel"},
				{"id": PHASE_SPOOL, "name": "Spool Focus"},
				{"id": PHASE_TRAVEL, "name": "Travel Focus"},
				{"id": PHASE_IMPACT, "name": "Impact Only"},
				{"id": PHASE_LABEL, "name": "Label Only"},
			]
		ENTRY_POINT_MASTERY_RESULT:
			return [
				{"id": PHASE_FULL, "name": "Full Result"},
				{"id": PHASE_CAST_TRAVEL, "name": "Beam Only"},
				{"id": PHASE_IMPACT, "name": "Impact Only"},
				{"id": PHASE_LABEL, "name": "Label Only"},
			]
		ENTRY_POINT_IMPACT, ENTRY_POINT_ARMOR_LINGER, ENTRY_POINT_GENERIC_VFX:
			return [
				{"id": PHASE_FULL, "name": "Full"},
				{"id": PHASE_IMPACT, "name": "Impact Only"},
				{"id": PHASE_LABEL, "name": "Label Only"},
			]
		ENTRY_POINT_ENEMY_ATTACK:
			return [
				{"id": PHASE_FULL, "name": "Full Sequence"},
				{"id": PHASE_CAST_TRAVEL, "name": "Cue + Travel"},
				{"id": PHASE_IMPACT, "name": "Impact Only"},
				{"id": PHASE_LABEL, "name": "Label Only"},
			]
	return [{"id": PHASE_FULL, "name": "Full"}]


static func default_entry_id() -> String:
	var all_entries := entries()
	if all_entries.is_empty():
		return ""
	return String(all_entries[0].get("id", ""))


static func result_label_text(entry: Dictionary, amount: int) -> String:
	var kind := String(entry.get("kind", "damage"))
	match kind:
		"heart", "heal":
			return "+%d HP" % amount
		"armor", "block":
			return "+%d Armor" % amount
		"gold":
			return "+%d Gold" % amount
		"damage":
			return "-%d HP" % amount
	return "%d" % amount


static func label_kind(entry: Dictionary) -> String:
	var kind := String(entry.get("kind", "damage"))
	if kind == "heart":
		return "heal"
	return kind


static func target_name(target_id: String) -> String:
	match target_id:
		TARGET_ENEMY:
			return "Enemy"
		TARGET_BOARD:
			return "Board"
		TARGET_HP_BAR:
			return "HP Bar"
		TARGET_GOLD:
			return "Gold"
	return "Target"


static func _mastery_entry(
	entry_id: String,
	display_name: String,
	category: String,
	orb_id: int,
	kind: String,
	target: String,
	default_amount: int,
	amount_presets: Array
) -> Dictionary:
	return {
		"id": entry_id,
		"name": display_name,
		"category": category,
		"entry_point": ENTRY_POINT_MASTERY_SEQUENCE,
		"orb_id": orb_id,
		"kind": kind,
		"target": target,
		"default_amount": default_amount,
		"amount_presets": amount_presets,
		"description": "Plays the real combat mastery cast, travel, impact, and label path.",
	}


static func _impact_entry(
	entry_id: String,
	display_name: String,
	category: String,
	kind: String,
	target: String,
	default_amount: int,
	amount_presets: Array
) -> Dictionary:
	return {
		"id": entry_id,
		"name": display_name,
		"category": category,
		"entry_point": ENTRY_POINT_IMPACT,
		"kind": kind,
		"target": target,
		"default_amount": default_amount,
		"amount_presets": amount_presets,
		"description": "Plays the real combat replay impact path.",
	}


static func _mastery_result_entry(
	entry_id: String,
	display_name: String,
	category: String,
	orb_id: int,
	kind: String,
	target: String,
	default_amount: int,
	amount_presets: Array
) -> Dictionary:
	return {
		"id": entry_id,
		"name": display_name,
		"category": category,
		"entry_point": ENTRY_POINT_MASTERY_RESULT,
		"orb_id": orb_id,
		"kind": kind,
		"target": target,
		"default_amount": default_amount,
		"amount_presets": amount_presets,
		"description": "Plays the real combat impact, mastery beam, and label result path.",
	}
