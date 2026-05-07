extends RefCounted
class_name PlayerLoadoutHud

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

signal equipment_slot_selected(slot_index: int)
signal consumable_slot_selected(slot_index: int)
signal sell_slot_requested(slot_type: String, slot_index: int)
signal slot_hover_started(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2)
signal slot_hover_ended()
signal intent_preview_hovered(preview: Dictionary)
signal intent_block_preview_hovered(preview: Dictionary)
signal intent_preview_hover_ended()

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")

const ICON_INNER_SIZE := Vector2(84, 84)
const SLOT_SIZE := Vector2(98, 98)
const SLOT_GAP := 10.0
const MASTERY_ICON_INNER_SIZE := Vector2(34, 34)
const MASTERY_SLOT_SIZE := Vector2(44, 44)
const MASTERY_CELL_WIDTH := 92.0
const MASTERY_CELL_GAP := 24.0
const COMBAT_MASTERY_CARD_SIZE := Vector2(170, 102)
const COMBAT_MASTERY_CARD_GAP := 2.0
const COMBAT_MASTERY_ICON_SIZE := Vector2(82, 82)
const COMBAT_MASTERY_COMPACT_CARD_SIZE := Vector2(102, 76)
const COMBAT_MASTERY_COMPACT_CARD_GAP := 2.0
const COMBAT_MASTERY_COMPACT_ICON_SIZE := Vector2(58, 58)
const COMBAT_MASTERY_ACTIVATION_BASE_ALPHA := 0.14
const COMBAT_MASTERY_ACTIVATION_ALPHA_STEP := 0.08
const COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS := 0.24
const COMBAT_MASTERY_HOVER_ALPHA := 0.20
const COMBAT_MASTERY_HOVER_BORDER_ALPHA := 0.90
const MASTERY_SOURCE_HIGHLIGHT_ALPHA := 0.22
const MASTERY_SOURCE_HIGHLIGHT_BORDER_ALPHA := 0.94
const COMBAT_MASTERY_ORDER: Array[int] = [
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
]
const RELIC_SLOT_SIZE := Vector2(64, 64)
const RELIC_ICON_SIZE := Vector2(54, 54)
const RELIC_SLOT_GAP := 10.0
const PLAYER_HUD_SECTION_RECT := Rect2(Vector2(0, 1428), Vector2(1080, 492))
const PLAYER_HUD_MASTERY_PANEL_RECT := Rect2(Vector2(16, 0), Vector2(1048, 160))
const PLAYER_HUD_MASTERY_TITLE_RECT := Rect2(Vector2(0, 6), Vector2(1048, 50))
const PLAYER_HUD_MASTERY_CARDS_RECT := Rect2(Vector2(0, 58), Vector2(1048, 102))
const PLAYER_HUD_FOOTER_PANEL_RECT := Rect2(Vector2(0, 168), Vector2(1080, 324))
const SHOP_PLAYER_HUD_LAYOUT_PRESET := {
	"section": PLAYER_HUD_SECTION_RECT,
}
const COMBAT_PLAYER_PANEL_SIZE := Vector2(1080, 640)
const COMPACT_COMBAT_PLAYER_PANEL_SIZE := Vector2(1080, 336)
const HERO_CARD_RECT := Rect2(Vector2(42, 32), Vector2(220, 246))
const HERO_PORTRAIT_RECT := Rect2(Vector2(16, 16), Vector2(188, 214))
const VITALS_PANEL_RECT := Rect2(Vector2(294, 50), Vector2(714, 196))
const VITALS_FRAME_RECT := Rect2(Vector2.ZERO, Vector2(714, 196))
const PLAYER_HP_BAR_RECT := Rect2(Vector2(18, 62), Vector2(678, 54))
const PLAYER_ARMOR_BAR_RECT := Rect2(Vector2(18, 112), Vector2(434, 34))
const ARMOR_BADGE_RECT := Rect2(Vector2(474, 112), Vector2(222, 34))
const PLAYER_LOADOUT_RECT := Rect2(Vector2(42, 258), Vector2(996, 228))
const PLAYER_MASTERY_RECT := Rect2(Vector2(42, 404), Vector2(996, 50))
const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 130), Vector2(526, 94))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(660, 130), Vector2(314, 94))
const VITALS_RELIC_ICONS_RECT := Rect2(Vector2(308, 132), Vector2(390, 58))
const RELIC_LABEL_RECT := Rect2(Vector2(308, 104), Vector2(390, 24))
const EQUIPMENT_LABEL_RECT := Rect2(Vector2(22, 102), Vector2(526, 22))
const CONSUMABLE_LABEL_RECT := Rect2(Vector2(660, 102), Vector2(314, 22))
const MASTERY_ROOT_RECT := Rect2(Vector2(16, 2), Vector2(964, 46))
const MASTERY_LABEL_RECT := Rect2(Vector2.ZERO, Vector2(120, 46))
const MASTERY_ICONS_RECT := Rect2(Vector2(172, 2), Vector2(720, MASTERY_SLOT_SIZE.y))
const COMPACT_HERO_CARD_RECT := Rect2(Vector2(16, 12), Vector2(200, 152))
const COMPACT_HERO_PORTRAIT_RECT := Rect2(Vector2(8, 8), Vector2(184, 136))
const COMPACT_VITALS_PANEL_RECT := Rect2(Vector2(228, 12), Vector2(836, 152))
const COMPACT_VITALS_FRAME_RECT := Rect2(Vector2.ZERO, Vector2(836, 152))
const COMPACT_PLAYER_HP_BAR_RECT := Rect2(Vector2(14, 16), Vector2(806, 58))
const COMPACT_PLAYER_ARMOR_BAR_RECT := Rect2(Vector2.ZERO, Vector2.ZERO)
const COMPACT_ARMOR_BADGE_RECT := Rect2(Vector2.ZERO, Vector2.ZERO)
const COMPACT_PLAYER_LOADOUT_RECT := Rect2(Vector2(16, 168), Vector2(1048, 156))
const COMPACT_EQUIPMENT_LABEL_RECT := Rect2(Vector2(20, 4), Vector2(540, 24))
const COMPACT_CONSUMABLE_LABEL_RECT := Rect2(Vector2(714, 4), Vector2(314, 24))
const COMPACT_EQUIPMENT_RAIL_RECT := Rect2(Vector2(20, 34), Vector2(540, 106))
const COMPACT_CONSUMABLE_RAIL_RECT := Rect2(Vector2(714, 34), Vector2(314, 106))
const COMPACT_RELIC_LABEL_RECT := Rect2(Vector2(20, 101), Vector2(98, 24))
const COMPACT_VITALS_RELIC_ICONS_RECT := Rect2(Vector2(126, 82), Vector2(402, 64))
const COMPACT_PLAYER_MASTERY_RECT := Rect2(Vector2(16, 286), Vector2(1048, 44))
const COMPACT_MASTERY_ROOT_RECT := Rect2(Vector2(0, 0), Vector2(1048, 44))
const COMPACT_MASTERY_LABEL_RECT := Rect2(Vector2.ZERO, Vector2(100, 44))
const COMPACT_MASTERY_ICONS_RECT := Rect2(Vector2(116, 0), Vector2(724, MASTERY_SLOT_SIZE.y))
const COMBAT_MASTERY_ROOT_RECT := Rect2(Vector2.ZERO, Vector2(1048, 108))
const SLOT_DETAIL_BUBBLE_MIN_WIDTH := 440.0
const SLOT_DETAIL_BUBBLE_MAX_WIDTH := 640.0
const SLOT_DETAIL_BUBBLE_MIN_HEIGHT := 144.0
const SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN := 10.0
const SLOT_DETAIL_BUBBLE_INTERNAL_PADDING := 16.0
const MASTERY_DETAIL_BUBBLE_SIZE := Vector2(960.0, 468.0)
const INTENT_PREVIEW_MIN_SEGMENT_WIDTH := 6.0
const INTENT_PREVIEW_PULSE_SECONDS := 0.52
const ARMOR_PREVIEW_PULSE_SECONDS := 0.84

var _visuals = null
var _selected_equipment_slot := -1
var _selected_consumable_slot := -1
var _empty_silhouette_cache: Dictionary = {}
var _hud_nodes: Dictionary = {}
var _player_data: Dictionary = {}
var _slot_detail_bubble: Panel
var _slot_detail_title: Label
var _slot_detail_description: Label
var _slot_detail_sell_button: Button
var _hover_slot_global_rect := Rect2()
var _hover_slot_type := ""
var _hover_slot_index := -1
var _hover_slot_title := ""
var _hover_slot_description := ""
var _layout_override: Dictionary = {}
var _intent_damage_preview: Dictionary = {}
var _player_armor_overshield_rect: ColorRect
var _intent_hp_danger_button: Button
var _intent_hp_danger_empty: ColorRect
var _intent_hp_danger_fill: ColorRect
var _intent_armor_risk_rect: ColorRect
var _intent_hp_danger_pulse_tween: Tween
var _intent_armor_risk_tween: Tween
var _hovered_mastery_orb_id := -1
var _mastery_hover_payload: Dictionary = {}
var _mastery_detail_bubble: Panel
var _mastery_detail_title: Label
var _mastery_detail_effect: Label
var _mastery_detail_value: Label
var _mastery_detail_modifiers: Label
var _mastery_detail_hovered_orb_id := -1
var _highlighted_mastery_source_ids: Dictionary = {}
var _hud_section_node: Node = null


func set_selected_equipment_slot(slot_index: int) -> void:
	_selected_equipment_slot = slot_index


func set_selected_consumable_slot(slot_index: int) -> void:
	_selected_consumable_slot = slot_index


func set_visual_registry(visuals: VisualRegistry) -> void:
	_visuals = visuals


