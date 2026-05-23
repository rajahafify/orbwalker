extends RefCounted
class_name CombatView

signal enemy_intent_bubble_hovered(kind: String, entry: Dictionary)
signal enemy_block_preview_hovered(preview: Dictionary)
signal intent_hover_ended

const COMBAT_LAYOUT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_layout_presenter.gd")
const COMBAT_CHROME_STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")

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
const TIMER_TRACK_SIZE := Vector2(720, 36)
const TIMER_TRACK_PADDING := 5.0
const INTENT_BUBBLE_SIZE := Vector2(136.0, 58.0)
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(518, 136), Vector2(280, 88))
const TOP_BAR_RECT := Rect2(Vector2(16, 8), Vector2(1048, 116))
const ENEMY_PANEL_RECT := Rect2(Vector2(16, 132), Vector2(1048, 432))
const COMBAT_STRIP_RECT := Rect2(Vector2(16, 576), Vector2(1048, 64))
const BOARD_PANEL_RECT := Rect2(Vector2(16, 660), Vector2(1048, 756))

var _root_nodes: Dictionary = {}
var _board: Control = null
var _board_view: BoardView = null
var _background: TextureRect = null
var _background_scrim: TextureRect = null
var _status_label: Label = null
var _timer_label: Label = null
var _run_progress_label: Label = null
var _turn_summary_label: Label = null
var _player_label: Label = null
var _enemy_label: Label = null
var _enemy_step_label: Label = null
var _enemy_debug_label: Label = null
var _intent_label: Label = null
var _phase_label: Label = null
var _combat_log_text: RichTextLabel = null
var _console_input: LineEdit = null
var _next_button: Button = null
var _back_button: Button = null
var _debug_toggle_button: Button = null
var _settings_button: Button = null
var _board_view_control: Control = null
var _layout_root: Control = null
var _top_bar: Panel = null
var _enemy_panel: PanelContainer = null
var _enemy_panel_root: Control = null
var _intent_row: HBoxContainer = null
var _enemy_stage: Control = null
var _enemy_stage_backdrop: TextureRect = null
var _enemy_ground_shadow: Panel = null
var _enemy_text_scrim: ColorRect = null
var _enemy_hp_row: Control = null
var _enemy_name_label: Label = null
var _enemy_hp_text_label: Label = null
var _combat_strip: PanelContainer = null
var _timer_track: Control = null
var _timer_fill: ColorRect = null
var _timer_icon: TextureRect = null
var _timer_state_label: Label = null
var _timer_center_marker: TextureRect = null
var _board_frame: PanelContainer = null
var _board_panel: Control = null
var _board_shadow: Panel = null
var _outcome_summary_panel: Panel = null
var _outcome_summary_root: Control = null
var _outcome_text_column: Control = null
var _outcome_title_label: Label = null
var _outcome_body_label: Label = null
var _player_hud_section: Panel = null
var _player_panel: Panel = null
var _player_panel_root: Control = null
var _hero_card: Panel = null
var _hero_card_root: Control = null
var _hero_level_badge: PanelContainer = null
var _vitals_panel: Control = null
var _vitals_frame: Panel = null
var _player_hp_label: Label = null
var _player_armor_label: Label = null
var _armor_badge: PanelContainer = null
var _armor_badge_label: Label = null
var _stat_chip_row: HBoxContainer = null
var _attack_stat_label: Label = null
var _armor_stat_label: Label = null
var _heart_stat_label: Label = null
var _gold_stat_label: Label = null
var _combat_meta_row: HBoxContainer = null
var _loadout_frame: Panel = null
var _mastery_strip: Panel = null
var _combat_log_frame: PanelContainer = null
var _debug_overlay: PanelContainer = null
var _title_label: Label = null
var _hint_label: Label = null
var _enemy_portrait: TextureRect = null
var _intent_badge: TextureRect = null
var _primary_intent_text_column: VBoxContainer = null
var _primary_intent_title_label: Label = null
var _primary_intent_amount_label: Label = null
var _primary_intent_detail_label: Label = null
var _enemy_hp_bar: ProgressBar = null
var _player_hp_bar: ProgressBar = null
var _player_armor_bar: ProgressBar = null
var _player_portrait: TextureRect = null
var _relic_icons: HBoxContainer = null
var _mastery_icons: Control = null
var _elemental_mastery_cards: Control = null
var _elemental_mastery_panel: Panel = null
var _elemental_mastery_title: Label = null
var _vfx_layer: Control = null
var _equipment_icons: Control = null
var _consumable_icons: Control = null
var _relic_row: HBoxContainer = null
var _mastery_root: Control = null
var _loadout_root: Control = null
var _equipment_row_label: Label = null
var _consumable_row_label: Label = null
var _relic_row_label: Label = null
var _mastery_row_label: Label = null
var _divider_enemy_timer: TextureRect = null
var _divider_timer_board: TextureRect = null
var _divider_board_player: TextureRect = null
var _corner_top_left: TextureRect = null
var _corner_top_right: TextureRect = null
var _corner_bottom_left: TextureRect = null
var _corner_bottom_right: TextureRect = null
var _zone_guides_enabled := false
var _combat_layout_presenter: Variant = null
var _layout_top_bar_rect := TOP_BAR_RECT
var _layout_enemy_panel_rect := ENEMY_PANEL_RECT
var _layout_combat_strip_rect := COMBAT_STRIP_RECT
var _layout_board_panel_rect := BOARD_PANEL_RECT
var _layout_player_hud_section_rect := Rect2(Vector2(0, 1428), Vector2(1080, 492))
var _is_low_vertical_layout := false

