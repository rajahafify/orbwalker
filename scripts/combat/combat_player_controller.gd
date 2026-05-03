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
var _active_drag := false
var _drag_touch_index: int = -1
var _drag_selected_orb_id: int = -1
var _drag_current_cell: Vector2i = Vector2i(-1, -1)
var _drag_path: Array[Vector2i] = []
var _move_time_left: float = 0.0
var _external_lock_reason := ""
var _last_resolve_result: Dictionary = {}
var _outcome_transition_queued := false
var _pending_next_scene_path := ""
var _combat_log_lines: Array[String] = []
var _combat_log_command_flags: Array[bool] = []
var _combat_log_level: String = LOG_LEVEL_NORMAL
var _consumable_rng := RandomNumberGenerator.new()
var _visuals: VisualRegistry = null
var _player_loadout_hud: PlayerLoadoutHud = null
var _outcome_overlay: CombatOutcomeOverlay = null
var _is_low_vertical_layout := false
var _zone_guides_enabled := false
var _resolve_combo_running := 0
var _resolve_trace_origin_usec := 0
var _resolve_trace_active := false
var _resolve_trace_pass_index := -1
var _combat_mastery_feedback_token := 0
var _combat_mastery_preview_totals: Dictionary = {}
var _match_clear_burst_texture: Texture2D
var _combo_popup_panel: PanelContainer
var _combo_popup_label: Label
var _combo_popup_fade_tween: Tween
var _combat_speed := COMBAT_SPEED_NORMAL
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
	_bind_outcome_overlay()
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
		_console_input.release_focus()
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


func _apply_visual_chrome() -> void:
	# Keep chrome code-driven to avoid any baked checkerboard artifacts from generated sheets.
	_board_view.cell_frame_texture = null
	_board_view.cell_spacing = 4.0
	_board_view.board_padding = 8.0
	_board_view.orb_scale_in_cell = 0.92
	_board_view.cell_background = Color(0.07, 0.09, 0.12, 0.96)
	_board_view.board_background = Color(0.03, 0.04, 0.06, 0.96)

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.025, 0.045, 0.07, 0.94)
	frame_style.border_color = Color(0.18, 0.24, 0.31, 0.90)
	frame_style.set_border_width_all(1)
	frame_style.set_corner_radius_all(4)
	frame_style.content_margin_left = 8.0
	frame_style.content_margin_right = 8.0
	frame_style.content_margin_top = 6.0
	frame_style.content_margin_bottom = 6.0

	_top_bar.add_theme_stylebox_override("panel", frame_style)
	_enemy_panel.add_theme_stylebox_override("panel", frame_style)
	_combat_strip.add_theme_stylebox_override("panel", frame_style)
	_board_frame.add_theme_stylebox_override("panel", frame_style)
	_debug_overlay.add_theme_stylebox_override("panel", frame_style)
	_combat_log_frame.add_theme_stylebox_override("panel", frame_style)

	_apply_progressbar_flat_style(_enemy_hp_bar, Color(0.70, 0.12, 0.13, 1.0))
	_apply_progressbar_flat_style(_player_hp_bar, Color(0.78, 0.16, 0.17, 1.0))
	_apply_progressbar_flat_style(_player_armor_bar, Color(0.16, 0.50, 0.86, 1.0))

	var ui_text_color := Color(0.95, 0.96, 0.98, 1.0)
	for label in [_title_label, _hint_label, _timer_label, _run_progress_label, _phase_label, _turn_summary_label, _player_label, _player_armor_label, _attack_stat_label, _armor_stat_label, _heart_stat_label, _gold_stat_label, _enemy_label, _intent_label]:
		label.add_theme_color_override("font_color", ui_text_color)
	_title_label.add_theme_font_size_override("font_size", FONT_SIZE_TITLE)
	_hint_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_intent_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_enemy_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_timer_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_player_label.add_theme_font_size_override("font_size", 24)
	_player_armor_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	for stat_label in [_attack_stat_label, _armor_stat_label, _heart_stat_label, _gold_stat_label]:
		stat_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_run_progress_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_phase_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_turn_summary_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	for row_label in [_equipment_row_label, _consumable_row_label, _relic_row_label, _mastery_row_label]:
		row_label.add_theme_color_override("font_color", Color(0.67, 0.73, 0.80, 1.0))
		row_label.add_theme_font_size_override("font_size", FONT_SIZE_ROW_LABEL)
	_armor_badge_label.add_theme_font_size_override("font_size", 16)
	_armor_badge_label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0, 1.0))
	_armor_badge_label.add_theme_constant_override("outline_size", 2)
	_armor_badge_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.94))
	_phase_label.add_theme_color_override("font_color", Color(0.70, 0.78, 0.86, 1.0))
	_run_progress_label.add_theme_color_override("font_color", Color(0.82, 0.90, 0.98, 1.0))
	_player_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.92, 1.0))
	_player_armor_label.add_theme_color_override("font_color", Color(0.82, 0.94, 1.0, 1.0))
	_timer_label.add_theme_color_override("font_color", Color(0.85, 0.93, 1.0, 1.0))
	_timer_state_label.add_theme_color_override("font_color", Color(0.73, 0.84, 0.92, 1.0))
	_timer_state_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_apply_timer_label_readability(_timer_label)
	_apply_timer_label_readability(_timer_state_label)
	_apply_button_theme()
	_apply_timer_track_theme()
	_apply_loadout_group_theme()
	_player_loadout_hud.apply_player_hud_chrome(_combat_player_hud_nodes())
	_apply_board_focus_theme()
	_apply_debug_overlay_theme()
	_apply_stat_chip_theme()

	_player_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ensure_placeholder_visuals()
	_apply_zone_guides()
	_title_label.text = RunState.level_sequence_label()
	_hint_label.text = "Gold 0"


func _apply_board_focus_theme() -> void:
	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color(0.0, 0.0, 0.0, 0.24)
	shadow_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	shadow_style.set_corner_radius_all(12)
	_board_shadow.add_theme_stylebox_override("panel", shadow_style)

	var summary_style := StyleBoxFlat.new()
	summary_style.bg_color = Color(0.03, 0.06, 0.10, 0.97)
	summary_style.border_color = Color(0.26, 0.34, 0.44, 0.96)
	summary_style.set_border_width_all(2)
	summary_style.set_corner_radius_all(12)
	summary_style.content_margin_left = 40.0
	summary_style.content_margin_right = 40.0
	summary_style.content_margin_top = 34.0
	summary_style.content_margin_bottom = 34.0
	_outcome_summary_panel.add_theme_stylebox_override("panel", summary_style)

	_outcome_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_outcome_title_label.add_theme_font_size_override("font_size", 46)
	_outcome_title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
	_outcome_title_label.add_theme_constant_override("outline_size", 3)
	_outcome_title_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.92))
	_outcome_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_outcome_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_outcome_body_label.clip_text = true
	_outcome_body_label.custom_minimum_size = Vector2.ZERO
	_outcome_body_label.add_theme_font_size_override("font_size", 24)
	_outcome_body_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
	_next_button.text = "Continue"
	_next_button.add_theme_font_size_override("font_size", 22)


func _apply_debug_overlay_theme() -> void:
	_status_label.add_theme_font_size_override("font_size", DEBUG_TEXT_FONT_SIZE)
	_enemy_debug_label.add_theme_font_size_override("font_size", DEBUG_TEXT_FONT_SIZE)
	_combat_log_text.add_theme_font_size_override("normal_font_size", DEBUG_TEXT_FONT_SIZE)
	_combat_log_text.add_theme_font_size_override("bold_font_size", DEBUG_TEXT_FONT_SIZE)
	_combat_log_text.add_theme_font_size_override("italics_font_size", DEBUG_TEXT_FONT_SIZE)
	_combat_log_text.add_theme_font_size_override("bold_italics_font_size", DEBUG_TEXT_FONT_SIZE)
	_combat_log_text.add_theme_font_size_override("mono_font_size", DEBUG_TEXT_FONT_SIZE)
	_console_input.custom_minimum_size = Vector2(0.0, DEBUG_INPUT_HEIGHT)
	_console_input.add_theme_font_size_override("font_size", DEBUG_INPUT_FONT_SIZE)
	_console_input.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	_console_input.add_theme_color_override("font_placeholder_color", Color(0.72, 0.76, 0.82, 0.95))


func _apply_stat_chip_theme() -> void:
	for stat_label in [_attack_stat_label, _armor_stat_label, _heart_stat_label, _gold_stat_label]:
		var chip_style := StyleBoxFlat.new()
		chip_style.bg_color = Color(0.04, 0.07, 0.10, 0.92)
		chip_style.border_color = Color(0.20, 0.27, 0.35, 0.95)
		chip_style.set_border_width_all(1)
		chip_style.set_corner_radius_all(4)
		chip_style.content_margin_left = 8.0
		chip_style.content_margin_right = 8.0
		chip_style.content_margin_top = 4.0
		chip_style.content_margin_bottom = 4.0
		stat_label.add_theme_stylebox_override("normal", chip_style)
		stat_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
		stat_label.add_theme_constant_override("shadow_offset_x", 1)
		stat_label.add_theme_constant_override("shadow_offset_y", 2)


func _stylebox_from_texture(texture: Texture2D, left: int, right: int, top: int, bottom: int) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = left
	style.texture_margin_right = right
	style.texture_margin_top = top
	style.texture_margin_bottom = bottom
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


func _apply_progressbar_style(bar: ProgressBar, frame_texture: Texture2D, fill_texture: Texture2D) -> void:
	if frame_texture != null:
		bar.add_theme_stylebox_override("background", _stylebox_from_texture(frame_texture, 12, 12, 7, 7))
	if fill_texture != null:
		bar.add_theme_stylebox_override("fill", _stylebox_from_texture(fill_texture, 12, 12, 7, 7))


func _apply_progressbar_flat_style(bar: ProgressBar, fill_color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.07, 0.10, 0.95)
	bg.set_corner_radius_all(4)
	bg.set_border_width_all(1)
	bg.border_color = Color(0.18, 0.25, 0.34, 0.85)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _apply_button_theme() -> void:
	for button in [_back_button, _debug_toggle_button, _settings_button, _next_button]:
		button.add_theme_color_override("font_color", Color(0.84, 0.89, 0.94, 1.0))
		button.add_theme_font_size_override("font_size", 18)
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.04, 0.07, 0.10, 0.84)
		style_normal.border_color = Color(0.22, 0.30, 0.39, 0.92)
		style_normal.set_border_width_all(1)
		style_normal.set_corner_radius_all(4)
		style_normal.content_margin_left = 8.0
		style_normal.content_margin_right = 8.0
		style_normal.content_margin_top = 4.0
		style_normal.content_margin_bottom = 4.0
		button.add_theme_stylebox_override("normal", style_normal)
		var style_hover := style_normal.duplicate()
		style_hover.bg_color = Color(0.08, 0.12, 0.17, 0.94)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_hover)


func _apply_timer_track_theme() -> void:
	var timer_style := StyleBoxFlat.new()
	timer_style.bg_color = Color(0.035, 0.075, 0.11, 0.94)
	timer_style.border_color = Color(0.20, 0.30, 0.40, 0.90)
	timer_style.set_border_width_all(1)
	timer_style.set_corner_radius_all(4)
	var frame := _timer_track.get_node_or_null("TimerTrackFrame")
	if frame is Panel:
		(frame as Panel).add_theme_stylebox_override("panel", timer_style)


func _apply_timer_label_readability(label: Label) -> void:
	label.add_theme_color_override("font_shadow_color", Color(0.01, 0.02, 0.03, 0.95))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.80))


