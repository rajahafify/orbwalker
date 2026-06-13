extends RefCounted
class_name PlayerLoadoutHud

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")
const MASTERY_SOURCE_HIGHLIGHTER_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_source_highlighter.gd")
const MASTERY_PANEL_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_panel.gd")
const INTENT_PREVIEW_SCRIPT := preload("res://scripts/ui/player_loadout_intent_preview.gd")
const SLOT_DETAIL_POPOVER_SCRIPT := preload("res://scripts/ui/player_loadout_slot_detail_popover.gd")
const INVENTORY_RENDERER_SCRIPT := preload("res://scripts/ui/player_loadout_inventory_renderer.gd")
const HUD_LAYOUT_SCRIPT := preload("res://scripts/ui/player_loadout_hud_layout.gd")
const HUD_CHROME_STYLER_SCRIPT := preload("res://scripts/ui/player_loadout_hud_chrome_styler.gd")

signal equipment_slot_selected(slot_index: int)
signal consumable_slot_selected(slot_index: int)
signal sell_slot_requested(slot_type: String, slot_index: int)
signal slot_hover_started(slot_type: String, slot_index: int, title: String, description: String, slot_global_rect: Rect2)
signal slot_hover_ended
signal intent_preview_hovered(preview: Dictionary)
signal intent_block_preview_hovered(preview: Dictionary)
signal intent_preview_hover_ended

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")

const SLOT_DETAIL_BUBBLE_MIN_WIDTH := 440.0
const SLOT_DETAIL_BUBBLE_MAX_WIDTH := 640.0
const SLOT_DETAIL_BUBBLE_MIN_HEIGHT := 144.0
const SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN := 10.0
const SLOT_DETAIL_BUBBLE_INTERNAL_PADDING := 16.0
const MASTERY_DETAIL_BUBBLE_SIZE := Vector2(960.0, 468.0)

var _visuals = null
var _selected_equipment_slot := -1
var _selected_consumable_slot := -1
var _hud_nodes: Dictionary = {}
var _player_data: Dictionary = {}
var _layout_override: Dictionary = {}
var _inventory_renderer: Variant
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
	_intent_preview().cleanup()


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
	if _slot_detail_popover()._is_slot_detail_sell_button(global_point):
		_on_slot_detail_sell_pressed()
		return true
	if _is_inside_inventory_focus_area(global_point):
		return false
	hide_slot_detail_popover()
	_selected_equipment_slot = -1
	_selected_consumable_slot = -1
	return true


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
		_inventory().populate_loadout_slot_row(equipment_row, equipment_slots, "equipment", 5, "equipment" if selectable_equipment else "")
	var consumable_row := _hud_nodes.get("consumable_icons") as Control
	if consumable_row != null:
		_inventory().populate_loadout_slot_row(consumable_row, consumable_slots, "consumable", 3, "consumable" if selectable_consumables else "")
	var relic_row := _hud_nodes.get("relic_icons") as Control
	if relic_row != null:
		_inventory().populate_relic_row(relic_row, Array(progression_snapshot.get("relic_ids", [])), max_visible_relics)
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


func apply_loadout_rail_layout(equipment_row: Control, equipment_rect: Rect2, consumable_row: Control, consumable_rect: Rect2) -> void:
	HUD_LAYOUT_SCRIPT.apply_loadout_rail_layout(equipment_row, equipment_rect, consumable_row, consumable_rect)


static func shop_player_hud_layout_preset() -> Dictionary:
	return HUD_LAYOUT_SCRIPT.shop_player_hud_layout_preset()


static func slot_detail_popover_probe_snapshot() -> Dictionary:
	return {
		"min_width": SLOT_DETAIL_BUBBLE_MIN_WIDTH,
		"max_width": SLOT_DETAIL_BUBBLE_MAX_WIDTH,
		"min_height": SLOT_DETAIL_BUBBLE_MIN_HEIGHT,
		"viewport_margin": SLOT_DETAIL_BUBBLE_VIEWPORT_MARGIN,
		"internal_padding": SLOT_DETAIL_BUBBLE_INTERNAL_PADDING,
	}


func apply_player_hud_layout(nodes: Dictionary, layout_override: Dictionary = {}) -> void:
	HUD_LAYOUT_SCRIPT.apply_player_hud_layout(nodes, layout_override)


func apply_player_hud_chrome(nodes: Dictionary) -> void:
	HUD_CHROME_STYLER_SCRIPT.apply_player_hud_chrome(nodes, _visual_registry())
	_apply_slot_detail_popover_chrome()


func apply_player_footer_layout(nodes: Dictionary) -> void:
	HUD_LAYOUT_SCRIPT.apply_player_footer_layout(nodes)


func apply_combat_player_panel_layout(nodes: Dictionary) -> void:
	HUD_LAYOUT_SCRIPT.apply_combat_player_panel_layout(nodes)


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
	_slot_detail_popover().clear_hover_state()
	_update_selected_slot_popover()


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


func _is_slot_detail_sell_button(global_point: Vector2) -> bool:
	return _slot_detail_popover()._is_slot_detail_sell_button(global_point)


func _point_hits_control_children(root: Control, global_point: Vector2) -> bool:
	return _slot_detail_popover()._point_hits_control_children(root, global_point)


