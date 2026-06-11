extends RefCounted
class_name PlayerLoadoutHud

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const MASTERY_SOURCE_HIGHLIGHTER_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_source_highlighter.gd")
const MASTERY_PANEL_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_panel.gd")
const INTENT_PREVIEW_SCRIPT := preload("res://scripts/ui/player_loadout_intent_preview.gd")
const SLOT_DETAIL_POPOVER_SCRIPT := preload("res://scripts/ui/player_loadout_slot_detail_popover.gd")

signal equipment_slot_selected(slot_index: int)
signal consumable_slot_selected(slot_index: int)
signal sell_slot_requested(slot_type: String, slot_index: int)
signal slot_hover_started(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2)
signal slot_hover_ended
signal intent_preview_hovered(preview: Dictionary)
signal intent_block_preview_hovered(preview: Dictionary)
signal intent_preview_hover_ended

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
const COMBAT_MASTERY_FEEDBACK_NUMBER_FONT_SIZE := 42
const COMBAT_MASTERY_COMPACT_FEEDBACK_NUMBER_FONT_SIZE := 34
const COMBAT_MASTERY_FEEDBACK_POP_SECONDS := 0.18
const COMBAT_MASTERY_ACTIVATION_BASE_ALPHA := 0.14
const COMBAT_MASTERY_ACTIVATION_ALPHA_STEP := 0.08
const COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS := 0.24
const COMBAT_MASTERY_HOVER_ALPHA := 0.20
const COMBAT_MASTERY_HOVER_BORDER_ALPHA := 0.90
const COMBAT_MASTERY_ORDER: Array[int] = [3, 4, 5, 0, 1, 2]
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
var _mastery_source_highlighter: Variant
var _mastery_panel_presenter: Variant
var _intent_preview_presenter: Variant
var _slot_detail_popover_presenter: Variant
var _hud_section_node: Node = null


func set_selected_equipment_slot(slot_index: int) -> void:
	_selected_equipment_slot = slot_index


func set_selected_consumable_slot(slot_index: int) -> void:
	_selected_consumable_slot = slot_index


func set_visual_registry(visuals: Variant) -> void:
	_visuals = visuals


func bind_player_hud(nodes: Dictionary) -> void:
	_disconnect_hud_lifecycle()
	_hud_nodes = nodes
	_mastery_highlighter().bind_hud_nodes(_hud_nodes)
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
		_intent_armor_risk_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
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
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
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
		_mastery_highlighter().add_highlight(slot, SLOT_SIZE)
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot, label, index, content, id_text, filled))
		slot.mouse_exited.connect(_on_slot_mouse_exited)
		row.add_child(slot)
	_mastery_highlighter().apply_highlights()


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
			mastery_cards, Dictionary(progression_snapshot.get("mastery_levels", {})), Dictionary(_player_data.get("combat_mastery_feedback_totals", {}))
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
	_mastery_panel().populate_mastery_row(row, mastery_levels)


func get_combat_mastery_card(row: Control, orb_id: int) -> Control:
	return _mastery_panel().get_combat_mastery_card(row, orb_id)


func populate_combat_mastery_panel(row: Control, mastery_levels: Dictionary, feedback_totals: Dictionary = {}) -> void:
	_mastery_panel().populate_combat_mastery_panel(row, mastery_levels, feedback_totals)


func clear_combat_mastery_feedback(row: Control) -> void:
	_mastery_panel().clear_combat_mastery_feedback(row)


func set_combat_mastery_feedback(row: Control, orb_id: int, feedback_value: int) -> void:
	_mastery_panel().set_combat_mastery_feedback(row, orb_id, feedback_value)


func set_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_mastery_panel().set_combat_mastery_hover_payload(payload)


func set_hovered_combat_mastery(row: Control, orb_id: int) -> void:
	_mastery_panel().set_hovered_combat_mastery(row, orb_id)


func clear_hovered_combat_mastery(row: Control) -> void:
	_mastery_panel().clear_hovered_combat_mastery(row)


func clear_combat_mastery_hover_ui(row: Control) -> void:
	_mastery_panel().clear_combat_mastery_hover_ui(row)


func pulse_modifier_sources(sources: Array) -> void:
	_mastery_highlighter().pulse_sources(sources)


