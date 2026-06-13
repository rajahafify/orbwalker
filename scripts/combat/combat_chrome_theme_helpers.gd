extends RefCounted
class_name CombatChromeThemeHelpers

const ZONE_GUIDE_LABEL_FONT_SIZE := 20


static func apply_board_focus_theme(
	board_shadow: Variant, outcome_summary_panel: Variant, outcome_title_label: Variant, outcome_body_label: Variant, next_button: Variant
) -> void:
	if board_shadow != null:
		var shadow_style := StyleBoxFlat.new()
		shadow_style.bg_color = Color(0.0, 0.0, 0.0, 0.34)
		shadow_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
		shadow_style.set_corner_radius_all(12)
		board_shadow.add_theme_stylebox_override("panel", shadow_style)

	if outcome_summary_panel != null:
		var summary_style := StyleBoxFlat.new()
		summary_style.bg_color = Color(0.03, 0.06, 0.10, 0.97)
		summary_style.border_color = Color(0.26, 0.34, 0.44, 0.96)
		summary_style.set_border_width_all(2)
		summary_style.set_corner_radius_all(12)
		summary_style.content_margin_left = 40.0
		summary_style.content_margin_right = 40.0
		summary_style.content_margin_top = 34.0
		summary_style.content_margin_bottom = 34.0
		outcome_summary_panel.add_theme_stylebox_override("panel", summary_style)

	if outcome_title_label != null:
		outcome_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		outcome_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		outcome_title_label.add_theme_font_size_override("font_size", 58)
		outcome_title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
		outcome_title_label.add_theme_constant_override("outline_size", 3)
		outcome_title_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.92))

	if outcome_body_label != null:
		outcome_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		outcome_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		outcome_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		outcome_body_label.clip_text = true
		outcome_body_label.custom_minimum_size = Vector2.ZERO
		outcome_body_label.add_theme_font_size_override("font_size", 30)
		outcome_body_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))

	if next_button != null:
		next_button.add_theme_font_size_override("font_size", 30)


static func apply_debug_overlay_theme(
	status_label: Variant,
	enemy_debug_label: Variant,
	combat_log_text: Variant,
	debug_console: Variant,
	debug_text_font_size: int,
	debug_input_font_size: int,
	debug_input_height: float
) -> void:
	if status_label != null:
		status_label.add_theme_font_size_override("font_size", debug_text_font_size)
	if enemy_debug_label != null:
		enemy_debug_label.add_theme_font_size_override("font_size", debug_text_font_size)
	if combat_log_text != null:
		combat_log_text.add_theme_font_size_override("normal_font_size", debug_text_font_size)
		combat_log_text.add_theme_font_size_override("bold_font_size", debug_text_font_size)
		combat_log_text.add_theme_font_size_override("italics_font_size", debug_text_font_size)
		combat_log_text.add_theme_font_size_override("bold_italics_font_size", debug_text_font_size)
		combat_log_text.add_theme_font_size_override("mono_font_size", debug_text_font_size)
	if debug_console != null:
		debug_console.apply_theme(debug_input_font_size, debug_input_height)


static func apply_stat_chip_theme(stat_labels: Array) -> void:
	for stat_label in stat_labels:
		if not (stat_label is Label):
			continue
		var chip_style := StyleBoxFlat.new()
		chip_style.bg_color = Color(0.04, 0.07, 0.10, 0.92)
		chip_style.border_color = Color(0.20, 0.27, 0.35, 0.95)
		chip_style.set_border_width_all(1)
		chip_style.set_corner_radius_all(4)
		chip_style.content_margin_left = 8.0
		chip_style.content_margin_right = 8.0
		chip_style.content_margin_top = 4.0
		chip_style.content_margin_bottom = 4.0
		(stat_label as Label).add_theme_stylebox_override("normal", chip_style)
		(stat_label as Label).add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
		(stat_label as Label).add_theme_constant_override("shadow_offset_x", 1)
		(stat_label as Label).add_theme_constant_override("shadow_offset_y", 2)


static func stylebox_from_texture(texture: Variant, left: int, right: int, top: int, bottom: int) -> Variant:
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


