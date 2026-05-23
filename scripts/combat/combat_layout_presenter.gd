extends RefCounted
class_name CombatLayoutPresenter

const TOP_HEADER_SCRIPT := preload("res://scripts/ui/top_header.gd")

const DESIGN_SIZE = Vector2(1080, 1920)
const TOP_BAR_RECT = Rect2(Vector2(16, 8), Vector2(1048, 116))
const ENEMY_PANEL_RECT = Rect2(Vector2(16, 132), Vector2(1048, 432))
const COMBAT_STRIP_RECT = Rect2(Vector2(16, 576), Vector2(1048, 64))
const BOARD_PANEL_RECT = Rect2(Vector2(16, 660), Vector2(1048, 756))
const ENEMY_INTENT_RECT = Rect2(Vector2(724, 332), Vector2(300, 76))
const ENEMY_STAGE_RECT = Rect2(Vector2(0, 0), Vector2(1048, 432))
const ENEMY_HP_ROW_RECT = Rect2(Vector2(24, 292), Vector2(682, 124))
const ENEMY_FIGURE_TARGET_RECT = Rect2(Vector2(0, 0), Vector2(1048, 432))
const ENEMY_HP_BAR_SIZE = Vector2(612, 52)
const BOARD_SIZE = Vector2(480, 576)
const BOARD_TOP = 4.0
const BOARD_SIDE_PADDING = 4.0
const BOARD_BOTTOM_PADDING = 4.0
const BOARD_SHADOW_OFFSET = Vector2(0, 0)
const BOARD_SHADOW_EXPAND = Vector2(36, 18)
const PLAYER_STAT_CHIP_RECT = Rect2(Vector2(222, 110), Vector2(552, 42))
const PLAYER_META_RECT = Rect2(Vector2(230, 190), Vector2(740, 32))
const PLAYER_SUMMARY_RECT = Rect2(Vector2(230, 224), Vector2(740, 28))
const PLAYER_PORTRAIT_SIZE = Vector2(188, 194)
const TIMER_TRACK_SIZE = Vector2(980, 32)
const TIMER_ICON_SIZE = Vector2.ZERO
const TIMER_CENTER_MARKER_SIZE = Vector2(18, 32)
const EQUIPMENT_RAIL_RECT = Rect2(Vector2(16, 16), Vector2(472, 88))
const CONSUMABLE_RAIL_RECT = Rect2(Vector2(696, 16), Vector2(280, 88))
const PLAYER_HUD_SECTION_BASE_RECT = Rect2(Vector2(0, 1428), Vector2(1080, 492))
const PLAYER_HUD_MASTERY_PANEL_RECT = Rect2(Vector2(16, 0), Vector2(1048, 160))
const PLAYER_HUD_MASTERY_TITLE_RECT = Rect2(Vector2(0, 6), Vector2(1048, 50))
const PLAYER_HUD_MASTERY_CARDS_RECT = Rect2(Vector2(0, 58), Vector2(1048, 102))
const PLAYER_HUD_FOOTER_PANEL_RECT = Rect2(Vector2(0, 168), Vector2(1080, 324))
const COMPACT_VITALS_PANEL_RECT = Rect2(Vector2(228, 12), Vector2(836, 152))
const COMPACT_PLAYER_HP_BAR_RECT = Rect2(Vector2(14, 16), Vector2(806, 58))
const COMPACT_PLAYER_LOADOUT_RECT = Rect2(Vector2(16, 168), Vector2(1048, 156))
const COMPACT_EQUIPMENT_RAIL_RECT = Rect2(Vector2(20, 34), Vector2(540, 106))
const COMPACT_CONSUMABLE_RAIL_RECT = Rect2(Vector2(714, 34), Vector2(314, 106))
const COMPACT_VITALS_RELIC_ICONS_RECT = Rect2(Vector2(126, 82), Vector2(402, 64))
const DIVIDER_SIZE = Vector2(700, 20)
const CORNER_ORNAMENT_SIZE = Vector2(56, 56)
const MIN_READABLE_ENEMY_INTENT = Vector2(280, 56)
const MIN_READABLE_TIMER = Vector2(860, 32)
const MIN_READABLE_BOARD = Vector2(470, 560)
const MIN_READABLE_MASTERY = Vector2(1000, 96)
const MIN_READABLE_HP = Vector2(760, 56)
const MIN_READABLE_LOADOUT = Vector2(860, 120)

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
	_apply_top_bar_layout()
	_apply_enemy_panel_layout()
	_apply_combat_strip_layout()
	_apply_board_panel_layout()
	_apply_player_panel_layout()
	_apply_decorative_layout()

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


