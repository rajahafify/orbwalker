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


func ready() -> void:
	if _owner.get("_board_view") == null:
		push_error("CombatPlayerController._ready aborted because BoardView failed to resolve.")
		return
	_ensure_combat_route_id()
	_mark_flow("combat_ready_start")
	_audio_router_callback("play_music").call("combat")
	_mark_flow("combat_after_music")
	ensure_runtime_helpers()
	_owner.call("_bind_outcome_overlay")
	_owner.call("_bind_boss_reward_handler")
	_ensure_ready_flow_binder()
	_owner.set("_resolve_presenter", _ready_flow_binder.bind_resolve_presenter(_ready_flow_dependencies(), _ready_flow_callbacks(), _ready_flow_config()))
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


func _ready_flow_config() -> Dictionary:
	return {"combat_speed": _owner.call("_combat_speed_value")}


func ensure_runtime_helpers() -> void:
	var helpers: Dictionary = _owner.CONTRACT.COMBAT_CONTROLLER_RUNTIME_HELPER_FACTORY_SCRIPT.ensure_helpers(
		_runtime_helper_values(), _runtime_helper_scripts()
	)
	_apply_runtime_helper_values(helpers)
	var player_loadout_hud: Variant = _owner_value("_player_loadout_hud")
	if player_loadout_hud != null:
		player_loadout_hud.set_visual_registry(_owner_value("_visuals"))
	var debug_runtime: Variant = _owner_value("_debug_runtime")
	if debug_runtime != null:
		_set_owner_value("_debug_console", debug_runtime.console())
	_owner_callback("_bind_audio_router").call()
	_owner_callback("_bind_debug_state_provider").call()
	var combat_consumable_service: Variant = _owner_value("_combat_consumable_service")
	if combat_consumable_service != null and combat_consumable_service.has_method("bind"):
		combat_consumable_service.bind({"convert_random_non_target_orbs": _owner_callback("_convert_random_non_target_orbs")})


func _runtime_helper_values() -> Dictionary:
	return {
		"visuals": _owner.get("_visuals"),
		"player_loadout_hud": _owner.get("_player_loadout_hud"),
		"outcome_overlay": _owner.get("_outcome_overlay"),
		"turn_log_presenter": _owner.get("_turn_log_presenter"),
		"debug_runtime": _owner.get("_debug_runtime"),
		"settings_command_handler": _owner.get("_settings_command_handler"),
		"combat_timer_service": _owner.get("_combat_timer_service"),
		"boss_reward_handler": _owner.get("_boss_reward_handler"),
		"combat_vfx_presenter": _owner.get("_combat_vfx_presenter"),
		"board_controller": _owner.get("_board_controller"),
		"hud_presenter": _owner.get("_hud_presenter"),
		"hud_snapshot_provider": _owner.get("_hud_snapshot_provider"),
		"vfx_target_resolver": _owner.get("_vfx_target_resolver"),
		"hud_stage_coordinator": _owner.get("_hud_stage_coordinator"),
		"mastery_preview_coordinator": _owner.get("_mastery_preview_coordinator"),
		"player_hud_refresh_coordinator": _owner.get("_player_hud_refresh_coordinator"),
		"loadout_command_handler": _owner.get("_loadout_command_handler"),
		"intent_hover_handler": _owner.get("_intent_hover_handler"),
		"scene_transition_handler": _owner.get("_scene_transition_handler"),
		"outcome_route_coordinator": _owner.get("_outcome_route_coordinator"),
		"turn_resolution_coordinator": _owner.get("_turn_resolution_coordinator"),
		"tutorial_prompt_presenter": _owner.get("_tutorial_prompt_presenter"),
		"tutorial_coachmark_coordinator": _owner.get("_tutorial_coachmark_coordinator"),
		"tutorial_end_command_handler": _owner.get("_tutorial_end_command_handler"),
		"tutorial_drag_flow": _owner.get("_tutorial_drag_flow"),
		"resolve_trace_logger": _owner.get("_resolve_trace_logger"),
		"turn_replay_coordinator": _owner.get("_turn_replay_coordinator"),
		"state_initializer": _owner.get("_state_initializer"),
		"combat_consumable_service": _owner.get("_combat_consumable_service"),
		"board_debug_command_handler": _owner.get("_board_debug_command_handler"),
		"input_command_handler": _owner.get("_input_command_handler"),
		"tutorial_director": _owner.get("_tutorial_director"),
	}


