extends RefCounted
class_name ContentRegistry

const EQUIPMENT := "equipment"
const CONSUMABLES := "consumables"
const MASTERY_CARDS := "mastery_cards"
const TREASURE_CHESTS := "treasure_chests"
const RELICS := "relics"
const ENEMIES := "enemies"
const BOSSES := "bosses"
const SHOP_MULTIPLIER_MIN := 0.1
const REROLL_COST_CEILING_DEFAULT := 30

var _player_state_content: Dictionary = {}
var _index := {}
var _shop_pricing_config := {
	"rarity_base": {
		"common": 10,
		"uncommon": 16,
		"rare": 24,
	},
	"level_step": 2,
	"reroll_base": 1,
	"reroll_step": 1,
	"reroll_max": REROLL_COST_CEILING_DEFAULT,
}
var _prototype_balance_levers := {
	"shop_price_multiplier": 1.0,
	"reroll_cost_multiplier": 1.0,
}


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
	var item_id := String(item.get("id", ""))
	if item_id == "":
		return false
	if run_state == null:
		return true
	if not run_state.has_method("is_equipment_unlocked"):
		return true
	return bool(run_state.is_equipment_unlocked(item_id))


func shop_relic_pool(dungeon_level: int) -> Array[Dictionary]:
	var level := maxi(1, dungeon_level)
	var pool: Array[Dictionary] = []
	for relic in list_relics():
		if _is_level_allowed(relic, level):
			pool.append(relic)
	return pool


func shop_pricing_config() -> Dictionary:
	var pricing := _shop_pricing_config.duplicate(true)
	var price_multiplier := maxf(
		SHOP_MULTIPLIER_MIN,
		float(_prototype_balance_levers.get("shop_price_multiplier", 1.0))
	)
	var reroll_multiplier := maxf(
		SHOP_MULTIPLIER_MIN,
		float(_prototype_balance_levers.get("reroll_cost_multiplier", 1.0))
	)
	pricing["prototype_balance"] = {
		"temporary": true,
		"shop_price_multiplier": price_multiplier,
		"reroll_cost_multiplier": reroll_multiplier,
	}
	pricing["reroll_max"] = maxi(
		int(pricing.get("reroll_base", 1)),
		maxi(1, int(pricing.get("reroll_max", REROLL_COST_CEILING_DEFAULT)))
	)
	return pricing


func set_prototype_balance_levers(levers: Dictionary) -> void:
	_prototype_balance_levers["shop_price_multiplier"] = maxf(
		SHOP_MULTIPLIER_MIN,
		float(levers.get("shop_price_multiplier", _prototype_balance_levers.get("shop_price_multiplier", 1.0)))
	)
	_prototype_balance_levers["reroll_cost_multiplier"] = maxf(
		SHOP_MULTIPLIER_MIN,
		float(levers.get("reroll_cost_multiplier", _prototype_balance_levers.get("reroll_cost_multiplier", 1.0)))
	)


func content_contract_snapshot() -> Dictionary:
	var snapshot := {
		"content_source": "dictionary_backed_default_content",
		"content_model": "collection_dictionary_indexed_by_entry_id",
		"collections": {
			EQUIPMENT: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": [
					"rarity",
					"rarity_color",
					"family_id",
					"next_tier_item_id",
					"unlock_cost",
					"target_orb_id",
					"base_price",
					"min_level",
					"max_level",
					"combat_modifiers",
				],
			},
			CONSUMABLES: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "convert_count"],
			},
			MASTERY_CARDS: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "amount"],
			},
			TREASURE_CHESTS: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "option_count"],
			},
			RELICS: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "base_price", "min_level", "max_level", "combat_modifiers"],
			},
			ENEMIES: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["dungeon_level", "max_hp", "is_boss", "intent_cycle"],
			},
			BOSSES: {
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["dungeon_level", "max_hp", "is_boss", "intent_cycle"],
			},
		},
		"validation_ownership": {
			"entry_validation_method": "validate_player_state_content",
			"effect_hook_validation_owner": "EffectHooks.is_valid_hook",
		},
		"shop_contract_ownership": {
			"shop_pool_owner": "ContentRegistry",
			"shop_item_pool_method": "shop_item_pool",
			"shop_relic_pool_method": "shop_relic_pool",
			"shop_pricing_owner": "ContentRegistry",
			"shop_pricing_method": "shop_pricing_config",
		},
		"future_migration_note": "AR-07 contract snapshot: content remains dictionary-backed until a later data-source migration.",
	}
	return snapshot.duplicate(true)


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
			var item_id := String(entry.get("id", ""))
			if item_id == "":
				errors.append(_validation_error("<missing_id>", "%s entry missing id" % collection_name))
				continue
			if seen_ids.has(item_id):
				errors.append(_validation_error(item_id, "duplicate_id"))
			else:
				seen_ids[item_id] = true

			if String(entry.get("display_name", "")).strip_edges() == "":
				errors.append(_validation_error(item_id, "missing_display_name"))
			if String(entry.get("description", "")).strip_edges() == "":
				errors.append(_validation_error(item_id, "missing_description"))
			if String(entry.get("icon_key", "")).strip_edges() == "":
				errors.append(_validation_error(item_id, "missing_icon_key"))
			if collection_name == EQUIPMENT:
				var next_tier_item_id := String(entry.get("next_tier_item_id", ""))
				if next_tier_item_id != "" and not known_equipment_ids.has(next_tier_item_id):
					errors.append(_validation_error(item_id, "missing_next_tier_item_id:%s" % next_tier_item_id))

			var effects: Array = entry.get("effects", [])
			for raw_effect in effects:
				if not (raw_effect is Dictionary):
					errors.append(_validation_error(item_id, "effect_entry_not_dictionary"))
					continue
				var effect = raw_effect
				var hook_name := String(effect.get("hook", ""))
				if hook_name == "":
					errors.append(_validation_error(item_id, "missing_effect_hook"))
					continue
				if not EffectHooks.is_valid_hook(hook_name):
					errors.append(_validation_error(item_id, "invalid_effect_hook:%s" % hook_name))

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
			var item_id := String(entry.get("id", ""))
			if item_id == "":
				continue
			_index[collection_name][item_id] = entry.duplicate(true)


