extends RefCounted
class_name PlayerLoadoutHud

signal equipment_slot_selected(slot_index: int)

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")

const ICON_INNER_SIZE := Vector2(74, 74)
const SLOT_SIZE := Vector2(88, 88)
const SLOT_GAP := 8.0
const MASTERY_ICON_INNER_SIZE := Vector2(34, 34)
const MASTERY_SLOT_SIZE := Vector2(44, 44)
const MASTERY_CELL_WIDTH := 92.0
const MASTERY_CELL_GAP := 24.0
const RELIC_SLOT_SIZE := Vector2(58, 58)
const RELIC_ICON_SIZE := Vector2(48, 48)
const RELIC_SLOT_GAP := 8.0
const COMBAT_PLAYER_PANEL_SIZE := Vector2(1080, 468)
const HERO_CARD_RECT := Rect2(Vector2(30, 18), Vector2(220, 226))
const HERO_PORTRAIT_RECT := Rect2(Vector2(16, 16), Vector2(188, 194))
const VITALS_PANEL_RECT := Rect2(Vector2(272, 26), Vector2(714, 176))
const VITALS_FRAME_RECT := Rect2(Vector2.ZERO, Vector2(714, 176))
const PLAYER_HP_BAR_RECT := Rect2(Vector2(18, 52), Vector2(678, 54))
const PLAYER_ARMOR_BAR_RECT := Rect2(Vector2(18, 112), Vector2(434, 34))
const ARMOR_BADGE_RECT := Rect2(Vector2(474, 112), Vector2(222, 34))
const PLAYER_LOADOUT_RECT := Rect2(Vector2(42, 248), Vector2(996, 150))
const PLAYER_MASTERY_RECT := Rect2(Vector2(42, 404), Vector2(996, 50))
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 34), Vector2(522, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(664, 34), Vector2(288, 88))
const EQUIPMENT_LABEL_RECT := Rect2(Vector2(146, 4), Vector2(296, 22))
const CONSUMABLE_LABEL_RECT := Rect2(Vector2(628, 4), Vector2(328, 22))
const MASTERY_ROOT_RECT := Rect2(Vector2(16, 2), Vector2(964, 46))
const MASTERY_LABEL_RECT := Rect2(Vector2.ZERO, Vector2(120, 46))
const MASTERY_ICONS_RECT := Rect2(Vector2(172, 2), Vector2(720, MASTERY_SLOT_SIZE.y))

var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _selected_equipment_slot := -1
var _empty_silhouette_cache: Dictionary = {}


func set_selected_equipment_slot(slot_index: int) -> void:
	_selected_equipment_slot = slot_index


func populate_loadout_slot_row(row: Control, ids: Array, label: String, slot_count: int, selectable_equipment: bool = false) -> void:
	var visible_ids: Array = []
	for index in range(slot_count):
		visible_ids.append(ids[index] if index < ids.size() else "")
	populate_icon_row(row, visible_ids, label, selectable_equipment)


func populate_icon_row(row: Control, ids: Array, label: String, selectable_equipment: bool = false) -> void:
	_clear_children(row)
	for index in range(ids.size()):
		var id_text := String(ids[index])
		var filled := id_text != ""
		var selectable := selectable_equipment and label == "equipment"
		var slot := _make_slot(index, filled, selectable)
		slot.name = "%sSlot%d" % [label.capitalize(), index]
		slot.position = Vector2(float(index) * (SLOT_SIZE.x + SLOT_GAP), 0.0)

		var icon := TextureRect.new()
		icon.name = "SlotIcon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2((SLOT_SIZE.x - ICON_INNER_SIZE.x) * 0.5, (SLOT_SIZE.y - ICON_INNER_SIZE.y) * 0.5)
		icon.size = ICON_INNER_SIZE
		icon.custom_minimum_size = ICON_INNER_SIZE

		var amount_label: Label = null
		if filled:
			var content: Dictionary = lookup_content_definition(id_text)
			var icon_key := String(content.get("icon_key", ""))
			icon.texture = _visuals.clean_icon_for_key(icon_key)
			icon.tooltip_text = String(content.get("display_name", id_text))
			slot.tooltip_text = _slot_tooltip(content, id_text)
			var badge_text := _badge_text_for(label, content)
			if badge_text != "":
				amount_label = _make_badge_label(badge_text, SLOT_SIZE)
		else:
			icon.texture = _empty_slot_silhouette(label)
			icon.modulate = Color(1.0, 1.0, 1.0, 0.35)
			slot.tooltip_text = "Empty %s slot" % label

		slot.add_child(icon)
		if amount_label != null:
			slot.add_child(amount_label)
		row.add_child(slot)


