extends RefCounted
class_name CombatView

signal enemy_intent_bubble_hovered(kind: String, entry: Dictionary)
signal enemy_block_preview_hovered(preview: Dictionary)
signal intent_hover_ended
signal tutorial_end_continue_pressed
signal tutorial_end_main_menu_pressed
signal settings_continue_pressed
signal settings_new_run_pressed
signal settings_main_menu_pressed
signal settings_speed_selected(speed: String)

const COMBAT_LAYOUT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_layout_presenter.gd")
const COMBAT_CHROME_STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const COMBAT_SURFACE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_surface_presenter.gd")
const COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
const COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_overlay_presenter.gd")
const COMBAT_ENEMY_INTENT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_intent_presenter.gd")
const COMBAT_ENEMY_STAGE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_stage_presenter.gd")
const COMBAT_PLAYER_HUD_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_player_hud_presenter.gd")
const COMBAT_HUD_SNAPSHOT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_hud_snapshot_presenter.gd")
const COMBAT_CHARACTER_VISUALS_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_character_visuals_presenter.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
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
var _surface_presenter: Variant = null
var _settings_overlay_presenter: Variant = null
var _tutorial_end_overlay_presenter: Variant = null
var _enemy_intent_presenter: Variant = null
var _enemy_stage_presenter: Variant = null
var _player_hud_presenter: Variant = null
var _hud_snapshot_presenter: Variant = null
var _character_visuals_presenter: Variant = null
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

var _current_enemy_visual_id := "cavern_striker"


func bind(root_nodes: Dictionary) -> void:
	_root_nodes = root_nodes
	for node_name in root_nodes.keys():
		if node_name in self:
			set(node_name, root_nodes[node_name])
	_sync_surface_presenter()


func nodes_snapshot() -> Dictionary:
	return _root_nodes


func set_dependencies(dependencies: Dictionary) -> void:
	_visuals = dependencies.get("visual_registry", _visuals)
	_player_loadout_hud = dependencies.get("player_loadout_hud", _player_loadout_hud)
	_debug_console = dependencies.get("debug_console", _debug_console)
	_outcome_overlay = dependencies.get("outcome_overlay", _outcome_overlay)
	_sync_surface_presenter()


func set_status_text(text: String) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_status_text(text)


func set_status_color(color: Color) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_status_color(color)


func set_turn_summary_text(text: String) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_turn_summary_text(text)


func turn_summary_text() -> String:
	_ensure_surface_presenter()
	return _surface_presenter.turn_summary_text()


func pulse_turn_summary(tint: Color) -> void:
	_ensure_surface_presenter()
	_surface_presenter.pulse_turn_summary(tint)


func debug_console_nodes() -> Dictionary:
	_ensure_surface_presenter()
	return _surface_presenter.debug_console_nodes()


func connect_debug_console_submit(on_submitted: Callable) -> void:
	_ensure_surface_presenter()
	_surface_presenter.connect_debug_console_submit(on_submitted)


func set_debug_toggle_button_visible(visible: bool) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_debug_toggle_button_visible(visible)


func set_debug_overlay_visible(visible: bool) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_debug_overlay_visible(visible)


func show_settings_overlay(speed: String) -> void:
	_ensure_settings_overlay()
	if _settings_overlay_presenter != null:
		_settings_overlay_presenter.show(speed)


func hide_settings_overlay() -> void:
	if _settings_overlay_presenter != null:
		_settings_overlay_presenter.hide()


func toggle_debug_overlay() -> bool:
	_ensure_surface_presenter()
	return _surface_presenter.toggle_debug_overlay()


func is_debug_overlay_visible() -> bool:
	_ensure_surface_presenter()
	return _surface_presenter.is_debug_overlay_visible()


func outcome_overlay_nodes() -> Dictionary:
	_ensure_surface_presenter()
	return _surface_presenter.outcome_overlay_nodes()


func bind_outcome_overlay(outcome_overlay: Variant, config: Dictionary = {}) -> void:
	_ensure_surface_presenter()
	_surface_presenter.bind_outcome_overlay(outcome_overlay, config)


func set_outcome_body_text(text: String) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_outcome_body_text(text)