func bind_player_hud(nodes: Dictionary) -> void:
	_disconnect_hud_lifecycle()
	_hud_nodes = nodes
	_connect_hud_lifecycle()
	_ensure_slot_detail_popover()
	_ensure_intent_damage_preview_nodes()
	apply_player_hud_chrome(_hud_nodes)
	_layout_intent_damage_preview()


func _connect_hud_lifecycle() -> void:
	var section := _hud_nodes.get("section", null) as Node
	if section == null:
		return
	_hud_section_node = section
	if not section.tree_exiting.is_connected(_on_hud_section_tree_exiting):
		section.tree_exiting.connect(_on_hud_section_tree_exiting)


func _disconnect_hud_lifecycle() -> void:
	if _hud_section_node == null or not is_instance_valid(_hud_section_node):
		_hud_section_node = null
		return
	if _hud_section_node.tree_exiting.is_connected(_on_hud_section_tree_exiting):
		_hud_section_node.tree_exiting.disconnect(_on_hud_section_tree_exiting)
	_hud_section_node = null


func _on_hud_section_tree_exiting() -> void:
	_cleanup_intent_preview_tweens()
	_hud_section_node = null


func _cleanup_intent_preview_tweens() -> void:
	_stop_intent_hp_danger_pulse()
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_tween = null
	if _intent_hp_danger_button != null and is_instance_valid(_intent_hp_danger_button):
		_intent_hp_danger_button.visible = false
	if _intent_hp_danger_empty != null and is_instance_valid(_intent_hp_danger_empty):
		_intent_hp_danger_empty.visible = false
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.visible = false
	if _intent_armor_risk_rect != null and is_instance_valid(_intent_armor_risk_rect):
		_intent_armor_risk_rect.visible = false
		_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_intent_armor_risk_rect.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_intent_damage_preview.clear()


func set_player_hud_layout_override(layout_override: Dictionary) -> void:
	_layout_override = layout_override.duplicate(true)


func clear_player_hud_layout_override() -> void:
	_layout_override.clear()


func load_player_data(player_data: Dictionary) -> void:
	_player_data = player_data.duplicate(true)
	_render_player_data()


func update_player_data(player_data: Dictionary) -> void:
	load_player_data(player_data)


func update_player_hud_layout() -> void:
	if _hud_nodes.is_empty():
		return
	apply_player_hud_layout(_hud_nodes, _layout_override)
	_update_slot_detail_bubble()
	_layout_mastery_detail_bubble()
	_layout_player_armor_overshield(_current_visible_armor())
	_layout_intent_damage_preview()


func handle_global_click(global_point: Vector2) -> bool:
	if not _has_inventory_focus():
		return false
	if _control_contains_point(_slot_detail_sell_button, global_point):
		_on_slot_detail_sell_pressed()
		return true
	if _is_inside_inventory_focus_area(global_point):
		return false
	hide_slot_detail_popover()
	_selected_equipment_slot = -1
	_selected_consumable_slot = -1
	return true


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
		var slot_y := maxf(0.0, (row.size.y - SLOT_SIZE.y) * 0.5)
		slot.position = Vector2(float(index) * (SLOT_SIZE.x + SLOT_GAP), slot_y)
		slot.set_meta("content_type", label)
		slot.set_meta("content_id", id_text)
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
			icon.texture = _visual_registry().clean_icon_for_key(icon_key)
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
		_add_mastery_source_highlight(slot, SLOT_SIZE)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot, label, index, content, id_text, filled))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
		row.add_child(slot)
	_apply_mastery_source_highlights()


func _render_player_data() -> void:
	if _hud_nodes.is_empty():
		return
	var player_state = _player_data.get("player_state", null)
	var progression_snapshot: Dictionary = _player_data.get("progression", {})
	var hero_portrait: Texture2D = _player_data.get("hero_portrait", null)
	var max_visible_relics := int(_player_data.get("max_visible_relics", 2))
	var selectable_equipment := bool(_player_data.get("selectable_equipment", true))
	var selectable_consumables := bool(_player_data.get("selectable_consumables", true))
	var display_values: Dictionary = _player_data.get("display_values", {})

	var hp_bar := _hud_nodes.get("hp_bar") as ProgressBar
	var hp_label := _hud_nodes.get("hp_label") as Label
	var current_armor := int(display_values.get("current_armor", 0))
	if player_state != null:
		var current_hp := int(display_values.get("current_hp", int(player_state.current_hp)))
		var max_hp := int(player_state.max_hp)
		current_armor = int(display_values.get("current_armor", int(player_state.armor)))
		if hp_bar != null:
			hp_bar.max_value = float(maxi(1, max_hp))
			hp_bar.value = float(maxi(0, current_hp))
		if hp_label != null:
			hp_label.text = "HP %d / %d" % [current_hp, max_hp]
	_layout_player_armor_overshield(maxi(0, current_armor))
	_sync_intent_damage_preview(Dictionary(_player_data.get("intent_damage_preview", {})))

	var hero := _hud_nodes.get("hero_portrait") as TextureRect
	if hero != null and hero_portrait != null:
		hero.texture = hero_portrait

	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	_selected_equipment_slot = _validated_slot_index(_selected_equipment_slot, equipment_slots)
	_selected_consumable_slot = _validated_slot_index(_selected_consumable_slot, consumable_slots)

	var equipment_row := _hud_nodes.get("equipment_icons") as Control
	if equipment_row != null:
		populate_loadout_slot_row(equipment_row, equipment_slots, "equipment", 5, "equipment" if selectable_equipment else "")
	var consumable_row := _hud_nodes.get("consumable_icons") as Control
	if consumable_row != null:
		populate_loadout_slot_row(consumable_row, consumable_slots, "consumable", 3, "consumable" if selectable_consumables else "")
	var relic_row := _hud_nodes.get("relic_icons") as Control
	if relic_row != null:
		populate_relic_row(relic_row, Array(progression_snapshot.get("relic_ids", [])), max_visible_relics)
	var mastery_cards := _hud_nodes.get("mastery_cards") as Control
	if mastery_cards != null:
		populate_combat_mastery_panel(
			mastery_cards,
			Dictionary(progression_snapshot.get("mastery_levels", {})),
			Dictionary(_player_data.get("combat_mastery_feedback_totals", {}))
		)
	_sync_combat_mastery_hover_payload(Dictionary(_player_data.get("combat_mastery_hover_payload", {})))
	_suppress_native_slot_tooltips()
	_update_selected_slot_popover()


func _validated_slot_index(slot_index: int, slots: Array) -> int:
	if slot_index < 0 or slot_index >= slots.size():
		return -1
	return slot_index if String(slots[slot_index]) != "" else -1


func _suppress_native_slot_tooltips() -> void:
	for key in ["equipment_icons", "consumable_icons", "relic_icons"]:
		var row := _hud_nodes.get(key) as Control
		if row == null:
			continue
		for child in row.get_children():
			if child is Control:
				(child as Control).tooltip_text = ""


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
		icon.texture = _visual_registry().mastery_icon(orb_id)
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


func populate_combat_mastery_panel(row: Control, _mastery_levels: Dictionary, feedback_totals: Dictionary = {}) -> void:
	_clear_children(row)
	var compact_mode := row.size.y > 0.0 and row.size.y <= 90.0
	var card_size := COMBAT_MASTERY_COMPACT_CARD_SIZE if compact_mode else COMBAT_MASTERY_CARD_SIZE
	var card_gap := COMBAT_MASTERY_COMPACT_CARD_GAP if compact_mode else COMBAT_MASTERY_CARD_GAP
	var icon_size := COMBAT_MASTERY_COMPACT_ICON_SIZE if compact_mode else COMBAT_MASTERY_ICON_SIZE
	var row_width := row.size.x if row.size.x > 0.0 else COMBAT_MASTERY_ROOT_RECT.size.x
	var total_cards_width := card_size.x * float(COMBAT_MASTERY_ORDER.size())
	total_cards_width += card_gap * float(COMBAT_MASTERY_ORDER.size() - 1)
	var start_x := maxf(0.0, (row_width - total_cards_width) * 0.5)
	for index in range(COMBAT_MASTERY_ORDER.size()):
		var orb_id: int = COMBAT_MASTERY_ORDER[index]
		var feedback_value := int(feedback_totals.get(orb_id, 0))

		var card := Control.new()
		card.name = _combat_mastery_card_name(orb_id)
		card.clip_contents = true
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.size = card_size
		card.position = Vector2(start_x + float(index) * (card_size.x + card_gap), 0.0)

		var panel := Panel.new()
		panel.name = "CardPanel"
		panel.custom_minimum_size = card_size
		panel.size = card_size
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_theme_stylebox_override("panel", _combat_mastery_card_stylebox(orb_id))

		var card_background := TextureRect.new()
		card_background.name = "CardTexture"
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_background.position = Vector2.ZERO
		card_background.size = card_size
		card_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_background.stretch_mode = TextureRect.STRETCH_SCALE
		card_background.texture = _visual_registry().mastery_card_texture(orb_id)
		card_background.modulate = Color(1.0, 1.0, 1.0, 0.18)

		var activation_glow := ColorRect.new()
		activation_glow.name = "ActivationGlow"
		activation_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		activation_glow.position = Vector2(4.0, 4.0)
		activation_glow.size = card_size - Vector2(8.0, 8.0)
		var activation_accent := OrbType.color(orb_id)
		activation_glow.color = Color(activation_accent.r, activation_accent.g, activation_accent.b, 0.0)
		activation_glow.visible = false

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.custom_minimum_size = icon_size
		icon.size = icon_size
		icon.position = Vector2((card_size.x - icon_size.x) * 0.5, 2.0 if compact_mode else 2.0)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = _visual_registry().menu_mastery_icon(orb_id)

		var feedback_label := Label.new()
		feedback_label.name = "MasteryFeedback"
		feedback_label.text = _combat_mastery_feedback_text_for_display(orb_id, feedback_value, compact_mode)
		feedback_label.position = Vector2(2.0, 58.0 if compact_mode else 82.0)
		feedback_label.size = Vector2(card_size.x - 4.0, 16.0 if compact_mode else 14.0)
		feedback_label.add_theme_font_size_override("font_size", 12 if compact_mode else 15)
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.58, 0.90))
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

		var activation_frame := Panel.new()
		activation_frame.name = "ActivationFrame"
		activation_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		activation_frame.position = Vector2.ZERO
		activation_frame.size = card_size
		activation_frame.visible = false

		var hover_highlight := ColorRect.new()
		hover_highlight.name = "HoverHighlight"
		hover_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hover_highlight.position = Vector2(2.0, 2.0)
		hover_highlight.size = card_size - Vector2(4.0, 4.0)
		hover_highlight.color = Color(1.0, 1.0, 1.0, 0.0)
		hover_highlight.visible = false

		var hover_frame := Panel.new()
		hover_frame.name = "HoverFrame"
		hover_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hover_frame.position = Vector2.ZERO
		hover_frame.size = card_size
		hover_frame.visible = false

		panel.add_child(card_background)
		panel.add_child(activation_glow)
		panel.add_child(icon)
		panel.add_child(feedback_label)
		panel.add_child(activation_frame)
		panel.add_child(hover_highlight)
		panel.add_child(hover_frame)
		card.add_child(panel)
		row.add_child(card)
		card.mouse_entered.connect(_on_combat_mastery_card_mouse_entered.bind(row, orb_id, card))
		card.mouse_exited.connect(_on_combat_mastery_card_mouse_exited.bind(row, orb_id))
		_apply_combat_mastery_activation(card, orb_id, feedback_value, false)
	_apply_hovered_combat_mastery(row)


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
	var compact_mode := card.size.y <= COMBAT_MASTERY_COMPACT_CARD_SIZE.y + 1.0
	var feedback_text := _combat_mastery_feedback_text_for_display(orb_id, feedback_value, compact_mode)
	feedback_label.text = feedback_text
	feedback_label.visible = feedback_text != ""
	feedback_label.modulate = Color(1.0, 0.95, 0.66, 1.0) if feedback_label.visible else Color(1.0, 1.0, 1.0, 0.38)
	_apply_combat_mastery_activation(card, orb_id, feedback_value, true)


