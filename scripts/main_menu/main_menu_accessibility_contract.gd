extends RefCounted
class_name MainMenuAccessibilityContract

const SETTINGS_OVERLAY_SCRIPT := preload("res://scripts/main_menu/main_menu_settings_overlay.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const MENU_FILL_COLOR := Color(0.055, 0.085, 0.13, 0.96)
const MENU_PRIMARY_FILL_COLOR := Color(0.07, 0.11, 0.17, 0.98)
const MENU_FOCUS_BORDER_COLOR := Color(0.68, 0.82, 0.98, 1.0)
const MENU_FONT_COLOR := Color(0.90, 0.94, 0.98, 1.0)
const MENU_PRIMARY_FONT_COLOR := Color(0.96, 0.98, 1.0, 1.0)
const MENU_HOVER_FONT_COLOR := Color(0.95, 0.98, 1.0, 1.0)
const MENU_PRESSED_FONT_COLOR := Color(0.84, 0.90, 0.98, 1.0)
const MENU_DISABLED_FONT_COLOR := Color(0.62, 0.70, 0.79, 0.84)
const FOOTER_FILL_COLOR := Color(0.045, 0.075, 0.115, 0.94)
const FOOTER_FONT_COLOR := Color(0.86, 0.92, 0.98, 0.98)
const FOOTER_HOVER_FONT_COLOR := Color(0.93, 0.97, 1.0, 1.0)
const FOOTER_PRESSED_FONT_COLOR := Color(0.80, 0.88, 0.96, 0.98)
const FOOTER_DISABLED_FONT_COLOR := Color(0.61, 0.69, 0.76, 0.80)
const PROFILE_PANEL_FILL_COLOR := Color(0.07, 0.055, 0.045, 0.96)
const PROFILE_PANEL_BORDER_COLOR := Color(0.86, 0.63, 0.24, 1.0)
const PROFILE_LABEL_COLOR := Color(0.95, 0.88, 0.72, 1.0)
const PROFILE_TITLE_COLOR := Color(1.0, 0.78, 0.30, 1.0)
const MIN_TEXT_CONTRAST_RATIO := 4.5
const MIN_NON_TEXT_CONTRAST_RATIO := 3.0
const MIN_TOUCH_TARGET_PX := 48.0


static func layout_probe_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return {"applied": false}
	var safe_rect := _layout_inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (34.0 / DESIGN_SIZE.x))
	var stats_panel := _layout_rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14)
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var element_row := _layout_rect_from_percent_in_rect(safe_rect, 0.03, 0.57, 0.94, 0.12)
	var element_icon_size := int(round(clampf(118.0 * scale_factor, 58.0, 136.0)))
	var element_cell_width := element_row.size.x / 6.0
	if element_icon_size > int(round(element_cell_width * 0.78)):
		element_icon_size = int(round(element_cell_width * 0.78))
	return {
		"applied": true,
		"design_size": DESIGN_SIZE,
		"viewport_size": viewport_size,
		"safe_rect": safe_rect,
		"background": Rect2(Vector2.ZERO, viewport_size),
		"outer_border": _layout_inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (12.0 / DESIGN_SIZE.x)),
		"logo": _layout_rect_from_percent_in_rect(safe_rect, 0.06, 0.11, 0.88, 0.20),
		"menu_button_column": _layout_rect_from_percent_in_rect(safe_rect, 0.18, 0.34, 0.64, 0.44),
		"element_row": element_row,
		"stats_panel": stats_panel,
		"stats_row": Rect2(Vector2(stats_panel.size.x * 0.055, stats_panel.size.y * 0.28), Vector2(stats_panel.size.x * 0.89, stats_panel.size.y * 0.48)),
		"footer_actions": _layout_rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.077),
		"version_label": _layout_rect_from_percent_in_rect(safe_rect, 0.33, 0.946, 0.34, 0.022),
		"status_label": _layout_rect_from_percent_in_rect(safe_rect, 0.04, 0.973, 0.92, 0.019),
		"menu_button_separation": int(round(clampf(16.0 * (viewport_size.y / DESIGN_SIZE.y), 10.0, 24.0))),
		"footer_action_separation": int(round(clampf(10.0 * (viewport_size.x / DESIGN_SIZE.x), 8.0, 16.0))),
		"menu_button_min_height": int(round(viewport_size.y * 0.060)),
		"element_icon_size": element_icon_size,
		"stat_icon_size": int(round(clampf(88.0 * scale_factor, 48.0, 100.0))),
		"footer_icon_max_width": int(round(clampf(72.0 * scale_factor, 36.0, 84.0))),
	}