var _visuals: Variant = null
var _player_loadout_hud: Variant = null
var _debug_console: Variant = null
var _outcome_overlay: Variant = null

var _intent_preview_emphasis_tween: Tween = null
var _intent_bubble_tweens: Array[Tween] = []
var _intent_entry_buttons: Array[Button] = []
var _enemy_block_preview_button: Control = null
var _enemy_block_preview_fill: ColorRect = null
var _enemy_block_preview_pulse_tween: Tween = null
var _enemy_block_intent_preview: Dictionary = {}
var _enemy_intent_entries: Array[Dictionary] = []
var _current_enemy_visual_id := "cavern_striker"


func bind(root_nodes: Dictionary) -> void:
	_root_nodes = root_nodes
	for node_name in root_nodes.keys():
		if node_name in self:
			set(node_name, root_nodes[node_name])


func nodes_snapshot() -> Dictionary:
	return _root_nodes


func set_dependencies(dependencies: Dictionary) -> void:
	_visuals = dependencies.get("visual_registry", _visuals)
	_player_loadout_hud = dependencies.get("player_loadout_hud", _player_loadout_hud)
	_debug_console = dependencies.get("debug_console", _debug_console)
	_outcome_overlay = dependencies.get("outcome_overlay", _outcome_overlay)


func set_status_text(text: String) -> void:
	if _status_label != null:
		_status_label.text = text


func set_status_color(color: Color) -> void:
	if _status_label != null:
		_status_label.modulate = color


func set_turn_summary_text(text: String) -> void:
	if _turn_summary_label != null:
		_turn_summary_label.text = text


func turn_summary_text() -> String:
	if _turn_summary_label == null:
		return ""
	return _turn_summary_label.text


func pulse_turn_summary(tint: Color) -> void:
	if _turn_summary_label == null:
		return
	_turn_summary_label.modulate = tint
	_turn_summary_label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func debug_console_nodes() -> Dictionary:
	return {
		"combat_log_text": _combat_log_text,
		"console_input": _console_input,
	}


func connect_debug_console_submit(on_submitted: Callable) -> void:
	if _console_input == null or not _console_input.visible:
		return
	if _console_input.text_submitted.is_connected(on_submitted):
		return
	_console_input.text_submitted.connect(on_submitted)


func set_debug_toggle_button_visible(visible: bool) -> void:
	if _debug_toggle_button != null:
		_debug_toggle_button.visible = visible


func set_debug_overlay_visible(visible: bool) -> void:
	if _debug_overlay != null:
		_debug_overlay.visible = visible
	if _debug_console != null:
		_debug_console.set_overlay_visible(visible)


func toggle_debug_overlay() -> bool:
	var visible := not is_debug_overlay_visible()
	set_debug_overlay_visible(visible)
	return visible


func is_debug_overlay_visible() -> bool:
	if _debug_overlay == null:
		return false
	return _debug_overlay.visible


func outcome_overlay_nodes() -> Dictionary:
	return {
		"layout_root": _layout_root,
		"summary_panel": _outcome_summary_panel,
		"summary_root": _outcome_summary_root,
		"text_column": _outcome_text_column,
		"title_label": _outcome_title_label,
		"body_label": _outcome_body_label,
		"next_button": _next_button,
	}


func bind_outcome_overlay(outcome_overlay: Variant, config: Dictionary) -> void:
	if outcome_overlay == null:
		return
	outcome_overlay.bind(outcome_overlay_nodes(), config)


func set_outcome_body_text(text: String) -> void:
	if _outcome_body_label != null:
		_outcome_body_label.text = text


func set_outcome_next_button_disabled(disabled: bool) -> void:
	if _next_button != null:
		_next_button.disabled = disabled


func next_button_text() -> String:
	if _next_button == null:
		return ""
	return _next_button.text


func bind_player_hud(popover_parent: Control = null, popover_z_index: int = 210) -> void:
	if _player_loadout_hud == null:
		return
	var resolved_popover_parent: Control = popover_parent if popover_parent != null else _layout_root
	_player_loadout_hud.bind_player_hud(_combat_player_hud_nodes(resolved_popover_parent, popover_z_index))


func enemy_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	return _control_target_global(_enemy_portrait, vertical_bias)


func enemy_vfx_size() -> Vector2:
	if _enemy_portrait == null:
		return Vector2.ZERO
	var rect := _enemy_portrait.get_global_rect()
	return rect.size


func player_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	return _control_target_global(_player_portrait, vertical_bias)


func player_hp_bar_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	return _control_target_global(_player_hp_bar, vertical_bias)


func player_hp_bar_vfx_size() -> Vector2:
	if _player_hp_bar == null:
		return Vector2.ZERO
	var rect := _player_hp_bar.get_global_rect()
	return rect.size


func vfx_presenter_bindings(visual_registry: Variant, player_loadout_hud: Variant, timer_owner: Node) -> Dictionary:
	var resolved_visual_registry: Variant = visual_registry if visual_registry != null else _visuals
	var resolved_player_loadout_hud: Variant = player_loadout_hud if player_loadout_hud != null else _player_loadout_hud
	return {
		"vfx_layer": _vfx_layer,
		"visual_registry": resolved_visual_registry,
		"player_loadout_hud": resolved_player_loadout_hud,
		"elemental_mastery_cards": _elemental_mastery_cards,
		"timer_owner": timer_owner,
	}


func resolve_presenter_bindings(
	board_controller: Variant,
	timer_owner: Node,
	spawn_vfx_texture_callback: Callable,
	combo_sound_callback: Callable
) -> Dictionary:
	return {
		"board": _board,
		"board_view": _board_view,
		"board_panel": _board_panel,
		"board_controller": board_controller,
		"timer_owner": timer_owner,
		"spawn_vfx_texture_callback": spawn_vfx_texture_callback,
		"combo_sound_callback": combo_sound_callback,
	}


