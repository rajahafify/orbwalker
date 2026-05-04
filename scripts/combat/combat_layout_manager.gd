extends RefCounted

const DESIGN_SIZE = Vector2(1080, 1920)
const TOP_BAR_RECT = Rect2(Vector2(16, 8), Vector2(1048, 58))
const ENEMY_PANEL_RECT = Rect2(Vector2(16, 70), Vector2(1048, 340))
const COMBAT_STRIP_RECT = Rect2(Vector2(16, 424), Vector2(1048, 56))
const BOARD_PANEL_RECT = Rect2(Vector2(16, 492), Vector2(1048, 584))
const ENEMY_INTENT_RECT = Rect2(Vector2(296, 16), Vector2(456, 60))
const ENEMY_STAGE_RECT = Rect2(Vector2(0, 70), Vector2(1048, 216))
const ENEMY_HP_ROW_RECT = Rect2(Vector2(0, 286), Vector2(1048, 52))
const ENEMY_PORTRAIT_SIZE = Vector2(280, 216)
const ENEMY_HP_BAR_SIZE = Vector2(620, 22)
const BOARD_SURFACE_SIZE = Vector2(480, 576)
const BOARD_SURFACE_TOP = 4.0
const BOARD_SURFACE_SIDE_PADDING = 4.0
const BOARD_SURFACE_BOTTOM_PADDING = 4.0
const BOARD_SHADOW_OFFSET = Vector2(10, 0)
const BOARD_SHADOW_EXPAND = Vector2(24, 8)
const PLAYER_STAT_CHIP_RECT = Rect2(Vector2(222, 110), Vector2(552, 42))
const PLAYER_META_RECT = Rect2(Vector2(230, 190), Vector2(740, 32))
const PLAYER_SUMMARY_RECT = Rect2(Vector2(230, 224), Vector2(740, 28))
const PLAYER_PORTRAIT_SIZE = Vector2(188, 194)
const TIMER_TRACK_SIZE = Vector2(720, 36)
const TIMER_ICON_SIZE = Vector2(34, 34)
const EQUIPMENT_RAIL_RECT = Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT = Rect2(Vector2(518, 136), Vector2(280, 88))
const PLAYER_HUD_SECTION_BASE_RECT = Rect2(Vector2(0, 1092), Vector2(1080, 828))

var _nodes = {}
var _layout_top_bar_rect = TOP_BAR_RECT
var _layout_enemy_panel_rect = ENEMY_PANEL_RECT
var _layout_combat_strip_rect = COMBAT_STRIP_RECT
var _layout_board_panel_rect = BOARD_PANEL_RECT
var _layout_player_hud_section_rect = PLAYER_HUD_SECTION_BASE_RECT


func bind(nodes) -> void:
	_nodes = nodes
	_reset_runtime_layout_rects()


func apply_layout(viewport_size):
	if viewport_size.y <= 0.0:
		return {"applied": false}
	var layout_root := _control("layout_root")
	if layout_root == null:
		return {"applied": false}

	var aspect = viewport_size.x / viewport_size.y
	var is_compact = aspect < 0.85
	var is_low_vertical = viewport_size.y < 760.0
	var design_aspect = DESIGN_SIZE.x / DESIGN_SIZE.y
	var fits_tall_portrait = aspect <= design_aspect
	var scale_factor: float
	if fits_tall_portrait:
		scale_factor = viewport_size.x / DESIGN_SIZE.x
		layout_root.size = Vector2(DESIGN_SIZE.x, viewport_size.y / maxf(0.001, scale_factor))
		layout_root.position = Vector2(0.0, 0.0)
	else:
		scale_factor = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
		var scaled_size = DESIGN_SIZE * scale_factor
		layout_root.position = (viewport_size - scaled_size) * 0.5
		layout_root.size = DESIGN_SIZE
	layout_root.scale = Vector2(scale_factor, scale_factor)

	_update_runtime_layout_rects(layout_root.size)

	_apply_design_rect(_control("top_bar"), _layout_top_bar_rect)
	_apply_design_rect(_control("enemy_panel"), _layout_enemy_panel_rect)
	_apply_design_rect(_control("combat_strip"), _layout_combat_strip_rect)
	_apply_design_rect(_control("board_panel"), _layout_board_panel_rect)
	_apply_player_hud_override()
	_apply_enemy_panel_layout()
	_apply_combat_strip_layout()
	_apply_board_panel_layout()
	_apply_player_panel_layout()

	if is_low_vertical:
		var mastery_strip := _canvas_item("mastery_strip")
		if mastery_strip != null:
			mastery_strip.visible = false
		var relic_row := _canvas_item("relic_row")
		if relic_row != null:
			relic_row.visible = false

	var debug_overlay := _control("debug_overlay")
	if debug_overlay != null:
		debug_overlay.anchor_left = 0.08 if is_compact else 0.58
		debug_overlay.anchor_top = 0.05
		debug_overlay.anchor_right = 0.985
		debug_overlay.anchor_bottom = 0.97

	return {
		"applied": true,
		"is_low_vertical_layout": is_low_vertical,
		"layout_top_bar_rect": _layout_top_bar_rect,
		"layout_enemy_panel_rect": _layout_enemy_panel_rect,
		"layout_combat_strip_rect": _layout_combat_strip_rect,
		"layout_board_panel_rect": _layout_board_panel_rect,
		"layout_player_hud_section_rect": _layout_player_hud_section_rect,
	}


