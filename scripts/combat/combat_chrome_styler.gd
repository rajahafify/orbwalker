extends RefCounted

const THEME_HELPERS := preload("res://scripts/combat/combat_chrome_theme_helpers.gd")

const MIN_TITLE_FONT_SIZE := 30
const MIN_VALUE_FONT_SIZE := 24
const MIN_META_FONT_SIZE := 20
const MIN_ROW_LABEL_FONT_SIZE := 20
const ENEMY_NAME_FONT_SIZE := 40
const ENEMY_HP_FONT_SIZE := 30
const PRIMARY_INTENT_TITLE_FONT_SIZE := 24
const PRIMARY_INTENT_AMOUNT_FONT_SIZE := 42
const PRIMARY_INTENT_DETAIL_FONT_SIZE := 20
const TIMER_FONT_SIZE := 36
const PLAYER_LABEL_FONT_SIZE := 28

const CHROME_NODE_BINDINGS := {
	"board_view": "_board_view",
	"background": "_background",
	"backdrop_scrim": "_background_scrim",
	"top_bar": "_top_bar",
	"enemy_panel": "_enemy_panel",
	"enemy_portrait": "_enemy_portrait",
	"enemy_hp_row": "_enemy_hp_row",
	"combat_strip": "_combat_strip",
	"board_frame": "_board_frame",
	"debug_overlay": "_debug_overlay",
	"combat_log_frame": "_combat_log_frame",
	"enemy_hp_bar": "_enemy_hp_bar",
	"player_hp_bar": "_player_hp_bar",
	"player_armor_bar": "_player_armor_bar",
	"title_label": "_title_label",
	"hint_label": "_hint_label",
	"enemy_step_label": "_enemy_step_label",
	"timer_label": "_timer_label",
	"run_progress_label": "_run_progress_label",
	"phase_label": "_phase_label",
	"turn_summary_label": "_turn_summary_label",
	"player_label": "_player_label",
	"player_armor_label": "_player_armor_label",
	"attack_stat_label": "_attack_stat_label",
	"armor_stat_label": "_armor_stat_label",
	"heart_stat_label": "_heart_stat_label",
	"gold_stat_label": "_gold_stat_label",
	"enemy_label": "_enemy_label",
	"enemy_name_label": "_enemy_name_label",
	"enemy_hp_text_label": "_enemy_hp_text_label",
	"intent_label": "_intent_label",
	"primary_intent_title_label": "_primary_intent_title_label",
	"primary_intent_amount_label": "_primary_intent_amount_label",
	"primary_intent_detail_label": "_primary_intent_detail_label",
	"equipment_row_label": "_equipment_row_label",
	"consumable_row_label": "_consumable_row_label",
	"relic_row_label": "_relic_row_label",
	"mastery_row_label": "_mastery_row_label",
	"armor_badge_label": "_armor_badge_label",
	"timer_state_label": "_timer_state_label",
	"back_button": "_back_button",
	"debug_toggle_button": "_debug_toggle_button",
	"settings_button": "_settings_button",
	"next_button": "_next_button",
	"timer_track": "_timer_track",
	"timer_center_marker": "_timer_center_marker",
	"intent_badge": "_intent_badge",
	"loadout_frame": "_loadout_frame",
	"mastery_strip": "_mastery_strip",
	"hero_card": "_hero_card",
	"vitals_frame": "_vitals_frame",
	"hero_level_badge": "_hero_level_badge",
	"armor_badge": "_armor_badge",
	"board_shadow": "_board_shadow",
	"outcome_summary_panel": "_outcome_summary_panel",
	"outcome_title_label": "_outcome_title_label",
	"outcome_body_label": "_outcome_body_label",
	"status_label": "_status_label",
	"enemy_debug_label": "_enemy_debug_label",
	"combat_log_text": "_combat_log_text",
	"divider_enemy_timer": "_divider_enemy_timer",
	"divider_timer_board": "_divider_timer_board",
	"divider_board_player": "_divider_board_player",
	"corner_top_left": "_corner_top_left",
	"corner_top_right": "_corner_top_right",
	"corner_bottom_left": "_corner_bottom_left",
	"corner_bottom_right": "_corner_bottom_right",
}


static func nodes_from_root_nodes(root_nodes: Dictionary, extras: Dictionary = {}) -> Dictionary:
	var nodes := {}
	for chrome_key in CHROME_NODE_BINDINGS.keys():
		nodes[chrome_key] = root_nodes.get(String(CHROME_NODE_BINDINGS[chrome_key]), null)
	for key in extras.keys():
		nodes[key] = extras[key]
	return nodes