func _apply_loadout_group_theme() -> void:
	var inner_panel_style := StyleBoxFlat.new()
	inner_panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.98)
	inner_panel_style.border_color = Color(0.18, 0.24, 0.31, 0.95)
	inner_panel_style.set_border_width_all(1)
	inner_panel_style.set_corner_radius_all(4)
	inner_panel_style.content_margin_left = 8.0
	inner_panel_style.content_margin_right = 8.0
	inner_panel_style.content_margin_top = 6.0
	inner_panel_style.content_margin_bottom = 6.0
	_loadout_frame.add_theme_stylebox_override("panel", inner_panel_style)
	_mastery_strip.add_theme_stylebox_override("panel", inner_panel_style)
	_hero_card.add_theme_stylebox_override("panel", inner_panel_style)

	var vitals_frame_style := StyleBoxFlat.new()
	vitals_frame_style.bg_color = Color(0.04, 0.08, 0.13, 0.98)
	vitals_frame_style.border_color = Color(0.18, 0.25, 0.34, 0.96)
	vitals_frame_style.set_border_width_all(1)
	vitals_frame_style.set_corner_radius_all(4)
	_vitals_frame.add_theme_stylebox_override("panel", vitals_frame_style)

	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.08, 0.09, 0.12, 0.98)
	badge_style.border_color = Color(0.24, 0.32, 0.42, 1.0)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(6)
	_hero_level_badge.visible = false

	var armor_badge_style := StyleBoxFlat.new()
	armor_badge_style.bg_color = Color(0.08, 0.19, 0.31, 0.98)
	armor_badge_style.border_color = Color(0.40, 0.70, 0.96, 0.96)
	armor_badge_style.set_border_width_all(1)
	armor_badge_style.set_corner_radius_all(6)
	armor_badge_style.content_margin_left = 8.0
	armor_badge_style.content_margin_right = 8.0
	armor_badge_style.content_margin_top = 2.0
	armor_badge_style.content_margin_bottom = 2.0
	_armor_badge.add_theme_stylebox_override("panel", armor_badge_style)


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
			get_tree().call_deferred("change_scene_to_file", redirect_scene)
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
	_combat_log_lines.clear()
	_combat_log_command_flags.clear()
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
	if _debug_overlay.visible and _console_input.visible:
		_console_input.grab_focus()
	else:
		_console_input.release_focus()


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
	_refresh_drag_match_glow()
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
	if not _active_drag:
		if _input_phase == InputPhase.PLAYER_INPUT:
			_sync_timer_display(_timer_ready_seconds(), TIMER_STATE_READY)
		else:
			_sync_timer_display(0.0, TIMER_STATE_LOCKED)
		return

	_refresh_drag_match_glow()
	_move_time_left = maxf(0.0, _move_time_left - delta)
	_sync_timer_display(_move_time_left, TIMER_STATE_ACTIVE)
	if _move_time_left <= 0.0:
		_end_drag(true)


func _handle_pointer_input(event: InputEvent) -> bool:
	if _input_phase != InputPhase.PLAYER_INPUT and not _active_drag:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			return _start_drag(event.position)
		if _active_drag:
			_end_drag(false)
			return true
		return false

	if event is InputEventMouseMotion and _active_drag and _drag_touch_index == -1:
		_update_drag(event.position)
		return true

	if event is InputEventScreenTouch:
		var touch_pos: Vector2 = event.position
		if event.pressed:
			if _drag_touch_index != -1:
				return false
			var started := _start_drag(touch_pos)
			if started:
				_drag_touch_index = event.index
			return started
		if _active_drag and event.index == _drag_touch_index:
			_end_drag(false)
			return true

	if event is InputEventScreenDrag and _active_drag and event.index == _drag_touch_index:
		var drag_pos: Vector2 = event.position
		_update_drag(drag_pos)
		return true

	return false


func _on_board_view_gui_input(event: InputEvent) -> void:
	if _handle_pointer_input(event):
		_board_view.accept_event()


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
	_reset_drag_visuals()
	_board_view.clear_animations()
	_board_state.initialize(board_seed, _settings)
	_board_view.board_state = _board_state
	if _combat != null and not _combat.is_fight_over():
		_set_input_phase(InputPhase.PLAYER_INPUT)


func _print_board_state_to_console() -> void:
	_append_combat_log("Board seed: %d" % _board_state.rng_seed)
	var lines: PackedStringArray = _board_state.to_debug_string().split("\n", false)
	for line in lines:
		_append_combat_log("  %s" % line)


func _on_console_input_text_submitted(text: String) -> void:
	var trimmed := text.strip_edges()
	if trimmed == "":
		_console_input.clear()
		return
	_append_combat_log("> " + trimmed)
	_console_input.clear()
	if not trimmed.begins_with("/"):
		return
	_handle_console_command(trimmed)


func _handle_console_command(raw_text: String) -> void:
	var body := raw_text.substr(1).strip_edges()
	if body == "":
		_command_error("missing command")
		return
	var parts: PackedStringArray = body.split(" ", false)
	if parts.is_empty():
		_command_error("missing command")
		return

	var command := String(parts[0]).to_lower()
	match command:
		"commands", "help":
			_print_command_list()
		"state":
			_print_state_snapshot()
		"clear":
			_combat_log_lines.clear()
			_combat_log_command_flags.clear()
			_refresh_combat_log_display()
			_status_label.text = "Console cleared."
		"log_level":
			_handle_log_level_command(parts)
		"skip":
			_handle_skip_command(parts)
		"board":
			if parts.size() < 2:
				_command_error("usage: /board print|reroll|seed <number>")
				return
			var board_sub := String(parts[1]).to_lower()
			match board_sub:
				"print":
					_print_board_state_to_console()
				"reroll":
					_create_new_board()
					_append_combat_log("Board rerolled (seed %d)." % _board_state.rng_seed)
				"seed":
					if parts.size() < 3:
						_command_error("usage: /board seed <number>")
						return
					var seed_token := String(parts[2])
					if not seed_token.is_valid_int():
						_command_error("seed must be an integer")
						return
					var seed_value := seed_token.to_int()
					_set_board_seed(seed_value)
					_append_combat_log("Board set to seed %d." % _board_state.rng_seed)
				_:
					_command_error("unknown /board subcommand: %s" % board_sub)
		"gold":
			if parts.size() < 3:
				_command_error("usage: /gold add <amount> | /gold set <amount>")
				return
			var gold_sub := String(parts[1]).to_lower()
			var amount_token := String(parts[2])
			if not amount_token.is_valid_int():
				_command_error("amount must be an integer")
				return
			var amount := amount_token.to_int()
			match gold_sub:
				"add":
					if amount <= 0:
						_command_error("gold add requires a positive amount")
						return
					var added := RunState.add_gold(amount)
					_update_hud()
					_append_combat_log("Gold added: +%d (now %d)." % [added, RunState.run_gold])
				"set":
					RunState.set_gold(amount)
					_update_hud()
					_append_combat_log("Gold set to %d." % RunState.run_gold)
				_:
					_command_error("unknown /gold subcommand: %s" % gold_sub)
		"mastery":
			if parts.size() < 2:
				_command_error("usage: /mastery add <orb> <amount> | /mastery list")
				return
			var mastery_sub := String(parts[1]).to_lower()
			match mastery_sub:
				"add":
					if parts.size() < 4:
						_command_error("usage: /mastery add <orb> <amount>")
						return
					var orb_token := String(parts[2]).to_lower()
					var orb_id := _orb_id_from_token(orb_token)
					if orb_id < 0:
						_command_error("invalid orb '%s'" % orb_token)
						return
					var mastery_amount_token := String(parts[3])
					if not mastery_amount_token.is_valid_int():
						_command_error("mastery amount must be an integer")
						return
					var mastery_amount := mastery_amount_token.to_int()
					if mastery_amount <= 0:
						_command_error("mastery amount must be positive")
						return
					var progression_state: Variant = RunState.ensure_player_progression_state()
					var progression_service: Variant = RunState.ensure_player_progression_service()
					var mastery_result: Dictionary = progression_service.grant_mastery(progression_state, orb_id, mastery_amount)
					if not bool(mastery_result.get("ok", false)):
						_command_error("mastery add failed: %s" % String(mastery_result.get("reason", "unknown_error")))
						return
					var mastery_payload: Dictionary = mastery_result.get("result", {})
					_update_hud()
					_append_combat_log(
						"Mastery added: %s +%d (new level %d)." % [
							OrbType.display_name(orb_id),
							int(mastery_payload.get("granted", 0)),
							int(mastery_payload.get("new_level", 0)),
						]
					)
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Mastery IDs", content.list_mastery_cards())
				_:
					_command_error("unknown /mastery subcommand: %s" % mastery_sub)
		"consumable":
			if parts.size() < 2:
				_command_error("usage: /consumable add <id> | /consumable list")
				return
			var consumable_sub := String(parts[1]).to_lower()
			match consumable_sub:
				"add":
					if parts.size() < 3:
						_command_error("usage: /consumable add <id>")
						return
					var consumable_id := String(parts[2])
					var progression_state: Variant = RunState.ensure_player_progression_state()
					var progression_service: Variant = RunState.ensure_player_progression_service()
					var content: Variant = RunState.ensure_content_registry()
					var consumable_result: Dictionary = progression_service.add_consumable(progression_state, consumable_id, content)
					if not bool(consumable_result.get("ok", false)):
						_command_error("consumable add failed: %s" % String(consumable_result.get("reason", "unknown_error")))
						return
					_update_hud()
					_append_combat_log("Consumable added: %s." % consumable_id)
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Consumable IDs", content.list_consumables())
				_:
					_command_error("unknown /consumable subcommand: %s" % consumable_sub)
		"equipment":
			if parts.size() < 2:
				_command_error("usage: /equipment list|show <id>|add <id>")
				return
			var equipment_sub := String(parts[1]).to_lower()
			match equipment_sub:
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Equipment IDs", content.list_equipment())
				"show":
					if parts.size() < 3:
						_command_error("usage: /equipment show <id>")
						return
					var equipment_id := String(parts[2]).strip_edges()
					_show_equipment_details(equipment_id)
				"add":
					if parts.size() < 3:
						_command_error("usage: /equipment add <id>")
						return
					var equipment_id := String(parts[2]).strip_edges()
					_add_equipment_by_id(equipment_id)
				_:
					_command_error("unknown /equipment subcommand: %s" % equipment_sub)
		"relic":
			if parts.size() < 2:
				_command_error("usage: /relic list|show <id>|add <id>")
				return
			var relic_sub := String(parts[1]).to_lower()
			match relic_sub:
				"list":
					var content: Variant = RunState.ensure_content_registry()
					_print_content_id_list("Relic IDs", content.list_relics())
				"show":
					if parts.size() < 3:
						_command_error("usage: /relic show <id>")
						return
					var relic_id := String(parts[2]).strip_edges()
					_show_relic_details(relic_id)
				"add":
					if parts.size() < 3:
						_command_error("usage: /relic add <id>")
						return
					var relic_id := String(parts[2]).strip_edges()
					_add_relic_by_id(relic_id)
				_:
					_command_error("unknown /relic subcommand: %s" % relic_sub)
		"fight":
			if parts.size() < 2:
				_command_error("usage: /fight win|lose")
				return
			var fight_sub := String(parts[1]).to_lower()
			match fight_sub:
				"win":
					var win_transition: Dictionary = RunState.mark_fight_victory()
					if not bool(win_transition.get("ok", false)):
						_command_error("fight win failed: %s" % String(win_transition.get("reason", "unknown_error")))
						return
					_set_input_phase(InputPhase.LOCKED_EXTERNAL)
					_pending_next_scene_path = String(win_transition.get("next_scene", "res://scenes/main.tscn"))
					_update_hud()
					_show_outcome_summary("Victory", _build_run_outcome_summary("Debug command."), true)
					_status_label.text = "Debug victory queued. Press Continue."
					_append_combat_log("Fight win queued. Press Next to continue.")
				"lose":
					var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
					_set_input_phase(InputPhase.LOCKED_EXTERNAL)
					_pending_next_scene_path = String(lose_transition.get("next_scene", "res://scenes/main.tscn"))
					_update_hud()
					_show_outcome_summary("Defeat", _build_run_outcome_summary("Debug command."), true, "Main Menu")
					_status_label.text = "Debug defeat queued. Main Menu available."
					_append_combat_log("Fight lose queued. Press Main Menu.")
				_:
					_command_error("unknown /fight subcommand: %s" % fight_sub)
		_:
			_command_error("unknown command '%s'" % command)


func _print_command_list() -> void:
	_append_combat_log("Available commands:", true)
	_append_combat_log("/commands (/help) - Show command list", true)
	_append_combat_log("/state - Show current run/combat snapshot", true)
	_append_combat_log("/clear - Clear console log", true)
	_append_combat_log("/log_level [normal|detailed] - Show or set turn log verbosity", true)
	_append_combat_log("/skip <level> <fight> - Jump to fight 1, 2, or boss 3 at level", true)
	_append_combat_log("/board print - Print current board", true)
	_append_combat_log("/board reroll - Regenerate board with random seed", true)
	_append_combat_log("/board seed <number> - Regenerate board with fixed seed", true)
	_append_combat_log("/gold add <amount> - Add run gold", true)
	_append_combat_log("/gold set <amount> - Set run gold", true)
	_append_combat_log("/mastery add <orb> <amount> - Grant mastery", true)
	_append_combat_log("/mastery list - List mastery IDs", true)
	_append_combat_log("/consumable add <id> - Add consumable by content id", true)
	_append_combat_log("/consumable list - List consumable IDs", true)
	_append_combat_log("/equipment list - List equipment IDs", true)
	_append_combat_log("/equipment show <id> - Show equipment details", true)
	_append_combat_log("/equipment add <id> - Equip item into leftmost free slot", true)
	_append_combat_log("/relic list - List relic IDs", true)
	_append_combat_log("/relic show <id> - Show relic details", true)
	_append_combat_log("/relic add <id> - Add relic if not already owned", true)
	_append_combat_log("/fight win - Queue victory flow", true)
	_append_combat_log("/fight lose - Queue defeat flow", true)


func _command_error(msg: String) -> void:
	_append_combat_log("Command error: %s. Type /commands." % msg)


func _handle_log_level_command(parts: PackedStringArray) -> void:
	if parts.size() == 1:
		_append_combat_log("Combat log level: %s." % _combat_log_level)
		return
	if parts.size() != 2:
		_command_error("usage: /log_level normal|detailed")
		return

	var requested_level := String(parts[1]).to_lower()
	if requested_level != LOG_LEVEL_NORMAL and requested_level != LOG_LEVEL_DETAILED:
		_command_error("usage: /log_level normal|detailed")
		return

	_combat_log_level = requested_level
	_append_combat_log("Combat log level set to %s." % _combat_log_level)


func _handle_skip_command(parts: PackedStringArray) -> void:
	if parts.size() != 3:
		_command_error("usage: /skip <level> <fight>")
		return
	var level_text := String(parts[1])
	var fight_text := String(parts[2])
	if not level_text.is_valid_int() or not fight_text.is_valid_int():
		_command_error("usage: /skip <level> <fight>")
		return
	var level := level_text.to_int()
	var fight := fight_text.to_int()
	var result: Dictionary = RunState.skip_to_fight(level, fight)
	if not bool(result.get("ok", false)):
		_command_error("skip failed: %s" % String(result.get("reason", "unknown_error")))
		return

	_active_drag = false
	_drag_touch_index = -1
	_drag_path.clear()
	_last_resolve_result.clear()
	_initialize_combat_state()
	_create_new_board()
	_begin_turn_preview()
	_status_label.text = "Skipped to %s." % RunState.level_sequence_label()
	_append_combat_log("Debug skip: jumped to %s." % RunState.level_sequence_label())


func _orb_id_from_token(token: String) -> int:
	match token:
		"fire", "f":
			return OrbType.Id.FIRE
		"ice", "i":
			return OrbType.Id.ICE
		"earth", "e":
			return OrbType.Id.EARTH
		"heart", "h":
			return OrbType.Id.HEART
		"armor", "a":
			return OrbType.Id.ARMOR
		"gold", "g":
			return OrbType.Id.GOLD
		_:
			return -1


func _print_state_snapshot() -> void:
	var progression: Dictionary = RunState.progression_snapshot()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	var intent_text := "-"
	if _enemy_state != null:
		intent_text = _format_intent(_enemy_state.get_current_intent())

	_append_combat_log("State snapshot:")
	_append_combat_log(
		"Run: active=%s, level=%d, step=%s, label=%s" % [
			str(RunState.run_active),
			int(RunState.dungeon_level),
			String(RunState.current_step_key),
			RunState.level_sequence_label(),
		]
	)
	_append_combat_log(
		"Combat: turn=%d, phase=%s, input_phase=%s" % [
			int(_combat.turn_index if _combat != null else 0),
			(_combat.phase_name() if _combat != null else "N/A"),
			_input_phase,
		]
	)
	_append_combat_log(
		"Player: HP %d/%d, Armor %d, Gold %d" % [
			int(_player_state.current_hp if _player_state != null else 0),
			int(_player_state.max_hp if _player_state != null else 0),
			int(_player_state.armor if _player_state != null else 0),
			int(RunState.run_gold),
		]
	)
	_append_combat_log(
		"Enemy: %s HP %d/%d, TurnBlock %d, Intent %s" % [
			String(encounter.get("display_name", _enemy_state.display_name if _enemy_state != null else "Unknown")),
			int(_enemy_state.current_hp if _enemy_state != null else 0),
			int(_enemy_state.max_hp if _enemy_state != null else 0),
			int(_enemy_state.current_turn_block if _enemy_state != null else 0),
			intent_text,
		]
	)
	_append_combat_log("Eq: %s" % _format_slot_line(progression.get("equipment_slots", [])))
	_append_combat_log("Cons: %s" % _format_slot_line(progression.get("consumable_slots", [])))
	_append_combat_log("Relics: %s" % _format_id_line(progression.get("relic_ids", [])))
	_append_combat_log("Mastery: %s" % _format_mastery_line(progression.get("mastery_levels", {})))


func _print_content_id_list(label: String, entries: Array) -> void:
	var ids: Array[String] = []
	for raw_entry in entries:
		var entry: Dictionary = raw_entry
		var entry_id := String(entry.get("id", "")).strip_edges()
		if entry_id != "":
			ids.append(entry_id)
	if ids.is_empty():
		_append_combat_log("%s: (none)." % label)
		return
	_append_combat_log("%s (%d): %s" % [label, ids.size(), ", ".join(ids)])


func _show_equipment_details(equipment_id: String) -> void:
	if equipment_id == "":
		_command_error("equipment id is required")
		return

	var content: Variant = RunState.ensure_content_registry()
	var equipment: Dictionary = content.get_equipment(equipment_id)
	if equipment.is_empty():
		_command_error("unknown equipment id '%s'" % equipment_id)
		return

	var target_orb_id := int(equipment.get("target_orb_id", -1))
	var target_orb := "Any"
	if OrbType.is_valid_id(target_orb_id):
		target_orb = OrbType.display_name(target_orb_id)
	var modifiers: Dictionary = equipment.get("combat_modifiers", {})

	_append_combat_log("Equipment %s" % equipment_id)
	_append_combat_log("  Name: %s" % String(equipment.get("display_name", equipment_id)))
	_append_combat_log("  Rarity: %s | Target: %s" % [String(equipment.get("rarity", "common")), target_orb])
	_append_combat_log(
		"  Price: %d | Sell: %d | Levels: %d-%d" % [
			int(equipment.get("base_price", 0)),
			int(equipment.get("sell_value", equipment.get("base_price", 0))),
			int(equipment.get("min_level", 1)),
			int(equipment.get("max_level", 3)),
		]
	)
	_append_combat_log("  Icon: %s" % String(equipment.get("icon_key", "")))
	_append_combat_log("  Description: %s" % String(equipment.get("description", "")))
	if modifiers.is_empty():
		_append_combat_log("  Combat Modifiers: none")
	else:
		_append_combat_log("  Combat Modifiers: %s" % JSON.stringify(modifiers))


func _add_equipment_by_id(equipment_id: String) -> void:
	if equipment_id == "":
		_command_error("equipment id is required")
		return

	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var equip_result: Dictionary = progression_service.equip_item(progression_state, equipment_id, content)
	if not bool(equip_result.get("ok", false)):
		_command_error("equipment add failed: %s" % String(equip_result.get("reason", "unknown_error")))
		return

	var payload: Dictionary = equip_result.get("result", {})
	var slot_index := int(payload.get("slot_index", -1))
	_update_hud()
	_append_combat_log("Equipment added: %s -> slot %d." % [equipment_id, slot_index])


func _show_relic_details(relic_id: String) -> void:
	if relic_id == "":
		_command_error("relic id is required")
		return

	var content: Variant = RunState.ensure_content_registry()
	var relic: Dictionary = content.get_relic(relic_id)
	if relic.is_empty():
		_command_error("unknown relic id '%s'" % relic_id)
		return

	var modifiers: Dictionary = relic.get("combat_modifiers", {})
	_append_combat_log("Relic %s" % relic_id)
	_append_combat_log("  Name: %s" % String(relic.get("display_name", relic_id)))
	_append_combat_log("  Rarity: %s" % String(relic.get("rarity", "common")))
	_append_combat_log(
		"  Price: %d | Levels: %d-%d" % [
			int(relic.get("base_price", 0)),
			int(relic.get("min_level", 1)),
			int(relic.get("max_level", 3)),
		]
	)
	_append_combat_log("  Icon: %s" % String(relic.get("icon_key", "")))
	_append_combat_log("  Description: %s" % String(relic.get("description", "")))
	if modifiers.is_empty():
		_append_combat_log("  Combat Modifiers: none")
	else:
		_append_combat_log("  Combat Modifiers: %s" % JSON.stringify(modifiers))


func _add_relic_by_id(relic_id: String) -> void:
	if relic_id == "":
		_command_error("relic id is required")
		return

	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var relic_result: Dictionary = progression_service.add_relic(progression_state, relic_id, content)
	if not bool(relic_result.get("ok", false)):
		_command_error("relic add failed: %s" % String(relic_result.get("reason", "unknown_error")))
		return

	_update_hud()
	_append_combat_log("Relic added: %s." % relic_id)


func _start_drag(board_local_position: Vector2) -> bool:
	if _input_phase != InputPhase.PLAYER_INPUT:
		return false

	var start_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(start_cell):
		return false

	_active_drag = true
	_move_time_left = _player_state.move_timer_seconds
	_drag_current_cell = start_cell
	_drag_selected_orb_id = _board_state.get_cell(start_cell.x, start_cell.y)
	_drag_path.clear()
	_drag_path.append(start_cell)
	_board_view.selected_cell = start_cell
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_pointer_position = board_local_position
	_board_view.drag_orb_id = _drag_selected_orb_id
	_sync_timer_display(_move_time_left, TIMER_STATE_ACTIVE)
	_status_label.text = "Dragging %s orb. Move timer running." % OrbType.display_name(_drag_selected_orb_id)
	_status_label.modulate = STATUS_COLOR_NEUTRAL
	return true


