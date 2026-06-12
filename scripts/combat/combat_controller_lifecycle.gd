extends RefCounted
class_name CombatControllerLifecycle

var _owner: Variant = null
var _view_actions: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner
	_view_actions = owner.get("_view_actions")


func ready() -> void:
	if _owner._board_view == null:
		push_error("CombatPlayerController._ready aborted because BoardView failed to resolve.")
		return
	if _owner._flow_trace_route_id_value() == "":
		_owner._set_flow_trace_route_id(RunState.flow_trace_active_route_id())
	if _owner._flow_trace_route_id_value() == "":
		_owner._set_flow_trace_route_id(RunState.flow_trace_begin("combat_scene_load", "res://scenes/combat.tscn", {"source": "combat._ready"}))
	RunState.flow_trace_mark("combat_ready_start", {}, _owner._flow_trace_route_id_value())
	_owner._audio_play_music("combat")
	RunState.flow_trace_mark("combat_after_music", {}, _owner._flow_trace_route_id_value())
	ensure_runtime_helpers()
	_owner._bind_outcome_overlay()
	_owner._bind_boss_reward_handler()
	if _owner._resolve_presenter == null:
		_owner._resolve_presenter = _owner.CONTRACT.COMBAT_RESOLVE_PRESENTER_SCRIPT.new()
	var spawn_vfx_texture_callback: Callable = Callable(_owner, "_spawn_vfx_texture")
	var resolve_presenter_bindings := {
		"board": _owner._board,
		"board_view": _owner._board_view,
		"board_panel": null,
		"board_controller": _owner._board_controller,
		"timer_owner": _owner._host,
		"spawn_vfx_texture_callback": spawn_vfx_texture_callback,
		"combo_sound_callback": _owner._on_presenter_combo_sound,
	}
	if _owner._view != null:
		resolve_presenter_bindings = _owner._view.resolve_presenter_bindings(
			_owner._board_controller, _owner._host, spawn_vfx_texture_callback, _owner._on_presenter_combo_sound
		)
	_owner._resolve_presenter.bind(resolve_presenter_bindings)
	_owner._resolve_presenter.set_combat_speed(_owner._combat_speed_value())
	_owner._bind_debug_console()
	_owner._bind_settings_command_handler()
	_owner._consumable_rng.randomize()
	if _owner._view != null:
		_owner._view.bootstrap_background()
	RunState.flow_trace_mark("combat_texture_map_deferred", {}, _owner._flow_trace_route_id_value())
	_view_actions.ensure_boss_reward_controls()
	_view_actions.ensure_outcome_overlay_layer()
	if _owner._view != null:
		(
			_owner
			. _view
			. set_dependencies(
				{
					"visual_registry": _owner._visuals,
					"player_loadout_hud": _owner._player_loadout_hud,
					"debug_console": _owner._debug_console,
					"outcome_overlay": _owner._outcome_overlay,
				}
			)
		)
		_owner._view.setup_rendering_helpers()
	RunState.flow_trace_mark("combat_after_boss_outcome_controls", {}, _owner._flow_trace_route_id_value())
	if _owner._view != null:
		_owner._view.bind_player_hud()
	_owner._bind_combat_vfx_presenter()
	if _owner._view != null:
		_owner._view.bind_layout_presenter()
	_owner._bind_board_controller()
	RunState.flow_trace_mark("combat_after_hud_bind", {}, _owner._flow_trace_route_id_value())
	_owner._apply_visual_chrome()
	RunState.flow_trace_mark("combat_after_chrome", {}, _owner._flow_trace_route_id_value())
	_owner._bind_resolve_trace_logger()
	_connect_resolver_signals()
	_connect_hud_and_view_signals()
	initialize_combat_state()
	_owner._bind_loadout_command_handler()
	RunState.flow_trace_mark("combat_after_initialize_state", {}, _owner._flow_trace_route_id_value())
	_owner._create_new_board()
	RunState.flow_trace_mark("combat_after_board_create", {}, _owner._flow_trace_route_id_value())
	if _owner._debug_runtime != null:
		_owner._debug_runtime.bootstrap_hidden(Callable(_owner, "_on_console_input_text_submitted"))
	_owner._host.get_viewport().size_changed.connect(_owner.on_viewport_size_changed)
	if _owner._view != null:
		_owner._view.set_vfx_layer_visible(true)
	_owner._host.set_process(true)
	_owner._apply_combat_layout()
	RunState.flow_trace_mark("combat_after_layout", {}, _owner._flow_trace_route_id_value())
	begin_turn_preview()
	RunState.flow_trace_mark("combat_after_begin_turn_preview", {}, _owner._flow_trace_route_id_value())
	_owner.call_deferred("_trace_flow_first_usable_frame")
	_owner.call_deferred("_apply_orb_texture_map_deferred")


