extends RefCounted
class_name ShopSessionTest

const SHOP_SESSION_SCRIPT := preload("res://scripts/shop/shop_session.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("direct_session_uses_injected_logging_and_tutorial_hooks", _test_direct_session_uses_injected_logging_and_tutorial_hooks, failures)
	_run_case("run_state_facade_opens_shop_and_logs", _test_run_state_facade_opens_shop_and_logs, failures)
	_run_case("run_state_facade_logs_shop_actions", _test_run_state_facade_logs_shop_actions, failures)
	_run_case("transition_snapshot_preserves_shop_session_state", _test_transition_snapshot_preserves_shop_session_state, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


class FakeShopState:
	var active := false
	var dungeon_level := 1
	var item_offers: Array = []
	var relic_offer: Dictionary = {}
	var reroll_count := 0
	var reroll_cost := 0
	var pending_treasure_chest_options: Array = []
	var pending_treasure_chest_offer_id := ""
	var offer_sequence := 1
	var skipped := false

	func to_snapshot() -> Dictionary:
		return {
			"active": active,
			"dungeon_level": dungeon_level,
			"item_offers": item_offers.duplicate(true),
			"relic_offer": relic_offer.duplicate(true),
			"reroll_count": reroll_count,
			"reroll_cost": reroll_cost,
			"pending_treasure_chest_options": pending_treasure_chest_options.duplicate(true),
			"pending_treasure_chest_offer_id": pending_treasure_chest_offer_id,
			"offer_sequence": offer_sequence,
			"skipped": skipped,
		}

	func close_shop(mark_skipped: bool = false) -> void:
		active = false
		skipped = mark_skipped


class FakeShopService:
	var opened := false
	var rerolled := false
	var seed_values: Array[int] = []

	func set_rng_seed(seed: int) -> void:
		seed_values.append(seed)

	func open_shop(run_state: Node, level: int) -> Dictionary:
		opened = true
		run_state.shop_state.active = true
		run_state.shop_state.dungeon_level = level
		run_state.shop_state.item_offers = [{"offer_id": "offer_1", "content_id": "shortsword", "price": 10}]
		return {"ok": true, "reason": "", "gold": run_state.run_gold, "shop": run_state.shop_state.to_snapshot()}

	func reroll_shop_items(run_state: Node) -> Dictionary:
		rerolled = true
		run_state.shop_state.reroll_count += 1
		return {"ok": true, "reason": "", "gold": run_state.run_gold, "shop": run_state.shop_state.to_snapshot()}


class FakeRunState:
	extends Node

	var dungeon_level := 2
	var run_gold := 25
	var shop_state := FakeShopState.new()
	var shop_service := FakeShopService.new()

	func ensure_shop_state() -> FakeShopState:
		return shop_state

	func ensure_shop_service() -> FakeShopService:
		return shop_service


class HookRecorder:
	var seeds: Array[int] = []
	var events: Array[Dictionary] = []
	var actions: Array[Dictionary] = []

	func apply_tutorial_shop_seed(action_offset: int) -> void:
		seeds.append(action_offset)

	func append_run_log(event_type: String, payload: Dictionary) -> void:
		events.append({"event": event_type, "payload": payload.duplicate(true)})

	func run_log_result_brief(result: Dictionary) -> Dictionary:
		return {"ok": bool(result.get("ok", false)), "reason": String(result.get("reason", ""))}

	func run_log_shop_action(
		action: String, result: Dictionary, request: Dictionary = {}, shop_before_snapshot: Dictionary = {}, gold_before: int = -1
	) -> void:
		(
			actions
			. append(
				{
					"action": action,
					"result": result.duplicate(true),
					"request": request.duplicate(true),
					"shop_before": shop_before_snapshot.duplicate(true),
					"gold_before": gold_before,
				}
			)
		)

	func run_log_sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
		return {"active": bool(shop_snapshot.get("active", false)), "gold": gold_value}

	func run_log_next_shop_ordinal() -> int:
		return 7


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_direct_session_uses_injected_logging_and_tutorial_hooks() -> String:
	var session = SHOP_SESSION_SCRIPT.new()
	var recorder := HookRecorder.new()
	(
		session
		. configure_hooks(
			{
				SHOP_SESSION_SCRIPT.HOOK_APPLY_TUTORIAL_SHOP_SEED: Callable(recorder, "apply_tutorial_shop_seed"),
				SHOP_SESSION_SCRIPT.HOOK_APPEND_RUN_LOG: Callable(recorder, "append_run_log"),
				SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_RESULT_BRIEF: Callable(recorder, "run_log_result_brief"),
				SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_SHOP_ACTION: Callable(recorder, "run_log_shop_action"),
				SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_SANITIZE_SHOP_SNAPSHOT: Callable(recorder, "run_log_sanitize_shop_snapshot"),
				SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_NEXT_SHOP_ORDINAL: Callable(recorder, "run_log_next_shop_ordinal"),
			}
		)
	)
	var fake_run_state := FakeRunState.new()
	var open_result: Dictionary = session.open_for_current_level(fake_run_state)
	session.reroll_items(fake_run_state)
	fake_run_state.free()

	var error_text := ""
	if not bool(open_result.get("ok", false)):
		error_text = "Expected direct session open to succeed through fake shop service."
	elif recorder.seeds != [0, 100]:
		error_text = "Expected tutorial seed offsets [0, 100], got %s." % str(recorder.seeds)
	elif recorder.events.size() != 1 or String(Dictionary(recorder.events[0]).get("event", "")) != "shop_open":
		error_text = "Expected injected append_run_log hook to record shop_open."
	else:
		var payload: Dictionary = Dictionary(Dictionary(recorder.events[0]).get("payload", {}))
		if int(payload.get("shop_ordinal", 0)) != 7:
			error_text = "Expected shop_open to use injected ordinal hook."
		elif Dictionary(payload.get("shop", {})).get("gold", -1) != 25:
			error_text = "Expected shop_open to use injected shop sanitizer hook."
	if error_text == "" and recorder.actions.size() != 1:
		error_text = "Expected reroll to use injected shop action hook."
	elif error_text == "" and String(Dictionary(recorder.actions[0]).get("action", "")) != "reroll":
		error_text = "Expected injected shop action to record reroll."
	return error_text


func _test_run_state_facade_opens_shop_and_logs() -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_tutorial_run()
	RunState.mark_fight_victory()
	var result: Dictionary = RunState.open_shop_for_current_level()
	var error_text := ""
	if not bool(result.get("ok", false)):
		error_text = "Expected opening the current shop to succeed."
	elif not bool(RunState.ensure_shop_state().active):
		error_text = "Expected RunState shop_state to be active after open_shop_for_current_level."
	else:
		var last_event := _last_run_log_event()
		if String(last_event.get("event", "")) != "shop_open":
			error_text = "Expected last run-log event to be shop_open, got %s." % String(last_event.get("event", ""))
		var payload: Dictionary = Dictionary(last_event.get("payload", {}))
		if error_text == "" and int(payload.get("dungeon_level", 0)) != RunState.dungeon_level:
			error_text = "Expected shop_open payload to use current dungeon level."
		if error_text == "" and Dictionary(payload.get("shop", {})).is_empty():
			error_text = "Expected shop_open payload to include a sanitized shop snapshot."
	RunState.restore_run_transition_state(saved_snapshot)
	return error_text


func _test_run_state_facade_logs_shop_actions() -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_tutorial_run()
	RunState.mark_fight_victory()
	RunState.open_shop_for_current_level()
	var result: Dictionary = RunState.buy_shop_offer("missing_offer")
	var error_text := ""
	if bool(result.get("ok", true)):
		error_text = "Expected buying a missing offer to fail."
	var last_event := _last_run_log_event()
	if error_text == "" and String(last_event.get("event", "")) != "shop_action":
		error_text = "Expected missing buy to still log a shop_action event."
	var payload: Dictionary = Dictionary(last_event.get("payload", {}))
	if error_text == "" and String(payload.get("action", "")) != "buy_offer":
		error_text = "Expected logged action to remain buy_offer."
	if error_text == "" and String(Dictionary(payload.get("request", {})).get("offer_id", "")) != "missing_offer":
		error_text = "Expected logged request to preserve offer_id."
	if error_text == "" and String(Dictionary(payload.get("result", {})).get("reason", "")) != "offer_not_found":
		error_text = "Expected logged result reason to be offer_not_found."
	RunState.restore_run_transition_state(saved_snapshot)
	return error_text


func _test_transition_snapshot_preserves_shop_session_state() -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_tutorial_run()
	RunState.mark_fight_victory()
	RunState.open_shop_for_current_level()
	var shop: Variant = RunState.ensure_shop_state()
	shop.offer_sequence = 42
	shop.pending_treasure_chest_offer_id = "offer_7"
	shop.pending_treasure_chest_options = [{"type": "equipment", "content_id": "shortsword"}]
	var transition_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	shop.close_shop(true)
	shop.offer_sequence = 1
	shop.pending_treasure_chest_options.clear()
	shop.pending_treasure_chest_offer_id = ""
	RunState.restore_run_transition_state(transition_snapshot)
	var error_text := ""
	if not bool(RunState.ensure_shop_state().active):
		error_text = "Expected restored shop to be active."
	elif int(RunState.ensure_shop_state().offer_sequence) != 42:
		error_text = "Expected restored offer_sequence to be 42."
	elif String(RunState.ensure_shop_state().pending_treasure_chest_offer_id) != "offer_7":
		error_text = "Expected restored pending treasure chest offer id."
	elif RunState.ensure_shop_state().pending_treasure_chest_options.size() != 1:
		error_text = "Expected restored pending treasure chest options."
	RunState.restore_run_transition_state(saved_snapshot)
	return error_text


func _last_run_log_event() -> Dictionary:
	var events: Array = Array(RunState.run_log_snapshot().get("events", []))
	if events.is_empty():
		return {}
	return Dictionary(events[events.size() - 1])