static func build_layout_probe(viewport_size: Vector2) -> Dictionary:
	if viewport_size.y <= 0.0:
		return {"applied": false}
	var snapshot := _compute_layout_rects(viewport_size)
	var section_rect: Rect2 = snapshot["player_hud_section_rect"]
	var enemy_panel_rect: Rect2 = snapshot["enemy_panel_rect"]
	var combat_strip_rect: Rect2 = snapshot["combat_strip_rect"]
	var board_panel_rect: Rect2 = snapshot["board_panel_rect"]
	var mastery_panel_local: Rect2 = snapshot["player_hud_mastery_panel_rect"]
	var footer_panel_local: Rect2 = snapshot["player_hud_footer_panel_rect"]
	var mastery_panel_global := _offset_rect(mastery_panel_local, section_rect.position)
	var footer_panel_global := _offset_rect(footer_panel_local, section_rect.position)
	var top_bar_rect: Rect2 = snapshot["top_bar_rect"]
	var shared_top_controls: Dictionary = TOP_HEADER_SCRIPT.layout_snapshot_for(top_bar_rect)
	var top_segments := {
		"top_title": shared_top_controls.get("title", Rect2()),
		"top_gold": shared_top_controls.get("gold_counter", Rect2()),
		"top_help": shared_top_controls.get("help_button", Rect2()),
		"top_settings": shared_top_controls.get("settings_button", Rect2()),
	}
	var primary_zone_rects := {
		"top_bar": top_bar_rect,
		"enemy_panel": snapshot["enemy_panel_rect"],
		"combat_strip": snapshot["combat_strip_rect"],
		"board_panel": snapshot["board_panel_rect"],
		"player_hud_section": section_rect,
	}
	var enemy_intent_rect := _offset_rect(ENEMY_INTENT_RECT, enemy_panel_rect.position)
	var enemy_name_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 4.0),
		Vector2(548.0, 42.0)
	)
	var enemy_hp_text_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 54.0),
		ENEMY_HP_BAR_SIZE
	)
	var timer_track_rect := _timer_track_rect(combat_strip_rect)
	var board_rect := _board_rect(board_panel_rect)
	var enemy_hp_bar_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 54.0),
		ENEMY_HP_BAR_SIZE
	)
	var mastery_rail_rect := mastery_panel_global
	var hero_vitals_rect := _offset_rect(COMPACT_VITALS_PANEL_RECT, footer_panel_global.position)
	var equipment_rail_rect := _offset_rect(COMPACT_EQUIPMENT_RAIL_RECT, _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_panel_global.position).position)
	var consumable_rail_rect := _offset_rect(COMPACT_CONSUMABLE_RAIL_RECT, _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_panel_global.position).position)
	var relic_rail_rect := _offset_rect(COMPACT_VITALS_RELIC_ICONS_RECT, hero_vitals_rect.position)
	var outcome_overlay_rect := Rect2(board_panel_rect.position + Vector2(224.0, 164.0), Vector2(600.0, 372.0))
	var hp_bar_rect := _player_hp_zone_rect(section_rect, footer_panel_local)
	var loadout_rails_rect := _player_loadout_rails_rect(section_rect, footer_panel_local)
	var readability_zones := {
		"top_segments": top_bar_rect,
		"enemy_name": enemy_name_rect,
		"enemy_hp": enemy_hp_text_rect,
		"primary_intent_badge": enemy_intent_rect,
		"timer": timer_track_rect,
		"board": board_rect,
		"mastery_rail": mastery_rail_rect,
		"hero_vitals": hero_vitals_rect,
		"relic_rail": relic_rail_rect,
		"equipment_rail": equipment_rail_rect,
		"consumable_rail": consumable_rail_rect,
		"outcome_overlay": outcome_overlay_rect,
		"enemy_hp_bar": enemy_hp_bar_rect,
		"player_hp": hp_bar_rect,
		"loadout_rails": loadout_rails_rect,
	}
	var readability_actionable_zone_rects := {
		"top_segments": top_bar_rect,
		"enemy_name": enemy_name_rect,
		"enemy_hp": enemy_hp_text_rect,
		"primary_intent_badge": enemy_intent_rect,
		"timer": timer_track_rect,
		"board": board_rect,
		"mastery_rail": mastery_rail_rect,
		"hero_vitals": hero_vitals_rect,
		"relic_rail": relic_rail_rect,
		"equipment_rail": equipment_rail_rect,
		"consumable_rail": consumable_rail_rect,
	}
	var player_hud_internal_zone_rects := {
		"player_hud_mastery_panel": mastery_panel_global,
		"player_hud_footer_panel": footer_panel_global,
	}
	for key in top_segments.keys():
		player_hud_internal_zone_rects[key] = top_segments[key]
	var primary_overlaps := _collect_zone_overlaps(primary_zone_rects)
	var player_hud_internal_overlaps := _collect_zone_overlaps(player_hud_internal_zone_rects)
	var readability_overlaps := _collect_zone_overlaps(readability_zones)
	var readability_actionable_overlaps := _collect_zone_overlaps(readability_actionable_zone_rects)
	readability_actionable_overlaps = _filter_actionable_readability_overlaps(
		readability_actionable_overlaps,
		readability_actionable_zone_rects
	)
	var actionable_overlaps: Array = []
	actionable_overlaps.append_array(primary_overlaps)
	actionable_overlaps.append_array(player_hud_internal_overlaps)
	actionable_overlaps.append_array(readability_actionable_overlaps)
	var readability := _build_readability_report(readability_zones)
	return {
		"applied": true,
		"viewport_size": viewport_size,
		"layout_root_size": snapshot["layout_root_size"],
		"scale_factor": snapshot["scale_factor"],
		"zone_rects": {
			"primary": primary_zone_rects,
			"readability": readability_zones,
			"player_hud_internals": player_hud_internal_zone_rects,
		},
		"overlaps_primary": primary_overlaps,
		"overlaps_player_hud_internals": player_hud_internal_overlaps,
		"overlaps_readability": readability_overlaps,
		"overlaps_readability_actionable": readability_actionable_overlaps,
		"overlaps": actionable_overlaps,
		"overlap_count": actionable_overlaps.size(),
		"board_size": _board_size_for_rect(board_panel_rect),
		"readability": readability,
	}


