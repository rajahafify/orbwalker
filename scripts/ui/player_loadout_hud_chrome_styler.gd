extends RefCounted
class_name PlayerLoadoutHudChromeStyler


static func apply_player_hud_chrome(nodes: Dictionary, visuals: Variant) -> void:
	var section_texture: Texture2D = null
	if visuals != null and visuals.has_method("combat_player_hud_rail_texture"):
		section_texture = visuals.combat_player_hud_rail_texture()
	if section_texture != null:
		_apply_node_stylebox(nodes, "section", _texture_stylebox(section_texture, 26, 26, 26, 26, 10.0))
		_apply_node_stylebox(nodes, "footer_panel", StyleBoxEmpty.new())
	else:
		_apply_node_stylebox(nodes, "section", _hud_section_stylebox())
		_apply_node_stylebox(nodes, "footer_panel", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "mastery_panel", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "loadout_frame", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "hero_card", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "vitals_frame", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "armor_badge", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "equipment_icons", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "consumable_icons", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "relic_icons", StyleBoxEmpty.new())
	_apply_progressbar_flat_style(nodes.get("hp_bar") as ProgressBar, Color(0.78, 0.16, 0.17, 1.0))
	var mastery_title_font_size := 32
	var mastery_panel := nodes.get("mastery_panel") as Control
	if mastery_panel != null and mastery_panel.size.y <= 150.0:
		mastery_title_font_size = 28
	var mastery_title := nodes.get("mastery_title") as Label
	if mastery_title != null:
		mastery_title.text = "MASTERY"
	_apply_hud_label_style(mastery_title, Color(0.94, 0.90, 0.78, 1.0), mastery_title_font_size)
	_apply_hud_label_style(nodes.get("hp_label") as Label, Color(0.98, 0.98, 0.99, 1.0), 36)
	var equipment_label := nodes.get("equipment_label") as Label
	if equipment_label != null:
		equipment_label.text = "EQUIPMENT"
	var consumable_label := nodes.get("consumable_label") as Label
	if consumable_label != null:
		consumable_label.text = "CONSUMABLES"
	var relic_label := nodes.get("relic_label") as Label
	if relic_label != null:
		relic_label.text = "RELICS"
	_apply_hud_label_style(equipment_label, Color(0.96, 0.88, 0.66, 1.0), 23)
	_apply_hud_label_style(consumable_label, Color(0.90, 0.93, 0.99, 1.0), 23)
	_apply_hud_label_style(relic_label, Color(0.88, 0.94, 0.99, 1.0), 21)


static func _hud_section_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.06, 0.97)
	style.border_color = Color(0.58, 0.46, 0.24, 0.94)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


static func _texture_stylebox(texture: Texture2D, left: int, right: int, top: int, bottom: int, content_margin: float = 8.0) -> StyleBoxTexture:
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


static func _apply_progressbar_flat_style(bar: ProgressBar, fill_color: Color) -> void:
	if bar == null:
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.03, 0.06, 0.09, 0.96)
	bg.set_corner_radius_all(7)
	bg.set_border_width_all(2)
	bg.border_color = Color(0.55, 0.42, 0.21, 0.84)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(7)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


static func _apply_hud_label_style(label: Label, color: Color, font_size: int) -> void:
	if label == null:
		return
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.96))


static func _apply_node_stylebox(nodes: Dictionary, key: String, stylebox: StyleBox) -> void:
	var control := nodes.get(key, null) as Control
	if control == null:
		return
	control.add_theme_stylebox_override("panel", stylebox)
