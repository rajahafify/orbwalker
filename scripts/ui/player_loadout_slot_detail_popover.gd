extends RefCounted
class_name PlayerLoadoutSlotDetailPopover

const HUD_CHROME_STYLER_SCRIPT := preload("res://scripts/ui/player_loadout_hud_chrome_styler.gd")
const SLOT_DETAIL_BUBBLE_MIN_WIDTH := 440.0
const SLOT_DETAIL_BUBBLE_MAX_WIDTH := 640.0
const SLOT_DETAIL_BUBBLE_MIN_HEIGHT := 144.0
const SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN := 10.0
const SLOT_DETAIL_BUBBLE_INTERNAL_PADDING := 16.0
const COMBAT_PLAYER_PANEL_SIZE := Vector2(1080, 640)

var _hud: Variant


func bind(hud: Variant) -> void:
	_hud = hud


func _ensure_slot_detail_popover() -> void:
	if _hud._slot_detail_bubble != null:
		return
	var parent := _hud._hud_nodes.get("popover_parent", null) as Control
	if parent == null:
		parent = _hud._hud_nodes.get("section", null) as Control
	if parent == null:
		return
	_hud._slot_detail_bubble = Panel.new()
	_hud._slot_detail_bubble.name = "SlotDetailBubble"
	_hud._slot_detail_bubble.visible = false
	_hud._slot_detail_bubble.z_index = int(_hud._hud_nodes.get("popover_z_index", 210))
	_hud._slot_detail_bubble.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	parent.add_child(_hud._slot_detail_bubble)

	_hud._slot_detail_title = Label.new()
	_hud._slot_detail_title.name = "SlotDetailTitle"
	_hud._slot_detail_title.clip_text = true
	_hud._slot_detail_bubble.add_child(_hud._slot_detail_title)

	_hud._slot_detail_description = Label.new()
	_hud._slot_detail_description.name = "SlotDetailDescription"
	_hud._slot_detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	_hud._slot_detail_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	_hud._slot_detail_description.clip_text = true
	_hud._slot_detail_bubble.add_child(_hud._slot_detail_description)

	_hud._slot_detail_sell_button = Button.new()
	_hud._slot_detail_sell_button.name = "SlotDetailSellButton"
	_hud._slot_detail_sell_button.text = "Sell"
	_hud._slot_detail_sell_button.visible = false
	_hud._slot_detail_sell_button.pressed.connect(_on_slot_detail_sell_pressed)
	_hud._slot_detail_bubble.add_child(_hud._slot_detail_sell_button)


func _apply_slot_detail_popover_chrome() -> void:
	if _hud._slot_detail_bubble == null:
		return
	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(0.03, 0.04, 0.05, 0.98)
	bubble_style.border_color = Color(0.68, 0.49, 0.23, 0.98)
	bubble_style.set_border_width_all(2)
	bubble_style.set_corner_radius_all(8)
	_hud._slot_detail_bubble.add_theme_stylebox_override("panel", bubble_style)
	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._slot_detail_title, Color(0.96, 0.90, 0.78, 1.0), 26)
	_hud._slot_detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._slot_detail_description, Color(0.72, 0.62, 0.45, 1.0), 18)
	_hud._slot_detail_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	_hud._slot_detail_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment
	_hud._slot_detail_sell_button.add_theme_font_size_override("font_size", 26)
	_hud._slot_detail_sell_button.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	var normal := _button_stylebox(Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0))
	var hover := _button_stylebox(Color(0.28, 0.18, 0.09, 0.98), Color(0.76, 0.59, 0.34, 1.0))
	_hud._slot_detail_sell_button.add_theme_stylebox_override("normal", normal)
	_hud._slot_detail_sell_button.add_theme_stylebox_override("hover", hover)
	_hud._slot_detail_sell_button.add_theme_stylebox_override("pressed", hover)