func _sync_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_mastery_panel()._sync_combat_mastery_hover_payload(payload)


func _apply_hovered_combat_mastery(row: Control) -> void:
	_mastery_panel()._apply_hovered_combat_mastery(row)


func _on_combat_mastery_card_mouse_entered(row: Control, orb_id: int, card: Control) -> void:
	_mastery_panel()._on_combat_mastery_card_mouse_entered(row, orb_id, card)


func _on_combat_mastery_card_mouse_exited(row: Control, orb_id: int) -> void:
	_mastery_panel()._on_combat_mastery_card_mouse_exited(row, orb_id)


func _ensure_mastery_detail_bubble() -> void:
	_mastery_panel()._ensure_mastery_detail_bubble()


func _show_mastery_detail(orb_id: int, anchor_card: Control = null) -> void:
	_mastery_panel()._show_mastery_detail(orb_id, anchor_card)


func _hide_mastery_detail() -> void:
	_mastery_panel()._hide_mastery_detail()


func _layout_mastery_detail_bubble(anchor_card: Control = null) -> void:
	_mastery_panel()._layout_mastery_detail_bubble(anchor_card)


func _mastery_modifier_source_lines(orb_id: int) -> Array[String]:
	return _mastery_highlighter().source_lines(orb_id)


func _set_mastery_source_highlights_for_orb(orb_id: int) -> void:
	_mastery_highlighter().set_highlights_for_orb(orb_id)


func _clear_mastery_source_highlights() -> void:
	_mastery_highlighter().clear_highlights()


func _apply_mastery_source_highlights() -> void:
	_mastery_highlighter().apply_highlights()


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
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		icon.position = Vector2((RELIC_SLOT_SIZE.x - RELIC_ICON_SIZE.x) * 0.5, (RELIC_SLOT_SIZE.y - RELIC_ICON_SIZE.y) * 0.5)
		icon.size = RELIC_ICON_SIZE
		icon.custom_minimum_size = RELIC_ICON_SIZE
		icon.texture = _visual_registry().clean_icon_for_key(String(content.get("icon_key", "")))
		slot.add_child(icon)
		_mastery_highlighter().add_highlight(slot, RELIC_SLOT_SIZE)
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
	var section_texture: Texture2D = _visual_registry().combat_player_hud_rail_texture()
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
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color(0.01, 0.02, 0.03, 0.96))


func _sync_intent_damage_preview(preview: Dictionary) -> void:
	_intent_preview()._sync_intent_damage_preview(preview)


func _current_visible_armor() -> int:
	return _intent_preview()._current_visible_armor()


func _ensure_intent_damage_preview_nodes() -> void:
	_intent_preview()._ensure_intent_damage_preview_nodes()


func _layout_player_armor_overshield(armor: int) -> void:
	_intent_preview()._layout_player_armor_overshield(armor)


func _layout_intent_damage_preview() -> void:
	_intent_preview()._layout_intent_damage_preview()


func _layout_player_block_intent_preview(blocked: int) -> void:
	_intent_preview()._layout_player_block_intent_preview(blocked)


func _start_intent_hp_danger_pulse() -> void:
	_intent_preview()._start_intent_hp_danger_pulse()


func _stop_intent_hp_danger_pulse() -> void:
	_intent_preview()._stop_intent_hp_danger_pulse()


func _set_armor_risk_highlight(enabled: bool) -> void:
	_intent_preview()._set_armor_risk_highlight(enabled)


func _start_player_block_intent_preview_pulse() -> void:
	_intent_preview()._start_player_block_intent_preview_pulse()


func _on_intent_damage_preview_hovered() -> void:
	_intent_preview()._on_intent_damage_preview_hovered()


func _on_intent_block_preview_hovered() -> void:
	_intent_preview()._on_intent_block_preview_hovered()


func _on_intent_damage_preview_hover_ended() -> void:
	_intent_preview()._on_intent_damage_preview_hover_ended()


