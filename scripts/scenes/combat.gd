extends Control

const COMBAT_MODEL_SCRIPT := preload("res://scripts/combat/combat_model.gd")
const COMBAT_VIEW_SCRIPT := preload("res://scripts/combat/combat_view.gd")
const COMBAT_CONTROLLER_SCRIPT := preload("res://scripts/combat/combat_controller.gd")

@onready var _board: Control = %Board
@onready var _board_view: BoardView = _resolve_board_view()
@onready var _background: TextureRect = %Background
@onready var _background_scrim: TextureRect = %BackgroundScrim
@onready var _status_label: Label = %StatusLabel
@onready var _timer_label: Label = %TimerLabel
@onready var _run_progress_label: Label = _player_hud_node("RunProgressLabel") as Label
@onready var _turn_summary_label: Label = _player_hud_node("TurnSummaryLabel") as Label
@onready var _player_label: Label = _player_hud_node("PlayerHpLabel") as Label
@onready var _enemy_label: Label = %EnemyStageLabel
@onready var _enemy_step_label: Label = $"CombatLayoutRoot/TopBar/EnemyStepLabel"
@onready var _enemy_debug_label: Label = %EnemyStateLabel
@onready var _intent_label: Label = %EnemyIntentLabel
@onready var _phase_label: Label = _player_hud_node("CombatPhaseLabel") as Label
@onready var _combat_log_text: RichTextLabel = %CombatLogText
@onready var _console_input: LineEdit = %ConsoleInput
@onready var _next_button: Button = %NextButton
@onready var _back_button: Button = $"CombatLayoutRoot/TopBar/HelpButton"
@onready var _debug_toggle_button: Button = $"CombatLayoutRoot/TopBar/DebugToggleButton"
@onready var _settings_button: Button = $"CombatLayoutRoot/TopBar/SettingsButton"
@onready var _board_view_control: Control = %Board
@onready var _layout_root: Control = %CombatLayoutRoot
@onready var _top_bar: Panel = $"CombatLayoutRoot/TopBar"
@onready var _enemy_panel: PanelContainer = $"CombatLayoutRoot/EnemyPanel"
@onready var _enemy_panel_root: Control = %EnemyPanelRoot
@onready var _intent_row: HBoxContainer = %IntentRow
@onready var _enemy_stage: Control = %EnemyStage
@onready var _enemy_hp_row: Control = %EnemyHpRow
@onready var _enemy_name_label: Label = %EnemyNameLabel
@onready var _enemy_hp_text_label: Label = %EnemyHpLabel
@onready var _combat_strip: PanelContainer = $"CombatLayoutRoot/CombatStrip"
@onready var _timer_track: Control = %TimerTrack
@onready var _timer_fill: ColorRect = %TimerFill
@onready var _timer_icon: TextureRect = %TimerIcon
@onready var _timer_state_label: Label = %TimerStateLabel
@onready var _timer_center_marker: TextureRect = %TimerCenterMarker
@onready var _board_frame: PanelContainer = $"CombatLayoutRoot/BoardPanel/Board/BoardFrame"
@onready var _board_panel: Control = %BoardPanel
@onready var _board_shadow: Panel = %BoardShadow
@onready var _outcome_summary_panel: Panel = %OutcomeSummaryPanel
@onready var _outcome_summary_root: Control = %OutcomeSummaryRoot
@onready var _outcome_text_column: Control = %OutcomeTextColumn
@onready var _outcome_title_label: Label = %OutcomeTitleLabel
@onready var _outcome_body_label: Label = %OutcomeBodyLabel
@onready var _player_hud_section: Panel = %PlayerHudSection
@onready var _player_panel: Panel = _player_hud_node("PlayerPanel") as Panel
@onready var _player_panel_root: Control = _player_hud_node("PlayerPanelRoot") as Control
@onready var _hero_card: Panel = _player_hud_node("HeroCard") as Panel
@onready var _hero_card_root: Control = _player_hud_node("HeroCardRoot") as Control
@onready var _hero_level_badge: PanelContainer = _player_hud_node("HeroLevelBadge") as PanelContainer
@onready var _vitals_panel: Control = _player_hud_node("VitalsPanel") as Control
@onready var _vitals_frame: Panel = _player_hud_node("VitalsFrame") as Panel
@onready var _player_hp_label: Label = _player_hud_node("PlayerHpLabel") as Label
@onready var _player_armor_label: Label = _player_hud_node("PlayerArmorLabel") as Label
@onready var _armor_badge: PanelContainer = _player_hud_node("ArmorBadge") as PanelContainer
@onready var _armor_badge_label: Label = _player_hud_node("ArmorBadgeLabel") as Label
@onready var _stat_chip_row: HBoxContainer = _player_hud_node("StatChipRow") as HBoxContainer
@onready var _attack_stat_label: Label = _player_hud_node("AttackStatLabel") as Label
@onready var _armor_stat_label: Label = _player_hud_node("ArmorStatLabel") as Label
@onready var _heart_stat_label: Label = _player_hud_node("HeartStatLabel") as Label
@onready var _gold_stat_label: Label = _player_hud_node("GoldStatLabel") as Label
@onready var _combat_meta_row: HBoxContainer = _player_hud_node("CombatMetaRow") as HBoxContainer
@onready var _loadout_frame: Panel = _player_hud_node("LoadoutFrame") as Panel
@onready var _loadout_root: Control = _player_hud_node("LoadoutRoot") as Control
@onready var _mastery_strip: Panel = _player_hud_node("MasteryStrip") as Panel
@onready var _mastery_root: Control = _player_hud_node("MasteryRoot") as Control
@onready var _combat_log_frame: PanelContainer = $"DebugOverlay/DebugVBox/CombatLogFrame"
@onready var _debug_overlay: PanelContainer = %DebugOverlay
@onready var _title_label: Label = $"CombatLayoutRoot/TopBar/TitleLabel"
@onready var _hint_label: Label = $"CombatLayoutRoot/TopBar/GoldPill/GoldLabel"
@onready var _enemy_portrait: TextureRect = %EnemyPortrait
@onready var _intent_badge: TextureRect = %IntentBadge
@onready var _primary_intent_text_column: VBoxContainer = %PrimaryIntentTextColumn
@onready var _primary_intent_title_label: Label = %PrimaryIntentTitleLabel
@onready var _primary_intent_amount_label: Label = %PrimaryIntentAmountLabel
@onready var _primary_intent_detail_label: Label = %PrimaryIntentDetailLabel
@onready var _enemy_hp_bar: ProgressBar = %EnemyHpBar
@onready var _player_hp_bar: ProgressBar = _player_hud_node("PlayerHpBar") as ProgressBar
@onready var _player_armor_bar: ProgressBar = _player_hud_node("PlayerArmorBar") as ProgressBar
@onready var _player_portrait: TextureRect = _player_hud_node("PlayerPortrait") as TextureRect
@onready var _equipment_icons: Control = _player_hud_node("EquipmentIcons") as Control
@onready var _consumable_icons: Control = _player_hud_node("ConsumableIcons") as Control
@onready var _relic_icons: HBoxContainer = _player_hud_node("RelicIcons") as HBoxContainer
@onready var _mastery_icons: Control = _player_hud_node("MasteryIcons") as Control
@onready var _elemental_mastery_cards: Control = _player_hud_node("ElementalMasteryCards") as Control
@onready var _elemental_mastery_panel: Panel = _player_hud_node("ElementalMasteryPanel") as Panel
@onready var _elemental_mastery_title: Label = _player_hud_node("ElementalMasteryTitle") as Label
@onready var _relic_row: HBoxContainer = _player_hud_node("RelicRow") as HBoxContainer
@onready var _equipment_row_label: Label = _player_hud_node("EquipmentLabel") as Label
@onready var _consumable_row_label: Label = _player_hud_node("ConsumableLabel") as Label
@onready var _relic_row_label: Label = _player_hud_node("RelicLabel") as Label
@onready var _mastery_row_label: Label = _player_hud_node("MasteryLabel") as Label
@onready var _vfx_layer: Control = %VfxLayer
@onready var _divider_enemy_timer: TextureRect = %DividerEnemyTimer
@onready var _divider_timer_board: TextureRect = %DividerTimerBoard
@onready var _divider_board_player: TextureRect = %DividerBoardPlayer
@onready var _corner_top_left: TextureRect = %CornerTopLeft
@onready var _corner_top_right: TextureRect = %CornerTopRight
@onready var _corner_bottom_left: TextureRect = %CornerBottomLeft
@onready var _corner_bottom_right: TextureRect = %CornerBottomRight

