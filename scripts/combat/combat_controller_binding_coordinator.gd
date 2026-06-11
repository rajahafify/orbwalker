extends RefCounted
class_name CombatControllerBindingCoordinator

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func bind_board_debug_command_handler() -> void:
	if _owner._board_debug_command_handler == null:
		_owner._board_debug_command_handler = _owner.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.new()
	(
		_owner
		. _board_debug_command_handler
		. bind(
			{
				"board_controller": _owner._board_controller,
				"board_model": _owner._board_model,
				"settings": _owner._settings,
				"combat": _owner._combat,
				"run_state": RunState,
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
			},
			{
				_owner.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(_owner, "_debug_set_input_phase"),
				_owner.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_owner, "_append_combat_log"),
				_owner.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: Callable(_owner, "_sync_tutorial_coachmark"),
			}
		)
	)


func bind_debug_console() -> void:
	if _owner._debug_runtime == null:
		_owner._debug_runtime = _owner.COMBAT_DEBUG_RUNTIME_SCRIPT.new()
	_owner._bind_debug_state_provider()
	(
		_owner
		. _debug_runtime
		. bind_for_combat_controller(
			_owner._view,
			_owner._turn_log_presenter,
			_owner,
			int(_owner.InputPhase.LOCKED_EXTERNAL),
			{
				"command_output_log_color": _owner.COMMAND_OUTPUT_LOG_COLOR,
				"max_combat_log_lines": _owner.MAX_COMBAT_LOG_LINES,
				"initial_log_level": _owner.LOG_LEVEL_NORMAL,
			},
			_owner._debug_state_provider.callbacks()
		)
	)
	_owner._debug_console = _owner._debug_runtime.console()


func bind_settings_command_handler() -> void:
	if _owner._settings_command_handler == null:
		_owner._settings_command_handler = _owner.COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT.new()
	var current_turn_index_provider := func() -> int: return int(_owner._combat.turn_index if _owner._combat != null else 1)
	var trace_and_change_scene := func(scene_path: String, trace_source: String, trace_mark: String) -> void:
		_owner._trace_and_change_scene_to_target(scene_path, _owner._flow_trace_route_id_value(), trace_source, trace_mark)
	_owner._settings_command_handler.bind_for_combat_controller(
		_owner._view,
		_owner._model,
		_owner._resolve_presenter,
		_owner,
		current_turn_index_provider,
		trace_and_change_scene,
		int(_owner.InputPhase.PLAYER_INPUT),
		int(_owner.InputPhase.LOCKED_EXTERNAL),
		_owner.STATUS_COLOR_NEUTRAL
	)


func bind_board_controller() -> void:
	if _owner._board_controller == null:
		return
	(
		_owner
		. _board_controller
		. bind(
			{
				"board_view": _owner._board_view,
				"board_model": _owner._board_model,
			},
			{
				"swap_animation_seconds": _owner.SWAP_ANIMATION_SECONDS,
				"swap_sound_callback": Callable(_owner, "_on_drag_swap_success"),
				"match_groups_callback": Callable(_owner, "_drag_match_groups"),
				"move_timer_seconds_callback": Callable(_owner, "_drag_move_timer_seconds"),
				"drag_input_result_callback": Callable(_owner, "_on_board_drag_input_result"),
				"hovered_orb_changed_callback": Callable(_owner, "_on_board_hovered_orb_changed"),
			}
		)
	)
	_owner._apply_feedback_settings()


func bind_input_command_handler() -> void:
	if _owner._input_command_handler == null:
		_owner._input_command_handler = _owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.new()
	(
		_owner
		. _input_command_handler
		. bind(
			{"view": _owner._view},
			{
				_owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_TOGGLE_DEBUG_OVERLAY: Callable(_owner, "_toggle_debug_overlay"),
				_owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_CREATE_NEW_BOARD: Callable(_owner, "_create_new_board"),
				_owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_PRINT_BOARD_MODEL: Callable(_owner, "_print_board_model"),
				_owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_TRY_USE_FIRST_CONSUMABLE: Callable(_owner, "_try_use_first_consumable"),
				_owner.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_INPUT_HANDLED: Callable(_owner, "_set_viewport_input_handled"),
			}
		)
	)


