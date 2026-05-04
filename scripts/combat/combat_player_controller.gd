extends Control

@onready var _board_surface: BoardSurface = %BoardSurface
@onready var _board_view: BoardView = _board_surface.board_view()
@onready var _background: TextureRect = %Background
@onready var _status_label: Label = %StatusLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _run_progress_label: Label = %RunProgressLabel
@onready var _turn_summary_label: Label = %TurnSummaryLabel
@onready var _player_label: Label = %PlayerHpLabel
@onready var _enemy_label: Label = %EnemyStageLabel
@onready var _enemy_debug_label: Label = %EnemyStateLabel
@onready var _intent_label: Label = %EnemyIntentLabel
@onready var _phase_label: Label = %CombatPhaseLabel
@onready var _combat_log_text: RichTextLabel = %CombatLogText
@onready var _console_input: LineEdit = %ConsoleInput
@onready var _next_button: Button = %NextButton
@onready var _back_button: Button = $"CombatLayoutRoot/TopBar/TopBarRow/BackButton"
@onready var _debug_toggle_button: Button = %DebugToggleButton
@onready var _settings_button: Button = $"CombatLayoutRoot/TopBar/TopBarRow/SettingsButton"
@onready var _board_view_control: Control = %BoardSurface
@onready var _layout_root: Control = %CombatLayoutRoot
@onready var _top_bar: PanelContainer = $"CombatLayoutRoot/TopBar"
@onready var _enemy_panel: PanelContainer = $"CombatLayoutRoot/EnemyPanel"
@onready var _enemy_panel_root: Control = %EnemyPanelRoot
@onready var _intent_row: HBoxContainer = %IntentRow
@onready var _enemy_stage: Control = %EnemyStage
@onready var _enemy_hp_row: Control = %EnemyHpRow
@onready var _combat_strip: PanelContainer = $"CombatLayoutRoot/CombatStrip"
@onready var _timer_track: Control = %TimerTrack
@onready var _timer_fill: ColorRect = %TimerFill
@onready var _timer_icon: TextureRect = %TimerIcon
@onready var _timer_state_label: Label = %TimerStateLabel
@onready var _board_frame: PanelContainer = $"CombatLayoutRoot/BoardPanel/BoardSurface/BoardFrame"
@onready var _board_panel: Control = %BoardPanel
@onready var _board_shadow: Panel = %BoardShadow
@onready var _outcome_summary_panel: Panel = %OutcomeSummaryPanel
@onready var _outcome_summary_root: Control = %OutcomeSummaryRoot
@onready var _outcome_text_column: Control = %OutcomeTextColumn
@onready var _outcome_title_label: Label = %OutcomeTitleLabel
@onready var _outcome_body_label: Label = %OutcomeBodyLabel
@onready var _player_hud_section: Panel = %PlayerHudSection
@onready var _player_panel: Panel = %PlayerPanel
@onready var _player_panel_root: Control = %PlayerPanelRoot
@onready var _hero_card: Panel = %HeroCard
@onready var _hero_card_root: Control = %HeroCardRoot
@onready var _hero_level_badge: PanelContainer = %HeroLevelBadge
@onready var _vitals_panel: Control = %VitalsPanel
@onready var _vitals_frame: Panel = %VitalsFrame
@onready var _player_hp_label: Label = %PlayerHpLabel
@onready var _player_armor_label: Label = %PlayerArmorLabel
@onready var _armor_badge: PanelContainer = %ArmorBadge
@onready var _armor_badge_label: Label = %ArmorBadgeLabel
@onready var _stat_chip_row: HBoxContainer = %StatChipRow
@onready var _attack_stat_label: Label = %AttackStatLabel
@onready var _armor_stat_label: Label = %ArmorStatLabel
@onready var _heart_stat_label: Label = %HeartStatLabel
@onready var _gold_stat_label: Label = %GoldStatLabel
@onready var _combat_meta_row: HBoxContainer = %CombatMetaRow
@onready var _loadout_frame: Panel = %LoadoutFrame
@onready var _loadout_root: Control = %LoadoutRoot
@onready var _mastery_strip: Panel = %MasteryStrip
@onready var _mastery_root: Control = %MasteryRoot
@onready var _combat_log_frame: PanelContainer = $"DebugOverlay/DebugVBox/CombatLogFrame"
@onready var _debug_overlay: PanelContainer = %DebugOverlay
@onready var _title_label: Label = %TitleLabel
@onready var _hint_label: Label = %HintLabel
@onready var _enemy_portrait: TextureRect = %EnemyPortrait
@onready var _intent_badge: TextureRect = %IntentBadge
@onready var _enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var _player_hp_bar: ProgressBar = %PlayerHpBar
@onready var _player_armor_bar: ProgressBar = %PlayerArmorBar
@onready var _player_portrait: TextureRect = %PlayerPortrait
@onready var _equipment_icons: Control = %EquipmentIcons
@onready var _consumable_icons: Control = %ConsumableIcons
@onready var _relic_icons: HBoxContainer = %RelicIcons
@onready var _mastery_icons: Control = %MasteryIcons
@onready var _elemental_mastery_cards: Control = %ElementalMasteryCards
@onready var _elemental_mastery_panel: Panel = %ElementalMasteryPanel
@onready var _elemental_mastery_title: Label = %ElementalMasteryTitle
@onready var _relic_row: HBoxContainer = %RelicRow
@onready var _equipment_row_label: Label = %EquipmentLabel
@onready var _consumable_row_label: Label = %ConsumableLabel
@onready var _relic_row_label: Label = %RelicLabel
@onready var _mastery_row_label: Label = %MasteryLabel
@onready var _vfx_layer: Control = %VfxLayer

const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14
const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_v3.gd")
const BOARD_RESOLVER_TEST_RUNNER_SCRIPT := preload("res://scripts/debug/board_resolver_test_runner.gd")
const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const COMBAT_OUTCOME_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_outcome_overlay.gd")
const COMBAT_RESOLVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_resolve_presenter.gd")
const COMBAT_DEBUG_CONSOLE_SCRIPT := preload("res://scripts/combat/combat_debug_console.gd")
const COMBAT_TURN_LOGGER_SCRIPT := preload("res://scripts/combat/combat_turn_logger.gd")
const COMBAT_LAYOUT_MANAGER_SCRIPT := preload("res://scripts/combat/combat_layout_manager.gd")
const COMBAT_CHROME_STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const COMBAT_VFX_MANAGER_SCRIPT := preload("res://scripts/combat/combat_vfx_manager.gd")
const BOARD_DRAG_INPUT_HANDLER_SCRIPT := preload("res://scripts/combat/board_drag_input_handler.gd")
const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")
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
const ROOT_RECT := Rect2(Vector2(16, 0), Vector2(1048, 1920))
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 58))
const ENEMY_PANEL_RECT := Rect2(Vector2(16, 70), Vector2(1048, 340))
const COMBAT_STRIP_RECT := Rect2(Vector2(16, 424), Vector2(1048, 56))
const BOARD_PANEL_RECT := Rect2(Vector2(16, 492), Vector2(1048, 584))
const ENEMY_INTENT_RECT := Rect2(Vector2(296, 16), Vector2(456, 60))
const ENEMY_STAGE_RECT := Rect2(Vector2(0, 70), Vector2(1048, 216))
const ENEMY_HP_ROW_RECT := Rect2(Vector2(0, 286), Vector2(1048, 52))
const ENEMY_PORTRAIT_SIZE := Vector2(280, 216)
const ENEMY_HP_BAR_SIZE := Vector2(620, 22)
const BOARD_SURFACE_SIZE := Vector2(480, 576)
const BOARD_SURFACE_TOP := 4.0
const BOARD_SURFACE_SIDE_PADDING := 4.0
const BOARD_SURFACE_BOTTOM_PADDING := 4.0
const BOARD_SHADOW_OFFSET := Vector2(10, 0)
const BOARD_SHADOW_EXPAND := Vector2(24, 8)
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
const HERO_CARD_RECT := Rect2(Vector2(30, 18), Vector2(220, 226))
const HERO_PORTRAIT_RECT := Rect2(Vector2(16, 16), Vector2(188, 194))
const HERO_LEVEL_BADGE_RECT := Rect2(Vector2(8, 178), Vector2(60, 40))
const VITALS_PANEL_RECT := Rect2(Vector2(272, 26), Vector2(714, 176))
const VITALS_FRAME_RECT := Rect2(Vector2(0, 0), Vector2(714, 176))
const PLAYER_HP_BAR_RECT := Rect2(Vector2(18, 52), Vector2(678, 54))
const PLAYER_ARMOR_BAR_RECT := Rect2(Vector2(18, 112), Vector2(434, 34))
const ARMOR_BADGE_RECT := Rect2(Vector2(474, 112), Vector2(222, 34))
const PLAYER_STAT_CHIP_RECT := Rect2(Vector2(222, 110), Vector2(552, 42))
const PLAYER_META_RECT := Rect2(Vector2(230, 190), Vector2(740, 32))
const PLAYER_SUMMARY_RECT := Rect2(Vector2(230, 224), Vector2(740, 28))
const PLAYER_LOADOUT_RECT := Rect2(Vector2(42, 248), Vector2(996, 150))
const PLAYER_MASTERY_RECT := Rect2(Vector2(42, 404), Vector2(996, 50))
const PLAYER_RELIC_RECT := Rect2(Vector2(230, 224), Vector2(740, 38))
const PLAYER_PORTRAIT_SIZE := Vector2(188, 194)
const COMBAT_STRIP_INSET := 12.0
const TIMER_TRACK_SIZE := Vector2(720, 36)
const TIMER_TRACK_PADDING := 5.0
const TIMER_ICON_SIZE := Vector2(34, 34)
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(518, 136), Vector2(280, 88))
const EQUIPMENT_LABEL_RECT := Rect2(Vector2(118, 108), Vector2(296, 22))
const CONSUMABLE_LABEL_RECT := Rect2(Vector2(514, 108), Vector2(288, 22))
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
var _board_state := BoardState.new()
var _resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()
var _combat: Variant
var _player_state: PlayerState
var _enemy_state: EnemyState
var _progression_state: PlayerProgressionState