func _get_indexed(collection_name: String, item_id: String) -> Dictionary:
	var collection_index: Dictionary = _index.get(collection_name, {})
	if not collection_index.has(item_id):
		return {}
	return Dictionary(collection_index[item_id]).duplicate(true)


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
		EQUIPMENT: [
			_make_equipment(
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
			_make_equipment(
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
			_make_equipment(
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
			_make_equipment(
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
			_make_equipment(
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
			_make_equipment(
				"shortsword_knight",
				"Knight Shortsword",
				"uncommon",
				"blue",
				"shortsword",
				OrbType.Id.FIRE,
				18,
				"Deal +4 flat elemental damage each turn.",
				"equipment_twin_blades",
				{"flat_damage_bonus": 4},
				"shortsword_royal",
				100,
				2
			),
			_make_equipment(
				"buckler_iron",
				"Iron Buckler",
				"uncommon",
				"blue",
				"buckler",
				OrbType.Id.ARMOR,
				19,
				"Gain +4 armor at turn start.",
				"equipment_tower_shield",
				{"start_turn_armor": 4},
				"buckler_guardian",
				100,
				2
			),
			_make_equipment(
				"coin_purse_merchant",
				"Merchant Coin Purse",
				"uncommon",
				"blue",
				"coin_purse",
				OrbType.Id.GOLD,
				17,
				"Gain +2 bonus gold when gold orbs resolve.",
				"equipment_merchant_scales",
				{"flat_gold_bonus": 2},
				"coin_purse_noble",
				100,
				2
			),
			_make_equipment(
				"healing_charm_blessed",
				"Blessed Healing Charm",
				"uncommon",
				"blue",
				"healing_charm",
				OrbType.Id.HEART,
				17,
				"Gain +4 bonus healing when heart orbs resolve.",
				"equipment_hearth_amulet",
				{"flat_heal_bonus": 4},
				"healing_charm_saint",
				100,
				2
			),
			_make_equipment(
				"leather_gloves_duelist",
				"Duelist Gloves",
				"uncommon",
				"blue",
				"leather_gloves",
				-1,
				18,
				"Combo count is treated as +2 for damage scaling.",
				"equipment_war_banner",
				{"combo_flat_bonus": 2},
				"leather_gloves_blademaster",
				100,
				2
			),
			_make_equipment(
				"shortsword_royal",
				"Royal Shortsword",
				"rare",
				"purple",
				"shortsword",
				OrbType.Id.FIRE,
				27,
				"Deal +6 flat elemental damage each turn.",
				"equipment_ruby_brooch",
				{"flat_damage_bonus": 6},
				"",
				300,
				3
			),
			_make_equipment(
				"buckler_guardian",
				"Guardian Buckler",
				"rare",
				"purple",
				"buckler",
				OrbType.Id.ARMOR,
				29,
				"Gain +6 armor at turn start.",
				"equipment_champion_plate",
				{"start_turn_armor": 6},
				"",
				300,
				3
			),
			_make_equipment(
				"coin_purse_noble",
				"Noble Coin Purse",
				"rare",
				"purple",
				"coin_purse",
				OrbType.Id.GOLD,
				27,
				"Gain +3 bonus gold when gold orbs resolve.",
				"equipment_royal_seal",
				{"flat_gold_bonus": 3},
				"",
				300,
				3
			),
			_make_equipment(
				"healing_charm_saint",
				"Saint's Healing Charm",
				"rare",
				"purple",
				"healing_charm",
				OrbType.Id.HEART,
				27,
				"Gain +6 bonus healing when heart orbs resolve.",
				"equipment_mirror_charm",
				{"flat_heal_bonus": 6},
				"",
				300,
				3
			),
			_make_equipment(
				"leather_gloves_blademaster",
				"Blademaster Gloves",
				"rare",
				"purple",
				"leather_gloves",
				-1,
				28,
				"Combo count is treated as +3 for damage scaling.",
				"equipment_battle_drum",
				{"combo_flat_bonus": 3},
				"",
				300,
				3
			),
		],
		CONSUMABLES: [
			_make_consumable("fire_scroll", "Fire Scroll", "common", OrbType.Id.FIRE, 9, 3, "consumable_fire_scroll"),
			_make_consumable("ice_scroll", "Ice Scroll", "common", OrbType.Id.ICE, 9, 3, "consumable_ice_scroll"),
			_make_consumable("earth_scroll", "Earth Scroll", "common", OrbType.Id.EARTH, 9, 3, "consumable_earth_scroll"),
			_make_consumable("heart_scroll", "Heart Scroll", "common", OrbType.Id.HEART, 9, 3, "consumable_heart_scroll"),
			_make_consumable("armor_scroll", "Armor Scroll", "common", OrbType.Id.ARMOR, 9, 3, "consumable_armor_scroll"),
			_make_consumable("gold_scroll", "Gold Scroll", "uncommon", OrbType.Id.GOLD, 13, 3, "consumable_gold_scroll", 2),
		],
		MASTERY_CARDS: [
			_make_mastery_card("fire_mastery", "Fire Mastery", "common", OrbType.Id.FIRE, 11, "mastery_fire"),
			_make_mastery_card("ice_mastery", "Ice Mastery", "common", OrbType.Id.ICE, 11, "mastery_ice"),
			_make_mastery_card("earth_mastery", "Earth Mastery", "common", OrbType.Id.EARTH, 11, "mastery_earth"),
			_make_mastery_card("heart_mastery", "Heart Mastery", "common", OrbType.Id.HEART, 12, "mastery_heart"),
			_make_mastery_card("armor_mastery", "Armor Mastery", "common", OrbType.Id.ARMOR, 12, "mastery_armor"),
			_make_mastery_card("gold_mastery", "Gold Mastery", "uncommon", OrbType.Id.GOLD, 16, "mastery_gold", 2),
		],
		TREASURE_CHESTS: [
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
		RELICS: [
			_make_relic(
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
			),
			_make_relic(
				"stalwart_mantle",
				"Stalwart Mantle",
				"rare",
				24,
				"Gain +6 armor at turn start.",
				"relic_stalwart_mantle",
				{"start_turn_armor": 6}
			),
			_make_relic(
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
			),
			_make_relic(
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
			),
			_make_relic(
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
			),
		],
		ENEMIES: [
			_make_enemy(
				"striker",
				"Striker",
				1,
				76,
				[
					{"type": 0, "attack": 12, "block": 0, "label": "Slash 12"},
					{"type": 2, "attack": 8, "block": 4, "label": "Shield Bash 8 + Guard 4"},
					{"type": 0, "attack": 13, "block": 0, "label": "Heavy Slash 13"},
				]
			),
			_make_enemy(
				"defender",
				"Defender",
				1,
				82,
				[
					{"type": 1, "attack": 0, "block": 10, "label": "Fortify 10"},
					{"type": 2, "attack": 10, "block": 6, "label": "Counter 10 + Guard 6"},
					{"type": 0, "attack": 11, "block": 0, "label": "Crush 11"},
				]
			),
			_make_enemy(
				"charger",
				"Charger",
				2,
				98,
				[
					{"type": 0, "attack": 16, "block": 0, "label": "Pierce 16"},
					{"type": 2, "attack": 10, "block": 8, "label": "Brace 8 + Jab 10"},
					{"type": 0, "attack": 14, "block": 0, "label": "Thrust 14"},
				]
			),
		],
		BOSSES: [
			_make_boss(
				"iron_gate",
				"Iron Gate",
				1,
				142,
				[
					{"type": 1, "attack": 0, "block": 16, "label": "Fortress Stance 16"},
					{"type": 0, "attack": 20, "block": 0, "label": "Gate Slam 20"},
					{"type": 2, "attack": 14, "block": 10, "label": "Wall Bash 14 + Guard 10"},
				]
			),
			_make_boss(
				"burning_knight",
				"Burning Knight",
				2,
				158,
				[
					{"type": 0, "attack": 21, "block": 0, "label": "Inferno Cleave 21"},
					{"type": 2, "attack": 15, "block": 10, "label": "Blazing Guard 10 + Slash 15"},
					{"type": 0, "attack": 19, "block": 0, "label": "Scorching Lunge 19"},
				]
			),
			_make_boss(
				"prism_warden",
				"Prism Warden",
				3,
				176,
				[
					{"type": 1, "attack": 0, "block": 18, "label": "Prism Shield 18"},
					{"type": 0, "attack": 24, "block": 0, "label": "Spectrum Beam 24"},
					{"type": 2, "attack": 16, "block": 12, "label": "Refraction 12 + Burst 16"},
				]
			),
		],
	}


func _make_equipment(
	item_id: String,
	display_name: String,
	rarity: String,
	rarity_color: String,
	family_id: String,
	target_orb_id: int,
	base_price: int,
	description: String,
	icon_key: String,
	combat_modifiers: Dictionary,
	next_tier_item_id: String = "",
	unlock_cost: int = 0,
	min_level: int = 1
) -> Dictionary:
	return {
		"id": item_id,
		"display_name": display_name,
		"description": description,
		"icon_key": icon_key,
		"rarity": rarity,
		"rarity_color": rarity_color,
		"family_id": family_id,
		"next_tier_item_id": next_tier_item_id,
		"unlock_cost": maxi(0, unlock_cost),
		"target_orb_id": target_orb_id,
		"base_price": base_price,
		"sell_value": base_price,
		"min_level": min_level,
		"max_level": 3,
		"combat_modifiers": combat_modifiers,
		"effects": [],
	}


func _make_consumable(
	item_id: String,
	display_name: String,
	rarity: String,
	target_orb_id: int,
	base_price: int,
	convert_count: int,
	icon_key: String,
	min_level: int = 1
) -> Dictionary:
	return {
		"id": item_id,
		"display_name": display_name,
		"description": "Convert %d random non-%s orbs into %s orbs." % [
			convert_count,
			OrbType.display_name(target_orb_id),
			OrbType.display_name(target_orb_id),
		],
		"icon_key": icon_key,
		"rarity": rarity,
		"target_orb_id": target_orb_id,
		"base_price": base_price,
		"convert_count": convert_count,
		"min_level": min_level,
		"max_level": 3,
		"effects": [
			{
				"hook": EffectHooks.ON_CONSUMABLE_USED,
				"operation": "convert_random_orbs",
				"value": {
					"target_orb_id": target_orb_id,
					"count": convert_count,
				},
			},
		],
	}


func _make_mastery_card(
	card_id: String,
	display_name: String,
	rarity: String,
	target_orb_id: int,
	base_price: int,
	icon_key: String,
	min_level: int = 1
) -> Dictionary:
	return {
		"id": card_id,
		"display_name": display_name,
		"description": "Increase %s mastery by 1 (max 5)." % OrbType.display_name(target_orb_id),
		"icon_key": icon_key,
		"rarity": rarity,
		"target_orb_id": target_orb_id,
		"amount": 1,
		"base_price": base_price,
		"min_level": min_level,
		"max_level": 3,
		"effects": [],
	}


func _make_relic(
	relic_id: String,
	display_name: String,
	rarity: String,
	base_price: int,
	description: String,
	icon_key: String,
	combat_modifiers: Dictionary
) -> Dictionary:
	return {
		"id": relic_id,
		"display_name": display_name,
		"description": description,
		"icon_key": icon_key,
		"rarity": rarity,
		"base_price": base_price,
		"min_level": 1,
		"max_level": 3,
		"combat_modifiers": combat_modifiers,
		"effects": [],
	}


func _make_enemy(
	enemy_id: String,
	display_name: String,
	dungeon_level: int,
	max_hp: int,
	intent_cycle: Array,
) -> Dictionary:
	return {
		"id": enemy_id,
		"display_name": display_name,
		"description": "Dungeon level %d normal enemy." % dungeon_level,
		"icon_key": "enemy_%s" % enemy_id,
		"dungeon_level": dungeon_level,
		"max_hp": max_hp,
		"is_boss": false,
		"intent_cycle": intent_cycle,
		"effects": [],
	}


func _make_boss(
	boss_id: String,
	display_name: String,
	dungeon_level: int,
	max_hp: int,
	intent_cycle: Array,
) -> Dictionary:
	return {
		"id": boss_id,
		"display_name": display_name,
		"description": "Dungeon level %d boss." % dungeon_level,
		"icon_key": "boss_%s" % boss_id,
		"dungeon_level": dungeon_level,
		"max_hp": max_hp,
		"is_boss": true,
		"intent_cycle": intent_cycle,
		"effects": [],
	}
