extends RefCounted
class_name CombatControllerHudUpdateRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func update_hud() -> void:
	if _owner_value("_player_state") == null or _owner_value("_enemy_state") == null or _owner_value("_combat") == null:
		return

	ensure_hud_presenter()
	_bind_hud_snapshot_provider()
	var hud_presenter: Variant = _owner_value("_hud_presenter")
	var hud_snapshot_provider: Variant = _owner_value("_hud_snapshot_provider")
	var hud_snapshot: Dictionary = hud_presenter.build_hud_snapshot(hud_snapshot_provider.build_snapshot())
	var view: Variant = _owner_value("_view")
	if view != null:
		view.apply_hud_snapshot(hud_snapshot, {"refresh_build_icon_rows": Callable(self, "refresh_build_icon_rows")})


func ensure_hud_presenter() -> void:
	if _owner_value("_hud_presenter") == null:
		_set_owner_value("_hud_presenter", _contract().COMBAT_HUD_PRESENTER_SCRIPT.new())


func refresh_build_icon_rows(progression_snapshot: Dictionary) -> void:
	_owner.call("_bind_player_hud_refresh_coordinator")
	var coordinator: Variant = _owner_value("_player_hud_refresh_coordinator")
	if coordinator != null:
		coordinator.refresh_build_icon_rows(progression_snapshot)


func _bind_hud_snapshot_provider() -> void:
	if _owner_value("_hud_snapshot_provider") == null:
		_set_owner_value("_hud_snapshot_provider", _contract().COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT.new())
	(
		_owner_value("_hud_snapshot_provider")
		. bind(
			{
				"run_state": RunState,
				"model": _owner_value("_model"),
				"player_state": _owner_value("_player_state"),
				"enemy_state": _owner_value("_enemy_state"),
				"combat": _owner_value("_combat"),
				"view": _owner_value("_view"),
				"visuals": _owner_value("_visuals"),
				"turn_log_presenter": _owner_value("_turn_log_presenter"),
			},
			{
				"input_phase_value": _owner_callback("_input_phase_value"),
				"drag_active": _input_callback("drag_active"),
				"drag_move_time_left": _input_callback("drag_move_time_left"),
				"timer_ready_seconds": _input_callback("timer_ready_seconds"),
				"show_intent_preview": _owner_callback("_should_show_intent_damage_preview"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT)}
		)
	)


func _owner_value(property_name: String) -> Variant:
	return _owner.get(property_name)


func _set_owner_value(property_name: String, value: Variant) -> void:
	_owner.set(property_name, value)


func _contract() -> Variant:
	return _owner.CONTRACT


func _owner_callback(method_name: String) -> Callable:
	return Callable(_owner, method_name)


func _input_callback(method_name: String) -> Callable:
	_owner.call("_bind_input_router")
	return Callable(_owner.get("_input_router"), method_name)
