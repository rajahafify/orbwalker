extends RefCounted


static func apply_visual_chrome(nodes: Dictionary, config: Dictionary) -> void:
	var board_view: Variant = nodes.get("board_view", null)
	if board_view != null:
		# Keep chrome code-driven to avoid any baked checkerboard artifacts from generated sheets.
		board_view.cell_frame_texture = null
		board_view.cell_spacing = 4.0
		board_view.board_padding = 8.0
		board_view.orb_scale_in_cell = 0.92
		board_view.cell_background = Color(0.07, 0.09, 0.12, 0.96)
		board_view.board_background = Color(0.03, 0.04, 0.06, 0.96)

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.025, 0.045, 0.07, 0.94)
	frame_style.border_color = Color(0.18, 0.24, 0.31, 0.90)
	frame_style.set_border_width_all(1)
	frame_style.set_corner_radius_all(4)
	frame_style.content_margin_left = 8.0
	frame_style.content_margin_right = 8.0
	frame_style.content_margin_top = 6.0
	frame_style.content_margin_bottom = 6.0

	for panel in [
		nodes.get("top_bar", null),
		nodes.get("enemy_panel", null),
		nodes.get("combat_strip", null),
		nodes.get("board_frame", null),
		nodes.get("debug_overlay", null),
		nodes.get("combat_log_frame", null),
	]:
		if panel is Control:
			(panel as Control).add_theme_stylebox_override("panel", frame_style)

	apply_progressbar_flat_style(nodes.get("enemy_hp_bar", null), Color(0.70, 0.12, 0.13, 1.0))
	apply_progressbar_flat_style(nodes.get("player_hp_bar", null), Color(0.78, 0.16, 0.17, 1.0))
	apply_progressbar_flat_style(nodes.get("player_armor_bar", null), Color(0.16, 0.50, 0.86, 1.0))

	var ui_text_color := Color(0.95, 0.96, 0.98, 1.0)
	for label in [
		nodes.get("title_label", null),
		nodes.get("hint_label", null),
		nodes.get("timer_label", null),
		nodes.get("run_progress_label", null),
		nodes.get("phase_label", null),
		nodes.get("turn_summary_label", null),
		nodes.get("player_label", null),
		nodes.get("player_armor_label", null),
		nodes.get("attack_stat_label", null),
		nodes.get("armor_stat_label", null),
		nodes.get("heart_stat_label", null),
		nodes.get("gold_stat_label", null),
		nodes.get("enemy_label", null),
		nodes.get("intent_label", null),
	]:
		if label is Label:
			(label as Label).add_theme_color_override("font_color", ui_text_color)

	var font_size_title := int(config.get("font_size_title", 20))
	var font_size_value := int(config.get("font_size_value", 18))
	var font_size_meta := int(config.get("font_size_meta", 15))
	var font_size_row_label := int(config.get("font_size_row_label", 16))
	var debug_text_font_size := int(config.get("debug_text_font_size", 24))
	var debug_input_font_size := int(config.get("debug_input_font_size", 24))
	var debug_input_height := float(config.get("debug_input_height", 72.0))

	_set_label_font_size(nodes.get("title_label", null), font_size_title)
	_set_label_font_size(nodes.get("hint_label", null), font_size_value)
	_set_label_font_size(nodes.get("intent_label", null), font_size_value)
	_set_label_font_size(nodes.get("enemy_label", null), font_size_value)
	_set_label_font_size(nodes.get("timer_label", null), font_size_value)
	_set_label_font_size(nodes.get("player_label", null), 24)
	_set_label_font_size(nodes.get("player_armor_label", null), font_size_value)

	for stat_label in [
		nodes.get("attack_stat_label", null),
		nodes.get("armor_stat_label", null),
		nodes.get("heart_stat_label", null),
		nodes.get("gold_stat_label", null),
	]:
		_set_label_font_size(stat_label, font_size_value)

	_set_label_font_size(nodes.get("run_progress_label", null), font_size_meta)
	_set_label_font_size(nodes.get("phase_label", null), font_size_meta)
	_set_label_font_size(nodes.get("turn_summary_label", null), font_size_meta)

	for row_label in [
		nodes.get("equipment_row_label", null),
		nodes.get("consumable_row_label", null),
		nodes.get("relic_row_label", null),
		nodes.get("mastery_row_label", null),
	]:
		if row_label is Label:
			(row_label as Label).add_theme_color_override("font_color", Color(0.67, 0.73, 0.80, 1.0))
			(row_label as Label).add_theme_font_size_override("font_size", font_size_row_label)

	var armor_badge_label: Label = nodes.get("armor_badge_label", null) as Label
	if armor_badge_label != null:
		armor_badge_label.add_theme_font_size_override("font_size", 16)
		armor_badge_label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0, 1.0))
		armor_badge_label.add_theme_constant_override("outline_size", 2)
		armor_badge_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.94))

	_set_label_color(nodes.get("phase_label", null), Color(0.70, 0.78, 0.86, 1.0))
	_set_label_color(nodes.get("run_progress_label", null), Color(0.82, 0.90, 0.98, 1.0))
	_set_label_color(nodes.get("player_label", null), Color(1.0, 0.96, 0.92, 1.0))
	_set_label_color(nodes.get("player_armor_label", null), Color(0.82, 0.94, 1.0, 1.0))
	_set_label_color(nodes.get("timer_label", null), Color(0.85, 0.93, 1.0, 1.0))
	_set_label_color(nodes.get("timer_state_label", null), Color(0.73, 0.84, 0.92, 1.0))
	_set_label_font_size(nodes.get("timer_state_label", null), font_size_meta)

	apply_timer_label_readability(nodes.get("timer_label", null))
	apply_timer_label_readability(nodes.get("timer_state_label", null))
	apply_button_theme([
		nodes.get("back_button", null),
		nodes.get("debug_toggle_button", null),
		nodes.get("settings_button", null),
		nodes.get("next_button", null),
	])
	apply_timer_track_theme(nodes.get("timer_track", null))
	apply_loadout_group_theme(
		nodes.get("loadout_frame", null),
		nodes.get("mastery_strip", null),
		nodes.get("hero_card", null),
		nodes.get("vitals_frame", null),
		nodes.get("hero_level_badge", null),
		nodes.get("armor_badge", null)
	)

	var player_loadout_hud: Variant = nodes.get("player_loadout_hud", null)
	if player_loadout_hud != null:
		player_loadout_hud.apply_player_hud_chrome(nodes.get("player_hud_nodes", {}))

	apply_board_focus_theme(
		nodes.get("board_shadow", null),
		nodes.get("outcome_summary_panel", null),
		nodes.get("outcome_title_label", null),
		nodes.get("outcome_body_label", null),
		nodes.get("next_button", null)
	)
	apply_debug_overlay_theme(
		nodes.get("status_label", null),
		nodes.get("enemy_debug_label", null),
		nodes.get("combat_log_text", null),
		nodes.get("debug_console", null),
		debug_text_font_size,
		debug_input_font_size,
		debug_input_height
	)
	apply_stat_chip_theme([
		nodes.get("attack_stat_label", null),
		nodes.get("armor_stat_label", null),
		nodes.get("heart_stat_label", null),
		nodes.get("gold_stat_label", null),
	])