func set_outcome_next_button_disabled(disabled: bool) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_outcome_next_button_disabled(disabled)


func next_button_text() -> String:
	_ensure_surface_presenter()
	return _surface_presenter.next_button_text()


func bind_player_hud(popover_parent: Control = null, popover_z_index: int = 210) -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.bind_player_hud(popover_parent, popover_z_index)


func enemy_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return Vector2.ZERO
	return _player_hud_presenter.vfx_target_global("_enemy_portrait", vertical_bias)


func enemy_vfx_size() -> Vector2:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return Vector2.ZERO
	return _player_hud_presenter.vfx_size("_enemy_portrait")


func player_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return Vector2.ZERO
	return _player_hud_presenter.vfx_target_global("_player_portrait", vertical_bias)


func player_hp_bar_vfx_target_global(vertical_bias: float = 0.5) -> Vector2:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return Vector2.ZERO
	return _player_hud_presenter.vfx_target_global("_player_hp_bar", vertical_bias)


func player_hp_bar_vfx_size() -> Vector2:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return Vector2.ZERO
	return _player_hud_presenter.vfx_size("_player_hp_bar")


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
	_ensure_surface_presenter()
	_surface_presenter.bootstrap_background()


func set_top_bar_text(level_text: String, hint_text: String) -> void:
	_ensure_hud_snapshot_presenter()
	if _hud_snapshot_presenter != null:
		_hud_snapshot_presenter.apply_top_hud({
			"level_text": level_text,
			"enemy_step_text": _enemy_step_label.text if _enemy_step_label != null else "FIGHT",
			"gold_text": hint_text,
		})


func setup_rendering_helpers() -> void:
	_ensure_enemy_stage_backdrop_node()
	_ensure_enemy_ground_shadow_node()
	_ensure_enemy_text_scrim_node()
	_ensure_enemy_intent_presenter()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.ensure_block_preview_nodes()
	_ensure_settings_overlay()


func bind_layout_presenter() -> void:
	if _combat_layout_presenter == null:
		_combat_layout_presenter = COMBAT_LAYOUT_PRESENTER_SCRIPT.new()
	_combat_layout_presenter.bind(COMBAT_LAYOUT_PRESENTER_SCRIPT.nodes_from_root_nodes(_root_nodes, {
		"enemy_stage_backdrop": _enemy_stage_backdrop,
		"enemy_ground_shadow": _enemy_ground_shadow,
		"enemy_text_scrim": _enemy_text_scrim,
		"player_loadout_hud": _player_loadout_hud,
		"outcome_overlay": _outcome_overlay,
	}))


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
	_layout_tutorial_end_overlay()
	return layout_result


func apply_loadout_rail_layout() -> void:
	if _combat_layout_presenter != null:
		_combat_layout_presenter.apply_loadout_rail_layout()
		return
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.apply_loadout_rail_layout()


func render_player_loadout(payload: Dictionary, deferred_layout: bool = true) -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.render_player_loadout(payload)
	if deferred_layout:
		call_deferred("apply_loadout_rail_layout")


func handle_player_hud_global_click(global_position: Vector2) -> bool:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return false
	return bool(_player_hud_presenter.handle_global_click(global_position))


func hide_player_hud_slot_popover() -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.hide_slot_popover()


func lookup_player_hud_content_definition(item_id: String) -> Dictionary:
	_ensure_player_hud_presenter()
	if _player_hud_presenter == null:
		return {}
	return _player_hud_presenter.lookup_content_definition(item_id)


func clear_hovered_combat_mastery() -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.clear_hovered_mastery()


func set_hovered_combat_mastery(orb_id: int) -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.set_hovered_mastery(orb_id)


func clear_combat_mastery_feedback() -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.clear_mastery_feedback()


func set_combat_mastery_feedback(orb_id: int, total: int) -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.set_mastery_feedback(orb_id, total)


func pulse_combat_modifier_sources(sources: Array) -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.pulse_modifier_sources(sources)


func clear_combat_mastery_hover_ui() -> void:
	_ensure_player_hud_presenter()
	if _player_hud_presenter != null:
		_player_hud_presenter.clear_mastery_hover_ui()