func set_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_sync_combat_mastery_hover_payload(payload)


func set_hovered_combat_mastery(row: Control, orb_id: int) -> void:
	_hovered_mastery_orb_id = orb_id if OrbType.is_valid_id(orb_id) else -1
	_apply_hovered_combat_mastery(row)


func clear_hovered_combat_mastery(row: Control) -> void:
	_hovered_mastery_orb_id = -1
	_apply_hovered_combat_mastery(row)
	if _mastery_detail_hovered_orb_id < 0:
		_hide_mastery_detail()


func clear_combat_mastery_hover_ui(row: Control) -> void:
	_hovered_mastery_orb_id = -1
	_mastery_detail_hovered_orb_id = -1
	_apply_hovered_combat_mastery(row)
	_hide_mastery_detail()
	_clear_mastery_source_highlights()


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


func _combat_mastery_feedback_text_for_display(orb_id: int, value: int, compact_mode: bool) -> String:
	if not compact_mode:
		return _combat_mastery_feedback_text(orb_id, value)
	if value <= 0:
		return ""
	var feedback_kind := ""
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			feedback_kind = "DMG"
		OrbType.Id.HEART:
			feedback_kind = "HP"
		OrbType.Id.ARMOR:
			feedback_kind = "AR"
		OrbType.Id.GOLD:
			feedback_kind = "G"
		_:
			return ""
	return "+%d %s" % [value, feedback_kind]


