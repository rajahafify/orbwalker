extends RefCounted
class_name CombatController

var _board: Control
var _board_view: BoardView

const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_service.gd")
const TEST_RUNNER_SCRIPT := preload("res://scripts/tests/run_all_tests.gd")
const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const COMBAT_OUTCOME_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_outcome_overlay.gd")
const COMBAT_RESOLVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_resolve_presenter.gd")
const COMBAT_DEBUG_RUNTIME_SCRIPT := preload("res://scripts/combat/combat_debug_runtime.gd")
const COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_settings_command_handler.gd")
const COMBAT_TIMER_SERVICE_SCRIPT := preload("res://scripts/combat/combat_timer_service.gd")
const COMBAT_BOSS_REWARD_HANDLER_SCRIPT := preload("res://scripts/combat/combat_boss_reward_handler.gd")
const COMBAT_TURN_LOG_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_turn_log_presenter.gd")
const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const BOARD_CONTROLLER_SCRIPT := preload("res://scripts/board/board_controller.gd")
const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")
const COMBAT_HUD_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_hud_presenter.gd")
const COMBAT_HUD_STAGE_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_hud_stage_coordinator.gd")
const COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_mastery_preview_coordinator.gd")
const COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_loadout_command_handler.gd")
const COMBAT_INTENT_HOVER_HANDLER_SCRIPT := preload("res://scripts/combat/combat_intent_hover_handler.gd")
const COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT := preload("res://scripts/combat/combat_scene_transition_handler.gd")
const COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_prompt_presenter.gd")
const COMBAT_CONSUMABLE_SERVICE_SCRIPT := preload("res://scripts/combat/combat_consumable_service.gd")
const COMBAT_GUIDANCE_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")

const COMBAT_PHASE_INTENT_PREVIEW := 0
const COMBAT_PHASE_VICTORY := 6
const COMBAT_PHASE_DEFEAT := 7
const MAX_COMBAT_LOG_LINES := 120
const COMMAND_OUTPUT_LOG_COLOR := Color(0.45, 0.95, 0.45, 1.0)
const LOG_LEVEL_NORMAL := "normal"
const LOG_LEVEL_DETAILED := "detailed"
const STATUS_COLOR_NEUTRAL := Color(1.0, 1.0, 1.0, 1.0)
const STATUS_COLOR_POSITIVE := Color(0.65, 1.0, 0.72, 1.0)
const STATUS_COLOR_WARNING := Color(1.0, 0.86, 0.54, 1.0)
const STATUS_COLOR_NEGATIVE := Color(1.0, 0.62, 0.62, 1.0)
const ICON_INNER_SIZE := Vector2(74, 74)
const SLOT_SIZE := Vector2(88, 88)
const MASTERY_ICON_INNER_SIZE := Vector2(34, 34)
const MASTERY_SLOT_SIZE := Vector2(44, 44)
const DESIGN_SIZE := Vector2(1080, 1920)
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(518, 136), Vector2(280, 88))
const FONT_SIZE_TITLE := 20
const FONT_SIZE_VALUE := 18
const FONT_SIZE_META := 15
const FONT_SIZE_ROW_LABEL := 16
const DEBUG_TEXT_FONT_SIZE := 24
const DEBUG_INPUT_FONT_SIZE := 24
const DEBUG_INPUT_HEIGHT := 72.0
const COMBO_POPUP_SIZE := Vector2(420.0, 96.0)
const COMBO_POPUP_BASE_FONT_SIZE := 42
const COMBO_POPUP_MAX_FONT_SIZE := 78
const COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS := 0.08
const COMBAT_SPEED_SLOW := "slow"
const COMBAT_SPEED_NORMAL := "normal"
const COMBAT_SPEED_FAST := "fast"
const COMBAT_SPEED_INSTANT := "instant"
const COMBO_COUNT_STEP_SECONDS := 0.22
const CASCADE_PASS_HOLD_SECONDS := 0.16
const TURN_REPLAY_STEP_SECONDS := 0.34
const TURN_REPLAY_FINAL_HOLD_SECONDS := 0.22
const ELEMENTAL_CAST_SPOOL_SECONDS := 0.86
const ELEMENTAL_CAST_LAUNCH_SECONDS := 0.82
const ELEMENTAL_CAST_IMPACT_HOLD_SECONDS := 0.50
const COMBAT_MASTERY_RESOLUTION_ORDER: Array[int] = [
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
]
enum InputPhase {
	PLAYER_INPUT,
	RESOLVING,
	LOCKED_EXTERNAL,
}

var _settings := BoardGenerationSettings.new()
var _board_model := BoardModel.new()
var _resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()
var _combat: Variant
var _player_state: PlayerState
var _enemy_state: EnemyState
var _progression_state: PlayerProgressionState

var _last_resolve_result: Dictionary = {}
var _consumable_rng := RandomNumberGenerator.new()
var _visuals: VisualRegistry = null
var _player_loadout_hud: PlayerLoadoutHud = null
var _outcome_overlay: CombatOutcomeOverlay = null
var _debug_runtime: Variant = null
var _debug_console: CombatDebugConsole = null
var _settings_command_handler: Variant = null
var _combat_timer_service: Variant = null
var _boss_reward_handler: Variant = null
var _turn_log_presenter: Variant = null
var _zone_guides_enabled := false
var _resolve_presenter: Variant = null
var _combat_vfx_presenter: Variant = null
var _board_controller: Variant = null
var _hud_presenter: Variant = null
var _hud_stage_coordinator: Variant = null
var _mastery_preview_coordinator: Variant = null
var _loadout_command_handler: Variant = null
var _intent_hover_handler: Variant = null
var _scene_transition_handler: Variant = null
var _tutorial_prompt_presenter: Variant = null
var _combat_consumable_service: Variant = null
var _tutorial_director: Variant = null
var _tutorial_drag_board_snapshot: BoardModel = null
var _host: Control = null
var _model = null
var _view = null


func bind(host: Control, root_nodes: Dictionary, model, view) -> void:
	_host = host
	_model = model
	if _model == null:
		_model = CombatModel.new()
	_view = view
	if _model != null:
		_model.set_combat_speed(_model.combat_speed())
	if _view != null:
		_view.bind(root_nodes)
	for node_name in root_nodes.keys():
		if node_name in self:
			set(node_name, root_nodes[node_name])
	if _board_view == null:
		_board_view = _resolve_board_view()
	_sync_model_state()


func enter_tree() -> void:
	_enter_tree()


func ready() -> void:
	_ready()


func exit_tree() -> void:
	_exit_tree()


func process(delta: float) -> void:
	_process(delta)


func unhandled_input(event: InputEvent) -> void:
	_unhandled_input(event)


func on_viewport_size_changed() -> void:
	_on_viewport_size_changed()


func on_back_button_pressed() -> void:
	_on_back_button_pressed()


func on_debug_toggle_button_pressed() -> void:
	_on_debug_toggle_button_pressed()


func on_settings_button_pressed() -> void:
	_on_settings_button_pressed()


func on_next_button_pressed() -> void:
	_on_next_button_pressed()

func _enter_tree() -> void:
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_active_route_id())
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_begin(
			"combat_scene_load",
			"res://scenes/combat.tscn",
			{"source": "combat._enter_tree"}
		))
	_sync_model_state()
	RunState.flow_trace_mark("combat_enter_tree", {}, _flow_trace_route_id_value())


func _resolve_board_view() -> BoardView:
	if _board != null and is_instance_valid(_board):
		var board_scene_unique: Node = _board.get_node_or_null("%BoardView")
		if board_scene_unique is BoardView:
			return board_scene_unique as BoardView
		var board_scene_path: Node = _board.get_node_or_null("BoardFrame/BoardAspect/BoardView")
		if board_scene_path is BoardView:
			return board_scene_path as BoardView
	var absolute_path: Node = _host.get_node_or_null("CombatLayoutRoot/BoardPanel/Board/BoardFrame/BoardAspect/BoardView")
	if absolute_path is BoardView:
		return absolute_path as BoardView
	push_error("CombatPlayerController: unable to resolve BoardView under CombatLayoutRoot/BoardPanel/Board.")
	return null


func _ready() -> void:
	if _board_view == null:
		push_error("CombatPlayerController._ready aborted because BoardView failed to resolve.")
		return
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_active_route_id())
	if _flow_trace_route_id_value() == "":
		_set_flow_trace_route_id(RunState.flow_trace_begin(
			"combat_scene_load",
			"res://scenes/combat.tscn",
			{"source": "combat._ready"}
		))
	RunState.flow_trace_mark("combat_ready_start", {}, _flow_trace_route_id_value())
	_audio_play_music("combat")
	RunState.flow_trace_mark("combat_after_music", {}, _flow_trace_route_id_value())
	_ensure_runtime_helpers()
	_bind_outcome_overlay()
	_bind_boss_reward_handler()
	if _resolve_presenter == null:
		_resolve_presenter = COMBAT_RESOLVE_PRESENTER_SCRIPT.new()
	var spawn_vfx_texture_callback: Callable = Callable(self, "_spawn_vfx_texture")
	var resolve_presenter_bindings := {
		"board": _board,
		"board_view": _board_view,
		"board_panel": null,
		"board_controller": _board_controller,
		"timer_owner": _host,
		"spawn_vfx_texture_callback": spawn_vfx_texture_callback,
		"combo_sound_callback": _on_presenter_combo_sound,
	}
	if _view != null:
		resolve_presenter_bindings = _view.resolve_presenter_bindings(
			_board_controller,
			_host,
			spawn_vfx_texture_callback,
			_on_presenter_combo_sound
		)
	_resolve_presenter.bind(resolve_presenter_bindings)
	_resolve_presenter.set_combat_speed(_combat_speed_value())
	_bind_debug_console()
	_bind_settings_command_handler()
	_consumable_rng.randomize()
	if _view != null:
		_view.bootstrap_background()
	RunState.flow_trace_mark("combat_texture_map_deferred", {}, _flow_trace_route_id_value())
	_ensure_boss_reward_controls()
	_ensure_outcome_overlay_layer()
	if _view != null:
		_view.set_dependencies({
			"visual_registry": _visuals,
			"player_loadout_hud": _player_loadout_hud,
			"debug_console": _debug_console,
			"outcome_overlay": _outcome_overlay,
		})
		_view.setup_rendering_helpers()
	RunState.flow_trace_mark("combat_after_boss_outcome_controls", {}, _flow_trace_route_id_value())
	if _view != null:
		_view.bind_player_hud()
	_bind_combat_vfx_presenter()
	if _view != null:
		_view.bind_layout_presenter()
	_bind_board_controller()
	RunState.flow_trace_mark("combat_after_hud_bind", {}, _flow_trace_route_id_value())
	_apply_visual_chrome()
	RunState.flow_trace_mark("combat_after_chrome", {}, _flow_trace_route_id_value())
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_player_loadout_hud.consumable_slot_selected.connect(_try_use_consumable_slot)
	_player_loadout_hud.sell_slot_requested.connect(_on_player_hud_sell_slot_requested)
	_player_loadout_hud.intent_preview_hovered.connect(_on_intent_damage_preview_hovered)
	_player_loadout_hud.intent_block_preview_hovered.connect(_on_intent_block_preview_hovered)
	_player_loadout_hud.intent_preview_hover_ended.connect(_on_intent_damage_preview_hover_ended)
	_connect_view_signals()
	_initialize_combat_state()
	RunState.flow_trace_mark("combat_after_initialize_state", {}, _flow_trace_route_id_value())
	_create_new_board()
	RunState.flow_trace_mark("combat_after_board_create", {}, _flow_trace_route_id_value())
	if _debug_runtime != null:
		_debug_runtime.bootstrap_hidden(Callable(self, "_on_console_input_text_submitted"))
	_host.get_viewport().size_changed.connect(_on_viewport_size_changed)
	if _view != null:
		_view.set_vfx_layer_visible(true)
	_host.set_process(true)
	_apply_combat_layout()
	RunState.flow_trace_mark("combat_after_layout", {}, _flow_trace_route_id_value())
	_begin_turn_preview()
	RunState.flow_trace_mark("combat_after_begin_turn_preview", {}, _flow_trace_route_id_value())
	call_deferred("_trace_flow_first_usable_frame")
	call_deferred("_apply_orb_texture_map_deferred")