var _input_phase: InputPhase = InputPhase.PLAYER_INPUT
var _external_lock_reason := ""
var _last_resolve_result: Dictionary = {}
var _outcome_transition_queued := false
var _pending_next_scene_path := ""
var _consumable_rng := RandomNumberGenerator.new()
var _visuals: VisualRegistry = null
var _player_loadout_hud: PlayerLoadoutHud = null
var _outcome_overlay: CombatOutcomeOverlay = null
var _debug_console: CombatDebugConsole = null
var _turn_logger: CombatTurnLogger = null
var _is_low_vertical_layout := false
var _zone_guides_enabled := false
var _resolve_trace_origin_usec := 0
var _resolve_trace_active := false
var _resolve_trace_pass_index := -1
var _combat_mastery_feedback_token := 0
var _combat_mastery_preview_totals: Dictionary = {}
var _combat_speed := COMBAT_SPEED_NORMAL
var _resolve_presenter: Variant = null
var _combat_layout_manager: Variant = null
var _combat_vfx_manager: Variant = null
var _board_drag_input_handler: Variant = null
var _layout_top_bar_rect := TOP_BAR_RECT
var _layout_enemy_panel_rect := ENEMY_PANEL_RECT
var _layout_combat_strip_rect := COMBAT_STRIP_RECT
var _layout_board_panel_rect := BOARD_PANEL_RECT
var _layout_player_hud_section_rect := Rect2(Vector2(0, 1092), Vector2(1080, 828))
var _flow_trace_route_id := ""


func _enter_tree() -> void:
	_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"combat_scene_load",
			"res://scenes/combat/combat_player.tscn",
			{"source": "combat_player_controller._enter_tree"}
		)
	RunState.flow_trace_mark("combat_enter_tree", {}, _flow_trace_route_id)


func _ready() -> void:
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"combat_scene_load",
			"res://scenes/combat/combat_player.tscn",
			{"source": "combat_player_controller._ready"}
		)
	RunState.flow_trace_mark("combat_ready_start", {}, _flow_trace_route_id)
	_audio_play_music("combat")
	RunState.flow_trace_mark("combat_after_music", {}, _flow_trace_route_id)
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	if _player_loadout_hud == null:
		_player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
	_player_loadout_hud.set_visual_registry(_visuals)
	if _outcome_overlay == null:
		_outcome_overlay = COMBAT_OUTCOME_OVERLAY_SCRIPT.new()
	if _turn_logger == null:
		_turn_logger = COMBAT_TURN_LOGGER_SCRIPT.new()
	if _debug_console == null:
		_debug_console = COMBAT_DEBUG_CONSOLE_SCRIPT.new()
	if _combat_vfx_manager == null:
		_combat_vfx_manager = COMBAT_VFX_MANAGER_SCRIPT.new()
	if _board_drag_input_handler == null:
		_board_drag_input_handler = BOARD_DRAG_INPUT_HANDLER_SCRIPT.new()
	_bind_outcome_overlay()
	if _resolve_presenter == null:
		_resolve_presenter = COMBAT_RESOLVE_PRESENTER_SCRIPT.new()
	_resolve_presenter.bind({
		"board_surface": _board_surface,
		"board_view": _board_view,
		"board_panel": _board_panel,
		"timer_owner": self,
		"spawn_vfx_texture_callback": Callable(self, "_spawn_vfx_texture"),
		"combo_sound_callback": Callable(self, "_on_presenter_combo_sound"),
	})
	_resolve_presenter.set_combat_speed(_combat_speed)
	_debug_console.bind(
		{
			"combat_log_text": _combat_log_text,
			"console_input": _console_input,
		},
		{
			"command_output_log_color": COMMAND_OUTPUT_LOG_COLOR,
			"max_combat_log_lines": MAX_COMBAT_LOG_LINES,
			"initial_log_level": LOG_LEVEL_NORMAL,
			"turn_logger": _turn_logger,
			"callbacks": {
				"set_status_text": Callable(self, "_console_set_status_text"),
				"state_snapshot_data": Callable(self, "_console_state_snapshot_data"),
				"skip_to_fight": Callable(self, "_console_skip_to_fight"),
				"board_print_data": Callable(self, "_console_board_print_data"),
				"board_reroll": Callable(self, "_console_board_reroll"),
				"board_seed": Callable(self, "_console_board_seed"),
				"gold_add": Callable(self, "_console_gold_add"),
				"gold_set": Callable(self, "_console_gold_set"),
				"mastery_add": Callable(self, "_console_mastery_add"),
				"mastery_list": Callable(self, "_console_mastery_list"),
				"consumable_add": Callable(self, "_console_consumable_add"),
				"consumable_list": Callable(self, "_console_consumable_list"),
				"equipment_list": Callable(self, "_console_equipment_list"),
				"equipment_details": Callable(self, "_console_equipment_details"),
				"equipment_add": Callable(self, "_console_equipment_add"),
				"relic_list": Callable(self, "_console_relic_list"),
				"relic_details": Callable(self, "_console_relic_details"),
				"relic_add": Callable(self, "_console_relic_add"),
				"fight_win": Callable(self, "_console_fight_win"),
				"fight_lose": Callable(self, "_console_fight_lose"),
			},
		}
	)
	_consumable_rng.randomize()
	_background.texture = null
	_background.modulate = Color(0.16, 0.17, 0.20, 1.0)
	RunState.flow_trace_mark("combat_texture_map_deferred", {}, _flow_trace_route_id)
	_ensure_boss_reward_controls()
	_ensure_outcome_overlay_layer()
	RunState.flow_trace_mark("combat_after_boss_outcome_controls", {}, _flow_trace_route_id)
	_adopt_relic_footer_nodes_for_shared_layout()
	_player_loadout_hud.bind_player_hud(_combat_player_hud_nodes().merged({
		"popover_parent": _layout_root,
		"popover_z_index": 210,
	}, true))
	_bind_combat_vfx_manager()
	_bind_combat_layout_manager()
	_bind_board_drag_input_handler()
	RunState.flow_trace_mark("combat_after_hud_bind", {}, _flow_trace_route_id)
	_apply_visual_chrome()
	RunState.flow_trace_mark("combat_after_chrome", {}, _flow_trace_route_id)
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_player_loadout_hud.consumable_slot_selected.connect(_try_use_consumable_slot)
	_player_loadout_hud.sell_slot_requested.connect(_on_player_hud_sell_slot_requested)
	_initialize_combat_state()
	RunState.flow_trace_mark("combat_after_initialize_state", {}, _flow_trace_route_id)
	_create_new_board()
	RunState.flow_trace_mark("combat_after_board_create", {}, _flow_trace_route_id)
	_board_view.gui_input.connect(_on_board_view_gui_input)
	_debug_overlay.visible = false
	if _console_input.visible:
		_console_input.text_submitted.connect(_on_console_input_text_submitted)
	_debug_console.set_overlay_visible(false)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_vfx_layer.visible = true
	set_process(true)
	_apply_combat_layout()
	RunState.flow_trace_mark("combat_after_layout", {}, _flow_trace_route_id)
	_begin_turn_preview()
	RunState.flow_trace_mark("combat_after_begin_turn_preview", {}, _flow_trace_route_id)
	call_deferred("_trace_flow_first_usable_frame")
	call_deferred("_apply_orb_texture_map_deferred")


