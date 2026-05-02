extends RefCounted
class_name PlayerLoadoutHud

signal equipment_slot_selected(slot_index: int)
signal consumable_slot_selected(slot_index: int)
signal slot_hover_started(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2)
signal slot_hover_ended()

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")

const ICON_INNER_SIZE := Vector2(74, 74)
const SLOT_SIZE := Vector2(88, 88)
const SLOT_GAP := 8.0
const MASTERY_ICON_INNER_SIZE := Vector2(34, 34)
const MASTERY_SLOT_SIZE := Vector2(44, 44)
const MASTERY_CELL_WIDTH := 92.0
const MASTERY_CELL_GAP := 24.0
const COMBAT_MASTERY_CARD_SIZE := Vector2(132, 104)
const COMBAT_MASTERY_CARD_GAP := 14.0
const COMBAT_MASTERY_ICON_SIZE := Vector2(46, 46)
const COMBAT_MASTERY_ORDER: Array[int] = [
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
]
const RELIC_SLOT_SIZE := Vector2(58, 58)
const RELIC_ICON_SIZE := Vector2(48, 48)
const RELIC_SLOT_GAP := 8.0
const PLAYER_HUD_SECTION_RECT := Rect2(Vector2(0, 1092), Vector2(1080, 828))
const PLAYER_HUD_MASTERY_PANEL_RECT := Rect2(Vector2(16, 0), Vector2(1048, 172))
const PLAYER_HUD_MASTERY_TITLE_RECT := Rect2(Vector2(0, 8), Vector2(1048, 32))
const PLAYER_HUD_MASTERY_CARDS_RECT := Rect2(Vector2(0, 48), Vector2(1048, 108))
const PLAYER_HUD_FOOTER_PANEL_RECT := Rect2(Vector2(0, 188), Vector2(1080, 640))
const COMBAT_PLAYER_PANEL_SIZE := Vector2(1080, 640)
const HERO_CARD_RECT := Rect2(Vector2(42, 32), Vector2(220, 246))
const HERO_PORTRAIT_RECT := Rect2(Vector2(16, 16), Vector2(188, 214))
const VITALS_PANEL_RECT := Rect2(Vector2(294, 50), Vector2(714, 196))
const VITALS_FRAME_RECT := Rect2(Vector2.ZERO, Vector2(714, 196))
const PLAYER_HP_BAR_RECT := Rect2(Vector2(18, 62), Vector2(678, 54))
const PLAYER_ARMOR_BAR_RECT := Rect2(Vector2(18, 112), Vector2(434, 34))
const ARMOR_BADGE_RECT := Rect2(Vector2(474, 112), Vector2(222, 34))
const PLAYER_LOADOUT_RECT := Rect2(Vector2(42, 258), Vector2(996, 228))
const PLAYER_MASTERY_RECT := Rect2(Vector2(42, 404), Vector2(996, 50))
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(518, 136), Vector2(280, 88))
const FOOTER_RELIC_RAIL_RECT := Rect2(Vector2(390, 30), Vector2(216, 58))
const EQUIPMENT_LABEL_RECT := Rect2(Vector2(118, 108), Vector2(296, 22))
const CONSUMABLE_LABEL_RECT := Rect2(Vector2(514, 108), Vector2(288, 22))
const FOOTER_RELIC_LABEL_RECT := Rect2(Vector2(390, 6), Vector2(216, 22))
const MASTERY_ROOT_RECT := Rect2(Vector2(16, 2), Vector2(964, 46))
const MASTERY_LABEL_RECT := Rect2(Vector2.ZERO, Vector2(120, 46))
const MASTERY_ICONS_RECT := Rect2(Vector2(172, 2), Vector2(720, MASTERY_SLOT_SIZE.y))
const COMBAT_MASTERY_ROOT_RECT := Rect2(Vector2.ZERO, Vector2(1048, 108))

var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _selected_equipment_slot := -1
var _selected_consumable_slot := -1
var _empty_silhouette_cache: Dictionary = {}


func set_selected_equipment_slot(slot_index: int) -> void:
	_selected_equipment_slot = slot_index


func set_selected_consumable_slot(slot_index: int) -> void:
	_selected_consumable_slot = slot_index


func populate_loadout_slot_row(row: Control, ids: Array, label: String, slot_count: int, selectable_label: String = "") -> void:
	var visible_ids: Array = []
	for index in range(slot_count):
		visible_ids.append(ids[index] if index < ids.size() else "")
	populate_icon_row(row, visible_ids, label, selectable_label)