func _combat_mastery_card_stylebox(orb_id: int, activation_tier: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := OrbType.color(orb_id)
	style.bg_color = Color(0.02, 0.05, 0.07, 0.70)
	var border_alpha := 0.42 + 0.10 * float(maxi(0, activation_tier))
	style.border_color = Color(accent.r, accent.g, accent.b, clampf(border_alpha, 0.0, 0.86))
	style.border_blend = true
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 1
	style.border_width_bottom = 1
	if activation_tier >= 2:
		style.border_width_right = 2
		style.border_width_bottom = 2
	style.set_corner_radius_all(4)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 3
	style.shadow_offset = Vector2(1.0, 2.0)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style


func _apply_combat_mastery_activation(card: Control, orb_id: int, feedback_value: int, animate: bool) -> void:
	if card == null:
		return
	var panel := card.get_node_or_null("CardPanel") as Control
	if panel == null:
		return
	var glow := panel.get_node_or_null("ActivationGlow") as ColorRect
	var frame := panel.get_node_or_null("ActivationFrame") as Panel
	var active := feedback_value > 0
	var tier := _combat_mastery_activation_tier(feedback_value)
	var accent := OrbType.color(orb_id)
	panel.add_theme_stylebox_override("panel", _combat_mastery_card_stylebox(orb_id, tier))
	if glow != null:
		glow.color = Color(accent.r, accent.g, accent.b, _combat_mastery_activation_alpha(tier) if active else 0.0)
		glow.visible = active
		glow.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if frame != null:
		frame.add_theme_stylebox_override("panel", _combat_mastery_activation_frame_stylebox(orb_id, tier))
		frame.visible = active
		frame.modulate = Color(1.0, 1.0, 1.0, 0.82 if active else 0.0)
	if active and animate:
		_pulse_combat_mastery_activation(glow, frame, tier)


func _combat_mastery_activation_tier(feedback_value: int) -> int:
	if feedback_value <= 0:
		return 0
	return clampi(int(ceil(float(feedback_value) / 5.0)), 1, 4)


func _combat_mastery_activation_alpha(tier: int) -> float:
	if tier <= 0:
		return 0.0
	return clampf(COMBAT_MASTERY_ACTIVATION_BASE_ALPHA + COMBAT_MASTERY_ACTIVATION_ALPHA_STEP * float(tier - 1), 0.0, 0.42)


func _pulse_combat_mastery_activation(glow: ColorRect, frame: Panel, tier: int) -> void:
	var target: Control = glow
	if target == null:
		target = frame
	if target == null or tier <= 0 or target.get_tree() == null:
		return
	var pulse_alpha := 0.16 + 0.05 * float(tier)
	var tween := target.create_tween()
	tween.set_parallel(true)
	if glow != null:
		var original_glow_alpha := glow.modulate.a
		tween.tween_property(glow, "modulate:a", minf(1.0, original_glow_alpha + pulse_alpha), COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)
		tween.tween_property(glow, "modulate:a", original_glow_alpha, COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS).set_delay(COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)
	if frame != null:
		var original_frame_alpha := frame.modulate.a
		tween.tween_property(frame, "modulate:a", minf(1.0, original_frame_alpha + pulse_alpha), COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)
		tween.tween_property(frame, "modulate:a", original_frame_alpha, COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS).set_delay(COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)


func _combat_mastery_activation_frame_stylebox(orb_id: int, tier: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := OrbType.color(orb_id)
	var strength := 0.42 + 0.10 * float(maxi(1, tier))
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.0)
	style.border_color = Color(accent.r, accent.g, accent.b, clampf(strength, 0.0, 0.88))
	style.set_border_width_all(1 + mini(2, maxi(0, tier - 1)))
	style.set_corner_radius_all(6)
	return style


func _combat_mastery_card_name(orb_id: int) -> String:
	return "CombatMasteryCard%d" % orb_id


func _sync_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_mastery_hover_payload = payload.duplicate(true)
	if _mastery_detail_hovered_orb_id >= 0:
		_show_mastery_detail(_mastery_detail_hovered_orb_id)
	else:
		_apply_mastery_source_highlights()


func _apply_hovered_combat_mastery(row: Control) -> void:
	if row == null:
		return
	for orb_id in COMBAT_MASTERY_ORDER:
		var card := get_combat_mastery_card(row, orb_id)
		if card == null:
			continue
		var panel := card.get_node_or_null("CardPanel") as Control
		if panel == null:
			continue
		var hover_highlight := panel.get_node_or_null("HoverHighlight") as ColorRect
		var hover_frame := panel.get_node_or_null("HoverFrame") as Panel
		var active := int(orb_id) == _hovered_mastery_orb_id
		if hover_highlight != null:
			var accent := OrbType.color(int(orb_id))
			hover_highlight.color = Color(accent.r, accent.g, accent.b, COMBAT_MASTERY_HOVER_ALPHA if active else 0.0)
			hover_highlight.visible = active
		if hover_frame != null:
			hover_frame.add_theme_stylebox_override("panel", _combat_mastery_hover_frame_stylebox(int(orb_id)))
			hover_frame.visible = active


func _combat_mastery_hover_frame_stylebox(orb_id: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := OrbType.color(orb_id)
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.0)
	style.border_color = Color(accent.r, accent.g, accent.b, COMBAT_MASTERY_HOVER_BORDER_ALPHA)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _on_combat_mastery_card_mouse_entered(row: Control, orb_id: int, card: Control) -> void:
	if not OrbType.is_valid_id(orb_id):
		return
	_mastery_detail_hovered_orb_id = orb_id
	set_hovered_combat_mastery(row, orb_id)
	_show_mastery_detail(orb_id, card)


func _on_combat_mastery_card_mouse_exited(row: Control, orb_id: int) -> void:
	if _mastery_detail_hovered_orb_id == orb_id:
		_mastery_detail_hovered_orb_id = -1
		_hide_mastery_detail()
		_clear_mastery_source_highlights()
	if _hovered_mastery_orb_id == orb_id:
		_hovered_mastery_orb_id = -1
	_apply_hovered_combat_mastery(row)


func _ensure_mastery_detail_bubble() -> void:
	if _mastery_detail_bubble != null:
		return
	var parent := _hud_nodes.get("popover_parent", null) as Control
	if parent == null:
		parent = _hud_nodes.get("section", null) as Control
	if parent == null:
		return

	_mastery_detail_bubble = Panel.new()
	_mastery_detail_bubble.name = "MasteryDetailBubble"
	_mastery_detail_bubble.visible = false
	_mastery_detail_bubble.z_index = int(_hud_nodes.get("popover_z_index", 210))
	_mastery_detail_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(_mastery_detail_bubble)

	_mastery_detail_title = Label.new()
	_mastery_detail_title.name = "MasteryDetailTitle"
	_mastery_detail_bubble.add_child(_mastery_detail_title)

	_mastery_detail_effect = Label.new()
	_mastery_detail_effect.name = "MasteryDetailEffect"
	_mastery_detail_bubble.add_child(_mastery_detail_effect)

	_mastery_detail_value = Label.new()
	_mastery_detail_value.name = "MasteryDetailValue"
	_mastery_detail_bubble.add_child(_mastery_detail_value)

	_mastery_detail_modifiers = Label.new()
	_mastery_detail_modifiers.name = "MasteryDetailModifiers"
	_mastery_detail_modifiers.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_mastery_detail_bubble.add_child(_mastery_detail_modifiers)

	_apply_mastery_detail_popover_chrome()


func _apply_mastery_detail_popover_chrome() -> void:
	if _mastery_detail_bubble == null:
		return
	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(0.03, 0.04, 0.05, 0.98)
	bubble_style.border_color = Color(0.52, 0.60, 0.72, 0.94)
	bubble_style.set_border_width_all(2)
	bubble_style.set_corner_radius_all(8)
	_mastery_detail_bubble.add_theme_stylebox_override("panel", bubble_style)

	_apply_hud_label_style(_mastery_detail_title, Color(0.96, 0.93, 0.86, 1.0), 36)
	_mastery_detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_hud_label_style(_mastery_detail_effect, Color(0.79, 0.86, 0.93, 1.0), 28)
	_mastery_detail_effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_hud_label_style(_mastery_detail_value, Color(0.90, 0.95, 0.72, 1.0), 28)
	_mastery_detail_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_hud_label_style(_mastery_detail_modifiers, Color(0.74, 0.78, 0.84, 1.0), 26)
	_mastery_detail_modifiers.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_mastery_detail_modifiers.vertical_alignment = VERTICAL_ALIGNMENT_TOP


func _show_mastery_detail(orb_id: int, anchor_card: Control = null) -> void:
	if not OrbType.is_valid_id(orb_id):
		_hide_mastery_detail()
		return
	_ensure_mastery_detail_bubble()
	if _mastery_detail_bubble == null:
		return
	var detail := _combat_mastery_detail_data(orb_id)
	_mastery_detail_title.text = String(detail.get("title", ""))
	_mastery_detail_effect.text = String(detail.get("effect", ""))
	_mastery_detail_value.text = String(detail.get("value", ""))
	_mastery_detail_modifiers.text = String(detail.get("modifiers", ""))
	_mastery_detail_bubble.size = MASTERY_DETAIL_BUBBLE_SIZE
	_mastery_detail_bubble.visible = true
	_set_mastery_source_highlights_for_orb(orb_id)
	_layout_mastery_detail_bubble(anchor_card)


func _hide_mastery_detail() -> void:
	if _mastery_detail_bubble == null:
		return
	_mastery_detail_bubble.visible = false


func _layout_mastery_detail_bubble(anchor_card: Control = null) -> void:
	if _mastery_detail_bubble == null:
		return
	var parent := _mastery_detail_bubble.get_parent() as Control
	if parent == null:
		return
	var anchor_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
	if anchor_card != null and is_instance_valid(anchor_card):
		anchor_rect = _to_parent_rect(anchor_card.get_global_rect(), parent)
	elif _mastery_detail_hovered_orb_id >= 0:
		var row := _hud_nodes.get("mastery_cards") as Control
		var fallback_card := get_combat_mastery_card(row, _mastery_detail_hovered_orb_id)
		if fallback_card != null:
			anchor_rect = _to_parent_rect(fallback_card.get_global_rect(), parent)
	if anchor_rect.size == Vector2.ZERO:
		return

	var bubble_size := _mastery_detail_bubble.size
	var local_x := anchor_rect.position.x + (anchor_rect.size.x - bubble_size.x) * 0.5
	local_x = clampf(local_x, 0.0, maxf(0.0, parent.size.x - bubble_size.x))
	var local_y := anchor_rect.position.y - bubble_size.y - 10.0
	if local_y < 0.0:
		local_y = anchor_rect.end.y + 10.0
	_mastery_detail_bubble.position = Vector2(local_x, local_y)

	_apply_rect(_mastery_detail_title, Rect2(Vector2(24.0, 20.0), Vector2(bubble_size.x - 48.0, 52.0)))
	_apply_rect(_mastery_detail_effect, Rect2(Vector2(24.0, 88.0), Vector2(bubble_size.x - 48.0, 46.0)))
	_apply_rect(_mastery_detail_value, Rect2(Vector2(24.0, 146.0), Vector2(bubble_size.x - 48.0, 46.0)))
	_apply_rect(_mastery_detail_modifiers, Rect2(Vector2(24.0, 208.0), Vector2(bubble_size.x - 48.0, bubble_size.y - 232.0)))


func _to_parent_rect(global_rect: Rect2, parent: Control) -> Rect2:
	var inverse := parent.get_global_transform_with_canvas().affine_inverse()
	var top_left := inverse * global_rect.position
	var bottom_right := inverse * (global_rect.position + global_rect.size)
	return Rect2(top_left, bottom_right - top_left)


func _combat_mastery_detail_data(orb_id: int) -> Dictionary:
	var mastery_levels: Dictionary = _mastery_hover_payload.get("mastery_levels", {})
	var level := int(mastery_levels.get(orb_id, 0))
	var orb_values: Dictionary = _mastery_hover_payload.get("orb_values_by_id", {})
	var orb_value := int(orb_values.get(orb_id, 0))
	var effect_text := _mastery_base_effect_text(orb_id, level)
	var value_text := _mastery_value_text(orb_id, orb_value)
	var source_lines := _mastery_modifier_source_lines(orb_id)
	var modifiers_text := "No equipment or relic modifiers"
	if not source_lines.is_empty():
		modifiers_text = "Modifiers: %s" % "; ".join(source_lines)
	return {
		"title": "%s Mastery Lv %d" % [OrbType.display_name(orb_id), level],
		"effect": effect_text,
		"value": value_text,
		"modifiers": modifiers_text,
	}


func _mastery_base_effect_text(orb_id: int, level: int) -> String:
	match orb_id:
		OrbType.Id.HEART:
			return "Base effect: restore HP (mastery bonus +%d)" % level
		OrbType.Id.ARMOR:
			return "Base effect: gain Armor (mastery bonus +%d)" % level
		OrbType.Id.GOLD:
			return "Base effect: gain Gold (mastery bonus +%d)" % level
		_:
			return "Base effect: deal Damage (mastery bonus +%d)" % level


func _mastery_value_text(orb_id: int, orb_value: int) -> String:
	var label := "Per orb value"
	match orb_id:
		OrbType.Id.HEART:
			label = "Per orb heal"
		OrbType.Id.ARMOR:
			label = "Per orb armor"
		OrbType.Id.GOLD:
			label = "Per orb gold"
		_:
			label = "Per orb damage"
	return "%s: %d" % [label, orb_value]


func _mastery_modifier_source_lines(orb_id: int) -> Array[String]:
	var lines: Array[String] = []
	for source in _mastery_modifier_sources(orb_id):
		var source_name := String(source.get("display_name", source.get("source_id", "Unknown")))
		lines.append(source_name)
	return lines


func _mastery_modifier_sources(orb_id: int) -> Array[Dictionary]:
	var matching_sources: Array[Dictionary] = []
	var combat_modifiers: Dictionary = _mastery_hover_payload.get("combat_modifiers", {})
	var sources: Array = combat_modifiers.get("sources", [])
	for raw_source in sources:
		var source: Dictionary = raw_source
		var source_modifiers: Dictionary = source.get("combat_modifiers", {})
		if not _source_affects_orb_mastery(orb_id, source_modifiers):
			continue
		matching_sources.append(source)
	return matching_sources


func _set_mastery_source_highlights_for_orb(orb_id: int) -> void:
	_highlighted_mastery_source_ids.clear()
	for source in _mastery_modifier_sources(orb_id):
		var source_type := String(source.get("source_type", ""))
		var source_id := String(source.get("source_id", ""))
		if source_type == "" or source_id == "":
			continue
		_highlighted_mastery_source_ids[_mastery_source_key(source_type, source_id)] = true
	_apply_mastery_source_highlights()


func _clear_mastery_source_highlights() -> void:
	_highlighted_mastery_source_ids.clear()
	_apply_mastery_source_highlights()


func _apply_mastery_source_highlights() -> void:
	_apply_mastery_source_highlights_to_row(_hud_nodes.get("equipment_icons") as Control)
	_apply_mastery_source_highlights_to_row(_hud_nodes.get("relic_icons") as Control)


func _apply_mastery_source_highlights_to_row(row: Control) -> void:
	if row == null:
		return
	for child in row.get_children():
		var slot := child as Control
		if slot == null:
			continue
		var highlight := slot.get_node_or_null("MasterySourceHighlight") as Panel
		if highlight == null:
			continue
		var content_type := String(slot.get_meta("content_type", ""))
		var content_id := String(slot.get_meta("content_id", ""))
		highlight.visible = _highlighted_mastery_source_ids.has(_mastery_source_key(content_type, content_id))


func _mastery_source_key(source_type: String, source_id: String) -> String:
	return "%s:%s" % [source_type, source_id]


func _add_mastery_source_highlight(slot: Control, slot_size: Vector2) -> void:
	var highlight := Panel.new()
	highlight.name = "MasterySourceHighlight"
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight.position = Vector2.ZERO
	highlight.size = slot_size
	highlight.custom_minimum_size = slot_size
	highlight.visible = false
	highlight.add_theme_stylebox_override("panel", _mastery_source_highlight_stylebox())
	slot.add_child(highlight)


func _mastery_source_highlight_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.86, 0.26, MASTERY_SOURCE_HIGHLIGHT_ALPHA)
	style.border_color = Color(1.0, 0.93, 0.48, MASTERY_SOURCE_HIGHLIGHT_BORDER_ALPHA)
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	return style