func _trace_flow_first_usable_frame() -> void:
	RunState.flow_trace_mark(
		"combat_first_usable_frame",
		{"source": "combat_player_controller._ready_deferred"},
		_flow_trace_route_id
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
	RunState.flow_trace_mark("combat_after_texture_map", {}, _flow_trace_route_id)


func _bind_combat_layout_manager() -> void:
	if _combat_layout_manager == null:
		_combat_layout_manager = COMBAT_LAYOUT_MANAGER_SCRIPT.new()
	_combat_layout_manager.bind({
		"layout_root": _layout_root,
		"top_bar": _top_bar,
		"enemy_panel": _enemy_panel,
		"enemy_panel_root": _enemy_panel_root,
		"intent_row": _intent_row,
		"enemy_stage": _enemy_stage,
		"enemy_hp_row": _enemy_hp_row,
		"intent_badge": _intent_badge,
		"enemy_portrait": _enemy_portrait,
		"enemy_hp_bar": _enemy_hp_bar,
		"enemy_label": _enemy_label,
		"combat_strip": _combat_strip,
		"timer_track": _timer_track,
		"timer_icon": _timer_icon,
		"board_panel": _board_panel,
		"board_surface": _board_surface,
		"board_view_control": _board_view_control,
		"board_shadow": _board_shadow,
		"player_loadout_hud": _player_loadout_hud,
		"equipment_icons": _equipment_icons,
		"consumable_icons": _consumable_icons,
		"stat_chip_row": _stat_chip_row,
		"combat_meta_row": _combat_meta_row,
		"turn_summary_label": _turn_summary_label,
		"mastery_root": _mastery_root,
		"hero_level_badge": _hero_level_badge,
		"player_armor_bar": _player_armor_bar,
		"player_armor_label": _player_armor_label,
		"mastery_strip": _mastery_strip,
		"player_portrait": _player_portrait,
		"relic_row": _relic_row,
		"debug_overlay": _debug_overlay,
		"outcome_overlay": _outcome_overlay,
	})


func _bind_combat_vfx_manager() -> void:
	if _combat_vfx_manager == null:
		return
	_combat_vfx_manager.bind({
		"vfx_layer": _vfx_layer,
		"visual_registry": _visuals,
		"player_loadout_hud": _player_loadout_hud,
		"elemental_mastery_cards": _elemental_mastery_cards,
		"timer_owner": self,
	})


func _bind_board_drag_input_handler() -> void:
	if _board_drag_input_handler == null:
		return
	_board_drag_input_handler.bind(
		{
			"board_view": _board_view,
			"board_state": _board_state,
		},
		{
			"swap_animation_seconds": SWAP_ANIMATION_SECONDS,
			"swap_sound_callback": Callable(self, "_on_drag_swap_success"),
			"match_groups_callback": Callable(self, "_drag_match_groups"),
			"move_timer_seconds_callback": Callable(self, "_drag_move_timer_seconds"),
		}
	)


func _on_drag_swap_success() -> void:
	_audio_play_sfx("swap")


func _drag_match_groups() -> Array:
	if _resolver == null or _board_state == null:
		return []
	return _resolver.get_match_groups(_board_state)


func _drag_move_timer_seconds() -> float:
	if _player_state == null:
		return MOVE_TIMER_MAX_SECONDS
	return _player_state.move_timer_seconds


func _drag_active() -> bool:
	return _board_drag_input_handler != null and bool(_board_drag_input_handler.active_drag())


func _drag_move_time_left() -> float:
	if _board_drag_input_handler == null:
		return 0.0
	return float(_board_drag_input_handler.move_time_left())


func _apply_visual_chrome() -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_visual_chrome(
		{
			"board_view": _board_view,
			"top_bar": _top_bar,
			"enemy_panel": _enemy_panel,
			"combat_strip": _combat_strip,
			"board_frame": _board_frame,
			"debug_overlay": _debug_overlay,
			"combat_log_frame": _combat_log_frame,
			"enemy_hp_bar": _enemy_hp_bar,
			"player_hp_bar": _player_hp_bar,
			"player_armor_bar": _player_armor_bar,
			"title_label": _title_label,
			"hint_label": _hint_label,
			"timer_label": _timer_label,
			"run_progress_label": _run_progress_label,
			"phase_label": _phase_label,
			"turn_summary_label": _turn_summary_label,
			"player_label": _player_label,
			"player_armor_label": _player_armor_label,
			"attack_stat_label": _attack_stat_label,
			"armor_stat_label": _armor_stat_label,
			"heart_stat_label": _heart_stat_label,
			"gold_stat_label": _gold_stat_label,
			"enemy_label": _enemy_label,
			"intent_label": _intent_label,
			"equipment_row_label": _equipment_row_label,
			"consumable_row_label": _consumable_row_label,
			"relic_row_label": _relic_row_label,
			"mastery_row_label": _mastery_row_label,
			"armor_badge_label": _armor_badge_label,
			"timer_state_label": _timer_state_label,
			"back_button": _back_button,
			"debug_toggle_button": _debug_toggle_button,
			"settings_button": _settings_button,
			"next_button": _next_button,
			"timer_track": _timer_track,
			"loadout_frame": _loadout_frame,
			"mastery_strip": _mastery_strip,
			"hero_card": _hero_card,
			"vitals_frame": _vitals_frame,
			"hero_level_badge": _hero_level_badge,
			"armor_badge": _armor_badge,
			"board_shadow": _board_shadow,
			"outcome_summary_panel": _outcome_summary_panel,
			"outcome_title_label": _outcome_title_label,
			"outcome_body_label": _outcome_body_label,
			"status_label": _status_label,
			"enemy_debug_label": _enemy_debug_label,
			"combat_log_text": _combat_log_text,
			"debug_console": _debug_console,
			"player_loadout_hud": _player_loadout_hud,
			"player_hud_nodes": _combat_player_hud_nodes(),
		},
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

	_player_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ensure_placeholder_visuals()
	_apply_zone_guides()
	_title_label.text = RunState.level_sequence_label()
	_hint_label.text = "Gold 0"


func _initialize_combat_state() -> void:
	if not RunState.run_active:
		RunState.flow_trace_mark(
			"combat_initialize_no_active_run_starting_new",
			{},
			_flow_trace_route_id
		)
		RunState.start_new_run()
	if RunState.is_current_step_boss_reward():
		_player_state = RunState.ensure_player_state()
		_progression_state = RunState.ensure_player_progression_state()
		var preview: Dictionary = RunState.current_level_boss_preview()
		_enemy_state = ENEMY_STATE_SCRIPT.new()
		_enemy_state.configure_from_blueprint(preview)
		_combat = null
		_outcome_transition_queued = false
		_pending_next_scene_path = ""
		_hide_outcome_summary()
		_refresh_character_portraits()
		_refresh_build_icon_rows(_progression_state.to_snapshot())
		_show_boss_reward_summary("Boss defeated.")
		_status_label.text = "Boss defeated. Choose a boss relic or skip before continuing."
		_status_label.modulate = STATUS_COLOR_WARNING
		RunState.flow_trace_mark("combat_initialize_boss_reward_overlay", {}, _flow_trace_route_id)
		return
	if not RunState.is_current_step_fight():
		var redirect_scene := RunState.next_scene_path()
		if redirect_scene != "":
			RunState.flow_trace_mark(
				"combat_initialize_redirect_before_change_scene",
				{"source": "_initialize_combat_state"},
				_flow_trace_route_id,
				redirect_scene
			)
			var change_result: Variant = RunState.flow_trace_change_scene(
				get_tree(),
				redirect_scene,
				_flow_trace_route_id,
				"combat_player_controller._initialize_combat_state"
			)
			if not _scene_change_succeeded(change_result):
				push_error("Combat initialize redirect failed: %s" % _scene_change_failure_reason(change_result))
		return

	_player_state = RunState.ensure_player_state()
	_progression_state = RunState.ensure_player_progression_state()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	_enemy_state = ENEMY_STATE_SCRIPT.new()
	_enemy_state.configure_from_blueprint(encounter)
	_refresh_character_portraits()
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_outcome_transition_queued = false
	_pending_next_scene_path = ""
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

	_combat.phase = COMBAT_PHASE_INTENT_PREVIEW
	_combat.begin_player_input()
	_set_input_phase(InputPhase.PLAYER_INPUT)
	_pending_next_scene_path = ""
	_hide_outcome_summary()
	_turn_summary_label.text = "Turn Summary: Awaiting move."
	_status_label.text = "%s | Turn %d." % [
		RunState.level_sequence_label(),
		_combat.turn_index,
	]
	_status_label.modulate = STATUS_COLOR_NEUTRAL
	_update_hud()
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
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F2:
			_zone_guides_enabled = not _zone_guides_enabled
			_apply_zone_guides()
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_R:
			_create_new_board()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_P:
			_print_board_state()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_C:
			_try_use_first_consumable()
			get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _player_loadout_hud.handle_global_click((event as InputEventMouseButton).position):
			get_viewport().set_input_as_handled()


func _on_debug_toggle_button_pressed() -> void:
	_toggle_debug_overlay()


func _toggle_debug_overlay() -> void:
	_debug_overlay.visible = not _debug_overlay.visible
	if _debug_console != null:
		_debug_console.set_overlay_visible(_debug_overlay.visible)


func _on_regenerate_button_pressed() -> void:
	_create_new_board()


func _on_print_board_button_pressed() -> void:
	_print_board_state()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


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
	if _input_phase != InputPhase.PLAYER_INPUT:
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
	_board_view.board_state = _board_state
	if _board_drag_input_handler != null:
		_board_drag_input_handler.refresh_match_glow()
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
		total_converted += _convert_random_non_target_orbs(target_orb_id, count)
	return total_converted


func _convert_random_non_target_orbs(target_orb_id: int, count: int) -> int:
	if count <= 0 or not OrbType.is_valid_id(target_orb_id):
		return 0

	var candidates: Array[Vector2i] = []
	for row in BoardState.ROW_COUNT:
		for column in BoardState.COLUMN_COUNT:
			var orb_id := _board_state.get_cell(column, row)
			if orb_id == target_orb_id:
				continue
			candidates.append(Vector2i(column, row))
	if candidates.is_empty():
		return 0

	var converted := 0
	var picks := mini(count, candidates.size())
	for _i in picks:
		var pick_index := _consumable_rng.randi_range(0, candidates.size() - 1)
		var cell := candidates[pick_index]
		_board_state.set_cell(cell.x, cell.y, target_orb_id)
		candidates.remove_at(pick_index)
		converted += 1
	return converted


func _process(delta: float) -> void:
	if _player_state == null:
		return
	if _board_drag_input_handler == null:
		return
	if not _drag_active():
		if _input_phase == InputPhase.PLAYER_INPUT:
			_sync_timer_display(_timer_ready_seconds(), TIMER_STATE_READY)
		else:
			_sync_timer_display(0.0, TIMER_STATE_LOCKED)
		return

	var drag_update: Dictionary = _board_drag_input_handler.update(
		delta,
		_input_phase == InputPhase.PLAYER_INPUT
	)
	_sync_timer_display(_drag_move_time_left(), TIMER_STATE_ACTIVE)
	_handle_drag_input_result(drag_update)


func _handle_pointer_input(event: InputEvent) -> bool:
	if _board_drag_input_handler == null:
		return false
	var drag_result: Dictionary = _board_drag_input_handler.handle_pointer_input(
		event,
		_input_phase == InputPhase.PLAYER_INPUT
	)
	_handle_drag_input_result(drag_result)
	return bool(drag_result.get("handled", false))


func _on_board_view_gui_input(event: InputEvent) -> void:
	if _handle_pointer_input(event):
		_board_view.accept_event()


func _handle_drag_input_result(result: Dictionary) -> void:
	if result.is_empty():
		return
	var action := String(result.get("action", ""))
	if action == "start":
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


func _print_board_state() -> void:
	var debug_text := _board_state.to_debug_string()
	print("\n[Board Debug] Seed=", _board_state.rng_seed)
	print(debug_text)
	_print_board_state_to_console()
	_status_label.text = "Printed board for seed %d to output." % _board_state.rng_seed


func _set_board_seed(board_seed: int) -> void:
	if _board_drag_input_handler != null:
		_board_drag_input_handler.abort()
	_board_view.clear_animations()
	_board_state.initialize(board_seed, _settings)
	if _board_drag_input_handler != null:
		_board_drag_input_handler.set_board_state(_board_state)
	_board_view.board_state = _board_state
	if _combat != null and not _combat.is_fight_over():
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _print_board_state_to_console() -> void:
	_append_combat_log("Board seed: %d" % _board_state.rng_seed)
	var lines: PackedStringArray = _board_state.to_debug_string().split("\n", false)
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
		intent_text = _turn_logger.format_intent(_enemy_state.get_current_intent())
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
			"input_phase": _input_phase,
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
	if _board_drag_input_handler != null:
		_board_drag_input_handler.abort()
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
	return {
		"seed": _board_state.rng_seed,
		"debug_text": _board_state.to_debug_string(),
	}


func _console_board_reroll() -> Dictionary:
	_create_new_board()
	return {
		"seed": _board_state.rng_seed,
	}


func _console_board_seed(board_seed: int) -> Dictionary:
	_set_board_seed(board_seed)
	return {
		"ok": true,
		"seed": _board_state.rng_seed,
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
	_pending_next_scene_path = String(win_transition.get("next_scene", "res://scenes/main.tscn"))
	_update_hud()
	_show_outcome_summary("Victory", _build_run_outcome_summary("Debug command."), true)
	_status_label.text = "Debug victory queued. Press Continue."
	return {"ok": true}


func _console_fight_lose() -> Dictionary:
	var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
	_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	_pending_next_scene_path = String(lose_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY))
	_update_hud()
	_show_outcome_summary("Defeat", _build_run_outcome_summary("Debug command."), true, "Run Summary")
	_status_label.text = "Debug defeat queued. Run Summary available."
	return {"ok": true}


func _end_drag(timed_out: bool) -> void:
	if _board_drag_input_handler == null:
		return

	_sync_timer_display(0.0, TIMER_STATE_LOCKED)
	var move_end_reason := "released"
	if timed_out:
		move_end_reason = "timer expired"
	_status_label.text = "Move ended: %s. Locking input for resolve phase." % move_end_reason
	_status_label.modulate = STATUS_COLOR_WARNING
	var resolve_trace_origin_usec := Time.get_ticks_usec()
	_resolve_trace_origin_usec = resolve_trace_origin_usec
	_resolve_trace_active = _resolve_trace_enabled()
	_resolve_trace_pass_index = -1
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=resolve_start move_end_reason=\"%s\" board_seed=%d" % [move_end_reason, _board_state.rng_seed]
	)

	_board_drag_input_handler.reset_visuals()
	_board_view.clear_animations()
	_set_input_phase(InputPhase.RESOLVING)
	_reset_combat_mastery_preview()
	var visual_board_state: BoardState = _board_state.clone()
	var simulation_board_state: BoardState = _board_state.clone()
	_board_view.board_state = visual_board_state
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=visual_state_ready board_seed=%d" % visual_board_state.rng_seed
	)
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=simulation_resolve_start board_seed=%d" % simulation_board_state.rng_seed
	)
	_last_resolve_result = _resolver.resolve_all(simulation_board_state)
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=simulation_resolve_complete total_combos=%d passes=%d" % [
			int(_last_resolve_result.get("total_combos", 0)),
			Array(_last_resolve_result.get("passes", [])).size(),
		]
	)
	await _play_resolve_animations(_last_resolve_result, visual_board_state, resolve_trace_origin_usec)
	if not _can_continue_after_async_wait(true):
		_resolve_trace_active = false
		_resolve_trace_pass_index = -1
		return
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=resolve_presentation_complete total_combos=%d passes=%d" % [
			int(_last_resolve_result.get("total_combos", 0)),
			Array(_last_resolve_result.get("passes", [])).size(),
		]
	)
	_board_state = simulation_board_state
	_board_drag_input_handler.set_board_state(_board_state)
	_board_view.board_state = _board_state
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=final_board_commit board_seed=%d" % _board_state.rng_seed
	)
	if _input_phase == InputPhase.RESOLVING:
		await _resolve_combat_turn_from_board(_last_resolve_result)
		if not _can_continue_after_async_wait():
			_resolve_trace_active = false
			_resolve_trace_pass_index = -1
			return
	_resolve_trace_active = false
	_resolve_trace_pass_index = -1