func _ensure_runtime_helpers() -> void:
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	if _player_loadout_hud == null:
		_player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
	_player_loadout_hud.set_visual_registry(_visuals)
	if _outcome_overlay == null:
		_outcome_overlay = COMBAT_OUTCOME_OVERLAY_SCRIPT.new()
	if _turn_log_presenter == null:
		_turn_log_presenter = COMBAT_TURN_LOG_PRESENTER_SCRIPT.new()
	if _debug_runtime == null:
		_debug_runtime = COMBAT_DEBUG_RUNTIME_SCRIPT.new()
	_debug_console = _debug_runtime.console()
	if _settings_command_handler == null:
		_settings_command_handler = COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT.new()
	if _combat_timer_service == null:
		_combat_timer_service = COMBAT_TIMER_SERVICE_SCRIPT.new()
	if _boss_reward_handler == null:
		_boss_reward_handler = COMBAT_BOSS_REWARD_HANDLER_SCRIPT.new()
	if _combat_vfx_presenter == null:
		_combat_vfx_presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	if _board_controller == null:
		_board_controller = BOARD_CONTROLLER_SCRIPT.new()
	if _hud_presenter == null:
		_hud_presenter = COMBAT_HUD_PRESENTER_SCRIPT.new()
	if _hud_stage_coordinator == null:
		_hud_stage_coordinator = COMBAT_HUD_STAGE_COORDINATOR_SCRIPT.new()
	if _mastery_preview_coordinator == null:
		_mastery_preview_coordinator = COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT.new()
	if _loadout_command_handler == null:
		_loadout_command_handler = COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.new()
	if _intent_hover_handler == null:
		_intent_hover_handler = COMBAT_INTENT_HOVER_HANDLER_SCRIPT.new()
	if _scene_transition_handler == null:
		_scene_transition_handler = COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.new()
	if _tutorial_prompt_presenter == null:
		_tutorial_prompt_presenter = COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT.new()
	if _combat_consumable_service == null:
		_combat_consumable_service = COMBAT_CONSUMABLE_SERVICE_SCRIPT.new()
	if _tutorial_director == null:
		_tutorial_director = COMBAT_GUIDANCE_DIRECTOR_SCRIPT.new()
	if _combat_consumable_service != null and _combat_consumable_service.has_method("bind"):
		_combat_consumable_service.bind({
			"convert_random_non_target_orbs": Callable(self, "_convert_random_non_target_orbs"),
		})


func _bind_debug_console() -> void:
	if _debug_runtime == null:
		_debug_runtime = COMBAT_DEBUG_RUNTIME_SCRIPT.new()
	_debug_runtime.bind_for_combat_controller(
		_view,
		_turn_log_presenter,
		self,
		int(InputPhase.LOCKED_EXTERNAL),
		{
			"command_output_log_color": COMMAND_OUTPUT_LOG_COLOR,
			"max_combat_log_lines": MAX_COMBAT_LOG_LINES,
			"initial_log_level": LOG_LEVEL_NORMAL,
		}
	)
	_debug_console = _debug_runtime.console()


func _bind_settings_command_handler() -> void:
	if _settings_command_handler == null:
		_settings_command_handler = COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT.new()
	_settings_command_handler.bind_for_combat_controller(
		_view,
		_model,
		_resolve_presenter,
		self,
		int(InputPhase.PLAYER_INPUT),
		int(InputPhase.LOCKED_EXTERNAL),
		STATUS_COLOR_NEUTRAL
	)


func _settings_current_turn_index() -> int:
	return int(_combat.turn_index if _combat != null else 1)


func _settings_trace_and_change_scene(scene_path: String, trace_source: String, trace_mark: String) -> void:
	_trace_and_change_scene_to_target(scene_path, _flow_trace_route_id_value(), trace_source, trace_mark)


func _connect_view_signals() -> void:
	if _view == null:
		return
	_view.enemy_intent_bubble_hovered.connect(_on_enemy_intent_bubble_hovered)
	_view.enemy_block_preview_hovered.connect(_on_enemy_block_preview_hovered)
	_view.intent_hover_ended.connect(_on_intent_damage_preview_hover_ended)
	_view.tutorial_end_continue_pressed.connect(_on_tutorial_end_continue_pressed)
	_view.tutorial_end_main_menu_pressed.connect(_on_tutorial_end_main_menu_pressed)
	_view.settings_continue_pressed.connect(_on_settings_continue_pressed)
	_view.settings_new_run_pressed.connect(_on_settings_new_run_pressed)
	_view.settings_main_menu_pressed.connect(_on_settings_main_menu_pressed)
	_view.settings_speed_selected.connect(_on_settings_speed_selected)


func _exit_tree() -> void:
	_clear_combat_mastery_hover_state()


func _trace_flow_first_usable_frame() -> void:
	RunState.flow_trace_mark(
		"combat_first_usable_frame",
		{"source": "combat._ready_deferred"},
		_flow_trace_route_id_value()
	)


func _apply_orb_texture_map_deferred() -> void:
	_board_view.set_orb_texture_map({
		OrbType.Id.FIRE: _visuals.orb_texture(OrbType.Id.FIRE),
		OrbType.Id.ICE: _visuals.orb_texture(OrbType.Id.ICE),
		OrbType.Id.EARTH: _visuals.orb_texture(OrbType.Id.EARTH),
		OrbType.Id.HEART: _visuals.orb_texture(OrbType.Id.HEART),
		OrbType.Id.ARMOR: _visuals.orb_texture(OrbType.Id.ARMOR),
		OrbType.Id.GOLD: _visuals.orb_texture(OrbType.Id.GOLD),
	})
	RunState.flow_trace_mark("combat_after_texture_map", {}, _flow_trace_route_id_value())


func _bind_combat_vfx_presenter() -> void:
	if _combat_vfx_presenter == null or _view == null:
		return
	var view_bindings: Variant = _view.vfx_presenter_bindings(_visuals, _player_loadout_hud, _host)
	if view_bindings is Dictionary:
		_combat_vfx_presenter.bind(view_bindings)
		_apply_vfx_speed_setting()


func _bind_board_controller() -> void:
	if _board_controller == null:
		return
	_board_controller.bind(
		{
			"board_view": _board_view,
			"board_model": _board_model,
		},
		{
			"swap_animation_seconds": SWAP_ANIMATION_SECONDS,
			"swap_sound_callback": _on_drag_swap_success,
			"match_groups_callback": _drag_match_groups,
			"move_timer_seconds_callback": _drag_move_timer_seconds,
			"drag_input_result_callback": _on_board_drag_input_result,
			"hovered_orb_changed_callback": _on_board_hovered_orb_changed,
		}
	)


func _on_drag_swap_success() -> void:
	_audio_play_sfx("swap")


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
	if _view != null:
		_view.apply_visual_chrome({
			"font_size_title": FONT_SIZE_TITLE,
			"font_size_value": FONT_SIZE_VALUE,
			"font_size_meta": FONT_SIZE_META,
			"font_size_row_label": FONT_SIZE_ROW_LABEL,
			"debug_text_font_size": DEBUG_TEXT_FONT_SIZE,
			"debug_input_font_size": DEBUG_INPUT_FONT_SIZE,
			"debug_input_height": DEBUG_INPUT_HEIGHT,
		})
		_view.set_top_bar_text(RunState.level_sequence_label(), "Gold 0")


func _initialize_combat_state() -> void:
	if not RunState.run_active:
		RunState.flow_trace_mark(
			"combat_initialize_no_active_run_starting_new",
			{},
			_flow_trace_route_id_value()
		)
		RunState.start_new_run()
	if RunState.is_current_step_boss_reward():
		_player_state = RunState.ensure_player_state()
		_progression_state = RunState.ensure_player_progression_state()
		_player_state.set_mastery_level_provider(Callable(_progression_state, "mastery_level"))
		var preview: Dictionary = RunState.current_level_boss_preview()
		_enemy_state = ENEMY_STATE_SCRIPT.new()
		_enemy_state.configure_from_blueprint(preview)
		_bind_hud_stage_coordinator()
		_combat = null
		_model.clear_outcome_transition_queued()
		_model.clear_pending_next_scene_path()
		_hide_outcome_summary()
		_refresh_character_portraits()
		_refresh_build_icon_rows(_progression_state.to_snapshot())
		_show_boss_reward_summary("Boss defeated.")
		_set_status_text("Boss defeated. Choose one boss relic before continuing.")
		_set_status_color(STATUS_COLOR_WARNING)
		RunState.flow_trace_mark("combat_initialize_boss_reward_overlay", {}, _flow_trace_route_id_value())
		return
	if not RunState.is_current_step_fight():
		var redirect_scene := RunState.next_scene_path()
		if redirect_scene != "":
			RunState.flow_trace_mark(
				"combat_initialize_redirect_before_change_scene",
				{"source": "_initialize_combat_state"},
				_flow_trace_route_id_value(),
				redirect_scene
			)
			var change_result: Variant = RunState.flow_trace_change_scene(
				_host.get_tree(),
				redirect_scene,
				_flow_trace_route_id_value(),
				"combat._initialize_combat_state",
				"",
				_on_combat_scene_post_ready_rollback
			)
			if not FLOW_RESULT_UTILS.scene_change_succeeded(change_result):
				_handle_combat_scene_change_failure(
					redirect_scene,
					_flow_trace_route_id_value(),
					"combat._initialize_combat_state",
					change_result
				)
		return

	_player_state = RunState.ensure_player_state()
	_progression_state = RunState.ensure_player_progression_state()
	_player_state.set_mastery_level_provider(Callable(_progression_state, "mastery_level"))
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	_enemy_state = ENEMY_STATE_SCRIPT.new()
	_enemy_state.configure_from_blueprint(encounter)
	_bind_hud_stage_coordinator()
	_refresh_character_portraits()
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_model.clear_outcome_transition_queued()
	_model.clear_pending_next_scene_path()
	_hide_outcome_summary()
	_update_hud()
	if _debug_runtime != null:
		_debug_runtime.clear_log()
	_append_combat_log("Run flow: %s" % RunState.level_sequence_label())
	if String(encounter.get("step_key", "")) == "enemy_1":
		_append_combat_log("Level %d boss preview: %s." % [RunState.dungeon_level, RunState.current_level_boss_name()])
	_append_combat_log("Fight started: %s HP %d." % [_enemy_state.display_name, _enemy_state.max_hp])
	_append_combat_log("Player start: HP %d/%d, Gold %d." % [_player_state.current_hp, _player_state.max_hp, _player_state.gold])
	if content_errors.is_empty():
		_append_combat_log("Milestone 5 content validation: OK.")
	else:
		_append_combat_log("Milestone 5 content validation: %d issue(s)." % content_errors.size())
		for error in content_errors:
			_append_combat_log("  - [%s] %s" % [String(error.get("item_id", "?")), String(error.get("reason", "unknown"))])