func _source_affects_orb_mastery(orb_id: int, modifiers: Dictionary) -> bool:
	var orb_bonus_by_id: Dictionary = modifiers.get("orb_bonus_by_id", {})
	if int(orb_bonus_by_id.get(orb_id, 0)) != 0:
		return true
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			return int(modifiers.get("flat_damage_bonus", 0)) != 0 \
				or int(modifiers.get("combo_flat_bonus", 0)) != 0 \
				or not is_equal_approx(float(modifiers.get("combo_multiplier_mult", 1.0)), 1.0)
		OrbType.Id.ARMOR:
			return int(modifiers.get("start_turn_armor", 0)) != 0 \
				or int(modifiers.get("combo_flat_bonus", 0)) != 0 \
				or not is_equal_approx(float(modifiers.get("combo_multiplier_mult", 1.0)), 1.0)
		OrbType.Id.HEART:
			return int(modifiers.get("flat_heal_bonus", 0)) != 0
		OrbType.Id.GOLD:
			return int(modifiers.get("flat_gold_bonus", 0)) != 0
	return false


func populate_relic_row(row: Control, relic_ids: Array, max_visible: int = 4) -> void:
	_clear_children(row)
	var visible_ids: Array[String] = []
	for raw_id in relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			visible_ids.append(relic_id)
	if visible_ids.is_empty():
		_populate_empty_relic_placeholders(row)
		_apply_mastery_source_highlights()
		return

	var show_count := mini(max_visible, visible_ids.size())
	for index in range(show_count):
		var relic_id := visible_ids[index]
		var slot := PanelContainer.new()
		slot.name = "RelicSlot%d" % index
		slot.custom_minimum_size = RELIC_SLOT_SIZE
		slot.size = RELIC_SLOT_SIZE
		var slot_y := maxf(0.0, (row.size.y - RELIC_SLOT_SIZE.y) * 0.5)
		slot.position = Vector2(float(index) * (RELIC_SLOT_SIZE.x + RELIC_SLOT_GAP), slot_y)
		slot.set_meta("content_type", "relic")
		slot.set_meta("content_id", relic_id)
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
		icon.texture = _visual_registry().clean_icon_for_key(String(content.get("icon_key", "")))
		slot.add_child(icon)
		_add_mastery_source_highlight(slot, RELIC_SLOT_SIZE)
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
	_apply_mastery_source_highlights()


func _populate_empty_relic_placeholders(row: Control) -> void:
	row.tooltip_text = "No relics"


func apply_loadout_rail_layout(equipment_row: Control, equipment_rect: Rect2, consumable_row: Control, consumable_rect: Rect2) -> void:
	_apply_rect(equipment_row, equipment_rect)
	_apply_rect(consumable_row, consumable_rect)


static func shop_player_hud_layout_preset() -> Dictionary:
	return SHOP_PLAYER_HUD_LAYOUT_PRESET.duplicate(true)


static func slot_detail_popover_probe_snapshot() -> Dictionary:
	return {
		"min_width": SLOT_DETAIL_BUBBLE_MIN_WIDTH,
		"max_width": SLOT_DETAIL_BUBBLE_MAX_WIDTH,
		"min_height": SLOT_DETAIL_BUBBLE_MIN_HEIGHT,
		"viewport_margin": SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN,
		"internal_padding": SLOT_DETAIL_BUBBLE_INTERNAL_PADDING,
	}


func apply_player_hud_layout(nodes: Dictionary, layout_override: Dictionary = {}) -> void:
	_apply_node_rect(nodes, "section", _layout_rect(layout_override, "section", PLAYER_HUD_SECTION_RECT))
	_apply_node_rect(nodes, "mastery_panel", _layout_rect(layout_override, "mastery_panel", PLAYER_HUD_MASTERY_PANEL_RECT))
	_apply_node_rect(nodes, "mastery_title", _layout_rect(layout_override, "mastery_title", PLAYER_HUD_MASTERY_TITLE_RECT))
	_apply_node_rect(nodes, "mastery_cards", _layout_rect(layout_override, "mastery_cards", PLAYER_HUD_MASTERY_CARDS_RECT))
	_apply_node_rect(nodes, "footer_panel", _layout_rect(layout_override, "footer_panel", PLAYER_HUD_FOOTER_PANEL_RECT))
	apply_player_footer_layout(nodes)


func apply_player_hud_chrome(nodes: Dictionary) -> void:
	var section_texture := _visual_registry().combat_player_hud_rail_texture()
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
	_apply_hud_label_style(nodes.get("hp_label") as Label, Color(0.98, 0.98, 0.99, 1.0), 32)
	var equipment_label := nodes.get("equipment_label") as Label
	if equipment_label != null:
		equipment_label.text = "EQUIPMENT"
	var consumable_label := nodes.get("consumable_label") as Label
	if consumable_label != null:
		consumable_label.text = "CONSUMABLES"
	var relic_label := nodes.get("relic_label") as Label
	if relic_label != null:
		relic_label.text = "RELICS"
	_apply_hud_label_style(equipment_label, Color(0.96, 0.88, 0.66, 1.0), 21)
	_apply_hud_label_style(consumable_label, Color(0.90, 0.93, 0.99, 1.0), 21)
	_apply_hud_label_style(relic_label, Color(0.88, 0.94, 0.99, 1.0), 18)
	_apply_slot_detail_popover_chrome()


func apply_player_footer_layout(nodes: Dictionary) -> void:
	_adopt_player_hud_relic_nodes(nodes)
	var footer_panel := nodes.get("footer_panel") as Control
	var compact_mode := footer_panel != null and footer_panel.size.y <= COMPACT_COMBAT_PLAYER_PANEL_SIZE.y + 4.0
	var player_panel_size := COMPACT_COMBAT_PLAYER_PANEL_SIZE if compact_mode else COMBAT_PLAYER_PANEL_SIZE
	var hero_card_rect := COMPACT_HERO_CARD_RECT if compact_mode else HERO_CARD_RECT
	var hero_portrait_rect := COMPACT_HERO_PORTRAIT_RECT if compact_mode else HERO_PORTRAIT_RECT
	var vitals_panel_rect := COMPACT_VITALS_PANEL_RECT if compact_mode else VITALS_PANEL_RECT
	var vitals_frame_rect := COMPACT_VITALS_FRAME_RECT if compact_mode else VITALS_FRAME_RECT
	var hp_bar_rect := COMPACT_PLAYER_HP_BAR_RECT if compact_mode else PLAYER_HP_BAR_RECT
	var armor_bar_rect := COMPACT_PLAYER_ARMOR_BAR_RECT if compact_mode else PLAYER_ARMOR_BAR_RECT
	var armor_badge_rect := COMPACT_ARMOR_BADGE_RECT if compact_mode else ARMOR_BADGE_RECT
	var loadout_rect := COMPACT_PLAYER_LOADOUT_RECT if compact_mode else PLAYER_LOADOUT_RECT
	var equipment_label_rect := COMPACT_EQUIPMENT_LABEL_RECT if compact_mode else EQUIPMENT_LABEL_RECT
	var consumable_label_rect := COMPACT_CONSUMABLE_LABEL_RECT if compact_mode else CONSUMABLE_LABEL_RECT
	var equipment_icons_rect := COMPACT_EQUIPMENT_RAIL_RECT if compact_mode else EQUIPMENT_RAIL_RECT
	var consumable_icons_rect := COMPACT_CONSUMABLE_RAIL_RECT if compact_mode else CONSUMABLE_RAIL_RECT
	var relic_label_rect := COMPACT_RELIC_LABEL_RECT if compact_mode else RELIC_LABEL_RECT
	var relic_icons_rect := COMPACT_VITALS_RELIC_ICONS_RECT if compact_mode else VITALS_RELIC_ICONS_RECT
	var mastery_strip_rect := COMPACT_PLAYER_MASTERY_RECT if compact_mode else PLAYER_MASTERY_RECT
	var mastery_root_rect := COMPACT_MASTERY_ROOT_RECT if compact_mode else MASTERY_ROOT_RECT
	var mastery_label_rect := COMPACT_MASTERY_LABEL_RECT if compact_mode else MASTERY_LABEL_RECT
	var mastery_icons_rect := COMPACT_MASTERY_ICONS_RECT if compact_mode else MASTERY_ICONS_RECT
	if nodes.has("footer_root"):
		_apply_node_rect(nodes, "footer_root", Rect2(Vector2.ZERO, player_panel_size))
	else:
		_apply_node_rect(nodes, "root", Rect2(Vector2.ZERO, player_panel_size))
	_apply_node_rect(nodes, "hero_card", hero_card_rect)
	_apply_node_rect(nodes, "hero_card_root", Rect2(Vector2.ZERO, hero_card_rect.size))
	_apply_node_rect(nodes, "hero_portrait", hero_portrait_rect)
	_apply_node_rect(nodes, "vitals_panel", vitals_panel_rect)
	_apply_node_rect(nodes, "vitals_frame", vitals_frame_rect)
	_apply_node_rect(nodes, "hp_bar", hp_bar_rect)
	_apply_node_rect(nodes, "hp_label", hp_bar_rect)
	_apply_node_rect(nodes, "armor_bar", armor_bar_rect)
	_apply_node_rect(nodes, "armor_label", armor_bar_rect)
	_apply_node_rect(nodes, "armor_badge", armor_badge_rect)
	_apply_node_min_size(nodes, "armor_badge_label", armor_badge_rect.size)
	_apply_node_rect(nodes, "loadout_frame", loadout_rect)
	_apply_node_rect(nodes, "loadout_root", Rect2(Vector2.ZERO, loadout_rect.size))
	_apply_node_rect(nodes, "equipment_label", equipment_label_rect)
	_apply_node_rect(nodes, "consumable_label", consumable_label_rect)
	_apply_node_rect(nodes, "equipment_icons", equipment_icons_rect)
	_apply_node_rect(nodes, "consumable_icons", consumable_icons_rect)
	_apply_node_rect(nodes, "relic_label", relic_label_rect)
	_apply_node_rect(nodes, "relic_icons", relic_icons_rect)
	_apply_node_min_size(nodes, "relic_icons", relic_icons_rect.size)
	_apply_node_rect(nodes, "mastery_strip", mastery_strip_rect)
	_apply_node_rect(nodes, "mastery_root", mastery_root_rect)
	_apply_node_rect(nodes, "mastery_label", mastery_label_rect)
	_apply_node_rect(nodes, "mastery_icons", mastery_icons_rect)
	_set_node_visible(nodes, "equipment_label", true)
	_set_node_visible(nodes, "consumable_label", true)
	_set_node_visible(nodes, "relic_label", true)
	_set_node_visible(nodes, "relic_icons", true)
	_set_node_visible(nodes, "relic_row", false)
	_set_node_visible(nodes, "mastery_label", false)
	_set_node_visible(nodes, "mastery_strip", false)
	_set_node_visible(nodes, "armor_bar", false)
	_set_node_visible(nodes, "armor_label", false)
	_set_node_visible(nodes, "armor_badge", false)
	_set_node_visible(nodes, "hero_level_badge", false)
	_set_node_visible(nodes, "stat_chip_row", false)
	_set_node_visible(nodes, "combat_meta_row", false)
	_set_node_visible(nodes, "turn_summary_label", false)
	var equipment_label := nodes.get("equipment_label") as Label
	if equipment_label != null:
		equipment_label.add_theme_font_size_override("font_size", 17 if compact_mode else 19)
	var consumable_label := nodes.get("consumable_label") as Label
	if consumable_label != null:
		consumable_label.add_theme_font_size_override("font_size", 17 if compact_mode else 19)
	var relic_label := nodes.get("relic_label") as Label
	if relic_label != null:
		relic_label.add_theme_font_size_override("font_size", 16 if compact_mode else 18)
	var hp_label := nodes.get("hp_label") as Label
	if hp_label != null:
		hp_label.add_theme_font_size_override("font_size", 30 if compact_mode else 33)


