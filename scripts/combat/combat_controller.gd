extends RefCounted
class_name CombatController

var _board: Control
var _board_view: BoardView

const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")

enum InputPhase {
	PLAYER_INPUT,
	RESOLVING,
	LOCKED_EXTERNAL,
}

var _settings := BoardGenerationSettings.new()
var _board_model := BoardModel.new()
var _resolver: BoardMatchResolverService = CONTRACT.BOARD_MATCH_RESOLVER_SCRIPT.new()
var _combat: CombatStateMachine = null
var _player_state: PlayerState
var _enemy_state: EnemyState
var _progression_state: PlayerProgressionState

var _last_resolve_result: Dictionary = {}
var _consumable_rng := RandomNumberGenerator.new()
var _visuals: VisualRegistry = null
var _player_loadout_hud: PlayerLoadoutHud = null
var _outcome_overlay: CombatOutcomeOverlay = null
var _debug_runtime: CombatDebugRuntime = null
var _debug_console: CombatDebugConsole = null
var _settings_command_handler: CombatSettingsCommandHandler = null
var _combat_timer_service: CombatTimerService = null
var _boss_reward_handler: CombatBossRewardHandler = null
var _turn_log_presenter: CombatTurnLogPresenter = null
var _resolve_presenter: CombatResolvePresenter = null
var _combat_vfx_presenter: CombatVfxPresenter = null
var _board_controller: BoardController = null
var _hud_presenter: CombatHudPresenter = null
var _hud_snapshot_provider: CombatHudSnapshotProvider = null
var _vfx_target_resolver: CombatVfxTargetResolver = null
var _hud_stage_coordinator: CombatHudStageCoordinator = null
var _mastery_preview_coordinator: CombatMasteryPreviewCoordinator = null
var _player_hud_refresh_coordinator: CombatPlayerHudRefreshCoordinator = null
var _loadout_command_handler: CombatLoadoutCommandHandler = null
var _intent_hover_handler: CombatIntentHoverHandler = null
var _scene_transition_handler: CombatSceneTransitionHandler = null
var _outcome_route_coordinator: CombatOutcomeRouteCoordinator = null
var _turn_resolution_coordinator: CombatTurnResolutionCoordinator = null
var _tutorial_prompt_presenter: CombatTutorialPromptPresenter = null
var _tutorial_coachmark_coordinator: CombatTutorialCoachmarkCoordinator = null
var _tutorial_end_command_handler: CombatTutorialEndCommandHandler = null
var _tutorial_drag_flow = null
var _resolve_trace_logger = null
var _turn_replay_coordinator = null
var _state_initializer = null
var _lifecycle = null
var _binding_coordinator = null
var _view_actions: Variant = null
var _hud_update_router: Variant = null
var _combat_consumable_service: CombatConsumableService = null
var _combat_audio_cue_player: CombatAudioCuePlayer = null
var _audio_router: Variant = null
var _debug_state_provider: CombatDebugStateProvider = null
var _board_debug_command_handler: CombatBoardDebugCommandHandler = null
var _input_command_handler: CombatInputCommandHandler = null
var _input_phase_router: CombatInputPhaseRouter = null
var _tutorial_director: TutorialDirector = null
var _host: Control = null
var _model: CombatModel = null
var _view: CombatView = null


func bind(host: Control, root_nodes: Dictionary, model, view) -> void:
	var bindings: Dictionary = CONTRACT.COMBAT_CONTROLLER_SCENE_BINDER_SCRIPT.bind_scene(self, host, root_nodes, model, view)
	_host = bindings.get("host") as Control
	_model = bindings.get("model") as CombatModel
	_view = bindings.get("view") as CombatView
	_board_view = bindings.get("board_view") as BoardView
	_sync_model_state()


func enter_tree() -> void:
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_active_route_id())
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_begin("combat_scene_load", "res://scenes/combat.tscn", {"source": "combat._enter_tree"}))
	_sync_model_state()
	RunState.flow_trace_mark("combat_enter_tree", {}, _flow_trace_route_id_value())


func ready() -> void:
	_bind_lifecycle()
	_lifecycle.ready()


func exit_tree() -> void:
	_clear_combat_mastery_hover_state()