static func apply_board_focus_theme(board_shadow: Variant, outcome_summary_panel: Variant, outcome_title_label: Variant, outcome_body_label: Variant, next_button: Variant) -> void:
	if board_shadow != null:
		var shadow_style := StyleBoxFlat.new()
		shadow_style.bg_color = Color(0.0, 0.0, 0.0, 0.24)
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
		outcome_title_label.add_theme_font_size_override("font_size", 46)
		outcome_title_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
		outcome_title_label.add_theme_constant_override("outline_size", 3)
		outcome_title_label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.92))

	if outcome_body_label != null:
		outcome_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		outcome_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		outcome_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		outcome_body_label.clip_text = true
		outcome_body_label.custom_minimum_size = Vector2.ZERO
		outcome_body_label.add_theme_font_size_override("font_size", 24)
		outcome_body_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))

	if next_button != null:
		next_button.text = "Continue"
		next_button.add_theme_font_size_override("font_size", 22)


static func apply_debug_overlay_theme(status_label: Variant, enemy_debug_label: Variant, combat_log_text: Variant, debug_console: Variant, debug_text_font_size: int, debug_input_font_size: int, debug_input_height: float) -> void:
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
	bg.bg_color = Color(0.04, 0.07, 0.10, 0.95)
	bg.set_corner_radius_all(4)
	bg.set_border_width_all(1)
	bg.border_color = Color(0.18, 0.25, 0.34, 0.85)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(4)
	(bar as ProgressBar).add_theme_stylebox_override("background", bg)
	(bar as ProgressBar).add_theme_stylebox_override("fill", fill)


