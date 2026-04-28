extends Control

@onready var _board_surface: BoardSurface = %BoardSurface
@onready var _board_view: BoardView = _board_surface.board_view()
@onready var _background: TextureRect = %Background
@onready var _status_label: Label = %StatusLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _run_progress_label: Label = %RunProgressLabel
@onready var _turn_summary_label: Label = %TurnSummaryLabel
@onready var _combo_summary_label: Label = %ComboSummaryLabel
@onready var _player_label: Label = %PlayerStateLabel
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
@onready var _combat_strip_row: HBoxContainer = %CombatStripRow
@onready var _timer_badge_panel: PanelContainer = %TimerBadgePanel
@onready var _board_frame: PanelContainer = $"CombatLayoutRoot/BoardPanel/BoardSurface/BoardFrame"
@onready var _board_panel: Control = %BoardPanel
@onready var _player_panel: PanelContainer = %PlayerPanel
@onready var _player_panel_root: Control = %PlayerPanelRoot
@onready var _player_stats_row: HBoxContainer = %PlayerStatsRow
@onready var _combat_meta_row: HBoxContainer = %CombatMetaRow
@onready var _loadout_row: VBoxContainer = %LoadoutRow
@onready var _combat_log_frame: PanelContainer = $"DebugOverlay/DebugVBox/CombatLogFrame"
@onready var _debug_overlay: PanelContainer = %DebugOverlay
@onready var _title_label: Label = %TitleLabel
@onready var _hint_label: Label = %HintLabel
@onready var _enemy_portrait: TextureRect = %EnemyPortrait
@onready var _intent_badge: TextureRect = %IntentBadge
@onready var _enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var _move_timer_bar: ProgressBar = %MoveTimerBar
@onready var _player_hp_bar: ProgressBar = %PlayerHpBar
@onready var _player_armor_bar: ProgressBar = %PlayerArmorBar
@onready var _player_portrait: TextureRect = %PlayerPortrait
@onready var _equipment_icons: HBoxContainer = %EquipmentIcons
@onready var _consumable_icons: HBoxContainer = %ConsumableIcons
@onready var _relic_icons: HBoxContainer = %RelicIcons
@onready var _mastery_icons: HBoxContainer = %MasteryIcons
@onready var _relic_row: HBoxContainer = $"CombatLayoutRoot/PlayerPanel/PlayerPanelRoot/LoadoutRow/RelicRow"
@onready var _mastery_row: HBoxContainer = $"CombatLayoutRoot/PlayerPanel/PlayerPanelRoot/LoadoutRow/MasteryRow"
@onready var _build_row_label: Label = $"CombatLayoutRoot/PlayerPanel/PlayerPanelRoot/LoadoutRow/BuildRowLabel"
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
const TEST_EQUIPMENT_IDS: Array[String] = [
	"shortsword",
	"buckler",
]
const TEST_CONSUMABLE_ID := "fire_scroll"