func apply_visual_chrome(style_config: Dictionary) -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_visual_chrome(
		COMBAT_CHROME_STYLER_SCRIPT.nodes_from_root_nodes(_root_nodes, {
			"enemy_stage_backdrop": _enemy_stage_backdrop,
			"enemy_ground_shadow": _enemy_ground_shadow,
			"enemy_text_scrim": _enemy_text_scrim,
			"debug_console": _debug_console,
			"player_loadout_hud": _player_loadout_hud,
			"player_hud_nodes": _combat_player_hud_nodes(),
			"visual_registry": _visuals,
		}),
		style_config
	)
	_ensure_character_visuals_presenter()
	if _character_visuals_presenter != null:
		_character_visuals_presenter.ensure_placeholders()
	_apply_zone_guides()


func set_zone_guides_enabled(enabled: bool) -> void:
	_zone_guides_enabled = enabled
	_apply_zone_guides()


func set_vfx_layer_visible(visible: bool) -> void:
	_ensure_surface_presenter()
	_surface_presenter.set_vfx_layer_visible(visible)


func apply_hud_snapshot(hud_snapshot: Dictionary, callbacks: Dictionary = {}) -> void:
	_ensure_hud_snapshot_presenter()
	if _hud_snapshot_presenter != null:
		_hud_snapshot_presenter.apply_top_hud(hud_snapshot.get("top_hud", {}))
	_sync_enemy_stage(hud_snapshot.get("enemy_stage", {}))
	if _hud_snapshot_presenter != null:
		_hud_snapshot_presenter.apply_primary_intent_badge(hud_snapshot.get("primary_intent_badge", {}))
		_hud_snapshot_presenter.apply_tempo_row(hud_snapshot.get("tempo_row", {}))
		_hud_snapshot_presenter.apply_player_strip(hud_snapshot.get("player_strip", {}), callbacks)
		_hud_snapshot_presenter.apply_debug_overlay(hud_snapshot.get("debug_overlay", {}))


func refresh_character_portraits(enemy_id: String) -> void:
	_ensure_character_visuals_presenter()
	if _character_visuals_presenter != null:
		_current_enemy_visual_id = _character_visuals_presenter.refresh_character_portraits(enemy_id)
		_sync_enemy_stage_presenter_nodes()


func sync_timer_display(seconds_left: float, state: String) -> void:
	_ensure_surface_presenter()
	_surface_presenter.sync_timer_display(seconds_left, state)


func start_enemy_intent_hover_emphasis(kind: String) -> void:
	_ensure_enemy_intent_presenter()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.start_hover_emphasis(kind)


func set_tutorial_enemy_intent_focus(kind: String) -> void:
	_ensure_enemy_intent_presenter()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.set_tutorial_focus(kind)


func clear_tutorial_enemy_intent_focus() -> void:
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.clear_tutorial_focus()


func show_tutorial_end_modal(step := "end") -> void:
	_ensure_tutorial_end_overlay_presenter()
	if _tutorial_end_overlay_presenter != null:
		_tutorial_end_overlay_presenter.show(step, _tutorial_end_layout_config())


func hide_tutorial_end_modal() -> void:
	if _tutorial_end_overlay_presenter != null:
		_tutorial_end_overlay_presenter.hide()


func is_tutorial_end_modal_visible() -> bool:
	return _tutorial_end_overlay_presenter != null and _tutorial_end_overlay_presenter.is_visible()


func stop_enemy_intent_hover_emphasis() -> void:
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.stop_hover_emphasis()


func _ensure_tutorial_end_overlay_presenter() -> void:
	if _layout_root == null:
		return
	if _tutorial_end_overlay_presenter == null:
		_tutorial_end_overlay_presenter = COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT.new()
	_tutorial_end_overlay_presenter.bind(
		_layout_root,
		{
			"equipment_icons": _equipment_icons,
			"elemental_mastery_panel": _elemental_mastery_panel,
		},
		{
			COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT.CALLBACK_CONTINUE: Callable(self, "_emit_tutorial_end_continue_pressed"),
			COMBAT_TUTORIAL_END_OVERLAY_PRESENTER_SCRIPT.CALLBACK_MAIN_MENU: Callable(self, "_emit_tutorial_end_main_menu_pressed"),
		}
	)
	_tutorial_end_overlay_presenter.ensure_overlay()