func apply_combat_player_panel_layout(nodes: Dictionary) -> void:
	apply_player_footer_layout(nodes)


func _adopt_player_hud_relic_nodes(nodes: Dictionary) -> void:
	var vitals_panel := nodes.get("vitals_panel") as Node
	if vitals_panel == null:
		return
	for key in ["relic_label", "relic_icons"]:
		var node := nodes.get(key) as Node
		if node == null or node.get_parent() == vitals_panel:
			continue
		var existing_parent := node.get_parent()
		if existing_parent != null:
			existing_parent.remove_child(node)
		vitals_panel.add_child(node)


func _layout_rect(layout_override: Dictionary, key: String, fallback: Rect2) -> Rect2:
	if layout_override.has(key):
		var value: Variant = layout_override[key]
		if value is Rect2:
			return value
	return fallback


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
	value = registry.get_treasure_chest(content_id)
	if not value.is_empty():
		return value
	return {
		"display_name": content_id,
		"description": "",
		"icon_key": "",
	}


func _hud_section_stylebox() -> StyleBoxFlat:
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


func _hud_inner_panel_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.07, 0.11, 0.98)
	style.border_color = Color(0.40, 0.33, 0.18, 0.88)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _hud_soft_panel_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.02, 0.04, 0.07, 0.82)
	style.border_color = Color(0.28, 0.34, 0.42, 0.70)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _hud_vitals_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.07, 0.12, 0.98)
	style.border_color = Color(0.52, 0.40, 0.19, 0.90)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	return style


func _hud_loadout_strip_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.08, 0.98)
	style.border_color = Color(0.56, 0.44, 0.21, 0.88)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style


func _hud_relic_strip_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.06, 0.09, 0.98)
	style.border_color = Color(0.72, 0.58, 0.28, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _texture_stylebox(texture: Texture2D, left: int, right: int, top: int, bottom: int, content_margin: float = 8.0) -> StyleBoxTexture:
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


func _apply_progressbar_flat_style(bar: ProgressBar, fill_color: Color) -> void:
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


func _apply_hud_label_style(label: Label, color: Color, font_size: int) -> void:
	if label == null:
		return
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.96))


func _sync_intent_damage_preview(preview: Dictionary) -> void:
	_intent_damage_preview = preview.duplicate(true)
	_ensure_intent_damage_preview_nodes()
	_layout_player_armor_overshield(_current_visible_armor())
	_layout_intent_damage_preview()


func _current_visible_armor() -> int:
	var display_values: Dictionary = _player_data.get("display_values", {})
	if display_values.has("current_armor"):
		return maxi(0, int(display_values.get("current_armor", 0)))
	var player_state = _player_data.get("player_state", null)
	if player_state != null:
		return maxi(0, int(player_state.armor))
	return 0


