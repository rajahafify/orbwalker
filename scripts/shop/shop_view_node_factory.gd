extends RefCounted
class_name ShopViewNodeFactory

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")


static func make_panel(node_name: String, parent: Node) -> Panel:
	var panel := Panel.new()
	panel.name = node_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(panel)
	return panel


static func make_button(node_name: String, parent: Node, button_text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = button_text
	button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	parent.add_child(button)
	return button


static func make_root(node_name: String, parent: Node) -> Control:
	var control := Control.new()
	control.name = node_name
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(control)
	return control


static func make_texture(node_name: String, parent: Node) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = node_name
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(texture)
	return texture


static func make_color_rect(node_name: String, parent: Node, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.name = node_name
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(rect)
	return rect


static func make_label(node_name: String, parent: Node, text: String, font_size: int, color: Color, align: int = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	label.name = node_name
	configure_label(label, text, font_size, color, align, enable_wrap)
	parent.add_child(label)
	return label


static func make_child_root(parent: Control) -> Control:
	var root := Control.new()
	root.name = "CardRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	root.position = Vector2.ZERO
	root.size = parent.size
	parent.add_child(root)
	return root


static func make_dynamic_panel(parent: Node, rect: Rect2, style: StyleBox) -> Panel:
	var panel := Panel.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	panel.position = rect.position
	panel.size = rect.size
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


static func make_dynamic_label(parent: Node, text: String, rect: Rect2, color: Color, font_size: int, align: int = HORIZONTAL_ALIGNMENT_LEFT, enable_wrap: bool = false) -> Label:
	var label := Label.new()
	configure_label(label, text, font_size, color, align, enable_wrap)
	label.position = rect.position
	label.size = rect.size
	label.custom_minimum_size = rect.size
	label.clip_contents = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	parent.add_child(label)
	label.position = rect.position
	label.size = rect.size
	return label


static func configure_label(label: Label, text: String, font_size: int, color: Color, align: int, enable_wrap: bool) -> void:
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = align as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART if enable_wrap else TextServer.AUTOWRAP_OFF
	) as TextServer.AutowrapMode
	label.clip_text = true
	label.clip_contents = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.74))


static func clear_children(node: Node) -> void:
	UI_UTILS.clear_children(node)