func _button_stylebox(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _set_slot_popover_content(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2) -> void:
	if _hud._slot_detail_bubble == null:
		return
	_hud._hover_slot_global_rect = slot_global_rect
	_hud._hover_slot_type = slot_type
	_hud._hover_slot_index = slot_index
	_hud._hover_slot_title = title
	_hud._hover_slot_description = description
	_hud._slot_detail_title.text = title
	_hud._slot_detail_description.text = description
	_hud._slot_detail_description.visible = description != ""
	_hud._slot_detail_bubble.visible = title != ""
	_update_slot_detail_bubble()


func _update_selected_slot_popover() -> void:
	if _hud._hover_slot_type != "":
		return
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		hide_slot_detail_popover()
		return
	var slot_index: int = int(_hud._selected_equipment_slot) if selected_kind == "equipment" else int(_hud._selected_consumable_slot)
	var row := _hud._hud_nodes.get("equipment_icons") as Control
	if selected_kind == "consumable":
		row = _hud._hud_nodes.get("consumable_icons") as Control
	var slot := row.get_node_or_null("%sSlot%d" % [selected_kind.capitalize(), slot_index]) as Control if row != null else null
	if slot == null:
		return
	var item_id: String = _hud._slot_content_id(selected_kind, slot_index)
	var content: Dictionary = _hud.lookup_content_definition(item_id)
	_set_slot_popover_content(
		selected_kind, slot_index, String(content.get("display_name", item_id)), String(content.get("description", "")), slot.get_global_rect()
	)


func hide_slot_detail_popover() -> void:
	if _hud._slot_detail_bubble == null:
		return
	_hud._hover_slot_global_rect = Rect2()
	_hud._hover_slot_type = ""
	_hud._hover_slot_index = -1
	_hud._hover_slot_title = ""
	_hud._hover_slot_description = ""
	_hud._slot_detail_bubble.visible = false


func _update_slot_detail_bubble() -> void:
	if _hud._slot_detail_bubble == null or not _hud._slot_detail_bubble.visible:
		return
	var has_description: bool = _hud._slot_detail_description.text != ""
	var show_sell_action := _slot_popover_shows_sell_action()
	var parent := _hud._slot_detail_bubble.get_parent() as Control
	var parent_size := COMBAT_PLAYER_PANEL_SIZE
	var slot_top_left: Vector2 = _hud._hover_slot_global_rect.position
	var slot_size: Vector2 = _hud._hover_slot_global_rect.size
	if parent != null:
		parent_size = parent.size
		var transform_inverse := parent.get_global_transform_with_canvas().affine_inverse()
		slot_top_left = transform_inverse * _hud._hover_slot_global_rect.position
		var slot_bottom_right: Vector2 = transform_inverse * (_hud._hover_slot_global_rect.position + _hud._hover_slot_global_rect.size)
		slot_size = slot_bottom_right - slot_top_left

	var bubble_width := _slot_detail_popover_width(parent_size.x)
	var max_width := maxf(280.0, parent_size.x - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var max_height := maxf(108.0, parent_size.y - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var bubble_size := Vector2(minf(bubble_width, max_width), SLOT_DETAIL_BUBBLE_MIN_HEIGHT)
	var content_width := maxf(200.0, bubble_size.x - SLOT_DETAIL_BUBBLE_INTERNAL_PADDING * 2.0)

	var title_height := 38.0
	var row_gap := 10.0
	var sell_button_height := 72.0 if show_sell_action else 0.0
	var description_target_height := _slot_detail_description_height(_hud._slot_detail_description.text, content_width, 18) if has_description else 0.0
	var non_description_height := SLOT_DETAIL_BUBBLE_INTERNAL_PADDING + title_height + SLOT_DETAIL_BUBBLE_INTERNAL_PADDING
	if has_description:
		non_description_height += row_gap
	if show_sell_action:
		non_description_height += 12.0 + sell_button_height
	var description_height := 0.0
	if has_description:
		var description_max_height := maxf(40.0, max_height - non_description_height)
		description_height = minf(description_target_height, description_max_height)
	var content_height := non_description_height + description_height
	bubble_size.y = minf(max_height, maxf(SLOT_DETAIL_BUBBLE_MIN_HEIGHT, content_height))

	var local_x: float = slot_top_left.x + (slot_size.x - bubble_size.x) * 0.5
	local_x = clampf(
		local_x,
		SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN,
		maxf(SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN, parent_size.x - bubble_size.x - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN)
	)
	var preferred_above := slot_top_left.y - bubble_size.y - 12.0
	var preferred_below := slot_top_left.y + slot_size.y + 12.0
	var max_local_y := maxf(SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN, parent_size.y - bubble_size.y - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN)
	var local_y := preferred_above
	if local_y < SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN:
		local_y = preferred_below
	if local_y > max_local_y:
		local_y = max_local_y
	local_y = clampf(local_y, SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN, max_local_y)

	_hud._slot_detail_bubble.position = Vector2(local_x, local_y)
	_hud._slot_detail_bubble.size = bubble_size

	var cursor_y := SLOT_DETAIL_BUBBLE_INTERNAL_PADDING
	_hud._apply_rect(_hud._slot_detail_title, Rect2(Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y), Vector2(content_width, title_height)))
	cursor_y += title_height
	if has_description:
		cursor_y += row_gap
		_hud._slot_detail_description.visible = true
		_hud._apply_rect(
			_hud._slot_detail_description, Rect2(Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y), Vector2(content_width, description_height))
		)
		cursor_y += description_height
	else:
		_hud._slot_detail_description.visible = false
		_hud._apply_rect(_hud._slot_detail_description, Rect2(Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y), Vector2(content_width, 0.0)))

	_hud._slot_detail_sell_button.visible = show_sell_action
	_hud._slot_detail_sell_button.disabled = _selected_slot_kind() == ""
	_hud._slot_detail_sell_button.text = "Sell  %s" % _selected_slot_sell_text()
	if show_sell_action:
		cursor_y += 12.0
		_hud._apply_rect(
			_hud._slot_detail_sell_button, Rect2(Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y), Vector2(content_width, sell_button_height))
		)
	else:
		_hud._apply_rect(_hud._slot_detail_sell_button, Rect2(Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y), Vector2(content_width, 0.0)))


