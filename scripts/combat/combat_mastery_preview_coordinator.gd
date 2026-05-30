extends RefCounted
class_name CombatMasteryPreviewCoordinator

const DEFAULT_FEEDBACK_STAGGER_SECONDS := 0.08

var _model: Variant = null
var _player_state: Variant = null
var _view: Variant = null
var _resolution_order: Array[int] = []
var _feedback_stagger_seconds := DEFAULT_FEEDBACK_STAGGER_SECONDS
var _base_amounts: Dictionary = {}
var _modifiers: Dictionary = {}


func bind(model: Variant, player_state: Variant, view: Variant, config: Dictionary = {}) -> void:
	_model = model
	_player_state = player_state
	_view = view
	_resolution_order = []
	for raw_orb_id in Array(config.get("resolution_order", [])):
		_resolution_order.append(int(raw_orb_id))
	_feedback_stagger_seconds = float(config.get("feedback_stagger_seconds", DEFAULT_FEEDBACK_STAGGER_SECONDS))
	if config.has("combat_modifiers"):
		_modifiers = Dictionary(config.get("combat_modifiers", {})).duplicate(true)


func reset(modifiers: Dictionary) -> void:
	_base_amounts.clear()
	_modifiers = modifiers.duplicate(true)
	if _model != null and _model.has_method("reset_combat_mastery_preview"):
		_model.reset_combat_mastery_preview()
	if _view != null and _view.has_method("clear_combat_mastery_feedback"):
		_view.clear_combat_mastery_feedback()


func show_match_feedback(group: Dictionary, combo_value: int) -> void:
	if _player_state == null:
		return
	var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
	if not OrbType.is_valid_id(orb_id):
		return
	var base_amount := _preview_match_base_feedback_value(group)
	if base_amount <= 0:
		return
	_base_amounts[orb_id] = int(_base_amounts.get(orb_id, 0)) + base_amount
	_pulse_modifier_sources(preview_modifier_sources_for_orb(orb_id))
	_sync_for_combo(combo_value)


func sync_totals() -> void:
	if _view == null or _model == null or not _model.has_method("combat_mastery_preview_total"):
		return
	for orb_id in _resolution_order:
		var total: int = _model.combat_mastery_preview_total(int(orb_id))
		_set_view_feedback(int(orb_id), total)


func release_feedback(orb_id: int) -> void:
	if not OrbType.is_valid_id(orb_id):
		return
	_base_amounts.erase(orb_id)
	if _model != null and _model.has_method("release_combat_mastery_feedback"):
		_model.release_combat_mastery_feedback(orb_id)
	_set_view_feedback(orb_id, 0)


func release_remaining(wait_callback: Callable = Callable(), can_continue_callback: Callable = Callable()) -> void:
	if _view == null or _model == null or not _model.has_method("consume_active_combat_mastery_feedback"):
		return
	for orb_id in _model.consume_active_combat_mastery_feedback(_resolution_order):
		_base_amounts.erase(int(orb_id))
		_set_view_feedback(int(orb_id), 0)
		if wait_callback.is_valid():
			await wait_callback.call(_feedback_stagger_seconds)
		if can_continue_callback.is_valid() and not bool(can_continue_callback.call()):
			return


func preview_match_feedback_value(group: Dictionary, combo_value: int) -> int:
	var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
	var base_amount := _preview_match_base_feedback_value(group)
	return _project_feedback_value(orb_id, base_amount, combo_value)


func apply_end_modifier_feedback(orb_id: int, amount: int, sources: Array[Dictionary], wait_callback: Callable = Callable()) -> void:
	if amount <= 0 or not OrbType.is_valid_id(orb_id) or _model == null:
		return
	_pulse_modifier_sources(sources)
	var next_total: int = int(_model.combat_mastery_preview_total(orb_id)) + amount
	_model.set_combat_mastery_preview_total(orb_id, next_total)
	_set_view_feedback(orb_id, next_total)
	if wait_callback.is_valid():
		await wait_callback.call(0.16)


func preview_modifier_sources_for_orb(orb_id: int) -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	sources.append_array(_modifier_sources_for_orb_bonus(orb_id))
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			sources.append_array(_modifier_sources_for_combo_scaling())
	return _unique_modifier_sources(sources)


func modifier_sources_for_key(key: String) -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	for raw_source in Array(_modifiers.get("sources", [])):
		var source: Dictionary = raw_source
		var modifiers: Dictionary = source.get("combat_modifiers", {})
		if key == "combo_multiplier_mult":
			if not is_equal_approx(float(modifiers.get(key, 1.0)), 1.0):
				sources.append(source)
			continue
		if int(modifiers.get(key, 0)) != 0:
			sources.append(source)
	return _unique_modifier_sources(sources)


func set_hovered_board_orb_id(orb_id: int) -> bool:
	if _model == null:
		return false
	var normalized_orb_id := orb_id if _is_hoverable_combat_orb(orb_id) else -1
	if _model.hovered_board_orb_id() == normalized_orb_id:
		return false
	_model.set_hovered_board_orb_id(normalized_orb_id)
	if normalized_orb_id < 0:
		_clear_hovered_mastery()
	else:
		_set_hovered_mastery(normalized_orb_id)
	return true