func apply_loadout_rail_layout() -> void:
	var player_loadout_hud = _node("player_loadout_hud")
	var equipment_icons := _control("equipment_icons")
	var consumable_icons := _control("consumable_icons")
	if player_loadout_hud == null or equipment_icons == null or consumable_icons == null:
		return
	player_loadout_hud.apply_loadout_rail_layout(
		equipment_icons,
		COMPACT_EQUIPMENT_RAIL_RECT,
		consumable_icons,
		COMPACT_CONSUMABLE_RAIL_RECT
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
	var layout_override := _player_hud_layout_override_for_section(_layout_player_hud_section_rect)
	player_loadout_hud.set_player_hud_layout_override(layout_override)
	player_loadout_hud.update_player_hud_layout()


func _apply_design_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _apply_top_bar_layout() -> void:
	var top_bar := _control("top_bar")
	if top_bar != null and top_bar.has_method("apply_header_layout"):
		top_bar.call("apply_header_layout")
		return


func _apply_enemy_panel_layout() -> void:
	var enemy_panel_root := _control("enemy_panel_root")
	if enemy_panel_root != null:
		enemy_panel_root.position = Vector2.ZERO
		enemy_panel_root.size = _layout_enemy_panel_rect.size
	_apply_design_rect(_control("intent_row"), ENEMY_INTENT_RECT)
	_apply_design_rect(_control("enemy_stage"), ENEMY_STAGE_RECT)
	_apply_design_rect(_control("enemy_hp_row"), ENEMY_HP_ROW_RECT)
	var enemy_stage_backdrop := _control("enemy_stage_backdrop")
	if enemy_stage_backdrop != null:
		enemy_stage_backdrop.position = ENEMY_STAGE_RECT.position
		enemy_stage_backdrop.size = ENEMY_STAGE_RECT.size
		enemy_stage_backdrop.z_index = 0
	var enemy_text_scrim := _control("enemy_text_scrim")
	if enemy_text_scrim != null:
		enemy_text_scrim.position = Vector2(18.0, ENEMY_HP_ROW_RECT.position.y + 2.0)
		enemy_text_scrim.size = Vector2(638.0, 116.0)
		enemy_text_scrim.z_index = 3
	var enemy_panel := _control("enemy_panel")
	if enemy_panel != null:
		enemy_panel.clip_contents = true
	var enemy_stage := _control("enemy_stage")
	if enemy_stage != null:
		enemy_stage.clip_contents = true
		enemy_stage.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	var intent_row := _control("intent_row")
	if intent_row != null:
		intent_row.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		intent_row.alignment = BoxContainer.AlignmentMode.ALIGNMENT_CENTER as BoxContainer.AlignmentMode
		intent_row.add_theme_constant_override("separation", 12)
		intent_row.z_index = 9
	var intent_badge := _control("intent_badge")
	if intent_badge != null:
		intent_badge.custom_minimum_size = Vector2(112, 112)
		intent_badge.size = Vector2(112, 112)
	var primary_intent_column := _control("primary_intent_column")
	if primary_intent_column != null:
		primary_intent_column.custom_minimum_size = Vector2(156, 198)
		primary_intent_column.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_END as Control.SizeFlags
	var primary_intent_title_label := _control("primary_intent_title_label")
	if primary_intent_title_label != null:
		primary_intent_title_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	var primary_intent_amount_label := _control("primary_intent_amount_label")
	if primary_intent_amount_label != null:
		primary_intent_amount_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	var primary_intent_detail_label := _control("primary_intent_detail_label")
	if primary_intent_detail_label != null:
		primary_intent_detail_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	var enemy_hp_row := _control("enemy_hp_row")
	if enemy_hp_row != null:
		enemy_hp_row.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
		enemy_hp_row.z_index = 8
		enemy_hp_row.clip_contents = true
	var enemy_name_label := _control("enemy_name_label")
	if enemy_name_label != null:
		enemy_name_label.position = Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 4.0)
		enemy_name_label.size = Vector2(548.0, 42.0)
		enemy_name_label.z_index = 9
	var enemy_portrait := _control("enemy_portrait")
	if enemy_portrait != null:
		enemy_portrait.position = ENEMY_FIGURE_TARGET_RECT.position
		enemy_portrait.size = ENEMY_FIGURE_TARGET_RECT.size
		enemy_portrait.z_index = 1
	var enemy_hp_bar := _control("enemy_hp_bar")
	if enemy_hp_bar != null:
		enemy_hp_bar.size = ENEMY_HP_BAR_SIZE
		enemy_hp_bar.position = Vector2(18.0, 54.0)
	var enemy_label := _control("enemy_label")
	if enemy_label != null:
		enemy_label.position = Vector2(0.0, 0.0)
		enemy_label.size = Vector2(1.0, 1.0)
		enemy_label.visible = false
	var enemy_hp_text_label := _control("enemy_hp_text_label")
	if enemy_hp_text_label != null:
		enemy_hp_text_label.position = Vector2(18.0, 54.0)
		enemy_hp_text_label.size = ENEMY_HP_BAR_SIZE
		enemy_hp_text_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		enemy_hp_text_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


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
		timer_icon.visible = false
	var timer_label := _control("timer_label")
	if timer_label != null:
		timer_label.custom_minimum_size = Vector2(420, 0.0)
	var timer_state_label := _control("timer_state_label")
	if timer_state_label != null:
		timer_state_label.custom_minimum_size = Vector2.ZERO
		timer_state_label.visible = false
	var timer_center_marker := _control("timer_center_marker")
	if timer_center_marker != null:
		var track_size := TIMER_TRACK_SIZE
		if timer_track != null and timer_track.size.x > 0.0 and timer_track.size.y > 0.0:
			track_size = timer_track.size
		timer_center_marker.size = TIMER_CENTER_MARKER_SIZE
		timer_center_marker.position = Vector2(
			(track_size.x - TIMER_CENTER_MARKER_SIZE.x) * 0.5,
			(track_size.y - TIMER_CENTER_MARKER_SIZE.y) * 0.5
		)