static func apply_progressbar_style(bar: Variant, frame_texture: Variant, fill_texture: Variant) -> void:
	if not (bar is ProgressBar):
		return
	if frame_texture != null:
		(bar as ProgressBar).add_theme_stylebox_override("background", stylebox_from_texture(frame_texture, 12, 12, 7, 7))
	if fill_texture != null:
		(bar as ProgressBar).add_theme_stylebox_override("fill", stylebox_from_texture(fill_texture, 12, 12, 7, 7))


static func apply_progressbar_flat_style(bar: Variant, fill_color: Color) -> void:
	if not (bar is ProgressBar):
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.015, 0.025, 0.035, 0.98)
	bg.set_corner_radius_all(7)
	bg.set_border_width_all(2)
	bg.border_color = Color(0.54, 0.42, 0.20, 0.82)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(7)
	(bar as ProgressBar).add_theme_stylebox_override("background", bg)
	(bar as ProgressBar).add_theme_stylebox_override("fill", fill)


static func apply_button_theme(buttons: Array) -> void:
	for button in buttons:
		if not (button is Button):
			continue
		(button as Button).add_theme_color_override("font_color", Color(0.84, 0.89, 0.94, 1.0))
		(button as Button).add_theme_font_size_override("font_size", 24)
		(button as Button).custom_minimum_size = Vector2(102.0, 58.0)
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.04, 0.07, 0.10, 0.92)
		style_normal.border_color = Color(0.58, 0.45, 0.21, 0.86)
		style_normal.set_border_width_all(2)
		style_normal.set_corner_radius_all(10)
		style_normal.content_margin_left = 8.0
		style_normal.content_margin_right = 8.0
		style_normal.content_margin_top = 4.0
		style_normal.content_margin_bottom = 4.0
		(button as Button).add_theme_stylebox_override("normal", style_normal)
		var style_hover: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
		style_hover.bg_color = Color(0.09, 0.14, 0.19, 0.96)
		(button as Button).add_theme_stylebox_override("hover", style_hover)
		(button as Button).add_theme_stylebox_override("pressed", style_hover)


static func apply_round_header_button_theme(buttons: Array) -> void:
	for button in buttons:
		if not (button is Button):
			continue
		(button as Button).custom_minimum_size = Vector2(64.0, 64.0)
		(button as Button).add_theme_font_size_override("font_size", 32)
		(button as Button).add_theme_color_override("font_color", Color(1.0, 0.91, 0.74, 1.0))
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.08, 0.09, 0.10, 0.96)
		style_normal.border_color = Color(0.85, 0.61, 0.20, 0.86)
		style_normal.set_border_width_all(2)
		style_normal.set_corner_radius_all(32)
		style_normal.content_margin_left = 4.0
		style_normal.content_margin_right = 4.0
		style_normal.content_margin_top = 4.0
		style_normal.content_margin_bottom = 4.0
		(button as Button).add_theme_stylebox_override("normal", style_normal)
		var style_hover := style_normal.duplicate() as StyleBoxFlat
		style_hover.bg_color = Color(0.16, 0.14, 0.10, 0.98)
		(button as Button).add_theme_stylebox_override("hover", style_hover)
		(button as Button).add_theme_stylebox_override("pressed", style_hover)


static func apply_top_header_label_theme(title_label: Variant, gold_label: Variant) -> void:
	if title_label is Label:
		var title := title_label as Label
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.32, 1.0))
		title.add_theme_constant_override("outline_size", 2)
		title.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.82))
	if gold_label is Label:
		var gold := gold_label as Label
		gold.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		gold.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		gold.add_theme_color_override("font_color", Color(1.0, 0.86, 0.57, 1.0))
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.22, 0.13, 0.04, 0.96)
		style.border_color = Color(0.85, 0.61, 0.20, 0.96)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		style.content_margin_left = 8.0
		style.content_margin_right = 8.0
		style.content_margin_top = 4.0
		style.content_margin_bottom = 4.0
		gold.add_theme_stylebox_override("normal", style)