const COMBAT_PHASE_INTENT_PREVIEW := 0
const COMBAT_PHASE_VICTORY := 6
const COMBAT_PHASE_DEFEAT := 7
const MOVE_TIMER_MAX_SECONDS := 5.0
const MAX_COMBAT_LOG_LINES := 120
const COMMAND_OUTPUT_LOG_COLOR := Color(0.45, 0.95, 0.45, 1.0)
const LOG_LEVEL_NORMAL := "normal"
const LOG_LEVEL_DETAILED := "detailed"
const STATUS_COLOR_NEUTRAL := Color(1.0, 1.0, 1.0, 1.0)
const STATUS_COLOR_POSITIVE := Color(0.65, 1.0, 0.72, 1.0)
const STATUS_COLOR_WARNING := Color(1.0, 0.86, 0.54, 1.0)
const STATUS_COLOR_NEGATIVE := Color(1.0, 0.62, 0.62, 1.0)
const ICON_INNER_SIZE := Vector2(42, 42)
const SLOT_SIZE := Vector2(48, 48)
const DESIGN_SIZE := Vector2(1080, 1920)
const ROOT_RECT := Rect2(Vector2(16, 0), Vector2(1048, 1920))
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 58))
const ENEMY_PANEL_RECT := Rect2(Vector2(16, 72), Vector2(1048, 360))
const COMBAT_STRIP_RECT := Rect2(Vector2(16, 438), Vector2(1048, 72))
const BOARD_PANEL_RECT := Rect2(Vector2(16, 520), Vector2(1048, 820))
const PLAYER_PANEL_RECT := Rect2(Vector2(16, 1360), Vector2(1048, 520))
const ENEMY_INTENT_RECT := Rect2(Vector2(296, 16), Vector2(456, 60))
const ENEMY_STAGE_RECT := Rect2(Vector2(0, 76), Vector2(1048, 230))
const ENEMY_HP_ROW_RECT := Rect2(Vector2(0, 306), Vector2(1048, 52))
const ENEMY_PORTRAIT_SIZE := Vector2(260, 230)
const ENEMY_HP_BAR_SIZE := Vector2(620, 22)
const BOARD_SURFACE_SIZE := Vector2(620, 744)
const BOARD_SURFACE_TOP := 22.0
const PLAYER_STATS_RECT := Rect2(Vector2(30, 28), Vector2(988, 132))
const PLAYER_META_RECT := Rect2(Vector2(30, 168), Vector2(988, 32))
const PLAYER_SUMMARY_RECT := Rect2(Vector2(30, 206), Vector2(988, 28))
const PLAYER_LOADOUT_RECT := Rect2(Vector2(30, 244), Vector2(988, 238))
const PLAYER_PORTRAIT_SIZE := Vector2(112, 112)
const COMBAT_STRIP_INSET := 12.0
const TIMER_BADGE_SIZE := Vector2(100, 48)
const COMBO_BLOCK_WIDTH := 140.0
const FONT_SIZE_TITLE := 20
const FONT_SIZE_VALUE := 18
const FONT_SIZE_META := 15
const FONT_SIZE_ROW_LABEL := 14

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
var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _is_low_vertical_layout := false
var _zone_guides_enabled := false


func _ready() -> void:
	_consumable_rng.randomize()
	_background.texture = null
	_background.modulate = Color(0.16, 0.17, 0.20, 1.0)
	_board_view.set_orb_texture_map({
		OrbType.Id.FIRE: _visuals.orb_texture(OrbType.Id.FIRE),
		OrbType.Id.ICE: _visuals.orb_texture(OrbType.Id.ICE),
		OrbType.Id.EARTH: _visuals.orb_texture(OrbType.Id.EARTH),
		OrbType.Id.HEART: _visuals.orb_texture(OrbType.Id.HEART),
		OrbType.Id.ARMOR: _visuals.orb_texture(OrbType.Id.ARMOR),
		OrbType.Id.GOLD: _visuals.orb_texture(OrbType.Id.GOLD),
	})
	_apply_visual_chrome()
	_resolver.match_found.connect(_on_resolver_match_found)
	_resolver.cells_cleared.connect(_on_resolver_cells_cleared)
	_resolver.gravity_applied.connect(_on_resolver_gravity_applied)
	_resolver.refill_applied.connect(_on_resolver_refill_applied)
	_resolver.cascade_step_complete.connect(_on_resolver_cascade_step_complete)
	_resolver.resolve_complete.connect(_on_resolver_complete)
	_initialize_combat_state()
	_create_new_board()
	_board_view.gui_input.connect(_on_board_view_gui_input)
	_debug_overlay.visible = false
	if _console_input.visible:
		_console_input.text_submitted.connect(_on_console_input_text_submitted)
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	set_process(true)
	_apply_combat_layout()
	_begin_turn_preview()
	if _console_input.visible:
		_console_input.grab_focus()