func apply_loadout_rail_layout() -> void:
	var player_loadout_hud = _node("player_loadout_hud")
	var equipment_icons := _control("equipment_icons")
	var consumable_icons := _control("consumable_icons")
	if player_loadout_hud == null or equipment_icons == null or consumable_icons == null:
		return
	player_loadout_hud.apply_loadout_rail_layout(
		equipment_icons,
		EQUIPMENT_RAIL_RECT,
		consumable_icons,
		CONSUMABLE_RAIL_RECT
	)


func _reset_runtime_layout_rects() -> void:
	_layout_top_bar_rect = TOP_BAR_RECT
	_layout_enemy_panel_rect = ENEMY_PANEL_RECT
	_layout_combat_strip_rect = COMBAT_STRIP_RECT
	_layout_board_panel_rect = BOARD_PANEL_RECT
	_layout_player_hud_section_rect = PLAYER_HUD_SECTION_BASE_RECT


func _apply_player_hud_override() -> void:
	var player_loadout_hud = _node("player_loadout_hud")
	if player_loadout_hud == null:
		return
	player_loadout_hud.set_player_hud_layout_override({
		"section": _layout_player_hud_section_rect,
	})
	player_loadout_hud.update_player_hud_layout()


func _apply_design_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _apply_enemy_panel_layout() -> void:
	var enemy_panel_root := _control("enemy_panel_root")
	if enemy_panel_root != null:
		enemy_panel_root.position = Vector2.ZERO
		enemy_panel_root.size = _layout_enemy_panel_rect.size
	_apply_design_rect(_control("intent_row"), ENEMY_INTENT_RECT)
	_apply_design_rect(_control("enemy_stage"), ENEMY_STAGE_RECT)
	_apply_design_rect(_control("enemy_hp_row"), ENEMY_HP_ROW_RECT)
	var intent_badge := _control("intent_badge")
	if intent_badge != null:
		intent_badge.custom_minimum_size = Vector2(56, 56)
	var enemy_portrait := _control("enemy_portrait")
	if enemy_portrait != null:
		enemy_portrait.size = ENEMY_PORTRAIT_SIZE
		enemy_portrait.position = Vector2(
			(ENEMY_STAGE_RECT.size.x - ENEMY_PORTRAIT_SIZE.x) * 0.5,
			ENEMY_STAGE_RECT.size.y - ENEMY_PORTRAIT_SIZE.y
		)
	var enemy_hp_bar := _control("enemy_hp_bar")
	if enemy_hp_bar != null:
		enemy_hp_bar.size = ENEMY_HP_BAR_SIZE
		enemy_hp_bar.position = Vector2((ENEMY_HP_ROW_RECT.size.x - ENEMY_HP_BAR_SIZE.x) * 0.5, 0.0)
	var enemy_label := _control("enemy_label")
	if enemy_label != null:
		enemy_label.position = Vector2(0.0, 22.0)
		enemy_label.size = Vector2(ENEMY_HP_ROW_RECT.size.x, 28.0)


func _apply_combat_strip_layout() -> void:
	var timer_track := _control("timer_track")
	if timer_track != null:
		timer_track.position = Vector2(
			(_layout_combat_strip_rect.size.x - TIMER_TRACK_SIZE.x) * 0.5,
			(_layout_combat_strip_rect.size.y - TIMER_TRACK_SIZE.y) * 0.5
		)
		timer_track.size = TIMER_TRACK_SIZE
	var timer_icon := _control("timer_icon")
	if timer_icon != null:
		timer_icon.custom_minimum_size = TIMER_ICON_SIZE


