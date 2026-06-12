extends RefCounted
class_name CombatControllerBindingCoordinator

const DEBUG_CALLBACK_KEYS := preload("res://scripts/combat/combat_debug_callback_keys.gd")

var _owner: Variant = null
var _view_actions: Variant = null
var _setup_binder: Variant = null


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


func _board_debug_callback(method_name: String) -> Callable:
	_owner.call("_bind_board_debug_router")
	return Callable(_owner.get("_board_debug_router"), method_name)


func _presentation_callback(method_name: String) -> Callable:
	_owner.call("_bind_presentation_router")
	return Callable(_owner.get("_presentation_router"), method_name)


func _input_callback(method_name: String) -> Callable:
	_owner.call("_bind_input_router")
	return Callable(_owner.get("_input_router"), method_name)


func _ensure_setup_binder() -> void:
	if _setup_binder == null:
		_setup_binder = _contract().COMBAT_CONTROLLER_SETUP_BINDER_SCRIPT.new()


func bind_board_debug_command_handler() -> void:
	var contract: Variant = _contract()
	if _owner_value("_board_debug_command_handler") == null:
		_set_owner_value("_board_debug_command_handler", contract.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.new())
	var handler: Variant = _owner_value("_board_debug_command_handler")
	(
		handler
		. bind(
			{
				"board_controller": _owner_value("_board_controller"),
				"board_model": _owner_value("_board_model"),
				"settings": _owner_value("_settings"),
				"combat": _owner_value("_combat"),
				"run_state": RunState,
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
			},
			{
				contract.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_INPUT_PHASE: _owner_callback("_debug_set_input_phase"),
				contract.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_view_actions, "append_combat_log"),
				contract.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.CALLBACK_SYNC_TUTORIAL_COACHMARK: _owner_callback("_sync_tutorial_coachmark"),
			}
		)
	)


func bind_debug_console() -> void:
	var contract: Variant = _contract()
	_ensure_setup_binder()
	_owner_callback("_bind_debug_state_provider").call()
	var debug_state_provider: Variant = _owner_value("_debug_state_provider")
	var debug_state_callbacks: Dictionary = debug_state_provider.callbacks() if debug_state_provider != null else {}
	var action_callbacks := DEBUG_CALLBACK_KEYS.controller_action_callbacks(_owner)
	var result: Variant = (
		_setup_binder
		. bind_debug_console(
			{
				"debug_runtime": _owner_value("_debug_runtime"),
				"debug_runtime_script": contract.COMBAT_DEBUG_RUNTIME_SCRIPT,
				"view": _owner_value("_view"),
				"turn_log_presenter": _owner_value("_turn_log_presenter"),
				"action_callbacks": action_callbacks,
				"debug_state_callbacks": debug_state_callbacks,
			},
			{},
			{
				"locked_external_phase_value": int(_owner.InputPhase.LOCKED_EXTERNAL),
				"command_output_log_color": contract.COMMAND_OUTPUT_LOG_COLOR,
				"max_combat_log_lines": contract.MAX_COMBAT_LOG_LINES,
				"initial_log_level": contract.LOG_LEVEL_NORMAL,
			}
		)
	)
	if result is Dictionary:
		_set_owner_value("_debug_runtime", result.get("debug_runtime"))
		_set_owner_value("_debug_console", result.get("debug_console"))