func _layout_tutorial_end_overlay() -> void:
	_ensure_tutorial_end_overlay_presenter()
	if _tutorial_end_overlay_presenter != null:
		_tutorial_end_overlay_presenter.layout(_tutorial_end_layout_config())


func _tutorial_end_layout_config() -> Dictionary:
	return {"board_panel_rect": _layout_board_panel_rect}


func _emit_tutorial_end_continue_pressed() -> void:
	tutorial_end_continue_pressed.emit()


func _emit_tutorial_end_main_menu_pressed() -> void:
	tutorial_end_main_menu_pressed.emit()


func _sync_enemy_stage(snapshot: Dictionary) -> void:
	if _intent_label != null:
		_intent_label.text = ""
		_intent_label.visible = false
	var preview := Dictionary(snapshot.get("enemy_intent_preview", {}))
	_ensure_enemy_intent_presenter()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.sync_intent_bubbles(preview)
	_ensure_enemy_stage_presenter()
	if _enemy_stage_presenter != null:
		var result: Dictionary = _enemy_stage_presenter.apply_snapshot(snapshot, _current_enemy_visual_id, _layout_enemy_panel_rect)
		_current_enemy_visual_id = String(result.get("enemy_id", _current_enemy_visual_id))
		_sync_enemy_stage_presenter_nodes()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.sync_block_intent_preview(preview)


func _ensure_enemy_intent_presenter() -> void:
	if _enemy_intent_presenter == null:
		_enemy_intent_presenter = COMBAT_ENEMY_INTENT_PRESENTER_SCRIPT.new()
	_enemy_intent_presenter.bind(
		_root_nodes,
		{
			COMBAT_ENEMY_INTENT_PRESENTER_SCRIPT.CALLBACK_INTENT_HOVERED: Callable(self, "_emit_enemy_intent_bubble_hovered"),
			COMBAT_ENEMY_INTENT_PRESENTER_SCRIPT.CALLBACK_BLOCK_HOVERED: Callable(self, "_emit_enemy_block_preview_hovered"),
			COMBAT_ENEMY_INTENT_PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: Callable(self, "_on_intent_damage_preview_hover_ended"),
		}
	)


func _emit_enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	enemy_intent_bubble_hovered.emit(kind, entry)


func _on_intent_damage_preview_hover_ended() -> void:
	intent_hover_ended.emit()


func _ensure_settings_overlay() -> void:
	if _layout_root == null:
		return
	if _settings_overlay_presenter == null:
		_settings_overlay_presenter = COMBAT_SETTINGS_OVERLAY_PRESENTER_SCRIPT.new()
	_settings_overlay_presenter.bind(
		_layout_root,
		{
			"continue": Callable(self, "_emit_settings_continue_pressed"),
			"new_run": Callable(self, "_emit_settings_new_run_pressed"),
			"main_menu": Callable(self, "_emit_settings_main_menu_pressed"),
			"speed_selected": Callable(self, "_emit_settings_speed_selected"),
		},
		{"design_size": DESIGN_SIZE}
	)
	_settings_overlay_presenter.ensure_overlay()


func _emit_settings_continue_pressed() -> void:
	settings_continue_pressed.emit()


func _emit_settings_new_run_pressed() -> void:
	settings_new_run_pressed.emit()


func _emit_settings_main_menu_pressed() -> void:
	settings_main_menu_pressed.emit()


func _emit_settings_speed_selected(speed: String) -> void:
	settings_speed_selected.emit(speed)


func _layout_enemy_block_intent_preview() -> void:
	_ensure_enemy_intent_presenter()
	if _enemy_intent_presenter != null:
		_enemy_intent_presenter.layout_block_intent_preview()


func _emit_enemy_block_preview_hovered(preview: Dictionary) -> void:
	enemy_block_preview_hovered.emit(preview)


func _ensure_enemy_stage_backdrop_node() -> void:
	_ensure_enemy_stage_presenter()
	if _enemy_stage_presenter != null:
		_enemy_stage_presenter.ensure_backdrop()
		_sync_enemy_stage_presenter_nodes()