func _apply_board_panel_layout() -> void:
	var board_panel := _control("board_panel")
	var board := _control("board")
	var board_view_control := _control("board_view_control")
	var board_shadow := _control("board_shadow")
	if board_panel == null or board == null or board_view_control == null or board_shadow == null:
		return
	board_panel.clip_contents = true
	var board_size := _board_size_for_rect(_layout_board_panel_rect)
	board.set_anchors_preset(Control.LayoutPreset.PRESET_TOP_LEFT as Control.LayoutPreset)
	board.position = Vector2((_layout_board_panel_rect.size.x - board_size.x) * 0.5, BOARD_TOP)
	board.size = board_size
	board_view_control.custom_minimum_size = board_size
	var shadow_position = board.position + BOARD_SHADOW_OFFSET - BOARD_SHADOW_EXPAND * 0.5
	var shadow_size = board_size + BOARD_SHADOW_EXPAND
	shadow_size.x = minf(shadow_size.x, _layout_board_panel_rect.size.x)
	shadow_size.y = minf(shadow_size.y, _layout_board_panel_rect.size.y)
	shadow_position.x = clampf(shadow_position.x, 0.0, maxf(0.0, _layout_board_panel_rect.size.x - shadow_size.x))
	shadow_position.y = clampf(shadow_position.y, 0.0, maxf(0.0, _layout_board_panel_rect.size.y - shadow_size.y))
	board_shadow.position = shadow_position
	board_shadow.size = shadow_size
	var outcome_overlay = _node("outcome_overlay")
	if outcome_overlay != null:
		outcome_overlay.sync_layout(_layout_board_panel_rect)