func bind_settings_command_handler() -> void:
	var contract: Variant = _contract()
	_ensure_setup_binder()
	var current_turn_index_provider := func() -> int:
		var combat: Variant = _owner_value("_combat")
		return int(combat.turn_index if combat != null else 1)
	var trace_and_change_scene := func(scene_path: String, trace_source: String, trace_mark: String) -> void:
		_owner_callback("_trace_and_change_scene_to_target").call(scene_path, _owner_callback("_flow_trace_route_id_value").call(), trace_source, trace_mark)
	var handler: Variant = (
		_setup_binder
		. bind_settings_command_handler(
			{
				"settings_command_handler": _owner_value("_settings_command_handler"),
				"settings_command_handler_script": contract.COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT,
				"view": _owner_value("_view"),
				"model": _owner_value("_model"),
				"resolve_presenter": _owner_value("_resolve_presenter"),
				"settings_owner": _owner,
			},
			{"current_turn_index_provider": current_turn_index_provider, "trace_and_change_scene": trace_and_change_scene},
			{
				"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT),
				"locked_external_phase_value": int(_owner.InputPhase.LOCKED_EXTERNAL),
				"status_color_neutral": contract.STATUS_COLOR_NEUTRAL,
			}
		)
	)
	_set_owner_value("_settings_command_handler", handler)


func bind_board_controller() -> void:
	var contract: Variant = _contract()
	_ensure_setup_binder()
	(
		_setup_binder
		. bind_board_controller(
			{
				"board_controller": _owner_value("_board_controller"),
				"board_view": _owner_value("_board_view"),
				"board_model": _owner_value("_board_model"),
			},
			{
				"swap_sound": _audio_router_callback("play_sfx").bind("swap"),
				"match_groups": _input_callback("drag_match_groups"),
				"move_timer_seconds": _input_callback("drag_move_timer_seconds"),
				"drag_input_result": _input_callback("on_board_drag_input_result"),
				"hovered_orb_changed": _input_callback("on_board_hovered_orb_changed"),
				"apply_feedback_settings": _owner_callback("_apply_feedback_settings"),
			},
			{"swap_animation_seconds": contract.SWAP_ANIMATION_SECONDS}
		)
	)


func bind_input_command_handler() -> void:
	var contract: Variant = _contract()
	if _owner_value("_input_command_handler") == null:
		_set_owner_value("_input_command_handler", contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.new())
	bind_loadout_command_handler()
	var loadout_command_handler: Variant = _owner.get("_loadout_command_handler")
	(
		_owner_value("_input_command_handler")
		. bind(
			{"view": _owner_value("_view")},
			{
				contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_TOGGLE_DEBUG_OVERLAY: _input_callback("toggle_debug_overlay"),
				contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_CREATE_NEW_BOARD: _board_debug_callback("create_new_board"),
				contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_PRINT_BOARD_MODEL: _board_debug_callback("print_board_model"),
				contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_TRY_USE_FIRST_CONSUMABLE: Callable(loadout_command_handler, "try_use_first_consumable"),
				contract.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_INPUT_HANDLED: _input_callback("set_viewport_input_handled"),
			}
		)
	)


func bind_player_hud_refresh_coordinator() -> void:
	var contract: Variant = _contract()
	if _owner_value("_player_hud_refresh_coordinator") == null:
		_set_owner_value("_player_hud_refresh_coordinator", contract.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT.new())
	_hud_update_callback("ensure_hud_presenter").call()
	Callable(_owner, "_bind_mastery_preview_coordinator").call()
	var mastery_preview_coordinator: Variant = _owner.get("_mastery_preview_coordinator")
	(
		_owner_value("_player_hud_refresh_coordinator")
		. bind(
			{
				"model": _owner_value("_model"),
				"player_state": _owner_value("_player_state"),
				"enemy_state": _owner_value("_enemy_state"),
				"visuals": _owner_value("_visuals"),
				"view": _owner_value("_view"),
				"hud_presenter": _owner_value("_hud_presenter"),
				"mastery_preview_coordinator": mastery_preview_coordinator,
			},
			{
				contract.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT.CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW:
				_owner_callback("_should_show_intent_damage_preview"),
			}
		)
	)