func _apply_visual_chrome() -> void:
	# Keep chrome code-driven to avoid any baked checkerboard artifacts from generated sheets.
	_board_view.cell_frame_texture = null
	_board_view.cell_spacing = 4.0
	_board_view.board_padding = 8.0
	_board_view.orb_scale_in_cell = 0.92
	_board_view.cell_background = Color(0.07, 0.09, 0.12, 0.96)
	_board_view.board_background = Color(0.03, 0.04, 0.06, 0.96)

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.03, 0.06, 0.10, 0.94)
	frame_style.border_color = Color(0.62, 0.49, 0.23, 0.92)
	frame_style.set_border_width_all(2)
	frame_style.set_corner_radius_all(6)
	frame_style.content_margin_left = 8.0
	frame_style.content_margin_right = 8.0
	frame_style.content_margin_top = 6.0
	frame_style.content_margin_bottom = 6.0

	_top_bar.add_theme_stylebox_override("panel", frame_style)
	_enemy_panel.add_theme_stylebox_override("panel", frame_style)
	_combat_strip.add_theme_stylebox_override("panel", frame_style)
	_board_frame.add_theme_stylebox_override("panel", frame_style)
	_player_panel.add_theme_stylebox_override("panel", frame_style)
	_debug_overlay.add_theme_stylebox_override("panel", frame_style)
	_combat_log_frame.add_theme_stylebox_override("panel", frame_style)

	_apply_progressbar_flat_style(_enemy_hp_bar, Color(0.70, 0.12, 0.13, 1.0))
	_apply_progressbar_flat_style(_move_timer_bar, Color(0.14, 0.46, 0.82, 1.0))
	_apply_progressbar_flat_style(_player_hp_bar, Color(0.78, 0.16, 0.17, 1.0))
	_apply_progressbar_flat_style(_player_armor_bar, Color(0.16, 0.50, 0.86, 1.0))

	var ui_text_color := Color(0.95, 0.96, 0.98, 1.0)
	for label in [_title_label, _hint_label, _timer_label, _combo_summary_label, _run_progress_label, _phase_label, _turn_summary_label, _player_label, _enemy_label, _intent_label]:
		label.add_theme_color_override("font_color", ui_text_color)
	_title_label.add_theme_font_size_override("font_size", FONT_SIZE_TITLE)
	_hint_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_intent_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_enemy_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_timer_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_combo_summary_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_player_label.add_theme_font_size_override("font_size", FONT_SIZE_VALUE)
	_run_progress_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_phase_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_turn_summary_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	_build_row_label.add_theme_font_size_override("font_size", FONT_SIZE_META)
	for row_label in [_equipment_row_label, _consumable_row_label, _relic_row_label, _mastery_row_label]:
		row_label.add_theme_color_override("font_color", Color(0.91, 0.80, 0.50, 1.0))
		row_label.add_theme_font_size_override("font_size", FONT_SIZE_ROW_LABEL)
	_combo_summary_label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.52, 1.0))
	_phase_label.add_theme_color_override("font_color", Color(0.84, 0.72, 0.44, 1.0))
	_run_progress_label.add_theme_color_override("font_color", Color(0.82, 0.90, 0.98, 1.0))
	_combo_summary_label.custom_minimum_size.x = COMBO_BLOCK_WIDTH
	_combo_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_apply_button_theme()

	_player_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ensure_placeholder_visuals()
	_apply_zone_guides()
	_title_label.text = RunState.level_sequence_label()
	_hint_label.text = "Gold 0"


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
	bg.set_corner_radius_all(6)
	bg.set_border_width_all(2)
	bg.border_color = Color(0.52, 0.40, 0.19, 0.85)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _apply_button_theme() -> void:
	for button in [_back_button, _debug_toggle_button, _settings_button, _next_button]:
		button.add_theme_color_override("font_color", Color(0.98, 0.93, 0.82, 1.0))
		button.add_theme_font_size_override("font_size", 18)
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.15, 0.11, 0.05, 0.84)
		style_normal.border_color = Color(0.64, 0.49, 0.21, 0.92)
		style_normal.set_border_width_all(2)
		style_normal.set_corner_radius_all(5)
		style_normal.content_margin_left = 8.0
		style_normal.content_margin_right = 8.0
		style_normal.content_margin_top = 4.0
		style_normal.content_margin_bottom = 4.0
		button.add_theme_stylebox_override("normal", style_normal)
		var style_hover := style_normal.duplicate()
		style_hover.bg_color = Color(0.23, 0.16, 0.08, 0.94)
		button.add_theme_stylebox_override("hover", style_hover)
		button.add_theme_stylebox_override("pressed", style_hover)