static func apply_timer_track_theme(timer_track: Variant, visuals: Variant = null) -> void:
	if not (timer_track is Control):
		return
	var timer_style_flat := StyleBoxFlat.new()
	timer_style_flat.bg_color = Color(0.01, 0.02, 0.04, 0.96)
	timer_style_flat.border_color = Color(0.62, 0.50, 0.24, 0.86)
	timer_style_flat.set_border_width_all(1)
	timer_style_flat.set_corner_radius_all(6)
	var timer_style: StyleBox = timer_style_flat
	var frame: Variant = (timer_track as Control).get_node_or_null("TimerTrackFrame")
	if frame is Panel:
		(frame as Panel).add_theme_stylebox_override("panel", timer_style)
	var timer_fill: Variant = (timer_track as Control).get_node_or_null("TimerFill")
	if timer_fill is ColorRect:
		(timer_fill as ColorRect).color = Color(0.72, 0.56, 0.26, 0.60)
		(timer_fill as ColorRect).visible = false
	var center_marker: Variant = (timer_track as Control).get_node_or_null("TimerCenterMarker")
	if center_marker is TextureRect:
		var marker_texture := resolve_visual_texture(visuals, "combat_timer_center_marker_texture")
		if marker_texture != null:
			(center_marker as TextureRect).texture = marker_texture
		(center_marker as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		(center_marker as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		(center_marker as TextureRect).modulate = Color(0.98, 0.90, 0.62, 0.96)


static func transparent_panel_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	style.set_border_width_all(0)
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	return style


static func apply_timer_label_readability(label: Variant) -> void:
	if not (label is Label):
		return
	(label as Label).add_theme_color_override("font_shadow_color", Color(0.01, 0.02, 0.03, 0.95))
	(label as Label).add_theme_constant_override("shadow_offset_x", 1)
	(label as Label).add_theme_constant_override("shadow_offset_y", 2)
	(label as Label).add_theme_constant_override("outline_size", 3)
	(label as Label).add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.80))


static func set_label_outline(label: Variant, outline_size: int, outline_color: Color) -> void:
	if not (label is Label):
		return
	(label as Label).add_theme_constant_override("outline_size", outline_size)
	(label as Label).add_theme_color_override("font_outline_color", outline_color)


static func apply_loadout_group_theme(
	loadout_frame: Variant,
	mastery_strip: Variant,
	hero_card: Variant,
	vitals_frame: Variant,
	hero_level_badge: Variant,
	armor_badge: Variant,
	visuals: Variant = null
) -> void:
	var inner_panel_style := StyleBoxFlat.new()
	inner_panel_style.bg_color = Color(0.04, 0.07, 0.11, 0.98)
	inner_panel_style.border_color = Color(0.40, 0.32, 0.18, 0.90)
	inner_panel_style.set_border_width_all(2)
	inner_panel_style.set_corner_radius_all(8)
	inner_panel_style.content_margin_left = 10.0
	inner_panel_style.content_margin_right = 10.0
	inner_panel_style.content_margin_top = 8.0
	inner_panel_style.content_margin_bottom = 8.0
	for panel in [loadout_frame, mastery_strip, hero_card]:
		if panel is Panel:
			(panel as Panel).add_theme_stylebox_override("panel", inner_panel_style)

	if vitals_frame is Panel:
		var vitals_frame_style := StyleBoxFlat.new()
		vitals_frame_style.bg_color = Color(0.03, 0.08, 0.13, 0.98)
		vitals_frame_style.border_color = Color(0.48, 0.37, 0.18, 0.92)
		vitals_frame_style.set_border_width_all(2)
		vitals_frame_style.set_corner_radius_all(8)
		(vitals_frame as Panel).add_theme_stylebox_override("panel", vitals_frame_style)

	if hero_level_badge is PanelContainer:
		(hero_level_badge as PanelContainer).visible = false

	if armor_badge is Control:
		var armor_badge_style := StyleBoxFlat.new()
		armor_badge_style.bg_color = Color(0.08, 0.19, 0.31, 0.96)
		armor_badge_style.border_color = Color(0.46, 0.75, 0.98, 0.94)
		armor_badge_style.set_border_width_all(2)
		armor_badge_style.set_corner_radius_all(8)
		armor_badge_style.content_margin_left = 8.0
		armor_badge_style.content_margin_right = 8.0
		armor_badge_style.content_margin_top = 2.0
		armor_badge_style.content_margin_bottom = 2.0
		var block_badge_texture := resolve_visual_texture(visuals, "combat_block_badge_texture")
		if block_badge_texture != null:
			(armor_badge as Control).add_theme_stylebox_override("panel", panel_texture_stylebox(block_badge_texture, 12, 12, 8, 8, 8.0))
		else:
			(armor_badge as Control).add_theme_stylebox_override("panel", armor_badge_style)