func _resolve_combat_turn_from_board(resolve_result: Dictionary) -> void:
	if _combat == null:
		return
	var turn_log: Dictionary = _combat.resolve_player_turn(resolve_result)
	_update_hud()
	_sync_combat_mastery_preview_totals()
	RunState.flow_trace_mark(
		"combat_before_replay_turn_resolution_from_log",
		{
			"total_combos": int(resolve_result.get("total_combos", 0)),
			"enemy_damage_taken": int(turn_log.get("enemy_damage_taken", 0)),
		},
		_flow_trace_route_id
	)
	await _replay_turn_resolution_from_log(turn_log)
	if not _can_continue_after_async_wait():
		return
	RunState.flow_trace_mark(
		"combat_after_replay_turn_resolution_from_log",
		{
			"healed": int(turn_log.get("healed", 0)),
			"armor_gained": int(turn_log.get("armor_gained", 0)),
			"gold_gained": int(turn_log.get("gold_gained", 0)),
		},
		_flow_trace_route_id
	)

	if _combat.phase == COMBAT_PHASE_VICTORY:
		_audio_play_sfx("victory")
		RunState.flow_trace_mark("combat_before_mark_fight_victory", {}, _flow_trace_route_id)
		var transition: Dictionary = RunState.mark_fight_victory()
		RunState.flow_trace_mark(
			"combat_after_mark_fight_victory",
			{
				"next_scene": String(transition.get("next_scene", "")),
				"step": String(transition.get("step", "")),
			},
			_flow_trace_route_id,
			String(transition.get("next_scene", ""))
		)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_append_turn_log(turn_log)
		if RunState.is_current_step_boss_reward():
			_pending_next_scene_path = ""
			_status_label.text = "Boss defeated. Choose a boss relic or skip before continuing."
			_append_combat_log("Outcome: Boss victory. Waiting for boss relic selection in victory overlay.")
			_show_boss_reward_summary(_turn_logger.build_victory_gold_summary(turn_log))
			_turn_summary_label.text = "Turn Summary: Boss victory. Choose a relic."
			RunState.flow_trace_mark("combat_boss_reward_available", {}, _flow_trace_route_id)
		else:
			var next_scene := String(transition.get("next_scene", "res://scenes/main.tscn"))
			if next_scene.find("run_summary") >= 0:
				_append_combat_log("Outcome: Final boss victory. Opening run summary.")
				_hide_outcome_summary()
				RunState.flow_trace_mark(
					"combat_before_final_summary_change_scene",
					{},
					_flow_trace_route_id,
					next_scene
				)
				RunState.call_deferred(
					"flow_trace_change_scene",
					get_tree(),
					next_scene,
					_flow_trace_route_id,
					"combat_final_summary_auto"
				)
				return
			_status_label.text = _turn_logger.build_victory_status(turn_log, transition) + " Press Continue."
			_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
			_pending_next_scene_path = next_scene
			_show_outcome_summary("Victory", _turn_logger.build_victory_gold_summary(turn_log), true)
			_turn_summary_label.text = "Turn Summary: Victory. Press Continue."
			RunState.flow_trace_mark(
				"combat_continue_available",
				{"button_text": "Continue"},
				_flow_trace_route_id,
				next_scene
			)
		_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		_audio_play_sfx("defeat")
		var defeat_cause := _turn_logger.build_defeat_cause(String(_enemy_state.display_name if _enemy_state != null else "Enemy"), turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _turn_logger.build_defeat_status(turn_log) + " Run Summary available."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Waiting for Run Summary button.")
		_pending_next_scene_path = String(defeat_transition.get("next_scene", RunState.SCENE_RUN_SUMMARY))
		_show_outcome_summary("Defeat", _build_run_outcome_summary(defeat_cause), true, "Run Summary")
		_turn_summary_label.text = "Turn Summary: Defeat. Run Summary available."
		RunState.flow_trace_mark(
			"combat_continue_available",
			{"button_text": "Run Summary"},
			_flow_trace_route_id,
			_pending_next_scene_path
		)
		_pulse_label(_turn_summary_label, STATUS_COLOR_NEGATIVE)
		return

	_status_label.text = _turn_logger.build_turn_summary_status(turn_log)
	_play_turn_result_sfx(turn_log)
	_status_label.modulate = STATUS_COLOR_POSITIVE
	_turn_summary_label.text = "Turn Summary: %s" % _turn_logger.build_turn_summary_status(turn_log)
	_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
	_append_turn_log(turn_log)
	_begin_turn_preview()


func _on_next_button_pressed() -> void:
	if _outcome_overlay != null and _outcome_overlay.is_boss_reward_pending():
		_audio_play_sfx("error")
		_status_label.text = "Choose a boss relic or skip the reward before continuing."
		return
	if _pending_next_scene_path == "":
		return
	RunState.flow_trace_mark(
		"combat_next_button_pressed",
		{"button_text": _next_button.text},
		_flow_trace_route_id,
		_pending_next_scene_path
	)
	_audio_play_sfx("ui_accept")
	var target_scene := _pending_next_scene_path
	_pending_next_scene_path = ""
	_hide_outcome_summary()
	var transition_route_id := _flow_trace_route_id
	if target_scene.find("shop_player.tscn") >= 0:
		transition_route_id = RunState.flow_trace_begin(
			"combat_to_shop",
			target_scene,
			{"source": "combat_next_button"}
		)
	RunState.flow_trace_mark(
		"combat_before_change_scene_to_file",
		{"source": "combat_next_button"},
		transition_route_id,
		target_scene
	)
	RunState.flow_trace_change_scene(
		get_tree(),
		target_scene,
		transition_route_id,
		"combat_next_button"
	)


func _play_turn_result_sfx(turn_log: Dictionary) -> void:
	if int(turn_log.get("enemy_damage_taken", 0)) > 0:
		_audio_play_sfx("hit")
	if int(turn_log.get("healed", 0)) > 0:
		_audio_play_sfx("heal")
	if int(turn_log.get("armor_gained", 0)) > 0:
		_audio_play_sfx("armor")
	if int(turn_log.get("gold_gained", 0)) > 0:
		_audio_play_sfx("gold")
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if int(enemy_attack.get("hp_damage", 0)) > 0:
		_audio_play_sfx("hit")


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	var audio := get_node_or_null("/root/AudioManager")
	if audio != null:
		return audio
	var script: GDScript = load("res://scripts/core/audio_manager.gd")
	if script == null:
		return null
	audio = script.new()
	audio.name = "AudioManager"
	get_tree().root.add_child(audio)
	return audio


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
	_pending_next_scene_path = ""
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
	var next_scene := String(transition.get("next_scene", "res://scenes/main.tscn"))
	var route_id := _flow_trace_route_id
	if next_scene.find("shop_player.tscn") >= 0:
		route_id = RunState.flow_trace_begin(
			"combat_to_shop",
			next_scene,
			{
				"source": "boss_reward_claim",
				"option_index": index,
			}
		)
	RunState.flow_trace_mark(
		"combat_before_change_scene_to_file_boss_reward_claim",
		{"source": "boss_reward_claim"},
		route_id,
		next_scene
	)
	RunState.flow_trace_change_scene(
		get_tree(),
		next_scene,
		route_id,
		"boss_reward_claim"
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
	var next_scene := String(transition.get("next_scene", "res://scenes/main.tscn"))
	var route_id := _flow_trace_route_id
	if next_scene.find("shop_player.tscn") >= 0:
		route_id = RunState.flow_trace_begin(
			"combat_to_shop",
			next_scene,
			{"source": "boss_reward_skip"}
		)
	RunState.flow_trace_mark(
		"combat_before_change_scene_to_file_boss_reward_skip",
		{"source": "boss_reward_skip"},
		route_id,
		next_scene
	)
	RunState.flow_trace_change_scene(
		get_tree(),
		next_scene,
		route_id,
		"boss_reward_skip"
	)


func _ensure_outcome_overlay_layer() -> void:
	if _outcome_overlay == null:
		return
	_outcome_overlay.ensure_overlay_layer()


func _queue_outcome_transition(scene_path: String) -> void:
	if _outcome_transition_queued:
		return
	_outcome_transition_queued = true
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		get_tree().change_scene_to_file(scene_path)


func set_external_input_locked(locked: bool, reason: String = "") -> void:
	_external_lock_reason = reason
	if locked:
		if _drag_active():
			_abort_active_drag()
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
	else:
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _set_input_phase(phase: InputPhase) -> void:
	_input_phase = phase

	match _input_phase:
		InputPhase.PLAYER_INPUT:
			_board_view.mouse_filter = Control.MOUSE_FILTER_STOP
		InputPhase.RESOLVING:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		InputPhase.LOCKED_EXTERNAL:
			_board_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if _external_lock_reason != "":
				_status_label.text = "Input locked: %s" % _external_lock_reason


func _sync_timer_display(seconds_left: float, state: String) -> void:
	var clamped_seconds := clampf(seconds_left, 0.0, MOVE_TIMER_MAX_SECONDS)
	var time_ratio := 0.0
	if MOVE_TIMER_MAX_SECONDS > 0.0:
		time_ratio = clamped_seconds / MOVE_TIMER_MAX_SECONDS

	var label_text := "READY"
	var state_text := "READY"
	var timer_color := TIMER_READY_COLOR
	var text_color := TIMER_TEXT_COLOR
	var fill_ratio := 1.0
	var text_alpha := 1.0
	if state == TIMER_STATE_ACTIVE:
		fill_ratio = time_ratio
		state_text = "MOVE"
		if clamped_seconds > 0.0 and clamped_seconds < TIMER_WARNING_SECONDS:
			label_text = "%.1f SEC" % clamped_seconds
		else:
			label_text = "%d SEC" % int(ceil(clamped_seconds))
		timer_color = TIMER_SAFE_COLOR
		if clamped_seconds <= TIMER_CRITICAL_SECONDS:
			state_text = "CRIT"
			var blink := 0.70 + 0.30 * sin(Time.get_ticks_msec() * 0.024)
			timer_color = TIMER_CRITICAL_COLOR.lerp(Color(1.0, 1.0, 1.0, 1.0), blink)
			text_color = TIMER_TEXT_CRITICAL_COLOR
			text_alpha = blink
		elif clamped_seconds <= TIMER_WARNING_SECONDS:
			state_text = "WARN"
			var warning_t := inverse_lerp(TIMER_WARNING_SECONDS, TIMER_CRITICAL_SECONDS, clamped_seconds)
			timer_color = TIMER_WARNING_COLOR.lerp(TIMER_CRITICAL_COLOR, warning_t)
			text_color = TIMER_TEXT_WARNING_COLOR
	else:
		if state == TIMER_STATE_LOCKED:
			label_text = "LOCK"
			state_text = ""
			timer_color = TIMER_LOCKED_COLOR
			text_color = TIMER_TEXT_LOCKED_COLOR
			fill_ratio = 0.0
			text_alpha = 0.72

	var track_size := _timer_track.size
	if track_size.x <= 0.0 or track_size.y <= 0.0:
		track_size = TIMER_TRACK_SIZE
	var fill_width := maxf(0.0, (track_size.x - TIMER_TRACK_PADDING * 2.0) * fill_ratio)
	_timer_fill.position = Vector2(TIMER_TRACK_PADDING, TIMER_TRACK_PADDING)
	_timer_fill.size = Vector2(fill_width, maxf(0.0, track_size.y - TIMER_TRACK_PADDING * 2.0))
	_timer_fill.color = Color(timer_color.r, timer_color.g, timer_color.b, 0.72)
	_timer_label.text = label_text
	_timer_state_label.text = state_text
	var final_text_color := Color(text_color.r, text_color.g, text_color.b, text_alpha)
	_timer_label.add_theme_color_override("font_color", final_text_color)
	_timer_state_label.add_theme_color_override("font_color", final_text_color)
	_timer_icon.modulate = final_text_color


func _timer_ready_seconds() -> float:
	if _player_state == null:
		return MOVE_TIMER_MAX_SECONDS
	return _player_state.move_timer_seconds


func _abort_active_drag() -> void:
	if _board_drag_input_handler != null:
		_board_drag_input_handler.abort()
	_sync_timer_display(0.0, TIMER_STATE_LOCKED)


func _play_resolve_animations(
	result: Dictionary,
	visual_board_state: BoardState = null,
	resolve_trace_origin_usec: int = 0
) -> void:
	if result.total_combos <= 0 or _resolve_presenter == null:
		return
	await _resolve_presenter.play_resolve_animations(
		result,
		visual_board_state,
		resolve_trace_origin_usec,
		{
			"trace_callback": Callable(self, "_resolve_trace"),
			"combo_preview_callback": Callable(self, "_on_resolve_presenter_combo_preview"),
			"combo_feedback_callback": Callable(self, "_on_resolve_presenter_combo_feedback"),
			"set_pass_index_callback": Callable(self, "_on_resolve_presenter_pass_index"),
		}
	)


func _trigger_match_mastery_feedback(group: Dictionary, combo_value: int) -> void:
	_show_match_mastery_feedback(group, combo_value)


func _on_resolve_presenter_combo_preview(group: Dictionary, combo_value: int) -> int:
	return _preview_match_feedback_value(group, combo_value)


func _on_resolve_presenter_combo_feedback(group: Dictionary, combo_value: int) -> void:
	_trigger_match_mastery_feedback(group, combo_value)


func _on_resolve_presenter_pass_index(pass_index: int) -> void:
	_resolve_trace_pass_index = pass_index


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
	var tree := get_tree()
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
	var current_total := int(_combat_mastery_preview_totals.get(orb_id, 0))
	var next_total := current_total + amount
	_combat_mastery_preview_totals[orb_id] = next_total
	_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, orb_id, next_total)


func _reset_combat_mastery_preview() -> void:
	_combat_mastery_feedback_token += 1
	_combat_mastery_preview_totals.clear()
	if _elemental_mastery_cards != null:
		_player_loadout_hud.clear_combat_mastery_feedback(_elemental_mastery_cards)


func _sync_combat_mastery_preview_totals() -> void:
	if _elemental_mastery_cards == null:
		return
	for orb_id in OrbType.ALL_TYPES:
		var total := int(_combat_mastery_preview_totals.get(int(orb_id), 0))
		_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, int(orb_id), total)


