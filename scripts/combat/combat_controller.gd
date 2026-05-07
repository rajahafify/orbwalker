extends RefCounted
class_name CombatController

var _board: Control
var _board_view: BoardView
var _background: TextureRect
var _background_scrim: TextureRect
var _status_label: Label
var _timer_label: Label
var _run_progress_label: Label
var _turn_summary_label: Label
var _player_label: Label
var _enemy_label: Label
var _enemy_step_label: Label
var _enemy_debug_label: Label
var _intent_label: Label
var _phase_label: Label
var _combat_log_text: RichTextLabel
var _console_input: LineEdit
var _next_button: Button
var _back_button: Button
var _debug_toggle_button: Button
var _settings_button: Button
var _board_view_control: Control
var _layout_root: Control
var _top_bar: PanelContainer
var _enemy_panel: PanelContainer
var _enemy_panel_root: Control
var _intent_row: HBoxContainer
var _enemy_stage: Control
var _enemy_hp_row: Control
var _enemy_name_label: Label
var _enemy_hp_text_label: Label
var _combat_strip: PanelContainer
var _timer_track: Control
var _timer_fill: ColorRect
var _timer_icon: TextureRect
var _timer_state_label: Label
var _timer_center_marker: TextureRect
var _board_frame: PanelContainer
var _board_panel: Control
var _board_shadow: Panel
var _outcome_summary_panel: Panel
var _outcome_summary_root: Control
var _outcome_text_column: Control
var _outcome_title_label: Label
var _outcome_body_label: Label
var _player_hud_section: Panel
var _player_panel: Panel
var _player_panel_root: Control
var _hero_card: Panel
var _hero_card_root: Control
var _hero_level_badge: PanelContainer
var _vitals_panel: Control
var _vitals_frame: Panel
var _player_hp_label: Label
var _player_armor_label: Label
var _armor_badge: PanelContainer
var _armor_badge_label: Label
var _stat_chip_row: HBoxContainer
var _attack_stat_label: Label
var _armor_stat_label: Label
var _heart_stat_label: Label
var _gold_stat_label: Label
var _combat_meta_row: HBoxContainer
var _loadout_frame: Panel
var _loadout_root: Control
var _mastery_strip: Panel
var _mastery_root: Control
var _combat_log_frame: PanelContainer
var _debug_overlay: PanelContainer
var _title_label: Label
var _hint_label: Label
var _enemy_portrait: TextureRect
var _intent_badge: TextureRect
var _primary_intent_text_column: VBoxContainer
var _primary_intent_title_label: Label
var _primary_intent_amount_label: Label
var _primary_intent_detail_label: Label
var _enemy_hp_bar: ProgressBar
var _player_hp_bar: ProgressBar
var _player_armor_bar: ProgressBar
var _player_portrait: TextureRect
var _equipment_icons: Control
var _consumable_icons: Control
var _relic_icons: HBoxContainer
var _mastery_icons: Control
var _elemental_mastery_cards: Control
var _elemental_mastery_panel: Panel
var _elemental_mastery_title: Label
var _relic_row: HBoxContainer
var _equipment_row_label: Label
var _consumable_row_label: Label
var _relic_row_label: Label
var _mastery_row_label: Label
var _vfx_layer: Control
var _divider_enemy_timer: TextureRect
var _divider_timer_board: TextureRect
var _divider_board_player: TextureRect
var _corner_top_left: TextureRect
var _corner_top_right: TextureRect
var _corner_bottom_left: TextureRect
var _corner_bottom_right: TextureRect

const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_service.gd")
const BOARD_RESOLVER_TEST_RUNNER_SCRIPT := preload("res://scripts/debug/board_resolver_test_runner.gd")
const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const COMBAT_OUTCOME_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_outcome_overlay.gd")
const COMBAT_RESOLVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_resolve_presenter.gd")
const COMBAT_DEBUG_CONSOLE_SCRIPT := preload("res://scripts/combat/combat_debug_console.gd")
const COMBAT_TURN_LOG_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_turn_log_presenter.gd")
const COMBAT_CHROME_STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const BOARD_CONTROLLER_SCRIPT := preload("res://scripts/board/board_controller.gd")
const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")
const COMBAT_HUD_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_hud_presenter.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")
const TEST_EQUIPMENT_IDS: Array[String] = [
	"shortsword",
	"buckler",
]
const TEST_CONSUMABLE_ID := "fire_scroll"

const COMBAT_PHASE_INTENT_PREVIEW := 0
const COMBAT_PHASE_VICTORY := 6
const COMBAT_PHASE_DEFEAT := 7
const MOVE_TIMER_MAX_SECONDS := 5.0
const TIMER_WARNING_SECONDS := 2.0
const TIMER_CRITICAL_SECONDS := 1.0
const TIMER_SAFE_COLOR := Color(0.60, 0.90, 1.0, 1.0)
const TIMER_WARNING_COLOR := Color(1.0, 0.82, 0.36, 1.0)
const TIMER_CRITICAL_COLOR := Color(1.0, 0.42, 0.38, 1.0)
const TIMER_READY_COLOR := Color(0.30, 0.56, 0.72, 1.0)
const TIMER_LOCKED_COLOR := Color(0.22, 0.24, 0.28, 1.0)
const TIMER_TEXT_COLOR := Color(0.96, 0.98, 1.0, 1.0)
const TIMER_TEXT_WARNING_COLOR := Color(1.0, 0.94, 0.68, 1.0)
const TIMER_TEXT_CRITICAL_COLOR := Color(1.0, 0.88, 0.84, 1.0)
const TIMER_TEXT_LOCKED_COLOR := Color(0.68, 0.72, 0.78, 1.0)
const TIMER_STATE_READY := "ready"
const TIMER_STATE_ACTIVE := "active"
const TIMER_STATE_LOCKED := "locked"
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
const OUTCOME_SUMMARY_RECT := Rect2(Vector2(224, 224), Vector2(600, 372))
const BOSS_REWARD_SUMMARY_RECT := Rect2(Vector2(80, 520), Vector2(920, 540))
const BOSS_REWARD_CARD_GAP := 12.0
const BOSS_REWARD_ROW_TOP := 176.0
const BOSS_REWARD_CARD_HEIGHT := 172.0
const BOSS_REWARD_ICON_SIZE := Vector2(54, 54)
const BOSS_REWARD_SKIP_BUTTON_SIZE := Vector2(190, 58)
const BOSS_REWARD_NEXT_BUTTON_SIZE := Vector2(280, 58)
const OUTCOME_MODAL_Z_INDEX := 180
const OUTCOME_SCRIM_Z_INDEX := 170
const OUTCOME_BOSS_SCRIM_COLOR := Color(0.0, 0.0, 0.0, 0.62)
const TIMER_TRACK_SIZE := Vector2(720, 36)
const TIMER_TRACK_PADDING := 5.0
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
var _debug_console: CombatDebugConsole = null
var _turn_log_presenter: Variant = null
var _zone_guides_enabled := false
var _resolve_presenter: Variant = null
var _combat_vfx_presenter: Variant = null
var _board_controller: Variant = null
var _hud_presenter: Variant = null
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
	if _view != null and _view.has_method("bind"):
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