var _model
var _view
var _controller


func _enter_tree() -> void:
	_ensure_mvc()
	_controller.enter_tree()


func _ready() -> void:
	_ensure_mvc()
	_controller.bind(self, _build_root_nodes(), _model, _view)
	_controller.ready()


func _exit_tree() -> void:
	if _controller != null:
		_controller.exit_tree()


func _process(delta: float) -> void:
	if _controller != null:
		_controller.process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if _controller != null:
		_controller.unhandled_input(event)


func _on_viewport_size_changed() -> void:
	if _controller != null:
		_controller.on_viewport_size_changed()


func _on_back_button_pressed() -> void:
	if _controller != null:
		_controller.on_back_button_pressed()


func _on_debug_toggle_button_pressed() -> void:
	if _controller != null:
		_controller.on_debug_toggle_button_pressed()


func _on_settings_button_pressed() -> void:
	if _controller != null:
		_controller.on_settings_button_pressed()


func _on_next_button_pressed() -> void:
	if _controller != null:
		_controller.on_next_button_pressed()


func set_external_input_locked(locked: bool, reason: String = "") -> void:
	if _controller != null:
		_controller.set_external_input_locked(locked, reason)


func _ensure_mvc() -> void:
	if _model == null:
		_model = COMBAT_MODEL_SCRIPT.new()
	if _view == null:
		_view = COMBAT_VIEW_SCRIPT.new()
	if _controller == null:
		_controller = COMBAT_CONTROLLER_SCRIPT.new()


