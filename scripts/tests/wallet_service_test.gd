extends RefCounted
class_name WalletServiceTest

const WALLET_SERVICE_SCRIPT := preload("res://scripts/run/wallet_service.gd")


class FakeRunState:
	extends RefCounted

	var run_gold: int = 0
	var run_score: int = 0
	var total_gold_earned: int = 0


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("add_gold_counts_total_and_run_score", _test_add_gold_counts_total_and_run_score, failures)
	_run_case("sell_refund_does_not_count_to_run_score", _test_sell_refund_does_not_count_to_run_score, failures)
	_run_case("spend_gold_rejects_invalid_amounts", _test_spend_gold_rejects_invalid_amounts, failures)
	_run_case("can_afford_and_set_gold_clamp", _test_can_afford_and_set_gold_clamp, failures)
	_run_case("run_state_spend_gold_emits_gold_changed", _test_run_state_spend_gold_emits_gold_changed, failures)
	return {
		"passed": failures.is_empty(),
		"total": 5,
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


func _test_add_gold_counts_total_and_run_score() -> String:
	var service: Variant = WALLET_SERVICE_SCRIPT.new()
	var run_state := FakeRunState.new()
	var added: int = service.add_gold(run_state, 12, "combat_gain")
	if added != 12:
		return "Expected combat_gain to add requested amount, got %d." % added
	if int(run_state.run_gold) != 12:
		return "Expected run_gold to become 12."
	if int(run_state.total_gold_earned) != 12:
		return "Expected total_gold_earned to become 12."
	if int(run_state.run_score) != 12:
		return "Expected run_score to become 12."
	return ""


func _test_sell_refund_does_not_count_to_run_score() -> String:
	var service: Variant = WALLET_SERVICE_SCRIPT.new()
	var run_state := FakeRunState.new()
	service.add_gold(run_state, 20, "combat_gain")
	service.add_gold(run_state, 7, "sell_refund")
	if int(run_state.run_gold) != 27:
		return "Expected sell_refund to increase run_gold by 7 to 27."
	if int(run_state.total_gold_earned) != 27:
		return "Expected sell_refund to count total gold earned to 27."
	if int(run_state.run_score) != 20:
		return "Expected sell_refund to skip run_score increment."
	return ""


func _test_spend_gold_rejects_invalid_amounts() -> String:
	var service: Variant = WALLET_SERVICE_SCRIPT.new()
	var run_state := FakeRunState.new()
	run_state.run_gold = 10
	if service.spend_gold(run_state, -1):
		return "Expected negative spend to fail."
	if int(run_state.run_gold) != 10:
		return "Expected run_gold to stay at 10 after negative spend."
	if service.spend_gold(run_state, 11):
		return "Expected spend over run_gold to fail."
	if int(run_state.run_gold) != 10:
		return "Expected run_gold to stay at 10 after failed spend."
	if not service.spend_gold(run_state, 0):
		return "Expected zero spend to succeed."
	if int(run_state.run_gold) != 10:
		return "Expected run_gold to remain 10 after zero spend."
	if not service.spend_gold(run_state, 10):
		return "Expected spending exact balance to succeed."
	if int(run_state.run_gold) != 0:
		return "Expected run_gold to become 0 after spending 10."
	return ""


func _test_can_afford_and_set_gold_clamp() -> String:
	var service: Variant = WALLET_SERVICE_SCRIPT.new()
	var run_state := FakeRunState.new()
	if service.can_afford(run_state, 0) == false:
		return "Expected zero to be affordable when run_gold is 0."
	if service.can_afford(run_state, 1):
		return "Expected nonzero cost to be unaffordable when run_gold is 0."
	service.set_gold(run_state, -30)
	if int(run_state.run_gold) != 0:
		return "Expected negative set_gold to clamp at 0."
	service.set_gold(run_state, 15)
	if int(run_state.run_gold) != 15:
		return "Expected set_gold to update run_gold to 15."
	if service.can_afford(run_state, 14) == false:
		return "Expected 14 to be affordable when run_gold is 15."
	if not service.can_afford(run_state, 15):
		return "Expected 15 to be affordable when run_gold is 15."
	return ""


func _test_run_state_spend_gold_emits_gold_changed() -> String:
	var previous_gold := RunState.run_gold
	var events: Array[Dictionary] = []
	var recorder := func(payload: Dictionary) -> void: events.append(payload)
	RunState.gold_changed.connect(recorder)
	RunState.set_gold(40)
	events.clear()
	var spent: bool = RunState.spend_gold(15)
	RunState.gold_changed.disconnect(recorder)
	RunState.set_gold(previous_gold)
	if not spent:
		return "Expected spend_gold to succeed with sufficient balance."
	if events.size() != 1:
		return "Expected spend_gold to emit gold_changed exactly once, got %d." % events.size()
	var payload: Dictionary = events[0]
	if int(payload.get("delta", 0)) != -15:
		return "Expected gold_changed delta of -15, got %s." % str(payload.get("delta"))
	if int(payload.get("gold", -1)) != 25:
		return "Expected gold_changed to report 25 gold, got %s." % str(payload.get("gold"))
	if String(payload.get("source", "")) != "spend_gold":
		return "Expected gold_changed source of spend_gold, got %s." % String(payload.get("source", ""))
	return ""
