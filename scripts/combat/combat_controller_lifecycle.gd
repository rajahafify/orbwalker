extends RefCounted
class_name CombatControllerLifecycle

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


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
	_owner._ensure_boss_reward_controls()
	_owner._ensure_outcome_overlay_layer()
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
	RunState.flow_trace_mark("combat_after_initialize_state", {}, _owner._flow_trace_route_id_value())
	_owner._create_new_board()
	RunState.flow_trace_mark("combat_after_board_create", {}, _owner._flow_trace_route_id_value())
	if _owner._debug_runtime != null:
		_owner._debug_runtime.bootstrap_hidden(Callable(_owner, "_on_console_input_text_submitted"))
	_owner._host.get_viewport().size_changed.connect(_owner._on_viewport_size_changed)
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
	if _owner._visuals == null:
		_owner._visuals = _owner.CONTRACT.VISUAL_REGISTRY_SCRIPT.new()
	if _owner._player_loadout_hud == null:
		_owner._player_loadout_hud = _owner.CONTRACT.PLAYER_LOADOUT_HUD_SCRIPT.new()
	_owner._player_loadout_hud.set_visual_registry(_owner._visuals)
	if _owner._outcome_overlay == null:
		_owner._outcome_overlay = _owner.CONTRACT.COMBAT_OUTCOME_OVERLAY_SCRIPT.new()
	if _owner._turn_log_presenter == null:
		_owner._turn_log_presenter = _owner.CONTRACT.COMBAT_TURN_LOG_PRESENTER_SCRIPT.new()
	if _owner._debug_runtime == null:
		_owner._debug_runtime = _owner.CONTRACT.COMBAT_DEBUG_RUNTIME_SCRIPT.new()
	_owner._debug_console = _owner._debug_runtime.console()
	if _owner._settings_command_handler == null:
		_owner._settings_command_handler = _owner.CONTRACT.COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT.new()
	if _owner._combat_timer_service == null:
		_owner._combat_timer_service = _owner.CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.new()
	if _owner._boss_reward_handler == null:
		_owner._boss_reward_handler = _owner.CONTRACT.COMBAT_BOSS_REWARD_HANDLER_SCRIPT.new()
	if _owner._combat_vfx_presenter == null:
		_owner._combat_vfx_presenter = _owner.CONTRACT.COMBAT_VFX_PRESENTER_SCRIPT.new()
	if _owner._board_controller == null:
		_owner._board_controller = _owner.CONTRACT.BOARD_CONTROLLER_SCRIPT.new()
	if _owner._hud_presenter == null:
		_owner._hud_presenter = _owner.CONTRACT.COMBAT_HUD_PRESENTER_SCRIPT.new()
	if _owner._hud_snapshot_provider == null:
		_owner._hud_snapshot_provider = _owner.CONTRACT.COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT.new()
	if _owner._vfx_target_resolver == null:
		_owner._vfx_target_resolver = _owner.CONTRACT.COMBAT_VFX_TARGET_RESOLVER_SCRIPT.new()
	if _owner._hud_stage_coordinator == null:
		_owner._hud_stage_coordinator = _owner.CONTRACT.COMBAT_HUD_STAGE_COORDINATOR_SCRIPT.new()
	if _owner._mastery_preview_coordinator == null:
		_owner._mastery_preview_coordinator = _owner.CONTRACT.COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT.new()
	if _owner._player_hud_refresh_coordinator == null:
		_owner._player_hud_refresh_coordinator = _owner.CONTRACT.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT.new()
	if _owner._loadout_command_handler == null:
		_owner._loadout_command_handler = _owner.CONTRACT.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.new()
	if _owner._intent_hover_handler == null:
		_owner._intent_hover_handler = _owner.CONTRACT.COMBAT_INTENT_HOVER_HANDLER_SCRIPT.new()
	if _owner._scene_transition_handler == null:
		_owner._scene_transition_handler = _owner.CONTRACT.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.new()
	if _owner._outcome_route_coordinator == null:
		_owner._outcome_route_coordinator = _owner.CONTRACT.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT.new()
	if _owner._turn_resolution_coordinator == null:
		_owner._turn_resolution_coordinator = _owner.CONTRACT.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT.new()
	if _owner._tutorial_prompt_presenter == null:
		_owner._tutorial_prompt_presenter = _owner.CONTRACT.COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT.new()
	if _owner._tutorial_coachmark_coordinator == null:
		_owner._tutorial_coachmark_coordinator = _owner.CONTRACT.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.new()
	if _owner._tutorial_end_command_handler == null:
		_owner._tutorial_end_command_handler = _owner.CONTRACT.COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT.new()
	if _owner._tutorial_drag_flow == null:
		_owner._tutorial_drag_flow = _owner.CONTRACT.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.new()
	if _owner._resolve_trace_logger == null:
		_owner._resolve_trace_logger = _owner.CONTRACT.COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT.new()
	if _owner._turn_replay_coordinator == null:
		_owner._turn_replay_coordinator = _owner.CONTRACT.COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT.new()
	if _owner._combat_consumable_service == null:
		_owner._combat_consumable_service = _owner.CONTRACT.COMBAT_CONSUMABLE_SERVICE_SCRIPT.new()
	if _owner._board_debug_command_handler == null:
		_owner._board_debug_command_handler = _owner.CONTRACT.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT.new()
	if _owner._input_command_handler == null:
		_owner._input_command_handler = _owner.CONTRACT.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT.new()
	_owner._bind_audio_cue_player()
	_owner._bind_debug_state_provider()
	if _owner._tutorial_director == null:
		_owner._tutorial_director = _owner.CONTRACT.COMBAT_GUIDANCE_DIRECTOR_SCRIPT.new()
	if _owner._combat_consumable_service != null and _owner._combat_consumable_service.has_method("bind"):
		_owner._combat_consumable_service.bind({"convert_random_non_target_orbs": Callable(_owner, "_convert_random_non_target_orbs")})