func _begin_turn_preview() -> void:
	if _combat == null:
		return
	if _combat.is_fight_over():
		return

	_combat.reset_to_intent_preview()
	_combat.begin_player_input()
	_set_input_phase(InputPhase.PLAYER_INPUT)
	_model.clear_pending_next_scene_path()
	_hide_outcome_summary()
	_set_turn_summary_text(_tutorial_turn_summary_text() if RunState.is_tutorial_run() else "Turn Summary: Awaiting move.")
	_set_status_text(
		_tutorial_turn_status_text()
		if RunState.is_tutorial_run()
		else "%s | Turn %d." % [
			RunState.level_sequence_label(),
			_combat.turn_index,
		]
	)
	_set_status_color(STATUS_COLOR_NEUTRAL)
	_update_hud()
	_clear_combat_mastery_hover_state()
	_sync_tutorial_coachmark()
	_append_combat_log(
		"Turn %d intent: %s." % [
			_combat.turn_index,
			_debug_format_intent(_enemy_state.get_current_intent()),
		]
	)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			_toggle_debug_overlay()
			_host.get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F2:
			_zone_guides_enabled = not _zone_guides_enabled
			if _view != null:
				_view.set_zone_guides_enabled(_zone_guides_enabled)
			_host.get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_R:
			_create_new_board()
			_host.get_viewport().set_input_as_handled()
		elif event.keycode == KEY_P:
			_print_board_model()
			_host.get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_try_use_first_consumable()
			_host.get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var handled_click := false
		if _view != null:
			handled_click = bool(_view.handle_player_hud_global_click((event as InputEventMouseButton).position))
		if handled_click:
			_host.get_viewport().set_input_as_handled()


func _on_debug_toggle_button_pressed() -> void:
	_toggle_debug_overlay()


func _toggle_debug_overlay() -> void:
	if _debug_runtime != null:
		_debug_runtime.toggle_overlay()
	_update_hud()


func _on_regenerate_button_pressed() -> void:
	_create_new_board()


func _on_print_board_button_pressed() -> void:
	_print_board_model()


func _on_back_button_pressed() -> void:
	_on_settings_button_pressed()


func _on_settings_button_pressed() -> void:
	_bind_settings_command_handler()
	_settings_command_handler.open()


func _on_settings_continue_pressed() -> void:
	_bind_settings_command_handler()
	_settings_command_handler.continue_combat()


func _on_settings_new_run_pressed() -> void:
	_bind_settings_command_handler()
	_settings_command_handler.start_new_run()


func _on_settings_main_menu_pressed() -> void:
	_bind_settings_command_handler()
	_settings_command_handler.return_to_main_menu()


func _on_settings_speed_selected(speed: String) -> void:
	_bind_settings_command_handler()
	_settings_command_handler.select_speed(speed)


func _on_tutorial_end_continue_pressed() -> void:
	if _tutorial_director != null and _tutorial_director.advance_post_shop_step() != "":
		_show_shop_damage_tutorial_end_modal()
		_audio_play_sfx("ui_accept")
		return
	if RunState.has_method("finish_tutorial_guidance"):
		RunState.finish_tutorial_guidance()
	if _view != null and _view.has_method("hide_tutorial_end_modal"):
		_view.hide_tutorial_end_modal()
	_audio_play_sfx("ui_accept")
	_set_status_text("%s | Turn %d." % [RunState.level_sequence_label(), _combat.turn_index if _combat != null else 1])
	_set_status_color(STATUS_COLOR_NEUTRAL)
	_update_hud()


func _on_tutorial_end_main_menu_pressed() -> void:
	if _tutorial_director != null:
		_tutorial_director.dismiss_end_choice()
	if RunState.has_method("finish_tutorial_guidance"):
		RunState.finish_tutorial_guidance()
	if _view != null and _view.has_method("hide_tutorial_end_modal"):
		_view.hide_tutorial_end_modal()
	_audio_play_sfx("ui_accept")
	_trace_and_change_scene_to_target(
		"res://scenes/main_menu.tscn",
		_flow_trace_route_id_value(),
		"tutorial_end_main_menu",
		"combat_before_change_scene_to_file_tutorial_end_main_menu"
	)


func _on_run_tests_button_pressed() -> void:
	var report: Dictionary = TEST_RUNNER_SCRIPT.run_all()
	if bool(report.get("passed", false)):
		_set_status_text("Tests passed (%d cases)." % int(report.get("total", 0)))
		print("[Combat Debug Tests] Passed %d cases across %d suites." % [
			int(report.get("total", 0)),
			int(report.get("suite_count", 0)),
		])
		return

	_set_status_text("Tests failed (%d/%d). See output." % [int(report.get("failed", 0)), int(report.get("total", 0))])
	push_warning("Combat debug tests failed:\n%s" % "\n".join(Array(report.get("failures", []))))


func _on_add_test_equipment_button_pressed() -> void:
	_bind_loadout_command_handler()
	_loadout_command_handler.add_test_equipment()


func _on_add_test_consumable_button_pressed() -> void:
	_bind_loadout_command_handler()
	_loadout_command_handler.add_test_consumable()


func _try_use_first_consumable() -> void:
	_bind_loadout_command_handler()
	_loadout_command_handler.try_use_first_consumable()


func _try_use_consumable_slot(slot_index: int) -> void:
	_bind_loadout_command_handler()
	_loadout_command_handler.try_use_consumable_slot(slot_index)


func _on_player_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	_bind_loadout_command_handler()
	_loadout_command_handler.sell_slot_requested(slot_type, slot_index)


func _convert_random_non_target_orbs(target_orb_id: int, count: int, rng: RandomNumberGenerator) -> int:
	if _board_controller == null:
		return 0
	return int(_board_controller.convert_random_non_target_orbs(target_orb_id, count, rng))


func _process(delta: float) -> void:
	if _combat_timer_service == null:
		return
	var drag_update: Dictionary = _combat_timer_service.process(
		_board_controller,
		_view,
		_player_state,
		delta,
		_input_phase_value() == InputPhase.PLAYER_INPUT
	)
	_handle_drag_input_result(drag_update)


func _on_board_drag_input_result(drag_result: Dictionary) -> void:
	_handle_drag_input_result(drag_result)


func _on_board_hovered_orb_changed(orb_id: int) -> void:
	_set_hovered_board_orb_id(orb_id)


func _set_hovered_board_orb_id(orb_id: int) -> void:
	var normalized_orb_id := orb_id if _is_hoverable_combat_orb(orb_id) else -1
	if _model.hovered_board_orb_id() == normalized_orb_id:
		return
	_model.set_hovered_board_orb_id(normalized_orb_id)
	if _model.hovered_board_orb_id() < 0:
		if _view != null:
			_view.clear_hovered_combat_mastery()
		return
	if _view != null:
		_view.set_hovered_combat_mastery(_model.hovered_board_orb_id())


func _is_hoverable_combat_orb(orb_id: int) -> bool:
	if not OrbType.is_valid_id(orb_id):
		return false
	return orb_id in [
		OrbType.Id.FIRE,
		OrbType.Id.ICE,
		OrbType.Id.EARTH,
		OrbType.Id.HEART,
		OrbType.Id.ARMOR,
		OrbType.Id.GOLD,
	]


func _clear_combat_mastery_hover_state() -> void:
	_model.clear_hovered_board_orb_id()
	if _view != null:
		_view.clear_combat_mastery_hover_ui()


func _build_combat_mastery_hover_payload(progression_snapshot: Dictionary) -> Dictionary:
	return {
		"orb_values_by_id": _orb_values_by_id(),
		"mastery_levels": Dictionary(progression_snapshot.get("mastery_levels", {})),
		"combat_modifiers": RunState.current_combat_modifiers(),
	}


func _handle_drag_input_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	var action := String(result.get("action", ""))
	if action == "start":
		_clear_combat_mastery_hover_state()
		var tutorial_start_path := _active_tutorial_drag_path()
		if not tutorial_start_path.is_empty() and _board_model != null:
			_tutorial_drag_board_snapshot = _board_model.clone()
		var selected_orb_id := int(result.get("selected_orb_id", -1))
		if _view != null:
			_view.sync_timer_display(_drag_move_time_left(), COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_ACTIVE)
		_set_status_text("Dragging %s orb. Move timer running." % OrbType.display_name(selected_orb_id))
		_set_status_color(STATUS_COLOR_NEUTRAL)
		return
	if action == "end":
		var drag_path: Array = result.get("path", [])
		var tutorial_drag_path := _active_tutorial_drag_path()
		if not tutorial_drag_path.is_empty():
			if _tutorial_director == null or not _tutorial_director.did_complete_drag_path(drag_path, tutorial_drag_path):
				_reset_incomplete_tutorial_drag()
				_set_status_text(_active_tutorial_retry_status_text())
				_set_status_color(STATUS_COLOR_WARNING)
				_sync_tutorial_coachmark()
				return
			_tutorial_drag_board_snapshot = null
			_hide_tutorial_coachmark()
		_end_drag(bool(result.get("timed_out", false)))


func _create_new_board() -> void:
	var board_seed := _resolve_seed()
	_set_board_seed(board_seed)
	if _combat != null and not _combat.is_fight_over():
		_set_status_text("Seed: %d | Turn %d ready." % [board_seed, _combat.turn_index])
	else:
		_set_status_text("Seed: %d | Fight complete." % board_seed)
	_sync_tutorial_coachmark()


func _resolve_seed() -> int:
	if RunState.has_method("tutorial_board_seed_for_turn") and RunState.is_tutorial_run():
		var tutorial_seed := int(RunState.tutorial_board_seed_for_turn(_combat.turn_index if _combat != null else 1))
		if tutorial_seed > 0:
			return tutorial_seed
	return int(Time.get_ticks_usec())