func process(delta: float) -> void:
	if _combat_timer_service == null:
		return
	var drag_update: Dictionary = _combat_timer_service.process(_board_controller, _view, _player_state, delta, _input_phase_value() == InputPhase.PLAYER_INPUT)
	_handle_drag_input_result(drag_update)


func unhandled_input(event: InputEvent) -> void:
	_bind_input_command_handler()
	_input_command_handler.handle_unhandled_input(event)


func on_viewport_size_changed() -> void:
	_apply_combat_layout()


func on_back_button_pressed() -> void:
	on_settings_button_pressed()


func on_debug_toggle_button_pressed() -> void:
	_toggle_debug_overlay()


func on_settings_button_pressed() -> void:
	_bind_settings_command_handler()
	_settings_command_handler.open()


func on_next_button_pressed() -> void:
	_bind_boss_reward_handler()
	if _boss_reward_handler != null and _boss_reward_handler.handle_next_pressed():
		return
	_bind_outcome_route_coordinator()
	if _outcome_route_coordinator != null:
		_outcome_route_coordinator.handle_next_pressed(_view.next_button_text() if _view != null else "")


func _bind_audio_router() -> void:
	if _audio_router == null:
		_audio_router = CONTRACT.COMBAT_CONTROLLER_AUDIO_ROUTER_SCRIPT.new()
	_audio_router.bind(
		{
			"cue_player": _combat_audio_cue_player,
			"cue_player_script": CONTRACT.COMBAT_AUDIO_CUE_PLAYER_SCRIPT,
			"runtime_binder": CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT,
			"host": _host,
			"run_state": RunState,
		}
	)
	_combat_audio_cue_player = _audio_router.cue_player()


func _audio_router_callback(method_name: String) -> Callable:
	_bind_audio_router()
	return Callable(_audio_router, method_name)


func _bind_hud_update_router() -> void:
	if _hud_update_router == null:
		_hud_update_router = CONTRACT.COMBAT_CONTROLLER_HUD_UPDATE_ROUTER_SCRIPT.new()
	_hud_update_router.bind(self)


func _hud_update_callback(method_name: String) -> Callable:
	_bind_hud_update_router()
	return Callable(_hud_update_router, method_name)


func _bind_debug_state_provider() -> void:
	_bind_view_actions()
	_debug_state_provider = (
		CONTRACT
		. COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT
		. bind_debug_state_provider(
			_debug_state_provider,
			CONTRACT.COMBAT_DEBUG_STATE_PROVIDER_SCRIPT,
			{
				"combat": _combat,
				"enemy_state": _enemy_state,
				"player_state": _player_state,
				"board_model": _board_model,
				"board_controller": _board_controller,
				"turn_log_presenter": _turn_log_presenter,
				"input_phase_value": Callable(self, "_input_phase_value"),
			}
		)
	)


func _bind_board_debug_command_handler() -> void:
	_bind_view_actions()
	_bind_binding_coordinator()
	_binding_coordinator.bind_board_debug_command_handler()


func _bind_input_command_handler() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_input_command_handler()


func _bind_debug_console() -> void:
	_bind_view_actions()
	_bind_binding_coordinator()
	_binding_coordinator.bind_debug_console()


func _bind_settings_command_handler() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_settings_command_handler()


func _trace_flow_first_usable_frame() -> void:
	RunState.flow_trace_mark("combat_first_usable_frame", {"source": "combat._ready_deferred"}, _flow_trace_route_id_value())


func _apply_orb_texture_map_deferred() -> void:
	CONTRACT.COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT.apply_orb_texture_map(_board_view, _visuals, RunState, Callable(self, "_flow_trace_route_id_value"))


func _bind_combat_vfx_presenter() -> void:
	if _combat_vfx_presenter == null or _view == null:
		return
	var view_bindings: Variant = _view.vfx_presenter_bindings(_visuals, _player_loadout_hud, _host)
	if view_bindings is Dictionary:
		_combat_vfx_presenter.bind(view_bindings)
		_apply_feedback_settings()


func _bind_board_controller() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_board_controller()


func _drag_match_groups() -> Array:
	if _resolver == null or _board_model == null:
		return []
	return _resolver.get_match_groups(_board_model)