func _update_drag(board_local_position: Vector2) -> void:
	if not _active_drag:
		return

	_board_view.drag_pointer_position = board_local_position
	var target_cell := _board_view.board_position_to_cell(board_local_position)
	if not _board_view.is_cell_valid(target_cell):
		return
	if target_cell == _drag_current_cell:
		return
	if not _is_orthogonally_adjacent(_drag_current_cell, target_cell):
		return

	var from_cell := _drag_current_cell
	var moving_orb_id := _board_state.get_cell(from_cell.x, from_cell.y)
	var displaced_orb_id := _board_state.get_cell(target_cell.x, target_cell.y)
	_board_state.swap_cells(_drag_current_cell.x, _drag_current_cell.y, target_cell.x, target_cell.y)
	_audio_play_sfx("swap")
	_drag_current_cell = target_cell
	_drag_path.append(target_cell)
	_board_view.animate_swap(from_cell, target_cell, moving_orb_id, displaced_orb_id, SWAP_ANIMATION_SECONDS)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.selected_cell = _drag_current_cell
	_board_view.board_state = _board_state


func _end_drag(timed_out: bool) -> void:
	if not _active_drag:
		return

	_active_drag = false
	_drag_touch_index = -1
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

	_reset_drag_visuals()
	_board_view.clear_animations()
	_set_input_phase(InputPhase.RESOLVING)
	_resolve_combo_running = 0
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
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=resolve_presentation_complete total_combos=%d passes=%d" % [
			int(_last_resolve_result.get("total_combos", 0)),
			Array(_last_resolve_result.get("passes", [])).size(),
		]
	)
	_board_state = simulation_board_state
	_board_view.board_state = _board_state
	_resolve_trace(
		resolve_trace_origin_usec,
		"phase=final_board_commit board_seed=%d" % _board_state.rng_seed
	)
	if _input_phase == InputPhase.RESOLVING:
		await _resolve_combat_turn_from_board(_last_resolve_result)
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
			_show_boss_reward_summary(_build_victory_gold_summary(turn_log))
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
			_status_label.text = _build_victory_status(turn_log, transition) + " Press Continue."
			_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
			_pending_next_scene_path = next_scene
			_show_outcome_summary("Victory", _build_victory_gold_summary(turn_log), true)
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
		var defeat_cause := _build_defeat_cause(turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_defeat_status(turn_log) + " Main Menu available."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Waiting for Main Menu button.")
		_pending_next_scene_path = String(defeat_transition.get("next_scene", "res://scenes/main.tscn"))
		_show_outcome_summary("Defeat", _build_run_outcome_summary(defeat_cause), true, "Main Menu")
		_turn_summary_label.text = "Turn Summary: Defeat. Main Menu available."
		RunState.flow_trace_mark(
			"combat_continue_available",
			{"button_text": "Main Menu"},
			_flow_trace_route_id,
			_pending_next_scene_path
		)
		_pulse_label(_turn_summary_label, STATUS_COLOR_NEGATIVE)
		return

	_status_label.text = _build_turn_summary_status(turn_log)
	_play_turn_result_sfx(turn_log)
	_status_label.modulate = STATUS_COLOR_POSITIVE
	_turn_summary_label.text = "Turn Summary: %s" % _build_turn_summary_status(turn_log)
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
	_apply_board_panel_layout()


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
	_apply_board_panel_layout()
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
		if _active_drag:
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


func _reset_drag_visuals() -> void:
	_drag_selected_orb_id = -1
	_drag_current_cell = Vector2i(-1, -1)
	_drag_path.clear()
	_board_view.clear_match_glow()
	_board_view.selected_cell = Vector2i(-1, -1)
	_board_view.path_cells = _drag_path.duplicate()
	_board_view.drag_orb_id = -1
	_board_view.drag_pointer_position = Vector2.ZERO


func _is_orthogonally_adjacent(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	var delta := to_cell - from_cell
	return abs(delta.x) + abs(delta.y) == 1


func _abort_active_drag() -> void:
	_active_drag = false
	_drag_touch_index = -1
	_sync_timer_display(0.0, TIMER_STATE_LOCKED)
	_reset_drag_visuals()


func _refresh_drag_match_glow() -> void:
	if not _active_drag:
		_board_view.clear_match_glow()
		return
	var predicted_groups: Array[Dictionary] = _resolver.get_match_groups(_board_state)
	_board_view.set_live_match_glow(predicted_groups)


func _play_resolve_animations(
	result: Dictionary,
	visual_board_state: BoardState = null,
	resolve_trace_origin_usec: int = 0
) -> void:
	if result.total_combos <= 0:
		return

	var pass_results: Array = result.get("passes", [])
	for pass_index in range(pass_results.size()):
		var pass_result: Dictionary = pass_results[pass_index]
		_resolve_trace_pass_index = pass_index
		var presented_groups := _sorted_match_groups_for_presentation(pass_result.get("groups", []))
		var group_count := presented_groups.size()
		var fall_count := Array(pass_result.get("fall_moves", [])).size()
		var refill_count := Array(pass_result.get("refill_spawns", [])).size()
		var step_index := int(pass_result.get("step_index", pass_index))
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=pass_start step_index=%d groups=%d fall=%d refill=%d" % [
				pass_index,
				step_index,
				group_count,
				fall_count,
				refill_count,
			]
		)
		await _play_match_groups_for_pass(
			presented_groups,
			visual_board_state,
			resolve_trace_origin_usec,
			pass_index
		)
		await _wait_combat_speed(CASCADE_PASS_HOLD_SECONDS)

		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=gravity_start moves=%d gravity_ms=%d" % [
				pass_index,
				fall_count,
				int(round(_combat_speed_duration(GRAVITY_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		var gravity_animation_seconds := _combat_speed_duration(GRAVITY_ANIMATION_SECONDS)
		_board_view.animate_fall_moves(pass_result.fall_moves, gravity_animation_seconds)
		await _wait_combat_speed(GRAVITY_ANIMATION_SECONDS)
		_apply_visual_fall_moves(visual_board_state, pass_result.fall_moves)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=gravity_visual_commit moves=%d" % [pass_index, fall_count]
		)

		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=refill_start spawns=%d refill_ms=%d" % [
				pass_index,
				refill_count,
				int(round(_combat_speed_duration(REFILL_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		var refill_animation_seconds := _combat_speed_duration(REFILL_ANIMATION_SECONDS)
		_board_view.animate_refill_spawns(pass_result.refill_spawns, refill_animation_seconds)
		await _wait_combat_speed(REFILL_ANIMATION_SECONDS)
		_apply_visual_refill_spawns(visual_board_state, pass_result.refill_spawns)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=refill_visual_commit spawns=%d" % [pass_index, refill_count]
		)
		await _wait_combat_speed(CASCADE_PASS_HOLD_SECONDS)
		_resolve_trace(resolve_trace_origin_usec, "pass=%d phase=pass_complete" % pass_index)

	_resolve_trace_pass_index = -1
	_resolve_trace(resolve_trace_origin_usec, "phase=animations_drain_start")
	while _board_view.has_active_animations():
		await get_tree().create_timer(0.02).timeout
	_finish_combo_popup()
	_resolve_trace(resolve_trace_origin_usec, "phase=animations_drain_complete")


func _trigger_match_feedback(groups: Array, flash_seconds: float) -> void:
	_board_view.flash_match_groups(groups, flash_seconds)
	if flash_seconds <= 0.01:
		await get_tree().process_frame
		return
	await get_tree().create_timer(flash_seconds).timeout


func _play_match_groups_for_pass(
	groups: Array,
	visual_board_state: BoardState,
	resolve_trace_origin_usec: int,
	pass_index: int
) -> void:
	for group_index in range(groups.size()):
		var typed_group: Dictionary = groups[group_index]
		var one_group: Array[Dictionary] = [typed_group]
		var match_flash_seconds := _combat_speed_duration(MATCH_FLASH_SECONDS)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=match_flash_start group_index=%d flash_ms=%d" % [
				pass_index,
				group_index,
				int(round(match_flash_seconds * 1000.0)),
			]
		)
		await _trigger_match_feedback(one_group, match_flash_seconds)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=match_flash_end group_index=%d" % [pass_index, group_index]
		)

		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=clear_start group_index=%d clear_ms=%d" % [
				pass_index,
				group_index,
				int(round(_combat_speed_duration(CLEAR_ANIMATION_SECONDS) * 1000.0)),
			]
		)
		_spawn_match_clear_bursts(one_group)
		var clear_animation_seconds := _combat_speed_duration(CLEAR_ANIMATION_SECONDS)
		_board_view.animate_clear_groups(one_group, clear_animation_seconds)
		await _wait_combat_speed(CLEAR_ANIMATION_SECONDS)
		_apply_visual_clear_groups(visual_board_state, one_group)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=clear_visual_commit group_index=%d" % [pass_index, group_index]
		)

		_resolve_combo_running += 1
		var orb_id := int(typed_group.get("orb_id", -1))
		var orb_symbol := "?"
		var orb_name := "unknown"
		if OrbType.is_valid_id(orb_id):
			orb_symbol = OrbType.debug_symbol(orb_id)
			orb_name = OrbType.display_name(orb_id)
		var cell_count := Array(typed_group.get("cells", [])).size()
		var preview_amount := _preview_match_feedback_value(typed_group, _resolve_combo_running)
		_resolve_trace(
			resolve_trace_origin_usec,
			"pass=%d phase=combo_tick group_index=%d combo_value=%d orb=%s orb_name=\"%s\" cells=%d preview=%d" % [
				pass_index,
				group_index,
				_resolve_combo_running,
				orb_symbol,
				orb_name,
				cell_count,
				preview_amount,
			]
		)
		_update_combo_feedback(typed_group, _resolve_combo_running)
		await _wait_combat_speed(COMBO_COUNT_STEP_SECONDS)


func _sorted_match_groups_for_presentation(groups: Array) -> Array:
	var sorted_groups := groups.duplicate()
	sorted_groups.sort_custom(_compare_match_groups_for_presentation)
	return sorted_groups


func _compare_match_groups_for_presentation(left: Dictionary, right: Dictionary) -> bool:
	var left_anchor := _match_group_anchor(left)
	var right_anchor := _match_group_anchor(right)
	if left_anchor.y == right_anchor.y:
		return left_anchor.x < right_anchor.x
	return left_anchor.y < right_anchor.y


func _match_group_anchor(group: Dictionary) -> Vector2i:
	var cells: Array = group.get("cells", [])
	if cells.is_empty():
		return Vector2i(BoardState.COLUMN_COUNT, BoardState.ROW_COUNT)

	var min_row := BoardState.ROW_COUNT
	var min_column := BoardState.COLUMN_COUNT
	for cell in cells:
		var typed_cell: Vector2i = cell
		if typed_cell.y < min_row:
			min_row = typed_cell.y
			min_column = typed_cell.x
		elif typed_cell.y == min_row:
			min_column = mini(min_column, typed_cell.x)
	return Vector2i(min_column, min_row)


func _update_combo_feedback(group: Dictionary, combo_value: int) -> void:
	_spawn_combo_floating_text(group, combo_value)
	_trigger_match_mastery_feedback(group, combo_value)


func _trigger_match_mastery_feedback(group: Dictionary, combo_value: int) -> void:
	_show_match_mastery_feedback(group, combo_value)


func _apply_visual_clear_groups(visual_board_state: BoardState, groups: Array) -> void:
	if visual_board_state == null:
		return
	for group in groups:
		for cell in group.cells:
			var typed_cell: Vector2i = cell
			visual_board_state.clear_cell(typed_cell.x, typed_cell.y)
	_board_view.queue_redraw()


