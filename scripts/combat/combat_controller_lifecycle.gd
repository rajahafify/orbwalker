extends RefCounted
class_name CombatControllerLifecycle

var _owner: Variant = null
var _view_actions: Variant = null
var _resolve_flow_coordinator: Variant = null
var _turn_preview_coordinator: Variant = null
var _signal_connector: Variant = null
var _ready_flow_binder: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner
	_view_actions = owner.get("_view_actions")


func _owner_value(property_name: String) -> Variant:
	return _owner.get(property_name)


func _set_owner_value(property_name: String, value: Variant) -> void:
	_owner.set(property_name, value)


func _contract() -> Variant:
	return _owner.CONTRACT


func _owner_callback(method_name: String) -> Callable:
	return Callable(_owner, method_name)


func _audio_router_callback(method_name: String) -> Callable:
	_owner.call("_bind_audio_router")
	return Callable(_owner.get("_audio_router"), method_name)


func _hud_update_callback(method_name: String) -> Callable:
	_owner.call("_bind_hud_update_router")
	return Callable(_owner.get("_hud_update_router"), method_name)


func _presentation_callback(method_name: String) -> Callable:
	_owner.call("_bind_presentation_router")
	return Callable(_owner.get("_presentation_router"), method_name)


func _input_callback(method_name: String) -> Callable:
	_owner.call("_bind_input_router")
	return Callable(_owner.get("_input_router"), method_name)


func _intent_callback(method_name: String) -> Callable:
	_owner.call("_bind_intent_router")
	return Callable(_owner.get("_intent_router"), method_name)


func _tutorial_callback(method_name: String) -> Callable:
	_owner.call("_bind_tutorial_router")
	return Callable(_owner.get("_tutorial_router"), method_name)


func ready() -> void:
	if _owner.get("_board_view") == null:
		push_error("CombatPlayerController._ready aborted because BoardView failed to resolve.")
		return
	_ensure_combat_route_id()
	_mark_flow("combat_ready_start")
	_audio_router_callback("play_music").call("combat")
	_mark_flow("combat_after_music")
	_owner.CONTRACT.COMBAT_CONTROLLER_RUNTIME_HELPER_FACTORY_SCRIPT.ensure_owner_helpers(_owner)
	_owner.call("_bind_outcome_overlay")
	_owner.call("_bind_boss_reward_handler")
	_ensure_ready_flow_binder()
	_owner.set(
		"_resolve_presenter",
		_ready_flow_binder.bind_resolve_presenter(_ready_flow_dependencies(), _ready_flow_callbacks(), {"combat_speed": _owner.call("_combat_speed_value")})
	)
	_owner.call("_bind_debug_console")
	_owner.call("_bind_settings_command_handler")
	var consumable_rng: Variant = _owner.get("_consumable_rng")
	if consumable_rng != null:
		consumable_rng.randomize()
	_ready_flow_binder.bootstrap_view(_ready_flow_dependencies(), _view_actions)
	_mark_flow("combat_texture_map_deferred")
	_mark_flow("combat_after_boss_outcome_controls")
	_owner.call("_bind_combat_vfx_presenter")
	_owner.call("_bind_board_controller")
	_mark_flow("combat_after_hud_bind")
	_presentation_callback("apply_visual_chrome").call()
	_mark_flow("combat_after_chrome")
	_owner.call("_bind_resolve_trace_logger")
	connect_signals()
	initialize_combat_state()
	_owner.call("_bind_loadout_command_handler")
	_mark_flow("combat_after_initialize_state")
	_owner.call("_bind_board_debug_router")
	_owner.get("_board_debug_router").create_new_board()
	_mark_flow("combat_after_board_create")
	_ready_flow_binder.activate_scene(_ready_flow_dependencies(), _ready_flow_callbacks())
	_mark_flow("combat_after_layout")
	begin_turn_preview()
	_mark_flow("combat_after_begin_turn_preview")


func _ensure_ready_flow_binder() -> void:
	if _ready_flow_binder == null:
		_ready_flow_binder = _contract().COMBAT_CONTROLLER_READY_FLOW_BINDER_SCRIPT.new()


func _ensure_combat_route_id() -> void:
	if _route_id() == "":
		_owner.call("_set_flow_trace_route_id", RunState.flow_trace_active_route_id())
	if _route_id() == "":
		_owner.call("_set_flow_trace_route_id", RunState.flow_trace_begin("combat_scene_load", "res://scenes/combat.tscn", {"source": "combat._ready"}))