static func apply_decorative_overlays(nodes: Dictionary, visuals: Variant) -> void:
	var divider_texture := resolve_visual_texture(visuals, "combat_divider_texture")
	for key in ["divider_enemy_timer", "divider_timer_board", "divider_board_player"]:
		var divider_node: Variant = nodes.get(key, null)
		if divider_node is TextureRect:
			if divider_texture != null:
				(divider_node as TextureRect).texture = divider_texture
			(divider_node as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
			(divider_node as TextureRect).stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
			if key == "divider_enemy_timer" or key == "divider_board_player":
				(divider_node as TextureRect).modulate = Color(1.0, 1.0, 1.0, 0.0)
			else:
				(divider_node as TextureRect).modulate = Color(1.0, 1.0, 1.0, 0.72)

	var corner_texture := resolve_visual_texture(visuals, "combat_corner_ornament_texture")
	for key in ["corner_top_left", "corner_top_right", "corner_bottom_left", "corner_bottom_right"]:
		var corner: Variant = nodes.get(key, null)
		if corner is TextureRect:
			if corner_texture != null:
				(corner as TextureRect).texture = corner_texture
			(corner as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
			(corner as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
			(corner as TextureRect).modulate = Color(1.0, 1.0, 1.0, 0.94)


static func apply_zone_guide(zone: Variant, label_text: String, enabled: bool) -> void:
	if zone == null:
		return
	if enabled:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.03, 0.06, 0.10, 0.94)
		style.border_color = Color(0.90, 0.72, 0.28, 0.95)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		if zone is PanelContainer:
			(zone as PanelContainer).add_theme_stylebox_override("panel", style)
		else:
			var frame: Variant = zone.get_node_or_null("ZoneGuideFrame")
			if frame == null:
				frame = Panel.new()
				frame.name = "ZoneGuideFrame"
				frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
				frame.anchors_preset = Control.PRESET_FULL_RECT as Control.LayoutPreset
				zone.add_child(frame)
			(frame as Panel).add_theme_stylebox_override("panel", style)
		var guide: Variant = zone.get_node_or_null("ZoneGuideLabel")
		if guide == null:
			guide = Label.new()
			guide.name = "ZoneGuideLabel"
			guide.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
			guide.position = Vector2(6, 4)
			zone.add_child(guide)
		(guide as Label).text = label_text
		(guide as Label).add_theme_color_override("font_color", Color(0.95, 0.80, 0.30, 1.0))
		(guide as Label).add_theme_font_size_override("font_size", ZONE_GUIDE_LABEL_FONT_SIZE)
	else:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.025, 0.045, 0.07, 0.94)
		style.border_color = Color(0.18, 0.24, 0.31, 0.90)
		style.set_border_width_all(1)
		style.set_corner_radius_all(4)
		if zone is PanelContainer:
			(zone as PanelContainer).add_theme_stylebox_override("panel", style)
		else:
			var frame: Variant = zone.get_node_or_null("ZoneGuideFrame")
			if frame != null:
				frame.queue_free()
		var guide: Variant = zone.get_node_or_null("ZoneGuideLabel")
		if guide != null:
			guide.queue_free()


static func apply_panel_stylebox(panel: Variant, stylebox: StyleBox) -> void:
	if panel is Control:
		(panel as Control).add_theme_stylebox_override("panel", stylebox)


static func panel_texture_stylebox(texture: Texture2D, left: int, right: int, top: int, bottom: int, content_margin: float = 8.0) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = left
	style.texture_margin_right = right
	style.texture_margin_top = top
	style.texture_margin_bottom = bottom
	style.content_margin_left = content_margin
	style.content_margin_right = content_margin
	style.content_margin_top = content_margin
	style.content_margin_bottom = content_margin
	return style


static func resolve_visual_texture(visuals: Variant, method_name: String, args: Array = []) -> Texture2D:
	if visuals == null:
		return null
	if not visuals.has_method(method_name):
		return null
	var value: Variant = visuals.callv(method_name, args)
	return value as Texture2D


static func set_label_font_size(label: Variant, font_size: int) -> void:
	if label is Label:
		(label as Label).add_theme_font_size_override("font_size", font_size)


static func set_label_color(label: Variant, color: Color) -> void:
	if label is Label:
		(label as Label).add_theme_color_override("font_color", color)