func _apply_visual_fall_moves(visual_board_state: BoardState, fall_moves: Array) -> void:
	if visual_board_state == null:
		return
	for move in fall_moves:
		var from_cell: Vector2i = move.from
		visual_board_state.clear_cell(from_cell.x, from_cell.y)
	for move in fall_moves:
		var to_cell: Vector2i = move.to
		var orb_id := int(move.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_state.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func _apply_visual_refill_spawns(visual_board_state: BoardState, refill_spawns: Array) -> void:
	if visual_board_state == null:
		return
	for spawn in refill_spawns:
		var to_cell: Vector2i = spawn.to
		var orb_id := int(spawn.orb_id)
		if OrbType.is_valid_id(orb_id):
			visual_board_state.set_cell(to_cell.x, to_cell.y, orb_id)
	_board_view.queue_redraw()


func _combat_speed_duration(base_seconds: float) -> float:
	match _combat_speed:
		COMBAT_SPEED_INSTANT:
			return 0.01
		COMBAT_SPEED_FAST:
			return base_seconds * 0.55
		COMBAT_SPEED_NORMAL:
			return base_seconds
		COMBAT_SPEED_SLOW:
			return base_seconds * 2.35
		_:
			return base_seconds


func _wait_combat_speed(base_seconds: float) -> void:
	var wait_seconds := _combat_speed_duration(base_seconds)
	if wait_seconds <= 0.01:
		await get_tree().process_frame
		return
	await get_tree().create_timer(wait_seconds).timeout


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
	return "Turn resolved: +%d HP, +%d Armor, +%d Gold, dealt %d (%d blocked)." % [
		int(turn_log.healed),
		int(turn_log.armor_gained),
		int(turn_log.gold_gained),
		int(turn_log.enemy_damage_taken),
		int(turn_log.enemy_blocked),
	]


func _build_victory_status(turn_log: Dictionary, transition: Dictionary) -> String:
	var next_scene := String(transition.get("next_scene", ""))
	var next_label := "Next scene"
	if next_scene.find("shop") >= 0:
		next_label = "shop"
	elif next_scene.find("boss_relic_reward") >= 0:
		next_label = "boss relic reward"
	elif next_scene.find("run_summary") >= 0:
		next_label = "run summary"
	elif next_scene.find("board_debug") >= 0:
		next_label = "next fight"
	return "Victory. Enemy defeated before intent (%s). Continue to %s." % [
		"skipped" if bool(turn_log.enemy_intent_skipped) else "resolved",
		next_label,
	]


func _build_victory_gold_summary(turn_log: Dictionary) -> String:
	return "GOLD GAINED +%d" % int(turn_log.get("gold_gained", 0))


func _build_run_outcome_summary(fallback_cause: String = "") -> String:
	var summary: Dictionary = RunState.run_summary_snapshot()
	var cause := String(summary.get("cause", fallback_cause))
	if cause == "":
		cause = fallback_cause
	var bosses_killed := int(summary.get("bosses_defeated", 0))
	var monsters_killed := maxi(0, int(summary.get("enemies_defeated", 0)) - bosses_killed)
	return "Total Gold +%d\nMonsters Killed %d\nBosses Killed %d\nLevel Reached %d/%d\n%s" % [
		int(summary.get("gold_earned", 0)),
		monsters_killed,
		bosses_killed,
		int(summary.get("level_reached", 1)),
		RunState.MAX_DUNGEON_LEVELS,
		cause,
	]


func _build_defeat_status(turn_log: Dictionary) -> String:
	var hp_damage := int(turn_log.enemy_attack_resolution.get("hp_damage", 0))
	return "Defeat. Enemy intent dealt %d HP damage." % hp_damage


func _build_defeat_cause(turn_log: Dictionary) -> String:
	var enemy_label := String(_enemy_state.display_name if _enemy_state != null else "Enemy")
	var intent_label := String(Dictionary(turn_log.get("enemy_intent", {})).get("label", "Unknown intent"))
	var hp_damage := int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0))
	return "%s defeated the hero with %s for %d HP." % [enemy_label, intent_label, hp_damage]


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
			_release_combat_mastery_feedback(OrbType.Id.FIRE)
		if ice_damage > 0:
			_spawn_replay_impact(enemy_target, "ice", enemy_impact_size, damage_lifetime)
			_spawn_mastery_beam(OrbType.Id.ICE, enemy_target, damage_lifetime)
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			_release_combat_mastery_feedback(OrbType.Id.ICE)
		if earth_damage > 0:
			_spawn_replay_impact(enemy_target, "earth", enemy_impact_size, damage_lifetime)
			_spawn_mastery_beam(OrbType.Id.EARTH, enemy_target, damage_lifetime)
			await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
			_release_combat_mastery_feedback(OrbType.Id.EARTH)
	elif enemy_damage > 0:
		var impact_orb := _dominant_orb_for_matches(turn_log.get("matched_counts", {}))
		_spawn_replay_impact(enemy_target, _mastery_impact_kind(impact_orb), enemy_impact_size, damage_lifetime)
		_spawn_mastery_beam(impact_orb, enemy_target, damage_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		_release_combat_mastery_feedback(impact_orb)

	if heart_heal > 0:
		_spawn_replay_impact(player_target, "heart", player_impact_size, player_lifetime)
		_spawn_mastery_beam(OrbType.Id.HEART, player_target, player_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		_release_combat_mastery_feedback(OrbType.Id.HEART)

	if armor_gain > 0:
		_spawn_replay_impact(player_target, "armor", player_impact_size, player_lifetime)
		_spawn_mastery_beam(OrbType.Id.ARMOR, player_target, player_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		_release_combat_mastery_feedback(OrbType.Id.ARMOR)

	if gold_gain > 0:
		_spawn_replay_impact(player_target, "gold", gold_impact_size, gold_lifetime)
		_spawn_mastery_beam(OrbType.Id.GOLD, player_target, gold_lifetime)
		await _wait_combat_speed(TURN_REPLAY_STEP_SECONDS)
		_release_combat_mastery_feedback(OrbType.Id.GOLD)
	await _release_remaining_combat_mastery_feedback()
	await _wait_combat_speed(TURN_REPLAY_FINAL_HOLD_SECONDS)
	_reset_combat_mastery_preview()


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
		_intent_badge.texture = _make_intent_placeholder_texture()
	_intent_badge.visible = true
	var enemy_texture := _visuals.enemy_portrait(_enemy_state.enemy_id)
	_enemy_portrait.texture = enemy_texture if enemy_texture != null else _make_enemy_placeholder_texture()
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
	if _active_drag:
		timer_state = TIMER_STATE_ACTIVE
	_sync_timer_display(_move_time_left if _active_drag else _timer_ready_seconds(), timer_state)


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
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func _format_intent_compact(intent: Dictionary) -> String:
	var label := _intent_action_label(String(intent.get("label", "Intent")))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	if attack > 0 and block > 0:
		return "%s Atk %d / Block %d" % [label, attack, block]
	if attack > 0:
		return "%s Atk %d" % [label, attack]
	if block > 0:
		return "%s Block %d" % [label, block]
	return label


func _intent_action_label(raw_label: String) -> String:
	var parts := raw_label.strip_edges().split(" ", false)
	var action_parts: Array[String] = []
	for part in parts:
		if not String(part).is_valid_int():
			action_parts.append(part)
	if action_parts.is_empty():
		return "Intent"
	return " ".join(action_parts)


func _append_turn_log(turn_log: Dictionary) -> void:
	if _combat_log_level == LOG_LEVEL_DETAILED:
		_append_turn_log_detailed(turn_log)
		return
	_append_turn_log_normal(turn_log)


func _resolve_trace_enabled() -> bool:
	return true


func _resolve_trace(start_ticks_usec: int, message: String) -> void:
	if not _resolve_trace_enabled():
		return
	if start_ticks_usec <= 0:
		return
	var elapsed_ms := maxi(0, int(float(Time.get_ticks_usec() - start_ticks_usec) / 1000.0))
	print("[ResolveTrace +%04dms] %s" % [elapsed_ms, message])


func _append_turn_log_normal(turn_log: Dictionary) -> void:
	var resolved_turn := int(turn_log.get("resolved_turn_index", 0))
	var combo_count := int(turn_log.get("combo_count", 0))
	var combo_count_with_bonus := int(turn_log.get("combo_count_with_bonus", combo_count))
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	_append_combat_log("---- Turn %d ----" % resolved_turn)
	_append_combat_log("Matches: combos=%d (effective %d) | %s" % [combo_count, combo_count_with_bonus, _format_matched_counts(matched_counts)])
	_append_combat_log(
		"Player gains: Heal +%d, Armor +%d, Gold +%d." % [
			int(turn_log.get("healed", 0)),
			int(turn_log.get("armor_gained", 0)),
			int(turn_log.get("gold_gained", 0)),
		]
	)
	_append_combat_log(
		"Damage dealt: Fire %d + Ice %d + Earth %d = %d (enemy blocked %d, enemy took %d)." % [
			int(turn_log.get("fire_damage", 0)),
			int(turn_log.get("ice_damage", 0)),
			int(turn_log.get("earth_damage", 0)),
			int(turn_log.get("total_elemental_damage", 0)),
			int(turn_log.get("enemy_blocked", 0)),
			int(turn_log.get("enemy_damage_taken", 0)),
		]
	)

	if bool(turn_log.enemy_intent_skipped):
		_append_combat_log("Enemy intent: skipped (enemy defeated first).")
	else:
		var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
		_append_combat_log(
			"Enemy intent: incoming %d, blocked %d, HP damage %d." % [
				int(enemy_attack.get("incoming", 0)),
				int(enemy_attack.get("blocked_by_armor", 0)),
				int(enemy_attack.get("hp_damage", 0)),
			]
		)

	_append_combat_log("Armor expired after enemy action: %d." % int(turn_log.get("expired_armor", 0)))
	_append_combat_log(
		"End state: Player HP %d/%d Armor %d Gold %d | Enemy HP %d/%d" % [
			_player_state.current_hp,
			_player_state.max_hp,
			_player_state.armor,
			_player_state.gold,
			_enemy_state.current_hp,
			_enemy_state.max_hp,
		]
	)


func _append_turn_log_detailed(turn_log: Dictionary) -> void:
	_append_turn_log_normal(turn_log)

	var combo_count := int(turn_log.get("combo_count", 0))
	var combo_flat_bonus := int(turn_log.get("combo_flat_bonus", 0))
	var combo_count_with_bonus := int(turn_log.get("combo_count_with_bonus", combo_count))
	var increase_combo_modifier := int(turn_log.get("increase_combo_modifier", 0))
	var more_combo_modifier := float(turn_log.get("more_combo_modifier", 1.0))
	var combo_multiplier_mult := float(turn_log.get("combo_multiplier_mult", 1.0))
	var damage_combo_multiplier := float(turn_log.get("damage_combo_multiplier", 0.0))
	var prep_armor_added := int(turn_log.get("prep_armor_added", 0))
	var flat_damage_bonus := int(turn_log.get("flat_damage_bonus", 0))
	var flat_heal_bonus := int(turn_log.get("flat_heal_bonus", 0))
	var flat_gold_bonus := int(turn_log.get("flat_gold_bonus", 0))
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	var orb_bonus_by_id: Dictionary = turn_log.get("orb_bonus_by_id", {})
	var modifier_sources: Array = turn_log.get("modifier_sources", [])

	_append_combat_log("Detailed combat breakdown:")
	_append_combat_log(
		"Modifier totals: combo+%d, combo_mult_x%.2f, prep_armor+%d, flat_damage+%d, flat_heal+%d, flat_gold+%d." % [
			combo_flat_bonus,
			combo_multiplier_mult,
			prep_armor_added,
			flat_damage_bonus,
			flat_heal_bonus,
			flat_gold_bonus,
		]
	)
	_append_combat_log(
		"Orb bonuses: F:+%d I:+%d E:+%d H:+%d A:+%d G:+%d." % [
			int(orb_bonus_by_id.get(OrbType.Id.FIRE, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.ICE, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.EARTH, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.HEART, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.ARMOR, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.GOLD, 0)),
		]
	)

	_append_combat_log("Formula path:")
	_append_combat_log("effective_combo = %d + %d = %d" % [combo_count, combo_flat_bonus, combo_count_with_bonus])
	_append_combat_log(
		"damage_multiplier = ((increase_combo_modifier + effective_combo) * more_combo_modifier) * combo_multiplier_mult = ((%d + %d) * %.2f) * %.2f = %.2f" % [
			increase_combo_modifier,
			combo_count_with_bonus,
			more_combo_modifier,
			combo_multiplier_mult,
			damage_combo_multiplier,
		]
	)
	var heart_orbs := int(matched_counts.get(OrbType.Id.HEART, 0))
	var armor_orbs := int(matched_counts.get(OrbType.Id.ARMOR, 0))
	var gold_orbs := int(matched_counts.get(OrbType.Id.GOLD, 0))
	var heart_mastery := _player_state.orb_value(OrbType.Id.HEART) - 1
	var armor_mastery := _player_state.orb_value(OrbType.Id.ARMOR) - 1
	var gold_mastery := _player_state.orb_value(OrbType.Id.GOLD) - 1
	var heart_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.HEART, 0))
	var armor_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.ARMOR, 0))
	var gold_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.GOLD, 0))
	var heart_base := int(turn_log.get("heart_base", 0))
	var armor_base := int(turn_log.get("armor_base", 0))
	var gold_base := int(turn_log.get("gold_base", 0))
	var heal_formula_total := heart_base + (flat_heal_bonus if heart_base > 0 else 0)
	var gold_formula_total := gold_base + (flat_gold_bonus if gold_base > 0 else 0)
	_append_combat_log(
		"Health: heart_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; heal = heart_base%s = %d (applied %d)." % [
			heart_orbs,
			heart_mastery,
			heart_orb_bonus,
			heart_base,
			(" + flat_heal_bonus(%d)" % flat_heal_bonus) if heart_base > 0 and flat_heal_bonus > 0 else "",
			heal_formula_total,
			int(turn_log.get("healed", 0)),
		]
	)
	_append_combat_log(
		"Armor: armor_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; armor_from_matches = round(armor_base * damage_multiplier) = round(%d * %.2f) = %d; total_armor_gain = armor_from_matches + prep_armor_bonus = %d + %d = %d." % [
			armor_orbs,
			armor_mastery,
			armor_orb_bonus,
			armor_base,
			armor_base,
			damage_combo_multiplier,
			int(turn_log.get("armor_gained", 0)),
			int(turn_log.get("armor_gained", 0)),
			prep_armor_added,
			int(turn_log.get("armor_gained", 0)) + prep_armor_added,
		]
	)
	_append_combat_log(
		"Gold: gold_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; gold = gold_base%s = %d (applied %d)." % [
			gold_orbs,
			gold_mastery,
			gold_orb_bonus,
			gold_base,
			(" + flat_gold_bonus(%d)" % flat_gold_bonus) if gold_base > 0 and flat_gold_bonus > 0 else "",
			gold_formula_total,
			int(turn_log.get("gold_gained", 0)),
		]
	)
	_append_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, OrbType.Id.FIRE, "fire", damage_combo_multiplier)
	_append_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, OrbType.Id.ICE, "ice", damage_combo_multiplier)
	_append_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, OrbType.Id.EARTH, "earth", damage_combo_multiplier)
	_append_combat_log(
		"total_damage = fire_damage + ice_damage + earth_damage + flat_damage_bonus = %d + %d + %d + %d = %d" % [
			int(turn_log.get("fire_damage", 0)),
			int(turn_log.get("ice_damage", 0)),
			int(turn_log.get("earth_damage", 0)),
			flat_damage_bonus,
			int(turn_log.get("total_elemental_damage", 0)),
		]
	)
	_append_combat_log(
		"final_enemy_damage = max(0, total_damage - enemy_block) = max(0, %d - %d) = %d" % [
			int(turn_log.get("total_elemental_damage", 0)),
			int(turn_log.get("enemy_blocked", 0)),
			int(turn_log.get("enemy_damage_taken", 0)),
		]
	)

	if modifier_sources.is_empty():
		_append_combat_log("Modifier sources: none.")
	else:
		_append_combat_log("Modifier sources:")
		for raw_source in modifier_sources:
			var source: Dictionary = raw_source
			_append_combat_log(
				"  - [%s] %s (%s): %s" % [
					String(source.get("source_type", "unknown")),
					String(source.get("display_name", source.get("source_id", "unknown"))),
					String(source.get("source_id", "")),
					JSON.stringify(source.get("combat_modifiers", {})),
				]
			)

	var player_start: Dictionary = turn_log.get("player_start", {})
	var player_end: Dictionary = turn_log.get("player_end", {})
	var enemy_start: Dictionary = turn_log.get("enemy_start", {})
	var enemy_end: Dictionary = turn_log.get("enemy_end", {})
	_append_combat_log(
		"Player delta: HP %d -> %d (delta %s), Armor %d -> %d (delta %s), Gold %d -> %d (delta %s)." % [
			int(player_start.get("hp", 0)),
			int(player_end.get("hp", 0)),
			_format_signed_delta(int(player_end.get("hp", 0)) - int(player_start.get("hp", 0))),
			int(player_start.get("armor", 0)),
			int(player_end.get("armor", 0)),
			_format_signed_delta(int(player_end.get("armor", 0)) - int(player_start.get("armor", 0))),
			int(player_start.get("gold", 0)),
			int(player_end.get("gold", 0)),
			_format_signed_delta(int(player_end.get("gold", 0)) - int(player_start.get("gold", 0))),
		]
	)
	_append_combat_log(
		"Enemy delta: HP %d -> %d (delta %s), Block %d -> %d (delta %s)." % [
			int(enemy_start.get("hp", 0)),
			int(enemy_end.get("hp", 0)),
			_format_signed_delta(int(enemy_end.get("hp", 0)) - int(enemy_start.get("hp", 0))),
			int(enemy_start.get("turn_block", 0)),
			int(enemy_end.get("turn_block", 0)),
			_format_signed_delta(int(enemy_end.get("turn_block", 0)) - int(enemy_start.get("turn_block", 0))),
		]
	)

	if bool(turn_log.get("enemy_intent_skipped", false)):
		_append_combat_log("Enemy attack resolution: skipped because enemy died before acting.")
	else:
		var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
		_append_combat_log(
			"Enemy attack resolution: incoming=%d, blocked_by_armor=%d, hp_damage=%d, post_hp=%d, post_armor=%d." % [
				int(enemy_attack.get("incoming", 0)),
				int(enemy_attack.get("blocked_by_armor", 0)),
				int(enemy_attack.get("hp_damage", 0)),
				int(enemy_attack.get("remaining_hp", 0)),
				int(enemy_attack.get("remaining_armor", 0)),
			]
		)
	_append_combat_log("Armor expiration after enemy action: %d." % int(turn_log.get("expired_armor", 0)))


