extends RefCounted
class_name CombatControllerPresentationRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func apply_orb_texture_map_deferred() -> void:
	_driver().apply_orb_texture_map(_owner_value("_board_view"), _owner_value("_visuals"), RunState, _owner_callback("_flow_trace_route_id_value"))


func apply_visual_chrome() -> void:
	_driver().apply_visual_chrome(_owner_value("_view"), RunState)


func apply_vfx_speed_setting() -> void:
	var combat_vfx_presenter: Variant = _owner_value("_combat_vfx_presenter")
	if combat_vfx_presenter == null or not combat_vfx_presenter.has_method("set_post_match_vfx_speed_scale"):
		return
	var combat_speed := String(_owner.call("_combat_speed_value"))
	if combat_speed == _contract().COMBAT_SPEED_SLOW:
		combat_vfx_presenter.set_post_match_vfx_speed_scale(0.35)
	elif combat_speed == _contract().COMBAT_SPEED_FAST:
		combat_vfx_presenter.set_post_match_vfx_speed_scale(1.0)
	elif combat_speed == _contract().COMBAT_SPEED_INSTANT:
		combat_vfx_presenter.set_post_match_vfx_speed_scale(2.0)
	else:
		combat_vfx_presenter.set_post_match_vfx_speed_scale(0.55)


func play_resolve_animations(result: Dictionary, visual_board_model: BoardModel = null, resolve_trace_origin_usec: int = 0) -> void:
	_owner.call("_bind_mastery_preview_coordinator")
	var mastery_preview_coordinator: Variant = _owner_value("_mastery_preview_coordinator")
	await (
		_driver()
		. play_resolve_animations(
			_owner_value("_resolve_presenter"),
			result,
			visual_board_model,
			resolve_trace_origin_usec,
			{
				"trace_callback": Callable(self, "resolve_trace"),
				"combo_preview_callback": Callable(mastery_preview_coordinator, "preview_match_feedback_value"),
				"combo_feedback_callback": Callable(mastery_preview_coordinator, "show_match_feedback"),
				"set_pass_index_callback": Callable(_owner_value("_model"), "set_resolve_trace_pass_index"),
			}
		)
	)


func combat_speed_duration(base_seconds: float) -> float:
	var resolve_presenter: Variant = _owner_value("_resolve_presenter")
	if resolve_presenter != null:
		return resolve_presenter.combat_speed_duration(base_seconds)
	return base_seconds


func wait_combat_speed(base_seconds: float) -> void:
	await _driver().wait_combat_speed(_owner_value("_resolve_presenter"), _owner_value("_host"), base_seconds)


func can_continue_after_async_wait(require_board_view: bool = false) -> bool:
	return _driver().can_continue_after_async_wait(_owner_value("_host"), _owner_value("_board_view"), require_board_view)


func bind_vfx_target_resolver() -> void:
	_set_owner_value(
		"_vfx_target_resolver",
		_contract().COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_vfx_target_resolver(
			_owner_value("_vfx_target_resolver"), _contract().COMBAT_VFX_TARGET_RESOLVER_SCRIPT, _owner_value("_view"), _owner_value("_combat_vfx_presenter")
		)
	)


func spawn_vfx_texture(
	texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
) -> void:
	var combat_vfx_presenter: Variant = _owner_value("_combat_vfx_presenter")
	if combat_vfx_presenter != null:
		combat_vfx_presenter.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func apply_combat_layout() -> void:
	_driver().apply_combat_layout(
		_owner_value("_view"),
		_owner_value("_host"),
		_owner_value("_combat_timer_service"),
		_owner_value("_board_controller"),
		_owner_value("_player_state"),
		_owner_value("_tutorial_prompt_presenter"),
		_contract().COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_READY
	)


func refresh_character_portraits() -> void:
	var view: Variant = _owner_value("_view")
	if view != null:
		var enemy_state: Variant = _owner_value("_enemy_state")
		view.refresh_character_portraits(String(enemy_state.enemy_id if enemy_state != null else ""))


func resolve_trace(start_ticks_usec: int, message: String) -> void:
	_owner.call("_bind_resolve_trace_logger")
	_owner.get("_resolve_trace_logger").trace(start_ticks_usec, message)


func resolver_match_found(groups: Array) -> void:
	_owner.call("_bind_view_actions")
	_owner.call("_audio_router_callback", "play_sfx").call("match")
	var view_actions: Variant = _owner_value("_view_actions")
	view_actions.set_status_text("Matches found: %d group(s)." % groups.size())
	view_actions.set_status_color(_contract().STATUS_COLOR_WARNING)


func _owner_value(property_name: String) -> Variant:
	return _owner.get(property_name)


func _set_owner_value(property_name: String, value: Variant) -> void:
	_owner.set(property_name, value)


func _owner_callback(method_name: String) -> Callable:
	return Callable(_owner, method_name)


func _contract() -> Variant:
	return _owner.CONTRACT


func _driver() -> Variant:
	return _contract().COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT
