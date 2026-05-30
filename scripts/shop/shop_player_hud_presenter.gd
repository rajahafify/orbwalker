extends RefCounted
class_name ShopPlayerHudPresenter

signal equipment_slot_selected(index: int)
signal consumable_slot_selected(index: int)
signal sell_slot_requested(slot_type: String, slot_index: int)

const PLAYER_HUD_SCENE := preload("res://scenes/ui/player_hud.tscn")

const HUD_NODE_NAMES := {
	"mastery_panel": "ElementalMasteryPanel",
	"mastery_title": "ElementalMasteryTitle",
	"mastery_cards": "ElementalMasteryCards",
	"footer_panel": "PlayerPanel",
	"footer_root": "PlayerPanelRoot",
	"root": "PlayerPanelRoot",
	"hero_card": "HeroCard",
	"hero_card_root": "HeroCardRoot",
	"hero_portrait": "PlayerPortrait",
	"hero_level_badge": "HeroLevelBadge",
	"vitals_panel": "VitalsPanel",
	"vitals_frame": "VitalsFrame",
	"hp_bar": "PlayerHpBar",
	"hp_label": "PlayerHpLabel",
	"armor_bar": "PlayerArmorBar",
	"armor_label": "PlayerArmorLabel",
	"armor_badge": "ArmorBadge",
	"armor_badge_label": "ArmorBadgeLabel",
	"loadout_frame": "LoadoutFrame",
	"loadout_root": "LoadoutRoot",
	"equipment_label": "EquipmentLabel",
	"equipment_icons": "EquipmentIcons",
	"consumable_label": "ConsumableLabel",
	"consumable_icons": "ConsumableIcons",
	"relic_label": "RelicLabel",
	"relic_icons": "RelicIcons",
	"relic_row": "RelicRow",
	"mastery_strip": "MasteryStrip",
	"mastery_root": "MasteryRoot",
	"mastery_label": "MasteryLabel",
	"mastery_icons": "MasteryIcons",
	"stat_chip_row": "StatChipRow",
	"combat_meta_row": "CombatMetaRow",
	"combat_phase_label": "CombatPhaseLabel",
	"turn_summary_label": "TurnSummaryLabel",
}
const MUTED_COLOR := Color(0.72, 0.62, 0.45, 1.0)
const INK_COLOR := Color(0.96, 0.90, 0.78, 1.0)

var _parent: Control
var _player_loadout_hud: Variant = null
var _visuals: Variant = null
var _hud_section: Panel
var _hud_nodes: Dictionary = {}


static func empty_hud_nodes() -> Dictionary:
	var nodes := {
		"section": null,
	}
	for hud_key in HUD_NODE_NAMES.keys():
		nodes[hud_key] = null
	return nodes


static func hud_nodes_from_section(hud_section: Node) -> Dictionary:
	var nodes := empty_hud_nodes()
	nodes["section"] = hud_section
	if hud_section == null:
		return nodes
	for hud_key in HUD_NODE_NAMES.keys():
		nodes[hud_key] = hud_section.get_node_or_null("%s%s" % ["%", String(HUD_NODE_NAMES[hud_key])])
	return nodes


static func player_hud_scene_path() -> String:
	return PLAYER_HUD_SCENE.resource_path


func bind(parent: Control, player_loadout_hud: Variant, visuals: Variant) -> void:
	_parent = parent
	_player_loadout_hud = player_loadout_hud
	_visuals = visuals
	_connect_hud_signals()


func ensure_scene() -> void:
	if _hud_section != null or _parent == null:
		return
	_hud_section = PLAYER_HUD_SCENE.instantiate() as Panel
	_hud_section.name = "PlayerHudSection"
	_hud_section.clip_contents = false
	_parent.add_child(_hud_section)
	_hud_nodes = hud_nodes_from_section(_hud_section)


func hud_nodes(popover_parent: Control = null, popover_z_index: int = 51) -> Dictionary:
	ensure_scene()
	var nodes := _hud_nodes.duplicate()
	if nodes.is_empty():
		nodes = empty_hud_nodes()
	if popover_parent != null:
		nodes["popover_parent"] = popover_parent
		nodes["popover_z_index"] = popover_z_index
	return nodes