func _player_hud_node(unique_name: String) -> Node:
	var hud_section: Node = _player_hud_section
	if hud_section == null:
		hud_section = _host.get_node_or_null("CombatLayoutRoot/PlayerHudSection")
	if hud_section == null:
		return null
	return hud_section.get_node_or_null("%s%s" % ["%", unique_name])


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
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	if _player_loadout_hud == null:
		_player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
	_player_loadout_hud.set_visual_registry(_visuals)
	if _outcome_overlay == null:
		_outcome_overlay = COMBAT_OUTCOME_OVERLAY_SCRIPT.new()
	if _turn_log_presenter == null:
		_turn_log_presenter = COMBAT_TURN_LOG_PRESENTER_SCRIPT.new()
	if _debug_console == null:
		_debug_console = COMBAT_DEBUG_CONSOLE_SCRIPT.new()
	if _combat_vfx_presenter == null:
		_combat_vfx_presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	if _board_controller == null:
		_board_controller = BOARD_CONTROLLER_SCRIPT.new()
	if _hud_presenter == null:
		_hud_presenter = COMBAT_HUD_PRESENTER_SCRIPT.new()
	_bind_outcome_overlay()
	if _resolve_presenter == null:
		_resolve_presenter = COMBAT_RESOLVE_PRESENTER_SCRIPT.new()
	_resolve_presenter.bind({
		"board": _board,
		"board_view": _board_view,
		"board_panel": _board_panel,
		"board_controller": _board_controller,
		"timer_owner": _host,
		"spawn_vfx_texture_callback": _spawn_vfx_texture,
		"combo_sound_callback": _on_presenter_combo_sound,
	})
	_resolve_presenter.set_combat_speed(_combat_speed_value())
	_debug_console.bind(
		{
			"combat_log_text": _combat_log_text,
			"console_input": _console_input,
		},
		{
			"command_output_log_color": COMMAND_OUTPUT_LOG_COLOR,
			"max_combat_log_lines": MAX_COMBAT_LOG_LINES,
			"initial_log_level": LOG_LEVEL_NORMAL,
			"turn_log_presenter": _turn_log_presenter,
			"callbacks": {
				"set_status_text": _console_set_status_text,
				"state_snapshot_data": _console_state_snapshot_data,
				"skip_to_fight": _console_skip_to_fight,
				"board_print_data": _console_board_print_data,
				"board_reroll": _console_board_reroll,
				"board_seed": _console_board_seed,
				"gold_add": _console_gold_add,
				"gold_set": _console_gold_set,
				"mastery_add": _console_mastery_add,
				"mastery_list": _console_mastery_list,
				"consumable_add": _console_consumable_add,
				"consumable_list": _console_consumable_list,
				"equipment_list": _console_equipment_list,
				"equipment_details": _console_equipment_details,
				"equipment_add": _console_equipment_add,
				"relic_list": _console_relic_list,
				"relic_details": _console_relic_details,
				"relic_add": _console_relic_add,
				"fight_win": _console_fight_win,
				"fight_lose": _console_fight_lose,
			},
		}
	)
	_consumable_rng.randomize()
	_background.texture = null
	_background.modulate = Color(0.16, 0.17, 0.20, 1.0)
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
	_player_loadout_hud.bind_player_hud(_combat_player_hud_nodes().merged({
		"popover_parent": _layout_root,
		"popover_z_index": 210,
	}, true))
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
	if _view != null:
		_view.enemy_intent_bubble_hovered.connect(_on_enemy_intent_bubble_hovered)
		_view.enemy_block_preview_hovered.connect(_on_enemy_block_preview_hovered)
		_view.intent_hover_ended.connect(_on_intent_damage_preview_hover_ended)
	_initialize_combat_state()
	RunState.flow_trace_mark("combat_after_initialize_state", {}, _flow_trace_route_id_value())
	_create_new_board()
	RunState.flow_trace_mark("combat_after_board_create", {}, _flow_trace_route_id_value())
	_debug_overlay.visible = false
	_debug_toggle_button.visible = false
	if _console_input.visible:
		_console_input.text_submitted.connect(_on_console_input_text_submitted)
	_debug_console.set_overlay_visible(false)
	_host.get_viewport().size_changed.connect(_on_viewport_size_changed)
	_vfx_layer.visible = true
	_host.set_process(true)
	_apply_combat_layout()
	RunState.flow_trace_mark("combat_after_layout", {}, _flow_trace_route_id_value())
	_begin_turn_preview()
	RunState.flow_trace_mark("combat_after_begin_turn_preview", {}, _flow_trace_route_id_value())
	call_deferred("_trace_flow_first_usable_frame")
	call_deferred("_apply_orb_texture_map_deferred")


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
	if _combat_vfx_presenter == null:
		return
	if _view != null and _view.has_method("vfx_presenter_bindings"):
		var view_bindings: Variant = _view.vfx_presenter_bindings(_visuals, _player_loadout_hud, _host)
		if view_bindings is Dictionary:
			_combat_vfx_presenter.bind(view_bindings)
			return
	_combat_vfx_presenter.bind({
		"vfx_layer": _vfx_layer,
		"visual_registry": _visuals,
		"player_loadout_hud": _player_loadout_hud,
		"elemental_mastery_cards": _elemental_mastery_cards,
		"timer_owner": _host,
	})


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
	if _player_state == null:
		return MOVE_TIMER_MAX_SECONDS
	return _player_state.move_timer_seconds


func _drag_active() -> bool:
	return _board_controller != null and bool(_board_controller.active_drag())


func _drag_move_time_left() -> float:
	if _board_controller == null:
		return 0.0
	return float(_board_controller.move_time_left())