func populate_icon_row(row: Control, ids: Array, label: String, selectable_label: String = "") -> void:
	_clear_children(row)
	for index in range(ids.size()):
		var id_text := String(ids[index])
		var filled := id_text != ""
		var slot := _make_slot(index, filled, label, selectable_label)
		slot.name = "%sSlot%d" % [label.capitalize(), index]
		slot.position = Vector2(float(index) * (SLOT_SIZE.x + SLOT_GAP), 0.0)
		var content: Dictionary = {}

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
			content = lookup_content_definition(id_text)
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
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot, label, index, content, id_text, filled))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
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


func get_combat_mastery_card(row: Control, orb_id: int) -> Control:
	if row == null:
		return null
	var card_name := _combat_mastery_card_name(orb_id)
	for child in row.get_children():
		if child.name == card_name:
			return child as Control
	return null


func populate_combat_mastery_panel(row: Control, mastery_levels: Dictionary, feedback_totals: Dictionary = {}) -> void:
	_clear_children(row)
	var row_width := row.size.x if row.size.x > 0.0 else COMBAT_MASTERY_ROOT_RECT.size.x
	var total_cards_width := COMBAT_MASTERY_CARD_SIZE.x * float(COMBAT_MASTERY_ORDER.size())
	total_cards_width += COMBAT_MASTERY_CARD_GAP * float(COMBAT_MASTERY_ORDER.size() - 1)
	var start_x := maxf(0.0, (row_width - total_cards_width) * 0.5)
	for index in range(COMBAT_MASTERY_ORDER.size()):
		var orb_id: int = COMBAT_MASTERY_ORDER[index]
		var level := int(mastery_levels.get(orb_id, 0))
		var feedback_value := int(feedback_totals.get(orb_id, 0))

		var card := Control.new()
		card.name = _combat_mastery_card_name(orb_id)
		card.clip_contents = true
		card.size = COMBAT_MASTERY_CARD_SIZE
		card.position = Vector2(start_x + float(index) * (COMBAT_MASTERY_CARD_SIZE.x + COMBAT_MASTERY_CARD_GAP), 0.0)

		var panel := Panel.new()
		panel.name = "CardPanel"
		panel.custom_minimum_size = COMBAT_MASTERY_CARD_SIZE
		panel.size = COMBAT_MASTERY_CARD_SIZE
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override("panel", _combat_mastery_card_stylebox(orb_id))

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.custom_minimum_size = COMBAT_MASTERY_ICON_SIZE
		icon.size = COMBAT_MASTERY_ICON_SIZE
		icon.position = Vector2((COMBAT_MASTERY_CARD_SIZE.x - COMBAT_MASTERY_ICON_SIZE.x) * 0.5, 8.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _visuals.menu_mastery_icon(orb_id)
		icon.tooltip_text = "%s Mastery" % OrbType.display_name(orb_id)

		var name_label := Label.new()
		name_label.name = "MasteryLabel"
		name_label.text = OrbType.display_name(orb_id)
		name_label.position = Vector2(8.0, 56.0)
		name_label.size = Vector2(116.0, 22.0)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96, 1.0))
		name_label.add_theme_constant_override("outline_size", 1)
		name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.92))

		var level_label := Label.new()
		level_label.name = "MasteryLevel"
		level_label.text = "Lv %d" % level
		level_label.position = Vector2(8.0, 76.0)
		level_label.size = Vector2(116.0, 18.0)
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.add_theme_font_size_override("font_size", 14)
		level_label.add_theme_color_override("font_color", Color(0.70, 0.76, 0.84, 1.0))
		level_label.add_theme_constant_override("outline_size", 1)
		level_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.92))
		level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var feedback_label := Label.new()
		feedback_label.name = "MasteryFeedback"
		feedback_label.text = _combat_mastery_feedback_text(orb_id, feedback_value)
		feedback_label.position = Vector2(4.0, 78.0)
		feedback_label.size = Vector2(124.0, 22.0)
		feedback_label.add_theme_font_size_override("font_size", 13)
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.90, 0.50, 0.86))
		feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		feedback_label.add_theme_constant_override("outline_size", 2)
		feedback_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.98))
		if feedback_value > 0:
			feedback_label.modulate = Color(1.0, 0.95, 0.66, 1.0)
			feedback_label.visible = true
		else:
			feedback_label.visible = false
			feedback_label.modulate = Color(1.0, 1.0, 1.0, 0.38)

		panel.add_child(icon)
		panel.add_child(name_label)
		panel.add_child(level_label)
		panel.add_child(feedback_label)
		card.add_child(panel)
		row.add_child(card)