func initialize_combat_state() -> void:
	if not RunState.run_active:
		RunState.flow_trace_mark("combat_initialize_no_active_run_starting_new", {}, _owner._flow_trace_route_id_value())
		RunState.start_new_run()
	if RunState.is_current_step_boss_reward():
		_initialize_boss_reward_state()
		return
	if not RunState.is_current_step_fight():
		_redirect_non_fight_step()
		return
	_initialize_fight_state()


func begin_turn_preview() -> void:
	if _owner._combat == null or _owner._combat.is_fight_over():
		return
	_owner._combat.reset_to_intent_preview()
	_owner._combat.begin_player_input()
	_owner._set_input_phase(_owner.InputPhase.PLAYER_INPUT)
	_owner._model.clear_pending_next_scene_path()
	_owner._hide_outcome_summary()
	_owner._set_turn_summary_text(_owner._tutorial_turn_summary_text() if RunState.is_tutorial_run() else "Turn Summary: Awaiting move.")
	_owner._set_status_text(
		_owner._tutorial_turn_status_text() if RunState.is_tutorial_run() else "%s | Turn %d." % [RunState.level_sequence_label(), _owner._combat.turn_index]
	)
	_owner._set_status_color(_owner.CONTRACT.STATUS_COLOR_NEUTRAL)
	_owner._update_hud()
	_owner._clear_combat_mastery_hover_state()
	_owner._sync_tutorial_coachmark()
	_owner._append_combat_log("Turn %d intent: %s." % [_owner._combat.turn_index, _owner._format_intent(_owner._enemy_state.get_current_intent())])


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
	_owner._set_status_text("Move ended: %s. Locking input for resolve phase." % move_end_reason)
	_owner._set_status_color(_owner.CONTRACT.STATUS_COLOR_WARNING)
	var resolve_trace_origin_usec := Time.get_ticks_usec()
	_owner._model.begin_resolve_trace(resolve_trace_origin_usec, true)
	_owner._resolve_trace(resolve_trace_origin_usec, 'phase=resolve_start move_end_reason="%s" board_seed=%d' % [move_end_reason, _owner._board_model.rng_seed])
	_owner._board_controller.reset_visuals()
	_owner._board_controller.clear_board_presentation()
	_owner._set_input_phase(_owner.InputPhase.RESOLVING)
	_owner._reset_combat_mastery_preview()
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
	_owner._player_loadout_hud.consumable_slot_selected.connect(_owner._try_use_consumable_slot)
	_owner._player_loadout_hud.sell_slot_requested.connect(_owner._on_player_hud_sell_slot_requested)
	_owner._player_loadout_hud.intent_preview_hovered.connect(_owner._on_intent_damage_preview_hovered)
	_owner._player_loadout_hud.intent_block_preview_hovered.connect(_owner._on_intent_block_preview_hovered)
	_owner._player_loadout_hud.intent_preview_hover_ended.connect(_owner._on_intent_damage_preview_hover_ended)
	_owner._connect_view_signals()


func connect_view_signals() -> void:
	if _owner._view == null:
		return
	_owner._view.enemy_intent_bubble_hovered.connect(_owner._on_enemy_intent_bubble_hovered)
	_owner._view.enemy_block_preview_hovered.connect(_owner._on_enemy_block_preview_hovered)
	_owner._view.intent_hover_ended.connect(_owner._on_intent_damage_preview_hover_ended)
	_owner._view.tutorial_end_continue_pressed.connect(_owner._on_tutorial_end_continue_pressed)
	_owner._view.tutorial_end_main_menu_pressed.connect(_owner._on_tutorial_end_main_menu_pressed)
	_owner._view.settings_continue_pressed.connect(_owner._on_settings_continue_pressed)
	_owner._view.settings_new_run_pressed.connect(_owner._on_settings_new_run_pressed)
	_owner._view.settings_main_menu_pressed.connect(_owner._on_settings_main_menu_pressed)
	_owner._view.settings_speed_selected.connect(_owner._on_settings_speed_selected)
	_owner._view.settings_quality_selected.connect(_owner._on_settings_quality_selected)
	_owner._view.settings_reduced_motion_toggled.connect(_owner._on_settings_reduced_motion_toggled)
	_owner._view.settings_game_juice_toggled.connect(_owner._on_settings_game_juice_toggled)
	_owner._view.settings_game_juice_flag_toggled.connect(_owner._on_settings_game_juice_flag_toggled)
	_owner._view.settings_defaults_reset.connect(_owner._on_settings_defaults_reset)