func _apply_visual_chrome() -> void:
	if _view != null:
		_view.apply_visual_chrome(
			_combat_player_hud_nodes(),
			{
				"font_size_title": FONT_SIZE_TITLE,
				"font_size_value": FONT_SIZE_VALUE,
				"font_size_meta": FONT_SIZE_META,
				"font_size_row_label": FONT_SIZE_ROW_LABEL,
				"debug_text_font_size": DEBUG_TEXT_FONT_SIZE,
				"debug_input_font_size": DEBUG_INPUT_FONT_SIZE,
				"debug_input_height": DEBUG_INPUT_HEIGHT,
			}
		)
	_title_label.text = RunState.level_sequence_label()
	_hint_label.text = "Gold 0"


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
		_combat = null
		_model.clear_outcome_transition_queued()
		_model.clear_pending_next_scene_path()
		_hide_outcome_summary()
		_refresh_character_portraits()
		_refresh_build_icon_rows(_progression_state.to_snapshot())
		_show_boss_reward_summary("Boss defeated.")
		_status_label.text = "Boss defeated. Choose a boss relic or skip before continuing."
		_status_label.modulate = STATUS_COLOR_WARNING
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
	_refresh_character_portraits()
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_model.clear_outcome_transition_queued()
	_model.clear_pending_next_scene_path()
	_hide_outcome_summary()
	_update_hud()
	if _debug_console != null:
		_debug_console.clear_log()
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
	_turn_summary_label.text = "Turn Summary: Awaiting move."
	_status_label.text = "%s | Turn %d." % [
		RunState.level_sequence_label(),
		_combat.turn_index,
	]
	_status_label.modulate = STATUS_COLOR_NEUTRAL
	_update_hud()
	_clear_combat_mastery_hover_state()
	_append_combat_log(
		"Turn %d intent: %s." % [
			_combat.turn_index,
			_format_intent(_enemy_state.get_current_intent()),
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
		if _player_loadout_hud.handle_global_click((event as InputEventMouseButton).position):
			_host.get_viewport().set_input_as_handled()


func _on_debug_toggle_button_pressed() -> void:
	_toggle_debug_overlay()


func _toggle_debug_overlay() -> void:
	_debug_overlay.visible = not _debug_overlay.visible
	if _debug_console != null:
		_debug_console.set_overlay_visible(_debug_overlay.visible)
	_update_hud()


func _on_regenerate_button_pressed() -> void:
	_create_new_board()


func _on_print_board_button_pressed() -> void:
	_print_board_model()


func _on_back_button_pressed() -> void:
	_host.get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_settings_button_pressed() -> void:
	_host.get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_run_tests_button_pressed() -> void:
	var runner: Variant = BOARD_RESOLVER_TEST_RUNNER_SCRIPT.new()
	var report: Dictionary = runner.run_all()
	if report.passed:
		_status_label.text = "Resolver tests passed (%d/%d)." % [report.total, report.total]
		print("[Board Resolver Tests] Passed %d/%d." % [report.total, report.total])
		return

	_status_label.text = "Resolver tests failed (%d/%d). See output." % [report.failed, report.total]
	push_warning("Board resolver tests failed:\n%s" % "\n".join(report.failures))


func _on_add_test_equipment_button_pressed() -> void:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var candidate_item_id := ""
	for item_id in TEST_EQUIPMENT_IDS:
		if not progression_state.equipped_item_ids.has(item_id):
			candidate_item_id = item_id
			break
	if candidate_item_id == "":
		candidate_item_id = TEST_EQUIPMENT_IDS[0]

	var result: Dictionary = progression_service.equip_item(progression_state, candidate_item_id, content)
	if bool(result.get("ok", false)):
		_status_label.text = "Added test equipment: %s" % candidate_item_id
		_append_combat_log("Debug add equipment OK: %s" % candidate_item_id)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_status_label.text = "Add test equipment failed: %s" % reason
		_append_combat_log("Debug add equipment failed: %s" % reason)
	_update_hud()


func _on_add_test_consumable_button_pressed() -> void:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var result: Dictionary = progression_service.add_consumable(progression_state, TEST_CONSUMABLE_ID, content)
	if bool(result.get("ok", false)):
		_status_label.text = "Added test consumable: %s" % TEST_CONSUMABLE_ID
		_append_combat_log("Debug add consumable OK: %s" % TEST_CONSUMABLE_ID)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_status_label.text = "Add test consumable failed: %s" % reason
		_append_combat_log("Debug add consumable failed: %s" % reason)
	_update_hud()


func _try_use_first_consumable() -> void:
	_try_use_consumable_slot(0)


func _try_use_consumable_slot(slot_index: int) -> void:
	if _combat == null or _combat.is_fight_over():
		return
	if _input_phase_value() != InputPhase.PLAYER_INPUT:
		_status_label.text = "Consumables can only be used during player input."
		return

	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var use_result: Dictionary = progression_service.use_consumable(progression_state, slot_index, content)
	if not bool(use_result.get("ok", false)):
		var reason := String(use_result.get("reason", "unknown_error"))
		_status_label.text = "Use consumable failed: %s" % reason
		_append_combat_log("Use consumable failed: %s" % reason)
		_update_hud()
		return

	var payload: Dictionary = use_result.get("result", {})
	var consumable_id := String(payload.get("consumable_id", ""))
	var effects: Array = payload.get("effects", [])
	var conversion_total := _apply_consumable_effects(effects)
	if _board_controller != null:
		_board_controller.bind_view_model()
	else:
		_board_view.set_board_presentation_model(_board_model)
	if _board_controller != null:
		_board_controller.refresh_match_glow()
	_status_label.text = "Used %s from slot %d. Converted %d orbs." % [consumable_id, slot_index + 1, conversion_total]
	_append_combat_log("Consumable used: %s from slot %d. Converted %d orbs." % [consumable_id, slot_index + 1, conversion_total])
	_update_hud()


func _on_player_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var slots: Array = progression_snapshot.get("equipment_slots", []) if slot_type == "equipment" else progression_snapshot.get("consumable_slots", [])
	if slot_index < 0 or slot_index >= slots.size() or String(slots[slot_index]) == "":
		_status_label.text = "Sell failed: select an occupied equipment or consumable slot first."
		_append_combat_log("Sell failed: no occupied loadout slot selected.")
		return
	var item_id := String(slots[slot_index])
	var item_content: Dictionary = {}
	if _player_loadout_hud != null:
		item_content = _player_loadout_hud.lookup_content_definition(item_id)
	var result: Dictionary = RunState.sell_equipped_item(slot_index) if slot_type == "equipment" else RunState.sell_consumable_item(slot_index)
	var display_name := String(item_content.get("display_name", item_id))
	if bool(result.get("ok", false)):
		_status_label.text = "Sold %s for gold. Gold %d." % [display_name, RunState.run_gold]
		_append_combat_log("Sold %s from %s slot %d. Gold %d." % [display_name, slot_type, slot_index + 1, RunState.run_gold])
		_player_loadout_hud.hide_slot_detail_popover()
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_status_label.text = "Sell failed: %s" % reason
		_append_combat_log("Sell %s failed: %s" % [display_name, reason])
	_update_hud()


func _apply_consumable_effects(effects: Array) -> int:
	var total_converted := 0
	for raw_effect in effects:
		var effect: Dictionary = raw_effect
		var operation := String(effect.get("operation", ""))
		if operation != "convert_random_orbs":
			continue
		var value: Dictionary = effect.get("value", {})
		var target_orb_id := int(value.get("target_orb_id", -1))
		var count := int(value.get("count", 0))
		if _board_controller != null:
			total_converted += _board_controller.convert_random_non_target_orbs(target_orb_id, count, _consumable_rng)
	return total_converted


func _process(delta: float) -> void:
	if _player_state == null:
		return
	if _board_controller == null:
		return
	if not _drag_active():
		if _input_phase_value() == InputPhase.PLAYER_INPUT:
			_sync_timer_display(_timer_ready_seconds(), TIMER_STATE_READY)
		else:
			_sync_timer_display(0.0, TIMER_STATE_LOCKED)
		return

	var drag_update: Dictionary = _board_controller.update(
		delta,
		_input_phase_value() == InputPhase.PLAYER_INPUT
	)
	_sync_timer_display(_drag_move_time_left(), TIMER_STATE_ACTIVE)
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
	if _player_loadout_hud == null:
		return
	if _model.hovered_board_orb_id() < 0:
		_player_loadout_hud.clear_hovered_combat_mastery(_elemental_mastery_cards)
		return
	_player_loadout_hud.set_hovered_combat_mastery(_elemental_mastery_cards, _model.hovered_board_orb_id())


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
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.clear_combat_mastery_hover_ui(_elemental_mastery_cards)


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
		var selected_orb_id := int(result.get("selected_orb_id", -1))
		_sync_timer_display(_drag_move_time_left(), TIMER_STATE_ACTIVE)
		_status_label.text = "Dragging %s orb. Move timer running." % OrbType.display_name(selected_orb_id)
		_status_label.modulate = STATUS_COLOR_NEUTRAL
		return
	if action == "end":
		_end_drag(bool(result.get("timed_out", false)))


func _create_new_board() -> void:
	var board_seed := _resolve_seed()
	_set_board_seed(board_seed)
	if _combat != null and not _combat.is_fight_over():
		_status_label.text = "Seed: %d | Turn %d ready." % [board_seed, _combat.turn_index]
	else:
		_status_label.text = "Seed: %d | Fight complete." % board_seed


func _resolve_seed() -> int:
	return int(Time.get_ticks_usec())


func _print_board_model() -> void:
	var debug_text: String = _board_controller.board_debug_string() if _board_controller != null else _board_model.to_debug_string()
	var board_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	print("\n[Board Debug] Seed=", board_seed)
	print(debug_text)
	_print_board_model_to_console()
	_status_label.text = "Printed board for seed %d to output." % board_seed


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
	if _debug_console != null:
		_debug_console.handle_submitted_text(text)


func _console_set_status_text(message: String) -> void:
	_status_label.text = message


func _console_state_snapshot_data() -> Dictionary:
	var progression: Dictionary = RunState.progression_snapshot()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	var intent_text := "-"
	if _enemy_state != null:
		intent_text = _turn_log_presenter.format_intent(_enemy_state.get_current_intent())
	return {
		"run": {
			"active": RunState.run_active,
			"level": int(RunState.dungeon_level),
			"step": String(RunState.current_step_key),
			"label": RunState.level_sequence_label(),
		},
		"combat": {
			"turn": int(_combat.turn_index if _combat != null else 0),
			"phase": (_combat.phase_name() if _combat != null else "N/A"),
			"input_phase": _input_phase_value(),
		},
		"player": {
			"hp": int(_player_state.current_hp if _player_state != null else 0),
			"max_hp": int(_player_state.max_hp if _player_state != null else 0),
			"armor": int(_player_state.armor if _player_state != null else 0),
			"gold": int(RunState.run_gold),
		},
		"enemy": {
			"display_name": String(encounter.get("display_name", _enemy_state.display_name if _enemy_state != null else "Unknown")),
			"hp": int(_enemy_state.current_hp if _enemy_state != null else 0),
			"max_hp": int(_enemy_state.max_hp if _enemy_state != null else 0),
			"turn_block": int(_enemy_state.current_turn_block if _enemy_state != null else 0),
			"intent": intent_text,
		},
		"progression": {
			"equipment_slots": progression.get("equipment_slots", []),
			"consumable_slots": progression.get("consumable_slots", []),
			"relic_ids": progression.get("relic_ids", []),
			"mastery_levels": progression.get("mastery_levels", {}),
		},
	}


func _console_skip_to_fight(level: int, fight: int) -> Dictionary:
	var result: Dictionary = RunState.skip_to_fight(level, fight)
	if not bool(result.get("ok", false)):
		return result
	if _board_controller != null:
		_board_controller.abort()
	_last_resolve_result.clear()
	_initialize_combat_state()
	_create_new_board()
	_begin_turn_preview()
	var label := RunState.level_sequence_label()
	_status_label.text = "Skipped to %s." % label
	return {
		"ok": true,
		"label": label,
	}


func _console_board_print_data() -> Dictionary:
	var board_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	var board_debug_text: String = _board_controller.board_debug_string() if _board_controller != null else _board_model.to_debug_string()
	return {
		"seed": board_seed,
		"debug_text": board_debug_text,
	}


func _console_board_reroll() -> Dictionary:
	_create_new_board()
	var board_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	return {
		"seed": board_seed,
	}


func _console_board_seed(board_seed: int) -> Dictionary:
	_set_board_seed(board_seed)
	var current_seed: int = _board_controller.board_seed() if _board_controller != null else _board_model.rng_seed
	return {
		"ok": true,
		"seed": current_seed,
	}


func _console_gold_add(amount: int) -> Dictionary:
	var added := RunState.add_gold(amount)
	_update_hud()
	return {
		"ok": true,
		"added": added,
		"current": RunState.run_gold,
	}


func _console_gold_set(amount: int) -> Dictionary:
	RunState.set_gold(amount)
	_update_hud()
	return {
		"ok": true,
		"current": RunState.run_gold,
	}


func _console_mastery_add(orb_id: int, mastery_amount: int) -> Dictionary:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var mastery_result: Dictionary = progression_service.grant_mastery(progression_state, orb_id, mastery_amount)
	if not bool(mastery_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(mastery_result.get("reason", "unknown_error")),
		}
	var mastery_payload: Dictionary = mastery_result.get("result", {})
	_update_hud()
	return {
		"ok": true,
		"granted": int(mastery_payload.get("granted", 0)),
		"new_level": int(mastery_payload.get("new_level", 0)),
	}


func _console_mastery_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_mastery_cards()


func _console_consumable_add(consumable_id: String) -> Dictionary:
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var consumable_result: Dictionary = progression_service.add_consumable(progression_state, consumable_id, content)
	if not bool(consumable_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(consumable_result.get("reason", "unknown_error")),
		}
	_update_hud()
	return {"ok": true}


func _console_consumable_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_consumables()


func _console_equipment_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_equipment()


func _console_equipment_details(equipment_id: String) -> Dictionary:
	if equipment_id == "":
		return {"ok": false, "reason": "equipment id is required"}
	var content: Variant = RunState.ensure_content_registry()
	var equipment: Dictionary = content.get_equipment(equipment_id)
	if equipment.is_empty():
		return {"ok": false, "reason": "unknown equipment id '%s'" % equipment_id}
	return {
		"ok": true,
		"equipment": equipment,
	}


func _console_equipment_add(equipment_id: String) -> Dictionary:
	if equipment_id == "":
		return {"ok": false, "reason": "equipment id is required"}
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var equip_result: Dictionary = progression_service.equip_item(progression_state, equipment_id, content)
	if not bool(equip_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(equip_result.get("reason", "unknown_error")),
		}
	var payload: Dictionary = equip_result.get("result", {})
	_update_hud()
	return {
		"ok": true,
		"slot_index": int(payload.get("slot_index", -1)),
	}


func _console_relic_list() -> Array:
	var content: Variant = RunState.ensure_content_registry()
	return content.list_relics()


func _console_relic_details(relic_id: String) -> Dictionary:
	if relic_id == "":
		return {"ok": false, "reason": "relic id is required"}
	var content: Variant = RunState.ensure_content_registry()
	var relic: Dictionary = content.get_relic(relic_id)
	if relic.is_empty():
		return {"ok": false, "reason": "unknown relic id '%s'" % relic_id}
	return {
		"ok": true,
		"relic": relic,
	}


func _console_relic_add(relic_id: String) -> Dictionary:
	if relic_id == "":
		return {"ok": false, "reason": "relic id is required"}
	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var relic_result: Dictionary = progression_service.add_relic(progression_state, relic_id, content)
	if not bool(relic_result.get("ok", false)):
		return {
			"ok": false,
			"reason": String(relic_result.get("reason", "unknown_error")),
		}
	_update_hud()
	return {"ok": true}


func _console_fight_win() -> Dictionary:
	var win_transition: Dictionary = RunState.mark_fight_victory()
	if not bool(win_transition.get("ok", false)):
		return {
			"ok": false,
			"reason": String(win_transition.get("reason", "unknown_error")),
		}
	_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	_model.set_pending_next_scene_path(String(win_transition.get("next_scene", "res://scenes/main_menu.tscn")))
	_update_hud()
	_show_outcome_summary("Victory", _build_run_outcome_summary("Debug command."), true)
	_status_label.text = "Debug victory queued. Press Continue."
	return {"ok": true}


func _console_fight_lose() -> Dictionary:
	var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
	_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	_model.set_pending_next_scene_path(String(lose_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY)))
	_update_hud()
	_show_outcome_summary("Defeat", _build_run_outcome_summary("Debug command."), true, "Run Summary")
	_status_label.text = "Debug defeat queued. Run Summary available."
	return {"ok": true}


func _end_drag(timed_out: bool) -> void:
	if _board_controller == null:
		return

	_sync_timer_display(0.0, TIMER_STATE_LOCKED)
	var move_end_reason := "released"
	if timed_out:
		move_end_reason = "timer expired"
	_status_label.text = "Move ended: %s. Locking input for resolve phase." % move_end_reason
	_status_label.modulate = STATUS_COLOR_WARNING
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
	_model.begin_hud_staging(_capture_hud_stage_values())
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
			_status_label.text = "Boss defeated. Choose a boss relic or skip before continuing."
			_append_combat_log("Outcome: Boss victory. Waiting for boss relic selection in victory overlay.")
			_show_boss_reward_summary(_turn_log_presenter.build_victory_gold_summary(turn_log, transition))
			_turn_summary_label.text = "Turn Summary: Boss victory. Choose a relic."
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
			_status_label.text = _turn_log_presenter.build_victory_status(turn_log, transition) + " Press Continue."
			_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
			_model.set_pending_next_scene_path(next_scene)
			_show_outcome_summary("Victory", _turn_log_presenter.build_victory_gold_summary(turn_log, transition), true)
			_turn_summary_label.text = "Turn Summary: Victory. Press Continue."
			RunState.flow_trace_mark(
				"combat_continue_available",
				{"button_text": "Continue"},
				_flow_trace_route_id_value(),
				next_scene
			)
		_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		_audio_play_sfx("defeat")
		var defeat_cause: String = _turn_log_presenter.build_defeat_cause(String(_enemy_state.display_name if _enemy_state != null else "Enemy"), turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _turn_log_presenter.build_defeat_status(turn_log) + " Run Summary available."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Waiting for Run Summary button.")
		_model.set_pending_next_scene_path(String(defeat_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY)))
		_show_outcome_summary("Defeat", _build_run_outcome_summary(defeat_cause), true, "Run Summary")
		_turn_summary_label.text = "Turn Summary: Defeat. Run Summary available."
		RunState.flow_trace_mark(
			"combat_continue_available",
			{"button_text": "Run Summary"},
			_flow_trace_route_id_value(),
			_model.pending_next_scene_path()
		)
		_pulse_label(_turn_summary_label, STATUS_COLOR_NEGATIVE)
		return

	_status_label.text = _turn_log_presenter.build_turn_summary_status(turn_log)
	_play_turn_result_sfx(turn_log)
	_status_label.modulate = STATUS_COLOR_POSITIVE
	_turn_summary_label.text = "Turn Summary: %s" % _turn_log_presenter.build_turn_summary_status(turn_log)
	_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
	_append_turn_log(turn_log)
	_begin_turn_preview()


func _on_next_button_pressed() -> void:
	if _outcome_overlay != null and _outcome_overlay.is_boss_reward_pending():
		_audio_play_sfx("error")
		_status_label.text = "Choose a boss relic or skip the reward before continuing."
		return
	if _model.pending_next_scene_path() == "":
		return
	RunState.flow_trace_mark(
		"combat_next_button_pressed",
		{"button_text": _next_button.text},
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
	if _outcome_overlay == null:
		return
	_outcome_overlay.bind(
		{
			"layout_root": _layout_root,
			"summary_panel": _outcome_summary_panel,
			"summary_root": _outcome_summary_root,
			"text_column": _outcome_text_column,
			"title_label": _outcome_title_label,
			"body_label": _outcome_body_label,
			"next_button": _next_button,
		},
		{
			"outcome_summary_rect": OUTCOME_SUMMARY_RECT,
			"boss_reward_summary_rect": BOSS_REWARD_SUMMARY_RECT,
			"boss_reward_card_gap": BOSS_REWARD_CARD_GAP,
			"boss_reward_row_top": BOSS_REWARD_ROW_TOP,
			"boss_reward_card_height": BOSS_REWARD_CARD_HEIGHT,
			"boss_reward_icon_size": BOSS_REWARD_ICON_SIZE,
			"boss_reward_skip_button_size": BOSS_REWARD_SKIP_BUTTON_SIZE,
			"boss_reward_next_button_size": BOSS_REWARD_NEXT_BUTTON_SIZE,
			"outcome_modal_z_index": OUTCOME_MODAL_Z_INDEX,
			"outcome_scrim_z_index": OUTCOME_SCRIM_Z_INDEX,
			"outcome_boss_scrim_color": OUTCOME_BOSS_SCRIM_COLOR,
		}
	)


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
	if _outcome_overlay == null:
		return
	_outcome_overlay.ensure_boss_reward_controls(_claim_boss_reward_option, _skip_boss_reward_option)


func _show_boss_reward_summary(body: String) -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.show_boss_reward(body)
	_model.clear_pending_next_scene_path()
	_apply_combat_layout()
	var options: Array = RunState.boss_relic_reward_options_snapshot()
	var boss_reward_buttons := _outcome_overlay.boss_reward_buttons()
	for index in boss_reward_buttons.size():
		var button := boss_reward_buttons[index]
		if index >= options.size():
			_outcome_overlay.set_boss_reward_card_content(button, null, "No Relic", "", "")
			button.disabled = true
			continue
		var option: Dictionary = options[index]
		var relic_id := String(option.get("relic_id", option.get("id", "")))
		var content: Dictionary = RunState.ensure_content_registry().get_relic(relic_id)
		var description := String(content.get("description", ""))
		_outcome_overlay.set_boss_reward_card_content(
			button,
			_visuals.clean_icon_for_key(String(content.get("icon_key", ""))),
			String(option.get("display_name", content.get("display_name", "Relic"))),
			String(option.get("rarity", content.get("rarity", "common"))).to_upper(),
			_outcome_overlay.wrap_text_to_lines(description, 28, 2)
		)
		button.tooltip_text = "%s\n%s\n%s" % [
			String(option.get("display_name", content.get("display_name", "Relic"))),
			String(option.get("rarity", content.get("rarity", "common"))).to_upper(),
			description,
		]
		button.disabled = false
	if options.is_empty():
		_outcome_body_label.text = "%s\nNo boss relic options generated. Use Skip Relic to continue." % body
		for button in boss_reward_buttons:
			button.visible = false
			button.disabled = true
		var skip_button := _outcome_overlay.boss_reward_skip_button()
		if skip_button != null:
			skip_button.visible = true
			skip_button.disabled = false
		_next_button.disabled = true


func _claim_boss_reward_option(index: int) -> void:
	if _outcome_overlay == null or not _outcome_overlay.is_boss_reward_pending():
		return
	var result: Dictionary = RunState.claim_boss_relic_reward(index)
	if not bool(result.get("ok", false)):
		_status_label.text = "Boss relic claim failed: %s" % String(result.get("reason", "unknown"))
		return
	var transition: Dictionary = RunState.advance_after_boss_reward()
	_outcome_overlay.set_boss_reward_pending(false)
	_update_hud()
	_audio_play_sfx("ui_accept")
	_hide_outcome_summary()
	var next_scene := String(transition.get("next_scene", "res://scenes/main_menu.tscn"))
	_trace_and_change_scene_to_target(
		next_scene,
		_flow_trace_route_id_value(),
		"boss_reward_claim",
		"combat_before_change_scene_to_file_boss_reward_claim",
		{"option_index": index}
	)


func _skip_boss_reward_option() -> void:
	if _outcome_overlay == null or not _outcome_overlay.is_boss_reward_pending():
		return
	var skip_result: Dictionary = RunState.skip_boss_relic_reward()
	if not bool(skip_result.get("ok", false)):
		_status_label.text = "Boss relic skip failed: %s" % String(skip_result.get("reason", "unknown"))
		return
	var transition: Dictionary = RunState.advance_after_boss_reward()
	_outcome_overlay.set_boss_reward_pending(false)
	_audio_play_sfx("ui_accept")
	_hide_outcome_summary()
	var next_scene := String(transition.get("next_scene", "res://scenes/main_menu.tscn"))
	_trace_and_change_scene_to_target(
		next_scene,
		_flow_trace_route_id_value(),
		"boss_reward_skip",
		"combat_before_change_scene_to_file_boss_reward_skip"
	)


func _trace_and_change_scene_to_target(
	target_scene: String,
	current_route_id: String,
	source: String,
	before_change_step: String,
	begin_payload_extra: Dictionary = {}
) -> void:
	var transition_route_id := current_route_id
	if target_scene.find("shop.tscn") >= 0:
		var begin_payload := {"source": source}
		for key in begin_payload_extra.keys():
			begin_payload[key] = begin_payload_extra[key]
		transition_route_id = RunState.flow_trace_begin(
			"combat_to_shop",
			target_scene,
			begin_payload
		)
	RunState.flow_trace_mark(
		before_change_step,
		{"source": source},
		transition_route_id,
		target_scene
	)
	var scene_change_result: Variant = RunState.flow_trace_change_scene(
		_host.get_tree(),
		target_scene,
		transition_route_id,
		source,
		"",
		_on_combat_scene_post_ready_rollback
	)
	if not FLOW_RESULT_UTILS.scene_change_succeeded(scene_change_result):
		_handle_combat_scene_change_failure(target_scene, transition_route_id, source, scene_change_result)


func _on_combat_scene_post_ready_rollback(result: Dictionary) -> void:
	_handle_combat_scene_change_failure(
		String(result.get("target_scene", RunState.SCENE_RUN_SUMMARY)),
		String(result.get("route_id", _flow_trace_route_id_value())),
		String(result.get("source", "combat_post_ready_rollback")),
		result
	)


func _handle_combat_scene_change_failure(target_scene: String, route_id: String, source: String, result: Variant) -> void:
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(result)
	_model.set_pending_next_scene_path(target_scene)
	_model.clear_outcome_transition_queued()
	_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	var button_text := "Run Summary" if target_scene.find("run_summary") >= 0 else "Continue"
	_show_outcome_summary("Transition Failed", "Could not open the next scene.\n%s" % failure_reason, true, button_text)
	if _status_label != null and is_instance_valid(_status_label):
		_status_label.text = "Transition failed: %s" % failure_reason
		_status_label.modulate = STATUS_COLOR_NEGATIVE
	_append_combat_log("Scene transition failed from %s to %s: %s" % [source, target_scene, failure_reason])
	RunState.flow_trace_mark(
		"combat_scene_change_failed",
		{
			"source": source,
			"reason": failure_reason,
		},
		route_id,
		target_scene
	)
	push_error("Combat scene transition failed: %s -> %s (%s)" % [source, target_scene, failure_reason])


func _ensure_outcome_overlay_layer() -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.ensure_overlay_layer()


func _queue_outcome_transition(scene_path: String) -> void:
	if not _model.mark_outcome_transition_queued():
		return
	await _host.get_tree().create_timer(1.0).timeout
	if (_host != null and is_instance_valid(_host) and _host.is_inside_tree()):
		_host.get_tree().change_scene_to_file(scene_path)


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
				_status_label.text = "Input locked: %s" % _ensure_model().external_lock_reason()
	_sync_model_state()


func _ensure_model() -> CombatModel:
	if _model == null:
		_model = CombatModel.new()
	return _model


func _sync_model_state() -> void:
	var model := _ensure_model()
	model.set_combat_speed(model.combat_speed())


func _flow_trace_route_id_value() -> String:
	return _ensure_model().flow_trace_route_id()


func _set_flow_trace_route_id(route_id: String) -> void:
	_ensure_model().set_flow_trace_route_id(route_id)


func _input_phase_value() -> InputPhase:
	return int(_ensure_model().input_phase()) as InputPhase


func _combat_speed_value() -> String:
	return _ensure_model().combat_speed()


func _sync_timer_display(seconds_left: float, state: String) -> void:
	if _view != null:
		_view.sync_timer_display(seconds_left, state)


func _timer_ready_seconds() -> float:
	if _player_state == null:
		return MOVE_TIMER_MAX_SECONDS
	return _player_state.move_timer_seconds


func _abort_active_drag() -> void:
	if _board_controller != null:
		_board_controller.abort()
	_sync_timer_display(0.0, TIMER_STATE_LOCKED)


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
	if _elemental_mastery_cards == null or _player_state == null:
		return
	var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
	if not OrbType.is_valid_id(orb_id):
		return
	var amount := _preview_match_feedback_value(group, combo_value)
	if amount <= 0:
		return
	var next_total: int = _model.add_combat_mastery_preview_total(orb_id, amount)
	_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, orb_id, next_total)


func _reset_combat_mastery_preview() -> void:
	_model.reset_combat_mastery_preview()
	if _elemental_mastery_cards != null:
		_player_loadout_hud.clear_combat_mastery_feedback(_elemental_mastery_cards)


func _sync_combat_mastery_preview_totals() -> void:
	if _elemental_mastery_cards == null:
		return
	for orb_id in OrbType.ALL_TYPES:
		var total: int = _model.combat_mastery_preview_total(int(orb_id))
		_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, int(orb_id), total)


