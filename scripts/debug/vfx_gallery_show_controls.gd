extends RefCounted
class_name VfxGalleryShowControls

const SMALL_LABEL_FONT_SIZE := 20
const ANCHOR_CAPTION_FONT_SIZE := 22
const STATUS_LABEL_FONT_SIZE := 22
const DESCRIPTION_LABEL_FONT_SIZE := 20
const CONTROL_BUTTON_FONT_SIZE := 22


static func build(owner: Control, callbacks: Dictionary) -> Dictionary:
	owner.anchor_right = 1.0
	owner.anchor_bottom = 1.0

	var nodes := {}
	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.012, 0.016, 0.024, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	owner.add_child(background)

	var margin := MarginContainer.new()
	margin.name = "PageMargin"
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	owner.add_child(margin)

	var page := VBoxContainer.new()
	page.name = "PageRoot"
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	page.add_child(_make_header(callbacks, nodes))
	page.add_child(_make_control_panel(callbacks, nodes))
	page.add_child(_make_preview_panel(nodes))
	return nodes


static func make_small_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(0, 42)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", SMALL_LABEL_FONT_SIZE)
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86, 1.0))
	return label


static func make_anchor_caption(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", ANCHOR_CAPTION_FONT_SIZE)
	label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.96, 0.92))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("outline_size", 4)
	return label


static func readability_font_probe() -> Dictionary:
	return {
		"small_label": SMALL_LABEL_FONT_SIZE,
		"anchor_caption": ANCHOR_CAPTION_FONT_SIZE,
		"status_label": STATUS_LABEL_FONT_SIZE,
		"description_label": DESCRIPTION_LABEL_FONT_SIZE,
		"control_button": CONTROL_BUTTON_FONT_SIZE,
	}


static func panel_style(bg: Color, border: Color, border_width: int = 2, radius: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style


static func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


static func _make_header(callbacks: Dictionary, nodes: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.name = "Header"
	row.custom_minimum_size = Vector2(0, 58)
	row.add_theme_constant_override("separation", 12)

	var back := Button.new()
	back.name = "BackButton"
	back.text = "< Index"
	back.custom_minimum_size = Vector2(132, 52)
	back.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(back.pressed, callbacks.get("back_pressed"))
	row.add_child(back)
	nodes["back_button"] = back

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "VFX Show Page"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72, 1.0))
	row.add_child(title)
	nodes["title_label"] = title

	var status_label := Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Ready"
	status_label.custom_minimum_size = Vector2(270, 52)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	status_label.add_theme_font_size_override("font_size", STATUS_LABEL_FONT_SIZE)
	status_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.92, 1.0))
	row.add_child(status_label)
	nodes["status_label"] = status_label
	return row


