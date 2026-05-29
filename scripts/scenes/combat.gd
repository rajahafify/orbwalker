extends Control

const COMBAT_MODEL_SCRIPT := preload("res://scripts/combat/combat_model.gd")
const COMBAT_VIEW_SCRIPT := preload("res://scripts/combat/combat_view.gd")
const COMBAT_CONTROLLER_SCRIPT := preload("res://scripts/combat/combat_controller.gd")

const ROOT_NODE_BINDINGS := {
	"_board": ^"%Board",
	"_background": ^"%Background",
	"_background_scrim": ^"%BackgroundScrim",
	"_status_label": ^"%StatusLabel",
	"_timer_label": ^"%TimerLabel",
	"_run_progress_label": ["player_hud", "RunProgressLabel"],
	"_turn_summary_label": ["player_hud", "TurnSummaryLabel"],
	"_player_label": ["player_hud", "PlayerHpLabel"],
	"_enemy_label": ^"%EnemyStageLabel",
	"_enemy_step_label": ^"CombatLayoutRoot/TopBar/EnemyStepLabel",
	"_enemy_debug_label": ^"%EnemyStateLabel",
	"_intent_label": ^"%EnemyIntentLabel",
	"_phase_label": ["player_hud", "CombatPhaseLabel"],
	"_combat_log_text": ^"%CombatLogText",
	"_console_input": ^"%ConsoleInput",
	"_next_button": ^"%NextButton",
	"_back_button": ^"CombatLayoutRoot/TopBar/HelpButton",
	"_debug_toggle_button": ^"CombatLayoutRoot/TopBar/DebugToggleButton",
	"_settings_button": ^"CombatLayoutRoot/TopBar/SettingsButton",
	"_board_view_control": ^"%Board",
	"_layout_root": ^"%CombatLayoutRoot",
	"_top_bar": ^"CombatLayoutRoot/TopBar",
	"_enemy_panel": ^"CombatLayoutRoot/EnemyPanel",
	"_enemy_panel_root": ^"%EnemyPanelRoot",
	"_intent_row": ^"%IntentRow",
	"_enemy_stage": ^"%EnemyStage",
	"_enemy_hp_row": ^"%EnemyHpRow",
	"_enemy_name_label": ^"%EnemyNameLabel",
	"_enemy_hp_text_label": ^"%EnemyHpLabel",
	"_combat_strip": ^"CombatLayoutRoot/CombatStrip",
	"_timer_track": ^"%TimerTrack",
	"_timer_fill": ^"%TimerFill",
	"_timer_icon": ^"%TimerIcon",
	"_timer_state_label": ^"%TimerStateLabel",
	"_timer_center_marker": ^"%TimerCenterMarker",
	"_board_frame": ^"CombatLayoutRoot/BoardPanel/Board/BoardFrame",
	"_board_panel": ^"%BoardPanel",
	"_board_shadow": ^"%BoardShadow",
	"_outcome_summary_panel": ^"%OutcomeSummaryPanel",
	"_outcome_summary_root": ^"%OutcomeSummaryRoot",
	"_outcome_text_column": ^"%OutcomeTextColumn",
	"_outcome_title_label": ^"%OutcomeTitleLabel",
	"_outcome_body_label": ^"%OutcomeBodyLabel",
	"_player_hud_section": ^"%PlayerHudSection",
	"_player_panel": ["player_hud", "PlayerPanel"],
	"_player_panel_root": ["player_hud", "PlayerPanelRoot"],
	"_hero_card": ["player_hud", "HeroCard"],
	"_hero_card_root": ["player_hud", "HeroCardRoot"],
	"_hero_level_badge": ["player_hud", "HeroLevelBadge"],
	"_vitals_panel": ["player_hud", "VitalsPanel"],
	"_vitals_frame": ["player_hud", "VitalsFrame"],
	"_player_hp_label": ["player_hud", "PlayerHpLabel"],
	"_player_armor_label": ["player_hud", "PlayerArmorLabel"],
	"_armor_badge": ["player_hud", "ArmorBadge"],
	"_armor_badge_label": ["player_hud", "ArmorBadgeLabel"],
	"_stat_chip_row": ["player_hud", "StatChipRow"],
	"_attack_stat_label": ["player_hud", "AttackStatLabel"],
	"_armor_stat_label": ["player_hud", "ArmorStatLabel"],
	"_heart_stat_label": ["player_hud", "HeartStatLabel"],
	"_gold_stat_label": ["player_hud", "GoldStatLabel"],
	"_combat_meta_row": ["player_hud", "CombatMetaRow"],
	"_loadout_frame": ["player_hud", "LoadoutFrame"],
	"_loadout_root": ["player_hud", "LoadoutRoot"],
	"_mastery_strip": ["player_hud", "MasteryStrip"],
	"_mastery_root": ["player_hud", "MasteryRoot"],
	"_combat_log_frame": ^"DebugOverlay/DebugVBox/CombatLogFrame",
	"_debug_overlay": ^"%DebugOverlay",
	"_title_label": ^"CombatLayoutRoot/TopBar/TitleLabel",
	"_hint_label": ^"CombatLayoutRoot/TopBar/GoldPill/GoldLabel",
	"_enemy_portrait": ^"%EnemyPortrait",
	"_intent_badge": ^"%IntentBadge",
	"_primary_intent_text_column": ^"%PrimaryIntentTextColumn",
	"_primary_intent_title_label": ^"%PrimaryIntentTitleLabel",
	"_primary_intent_amount_label": ^"%PrimaryIntentAmountLabel",
	"_primary_intent_detail_label": ^"%PrimaryIntentDetailLabel",
	"_enemy_hp_bar": ^"%EnemyHpBar",
	"_player_hp_bar": ["player_hud", "PlayerHpBar"],
	"_player_armor_bar": ["player_hud", "PlayerArmorBar"],
	"_player_portrait": ["player_hud", "PlayerPortrait"],
	"_equipment_icons": ["player_hud", "EquipmentIcons"],
	"_consumable_icons": ["player_hud", "ConsumableIcons"],
	"_relic_icons": ["player_hud", "RelicIcons"],
	"_mastery_icons": ["player_hud", "MasteryIcons"],
	"_elemental_mastery_cards": ["player_hud", "ElementalMasteryCards"],
	"_elemental_mastery_panel": ["player_hud", "ElementalMasteryPanel"],
	"_elemental_mastery_title": ["player_hud", "ElementalMasteryTitle"],
	"_relic_row": ["player_hud", "RelicRow"],
	"_equipment_row_label": ["player_hud", "EquipmentLabel"],
	"_consumable_row_label": ["player_hud", "ConsumableLabel"],
	"_relic_row_label": ["player_hud", "RelicLabel"],
	"_mastery_row_label": ["player_hud", "MasteryLabel"],
	"_vfx_layer": ^"%VfxLayer",
	"_divider_enemy_timer": ^"%DividerEnemyTimer",
	"_divider_timer_board": ^"%DividerTimerBoard",
	"_divider_board_player": ^"%DividerBoardPlayer",
	"_corner_top_left": ^"%CornerTopLeft",
	"_corner_top_right": ^"%CornerTopRight",
	"_corner_bottom_left": ^"%CornerBottomLeft",
	"_corner_bottom_right": ^"%CornerBottomRight",
}

