extends RefCounted
class_name ContentRegistryDefaultContent

const CONTENT_REGISTRY_DEFAULT_EQUIPMENT_SCRIPT := preload("res://scripts/content/content_registry_default_equipment.gd")

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const MASTERY_CARDS := "mastery_cards"
const TREASURE_CHESTS := "treasure_chests"
const RELICS := "relics"
const ENEMIES := "enemies"
const BOSSES := "bosses"

var _entry_factory: RefCounted
var _equipment: RefCounted = CONTENT_REGISTRY_DEFAULT_EQUIPMENT_SCRIPT.new()


func bind(entry_factory: RefCounted) -> void:
	_entry_factory = entry_factory


func build() -> Dictionary:
	return {
		EQUIPMENT: _equipment.build(_entry_factory),
		CONSUMABLES:
		[
			_entry_factory.make_consumable("fire_scroll", "Fire Scroll", "common", OrbType.Id.FIRE, 9, 3, "consumable_fire_scroll"),
			_entry_factory.make_consumable("ice_scroll", "Ice Scroll", "common", OrbType.Id.ICE, 9, 3, "consumable_ice_scroll"),
			_entry_factory.make_consumable("earth_scroll", "Earth Scroll", "common", OrbType.Id.EARTH, 9, 3, "consumable_earth_scroll"),
			_entry_factory.make_consumable("heart_scroll", "Heart Scroll", "common", OrbType.Id.HEART, 9, 3, "consumable_heart_scroll"),
			_entry_factory.make_consumable("armor_scroll", "Armor Scroll", "common", OrbType.Id.ARMOR, 9, 3, "consumable_armor_scroll"),
			_entry_factory.make_consumable("gold_scroll", "Gold Scroll", "uncommon", OrbType.Id.GOLD, 13, 3, "consumable_gold_scroll", 2),
		],
		MASTERY_CARDS:
		[
			_entry_factory.make_mastery_card("fire_mastery", "Fire Mastery", "common", OrbType.Id.FIRE, 11, "mastery_fire"),
			_entry_factory.make_mastery_card("ice_mastery", "Ice Mastery", "common", OrbType.Id.ICE, 11, "mastery_ice"),
			_entry_factory.make_mastery_card("earth_mastery", "Earth Mastery", "common", OrbType.Id.EARTH, 11, "mastery_earth"),
			_entry_factory.make_mastery_card("heart_mastery", "Heart Mastery", "common", OrbType.Id.HEART, 12, "mastery_heart"),
			_entry_factory.make_mastery_card("armor_mastery", "Armor Mastery", "common", OrbType.Id.ARMOR, 12, "mastery_armor"),
			_entry_factory.make_mastery_card("gold_mastery", "Gold Mastery", "uncommon", OrbType.Id.GOLD, 16, "mastery_gold", 2),
		],
		TREASURE_CHESTS:
		[
			{
				"id": "elemental_treasure_chest",
				"display_name": "Elemental Chest",
				"description": "Choose 1 of 3 elemental-focused treasures.",
				"icon_key": "treasure_chest_elemental",
				"rarity": "common",
				"target_orb_id": -1,
				"option_count": 3,
				"base_price": 9,
				"min_level": 1,
				"max_level": 3,
				"effects": [],
			},
			{
				"id": "fire_treasure_chest",
				"display_name": "Fire Chest",
				"description": "Choose 1 of 3 Fire-aligned treasures.",
				"icon_key": "treasure_chest_fire",
				"rarity": "common",
				"target_orb_id": OrbType.Id.FIRE,
				"option_count": 3,
				"base_price": 10,
				"min_level": 1,
				"max_level": 3,
				"effects": [],
			},
		],
		RELICS:
		[
			(
				_entry_factory
				. make_relic(
					"deep_pockets",
					"Deep Pockets",
					"rare",
					24,
					"Gold orb value +2 and +2 bonus gold on gold matches.",
					"relic_deep_pockets",
					{
						"orb_bonus_by_id": {OrbType.Id.GOLD: 2},
						"flat_gold_bonus": 2,
					}
				)
			),
			_entry_factory.make_relic(
				"stalwart_mantle", "Stalwart Mantle", "rare", 24, "Gain +6 armor at turn start.", "relic_stalwart_mantle", {"start_turn_armor": 6}
			),
			(
				_entry_factory
				. make_relic(
					"golden_idol",
					"Golden Idol",
					"rare",
					25,
					"Combo multiplier x1.20 and +2 bonus gold on gold matches.",
					"relic_golden_idol",
					{
						"combo_multiplier_mult": 1.20,
						"flat_gold_bonus": 2,
					}
				)
			),
			(
				_entry_factory
				. make_relic(
					"crown_of_chains",
					"Crown of Chains",
					"rare",
					25,
					"Combo count +3 and +5 flat elemental damage each turn.",
					"relic_crown_of_chains",
					{
						"combo_flat_bonus": 3,
						"flat_damage_bonus": 5,
					}
				)
			),
			(
				_entry_factory
				. make_relic(
					"merchant_compass",
					"Merchant Compass",
					"rare",
					24,
					"+1 bonus gold and +2 bonus healing when matching gold/hearts.",
					"relic_merchant_compass",
					{
						"flat_gold_bonus": 1,
						"flat_heal_bonus": 2,
					}
				)
			),
		],
		ENEMIES:
		[
			(
				_entry_factory
				. make_enemy(
					"striker",
					"Striker",
					1,
					76,
					[
						{"type": 0, "attack": 12, "block": 0, "label": "Slash 12"},
						{"type": 2, "attack": 8, "block": 4, "label": "Shield Bash 8 + Guard 4"},
						{"type": 0, "attack": 13, "block": 0, "label": "Heavy Slash 13"},
					]
				)
			),
			(
				_entry_factory
				. make_enemy(
					"defender",
					"Defender",
					1,
					82,
					[
						{"type": 1, "attack": 0, "block": 10, "label": "Fortify 10"},
						{"type": 2, "attack": 10, "block": 6, "label": "Counter 10 + Guard 6"},
						{"type": 0, "attack": 11, "block": 0, "label": "Crush 11"},
					]
				)
			),
			(
				_entry_factory
				. make_enemy(
					"charger",
					"Charger",
					2,
					98,
					[
						{"type": 0, "attack": 16, "block": 0, "label": "Pierce 16"},
						{"type": 2, "attack": 10, "block": 8, "label": "Brace 8 + Jab 10"},
						{"type": 0, "attack": 14, "block": 0, "label": "Thrust 14"},
					]
				)
			),
		],
		BOSSES:
		[
			(
				_entry_factory
				. make_boss(
					"iron_gate",
					"Iron Gate",
					1,
					142,
					[
						{"type": 1, "attack": 0, "block": 16, "label": "Fortress Stance 16"},
						{"type": 0, "attack": 20, "block": 0, "label": "Gate Slam 20"},
						{"type": 2, "attack": 14, "block": 10, "label": "Wall Bash 14 + Guard 10"},
					]
				)
			),
			(
				_entry_factory
				. make_boss(
					"burning_knight",
					"Burning Knight",
					2,
					158,
					[
						{"type": 0, "attack": 21, "block": 0, "label": "Inferno Cleave 21"},
						{"type": 2, "attack": 15, "block": 10, "label": "Blazing Guard 10 + Slash 15"},
						{"type": 0, "attack": 19, "block": 0, "label": "Scorching Lunge 19"},
					]
				)
			),
			(
				_entry_factory
				. make_boss(
					"prism_warden",
					"Prism Warden",
					3,
					176,
					[
						{"type": 1, "attack": 0, "block": 18, "label": "Prism Shield 18"},
						{"type": 0, "attack": 24, "block": 0, "label": "Spectrum Beam 24"},
						{"type": 2, "attack": 16, "block": 12, "label": "Refraction 12 + Burst 16"},
					]
				)
			),
		],
	}
