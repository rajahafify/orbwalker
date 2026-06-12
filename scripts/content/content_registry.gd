extends RefCounted
class_name ContentRegistry

const CONTENT_REGISTRY_ENTRY_FACTORY_SCRIPT := preload("res://scripts/content/content_registry_entry_factory.gd")
const CONTENT_REGISTRY_SHOP_PRICING_SCRIPT := preload("res://scripts/content/content_registry_shop_pricing.gd")
const CONTENT_REGISTRY_CONTRACT_SNAPSHOT_SCRIPT := preload("res://scripts/content/content_registry_contract_snapshot.gd")

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const MASTERY_CARDS := "mastery_cards"
const TREASURE_CHESTS := "treasure_chests"
const RELICS := "relics"
const ENEMIES := "enemies"
const BOSSES := "bosses"

var _player_state_content: Dictionary = {}
var _index := {}
var _entry_factory: RefCounted = CONTENT_REGISTRY_ENTRY_FACTORY_SCRIPT.new()
var _shop_pricing: RefCounted = CONTENT_REGISTRY_SHOP_PRICING_SCRIPT.new()
var _contract_snapshot: RefCounted = CONTENT_REGISTRY_CONTRACT_SNAPSHOT_SCRIPT.new()


func _init() -> void:
	_player_state_content = _build_default_content()
	_rebuild_index()


func set_player_state_content(content: Dictionary) -> void:
	_player_state_content = content.duplicate(true)
	_rebuild_index()


func get_equipment(item_id: String) -> Dictionary:
	return _get_indexed(EQUIPMENT, item_id)


func get_consumable(consumable_id: String) -> Dictionary:
	return _get_indexed(CONSUMABLES, consumable_id)


func get_mastery_card(card_id: String) -> Dictionary:
	return _get_indexed(MASTERY_CARDS, card_id)


func get_treasure_chest(treasure_chest_id: String) -> Dictionary:
	return _get_indexed(TREASURE_CHESTS, treasure_chest_id)


func get_relic(relic_id: String) -> Dictionary:
	return _get_indexed(RELICS, relic_id)


func list_equipment() -> Array[Dictionary]:
	return _collection_index_values(EQUIPMENT)


func list_consumables() -> Array[Dictionary]:
	return _collection_index_values(CONSUMABLES)


func list_mastery_cards() -> Array[Dictionary]:
	return _collection_index_values(MASTERY_CARDS)


func list_treasure_chests() -> Array[Dictionary]:
	return _collection_index_values(TREASURE_CHESTS)


func list_relics() -> Array[Dictionary]:
	return _collection_index_values(RELICS)


func list_enemies() -> Array[Dictionary]:
	return _collection_index_values(ENEMIES)


func list_bosses() -> Array[Dictionary]:
	return _collection_index_values(BOSSES)


func shop_item_pool(dungeon_level: int, run_state: Variant = null) -> Array[Dictionary]:
	var level := maxi(1, dungeon_level)
	var pool: Array[Dictionary] = []
	for item in list_equipment():
		if _is_level_allowed(item, level) and _is_equipment_available_for_run(item, run_state):
			pool.append({"type": "equipment", "id": String(item.get("id", ""))})
	for item in list_consumables():
		if _is_level_allowed(item, level):
			pool.append({"type": "consumable", "id": String(item.get("id", ""))})
	for item in list_mastery_cards():
		if _is_level_allowed(item, level):
			pool.append({"type": "mastery_card", "id": String(item.get("id", ""))})
	for item in list_treasure_chests():
		if _is_level_allowed(item, level):
			pool.append({"type": "treasure_chest", "id": String(item.get("id", ""))})
	return pool


func _is_equipment_available_for_run(item: Dictionary, run_state: Variant) -> bool:
	var equipment_id := String(item.get("id", ""))
	if equipment_id == "":
		return false
	if run_state == null:
		return true
	if not run_state.has_method("is_equipment_unlocked"):
		return true
	return bool(run_state.is_equipment_unlocked(equipment_id))


func shop_relic_pool(dungeon_level: int) -> Array[Dictionary]:
	var level := maxi(1, dungeon_level)
	var pool: Array[Dictionary] = []
	for relic in list_relics():
		if _is_level_allowed(relic, level):
			pool.append(relic)
	return pool


func shop_pricing_config() -> Dictionary:
	return _shop_pricing.shop_pricing_config()


func set_prototype_balance_levers(levers: Dictionary) -> void:
	_shop_pricing.set_prototype_balance_levers(levers)


func content_contract_snapshot() -> Dictionary:
	return _contract_snapshot.snapshot()