func _release_combat_mastery_feedback(orb_id: int) -> void:
	if _elemental_mastery_cards == null or not OrbType.is_valid_id(orb_id):
		return
	_model.release_combat_mastery_feedback(orb_id)
	_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, orb_id, 0)


func _release_remaining_combat_mastery_feedback() -> void:
	for orb_id in OrbType.ALL_TYPES:
		if _model.combat_mastery_preview_total(int(orb_id)) <= 0:
			continue
		_release_combat_mastery_feedback(int(orb_id))
		await _wait_combat_speed(COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS)
		if not _can_continue_after_async_wait():
			return


func _preview_match_feedback_value(group: Dictionary, combo_value: int) -> int:
	var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
	if not OrbType.is_valid_id(orb_id) or _player_state == null:
		return 0
	var cells: Array = group.get("cells", [])
	var matched_count := cells.size()
	if matched_count <= 0:
		return 0
	var base_amount := matched_count * _player_state.orb_value(orb_id)
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH, OrbType.Id.ARMOR:
			return int(round(float(base_amount) * _player_state.combo_multiplier(combo_value)))
		_:
			return base_amount


func _build_turn_summary_status(turn_log: Dictionary) -> String:
	return _turn_log_presenter.build_turn_summary_status(turn_log)


func _build_victory_status(turn_log: Dictionary, transition: Dictionary) -> String:
	return _turn_log_presenter.build_victory_status(turn_log, transition)


