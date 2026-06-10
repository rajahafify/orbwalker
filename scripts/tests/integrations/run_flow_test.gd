extends RefCounted
class_name RunFlowTest

const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const RUN_STATE_SCRIPT := preload("res://scripts/core/run_state.gd")
const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")


class FakeProfileRepository:
	extends ProfileRepository

	var save_count := 0

	func load_profile(profile: PlayerProfileState) -> Dictionary:
		if profile != null:
			profile.reset_to_default(1000)
		return {"ok": true, "source": "test_profile"}

	func save_profile(profile: PlayerProfileState) -> Dictionary:
		save_count += 1
		return {"ok": profile != null, "path": "memory://test_profile"}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("start_run_routes_to_first_combat", _test_start_run_routes_to_first_combat, failures)
	_run_case("combat_victory_routes_to_shop", _test_combat_victory_routes_to_shop, failures)
	_run_case("shop_buy_reroll_continue_routes_to_second_combat", _test_shop_buy_reroll_continue_routes_to_second_combat, failures)
	_run_case("boss_reward_routes_to_shop_after_claim", _test_boss_reward_routes_to_shop_after_claim, failures)
	_run_case("combat_defeat_routes_to_run_summary", _test_combat_defeat_routes_to_run_summary, failures)
	_run_case("tutorial_first_step_uses_scripted_encounter_and_shop_offer", _test_tutorial_first_step_uses_scripted_encounter_and_shop_offer, failures)

	return {
		"passed": failures.is_empty(),
		"total": 6,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_start_run_routes_to_first_combat() -> String:
	var run_state = _new_run_state()
	run_state.start_new_run()
	var encounter := Dictionary(run_state.current_encounter_snapshot())
	if not run_state.run_active:
		return _finish_flow_case(run_state, "Expected start_new_run to activate the run.")
	if run_state.current_step_key != "enemy_1":
		return _finish_flow_case(run_state, "Expected run to start at enemy_1.")
	if run_state.next_scene_path() != RUN_STATE_SCRIPT.SCENE_COMBAT:
		return _finish_flow_case(run_state, "Expected first run scene to be combat.")
	if encounter.is_empty() or String(encounter.get("step_key", "")) != "enemy_1":
		return _finish_flow_case(run_state, "Expected first encounter snapshot for enemy_1.")
	return _finish_flow_case(run_state, "")


func _test_combat_victory_routes_to_shop() -> String:
	var run_state = _new_run_state()
	run_state.start_new_run()
	var fight := _combat_for_current_encounter(run_state)
	var combat: CombatStateMachine = fight["combat"]
	var enemy: EnemyState = fight["enemy"]
	combat.begin_player_input()
	combat.resolve_player_turn(_lethal_resolve_result(enemy))
	if combat.phase != CombatStateMachine.Phase.VICTORY:
		return _finish_flow_case(run_state, "Expected simulated combat turn to reach Victory.")
	var gold_before := int(run_state.run_gold)
	var transition: Dictionary = run_state.mark_fight_victory()
	if not bool(transition.get("ok", false)):
		return _finish_flow_case(run_state, "Expected mark_fight_victory to succeed.")
	if run_state.current_step_key != "shop":
		return _finish_flow_case(run_state, "Expected victory to advance to first shop.")
	if String(transition.get("next_scene", "")) != RUN_STATE_SCRIPT.SCENE_SHOP:
		return _finish_flow_case(run_state, "Expected victory transition to route to shop.")
	if int(run_state.enemies_defeated) != 1:
		return _finish_flow_case(run_state, "Expected defeated enemy count to increment.")
	if int(run_state.run_gold) <= gold_before:
		return _finish_flow_case(run_state, "Expected fight victory to grant base gold.")
	return _finish_flow_case(run_state, "")


func _test_shop_buy_reroll_continue_routes_to_second_combat() -> String:
	var run_state = _new_run_state()
	run_state.start_new_run()
	run_state.mark_fight_victory()
	run_state.set_gold(200)
	var open_result: Dictionary = run_state.open_shop_for_current_level()
	if not bool(open_result.get("ok", false)):
		return _finish_flow_case(run_state, "Expected first shop to open.")
	var offer := _first_non_treasure_chest_offer(run_state)
	if offer.is_empty():
		return _finish_flow_case(run_state, "Expected first shop to expose a buyable non-treasure-chest offer.")
	var gold_before_buy := int(run_state.run_gold)
	var buy_result: Dictionary = run_state.buy_shop_offer(String(offer.get("offer_id", "")))
	if not bool(buy_result.get("ok", false)):
		return _finish_flow_case(run_state, "Expected buying first non-treasure-chest offer to succeed, got %s." % String(buy_result.get("reason", "unknown")))
	if int(run_state.run_gold) >= gold_before_buy:
		return _finish_flow_case(run_state, "Expected buying an offer to spend gold.")
	var reroll_result: Dictionary = run_state.reroll_shop_items()
	if not bool(reroll_result.get("ok", false)):
		return _finish_flow_case(run_state, "Expected reroll after non-pending buy to succeed, got %s." % String(reroll_result.get("reason", "unknown")))
	if int(run_state.ensure_shop_state().reroll_count) != 1:
		return _finish_flow_case(run_state, "Expected shop reroll count to increment.")
	var transition: Dictionary = run_state.advance_after_shop(false)
	if not bool(transition.get("ok", false)):
		return _finish_flow_case(run_state, "Expected continue after shop to succeed.")
	if run_state.current_step_key != "enemy_2":
		return _finish_flow_case(run_state, "Expected continuing first shop to advance to enemy_2.")
	if String(transition.get("next_scene", "")) != RUN_STATE_SCRIPT.SCENE_COMBAT:
		return _finish_flow_case(run_state, "Expected continuing first shop to route to combat.")
	return _finish_flow_case(run_state, "")


func _test_boss_reward_routes_to_shop_after_claim() -> String:
	var run_state = _new_run_state()
	var skip_result: Dictionary = run_state.skip_to_fight(1, 3)
	if not bool(skip_result.get("ok", false)) or run_state.current_step_key != "boss":
		return _finish_flow_case(run_state, "Expected skip_to_fight(1, 3) to reach the level 1 boss.")
	var victory_result: Dictionary = run_state.mark_fight_victory()
	if not bool(victory_result.get("ok", false)):
		return _finish_flow_case(run_state, "Expected boss victory transition to succeed.")
	if run_state.current_step_key != "boss_relic_reward":
		return _finish_flow_case(run_state, "Expected boss victory to enter boss relic reward step.")
	var options := Array(run_state.boss_relic_reward_options_snapshot())
	if options.is_empty():
		return _finish_flow_case(run_state, "Expected boss victory to generate relic reward options.")
	var claim_result: Dictionary = run_state.claim_boss_relic_reward(0)
	if not bool(claim_result.get("ok", false)):
		return _finish_flow_case(run_state, "Expected boss relic reward claim to succeed, got %s." % String(claim_result.get("reason", "unknown")))
	var transition: Dictionary = run_state.advance_after_boss_reward()
	if not bool(transition.get("ok", false)):
		return _finish_flow_case(run_state, "Expected advancing after boss reward to succeed.")
	if run_state.current_step_key != "shop":
		return _finish_flow_case(run_state, "Expected boss reward advance to route to the post-boss shop.")
	if String(transition.get("next_scene", "")) != RUN_STATE_SCRIPT.SCENE_SHOP:
		return _finish_flow_case(run_state, "Expected boss reward advance next scene to be shop.")
	return _finish_flow_case(run_state, "")


func _test_combat_defeat_routes_to_run_summary() -> String:
	var run_state = _new_run_state()
	run_state.skip_to_fight(2, 1)
	run_state.ensure_player_state().current_hp = 1
	var fight := _combat_for_current_encounter(run_state)
	var combat: CombatStateMachine = fight["combat"]
	combat.begin_player_input()
	combat.resolve_player_turn({"total_combos": 0, "matched_counts": {}})
	if combat.phase != CombatStateMachine.Phase.DEFEAT:
		return _finish_flow_case(run_state, "Expected level 2 opening attack to defeat a 1 HP player.")
	var transition: Dictionary = run_state.mark_player_defeated("flow_test_defeat")
	if run_state.run_active:
		return _finish_flow_case(run_state, "Expected defeat to finalize and deactivate the run.")
	if String(transition.get("next_scene", "")) != RUN_STATE_SCRIPT.SCENE_RUN_SUMMARY:
		return _finish_flow_case(run_state, "Expected defeat transition to route to run summary.")
	var summary := Dictionary(run_state.run_summary_snapshot())
	if bool(summary.get("victory", true)):
		return _finish_flow_case(run_state, "Expected defeat summary victory=false.")
	if String(summary.get("cause", "")) != "flow_test_defeat":
		return _finish_flow_case(run_state, "Expected defeat cause to be preserved in summary.")
	return _finish_flow_case(run_state, "")


func _test_tutorial_first_step_uses_scripted_encounter_and_shop_offer() -> String:
	var run_state = _new_run_state()
	run_state.start_tutorial_run(12345)
	var encounter := Dictionary(run_state.current_encounter_snapshot())
	if not run_state.tutorial_run_active:
		return _finish_flow_case(run_state, "Expected tutorial run flag to be active.")
	if String(encounter.get("enemy_id", "")) != "training_striker":
		return _finish_flow_case(run_state, "Expected tutorial run to use the scripted training striker encounter.")
	var fight := _combat_for_current_encounter(run_state)
	var combat: CombatStateMachine = fight["combat"]
	var enemy: EnemyState = fight["enemy"]
	combat.begin_player_input()
	combat.resolve_player_turn(_lethal_resolve_result(enemy))
	if combat.phase != CombatStateMachine.Phase.VICTORY:
		return _finish_flow_case(run_state, "Expected tutorial combat to be winnable through the combat state machine.")
	run_state.mark_fight_victory()
	if run_state.current_step_key != "shop":
		return _finish_flow_case(run_state, "Expected tutorial first victory to advance to shop.")
	run_state.open_shop_for_current_level()
	var offers := Array(run_state.ensure_shop_state().item_offers)
	if offers.is_empty():
		return _finish_flow_case(run_state, "Expected tutorial first shop to expose item offers.")
	var first_offer := Dictionary(offers[0])
	if String(first_offer.get("content_id", "")) != "shortsword":
		return _finish_flow_case(run_state, "Expected tutorial first shop to surface shortsword as the guided first offer.")
	return _finish_flow_case(run_state, "")


func _new_run_state():
	var run_state = RUN_STATE_SCRIPT.new()
	run_state._profile_repository = FakeProfileRepository.new()
	run_state.player_profile_state = PLAYER_PROFILE_STATE_SCRIPT.new()
	run_state.meta_profile_state = run_state.player_profile_state.meta_profile
	run_state._reward_rng.seed = 424242
	return run_state


func _finish_flow_case(run_state, message: String) -> String:
	if run_state != null and is_instance_valid(run_state):
		run_state.free()
	return message


func _combat_for_current_encounter(run_state) -> Dictionary:
	var player: PlayerState = run_state.ensure_player_state()
	var enemy: EnemyState = ENEMY_STATE_SCRIPT.new()
	enemy.configure_from_blueprint(run_state.current_encounter_snapshot())
	var combat: CombatStateMachine = COMBAT_STATE_MACHINE_SCRIPT.new()
	combat.set_debug_hooks({
		"combat_modifiers_callable": Callable(run_state, "current_combat_modifiers"),
		"apply_gold_callable": Callable(run_state, "add_gold"),
		"run_gold_callable": Callable(self, "_run_gold_for").bind(run_state),
	})
	combat.start_fight(player, enemy)
	return {
		"combat": combat,
		"enemy": enemy,
		"player": player,
	}


func _lethal_resolve_result(enemy: EnemyState) -> Dictionary:
	return {
		"total_combos": 1,
		"matched_counts": {
			OrbType.Id.FIRE: enemy.current_hp + enemy.current_turn_block + 1,
		},
	}


func _first_non_treasure_chest_offer(run_state) -> Dictionary:
	for raw_offer in Array(run_state.ensure_shop_state().item_offers):
		var offer := Dictionary(raw_offer)
		if String(offer.get("type", "")) != ShopService.ITEM_TYPE_TREASURE_CHEST:
			return offer
	return {}


func _run_gold_for(run_state) -> int:
	return int(run_state.run_gold)