func clear_combat_mastery_feedback(row: Control) -> void:
	for orb_id in OrbType.ALL_TYPES:
		set_combat_mastery_feedback(row, int(orb_id), 0)


func set_combat_mastery_feedback(row: Control, orb_id: int, feedback_value: int) -> void:
	if not OrbType.is_valid_id(orb_id):
		return
	var card: Control = get_combat_mastery_card(row, orb_id)
	if card == null:
		return
	var panel: Control = card.get_node_or_null("CardPanel") as Control
	if panel == null:
		return
	var feedback_label: Label = panel.get_node_or_null("MasteryFeedback") as Label
	if feedback_label == null:
		return
	var feedback_text := _combat_mastery_feedback_text(orb_id, feedback_value)
	feedback_label.text = feedback_text
	feedback_label.visible = feedback_text != ""
	feedback_label.modulate = Color(1.0, 0.95, 0.66, 1.0) if feedback_label.visible else Color(1.0, 1.0, 1.0, 0.38)


func _combat_mastery_feedback_text(orb_id: int, value: int) -> String:
	if value <= 0:
		return ""
	var feedback_kind: String = ""
	match orb_id:
		OrbType.Id.FIRE:
			feedback_kind = "DAMAGE"
		OrbType.Id.ICE:
			feedback_kind = "DAMAGE"
		OrbType.Id.EARTH:
			feedback_kind = "DAMAGE"
		OrbType.Id.HEART:
			feedback_kind = "HEAL"
		OrbType.Id.ARMOR:
			feedback_kind = "ARMOR"
		OrbType.Id.GOLD:
			feedback_kind = "GOLD"
		_:
			return ""
	return "+%d %s" % [value, feedback_kind]


func _combat_mastery_card_stylebox(orb_id: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := OrbType.color(orb_id)
	style.bg_color = Color(0.035, 0.055, 0.08, 0.96)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.58)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style


func _combat_mastery_card_name(orb_id: int) -> String:
	return "CombatMasteryCard%d" % orb_id


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
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot, "relic", index, content, relic_id, true))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
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


func apply_player_hud_layout(nodes: Dictionary) -> void:
	_apply_node_rect(nodes, "section", PLAYER_HUD_SECTION_RECT)
	_apply_node_rect(nodes, "mastery_panel", PLAYER_HUD_MASTERY_PANEL_RECT)
	_apply_node_rect(nodes, "mastery_title", PLAYER_HUD_MASTERY_TITLE_RECT)
	_apply_node_rect(nodes, "mastery_cards", PLAYER_HUD_MASTERY_CARDS_RECT)
	_apply_node_rect(nodes, "footer_panel", PLAYER_HUD_FOOTER_PANEL_RECT)
	apply_player_footer_layout(nodes)


func apply_player_hud_chrome(nodes: Dictionary) -> void:
	_apply_node_stylebox(nodes, "section", _hud_section_stylebox())
	_apply_node_stylebox(nodes, "mastery_panel", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "footer_panel", StyleBoxEmpty.new())
	_apply_node_stylebox(nodes, "hero_card", _hud_inner_panel_stylebox())
	_apply_node_stylebox(nodes, "vitals_frame", _hud_vitals_stylebox())
	_apply_node_stylebox(nodes, "loadout_frame", _hud_inner_panel_stylebox())
	_apply_progressbar_flat_style(nodes.get("hp_bar") as ProgressBar, Color(0.78, 0.16, 0.17, 1.0))
	_apply_hud_label_style(nodes.get("mastery_title") as Label, Color(0.78, 0.84, 0.90, 1.0), 22)
	_apply_hud_label_style(nodes.get("hp_label") as Label, Color(0.95, 0.96, 0.98, 1.0), 24)
	_apply_hud_label_style(nodes.get("equipment_label") as Label, Color(0.67, 0.73, 0.80, 1.0), 18)
	_apply_hud_label_style(nodes.get("consumable_label") as Label, Color(0.67, 0.73, 0.80, 1.0), 18)
	_apply_hud_label_style(nodes.get("relic_label") as Label, Color(0.67, 0.73, 0.80, 1.0), 18)