func _drag_move_timer_seconds() -> float:
	return _timer_ready_seconds()


func _drag_active() -> bool:
	if _combat_timer_service == null:
		return false
	return _combat_timer_service.drag_active(_board_controller)


func _drag_move_time_left() -> float:
	if _combat_timer_service == null:
		return 0.0
	return _combat_timer_service.move_time_left(_board_controller)


func _apply_visual_chrome() -> void:
	CONTRACT.COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT.apply_visual_chrome(_view, RunState)


func _begin_turn_preview() -> void:
	_bind_lifecycle()
	_lifecycle.begin_turn_preview()


func _set_viewport_input_handled() -> void:
	if _host != null and is_instance_valid(_host) and _host.get_viewport() != null:
		_host.get_viewport().set_input_as_handled()


func _toggle_debug_overlay() -> void:
	if _debug_runtime != null:
		_debug_runtime.toggle_overlay()
	_hud_update_callback("update_hud").call()


func _convert_random_non_target_orbs(target_orb_id: int, count: int, rng: RandomNumberGenerator) -> int:
	if _board_controller == null:
		return 0
	return int(_board_controller.convert_random_non_target_orbs(target_orb_id, count, rng))


func _on_board_drag_input_result(drag_result: Dictionary) -> void:
	_handle_drag_input_result(drag_result)


func _on_board_hovered_orb_changed(orb_id: int) -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.set_hovered_board_orb_id(orb_id)


func _clear_combat_mastery_hover_state() -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.clear_hover_state()


func _handle_drag_input_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	_bind_view_actions()
	var action := String(result.get("action", ""))
	if action == "start":
		_clear_combat_mastery_hover_state()
		_bind_tutorial_drag_flow()
		_tutorial_drag_flow.handle_start()
		var selected_orb_id := int(result.get("selected_orb_id", -1))
		if _view != null:
			_view.sync_timer_display(_drag_move_time_left(), CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_ACTIVE)
		_view_actions.set_status_text("Dragging %s orb. Move timer running." % OrbType.display_name(selected_orb_id))
		_view_actions.set_status_color(CONTRACT.STATUS_COLOR_NEUTRAL)
		return
	if action == "end":
		_bind_tutorial_drag_flow()
		_tutorial_drag_flow.handle_end(result)


func _create_new_board() -> void:
	_bind_board_debug_command_handler()
	_sync_board_debug_command_result(_board_debug_command_handler.create_new_board())


func _tutorial_turn_summary_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.turn_summary_text()


func _tutorial_turn_status_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.turn_status_text(int(_combat.turn_index if _combat != null else 1))


func _sync_tutorial_coachmark() -> void:
	_bind_tutorial_coachmark_coordinator()
	_tutorial_coachmark_coordinator.sync()


func _print_board_model() -> void:
	_bind_board_debug_command_handler()
	_board_debug_command_handler.print_board_model()


func _set_board_seed(board_seed: int) -> void:
	_bind_board_debug_command_handler()
	_sync_board_debug_command_result(_board_debug_command_handler.set_board_seed(board_seed))


func _sync_board_debug_command_result(result: Dictionary) -> void:
	if result.has("board_model") and result.get("board_model") != null:
		_board_model = result["board_model"]
	_bind_debug_state_provider()


func _on_console_input_text_submitted(text: String) -> void:
	if _debug_runtime != null:
		_debug_runtime.handle_submitted_text(text)


func _console_on_skip_success() -> void:
	if _board_controller != null:
		_board_controller.abort()
	_last_resolve_result.clear()
	_bind_lifecycle()
	_lifecycle.initialize_combat_state()
	_create_new_board()
	_begin_turn_preview()


func _format_intent(intent: Dictionary) -> String:
	_bind_debug_state_provider()
	return String(_debug_state_provider.format_intent(intent))


func _debug_set_input_phase(raw_phase: int) -> void:
	_set_input_phase(raw_phase as InputPhase)


func _debug_set_pending_next_scene_path(scene_path: String) -> void:
	_model.set_pending_next_scene_path(scene_path)


func _end_drag(timed_out: bool) -> void:
	_bind_lifecycle()
	await _lifecycle.end_drag(timed_out)