func _route_id() -> String:
	return String(_owner.call("_flow_trace_route_id_value"))


func _mark_flow(step: String) -> void:
	RunState.flow_trace_mark(step, {}, _route_id())


func _ready_flow_dependencies() -> Dictionary:
	return {
		"resolve_presenter": _owner.get("_resolve_presenter"),
		"resolve_presenter_script": _owner.CONTRACT.COMBAT_RESOLVE_PRESENTER_SCRIPT,
		"board": _owner.get("_board"),
		"board_view": _owner.get("_board_view"),
		"board_controller": _owner.get("_board_controller"),
		"host": _owner.get("_host"),
		"view": _owner.get("_view"),
		"visuals": _owner.get("_visuals"),
		"player_loadout_hud": _owner.get("_player_loadout_hud"),
		"debug_console": _owner.get("_debug_console"),
		"outcome_overlay": _owner.get("_outcome_overlay"),
		"debug_runtime": _owner.get("_debug_runtime"),
	}


func _ready_flow_callbacks() -> Dictionary:
	return {
		"spawn_vfx_texture": _presentation_callback("spawn_vfx_texture"),
		"combo_sound": _audio_router_callback("play_match_clear"),
		"console_input_submitted": Callable(_owner, "_on_console_input_text_submitted"),
		"viewport_size_changed": Callable(_owner, "on_viewport_size_changed"),
		"apply_combat_layout": _presentation_callback("apply_combat_layout"),
		"trace_first_usable_frame": Callable(_owner, "_trace_flow_first_usable_frame"),
		"apply_orb_texture_map_deferred": _presentation_callback("apply_orb_texture_map_deferred"),
	}


func initialize_combat_state() -> void:
	_bind_state_initializer()
	_owner_value("_state_initializer").initialize()


func begin_turn_preview() -> void:
	_bind_turn_preview_coordinator()
	_turn_preview_coordinator.begin_turn_preview()


func end_drag(drag_result: Dictionary) -> void:
	_bind_resolve_flow_coordinator()
	await _resolve_flow_coordinator.end_drag(drag_result)


func connect_signals() -> void:
	_owner_callback("_bind_loadout_command_handler").call()
	_owner_callback("_bind_settings_command_handler").call()
	_owner_callback("_bind_tutorial_end_command_handler").call()
	_bind_signal_connector()
	_signal_connector.connect_all()