func _append_detailed_element_formula_line(
	turn_log: Dictionary,
	matched_counts: Dictionary,
	orb_bonus_by_id: Dictionary,
	orb_id: int,
	element_name: String,
	damage_multiplier: float
) -> void:
	var orbs_matched := int(matched_counts.get(orb_id, 0))
	var mastery_level := _player_state.orb_value(orb_id) - 1
	var orb_bonus := int(orb_bonus_by_id.get(orb_id, 0))
	var base_key := "%s_base" % element_name
	var damage_key := "%s_damage" % element_name
	_append_combat_log(
		"%s: element_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; element_damage = round(element_base * damage_multiplier) = round(%d * %.2f) = %d" % [
			element_name.capitalize(),
			orbs_matched,
			mastery_level,
			orb_bonus,
			int(turn_log.get(base_key, 0)),
			int(turn_log.get(base_key, 0)),
			damage_multiplier,
			int(turn_log.get(damage_key, 0)),
		]
	)


func _format_signed_delta(value: int) -> String:
	if value >= 0:
		return "+%d" % value
	return "%d" % value


func _format_matched_counts(matched_counts: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count <= 0:
			continue
		parts.append("%s=%d" % [OrbType.debug_symbol(orb_id), count])
	if parts.is_empty():
		return "none"
	return ", ".join(parts)


func _append_combat_log(message: String, is_command_output: bool = false) -> void:
	var timestamp := Time.get_time_string_from_system()
	_combat_log_lines.append("[%s] %s" % [timestamp, message])
	_combat_log_command_flags.append(is_command_output)
	if _combat_log_lines.size() > MAX_COMBAT_LOG_LINES:
		_combat_log_lines = _combat_log_lines.slice(_combat_log_lines.size() - MAX_COMBAT_LOG_LINES, _combat_log_lines.size())
		_combat_log_command_flags = _combat_log_command_flags.slice(
			_combat_log_command_flags.size() - MAX_COMBAT_LOG_LINES,
			_combat_log_command_flags.size()
		)
	_refresh_combat_log_display()


func _refresh_combat_log_display() -> void:
	if _combat_log_text == null:
		return
	_combat_log_text.clear()
	var line_count := _combat_log_lines.size()
	for index in range(line_count):
		var line_text := _combat_log_lines[index]
		if index < line_count - 1:
			line_text += "\n"
		if index < _combat_log_command_flags.size() and _combat_log_command_flags[index]:
			_combat_log_text.push_color(COMMAND_OUTPUT_LOG_COLOR)
			_combat_log_text.add_text(line_text)
			_combat_log_text.pop()
		else:
			_combat_log_text.add_text(line_text)
	_combat_log_text.scroll_to_line(maxi(0, line_count - 1))


func debug_console_log(message: String) -> void:
	_append_combat_log(message)


func _format_slot_line(slot_values: Array) -> String:
	var parts: Array[String] = []
	for value in slot_values:
		var text := String(value)
		parts.append(text if text != "" else "-")
	return "[" + ", ".join(parts) + "]"


func _format_id_line(values: Array) -> String:
	if values.is_empty():
		return "-"
	var rendered: Array[String] = []
	for value in values:
		rendered.append(String(value))
	return "[" + ", ".join(rendered) + "]"


func _format_mastery_line(levels: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		parts.append("%s:%d" % [OrbType.debug_symbol(orb_id), int(levels.get(orb_id, 0))])
	return "[" + ", ".join(parts) + "]"


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
	var tex := _visuals.vfx_texture(effect_name)
	if tex == null:
		return
	_spawn_vfx_texture(tex, global_center, draw_size, lifetime, modulate_color)


func _spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if texture == null:
		return
	var sprite := TextureRect.new()
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.modulate = modulate_color
	_vfx_layer.add_child(sprite)
	var local_center: Vector2 = _vfx_layer.get_global_transform_with_canvas().affine_inverse() * global_center
	sprite.position = local_center - draw_size * 0.5
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, maxf(0.08, lifetime))
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


func _spawn_replay_impact(global_center: Vector2, impact_kind: String, draw_size: Vector2, lifetime: float) -> void:
	if global_center == Vector2.ZERO:
		return
	var impact_texture := _visuals.mastery_impact_texture(impact_kind)
	if impact_texture == null:
		impact_texture = _visuals.vfx_texture("orb_clear")
	_spawn_vfx_texture(impact_texture, global_center, draw_size, lifetime, Color(1.0, 1.0, 1.0, 0.92))


func _mastery_impact_kind(orb_id: int) -> String:
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


func _mastery_card_source(orb_id: int) -> Control:
	var elemental_mastery_cards := _elemental_mastery_cards
	if _player_loadout_hud == null or elemental_mastery_cards == null:
		return null

	var card := _player_loadout_hud.get_combat_mastery_card(elemental_mastery_cards, orb_id)
	if card == null:
		var fallback_name := "CombatMasteryCard%d" % orb_id
		card = elemental_mastery_cards.get_node_or_null(fallback_name) as Control
	if card == null:
		return null

	var slot := card.get_node_or_null("CardPanel") as Control
	if slot == null:
		return card
	var icon := slot.get_node_or_null("MasteryIcon")
	if icon == null and card.get_node_or_null("MasteryIconSlot") is Control:
		slot = card.get_node_or_null("MasteryIconSlot") as Control
		icon = slot.get_node_or_null("MasteryIcon")
	return icon if icon is Control else slot


func _control_global_center(control: Control, vertical_bias: float = 0.5) -> Vector2:
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
	var source: Control = null
	var target_global: Vector2 = Vector2.ZERO
	var orb_id: int = OrbType.Id.FIRE
	var beam_lifetime: float = lifetime

	if source_orb_or_node is int:
		orb_id = int(source_orb_or_node)
		source = _mastery_card_source(orb_id)
		if source == null:
			return
		target_global = target_or_start
		if orb_or_target is Vector2:
			target_global = orb_or_target
		elif orb_or_target is float:
			beam_lifetime = float(orb_or_target)
	elif source_orb_or_node is Control:
		source = source_orb_or_node
		if orb_or_target is int:
			orb_id = int(orb_or_target)
		elif orb_or_target is float:
			beam_lifetime = float(orb_or_target)
		target_global = target_or_start
	else:
		return

	if source == null or target_global == Vector2.ZERO:
		return

	if _vfx_layer == null or source == null:
		return
	var source_point := _control_global_center(source, 0.5)
	if source_point == Vector2.ZERO:
		return
	var beam_texture := _visuals.mastery_beam_texture(orb_id)
	if beam_texture == null:
		return

	var inverse_canvas_transform: Transform2D = _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	var source_local: Vector2 = inverse_canvas_transform * source_point
	var target_local: Vector2 = inverse_canvas_transform * target_global
	var delta: Vector2 = target_local - source_local
	var distance: float = delta.length()
	if distance <= 1.0:
		return

	var beam := TextureRect.new()
	beam.texture = beam_texture
	beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	beam.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	beam.stretch_mode = TextureRect.STRETCH_SCALE
	var beam_thickness := 28.0
	beam.size = Vector2(distance, beam_thickness)
	beam.pivot_offset = Vector2(0.0, beam_thickness * 0.5)
	beam.position = source_local - Vector2(0.0, beam_thickness * 0.5)
	beam.rotation = delta.angle()
	beam.modulate = Color(1.0, 1.0, 1.0, 1.0)
	beam.z_index = 92
	_vfx_layer.add_child(beam)

	var fade_tween := create_tween()
	fade_tween.tween_property(beam, "modulate:a", 0.0, maxf(0.08, beam_lifetime))
	fade_tween.finished.connect(func() -> void:
		if is_instance_valid(beam):
			beam.queue_free()
	)


func _on_resolver_match_found(groups: Array) -> void:
	_audio_play_sfx("match")
	_status_label.text = "Matches found: %d group(s)." % groups.size()
	_status_label.modulate = STATUS_COLOR_WARNING


func _spawn_match_clear_bursts(groups: Array) -> void:
	for raw_group in groups:
		var group: Dictionary = raw_group
		var cells: Array = group.get("cells", [])
		var matched_count: int = cells.size()
		var orb_id := int(group.get("orb_id", OrbType.Id.FIRE))
		var burst_size := Vector2(60.0, 60.0)
		if matched_count >= 5:
			burst_size = Vector2(78.0, 78.0)
		elif matched_count >= 4:
			burst_size = Vector2(68.0, 68.0)
		for raw_cell in cells:
			var cell: Vector2i = raw_cell
			if not _board_view.is_cell_valid(cell):
				continue
			var board_center: Vector2 = _board_view.get_cell_center(cell)
			var global_center: Vector2 = _board_view.get_global_transform_with_canvas() * board_center
			_spawn_match_clear_burst(global_center, burst_size, orb_id)


func _spawn_match_clear_burst(global_center: Vector2, draw_size: Vector2, orb_id: int) -> void:
	var burst_texture := _match_clear_burst()
	var orb_tint := OrbType.color(orb_id)
	orb_tint = orb_tint.lerp(Color.WHITE, 0.42)
	orb_tint.a = 0.72
	_spawn_vfx_texture(burst_texture, global_center, draw_size, 0.22, orb_tint)


func _match_clear_burst() -> Texture2D:
	if _match_clear_burst_texture != null:
		return _match_clear_burst_texture
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 0.0))
	var center := Vector2(47.5, 47.5)
	for y in 96:
		for x in 96:
			var point := Vector2(float(x), float(y))
			var offset := point - center
			var distance := offset.length()
			var radial_alpha: float = clampf(1.0 - distance / 44.0, 0.0, 1.0)
			var ring_alpha: float = maxf(0.0, 1.0 - absf(distance - 24.0) / 7.0) * 0.38
			var axis_alpha: float = 0.0
			if absf(offset.x) < 2.0 or absf(offset.y) < 2.0:
				axis_alpha = clampf(1.0 - distance / 43.0, 0.0, 1.0) * 0.74
			if absf(absf(offset.x) - absf(offset.y)) < 1.7:
				axis_alpha = maxf(axis_alpha, clampf(1.0 - distance / 39.0, 0.0, 1.0) * 0.44)
			var alpha: float = maxf(radial_alpha * radial_alpha * 0.34, maxf(ring_alpha, axis_alpha))
			if alpha > 0.01:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	_match_clear_burst_texture = ImageTexture.create_from_image(image)
	return _match_clear_burst_texture


