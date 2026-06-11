extends RefCounted
class_name ShopSessionTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("run_state_facade_opens_shop_and_logs", _test_run_state_facade_opens_shop_and_logs, failures)
	_run_case("run_state_facade_logs_shop_actions", _test_run_state_facade_logs_shop_actions, failures)
	_run_case("transition_snapshot_preserves_shop_session_state", _test_transition_snapshot_preserves_shop_session_state, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
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