func _build_root_nodes() -> Dictionary:
	return {
		"_board": _board,
		"_board_view": _board_view,
		"_background": _background,
		"_background_scrim": _background_scrim,
		"_status_label": _status_label,
		"_timer_label": _timer_label,
		"_run_progress_label": _run_progress_label,
		"_turn_summary_label": _turn_summary_label,
		"_player_label": _player_label,
		"_enemy_label": _enemy_label,
		"_enemy_step_label": _enemy_step_label,
		"_enemy_debug_label": _enemy_debug_label,
		"_intent_label": _intent_label,
		"_phase_label": _phase_label,
		"_combat_log_text": _combat_log_text,
		"_console_input": _console_input,
		"_next_button": _next_button,
		"_back_button": _back_button,
		"_debug_toggle_button": _debug_toggle_button,
		"_settings_button": _settings_button,
		"_board_view_control": _board_view_control,
		"_layout_root": _layout_root,
		"_top_bar": _top_bar,
		"_enemy_panel": _enemy_panel,
		"_enemy_panel_root": _enemy_panel_root,
		"_intent_row": _intent_row,
		"_enemy_stage": _enemy_stage,
		"_enemy_hp_row": _enemy_hp_row,
		"_enemy_name_label": _enemy_name_label,
		"_enemy_hp_text_label": _enemy_hp_text_label,
		"_combat_strip": _combat_strip,
		"_timer_track": _timer_track,
		"_timer_fill": _timer_fill,
		"_timer_icon": _timer_icon,
		"_timer_state_label": _timer_state_label,
		"_timer_center_marker": _timer_center_marker,
		"_board_frame": _board_frame,
		"_board_panel": _board_panel,
		"_board_shadow": _board_shadow,
		"_outcome_summary_panel": _outcome_summary_panel,
		"_outcome_summary_root": _outcome_summary_root,
		"_outcome_text_column": _outcome_text_column,
		"_outcome_title_label": _outcome_title_label,
		"_outcome_body_label": _outcome_body_label,
		"_player_hud_section": _player_hud_section,
		"_player_panel": _player_panel,
		"_player_panel_root": _player_panel_root,
		"_hero_card": _hero_card,
		"_hero_card_root": _hero_card_root,
		"_hero_level_badge": _hero_level_badge,
		"_vitals_panel": _vitals_panel,
		"_vitals_frame": _vitals_frame,
		"_player_hp_label": _player_hp_label,
		"_player_armor_label": _player_armor_label,
		"_armor_badge": _armor_badge,
		"_armor_badge_label": _armor_badge_label,
		"_stat_chip_row": _stat_chip_row,
		"_attack_stat_label": _attack_stat_label,
		"_armor_stat_label": _armor_stat_label,
		"_heart_stat_label": _heart_stat_label,
		"_gold_stat_label": _gold_stat_label,
		"_combat_meta_row": _combat_meta_row,
		"_loadout_frame": _loadout_frame,
		"_loadout_root": _loadout_root,
		"_mastery_strip": _mastery_strip,
		"_mastery_root": _mastery_root,
		"_combat_log_frame": _combat_log_frame,
		"_debug_overlay": _debug_overlay,
		"_title_label": _title_label,
		"_hint_label": _hint_label,
		"_enemy_portrait": _enemy_portrait,
		"_intent_badge": _intent_badge,
		"_primary_intent_text_column": _primary_intent_text_column,
		"_primary_intent_title_label": _primary_intent_title_label,
		"_primary_intent_amount_label": _primary_intent_amount_label,
		"_primary_intent_detail_label": _primary_intent_detail_label,
		"_enemy_hp_bar": _enemy_hp_bar,
		"_player_hp_bar": _player_hp_bar,
		"_player_armor_bar": _player_armor_bar,
		"_player_portrait": _player_portrait,
		"_equipment_icons": _equipment_icons,
		"_consumable_icons": _consumable_icons,
		"_relic_icons": _relic_icons,
		"_mastery_icons": _mastery_icons,
		"_elemental_mastery_cards": _elemental_mastery_cards,
		"_elemental_mastery_panel": _elemental_mastery_panel,
		"_elemental_mastery_title": _elemental_mastery_title,
		"_relic_row": _relic_row,
		"_equipment_row_label": _equipment_row_label,
		"_consumable_row_label": _consumable_row_label,
		"_relic_row_label": _relic_row_label,
		"_mastery_row_label": _mastery_row_label,
		"_vfx_layer": _vfx_layer,
		"_divider_enemy_timer": _divider_enemy_timer,
		"_divider_timer_board": _divider_timer_board,
		"_divider_board_player": _divider_board_player,
		"_corner_top_left": _corner_top_left,
		"_corner_top_right": _corner_top_right,
		"_corner_bottom_left": _corner_bottom_left,
		"_corner_bottom_right": _corner_bottom_right,
	}


func _player_hud_node(unique_name: String) -> Node:
	var hud_section: Node = _player_hud_section
	if hud_section == null:
		hud_section = get_node_or_null("CombatLayoutRoot/PlayerHudSection")
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
	var absolute_path: Node = get_node_or_null("CombatLayoutRoot/BoardPanel/Board/BoardFrame/BoardAspect/BoardView")
	if absolute_path is BoardView:
		return absolute_path as BoardView
	push_error("CombatPlayerController: unable to resolve BoardView under CombatLayoutRoot/BoardPanel/Board.")
	return null



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