func _spawn_combo_floating_text(group: Dictionary, combo_value: int) -> void:
	var cells: Array = group.get("cells", [])
	if cells.is_empty():
		return
	var combo_text := "COMBO x%d" % combo_value
	_audio_play_sfx("combo")
	var font_size := mini(COMBO_POPUP_MAX_FONT_SIZE, COMBO_POPUP_BASE_FONT_SIZE + maxi(0, combo_value - 1) * 6)

	var combo_panel := _ensure_combo_popup_panel()
	combo_panel.position = _center_combo_popup_position()
	combo_panel.modulate.a = 1.0
	_combo_popup_label.text = combo_text
	_combo_popup_label.add_theme_font_size_override("font_size", font_size)
	_combo_popup_label.size = COMBO_POPUP_SIZE
	if _combo_popup_fade_tween != null and _combo_popup_fade_tween.is_valid():
		_combo_popup_fade_tween.kill()

	combo_panel.pivot_offset = combo_panel.size * 0.5
	combo_panel.scale = Vector2(1.0, 1.0)
	var pulse_scale := 1.0 + minf(0.22, float(combo_value) * 0.018)
	var pop_tween := create_tween()
	pop_tween.tween_property(combo_panel, "scale", Vector2(pulse_scale, pulse_scale), 0.07)
	pop_tween.tween_property(combo_panel, "scale", Vector2(1.0, 1.0), 0.10)


func _ensure_combo_popup_panel() -> PanelContainer:
	if is_instance_valid(_combo_popup_panel):
		return _combo_popup_panel
	var combo_panel := PanelContainer.new()
	combo_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combo_panel.size = COMBO_POPUP_SIZE
	combo_panel.custom_minimum_size = COMBO_POPUP_SIZE
	combo_panel.z_index = 80
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	panel_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	panel_style.set_border_width_all(0)
	combo_panel.add_theme_stylebox_override("panel", panel_style)

	var combo_label := Label.new()
	combo_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", COMBO_POPUP_BASE_FONT_SIZE)
	combo_label.add_theme_constant_override("outline_size", 7)
	combo_label.add_theme_color_override("font_outline_color", Color(0.05, 0.02, 0.00, 0.96))
	combo_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.28, 1.0))
	combo_label.position = Vector2.ZERO
	combo_label.size = COMBO_POPUP_SIZE
	combo_panel.add_child(combo_label)
	_board_panel.add_child(combo_panel)
	_combo_popup_panel = combo_panel
	_combo_popup_label = combo_label
	return combo_panel


func _finish_combo_popup() -> void:
	if not is_instance_valid(_combo_popup_panel):
		return
	var combo_panel := _combo_popup_panel
	_combo_popup_fade_tween = create_tween()
	_combo_popup_fade_tween.tween_interval(0.18)
	_combo_popup_fade_tween.tween_property(combo_panel, "modulate:a", 0.0, 0.36)
	_combo_popup_fade_tween.finished.connect(func() -> void:
		if is_instance_valid(combo_panel):
			combo_panel.queue_free()
		_combo_popup_panel = null
		_combo_popup_label = null
	)


func _center_combo_popup_position() -> Vector2:
	return _board_surface.position + (_board_surface.size - COMBO_POPUP_SIZE) * 0.5


func _pulse_label(target: Label, tint: Color) -> void:
	target.modulate = tint
	var tween := create_tween()
	tween.tween_property(target, "modulate", STATUS_COLOR_NEUTRAL, 0.28)


func _on_viewport_size_changed() -> void:
	_apply_combat_layout()


func _apply_combat_layout() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.y <= 0.0:
		return
	var aspect := viewport_size.x / viewport_size.y
	var is_compact := aspect < 0.85
	var is_low_vertical := viewport_size.y < 760.0
	_is_low_vertical_layout = is_low_vertical

	var design_aspect := DESIGN_SIZE.x / DESIGN_SIZE.y
	var fits_tall_portrait := aspect <= design_aspect
	var scale_factor: float
	if fits_tall_portrait:
		scale_factor = viewport_size.x / DESIGN_SIZE.x
		_layout_root.size = Vector2(DESIGN_SIZE.x, viewport_size.y / maxf(0.001, scale_factor))
		_layout_root.position = Vector2(0.0, 0.0)
	else:
		scale_factor = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
		var scaled_size := DESIGN_SIZE * scale_factor
		_layout_root.position = (viewport_size - scaled_size) * 0.5
		_layout_root.size = DESIGN_SIZE
	_layout_root.scale = Vector2(scale_factor, scale_factor)
	_update_runtime_layout_rects()

	_apply_design_rect(_top_bar, _layout_top_bar_rect)
	_apply_design_rect(_enemy_panel, _layout_enemy_panel_rect)
	_apply_design_rect(_combat_strip, _layout_combat_strip_rect)
	_apply_design_rect(_board_panel, _layout_board_panel_rect)
	_player_loadout_hud.set_player_hud_layout_override({
		"section": _layout_player_hud_section_rect,
	})
	_player_loadout_hud.update_player_hud_layout()
	_apply_enemy_panel_layout()
	_apply_combat_strip_layout()
	_apply_board_panel_layout()
	_apply_player_panel_layout()

	if is_low_vertical:
		_mastery_strip.visible = false
		_relic_row.visible = false
	_debug_overlay.anchor_left = 0.08 if is_compact else 0.58
	_debug_overlay.anchor_top = 0.05
	_debug_overlay.anchor_right = 0.985
	_debug_overlay.anchor_bottom = 0.97