func _apply_decorative_layout() -> void:
	_place_divider(_control("divider_enemy_timer"), _layout_enemy_panel_rect.position.y + _layout_enemy_panel_rect.size.y + 2.0)
	_place_divider(_control("divider_timer_board"), _layout_combat_strip_rect.position.y + _layout_combat_strip_rect.size.y + 2.0)
	_place_divider(_control("divider_board_player"), _layout_board_panel_rect.position.y + _layout_board_panel_rect.size.y + 2.0)
	_hide_corner(_control("corner_top_left"))
	_hide_corner(_control("corner_top_right"))
	_place_corner(_control("corner_bottom_left"), Vector2(_layout_player_hud_section_rect.position.x - 10.0, _layout_player_hud_section_rect.position.y + _layout_player_hud_section_rect.size.y - CORNER_ORNAMENT_SIZE.y + 8.0), false, true)
	_place_corner(_control("corner_bottom_right"), Vector2(_layout_player_hud_section_rect.position.x + _layout_player_hud_section_rect.size.x - CORNER_ORNAMENT_SIZE.x + 10.0, _layout_player_hud_section_rect.position.y + _layout_player_hud_section_rect.size.y - CORNER_ORNAMENT_SIZE.y + 8.0), true, true)


func _place_divider(node: Control, y: float) -> void:
	if node == null:
		return
	node.size = DIVIDER_SIZE
	node.position = Vector2((DESIGN_SIZE.x - DIVIDER_SIZE.x) * 0.5, y)