func _bind_outcome_overlay() -> void:
	CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_outcome_overlay(_view, _outcome_overlay)


func _bind_boss_reward_handler() -> void:
	_boss_reward_handler = (
		CONTRACT
		. COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT
		. bind_boss_reward_handler(
			_boss_reward_handler,
			CONTRACT.COMBAT_BOSS_REWARD_HANDLER_SCRIPT,
			_outcome_overlay,
			_view,
			_model,
			_visuals,
			{
				"set_status_text": Callable(_view_actions, "set_status_text"),
				"update_hud": _hud_update_callback("update_hud"),
				"play_sfx": _audio_router_callback("play_sfx"),
				"apply_layout": Callable(self, "_apply_combat_layout"),
				"trace_and_change_scene": Callable(self, "_boss_reward_trace_and_change_scene"),
			}
		)
	)


func _boss_reward_trace_and_change_scene(scene_path: String, source: String, trace_mark: String, payload: Dictionary = {}) -> void:
	_trace_and_change_scene_to_target(scene_path, _flow_trace_route_id_value(), source, trace_mark, payload)


func _trace_and_change_scene_to_target(
	target_scene: String, current_route_id: String, source: String, before_change_step: String, begin_payload_extra: Dictionary = {}
) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.trace_and_change_scene_to_target(target_scene, current_route_id, source, before_change_step, begin_payload_extra)


func _on_combat_scene_post_ready_rollback(result: Dictionary) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.on_scene_post_ready_rollback(result)


func _handle_combat_scene_change_failure(target_scene: String, route_id: String, source: String, result: Variant) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.handle_scene_change_failure(target_scene, route_id, source, result)


func set_external_input_locked(locked: bool, reason: String = "") -> void:
	_bind_input_phase_router()
	_input_phase_router.set_external_locked(locked, reason)


func _set_input_phase(phase: InputPhase) -> void:
	_bind_input_phase_router()
	_input_phase_router.set_phase(int(phase))


func _lock_scene_transition_input() -> void:
	_set_input_phase(InputPhase.LOCKED_EXTERNAL)


func _ensure_model() -> CombatModel:
	if _model == null:
		_model = CombatModel.new()
	return _model


func _sync_model_state() -> void:
	var model := _ensure_model()
	if RunState.has_method("vfx_speed"):
		model.set_combat_speed(RunState.vfx_speed())
	else:
		model.set_combat_speed(model.combat_speed())


func _flow_trace_route_id_value() -> String:
	return _ensure_model().flow_trace_route_id()


func _set_flow_trace_route_id(route_id: String) -> void:
	_ensure_model().set_flow_trace_route_id(route_id)


func _input_phase_value() -> InputPhase:
	return int(_ensure_model().input_phase()) as InputPhase


func _combat_speed_value() -> String:
	return _ensure_model().combat_speed()


func _apply_vfx_speed_setting() -> void:
	if _combat_vfx_presenter == null or not _combat_vfx_presenter.has_method("set_post_match_vfx_speed_scale"):
		return
	match _combat_speed_value():
		CONTRACT.COMBAT_SPEED_SLOW:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(0.35)
		CONTRACT.COMBAT_SPEED_FAST:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(1.0)
		CONTRACT.COMBAT_SPEED_INSTANT:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(2.0)
		_:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(0.55)


func _apply_feedback_settings() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.apply_feedback_settings()


func _timer_ready_seconds() -> float:
	if _combat_timer_service == null:
		return CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.MOVE_TIMER_MAX_SECONDS
	return _combat_timer_service.ready_seconds(_player_state)


func _abort_active_drag() -> void:
	if _board_controller != null:
		_board_controller.abort()
	if _view != null:
		_view.sync_timer_display(0.0, CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED)


func _play_resolve_animations(result: Dictionary, visual_board_model: BoardModel = null, resolve_trace_origin_usec: int = 0) -> void:
	_bind_mastery_preview_coordinator()
	await (
		CONTRACT
		. COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT
		. play_resolve_animations(
			_resolve_presenter,
			result,
			visual_board_model,
			resolve_trace_origin_usec,
			{
				"trace_callback": _resolve_trace,
				"combo_preview_callback": Callable(_mastery_preview_coordinator, "preview_match_feedback_value"),
				"combo_feedback_callback": Callable(_mastery_preview_coordinator, "show_match_feedback"),
				"set_pass_index_callback": Callable(_model, "set_resolve_trace_pass_index"),
			}
		)
	)