func ensure_runtime_helpers() -> void:
	var helpers: Dictionary = _owner.CONTRACT.COMBAT_CONTROLLER_RUNTIME_HELPER_FACTORY_SCRIPT.ensure_helpers(
		_runtime_helper_values(), _runtime_helper_scripts()
	)
	_apply_runtime_helper_values(helpers)
	_owner._player_loadout_hud.set_visual_registry(_owner._visuals)
	_owner._debug_console = _owner._debug_runtime.console()
	_owner._bind_audio_cue_player()
	_owner._bind_debug_state_provider()
	if _owner._combat_consumable_service != null and _owner._combat_consumable_service.has_method("bind"):
		_owner._combat_consumable_service.bind({"convert_random_non_target_orbs": Callable(_owner, "_convert_random_non_target_orbs")})


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
	_owner._state_initializer.initialize()


func begin_turn_preview() -> void:
	if _owner._combat == null or _owner._combat.is_fight_over():
		return
	_owner._combat.reset_to_intent_preview()
	_owner._combat.begin_player_input()
	_owner._set_input_phase(_owner.InputPhase.PLAYER_INPUT)
	_owner._model.clear_pending_next_scene_path()
	_view_actions.hide_outcome_summary()
	_view_actions.set_turn_summary_text(_owner._tutorial_turn_summary_text() if RunState.is_tutorial_run() else "Turn Summary: Awaiting move.")
	_view_actions.set_status_text(
		_owner._tutorial_turn_status_text() if RunState.is_tutorial_run() else "%s | Turn %d." % [RunState.level_sequence_label(), _owner._combat.turn_index]
	)
	_view_actions.set_status_color(_owner.CONTRACT.STATUS_COLOR_NEUTRAL)
	_owner._update_hud()
	_owner._clear_combat_mastery_hover_state()
	_owner._sync_tutorial_coachmark()
	_view_actions.append_combat_log("Turn %d intent: %s." % [_owner._combat.turn_index, _owner._format_intent(_owner._enemy_state.get_current_intent())])