func populate_mastery_row(row: Control, mastery_levels: Dictionary) -> void:
	_clear_children(row)
	for index in range(OrbType.ALL_TYPES.size()):
		var orb_id: int = OrbType.ALL_TYPES[index]
		var cell := Control.new()
		cell.name = "MasteryCell%d" % orb_id
		cell.size = Vector2(MASTERY_CELL_WIDTH, MASTERY_SLOT_SIZE.y)
		cell.position = Vector2(float(index) * (MASTERY_CELL_WIDTH + MASTERY_CELL_GAP), 0.0)

		var slot := PanelContainer.new()
		slot.name = "MasteryIconSlot"
		slot.custom_minimum_size = MASTERY_SLOT_SIZE
		slot.size = MASTERY_SLOT_SIZE
		slot.position = Vector2.ZERO
		slot.add_theme_stylebox_override("panel", _slot_stylebox())

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.custom_minimum_size = MASTERY_ICON_INNER_SIZE
		icon.size = MASTERY_ICON_INNER_SIZE
		icon.position = Vector2((MASTERY_SLOT_SIZE.x - MASTERY_ICON_INNER_SIZE.x) * 0.5, (MASTERY_SLOT_SIZE.y - MASTERY_ICON_INNER_SIZE.y) * 0.5)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _visuals.mastery_icon(orb_id)
		var level := int(mastery_levels.get(orb_id, 0))
		icon.tooltip_text = "%s Mastery %d" % [OrbType.display_name(orb_id), level]
		if level <= 0:
			icon.modulate = Color(0.6, 0.6, 0.6, 0.7)
		slot.add_child(icon)

		var amount_label := Label.new()
		amount_label.name = "MasteryAmount"
		amount_label.text = str(level)
		amount_label.position = Vector2(52.0, 0.0)
		amount_label.size = Vector2(28.0, MASTERY_SLOT_SIZE.y)
		amount_label.custom_minimum_size = amount_label.size
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		amount_label.add_theme_font_size_override("font_size", 24)
		amount_label.add_theme_color_override("font_color", Color(0.95, 0.84, 0.42, 1.0))
		amount_label.add_theme_constant_override("outline_size", 2)
		amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))

		cell.add_child(slot)
		cell.add_child(amount_label)
		row.add_child(cell)


func populate_relic_row(row: Control, relic_ids: Array, max_visible: int = 4) -> void:
	_clear_children(row)
	var visible_ids: Array[String] = []
	for raw_id in relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			visible_ids.append(relic_id)
	if visible_ids.is_empty():
		return

	var show_count := mini(max_visible, visible_ids.size())
	for index in range(show_count):
		var relic_id := visible_ids[index]
		var slot := PanelContainer.new()
		slot.name = "RelicSlot%d" % index
		slot.custom_minimum_size = RELIC_SLOT_SIZE
		slot.size = RELIC_SLOT_SIZE
		slot.position = Vector2(float(index) * (RELIC_SLOT_SIZE.x + RELIC_SLOT_GAP), 0.0)
		slot.add_theme_stylebox_override("panel", _slot_stylebox())

		var content := lookup_content_definition(relic_id)
		slot.tooltip_text = _slot_tooltip(content, relic_id)

		var icon := TextureRect.new()
		icon.name = "RelicIcon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.position = Vector2((RELIC_SLOT_SIZE.x - RELIC_ICON_SIZE.x) * 0.5, (RELIC_SLOT_SIZE.y - RELIC_ICON_SIZE.y) * 0.5)
		icon.size = RELIC_ICON_SIZE
		icon.custom_minimum_size = RELIC_ICON_SIZE
		icon.texture = _visuals.clean_icon_for_key(String(content.get("icon_key", "")))
		slot.add_child(icon)
		row.add_child(slot)

	if visible_ids.size() > show_count:
		var overflow := Label.new()
		overflow.name = "RelicOverflow"
		overflow.text = "+%d" % (visible_ids.size() - show_count)
		overflow.position = Vector2(float(show_count) * (RELIC_SLOT_SIZE.x + RELIC_SLOT_GAP) + 4.0, 15.0)
		overflow.size = Vector2(50.0, 28.0)
		overflow.add_theme_font_size_override("font_size", 20)
		overflow.add_theme_color_override("font_color", Color(0.95, 0.84, 0.42, 1.0))
		overflow.add_theme_constant_override("outline_size", 2)
		overflow.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
		row.add_child(overflow)