func _tutorial_turn_summary_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.turn_summary_text()


func _tutorial_turn_status_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.turn_status_text(int(_combat.turn_index if _combat != null else 1))


func _sync_tutorial_coachmark() -> void:
	var step := _active_tutorial_step()
	if step == COMBAT_GUIDANCE_DIRECTOR_SCRIPT.STEP_SHOP_DAMAGE:
		_show_shop_damage_tutorial_end_modal()
		return
	var tutorial_path := _active_tutorial_drag_path_for_step(step)
	if not tutorial_path.is_empty():
		_focus_tutorial_intent_for_step(step)
		_apply_tutorial_drag_coachmark(
			tutorial_path,
			_tutorial_director.prompt_message(step),
			_tutorial_director.prompt_anchor(step)
		)
		return
	if _view != null and _view.has_method("is_tutorial_end_modal_visible") and bool(_view.is_tutorial_end_modal_visible()):
		_view.hide_tutorial_end_modal()
	_hide_tutorial_coachmark()


func _apply_tutorial_drag_coachmark(path: Array[Vector2i], message: String, prompt_anchor: String) -> void:
	if path.is_empty():
		return
	var from_cell := path[0]
	var to_cell := path[path.size() - 1]
	if _board_view != null and _board_view.has_method("set_tutorial_hint"):
		_board_view.set_tutorial_hint(from_cell, to_cell, path)
	if _board_controller != null:
		if _board_controller.has_method("set_restricted_drag_path"):
			_board_controller.set_restricted_drag_path(path)
		elif path.size() >= 2 and _board_controller.has_method("set_restricted_swap"):
			_board_controller.set_restricted_swap(path[0], path[1])
	_show_tutorial_prompt(message, prompt_anchor)


func _active_tutorial_step() -> String:
	if _tutorial_director == null:
		return COMBAT_GUIDANCE_DIRECTOR_SCRIPT.STEP_NONE
	return _tutorial_director.active_step({
		"tutorial_run_active": RunState.is_tutorial_run(),
		"fight_over": _combat == null or _combat.is_fight_over(),
		"input_is_player_input": _input_phase_value() == InputPhase.PLAYER_INPUT,
		"dungeon_level": RunState.dungeon_level,
		"step_key": String(RunState.current_step_key),
		"turn_index": int(_combat.turn_index if _combat != null else 1),
		"progression_snapshot": RunState.progression_snapshot(),
	})


func _show_shop_damage_tutorial_end_modal() -> void:
	_hide_tutorial_coachmark()
	if _view == null or not _view.has_method("show_tutorial_end_modal"):
		return
	var post_shop_step: String = _tutorial_director.post_shop_step() if _tutorial_director != null else COMBAT_GUIDANCE_DIRECTOR_SCRIPT.POST_SHOP_END
	_view.show_tutorial_end_modal(post_shop_step)
	if _tutorial_director != null:
		_set_status_text(_tutorial_director.end_modal_status_text(post_shop_step))
	_set_status_color(STATUS_COLOR_WARNING)


func _active_tutorial_drag_path() -> Array[Vector2i]:
	return _active_tutorial_drag_path_for_step(_active_tutorial_step())


func _active_tutorial_drag_path_for_step(step: String) -> Array[Vector2i]:
	if _tutorial_director == null:
		return []
	return _tutorial_director.drag_path_for_step(step)


func _active_tutorial_retry_status_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.retry_status_text(_active_tutorial_step())


func _focus_tutorial_intent_for_step(step: String) -> void:
	if _tutorial_director == null:
		return
	match _tutorial_director.intent_focus_kind(step):
		"attack":
			_focus_tutorial_enemy_attack_intent()
		"block":
			_focus_tutorial_enemy_block_intent()


func _focus_tutorial_enemy_attack_intent() -> void:
	if _view == null:
		return
	if _view.has_method("set_tutorial_enemy_intent_focus"):
		_view.set_tutorial_enemy_intent_focus("attack")
	if _view.has_method("start_enemy_intent_hover_emphasis"):
		_view.start_enemy_intent_hover_emphasis("attack")


func _focus_tutorial_enemy_block_intent() -> void:
	if _view == null:
		return
	if _view.has_method("set_tutorial_enemy_intent_focus"):
		_view.set_tutorial_enemy_intent_focus("block")
	if _view.has_method("start_enemy_intent_hover_emphasis"):
		_view.start_enemy_intent_hover_emphasis("block")


func _clear_tutorial_enemy_intent_focus() -> void:
	if _view == null:
		return
	if _view.has_method("clear_tutorial_enemy_intent_focus"):
		_view.clear_tutorial_enemy_intent_focus()
	elif _view.has_method("stop_enemy_intent_hover_emphasis"):
		_view.stop_enemy_intent_hover_emphasis()


func _reset_incomplete_tutorial_drag() -> void:
	if _board_controller == null:
		return
	if _tutorial_drag_board_snapshot != null:
		_board_controller.abort()
		_board_controller.set_board_model(_tutorial_drag_board_snapshot.clone())
		_board_model = _board_controller.current_board_model()
		_tutorial_drag_board_snapshot = null
		return
	var current_seed := int(_board_controller.board_seed()) if _board_controller.has_method("board_seed") else -1
	if current_seed > 0:
		_set_board_seed(current_seed)
	elif _board_controller.has_method("reset_visuals"):
		_board_controller.reset_visuals()


func _show_tutorial_prompt(message: String, prompt_anchor: String = "above_board") -> void:
	_bind_tutorial_prompt_presenter()
	_tutorial_prompt_presenter.show(message, prompt_anchor)


func _hide_tutorial_coachmark() -> void:
	_bind_tutorial_prompt_presenter()
	_tutorial_prompt_presenter.hide()
	_tutorial_drag_board_snapshot = null
	_clear_tutorial_enemy_intent_focus()
	if _board_view != null and _board_view.has_method("clear_tutorial_hint"):
		_board_view.clear_tutorial_hint()
	if _board_controller != null:
		if _board_controller.has_method("clear_restricted_drag_path"):
			_board_controller.clear_restricted_drag_path()
		elif _board_controller.has_method("clear_restricted_swap"):
			_board_controller.clear_restricted_swap()


func _print_board_model() -> void:
	var debug_text: String = _board_controller.board_debug_string() if _board_controller != null else _board_model.to_debug_string()
	var board_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	print("\n[Board Debug] Seed=", board_seed)
	print(debug_text)
	_print_board_model_to_console()
	_set_status_text("Printed board for seed %d to output." % board_seed)


func _set_board_seed(board_seed: int) -> void:
	if _board_controller == null:
		push_error("CombatPlayerController._set_board_seed called before BoardController was bound.")
		return
	_board_controller.abort()
	_board_controller.clear_board_presentation()
	_board_controller.initialize_board(board_seed, _settings)
	_board_model = _board_controller.current_board_model()
	if _combat != null and not _combat.is_fight_over():
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _print_board_model_to_console() -> void:
	var board_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	var board_debug_text: String = _board_controller.board_debug_string() if _board_controller != null else _board_model.to_debug_string()
	_append_combat_log("Board seed: %d" % board_seed)
	var lines: PackedStringArray = board_debug_text.split("\n", false)
	for line in lines:
		_append_combat_log("  %s" % line)


func _on_console_input_text_submitted(text: String) -> void:
	if _debug_runtime != null:
		_debug_runtime.handle_submitted_text(text)


func _console_set_status_text(message: String) -> void:
	_set_status_text(message)


func _set_status_text(message: String) -> void:
	if _view != null:
		_view.set_status_text(message)


func _set_status_color(color: Color) -> void:
	if _view != null:
		_view.set_status_color(color)


func _set_turn_summary_text(text: String) -> void:
	if _view != null:
		_view.set_turn_summary_text(text)


func _pulse_turn_summary(tint: Color) -> void:
	if _view != null:
		_view.pulse_turn_summary(tint)


func _console_on_skip_success() -> void:
	if _board_controller != null:
		_board_controller.abort()
	_last_resolve_result.clear()
	_initialize_combat_state()
	_create_new_board()
	_begin_turn_preview()

func _debug_combat_state() -> Variant:
	return _combat


func _debug_enemy_state() -> Variant:
	return _enemy_state


func _debug_player_hp() -> int:
	return int(_player_state.current_hp if _player_state != null else 0)


func _debug_player_max_hp() -> int:
	return int(_player_state.max_hp if _player_state != null else 0)


func _debug_player_armor() -> int:
	return int(_player_state.armor if _player_state != null else 0)


func _debug_enemy_display_name() -> String:
	return String(_enemy_state.display_name if _enemy_state != null else "Unknown")


func _debug_enemy_hp() -> int:
	return int(_enemy_state.current_hp if _enemy_state != null else 0)


func _debug_enemy_max_hp() -> int:
	return int(_enemy_state.max_hp if _enemy_state != null else 0)


func _debug_enemy_turn_block() -> int:
	return int(_enemy_state.current_turn_block if _enemy_state != null else 0)


func _debug_input_phase_value() -> int:
	return int(_input_phase_value())


func _debug_format_intent(intent: Dictionary) -> String:
	if _turn_log_presenter != null:
		return _turn_log_presenter.format_intent(intent)
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func _debug_board_seed() -> int:
	return int(_board_controller.board_seed() if _board_controller != null else _board_model.rng_seed)


func _debug_board_debug_text() -> String:
	return String(_board_controller.board_debug_string() if _board_controller != null else _board_model.to_debug_string())


func _debug_set_input_phase(raw_phase: int) -> void:
	_set_input_phase(raw_phase as InputPhase)


func _debug_set_pending_next_scene_path(scene_path: String) -> void:
	_model.set_pending_next_scene_path(scene_path)


