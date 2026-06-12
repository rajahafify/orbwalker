extends RefCounted
class_name CombatLayoutPresenter

const GEOMETRY := preload("res://scripts/combat/combat_layout_geometry.gd")

const LAYOUT_NODE_BINDINGS := {
	"layout_root": "_layout_root",
	"top_bar": "_top_bar",
	"back_button": "_back_button",
	"debug_toggle_button": "_debug_toggle_button",
	"settings_button": "_settings_button",
	"title_label": "_title_label",
	"hint_label": "_hint_label",
	"enemy_panel": "_enemy_panel",
	"enemy_panel_root": "_enemy_panel_root",
	"intent_row": "_intent_row",
	"enemy_stage": "_enemy_stage",
	"enemy_hp_row": "_enemy_hp_row",
	"intent_badge": "_intent_badge",
	"primary_intent_column": "_primary_intent_text_column",
	"primary_intent_title_label": "_primary_intent_title_label",
	"primary_intent_amount_label": "_primary_intent_amount_label",
	"primary_intent_detail_label": "_primary_intent_detail_label",
	"enemy_portrait": "_enemy_portrait",
	"enemy_hp_bar": "_enemy_hp_bar",
	"enemy_label": "_enemy_label",
	"enemy_name_label": "_enemy_name_label",
	"enemy_hp_text_label": "_enemy_hp_text_label",
	"enemy_step_label": "_enemy_step_label",
	"combat_strip": "_combat_strip",
	"timer_track": "_timer_track",
	"timer_icon": "_timer_icon",
	"timer_center_marker": "_timer_center_marker",
	"board_panel": "_board_panel",
	"board": "_board",
	"board_view_control": "_board_view_control",
	"board_shadow": "_board_shadow",
	"divider_enemy_timer": "_divider_enemy_timer",
	"divider_timer_board": "_divider_timer_board",
	"divider_board_player": "_divider_board_player",
	"corner_top_left": "_corner_top_left",
	"corner_top_right": "_corner_top_right",
	"corner_bottom_left": "_corner_bottom_left",
	"corner_bottom_right": "_corner_bottom_right",
	"equipment_icons": "_equipment_icons",
	"consumable_icons": "_consumable_icons",
	"stat_chip_row": "_stat_chip_row",
	"combat_meta_row": "_combat_meta_row",
	"turn_summary_label": "_turn_summary_label",
	"mastery_root": "_mastery_root",
	"hero_level_badge": "_hero_level_badge",
	"player_armor_bar": "_player_armor_bar",
	"player_armor_label": "_player_armor_label",
	"mastery_strip": "_mastery_strip",
	"player_portrait": "_player_portrait",
	"relic_row": "_relic_row",
	"debug_overlay": "_debug_overlay",
}

var _nodes = {}
var _layout_top_bar_rect = GEOMETRY.TOP_BAR_RECT
var _layout_enemy_panel_rect = GEOMETRY.ENEMY_PANEL_RECT
var _layout_combat_strip_rect = GEOMETRY.COMBAT_STRIP_RECT
var _layout_board_panel_rect = GEOMETRY.BOARD_PANEL_RECT
var _layout_player_hud_section_rect = GEOMETRY.PLAYER_HUD_SECTION_BASE_RECT


static func nodes_from_root_nodes(root_nodes: Dictionary, extras: Dictionary = {}) -> Dictionary:
	var nodes := {}
	for layout_key in LAYOUT_NODE_BINDINGS.keys():
		nodes[layout_key] = root_nodes.get(String(LAYOUT_NODE_BINDINGS[layout_key]), null)
	var top_bar := nodes.get("top_bar") as Control
	nodes["top_bar_row"] = top_bar.get_node_or_null("TopBarRow") if top_bar != null else null
	for key in extras.keys():
		nodes[key] = extras[key]
	return nodes


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
	var design_aspect = GEOMETRY.DESIGN_SIZE.x / GEOMETRY.DESIGN_SIZE.y
	var fits_tall_portrait = aspect <= design_aspect
	var scale_factor: float
	if fits_tall_portrait:
		scale_factor = viewport_size.x / GEOMETRY.DESIGN_SIZE.x
		layout_root.size = Vector2(GEOMETRY.DESIGN_SIZE.x, viewport_size.y / maxf(0.001, scale_factor))
		layout_root.position = Vector2(0.0, 0.0)
	else:
		scale_factor = minf(viewport_size.x / GEOMETRY.DESIGN_SIZE.x, viewport_size.y / GEOMETRY.DESIGN_SIZE.y)
		var scaled_size = GEOMETRY.DESIGN_SIZE * scale_factor
		layout_root.position = (viewport_size - scaled_size) * 0.5
		layout_root.size = GEOMETRY.DESIGN_SIZE
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
	return GEOMETRY.build_layout_probe(viewport_size)


