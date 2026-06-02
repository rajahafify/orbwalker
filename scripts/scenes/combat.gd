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

const ROOT_NODE_TYPES := {
	"_board": "Control",
	"_background": "TextureRect",
	"_background_scrim": "TextureRect",
	"_status_label": "Label",
	"_timer_label": "Label",
	"_run_progress_label": "Label",
	"_turn_summary_label": "Label",
	"_player_label": "Label",
	"_enemy_label": "Label",
	"_enemy_step_label": "Label",
	"_enemy_debug_label": "Label",
	"_intent_label": "Label",
	"_phase_label": "Label",
	"_combat_log_text": "RichTextLabel",
	"_console_input": "LineEdit",
	"_next_button": "Button",
	"_back_button": "Button",
	"_debug_toggle_button": "Button",
	"_settings_button": "Button",
	"_board_view_control": "Control",
	"_layout_root": "Control",
	"_top_bar": "TopHeader",
	"_enemy_panel": "PanelContainer",
	"_enemy_panel_root": "Control",
	"_intent_row": "HBoxContainer",
	"_enemy_stage": "Control",
	"_enemy_hp_row": "Control",
	"_enemy_name_label": "Label",
	"_enemy_hp_text_label": "Label",
	"_combat_strip": "PanelContainer",
	"_timer_track": "Control",
	"_timer_fill": "ColorRect",
	"_timer_icon": "TextureRect",
	"_timer_state_label": "Label",
	"_timer_center_marker": "TextureRect",
	"_board_frame": "PanelContainer",
	"_board_panel": "Control",
	"_board_shadow": "Panel",
	"_outcome_summary_panel": "Panel",
	"_outcome_summary_root": "Control",
	"_outcome_text_column": "Control",
	"_outcome_title_label": "Label",
	"_outcome_body_label": "Label",
	"_player_hud_section": "Panel",
	"_player_panel": "Panel",
	"_player_panel_root": "Control",
	"_hero_card": "Panel",
	"_hero_card_root": "Control",
	"_hero_level_badge": "PanelContainer",
	"_vitals_panel": "Control",
	"_vitals_frame": "Panel",
	"_player_hp_label": "Label",
	"_player_armor_label": "Label",
	"_armor_badge": "PanelContainer",
	"_armor_badge_label": "Label",
	"_stat_chip_row": "HBoxContainer",
	"_attack_stat_label": "Label",
	"_armor_stat_label": "Label",
	"_heart_stat_label": "Label",
	"_gold_stat_label": "Label",
	"_combat_meta_row": "HBoxContainer",
	"_loadout_frame": "Panel",
	"_loadout_root": "Control",
	"_mastery_strip": "Panel",
	"_mastery_root": "Control",
	"_combat_log_frame": "PanelContainer",
	"_debug_overlay": "PanelContainer",
	"_title_label": "Label",
	"_hint_label": "Label",
	"_enemy_portrait": "TextureRect",
	"_intent_badge": "TextureRect",
	"_primary_intent_text_column": "VBoxContainer",
	"_primary_intent_title_label": "Label",
	"_primary_intent_amount_label": "Label",
	"_primary_intent_detail_label": "Label",
	"_enemy_hp_bar": "ProgressBar",
	"_player_hp_bar": "ProgressBar",
	"_player_armor_bar": "ProgressBar",
	"_player_portrait": "TextureRect",
	"_equipment_icons": "Control",
	"_consumable_icons": "Control",
	"_relic_icons": "HBoxContainer",
	"_mastery_icons": "Control",
	"_elemental_mastery_cards": "Control",
	"_elemental_mastery_panel": "Panel",
	"_elemental_mastery_title": "Label",
	"_relic_row": "HBoxContainer",
	"_equipment_row_label": "Label",
	"_consumable_row_label": "Label",
	"_relic_row_label": "Label",
	"_mastery_row_label": "Label",
	"_vfx_layer": "Control",
	"_divider_enemy_timer": "TextureRect",
	"_divider_timer_board": "TextureRect",
	"_divider_board_player": "TextureRect",
	"_corner_top_left": "TextureRect",
	"_corner_top_right": "TextureRect",
	"_corner_bottom_left": "TextureRect",
	"_corner_bottom_right": "TextureRect",
	"_board_view": "BoardView",
}

var _model
var _view
var _controller
var _root_nodes: Dictionary = {}
var _last_settings_press_msec := -1000000


func _enter_tree() -> void:
	_ensure_mvc()
	_controller.enter_tree()


func _ready() -> void:
	_ensure_mvc()
	_root_nodes = _build_root_nodes()
	_connect_header_action_signals()
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
	var now := Time.get_ticks_msec()
	if now - _last_settings_press_msec < 180:
		return
	_last_settings_press_msec = now
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


func _connect_header_action_signals() -> void:
	var top_bar := _root_nodes.get("_top_bar") as TopHeader
	if top_bar == null:
		return
	var settings_callback := Callable(self, "_on_settings_button_pressed")
	if not top_bar.settings_pressed.is_connected(settings_callback):
		top_bar.settings_pressed.connect(settings_callback)
	var help_callback := Callable(self, "_on_back_button_pressed")
	if not top_bar.help_pressed.is_connected(help_callback):
		top_bar.help_pressed.connect(help_callback)


func _build_root_nodes() -> Dictionary:
	var nodes := {}
	var hud_section: Node = _resolve_bound_node(ROOT_NODE_BINDINGS.get("_player_hud_section"), null)
	for node_name in ROOT_NODE_BINDINGS.keys():
		var node: Node = _resolve_bound_node(ROOT_NODE_BINDINGS[node_name], hud_section)
		if node == null:
			push_error("Combat scene root node binding failed: %s -> %s" % [node_name, _binding_label(ROOT_NODE_BINDINGS[node_name])])
		elif not _node_matches_expected_type(node, String(ROOT_NODE_TYPES.get(node_name, ""))):
			push_error("Combat scene root node binding type mismatch: %s expected %s, got %s at %s" % [
				node_name,
				String(ROOT_NODE_TYPES.get(node_name, "")),
				_node_type_label(node),
				_binding_label(ROOT_NODE_BINDINGS[node_name]),
			])
			node = null
		nodes[node_name] = node
	var board_view: BoardView = _resolve_board_view(nodes)
	if board_view != null and not _node_matches_expected_type(board_view, String(ROOT_NODE_TYPES.get("_board_view", ""))):
		push_error("Combat scene root node binding type mismatch: _board_view expected %s, got %s" % [
			String(ROOT_NODE_TYPES.get("_board_view", "")),
			_node_type_label(board_view),
		])
		board_view = null
	nodes["_board_view"] = board_view
	return nodes


func _root_node_types() -> Dictionary:
	return ROOT_NODE_TYPES.duplicate()


func _resolve_bound_node(binding: Variant, hud_section: Node) -> Node:
	if binding is NodePath:
		var path: NodePath = binding
		return get_node_or_null(path)
	if binding is Array:
		var binding_parts: Array = binding
		if binding_parts.size() == 2 and String(binding_parts[0]) == "player_hud":
			return _player_hud_node(String(binding_parts[1]), hud_section)
	return null


func _node_matches_expected_type(node: Node, expected_type: String) -> bool:
	if node == null or expected_type == "":
		return expected_type == ""
	match expected_type:
		"BoardView":
			return node is BoardView
		"TopHeader":
			return node is TopHeader
		_:
			return node.is_class(expected_type)


func _node_type_label(node: Node) -> String:
	if node == null:
		return "<null>"
	if node is BoardView:
		return "BoardView"
	if node is TopHeader:
		return "TopHeader"
	return node.get_class()


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