static func _make_control_panel(callbacks: Dictionary, nodes: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.name = "ControlPanel"
	panel.add_theme_stylebox_override("panel", panel_style(Color(0.035, 0.047, 0.067, 0.95), Color(0.33, 0.43, 0.56, 0.9), 2))

	var box := VBoxContainer.new()
	box.name = "ControlBox"
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var first_row := HBoxContainer.new()
	first_row.name = "SelectorRow"
	first_row.add_theme_constant_override("separation", 10)
	box.add_child(first_row)

	var entry_select := OptionButton.new()
	entry_select.name = "EntrySelect"
	entry_select.custom_minimum_size = Vector2(330, 48)
	entry_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	entry_select.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(entry_select.item_selected, callbacks.get("entry_selected"))
	first_row.add_child(entry_select)
	nodes["entry_select"] = entry_select

	var phase_select := OptionButton.new()
	phase_select.name = "PhaseSelect"
	phase_select.custom_minimum_size = Vector2(210, 48)
	phase_select.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(phase_select.item_selected, callbacks.get("phase_selected"))
	first_row.add_child(phase_select)
	nodes["phase_select"] = phase_select

	var quality_select := OptionButton.new()
	quality_select.name = "QualitySelect"
	quality_select.custom_minimum_size = Vector2(150, 48)
	quality_select.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	quality_select.add_item("Low")
	quality_select.set_item_metadata(0, "low")
	quality_select.add_item("High")
	quality_select.set_item_metadata(1, "high")
	quality_select.select(0)
	_connect_callback(quality_select.item_selected, callbacks.get("quality_selected"))
	first_row.add_child(quality_select)
	nodes["quality_select"] = quality_select

	var play_button := Button.new()
	play_button.name = "PlayButton"
	play_button.text = "Play"
	play_button.custom_minimum_size = Vector2(112, 48)
	play_button.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(play_button.pressed, callbacks.get("restart_playback"))
	first_row.add_child(play_button)
	nodes["play_button"] = play_button

	var second_row := HBoxContainer.new()
	second_row.name = "AmountRow"
	second_row.add_theme_constant_override("separation", 10)
	box.add_child(second_row)

	second_row.add_child(make_small_label("Amount"))
	var amount_slider := HSlider.new()
	amount_slider.name = "AmountSlider"
	amount_slider.min_value = 1.0
	amount_slider.max_value = 60.0
	amount_slider.step = 1.0
	amount_slider.value = 12.0
	amount_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_connect_callback(amount_slider.value_changed, callbacks.get("amount_slider_changed"))
	second_row.add_child(amount_slider)
	nodes["amount_slider"] = amount_slider

	var amount_spin := SpinBox.new()
	amount_spin.name = "AmountSpin"
	amount_spin.min_value = 1.0
	amount_spin.max_value = 60.0
	amount_spin.step = 1.0
	amount_spin.value = 12.0
	amount_spin.custom_minimum_size = Vector2(104, 48)
	amount_spin.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(amount_spin.value_changed, callbacks.get("amount_spin_changed"))
	second_row.add_child(amount_spin)
	nodes["amount_spin"] = amount_spin

	second_row.add_child(make_small_label("Speed"))
	var speed_slider := HSlider.new()
	speed_slider.name = "SpeedSlider"
	speed_slider.min_value = 0.35
	speed_slider.max_value = 1.25
	speed_slider.step = 0.05
	speed_slider.value = 0.55
	speed_slider.custom_minimum_size = Vector2(170, 40)
	_connect_callback(speed_slider.value_changed, callbacks.get("speed_changed"))
	second_row.add_child(speed_slider)
	nodes["speed_slider"] = speed_slider

	var third_row := HBoxContainer.new()
	third_row.name = "PresetRow"
	third_row.add_theme_constant_override("separation", 10)
	box.add_child(third_row)

	var preset_row := HBoxContainer.new()
	preset_row.name = "AmountPresets"
	preset_row.add_theme_constant_override("separation", 8)
	preset_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	third_row.add_child(preset_row)
	nodes["preset_row"] = preset_row

	var loop_toggle := CheckBox.new()
	loop_toggle.name = "LoopToggle"
	loop_toggle.text = "Loop"
	loop_toggle.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(loop_toggle.toggled, callbacks.get("loop_toggled"))
	third_row.add_child(loop_toggle)
	nodes["loop_toggle"] = loop_toggle

	var anchors_toggle := CheckBox.new()
	anchors_toggle.name = "AnchorsToggle"
	anchors_toggle.text = "Anchors"
	anchors_toggle.button_pressed = true
	anchors_toggle.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(anchors_toggle.toggled, callbacks.get("anchor_toggle_changed"))
	third_row.add_child(anchors_toggle)
	nodes["anchors_toggle"] = anchors_toggle

	var clean_toggle := CheckBox.new()
	clean_toggle.name = "CleanToggle"
	clean_toggle.text = "Clean"
	clean_toggle.add_theme_font_size_override("font_size", CONTROL_BUTTON_FONT_SIZE)
	_connect_callback(clean_toggle.toggled, callbacks.get("clean_toggle_changed"))
	third_row.add_child(clean_toggle)
	nodes["clean_toggle"] = clean_toggle

	var description_label := Label.new()
	description_label.name = "DescriptionLabel"
	description_label.text = ""
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	description_label.add_theme_font_size_override("font_size", DESCRIPTION_LABEL_FONT_SIZE)
	description_label.add_theme_color_override("font_color", Color(0.68, 0.74, 0.82, 1.0))
	box.add_child(description_label)
	nodes["description_label"] = description_label
	return panel


static func _make_preview_panel(nodes: Dictionary) -> Control:
	var frame := PanelContainer.new()
	frame.name = "PreviewFrame"
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", panel_style(Color(0.0, 0.0, 0.0, 0.96), Color(0.78, 0.60, 0.24, 0.95), 2))

	var preview_root := Control.new()
	preview_root.name = "PreviewRoot"
	preview_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_root.clip_contents = true
	frame.add_child(preview_root)
	nodes["preview_root"] = preview_root
	return frame


static func _connect_callback(signal_value: Signal, callback: Variant) -> void:
	if callback is Callable and callback.is_valid():
		signal_value.connect(callback)