func _combat_speed_duration(base_seconds: float) -> float:
	if _resolve_presenter != null:
		return _resolve_presenter.combat_speed_duration(base_seconds)
	return base_seconds


func _wait_combat_speed(base_seconds: float) -> void:
	await CONTRACT.COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT.wait_combat_speed(_resolve_presenter, _host, base_seconds)


func _build_run_outcome_summary(fallback_cause: String = "") -> String:
	return CONTRACT.COMBAT_TURN_LOG_WRITER_SCRIPT.build_run_outcome_summary(_turn_log_presenter, RunState, RunState.MAX_DUNGEON_LEVELS, fallback_cause)


func _replay_turn_resolution_from_log(turn_log: Dictionary) -> void:
	_bind_turn_replay_coordinator()
	await _turn_replay_coordinator.replay_turn_resolution_from_log(turn_log)


func _can_continue_after_async_wait(require_board_view: bool = false) -> bool:
	return CONTRACT.COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT.can_continue_after_async_wait(_host, _board_view, require_board_view)


func _bind_vfx_target_resolver() -> void:
	_vfx_target_resolver = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_vfx_target_resolver(
		_vfx_target_resolver, CONTRACT.COMBAT_VFX_TARGET_RESOLVER_SCRIPT, _view, _combat_vfx_presenter
	)


func _bind_hud_stage_coordinator() -> void:
	_hud_stage_coordinator = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_hud_stage_coordinator(
		_hud_stage_coordinator, CONTRACT.COMBAT_HUD_STAGE_COORDINATOR_SCRIPT, _model, _player_state, _enemy_state, _hud_update_callback("update_hud")
	)


func _bind_mastery_preview_coordinator() -> void:
	_mastery_preview_coordinator = (
		CONTRACT
		. COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT
		. bind_mastery_preview_coordinator(
			_mastery_preview_coordinator,
			CONTRACT.COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT,
			_model,
			_player_state,
			_view,
			CONTRACT.COMBAT_MASTERY_RESOLUTION_ORDER,
			CONTRACT.COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS,
			RunState.current_combat_modifiers(),
			{
				"board_view": _board_view,
				"combat_vfx_presenter": _combat_vfx_presenter,
				"combat_speed_duration_callback": Callable(self, "_combat_speed_duration"),
			}
		)
	)


func _bind_player_hud_refresh_coordinator() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_player_hud_refresh_coordinator()


func _bind_loadout_command_handler() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_loadout_command_handler()


func _bind_intent_hover_handler() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_intent_hover_handler()


func _bind_scene_transition_handler() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_scene_transition_handler()


func _bind_outcome_route_coordinator() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_outcome_route_coordinator()


func _bind_input_phase_router() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_input_phase_router()


func _bind_turn_resolution_coordinator() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_turn_resolution_coordinator()


func _bind_tutorial_prompt_presenter() -> void:
	_tutorial_prompt_presenter = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_tutorial_prompt_presenter(
		_tutorial_prompt_presenter, CONTRACT.COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT, _host
	)


func _bind_tutorial_coachmark_coordinator() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_tutorial_coachmark_coordinator()


func _bind_tutorial_drag_flow() -> void:
	_bind_binding_coordinator()
	_binding_coordinator.bind_tutorial_drag_flow()


func _set_board_model_from_tutorial_drag_flow(board_model: BoardModel) -> void:
	_board_model = board_model


func _bind_resolve_trace_logger() -> void:
	_resolve_trace_logger = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_resolve_trace_logger(
		_resolve_trace_logger, CONTRACT.COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT, _model
	)


func _bind_lifecycle() -> void:
	_bind_view_actions()
	_lifecycle = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_lifecycle(_lifecycle, CONTRACT.COMBAT_CONTROLLER_LIFECYCLE_SCRIPT, self)


