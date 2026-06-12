extends RefCounted
class_name CombatTurnLogWriter


static func append_turn_log(
	turn_log: Dictionary,
	turn_log_presenter: Variant,
	debug_runtime: Variant,
	player_state: Variant,
	enemy_state: Variant,
	append_callback: Callable,
	default_log_level: String
) -> void:
	if turn_log_presenter == null or not append_callback.is_valid():
		return
	var context := {
		"player_end":
		{
			"hp": int(player_state.current_hp if player_state != null else 0),
			"max_hp": int(player_state.max_hp if player_state != null else 0),
			"armor": int(player_state.armor if player_state != null else 0),
			"gold": int(player_state.gold if player_state != null else 0),
		},
		"enemy_end":
		{
			"hp": int(enemy_state.current_hp if enemy_state != null else 0),
			"max_hp": int(enemy_state.max_hp if enemy_state != null else 0),
		},
		"orb_values_by_id": _orb_values_by_id(player_state),
	}
	var log_level := default_log_level
	if debug_runtime != null and debug_runtime.has_method("log_level"):
		log_level = String(debug_runtime.log_level())
	var lines: Array[String] = turn_log_presenter.build_turn_log_lines(turn_log, log_level, context)
	for line in lines:
		append_callback.call(line)


static func build_run_outcome_summary(turn_log_presenter: Variant, run_state: Variant, max_dungeon_levels: int, fallback_cause: String = "") -> String:
	if turn_log_presenter == null or run_state == null:
		return fallback_cause
	var summary: Dictionary = run_state.run_summary_snapshot()
	return turn_log_presenter.build_run_outcome_summary(summary, max_dungeon_levels, fallback_cause)


static func _orb_values_by_id(player_state: Variant) -> Dictionary:
	var values := {}
	if player_state == null or not player_state.has_method("orb_value"):
		return values
	for orb_id in OrbType.ALL_TYPES:
		values[int(orb_id)] = player_state.orb_value(int(orb_id))
	return values