func _release_combat_mastery_feedback(orb_id: int) -> void:
	if _elemental_mastery_cards == null or not OrbType.is_valid_id(orb_id):
		return
	_combat_mastery_preview_totals.erase(orb_id)
	_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, orb_id, 0)


func _release_remaining_combat_mastery_feedback() -> void:
	for orb_id in OrbType.ALL_TYPES:
		if int(_combat_mastery_preview_totals.get(int(orb_id), 0)) <= 0:
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
	return _turn_logger.build_turn_summary_status(turn_log)


func _build_victory_status(turn_log: Dictionary, transition: Dictionary) -> String:
	return _turn_logger.build_victory_status(turn_log, transition)


func _build_victory_gold_summary(turn_log: Dictionary) -> String:
	return _turn_logger.build_victory_gold_summary(turn_log)


func _build_run_outcome_summary(fallback_cause: String = "") -> String:
	var summary: Dictionary = RunState.run_summary_snapshot()
	return _turn_logger.build_run_outcome_summary(summary, RunState.MAX_DUNGEON_LEVELS, fallback_cause)


func _build_defeat_status(turn_log: Dictionary) -> String:
	return _turn_logger.build_defeat_status(turn_log)


func _build_defeat_cause(turn_log: Dictionary) -> String:
	var enemy_label := String(_enemy_state.display_name if _enemy_state != null else "Enemy")
	return _turn_logger.build_defeat_cause(enemy_label, turn_log)