func bind_loadout_command_handler() -> void:
	var contract: Variant = _contract()
	if _owner_value("_loadout_command_handler") == null:
		_set_owner_value("_loadout_command_handler", contract.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.new())
	(
		_owner_value("_loadout_command_handler")
		. bind(
			{
				"run_state": RunState,
				"combat": _owner_value("_combat"),
				"view": _owner_value("_view"),
				"board_controller": _owner_value("_board_controller"),
				"board_view": _owner_value("_board_view"),
				"board_model": _owner_value("_board_model"),
				"consumable_service": _owner_value("_combat_consumable_service"),
				"consumable_rng": _owner_value("_consumable_rng"),
			},
			{
				contract.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_view_actions, "append_combat_log"),
				contract.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: _hud_update_callback("update_hud"),
				contract.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: _owner_callback("_input_phase_value"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT)}
		)
	)


func bind_intent_hover_handler() -> void:
	var contract: Variant = _contract()
	if _owner_value("_intent_hover_handler") == null:
		_set_owner_value("_intent_hover_handler", contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.new())
	_owner_callback("_bind_debug_state_provider").call()
	(
		_owner_value("_intent_hover_handler")
		. bind(
			{
				"run_state": RunState,
				"combat": _owner_value("_combat"),
				"enemy_state": _owner_value("_enemy_state"),
				"model": _owner_value("_model"),
				"view": _owner_value("_view"),
			},
			{
				contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: _owner_callback("_input_phase_value"),
				contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
				contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(_view_actions, "set_turn_summary_text"),
				contract.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_FORMAT_INTENT: Callable(_owner_value("_debug_state_provider"), "format_intent"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT), "warning_color": contract.STATUS_COLOR_WARNING}
		)
	)


func bind_scene_transition_handler() -> void:
	var contract: Variant = _contract()
	if _owner_value("_scene_transition_handler") == null:
		_set_owner_value("_scene_transition_handler", contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.new())
	var host: Variant = _owner_value("_host")
	(
		_owner_value("_scene_transition_handler")
		. bind(
			{"run_state": RunState, "scene_tree": host.get_tree() if host != null else null, "model": _owner_value("_model")},
			{
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: _owner_callback("_flow_trace_route_id_value"),
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_LOCK_EXTERNAL_INPUT: _owner_callback("_lock_scene_transition_input"),
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(_view_actions, "show_outcome_summary"),
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
				contract.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_view_actions, "append_combat_log"),
			},
			{"negative_color": contract.STATUS_COLOR_NEGATIVE, "run_summary_scene": RunState.SCENE_RUN_SUMMARY}
		)
	)