func _ensure_enemy_ground_shadow_node() -> void:
	_ensure_enemy_stage_presenter()
	if _enemy_stage_presenter != null:
		_enemy_stage_presenter.ensure_ground_shadow()
		_sync_enemy_stage_presenter_nodes()


func _apply_enemy_visual_profile(enemy_id: String) -> void:
	_ensure_enemy_stage_presenter()
	if _enemy_stage_presenter != null:
		_enemy_stage_presenter.apply_visual_profile(enemy_id, _layout_enemy_panel_rect)
		_sync_enemy_stage_presenter_nodes()


func _ensure_enemy_text_scrim_node() -> void:
	_ensure_enemy_stage_presenter()
	if _enemy_stage_presenter != null:
		_enemy_stage_presenter.ensure_text_scrim()
		_sync_enemy_stage_presenter_nodes()


func _ensure_enemy_stage_presenter() -> void:
	if _enemy_stage == null:
		return
	if _enemy_stage_presenter == null:
		_enemy_stage_presenter = COMBAT_ENEMY_STAGE_PRESENTER_SCRIPT.new()
	_enemy_stage_presenter.bind(_enemy_stage, _enemy_portrait, _visuals)
	_enemy_stage_presenter.bind_snapshot_nodes({
		"enemy_hp_bar": _enemy_hp_bar,
		"enemy_name_label": _enemy_name_label,
		"enemy_label": _enemy_label,
		"enemy_hp_text_label": _enemy_hp_text_label,
	})


func _sync_enemy_stage_presenter_nodes() -> void:
	if _enemy_stage_presenter == null:
		return
	_enemy_stage_backdrop = _enemy_stage_presenter.backdrop()
	_enemy_ground_shadow = _enemy_stage_presenter.ground_shadow()
	_enemy_text_scrim = _enemy_stage_presenter.text_scrim()


func _apply_zone_guides() -> void:
	_set_zone_guide(_top_bar, "TopBar")
	_set_zone_guide(_enemy_panel, "EnemyPanel")
	_set_zone_guide(_combat_strip, "CombatStrip")
	_set_zone_guide(_board_panel, "BoardPanel")
	_set_zone_guide(_player_panel, "PlayerPanel")


func _set_zone_guide(zone: Control, label_text: String) -> void:
	COMBAT_CHROME_STYLER_SCRIPT.apply_zone_guide(zone, label_text, _zone_guides_enabled)


func _ensure_surface_presenter() -> void:
	if _surface_presenter == null:
		_surface_presenter = COMBAT_SURFACE_PRESENTER_SCRIPT.new()
	_sync_surface_presenter()


func _sync_surface_presenter() -> void:
	if _surface_presenter == null:
		return
	_surface_presenter.bind(_root_nodes, {"debug_console": _debug_console})


func _combat_player_hud_nodes(popover_parent: Control = null, popover_z_index: int = 210) -> Dictionary:
	return COMBAT_PLAYER_HUD_PRESENTER_SCRIPT.hud_nodes_from_root_nodes(_root_nodes, popover_parent, popover_z_index)


func _ensure_player_hud_presenter() -> void:
	if _player_hud_presenter == null:
		_player_hud_presenter = COMBAT_PLAYER_HUD_PRESENTER_SCRIPT.new()
	_player_hud_presenter.bind(_player_loadout_hud, _root_nodes)


func _ensure_hud_snapshot_presenter() -> void:
	if _hud_snapshot_presenter == null:
		_hud_snapshot_presenter = COMBAT_HUD_SNAPSHOT_PRESENTER_SCRIPT.new()
	_hud_snapshot_presenter.bind(_root_nodes)


func _ensure_character_visuals_presenter() -> void:
	_ensure_enemy_stage_presenter()
	if _character_visuals_presenter == null:
		_character_visuals_presenter = COMBAT_CHARACTER_VISUALS_PRESENTER_SCRIPT.new()
	_character_visuals_presenter.bind(_root_nodes, _visuals, _enemy_stage_presenter, _layout_enemy_panel_rect)