func _replay_turn_resolution_from_log(turn_log: Dictionary) -> void:
	var enemy_damage := int(turn_log.get("enemy_damage_taken", 0))
	var fire_damage := int(turn_log.get("fire_damage", 0))
	var ice_damage := int(turn_log.get("ice_damage", 0))
	var earth_damage := int(turn_log.get("earth_damage", 0))
	var heart_heal := int(turn_log.get("healed", 0))
	var armor_gain := int(turn_log.get("armor_gained", 0))
	var gold_gain := int(turn_log.get("gold_gained", 0))
	var enemy_target := _control_global_center(_enemy_portrait, 0.48)
	var player_target := _control_global_center(_player_portrait, 0.64)
	var enemy_impact_size := Vector2(84, 84)
	var player_impact_size := Vector2(84, 84)
	var gold_impact_size := Vector2(70, 70)
	var damage_lifetime := _combat_speed_duration(0.42)
	var player_lifetime := _combat_speed_duration(0.45)
	var gold_lifetime := _combat_speed_duration(0.55)

	if fire_damage > 0 or ice_damage > 0 or earth_damage > 0:
		if fire_damage > 0:
			_spawn_replay_impact(enemy_target, "fire", enemy_impact_size, damage_lifetime)
			_spawn_mastery_beam(OrbType.Id.FIRE, enemy_target, damage_lifetime)
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_release_combat_mastery_feedback(OrbType.Id.FIRE)
		if ice_damage > 0:
			_spawn_replay_impact(enemy_target, "ice", enemy_impact_size, damage_lifetime)
			_spawn_mastery_beam(OrbType.Id.ICE, enemy_target, damage_lifetime)
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_release_combat_mastery_feedback(OrbType.Id.ICE)
		if earth_damage > 0:
			_spawn_replay_impact(enemy_target, "earth", enemy_impact_size, damage_lifetime)
			_spawn_mastery_beam(OrbType.Id.EARTH, enemy_target, damage_lifetime)
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			if not _can_continue_after_async_wait():
				return
			_release_combat_mastery_feedback(OrbType.Id.EARTH)
	elif enemy_damage > 0:
		var impact_orb := _dominant_orb_for_matches(turn_log.get("matched_counts", {}))
		_spawn_replay_impact(enemy_target, _mastery_impact_kind(impact_orb), enemy_impact_size, damage_lifetime)
		_spawn_mastery_beam(impact_orb, enemy_target, damage_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_release_combat_mastery_feedback(impact_orb)

	if heart_heal > 0:
		_spawn_replay_impact(player_target, "heart", player_impact_size, player_lifetime)
		_spawn_mastery_beam(OrbType.Id.HEART, player_target, player_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_release_combat_mastery_feedback(OrbType.Id.HEART)

	if armor_gain > 0:
		_spawn_replay_impact(player_target, "armor", player_impact_size, player_lifetime)
		_spawn_mastery_beam(OrbType.Id.ARMOR, player_target, player_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_release_combat_mastery_feedback(OrbType.Id.ARMOR)

	if gold_gain > 0:
		_spawn_replay_impact(player_target, "gold", gold_impact_size, gold_lifetime)
		_spawn_mastery_beam(OrbType.Id.GOLD, player_target, gold_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		if not _can_continue_after_async_wait():
			return
		_release_combat_mastery_feedback(OrbType.Id.GOLD)
	await _release_remaining_combat_mastery_feedback()
	if not _can_continue_after_async_wait():
		return
	await _wait_combat_speed(TURN_REPLAY_FINAL_HOLD_SECONDS)
	if not _can_continue_after_async_wait():
		return
	_reset_combat_mastery_preview()


func _can_continue_after_async_wait(require_board_view: bool = false) -> bool:
	if not is_inside_tree():
		return false
	if get_tree() == null:
		return false
	if require_board_view and (_board_view == null or not is_instance_valid(_board_view)):
		return false
	return true


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	return int(result) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	return "error_code_%d" % int(result)


func _update_hud() -> void:
	if _player_state == null or _enemy_state == null or _combat == null:
		return

	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	_sync_top_hud()
	_sync_enemy_stage()
	_sync_tempo_row()
	_sync_player_strip(progression_snapshot)
	_sync_debug_overlay()


func _sync_top_hud() -> void:
	_title_label.text = RunState.level_sequence_label().replace(" | ", "  |  ")
	_hint_label.text = "Gold %d" % _player_state.gold


func _sync_enemy_stage() -> void:
	var intent := _enemy_state.get_current_intent()
	_intent_label.text = _format_intent_compact(intent)
	if _intent_badge.texture == null:
		_intent_badge.texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_intent_placeholder_texture()
	_intent_badge.visible = true
	var enemy_texture := _visuals.enemy_portrait(_enemy_state.enemy_id)
	_enemy_portrait.texture = enemy_texture if enemy_texture != null else COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.visible = true
	_enemy_hp_bar.max_value = float(maxi(1, _enemy_state.max_hp))
	_enemy_hp_bar.value = float(_enemy_state.current_hp)
	_enemy_label.text = "%s HP %d/%d  Block %d" % [
		_enemy_state.display_name,
		_enemy_state.current_hp,
		_enemy_state.max_hp,
		_enemy_state.current_turn_block,
	]


func _sync_tempo_row() -> void:
	_phase_label.text = "Turn %d  %s" % [int(_combat.turn_index), _combat.phase_name()]
	var timer_state := TIMER_STATE_READY if _input_phase == InputPhase.PLAYER_INPUT else TIMER_STATE_LOCKED
	if _drag_active():
		timer_state = TIMER_STATE_ACTIVE
	_sync_timer_display(_drag_move_time_left() if _drag_active() else _timer_ready_seconds(), timer_state)


func _sync_player_strip(progression_snapshot: Dictionary) -> void:
	_player_label.text = "HP %d / %d" % [
		_player_state.current_hp,
		_player_state.max_hp,
	]
	_player_hp_bar.max_value = float(maxi(1, _player_state.max_hp))
	_player_hp_bar.value = float(_player_state.current_hp)
	_player_armor_bar.max_value = float(maxi(30, _player_state.armor + 10))
	_player_armor_bar.value = float(maxi(0, _player_state.armor))
	_player_armor_label.text = "%d / %d" % [maxi(0, _player_state.armor), int(_player_armor_bar.max_value)]
	var armor_value := maxi(0, _player_state.armor)
	_armor_badge.visible = armor_value > 0
	_armor_badge_label.text = "BLOCK +%d" % armor_value
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	_attack_stat_label.text = "ATK  %d" % _player_state.orb_value(OrbType.Id.FIRE)
	_armor_stat_label.text = "ARM  %d" % _player_state.orb_value(OrbType.Id.ARMOR)
	_heart_stat_label.text = "HEART  %d%%" % (int(mastery_levels.get(OrbType.Id.HEART, 0)) * 5)
	_gold_stat_label.text = "GOLD  %d%%" % (int(mastery_levels.get(OrbType.Id.GOLD, 0)) * 5)
	_run_progress_label.text = ""
	_phase_label.text = ""
	_turn_summary_label.text = _turn_summary_label.text.substr(0, mini(70, _turn_summary_label.text.length()))
	_refresh_build_icon_rows(progression_snapshot)


func _sync_debug_overlay() -> void:
	_status_label.text = "%s | Turn %d." % [RunState.level_sequence_label(), _combat.turn_index]
	_enemy_debug_label.text = "%s HP %d/%d Block %d" % [
		_enemy_state.display_name,
		_enemy_state.current_hp,
		_enemy_state.max_hp,
		_enemy_state.current_turn_block,
	]


func _format_intent(intent: Dictionary) -> String:
	if _turn_logger != null:
		return _turn_logger.format_intent(intent)
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func _format_intent_compact(intent: Dictionary) -> String:
	if _turn_logger != null:
		return _turn_logger.format_intent_compact(intent)
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
	var lines := _turn_logger.build_turn_log_lines(turn_log, log_level, context)
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
	_player_loadout_hud.update_player_data({
		"player_state": _player_state,
		"progression": progression_snapshot,
		"hero_portrait": _visuals.hero_portrait(),
		"max_visible_relics": 2,
		"selectable_equipment": true,
		"selectable_consumables": true,
	})
	_apply_loadout_rail_layout()
	call_deferred("_apply_loadout_rail_layout")

	_relic_row.visible = false
	_mastery_strip.visible = false


func _emit_turn_feedback_vfx(_turn_log: Dictionary) -> void:
	pass


func _spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _combat_vfx_manager == null:
		return
	_combat_vfx_manager.spawn_vfx(effect_name, global_center, draw_size, lifetime, modulate_color)


func _spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _combat_vfx_manager == null:
		return
	_combat_vfx_manager.spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func _spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float) -> void:
	if _combat_vfx_manager == null:
		return
	_combat_vfx_manager.spawn_replay_impact(global_center, impact_kind, draw_size, lifetime)


func _mastery_impact_kind(orb_id: int) -> String:
	if _combat_vfx_manager != null:
		return String(_combat_vfx_manager.mastery_impact_kind(orb_id))
	match orb_id:
		OrbType.Id.HEART:
			return "heart"
		OrbType.Id.GOLD:
			return "gold"
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
	if _combat_vfx_manager != null:
		return _combat_vfx_manager.control_global_center(control, vertical_bias)
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0)
	)


func _spawn_mastery_beam(source_orb_or_node: Variant, target_or_start: Vector2, orb_or_target: Variant, lifetime: float = 0.42) -> void:
	if _combat_vfx_manager == null:
		return
	_combat_vfx_manager.spawn_mastery_beam(source_orb_or_node, target_or_start, orb_or_target, lifetime)


func _on_resolver_match_found(groups: Array) -> void:
	_audio_play_sfx("match")
	_status_label.text = "Matches found: %d group(s)." % groups.size()
	_status_label.modulate = STATUS_COLOR_WARNING


func _pulse_label(target: Label, tint: Color) -> void:
	target.modulate = tint
	var tween := create_tween()
	tween.tween_property(target, "modulate", STATUS_COLOR_NEUTRAL, 0.28)


func _on_viewport_size_changed() -> void:
	_apply_combat_layout()


func _apply_combat_layout() -> void:
	if _combat_layout_manager == null:
		return
	var layout_result = _combat_layout_manager.apply_layout(get_viewport_rect().size)
	if not bool(layout_result.get("applied", false)):
		return
	_is_low_vertical_layout = bool(layout_result.get("is_low_vertical_layout", false))
	_layout_top_bar_rect = layout_result.get("layout_top_bar_rect", _layout_top_bar_rect)
	_layout_enemy_panel_rect = layout_result.get("layout_enemy_panel_rect", _layout_enemy_panel_rect)
	_layout_combat_strip_rect = layout_result.get("layout_combat_strip_rect", _layout_combat_strip_rect)
	_layout_board_panel_rect = layout_result.get("layout_board_panel_rect", _layout_board_panel_rect)
	_layout_player_hud_section_rect = layout_result.get("layout_player_hud_section_rect", _layout_player_hud_section_rect)
	_sync_timer_display(
		_drag_move_time_left() if _drag_active() else _timer_ready_seconds(),
		TIMER_STATE_ACTIVE if _drag_active() else TIMER_STATE_READY
	)


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
		"mastery_strip": _mastery_strip,
		"mastery_root": _mastery_root,
		"mastery_label": _mastery_row_label,
		"mastery_icons": _mastery_icons,
	}