func _runtime_helper_scripts() -> Dictionary:
	return {
		"VISUAL_REGISTRY_SCRIPT": _owner.CONTRACT.VISUAL_REGISTRY_SCRIPT,
		"PLAYER_LOADOUT_HUD_SCRIPT": _owner.CONTRACT.PLAYER_LOADOUT_HUD_SCRIPT,
		"COMBAT_OUTCOME_OVERLAY_SCRIPT": _owner.CONTRACT.COMBAT_OUTCOME_OVERLAY_SCRIPT,
		"COMBAT_TURN_LOG_PRESENTER_SCRIPT": _owner.CONTRACT.COMBAT_TURN_LOG_PRESENTER_SCRIPT,
		"COMBAT_DEBUG_RUNTIME_SCRIPT": _owner.CONTRACT.COMBAT_DEBUG_RUNTIME_SCRIPT,
		"COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT,
		"COMBAT_TIMER_SERVICE_SCRIPT": _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT,
		"COMBAT_BOSS_REWARD_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_BOSS_REWARD_HANDLER_SCRIPT,
		"COMBAT_VFX_PRESENTER_SCRIPT": _owner.CONTRACT.COMBAT_VFX_PRESENTER_SCRIPT,
		"BOARD_CONTROLLER_SCRIPT": _owner.CONTRACT.BOARD_CONTROLLER_SCRIPT,
		"COMBAT_HUD_PRESENTER_SCRIPT": _owner.CONTRACT.COMBAT_HUD_PRESENTER_SCRIPT,
		"COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT": _owner.CONTRACT.COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT,
		"COMBAT_VFX_TARGET_RESOLVER_SCRIPT": _owner.CONTRACT.COMBAT_VFX_TARGET_RESOLVER_SCRIPT,
		"COMBAT_HUD_STAGE_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_HUD_STAGE_COORDINATOR_SCRIPT,
		"COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT,
		"COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT,
		"COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT,
		"COMBAT_INTENT_HOVER_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_INTENT_HOVER_HANDLER_SCRIPT,
		"COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT,
		"COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT,
		"COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT,
		"COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT": _owner.CONTRACT.COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT,
		"COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT,
		"COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT,
		"COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT": _owner.CONTRACT.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT,
		"COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT": _owner.CONTRACT.COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT,
		"COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT": _owner.CONTRACT.COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT,
		"COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT": _owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT,
		"COMBAT_CONSUMABLE_SERVICE_SCRIPT": _owner.CONTRACT.COMBAT_CONSUMABLE_SERVICE_SCRIPT,
		"COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT,
		"COMBAT_INPUT_COMMAND_HANDLER_SCRIPT": _owner.CONTRACT.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT,
		"COMBAT_GUIDANCE_DIRECTOR_SCRIPT": _owner.CONTRACT.COMBAT_GUIDANCE_DIRECTOR_SCRIPT,
	}