func _build_victory_gold_summary(turn_log: Dictionary, transition: Dictionary = {}) -> String:
	return _turn_log_presenter.build_victory_gold_summary(turn_log, transition)


func _build_run_outcome_summary(fallback_cause: String = "") -> String:
	var summary: Dictionary = RunState.run_summary_snapshot()
	return _turn_log_presenter.build_run_outcome_summary(summary, RunState.MAX_DUNGEON_LEVELS, fallback_cause)


func _build_defeat_status(turn_log: Dictionary) -> String:
	return _turn_log_presenter.build_defeat_status(turn_log)


func _build_defeat_cause(turn_log: Dictionary) -> String:
	var enemy_label := String(_enemy_state.display_name if _enemy_state != null else "Enemy")
	return _turn_log_presenter.build_defeat_cause(enemy_label, turn_log)


func _replay_turn_resolution_from_log(turn_log: Dictionary) -> void:
	var enemy_damage := int(turn_log.get("enemy_damage_taken", 0))
	var enemy_blocked := int(turn_log.get("enemy_blocked", 0))
	var fire_damage := int(turn_log.get("fire_damage", 0))
	var ice_damage := int(turn_log.get("ice_damage", 0))
	var earth_damage := int(turn_log.get("earth_damage", 0))
	var heart_heal := int(turn_log.get("healed", 0))
	var armor_gain := int(turn_log.get("armor_gained", 0))
	var gold_gain := int(turn_log.get("gold_gained", 0))
	var enemy_target := _enemy_vfx_target_global(0.48)
	var player_target := _player_vfx_target_global(0.64)
	var enemy_impact_size := Vector2(84, 84)
	var player_impact_size := Vector2(84, 84)
	var gold_impact_size := Vector2(70, 70)
	var damage_lifetime := _combat_speed_duration(0.42)
	var player_lifetime := _combat_speed_duration(0.45)
	var gold_lifetime := _combat_speed_duration(0.55)
	var label_lifetime := _combat_speed_duration(0.72)

	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		if fire_damage > 0:
			_spawn_replay_impact(enemy_target, "fire", enemy_impact_size, damage_lifetime, fire_damage)
			_spawn_mastery_beam(OrbType.Id.FIRE, enemy_target, damage_lifetime)
			_spawn_result_label("%d" % fire_damage, enemy_target, "fire", label_lifetime, Vector2(0, -52), fire_damage)
			_play_mastery_effect_sfx("damage")
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_stage_hud_enemy_damage_step(fire_damage)
			_release_combat_mastery_feedback(OrbType.Id.FIRE)
		if ice_damage > 0:
			_spawn_replay_impact(enemy_target, "ice", enemy_impact_size, damage_lifetime, ice_damage)
			_spawn_mastery_beam(OrbType.Id.ICE, enemy_target, damage_lifetime)
			_spawn_result_label("%d" % ice_damage, enemy_target, "ice", label_lifetime, Vector2(0, -52), ice_damage)
			_play_mastery_effect_sfx("damage")
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_stage_hud_enemy_damage_step(ice_damage)
			_release_combat_mastery_feedback(OrbType.Id.ICE)
		if earth_damage > 0:
			_spawn_replay_impact(enemy_target, "earth", enemy_impact_size, damage_lifetime, earth_damage)
			_spawn_mastery_beam(OrbType.Id.EARTH, enemy_target, damage_lifetime)
			_spawn_result_label("%d" % earth_damage, enemy_target, "earth", label_lifetime, Vector2(0, -52), earth_damage)
			_play_mastery_effect_sfx("damage")
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_stage_hud_enemy_damage_step(earth_damage)
			_release_combat_mastery_feedback(OrbType.Id.EARTH)
	elif enemy_damage > 0:
		var impact_orb := _dominant_orb_for_matches(turn_log.get("matched_counts", {}))
		_spawn_replay_impact(enemy_target, _mastery_impact_kind(impact_orb), enemy_impact_size, damage_lifetime, enemy_damage)
		_spawn_mastery_beam(impact_orb, enemy_target, damage_lifetime)
		_spawn_result_label("%d" % enemy_damage, enemy_target, _result_label_kind_for_orb(impact_orb), label_lifetime, Vector2(0, -52), enemy_damage)
		_play_mastery_effect_sfx("damage")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_stage_hud_enemy_result()
		_release_combat_mastery_feedback(impact_orb)
	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		_stage_hud_enemy_result()
	if enemy_blocked > 0:
		_spawn_result_label("-%d Damage Blocked" % enemy_blocked, enemy_target, "block", label_lifetime, Vector2(0, 16))
		_stage_hud_enemy_result()

	if heart_heal > 0:
		var staged_hp_before_heal: int = _model.staged_hud_value("player_hp", int(_player_state.current_hp))
		_spawn_replay_impact(player_target, "heart", player_impact_size, player_lifetime, heart_heal)
		_spawn_mastery_beam(OrbType.Id.HEART, player_target, player_lifetime)
		_spawn_result_label("+%d HP" % heart_heal, player_target, "heal", label_lifetime, Vector2(0, -46), heart_heal)
		_play_mastery_effect_sfx("heal")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_stage_hud_player_hp(staged_hp_before_heal + heart_heal)
		_release_combat_mastery_feedback(OrbType.Id.HEART)

	if armor_gain > 0:
		var staged_armor_before_gain: int = _model.staged_hud_value("player_armor", int(_player_state.armor))
		_spawn_replay_impact(player_target, "armor", player_impact_size, player_lifetime, armor_gain)
		_spawn_mastery_beam(OrbType.Id.ARMOR, player_target, player_lifetime)
		_spawn_result_label("+%d Armor" % armor_gain, player_target, "armor", label_lifetime, Vector2(0, -46), armor_gain)
		_play_mastery_effect_sfx("armor")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_stage_hud_player_armor(staged_armor_before_gain + armor_gain)
		_release_combat_mastery_feedback(OrbType.Id.ARMOR)

	if gold_gain > 0:
		var staged_gold_before_gain: int = _model.staged_hud_value("player_gold", int(_player_state.gold))
		_spawn_replay_impact(player_target, "gold", gold_impact_size, gold_lifetime, gold_gain)
		_spawn_mastery_beam(OrbType.Id.GOLD, player_target, gold_lifetime)
		_spawn_result_label("+%d Gold" % gold_gain, player_target, "gold", label_lifetime, Vector2(0, -46), gold_gain)
		_play_mastery_effect_sfx("gold")
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_stage_hud_gold(staged_gold_before_gain + gold_gain)
		_release_combat_mastery_feedback(OrbType.Id.GOLD)
	await _release_remaining_combat_mastery_feedback()
	if not _can_continue_after_async_wait():
		return
	await _replay_enemy_attack_result_labels(turn_log, player_target, label_lifetime)
	if not _can_continue_after_async_wait():
		return
	await _wait_combat_speed(TURN_REPLAY_FINAL_HOLD_SECONDS)
	if not _can_continue_after_async_wait():
		return
	_reset_combat_mastery_preview()


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

	if _hud_presenter == null:
		_hud_presenter = COMBAT_HUD_PRESENTER_SCRIPT.new()
	var hud_snapshot: Dictionary = _build_hud_snapshot()
	if _view != null:
		_view.apply_hud_snapshot(
			hud_snapshot,
			{"refresh_build_icon_rows": Callable(self, "_refresh_build_icon_rows")}
		)