func _adopt_relic_footer_nodes_for_shared_layout() -> void:
	if _loadout_root == null:
		return
	if _relic_row != null:
		_relic_row.visible = false
	if _relic_row_label != null and _relic_row_label.get_parent() != _loadout_root:
		var label_parent := _relic_row_label.get_parent()
		if label_parent != null:
			label_parent.remove_child(_relic_row_label)
		_loadout_root.add_child(_relic_row_label)
	if _relic_icons != null and _relic_icons.get_parent() != _loadout_root:
		var icons_parent := _relic_icons.get_parent()
		if icons_parent != null:
			icons_parent.remove_child(_relic_icons)
		_loadout_root.add_child(_relic_icons)


func _apply_loadout_rail_layout() -> void:
	if _combat_layout_manager != null:
		_combat_layout_manager.apply_loadout_rail_layout()
		return
	_player_loadout_hud.apply_loadout_rail_layout(_equipment_icons, EQUIPMENT_RAIL_RECT, _consumable_icons, CONSUMABLE_RAIL_RECT)


func _ensure_placeholder_visuals() -> void:
	if _timer_icon.texture == null:
		_timer_icon.texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_timer_placeholder_texture()
	_timer_icon.visible = true
	if _intent_badge.texture == null:
		_intent_badge.texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_intent_placeholder_texture()
	_intent_badge.visible = true
	var enemy_texture: Texture2D = null
	if _enemy_state != null:
		enemy_texture = _visuals.enemy_portrait(_enemy_state.enemy_id)
	if enemy_texture == null:
		enemy_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_texture
	_enemy_portrait.visible = true
	var hero_texture := _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture
	_player_portrait.visible = true