func _initialize_combat_state() -> void:
	if not RunState.run_active:
		RunState.start_new_run()
	if not RunState.is_current_step_fight():
		var redirect_scene := RunState.next_scene_path()
		if redirect_scene != "":
			get_tree().call_deferred("change_scene_to_file", redirect_scene)
		return

	_player_state = RunState.ensure_player_state()
	_progression_state = RunState.ensure_player_progression_state()
	var encounter: Dictionary = RunState.current_encounter_snapshot()
	_enemy_state = ENEMY_STATE_SCRIPT.new()
	_enemy_state.configure_from_blueprint(encounter)
	_combat = COMBAT_STATE_MACHINE_SCRIPT.new()
	_combat.start_fight(_player_state, _enemy_state)
	var content_errors: Array[Dictionary] = RunState.validate_player_state_content()
	_outcome_transition_queued = false
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
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
	_next_button.visible = false
	_next_button.disabled = true
	_turn_summary_label.text = "Turn Summary: Awaiting move."
	_combo_summary_label.text = "Combos: 0"
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


func _on_debug_toggle_button_pressed() -> void:
	_toggle_debug_overlay()


func _toggle_debug_overlay() -> void:
	_debug_overlay.visible = not _debug_overlay.visible
	if _debug_overlay.visible and _console_input.visible:
		_console_input.grab_focus()


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
	if _combat == null or _combat.is_fight_over():
		return
	if _input_phase != InputPhase.PLAYER_INPUT:
		_status_label.text = "Consumables can only be used during player input."
		return

	var progression_state: Variant = RunState.ensure_player_progression_state()
	var progression_service: Variant = RunState.ensure_player_progression_service()
	var content: Variant = RunState.ensure_content_registry()
	var use_result: Dictionary = progression_service.use_consumable(progression_state, 0, content)
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
	_status_label.text = "Used %s. Converted %d orbs." % [consumable_id, conversion_total]
	_append_combat_log("Consumable used: %s. Converted %d orbs." % [consumable_id, conversion_total])
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
	if not _active_drag:
		_update_timer_label(0.0)
		return

	_refresh_drag_match_glow()
	_move_time_left = maxf(0.0, _move_time_left - delta)
	_update_timer_label(_move_time_left)
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
		var touch_pos: Vector2 = _screen_to_board_local(event.position)
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
		var drag_pos: Vector2 = _screen_to_board_local(event.position)
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
					_next_button.visible = true
					_next_button.disabled = false
					_update_hud()
					_status_label.text = "Debug victory queued. Press Next."
					_append_combat_log("Fight win queued. Press Next to continue.")
				"lose":
					var lose_transition: Dictionary = RunState.mark_player_defeated("Debug command.")
					_set_input_phase(InputPhase.LOCKED_EXTERNAL)
					_pending_next_scene_path = ""
					_next_button.visible = false
					_next_button.disabled = true
					_update_hud()
					_status_label.text = "Debug defeat queued. Transitioning..."
					_append_combat_log("Fight lose queued. Transitioning to run summary.")
					_queue_outcome_transition(String(lose_transition.get("next_scene", "res://scenes/flow/run_summary_placeholder.tscn")))
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
	_update_timer_label(_move_time_left)
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
	_update_timer_label(0.0)
	var move_end_reason := "released"
	if timed_out:
		move_end_reason = "timer expired"
	_status_label.text = "Move ended: %s. Locking input for resolve phase." % move_end_reason
	_status_label.modulate = STATUS_COLOR_WARNING

	_reset_drag_visuals()
	_set_input_phase(InputPhase.RESOLVING)
	_last_resolve_result = _resolver.resolve_all(_board_state)
	_board_view.board_state = _board_state
	await _play_resolve_animations(_last_resolve_result)
	if _input_phase == InputPhase.RESOLVING:
		_resolve_combat_turn_from_board(_last_resolve_result)


