extends RefCounted
class_name RunEncounterCatalog

var _normal_encounters_by_level := {
	1:
	[
		{
			"enemy_id": "cavern_striker",
			"display_name": "Cavern Striker",
			"max_hp": 76,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 1, "attack": 0, "block": 8, "label": "Brace 8"},
				{"type": 2, "attack": 9, "block": 6, "label": "Shield Bash 9 + Guard 6"},
				{"type": 0, "attack": 11, "block": 0, "label": "Heavy Slash 11"},
			],
		},
		{
			"enemy_id": "cavern_defender",
			"display_name": "Cavern Defender",
			"max_hp": 82,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 1, "attack": 0, "block": 12, "label": "Fortify 12"},
				{"type": 2, "attack": 8, "block": 9, "label": "Counter 8 + Guard 9"},
				{"type": 0, "attack": 10, "block": 0, "label": "Crush 10"},
			],
		},
	],
	2:
	[
		{
			"enemy_id": "ash_hunter",
			"display_name": "Ash Hunter",
			"max_hp": 94,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 0, "attack": 16, "block": 0, "label": "Torch Combo 16"},
				{"type": 2, "attack": 14, "block": 3, "label": "Flare Cut 14 + Guard 3"},
				{"type": 0, "attack": 18, "block": 0, "label": "Scorch Drive 18"},
			],
		},
		{
			"enemy_id": "ruin_lancer",
			"display_name": "Ruin Lancer",
			"max_hp": 98,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 0, "attack": 18, "block": 0, "label": "Pierce 18"},
				{"type": 0, "attack": 16, "block": 0, "label": "Thrust 16"},
				{"type": 2, "attack": 15, "block": 2, "label": "Jab 15 + Brace 2"},
			],
		},
	],
	3:
	[
		{
			"enemy_id": "vault_executioner",
			"display_name": "Vault Executioner",
			"max_hp": 112,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 0, "attack": 18, "block": 0, "label": "Execution 18"},
				{"type": 2, "attack": 12, "block": 9, "label": "Parry 9 + Cleave 12"},
				{"type": 0, "attack": 17, "block": 0, "label": "Overhead 17"},
			],
		},
		{
			"enemy_id": "goldbound_keeper",
			"display_name": "Goldbound Keeper",
			"max_hp": 118,
			"is_boss": false,
			"intent_cycle":
			[
				{"type": 1, "attack": 0, "block": 14, "label": "Aegis 14"},
				{"type": 0, "attack": 17, "block": 0, "label": "Coin Hammer 17"},
				{"type": 2, "attack": 13, "block": 8, "label": "Rally 8 + Strike 13"},
			],
		},
	],
}

var _boss_encounters_by_level := {
	1:
	{
		"enemy_id": "iron_gate",
		"display_name": "Iron Gate",
		"max_hp": 142,
		"is_boss": true,
		"intent_cycle":
		[
			{"type": 1, "attack": 0, "block": 20, "label": "Fortress Stance 20"},
			{"type": 2, "attack": 14, "block": 12, "label": "Wall Bash 14 + Guard 12"},
			{"type": 0, "attack": 16, "block": 0, "label": "Gate Slam 16"},
		],
	},
	2:
	{
		"enemy_id": "burning_knight",
		"display_name": "Burning Knight",
		"max_hp": 158,
		"is_boss": true,
		"intent_cycle":
		[
			{"type": 0, "attack": 24, "block": 0, "label": "Inferno Cleave 24"},
			{"type": 0, "attack": 22, "block": 0, "label": "Scorching Lunge 22"},
			{"type": 2, "attack": 18, "block": 4, "label": "Blazing Guard 4 + Slash 18"},
		],
	},
	3:
	{
		"enemy_id": "prism_warden",
		"display_name": "Prism Warden",
		"max_hp": 176,
		"is_boss": true,
		"intent_cycle":
		[
			{"type": 1, "attack": 0, "block": 18, "label": "Prism Shield 18"},
			{"type": 0, "attack": 24, "block": 0, "label": "Spectrum Beam 24"},
			{"type": 2, "attack": 16, "block": 12, "label": "Refraction 12 + Burst 16"},
		],
	},
}


func normal_encounter(level: int, step_key: String) -> Dictionary:
	var fights: Array = _normal_encounters_by_level.get(level, [])
	var fight_index := 0 if step_key == "enemy_1" else 1
	if fight_index >= 0 and fight_index < fights.size():
		return Dictionary(fights[fight_index]).duplicate(true)
	return {}


func boss_encounter(level: int) -> Dictionary:
	return Dictionary(_boss_encounters_by_level.get(level, {})).duplicate(true)


func tutorial_encounter_for(dungeon_level: int, step_key: String) -> Dictionary:
	if dungeon_level != 1 or step_key != "enemy_1":
		return {}
	return {
		"enemy_id": "training_striker",
		"display_name": "Training Striker",
		"max_hp": 15,
		"is_boss": false,
		"intent_cycle":
		[
			{"type": 1, "attack": 0, "block": 8, "label": "Brace"},
			{"type": 2, "attack": 30, "block": 6, "label": "Punishing Bash"},
			{"type": 1, "attack": 0, "block": 10, "label": "Guard"},
			{"type": 0, "attack": 20, "block": 0, "label": "Heavy Slash"},
		],
	}


func fallback_encounter(step_key: String) -> Dictionary:
	return {
		"enemy_id": "training_goblin",
		"display_name": "Training Goblin",
		"max_hp": 90,
		"is_boss": step_key == "boss",
		"intent_cycle": [],
	}


func step_display_name(step: String) -> String:
	match step:
		"enemy_1":
			return "Enemy 1"
		"enemy_2":
			return "Enemy 2"
		"boss":
			return "Boss"
		"shop":
			return "Shop"
		"boss_relic_reward":
			return "Boss Relic Reward"
		"advance":
			return "Advance"
		_:
			return "Unknown"