static func readability_font_probe() -> Dictionary:
	return {
		"timer_label": TIMER_FONT_SIZE,
		"enemy_name_label": ENEMY_NAME_FONT_SIZE,
		"enemy_hp_text_label": ENEMY_HP_FONT_SIZE,
		"primary_intent_title_label": PRIMARY_INTENT_TITLE_FONT_SIZE,
		"primary_intent_amount_label": PRIMARY_INTENT_AMOUNT_FONT_SIZE,
		"primary_intent_detail_label": PRIMARY_INTENT_DETAIL_FONT_SIZE,
		"run_progress_label": MIN_META_FONT_SIZE,
		"phase_label": MIN_META_FONT_SIZE,
		"turn_summary_label": MIN_META_FONT_SIZE,
		"equipment_row_label": MIN_ROW_LABEL_FONT_SIZE,
		"consumable_row_label": MIN_ROW_LABEL_FONT_SIZE,
		"relic_row_label": MIN_ROW_LABEL_FONT_SIZE,
		"mastery_row_label": MIN_ROW_LABEL_FONT_SIZE,
		"player_label": PLAYER_LABEL_FONT_SIZE,
		"player_armor_label": MIN_VALUE_FONT_SIZE,
		"intent_label": MIN_VALUE_FONT_SIZE,
	}


