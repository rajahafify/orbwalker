extends RefCounted
class_name PlayerLoadoutHudLayout

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
const MASTERY_SLOT_SIZE := Vector2(44, 44)
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


static func shop_player_hud_layout_preset() -> Dictionary:
	return SHOP_PLAYER_HUD_LAYOUT_PRESET.duplicate(true)


static func apply_loadout_rail_layout(equipment_row: Control, equipment_rect: Rect2, consumable_row: Control, consumable_rect: Rect2) -> void:
	_apply_rect(equipment_row, equipment_rect)
	_apply_rect(consumable_row, consumable_rect)


static func apply_player_hud_layout(nodes: Dictionary, layout_override: Dictionary = {}) -> void:
	_apply_node_rect(nodes, "section", _layout_rect(layout_override, "section", PLAYER_HUD_SECTION_RECT))
	_apply_node_rect(nodes, "mastery_panel", _layout_rect(layout_override, "mastery_panel", PLAYER_HUD_MASTERY_PANEL_RECT))
	_apply_node_rect(nodes, "mastery_title", _layout_rect(layout_override, "mastery_title", PLAYER_HUD_MASTERY_TITLE_RECT))
	_apply_node_rect(nodes, "mastery_cards", _layout_rect(layout_override, "mastery_cards", PLAYER_HUD_MASTERY_CARDS_RECT))
	_apply_node_rect(nodes, "footer_panel", _layout_rect(layout_override, "footer_panel", PLAYER_HUD_FOOTER_PANEL_RECT))
	apply_player_footer_layout(nodes)


static func apply_player_footer_layout(nodes: Dictionary) -> void:
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


static func apply_combat_player_panel_layout(nodes: Dictionary) -> void:
	apply_player_footer_layout(nodes)


static func _adopt_player_hud_relic_nodes(nodes: Dictionary) -> void:
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


static func _layout_rect(layout_override: Dictionary, key: String, fallback: Rect2) -> Rect2:
	if layout_override.has(key):
		var value: Variant = layout_override[key]
		if value is Rect2:
			return value
	return fallback


static func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size
	control.custom_minimum_size = rect.size


static func _apply_node_rect(nodes: Dictionary, key: String, rect: Rect2) -> void:
	_apply_rect(nodes.get(key, null) as Control, rect)


static func _apply_node_min_size(nodes: Dictionary, key: String, size: Vector2) -> void:
	var control := nodes.get(key, null) as Control
	if control == null:
		return
	control.custom_minimum_size = size


static func _set_node_visible(nodes: Dictionary, key: String, visible: bool) -> void:
	var canvas_item := nodes.get(key, null) as CanvasItem
	if canvas_item != null:
		canvas_item.visible = visible