func apply_loadout_rail_layout(equipment_row: Control, equipment_rect: Rect2, consumable_row: Control, consumable_rect: Rect2) -> void:
	_apply_rect(equipment_row, equipment_rect)
	_apply_rect(consumable_row, consumable_rect)


func apply_combat_player_panel_layout(nodes: Dictionary) -> void:
	_apply_node_rect(nodes, "root", Rect2(Vector2.ZERO, COMBAT_PLAYER_PANEL_SIZE))
	_apply_node_rect(nodes, "hero_card", HERO_CARD_RECT)
	_apply_node_rect(nodes, "hero_portrait", HERO_PORTRAIT_RECT)
	_apply_node_rect(nodes, "vitals_panel", VITALS_PANEL_RECT)
	_apply_node_rect(nodes, "vitals_frame", VITALS_FRAME_RECT)
	_apply_node_rect(nodes, "hp_bar", PLAYER_HP_BAR_RECT)
	_apply_node_rect(nodes, "hp_label", PLAYER_HP_BAR_RECT)
	_apply_node_rect(nodes, "armor_bar", PLAYER_ARMOR_BAR_RECT)
	_apply_node_rect(nodes, "armor_label", PLAYER_ARMOR_BAR_RECT)
	_apply_node_rect(nodes, "armor_badge", ARMOR_BADGE_RECT)
	_apply_node_min_size(nodes, "armor_badge_label", ARMOR_BADGE_RECT.size)
	_apply_node_rect(nodes, "loadout_frame", PLAYER_LOADOUT_RECT)
	_apply_node_rect(nodes, "loadout_root", Rect2(Vector2.ZERO, PLAYER_LOADOUT_RECT.size))
	_apply_node_rect(nodes, "equipment_label", EQUIPMENT_LABEL_RECT)
	_apply_node_rect(nodes, "consumable_label", CONSUMABLE_LABEL_RECT)
	_apply_node_rect(nodes, "equipment_icons", EQUIPMENT_RAIL_RECT)
	_apply_node_rect(nodes, "consumable_icons", CONSUMABLE_RAIL_RECT)
	_apply_node_rect(nodes, "mastery_strip", PLAYER_MASTERY_RECT)
	_apply_node_rect(nodes, "mastery_root", MASTERY_ROOT_RECT)
	_apply_node_rect(nodes, "mastery_label", MASTERY_LABEL_RECT)
	_apply_node_rect(nodes, "mastery_icons", MASTERY_ICONS_RECT)


func lookup_content_definition(content_id: String) -> Dictionary:
	var registry = RunState.ensure_content_registry()
	var value: Dictionary = registry.get_equipment(content_id)
	if not value.is_empty():
		return value
	value = registry.get_consumable(content_id)
	if not value.is_empty():
		return value
	value = registry.get_relic(content_id)
	if not value.is_empty():
		return value
	value = registry.get_mastery_card(content_id)
	if not value.is_empty():
		return value
	value = registry.get_booster(content_id)
	if not value.is_empty():
		return value
	return {
		"display_name": content_id,
		"description": "",
		"icon_key": "",
	}


func _make_slot(index: int, filled: bool, selectable: bool) -> Control:
	if selectable:
		var button := Button.new()
		button.text = ""
		button.size = SLOT_SIZE
		button.custom_minimum_size = SLOT_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = not filled
		var selected := index == _selected_equipment_slot
		button.add_theme_stylebox_override("normal", _slot_stylebox(selected, not filled))
		button.add_theme_stylebox_override("hover", _slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("pressed", _slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("disabled", _slot_stylebox(selected, not filled))
		if filled:
			button.pressed.connect(_on_equipment_slot_pressed.bind(index))
		return button

	var panel := PanelContainer.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.size = SLOT_SIZE
	panel.add_theme_stylebox_override("panel", _slot_stylebox(false, not filled))
	return panel


func _on_equipment_slot_pressed(index: int) -> void:
	_selected_equipment_slot = index
	equipment_slot_selected.emit(index)


func _make_badge_label(text: String, slot_size: Vector2) -> Label:
	var amount_label := Label.new()
	amount_label.name = "SlotBadge"
	amount_label.text = text
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	amount_label.add_theme_font_size_override("font_size", 19)
	amount_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.34, 1.0))
	amount_label.add_theme_constant_override("outline_size", 3)
	amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
	amount_label.position = Vector2.ZERO
	amount_label.size = slot_size
	amount_label.anchors_preset = Control.PRESET_FULL_RECT
	return amount_label