func apply_loadout_rail_layout() -> void:
	var player_loadout_hud = _node("player_loadout_hud")
	var equipment_icons := _control("equipment_icons")
	var consumable_icons := _control("consumable_icons")
	if player_loadout_hud == null or equipment_icons == null or consumable_icons == null:
		return
	player_loadout_hud.apply_loadout_rail_layout(equipment_icons, GEOMETRY.COMPACT_EQUIPMENT_RAIL_RECT, consumable_icons, GEOMETRY.COMPACT_CONSUMABLE_RAIL_RECT)


func _reset_runtime_layout_rects() -> void:
	_layout_top_bar_rect = GEOMETRY.TOP_BAR_RECT
	_layout_enemy_panel_rect = GEOMETRY.ENEMY_PANEL_RECT
	_layout_combat_strip_rect = GEOMETRY.COMBAT_STRIP_RECT
	_layout_board_panel_rect = GEOMETRY.BOARD_PANEL_RECT
	_layout_player_hud_section_rect = GEOMETRY.PLAYER_HUD_SECTION_BASE_RECT


func _apply_player_hud_override() -> void:
	var player_loadout_hud = _node("player_loadout_hud")
	if player_loadout_hud == null:
		return
	var layout_override := GEOMETRY.player_hud_layout_override_for_section(_layout_player_hud_section_rect)
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
	_apply_design_rect(_control("intent_row"), GEOMETRY.ENEMY_INTENT_RECT)
	_apply_design_rect(_control("enemy_stage"), GEOMETRY.ENEMY_STAGE_RECT)
	_apply_design_rect(_control("enemy_hp_row"), GEOMETRY.ENEMY_HP_ROW_RECT)
	var enemy_stage_backdrop := _control("enemy_stage_backdrop")
	if enemy_stage_backdrop != null:
		enemy_stage_backdrop.position = GEOMETRY.ENEMY_STAGE_RECT.position
		enemy_stage_backdrop.size = GEOMETRY.ENEMY_STAGE_RECT.size
		enemy_stage_backdrop.z_index = 0
	var enemy_text_scrim := _control("enemy_text_scrim")
	if enemy_text_scrim != null:
		enemy_text_scrim.position = Vector2(18.0, GEOMETRY.ENEMY_HP_ROW_RECT.position.y + 2.0)
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
		enemy_name_label.position = Vector2(GEOMETRY.ENEMY_HP_ROW_RECT.position.x + 18.0, GEOMETRY.ENEMY_HP_ROW_RECT.position.y + 4.0)
		enemy_name_label.size = Vector2(548.0, 42.0)
		enemy_name_label.z_index = 9
	var enemy_portrait := _control("enemy_portrait")
	if enemy_portrait != null:
		enemy_portrait.position = GEOMETRY.ENEMY_FIGURE_TARGET_RECT.position
		enemy_portrait.size = GEOMETRY.ENEMY_FIGURE_TARGET_RECT.size
		enemy_portrait.z_index = 1
	var enemy_hp_bar := _control("enemy_hp_bar")
	if enemy_hp_bar != null:
		enemy_hp_bar.size = GEOMETRY.ENEMY_HP_BAR_SIZE
		enemy_hp_bar.position = Vector2(18.0, 54.0)
	var enemy_label := _control("enemy_label")
	if enemy_label != null:
		enemy_label.position = Vector2(0.0, 0.0)
		enemy_label.size = Vector2(1.0, 1.0)
		enemy_label.visible = false
	var enemy_hp_text_label := _control("enemy_hp_text_label")
	if enemy_hp_text_label != null:
		enemy_hp_text_label.position = Vector2(18.0, 54.0)
		enemy_hp_text_label.size = GEOMETRY.ENEMY_HP_BAR_SIZE
		enemy_hp_text_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		enemy_hp_text_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