func bootstrap_background() -> void:
	if _background == null:
		return
	_background.texture = null
	_background.modulate = Color(0.16, 0.17, 0.20, 1.0)


func set_top_bar_text(level_text: String, hint_text: String) -> void:
	if _title_label != null:
		_title_label.text = level_text
	if _hint_label != null:
		_hint_label.text = _format_top_gold_text(hint_text)


func setup_rendering_helpers() -> void:
	_ensure_enemy_stage_backdrop_node()
	_ensure_enemy_ground_shadow_node()
	_ensure_enemy_text_scrim_node()
	_ensure_enemy_block_preview_nodes()


func bind_layout_presenter() -> void:
	if _combat_layout_presenter == null:
		_combat_layout_presenter = COMBAT_LAYOUT_PRESENTER_SCRIPT.new()
	_combat_layout_presenter.bind({
		"layout_root": _layout_root,
		"top_bar": _top_bar,
		"top_bar_row": _top_bar.get_node_or_null("TopBarRow") if _top_bar != null else null,
		"back_button": _back_button,
		"debug_toggle_button": _debug_toggle_button,
		"settings_button": _settings_button,
		"title_label": _title_label,
		"hint_label": _hint_label,
		"enemy_panel": _enemy_panel,
		"enemy_panel_root": _enemy_panel_root,
		"intent_row": _intent_row,
		"enemy_stage": _enemy_stage,
		"enemy_stage_backdrop": _enemy_stage_backdrop,
		"enemy_ground_shadow": _enemy_ground_shadow,
		"enemy_text_scrim": _enemy_text_scrim,
		"enemy_hp_row": _enemy_hp_row,
		"intent_badge": _intent_badge,
		"primary_intent_column": _primary_intent_text_column,
		"primary_intent_title_label": _primary_intent_title_label,
		"primary_intent_amount_label": _primary_intent_amount_label,
		"primary_intent_detail_label": _primary_intent_detail_label,
		"enemy_portrait": _enemy_portrait,
		"enemy_hp_bar": _enemy_hp_bar,
		"enemy_label": _enemy_label,
		"enemy_name_label": _enemy_name_label,
		"enemy_hp_text_label": _enemy_hp_text_label,
		"enemy_step_label": _enemy_step_label,
		"combat_strip": _combat_strip,
		"timer_track": _timer_track,
		"timer_icon": _timer_icon,
		"timer_center_marker": _timer_center_marker,
		"board_panel": _board_panel,
		"board": _board,
		"board_view_control": _board_view_control,
		"board_shadow": _board_shadow,
		"divider_enemy_timer": _divider_enemy_timer,
		"divider_timer_board": _divider_timer_board,
		"divider_board_player": _divider_board_player,
		"corner_top_left": _corner_top_left,
		"corner_top_right": _corner_top_right,
		"corner_bottom_left": _corner_bottom_left,
		"corner_bottom_right": _corner_bottom_right,
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


func apply_combat_layout(viewport_size: Vector2, timer_seconds: float, timer_state: String) -> Dictionary:
	if _combat_layout_presenter == null:
		return {"applied": false}
	var layout_result = _combat_layout_presenter.apply_layout(viewport_size)
	if not bool(layout_result.get("applied", false)):
		return layout_result
	_is_low_vertical_layout = bool(layout_result.get("is_low_vertical_layout", false))
	_layout_top_bar_rect = layout_result.get("layout_top_bar_rect", _layout_top_bar_rect)
	_layout_enemy_panel_rect = layout_result.get("layout_enemy_panel_rect", _layout_enemy_panel_rect)
	_layout_combat_strip_rect = layout_result.get("layout_combat_strip_rect", _layout_combat_strip_rect)
	_layout_board_panel_rect = layout_result.get("layout_board_panel_rect", _layout_board_panel_rect)
	_layout_player_hud_section_rect = layout_result.get("layout_player_hud_section_rect", _layout_player_hud_section_rect)
	sync_timer_display(timer_seconds, timer_state)
	_apply_enemy_visual_profile(_current_enemy_visual_id)
	_layout_enemy_block_intent_preview()
	return layout_result


func apply_loadout_rail_layout() -> void:
	if _combat_layout_presenter != null:
		_combat_layout_presenter.apply_loadout_rail_layout()
		return
	if _player_loadout_hud != null:
		_player_loadout_hud.apply_loadout_rail_layout(_equipment_icons, EQUIPMENT_RAIL_RECT, _consumable_icons, CONSUMABLE_RAIL_RECT)


func render_player_loadout(payload: Dictionary, deferred_layout: bool = true) -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.update_player_data(payload)
	apply_loadout_rail_layout()
	if deferred_layout:
		call_deferred("apply_loadout_rail_layout")
	if _relic_row != null:
		_relic_row.visible = false
	if _mastery_strip != null:
		_mastery_strip.visible = false


func handle_player_hud_global_click(global_position: Vector2) -> bool:
	if _player_loadout_hud == null:
		return false
	return bool(_player_loadout_hud.handle_global_click(global_position))


func hide_player_hud_slot_popover() -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.hide_slot_detail_popover()


func lookup_player_hud_content_definition(item_id: String) -> Dictionary:
	if _player_loadout_hud == null:
		return {}
	return _player_loadout_hud.lookup_content_definition(item_id)


func clear_hovered_combat_mastery() -> void:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return
	_player_loadout_hud.clear_hovered_combat_mastery(_elemental_mastery_cards)


func set_hovered_combat_mastery(orb_id: int) -> void:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return
	_player_loadout_hud.set_hovered_combat_mastery(_elemental_mastery_cards, orb_id)


func clear_combat_mastery_feedback() -> void:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return
	_player_loadout_hud.clear_combat_mastery_feedback(_elemental_mastery_cards)


func set_combat_mastery_feedback(orb_id: int, total: int) -> void:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return
	_player_loadout_hud.set_combat_mastery_feedback(_elemental_mastery_cards, orb_id, total)


func pulse_combat_modifier_sources(sources: Array) -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.pulse_modifier_sources(sources)


func clear_combat_mastery_hover_ui() -> void:
	if _player_loadout_hud == null or _elemental_mastery_cards == null:
		return
	_player_loadout_hud.clear_combat_mastery_hover_ui(_elemental_mastery_cards)


func apply_visual_chrome(style_config: Dictionary) -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_visual_chrome(
		{
			"board_view": _board_view,
			"background": _background,
			"backdrop_scrim": _background_scrim,
			"top_bar": _top_bar,
			"enemy_panel": _enemy_panel,
			"enemy_stage_backdrop": _enemy_stage_backdrop,
			"enemy_ground_shadow": _enemy_ground_shadow,
			"enemy_text_scrim": _enemy_text_scrim,
			"enemy_portrait": _enemy_portrait,
			"enemy_hp_row": _enemy_hp_row,
			"combat_strip": _combat_strip,
			"board_frame": _board_frame,
			"debug_overlay": _debug_overlay,
			"combat_log_frame": _combat_log_frame,
			"enemy_hp_bar": _enemy_hp_bar,
			"player_hp_bar": _player_hp_bar,
			"player_armor_bar": _player_armor_bar,
			"title_label": _title_label,
			"hint_label": _hint_label,
			"enemy_step_label": _enemy_step_label,
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
			"enemy_name_label": _enemy_name_label,
			"enemy_hp_text_label": _enemy_hp_text_label,
			"intent_label": _intent_label,
			"primary_intent_title_label": _primary_intent_title_label,
			"primary_intent_amount_label": _primary_intent_amount_label,
			"primary_intent_detail_label": _primary_intent_detail_label,
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
			"timer_center_marker": _timer_center_marker,
			"intent_badge": _intent_badge,
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
			"divider_enemy_timer": _divider_enemy_timer,
			"divider_timer_board": _divider_timer_board,
			"divider_board_player": _divider_board_player,
			"corner_top_left": _corner_top_left,
			"corner_top_right": _corner_top_right,
			"corner_bottom_left": _corner_bottom_left,
			"corner_bottom_right": _corner_bottom_right,
			"player_loadout_hud": _player_loadout_hud,
			"player_hud_nodes": _combat_player_hud_nodes(),
			"visual_registry": _visuals,
		},
		style_config
	)
	_player_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_ensure_placeholder_visuals()
	_apply_zone_guides()


func set_zone_guides_enabled(enabled: bool) -> void:
	_zone_guides_enabled = enabled
	_apply_zone_guides()


func set_vfx_layer_visible(visible: bool) -> void:
	if _vfx_layer == null:
		return
	_vfx_layer.visible = visible


func apply_hud_snapshot(hud_snapshot: Dictionary, callbacks: Dictionary = {}) -> void:
	_sync_top_hud(hud_snapshot.get("top_hud", {}))
	_sync_enemy_stage(hud_snapshot.get("enemy_stage", {}))
	_sync_primary_intent_badge(hud_snapshot.get("primary_intent_badge", {}))
	_sync_tempo_row(hud_snapshot.get("tempo_row", {}))
	_sync_player_strip(hud_snapshot.get("player_strip", {}), callbacks)
	_sync_debug_overlay(hud_snapshot.get("debug_overlay", {}))


func refresh_character_portraits(enemy_id: String) -> void:
	_ensure_enemy_stage_backdrop_node()
	_ensure_enemy_ground_shadow_node()
	var resolved_enemy_id := enemy_id.strip_edges()
	if resolved_enemy_id == "":
		resolved_enemy_id = "cavern_striker"
	_current_enemy_visual_id = resolved_enemy_id

	var backdrop_texture: Texture2D = null
	if _visuals != null:
		backdrop_texture = _visuals.combat_enemy_stage_texture(resolved_enemy_id)
		if backdrop_texture == null:
			backdrop_texture = _visuals.combat_enemy_stage_texture("cavern_striker")
	if backdrop_texture == null:
		backdrop_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	if _enemy_stage_backdrop != null and is_instance_valid(_enemy_stage_backdrop):
		_enemy_stage_backdrop.texture = backdrop_texture
		_enemy_stage_backdrop.visible = true

	var enemy_figure_texture: Texture2D = null
	if _visuals != null:
		enemy_figure_texture = _visuals.enemy_sprite(resolved_enemy_id)
		if enemy_figure_texture == null:
			enemy_figure_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_figure_texture == null:
		enemy_figure_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_figure_texture
	_enemy_portrait.visible = true
	_apply_enemy_visual_profile(resolved_enemy_id)

	var hero_texture: Texture2D = null
	if _visuals != null:
		hero_texture = _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture
	_player_portrait.visible = true


func sync_timer_display(seconds_left: float, state: String) -> void:
	var clamped_seconds := clampf(seconds_left, 0.0, MOVE_TIMER_MAX_SECONDS)
	var time_ratio := 0.0
	if MOVE_TIMER_MAX_SECONDS > 0.0:
		time_ratio = clamped_seconds / MOVE_TIMER_MAX_SECONDS

	var label_text := "READY"
	var state_text := "READY"
	var timer_color := TIMER_READY_COLOR
	var text_color := TIMER_TEXT_COLOR
	var fill_ratio := 0.0
	var show_fill := false
	var text_alpha := 1.0
	if state == "active":
		show_fill = true
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
		if state == "locked":
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
	_timer_fill.color = Color(timer_color.r, timer_color.g, timer_color.b, 0.72 if show_fill else 0.0)
	_timer_fill.visible = show_fill
	_timer_label.text = label_text
	_timer_state_label.text = state_text
	var final_text_color := Color(text_color.r, text_color.g, text_color.b, text_alpha)
	_timer_label.add_theme_color_override("font_color", final_text_color)
	_timer_state_label.add_theme_color_override("font_color", final_text_color)
	_timer_icon.modulate = final_text_color


func start_enemy_intent_hover_emphasis(kind: String) -> void:
	for tween in _intent_bubble_tweens:
		if tween != null and is_instance_valid(tween):
			tween.kill()
	_intent_bubble_tweens.clear()
	_reset_enemy_intent_emphasis()
	var targets := _intent_bubble_targets(kind)
	if targets.is_empty():
		return
	var tint := Color(1.0, 0.30, 0.24, 1.0) if kind == "attack" else Color(0.86, 0.92, 1.0, 1.0)
	for target in targets:
		if target == null or not is_instance_valid(target):
			continue
		target.modulate = tint
		target.scale = Vector2(1.12, 1.12)


func stop_enemy_intent_hover_emphasis() -> void:
	if _intent_preview_emphasis_tween != null and is_instance_valid(_intent_preview_emphasis_tween):
		_intent_preview_emphasis_tween.kill()
	_intent_preview_emphasis_tween = null
	_reset_enemy_intent_emphasis()


func _sync_top_hud(snapshot: Dictionary) -> void:
	_title_label.text = String(snapshot.get("level_text", "LEVEL"))
	_enemy_step_label.text = String(snapshot.get("enemy_step_text", "FIGHT"))
	_hint_label.text = _format_top_gold_text(String(snapshot.get("gold_text", "GOLD 0")))


func _format_top_gold_text(text: String) -> String:
	var clean_text := text.strip_edges()
	if clean_text.begins_with("$"):
		return clean_text
	if clean_text.to_upper().begins_with("GOLD"):
		var amount_text := clean_text.substr(4).strip_edges()
		return "$  %s" % amount_text
	return clean_text


func _sync_enemy_stage(snapshot: Dictionary) -> void:
	_intent_label.text = ""
	_intent_label.visible = false
	_sync_enemy_intent_bubbles(Dictionary(snapshot.get("enemy_intent_preview", {})))
	var enemy_id := String(snapshot.get("enemy_id", _current_enemy_visual_id))
	if enemy_id.strip_edges() != "":
		_current_enemy_visual_id = enemy_id.strip_edges()
	var enemy_stage_texture: Texture2D = snapshot.get("enemy_stage_texture", null)
	if _enemy_stage_backdrop != null and is_instance_valid(_enemy_stage_backdrop):
		var backdrop_texture: Texture2D = enemy_stage_texture
		if backdrop_texture == null and _visuals != null:
			backdrop_texture = _visuals.combat_enemy_stage_texture("cavern_striker")
		if backdrop_texture == null:
			backdrop_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
		_enemy_stage_backdrop.texture = backdrop_texture
		_enemy_stage_backdrop.visible = true
	var enemy_figure_texture: Texture2D = snapshot.get("enemy_portrait_texture", null)
	if enemy_figure_texture == null and _visuals != null:
		enemy_figure_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_figure_texture == null:
		enemy_figure_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_figure_texture
	_enemy_portrait.visible = true
	_apply_enemy_visual_profile(_current_enemy_visual_id)
	_enemy_hp_bar.max_value = float(maxi(1, int(snapshot.get("enemy_hp_max", 1))))
	_enemy_hp_bar.value = float(int(snapshot.get("enemy_hp_value", 0)))
	_enemy_name_label.text = String(snapshot.get("enemy_name_text", "Enemy"))
	_enemy_label.text = _enemy_name_label.text
	_enemy_hp_text_label.text = String(snapshot.get("enemy_hp_text", "HP 0 / 0"))
	_sync_enemy_block_intent_preview(Dictionary(snapshot.get("enemy_intent_preview", {})))


func _sync_primary_intent_badge(_snapshot: Dictionary) -> void:
	_intent_badge.visible = false
	_primary_intent_text_column.visible = false
	_primary_intent_title_label.visible = false
	_primary_intent_amount_label.visible = false
	_primary_intent_detail_label.visible = false


func _sync_tempo_row(snapshot: Dictionary) -> void:
	_phase_label.text = String(snapshot.get("phase_text", ""))
	sync_timer_display(
		float(snapshot.get("timer_seconds", 0.0)),
		String(snapshot.get("timer_state", "ready"))
	)


func _sync_player_strip(snapshot: Dictionary, callbacks: Dictionary) -> void:
	_player_label.text = String(snapshot.get("player_text", ""))
	_player_hp_bar.max_value = float(maxi(1, int(snapshot.get("player_hp_max", 1))))
	_player_hp_bar.value = float(int(snapshot.get("player_hp_value", 0)))
	_player_armor_bar.max_value = float(maxi(1, int(snapshot.get("player_armor_max", 1))))
	_player_armor_bar.value = float(maxi(0, int(snapshot.get("player_armor_value", 0))))
	_player_armor_label.text = String(snapshot.get("player_armor_text", "0 / 0"))
	_armor_badge.visible = false
	_armor_badge_label.text = String(snapshot.get("armor_badge_text", ""))
	_attack_stat_label.text = String(snapshot.get("attack_stat_text", ""))
	_armor_stat_label.text = String(snapshot.get("armor_stat_text", ""))
	_heart_stat_label.text = String(snapshot.get("heart_stat_text", ""))
	_gold_stat_label.text = String(snapshot.get("gold_stat_text", ""))
	_run_progress_label.text = String(snapshot.get("run_progress_text", ""))
	_phase_label.text = String(snapshot.get("phase_text", ""))
	_turn_summary_label.text = String(snapshot.get("turn_summary_text", ""))
	var progression_snapshot: Dictionary = snapshot.get("progression_snapshot", {})
	var refresh_callback: Variant = callbacks.get("refresh_build_icon_rows", Callable())
	if refresh_callback is Callable and (refresh_callback as Callable).is_valid():
		(refresh_callback as Callable).call(progression_snapshot)


func _sync_debug_overlay(snapshot: Dictionary) -> void:
	_status_label.text = String(snapshot.get("status_text", ""))
	_enemy_debug_label.text = String(snapshot.get("enemy_text", ""))


func _intent_bubble_targets(kind: String) -> Array[Control]:
	var targets: Array[Control] = []
	for button in _intent_entry_buttons:
		if button == null or not is_instance_valid(button):
			continue
		if String(button.get_meta("intent_kind", "")) == kind:
			targets.append(button)
	if targets.is_empty() and _intent_badge != null and _intent_badge.visible:
		targets.append(_intent_badge)
	return targets


func _reset_enemy_intent_emphasis() -> void:
	_intent_row.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_intent_label.scale = Vector2.ONE
	_intent_badge.scale = Vector2.ONE
	_intent_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_intent_badge.modulate = Color(1.0, 1.0, 1.0, 1.0)
	for button in _intent_entry_buttons:
		if button == null or not is_instance_valid(button):
			continue
		button.scale = Vector2.ONE
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _sync_enemy_intent_bubbles(preview: Dictionary) -> void:
	_enemy_intent_entries.clear()
	_clear_enemy_intent_bubbles()
	if preview.has("entries") and preview.get("entries") is Array:
		for raw in Array(preview.get("entries", [])):
			if raw is Dictionary:
				_enemy_intent_entries.append((raw as Dictionary).duplicate(true))
	if _intent_row == null:
		return
	var has_entries := not _enemy_intent_entries.is_empty()
	_intent_badge.visible = false
	_intent_label.visible = false
	_primary_intent_text_column.visible = false
	_intent_row.visible = has_entries
	if not has_entries:
		return
	var index := 0
	for entry in _enemy_intent_entries:
		var button := _make_intent_entry_button(entry, index)
		_intent_row.add_child(button)
		_intent_entry_buttons.append(button)
		index += 1


func _clear_enemy_intent_bubbles() -> void:
	for tween in _intent_bubble_tweens:
		if tween != null and is_instance_valid(tween):
			tween.kill()
	_intent_bubble_tweens.clear()
	for button in _intent_entry_buttons:
		if button != null and is_instance_valid(button):
			button.queue_free()
	_intent_entry_buttons.clear()


func _make_intent_entry_button(entry: Dictionary, index: int) -> Button:
	var button := Button.new()
	var kind := String(entry.get("kind", ""))
	var amount := maxi(0, int(entry.get("amount", 0)))
	button.name = "EnemyIntent%s%d" % [kind.capitalize(), index]
	button.text = String(entry.get("label", _intent_entry_label(kind, amount)))
	button.custom_minimum_size = INTENT_BUBBLE_SIZE
	button.size = INTENT_BUBBLE_SIZE
	button.focus_mode = Control.FocusMode.FOCUS_NONE as Control.FocusMode
	button.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND as Control.CursorShape
	button.pivot_offset = INTENT_BUBBLE_SIZE * 0.5
	button.set_meta("intent_kind", kind)
	button.add_theme_font_size_override("font_size", 24)
	button.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.95))
	button.add_theme_stylebox_override("normal", _intent_bubble_stylebox(kind, false))
	button.add_theme_stylebox_override("hover", _intent_bubble_stylebox(kind, true))
	button.add_theme_stylebox_override("pressed", _intent_bubble_stylebox(kind, true))
	button.mouse_entered.connect(_on_enemy_intent_bubble_hovered.bind(kind, entry.duplicate(true)))
	button.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
	return button