func _badge_text_for(label: String, content: Dictionary) -> String:
	if label == "equipment":
		return _equipment_badge_text(content)
	if label == "consumable":
		return "1"
	return ""


func _equipment_badge_text(content: Dictionary) -> String:
	var modifiers: Dictionary = content.get("combat_modifiers", {})
	if int(modifiers.get("flat_damage_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_damage_bonus", 0))
	if int(modifiers.get("start_turn_armor", 0)) != 0:
		return "+%d" % int(modifiers.get("start_turn_armor", 0))
	if int(modifiers.get("flat_heal_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_heal_bonus", 0))
	if int(modifiers.get("flat_gold_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_gold_bonus", 0))
	var orb_bonus_by_id: Dictionary = modifiers.get("orb_bonus_by_id", {})
	for value in orb_bonus_by_id.values():
		if int(value) != 0:
			return "+%d" % int(value)
	if int(modifiers.get("combo_flat_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("combo_flat_bonus", 0))
	var combo_mult := float(modifiers.get("combo_multiplier_mult", 1.0))
	if not is_equal_approx(combo_mult, 1.0):
		return "x%.1f" % combo_mult
	return ""


func _slot_tooltip(content: Dictionary, fallback_id: String) -> String:
	var display_name := String(content.get("display_name", fallback_id))
	var description := String(content.get("description", ""))
	return display_name if description == "" else "%s\n%s" % [display_name, description]


func _slot_stylebox(selected: bool = false, empty: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if empty:
		style.bg_color = Color(0.03, 0.05, 0.08, 0.98)
		style.border_color = Color(0.21, 0.26, 0.34, 0.90)
	elif selected:
		style.bg_color = Color(0.16, 0.11, 0.05, 0.98)
		style.border_color = Color(0.95, 0.70, 0.25, 1.0)
	else:
		style.bg_color = Color(0.10, 0.08, 0.13, 0.98)
		style.border_color = Color(0.68, 0.49, 0.23, 0.94)
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 5.0
	style.content_margin_right = 5.0
	style.content_margin_top = 5.0
	style.content_margin_bottom = 5.0
	return style


func _empty_slot_silhouette(label: String) -> Texture2D:
	var key := "%s_empty_silhouette" % label
	if _empty_silhouette_cache.has(key):
		return _empty_silhouette_cache[key]
	var base := Color(0.00, 0.00, 0.00, 0.0)
	var tone := Color(0.56, 0.62, 0.72, 0.82)
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(base)
	if label == "equipment":
		image.fill_rect(Rect2i(45, 16, 6, 46), tone)
		image.fill_rect(Rect2i(34, 46, 28, 8), tone)
		image.fill_rect(Rect2i(36, 54, 24, 10), Color(tone.r, tone.g, tone.b, 0.58))
		image.fill_rect(Rect2i(42, 62, 12, 14), Color(tone.r, tone.g, tone.b, 0.52))
	elif label == "consumable":
		image.fill_rect(Rect2i(34, 18, 28, 12), tone)
		image.fill_rect(Rect2i(38, 30, 20, 10), Color(tone.r, tone.g, tone.b, 0.70))
		image.fill_rect(Rect2i(31, 40, 34, 36), Color(tone.r, tone.g, tone.b, 0.62))
		image.fill_rect(Rect2i(42, 52, 12, 12), Color(tone.r, tone.g, tone.b, 0.34))
	else:
		image.fill_rect(Rect2i(30, 30, 36, 36), tone)
	var texture := ImageTexture.create_from_image(image)
	_empty_silhouette_cache[key] = texture
	return texture


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size


func _apply_node_rect(nodes: Dictionary, key: String, rect: Rect2) -> void:
	var control := nodes.get(key, null) as Control
	_apply_rect(control, rect)


func _apply_node_min_size(nodes: Dictionary, key: String, size: Vector2) -> void:
	var control := nodes.get(key, null) as Control
	if control == null:
		return
	control.custom_minimum_size = size