func end_drag(timed_out: bool) -> void:
	if _owner._input_phase_value() != _owner.InputPhase.PLAYER_INPUT:
		return
	if _owner._board_controller == null:
		return
	var drag_result: Dictionary = _owner._board_controller.end_drag(timed_out)
	if not bool(drag_result.get("handled", false)):
		return
	_owner._audio_play_sfx("drop")
	if _owner._view != null:
		_owner._view.sync_timer_display(0.0, _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED)
	var move_end_reason := "timer expired" if timed_out else "released"
	_view_actions.set_status_text("Move ended: %s. Locking input for resolve phase." % move_end_reason)
	_view_actions.set_status_color(_owner.CONTRACT.STATUS_COLOR_WARNING)
	var resolve_trace_origin_usec := Time.get_ticks_usec()
	_owner._model.begin_resolve_trace(resolve_trace_origin_usec, true)
	_owner._resolve_trace(resolve_trace_origin_usec, 'phase=resolve_start move_end_reason="%s" board_seed=%d' % [move_end_reason, _owner._board_model.rng_seed])
	_owner._board_controller.reset_visuals()
	_owner._board_controller.clear_board_presentation()
	_owner._set_input_phase(_owner.InputPhase.RESOLVING)
	Callable(_owner, "_bind_mastery_preview_coordinator").call()
	var mastery_preview_coordinator: Variant = _owner.get("_mastery_preview_coordinator")
	mastery_preview_coordinator.reset(RunState.current_combat_modifiers())
	var resolve_models: Dictionary = _owner._board_controller.prepare_visual_model_for_resolve()
	var visual_board_model: BoardModel = resolve_models.get("visual_board_model") as BoardModel
	var simulation_board_model: BoardModel = resolve_models.get("simulation_board_model") as BoardModel
	if visual_board_model == null or simulation_board_model == null:
		visual_board_model = _owner._board_model.clone()
		simulation_board_model = _owner._board_model.clone()
		_owner._board_view.set_board_presentation_model(visual_board_model)
	_owner._resolve_trace(resolve_trace_origin_usec, "phase=visual_state_ready board_seed=%d" % visual_board_model.rng_seed)
	_owner._resolve_trace(resolve_trace_origin_usec, "phase=simulation_resolve_start board_seed=%d" % simulation_board_model.rng_seed)
	_owner._last_resolve_result = _owner._resolver.resolve_all(simulation_board_model)
	(
		_owner
		. _resolve_trace(
			resolve_trace_origin_usec,
			(
				"phase=simulation_resolve_complete total_combos=%d passes=%d"
				% [
					int(_owner._last_resolve_result.get("total_combos", 0)),
					Array(_owner._last_resolve_result.get("passes", [])).size(),
				]
			)
		)
	)
	await _owner._play_resolve_animations(_owner._last_resolve_result, visual_board_model, resolve_trace_origin_usec)
	if not _owner._can_continue_after_async_wait(true):
		_owner._model.end_resolve_trace()
		return
	(
		_owner
		. _resolve_trace(
			resolve_trace_origin_usec,
			(
				"phase=resolve_presentation_complete total_combos=%d passes=%d"
				% [
					int(_owner._last_resolve_result.get("total_combos", 0)),
					Array(_owner._last_resolve_result.get("passes", [])).size(),
				]
			)
		)
	)
	_owner._board_controller.commit_model_after_resolve(simulation_board_model)
	_owner._board_model = _owner._board_controller.current_board_model()
	_owner._resolve_trace(resolve_trace_origin_usec, "phase=final_board_commit board_seed=%d" % _owner._board_model.rng_seed)
	_owner._bind_turn_resolution_coordinator()
	var turn_route_result: Dictionary = await _owner._turn_resolution_coordinator.handle_resolved_board_turn(
		int(_owner._input_phase_value()), _owner._last_resolve_result
	)
	if bool(turn_route_result.get("stop", false)):
		_owner._model.end_resolve_trace()
		return
	_owner._model.end_resolve_trace()


func _connect_resolver_signals() -> void:
	_owner._resolver.match_found.connect(_owner._on_resolver_match_found)
	_owner._resolver.cells_cleared.connect(_owner._resolve_trace_logger.on_resolver_cells_cleared)
	_owner._resolver.gravity_applied.connect(_owner._resolve_trace_logger.on_resolver_gravity_applied)
	_owner._resolver.refill_applied.connect(_owner._resolve_trace_logger.on_resolver_refill_applied)
	_owner._resolver.cascade_step_complete.connect(_owner._resolve_trace_logger.on_resolver_cascade_step_complete)
	_owner._resolver.resolve_complete.connect(_owner._resolve_trace_logger.on_resolver_complete)