static func apply_button_theme(buttons: Array) -> void:
	for button in buttons:
		if not (button is Button):
			continue
		(button as Button).add_theme_color_override("font_color", Color(0.84, 0.89, 0.94, 1.0))
		(button as Button).add_theme_font_size_override("font_size", 18)
		var style_normal := StyleBoxFlat.new()
		style_normal.bg_color = Color(0.04, 0.07, 0.10, 0.84)
		style_normal.border_color = Color(0.22, 0.30, 0.39, 0.92)
		style_normal.set_border_width_all(1)
		style_normal.set_corner_radius_all(4)
		style_normal.content_margin_left = 8.0
		style_normal.content_margin_right = 8.0
		style_normal.content_margin_top = 4.0
		style_normal.content_margin_bottom = 4.0
		(button as Button).add_theme_stylebox_override("normal", style_normal)
		var style_hover: StyleBoxFlat = style_normal.duplicate() as StyleBoxFlat
		style_hover.bg_color = Color(0.08, 0.12, 0.17, 0.94)
		(button as Button).add_theme_stylebox_override("hover", style_hover)
		(button as Button).add_theme_stylebox_override("pressed", style_hover)


static func apply_timer_track_theme(timer_track: Variant) -> void:
	if not (timer_track is Control):
		return
	var timer_style := StyleBoxFlat.new()
	timer_style.bg_color = Color(0.035, 0.075, 0.11, 0.94)
	timer_style.border_color = Color(0.20, 0.30, 0.40, 0.90)
	timer_style.set_border_width_all(1)
	timer_style.set_corner_radius_all(4)
	var frame: Variant = (timer_track as Control).get_node_or_null("TimerTrackFrame")
	if frame is Panel:
		(frame as Panel).add_theme_stylebox_override("panel", timer_style)


static func apply_timer_label_readability(label: Variant) -> void:
	if not (label is Label):
		return
	(label as Label).add_theme_color_override("font_shadow_color", Color(0.01, 0.02, 0.03, 0.95))
	(label as Label).add_theme_constant_override("shadow_offset_x", 1)
	(label as Label).add_theme_constant_override("shadow_offset_y", 2)
	(label as Label).add_theme_constant_override("outline_size", 2)
	(label as Label).add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.80))


static func apply_loadout_group_theme(loadout_frame: Variant, mastery_strip: Variant, hero_card: Variant, vitals_frame: Variant, hero_level_badge: Variant, armor_badge: Variant) -> void:
	var inner_panel_style := StyleBoxFlat.new()
	inner_panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.98)
	inner_panel_style.border_color = Color(0.18, 0.24, 0.31, 0.95)
	inner_panel_style.set_border_width_all(1)
	inner_panel_style.set_corner_radius_all(4)
	inner_panel_style.content_margin_left = 8.0
	inner_panel_style.content_margin_right = 8.0
	inner_panel_style.content_margin_top = 6.0
	inner_panel_style.content_margin_bottom = 6.0
	for panel in [loadout_frame, mastery_strip, hero_card]:
		if panel is Panel:
			(panel as Panel).add_theme_stylebox_override("panel", inner_panel_style)

	if vitals_frame is Panel:
		var vitals_frame_style := StyleBoxFlat.new()
		vitals_frame_style.bg_color = Color(0.04, 0.08, 0.13, 0.98)
		vitals_frame_style.border_color = Color(0.18, 0.25, 0.34, 0.96)
		vitals_frame_style.set_border_width_all(1)
		vitals_frame_style.set_corner_radius_all(4)
		(vitals_frame as Panel).add_theme_stylebox_override("panel", vitals_frame_style)

	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.08, 0.09, 0.12, 0.98)
	badge_style.border_color = Color(0.24, 0.32, 0.42, 1.0)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(6)
	if hero_level_badge is PanelContainer:
		(hero_level_badge as PanelContainer).visible = false

	if armor_badge is Control:
		var armor_badge_style := StyleBoxFlat.new()
		armor_badge_style.bg_color = Color(0.08, 0.19, 0.31, 0.98)
		armor_badge_style.border_color = Color(0.40, 0.70, 0.96, 0.96)
		armor_badge_style.set_border_width_all(1)
		armor_badge_style.set_corner_radius_all(6)
		armor_badge_style.content_margin_left = 8.0
		armor_badge_style.content_margin_right = 8.0
		armor_badge_style.content_margin_top = 2.0
		armor_badge_style.content_margin_bottom = 2.0
		(armor_badge as Control).add_theme_stylebox_override("panel", armor_badge_style)


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
		(guide as Label).add_theme_font_size_override("font_size", 12)
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


static func _set_label_font_size(label: Variant, font_size: int) -> void:
	if label is Label:
		(label as Label).add_theme_font_size_override("font_size", font_size)


static func _set_label_color(label: Variant, color: Color) -> void:
	if label is Label:
		(label as Label).add_theme_color_override("font_color", color)