func _resolve_combat_turn_from_board(resolve_result: Dictionary) -> void:
	if _combat == null:
		return
	var turn_log: Dictionary = _combat.resolve_player_turn(resolve_result)
	_update_hud()

	if _combat.phase == COMBAT_PHASE_VICTORY:
		var transition: Dictionary = RunState.mark_fight_victory()
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_victory_status(turn_log, transition) + " Press Next."
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Victory. Waiting for Next button to continue run flow.")
		_pending_next_scene_path = String(transition.get("next_scene", "res://scenes/main.tscn"))
		_next_button.visible = true
		_next_button.disabled = false
		_turn_summary_label.text = "Turn Summary: Victory. Press Next to continue."
		_combo_summary_label.text = _combo_summary_text(turn_log)
		_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
		return

	if _combat.phase == COMBAT_PHASE_DEFEAT:
		var defeat_cause := _build_defeat_cause(turn_log)
		var defeat_transition: Dictionary = RunState.mark_player_defeated(defeat_cause)
		_set_input_phase(InputPhase.LOCKED_EXTERNAL)
		_status_label.text = _build_defeat_status(turn_log)
		_append_turn_log(turn_log)
		_append_combat_log("Outcome: Defeat. Transitioning to run summary.")
		_pending_next_scene_path = ""
		_next_button.visible = false
		_next_button.disabled = true
		_turn_summary_label.text = "Turn Summary: Defeat."
		_combo_summary_label.text = _combo_summary_text(turn_log)
		_pulse_label(_turn_summary_label, STATUS_COLOR_NEGATIVE)
		_queue_outcome_transition(String(defeat_transition.get("next_scene", "res://scenes/flow/run_summary_placeholder.tscn")))
		return

	_status_label.text = _build_turn_summary_status(turn_log)
	_status_label.modulate = STATUS_COLOR_POSITIVE
	_turn_summary_label.text = "Turn Summary: %s" % _build_turn_summary_status(turn_log)
	_combo_summary_label.text = _combo_summary_text(turn_log)
	_pulse_label(_turn_summary_label, STATUS_COLOR_POSITIVE)
	_append_turn_log(turn_log)
	_begin_turn_preview()


func _on_next_button_pressed() -> void:
	if _pending_next_scene_path == "":
		return
	var target_scene := _pending_next_scene_path
	_pending_next_scene_path = ""
	_next_button.visible = false
	_next_button.disabled = true
	get_tree().change_scene_to_file(target_scene)


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


func _update_timer_label(seconds_left: float) -> void:
	_timer_label.text = "%.1f sec" % seconds_left
	_move_timer_bar.max_value = MOVE_TIMER_MAX_SECONDS
	_move_timer_bar.value = clampf(seconds_left, 0.0, _move_timer_bar.max_value)


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
	_update_timer_label(0.0)
	_reset_drag_visuals()


func _screen_to_board_local(screen_position: Vector2) -> Vector2:
	var inverse_canvas_transform: Transform2D = _board_view.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas_transform * screen_position


func _refresh_drag_match_glow() -> void:
	if not _active_drag:
		_board_view.clear_match_glow()
		return
	var predicted_groups: Array[Dictionary] = _resolver.get_match_groups(_board_state)
	_board_view.set_live_match_glow(predicted_groups)


func _play_resolve_animations(result: Dictionary) -> void:
	if result.total_combos <= 0:
		return

	for pass_result in result.passes:
		_board_view.flash_match_groups(pass_result.groups, MATCH_FLASH_SECONDS)
		await get_tree().create_timer(MATCH_FLASH_SECONDS).timeout

		_board_view.animate_clear_groups(pass_result.groups, CLEAR_ANIMATION_SECONDS)
		await get_tree().create_timer(CLEAR_ANIMATION_SECONDS).timeout

		_board_view.animate_fall_moves(pass_result.fall_moves, GRAVITY_ANIMATION_SECONDS)
		await get_tree().create_timer(GRAVITY_ANIMATION_SECONDS).timeout

		_board_view.animate_refill_spawns(pass_result.refill_spawns, REFILL_ANIMATION_SECONDS)
		await get_tree().create_timer(REFILL_ANIMATION_SECONDS).timeout

	while _board_view.has_active_animations():
		await get_tree().create_timer(0.02).timeout


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


func _build_defeat_status(turn_log: Dictionary) -> String:
	var hp_damage := int(turn_log.enemy_attack_resolution.get("hp_damage", 0))
	return "Defeat. Enemy intent dealt %d HP damage. Transitioning to run summary." % hp_damage