func validate_player_state_content() -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var known_equipment_ids := {}
	var equipment_entries: Array = _player_state_content.get(EQUIPMENT, [])
	for raw_equipment_entry in equipment_entries:
		if not (raw_equipment_entry is Dictionary):
			continue
		var equipment_entry = raw_equipment_entry
		var equipment_id := String(equipment_entry.get("id", ""))
		if equipment_id != "":
			known_equipment_ids[equipment_id] = true

	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, TREASURE_CHESTS, RELICS, ENEMIES, BOSSES]:
		var entries: Array = _player_state_content.get(collection_name, [])
		var seen_ids := {}
		for raw_entry in entries:
			if not (raw_entry is Dictionary):
				errors.append(_validation_error("<invalid_entry>", "%s entry is not a Dictionary" % collection_name))
				continue
			var entry = raw_entry
			var entry_id := String(entry.get("id", ""))
			if entry_id == "":
				errors.append(_validation_error("<missing_id>", "%s entry missing id" % collection_name))
				continue
			if seen_ids.has(entry_id):
				errors.append(_validation_error(entry_id, "duplicate_id"))
			else:
				seen_ids[entry_id] = true

			if String(entry.get("display_name", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_display_name"))
			if String(entry.get("description", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_description"))
			if String(entry.get("icon_key", "")).strip_edges() == "":
				errors.append(_validation_error(entry_id, "missing_icon_key"))
			if collection_name == EQUIPMENT:
				var next_tier_item_id := String(entry.get("next_tier_item_id", ""))
				if next_tier_item_id != "" and not known_equipment_ids.has(next_tier_item_id):
					errors.append(_validation_error(entry_id, "missing_next_tier_item_id:%s" % next_tier_item_id))

			var effects: Array = entry.get("effects", [])
			for raw_effect in effects:
				if not (raw_effect is Dictionary):
					errors.append(_validation_error(entry_id, "effect_entry_not_dictionary"))
					continue
				var effect = raw_effect
				var hook_name := String(effect.get("hook", ""))
				if hook_name == "":
					errors.append(_validation_error(entry_id, "missing_effect_hook"))
					continue
				if not EffectHooks.is_valid_hook(hook_name):
					errors.append(_validation_error(entry_id, "invalid_effect_hook:%s" % hook_name))

	return errors


func _rebuild_index() -> void:
	_index.clear()
	for collection_name in [EQUIPMENT, CONSUMABLES, MASTERY_CARDS, TREASURE_CHESTS, RELICS, ENEMIES, BOSSES]:
		_index[collection_name] = {}
		var entries: Array = _player_state_content.get(collection_name, [])
		for raw_entry in entries:
			if not (raw_entry is Dictionary):
				continue
			var entry = raw_entry
			var indexed_entry_id := String(entry.get("id", ""))
			if indexed_entry_id == "":
				continue
			_index[collection_name][indexed_entry_id] = entry.duplicate(true)


func _get_indexed(collection_name: String, lookup_entry_id: String) -> Dictionary:
	var collection_index: Dictionary = _index.get(collection_name, {})
	if not collection_index.has(lookup_entry_id):
		return {}
	return Dictionary(collection_index[lookup_entry_id]).duplicate(true)


func _collection_index_values(collection_name: String) -> Array[Dictionary]:
	var values: Array[Dictionary] = []
	var collection_index: Dictionary = _index.get(collection_name, {})
	for value in collection_index.values():
		values.append(Dictionary(value).duplicate(true))
	return values


func _is_level_allowed(entry: Dictionary, level: int) -> bool:
	var min_level := int(entry.get("min_level", 1))
	var max_level := int(entry.get("max_level", 999))
	return level >= min_level and level <= max_level


func _validation_error(item_id: String, reason: String) -> Dictionary:
	return {
		"item_id": item_id,
		"reason": reason,
	}


func _build_default_content() -> Dictionary:
	return {
		EQUIPMENT:
		[
			_entry_factory.make_equipment(
				"shortsword",
				"Iron Shortsword",
				"common",
				"white",
				"shortsword",
				OrbType.Id.FIRE,
				10,
				"Deal +2 flat elemental damage each turn.",
				"equipment_shortsword",
				{"flat_damage_bonus": 2},
				"shortsword_knight",
				0
			),
			_entry_factory.make_equipment(
				"buckler",
				"Wooden Buckler",
				"common",
				"white",
				"buckler",
				OrbType.Id.ARMOR,
				11,
				"Gain +2 armor at turn start.",
				"equipment_buckler",
				{"start_turn_armor": 2},
				"buckler_iron",
				0
			),
			_entry_factory.make_equipment(
				"coin_purse",
				"Worn Coin Purse",
				"common",
				"white",
				"coin_purse",
				OrbType.Id.GOLD,
				10,
				"Gain +1 bonus gold when gold orbs resolve.",
				"equipment_coin_purse",
				{"flat_gold_bonus": 1},
				"coin_purse_merchant",
				0
			),
			_entry_factory.make_equipment(
				"healing_charm",
				"Linen Healing Charm",
				"common",
				"white",
				"healing_charm",
				OrbType.Id.HEART,
				11,
				"Gain +2 bonus healing when heart orbs resolve.",
				"equipment_healing_charm",
				{"flat_heal_bonus": 2},
				"healing_charm_blessed",
				0
			),
			_entry_factory.make_equipment(
				"leather_gloves",
				"Leather Gloves",
				"common",
				"white",
				"leather_gloves",
				-1,
				11,
				"Combo count is treated as +1 for damage scaling.",
				"equipment_leather_gloves",
				{"combo_flat_bonus": 1},
				"leather_gloves_duelist",
				0
			),
			_entry_factory.make_equipment(
				"shortsword_knight",
				"Knight Shortsword",
				"uncommon",
				"blue",
				"shortsword",
				OrbType.Id.FIRE,
				18,
				"Deal +4 flat elemental damage each turn.",
				"equipment_shortsword_knight",
				{"flat_damage_bonus": 4},
				"shortsword_royal",
				100,
				2
			),
			_entry_factory.make_equipment(
				"buckler_iron",
				"Iron Buckler",
				"uncommon",
				"blue",
				"buckler",
				OrbType.Id.ARMOR,
				19,
				"Gain +4 armor at turn start.",
				"equipment_buckler_iron",
				{"start_turn_armor": 4},
				"buckler_guardian",
				100,
				2
			),
			_entry_factory.make_equipment(
				"coin_purse_merchant",
				"Merchant Coin Purse",
				"uncommon",
				"blue",
				"coin_purse",
				OrbType.Id.GOLD,
				17,
				"Gain +2 bonus gold when gold orbs resolve.",
				"equipment_coin_purse_merchant",
				{"flat_gold_bonus": 2},
				"coin_purse_noble",
				100,
				2
			),
			_entry_factory.make_equipment(
				"healing_charm_blessed",
				"Blessed Healing Charm",
				"uncommon",
				"blue",
				"healing_charm",
				OrbType.Id.HEART,
				17,
				"Gain +4 bonus healing when heart orbs resolve.",
				"equipment_healing_charm_blessed",
				{"flat_heal_bonus": 4},
				"healing_charm_saint",
				100,
				2
			),
			_entry_factory.make_equipment(
				"leather_gloves_duelist",
				"Duelist Gloves",
				"uncommon",
				"blue",
				"leather_gloves",
				-1,
				18,
				"Combo count is treated as +2 for damage scaling.",
				"equipment_leather_gloves_duelist",
				{"combo_flat_bonus": 2},
				"leather_gloves_blademaster",
				100,
				2
			),
			_entry_factory.make_equipment(
				"shortsword_royal",
				"Royal Shortsword",
				"rare",
				"purple",
				"shortsword",
				OrbType.Id.FIRE,
				27,
				"Deal +6 flat elemental damage each turn.",
				"equipment_shortsword_royal",
				{"flat_damage_bonus": 6},
				"",
				300,
				3
			),
			_entry_factory.make_equipment(
				"buckler_guardian",
				"Guardian Buckler",
				"rare",
				"purple",
				"buckler",
				OrbType.Id.ARMOR,
				29,
				"Gain +6 armor at turn start.",
				"equipment_buckler_guardian",
				{"start_turn_armor": 6},
				"",
				300,
				3
			),
			_entry_factory.make_equipment(
				"coin_purse_noble",
				"Noble Coin Purse",
				"rare",
				"purple",
				"coin_purse",
				OrbType.Id.GOLD,
				27,
				"Gain +3 bonus gold when gold orbs resolve.",
				"equipment_coin_purse_noble",
				{"flat_gold_bonus": 3},
				"",
				300,
				3
			),
			_entry_factory.make_equipment(
				"healing_charm_saint",
				"Saint's Healing Charm",
				"rare",
				"purple",
				"healing_charm",
				OrbType.Id.HEART,
				27,
				"Gain +6 bonus healing when heart orbs resolve.",
				"equipment_healing_charm_saint",
				{"flat_heal_bonus": 6},
				"",
				300,
				3
			),
			_entry_factory.make_equipment(
				"leather_gloves_blademaster",
				"Blademaster Gloves",
				"rare",
				"purple",
				"leather_gloves",
				-1,
				28,
				"Combo count is treated as +3 for damage scaling.",
				"equipment_leather_gloves_blademaster",
				{"combo_flat_bonus": 3},
				"",
				300,
				3
			),
		],
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
