extends RefCounted
class_name CombatPlayerHudPresenter

const EQUIPMENT_RAIL_RECT := Rect2(Vector2(22, 136), Vector2(488, 88))
const CONSUMABLE_RAIL_RECT := Rect2(Vector2(518, 136), Vector2(280, 88))
const HUD_NODE_BINDINGS := {
	"section": "_player_hud_section",
	"mastery_panel": "_elemental_mastery_panel",
	"mastery_title": "_elemental_mastery_title",
	"mastery_cards": "_elemental_mastery_cards",
	"footer_panel": "_player_panel",
	"footer_root": "_player_panel_root",
	"root": "_player_panel_root",
	"hero_card": "_hero_card",
	"hero_card_root": "_hero_card_root",
	"hero_portrait": "_player_portrait",
	"hero_level_badge": "_hero_level_badge",
	"vitals_panel": "_vitals_panel",
	"vitals_frame": "_vitals_frame",
	"hp_bar": "_player_hp_bar",
	"hp_label": "_player_hp_label",
	"armor_bar": "_player_armor_bar",
	"armor_label": "_player_armor_label",
	"armor_badge": "_armor_badge",
	"armor_badge_label": "_armor_badge_label",
	"stat_chip_row": "_stat_chip_row",
	"combat_meta_row": "_combat_meta_row",
	"combat_phase_label": "_phase_label",
	"turn_summary_label": "_turn_summary_label",
	"loadout_frame": "_loadout_frame",
	"loadout_root": "_loadout_root",
	"equipment_label": "_equipment_row_label",
	"equipment_icons": "_equipment_icons",
	"consumable_label": "_consumable_row_label",
	"consumable_icons": "_consumable_icons",
	"relic_label": "_relic_row_label",
	"relic_icons": "_relic_icons",
	"relic_row": "_relic_row",
	"mastery_strip": "_mastery_strip",
	"mastery_root": "_mastery_root",
	"mastery_label": "_mastery_row_label",
	"mastery_icons": "_mastery_icons",
}

var _player_loadout_hud: Variant = null
var _root_nodes: Dictionary = {}


static func hud_nodes_from_root_nodes(root_nodes: Dictionary, popover_parent: Control = null, popover_z_index: int = 210) -> Dictionary:
	var nodes := {}
	for hud_key in HUD_NODE_BINDINGS.keys():
		nodes[hud_key] = root_nodes.get(String(HUD_NODE_BINDINGS[hud_key]), null)
	if popover_parent != null:
		nodes["popover_parent"] = popover_parent
		nodes["popover_z_index"] = popover_z_index
	return nodes


func bind(player_loadout_hud: Variant, root_nodes: Dictionary) -> void:
	_player_loadout_hud = player_loadout_hud
	_root_nodes = root_nodes


func hud_nodes(popover_parent: Control = null, popover_z_index: int = 210) -> Dictionary:
	return hud_nodes_from_root_nodes(_root_nodes, popover_parent, popover_z_index)


func bind_player_hud(popover_parent: Control = null, popover_z_index: int = 210) -> void:
	if _player_loadout_hud == null:
		return
	var resolved_popover_parent: Control = popover_parent if popover_parent != null else _root_nodes.get("_layout_root") as Control
	_player_loadout_hud.bind_player_hud(hud_nodes(resolved_popover_parent, popover_z_index))


func apply_loadout_rail_layout() -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.apply_loadout_rail_layout(
		_root_nodes.get("_equipment_icons") as Control,
		EQUIPMENT_RAIL_RECT,
		_root_nodes.get("_consumable_icons") as Control,
		CONSUMABLE_RAIL_RECT
	)


func render_player_loadout(payload: Dictionary) -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.update_player_data(payload)
	apply_loadout_rail_layout()
	var relic_row := _root_nodes.get("_relic_row") as Control
	if relic_row != null:
		relic_row.visible = false
	var mastery_strip := _root_nodes.get("_mastery_strip") as Control
	if mastery_strip != null:
		mastery_strip.visible = false


func handle_global_click(global_position: Vector2) -> bool:
	if _player_loadout_hud == null:
		return false
	return bool(_player_loadout_hud.handle_global_click(global_position))


func hide_slot_popover() -> void:
	if _player_loadout_hud != null:
		_player_loadout_hud.hide_slot_detail_popover()


func lookup_content_definition(item_id: String) -> Dictionary:
	if _player_loadout_hud == null:
		return {}
	return _player_loadout_hud.lookup_content_definition(item_id)


func clear_hovered_mastery() -> void:
	var mastery_cards := _root_nodes.get("_elemental_mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.clear_hovered_combat_mastery(mastery_cards)


func set_hovered_mastery(orb_id: int) -> void:
	var mastery_cards := _root_nodes.get("_elemental_mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.set_hovered_combat_mastery(mastery_cards, orb_id)


func clear_mastery_feedback() -> void:
	var mastery_cards := _root_nodes.get("_elemental_mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.clear_combat_mastery_feedback(mastery_cards)


func set_mastery_feedback(orb_id: int, total: int) -> void:
	var mastery_cards := _root_nodes.get("_elemental_mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.set_combat_mastery_feedback(mastery_cards, orb_id, total)


func pulse_modifier_sources(sources: Array) -> void:
	if _player_loadout_hud != null:
		_player_loadout_hud.pulse_modifier_sources(sources)


func clear_mastery_hover_ui() -> void:
	var mastery_cards := _root_nodes.get("_elemental_mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.clear_combat_mastery_hover_ui(mastery_cards)


func vfx_target_global(root_node_key: String, vertical_bias: float = 0.5) -> Vector2:
	return _control_target_global(_root_nodes.get(root_node_key) as Control, vertical_bias)


func vfx_size(root_node_key: String) -> Vector2:
	var control := _root_nodes.get(root_node_key) as Control
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	return rect.size


func _control_target_global(control: Control, vertical_bias: float = 0.5) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return Vector2(
		rect.position.x + rect.size.x * 0.5,
		rect.position.y + rect.size.y * clampf(vertical_bias, 0.0, 1.0)
	)