func _build_hud_snapshot() -> Dictionary:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	var intent := _enemy_state.get_current_intent()
	var timer_state := TIMER_STATE_READY if _input_phase_value() == InputPhase.PLAYER_INPUT else TIMER_STATE_LOCKED
	if _drag_active():
		timer_state = TIMER_STATE_ACTIVE
	var timer_seconds := _drag_move_time_left() if _drag_active() else _timer_ready_seconds()
	var enemy_stage_texture: Texture2D = null
	var enemy_portrait_texture: Texture2D = null
	if _visuals != null:
		enemy_stage_texture = _visuals.enemy_stage_background(_enemy_state.enemy_id)
		enemy_portrait_texture = _visuals.enemy_sprite(_enemy_state.enemy_id)
	if enemy_portrait_texture == null and _visuals != null:
		enemy_portrait_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_portrait_texture == null:
		enemy_portrait_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	var player_gold: int = _model.staged_hud_value("player_gold", int(_player_state.gold))
	var enemy_hp: int = _model.staged_hud_value("enemy_hp", int(_enemy_state.current_hp))
	var enemy_turn_block: int = _model.staged_hud_value("enemy_turn_block", int(_enemy_state.current_turn_block))
	var enemy_intent_preview: Dictionary = {}
	if _should_show_intent_damage_preview():
		enemy_intent_preview = _enemy_intent_preview_data(intent, enemy_hp, int(_enemy_state.max_hp))
	var player_hp: int = _model.staged_hud_value("player_hp", int(_player_state.current_hp))
	var player_armor: int = _model.staged_hud_value("player_armor", int(_player_state.armor))
	var run_label := RunState.level_sequence_label()
	var top_level_text := "LEVEL %d / %d" % [RunState.dungeon_level, RunState.MAX_DUNGEON_LEVELS]
	var top_enemy_step_text := _top_enemy_step_text()
	var top_gold_text := "GOLD %d" % player_gold
	var primary_intent_badge := _primary_intent_badge_snapshot(intent)
	var hud_snapshot: Dictionary = _hud_presenter.build_snapshot(
		{
			"top_level_text": top_level_text,
			"top_enemy_step_text": top_enemy_step_text,
			"top_gold_text": top_gold_text,
			"enemy_name_text": _enemy_state.display_name,
			"enemy_hp": enemy_hp,
			"enemy_max_hp": int(_enemy_state.max_hp),
			"enemy_hp_text": "HP %d / %d" % [enemy_hp, int(_enemy_state.max_hp)],
			"enemy_turn_block": enemy_turn_block,
			"enemy_intent_preview": enemy_intent_preview,
			"enemy_stage_texture": enemy_stage_texture,
			"enemy_portrait_texture": enemy_portrait_texture,
			"primary_intent_badge": primary_intent_badge,
			"combat_turn_index": int(_combat.turn_index),
			"combat_phase_name": _combat.phase_name(),
			"timer_state": timer_state,
			"timer_seconds": timer_seconds,
			"player_hp": player_hp,
			"player_max_hp": int(_player_state.max_hp),
			"player_armor": player_armor,
			"fire_orb_value": int(_player_state.orb_value(OrbType.Id.FIRE)),
			"armor_orb_value": int(_player_state.orb_value(OrbType.Id.ARMOR)),
			"heart_mastery_level": int(mastery_levels.get(OrbType.Id.HEART, 0)),
			"gold_mastery_level": int(mastery_levels.get(OrbType.Id.GOLD, 0)),
			"turn_summary_text": _turn_summary_label.text,
			"progression_snapshot": progression_snapshot,
			"run_label": run_label,
		}
	)
	var enemy_stage_snapshot: Dictionary = Dictionary(hud_snapshot.get("enemy_stage", {}))
	enemy_stage_snapshot["enemy_portrait_texture"] = enemy_portrait_texture
	hud_snapshot["enemy_stage"] = enemy_stage_snapshot
	return hud_snapshot


func _top_enemy_step_text() -> String:
	var step := String(RunState.current_step_key)
	match step:
		"enemy_1":
			return "ENEMY 1"
		"enemy_2":
			return "ENEMY 2"
		"boss":
			return "BOSS"
		"shop":
			return "SHOP"
		_:
			return step.to_upper()


func _primary_intent_badge_snapshot(intent: Dictionary) -> Dictionary:
	if intent.is_empty():
		return {
			"kind": "idle",
			"title": "Intent",
			"amount": "--",
			"detail": "No immediate action.",
		}
	var entries := _intent_entries_data(intent)
	if entries.is_empty():
		return {
			"kind": "idle",
			"title": "Intent",
			"amount": "--",
			"detail": _format_intent_compact(intent),
		}
	var attack_amount := 0
	var block_amount := 0
	for entry in entries:
		var entry_kind := String(entry.get("kind", ""))
		var amount := maxi(0, int(entry.get("amount", 0)))
		if entry_kind == "attack":
			attack_amount += amount
		elif entry_kind == "block":
			block_amount += amount
	var badge_kind := "idle"
	var title := "Intent"
	var amount_text := "--"
	var detail_text := ""
	if attack_amount > 0 and block_amount > 0:
		badge_kind = "mixed"
		title = "Strike + Guard"
		amount_text = "%d / %d" % [attack_amount, block_amount]
		detail_text = "Deals %d and gains %d block." % [attack_amount, block_amount]
	elif attack_amount > 0:
		badge_kind = "attack"
		title = "Attack"
		amount_text = str(attack_amount)
		detail_text = "Incoming damage %d." % attack_amount
	elif block_amount > 0:
		badge_kind = "block"
		title = "Block"
		amount_text = str(block_amount)
		detail_text = "Enemy gains %d block." % block_amount
	else:
		detail_text = _format_intent_compact(intent)
	return {
		"kind": badge_kind,
		"title": title,
		"amount": amount_text,
		"detail": detail_text,
	}