func _end_drag(timed_out: bool) -> void:
	if _board_controller == null:
		return

	if _view != null:
		_view.sync_timer_display(0.0, COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED)
	var move_end_reason := "released"
	if timed_out:
		move_end_reason = "timer expired"
	_set_status_text("Move ended: %s. Locking input for resolve phase." % move_end_reason)
	_set_status_color(STATUS_COLOR_WARNING)
	var resolve_trace_origin_usec := Time.get_ticks_usec()
	_model.begin_resolve_trace(resolve_trace_origin_usec, _resolve_trace_enabled())
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=resolve_start move_end_reason=\"%s\" board_seed=%d" % [move_end_reason, _board_model.rng_seed]
	)

	_board_controller.reset_visuals()
	_board_controller.clear_board_presentation()
	_set_input_phase(InputPhase.RESOLVING)
	_reset_combat_mastery_preview()
	var resolve_models: Dictionary = _board_controller.prepare_visual_model_for_resolve()
	var visual_board_model: BoardModel = resolve_models.get("visual_board_model") as BoardModel
	var simulation_board_model: BoardModel = resolve_models.get("simulation_board_model") as BoardModel
	if visual_board_model == null or simulation_board_model == null:
		visual_board_model = _board_model.clone()
		simulation_board_model = _board_model.clone()
		_board_view.set_board_presentation_model(visual_board_model)
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=visual_state_ready board_seed=%d" % visual_board_model.rng_seed
	)
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=simulation_resolve_start board_seed=%d" % simulation_board_model.rng_seed
	)
	_last_resolve_result = _resolver.resolve_all(simulation_board_model)
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=simulation_resolve_complete total_combos=%d passes=%d" % [
			int(_last_resolve_result.get("total_combos", 0)),
			Array(_last_resolve_result.get("passes", [])).size(),
		]
	)
	await _play_resolve_animations(_last_resolve_result, visual_board_model, resolve_trace_origin_usec)
	if not _can_continue_after_async_wait(true):
		_model.end_resolve_trace()
		return
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=resolve_presentation_complete total_combos=%d passes=%d" % [
			int(_last_resolve_result.get("total_combos", 0)),
			Array(_last_resolve_result.get("passes", [])).size(),
		]
	)
	_board_controller.commit_model_after_resolve(simulation_board_model)
	_board_model = _board_controller.current_board_model()
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=final_board_commit board_seed=%d" % _board_model.rng_seed
	)
	if _input_phase_value() == InputPhase.RESOLVING:
		await _resolve_combat_turn_from_board(_last_resolve_result)
		if not _can_continue_after_async_wait():
			_model.end_resolve_trace()
			return
	_model.end_resolve_trace()


func _resolve_combat_turn_from_board(resolve_result: Dictionary) -> void:
	if _combat == null:
		return
	_bind_hud_stage_coordinator()
	_model.begin_hud_staging(_hud_stage_coordinator.capture_values())
	var turn_log: Dictionary = _combat.resolve_player_turn(resolve_result)
	RunState.log_turn_result(
		turn_log,
		{
			"total_combos": int(resolve_result.get("total_combos", 0)),
			"resolve_pass_count": Array(resolve_result.get("passes", [])).size(),
		}
	)
	_sync_combat_mastery_preview_totals()
	RunState.flow_trace_mark(
		"combat_before_replay_turn_resolution_from_log",
		{
			"total_combos": int(resolve_result.get("total_combos", 0)),
			"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", 0)),
		},
		_flow_trace_route_id_value()
	)
	await _replay_turn_resolution_from_log(turn_log)
	if not _can_continue_after_async_wait():
		_model.clear_hud_staging()
		return
	_model.clear_hud_staging()
	_update_hud()
	RunState.flow_trace_mark(
		"combat_after_replay_turn_resolution_from_log",
		{
			"healed": int(turn_log.get("healed", 0)),
			"armor_gained": int(turn_log.get("armor_gained", 0)),
			"gold_gained": int(turn_log.get("gold_gained", 0)),
		},
		_flow_trace_route_id_value()
	)

	if _combat.phase == COMBAT_PHASE_VICTORY:
		_audio_play_sfx("victory")
		RunState.flow_trace_mark("combat_before_mark_fight_victory", {}, _flow_trace_route_id_value())
		var transition: Dictionary = RunState.mark_fight_victory()
		RunState.flow_trace_mark(
			"combat_after_mark_fight_victory",
			{
				"next_scene": String(transition.get("next_scene", "")),
				"step": String(transition.get("step", "")),
			},
			_flow_trace_route_id_value(),
			String(transition.get("next_scene", ""))
		)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_append_turn_log(turn_log)
		if RunState.is_current_step_boss_reward():
			_model.clear_pending_next_scene_path()
			_set_status_text("Boss defeated. Choose one boss relic before continuing.")
			_append_combat_log("Outcome: Boss victory. Waiting for boss relic selection in victory overlay.")
			_show_boss_reward_summary(_turn_log_presenter.build_victory_gold_summary(turn_log, transition))
			_set_turn_summary_text("Turn Summary: Boss victory. Choose a relic.")
			RunState.flow_trace_mark("combat_boss_reward_available", {}, _flow_trace_route_id_value())
		else:
			var next_scene := String(transition.get("next_scene", "res://scenes/main_menu.tscn"))
			if next_scene.find("run_summary") >= 0:
				_append_combat_log("Outcome: Final boss victory. Opening run summary.")
				_hide_outcome_summary()
				_trace_and_change_scene_to_target(
					next_scene,
					_flow_trace_route_id_value(),
					"combat_final_summary_auto",
					"combat_before_final_summary_change_scene"
				)
				return
			_set_status_text(_turn_log_presenter.build_victory_status(turn_log, transition) + " Press Continue.")
			_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
			_model.set_pending_next_scene_path(next_scene)
			_show_outcome_summary("Victory", _turn_log_presenter.build_victory_gold_summary(turn_log, transition), true)
			_set_turn_summary_text("Turn Summary: Victory. Press Continue.")
			RunState.flow_trace_mark(
				"combat_continue_available",
				{"button_text": "Continue"},
				_flow_trace_route_id_value(),
				next_scene
			)
		_pulse_turn_summary(STATUS_COLOR_POSITIVE)
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		_audio_play_sfx("defeat")
		var defeat_cause: String = _turn_log_presenter.build_defeat_cause(String(_enemy_state.display_name if _enemy_state != null else "Enemy"), turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_set_status_text(_turn_log_presenter.build_defeat_status(turn_log) + " Run Summary available.")
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Waiting for Run Summary button.")
		_model.set_pending_next_scene_path(String(defeat_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY)))
		_show_outcome_summary("Defeat", _build_run_outcome_summary(defeat_cause), true, "Run Summary")
		_set_turn_summary_text("Turn Summary: Defeat. Run Summary available.")
		RunState.flow_trace_mark(
			"combat_continue_available",
			{"button_text": "Run Summary"},
			_flow_trace_route_id_value(),
			_model.pending_next_scene_path()
		)
		_pulse_turn_summary(STATUS_COLOR_NEGATIVE)
		return

	_set_status_text(_turn_log_presenter.build_turn_summary_status(turn_log))
	_play_turn_result_sfx(turn_log)
	_set_status_color(STATUS_COLOR_POSITIVE)
	_set_turn_summary_text("Turn Summary: %s" % _turn_log_presenter.build_turn_summary_status(turn_log))
	_pulse_turn_summary(STATUS_COLOR_POSITIVE)
	_append_turn_log(turn_log)
	_begin_turn_preview()


func _on_next_button_pressed() -> void:
	_bind_boss_reward_handler()
	if _boss_reward_handler != null and _boss_reward_handler.handle_next_pressed():
		return
	if _model.pending_next_scene_path() == "":
		return
	RunState.flow_trace_mark(
		"combat_next_button_pressed",
		{"button_text": _view.next_button_text() if _view != null else ""},
		_flow_trace_route_id_value(),
		_model.pending_next_scene_path()
	)
	_audio_play_sfx("ui_accept")
	var target_scene: String = _model.take_pending_next_scene_path()
	_hide_outcome_summary()
	_trace_and_change_scene_to_target(
		target_scene,
		_flow_trace_route_id_value(),
		"combat_next_button",
		"combat_before_change_scene_to_file"
	)


func _play_turn_result_sfx(turn_log: Dictionary) -> void:
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if int(enemy_attack.get("hp_damage", 0)) > 0:
		_audio_play_sfx("hit")


func _play_mastery_effect_sfx(effect_kind: String) -> void:
	match effect_kind:
		"damage":
			_audio_play_sfx("hit")
		"heal":
			_audio_play_sfx("heal")
		"armor":
			_audio_play_sfx("armor")
		"gold":
			_audio_play_sfx("gold")


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(_host.get_tree())


func _bind_outcome_overlay() -> void:
	if _outcome_overlay == null or _view == null:
		return
	_view.bind_outcome_overlay(_outcome_overlay)


func _bind_boss_reward_handler() -> void:
	if _boss_reward_handler == null:
		_boss_reward_handler = COMBAT_BOSS_REWARD_HANDLER_SCRIPT.new()
	_boss_reward_handler.bind(
		_outcome_overlay,
		_view,
		_model,
		_visuals,
		{
			"set_status_text": Callable(self, "_set_status_text"),
			"update_hud": Callable(self, "_update_hud"),
			"play_sfx": Callable(self, "_audio_play_sfx"),
			"apply_layout": Callable(self, "_apply_combat_layout"),
			"trace_and_change_scene": Callable(self, "_boss_reward_trace_and_change_scene"),
		}
	)


func _boss_reward_trace_and_change_scene(scene_path: String, source: String, trace_mark: String, payload: Dictionary = {}) -> void:
	_trace_and_change_scene_to_target(scene_path, _flow_trace_route_id_value(), source, trace_mark, payload)


func _show_outcome_summary(title: String, body: String, show_next: bool, button_text: String = "Continue") -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.show_summary(title, body, show_next, button_text)
	_apply_combat_layout()


func _hide_outcome_summary() -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.hide()


func _ensure_boss_reward_controls() -> void:
	_bind_boss_reward_handler()
	if _boss_reward_handler == null:
		return
	_boss_reward_handler.ensure_controls()


func _show_boss_reward_summary(body: String) -> void:
	_bind_boss_reward_handler()
	if _boss_reward_handler == null:
		return
	_boss_reward_handler.show_summary(body)


func _trace_and_change_scene_to_target(
	target_scene: String,
	current_route_id: String,
	source: String,
	before_change_step: String,
	begin_payload_extra: Dictionary = {}
) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.trace_and_change_scene_to_target(
		target_scene,
		current_route_id,
		source,
		before_change_step,
		begin_payload_extra
	)


func _on_combat_scene_post_ready_rollback(result: Dictionary) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.on_scene_post_ready_rollback(result)


func _handle_combat_scene_change_failure(target_scene: String, route_id: String, source: String, result: Variant) -> void:
	_bind_scene_transition_handler()
	_scene_transition_handler.handle_scene_change_failure(target_scene, route_id, source, result)


func _ensure_outcome_overlay_layer() -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.ensure_overlay_layer()


func set_external_input_locked(locked: bool, reason: String = "") -> void:
	_ensure_model().set_external_lock_reason(reason)
	if locked:
		if _drag_active():
			_abort_active_drag()
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	else:
		_set_input_phase(InputPhase.PLAYER_INPUT)
	_sync_model_state()


func _set_input_phase(phase: InputPhase) -> void:
	_ensure_model().set_input_phase(int(phase))
	var current_phase: InputPhase = _input_phase_value()
	if current_phase != InputPhase.PLAYER_INPUT:
		_clear_combat_mastery_hover_state()

	match current_phase:
		InputPhase.PLAYER_INPUT:
			if _board_controller != null:
				_board_controller.set_input_enabled(true)
		InputPhase.RESOLVING:
			if _board_controller != null:
				_board_controller.set_input_enabled(false)
		InputPhase.LOCKED_EXTERNAL:
			if _board_controller != null:
				_board_controller.set_input_enabled(false)
			if _ensure_model().external_lock_reason() != "":
				_set_status_text("Input locked: %s" % _ensure_model().external_lock_reason())
	_sync_model_state()


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
		COMBAT_SPEED_SLOW:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(0.35)
		COMBAT_SPEED_FAST:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(1.0)
		COMBAT_SPEED_INSTANT:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(2.0)
		_:
			_combat_vfx_presenter.set_post_match_vfx_speed_scale(0.55)


