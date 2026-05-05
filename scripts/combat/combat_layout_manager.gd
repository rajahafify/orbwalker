extends RefCounted

const DESIGN_SIZE = Vector2(1080, 1920)
const TOP_BAR_RECT = Rect2(Vector2(16, 8), Vector2(1048, 62))
const ENEMY_PANEL_RECT = Rect2(Vector2(16, 74), Vector2(1048, 336))
const COMBAT_STRIP_RECT = Rect2(Vector2(16, 414), Vector2(1048, 44))
const BOARD_PANEL_RECT = Rect2(Vector2(16, 466), Vector2(1048, 946))
const ENEMY_INTENT_RECT = Rect2(Vector2(742, 10), Vector2(288, 82))
const ENEMY_STAGE_RECT = Rect2(Vector2(0, 52), Vector2(1048, 232))
const ENEMY_HP_ROW_RECT = Rect2(Vector2(0, 286), Vector2(1048, 46))
const ENEMY_PORTRAIT_SIZE = Vector2(420, 232)
const ENEMY_HP_BAR_SIZE = Vector2(760, 24)
const BOARD_SURFACE_SIZE = Vector2(480, 576)
const BOARD_SURFACE_TOP = 4.0
const BOARD_SURFACE_SIDE_PADDING = 4.0
const BOARD_SURFACE_BOTTOM_PADDING = 4.0
const BOARD_SHADOW_OFFSET = Vector2(0, 0)
const BOARD_SHADOW_EXPAND = Vector2(36, 18)
const PLAYER_STAT_CHIP_RECT = Rect2(Vector2(222, 110), Vector2(552, 42))
const PLAYER_META_RECT = Rect2(Vector2(230, 190), Vector2(740, 32))
const PLAYER_SUMMARY_RECT = Rect2(Vector2(230, 224), Vector2(740, 28))
const PLAYER_PORTRAIT_SIZE = Vector2(188, 194)
const TIMER_TRACK_SIZE = Vector2(860, 34)
const TIMER_ICON_SIZE = Vector2(34, 34)
const EQUIPMENT_RAIL_RECT = Rect2(Vector2(16, 16), Vector2(472, 88))
const CONSUMABLE_RAIL_RECT = Rect2(Vector2(512, 16), Vector2(280, 88))
const PLAYER_HUD_SECTION_BASE_RECT = Rect2(Vector2(0, 1420), Vector2(1080, 500))
const PLAYER_HUD_MASTERY_PANEL_RECT = Rect2(Vector2(16, 0), Vector2(1048, 82))
const PLAYER_HUD_MASTERY_TITLE_RECT = Rect2(Vector2(0, 0), Vector2(1048, 20))
const PLAYER_HUD_MASTERY_CARDS_RECT = Rect2(Vector2(0, 18), Vector2(1048, 60))
const PLAYER_HUD_FOOTER_PANEL_RECT = Rect2(Vector2(0, 92), Vector2(1080, 408))

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


static func build_layout_probe(viewport_size: Vector2) -> Dictionary:
	if viewport_size.y <= 0.0:
		return {"applied": false}
	var snapshot := _compute_layout_rects(viewport_size)
	var section_rect: Rect2 = snapshot["player_hud_section_rect"]
	var mastery_panel_local: Rect2 = snapshot["player_hud_mastery_panel_rect"]
	var footer_panel_local: Rect2 = snapshot["player_hud_footer_panel_rect"]
	var mastery_panel_global := _offset_rect(mastery_panel_local, section_rect.position)
	var footer_panel_global := _offset_rect(footer_panel_local, section_rect.position)
	var primary_zone_rects := {
		"top_bar": snapshot["top_bar_rect"],
		"enemy_panel": snapshot["enemy_panel_rect"],
		"combat_strip": snapshot["combat_strip_rect"],
		"board_panel": snapshot["board_panel_rect"],
		"player_hud_section": section_rect,
	}
	var player_hud_internal_zone_rects := {
		"player_hud_mastery_panel": mastery_panel_global,
		"player_hud_footer_panel": footer_panel_global,
	}
	var primary_overlaps := _collect_zone_overlaps(primary_zone_rects)
	var player_hud_internal_overlaps := _collect_zone_overlaps(player_hud_internal_zone_rects)
	var actionable_overlaps: Array = []
	actionable_overlaps.append_array(primary_overlaps)
	actionable_overlaps.append_array(player_hud_internal_overlaps)
	return {
		"applied": true,
		"viewport_size": viewport_size,
		"layout_root_size": snapshot["layout_root_size"],
		"scale_factor": snapshot["scale_factor"],
		"zone_rects": {
			"primary": primary_zone_rects,
			"player_hud_internals": player_hud_internal_zone_rects,
		},
		"overlaps_primary": primary_overlaps,
		"overlaps_player_hud_internals": player_hud_internal_overlaps,
		"overlaps": actionable_overlaps,
		"overlap_count": actionable_overlaps.size(),
		"board_surface_size": _board_surface_size_for_rect(snapshot["board_panel_rect"]),
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
	var layout_override := _player_hud_layout_override_for_section(_layout_player_hud_section_rect)
	player_loadout_hud.set_player_hud_layout_override(layout_override)
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
		intent_badge.custom_minimum_size = Vector2(86, 86)
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
		enemy_label.position = Vector2(0.0, 18.0)
		enemy_label.size = Vector2(ENEMY_HP_ROW_RECT.size.x, 26.0)


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
	var timer_label := _control("timer_label")
	if timer_label != null:
		timer_label.custom_minimum_size = Vector2(176, 0.0)
	var timer_state_label := _control("timer_state_label")
	if timer_state_label != null:
		timer_state_label.custom_minimum_size = Vector2(132, 0.0)


func _apply_board_panel_layout() -> void:
	var board_panel := _control("board_panel")
	var board_surface := _control("board_surface")
	var board_view_control := _control("board_view_control")
	var board_shadow := _control("board_shadow")
	if board_panel == null or board_surface == null or board_view_control == null or board_shadow == null:
		return
	board_panel.clip_contents = true
	var board_surface_size := _board_surface_size_for_rect(_layout_board_panel_rect)
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
	var board_gap = 8.0
	var player_section_base_size = player_hud_section_rect.size
	var max_board_width = BOARD_PANEL_RECT.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0)
	var board_panel_max_height = (max_board_width * (BOARD_SURFACE_SIZE.y / BOARD_SURFACE_SIZE.x)) + BOARD_SURFACE_TOP + BOARD_SURFACE_BOTTOM_PADDING
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


static func _board_surface_size_for_rect(board_panel_rect: Rect2) -> Vector2:
	var board_aspect = BOARD_SURFACE_SIZE.x / BOARD_SURFACE_SIZE.y
	var max_board_height = maxf(64.0, board_panel_rect.size.y - BOARD_SURFACE_TOP - BOARD_SURFACE_BOTTOM_PADDING)
	var max_board_width = maxf(64.0, board_panel_rect.size.x - (BOARD_SURFACE_SIDE_PADDING * 2.0))
	var board_height = minf(max_board_height, max_board_width / maxf(0.001, board_aspect))
	var board_width = board_height * board_aspect
	return Vector2(board_width, board_height)


static func _offset_rect(rect: Rect2, offset: Vector2) -> Rect2:
	return Rect2(rect.position + offset, rect.size)


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