func _apply_hud_snapshot(hud_snapshot: Dictionary) -> void:
	if _view != null:
		_view.apply_hud_snapshot(
			hud_snapshot,
			{"refresh_build_icon_rows": Callable(self, "_refresh_build_icon_rows")}
		)


func _capture_hud_stage_values() -> Dictionary:
	if _player_state == null or _enemy_state == null:
		return {}
	return {
		"player_gold": int(_player_state.gold),
		"enemy_hp": int(_enemy_state.current_hp),
		"enemy_turn_block": int(_enemy_state.current_turn_block),
		"player_hp": int(_player_state.current_hp),
		"player_armor": int(_player_state.armor),
	}


func _stage_hud_values(values: Dictionary) -> void:
	if not _model.is_hud_staging_active():
		return
	_model.stage_hud_values(values)
	_update_hud()


func _stage_hud_enemy_damage_step(raw_damage: int) -> void:
	if _enemy_state == null or raw_damage <= 0:
		return
	var staged_block := maxi(0, _model.staged_hud_value("enemy_turn_block", int(_enemy_state.current_turn_block)))
	var staged_hp := maxi(0, _model.staged_hud_value("enemy_hp", int(_enemy_state.current_hp)))
	var blocked := mini(staged_block, raw_damage)
	var hp_damage := maxi(0, raw_damage - blocked)
	_stage_hud_values({
		"enemy_turn_block": staged_block - blocked,
		"enemy_hp": maxi(0, staged_hp - hp_damage),
	})


func _stage_hud_enemy_result() -> void:
	if _enemy_state == null:
		return
	_stage_hud_values({
		"enemy_hp": int(_enemy_state.current_hp),
		"enemy_turn_block": int(_enemy_state.current_turn_block),
	})


func _stage_hud_player_hp(value: int) -> void:
	if _player_state == null:
		return
	_stage_hud_values({"player_hp": clampi(value, 0, int(_player_state.max_hp))})


func _stage_hud_player_armor(value: int) -> void:
	_stage_hud_values({"player_armor": maxi(0, value)})


func _stage_hud_player_block_step(blocked_by_armor: int) -> void:
	if blocked_by_armor <= 0:
		return
	var staged_armor := maxi(0, _model.staged_hud_value("player_armor", int(_player_state.armor if _player_state != null else 0)))
	var consumed_armor := mini(blocked_by_armor, staged_armor)
	_stage_hud_player_armor(staged_armor - consumed_armor)


func _stage_hud_gold(value: int) -> void:
	_stage_hud_values({"player_gold": maxi(0, value)})


func _stage_hud_player_final() -> void:
	if _player_state == null:
		return
	_stage_hud_values({
		"player_hp": int(_player_state.current_hp),
		"player_armor": int(_player_state.armor),
	})


func _should_show_intent_damage_preview() -> bool:
	if _combat == null or _enemy_state == null:
		return false
	if _input_phase_value() != InputPhase.PLAYER_INPUT:
		return false
	if _model.is_outcome_transition_queued():
		return false
	if _combat.is_fight_over():
		return false
	return true


func _intent_damage_preview_data(intent: Dictionary, player_hp: int, player_armor: int) -> Dictionary:
	if intent.is_empty():
		return {}
	var attack_entries := _intent_entries_for_kind(intent, "attack")
	if attack_entries.is_empty():
		return {}
	var visible_hp := maxi(0, player_hp)
	if visible_hp <= 0:
		return {}
	var visible_armor := maxi(0, player_armor)
	var attack := 0
	var blocked := 0
	var hp_loss := 0
	for entry in attack_entries:
		var amount := maxi(0, int(entry.get("amount", 0)))
		if amount <= 0:
			continue
		attack += amount
		var entry_blocked := mini(amount, visible_armor - blocked)
		blocked += maxi(0, entry_blocked)
		hp_loss = mini(visible_hp, hp_loss + maxi(0, amount - entry_blocked))
	if blocked <= 0 and hp_loss <= 0:
		return {}
	return {
		"attack": attack,
		"blocked": blocked,
		"hp_loss": hp_loss,
		"current_hp": visible_hp,
		"current_armor": visible_armor,
		"fully_blocked": hp_loss <= 0 and blocked > 0,
	}


func _enemy_intent_preview_data(intent: Dictionary, enemy_hp: int, enemy_max_hp: int) -> Dictionary:
	if intent.is_empty():
		return {}
	var entries := _intent_entries_data(intent)
	if entries.is_empty():
		return {}
	var max_hp := maxi(1, enemy_max_hp)
	var block := 0
	for entry in entries:
		if String(entry.get("kind", "")) == "block":
			block += maxi(0, int(entry.get("amount", 0)))
	return {
		"block": block,
		"current_hp": maxi(0, enemy_hp),
		"max_hp": max_hp,
		"entries": entries,
	}


func _intent_entries_data(intent: Dictionary) -> Array[Dictionary]:
	var raw_entries: Array = []
	if intent.has("entries") and intent.get("entries") is Array:
		raw_entries = intent.get("entries")
	elif intent.has("intents") and intent.get("intents") is Array:
		raw_entries = intent.get("intents")
	var entries: Array[Dictionary] = []
	for raw in raw_entries:
		if not (raw is Dictionary):
			continue
		var raw_entry := raw as Dictionary
		var kind := String(raw_entry.get("kind", raw_entry.get("type", ""))).to_lower()
		var amount := maxi(0, int(raw_entry.get("amount", raw_entry.get(kind, 0))))
		if kind == "attack" and amount <= 0:
			amount = maxi(0, int(raw_entry.get("damage", raw_entry.get("attack", 0))))
		if kind == "block" and amount <= 0:
			amount = maxi(0, int(raw_entry.get("block", 0)))
		if amount <= 0 or (kind != "attack" and kind != "block"):
			continue
		entries.append({
			"id": String(raw_entry.get("id", "%s_%d" % [kind, entries.size()])),
			"kind": kind,
			"amount": amount,
			"label": String(raw_entry.get("label", _intent_entry_label(kind, amount))),
		})
	if entries.is_empty():
		var attack := maxi(0, int(intent.get("attack", 0)))
		if attack > 0:
			entries.append({"id": "attack_0", "kind": "attack", "amount": attack, "label": _intent_entry_label("attack", attack)})
		var block := maxi(0, int(intent.get("block", 0)))
		if block > 0:
			entries.append({"id": "block_%d" % entries.size(), "kind": "block", "amount": block, "label": _intent_entry_label("block", block)})
	return entries