func _timer_ready_seconds() -> float:
	if _combat_timer_service == null:
		return COMBAT_TIMER_SERVICE_SCRIPT.MOVE_TIMER_MAX_SECONDS
	return _combat_timer_service.ready_seconds(_player_state)


func _abort_active_drag() -> void:
	if _board_controller != null:
		_board_controller.abort()
	if _view != null:
		_view.sync_timer_display(0.0, COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_LOCKED)


func _play_resolve_animations(
	result: Dictionary,
	visual_board_model: BoardModel = null,
	resolve_trace_origin_usec: int = 0
) -> void:
	if result.total_combos <= 0 or _resolve_presenter == null:
		return
	await _resolve_presenter.play_resolve_animations(
		result,
		visual_board_model,
		resolve_trace_origin_usec,
		{
			"trace_callback": _resolve_trace,
			"combo_preview_callback": _on_resolve_presenter_combo_preview,
			"combo_feedback_callback": _on_resolve_presenter_combo_feedback,
			"set_pass_index_callback": _on_resolve_presenter_pass_index,
		}
	)


func _trigger_match_mastery_feedback(group: Dictionary, combo_value: int) -> void:
	_show_match_mastery_feedback(group, combo_value)


func _on_resolve_presenter_combo_preview(group: Dictionary, combo_value: int) -> int:
	return _preview_match_feedback_value(group, combo_value)


func _on_resolve_presenter_combo_feedback(group: Dictionary, combo_value: int) -> void:
	_trigger_match_mastery_feedback(group, combo_value)


func _on_resolve_presenter_pass_index(pass_index: int) -> void:
	_model.set_resolve_trace_pass_index(pass_index)


func _on_presenter_combo_sound() -> void:
	_audio_play_sfx("combo")


func _combat_speed_duration(base_seconds: float) -> float:
	if _resolve_presenter != null:
		return _resolve_presenter.combat_speed_duration(base_seconds)
	return base_seconds


func _wait_combat_speed(base_seconds: float) -> void:
	if _resolve_presenter != null:
		await _resolve_presenter.wait_combat_speed(base_seconds)
		return
	var tree := _host.get_tree()
	if tree == null:
		return
	if base_seconds <= 0.01:
		await tree.process_frame
		return
	await tree.create_timer(base_seconds).timeout


func _show_match_mastery_feedback(group: Dictionary, combo_value: int) -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.show_match_feedback(group, combo_value)


func _reset_combat_mastery_preview() -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.reset(RunState.current_combat_modifiers())


func _sync_combat_mastery_preview_totals() -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.sync_totals()


func _release_combat_mastery_feedback(orb_id: int) -> void:
	_bind_mastery_preview_coordinator()
	_mastery_preview_coordinator.release_feedback(orb_id)


func _release_remaining_combat_mastery_feedback() -> void:
	_bind_mastery_preview_coordinator()
	await _mastery_preview_coordinator.release_remaining(
		Callable(self, "_wait_combat_speed"),
		Callable(self, "_can_continue_after_async_wait")
	)


func _preview_match_feedback_value(group: Dictionary, combo_value: int) -> int:
	_bind_mastery_preview_coordinator()
	return int(_mastery_preview_coordinator.preview_match_feedback_value(group, combo_value))


func _modifier_sources_for_key(key: String) -> Array[Dictionary]:
	_bind_mastery_preview_coordinator()
	return _mastery_preview_coordinator.modifier_sources_for_key(key)


func _build_run_outcome_summary(fallback_cause: String = "") -> String:
	var summary: Dictionary = RunState.run_summary_snapshot()
	return _turn_log_presenter.build_run_outcome_summary(summary, RunState.MAX_DUNGEON_LEVELS, fallback_cause)


func _replay_turn_resolution_from_log(turn_log: Dictionary) -> void:
	_bind_hud_stage_coordinator()
	var vfx_presenter: Variant = _combat_vfx_presenter
	var enemy_damage := int(turn_log.get("enemy_damage_taken", 0))
	var enemy_blocked := int(turn_log.get("enemy_blocked", 0))
	var fire_damage := int(turn_log.get("fire_damage", 0))
	var ice_damage := int(turn_log.get("ice_damage", 0))
	var earth_damage := int(turn_log.get("earth_damage", 0))
	var heart_heal := int(turn_log.get("healed", 0))
	var armor_gain := int(turn_log.get("armor_gained", 0))
	var gold_gain := int(turn_log.get("gold_gained", 0))
	var flat_damage_bonus := int(turn_log.get("flat_damage_bonus", 0))
	var prep_armor_added := int(turn_log.get("prep_armor_added", 0))
	var applied_flat_heal_bonus := maxi(0, heart_heal - int(turn_log.get("heart_base", 0)))
	var applied_flat_gold_bonus := maxi(0, gold_gain - int(turn_log.get("gold_base", 0)))
	var enemy_target: Vector2 = Vector2.ZERO
	var player_target: Vector2 = Vector2.ZERO
	var player_hp_target: Vector2 = Vector2.ZERO
	var player_hp_impact_size := Vector2(180, 76)
	if _view != null:
		enemy_target = _view.enemy_vfx_target_global(0.48)
		player_target = _view.player_vfx_target_global(0.64)
		player_hp_target = _view.player_hp_bar_vfx_target_global(0.50)
		var hp_bar_size: Vector2 = _view.player_hp_bar_vfx_size()
		if hp_bar_size.x > 0.0 and hp_bar_size.y > 0.0:
			player_hp_impact_size = Vector2(
				clampf(hp_bar_size.x * 0.58, 180.0, 420.0),
				clampf(hp_bar_size.y * 1.90, 76.0, 130.0)
			)
	if player_hp_target == Vector2.ZERO:
		player_hp_target = player_target
	var enemy_impact_size := Vector2(84, 84)
	var gold_impact_size := Vector2(70, 70)
	var damage_lifetime := _combat_speed_duration(0.42)
	var player_lifetime := _combat_speed_duration(0.45)
	var gold_lifetime := _combat_speed_duration(0.55)
	var label_lifetime := _combat_speed_duration(0.72)

	if heart_heal > 0:
		if applied_flat_heal_bonus > 0:
			await _apply_end_modifier_feedback(OrbType.Id.HEART, applied_flat_heal_bonus, _modifier_sources_for_key("flat_heal_bonus"))
			if not _can_continue_after_async_wait():
				return
		var staged_hp_before_heal: int = _model.staged_hud_value("player_hp", int(_player_state.current_hp))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(player_hp_target, "heart", player_hp_impact_size, player_lifetime, heart_heal)
			vfx_presenter.spawn_mastery_beam(OrbType.Id.HEART, player_hp_target, player_lifetime)
			vfx_presenter.spawn_result_label("+%d HP" % heart_heal, player_hp_target, "heal", label_lifetime, Vector2(0, -54), heart_heal)
		_play_mastery_effect_sfx("heal")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_hud_stage_coordinator.stage_player_hp(staged_hp_before_heal + heart_heal)
		_release_combat_mastery_feedback(OrbType.Id.HEART)

	if armor_gain > 0:
		var staged_armor_before_gain: int = _model.staged_hud_value("player_armor", int(_player_state.armor))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(player_hp_target, "armor", player_hp_impact_size, player_lifetime, armor_gain)
			vfx_presenter.spawn_armor_bar_linger(player_hp_target, player_hp_impact_size, player_lifetime, armor_gain)
			vfx_presenter.spawn_mastery_beam(OrbType.Id.ARMOR, player_hp_target, player_lifetime)
			vfx_presenter.spawn_result_label("+%d Armor" % armor_gain, player_hp_target, "armor", label_lifetime, Vector2(0, -54), armor_gain)
		_play_mastery_effect_sfx("armor")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_hud_stage_coordinator.stage_player_armor(staged_armor_before_gain + armor_gain)
		_release_combat_mastery_feedback(OrbType.Id.ARMOR)

	if gold_gain > 0:
		if applied_flat_gold_bonus > 0:
			await _apply_end_modifier_feedback(OrbType.Id.GOLD, applied_flat_gold_bonus, _modifier_sources_for_key("flat_gold_bonus"))
			if not _can_continue_after_async_wait():
				return
		var staged_gold_before_gain: int = _model.staged_hud_value("player_gold", int(_player_state.gold))
		if vfx_presenter != null:
			vfx_presenter.spawn_replay_impact(player_target, "gold", gold_impact_size, gold_lifetime, gold_gain)
			vfx_presenter.spawn_mastery_beam(OrbType.Id.GOLD, player_target, gold_lifetime)
			vfx_presenter.spawn_result_label("+%d Gold" % gold_gain, player_target, "gold", label_lifetime, Vector2(0, -46), gold_gain)
		_play_mastery_effect_sfx("gold")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_hud_stage_coordinator.stage_gold(staged_gold_before_gain + gold_gain)
		_release_combat_mastery_feedback(OrbType.Id.GOLD)

	if flat_damage_bonus > 0 and int(turn_log.get("total_elemental_damage_before_flat", 0)) > 0:
		var flat_damage_orb := _dominant_damage_orb_for_turn(turn_log)
		await _apply_end_modifier_feedback(flat_damage_orb, flat_damage_bonus, _modifier_sources_for_key("flat_damage_bonus"))
		if not _can_continue_after_async_wait():
			return

	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		if fire_damage > 0:
			var fire_replay_ok: bool = await _replay_elemental_damage_result(OrbType.Id.FIRE, fire_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime)
			if not fire_replay_ok:
				return
		if ice_damage > 0 and not _hud_stage_coordinator.staged_enemy_defeated():
			var ice_replay_ok: bool = await _replay_elemental_damage_result(OrbType.Id.ICE, ice_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime)
			if not ice_replay_ok:
				return
		if earth_damage > 0 and not _hud_stage_coordinator.staged_enemy_defeated():
			var earth_replay_ok: bool = await _replay_elemental_damage_result(OrbType.Id.EARTH, earth_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime)
			if not earth_replay_ok:
				return
	elif enemy_damage > 0:
		var impact_orb := _dominant_orb_for_matches(turn_log.get("matched_counts", {}))
		if impact_orb in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
			var dominant_replay_ok: bool = await _replay_elemental_damage_result(impact_orb, enemy_damage, enemy_target, enemy_impact_size, damage_lifetime, label_lifetime)
			if not dominant_replay_ok:
				return
			_hud_stage_coordinator.stage_enemy_result()
		else:
			if vfx_presenter != null:
				vfx_presenter.spawn_replay_impact(enemy_target, _mastery_impact_kind(impact_orb), enemy_impact_size, damage_lifetime, enemy_damage)
				vfx_presenter.spawn_mastery_beam(impact_orb, enemy_target, damage_lifetime)
				vfx_presenter.spawn_result_label("%d" % enemy_damage, enemy_target, _result_label_kind_for_orb(impact_orb), label_lifetime, Vector2(0, -52), enemy_damage)
			_play_mastery_effect_sfx("damage")
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_hud_stage_coordinator.stage_enemy_result()
			_release_combat_mastery_feedback(impact_orb)
	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		_hud_stage_coordinator.stage_enemy_result()
	if enemy_blocked > 0:
		if vfx_presenter != null:
			vfx_presenter.spawn_result_label("-%d Damage Blocked" % enemy_blocked, enemy_target, "block", label_lifetime, Vector2(0, 16))
		_hud_stage_coordinator.stage_enemy_result()
	await _release_remaining_combat_mastery_feedback()
	if not _can_continue_after_async_wait():
		return
	var enemy_attack_resolution: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if prep_armor_added > 0 and int(enemy_attack_resolution.get("incoming", 0)) > 0:
		await _apply_end_modifier_feedback(OrbType.Id.ARMOR, prep_armor_added, _modifier_sources_for_key("start_turn_armor"))
		if not _can_continue_after_async_wait():
			return
	await _replay_enemy_attack_result_labels(turn_log, player_target, label_lifetime)
	if not _can_continue_after_async_wait():
		return
	await _wait_combat_speed(TURN_REPLAY_FINAL_HOLD_SECONDS)
	if not _can_continue_after_async_wait():
		return
	_reset_combat_mastery_preview()