func bind_outcome_route_coordinator() -> void:
	var contract: Variant = _contract()
	if _owner_value("_outcome_route_coordinator") == null:
		_set_owner_value("_outcome_route_coordinator", contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.new())
	(
		_owner_value("_outcome_route_coordinator")
		. bind(
			{
				"run_state": RunState,
				"model": _owner_value("_model"),
				"enemy_state": _owner_value("_enemy_state"),
				"turn_log_presenter": _owner_value("_turn_log_presenter")
			},
			{
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_PLAY_SFX: _audio_router_callback("play_sfx"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_INPUT_PHASE: _owner_callback("_set_input_phase"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_APPEND_TURN_LOG: _owner_callback("_append_turn_log"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(_view_actions, "append_combat_log"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SHOW_BOSS_REWARD_SUMMARY: Callable(_view_actions, "show_boss_reward_summary"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(_view_actions, "set_turn_summary_text"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: _owner_callback("_flow_trace_route_id_value"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_HIDE_OUTCOME_SUMMARY: Callable(_view_actions, "hide_outcome_summary"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: _owner_callback("_trace_and_change_scene_to_target"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(_view_actions, "show_outcome_summary"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_PULSE_TURN_SUMMARY: Callable(_view_actions, "pulse_turn_summary"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_BEGIN_TURN_PREVIEW: _owner_callback("_begin_turn_preview"),
				contract.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.CALLBACK_BUILD_RUN_OUTCOME_SUMMARY: _owner_callback("_build_run_outcome_summary"),
			},
			{
				"victory_phase_value": int(contract.COMBAT_PHASE_VICTORY),
				"defeat_phase_value": int(contract.COMBAT_PHASE_DEFEAT),
				"locked_input_phase_value": int(_owner.InputPhase.LOCKED_EXTERNAL),
				"positive_color": contract.STATUS_COLOR_POSITIVE,
				"negative_color": contract.STATUS_COLOR_NEGATIVE,
				"default_victory_scene": "res://scenes/main_menu.tscn",
				"run_summary_scene": RunState.SCENE_RUN_SUMMARY,
			}
		)
	)


func bind_turn_resolution_coordinator() -> void:
	var contract: Variant = _contract()
	if _owner_value("_turn_resolution_coordinator") == null:
		_set_owner_value("_turn_resolution_coordinator", contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.new())
	_owner_callback("_bind_hud_stage_coordinator").call()
	Callable(_owner, "_bind_mastery_preview_coordinator").call()
	var mastery_preview_coordinator: Variant = _owner.get("_mastery_preview_coordinator")
	_owner_callback("_bind_outcome_route_coordinator").call()
	(
		_owner_value("_turn_resolution_coordinator")
		. bind(
			{
				"combat": _owner_value("_combat"),
				"model": _owner_value("_model"),
				"run_state": RunState,
				"hud_stage_coordinator": _owner_value("_hud_stage_coordinator"),
				"outcome_route_coordinator": _owner_value("_outcome_route_coordinator"),
			},
			{
				contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_REPLAY_TURN_RESOLUTION: _owner_callback("_replay_turn_resolution_from_log"),
				contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_CAN_CONTINUE: _presentation_callback("can_continue_after_async_wait"),
				contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_SYNC_MASTERY_TOTALS: Callable(mastery_preview_coordinator, "sync_totals"),
				contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: _hud_update_callback("update_hud"),
				contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: _owner_callback("_flow_trace_route_id_value"),
			},
			{contract.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.CONFIG_RESOLVING_INPUT_PHASE_VALUE: int(_owner.InputPhase.RESOLVING)}
		)
	)


func bind_input_phase_router() -> void:
	var contract: Variant = _contract()
	if _owner_value("_input_phase_router") == null:
		_set_owner_value("_input_phase_router", contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.new())
	(
		_owner_value("_input_phase_router")
		. bind(
			{"model": _owner_callback("_ensure_model").call(), "board_controller": _owner_value("_board_controller")},
			{
				contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_CLEAR_HOVER_STATE: _input_callback("clear_combat_mastery_hover_state"),
				contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_SYNC_MODEL_STATE: _owner_callback("_sync_model_state"),
				contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_DRAG_ACTIVE: _input_callback("drag_active"),
				contract.COMBAT_INPUT_PHASE_ROUTER_SCRIPT.CALLBACK_ABORT_ACTIVE_DRAG: _input_callback("abort_active_drag"),
			}
		)
	)


func apply_feedback_settings() -> void:
	var contract: Variant = _contract()
	_presentation_callback("apply_vfx_speed_setting").call()
	var raw_game_juice_flags := RunState.game_juice_flags()
	var effective_game_juice_flags := _effective_game_juice_flags_for_motion(raw_game_juice_flags)
	var refill_overshoot_enabled := (
		RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(contract.GAME_JUICE_FLAGS_SCRIPT.GRAVITY_REFILL_OVERSHOOT, true))
	)
	var board_controller: Variant = _owner_value("_board_controller")
	if board_controller != null and board_controller.has_method("set_refill_overshoot_enabled"):
		board_controller.set_refill_overshoot_enabled(refill_overshoot_enabled)
	var combat_vfx_presenter: Variant = _owner_value("_combat_vfx_presenter")
	if combat_vfx_presenter != null:
		if combat_vfx_presenter.has_method("set_post_match_vfx_quality"):
			combat_vfx_presenter.set_post_match_vfx_quality(RunState.combat_vfx_quality())
		if combat_vfx_presenter.has_method("set_reduced_motion_enabled"):
			combat_vfx_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
		if combat_vfx_presenter.has_method("set_game_juice_enabled"):
			combat_vfx_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
		if combat_vfx_presenter.has_method("set_game_juice_flags"):
			combat_vfx_presenter.set_game_juice_flags(effective_game_juice_flags)
	var resolve_presenter: Variant = _owner_value("_resolve_presenter")
	if resolve_presenter != null and resolve_presenter.has_method("set_reduced_motion_enabled"):
		resolve_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
	if resolve_presenter != null and resolve_presenter.has_method("set_game_juice_enabled"):
		resolve_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
	if resolve_presenter != null and resolve_presenter.has_method("set_game_juice_flags"):
		resolve_presenter.set_game_juice_flags(effective_game_juice_flags)
	var combat_audio_cue_player: Variant = _owner_value("_combat_audio_cue_player")
	if combat_audio_cue_player != null and combat_audio_cue_player.has_method("set_game_juice_enabled"):
		combat_audio_cue_player.set_game_juice_enabled(RunState.game_juice_enabled())
	if combat_audio_cue_player != null and combat_audio_cue_player.has_method("set_game_juice_flags"):
		combat_audio_cue_player.set_game_juice_flags(raw_game_juice_flags)
	var view: Variant = _owner_value("_view")
	if view != null and view.has_method("set_enemy_reaction_settings"):
		view.set_enemy_reaction_settings(
			RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(contract.GAME_JUICE_FLAGS_SCRIPT.ENEMY_REACTION_CHARACTER, true)),
			RunState.reduced_motion_enabled()
		)


func _effective_game_juice_flags_for_motion(flags: Dictionary) -> Dictionary:
	var game_juice_flags_script: Variant = _contract().GAME_JUICE_FLAGS_SCRIPT
	var effective: Dictionary = game_juice_flags_script.normalized_flags(flags)
	if not RunState.reduced_motion_enabled():
		return effective
	for flag_key in game_juice_flags_script.all_keys():
		if game_juice_flags_script.is_motion_heavy(flag_key):
			effective[flag_key] = false
	return effective


func bind_tutorial_coachmark_coordinator() -> void:
	var contract: Variant = _contract()
	if _owner_value("_tutorial_coachmark_coordinator") == null:
		_set_owner_value("_tutorial_coachmark_coordinator", contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.new())
	_owner_callback("_bind_tutorial_prompt_presenter").call()
	(
		_owner_value("_tutorial_coachmark_coordinator")
		. bind(
			{
				"run_state": RunState,
				"combat": _owner_value("_combat"),
				"tutorial_director": _owner_value("_tutorial_director"),
				"view": _owner_value("_view"),
				"board_view": _owner_value("_board_view"),
				"board_controller": _owner_value("_board_controller"),
				"prompt_presenter": _owner_value("_tutorial_prompt_presenter"),
			},
			{
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: _owner_callback("_input_phase_value"),
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT), "warning_status_color": contract.STATUS_COLOR_WARNING}
		)
	)


func bind_tutorial_drag_flow() -> void:
	var contract: Variant = _contract()
	if _owner_value("_tutorial_drag_flow") == null:
		_set_owner_value("_tutorial_drag_flow", contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.new())
	_owner_callback("_bind_tutorial_coachmark_coordinator").call()
	(
		_owner_value("_tutorial_drag_flow")
		. bind(
			{
				"board_model": _owner_value("_board_model"),
				"board_controller": _owner_value("_board_controller"),
				"tutorial_director": _owner_value("_tutorial_director"),
				"coachmark_coordinator": _owner_value("_tutorial_coachmark_coordinator"),
			},
			{
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_END_DRAG: _owner_callback("_end_drag"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_BOARD_SEED: _board_debug_callback("set_board_seed"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_view_actions, "set_status_text"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_view_actions, "set_status_color"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_BOARD_MODEL_CHANGED: _owner_callback("_set_board_model_from_tutorial_drag_flow"),
			},
			{"warning_status_color": contract.STATUS_COLOR_WARNING}
		)
	)