func _bind_state_initializer() -> void:
	(
		_owner_value("_state_initializer")
		. bind(
			{
				"run_state": RunState,
				"model": _owner_value("_model"),
				"host": _owner_value("_host"),
				"view_actions": _view_actions,
				"enemy_state_script": _contract().ENEMY_STATE_SCRIPT,
				"combat_state_machine_script": _contract().COMBAT_STATE_MACHINE_SCRIPT,
				"flow_result_utils": _contract().FLOW_RESULT_UTILS,
				"status_color_warning": _contract().STATUS_COLOR_WARNING,
			},
			{
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_APPLY_STATE: Callable(self, "_apply_initialized_combat_state"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_BIND_HUD_STAGE: _owner_callback("_bind_hud_stage_coordinator"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_REFRESH_CHARACTER_PORTRAITS:
				_presentation_callback("refresh_character_portraits"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_REFRESH_BUILD_ICON_ROWS: _hud_update_callback("refresh_build_icon_rows"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_UPDATE_HUD: _hud_update_callback("update_hud"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_BIND_DEBUG_STATE_PROVIDER: _owner_callback("_bind_debug_state_provider"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_ROUTE_ID: _owner_callback("_flow_trace_route_id_value"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_SCENE_ROLLBACK: _owner_callback("_on_combat_scene_post_ready_rollback"),
				_contract().COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_HANDLE_SCENE_CHANGE_FAILURE:
				_owner_callback("_handle_combat_scene_change_failure"),
				"debug_runtime": _owner_value("_debug_runtime"),
			}
		)
	)


func _apply_initialized_combat_state(state: Dictionary) -> void:
	_set_owner_value("_player_state", state.get("player_state"))
	_set_owner_value("_progression_state", state.get("progression_state"))
	_set_owner_value("_enemy_state", state.get("enemy_state"))
	_set_owner_value("_combat", state.get("combat"))


func _bind_resolve_flow_coordinator() -> void:
	if _resolve_flow_coordinator == null:
		_resolve_flow_coordinator = _contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.new()
	_owner_callback("_bind_mastery_preview_coordinator").call()
	_owner_callback("_bind_turn_resolution_coordinator").call()
	(
		_resolve_flow_coordinator
		. bind(
			{
				"model": _owner_value("_model"),
				"board_controller": _owner_value("_board_controller"),
				"board_view": _owner_value("_board_view"),
				"board_model": _owner_value("_board_model"),
				"resolver": _owner_value("_resolver"),
				"mastery_preview_coordinator": _owner_value("_mastery_preview_coordinator"),
				"turn_resolution_coordinator": _owner_value("_turn_resolution_coordinator"),
				"combat_modifiers": RunState.current_combat_modifiers(),
			},
			{
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_PLAY_SFX: _audio_router_callback("play_sfx"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_SYNC_TIMER_DISPLAY: Callable(self, "_sync_timer_display"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: _owner_callback("_set_input_phase"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_BIND_MASTERY_PREVIEW: _owner_callback("_bind_mastery_preview_coordinator"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_PLAY_RESOLVE_ANIMATIONS: _presentation_callback("play_resolve_animations"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: _presentation_callback("can_continue_after_async_wait"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_BIND_TURN_RESOLUTION: _owner_callback("_bind_turn_resolution_coordinator"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: _owner_callback("_input_phase_value"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_APPLY_BOARD_MODEL: Callable(self, "_apply_committed_board_model"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_RESOLVE_TRACE: _presentation_callback("resolve_trace"),
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_STORE_LAST_RESOLVE_RESULT: Callable(self, "_store_last_resolve_result"),
			},
			{
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
				"resolving_input_phase_value": int(_owner.InputPhase.RESOLVING),
				"timer_state_locked": _contract().COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED,
				"status_color_warning": _contract().STATUS_COLOR_WARNING,
			}
		)
	)


func _sync_timer_display(seconds_left: float, timer_state: int) -> void:
	var view: Variant = _owner_value("_view")
	if view != null:
		view.sync_timer_display(seconds_left, timer_state)


func _apply_committed_board_model(board_model: BoardModel) -> void:
	_set_owner_value("_board_model", board_model)


func _store_last_resolve_result(resolve_result: Dictionary) -> void:
	_set_owner_value("_last_resolve_result", resolve_result)


func _bind_signal_connector() -> void:
	if _signal_connector == null:
		_signal_connector = _contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.new()
	(
		_signal_connector
		. bind(
			{
				"resolver": _owner_value("_resolver"),
				"resolve_trace_logger": _owner_value("_resolve_trace_logger"),
				"player_loadout_hud": _owner_value("_player_loadout_hud"),
				"loadout_command_handler": _owner_value("_loadout_command_handler"),
				"view": _owner_value("_view"),
				"settings_command_handler": _owner_value("_settings_command_handler"),
				"tutorial_end_command_handler": _owner_value("_tutorial_end_command_handler"),
			},
			{
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_RESOLVER_MATCH_FOUND: _presentation_callback("resolver_match_found"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVERED:
				_intent_callback("intent_damage_preview_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_BLOCK_PREVIEW_HOVERED:
				_intent_callback("intent_block_preview_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED:
				_intent_callback("intent_damage_preview_hover_ended"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_INTENT_BUBBLE_HOVERED: _intent_callback("enemy_intent_bubble_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_BLOCK_PREVIEW_HOVERED: _intent_callback("enemy_block_preview_hovered"),
			}
		)
	)


func _bind_turn_preview_coordinator() -> void:
	if _turn_preview_coordinator == null:
		_turn_preview_coordinator = _contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.new()
	(
		_turn_preview_coordinator
		. bind(
			{
				"combat": _owner_value("_combat"),
				"enemy_state": _owner_value("_enemy_state"),
				"model": _owner_value("_model"),
				"view_actions": _view_actions,
				"run_state": RunState,
			},
			{
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: _owner_callback("_set_input_phase"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: _hud_update_callback("update_hud"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_CLEAR_MASTERY_HOVER: _input_callback("clear_combat_mastery_hover_state"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: _tutorial_callback("sync_coachmark"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_FORMAT_INTENT: _intent_callback("format_intent"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_SUMMARY_TEXT: _tutorial_callback("turn_summary_text"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_STATUS_TEXT: _tutorial_callback("turn_status_text"),
			},
			{
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
				"status_color_neutral": _contract().STATUS_COLOR_NEUTRAL,
			}
		)
	)