func _apply_runtime_helper_values(helpers: Dictionary) -> void:
	_owner.set("_visuals", helpers.get("visuals"))
	_owner.set("_player_loadout_hud", helpers.get("player_loadout_hud"))
	_owner.set("_outcome_overlay", helpers.get("outcome_overlay"))
	_owner.set("_turn_log_presenter", helpers.get("turn_log_presenter"))
	_owner.set("_debug_runtime", helpers.get("debug_runtime"))
	_owner.set("_settings_command_handler", helpers.get("settings_command_handler"))
	_owner.set("_combat_timer_service", helpers.get("combat_timer_service"))
	_owner.set("_boss_reward_handler", helpers.get("boss_reward_handler"))
	_owner.set("_combat_vfx_presenter", helpers.get("combat_vfx_presenter"))
	_owner.set("_board_controller", helpers.get("board_controller"))
	_owner.set("_hud_presenter", helpers.get("hud_presenter"))
	_owner.set("_hud_snapshot_provider", helpers.get("hud_snapshot_provider"))
	_owner.set("_vfx_target_resolver", helpers.get("vfx_target_resolver"))
	_owner.set("_hud_stage_coordinator", helpers.get("hud_stage_coordinator"))
	_owner.set("_mastery_preview_coordinator", helpers.get("mastery_preview_coordinator"))
	_owner.set("_player_hud_refresh_coordinator", helpers.get("player_hud_refresh_coordinator"))
	_owner.set("_loadout_command_handler", helpers.get("loadout_command_handler"))
	_owner.set("_intent_hover_handler", helpers.get("intent_hover_handler"))
	_owner.set("_scene_transition_handler", helpers.get("scene_transition_handler"))
	_owner.set("_outcome_route_coordinator", helpers.get("outcome_route_coordinator"))
	_owner.set("_turn_resolution_coordinator", helpers.get("turn_resolution_coordinator"))
	_owner.set("_tutorial_prompt_presenter", helpers.get("tutorial_prompt_presenter"))
	_owner.set("_tutorial_coachmark_coordinator", helpers.get("tutorial_coachmark_coordinator"))
	_owner.set("_tutorial_end_command_handler", helpers.get("tutorial_end_command_handler"))
	_owner.set("_tutorial_drag_flow", helpers.get("tutorial_drag_flow"))
	_owner.set("_resolve_trace_logger", helpers.get("resolve_trace_logger"))
	_owner.set("_turn_replay_coordinator", helpers.get("turn_replay_coordinator"))
	_owner.set("_state_initializer", helpers.get("state_initializer"))
	_owner.set("_combat_consumable_service", helpers.get("combat_consumable_service"))
	_owner.set("_board_debug_command_handler", helpers.get("board_debug_command_handler"))
	_owner.set("_input_command_handler", helpers.get("input_command_handler"))
	_owner.set("_tutorial_director", helpers.get("tutorial_director"))


func initialize_combat_state() -> void:
	_bind_state_initializer()
	_owner_value("_state_initializer").initialize()


func begin_turn_preview() -> void:
	_bind_turn_preview_coordinator()
	_turn_preview_coordinator.begin_turn_preview()


func end_drag(timed_out: bool) -> void:
	_bind_resolve_flow_coordinator()
	await _resolve_flow_coordinator.end_drag(timed_out)


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
				_contract().COMBAT_RESOLVE_FLOW_COORDINATOR_SCRIPT.CALLBACK_RESOLVE_TRACE: _owner_callback("_resolve_trace"),
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
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_RESOLVER_MATCH_FOUND: _owner_callback("_on_resolver_match_found"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVERED:
				_owner_callback("_on_intent_damage_preview_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_BLOCK_PREVIEW_HOVERED:
				_owner_callback("_on_intent_block_preview_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED:
				_owner_callback("_on_intent_damage_preview_hover_ended"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_INTENT_BUBBLE_HOVERED:
				_owner_callback("_on_enemy_intent_bubble_hovered"),
				_contract().COMBAT_CONTROLLER_SIGNAL_CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_BLOCK_PREVIEW_HOVERED:
				_owner_callback("_on_enemy_block_preview_hovered"),
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
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: _owner_callback("_sync_tutorial_coachmark"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_FORMAT_INTENT: _owner_callback("_format_intent"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_SUMMARY_TEXT: _owner_callback("_tutorial_turn_summary_text"),
				_contract().COMBAT_TURN_PREVIEW_COORDINATOR_SCRIPT.CALLBACK_TUTORIAL_TURN_STATUS_TEXT: _owner_callback("_tutorial_turn_status_text"),
			},
			{
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
				"status_color_neutral": _contract().STATUS_COLOR_NEUTRAL,
			}
		)
	)