func bind_hud_snapshot_provider() -> void:
	if _owner._hud_snapshot_provider == null:
		_owner._hud_snapshot_provider = _owner.COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT.new()
	(
		_owner
		. _hud_snapshot_provider
		. bind(
			{
				"run_state": RunState,
				"model": _owner._model,
				"player_state": _owner._player_state,
				"enemy_state": _owner._enemy_state,
				"combat": _owner._combat,
				"view": _owner._view,
				"visuals": _owner._visuals,
				"turn_log_presenter": _owner._turn_log_presenter,
			},
			{
				"input_phase_value": Callable(_owner, "_input_phase_value"),
				"drag_active": Callable(_owner, "_drag_active"),
				"drag_move_time_left": Callable(_owner, "_drag_move_time_left"),
				"timer_ready_seconds": Callable(_owner, "_timer_ready_seconds"),
				"show_intent_preview": Callable(_owner, "_should_show_intent_damage_preview"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT)}
		)
	)


func bind_player_hud_refresh_coordinator() -> void:
	if _owner._player_hud_refresh_coordinator == null:
		_owner._player_hud_refresh_coordinator = _owner.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT.new()
	_owner._ensure_hud_presenter()
	_owner._bind_mastery_preview_coordinator()
	(
		_owner
		. _player_hud_refresh_coordinator
		. bind(
			{
				"model": _owner._model,
				"player_state": _owner._player_state,
				"enemy_state": _owner._enemy_state,
				"visuals": _owner._visuals,
				"view": _owner._view,
				"hud_presenter": _owner._hud_presenter,
				"mastery_preview_coordinator": _owner._mastery_preview_coordinator,
			},
			{
				_owner.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT.CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW:
				Callable(_owner, "_should_show_intent_damage_preview"),
			}
		)
	)


func bind_loadout_command_handler() -> void:
	if _owner._loadout_command_handler == null:
		_owner._loadout_command_handler = _owner.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.new()
	(
		_owner
		. _loadout_command_handler
		. bind(
			{
				"run_state": RunState,
				"combat": _owner._combat,
				"view": _owner._view,
				"board_controller": _owner._board_controller,
				"board_view": _owner._board_view,
				"board_model": _owner._board_model,
				"consumable_service": _owner._combat_consumable_service,
				"consumable_rng": _owner._consumable_rng,
			},
			{
				_owner.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_owner, "_append_combat_log"),
				_owner.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(_owner, "_update_hud"),
				_owner.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(_owner, "_input_phase_value"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT)}
		)
	)


func bind_intent_hover_handler() -> void:
	if _owner._intent_hover_handler == null:
		_owner._intent_hover_handler = _owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.new()
	_owner._bind_debug_state_provider()
	(
		_owner
		. _intent_hover_handler
		. bind(
			{"run_state": RunState, "combat": _owner._combat, "enemy_state": _owner._enemy_state, "model": _owner._model, "view": _owner._view},
			{
				_owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(_owner, "_input_phase_value"),
				_owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner, "_set_status_color"),
				_owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(_owner, "_set_turn_summary_text"),
				_owner.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_FORMAT_INTENT: Callable(_owner._debug_state_provider, "format_intent"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT), "warning_color": _owner.STATUS_COLOR_WARNING}
		)
	)


func bind_scene_transition_handler() -> void:
	if _owner._scene_transition_handler == null:
		_owner._scene_transition_handler = _owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.new()
	(
		_owner
		. _scene_transition_handler
		. bind(
			{"run_state": RunState, "scene_tree": _owner._host.get_tree() if _owner._host != null else null, "model": _owner._model},
			{
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(_owner, "_flow_trace_route_id_value"),
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_LOCK_EXTERNAL_INPUT: Callable(_owner, "_lock_scene_transition_input"),
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(_owner, "_show_outcome_summary"),
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner, "_set_status_color"),
				_owner.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_owner, "_append_combat_log"),
			},
			{"negative_color": _owner.STATUS_COLOR_NEGATIVE, "run_summary_scene": RunState.SCENE_RUN_SUMMARY}
		)
	)


