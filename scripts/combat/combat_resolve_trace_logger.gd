extends RefCounted
class_name CombatResolveTraceLogger

var _model: Variant = null


func bind(model: Variant) -> void:
	_model = model


func resolve_trace_enabled() -> bool:
	return true


func trace(start_ticks_usec: int, message: String) -> void:
	if not resolve_trace_enabled() or start_ticks_usec <= 0:
		return
	_print_trace(start_ticks_usec, message)


func on_resolver_cells_cleared(cells: Array) -> void:
	if not _resolve_trace_active():
		return
	_resolve_trace("phase=clear_applied source=simulation_signal cells=%d" % cells.size())


func on_resolver_gravity_applied(fall_moves: Array) -> void:
	if not _resolve_trace_active():
		return
	_resolve_trace("phase=gravity_applied source=simulation_signal moves=%d" % fall_moves.size())


func on_resolver_refill_applied(refill_spawns: Array) -> void:
	if not _resolve_trace_active():
		return
	_resolve_trace("phase=refill_applied source=simulation_signal spawns=%d" % refill_spawns.size())


func on_resolver_cascade_step_complete(step_index: int, total_combos: int) -> void:
	if not _resolve_trace_active():
		return
	_resolve_trace("phase=pass_complete source=simulation_signal step_index=%d total_combos=%d" % [step_index, total_combos])


func on_resolver_complete(result: Dictionary) -> void:
	if not _resolve_trace_active():
		return
	_resolve_trace(
		(
			"phase=simulation_resolve_complete source=signal total_combos=%d passes=%d"
			% [int(result.get("total_combos", 0)), Array(result.get("passes", [])).size()]
		)
	)


func _resolve_trace_active() -> bool:
	return _model != null and _model.has_method("resolve_trace_active") and bool(_model.resolve_trace_active())


func _resolve_trace(message: String) -> void:
	var start_ticks_usec := _resolve_trace_origin_usec()
	if start_ticks_usec <= 0:
		return
	_print_trace(start_ticks_usec, message)


func _print_trace(start_ticks_usec: int, message: String) -> void:
	var elapsed_ms := maxi(0, int(float(Time.get_ticks_usec() - start_ticks_usec) / 1000.0))
	print("[ResolveTrace +%04dms] %s" % [elapsed_ms, message])


func _resolve_trace_origin_usec() -> int:
	if _model != null and _model.has_method("resolve_trace_origin_usec"):
		return int(_model.resolve_trace_origin_usec())
	return 0
