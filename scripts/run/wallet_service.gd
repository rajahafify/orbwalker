extends RefCounted
class_name WalletService


func set_gold(run_state: Variant, amount: int) -> int:
	run_state.run_gold = maxi(0, amount)
	return run_state.run_gold


func add_gold(run_state: Variant, amount: int, source: String = "combat_gain") -> int:
	if amount <= 0:
		return 0
	run_state.run_gold += amount
	run_state.total_gold_earned += amount
	if _source_counts_for_run_score(source):
		run_state.run_score += amount
	return amount


func spend_gold(run_state: Variant, amount: int) -> bool:
	if amount < 0:
		return false
	if run_state.run_gold < amount:
		return false
	run_state.run_gold -= amount
	return true


func can_afford(run_state: Variant, amount: int) -> bool:
	return amount >= 0 and run_state.run_gold >= amount


func reset_for_new_run(run_state: Variant, starting_gold: int) -> void:
	run_state.run_gold = maxi(0, starting_gold)
	run_state.run_score = 0
	run_state.total_gold_earned = 0


func restore_from_snapshot(run_state: Variant, snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	run_state.run_gold = maxi(0, int(snapshot.get("run_gold", run_state.run_gold)))
	run_state.run_score = int(snapshot.get("run_score", run_state.run_score))
	run_state.total_gold_earned = maxi(0, int(snapshot.get("total_gold_earned", run_state.total_gold_earned)))


func _source_counts_for_run_score(source: String) -> bool:
	return source != "sell_refund" and source != "shop_refund" and source != "replacement_sell_refund"