func _place_corner(node: Control, position: Vector2, flip_h: bool, flip_v: bool) -> void:
	if node == null:
		return
	node.size = CORNER_ORNAMENT_SIZE
	node.position = position
	node.scale = Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0)
	if flip_h:
		node.position.x += CORNER_ORNAMENT_SIZE.x
	if flip_v:
		node.position.y += CORNER_ORNAMENT_SIZE.y


func _hide_corner(node: Control) -> void:
	if node == null:
		return
	node.visible = false
	node.size = Vector2.ZERO
	node.position = Vector2(-9999.0, -9999.0)


func _update_runtime_layout_rects(layout_root_size: Vector2) -> void:
	_reset_runtime_layout_rects()
	var snapshot := _compute_layout_rects_from_root_size(layout_root_size)
	_layout_top_bar_rect = snapshot["top_bar_rect"]
	_layout_enemy_panel_rect = snapshot["enemy_panel_rect"]
	_layout_combat_strip_rect = snapshot["combat_strip_rect"]
	_layout_board_panel_rect = snapshot["board_panel_rect"]
	_layout_player_hud_section_rect = snapshot["player_hud_section_rect"]


static func _compute_layout_rects(viewport_size: Vector2) -> Dictionary:
	var aspect = viewport_size.x / viewport_size.y
	var design_aspect = DESIGN_SIZE.x / DESIGN_SIZE.y
	var fits_tall_portrait = aspect <= design_aspect
	var scale_factor: float
	var layout_root_size: Vector2
	if fits_tall_portrait:
		scale_factor = viewport_size.x / DESIGN_SIZE.x
		layout_root_size = Vector2(DESIGN_SIZE.x, viewport_size.y / maxf(0.001, scale_factor))
	else:
		scale_factor = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
		layout_root_size = DESIGN_SIZE
	var rects := _compute_layout_rects_from_root_size(layout_root_size)
	rects["layout_root_size"] = layout_root_size
	rects["scale_factor"] = scale_factor
	return rects


static func _compute_layout_rects_from_root_size(layout_root_size: Vector2) -> Dictionary:
	var top_bar_rect := TOP_BAR_RECT
	var enemy_panel_rect := ENEMY_PANEL_RECT
	var combat_strip_rect := COMBAT_STRIP_RECT
	var board_panel_rect := BOARD_PANEL_RECT
	var player_hud_section_rect := PLAYER_HUD_SECTION_BASE_RECT
	var extra_height = maxf(0.0, layout_root_size.y - DESIGN_SIZE.y)
	if extra_height <= 0.0:
		var base_player_override := _player_hud_layout_override_for_section(player_hud_section_rect)
		return {
			"top_bar_rect": top_bar_rect,
			"enemy_panel_rect": enemy_panel_rect,
			"combat_strip_rect": combat_strip_rect,
			"board_panel_rect": board_panel_rect,
			"player_hud_section_rect": player_hud_section_rect,
			"player_hud_mastery_panel_rect": base_player_override["mastery_panel"],
			"player_hud_mastery_title_rect": base_player_override["mastery_title"],
			"player_hud_mastery_cards_rect": base_player_override["mastery_cards"],
			"player_hud_footer_panel_rect": base_player_override["footer_panel"],
		}
	var board_top = board_panel_rect.position.y
	var board_gap = 12.0
	var player_section_base_size = player_hud_section_rect.size
	var max_board_width = BOARD_PANEL_RECT.size.x - (BOARD_SIDE_PADDING * 2.0)
	var board_panel_max_height = (max_board_width * (BOARD_SIZE.y / BOARD_SIZE.x)) + BOARD_TOP + BOARD_BOTTOM_PADDING
	var board_growth_capacity = maxf(0.0, board_panel_max_height - BOARD_PANEL_RECT.size.y)
	var board_growth = minf(extra_height, board_growth_capacity)
	var player_growth = extra_height - board_growth
	board_panel_rect = Rect2(BOARD_PANEL_RECT.position, Vector2(BOARD_PANEL_RECT.size.x, BOARD_PANEL_RECT.size.y + board_growth))
	var section_position = Vector2(0.0, board_top + board_panel_rect.size.y + board_gap)
	player_hud_section_rect = Rect2(
		section_position,
		Vector2(player_section_base_size.x, player_section_base_size.y + player_growth)
	)
	var player_override := _player_hud_layout_override_for_section(player_hud_section_rect)
	return {
		"top_bar_rect": top_bar_rect,
		"enemy_panel_rect": enemy_panel_rect,
		"combat_strip_rect": combat_strip_rect,
		"board_panel_rect": board_panel_rect,
		"player_hud_section_rect": player_hud_section_rect,
		"player_hud_mastery_panel_rect": player_override["mastery_panel"],
		"player_hud_mastery_title_rect": player_override["mastery_title"],
		"player_hud_mastery_cards_rect": player_override["mastery_cards"],
		"player_hud_footer_panel_rect": player_override["footer_panel"],
	}