func _slot_detail_popover_width(parent_width: float) -> float:
	var available_width := maxf(280.0, parent_width - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var title_len := float(_hud._slot_detail_title.text.length())
	var description_len := float(_hud._slot_detail_description.text.length())
	var title_bonus := minf(96.0, maxf(0.0, title_len - 18.0) * 2.2)
	var description_bonus := minf(140.0, maxf(0.0, description_len - 72.0) * 1.2)
	var desired := SLOT_DETAIL_BUBBLE_MIN_WIDTH + maxf(title_bonus, description_bonus)
	return clampf(desired, SLOT_DETAIL_BUBBLE_MIN_WIDTH, minf(SLOT_DETAIL_BUBBLE_MAX_WIDTH, available_width))


func _slot_detail_description_height(description: String, width: float, font_size: int) -> float:
	if description == "":
		return 0.0
	var chars_per_line := maxi(18, int(floor(width / maxf(7.0, float(font_size) * 0.53))))
	var total_lines := 0
	for segment in description.split("\n", false):
		var segment_text := segment.strip_edges()
		if segment_text == "":
			total_lines += 1
			continue
		total_lines += maxi(1, int(ceil(float(segment_text.length()) / float(chars_per_line))))
	total_lines = clampi(total_lines, 1, 10)
	return float(total_lines) * (float(font_size) + 3.0) + 6.0


func _slot_popover_shows_sell_action() -> bool:
	if _hud._hover_slot_type != "equipment" and _hud._hover_slot_type != "consumable":
		return false
	if _hud._hover_slot_title == "":
		return false
	if _hud._hover_slot_title.begins_with("Empty "):
		return false
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return false
	var selected_slot_index: int = int(_hud._selected_equipment_slot) if selected_kind == "equipment" else int(_hud._selected_consumable_slot)
	return selected_kind == _hud._hover_slot_type and selected_slot_index == _hud._hover_slot_index


func _selected_slot_sell_text() -> String:
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return "Select slot"
	var slot_index: int = int(_hud._selected_equipment_slot) if selected_kind == "equipment" else int(_hud._selected_consumable_slot)
	var item_id: String = _hud._slot_content_id(selected_kind, slot_index)
	var content: Dictionary = _hud.lookup_content_definition(item_id)
	return "+%d gold" % int(content.get("sell_value", content.get("base_price", 0)))


func _selected_slot_kind() -> String:
	if _hud._slot_content_id("equipment", _hud._selected_equipment_slot) != "":
		return "equipment"
	if _hud._slot_content_id("consumable", _hud._selected_consumable_slot) != "":
		return "consumable"
	return ""


func _slot_content_id(slot_type: String, slot_index: int) -> String:
	var progression_snapshot: Dictionary = _hud._player_data.get("progression", {})
	var slots: Array = progression_snapshot.get("equipment_slots", []) if slot_type == "equipment" else progression_snapshot.get("consumable_slots", [])
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	return String(slots[slot_index])


func _on_slot_detail_sell_pressed() -> void:
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return
	var slot_index: int = int(_hud._selected_equipment_slot) if selected_kind == "equipment" else int(_hud._selected_consumable_slot)
	_hud.sell_slot_requested.emit(selected_kind, slot_index)


func _has_inventory_focus() -> bool:
	return _hud._selected_equipment_slot >= 0 or _hud._selected_consumable_slot >= 0 or (_hud._slot_detail_bubble != null and _hud._slot_detail_bubble.visible)


func _is_inside_inventory_focus_area(global_point: Vector2) -> bool:
	if _control_contains_point(_hud._slot_detail_bubble, global_point):
		return true
	if _control_contains_point(_hud._slot_detail_sell_button, global_point):
		return true
	for key in ["equipment_icons", "consumable_icons", "relic_icons"]:
		if _point_hits_control_children(_hud._hud_nodes.get(key) as Control, global_point):
			return true
	return false


func _point_hits_control_children(root: Control, global_point: Vector2) -> bool:
	if root == null:
		return false
	for child in root.get_children():
		if child is Control and _control_contains_point(child as Control, global_point):
			return true
	return false


func _control_contains_point(control: Control, global_point: Vector2) -> bool:
	if control == null or not control.is_visible_in_tree():
		return false
	return control.get_global_rect().has_point(global_point)