func _apply_combat_strip_layout() -> void:
	var timer_track := _control("timer_track")
	if timer_track != null:
		timer_track.position = Vector2(
			(_layout_combat_strip_rect.size.x - GEOMETRY.TIMER_TRACK_SIZE.x) * 0.5, (_layout_combat_strip_rect.size.y - GEOMETRY.TIMER_TRACK_SIZE.y) * 0.5
		)
		timer_track.size = GEOMETRY.TIMER_TRACK_SIZE
	var timer_icon := _control("timer_icon")
	if timer_icon != null:
		timer_icon.custom_minimum_size = GEOMETRY.TIMER_ICON_SIZE
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
		var track_size := GEOMETRY.TIMER_TRACK_SIZE
		if timer_track != null and timer_track.size.x > 0.0 and timer_track.size.y > 0.0:
			track_size = timer_track.size
		timer_center_marker.size = GEOMETRY.TIMER_CENTER_MARKER_SIZE
		timer_center_marker.position = Vector2(
			(track_size.x - GEOMETRY.TIMER_CENTER_MARKER_SIZE.x) * 0.5, (track_size.y - GEOMETRY.TIMER_CENTER_MARKER_SIZE.y) * 0.5
		)


func _apply_board_panel_layout() -> void:
	var board_panel := _control("board_panel")
	var board := _control("board")
	var board_view_control := _control("board_view_control")
	var board_shadow := _control("board_shadow")
	if board_panel == null or board == null or board_view_control == null or board_shadow == null:
		return
	board_panel.clip_contents = true
	var board_size := GEOMETRY.board_size_for_rect(_layout_board_panel_rect)
	board.set_anchors_preset(Control.LayoutPreset.PRESET_TOP_LEFT as Control.LayoutPreset)
	board.position = Vector2((_layout_board_panel_rect.size.x - board_size.x) * 0.5, GEOMETRY.BOARD_TOP)
	board.size = board_size
	board_view_control.custom_minimum_size = board_size
	var shadow_position = board.position + GEOMETRY.BOARD_SHADOW_OFFSET - GEOMETRY.BOARD_SHADOW_EXPAND * 0.5
	var shadow_size = board_size + GEOMETRY.BOARD_SHADOW_EXPAND
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
	_place_corner(
		_control("corner_bottom_left"),
		Vector2(
			_layout_player_hud_section_rect.position.x - 10.0,
			_layout_player_hud_section_rect.position.y + _layout_player_hud_section_rect.size.y - GEOMETRY.CORNER_ORNAMENT_SIZE.y + 8.0
		),
		false,
		true
	)
	_place_corner(
		_control("corner_bottom_right"),
		Vector2(
			_layout_player_hud_section_rect.position.x + _layout_player_hud_section_rect.size.x - GEOMETRY.CORNER_ORNAMENT_SIZE.x + 10.0,
			_layout_player_hud_section_rect.position.y + _layout_player_hud_section_rect.size.y - GEOMETRY.CORNER_ORNAMENT_SIZE.y + 8.0
		),
		true,
		true
	)


func _place_divider(node: Control, y: float) -> void:
	if node == null:
		return
	node.size = GEOMETRY.DIVIDER_SIZE
	node.position = Vector2((GEOMETRY.DESIGN_SIZE.x - GEOMETRY.DIVIDER_SIZE.x) * 0.5, y)


func _place_corner(node: Control, position: Vector2, flip_h: bool, flip_v: bool) -> void:
	if node == null:
		return
	node.size = GEOMETRY.CORNER_ORNAMENT_SIZE
	node.position = position
	node.scale = Vector2(-1.0 if flip_h else 1.0, -1.0 if flip_v else 1.0)
	if flip_h:
		node.position.x += GEOMETRY.CORNER_ORNAMENT_SIZE.x
	if flip_v:
		node.position.y += GEOMETRY.CORNER_ORNAMENT_SIZE.y


func _hide_corner(node: Control) -> void:
	if node == null:
		return
	node.visible = false
	node.size = Vector2.ZERO
	node.position = Vector2(-9999.0, -9999.0)


func _update_runtime_layout_rects(layout_root_size: Vector2) -> void:
	_reset_runtime_layout_rects()
	var snapshot := GEOMETRY.compute_layout_rects_from_root_size(layout_root_size)
	_layout_top_bar_rect = snapshot["top_bar_rect"]
	_layout_enemy_panel_rect = snapshot["enemy_panel_rect"]
	_layout_combat_strip_rect = snapshot["combat_strip_rect"]
	_layout_board_panel_rect = snapshot["board_panel_rect"]
	_layout_player_hud_section_rect = snapshot["player_hud_section_rect"]


func _apply_player_panel_layout() -> void:
	_apply_design_rect(_control("stat_chip_row"), GEOMETRY.PLAYER_STAT_CHIP_RECT)
	_apply_design_rect(_control("combat_meta_row"), GEOMETRY.PLAYER_META_RECT)
	_apply_design_rect(_control("turn_summary_label"), GEOMETRY.PLAYER_SUMMARY_RECT)
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