static func _player_hud_layout_override_for_section(section_rect: Rect2) -> Dictionary:
	var mastery_panel_rect = PLAYER_HUD_MASTERY_PANEL_RECT
	var mastery_title_rect = PLAYER_HUD_MASTERY_TITLE_RECT
	var mastery_cards_rect = PLAYER_HUD_MASTERY_CARDS_RECT
	var footer_panel_rect = PLAYER_HUD_FOOTER_PANEL_RECT
	var section_delta = maxf(0.0, section_rect.size.y - PLAYER_HUD_SECTION_BASE_RECT.size.y)
	if section_delta > 0.0:
		footer_panel_rect.size.y += section_delta
	return {
		"section": section_rect,
		"mastery_panel": mastery_panel_rect,
		"mastery_title": mastery_title_rect,
		"mastery_cards": mastery_cards_rect,
		"footer_panel": footer_panel_rect,
	}


static func _board_size_for_rect(board_panel_rect: Rect2) -> Vector2:
	var board_aspect = BOARD_SIZE.x / BOARD_SIZE.y
	var max_board_height = maxf(64.0, board_panel_rect.size.y - BOARD_TOP - BOARD_BOTTOM_PADDING)
	var max_board_width = maxf(64.0, board_panel_rect.size.x - (BOARD_SIDE_PADDING * 2.0))
	var board_height = minf(max_board_height, max_board_width / maxf(0.001, board_aspect))
	var board_width = board_height * board_aspect
	return Vector2(board_width, board_height)


static func _offset_rect(rect: Rect2, offset: Vector2) -> Rect2:
	return Rect2(rect.position + offset, rect.size)


static func _timer_track_rect(combat_strip_rect: Rect2) -> Rect2:
	return Rect2(
		Vector2(
			combat_strip_rect.position.x + (combat_strip_rect.size.x - TIMER_TRACK_SIZE.x) * 0.5,
			combat_strip_rect.position.y + (combat_strip_rect.size.y - TIMER_TRACK_SIZE.y) * 0.5
		),
		TIMER_TRACK_SIZE
	)


static func _board_rect(board_panel_rect: Rect2) -> Rect2:
	var board_size := _board_size_for_rect(board_panel_rect)
	return Rect2(
		Vector2(
			board_panel_rect.position.x + (board_panel_rect.size.x - board_size.x) * 0.5,
			board_panel_rect.position.y + BOARD_TOP
		),
		board_size
	)


static func _player_hp_zone_rect(section_rect: Rect2, footer_panel_local: Rect2) -> Rect2:
	var footer_global := _offset_rect(footer_panel_local, section_rect.position)
	var vitals_rect := _offset_rect(COMPACT_VITALS_PANEL_RECT, footer_global.position)
	return _offset_rect(COMPACT_PLAYER_HP_BAR_RECT, vitals_rect.position)


static func _player_loadout_rails_rect(section_rect: Rect2, footer_panel_local: Rect2) -> Rect2:
	var footer_global := _offset_rect(footer_panel_local, section_rect.position)
	var loadout_rect := _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_global.position)
	var equipment_rect := _offset_rect(COMPACT_EQUIPMENT_RAIL_RECT, loadout_rect.position)
	var consumable_rect := _offset_rect(COMPACT_CONSUMABLE_RAIL_RECT, loadout_rect.position)
	return equipment_rect.merge(consumable_rect)