func _ensure_intent_damage_preview_nodes() -> void:
	var hp_bar := _hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar != null:
		if _player_armor_overshield_rect == null or not is_instance_valid(_player_armor_overshield_rect):
			_player_armor_overshield_rect = ColorRect.new()
			_player_armor_overshield_rect.name = "PlayerArmorOvershieldFill"
			_player_armor_overshield_rect.color = Color(0.86, 0.90, 0.94, 0.46)
			_player_armor_overshield_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_player_armor_overshield_rect.visible = false
		if _player_armor_overshield_rect.get_parent() != hp_bar:
			var existing_overshield_parent := _player_armor_overshield_rect.get_parent()
			if existing_overshield_parent != null:
				existing_overshield_parent.remove_child(_player_armor_overshield_rect)
			hp_bar.add_child(_player_armor_overshield_rect)
		if _intent_hp_danger_button == null or not is_instance_valid(_intent_hp_danger_button):
			_intent_hp_danger_button = Button.new()
			_intent_hp_danger_button.name = "HpDangerPreviewButton"
			_intent_hp_danger_button.text = ""
			_intent_hp_danger_button.focus_mode = Control.FOCUS_NONE
			_intent_hp_danger_button.visible = false
			_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_intent_hp_danger_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var clear_style := StyleBoxEmpty.new()
			_intent_hp_danger_button.add_theme_stylebox_override("normal", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("hover", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("pressed", clear_style)
			_intent_hp_danger_button.add_theme_stylebox_override("focus", clear_style)
			_intent_hp_danger_button.mouse_entered.connect(_on_intent_damage_preview_hovered)
			_intent_hp_danger_button.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		if _intent_hp_danger_button.get_parent() != hp_bar:
			var existing_parent := _intent_hp_danger_button.get_parent()
			if existing_parent != null:
				existing_parent.remove_child(_intent_hp_danger_button)
			hp_bar.add_child(_intent_hp_danger_button)
		if _intent_hp_danger_empty == null or not is_instance_valid(_intent_hp_danger_empty):
			_intent_hp_danger_empty = ColorRect.new()
			_intent_hp_danger_empty.name = "HpDangerPreviewEmpty"
			_intent_hp_danger_empty.color = Color(0.04, 0.07, 0.10, 1.0)
			_intent_hp_danger_empty.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_intent_hp_danger_empty.visible = false
		if _intent_hp_danger_empty.get_parent() != _intent_hp_danger_button:
			var existing_empty_parent := _intent_hp_danger_empty.get_parent()
			if existing_empty_parent != null:
				existing_empty_parent.remove_child(_intent_hp_danger_empty)
			_intent_hp_danger_button.add_child(_intent_hp_danger_empty)
		if _intent_hp_danger_fill == null or not is_instance_valid(_intent_hp_danger_fill):
			_intent_hp_danger_fill = ColorRect.new()
			_intent_hp_danger_fill.name = "HpDangerPreviewFill"
			_intent_hp_danger_fill.color = Color(1.0, 0.02, 0.02, 1.0)
			_intent_hp_danger_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_intent_hp_danger_fill.visible = false
		if _intent_hp_danger_fill.get_parent() != _intent_hp_danger_button:
			var existing_fill_parent := _intent_hp_danger_fill.get_parent()
			if existing_fill_parent != null:
				existing_fill_parent.remove_child(_intent_hp_danger_fill)
			_intent_hp_danger_button.add_child(_intent_hp_danger_fill)

	if hp_bar != null:
		if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
			_intent_armor_risk_rect = ColorRect.new()
			_intent_armor_risk_rect.name = "PlayerBlockIntentPreviewFill"
			_intent_armor_risk_rect.color = Color(0.86, 0.90, 0.94, 0.68)
			_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_intent_armor_risk_rect.visible = false
			_intent_armor_risk_rect.mouse_entered.connect(_on_intent_block_preview_hovered)
			_intent_armor_risk_rect.mouse_exited.connect(_on_intent_damage_preview_hover_ended)
		if _intent_armor_risk_rect.get_parent() != hp_bar:
			var existing_armor_parent := _intent_armor_risk_rect.get_parent()
			if existing_armor_parent != null:
				existing_armor_parent.remove_child(_intent_armor_risk_rect)
			hp_bar.add_child(_intent_armor_risk_rect)


func _layout_player_armor_overshield(armor: int) -> void:
	if _player_armor_overshield_rect == null or not is_instance_valid(_player_armor_overshield_rect):
		return
	var hp_bar := _hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar == null:
		return
	_player_armor_overshield_rect.visible = false
	if armor <= 0:
		return
	var bar_width := maxf(0.0, hp_bar.size.x)
	var bar_height := maxf(0.0, hp_bar.size.y)
	var max_hp := maxf(1.0, hp_bar.max_value)
	if bar_width <= 0.0 or bar_height <= 0.0:
		return
	var overshield_width := bar_width * clampf(float(armor) / max_hp, 0.0, 1.0)
	if overshield_width <= 0.0:
		return
	_player_armor_overshield_rect.position = Vector2.ZERO
	_player_armor_overshield_rect.size = Vector2(overshield_width, bar_height)
	_player_armor_overshield_rect.visible = true


func _layout_intent_damage_preview() -> void:
	if _intent_hp_danger_button != null and is_instance_valid(_intent_hp_danger_button):
		_intent_hp_danger_button.visible = false
		_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.visible = false
	if _intent_hp_danger_empty != null and is_instance_valid(_intent_hp_danger_empty):
		_intent_hp_danger_empty.visible = false
	_stop_intent_hp_danger_pulse()
	_set_armor_risk_highlight(false)
	if _intent_damage_preview.is_empty():
		return
	var hp_loss := maxi(0, int(_intent_damage_preview.get("hp_loss", 0)))
	var blocked := maxi(0, int(_intent_damage_preview.get("blocked", 0)))
	var fully_blocked := bool(_intent_damage_preview.get("fully_blocked", false))
	if blocked > 0:
		_layout_player_block_intent_preview(blocked)
	if hp_loss > 0:
		var hp_bar := _hud_nodes.get("hp_bar") as ProgressBar
		if hp_bar == null or _intent_hp_danger_button == null or _intent_hp_danger_empty == null or _intent_hp_danger_fill == null:
			return
		var bar_width := maxf(0.0, hp_bar.size.x)
		var bar_height := maxf(0.0, hp_bar.size.y)
		if bar_width <= 0.0 or bar_height <= 0.0:
			return
		var max_hp := maxf(1.0, hp_bar.max_value)
		var current_hp := float(maxi(0, int(_intent_damage_preview.get("current_hp", int(round(hp_bar.value))))))
		var fill_width := bar_width * clampf(current_hp / max_hp, 0.0, 1.0)
		var segment_width := bar_width * clampf(float(hp_loss) / max_hp, 0.0, 1.0)
		segment_width = clampf(segment_width, 0.0, fill_width)
		if segment_width > 0.0:
			segment_width = maxf(segment_width, INTENT_PREVIEW_MIN_SEGMENT_WIDTH)
			segment_width = minf(segment_width, fill_width)
		if segment_width <= 0.0:
			return
		var segment_x := maxf(0.0, fill_width - segment_width)
		_intent_hp_danger_button.position = Vector2(segment_x, 0.0)
		_intent_hp_danger_button.size = Vector2(segment_width, bar_height)
		_intent_hp_danger_button.visible = true
		_intent_hp_danger_button.mouse_filter = Control.MOUSE_FILTER_STOP
		_intent_hp_danger_empty.visible = true
		_intent_hp_danger_empty.position = Vector2.ZERO
		_intent_hp_danger_empty.size = _intent_hp_danger_button.size
		_intent_hp_danger_fill.visible = true
		_intent_hp_danger_fill.position = Vector2.ZERO
		_intent_hp_danger_fill.size = _intent_hp_danger_button.size
		_start_intent_hp_danger_pulse()
		return
	if fully_blocked:
		return


func _layout_player_block_intent_preview(blocked: int) -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	var hp_bar := _hud_nodes.get("hp_bar") as ProgressBar
	if hp_bar == null:
		return
	var bar_width := maxf(0.0, hp_bar.size.x)
	var max_hp := maxf(1.0, hp_bar.max_value)
	if bar_width <= 0.0 or blocked <= 0:
		return
	var preview_width := bar_width * clampf(float(blocked) / max_hp, 0.0, 1.0)
	if preview_width <= 0.0:
		return
	_intent_armor_risk_rect.visible = true
	_intent_armor_risk_rect.position = Vector2.ZERO
	_intent_armor_risk_rect.size = Vector2(preview_width, hp_bar.size.y)
	_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_start_player_block_intent_preview_pulse()


func _start_intent_hp_danger_pulse() -> void:
	if _intent_hp_danger_fill == null or not is_instance_valid(_intent_hp_danger_fill):
		return
	_stop_intent_hp_danger_pulse()
	_intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)
	_intent_hp_danger_pulse_tween = _intent_hp_danger_fill.create_tween()
	_intent_hp_danger_pulse_tween.set_loops()
	_intent_hp_danger_pulse_tween.tween_property(_intent_hp_danger_fill, "modulate:a", 0.0, INTENT_PREVIEW_PULSE_SECONDS)
	_intent_hp_danger_pulse_tween.tween_property(_intent_hp_danger_fill, "modulate:a", 1.0, INTENT_PREVIEW_PULSE_SECONDS)


func _stop_intent_hp_danger_pulse() -> void:
	if _intent_hp_danger_pulse_tween != null and is_instance_valid(_intent_hp_danger_pulse_tween):
		_intent_hp_danger_pulse_tween.kill()
	_intent_hp_danger_pulse_tween = null
	if _intent_hp_danger_fill != null and is_instance_valid(_intent_hp_danger_fill):
		_intent_hp_danger_fill.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _set_armor_risk_highlight(enabled: bool) -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	_intent_armor_risk_rect.visible = enabled
	_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_STOP if enabled else Control.MOUSE_FILTER_IGNORE
	if enabled:
		_start_player_block_intent_preview_pulse()
		return
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_tween = null


func _start_player_block_intent_preview_pulse() -> void:
	if _intent_armor_risk_rect == null or not is_instance_valid(_intent_armor_risk_rect):
		return
	if _intent_armor_risk_tween != null and is_instance_valid(_intent_armor_risk_tween):
		_intent_armor_risk_tween.kill()
	_intent_armor_risk_rect.modulate = Color(1.0, 1.0, 1.0, 0.68)
	_intent_armor_risk_tween = _intent_armor_risk_rect.create_tween()
	_intent_armor_risk_tween.set_loops()
	_intent_armor_risk_tween.tween_property(_intent_armor_risk_rect, "modulate:a", 0.22, ARMOR_PREVIEW_PULSE_SECONDS)
	_intent_armor_risk_tween.tween_property(_intent_armor_risk_rect, "modulate:a", 0.68, ARMOR_PREVIEW_PULSE_SECONDS)


func _on_intent_damage_preview_hovered() -> void:
	if _intent_damage_preview.is_empty():
		return
	intent_preview_hovered.emit(_intent_damage_preview.duplicate(true))


func _on_intent_block_preview_hovered() -> void:
	if _intent_damage_preview.is_empty():
		return
	intent_block_preview_hovered.emit(_intent_damage_preview.duplicate(true))


func _on_intent_damage_preview_hover_ended() -> void:
	intent_preview_hover_ended.emit()


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
	_update_selected_slot_popover()


func _on_consumable_slot_pressed(index: int) -> void:
	_selected_consumable_slot = index
	_selected_equipment_slot = -1
	consumable_slot_selected.emit(index)
	_update_selected_slot_popover()


func _on_slot_mouse_entered(slot: Control, slot_type: String, slot_index: int, content: Dictionary, fallback_id: String, filled: bool) -> void:
	if slot == null:
		return
	var title := "Empty %s slot" % slot_type
	var description := ""
	if filled:
		title = String(content.get("display_name", fallback_id))
		description = String(content.get("description", ""))
	slot_hover_started.emit(slot_type, slot_index, title, description, slot.get_global_rect())
	_set_slot_popover_content(slot_type, slot_index, title, description, slot.get_global_rect())


func _on_slot_mouse_exited() -> void:
	slot_hover_ended.emit()
	_hover_slot_global_rect = Rect2()
	_hover_slot_type = ""
	_hover_slot_index = -1
	_hover_slot_title = ""
	_hover_slot_description = ""
	_update_selected_slot_popover()


func _make_badge_label(text: String, slot_size: Vector2) -> Label:
	var amount_label := Label.new()
	amount_label.name = "SlotBadge"
	amount_label.text = text
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	amount_label.add_theme_font_size_override("font_size", 21)
	amount_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.34, 1.0))
	amount_label.add_theme_constant_override("outline_size", 3)
	amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
	amount_label.position = Vector2.ZERO
	amount_label.size = slot_size
	amount_label.anchors_preset = Control.PRESET_FULL_RECT
	return amount_label


func _ensure_slot_detail_popover() -> void:
	if _slot_detail_bubble != null:
		return
	var parent := _hud_nodes.get("popover_parent", null) as Control
	if parent == null:
		parent = _hud_nodes.get("section", null) as Control
	if parent == null:
		return
	_slot_detail_bubble = Panel.new()
	_slot_detail_bubble.name = "SlotDetailBubble"
	_slot_detail_bubble.visible = false
	_slot_detail_bubble.z_index = int(_hud_nodes.get("popover_z_index", 210))
	_slot_detail_bubble.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(_slot_detail_bubble)

	_slot_detail_title = Label.new()
	_slot_detail_title.name = "SlotDetailTitle"
	_slot_detail_title.clip_text = true
	_slot_detail_bubble.add_child(_slot_detail_title)

	_slot_detail_description = Label.new()
	_slot_detail_description.name = "SlotDetailDescription"
	_slot_detail_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_slot_detail_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_slot_detail_description.clip_text = true
	_slot_detail_bubble.add_child(_slot_detail_description)

	_slot_detail_sell_button = Button.new()
	_slot_detail_sell_button.name = "SlotDetailSellButton"
	_slot_detail_sell_button.text = "Sell"
	_slot_detail_sell_button.visible = false
	_slot_detail_sell_button.pressed.connect(_on_slot_detail_sell_pressed)
	_slot_detail_bubble.add_child(_slot_detail_sell_button)