func bind_player_hud(popover_parent: Control, popover_z_index: int = 51) -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.bind_player_hud(hud_nodes(popover_parent, popover_z_index))


func set_layout_override(layout_override: Dictionary) -> void:
	if _player_loadout_hud != null:
		_player_loadout_hud.set_player_hud_layout_override(layout_override)


func update_layout() -> void:
	if _player_loadout_hud != null:
		_player_loadout_hud.update_player_hud_layout()


func render_player_build(snapshot: Dictionary) -> void:
	if _player_loadout_hud == null:
		return
	var progression_snapshot: Dictionary = snapshot.get("progression", {})
	var player_state = snapshot.get("player_state")
	_player_loadout_hud.set_selected_equipment_slot(int(snapshot.get("selected_equipment_slot", -1)))
	_player_loadout_hud.set_selected_consumable_slot(int(snapshot.get("selected_consumable_slot", -1)))
	_player_loadout_hud.update_player_data({
		"player_state": player_state,
		"progression": progression_snapshot,
		"hero_portrait": _visuals.hero_portrait() if _visuals != null else null,
		"max_visible_relics": 2,
		"selectable_equipment": true,
		"selectable_consumables": true,
	})


func render_elemental_mastery_panel(mastery_levels: Dictionary) -> void:
	ensure_scene()
	var mastery_cards := _hud_nodes.get("mastery_cards") as Control
	if _player_loadout_hud != null and mastery_cards != null:
		_player_loadout_hud.populate_combat_mastery_panel(mastery_cards, mastery_levels)


func apply_chrome() -> void:
	ensure_scene()
	for key in ["equipment_label", "consumable_label", "relic_label", "mastery_title"]:
		_apply_label_color(key, MUTED_COLOR, false)
	_apply_label_color("hp_label", INK_COLOR, true)
	if _player_loadout_hud != null:
		_player_loadout_hud.apply_player_hud_chrome(hud_nodes())


func handle_global_click(global_position: Vector2) -> bool:
	if _player_loadout_hud == null:
		return false
	return bool(_player_loadout_hud.handle_global_click(global_position))


func clear_inventory_focus() -> void:
	if _player_loadout_hud == null:
		return
	_player_loadout_hud.set_selected_equipment_slot(-1)
	_player_loadout_hud.set_selected_consumable_slot(-1)
	_player_loadout_hud.hide_slot_detail_popover()


func lookup_content_definition(content_id: String) -> Dictionary:
	if _player_loadout_hud == null:
		return {}
	return _player_loadout_hud.lookup_content_definition(content_id)


func section() -> Panel:
	ensure_scene()
	return _hud_section


func mastery_cards() -> Control:
	ensure_scene()
	return _hud_nodes.get("mastery_cards") as Control


func _connect_hud_signals() -> void:
	if _player_loadout_hud == null:
		return
	if not _player_loadout_hud.equipment_slot_selected.is_connected(_on_equipment_slot_selected):
		_player_loadout_hud.equipment_slot_selected.connect(_on_equipment_slot_selected)
	if not _player_loadout_hud.consumable_slot_selected.is_connected(_on_consumable_slot_selected):
		_player_loadout_hud.consumable_slot_selected.connect(_on_consumable_slot_selected)
	if not _player_loadout_hud.sell_slot_requested.is_connected(_on_sell_slot_requested):
		_player_loadout_hud.sell_slot_requested.connect(_on_sell_slot_requested)


func _on_equipment_slot_selected(index: int) -> void:
	equipment_slot_selected.emit(index)


func _on_consumable_slot_selected(index: int) -> void:
	consumable_slot_selected.emit(index)


func _on_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	sell_slot_requested.emit(slot_type, slot_index)


func _apply_label_color(key: String, color: Color, outlined: bool) -> void:
	var label := _hud_nodes.get(key) as Label
	if label == null:
		return
	label.add_theme_color_override("font_color", color)
	if outlined:
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
