extends RefCounted
class_name CombatControllerInputRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func process(delta: float) -> void:
	var timer_service: Variant = _owner_value("_combat_timer_service")
	if timer_service == null:
		return
	var drag_update: Dictionary = timer_service.process(
		_owner_value("_board_controller"),
		_owner_value("_view"),
		_owner_value("_player_state"),
		delta,
		int(_owner.call("_input_phase_value")) == int(_owner.InputPhase.PLAYER_INPUT)
	)
	handle_drag_input_result(drag_update)


func unhandled_input(event: InputEvent) -> void:
	_owner.call("_bind_input_command_handler")
	var handler: Variant = _owner_value("_input_command_handler")
	if handler != null:
		handler.handle_unhandled_input(event)


func set_viewport_input_handled() -> void:
	var host: Variant = _owner_value("_host")
	if host != null and is_instance_valid(host) and host.get_viewport() != null:
		host.get_viewport().set_input_as_handled()


func toggle_debug_overlay() -> void:
	var debug_runtime: Variant = _owner_value("_debug_runtime")
	if debug_runtime != null:
		debug_runtime.toggle_overlay()
	_owner.call("_bind_hud_update_router")
	_owner.get("_hud_update_router").update_hud()


func drag_match_groups() -> Array:
	var resolver: Variant = _owner_value("_resolver")
	var board_model: Variant = _owner_value("_board_model")
	if resolver == null or board_model == null:
		return []
	return resolver.get_match_groups(board_model)


func drag_move_timer_seconds() -> float:
	return timer_ready_seconds()


func drag_active() -> bool:
	var timer_service: Variant = _owner_value("_combat_timer_service")
	if timer_service == null:
		return false
	return timer_service.drag_active(_owner_value("_board_controller"))


func drag_move_time_left() -> float:
	var timer_service: Variant = _owner_value("_combat_timer_service")
	if timer_service == null:
		return 0.0
	return timer_service.move_time_left(_owner_value("_board_controller"))


func on_board_drag_input_result(drag_result: Dictionary) -> void:
	handle_drag_input_result(drag_result)


func on_board_hovered_orb_changed(orb_id: int) -> void:
	_owner.call("_bind_mastery_preview_coordinator")
	_owner.get("_mastery_preview_coordinator").set_hovered_board_orb_id(orb_id)


func clear_combat_mastery_hover_state() -> void:
	_owner.call("_bind_mastery_preview_coordinator")
	_owner.get("_mastery_preview_coordinator").clear_hover_state()


func handle_drag_input_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	_owner.call("_bind_view_actions")
	var view_actions: Variant = _owner_value("_view_actions")
	var action := String(result.get("action", ""))
	if action == "start":
		clear_combat_mastery_hover_state()
		_owner.call("_bind_tutorial_router")
		_owner.get("_tutorial_router").bind_drag_flow()
		_owner.get("_tutorial_drag_flow").handle_start()
		var selected_orb_id := int(result.get("selected_orb_id", -1))
		var view: Variant = _owner_value("_view")
		if view != null:
			view.sync_timer_display(drag_move_time_left(), _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_ACTIVE)
		view_actions.set_status_text("Dragging %s orb. Move timer running." % OrbType.display_name(selected_orb_id))
		view_actions.set_status_color(_owner.CONTRACT.STATUS_COLOR_NEUTRAL)
		return
	if action == "end":
		_owner.call("_bind_tutorial_router")
		_owner.get("_tutorial_router").bind_drag_flow()
		_owner.get("_tutorial_drag_flow").handle_end(result)


func timer_ready_seconds() -> float:
	var timer_service: Variant = _owner_value("_combat_timer_service")
	if timer_service == null:
		return _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.MOVE_TIMER_MAX_SECONDS
	return timer_service.ready_seconds(_owner_value("_player_state"))


func abort_active_drag() -> void:
	var board_controller: Variant = _owner_value("_board_controller")
	if board_controller != null:
		board_controller.abort()
	var view: Variant = _owner_value("_view")
	if view != null:
		view.sync_timer_display(0.0, _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED)


func debug_set_input_phase(raw_phase: int) -> void:
	_owner.call("_set_input_phase", raw_phase)


func debug_set_pending_next_scene_path(scene_path: String) -> void:
	_owner.get("_model").set_pending_next_scene_path(scene_path)


func _owner_value(property_name: String) -> Variant:
	return _owner.get(property_name)