func _apply_slot_detail_popover_chrome() -> void:
	if _slot_detail_bubble == null:
		return
	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(0.03, 0.04, 0.05, 0.98)
	bubble_style.border_color = Color(0.68, 0.49, 0.23, 0.98)
	bubble_style.set_border_width_all(2)
	bubble_style.set_corner_radius_all(8)
	_slot_detail_bubble.add_theme_stylebox_override("panel", bubble_style)
	_apply_hud_label_style(_slot_detail_title, Color(0.96, 0.90, 0.78, 1.0), 26)
	_slot_detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_apply_hud_label_style(_slot_detail_description, Color(0.72, 0.62, 0.45, 1.0), 18)
	_slot_detail_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_slot_detail_description.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_slot_detail_sell_button.add_theme_font_size_override("font_size", 26)
	_slot_detail_sell_button.add_theme_color_override("font_color", Color(0.96, 0.90, 0.78, 1.0))
	var normal := _button_stylebox(Color(0.20, 0.13, 0.07, 0.96), Color(0.66, 0.49, 0.24, 1.0))
	var hover := _button_stylebox(Color(0.28, 0.18, 0.09, 0.98), Color(0.76, 0.59, 0.34, 1.0))
	_slot_detail_sell_button.add_theme_stylebox_override("normal", normal)
	_slot_detail_sell_button.add_theme_stylebox_override("hover", hover)
	_slot_detail_sell_button.add_theme_stylebox_override("pressed", hover)


func _button_stylebox(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _set_slot_popover_content(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2) -> void:
	if _slot_detail_bubble == null:
		return
	_hover_slot_global_rect = slot_global_rect
	_hover_slot_type = slot_type
	_hover_slot_index = slot_index
	_hover_slot_title = title
	_hover_slot_description = description
	_slot_detail_title.text = title
	_slot_detail_description.text = description
	_slot_detail_description.visible = description != ""
	_slot_detail_bubble.visible = title != ""
	_update_slot_detail_bubble()


func _update_selected_slot_popover() -> void:
	if _hover_slot_type != "":
		return
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		hide_slot_detail_popover()
		return
	var slot_index := _selected_equipment_slot if selected_kind == "equipment" else _selected_consumable_slot
	var row := _hud_nodes.get("equipment_icons") as Control
	if selected_kind == "consumable":
		row = _hud_nodes.get("consumable_icons") as Control
	var slot := row.get_node_or_null("%sSlot%d" % [selected_kind.capitalize(), slot_index]) as Control if row != null else null
	if slot == null:
		return
	var item_id := _slot_content_id(selected_kind, slot_index)
	var content := lookup_content_definition(item_id)
	_set_slot_popover_content(selected_kind, slot_index, String(content.get("display_name", item_id)), String(content.get("description", "")), slot.get_global_rect())


func hide_slot_detail_popover() -> void:
	if _slot_detail_bubble == null:
		return
	_hover_slot_global_rect = Rect2()
	_hover_slot_type = ""
	_hover_slot_index = -1
	_hover_slot_title = ""
	_hover_slot_description = ""
	_slot_detail_bubble.visible = false


func _update_slot_detail_bubble() -> void:
	if _slot_detail_bubble == null or not _slot_detail_bubble.visible:
		return
	var has_description := _slot_detail_description.text != ""
	var show_sell_action := _slot_popover_shows_sell_action()
	var parent := _slot_detail_bubble.get_parent() as Control
	var parent_size := COMBAT_PLAYER_PANEL_SIZE
	var slot_top_left: Vector2 = _hover_slot_global_rect.position
	var slot_size: Vector2 = _hover_slot_global_rect.size
	if parent != null:
		parent_size = parent.size
		var transform_inverse := parent.get_global_transform_with_canvas().affine_inverse()
		slot_top_left = transform_inverse * _hover_slot_global_rect.position
		var slot_bottom_right: Vector2 = transform_inverse * (_hover_slot_global_rect.position + _hover_slot_global_rect.size)
		slot_size = slot_bottom_right - slot_top_left

	var bubble_width := _slot_detail_popover_width(parent_size.x)
	var max_width := maxf(280.0, parent_size.x - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var max_height := maxf(108.0, parent_size.y - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var bubble_size := Vector2(minf(bubble_width, max_width), SLOT_DETAIL_BUBBLE_MIN_HEIGHT)
	var content_width := maxf(200.0, bubble_size.x - SLOT_DETAIL_BUBBLE_INTERNAL_PADDING * 2.0)

	var title_height := 38.0
	var row_gap := 10.0
	var sell_button_height := 72.0 if show_sell_action else 0.0
	var description_target_height := _slot_detail_description_height(_slot_detail_description.text, content_width, 18) if has_description else 0.0
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

	_slot_detail_bubble.position = Vector2(local_x, local_y)
	_slot_detail_bubble.size = bubble_size

	var cursor_y := SLOT_DETAIL_BUBBLE_INTERNAL_PADDING
	_apply_rect(
		_slot_detail_title,
		Rect2(
			Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y),
			Vector2(content_width, title_height)
		)
	)
	cursor_y += title_height
	if has_description:
		cursor_y += row_gap
		_slot_detail_description.visible = true
		_apply_rect(
			_slot_detail_description,
			Rect2(
				Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y),
				Vector2(content_width, description_height)
			)
		)
		cursor_y += description_height
	else:
		_slot_detail_description.visible = false
		_apply_rect(
			_slot_detail_description,
			Rect2(
				Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y),
				Vector2(content_width, 0.0)
			)
		)

	_slot_detail_sell_button.visible = show_sell_action
	_slot_detail_sell_button.disabled = _selected_slot_kind() == ""
	_slot_detail_sell_button.text = "Sell  %s" % _selected_slot_sell_text()
	if show_sell_action:
		cursor_y += 12.0
		_apply_rect(
			_slot_detail_sell_button,
			Rect2(
				Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y),
				Vector2(content_width, sell_button_height)
			)
		)
	else:
		_apply_rect(
			_slot_detail_sell_button,
			Rect2(
				Vector2(SLOT_DETAIL_BUBBLE_INTERNAL_PADDING, cursor_y),
				Vector2(content_width, 0.0)
			)
		)


func _slot_detail_popover_width(parent_width: float) -> float:
	var available_width := maxf(280.0, parent_width - SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN * 2.0)
	var title_len := float(_slot_detail_title.text.length())
	var description_len := float(_slot_detail_description.text.length())
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
	if _hover_slot_type != "equipment" and _hover_slot_type != "consumable":
		return false
	if _hover_slot_title == "":
		return false
	if _hover_slot_title.begins_with("Empty "):
		return false
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return false
	var selected_slot_index := _selected_equipment_slot if selected_kind == "equipment" else _selected_consumable_slot
	return selected_kind == _hover_slot_type and selected_slot_index == _hover_slot_index


func _selected_slot_sell_text() -> String:
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return "Select slot"
	var slot_index := _selected_equipment_slot if selected_kind == "equipment" else _selected_consumable_slot
	var item_id := _slot_content_id(selected_kind, slot_index)
	var content := lookup_content_definition(item_id)
	return "+%d gold" % int(content.get("sell_value", content.get("base_price", 0)))


func _selected_slot_kind() -> String:
	if _slot_content_id("equipment", _selected_equipment_slot) != "":
		return "equipment"
	if _slot_content_id("consumable", _selected_consumable_slot) != "":
		return "consumable"
	return ""


func _slot_content_id(slot_type: String, slot_index: int) -> String:
	var progression_snapshot: Dictionary = _player_data.get("progression", {})
	var slots: Array = progression_snapshot.get("equipment_slots", []) if slot_type == "equipment" else progression_snapshot.get("consumable_slots", [])
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	return String(slots[slot_index])


func _on_slot_detail_sell_pressed() -> void:
	var selected_kind := _selected_slot_kind()
	if selected_kind == "":
		return
	var slot_index := _selected_equipment_slot if selected_kind == "equipment" else _selected_consumable_slot
	sell_slot_requested.emit(selected_kind, slot_index)


func _has_inventory_focus() -> bool:
	return _selected_equipment_slot >= 0 or _selected_consumable_slot >= 0 or (_slot_detail_bubble != null and _slot_detail_bubble.visible)


func _is_inside_inventory_focus_area(global_point: Vector2) -> bool:
	if _control_contains_point(_slot_detail_bubble, global_point):
		return true
	if _control_contains_point(_slot_detail_sell_button, global_point):
		return true
	for key in ["equipment_icons", "consumable_icons", "relic_icons"]:
		if _point_hits_control_children(_hud_nodes.get(key) as Control, global_point):
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


func _slot_stylebox(selected: bool = false, empty: bool = false) -> StyleBox:
	var slot_texture := _visual_registry().combat_slot_frame_texture(not empty)
	if slot_texture != null and not selected:
		return _texture_stylebox(slot_texture, 20, 20, 20, 20, 6.0)
	var style := StyleBoxFlat.new()
	if empty:
		style.bg_color = Color(0.03, 0.05, 0.08, 0.98)
		style.border_color = Color(0.34, 0.30, 0.22, 0.80)
	elif selected:
		style.bg_color = Color(0.16, 0.11, 0.05, 0.99)
		style.border_color = Color(0.95, 0.70, 0.25, 1.0)
	else:
		style.bg_color = Color(0.08, 0.07, 0.10, 0.98)
		style.border_color = Color(0.68, 0.49, 0.23, 0.96)
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
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
	UI_UTILS.clear_children(node)


func _visual_registry() -> VisualRegistry:
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	return _visuals


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


func _set_node_visible(nodes: Dictionary, key: String, visible: bool) -> void:
	var canvas_item := nodes.get(key, null) as CanvasItem
	if canvas_item == null:
		return
	canvas_item.visible = visible