static func apply_visual_chrome(nodes: Dictionary, config: Dictionary) -> void:
	var visuals: Variant = nodes.get("visual_registry", null)
	var background: Variant = nodes.get("background", null)
	if background is TextureRect:
		var background_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_background")
		if background_texture != null:
			(background as TextureRect).texture = background_texture
		(background as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		(background as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
		(background as TextureRect).modulate = Color(1.0, 1.0, 1.0, 1.0)
	var backdrop_scrim: Variant = nodes.get("backdrop_scrim", null)
	if backdrop_scrim is TextureRect:
		var scrim_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_backdrop_scrim_texture")
		if scrim_texture != null:
			(backdrop_scrim as TextureRect).texture = scrim_texture
		(backdrop_scrim as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		(backdrop_scrim as TextureRect).stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
		(backdrop_scrim as TextureRect).modulate = Color(1.0, 1.0, 1.0, 1.0)

	var board_view: Variant = nodes.get("board_view", null)
	if board_view != null:
		board_view.cell_frame_texture = null
		board_view.cell_spacing = 5.0
		board_view.board_padding = 10.0
		board_view.orb_scale_in_cell = 0.90
		board_view.cell_background = Color(0.08, 0.10, 0.14, 0.99)
		board_view.board_background = Color(0.01, 0.02, 0.04, 0.98)

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.02, 0.04, 0.06, 0.96)
	frame_style.border_color = Color(0.56, 0.44, 0.22, 0.88)
	frame_style.set_border_width_all(2)
	frame_style.set_corner_radius_all(8)
	frame_style.content_margin_left = 10.0
	frame_style.content_margin_right = 10.0
	frame_style.content_margin_top = 8.0
	frame_style.content_margin_bottom = 8.0

	for panel in [
		nodes.get("board_frame", null),
		nodes.get("debug_overlay", null),
		nodes.get("combat_log_frame", null),
	]:
		if panel is Control:
			(panel as Control).add_theme_stylebox_override("panel", frame_style)

	var board_frame_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_board_frame_texture")
	if board_frame_texture != null:
		var board_style := THEME_HELPERS.panel_texture_stylebox(board_frame_texture, 26, 26, 26, 26, 16.0)
		var board_frame: Variant = nodes.get("board_frame", null)
		if board_frame is Control:
			(board_frame as Control).add_theme_stylebox_override("panel", board_style)

	var enemy_panel_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_enemy_panel_frame_texture")
	if enemy_panel_texture != null:
		var enemy_style := THEME_HELPERS.panel_texture_stylebox(enemy_panel_texture, 24, 24, 24, 24, 2.0)
		var enemy_panel: Variant = nodes.get("enemy_panel", null)
		if enemy_panel is Control:
			(enemy_panel as Control).add_theme_stylebox_override("panel", enemy_style)
	var enemy_stage_backdrop: Variant = nodes.get("enemy_stage_backdrop", null)
	if enemy_stage_backdrop is TextureRect:
		(enemy_stage_backdrop as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		(enemy_stage_backdrop as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
		(enemy_stage_backdrop as TextureRect).texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		(enemy_stage_backdrop as TextureRect).modulate = Color(1.0, 1.0, 1.0, 0.94)
	var enemy_ground_shadow: Variant = nodes.get("enemy_ground_shadow", null)
	if enemy_ground_shadow is Panel:
		var shadow_style := StyleBoxFlat.new()
		shadow_style.bg_color = Color(0.0, 0.0, 0.0, 0.34)
		shadow_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
		shadow_style.set_corner_radius_all(999)
		(enemy_ground_shadow as Panel).add_theme_stylebox_override("panel", shadow_style)
	var enemy_portrait: Variant = nodes.get("enemy_portrait", null)
	if enemy_portrait is TextureRect:
		(enemy_portrait as TextureRect).expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		(enemy_portrait as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		(enemy_portrait as TextureRect).texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		(enemy_portrait as TextureRect).modulate = Color(1.0, 1.0, 1.0, 1.0)
		(enemy_portrait as TextureRect).material = null
	var enemy_text_scrim: Variant = nodes.get("enemy_text_scrim", null)
	if enemy_text_scrim is ColorRect:
		(enemy_text_scrim as ColorRect).color = Color(0.01, 0.03, 0.05, 0.56)
		(enemy_text_scrim as ColorRect).visible = true

	var top_bar_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_top_bar_frame_texture")
	if top_bar_texture != null:
		var top_style := THEME_HELPERS.panel_texture_stylebox(top_bar_texture, 34, 34, 24, 24, 10.0)
		var top_bar: Variant = nodes.get("top_bar", null)
		if top_bar is Control and not (top_bar as Control).has_method("apply_header_layout"):
			(top_bar as Control).add_theme_stylebox_override("panel", top_style)

	var combat_strip_texture := THEME_HELPERS.resolve_visual_texture(visuals, "combat_timer_track_texture")
	var combat_strip: Variant = nodes.get("combat_strip", null)
	if combat_strip is Control:
		(combat_strip as Control).add_theme_stylebox_override("panel", THEME_HELPERS.transparent_panel_stylebox())

	var ornate_frame_style := StyleBoxFlat.new()
	ornate_frame_style.bg_color = Color(0.02, 0.04, 0.07, 0.98)
	ornate_frame_style.border_color = Color(0.70, 0.55, 0.29, 0.94)
	ornate_frame_style.set_border_width_all(2)
	ornate_frame_style.set_corner_radius_all(10)
	ornate_frame_style.content_margin_left = 10.0
	ornate_frame_style.content_margin_right = 10.0
	ornate_frame_style.content_margin_top = 8.0
	ornate_frame_style.content_margin_bottom = 8.0
	var shared_top_bar: Variant = nodes.get("top_bar", null)
	var is_shared_top_header := shared_top_bar is Control and (shared_top_bar as Control).has_method("apply_header_layout")
	if top_bar_texture == null and not is_shared_top_header:
		THEME_HELPERS.apply_panel_stylebox(nodes.get("top_bar", null), ornate_frame_style)
	if enemy_panel_texture == null:
		THEME_HELPERS.apply_panel_stylebox(nodes.get("enemy_panel", null), ornate_frame_style)
	if combat_strip_texture == null:
		THEME_HELPERS.apply_panel_stylebox(nodes.get("combat_strip", null), THEME_HELPERS.transparent_panel_stylebox())

	THEME_HELPERS.apply_progressbar_flat_style(nodes.get("enemy_hp_bar", null), Color(0.58, 0.09, 0.78, 1.0))
	THEME_HELPERS.apply_progressbar_flat_style(nodes.get("player_hp_bar", null), Color(0.78, 0.16, 0.17, 1.0))
	THEME_HELPERS.apply_progressbar_flat_style(nodes.get("player_armor_bar", null), Color(0.16, 0.50, 0.86, 1.0))
	THEME_HELPERS.apply_progressbar_style(
		nodes.get("player_hp_bar", null),
		THEME_HELPERS.resolve_visual_texture(visuals, "clean_hud_texture", ["hp_bar_frame"]),
		THEME_HELPERS.resolve_visual_texture(visuals, "clean_hud_texture", ["hp_bar_fill"])
	)

	var ui_text_color := Color(0.95, 0.96, 0.98, 1.0)
	for label in [
		nodes.get("title_label", null),
		nodes.get("hint_label", null),
		nodes.get("timer_label", null),
		nodes.get("enemy_step_label", null),
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
		nodes.get("enemy_name_label", null),
		nodes.get("enemy_hp_text_label", null),
		nodes.get("intent_label", null),
		nodes.get("primary_intent_title_label", null),
		nodes.get("primary_intent_amount_label", null),
		nodes.get("primary_intent_detail_label", null),
	]:
		if is_shared_top_header and (label == nodes.get("title_label", null) or label == nodes.get("hint_label", null)):
			continue
		if label is Label:
			(label as Label).add_theme_color_override("font_color", ui_text_color)

	var font_size_title := maxi(int(config.get("font_size_title", 20)), MIN_TITLE_FONT_SIZE)
	var font_size_value := maxi(int(config.get("font_size_value", 18)), MIN_VALUE_FONT_SIZE)
	var font_size_meta := maxi(int(config.get("font_size_meta", 15)), MIN_META_FONT_SIZE)
	var font_size_row_label := maxi(int(config.get("font_size_row_label", 16)), MIN_ROW_LABEL_FONT_SIZE)
	var debug_text_font_size := int(config.get("debug_text_font_size", 24))
	var debug_input_font_size := int(config.get("debug_input_font_size", 24))
	var debug_input_height := float(config.get("debug_input_height", 72.0))

	if not is_shared_top_header:
		THEME_HELPERS.set_label_font_size(nodes.get("title_label", null), font_size_title)
	THEME_HELPERS.set_label_font_size(nodes.get("enemy_step_label", null), font_size_value)
	if not is_shared_top_header:
		THEME_HELPERS.set_label_font_size(nodes.get("hint_label", null), font_size_value)
		THEME_HELPERS.apply_top_header_label_theme(nodes.get("title_label", null), nodes.get("hint_label", null))
	THEME_HELPERS.set_label_font_size(nodes.get("intent_label", null), font_size_value)
	THEME_HELPERS.set_label_font_size(nodes.get("enemy_name_label", null), ENEMY_NAME_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("enemy_hp_text_label", null), ENEMY_HP_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("enemy_label", null), font_size_value)
	THEME_HELPERS.set_label_font_size(nodes.get("primary_intent_title_label", null), PRIMARY_INTENT_TITLE_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("primary_intent_amount_label", null), PRIMARY_INTENT_AMOUNT_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("primary_intent_detail_label", null), PRIMARY_INTENT_DETAIL_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("timer_label", null), TIMER_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("player_label", null), PLAYER_LABEL_FONT_SIZE)
	THEME_HELPERS.set_label_font_size(nodes.get("player_armor_label", null), font_size_value)

	for stat_label in [
		nodes.get("attack_stat_label", null),
		nodes.get("armor_stat_label", null),
		nodes.get("heart_stat_label", null),
		nodes.get("gold_stat_label", null),
	]:
		THEME_HELPERS.set_label_font_size(stat_label, font_size_value)

	THEME_HELPERS.set_label_font_size(nodes.get("run_progress_label", null), font_size_meta)
	THEME_HELPERS.set_label_font_size(nodes.get("phase_label", null), font_size_meta)
	THEME_HELPERS.set_label_font_size(nodes.get("turn_summary_label", null), font_size_meta)

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
		armor_badge_label.add_theme_font_size_override("font_size", 20)
		armor_badge_label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0, 1.0))
		armor_badge_label.add_theme_constant_override("outline_size", 2)
		armor_badge_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 0.94))

	THEME_HELPERS.set_label_color(nodes.get("phase_label", null), Color(0.70, 0.78, 0.86, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("primary_intent_amount_label", null), Color(1.0, 0.94, 0.75, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("primary_intent_detail_label", null), Color(0.88, 0.94, 0.99, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("enemy_name_label", null), Color(0.98, 0.95, 0.86, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("enemy_hp_text_label", null), Color(1.0, 0.93, 0.88, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("run_progress_label", null), Color(0.82, 0.90, 0.98, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("player_label", null), Color(1.0, 0.96, 0.92, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("player_armor_label", null), Color(0.82, 0.94, 1.0, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("timer_label", null), Color(0.92, 0.97, 1.0, 1.0))
	THEME_HELPERS.set_label_color(nodes.get("timer_state_label", null), Color(0.73, 0.84, 0.92, 1.0))
	THEME_HELPERS.set_label_font_size(nodes.get("timer_state_label", null), 22)
	var timer_state_label := nodes.get("timer_state_label", null) as Label
	if timer_state_label != null:
		timer_state_label.visible = false
		timer_state_label.custom_minimum_size = Vector2.ZERO
	var timer_icon := nodes.get("timer_icon", null) as TextureRect
	if timer_icon != null:
		timer_icon.visible = false
		timer_icon.custom_minimum_size = Vector2.ZERO
	if not is_shared_top_header:
		THEME_HELPERS.set_label_outline(nodes.get("title_label", null), 3, Color(0.01, 0.02, 0.03, 0.92))
	THEME_HELPERS.set_label_outline(nodes.get("enemy_step_label", null), 2, Color(0.01, 0.02, 0.03, 0.90))
	if not is_shared_top_header:
		THEME_HELPERS.set_label_outline(nodes.get("hint_label", null), 2, Color(0.01, 0.02, 0.03, 0.90))
	THEME_HELPERS.set_label_outline(nodes.get("run_progress_label", null), 2, Color(0.01, 0.02, 0.03, 0.90))
	THEME_HELPERS.set_label_outline(nodes.get("timer_label", null), 3, Color(0.01, 0.02, 0.03, 0.92))

	THEME_HELPERS.apply_timer_label_readability(nodes.get("timer_label", null))
	THEME_HELPERS.apply_timer_label_readability(nodes.get("timer_state_label", null))
	var intent_badge: TextureRect = nodes.get("intent_badge", null) as TextureRect
	if intent_badge != null:
		intent_badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		intent_badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		intent_badge.custom_minimum_size = Vector2(112, 112)
		intent_badge.visible = false
	var primary_intent_detail: Label = nodes.get("primary_intent_detail_label", null) as Label
	if primary_intent_detail != null:
		primary_intent_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
		primary_intent_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
		primary_intent_detail.visible = false
	var primary_intent_title: Label = nodes.get("primary_intent_title_label", null) as Label
	if primary_intent_title != null:
		primary_intent_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
		primary_intent_title.visible = false
	var primary_intent_amount: Label = nodes.get("primary_intent_amount_label", null) as Label
	if primary_intent_amount != null:
		primary_intent_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
		primary_intent_amount.visible = false
	var themed_buttons: Array = [nodes.get("debug_toggle_button", null), nodes.get("next_button", null)]
	if not is_shared_top_header:
		themed_buttons.append(nodes.get("back_button", null))
		themed_buttons.append(nodes.get("settings_button", null))
	THEME_HELPERS.apply_button_theme(themed_buttons)
	if not is_shared_top_header:
		THEME_HELPERS.apply_round_header_button_theme([nodes.get("back_button", null), nodes.get("settings_button", null)])
	THEME_HELPERS.apply_timer_track_theme(nodes.get("timer_track", null), visuals)
	THEME_HELPERS.apply_decorative_overlays(nodes, visuals)
	THEME_HELPERS.apply_loadout_group_theme(
		nodes.get("loadout_frame", null),
		nodes.get("mastery_strip", null),
		nodes.get("hero_card", null),
		nodes.get("vitals_frame", null),
		nodes.get("hero_level_badge", null),
		nodes.get("armor_badge", null),
		visuals
	)

	var player_loadout_hud: Variant = nodes.get("player_loadout_hud", null)
	if player_loadout_hud != null:
		player_loadout_hud.apply_player_hud_chrome(nodes.get("player_hud_nodes", {}))

	THEME_HELPERS.apply_board_focus_theme(
		nodes.get("board_shadow", null),
		nodes.get("outcome_summary_panel", null),
		nodes.get("outcome_title_label", null),
		nodes.get("outcome_body_label", null),
		nodes.get("next_button", null)
	)
	THEME_HELPERS.apply_debug_overlay_theme(
		nodes.get("status_label", null),
		nodes.get("enemy_debug_label", null),
		nodes.get("combat_log_text", null),
		nodes.get("debug_console", null),
		debug_text_font_size,
		debug_input_font_size,
		debug_input_height
	)
	(
		THEME_HELPERS
		. apply_stat_chip_theme(
			[
				nodes.get("attack_stat_label", null),
				nodes.get("armor_stat_label", null),
				nodes.get("heart_stat_label", null),
				nodes.get("gold_stat_label", null),
			]
		)
	)


static func apply_zone_guide(zone: Variant, label_text: String, enabled: bool) -> void:
	THEME_HELPERS.apply_zone_guide(zone, label_text, enabled)
