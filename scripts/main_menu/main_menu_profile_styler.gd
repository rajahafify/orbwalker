extends RefCounted
class_name MainMenuProfileStyler

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")


static func apply(
	profile_panel: PanelContainer,
	title_label: Label,
	name_label: Label,
	score_label: Label,
	reset_button: Button,
	close_button: Button,
	colors: Dictionary,
	set_label_style: Callable,
	apply_menu_button_style: Callable
) -> void:
	profile_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(colors.panel_fill, colors.panel_border, 3, 18, Vector4(28, 24, 28, 24)))
	for label_node in [title_label, name_label, score_label]:
		var label := label_node as Label
		if label != null:
			set_label_style.call(label, colors.label, colors.label_outline, 2)
	set_label_style.call(title_label, colors.title, colors.label_outline, 3)
	apply_menu_button_style.call(reset_button, false, false)
	apply_menu_button_style.call(close_button, false, false)
