extends RefCounted
class_name RunStateSignalEmitter

var _owner
var _step_index_provider: Callable
var _run_summary_provider: Callable


func _init(owner, step_index_provider: Callable = Callable(), run_summary_provider: Callable = Callable()) -> void:
	_owner = owner
	_step_index_provider = step_index_provider
	_run_summary_provider = run_summary_provider


func capture() -> Dictionary:
	var run_summary := _run_summary()
	return {
		"run_gold": _owner.run_gold,
		"dungeon_level": _owner.dungeon_level,
		"step_key": _owner.current_step_key,
		"step_index": _step_index(),
		"run_active": _owner.run_active,
		"run_victory": _owner.run_victory,
		"summary_available": not run_summary.is_empty(),
		"run_summary": run_summary,
	}


func emit_run_state_signals(previous: Dictionary, reason: String, gold_source: String) -> void:
	var source := gold_source if gold_source != "" else reason
	_emit_gold_changed_if_needed(previous, source)
	_emit_run_step_changed_if_needed(previous, reason)
	_emit_run_summary_changed_if_needed(previous, reason)
	_emit_run_state_changed_if_needed(previous, reason)


func emit_profile_changed(reason: String, score_delta: int = 0, unlock: Dictionary = {}) -> void:
	(
		_owner
		. profile_changed
		. emit(
			{
				"reason": reason,
				"profile": _owner.profile_snapshot(),
				"meta_profile": _owner.meta_profile_snapshot(),
				"score_delta": score_delta,
				"unlock": unlock.duplicate(true),
			}
		)
	)


func _emit_gold_changed_if_needed(previous: Dictionary, source: String) -> void:
	var previous_gold := int(previous.get("run_gold", _owner.run_gold))
	if previous_gold == _owner.run_gold:
		return
	(
		_owner
		. gold_changed
		. emit(
			{
				"gold": _owner.run_gold,
				"previous_gold": previous_gold,
				"delta": _owner.run_gold - previous_gold,
				"source": source,
				"run_score": _owner.run_score,
				"total_gold_earned": _owner.total_gold_earned,
			}
		)
	)


func _emit_run_step_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_level := int(previous.get("dungeon_level", _owner.dungeon_level))
	var previous_step_key := String(previous.get("step_key", _owner.current_step_key))
	var step_index := _step_index()
	var previous_step_index := int(previous.get("step_index", step_index))
	if previous_level == _owner.dungeon_level and previous_step_key == _owner.current_step_key and previous_step_index == step_index:
		return
	(
		_owner
		. run_step_changed
		. emit(
			{
				"dungeon_level": _owner.dungeon_level,
				"previous_dungeon_level": previous_level,
				"step_key": _owner.current_step_key,
				"previous_step_key": previous_step_key,
				"step_index": step_index,
				"run_active": _owner.run_active,
				"next_scene": _owner.next_scene_path(),
				"reason": reason,
			}
		)
	)


func _emit_run_state_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_run_active := bool(previous.get("run_active", _owner.run_active))
	var previous_run_victory := bool(previous.get("run_victory", _owner.run_victory))
	var run_summary := _run_summary()
	var summary_available: bool = not run_summary.is_empty()
	var previous_summary_available := bool(previous.get("summary_available", summary_available))
	if previous_run_active == _owner.run_active and previous_run_victory == _owner.run_victory and previous_summary_available == summary_available:
		return
	(
		_owner
		. run_state_changed
		. emit(
			{
				"run_active": _owner.run_active,
				"previous_run_active": previous_run_active,
				"run_victory": _owner.run_victory,
				"previous_run_victory": previous_run_victory,
				"summary_available": summary_available,
				"reason": reason,
				"next_scene": _owner.next_scene_path(),
			}
		)
	)


func _emit_run_summary_changed_if_needed(previous: Dictionary, reason: String) -> void:
	var previous_summary := Dictionary(previous.get("run_summary", {}))
	var run_summary := _run_summary()
	if previous_summary == run_summary:
		return
	(
		_owner
		. run_summary_changed
		. emit(
			{
				"summary": run_summary,
				"available": not run_summary.is_empty(),
				"reason": reason,
			}
		)
	)


func _step_index() -> int:
	return int(_step_index_provider.call()) if _step_index_provider.is_valid() else 0


func _run_summary() -> Dictionary:
	if not _run_summary_provider.is_valid():
		return {}
	return Dictionary(_run_summary_provider.call()).duplicate(true)