func _intent_entries_for_kind(intent: Dictionary, kind: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in _intent_entries_data(intent):
		if String(entry.get("kind", "")) == kind:
			entries.append(entry)
	return entries


func _intent_entry_label(kind: String, amount: int) -> String:
	match kind:
		"attack":
			return "Attack %d" % amount
		"block":
			return "Block %d" % amount
		_:
			return "%s %d" % [kind.capitalize(), amount]


func _on_intent_damage_preview_hovered(preview: Dictionary) -> void:
	if not _should_show_intent_damage_preview():
		return
	var attack := maxi(0, int(preview.get("attack", 0)))
	var blocked := maxi(0, int(preview.get("blocked", 0)))
	var hp_loss := maxi(0, int(preview.get("hp_loss", 0)))
	if attack <= 0:
		return
	_status_label.text = "%s | Incoming %d (Block %d, HP Loss %d)." % [
		RunState.level_sequence_label(),
		attack,
		blocked,
		hp_loss,
	]
	_status_label.modulate = STATUS_COLOR_WARNING
	if _enemy_state != null:
		var intent := _enemy_state.get_current_intent()
		if not intent.is_empty():
			_turn_summary_label.text = _format_intent(intent)
	_start_enemy_intent_hover_emphasis("attack")


func _on_intent_block_preview_hovered(preview: Dictionary) -> void:
	if not _should_show_intent_damage_preview():
		return
	var blocked := maxi(0, int(preview.get("blocked", 0)))
	if blocked <= 0:
		return
	_status_label.text = "%s | Incoming attack blocked by %d armor." % [
		RunState.level_sequence_label(),
		blocked,
	]
	_status_label.modulate = STATUS_COLOR_WARNING
	if _enemy_state != null:
		var intent := _enemy_state.get_current_intent()
		if not intent.is_empty():
			_turn_summary_label.text = _format_intent(intent)
	_start_enemy_intent_hover_emphasis("block")


func _on_enemy_block_preview_hovered(preview: Dictionary) -> void:
	if not _should_show_intent_damage_preview():
		return
	if preview.is_empty():
		return
	var block := maxi(0, int(preview.get("block", 0)))
	if block <= 0:
		return
	_status_label.text = "%s | Enemy will gain %d block." % [
		RunState.level_sequence_label(),
		block,
	]
	_status_label.modulate = STATUS_COLOR_WARNING
	if _enemy_state != null:
		var intent := _enemy_state.get_current_intent()
		if not intent.is_empty():
			_turn_summary_label.text = _format_intent(intent)
	_start_enemy_intent_hover_emphasis("block")


func _on_intent_damage_preview_hover_ended() -> void:
	_stop_enemy_intent_hover_emphasis()


func _start_enemy_intent_hover_emphasis(kind: String) -> void:
	if _view != null:
		_view.start_enemy_intent_hover_emphasis(kind)


func _stop_enemy_intent_hover_emphasis() -> void:
	if _view != null:
		_view.stop_enemy_intent_hover_emphasis()


func _on_enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	if not _should_show_intent_damage_preview():
		return
	var amount := maxi(0, int(entry.get("amount", 0)))
	if amount <= 0:
		return
	if kind == "attack":
		_status_label.text = "%s | Enemy intent: Attack %d." % [RunState.level_sequence_label(), amount]
	elif kind == "block":
		_status_label.text = "%s | Enemy intent: Block %d." % [RunState.level_sequence_label(), amount]
	else:
		_status_label.text = "%s | Enemy intent: %s." % [RunState.level_sequence_label(), String(entry.get("label", ""))]
	_status_label.modulate = STATUS_COLOR_WARNING
	_start_enemy_intent_hover_emphasis(kind)


func _format_intent(intent: Dictionary) -> String:
	if _turn_log_presenter != null:
		return _turn_log_presenter.format_intent(intent)
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func _format_intent_compact(intent: Dictionary) -> String:
	if _turn_log_presenter != null:
		return _turn_log_presenter.format_intent_compact(intent)
	return _format_intent(intent)


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
	if _debug_console != null:
		log_level = _debug_console.log_level()
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
	if _debug_console != null:
		_debug_console.append_log(message, is_command_output)


func _refresh_combat_log_display() -> void:
	if _debug_console != null:
		_debug_console.refresh_display()


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
		intent_preview = _intent_damage_preview_data(
			_enemy_state.get_current_intent(),
			visible_player_hp,
			visible_player_armor
		)
	_player_loadout_hud.update_player_data({
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
	})
	_apply_loadout_rail_layout()
	call_deferred("_apply_loadout_rail_layout")

	_relic_row.visible = false
	_mastery_strip.visible = false


func _emit_turn_feedback_vfx(_turn_log: Dictionary) -> void:
	pass


func _replay_enemy_attack_result_labels(turn_log: Dictionary, player_target: Vector2, label_lifetime: float) -> void:
	if bool(turn_log.get("enemy_intent_skipped", false)):
		return
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	var blocked_by_armor := int(enemy_attack.get("blocked_by_armor", 0))
	var hp_damage := int(enemy_attack.get("hp_damage", 0))
	if blocked_by_armor <= 0 and hp_damage <= 0:
		return
	var enemy_source := _enemy_vfx_target_global(0.56)
	var player_impact_target := _player_vfx_target_global(0.58)
	if player_impact_target == Vector2.ZERO:
		player_impact_target = player_target
	var cue_lifetime := _combat_speed_duration(0.24)
	var travel_lifetime := _combat_speed_duration(0.28)
	var impact_lifetime := _combat_speed_duration(0.34)
	_spawn_enemy_attack_cue(enemy_source, player_impact_target, cue_lifetime, travel_lifetime)
	if blocked_by_armor > 0:
		_spawn_enemy_attack_block_impact(player_impact_target, impact_lifetime, blocked_by_armor)
		var block_text := "-%d Damage Blocked" % blocked_by_armor
		_spawn_result_label(block_text, player_target, "block", label_lifetime, Vector2(0, 18))
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_stage_hud_player_block_step(blocked_by_armor)
		if hp_damage <= 0:
			_stage_hud_player_final()
			return
	if hp_damage > 0:
		_spawn_enemy_attack_hit_impact(player_impact_target, impact_lifetime, hp_damage)
		_spawn_result_label("-%d HP" % hp_damage, player_target, "damage", label_lifetime, Vector2(0, -54))
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
	_stage_hud_player_final()


func _spawn_enemy_attack_cue(source_global: Vector2, target_global: Vector2, cue_lifetime: float, travel_lifetime: float) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_enemy_attack_cue(source_global, cue_lifetime)
	_combat_vfx_presenter.spawn_enemy_attack_travel(source_global, target_global, travel_lifetime)


func _spawn_enemy_attack_block_impact(target_global: Vector2, lifetime: float, blocked_amount: int) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_enemy_attack_block_impact(target_global, lifetime, blocked_amount)


func _spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float, hp_damage: int) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_enemy_attack_hit_impact(target_global, lifetime, hp_damage)


func _spawn_result_label(text: String, global_center: Vector2, kind: String, lifetime: float, offset: Vector2 = Vector2.ZERO, result_amount: int = 0) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_result_label(text, global_center, kind, lifetime, offset, result_amount)


func _spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_vfx(effect_name, global_center, draw_size, lifetime, modulate_color)


func _spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func _spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float, result_amount: int = 0) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_replay_impact(global_center, impact_kind, draw_size, lifetime, result_amount)


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
	for orb_id in OrbType.ALL_TYPES:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count > selected_count:
			selected_count = count
			selected_orb = int(orb_id)
	if selected_count <= 0:
		return OrbType.Id.FIRE
	return selected_orb


func _control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if _combat_vfx_presenter != null:
		return _combat_vfx_presenter.control_global_center(control, vertical_bias)
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0)
	)


func _enemy_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	if _view != null and _view.has_method("enemy_vfx_target_global"):
		var view_target: Variant = _view.enemy_vfx_target_global(vertical_bias)
		if view_target is Vector2 and (view_target as Vector2) != Vector2.ZERO:
			return view_target as Vector2
	var enemy_portrait_control: Control = _enemy_portrait
	return _control_global_center(enemy_portrait_control, vertical_bias)


func _player_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	if _view != null and _view.has_method("player_vfx_target_global"):
		var view_target: Variant = _view.player_vfx_target_global(vertical_bias)
		if view_target is Vector2 and (view_target as Vector2) != Vector2.ZERO:
			return view_target as Vector2
	var player_portrait_control: Control = _player_portrait
	return _control_global_center(player_portrait_control, vertical_bias)


func _spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	if _combat_vfx_presenter == null:
		return
	_combat_vfx_presenter.spawn_mastery_beam(source_orb_or_node, target_or_start, orb_or_target, lifetime)


func _on_resolver_match_found(groups: Array) -> void:
	_audio_play_sfx("match")
	_status_label.text = "Matches found: %d group(s)." % groups.size()
	_status_label.modulate = STATUS_COLOR_WARNING


func _pulse_label(target: Label, tint: Color) -> void:
	target.modulate = tint
	target.modulate = STATUS_COLOR_NEUTRAL


func _on_viewport_size_changed() -> void:
	_apply_combat_layout()


func _apply_combat_layout() -> void:
	if _view == null:
		return
	var layout_result: Dictionary = _view.apply_combat_layout(
		_host.get_viewport_rect().size,
		_drag_move_time_left() if _drag_active() else _timer_ready_seconds(),
		TIMER_STATE_ACTIVE if _drag_active() else TIMER_STATE_READY
	)
	if not bool(layout_result.get("applied", false)):
		return


func _apply_combat_mastery_panel_layout() -> void:
	pass


func _combat_player_hud_nodes() -> Dictionary:
	return {
		"section": _player_hud_section,
		"mastery_panel": _elemental_mastery_panel,
		"mastery_title": _elemental_mastery_title,
		"mastery_cards": _elemental_mastery_cards,
		"footer_panel": _player_panel,
		"footer_root": _player_panel_root,
		"root": _player_panel_root,
		"hero_card": _hero_card,
		"hero_card_root": _hero_card_root,
		"hero_portrait": _player_portrait,
		"hero_level_badge": _hero_level_badge,
		"vitals_panel": _vitals_panel,
		"vitals_frame": _vitals_frame,
		"hp_bar": _player_hp_bar,
		"hp_label": _player_hp_label,
		"armor_bar": _player_armor_bar,
		"armor_label": _player_armor_label,
		"armor_badge": _armor_badge,
		"armor_badge_label": _armor_badge_label,
		"loadout_frame": _loadout_frame,
		"loadout_root": _loadout_root,
		"equipment_label": _equipment_row_label,
		"equipment_icons": _equipment_icons,
		"consumable_label": _consumable_row_label,
		"consumable_icons": _consumable_icons,
		"relic_label": _relic_row_label,
		"relic_icons": _relic_icons,
		"relic_row": _relic_row,
		"mastery_strip": _mastery_strip,
		"mastery_root": _mastery_root,
		"mastery_label": _mastery_row_label,
		"mastery_icons": _mastery_icons,
		"stat_chip_row": _stat_chip_row,
		"combat_meta_row": _combat_meta_row,
		"combat_phase_label": _phase_label,
		"turn_summary_label": _turn_summary_label,
	}


func _apply_loadout_rail_layout() -> void:
	if _view != null:
		_view.apply_loadout_rail_layout()


func _refresh_character_portraits() -> void:
	if _view != null:
		_view.refresh_character_portraits(String(_enemy_state.enemy_id if _enemy_state != null else ""))
		return
	_enemy_portrait.texture = _resolve_enemy_figure_texture()
	_enemy_portrait.visible = true
	var hero_texture := _visuals.hero_portrait() if _visuals != null else null
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture


func _resolve_enemy_figure_texture() -> Texture2D:
	var enemy_figure_texture: Texture2D = null
	if _visuals != null and _enemy_state != null:
		enemy_figure_texture = _visuals.enemy_sprite(_enemy_state.enemy_id)
	if enemy_figure_texture == null and _visuals != null:
		enemy_figure_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_figure_texture == null:
		enemy_figure_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	return enemy_figure_texture


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