func _replay_elemental_damage_result(orb_id: int, damage_amount: int, enemy_target: Vector2, enemy_impact_size: Vector2, damage_lifetime: float, label_lifetime: float) -> bool:
	_bind_hud_stage_coordinator()
	var vfx_presenter: Variant = _combat_vfx_presenter
	if vfx_presenter != null:
		vfx_presenter.spawn_mastery_cast_sequence(
			orb_id,
			enemy_target,
			_combat_speed_duration(ELEMENTAL_CAST_SPOOL_SECONDS),
			_combat_speed_duration(ELEMENTAL_CAST_LAUNCH_SECONDS),
			damage_amount
		)
		await _wait_combat_speed(ELEMENTAL_CAST_SPOOL_SECONDS)
		if not _can_continue_after_async_wait():
			return false
		await _wait_combat_speed(ELEMENTAL_CAST_LAUNCH_SECONDS)
		if not _can_continue_after_async_wait():
			return false
	if vfx_presenter != null:
		var impact_kind := _mastery_impact_kind(orb_id)
		var resolved_impact_size := _enemy_result_impact_size(orb_id, enemy_impact_size, damage_amount, vfx_presenter)
		vfx_presenter.spawn_replay_impact(enemy_target, impact_kind, resolved_impact_size, damage_lifetime, damage_amount)
		vfx_presenter.spawn_result_label("%d" % damage_amount, enemy_target, _result_label_kind_for_orb(orb_id), label_lifetime, Vector2(0, -52), damage_amount)
	_play_mastery_effect_sfx("damage")
	await _wait_combat_speed(ELEMENTAL_CAST_IMPACT_HOLD_SECONDS)
	if not _can_continue_after_async_wait():
		return false
	_hud_stage_coordinator.stage_enemy_damage_step(damage_amount)
	_release_combat_mastery_feedback(orb_id)
	return true


func _enemy_result_impact_size(orb_id: int, fallback_size: Vector2, amount: int, vfx_presenter: Variant) -> Vector2:
	if orb_id != OrbType.Id.FIRE or _view == null or not _view.has_method("enemy_vfx_size"):
		return fallback_size
	if vfx_presenter == null or not vfx_presenter.has_method("replay_result_is_screen_wide"):
		return fallback_size
	if not bool(vfx_presenter.replay_result_is_screen_wide("fire", amount)):
		return fallback_size
	var enemy_size: Vector2 = _view.enemy_vfx_size()
	if enemy_size.x <= 1.0 or enemy_size.y <= 1.0:
		return fallback_size
	var scale := 1.0
	if vfx_presenter != null and vfx_presenter.has_method("result_vfx_size_scale"):
		scale = maxf(1.0, float(vfx_presenter.result_vfx_size_scale("fire", amount)))
	return Vector2(
		maxf(fallback_size.x, enemy_size.x / scale),
		maxf(fallback_size.y, enemy_size.y / scale)
	)


func _apply_end_modifier_feedback(orb_id: int, amount: int, sources: Array[Dictionary]) -> void:
	_bind_mastery_preview_coordinator()
	await _mastery_preview_coordinator.apply_end_modifier_feedback(
		orb_id,
		amount,
		sources,
		Callable(self, "_wait_combat_speed")
	)


func _can_continue_after_async_wait(require_board_view: bool = false) -> bool:
	if not (_host != null and is_instance_valid(_host) and _host.is_inside_tree()):
		return false
	if _host.get_tree() == null:
		return false
	if require_board_view and (_board_view == null or not is_instance_valid(_board_view)):
		return false
	return true


func _update_hud() -> void:
	if _player_state == null or _enemy_state == null or _combat == null:
		return

	_ensure_hud_presenter()
	var hud_snapshot: Dictionary = _hud_presenter.build_hud_snapshot(_hud_snapshot_input_data())
	if _view != null:
		_view.apply_hud_snapshot(
			hud_snapshot,
			{"refresh_build_icon_rows": Callable(self, "_refresh_build_icon_rows")}
		)


func _ensure_hud_presenter() -> void:
	if _hud_presenter == null:
		_hud_presenter = COMBAT_HUD_PRESENTER_SCRIPT.new()


func _bind_hud_stage_coordinator() -> void:
	if _hud_stage_coordinator == null:
		_hud_stage_coordinator = COMBAT_HUD_STAGE_COORDINATOR_SCRIPT.new()
	_hud_stage_coordinator.bind(_model, _player_state, _enemy_state, {
		COMBAT_HUD_STAGE_COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: Callable(self, "_update_hud"),
	})


func _bind_mastery_preview_coordinator() -> void:
	if _mastery_preview_coordinator == null:
		_mastery_preview_coordinator = COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT.new()
	_mastery_preview_coordinator.bind(_model, _player_state, _view, {
		"resolution_order": COMBAT_MASTERY_RESOLUTION_ORDER,
		"feedback_stagger_seconds": COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS,
	})


func _bind_loadout_command_handler() -> void:
	if _loadout_command_handler == null:
		_loadout_command_handler = COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.new()
	_loadout_command_handler.bind(
		{
			"run_state": RunState,
			"combat": _combat,
			"view": _view,
			"board_controller": _board_controller,
			"board_view": _board_view,
			"board_model": _board_model,
			"consumable_service": _combat_consumable_service,
			"consumable_rng": _consumable_rng,
		},
		{
			COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(self, "_set_status_text"),
			COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(self, "_append_combat_log"),
			COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(self, "_update_hud"),
			COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(self, "_input_phase_value"),
		},
		{"player_input_phase_value": int(InputPhase.PLAYER_INPUT)}
	)


func _bind_intent_hover_handler() -> void:
	if _intent_hover_handler == null:
		_intent_hover_handler = COMBAT_INTENT_HOVER_HANDLER_SCRIPT.new()
	_intent_hover_handler.bind(
		{
			"run_state": RunState,
			"combat": _combat,
			"enemy_state": _enemy_state,
			"model": _model,
			"view": _view,
		},
		{
			COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(self, "_input_phase_value"),
			COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(self, "_set_status_text"),
			COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(self, "_set_status_color"),
			COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_SET_TURN_SUMMARY_TEXT: Callable(self, "_set_turn_summary_text"),
			COMBAT_INTENT_HOVER_HANDLER_SCRIPT.CALLBACK_FORMAT_INTENT: Callable(self, "_debug_format_intent"),
		},
		{
			"player_input_phase_value": int(InputPhase.PLAYER_INPUT),
			"warning_color": STATUS_COLOR_WARNING,
		}
	)


func _bind_scene_transition_handler() -> void:
	if _scene_transition_handler == null:
		_scene_transition_handler = COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.new()
	_scene_transition_handler.bind(
		{
			"run_state": RunState,
			"scene_tree": _host.get_tree() if _host != null else null,
			"model": _model,
		},
		{
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_CURRENT_ROUTE_ID: Callable(self, "_flow_trace_route_id_value"),
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_LOCK_EXTERNAL_INPUT: Callable(self, "_lock_scene_transition_input"),
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SHOW_OUTCOME_SUMMARY: Callable(self, "_show_outcome_summary"),
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(self, "_set_status_text"),
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(self, "_set_status_color"),
			COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(self, "_append_combat_log"),
		},
		{
			"negative_color": STATUS_COLOR_NEGATIVE,
			"run_summary_scene": RunState.SCENE_RUN_SUMMARY,
		}
	)


func _bind_tutorial_prompt_presenter() -> void:
	if _tutorial_prompt_presenter == null:
		_tutorial_prompt_presenter = COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT.new()
	_tutorial_prompt_presenter.bind(_host)


func _hud_snapshot_input_data() -> Dictionary:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var intent := _enemy_state.get_current_intent()
	var timer_seconds := _drag_move_time_left() if _drag_active() else _timer_ready_seconds()
	var turn_summary_text: String = ""
	if _view != null:
		turn_summary_text = _view.turn_summary_text()
	var enemy_stage_texture: Texture2D = null
	var enemy_portrait_texture: Texture2D = null
	if _visuals != null:
		enemy_stage_texture = _visuals.combat_enemy_stage_texture(_enemy_state.enemy_id)
		enemy_portrait_texture = _visuals.enemy_sprite(_enemy_state.enemy_id)
	if enemy_portrait_texture == null and _visuals != null:
		enemy_portrait_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_portrait_texture == null:
		enemy_portrait_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	var player_gold: int = _model.staged_hud_value("player_gold", int(_player_state.gold))
	var enemy_hp: int = _model.staged_hud_value("enemy_hp", int(_enemy_state.current_hp))
	var enemy_turn_block: int = _model.staged_hud_value("enemy_turn_block", int(_enemy_state.current_turn_block))
	var player_hp: int = _model.staged_hud_value("player_hp", int(_player_state.current_hp))
	var player_armor: int = _model.staged_hud_value("player_armor", int(_player_state.armor))
	return {
		"progression_snapshot": progression_snapshot,
		"intent": intent,
		"show_intent_preview": _should_show_intent_damage_preview(),
		"dungeon_level": int(RunState.dungeon_level),
		"max_dungeon_levels": int(RunState.MAX_DUNGEON_LEVELS),
		"current_step_key": String(RunState.current_step_key),
		"player_gold": player_gold,
		"enemy_id": String(_enemy_state.enemy_id),
		"enemy_name_text": _enemy_state.display_name,
		"enemy_hp": enemy_hp,
		"enemy_max_hp": int(_enemy_state.max_hp),
		"enemy_turn_block": enemy_turn_block,
		"enemy_stage_texture": enemy_stage_texture,
		"enemy_portrait_texture": enemy_portrait_texture,
		"combat_turn_index": int(_combat.turn_index),
		"combat_phase_name": _combat.phase_name(),
		"is_player_input_phase": _input_phase_value() == InputPhase.PLAYER_INPUT,
		"drag_active": _drag_active(),
		"timer_seconds": timer_seconds,
		"player_hp": player_hp,
		"player_max_hp": int(_player_state.max_hp),
		"player_armor": player_armor,
		"fire_orb_value": int(_player_state.orb_value(OrbType.Id.FIRE)),
		"armor_orb_value": int(_player_state.orb_value(OrbType.Id.ARMOR)),
		"heart_orb_id": int(OrbType.Id.HEART),
		"gold_orb_id": int(OrbType.Id.GOLD),
		"turn_summary_text": turn_summary_text,
		"format_intent_compact": Callable(_turn_log_presenter, "format_intent_compact") if _turn_log_presenter != null else Callable(),
	}


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
	var context := {
		"player_end": {
			"hp": int(_player_state.current_hp if _player_state != null else 0),
			"max_hp": int(_player_state.max_hp if _player_state != null else 0),
			"armor": int(_player_state.armor if _player_state != null else 0),
			"gold": int(_player_state.gold if _player_state != null else 0),
		},
		"enemy_end": {
			"hp": int(_enemy_state.current_hp if _enemy_state != null else 0),
			"max_hp": int(_enemy_state.max_hp if _enemy_state != null else 0),
		},
		"orb_values_by_id": _orb_values_by_id(),
	}
	var log_level := LOG_LEVEL_NORMAL
	if _debug_runtime != null:
		log_level = _debug_runtime.log_level()
	var lines: Array[String] = _turn_log_presenter.build_turn_log_lines(turn_log, log_level, context)
	for line in lines:
		_append_combat_log(line)