func _bind_binding_coordinator() -> void:
	_bind_view_actions()
	if _binding_coordinator == null:
		_binding_coordinator = CONTRACT.COMBAT_CONTROLLER_BINDING_COORDINATOR_SCRIPT.new()
	_binding_coordinator.bind(self)


func _bind_view_actions() -> void:
	if _view_actions == null:
		_view_actions = CONTRACT.COMBAT_CONTROLLER_VIEW_ACTIONS_SCRIPT.new()
	_view_actions.bind(
		{"view": _view, "outcome_overlay": _outcome_overlay, "debug_runtime": _debug_runtime},
		{
			CONTRACT.COMBAT_CONTROLLER_VIEW_ACTIONS_SCRIPT.CALLBACK_APPLY_LAYOUT: Callable(self, "_apply_combat_layout"),
			CONTRACT.COMBAT_CONTROLLER_VIEW_ACTIONS_SCRIPT.CALLBACK_BIND_BOSS_REWARD_HANDLER: Callable(self, "_bind_boss_reward_handler"),
			CONTRACT.COMBAT_CONTROLLER_VIEW_ACTIONS_SCRIPT.CALLBACK_BOSS_REWARD_HANDLER: func() -> Variant: return _boss_reward_handler,
		}
	)


func _bind_turn_replay_coordinator() -> void:
	_turn_replay_coordinator = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_turn_replay_coordinator(
		_turn_replay_coordinator, CONTRACT.COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT, self, RunState
	)


func _bind_tutorial_end_command_handler() -> void:
	_tutorial_end_command_handler = CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_tutorial_end_command_handler(
		_tutorial_end_command_handler,
		CONTRACT.COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT,
		RunState,
		_tutorial_director,
		_view,
		self,
		CONTRACT.STATUS_COLOR_NEUTRAL
	)


func _should_show_intent_damage_preview() -> bool:
	_bind_intent_hover_handler()
	return bool(_intent_hover_handler.should_show_preview())


func _on_intent_damage_preview_hovered(preview: Dictionary) -> void:
	_bind_intent_hover_handler()
	_intent_hover_handler.intent_damage_preview_hovered(preview)


func _on_intent_block_preview_hovered(preview: Dictionary) -> void:
	_bind_intent_hover_handler()
	_intent_hover_handler.intent_block_preview_hovered(preview)


func _on_enemy_block_preview_hovered(preview: Dictionary) -> void:
	_bind_intent_hover_handler()
	_intent_hover_handler.enemy_block_preview_hovered(preview)


func _on_intent_damage_preview_hover_ended() -> void:
	_bind_intent_hover_handler()
	_intent_hover_handler.intent_damage_preview_hover_ended()


func _on_enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	_bind_intent_hover_handler()
	_intent_hover_handler.enemy_intent_bubble_hovered(kind, entry)


func _append_turn_log(turn_log: Dictionary) -> void:
	_bind_view_actions()
	CONTRACT.COMBAT_TURN_LOG_WRITER_SCRIPT.append_turn_log(
		turn_log, _turn_log_presenter, _debug_runtime, _player_state, _enemy_state, Callable(_view_actions, "append_combat_log"), CONTRACT.LOG_LEVEL_NORMAL
	)


func _resolve_trace(start_ticks_usec: int, message: String) -> void:
	_bind_resolve_trace_logger()
	_resolve_trace_logger.trace(start_ticks_usec, message)


func _spawn_vfx_texture(
	texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func _on_resolver_match_found(groups: Array) -> void:
	_bind_view_actions()
	_audio_router_callback("play_sfx").call("match")
	_view_actions.set_status_text("Matches found: %d group(s)." % groups.size())
	_view_actions.set_status_color(CONTRACT.STATUS_COLOR_WARNING)


func _apply_combat_layout() -> void:
	CONTRACT.COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT.apply_combat_layout(
		_view,
		_host,
		_combat_timer_service,
		_board_controller,
		_player_state,
		_tutorial_prompt_presenter,
		CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_READY
	)


func _refresh_character_portraits() -> void:
	if _view != null:
		_view.refresh_character_portraits(String(_enemy_state.enemy_id if _enemy_state != null else ""))