func _connect_hud_and_view_signals() -> void:
	_owner._bind_loadout_command_handler()
	var player_loadout_hud: Variant = _owner._player_loadout_hud
	var loadout_command_handler: Variant = _owner._loadout_command_handler
	player_loadout_hud.consumable_slot_selected.connect(loadout_command_handler.try_use_consumable_slot)
	player_loadout_hud.sell_slot_requested.connect(loadout_command_handler.sell_slot_requested)
	player_loadout_hud.intent_preview_hovered.connect(_owner._on_intent_damage_preview_hovered)
	player_loadout_hud.intent_block_preview_hovered.connect(_owner._on_intent_block_preview_hovered)
	player_loadout_hud.intent_preview_hover_ended.connect(_owner._on_intent_damage_preview_hover_ended)
	_owner._connect_view_signals()


func connect_view_signals() -> void:
	if _owner._view == null:
		return
	_owner._bind_settings_command_handler()
	_owner._bind_tutorial_end_command_handler()
	var view: Variant = _owner._view
	var settings_command_handler: Variant = _owner._settings_command_handler
	var tutorial_end_command_handler: Variant = _owner._tutorial_end_command_handler
	view.enemy_intent_bubble_hovered.connect(_owner._on_enemy_intent_bubble_hovered)
	view.enemy_block_preview_hovered.connect(_owner._on_enemy_block_preview_hovered)
	view.intent_hover_ended.connect(_owner._on_intent_damage_preview_hover_ended)
	view.tutorial_end_continue_pressed.connect(tutorial_end_command_handler.continue_pressed)
	view.tutorial_end_main_menu_pressed.connect(tutorial_end_command_handler.main_menu_pressed)
	view.settings_continue_pressed.connect(settings_command_handler.continue_combat)
	view.settings_new_run_pressed.connect(settings_command_handler.start_new_run)
	view.settings_main_menu_pressed.connect(settings_command_handler.return_to_main_menu)
	view.settings_speed_selected.connect(settings_command_handler.select_speed)
	view.settings_quality_selected.connect(settings_command_handler.select_quality)
	view.settings_reduced_motion_toggled.connect(settings_command_handler.toggle_reduced_motion)
	view.settings_game_juice_toggled.connect(settings_command_handler.toggle_game_juice)
	view.settings_game_juice_flag_toggled.connect(settings_command_handler.toggle_game_juice_flag)
	view.settings_defaults_reset.connect(settings_command_handler.reset_feedback_settings)


func _bind_state_initializer() -> void:
	(
		_owner
		. _state_initializer
		. bind(
			{
				"run_state": RunState,
				"model": _owner._model,
				"host": _owner._host,
				"view_actions": _view_actions,
				"enemy_state_script": _owner.CONTRACT.ENEMY_STATE_SCRIPT,
				"combat_state_machine_script": _owner.CONTRACT.COMBAT_STATE_MACHINE_SCRIPT,
				"flow_result_utils": _owner.CONTRACT.FLOW_RESULT_UTILS,
				"status_color_warning": _owner.CONTRACT.STATUS_COLOR_WARNING,
			},
			{
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_APPLY_STATE: Callable(self, "_apply_initialized_combat_state"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_BIND_HUD_STAGE: Callable(_owner, "_bind_hud_stage_coordinator"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_REFRESH_CHARACTER_PORTRAITS:
				Callable(_owner, "_refresh_character_portraits"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_REFRESH_BUILD_ICON_ROWS: Callable(_owner, "_refresh_build_icon_rows"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(_owner, "_update_hud"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_BIND_DEBUG_STATE_PROVIDER: Callable(_owner, "_bind_debug_state_provider"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_ROUTE_ID: Callable(_owner, "_flow_trace_route_id_value"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_SCENE_ROLLBACK: Callable(_owner, "_on_combat_scene_post_ready_rollback"),
				_owner.CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT.CALLBACK_HANDLE_SCENE_CHANGE_FAILURE:
				Callable(_owner, "_handle_combat_scene_change_failure"),
				"debug_runtime": _owner._debug_runtime,
			}
		)
	)


func _apply_initialized_combat_state(state: Dictionary) -> void:
	_owner._player_state = state.get("player_state")
	_owner._progression_state = state.get("progression_state")
	_owner._enemy_state = state.get("enemy_state")
	_owner._combat = state.get("combat")
