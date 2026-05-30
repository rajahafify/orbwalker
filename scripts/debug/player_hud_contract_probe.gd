extends RefCounted
class_name PlayerHudContractProbe

const PLAYER_HUD_SCENE_PATH := "res://scenes/ui/player_hud.tscn"
const COMBAT_SCENE_PATH := "res://scenes/combat.tscn"
const SHOP_HOST_SCRIPT_PATH := "res://scripts/scenes/shop.gd"
const SHOP_VIEW_SCRIPT_PATH := "res://scripts/shop/shop_view.gd"
const COMBAT_VIEW_SCRIPT_PATH := "res://scripts/combat/combat_view.gd"
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")

const REQUIRED_SHARED_NODE_NAMES := [
	"ElementalMasteryPanel",
	"ElementalMasteryTitle",
	"ElementalMasteryCards",
	"PlayerPanel",
	"PlayerPanelRoot",
	"HeroCard",
	"HeroCardRoot",
	"PlayerPortrait",
	"HeroLevelBadge",
	"VitalsPanel",
	"VitalsFrame",
	"PlayerHpBar",
	"PlayerHpLabel",
	"PlayerArmorBar",
	"PlayerArmorLabel",
	"ArmorBadge",
	"ArmorBadgeLabel",
	"StatChipRow",
	"CombatMetaRow",
	"CombatPhaseLabel",
	"TurnSummaryLabel",
	"LoadoutFrame",
	"LoadoutRoot",
	"EquipmentLabel",
	"EquipmentIcons",
	"ConsumableLabel",
	"ConsumableIcons",
	"RelicLabel",
	"RelicIcons",
	"RelicRow",
	"MasteryStrip",
	"MasteryRoot",
	"MasteryLabel",
	"MasteryIcons",
]

const REQUIRED_HUD_BINDING_KEYS := [
	"section",
	"mastery_panel",
	"mastery_title",
	"mastery_cards",
	"footer_panel",
	"footer_root",
	"root",
	"hero_card",
	"hero_card_root",
	"hero_portrait",
	"hero_level_badge",
	"vitals_panel",
	"vitals_frame",
	"hp_bar",
	"hp_label",
	"armor_bar",
	"armor_label",
	"armor_badge",
	"armor_badge_label",
	"stat_chip_row",
	"combat_meta_row",
	"combat_phase_label",
	"turn_summary_label",
	"loadout_frame",
	"loadout_root",
	"equipment_label",
	"equipment_icons",
	"consumable_label",
	"consumable_icons",
	"relic_label",
	"relic_icons",
	"relic_row",
	"mastery_strip",
	"mastery_root",
	"mastery_label",
	"mastery_icons",
]


static func run_probe() -> Dictionary:
	var failures: Array[String] = []
	_check_shared_scene_tree(failures)
	_check_combat_instances_shared_scene(failures)
	_check_shop_instances_shared_scene(failures)
	_check_binding_key_contract(failures)
	_check_shop_layout_preset_contract(failures)
	return {
		"status": "ok" if failures.is_empty() else "failed",
		"failures": failures,
	}


static func _check_shared_scene_tree(failures: Array[String]) -> void:
	var packed := ResourceLoader.load(PLAYER_HUD_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		failures.append("Shared PlayerHUD scene failed to load: %s" % PLAYER_HUD_SCENE_PATH)
		return
	var hud := packed.instantiate()
	for node_name in REQUIRED_SHARED_NODE_NAMES:
		if hud.get_node_or_null("%s%s" % ["%", node_name]) == null:
			failures.append("Shared PlayerHUD scene is missing node: %s" % node_name)
	hud.free()


static func _check_combat_instances_shared_scene(failures: Array[String]) -> void:
	var packed := ResourceLoader.load(COMBAT_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		failures.append("Combat scene failed to load: %s" % COMBAT_SCENE_PATH)
		return
	var combat := packed.instantiate()
	var hud := combat.get_node_or_null("CombatLayoutRoot/PlayerHudSection")
	if hud == null:
		failures.append("Combat scene is missing CombatLayoutRoot/PlayerHudSection")
	elif hud.scene_file_path != PLAYER_HUD_SCENE_PATH:
		failures.append("Combat PlayerHudSection must instance %s, got %s" % [PLAYER_HUD_SCENE_PATH, hud.scene_file_path])
	combat.free()


static func _check_shop_instances_shared_scene(failures: Array[String]) -> void:
	var host_source := FileAccess.get_file_as_string(SHOP_HOST_SCRIPT_PATH)
	if host_source.is_empty():
		failures.append("Shop host script failed to read: %s" % SHOP_HOST_SCRIPT_PATH)
	elif not host_source.contains('SHOP_VIEW_SCRIPT := preload("%s")' % SHOP_VIEW_SCRIPT_PATH):
		failures.append("Shop host must preload ShopView script")

	var shop_source := FileAccess.get_file_as_string(SHOP_VIEW_SCRIPT_PATH)
	if shop_source.is_empty():
		failures.append("Shop view script failed to read: %s" % SHOP_VIEW_SCRIPT_PATH)
		return
	if not shop_source.contains('PLAYER_HUD_SCENE := preload("%s")' % PLAYER_HUD_SCENE_PATH):
		failures.append("Shop view must preload the shared PlayerHUD scene instead of building a private HUD")
	if not shop_source.contains("_player_hud_section = PLAYER_HUD_SCENE.instantiate()"):
		failures.append("Shop view must instance PLAYER_HUD_SCENE for PlayerHudSection")


static func _check_binding_key_contract(failures: Array[String]) -> void:
	_check_callable_binding_keys(COMBAT_VIEW_SCRIPT_PATH, "_combat_player_hud_nodes", failures)
	_check_callable_binding_keys(SHOP_VIEW_SCRIPT_PATH, "_shop_player_hud_nodes", failures)


static func _check_callable_binding_keys(path: String, function_name: String, failures: Array[String]) -> void:
	var script := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Script
	if script == null:
		failures.append("Failed to load binding script: %s" % path)
		return
	var owner: Variant = script.new()
	if owner == null:
		failures.append("Failed to instantiate binding script: %s" % path)
		return
	if not owner.has_method(function_name):
		failures.append("Missing %s in %s" % [function_name, path])
		return
	var result: Variant = owner.call(function_name)
	if not (result is Dictionary):
		failures.append("%s in %s must return a Dictionary" % [function_name, path])
		return
	var bindings: Dictionary = result
	for key in REQUIRED_HUD_BINDING_KEYS:
		if not bindings.has(key):
			failures.append("%s is missing HUD binding key: %s" % [function_name, key])


static func _check_shop_layout_preset_contract(failures: Array[String]) -> void:
	var preset: Dictionary = PLAYER_LOADOUT_HUD_SCRIPT.shop_player_hud_layout_preset()
	var keys := preset.keys()
	if not preset.has("section"):
		failures.append("Shop PlayerHUD preset must position the whole section")
	for key in keys:
		if key != "section":
			failures.append("Shop PlayerHUD preset must not override internal HUD layout key: %s" % key)