func bind_outcome_route_coordinator() -> void:
	if _owner._outcome_route_coordinator == null:
		_owner._outcome_route_coordinator = _owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.new()
	(
		_owner
		. _outcome_route_coordinator
		. bind(
			{"run_state": RunState, "model": _owner._model, "enemy_state": _owner._enemy_state, "turn_log_presenter": _owner._turn_log_presenter},
			{
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_PLAY_SFX: Callable(_owner, "_audio_play_sfx"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: Callable(_owner, "_set_input_phase"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_APPEND_TURN_LOG: Callable(_owner, "_append_turn_log"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner, "_set_status_color"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_owner, "_append_combat_log"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SHOW_BOSS_REWARD_SUMMARY: Callable(_owner, "_show_boss_reward_summary"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(_owner, "_set_turn_summary_text"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(_owner, "_flow_trace_route_id_value"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_HIDE_OUTCOME_SUMMARY: Callable(_owner, "_hide_outcome_summary"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(_owner, "_trace_and_change_scene_to_target"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(_owner, "_show_outcome_summary"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_PULSE_TURN_SUMMARY: Callable(_owner, "_pulse_turn_summary"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_BEGIN_TURN_PREVIEW: Callable(_owner, "_begin_turn_preview"),
				_owner.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_BUILD_RUN_OUTCOME_SUMMARY: Callable(_owner, "_build_run_outcome_summary"),
			},
			{
				"victory_phase_value": int(_owner.COMBAT_PHASE_VICTORY),
				"defeat_phase_value": int(_owner.COMBAT_PHASE_DEFEAT),
				"locked_input_phase_value": int(_owner.InputPhase.LOCKED_EXTERNAL),
				"positive_color": _owner.STATUS_COLOR_POSITIVE,
				"negative_color": _owner.STATUS_COLOR_NEGATIVE,
				"default_victory_scene": "res://scenes/main_menu.tscn",
				"run_summary_scene": RunState.SCENE_RUN_SUMMARY,
			}
		)
	)


func bind_turn_resolution_coordinator() -> void:
	if _owner._turn_resolution_coordinator == null:
		_owner._turn_resolution_coordinator = _owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.new()
	_owner._bind_hud_stage_coordinator()
	_owner._bind_outcome_route_coordinator()
	(
		_owner
		. _turn_resolution_coordinator
		. bind(
			{
				"combat": _owner._combat,
				"model": _owner._model,
				"run_state": RunState,
				"hud_stage_coordinator": _owner._hud_stage_coordinator,
				"outcome_route_coordinator": _owner._outcome_route_coordinator,
			},
			{
				_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_REPLAY_TURN_RESOLUTION: Callable(_owner, "_replay_turn_resolution_from_log"),
				_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: Callable(_owner, "_can_continue_after_async_wait"),
				_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_SYNC_MASTERY_TOTALS: Callable(_owner, "_sync_combat_mastery_preview_totals"),
				_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: Callable(_owner, "_update_hud"),
				_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(_owner, "_flow_trace_route_id_value"),
			},
			{_owner.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CONFIG_RESOLVING_INPUT_PHASE_VALUE: int(_owner.InputPhase.RESOLVING)}
		)
	)


func bind_input_phase_router() -> void:
	if _owner._input_phase_router == null:
		_owner._input_phase_router = _owner.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.new()
	(
		_owner
		. _input_phase_router
		. bind(
			{"model": _owner._ensure_model(), "board_controller": _owner._board_controller},
			{
				_owner.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_CLEAR_HOVER_STATE: Callable(_owner, "_clear_combat_mastery_hover_state"),
				_owner.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_SYNC_MODEL_STATE: Callable(_owner, "_sync_model_state"),
			}
		)
	)


func apply_feedback_settings() -> void:
	_owner._apply_vfx_speed_setting()
	var raw_game_juice_flags := RunState.game_juice_flags()
	var effective_game_juice_flags := _effective_game_juice_flags_for_motion(raw_game_juice_flags)
	var refill_overshoot_enabled := (
		RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(_owner.GAME_JUICE_FLAGS_SCRIPT.GRAVITY_REFILL_OVERSHOOT, true))
	)
	if _owner._board_controller != null and _owner._board_controller.has_method("set_refill_overshoot_enabled"):
		_owner._board_controller.set_refill_overshoot_enabled(refill_overshoot_enabled)
	if _owner._combat_vfx_presenter != null:
		if _owner._combat_vfx_presenter.has_method("set_post_match_vfx_quality"):
			_owner._combat_vfx_presenter.set_post_match_vfx_quality(RunState.combat_vfx_quality())
		if _owner._combat_vfx_presenter.has_method("set_reduced_motion_enabled"):
			_owner._combat_vfx_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
		if _owner._combat_vfx_presenter.has_method("set_game_juice_enabled"):
			_owner._combat_vfx_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
		if _owner._combat_vfx_presenter.has_method("set_game_juice_flags"):
			_owner._combat_vfx_presenter.set_game_juice_flags(effective_game_juice_flags)
	if _owner._resolve_presenter != null and _owner._resolve_presenter.has_method("set_reduced_motion_enabled"):
		_owner._resolve_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
	if _owner._resolve_presenter != null and _owner._resolve_presenter.has_method("set_game_juice_enabled"):
		_owner._resolve_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
	if _owner._resolve_presenter != null and _owner._resolve_presenter.has_method("set_game_juice_flags"):
		_owner._resolve_presenter.set_game_juice_flags(effective_game_juice_flags)
	if _owner._combat_audio_cue_player != null and _owner._combat_audio_cue_player.has_method("set_game_juice_enabled"):
		_owner._combat_audio_cue_player.set_game_juice_enabled(RunState.game_juice_enabled())
	if _owner._combat_audio_cue_player != null and _owner._combat_audio_cue_player.has_method("set_game_juice_flags"):
		_owner._combat_audio_cue_player.set_game_juice_flags(raw_game_juice_flags)
	if _owner._view != null and _owner._view.has_method("set_enemy_reaction_settings"):
		_owner._view.set_enemy_reaction_settings(
			RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(_owner.GAME_JUICE_FLAGS_SCRIPT.ENEMY_REACTION_CHARACTER, true)),
			RunState.reduced_motion_enabled()
		)


func _effective_game_juice_flags_for_motion(flags: Dictionary) -> Dictionary:
	var effective: Dictionary = _owner.GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)
	if not RunState.reduced_motion_enabled():
		return effective
	for flag_key in _owner.GAME_JUICE_FLAGS_SCRIPT.all_keys():
		if _owner.GAME_JUICE_FLAGS_SCRIPT.is_motion_heavy(flag_key):
			effective[flag_key] = false
	return effective


func bind_tutorial_coachmark_coordinator() -> void:
	if _owner._tutorial_coachmark_coordinator == null:
		_owner._tutorial_coachmark_coordinator = _owner.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.new()
	_owner._bind_tutorial_prompt_presenter()
	(
		_owner
		. _tutorial_coachmark_coordinator
		. bind(
			{
				"run_state": RunState,
				"combat": _owner._combat,
				"tutorial_director": _owner._tutorial_director,
				"view": _owner._view,
				"board_view": _owner._board_view,
				"board_controller": _owner._board_controller,
				"prompt_presenter": _owner._tutorial_prompt_presenter,
			},
			{
				_owner.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(_owner, "_input_phase_value"),
				_owner.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner, "_set_status_color"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT), "warning_status_color": _owner.STATUS_COLOR_WARNING}
		)
	)


func bind_tutorial_drag_flow() -> void:
	if _owner._tutorial_drag_flow == null:
		_owner._tutorial_drag_flow = _owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.new()
	_owner._bind_tutorial_coachmark_coordinator()
	(
		_owner
		. _tutorial_drag_flow
		. bind(
			{
				"board_model": _owner._board_model,
				"board_controller": _owner._board_controller,
				"tutorial_director": _owner._tutorial_director,
				"coachmark_coordinator": _owner._tutorial_coachmark_coordinator,
			},
			{
				_owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_END_DRAG: Callable(_owner, "_end_drag"),
				_owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_BOARD_SEED: Callable(_owner, "_set_board_seed"),
				_owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner, "_set_status_text"),
				_owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner, "_set_status_color"),
				_owner.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_BOARD_MODEL_CHANGED: Callable(_owner, "_set_board_model_from_tutorial_drag_flow"),
			},
			{"warning_status_color": _owner.STATUS_COLOR_WARNING}
		)
	)