func _initialize_boss_reward_state() -> void:
	_owner._player_state = RunState.ensure_player_state()
	_owner._progression_state = RunState.ensure_player_progression_state()
	_owner._player_state.set_mastery_level_provider(Callable(_owner._progression_state, "mastery_level"))
	var preview: Dictionary = RunState.current_level_boss_preview()
	_owner._enemy_state = _owner.CONTRACT.ENEMY_STATE_SCRIPT.new()
	_owner._enemy_state.configure_from_blueprint(preview)
	_owner._bind_hud_stage_coordinator()
	_owner._combat = null
	_owner._model.clear_outcome_transition_queued()
	_owner._model.clear_pending_next_scene_path()
	_owner._hide_outcome_summary()
	_owner._refresh_character_portraits()
	_owner._refresh_build_icon_rows(_owner._progression_state.to_snapshot())
	_owner._show_boss_reward_summary("Boss defeated.")
	_owner._set_status_text("Boss defeated. Choose one boss relic before continuing.")
	_owner._set_status_color(_owner.CONTRACT.STATUS_COLOR_WARNING)
	_owner._bind_debug_state_provider()
	RunState.flow_trace_mark("combat_initialize_boss_reward_overlay", {}, _owner._flow_trace_route_id_value())


func _redirect_non_fight_step() -> void:
	var redirect_scene := RunState.next_scene_path()
	if redirect_scene == "":
		return
	RunState.flow_trace_mark(
		"combat_initialize_redirect_before_change_scene", {"source": "_initialize_combat_state"}, _owner._flow_trace_route_id_value(), redirect_scene
	)
	var change_result: Variant = RunState.flow_trace_change_scene(
		_owner._host.get_tree(),
		redirect_scene,
		_owner._flow_trace_route_id_value(),
		"combat._initialize_combat_state",
		"",
		_owner._on_combat_scene_post_ready_rollback
	)
	if not _owner.CONTRACT.FLOW_RESULT_UTILS.scene_change_succeeded(change_result):
		_owner._handle_combat_scene_change_failure(redirect_scene, _owner._flow_trace_route_id_value(), "combat._initialize_combat_state", change_result)


func _initialize_fight_state() -> void:
	_owner._player_state = RunState.ensure_player_state()
	_owner._progression_state = RunState.ensure_player_progression_state()
	_owner._player_state.set_mastery_level_provider(Callable(_owner._progression_state, "mastery_level"))
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	_owner._enemy_state = _owner.CONTRACT.ENEMY_STATE_SCRIPT.new()
	_owner._enemy_state.configure_from_blueprint(encounter)
	_owner._bind_hud_stage_coordinator()
	_owner._refresh_character_portraits()
	_owner._combat = _owner.CONTRACT.COMBAT_STATE_MACHINE_SCRIPT.new()
	_owner._combat.start_fight(_owner._player_state, _owner._enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_owner._model.clear_outcome_transition_queued()
	_owner._model.clear_pending_next_scene_path()
	_owner._hide_outcome_summary()
	_owner._update_hud()
	if _owner._debug_runtime != null:
		_owner._debug_runtime.clear_log()
	_owner._append_combat_log("Run flow: %s" % RunState.level_sequence_label())
	if String(encounter.get("step_key", "")) == "enemy_1":
		_owner._append_combat_log("Level %d boss preview: %s." % [RunState.dungeon_level, RunState.current_level_boss_name()])
	_owner._append_combat_log("Fight started: %s HP %d." % [_owner._enemy_state.display_name, _owner._enemy_state.max_hp])
	_owner._append_combat_log("Player start: HP %d/%d, Gold %d." % [_owner._player_state.current_hp, _owner._player_state.max_hp, _owner._player_state.gold])
	if content_errors.is_empty():
		_owner._append_combat_log("Milestone 5 content validation: OK.")
	else:
		_owner._append_combat_log("Milestone 5 content validation: %d issue(s)." % content_errors.size())
		for error in content_errors:
			_owner._append_combat_log("  - [%s] %s" % [String(error.get("item_id", "?")), String(error.get("reason", "unknown"))])
	_owner._bind_debug_state_provider()