static func _build_readability_report(zone_rects: Dictionary) -> Dictionary:
	var thresholds := {
		"primary_intent_badge": MIN_READABLE_ENEMY_INTENT,
		"timer": MIN_READABLE_TIMER,
		"board": MIN_READABLE_BOARD,
		"mastery_rail": MIN_READABLE_MASTERY,
		"player_hp": MIN_READABLE_HP,
		"equipment_rail": Vector2(500, 100),
		"consumable_rail": Vector2(308, 100),
	}
	var checks: Dictionary = {}
	var passing_count := 0
	for key in thresholds.keys():
		var zone_rect: Variant = zone_rects.get(key, Rect2())
		if not (zone_rect is Rect2):
			continue
		var min_size: Vector2 = thresholds.get(key, Vector2.ZERO)
		var rect_value: Rect2 = zone_rect
		var pass_size := rect_value.size.x >= min_size.x and rect_value.size.y >= min_size.y
		if pass_size:
			passing_count += 1
		checks[key] = {
			"rect": rect_value,
			"size": rect_value.size,
			"min_size": min_size,
			"passes_minimum": pass_size,
		}
	return {
		"checks": checks,
		"passing_count": passing_count,
		"required_count": thresholds.size(),
		"all_pass": passing_count == thresholds.size(),
	}


static func _collect_zone_overlaps(zone_rects: Dictionary) -> Array:
	var keys := zone_rects.keys()
	var overlaps: Array = []
	for i in range(keys.size()):
		var key_a: String = String(keys[i])
		var rect_a: Variant = zone_rects.get(key_a, Rect2())
		if not (rect_a is Rect2):
			continue
		for j in range(i + 1, keys.size()):
			var key_b: String = String(keys[j])
			var rect_b: Variant = zone_rects.get(key_b, Rect2())
			if not (rect_b is Rect2):
				continue
			var intersection: Rect2 = (rect_a as Rect2).intersection(rect_b as Rect2)
			if intersection.size.x > 0.0 and intersection.size.y > 0.0:
				overlaps.append({
					"a": key_a,
					"b": key_b,
					"intersection": intersection,
				})
	return overlaps


static func _filter_actionable_readability_overlaps(overlaps: Array, zone_rects: Dictionary) -> Array:
	var filtered: Array = []
	var hero_vitals_rect: Rect2 = zone_rects.get("hero_vitals", Rect2())
	var relic_rail_rect: Rect2 = zone_rects.get("relic_rail", Rect2())
	var is_embedded_relic_rail := _rect_contains_rect(hero_vitals_rect, relic_rail_rect)
	for overlap_entry in overlaps:
		var a := String(overlap_entry.get("a", ""))
		var b := String(overlap_entry.get("b", ""))
		var is_relic_inside_vitals_pair := (a == "hero_vitals" and b == "relic_rail") or (a == "relic_rail" and b == "hero_vitals")
		if is_embedded_relic_rail and is_relic_inside_vitals_pair:
			continue
		filtered.append(overlap_entry)
	return filtered


static func _rect_contains_rect(container: Rect2, candidate: Rect2) -> bool:
	if container.size.x <= 0.0 or container.size.y <= 0.0:
		return false
	if candidate.size.x <= 0.0 or candidate.size.y <= 0.0:
		return false
	var clipped := container.intersection(candidate)
	return is_equal_approx(clipped.size.x, candidate.size.x) and is_equal_approx(clipped.size.y, candidate.size.y)


func _apply_player_panel_layout() -> void:
	_apply_design_rect(_control("stat_chip_row"), PLAYER_STAT_CHIP_RECT)
	_apply_design_rect(_control("combat_meta_row"), PLAYER_META_RECT)
	_apply_design_rect(_control("turn_summary_label"), PLAYER_SUMMARY_RECT)
	var mastery_root := _control("mastery_root")
	if mastery_root != null:
		mastery_root.size_flags_horizontal = Control.SizeFlags.SIZE_SHRINK_BEGIN as Control.SizeFlags
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
