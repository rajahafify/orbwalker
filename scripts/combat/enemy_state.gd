extends RefCounted
class_name EnemyState

enum IntentType {
	ATTACK,
	BLOCK,
	ATTACK_AND_BLOCK,
}

var enemy_id: String = "training_goblin"
var display_name: String = "Training Goblin"
var max_hp: int = 90
var current_hp: int = 90
var is_boss: bool = false

# Intent entries use: {"type": IntentType, "attack": int, "block": int, "label": String}
var intent_cycle: Array[Dictionary] = []
var intent_index: int = 0
var current_turn_block: int = 0


func _init() -> void:
	intent_cycle = _default_intent_cycle()


func reset_for_fight() -> void:
	current_hp = max_hp
	intent_index = 0
	current_turn_block = 0


func configure_from_blueprint(blueprint: Dictionary) -> void:
	enemy_id = String(blueprint.get("enemy_id", enemy_id))
	display_name = String(blueprint.get("display_name", display_name))
	max_hp = maxi(1, int(blueprint.get("max_hp", max_hp)))
	current_hp = max_hp
	is_boss = bool(blueprint.get("is_boss", false))
	var configured_cycle: Array = blueprint.get("intent_cycle", [])
	if configured_cycle.is_empty():
		intent_cycle = _default_intent_cycle()
	else:
		intent_cycle = []
		for raw_intent in configured_cycle:
			intent_cycle.append(Dictionary(raw_intent).duplicate(true))
	intent_index = 0
	current_turn_block = 0


func get_current_intent() -> Dictionary:
	if intent_cycle.is_empty():
		return {
			"type": IntentType.ATTACK,
			"attack": 0,
			"block": 0,
			"label": "Idle",
		}
	var safe_index := posmod(intent_index, intent_cycle.size())
	var intent: Dictionary = intent_cycle[safe_index].duplicate(true)
	intent["index"] = safe_index
	return intent


func prepare_turn_block_from_intent() -> int:
	current_turn_block = int(get_current_intent().get("block", 0))
	return current_turn_block


func consume_block_vs_player_damage(incoming_damage: int) -> Dictionary:
	var incoming := maxi(0, incoming_damage)
	var blocked := mini(current_turn_block, incoming)
	current_turn_block -= blocked
	return {
		"incoming": incoming,
		"blocked": blocked,
		"final_damage": incoming - blocked,
		"remaining_block": current_turn_block,
	}


func apply_damage(damage: int) -> int:
	var dealt := maxi(0, damage)
	current_hp = maxi(0, current_hp - dealt)
	return dealt


func advance_intent() -> void:
	if intent_cycle.is_empty():
		intent_index = 0
		return
	intent_index = (intent_index + 1) % intent_cycle.size()


func clear_turn_block() -> void:
	current_turn_block = 0


func is_dead() -> bool:
	return current_hp <= 0


func _default_intent_cycle() -> Array[Dictionary]:
	return [
		{
			"type": IntentType.ATTACK,
			"attack": 14,
			"block": 0,
			"label": "Slash 14",
		},
		{
			"type": IntentType.BLOCK,
			"attack": 0,
			"block": 8,
			"label": "Guard 8",
		},
		{
			"type": IntentType.ATTACK_AND_BLOCK,
			"attack": 9,
			"block": 6,
			"label": "Bash 9 + Guard 6",
		},
	]