func _build_defeat_cause(turn_log: Dictionary) -> String:
	var enemy_label := String(_enemy_state.display_name if _enemy_state != null else "Enemy")
	var intent_label := String(Dictionary(turn_log.get("enemy_intent", {})).get("label", "Unknown intent"))
	var hp_damage := int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0))
	return "%s defeated the hero with %s for %d HP." % [enemy_label, intent_label, hp_damage]


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
	if _enemy_portrait.texture == null:
		_enemy_portrait.texture = _make_enemy_placeholder_texture()
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
	var turn_log: Dictionary = _last_resolve_result.get("turn_log", {})
	var combo_count := int(_last_resolve_result.get("combo_count", 0))
	var combo_multiplier := float(turn_log.get("damage_combo_multiplier", 1.0))
	var bonus_percent := maxi(0, int(round((combo_multiplier - 1.0) * 100.0)))
	_combo_summary_label.text = "%d Combos\n+%d%% Damage" % [combo_count, bonus_percent]
	_timer_label.text = "%d SEC" % int(ceil(_move_time_left))


func _sync_player_strip(progression_snapshot: Dictionary) -> void:
	_player_label.text = "HP %d/%d   Armor %d   Gold %d" % [
		_player_state.current_hp,
		_player_state.max_hp,
		_player_state.armor,
		_player_state.gold,
	]
	_player_hp_bar.max_value = float(maxi(1, _player_state.max_hp))
	_player_hp_bar.value = float(_player_state.current_hp)
	_player_armor_bar.max_value = float(maxi(30, _player_state.armor + 10))
	_player_armor_bar.value = float(maxi(0, _player_state.armor))
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	_run_progress_label.text = "ATK %d | ARM %d | HEART %d%% | GOLD %d%%" % [
		_player_state.orb_value(OrbType.Id.FIRE),
		_player_state.orb_value(OrbType.Id.ARMOR),
		int(mastery_levels.get(OrbType.Id.HEART, 0)) * 5,
		int(mastery_levels.get(OrbType.Id.GOLD, 0)) * 5,
	]
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
	var label := String(intent.get("label", "Intent"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	if attack > 0 and block > 0:
		return "%s %d / %d" % [label, attack, block]
	if attack > 0:
		return "%s %d" % [label, attack]
	if block > 0:
		return "%s %d" % [label, block]
	return label


func _append_turn_log(turn_log: Dictionary) -> void:
	_emit_turn_feedback_vfx(turn_log)
	if _combat_log_level == LOG_LEVEL_DETAILED:
		_append_turn_log_detailed(turn_log)
		return
	_append_turn_log_normal(turn_log)


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
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	var relic_ids: Array = progression_snapshot.get("relic_ids", [])
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})

	_populate_icon_row(_equipment_icons, equipment_slots, "equipment")
	_populate_icon_row(_consumable_icons, consumable_slots, "consumable")
	_populate_icon_row(_relic_icons, relic_ids, "relic")
	_populate_mastery_row(_mastery_icons, mastery_levels)

	var has_relic := false
	for relic_id in relic_ids:
		if String(relic_id) != "":
			has_relic = true
			break
	var has_mastery := false
	for orb_id in OrbType.ALL_TYPES:
		if int(mastery_levels.get(orb_id, 0)) > 0:
			has_mastery = true
			break
	_relic_row.visible = has_relic and not _is_low_vertical_layout
	_mastery_row.visible = has_mastery and not _is_low_vertical_layout


func _populate_icon_row(row: HBoxContainer, ids: Array, label: String) -> void:
	for child in row.get_children():
		child.queue_free()
	for id_value in ids:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = SLOT_SIZE
		slot.add_theme_stylebox_override("panel", _slot_stylebox())
		var icon := TextureRect.new()
		icon.custom_minimum_size = ICON_INNER_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var id_text := String(id_value)
		if id_text == "":
			icon.texture = _visuals.placeholder_texture("%s_empty" % label, Color(0.20, 0.22, 0.26, 0.95), Vector2i(96, 96))
			icon.modulate = Color(1.0, 1.0, 1.0, 0.35)
		else:
			var content: Dictionary = _lookup_content_definition(id_text)
			var icon_key := String(content.get("icon_key", ""))
			icon.texture = _visuals.clean_icon_for_key(icon_key)
			icon.tooltip_text = String(content.get("display_name", id_text))
			if label == "consumable":
				var amount_label := Label.new()
				amount_label.text = "1"
				amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
				amount_label.add_theme_font_size_override("font_size", 14)
				amount_label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0, 1.0))
				amount_label.anchors_preset = Control.PRESET_FULL_RECT
				slot.add_child(amount_label)
		slot.add_child(icon)
		row.add_child(slot)