func _intent_bubble_stylebox(kind: String, hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := Color(0.12, 0.04, 0.04, 0.94) if kind == "attack" else Color(0.10, 0.13, 0.16, 0.90)
	var border := Color(1.0, 0.22, 0.20, 1.0) if kind == "attack" else Color(0.72, 0.82, 0.92, 0.95)
	if hover:
		bg = bg.lightened(0.08)
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _on_enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	enemy_intent_bubble_hovered.emit(kind, entry)


func _on_intent_damage_preview_hover_ended() -> void:
	intent_hover_ended.emit()


func _ensure_enemy_block_preview_nodes() -> void:
	if _enemy_hp_row == null:
		return
	if _enemy_block_preview_button == null or not is_instance_valid(_enemy_block_preview_button):
		_enemy_block_preview_button = Control.new()
		_enemy_block_preview_button.name = "EnemyBlockIntentPreviewButton"
		_enemy_block_preview_button.visible = false
		_enemy_block_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		_enemy_block_preview_button.mouse_default_cursor_shape = Control.CursorShape.CURSOR_POINTING_HAND as Control.CursorShape
		_enemy_block_preview_button.mouse_entered.connect(_on_enemy_block_preview_node_hovered)
		_enemy_block_preview_button.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
	if _enemy_block_preview_button.get_parent() != _enemy_hp_row:
		var existing_parent := _enemy_block_preview_button.get_parent()
		if existing_parent != null:
			existing_parent.remove_child(_enemy_block_preview_button)
		_enemy_hp_row.add_child(_enemy_block_preview_button)
	if _enemy_block_preview_fill == null or not is_instance_valid(_enemy_block_preview_fill):
		_enemy_block_preview_fill = ColorRect.new()
		_enemy_block_preview_fill.name = "EnemyBlockIntentPreviewFill"
		_enemy_block_preview_fill.color = Color(0.86, 0.90, 0.94, 0.68)
		_enemy_block_preview_fill.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		_enemy_block_preview_fill.visible = false
	if _enemy_block_preview_fill.get_parent() != _enemy_block_preview_button:
		var existing_fill_parent := _enemy_block_preview_fill.get_parent()
		if existing_fill_parent != null:
			existing_fill_parent.remove_child(_enemy_block_preview_fill)
		_enemy_block_preview_button.add_child(_enemy_block_preview_fill)


func _sync_enemy_block_intent_preview(preview: Dictionary) -> void:
	_enemy_block_intent_preview = preview.duplicate(true)
	_layout_enemy_block_intent_preview()


func _layout_enemy_block_intent_preview() -> void:
	_ensure_enemy_block_preview_nodes()
	if _enemy_block_preview_button != null and is_instance_valid(_enemy_block_preview_button):
		_enemy_block_preview_button.visible = false
		_enemy_block_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	if _enemy_block_preview_fill != null and is_instance_valid(_enemy_block_preview_fill):
		_enemy_block_preview_fill.visible = false
	_stop_enemy_block_preview_pulse()
	if _enemy_block_intent_preview.is_empty():
		return
	if _enemy_hp_bar == null or _enemy_block_preview_button == null or _enemy_block_preview_fill == null:
		return
	var block := maxi(0, int(_enemy_block_intent_preview.get("block", 0)))
	var max_hp := maxi(1, int(_enemy_block_intent_preview.get("max_hp", int(_enemy_hp_bar.max_value))))
	if block <= 0:
		return
	var bar_width := maxf(0.0, _enemy_hp_bar.size.x)
	if bar_width <= 0.0:
		return
	var preview_width := bar_width * clampf(float(block) / float(max_hp), 0.0, 1.0)
	if preview_width <= 0.0:
		return
	_enemy_block_preview_button.position = _enemy_hp_bar.position
	_enemy_block_preview_button.size = Vector2(preview_width, _enemy_hp_bar.size.y)
	_enemy_block_preview_button.visible = true
	_enemy_block_preview_button.mouse_filter = Control.MouseFilter.MOUSE_FILTER_STOP as Control.MouseFilter
	_enemy_block_preview_fill.position = Vector2.ZERO
	_enemy_block_preview_fill.size = _enemy_block_preview_button.size
	_enemy_block_preview_fill.visible = true
	_start_enemy_block_preview_pulse()


func _start_enemy_block_preview_pulse() -> void:
	if _enemy_block_preview_fill == null or not is_instance_valid(_enemy_block_preview_fill):
		return
	_stop_enemy_block_preview_pulse()
	_enemy_block_preview_fill.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_enemy_block_preview_pulse_tween = null


func _stop_enemy_block_preview_pulse() -> void:
	if _enemy_block_preview_pulse_tween != null and is_instance_valid(_enemy_block_preview_pulse_tween):
		_enemy_block_preview_pulse_tween.kill()
	_enemy_block_preview_pulse_tween = null
	if _enemy_block_preview_fill != null and is_instance_valid(_enemy_block_preview_fill):
		_enemy_block_preview_fill.modulate = Color(1.0, 1.0, 1.0, 0.68)


func _on_enemy_block_preview_node_hovered() -> void:
	enemy_block_preview_hovered.emit(_enemy_block_intent_preview.duplicate(true))


func _intent_entry_label(kind: String, amount: int) -> String:
	match kind:
		"attack":
			return "Attack %d" % amount
		"block":
			return "Block %d" % amount
		_:
			return "%s %d" % [kind.capitalize(), amount]


func _ensure_placeholder_visuals() -> void:
	if _timer_icon.texture == null:
		_timer_icon.texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_timer_placeholder_texture()
	_timer_icon.visible = true
	_intent_badge.visible = false
	_intent_label.visible = false
	_primary_intent_text_column.visible = false
	var backdrop_texture: Texture2D = null
	if _visuals != null:
		backdrop_texture = _visuals.combat_enemy_stage_texture("cavern_striker")
	if backdrop_texture == null:
		backdrop_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	if _enemy_stage_backdrop != null and is_instance_valid(_enemy_stage_backdrop):
		_enemy_stage_backdrop.texture = backdrop_texture
		_enemy_stage_backdrop.visible = true
	var hero_texture: Texture2D = null
	if _visuals != null:
		hero_texture = _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	_player_portrait.texture = hero_texture
	_player_portrait.visible = true


func _ensure_enemy_stage_backdrop_node() -> void:
	if _enemy_stage == null:
		return
	if _enemy_stage_backdrop != null and is_instance_valid(_enemy_stage_backdrop):
		if _enemy_stage_backdrop.get_parent() != _enemy_stage:
			var existing_parent := _enemy_stage_backdrop.get_parent()
			if existing_parent != null:
				existing_parent.remove_child(_enemy_stage_backdrop)
			_enemy_stage.add_child(_enemy_stage_backdrop)
		_enemy_stage.move_child(_enemy_stage_backdrop, 0)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyStageBackdrop")
	if existing is TextureRect:
		_enemy_stage_backdrop = existing as TextureRect
	else:
		_enemy_stage_backdrop = TextureRect.new()
		_enemy_stage_backdrop.name = "EnemyStageBackdrop"
		_enemy_stage.add_child(_enemy_stage_backdrop)
	_enemy_stage_backdrop.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_enemy_stage_backdrop.expand_mode = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_enemy_stage_backdrop.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_enemy_stage_backdrop.modulate = Color(1.0, 1.0, 1.0, 0.94)
	_enemy_stage_backdrop.visible = true
	_enemy_stage.move_child(_enemy_stage_backdrop, 0)


func _ensure_enemy_ground_shadow_node() -> void:
	if _enemy_stage == null:
		return
	if _enemy_ground_shadow != null and is_instance_valid(_enemy_ground_shadow):
		if _enemy_ground_shadow.get_parent() != _enemy_stage:
			var existing_parent := _enemy_ground_shadow.get_parent()
			if existing_parent != null:
				existing_parent.remove_child(_enemy_ground_shadow)
			_enemy_stage.add_child(_enemy_ground_shadow)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyGroundShadow")
	if existing is Panel:
		_enemy_ground_shadow = existing as Panel
	else:
		_enemy_ground_shadow = Panel.new()
		_enemy_ground_shadow.name = "EnemyGroundShadow"
		_enemy_stage.add_child(_enemy_ground_shadow)
	_enemy_ground_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_enemy_ground_shadow.z_index = 1
	_enemy_ground_shadow.visible = true


func _apply_enemy_visual_profile(enemy_id: String) -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	var stage_size := _enemy_stage.size if _enemy_stage != null else Vector2.ZERO
	if stage_size.x <= 0.0 or stage_size.y <= 0.0:
		stage_size = _layout_enemy_panel_rect.size
	var profile := {}
	if _visuals != null and _visuals.has_method("enemy_visual_profile"):
		profile = Dictionary(_visuals.enemy_visual_profile(enemy_id))
	var scale := float(profile.get("scale", 1.0))
	var offset: Vector2 = profile.get("offset", Vector2.ZERO)
	var shadow_scale := float(profile.get("shadow_scale", 1.0))
	var shadow_alpha := float(profile.get("shadow_alpha", 0.34))

	_enemy_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	_enemy_portrait.position = offset
	_enemy_portrait.size = stage_size
	_enemy_portrait.pivot_offset = stage_size * 0.5
	_enemy_portrait.scale = Vector2(scale, scale)
	_enemy_portrait.z_index = 2
	if _enemy_stage_backdrop != null and is_instance_valid(_enemy_stage_backdrop):
		_enemy_stage_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	if _enemy_text_scrim != null and is_instance_valid(_enemy_text_scrim):
		_enemy_text_scrim.z_index = 3

	_ensure_enemy_ground_shadow_node()
	if _enemy_ground_shadow == null or not is_instance_valid(_enemy_ground_shadow):
		return
	var shadow_size := Vector2(stage_size.x * 0.36 * shadow_scale, maxf(30.0, stage_size.y * 0.11 * shadow_scale))
	_enemy_ground_shadow.position = Vector2((stage_size.x - shadow_size.x) * 0.5, stage_size.y * 0.73)
	_enemy_ground_shadow.size = shadow_size
	_enemy_ground_shadow.z_index = 1
	_enemy_ground_shadow.visible = _enemy_portrait.visible
	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color(0.0, 0.0, 0.0, clampf(shadow_alpha, 0.0, 0.65))
	shadow_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	shadow_style.set_corner_radius_all(999)
	_enemy_ground_shadow.add_theme_stylebox_override("panel", shadow_style)


func _ensure_enemy_text_scrim_node() -> void:
	if _enemy_stage == null:
		return
	if _enemy_text_scrim != null and is_instance_valid(_enemy_text_scrim):
		if _enemy_text_scrim.get_parent() != _enemy_stage:
			var existing_parent := _enemy_text_scrim.get_parent()
			if existing_parent != null:
				existing_parent.remove_child(_enemy_text_scrim)
			_enemy_stage.add_child(_enemy_text_scrim)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyTextScrim")
	if existing is ColorRect:
		_enemy_text_scrim = existing as ColorRect
	else:
		_enemy_text_scrim = ColorRect.new()
		_enemy_text_scrim.name = "EnemyTextScrim"
		_enemy_stage.add_child(_enemy_text_scrim)
	_enemy_text_scrim.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_enemy_text_scrim.color = Color(0.02, 0.04, 0.06, 0.72)
	_enemy_text_scrim.visible = true


func _apply_zone_guides() -> void:
	_set_zone_guide(_top_bar, "TopBar")
	_set_zone_guide(_enemy_panel, "EnemyPanel")
	_set_zone_guide(_combat_strip, "CombatStrip")
	_set_zone_guide(_board_panel, "BoardPanel")
	_set_zone_guide(_player_panel, "PlayerPanel")


func _set_zone_guide(zone: Control, label_text: String) -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_zone_guide(zone, label_text, _zone_guides_enabled)


func _combat_player_hud_nodes(popover_parent: Control = null, popover_z_index: int = 210) -> Dictionary:
	var nodes := {
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
	if popover_parent != null:
		nodes["popover_parent"] = popover_parent
		nodes["popover_z_index"] = popover_z_index
	return nodes


func _control_target_global(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0)
	)