func apply_player_footer_layout(nodes: Dictionary) -> void:
	if nodes.has("footer_root"):
		_apply_node_rect(nodes, "footer_root", Rect2(Vector2.ZERO, COMBAT_PLAYER_PANEL_SIZE))
	else:
		_apply_node_rect(nodes, "root", Rect2(Vector2.ZERO, COMBAT_PLAYER_PANEL_SIZE))
	_apply_node_rect(nodes, "hero_card", HERO_CARD_RECT)
	_apply_node_rect(nodes, "hero_card_root", Rect2(Vector2.ZERO, HERO_CARD_RECT.size))
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
	_apply_node_rect(nodes, "relic_label", FOOTER_RELIC_LABEL_RECT)
	_apply_node_rect(nodes, "equipment_icons", EQUIPMENT_RAIL_RECT)
	_apply_node_rect(nodes, "consumable_icons", CONSUMABLE_RAIL_RECT)
	_apply_node_rect(nodes, "relic_icons", FOOTER_RELIC_RAIL_RECT)
	_apply_node_rect(nodes, "mastery_strip", PLAYER_MASTERY_RECT)
	_apply_node_rect(nodes, "mastery_root", MASTERY_ROOT_RECT)
	_apply_node_rect(nodes, "mastery_label", MASTERY_LABEL_RECT)
	_apply_node_rect(nodes, "mastery_icons", MASTERY_ICONS_RECT)


func apply_combat_player_panel_layout(nodes: Dictionary) -> void:
	apply_player_footer_layout(nodes)


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


func _hud_section_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.045, 0.07, 0.94)
	style.border_color = Color(0.18, 0.24, 0.31, 0.90)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _hud_inner_panel_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.12, 0.98)
	style.border_color = Color(0.18, 0.24, 0.31, 0.95)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _hud_vitals_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.08, 0.13, 0.98)
	style.border_color = Color(0.18, 0.25, 0.34, 0.96)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	return style


func _apply_progressbar_flat_style(bar: ProgressBar, fill_color: Color) -> void:
	if bar == null:
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.04, 0.07, 0.10, 0.95)
	bg.set_corner_radius_all(4)
	bg.set_border_width_all(1)
	bg.border_color = Color(0.18, 0.25, 0.34, 0.85)
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


func _apply_hud_label_style(label: Label, color: Color, font_size: int) -> void:
	if label == null:
		return
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 1)
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.04, 0.92))


func _make_slot(index: int, filled: bool, slot_label: String, selectable_label: String = "") -> Control:
	var selectable := selectable_label != "" and slot_label == selectable_label
	if selectable:
		var button := Button.new()
		button.text = ""
		button.size = SLOT_SIZE
		button.custom_minimum_size = SLOT_SIZE
		button.focus_mode = Control.FOCUS_NONE
		button.disabled = not filled
		var selected := false
		if slot_label == "equipment":
			selected = index == _selected_equipment_slot
		elif slot_label == "consumable":
			selected = index == _selected_consumable_slot
		button.add_theme_stylebox_override("normal", _slot_stylebox(selected, not filled))
		button.add_theme_stylebox_override("hover", _slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("pressed", _slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("disabled", _slot_stylebox(selected, not filled))
		if filled:
			if slot_label == "equipment":
				button.pressed.connect(_on_equipment_slot_pressed.bind(index))
			elif slot_label == "consumable":
				button.pressed.connect(_on_consumable_slot_pressed.bind(index))
		return button

	var panel := PanelContainer.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.size = SLOT_SIZE
	panel.add_theme_stylebox_override("panel", _slot_stylebox(false, not filled))
	return panel


func _on_equipment_slot_pressed(index: int) -> void:
	_selected_equipment_slot = index
	_selected_consumable_slot = -1
	equipment_slot_selected.emit(index)


func _on_consumable_slot_pressed(index: int) -> void:
	_selected_consumable_slot = index
	_selected_equipment_slot = -1
	consumable_slot_selected.emit(index)


func _on_slot_mouse_entered(slot: Control, slot_type: String, slot_index: int, content: Dictionary, fallback_id: String, filled: bool) -> void:
	if slot == null:
		return
	var title := "Empty %s slot" % slot_type
	var description := ""
	if filled:
		title = String(content.get("display_name", fallback_id))
		description = String(content.get("description", ""))
	slot_hover_started.emit(slot_type, slot_index, title, description, slot.get_global_rect())


func _on_slot_mouse_exited() -> void:
	slot_hover_ended.emit()


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


func _apply_node_stylebox(nodes: Dictionary, key: String, stylebox: StyleBox) -> void:
	var control := nodes.get(key, null) as Control
	if control == null:
		return
	control.add_theme_stylebox_override("panel", stylebox)


func _apply_node_min_size(nodes: Dictionary, key: String, size: Vector2) -> void:
	var control := nodes.get(key, null) as Control
	if control == null:
		return
	control.custom_minimum_size = size