func _apply_design_rect(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size


func _apply_enemy_panel_layout() -> void:
	_enemy_panel_root.position = Vector2.ZERO
	_enemy_panel_root.size = _layout_enemy_panel_rect.size
	_apply_design_rect(_intent_row, ENEMY_INTENT_RECT)
	_apply_design_rect(_enemy_stage, ENEMY_STAGE_RECT)
	_apply_design_rect(_enemy_hp_row, ENEMY_HP_ROW_RECT)
	_intent_badge.custom_minimum_size = Vector2(56, 56)
	_enemy_portrait.size = ENEMY_PORTRAIT_SIZE
	_enemy_portrait.position = Vector2(
		(ENEMY_STAGE_RECT.size.x - ENEMY_PORTRAIT_SIZE.x) * 0.5,
		ENEMY_STAGE_RECT.size.y - ENEMY_PORTRAIT_SIZE.y
	)
	_enemy_hp_bar.size = ENEMY_HP_BAR_SIZE
	_enemy_hp_bar.position = Vector2((ENEMY_HP_ROW_RECT.size.x - ENEMY_HP_BAR_SIZE.x) * 0.5, 0.0)
	_enemy_label.position = Vector2(0.0, 22.0)
	_enemy_label.size = Vector2(ENEMY_HP_ROW_RECT.size.x, 28.0)


func _apply_combat_strip_layout() -> void:
	_timer_track.position = Vector2(
		(_layout_combat_strip_rect.size.x - TIMER_TRACK_SIZE.x) * 0.5,
		(_layout_combat_strip_rect.size.y - TIMER_TRACK_SIZE.y) * 0.5
	)
	_timer_track.size = TIMER_TRACK_SIZE
	_timer_icon.custom_minimum_size = TIMER_ICON_SIZE
	_sync_timer_display(_move_time_left if _active_drag else _timer_ready_seconds(), TIMER_STATE_ACTIVE if _active_drag else TIMER_STATE_READY)


func _apply_board_panel_layout() -> void:
	_board_panel.clip_contents = true
	var board_aspect := BOARD_SURFACE_SIZE.x / BOARD_SURFACE_SIZE.y
	var max_board_height := maxf(64.0, _layout_board_panel_rect.size.y - BOARD_SURFACE_TOP - BOARD_SURFACE_BOTTOM_PADDING)
	var max_board_width := maxf(64.0, _layout_board_panel_rect.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0))
	var board_height := minf(max_board_height, max_board_width / maxf(0.001, board_aspect))
	var board_width := board_height * board_aspect
	var board_surface_size := Vector2(board_width, board_height)
	_board_surface.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_board_surface.position = Vector2((_layout_board_panel_rect.size.x - board_surface_size.x) * 0.5, BOARD_SURFACE_TOP)
	_board_surface.size = board_surface_size
	_board_view_control.custom_minimum_size = board_surface_size
	var shadow_position := _board_surface.position + BOARD_SHADOW_OFFSET - BOARD_SHADOW_EXPAND * 0.5
	var shadow_size := board_surface_size + BOARD_SHADOW_EXPAND
	shadow_size.x = minf(shadow_size.x, _layout_board_panel_rect.size.x)
	shadow_size.y = minf(shadow_size.y, _layout_board_panel_rect.size.y)
	shadow_position.x = clampf(shadow_position.x, 0.0, maxf(0.0, _layout_board_panel_rect.size.x - shadow_size.x))
	shadow_position.y = clampf(shadow_position.y, 0.0, maxf(0.0, _layout_board_panel_rect.size.y - shadow_size.y))
	_board_shadow.position = shadow_position
	_board_shadow.size = shadow_size
	if _outcome_overlay != null:
		_outcome_overlay.sync_layout(_layout_board_panel_rect)


func _update_runtime_layout_rects() -> void:
	_layout_top_bar_rect = TOP_BAR_RECT
	_layout_enemy_panel_rect = ENEMY_PANEL_RECT
	_layout_combat_strip_rect = COMBAT_STRIP_RECT
	_layout_board_panel_rect = BOARD_PANEL_RECT
	_layout_player_hud_section_rect = Rect2(Vector2(0, 1092), Vector2(1080, 828))
	var extra_height := maxf(0.0, _layout_root.size.y - DESIGN_SIZE.y)
	if extra_height <= 0.0:
		return
	var board_top := BOARD_PANEL_RECT.position.y
	var board_gap := 16.0
	var player_section_base_size := _layout_player_hud_section_rect.size
	var max_board_width := BOARD_PANEL_RECT.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0)
	var board_panel_max_height := (max_board_width * (BOARD_SURFACE_SIZE.y / BOARD_SURFACE_SIZE.x)) + BOARD_SURFACE_TOP + BOARD_SURFACE_BOTTOM_PADDING
	var board_growth_capacity := maxf(0.0, board_panel_max_height - BOARD_PANEL_RECT.size.y)
	var board_growth := minf(extra_height, board_growth_capacity)
	var player_growth := extra_height - board_growth
	_layout_board_panel_rect = Rect2(BOARD_PANEL_RECT.position, Vector2(BOARD_PANEL_RECT.size.x, BOARD_PANEL_RECT.size.y + board_growth))
	var section_position := Vector2(0.0, board_top + _layout_board_panel_rect.size.y + board_gap)
	_layout_player_hud_section_rect = Rect2(section_position, Vector2(player_section_base_size.x, player_section_base_size.y + player_growth))


func _apply_player_panel_layout() -> void:
	_apply_design_rect(_stat_chip_row, PLAYER_STAT_CHIP_RECT)
	_apply_design_rect(_combat_meta_row, PLAYER_META_RECT)
	_apply_design_rect(_turn_summary_label, PLAYER_SUMMARY_RECT)
	_mastery_root.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	_hero_level_badge.visible = false
	_player_armor_bar.visible = false
	_player_armor_label.visible = false
	_stat_chip_row.visible = false
	_combat_meta_row.visible = false
	_turn_summary_label.visible = false
	_mastery_strip.visible = false
	_apply_loadout_rail_layout()
	_player_portrait.custom_minimum_size = PLAYER_PORTRAIT_SIZE


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
	_player_loadout_hud.apply_loadout_rail_layout(_equipment_icons, EQUIPMENT_RAIL_RECT, _consumable_icons, CONSUMABLE_RAIL_RECT)


func _ensure_placeholder_visuals() -> void:
	if _timer_icon.texture == null:
		_timer_icon.texture = _make_timer_placeholder_texture()
	_timer_icon.visible = true
	if _intent_badge.texture == null:
		_intent_badge.texture = _make_intent_placeholder_texture()
	_intent_badge.visible = true
	var enemy_texture: Texture2D = null
	if _enemy_state != null:
		enemy_texture = _visuals.enemy_portrait(_enemy_state.enemy_id)
	if enemy_texture == null:
		enemy_texture = _make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_texture
	_enemy_portrait.visible = true
	var hero_texture := _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = _make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture
	_player_portrait.visible = true


func _refresh_character_portraits() -> void:
	var enemy_texture: Texture2D = null
	if _enemy_state != null:
		enemy_texture = _visuals.enemy_portrait(_enemy_state.enemy_id)
	if enemy_texture == null:
		enemy_texture = _make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_texture
	var hero_texture := _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = _make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture


func _make_timer_placeholder_texture() -> Texture2D:
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.04, 0.10, 0.16, 0.0))
	image.fill_rect(Rect2i(28, 14, 40, 12), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(28, 70, 40, 12), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(34, 24, 28, 14), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(34, 58, 28, 14), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(38, 38, 20, 20), Color(0.44, 0.74, 1.0, 0.95))
	return ImageTexture.create_from_image(image)


func _make_intent_placeholder_texture() -> Texture2D:
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.06, 0.08, 0.11, 0.95))
	image.fill_rect(Rect2i(4, 4, 88, 88), Color(0.15, 0.10, 0.08, 1.0))
	image.fill_rect(Rect2i(8, 8, 80, 80), Color(0.45, 0.12, 0.10, 1.0))
	image.fill_rect(Rect2i(44, 18, 8, 60), Color(0.92, 0.86, 0.72, 1.0))
	image.fill_rect(Rect2i(26, 48, 44, 8), Color(0.92, 0.86, 0.72, 1.0))
	return ImageTexture.create_from_image(image)


func _make_enemy_placeholder_texture() -> Texture2D:
	var image := Image.create(260, 230, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.08, 0.11, 0.94))
	image.fill_rect(Rect2i(4, 4, 252, 222), Color(0.48, 0.38, 0.18, 0.95))
	image.fill_rect(Rect2i(8, 8, 244, 214), Color(0.09, 0.13, 0.17, 0.98))
	image.fill_rect(Rect2i(98, 28, 64, 58), Color(0.19, 0.24, 0.29, 1.0))
	image.fill_rect(Rect2i(72, 92, 116, 106), Color(0.16, 0.21, 0.27, 1.0))
	image.fill_rect(Rect2i(42, 122, 50, 74), Color(0.13, 0.18, 0.24, 1.0))
	image.fill_rect(Rect2i(168, 122, 50, 74), Color(0.13, 0.18, 0.24, 1.0))
	return ImageTexture.create_from_image(image)


func _make_hero_placeholder_texture() -> Texture2D:
	var image := Image.create(192, 192, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.07, 0.10, 0.96))
	image.fill_rect(Rect2i(4, 4, 184, 184), Color(0.50, 0.38, 0.18, 0.95))
	image.fill_rect(Rect2i(8, 8, 176, 176), Color(0.11, 0.13, 0.17, 0.98))
	image.fill_rect(Rect2i(66, 34, 60, 58), Color(0.20, 0.23, 0.28, 1.0))
	image.fill_rect(Rect2i(44, 104, 104, 58), Color(0.16, 0.19, 0.25, 1.0))
	image.fill_rect(Rect2i(134, 120, 28, 42), Color(0.16, 0.27, 0.42, 1.0))
	return ImageTexture.create_from_image(image)


func _apply_zone_guides() -> void:
	_set_zone_guide(_top_bar, "TopBar")
	_set_zone_guide(_enemy_panel, "EnemyPanel")
	_set_zone_guide(_combat_strip, "CombatStrip")
	_set_zone_guide(_board_panel, "BoardPanel")
	_set_zone_guide(_player_panel, "PlayerPanel")


func _set_zone_guide(zone: Control, label_text: String) -> void:
	if zone == null:
		return
	if _zone_guides_enabled:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.03, 0.06, 0.10, 0.94)
		style.border_color = Color(0.90, 0.72, 0.28, 0.95)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		if zone is PanelContainer:
			(zone as PanelContainer).add_theme_stylebox_override("panel", style)
		else:
			var frame := zone.get_node_or_null("ZoneGuideFrame")
			if frame == null:
				frame = Panel.new()
				frame.name = "ZoneGuideFrame"
				frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
				frame.anchors_preset = Control.PRESET_FULL_RECT
				zone.add_child(frame)
			(frame as Panel).add_theme_stylebox_override("panel", style)
		var guide := zone.get_node_or_null("ZoneGuideLabel")
		if guide == null:
			guide = Label.new()
			guide.name = "ZoneGuideLabel"
			guide.mouse_filter = Control.MOUSE_FILTER_IGNORE
			guide.position = Vector2(6, 4)
			zone.add_child(guide)
		(guide as Label).text = label_text
		(guide as Label).add_theme_color_override("font_color", Color(0.95, 0.80, 0.30, 1.0))
		(guide as Label).add_theme_font_size_override("font_size", 12)
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.025, 0.045, 0.07, 0.94)
		style.border_color = Color(0.18, 0.24, 0.31, 0.90)
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		if zone is PanelContainer:
			(zone as PanelContainer).add_theme_stylebox_override("panel", style)
		else:
			var frame := zone.get_node_or_null("ZoneGuideFrame")
			if frame != null:
				frame.queue_free()
		var guide := zone.get_node_or_null("ZoneGuideLabel")
		if guide != null:
			guide.queue_free()


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
