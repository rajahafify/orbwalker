extends RefCounted
class_name PlayerState

const DEFAULT_MAX_HP := 100
const DEFAULT_EQUIPMENT_SLOTS := 5
const DEFAULT_CONSUMABLE_SLOTS := 3
const DEFAULT_MOVE_TIMER_SECONDS := 5.0
const DEFAULT_INCREASE_COMBO_MODIFIER := 0
const DEFAULT_MORE_COMBO_MODIFIER := 1.0

var max_hp: int = DEFAULT_MAX_HP
var current_hp: int = DEFAULT_MAX_HP
var armor: int = 0
var gold: int = 0

var base_orb_values := {
	OrbType.Id.FIRE: 1,
	OrbType.Id.ICE: 1,
	OrbType.Id.EARTH: 1,
	OrbType.Id.HEART: 1,
	OrbType.Id.ARMOR: 1,
	OrbType.Id.GOLD: 1,
}

var equipment_slots: int = DEFAULT_EQUIPMENT_SLOTS
var consumable_slots: int = DEFAULT_CONSUMABLE_SLOTS
var move_timer_seconds: float = DEFAULT_MOVE_TIMER_SECONDS
var increase_combo_modifier: int = DEFAULT_INCREASE_COMBO_MODIFIER
var more_combo_modifier: float = DEFAULT_MORE_COMBO_MODIFIER


func reset_for_new_run() -> void:
	max_hp = DEFAULT_MAX_HP
	current_hp = max_hp
	armor = 0
	gold = 0
	equipment_slots = DEFAULT_EQUIPMENT_SLOTS
	consumable_slots = DEFAULT_CONSUMABLE_SLOTS
	move_timer_seconds = DEFAULT_MOVE_TIMER_SECONDS
	increase_combo_modifier = DEFAULT_INCREASE_COMBO_MODIFIER
	more_combo_modifier = DEFAULT_MORE_COMBO_MODIFIER


func heal(amount: int, allow_overheal: bool = false) -> int:
	if amount <= 0:
		return 0
	var previous_hp := current_hp
	if allow_overheal:
		current_hp += amount
	else:
		current_hp = mini(max_hp, current_hp + amount)
	return current_hp - previous_hp


func add_temporary_armor(amount: int) -> int:
	if amount <= 0:
		return 0
	armor += amount
	return amount


func apply_damage(damage: int) -> Dictionary:
	var incoming := maxi(0, damage)
	var armor_blocked := mini(armor, incoming)
	armor -= armor_blocked
	var hp_damage := incoming - armor_blocked
	current_hp = maxi(0, current_hp - hp_damage)

	return {
		"incoming": incoming,
		"blocked_by_armor": armor_blocked,
		"hp_damage": hp_damage,
		"remaining_hp": current_hp,
		"remaining_armor": armor,
	}


func expire_temporary_armor() -> int:
	var expired := armor
	armor = 0
	return expired


func is_dead() -> bool:
	return current_hp <= 0


func orb_value(orb_id: int) -> int:
	if not OrbType.is_valid_id(orb_id):
		return 0
	var mastery_bonus := 0
	if RunState != null and RunState.player_progression_state != null:
		mastery_bonus = int(RunState.player_progression_state.mastery_level(orb_id))
	return mastery_bonus + 1


func combo_multiplier(combo_count: int) -> float:
	var scaled_combo := increase_combo_modifier + maxi(0, combo_count)
	return float(scaled_combo) * more_combo_modifier