func _refresh_character_portraits() -> void:
	var enemy_texture: Texture2D = null
	if _enemy_state != null:
		enemy_texture = _visuals.enemy_portrait(_enemy_state.enemy_id)
	if enemy_texture == null:
		enemy_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_texture
	var hero_texture := _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture


func _apply_zone_guides() -> void:
	_set_zone_guide(_top_bar, "TopBar")
	_set_zone_guide(_enemy_panel, "EnemyPanel")
	_set_zone_guide(_combat_strip, "CombatStrip")
	_set_zone_guide(_board_panel, "BoardPanel")
	_set_zone_guide(_player_panel, "PlayerPanel")


func _set_zone_guide(zone: Control, label_text: String) -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_zone_guide(zone, label_text, _zone_guides_enabled)


func _on_resolver_cells_cleared(cells: Array) -> void:
	if not _resolve_trace_active:
		return
	_resolve_trace(
		_resolve_trace_origin_usec,
		"phase=clear_applied source=simulation_signal cells=%d" % cells.size()
	)


func _on_resolver_gravity_applied(fall_moves: Array) -> void:
	if not _resolve_trace_active:
		return
	_resolve_trace(
		_resolve_trace_origin_usec,
		"phase=gravity_applied source=simulation_signal moves=%d" % fall_moves.size()
	)


func _on_resolver_refill_applied(refill_spawns: Array) -> void:
	if not _resolve_trace_active:
		return
	_resolve_trace(
		_resolve_trace_origin_usec,
		"phase=refill_applied source=simulation_signal spawns=%d" % refill_spawns.size()
	)


func _on_resolver_cascade_step_complete(step_index: int, total_combos: int) -> void:
	if not _resolve_trace_active:
		return
	_resolve_trace(
		_resolve_trace_origin_usec,
		"phase=pass_complete source=simulation_signal step_index=%d total_combos=%d" % [
			step_index,
			total_combos,
		]
	)


func _on_resolver_complete(result: Dictionary) -> void:
	if not _resolve_trace_active:
		return
	_resolve_trace(
		_resolve_trace_origin_usec,
		"phase=simulation_resolve_complete source=signal total_combos=%d passes=%d" % [
			int(result.get("total_combos", 0)),
			Array(result.get("passes", [])).size(),
		]
	)
