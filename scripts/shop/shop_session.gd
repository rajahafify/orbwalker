extends RefCounted
class_name ShopSession

const HOOK_APPLY_TUTORIAL_SHOP_SEED := "apply_tutorial_shop_seed"
const HOOK_APPEND_RUN_LOG := "append_run_log"
const HOOK_RUN_LOG_RESULT_BRIEF := "run_log_result_brief"
const HOOK_RUN_LOG_SHOP_ACTION := "run_log_shop_action"
const HOOK_RUN_LOG_SANITIZE_SHOP_SNAPSHOT := "run_log_sanitize_shop_snapshot"
const HOOK_RUN_LOG_NEXT_SHOP_ORDINAL := "run_log_next_shop_ordinal"

var _hooks: Dictionary = {}


func configure_hooks(hooks: Dictionary) -> void:
	_hooks = hooks.duplicate()


func open_for_current_level(run_state: Node) -> Dictionary:
	_apply_tutorial_shop_seed(0)
	var result: Dictionary = run_state.ensure_shop_service().open_shop(run_state, run_state.dungeon_level)
	var shop_snapshot: Dictionary = run_state.ensure_shop_state().to_snapshot()
	_append_run_log(
		"shop_open",
		{
			"result": _run_log_result_brief(result),
			"dungeon_level": run_state.dungeon_level,
			"shop_ordinal": _run_log_next_shop_ordinal(),
			"shop": _run_log_sanitize_shop_snapshot(shop_snapshot, run_state.run_gold),
		}
	)
	return result


func reroll_items(run_state: Node) -> Dictionary:
	var shop_before: Dictionary = run_state.ensure_shop_state().to_snapshot()
	var gold_before := int(run_state.run_gold)
	_apply_tutorial_shop_seed(100 + run_state.ensure_shop_state().reroll_count)
	var result: Dictionary = run_state.ensure_shop_service().reroll_shop_items(run_state)
	_run_log_shop_action("reroll", result, {}, shop_before, gold_before)
	return result


func buy_offer(run_state: Node, offer_id: String) -> Dictionary:
	return _logged_shop_action(
		run_state, "buy_offer", {"offer_id": offer_id}, func() -> Dictionary: return run_state.ensure_shop_service().buy_offer(run_state, offer_id)
	)


func sell_equipped_item(run_state: Node, slot_index: int) -> Dictionary:
	return _logged_shop_action(
		run_state,
		"sell_equipment",
		{"slot_index": slot_index},
		func() -> Dictionary: return run_state.ensure_shop_service().sell_equipped_item(run_state, slot_index)
	)


func sell_consumable_item(run_state: Node, slot_index: int) -> Dictionary:
	return _logged_shop_action(
		run_state,
		"sell_consumable",
		{"slot_index": slot_index},
		func() -> Dictionary: return run_state.ensure_shop_service().sell_consumable_item(run_state, slot_index)
	)


func choose_treasure_chest_option(run_state: Node, option_index: int) -> Dictionary:
	return _logged_shop_action(
		run_state,
		"choose_treasure_chest",
		{"option_index": option_index},
		func() -> Dictionary: return run_state.ensure_shop_service().choose_treasure_chest_option(run_state, option_index)
	)


func replace_pending_treasure_chest_option(run_state: Node, option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	return _logged_shop_action(
		run_state,
		"replace_treasure_chest_option",
		{
			"option_index": option_index,
			"slot_index": slot_index,
			"sell_replaced": sell_replaced,
		},
		func() -> Dictionary: return run_state.ensure_shop_service().replace_pending_treasure_chest_option(run_state, option_index, slot_index, sell_replaced)
	)


func discard_pending_treasure_chest_options(run_state: Node) -> Dictionary:
	return _logged_shop_action(
		run_state, "skip_treasure_chest", {}, func() -> Dictionary: return run_state.ensure_shop_service().discard_pending_treasure_chest_options(run_state)
	)


func close(run_state: Node, mark_skipped: bool = false) -> void:
	run_state.ensure_shop_state().close_shop(mark_skipped)


func snapshot_for_transition(run_state: Node) -> Dictionary:
	var state = run_state.ensure_shop_state()
	var snapshot: Dictionary = state.to_snapshot()
	snapshot["offer_sequence"] = state.offer_sequence
	return snapshot


func restore_for_transition(run_state: Node, snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	var state = run_state.ensure_shop_state()
	state.active = bool(snapshot.get("active", state.active))
	state.dungeon_level = maxi(1, int(snapshot.get("dungeon_level", state.dungeon_level)))
	state.item_offers = Array(snapshot.get("item_offers", [])).duplicate(true)
	state.relic_offer = Dictionary(snapshot.get("relic_offer", {})).duplicate(true)
	state.reroll_count = maxi(0, int(snapshot.get("reroll_count", state.reroll_count)))
	state.reroll_cost = maxi(0, int(snapshot.get("reroll_cost", state.reroll_cost)))
	state.pending_treasure_chest_options = Array(snapshot.get("pending_treasure_chest_options", [])).duplicate(true)
	state.pending_treasure_chest_offer_id = String(snapshot.get("pending_treasure_chest_offer_id", state.pending_treasure_chest_offer_id))
	state.offer_sequence = maxi(1, int(snapshot.get("offer_sequence", state.offer_sequence)))
	state.skipped = bool(snapshot.get("skipped", state.skipped))


func _logged_shop_action(run_state: Node, action: String, request: Dictionary, operation: Callable) -> Dictionary:
	var shop_before: Dictionary = run_state.ensure_shop_state().to_snapshot()
	var gold_before := int(run_state.run_gold)
	var result: Dictionary = operation.call()
	_run_log_shop_action(action, result, request, shop_before, gold_before)
	return result


func _hook(name: String) -> Callable:
	var callable: Callable = _hooks.get(name, Callable())
	return callable if callable.is_valid() else Callable()


func _apply_tutorial_shop_seed(action_offset: int) -> void:
	var callable := _hook(HOOK_APPLY_TUTORIAL_SHOP_SEED)
	if callable.is_valid():
		callable.call(action_offset)


func _append_run_log(event_type: String, payload: Dictionary) -> void:
	var callable := _hook(HOOK_APPEND_RUN_LOG)
	if callable.is_valid():
		callable.call(event_type, payload)


func _run_log_result_brief(result: Dictionary) -> Dictionary:
	var callable := _hook(HOOK_RUN_LOG_RESULT_BRIEF)
	if callable.is_valid():
		return Dictionary(callable.call(result))
	return result.duplicate(true)


func _run_log_shop_action(action: String, result: Dictionary, request: Dictionary = {}, shop_before_snapshot: Dictionary = {}, gold_before: int = -1) -> void:
	var callable := _hook(HOOK_RUN_LOG_SHOP_ACTION)
	if callable.is_valid():
		callable.call(action, result, request, shop_before_snapshot, gold_before)


func _run_log_sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	var callable := _hook(HOOK_RUN_LOG_SANITIZE_SHOP_SNAPSHOT)
	if callable.is_valid():
		return Dictionary(callable.call(shop_snapshot, gold_value))
	return shop_snapshot.duplicate(true)


func _run_log_next_shop_ordinal() -> int:
	var callable := _hook(HOOK_RUN_LOG_NEXT_SHOP_ORDINAL)
	if callable.is_valid():
		return int(callable.call())
	return 1
