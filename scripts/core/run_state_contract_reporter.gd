extends RefCounted
class_name RunStateContractReporter

var _owner


func _init(owner) -> void:
	_owner = owner


func run_contract_snapshot() -> Dictionary:
	var snapshot := {
		"run_state_owned_fields":
		[
			"run_active",
			"run_victory",
			"run_gold",
			"run_score",
			"dungeon_level",
			"current_step_key",
			"enemies_defeated",
			"bosses_defeated",
			"total_gold_earned",
			"_relic_offer_ids_by_level",
			"_current_encounter",
			"_boss_relic_reward_options",
			"_boss_reward_claimed_relic_id",
			"_run_summary",
			"_balance_manager",
		],
		"scene_route_constants":
		{
			"SCENE_MAIN": _owner.SCENE_MAIN,
			"SCENE_COMBAT": _owner.SCENE_COMBAT,
			"SCENE_SHOP": _owner.SCENE_SHOP,
			"SCENE_RUN_SUMMARY": _owner.SCENE_RUN_SUMMARY,
		},
		"level_sequence": _owner.LEVEL_SEQUENCE.duplicate(),
		"public_transition_action_api":
		[
			"start_new_run",
			"skip_to_fight",
			"mark_fight_victory",
			"mark_player_defeated",
			"advance_after_shop",
			"advance_after_boss_reward",
			"claim_boss_relic_reward",
			"skip_boss_relic_reward",
			"next_scene_path",
			"run_summary_snapshot",
			"run_log_snapshot",
			"run_log_export_json",
			"run_log_export_text",
			"run_log_export_html",
			"run_log_last_export_snapshot",
			"run_log_last_export_paths",
			"log_turn_result",
			"prototype_balance_levers_snapshot",
			"set_prototype_balance_levers",
			"reset_prototype_balance_levers",
			"prototype_fight_gold_reward_for",
			"current_shop_ordinal_in_level",
			"finish_tutorial_guidance",
			"profile_snapshot",
			"reset_profile",
			"create_default_profile",
			"meta_profile_snapshot",
			"is_equipment_unlocked",
			"unlock_equipment",
			"claim_equipment_unlock",
			"consume_recent_equipment_unlocks",
			"add_total_score",
		],
		"content_dependency":
		{
			"content_registry_owner": "ContentRegistry",
			"content_registry_provider": "ensure_content_registry",
			"content_validation_method": "validate_player_state_content",
			"combat_modifier_content_access": ["current_combat_modifiers", "ensure_content_registry"],
			"shop_content_access": ["open_shop_for_current_level", "reroll_shop_items", "buy_shop_offer"],
		},
		"compatibility_note": "AR-07 contract snapshot only; no routing, transition, resolver, summary, or presentation behavior changes.",
	}
	return snapshot.duplicate(true)