func clear_hover_state() -> void:
	if _model != null and _model.has_method("clear_hovered_board_orb_id"):
		_model.clear_hovered_board_orb_id()
	if _view != null and _view.has_method("clear_combat_mastery_hover_ui"):
		_view.clear_combat_mastery_hover_ui()


func build_hover_payload(progression_snapshot: Dictionary) -> Dictionary:
	return {
		"orb_values_by_id": _orb_values_by_id(),
		"mastery_levels": Dictionary(progression_snapshot.get("mastery_levels", {})),
		"combat_modifiers": _modifiers.duplicate(true),
	}


func _preview_match_base_feedback_value(group: Dictionary) -> int:
	var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
	if not OrbType.is_valid_id(orb_id) or _player_state == null:
		return 0
	var cells: Array = group.get("cells", [])
	var matched_count := cells.size()
	if matched_count <= 0:
		return 0
	var orb_bonus_by_id: Dictionary = _modifiers.get("orb_bonus_by_id", {})
	var orb_value := int(_player_state.orb_value(orb_id)) + int(orb_bonus_by_id.get(orb_id, 0))
	return matched_count * maxi(0, orb_value)


func _is_hoverable_combat_orb(orb_id: int) -> bool:
	if not OrbType.is_valid_id(orb_id):
		return false
	return (
		orb_id
		in [
			OrbType.Id.FIRE,
			OrbType.Id.ICE,
			OrbType.Id.EARTH,
			OrbType.Id.HEART,
			OrbType.Id.ARMOR,
			OrbType.Id.GOLD,
		]
	)


func _orb_values_by_id() -> Dictionary:
	var values := {}
	if _player_state == null or not _player_state.has_method("orb_value"):
		return values
	for orb_id in OrbType.ALL_TYPES:
		values[int(orb_id)] = _player_state.orb_value(int(orb_id))
	return values


func _sync_for_combo(combo_value: int) -> void:
	if _model == null:
		return
	for raw_orb_id in _resolution_order:
		var orb_id := int(raw_orb_id)
		var base_amount := int(_base_amounts.get(orb_id, 0))
		var projected_amount := _project_feedback_value(orb_id, base_amount, combo_value)
		_model.set_combat_mastery_preview_total(orb_id, projected_amount)
		_set_view_feedback(orb_id, projected_amount)


func _project_feedback_value(orb_id: int, base_amount: int, combo_value: int) -> int:
	if base_amount <= 0 or not OrbType.is_valid_id(orb_id) or _player_state == null:
		return 0
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			var combo_flat_bonus := int(_modifiers.get("combo_flat_bonus", 0))
			var combo_multiplier_mult := maxf(0.0, float(_modifiers.get("combo_multiplier_mult", 1.0)))
			return int(round(float(base_amount) * float(_player_state.combo_multiplier(combo_value + combo_flat_bonus)) * combo_multiplier_mult))
		_:
			return base_amount


func _modifier_sources_for_orb_bonus(orb_id: int) -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	for raw_source in Array(_modifiers.get("sources", [])):
		var source: Dictionary = raw_source
		var modifiers: Dictionary = source.get("combat_modifiers", {})
		var orb_bonus_by_id: Dictionary = modifiers.get("orb_bonus_by_id", {})
		if int(orb_bonus_by_id.get(orb_id, 0)) != 0:
			sources.append(source)
	return sources


func _modifier_sources_for_combo_scaling() -> Array[Dictionary]:
	var sources: Array[Dictionary] = []
	for raw_source in Array(_modifiers.get("sources", [])):
		var source: Dictionary = raw_source
		var modifiers: Dictionary = source.get("combat_modifiers", {})
		if int(modifiers.get("combo_flat_bonus", 0)) != 0 or not is_equal_approx(float(modifiers.get("combo_multiplier_mult", 1.0)), 1.0):
			sources.append(source)
	return sources


func _unique_modifier_sources(sources: Array[Dictionary]) -> Array[Dictionary]:
	var unique_sources: Array[Dictionary] = []
	var seen := {}
	for source in sources:
		var source_key := "%s:%s" % [String(source.get("source_type", "")), String(source.get("source_id", ""))]
		if seen.has(source_key):
			continue
		seen[source_key] = true
		unique_sources.append(source)
	return unique_sources


func _pulse_modifier_sources(sources: Array[Dictionary]) -> void:
	if sources.is_empty() or _view == null or not _view.has_method("pulse_combat_modifier_sources"):
		return
	_view.pulse_combat_modifier_sources(sources)


func _set_view_feedback(orb_id: int, amount: int) -> void:
	if _view != null and _view.has_method("set_combat_mastery_feedback"):
		_view.set_combat_mastery_feedback(orb_id, amount)


func _set_hovered_mastery(orb_id: int) -> void:
	if _view != null and _view.has_method("set_hovered_combat_mastery"):
		_view.set_hovered_combat_mastery(orb_id)


func _clear_hovered_mastery() -> void:
	if _view != null and _view.has_method("clear_hovered_combat_mastery"):
		_view.clear_hovered_combat_mastery()