func _control_contains_point(control: Control, global_point: Vector2) -> bool:
	return _slot_detail_popover()._control_contains_point(control, global_point)


func _clear_children(node: Node) -> void:
	UI_UTILS.clear_children(node)


func _visual_registry() -> Variant:
	if _visuals == null:
		_visuals = VISUAL_REGISTRY_SCRIPT.new()
	return _visuals


func _inventory() -> Variant:
	if _inventory_renderer == null:
		_inventory_renderer = INVENTORY_RENDERER_SCRIPT.new()
		_inventory_renderer.bind(
			{
				"content_lookup": Callable(self, "lookup_content_definition"),
				"visual_registry_provider": Callable(self, "_visual_registry"),
				"mastery_highlighter_provider": Callable(self, "_mastery_highlighter"),
				"selected_equipment_slot": func() -> int: return _selected_equipment_slot,
				"selected_consumable_slot": func() -> int: return _selected_consumable_slot,
			},
			{
				"equipment_slot_pressed": Callable(self, "_on_equipment_slot_pressed"),
				"consumable_slot_pressed": Callable(self, "_on_consumable_slot_pressed"),
				"slot_mouse_entered": Callable(self, "_on_slot_mouse_entered"),
				"slot_mouse_exited": Callable(self, "_on_slot_mouse_exited"),
			}
		)
	return _inventory_renderer


func _mastery_highlighter() -> Variant:
	if _mastery_source_highlighter == null:
		_mastery_source_highlighter = MASTERY_SOURCE_HIGHLIGHTER_SCRIPT.new()
		_mastery_source_highlighter.bind_hud_nodes(_hud_nodes)
		_mastery_source_highlighter.set_hover_payload({})
	return _mastery_source_highlighter


func _mastery_panel() -> Variant:
	if _mastery_panel_presenter == null:
		_mastery_panel_presenter = MASTERY_PANEL_SCRIPT.new()
		_mastery_panel_presenter.bind(_mastery_panel_hooks())
	return _mastery_panel_presenter


func _mastery_panel_hooks() -> Dictionary:
	return {
		"clear_children": Callable(self, "_clear_children"),
		"slot_stylebox": Callable(_inventory(), "slot_stylebox"),
		"visual_registry_provider": Callable(self, "_visual_registry"),
		"mastery_highlighter_provider": Callable(self, "_mastery_highlighter"),
		"hud_nodes_provider": func() -> Dictionary: return _hud_nodes,
		"to_parent_rect": Callable(self, "_to_parent_rect"),
		"apply_rect": Callable(self, "_apply_rect"),
	}


func _intent_preview() -> Variant:
	if _intent_preview_presenter == null:
		_intent_preview_presenter = INTENT_PREVIEW_SCRIPT.new()
		_intent_preview_presenter.bind(
			{"hud_nodes_provider": func() -> Dictionary: return _hud_nodes, "player_data_provider": func() -> Dictionary: return _player_data},
			{
				INTENT_PREVIEW_SCRIPT.CALLBACK_INTENT_PREVIEW_HOVERED: func(preview: Dictionary) -> void: intent_preview_hovered.emit(preview),
				INTENT_PREVIEW_SCRIPT.CALLBACK_INTENT_BLOCK_PREVIEW_HOVERED: func(preview: Dictionary) -> void: intent_block_preview_hovered.emit(preview),
				INTENT_PREVIEW_SCRIPT.CALLBACK_INTENT_PREVIEW_HOVER_ENDED: func() -> void: intent_preview_hover_ended.emit(),
			}
		)
	return _intent_preview_presenter


func _slot_detail_popover() -> Variant:
	if _slot_detail_popover_presenter == null:
		_slot_detail_popover_presenter = SLOT_DETAIL_POPOVER_SCRIPT.new()
		_slot_detail_popover_presenter.bind(
			{
				"hud_nodes_provider": func() -> Dictionary: return _hud_nodes,
				"player_data_provider": func() -> Dictionary: return _player_data,
				"selected_equipment_slot_provider": func() -> int: return _selected_equipment_slot,
				"selected_consumable_slot_provider": func() -> int: return _selected_consumable_slot,
				"content_lookup": Callable(self, "lookup_content_definition"),
				"apply_rect": Callable(self, "_apply_rect"),
			},
			{
				SLOT_DETAIL_POPOVER_SCRIPT.CALLBACK_SELL_SLOT_REQUESTED:
				func(slot_type: String, slot_index: int) -> void: sell_slot_requested.emit(slot_type, slot_index),
			}
		)
	return _slot_detail_popover_presenter


func _to_parent_rect(global_rect: Rect2, parent: Control) -> Rect2:
	if parent == null:
		return global_rect
	var parent_inverse := parent.get_global_transform_with_canvas().affine_inverse()
	var local_position: Vector2 = parent_inverse * global_rect.position
	var local_end: Vector2 = parent_inverse * (global_rect.position + global_rect.size)
	return Rect2(local_position, local_end - local_position)


func _apply_rect(control: Control, rect: Rect2) -> void:
	HUD_LAYOUT_SCRIPT._apply_rect(control, rect)