func _apply_board_panel_layout() -> void:
	var board_panel := _control("board_panel")
	var board_surface := _control("board_surface")
	var board_view_control := _control("board_view_control")
	var board_shadow := _control("board_shadow")
	if board_panel == null or board_surface == null or board_view_control == null or board_shadow == null:
		return
	board_panel.clip_contents = true
	var board_aspect = BOARD_SURFACE_SIZE.x / BOARD_SURFACE_SIZE.y
	var max_board_height = maxf(64.0, _layout_board_panel_rect.size.y - BOARD_SURFACE_TOP - BOARD_SURFACE_BOTTOM_PADDING)
	var max_board_width = maxf(64.0, _layout_board_panel_rect.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0))
	var board_height = minf(max_board_height, max_board_width / maxf(0.001, board_aspect))
	var board_width = board_height * board_aspect
	var board_surface_size = Vector2(board_width, board_height)
	board_surface.set_anchors_preset(Control.PRESET_TOP_LEFT)
	board_surface.position = Vector2((_layout_board_panel_rect.size.x - board_surface_size.x) * 0.5, BOARD_SURFACE_TOP)
	board_surface.size = board_surface_size
	board_view_control.custom_minimum_size = board_surface_size
	var shadow_position = board_surface.position + BOARD_SHADOW_OFFSET - BOARD_SHADOW_EXPAND * 0.5
	var shadow_size = board_surface_size + BOARD_SHADOW_EXPAND
	shadow_size.x = minf(shadow_size.x, _layout_board_panel_rect.size.x)
	shadow_size.y = minf(shadow_size.y, _layout_board_panel_rect.size.y)
	shadow_position.x = clampf(shadow_position.x, 0.0, maxf(0.0, _layout_board_panel_rect.size.x - shadow_size.x))
	shadow_position.y = clampf(shadow_position.y, 0.0, maxf(0.0, _layout_board_panel_rect.size.y - shadow_size.y))
	board_shadow.position = shadow_position
	board_shadow.size = shadow_size
	var outcome_overlay = _node("outcome_overlay")
	if outcome_overlay != null:
		outcome_overlay.sync_layout(_layout_board_panel_rect)


func _update_runtime_layout_rects(layout_root_size: Vector2) -> void:
	_reset_runtime_layout_rects()
	var extra_height = maxf(0.0, layout_root_size.y - DESIGN_SIZE.y)
	if extra_height <= 0.0:
		return
	var board_top = BOARD_PANEL_RECT.position.y
	var board_gap = 16.0
	var player_section_base_size = _layout_player_hud_section_rect.size
	var max_board_width = BOARD_PANEL_RECT.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0)
	var board_panel_max_height = (max_board_width * (BOARD_SURFACE_SIZE.y / BOARD_SURFACE_SIZE.x)) + BOARD_SURFACE_TOP + BOARD_SURFACE_BOTTOM_PADDING
	var board_growth_capacity = maxf(0.0, board_panel_max_height - BOARD_PANEL_RECT.size.y)
	var board_growth = minf(extra_height, board_growth_capacity)
	var player_growth = extra_height - board_growth
	_layout_board_panel_rect = Rect2(BOARD_PANEL_RECT.position, Vector2(BOARD_PANEL_RECT.size.x, BOARD_PANEL_RECT.size.y + board_growth))
	var section_position = Vector2(0.0, board_top + _layout_board_panel_rect.size.y + board_gap)
	_layout_player_hud_section_rect = Rect2(
		section_position,
		Vector2(player_section_base_size.x, player_section_base_size.y + player_growth)
	)


func _apply_player_panel_layout() -> void:
	_apply_design_rect(_control("stat_chip_row"), PLAYER_STAT_CHIP_RECT)
	_apply_design_rect(_control("combat_meta_row"), PLAYER_META_RECT)
	_apply_design_rect(_control("turn_summary_label"), PLAYER_SUMMARY_RECT)
	var mastery_root := _control("mastery_root")
	if mastery_root != null:
		mastery_root.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	var hero_level_badge := _canvas_item("hero_level_badge")
	if hero_level_badge != null:
		hero_level_badge.visible = false
	var player_armor_bar := _canvas_item("player_armor_bar")
	if player_armor_bar != null:
		player_armor_bar.visible = false
	var player_armor_label := _canvas_item("player_armor_label")
	if player_armor_label != null:
		player_armor_label.visible = false
	var stat_chip_row := _canvas_item("stat_chip_row")
	if stat_chip_row != null:
		stat_chip_row.visible = false
	var combat_meta_row := _canvas_item("combat_meta_row")
	if combat_meta_row != null:
		combat_meta_row.visible = false
	var turn_summary_label := _canvas_item("turn_summary_label")
	if turn_summary_label != null:
		turn_summary_label.visible = false
	var mastery_strip := _canvas_item("mastery_strip")
	if mastery_strip != null:
		mastery_strip.visible = false
	apply_loadout_rail_layout()
	var player_portrait := _control("player_portrait")
	if player_portrait != null:
		player_portrait.custom_minimum_size = PLAYER_PORTRAIT_SIZE


func _node(key: String) -> Variant:
	var value: Variant = _nodes.get(key, null)
	if value == null:
		return null
	if not is_instance_valid(value):
		return null
	return value


func _control(key: String) -> Control:
	var value: Variant = _nodes.get(key, null)
	if value == null or not is_instance_valid(value):
		return null
	if value is Control:
		return value as Control
	return null


func _canvas_item(key: String) -> CanvasItem:
	var value: Variant = _nodes.get(key, null)
	if value == null or not is_instance_valid(value):
		return null
	if value is CanvasItem:
		return value as CanvasItem
	return null