var _model
var _view
var _controller
var _root_nodes: Dictionary = {}


func _enter_tree() -> void:
	_ensure_mvc()
	_controller.enter_tree()


func _ready() -> void:
	_ensure_mvc()
	_root_nodes = _build_root_nodes()
	_controller.bind(self, _root_nodes, _model, _view)
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
	var nodes := {}
	var hud_section: Node = _resolve_bound_node(ROOT_NODE_BINDINGS.get("_player_hud_section"), null)
	for node_name in ROOT_NODE_BINDINGS.keys():
		var node: Node = _resolve_bound_node(ROOT_NODE_BINDINGS[node_name], hud_section)
		if node == null:
			push_error("Combat scene root node binding failed: %s -> %s" % [node_name, _binding_label(ROOT_NODE_BINDINGS[node_name])])
		nodes[node_name] = node
	nodes["_board_view"] = _resolve_board_view(nodes)
	return nodes


func _resolve_bound_node(binding: Variant, hud_section: Node) -> Node:
	if binding is NodePath:
		var path: NodePath = binding
		return get_node_or_null(path)
	if binding is Array:
		var binding_parts: Array = binding
		if binding_parts.size() == 2 and String(binding_parts[0]) == "player_hud":
			return _player_hud_node(String(binding_parts[1]), hud_section)
	return null


func _binding_label(binding: Variant) -> String:
	if binding is NodePath:
		return String(binding)
	if binding is Array:
		var binding_parts: Array = binding
		if binding_parts.size() == 2 and String(binding_parts[0]) == "player_hud":
			return "PlayerHudSection/%s%s" % ["%", String(binding_parts[1])]
	return String(binding)


func _player_hud_node(unique_name: String, hud_section: Node = null) -> Node:
	var resolved_hud_section: Node = hud_section
	if resolved_hud_section == null:
		resolved_hud_section = get_node_or_null("CombatLayoutRoot/PlayerHudSection")
	if resolved_hud_section == null:
		return null
	return resolved_hud_section.get_node_or_null("%s%s" % ["%", unique_name])


func _resolve_board_view(nodes: Dictionary = {}) -> BoardView:
	var board: Node = nodes.get("_board", null) as Node
	if board == null:
		board = get_node_or_null("%Board")
	if board != null and is_instance_valid(board):
		var board_scene_unique: Node = board.get_node_or_null("%BoardView")
		if board_scene_unique is BoardView:
			return board_scene_unique as BoardView
		var board_scene_path: Node = board.get_node_or_null("BoardFrame/BoardAspect/BoardView")
		if board_scene_path is BoardView:
			return board_scene_path as BoardView
	var absolute_path: Node = get_node_or_null("CombatLayoutRoot/BoardPanel/Board/BoardFrame/BoardAspect/BoardView")
	if absolute_path is BoardView:
		return absolute_path as BoardView
	push_error("CombatPlayerController: unable to resolve BoardView under CombatLayoutRoot/BoardPanel/Board.")
	return null
