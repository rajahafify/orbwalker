extends RefCounted
class_name ContentRegistryEntryFactory


func make_equipment(
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


func make_consumable(
	item_id: String, display_name: String, rarity: String, target_orb_id: int, base_price: int, convert_count: int, icon_key: String, min_level: int = 1
) -> Dictionary:
	return {
		"id": item_id,
		"display_name": display_name,
		"description":
		(
			"Convert %d random non-%s orbs into %s orbs."
			% [
				convert_count,
				OrbType.display_name(target_orb_id),
				OrbType.display_name(target_orb_id),
			]
		),
		"icon_key": icon_key,
		"rarity": rarity,
		"target_orb_id": target_orb_id,
		"base_price": base_price,
		"convert_count": convert_count,
		"min_level": min_level,
		"max_level": 3,
		"effects":
		[
			{
				"hook": EffectHooks.ON_CONSUMABLE_USED,
				"operation": "convert_random_orbs",
				"value":
				{
					"target_orb_id": target_orb_id,
					"count": convert_count,
				},
			},
		],
	}


func make_mastery_card(
	card_id: String, display_name: String, rarity: String, target_orb_id: int, base_price: int, icon_key: String, min_level: int = 1
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


func make_relic(
	relic_id: String, display_name: String, rarity: String, base_price: int, description: String, icon_key: String, combat_modifiers: Dictionary
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


func make_enemy(
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


func make_boss(
	boss_id: String,
	display_name: String,
	dungeon_level: int,
	max_hp: int,
	intent_cycle: Array,
) -> Dictionary:
	var entry := make_enemy(boss_id, display_name, dungeon_level, max_hp, intent_cycle)
	entry["description"] = "Dungeon level %d boss." % dungeon_level
	entry["icon_key"] = "boss_%s" % boss_id
	entry["is_boss"] = true
	return entry
