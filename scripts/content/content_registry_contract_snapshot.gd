extends RefCounted
class_name ContentRegistryContractSnapshot


func snapshot() -> Dictionary:
	var contract := {
		"content_source": "dictionary_backed_default_content",
		"content_model": "collection_dictionary_indexed_by_entry_id",
		"collections":
		{
			"equipment":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields":
				[
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
			"consumables":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "convert_count"],
			},
			"mastery_cards":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "amount"],
			},
			"treasure_chests":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "target_orb_id", "base_price", "min_level", "max_level", "option_count"],
			},
			"relics":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["rarity", "base_price", "min_level", "max_level", "combat_modifiers"],
			},
			"enemies":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["dungeon_level", "max_hp", "is_boss", "intent_cycle"],
			},
			"bosses":
			{
				"required_fields": ["id", "display_name", "description", "icon_key", "effects"],
				"common_optional_fields": ["dungeon_level", "max_hp", "is_boss", "intent_cycle"],
			},
		},
		"validation_ownership":
		{
			"entry_validation_method": "validate_player_state_content",
			"effect_hook_validation_owner": "EffectHooks.is_valid_hook",
		},
		"shop_contract_ownership":
		{
			"shop_pool_owner": "ContentRegistry",
			"shop_item_pool_method": "shop_item_pool",
			"shop_relic_pool_method": "shop_relic_pool",
			"shop_pricing_owner": "ContentRegistry",
			"shop_pricing_method": "shop_pricing_config",
		},
		"future_migration_note": "AR-07 contract snapshot: content remains dictionary-backed until a later data-source migration.",
	}
	return contract.duplicate(true)