func _populate_mastery_row(row: HBoxContainer, mastery_levels: Dictionary) -> void:
	for child in row.get_children():
		child.queue_free()
	for orb_id in OrbType.ALL_TYPES:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = SLOT_SIZE
		slot.add_theme_stylebox_override("panel", _slot_stylebox())
		var icon := TextureRect.new()
		icon.custom_minimum_size = ICON_INNER_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _visuals.mastery_icon(orb_id)
		var level := int(mastery_levels.get(orb_id, 0))
		icon.tooltip_text = "%s Mastery %d" % [OrbType.display_name(orb_id), level]
		if level <= 0:
			icon.modulate = Color(0.6, 0.6, 0.6, 0.7)
		slot.add_child(icon)
		var amount_label := Label.new()
		amount_label.text = str(level)
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		amount_label.add_theme_font_size_override("font_size", 14)
		amount_label.add_theme_color_override("font_color", Color(0.95, 0.84, 0.42, 1.0))
		amount_label.anchors_preset = Control.PRESET_FULL_RECT
		slot.add_child(amount_label)
		row.add_child(slot)


func _slot_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.14, 0.95)
	style.border_color = Color(0.50, 0.38, 0.18, 0.84)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 2.0
	style.content_margin_right = 2.0
	style.content_margin_top = 2.0
	style.content_margin_bottom = 2.0
	return style


func _lookup_content_definition(content_id: String) -> Dictionary:
	var registry = RunState.ensure_content_registry()
	var value: Dictionary = registry.get_equipment(content_id)
	if not value.is_empty():
		return value
	value = registry.get_consumable(content_id)
	if not value.is_empty():
		return value
	value = registry.get_relic(content_id)
	if not value.is_empty():
		return value
	value = registry.get_mastery_card(content_id)
	if not value.is_empty():
		return value
	return {
		"display_name": content_id,
		"icon_key": "",
	}


func _emit_turn_feedback_vfx(turn_log: Dictionary) -> void:
	var enemy_damage := int(turn_log.get("enemy_damage_taken", 0))
	if enemy_damage > 0:
		var target := _enemy_portrait.global_position + _enemy_portrait.size * 0.5
		_spawn_vfx("hit_flash", target, Vector2(84, 84), 0.42)

	var gold_gained := int(turn_log.get("gold_gained", 0))
	if gold_gained > 0:
		var target := _player_label.global_position + Vector2(18, 18)
		_spawn_vfx("gold_gain", target, Vector2(70, 70), 0.55)


func _spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float) -> void:
	var tex := _visuals.vfx_texture(effect_name)
	if tex == null:
		return
	var sprite := TextureRect.new()
	sprite.texture = tex
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.global_position = global_center - draw_size * 0.5
	_vfx_layer.add_child(sprite)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, maxf(0.08, lifetime))
	tween.finished.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.queue_free()
	)


func _on_resolver_match_found(groups: Array) -> void:
	_status_label.text = "Matches found: %d group(s)." % groups.size()
	_status_label.modulate = STATUS_COLOR_WARNING