func _make_slot(index: int, filled: bool, slot_label: String, selectable_label: String = "") -> Control:
	var selectable := selectable_label != "" and slot_label == selectable_label
	if selectable:
		var button := Button.new()
		button.text = ""
		button.size = SLOT_SIZE
		button.custom_minimum_size = SLOT_SIZE
		button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
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
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM as VerticalAlignment
	amount_label.add_theme_font_size_override("font_size", 21)
	amount_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.34, 1.0))
	amount_label.add_theme_constant_override("outline_size", 3)
	amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
	amount_label.position = Vector2.ZERO
	amount_label.size = slot_size
	amount_label.anchors_preset = Control.PRESET_FULL_RECT as Control.LayoutPreset
	return amount_label


func _ensure_slot_detail_popover() -> void:
	_slot_detail_popover()._ensure_slot_detail_popover()


func _apply_slot_detail_popover_chrome() -> void:
	_slot_detail_popover()._apply_slot_detail_popover_chrome()


func _button_stylebox(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	return _slot_detail_popover()._button_stylebox(bg_color, border_color)


func _set_slot_popover_content(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2) -> void:
	_slot_detail_popover()._set_slot_popover_content(slot_type, slot_index, title, description, slot_global_rect)


func _update_selected_slot_popover() -> void:
	_slot_detail_popover()._update_selected_slot_popover()


func hide_slot_detail_popover() -> void:
	_slot_detail_popover().hide_slot_detail_popover()


func _update_slot_detail_bubble() -> void:
	_slot_detail_popover()._update_slot_detail_bubble()


func _slot_detail_popover_width(parent_width: float) -> float:
	return _slot_detail_popover()._slot_detail_popover_width(parent_width)


func _slot_detail_description_height(description: String, width: float, font_size: int) -> float:
	return _slot_detail_popover()._slot_detail_description_height(description, width, font_size)


func _slot_popover_shows_sell_action() -> bool:
	return _slot_detail_popover()._slot_popover_shows_sell_action()


func _selected_slot_sell_text() -> String:
	return _slot_detail_popover()._selected_slot_sell_text()


func _selected_slot_kind() -> String:
	return _slot_detail_popover()._selected_slot_kind()


func _slot_content_id(slot_type: String, slot_index: int) -> String:
	var progression_snapshot: Dictionary = _player_data.get("progression", {})
	var slots: Array = progression_snapshot.get("equipment_slots", []) if slot_type == "equipment" else progression_snapshot.get("consumable_slots", [])
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	return String(slots[slot_index])


func _on_slot_detail_sell_pressed() -> void:
	_slot_detail_popover()._on_slot_detail_sell_pressed()


func _has_inventory_focus() -> bool:
	return _slot_detail_popover()._has_inventory_focus()


func _is_inside_inventory_focus_area(global_point: Vector2) -> bool:
	return _slot_detail_popover()._is_inside_inventory_focus_area(global_point)


func _point_hits_control_children(root: Control, global_point: Vector2) -> bool:
	return _slot_detail_popover()._point_hits_control_children(root, global_point)


func _control_contains_point(control: Control, global_point: Vector2) -> bool:
	return _slot_detail_popover()._control_contains_point(control, global_point)


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
	var slot_texture: Texture2D = _visual_registry().combat_slot_frame_texture(not empty)
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


func _visual_registry() -> Variant:
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	return _visuals


func _mastery_highlighter() -> Variant:
	if _mastery_source_highlighter == null:
		_mastery_source_highlighter = MASTERY_SOURCE_HIGHLIGHTER_SCRIPT.new()
		_mastery_source_highlighter.bind_hud_nodes(_hud_nodes)
		_mastery_source_highlighter.set_hover_payload(_mastery_hover_payload)
	return _mastery_source_highlighter


func _mastery_panel() -> Variant:
	if _mastery_panel_presenter == null:
		_mastery_panel_presenter = MASTERY_PANEL_SCRIPT.new()
		_mastery_panel_presenter.bind(self)
	return _mastery_panel_presenter


func _intent_preview() -> Variant:
	if _intent_preview_presenter == null:
		_intent_preview_presenter = INTENT_PREVIEW_SCRIPT.new()
		_intent_preview_presenter.bind(self)
	return _intent_preview_presenter


func _slot_detail_popover() -> Variant:
	if _slot_detail_popover_presenter == null:
		_slot_detail_popover_presenter = SLOT_DETAIL_POPOVER_SCRIPT.new()
		_slot_detail_popover_presenter.bind(self)
	return _slot_detail_popover_presenter


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