static func accessibility_audit_snapshot(viewport_size: Vector2 = DESIGN_SIZE) -> Dictionary:
	var layout_probe := layout_probe_snapshot(viewport_size)
	var menu_button_column_rect: Rect2 = layout_probe.get("menu_button_column", Rect2())
	var footer_rect: Rect2 = layout_probe.get("footer_actions", Rect2())
	var menu_button_height := float(layout_probe.get("menu_button_min_height", 0))
	return {
		"min_text_contrast_ratio": MIN_TEXT_CONTRAST_RATIO,
		"min_non_text_contrast_ratio": MIN_NON_TEXT_CONTRAST_RATIO,
		"min_touch_target_px": MIN_TOUCH_TARGET_PX,
		"contrast_pairs":
		[
			_contrast_pair("menu.primary.text", MENU_PRIMARY_FONT_COLOR, MENU_PRIMARY_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.text", MENU_FONT_COLOR, MENU_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.hover_text", MENU_HOVER_FONT_COLOR, MENU_FILL_COLOR.lightened(0.10), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.pressed_text", MENU_PRESSED_FONT_COLOR, MENU_FILL_COLOR.darkened(0.12), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.disabled_text", MENU_DISABLED_FONT_COLOR, MENU_FILL_COLOR.darkened(0.24), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("menu.focus_border", MENU_FOCUS_BORDER_COLOR, MENU_FILL_COLOR.lightened(0.08), MIN_NON_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.text", FOOTER_FONT_COLOR, FOOTER_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.hover_text", FOOTER_HOVER_FONT_COLOR, FOOTER_FILL_COLOR.lightened(0.08), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.pressed_text", FOOTER_PRESSED_FONT_COLOR, FOOTER_FILL_COLOR.darkened(0.10), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("footer.disabled_text", FOOTER_DISABLED_FONT_COLOR, FOOTER_FILL_COLOR.darkened(0.20), MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair(
				"settings.panel_border",
				SETTINGS_OVERLAY_SCRIPT.SETTINGS_PANEL_BORDER_COLOR,
				SETTINGS_OVERLAY_SCRIPT.SETTINGS_PANEL_FILL_COLOR,
				MIN_NON_TEXT_CONTRAST_RATIO
			),
			_contrast_pair("profile.text", PROFILE_LABEL_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("profile.title", PROFILE_TITLE_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_TEXT_CONTRAST_RATIO),
			_contrast_pair("profile.panel_border", PROFILE_PANEL_BORDER_COLOR, PROFILE_PANEL_FILL_COLOR, MIN_NON_TEXT_CONTRAST_RATIO),
		],
		"touch_targets":
		[
			_touch_target("main_menu_button", Vector2(menu_button_column_rect.size.x, menu_button_height)),
			_touch_target("footer_action_button", Vector2(footer_rect.size.x / 3.0, footer_rect.size.y)),
			_touch_target("profile_action_button", Vector2(0.0, menu_button_height)),
		],
		"keyboard_focus_controls":
		[
			"start_run_button",
			"continue_button",
			"tutorial_button",
			"settings_button",
			"profile_button",
			"quit_button",
			"settings_speed_buttons",
			"settings_reduced_motion_button",
			"settings_game_juice_button",
			"settings_game_juice_flag_buttons",
			"settings_reset_button",
			"settings_close_button",
			"reset_profile_button",
			"close_profile_button",
		],
		"initial_focus_control": "start_run_button",
		"main_menu_focus_chain":
		[
			"start_run_button",
			"tutorial_button",
			"settings_button",
			"profile_button",
			"quit_button",
		],
	}


static func _contrast_pair(label: String, foreground: Color, background: Color, minimum_ratio: float) -> Dictionary:
	return {
		"label": label,
		"foreground": foreground,
		"background": background,
		"minimum_ratio": minimum_ratio,
	}


static func _touch_target(label: String, size: Vector2) -> Dictionary:
	return {
		"label": label,
		"size": size,
		"minimum_size": MIN_TOUCH_TARGET_PX,
	}


static func set_control_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect.position
	control.size = rect.size


static func rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return _layout_rect_from_percent_in_rect(base_rect, left, top, width, height)


static func inset_rect(rect: Rect2, inset: float) -> Rect2:
	return _layout_inset_rect(rect, inset)


static func _layout_rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(base_rect.position + Vector2(base_rect.size.x * left, base_rect.size.y * top), Vector2(base_rect.size.x * width, base_rect.size.y * height))


static func _layout_inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(rect.position + Vector2(inset, inset), Vector2(maxf(0.0, rect.size.x - inset * 2.0), maxf(0.0, rect.size.y - inset * 2.0)))