func _combo_summary_text(turn_log: Dictionary) -> String:
	return "Combos: %d (effective %d) | Damage %d | Heal +%d | Armor +%d | Gold +%d" % [
		int(turn_log.get("combo_count", 0)),
		int(turn_log.get("combo_count_with_bonus", turn_log.get("combo_count", 0))),
		int(turn_log.get("enemy_damage_taken", 0)),
		int(turn_log.get("healed", 0)),
		int(turn_log.get("armor_gained", 0)),
		int(turn_log.get("gold_gained", 0)),
	]


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

	var scale_factor: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var scaled_size := DESIGN_SIZE * scale_factor
	_layout_root.position = (viewport_size - scaled_size) * 0.5
	_layout_root.size = DESIGN_SIZE
	_layout_root.scale = Vector2(scale_factor, scale_factor)

	_apply_design_rect(_top_bar, TOP_BAR_RECT)
	_apply_design_rect(_enemy_panel, ENEMY_PANEL_RECT)
	_apply_design_rect(_combat_strip, COMBAT_STRIP_RECT)
	_apply_design_rect(_board_panel, BOARD_PANEL_RECT)
	_apply_design_rect(_player_panel, PLAYER_PANEL_RECT)
	_apply_enemy_panel_layout()
	_apply_combat_strip_layout()
	_apply_board_panel_layout()
	_apply_player_panel_layout()

	_turn_summary_label.visible = not is_low_vertical
	if is_low_vertical:
		_mastery_row.visible = false
		_relic_row.visible = false
	elif is_compact:
		_relic_row.visible = false
	_combo_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if is_compact else HORIZONTAL_ALIGNMENT_RIGHT
	_debug_overlay.anchor_left = 0.08 if is_compact else 0.58
	_debug_overlay.anchor_top = 0.05
	_debug_overlay.anchor_right = 0.985
	_debug_overlay.anchor_bottom = 0.97


func _apply_design_rect(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size


func _apply_enemy_panel_layout() -> void:
	_enemy_panel_root.position = Vector2.ZERO
	_enemy_panel_root.size = ENEMY_PANEL_RECT.size
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
	_combat_strip_row.position = Vector2(COMBAT_STRIP_INSET, 12.0)
	_combat_strip_row.size = Vector2(COMBAT_STRIP_RECT.size.x - COMBAT_STRIP_INSET * 2.0, 48.0)
	_timer_badge_panel.custom_minimum_size = TIMER_BADGE_SIZE
	_move_timer_bar.custom_minimum_size.y = 16.0
	_combo_summary_label.custom_minimum_size.x = COMBO_BLOCK_WIDTH


func _apply_board_panel_layout() -> void:
	_board_surface.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_board_surface.position = Vector2((BOARD_PANEL_RECT.size.x - BOARD_SURFACE_SIZE.x) * 0.5, BOARD_SURFACE_TOP)
	_board_surface.size = BOARD_SURFACE_SIZE
	_board_view_control.custom_minimum_size = BOARD_SURFACE_SIZE


func _apply_player_panel_layout() -> void:
	_player_panel_root.position = Vector2.ZERO
	_player_panel_root.size = PLAYER_PANEL_RECT.size
	_apply_design_rect(_player_stats_row, PLAYER_STATS_RECT)
	_apply_design_rect(_combat_meta_row, PLAYER_META_RECT)
	_apply_design_rect(_turn_summary_label, PLAYER_SUMMARY_RECT)
	_apply_design_rect(_loadout_row, PLAYER_LOADOUT_RECT)
	_player_portrait.custom_minimum_size = PLAYER_PORTRAIT_SIZE


func _ensure_placeholder_visuals() -> void:
	if _intent_badge.texture == null:
		_intent_badge.texture = _make_intent_placeholder_texture()
	_intent_badge.visible = true
	if _enemy_portrait.texture == null:
		_enemy_portrait.texture = _make_enemy_placeholder_texture()
	_enemy_portrait.visible = true
	if _player_portrait.texture == null:
		_player_portrait.texture = _make_hero_placeholder_texture()
	_player_portrait.visible = true


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
		style.bg_color = Color(0.03, 0.06, 0.10, 0.94)
		style.border_color = Color(0.62, 0.49, 0.23, 0.92)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
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
	for raw_cell in cells:
		var cell: Vector2i = raw_cell
		if not _board_view.is_cell_valid(cell):
			continue
		var center := _board_view.get_cell_center(cell)
		var global_center := _board_view.global_position + center
		_spawn_vfx("orb_clear", global_center, Vector2(60, 60), 0.33)


func _on_resolver_gravity_applied(_fall_moves: Array) -> void:
	pass


func _on_resolver_refill_applied(_refill_spawns: Array) -> void:
	pass


func _on_resolver_cascade_step_complete(_step_index: int, _total_combos: int) -> void:
	pass


func _on_resolver_complete(_result: Dictionary) -> void:
	pass