func _resolve_trace_enabled() -> bool:
	return true


func _resolve_trace(start_ticks_usec: int, message: String) -> void:
	if not _resolve_trace_enabled():
		return
	if start_ticks_usec <= 0:
		return
	var elapsed_ms := maxi(0, int(float(Time.get_ticks_usec() - start_ticks_usec) / 1000.0))
	print("[ResolveTrace +%04dms] %s" % [elapsed_ms, message])


func _orb_values_by_id() -> Dictionary:
	var values := {}
	if _player_state == null:
		return values
	for orb_id in OrbType.ALL_TYPES:
		values[int(orb_id)] = _player_state.orb_value(int(orb_id))
	return values


func _append_combat_log(message: String, is_command_output: bool = false) -> void:
	if _debug_runtime != null:
		_debug_runtime.append_log(message, is_command_output)


func debug_console_log(message: String) -> void:
	_append_combat_log(message)


func _refresh_build_icon_rows(progression_snapshot: Dictionary) -> void:
	var player_display_values := {}
	var visible_player_hp := int(_player_state.current_hp)
	var visible_player_armor := int(_player_state.armor)
	if _model.is_hud_staging_active():
		visible_player_hp = _model.staged_hud_value("player_hp", visible_player_hp)
		visible_player_armor = _model.staged_hud_value("player_armor", visible_player_armor)
	player_display_values["current_hp"] = visible_player_hp
	player_display_values["current_armor"] = visible_player_armor
	var intent_preview: Dictionary = {}
	if _should_show_intent_damage_preview():
		_ensure_hud_presenter()
		intent_preview = _hud_presenter.build_intent_damage_preview(
			_enemy_state.get_current_intent(),
			visible_player_hp,
			visible_player_armor
		)
	var loadout_payload := {
		"player_state": _player_state,
		"progression": progression_snapshot,
		"hero_portrait": _visuals.hero_portrait(),
		"max_visible_relics": 2,
		"selectable_equipment": true,
		"selectable_consumables": true,
		"display_values": player_display_values,
		"intent_damage_preview": intent_preview,
		"combat_mastery_feedback_totals": _model.combat_mastery_preview_totals_snapshot(),
		"combat_mastery_hover_payload": _build_combat_mastery_hover_payload(progression_snapshot),
	}
	if _view != null:
		_view.render_player_loadout(loadout_payload, true)


func _replay_enemy_attack_result_labels(turn_log: Dictionary, player_target: Vector2, label_lifetime: float) -> void:
	_bind_hud_stage_coordinator()
	var vfx_presenter: Variant = _combat_vfx_presenter
	if bool(turn_log.get("enemy_intent_skipped", false)):
		return
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	var blocked_by_armor := int(enemy_attack.get("blocked_by_armor", 0))
	var hp_damage := int(enemy_attack.get("hp_damage", 0))
	if blocked_by_armor <= 0 and hp_damage <= 0:
		return
	var enemy_source: Vector2 = Vector2.ZERO
	var player_impact_target: Vector2 = Vector2.ZERO
	if _view != null:
		enemy_source = _view.enemy_vfx_target_global(0.56)
		player_impact_target = _view.player_vfx_target_global(0.58)
	if player_impact_target == Vector2.ZERO:
		player_impact_target = player_target
	var cue_lifetime := _combat_speed_duration(0.24)
	var travel_lifetime := _combat_speed_duration(0.28)
	var impact_lifetime := _combat_speed_duration(0.34)
	if vfx_presenter != null:
		vfx_presenter.spawn_enemy_attack_cue(enemy_source, cue_lifetime)
		vfx_presenter.spawn_enemy_attack_travel(enemy_source, player_impact_target, travel_lifetime)
	if blocked_by_armor > 0:
		if vfx_presenter != null:
			vfx_presenter.spawn_enemy_attack_block_impact(player_impact_target, impact_lifetime, blocked_by_armor)
		var block_text := "-%d Damage Blocked" % blocked_by_armor
		if vfx_presenter != null:
			vfx_presenter.spawn_result_label(block_text, player_target, "block", label_lifetime, Vector2(0, 18))
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_hud_stage_coordinator.stage_player_block_step(blocked_by_armor)
		if hp_damage <= 0:
			_hud_stage_coordinator.stage_player_final()
			return
	if hp_damage > 0:
		if vfx_presenter != null:
			vfx_presenter.spawn_enemy_attack_hit_impact(player_impact_target, impact_lifetime, hp_damage)
			vfx_presenter.spawn_result_label("-%d HP" % hp_damage, player_target, "damage", label_lifetime, Vector2(0, -54))
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
	_hud_stage_coordinator.stage_player_final()


func _spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func _mastery_impact_kind(orb_id: int) -> String:
	if _combat_vfx_presenter != null:
		return String(_combat_vfx_presenter.mastery_impact_kind(orb_id))
	match orb_id:
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.GOLD:
			return "gold"
		_:
			return "fire"


func _result_label_kind_for_orb(orb_id: int) -> String:
	match orb_id:
		OrbType.Id.ICE:
			return "ice"
		OrbType.Id.EARTH:
			return "earth"
		_:
			return "fire"


func _dominant_orb_for_matches(matched_counts: Dictionary) -> int:
	var selected_orb: int = OrbType.Id.FIRE
	var selected_count: int = -1
	for orb_id in COMBAT_MASTERY_RESOLUTION_ORDER:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count > selected_count:
			selected_count = count
			selected_orb = int(orb_id)
	if selected_count <= 0:
		return OrbType.Id.FIRE
	return selected_orb


func _dominant_damage_orb_for_turn(turn_log: Dictionary) -> int:
	var selected_orb: int = OrbType.Id.FIRE
	var selected_amount: int = -1
	var damage_by_orb := {
		OrbType.Id.FIRE: int(turn_log.get("fire_damage", 0)),
		OrbType.Id.ICE: int(turn_log.get("ice_damage", 0)),
		OrbType.Id.EARTH: int(turn_log.get("earth_damage", 0)),
	}
	for raw_orb_id in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
		var orb_id := int(raw_orb_id)
		var amount := int(damage_by_orb.get(orb_id, 0))
		if amount > selected_amount:
			selected_amount = amount
			selected_orb = orb_id
	if selected_amount > 0:
		return selected_orb
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	selected_amount = -1
	for raw_orb_id in [OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH]:
		var orb_id := int(raw_orb_id)
		var amount := int(matched_counts.get(orb_id, 0))
		if amount > selected_amount:
			selected_amount = amount
			selected_orb = orb_id
	return selected_orb


func _on_resolver_match_found(groups: Array) -> void:
	_audio_play_sfx("match")
	_set_status_text("Matches found: %d group(s)." % groups.size())
	_set_status_color(STATUS_COLOR_WARNING)


func _on_viewport_size_changed() -> void:
	_apply_combat_layout()


func _apply_combat_layout() -> void:
	if _view == null:
		return
	var layout_result: Dictionary = _view.apply_combat_layout(
		_host.get_viewport_rect().size,
		_combat_timer_service.layout_timer_seconds(_board_controller, _player_state) if _combat_timer_service != null else 0.0,
		_combat_timer_service.layout_timer_state(_board_controller) if _combat_timer_service != null else COMBAT_TIMER_SERVICE_SCRIPT.TIMER_STATE_READY
	)
	if not bool(layout_result.get("applied", false)):
		return
	if _tutorial_prompt_presenter != null and _tutorial_prompt_presenter.is_visible():
		_tutorial_prompt_presenter.layout()


func _refresh_character_portraits() -> void:
	if _view != null:
		_view.refresh_character_portraits(String(_enemy_state.enemy_id if _enemy_state != null else ""))


func _on_resolver_cells_cleared(cells: Array) -> void:
	if not _model.resolve_trace_active():
		return
	_resolve_trace(
		_model.resolve_trace_origin_usec(),
		"phase=clear_applied source=simulation_signal cells=%d" % cells.size()
	)


func _on_resolver_gravity_applied(fall_moves: Array) -> void:
	if not _model.resolve_trace_active():
		return
	_resolve_trace(
		_model.resolve_trace_origin_usec(),
		"phase=gravity_applied source=simulation_signal moves=%d" % fall_moves.size()
	)


func _on_resolver_refill_applied(refill_spawns: Array) -> void:
	if not _model.resolve_trace_active():
		return
	_resolve_trace(
		_model.resolve_trace_origin_usec(),
		"phase=refill_applied source=simulation_signal spawns=%d" % refill_spawns.size()
	)


func _on_resolver_cascade_step_complete(step_index: int, total_combos: int) -> void:
	if not _model.resolve_trace_active():
		return
	_resolve_trace(
		_model.resolve_trace_origin_usec(),
		"phase=pass_complete source=simulation_signal step_index=%d total_combos=%d" % [
			step_index,
			total_combos,
		]
	)


func _on_resolver_complete(result: Dictionary) -> void:
	if not _model.resolve_trace_active():
		return
	_resolve_trace(
		_model.resolve_trace_origin_usec(),
		"phase=simulation_resolve_complete source=signal total_combos=%d passes=%d" % [
			int(result.get("total_combos", 0)),
			Array(result.get("passes", [])).size(),
		]
	)
