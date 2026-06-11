extends RefCounted
class_name VisualRegistryData

const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")
const ORB_CATALOG_SCRIPT := preload("res://scripts/ui/visual_registry_orb_catalog.gd")

const PATH_COMBAT_BACKGROUND := "res://resources/art/assetgen/backgrounds/combat_background_candidate_01.png"
const PATH_COMBAT_ENEMY_STAGE_SHEET := "res://resources/art/assetgen/backgrounds/combat_enemy_stage_art_candidate_01.png"
const PATH_SHOP_BACKGROUND := "res://resources/art/assetgen/backgrounds/shop_background_candidate_01.png"
const SHOP_MERCHANT_HEADER_CANDIDATE_PATHS := [
	"res://resources/art/first_pass/derived/shop_ui/shop_merchant_header_v1.png",
	"res://resources/art/first_pass/derived/shop_ui/shop_merchant_header.png",
	"res://resources/art/first_pass/derived/shop_ui/merchant_header.png",
	"res://resources/art/first_pass/backgrounds/shop_merchant_header.png",
	"res://resources/art/first_pass/backgrounds/merchant_header.png",
]
const PATH_ORB_SHEET := "res://resources/art/assetgen/sheets/orb_icons_candidate_04_adaptive_alpha.png"
const PATH_INTENT_SHEET := "res://resources/art/assetgen/sheets/intent_icons_candidate_04_adaptive_alpha.png"
const PATH_RARITY_SHEET := "res://resources/art/assetgen/sheets/rarity_badges_candidate_04_adaptive_alpha.png"
const PATH_MASTERY_SHEET := "res://resources/art/assetgen/sheets/mastery_icons_candidate_04_adaptive_alpha.png"
const PATH_ITEM_SHEET := "res://resources/art/assetgen/sheets/equipment_icons_candidate_04_adaptive_alpha.png"
const PATH_RELIC_SHEET := "res://resources/art/assetgen/sheets/relic_icons_candidate_04_adaptive_alpha.png"
const PATH_DERIVED_ICON_DIR := "res://resources/art/first_pass/derived/icons"
const PATH_DERIVED_ORB_DIR := "res://resources/art/first_pass/derived/orbs"
const PATH_DERIVED_HUD_DIR := "res://resources/art/first_pass/derived/hud"
const PATH_DERIVED_CHROME_DIR := "res://resources/art/first_pass/derived/ui_chrome"
const PATH_DERIVED_COMBAT_UI_DIR := "res://resources/art/first_pass/derived/combat_ui"
const PATH_DERIVED_COMBAT_LAYERS_DIR := "res://resources/art/first_pass/derived/combat_layers"
const PATH_DERIVED_VFX_DIR := "res://resources/art/first_pass/derived/vfx"
const PATH_UI_FRAME_SHEET := "res://resources/art/first_pass/ui/ui_frame_kit_v1.png"
const PATH_UI_BAR_SHEET := "res://resources/art/first_pass/ui/bar_kit_v1.png"
const PATH_UI_SHOP_CARD_SHEET := "res://resources/art/first_pass/ui/shop_card_kit_v1.png"
const PATH_VFX_SHEET := "res://resources/art/assetgen/vfx/board_orb_clear_vfx_candidate_04_adaptive_alpha.png"
const PATH_HERO_PORTRAIT := "res://resources/art/assetgen/heroes/hero_orbwalker_portrait_candidate_01.png"
const PATH_FALLBACK_HERO_PORTRAIT := "res://resources/art/first_pass/heroes/hero_orbwalker.png"
const PATH_RUNTIME_MANIFEST := "res://resources/art/assetgen/runtime/manifest.json"
const PATH_RUNTIME_COLLECTION_UI_DIR := "res://resources/art/assetgen/runtime/collection_ui"
const PATH_RUNTIME_SHOP_UI_DIR := "res://resources/art/assetgen/runtime/shop_ui"

static var orb_catalog: Resource = ORB_CATALOG_SCRIPT.default_catalog()

const INTENT_INDEX_BY_TYPE := {
	0: 0,  # ATTACK
	1: 1,  # BLOCK
	2: 2,  # ATTACK_AND_BLOCK
}

const RARITY_INDEX := {
	"common": 0,
	"uncommon": 1,
	"rare": 2,
}

const ENEMY_PORTRAIT_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"cavern_defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"ash_hunter": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
	"ruin_lancer": "res://resources/art/first_pass/enemies/enemy_ruin_lancer.png",
	"vault_executioner": "res://resources/art/first_pass/enemies/enemy_vault_executioner.png",
	"goldbound_keeper": "res://resources/art/first_pass/enemies/enemy_goldbound_keeper.png",
	"training_striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"training_goblin": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"iron_gate": "res://resources/art/first_pass/enemies/boss_iron_gate.png",
	"burning_knight": "res://resources/art/first_pass/enemies/boss_burning_knight.png",
	"prism_warden": "res://resources/art/first_pass/enemies/boss_prism_warden.png",
	"striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"charger": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
}

const ENEMY_STAGE_BACKGROUND_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/derived/combat_layers/generated_cavern_dungeon_bg_v1.png",
}

const ENEMY_SPRITE_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/enemy_sprites/generated_cavern_striker_sprite_wide_v1.png",
}

const COMBAT_STAGE_ALIAS_BY_ENEMY_ID := {
	"training_striker": "cavern_striker",
	"training_goblin": "cavern_striker",
	"striker": "cavern_striker",
	"defender": "cavern_defender",
	"charger": "ruin_lancer",
}

const RUNTIME_ENEMY_ALIAS_BY_ID := {
	"training_striker": "enemy_cavern_striker",
	"training_goblin": "enemy_cavern_striker",
	"striker": "enemy_cavern_striker",
	"defender": "enemy_cavern_defender",
	"charger": "enemy_charger",
	"cavern_striker": "enemy_cavern_striker",
	"cavern_defender": "enemy_cavern_defender",
	"ash_hunter": "enemy_ash_hunter",
	"ruin_lancer": "enemy_ruin_lancer",
	"vault_executioner": "enemy_vault_executioner",
	"goldbound_keeper": "enemy_goldbound_keeper",
	"iron_gate": "boss_iron_gate",
	"burning_knight": "boss_burning_knight",
	"prism_warden": "boss_prism_warden",
}

const PLACEHOLDER_RUNTIME_ENEMY_KEYS := {
	"enemy_charger": true,
	"enemy_ruin_lancer": true,
	"enemy_vault_executioner": true,
	"enemy_goldbound_keeper": true,
}

const COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID := {
	"cavern_striker": 0,
	"cavern_defender": 1,
	"ash_hunter": 2,
	"ruin_lancer": 1,
	"vault_executioner": 1,
	"goldbound_keeper": 1,
	"iron_gate": 1,
	"burning_knight": 2,
	"prism_warden": 3,
}

const ENEMY_VISUAL_PROFILES := {
	"default": {"scale": 1.0, "offset": Vector2.ZERO, "shadow_scale": 1.0, "shadow_alpha": 0.34},
	"cavern_striker": {"scale": 0.98, "offset": Vector2(0.0, 4.0), "shadow_scale": 0.92, "shadow_alpha": 0.30},
	"cavern_defender": {"scale": 1.0, "offset": Vector2(0.0, 2.0), "shadow_scale": 0.96, "shadow_alpha": 0.32},
	"ash_hunter": {"scale": 1.0, "offset": Vector2(0.0, 2.0), "shadow_scale": 0.95, "shadow_alpha": 0.31},
	"ruin_lancer": {"scale": 1.02, "offset": Vector2(0.0, -2.0), "shadow_scale": 0.98, "shadow_alpha": 0.32},
	"vault_executioner": {"scale": 1.04, "offset": Vector2(0.0, -4.0), "shadow_scale": 1.02, "shadow_alpha": 0.34},
	"goldbound_keeper": {"scale": 1.04, "offset": Vector2(0.0, -2.0), "shadow_scale": 1.04, "shadow_alpha": 0.34},
	"iron_gate": {"scale": 1.16, "offset": Vector2(0.0, -18.0), "shadow_scale": 1.22, "shadow_alpha": 0.38},
	"burning_knight": {"scale": 1.12, "offset": Vector2(0.0, -14.0), "shadow_scale": 1.14, "shadow_alpha": 0.36},
	"prism_warden": {"scale": 1.12, "offset": Vector2(0.0, -14.0), "shadow_scale": 1.14, "shadow_alpha": 0.35},
}

const ICON_INDEX_BY_KEY := {
	"equipment_shortsword": 0,
	"equipment_buckler": 1,
	"equipment_coin_purse": 2,
	"equipment_healing_charm": 3,
	"equipment_stone_ring": 3,
	"equipment_ember_ring": 8,
	"equipment_frost_ring": 8,
	"equipment_leather_gloves": 4,
	"equipment_iron_helm": 1,
	"equipment_combo_lens": 7,
	"equipment_twin_blades": 5,
	"equipment_war_banner": 9,
	"equipment_tower_shield": 6,
	"equipment_merchant_scales": 7,
	"equipment_battle_drum": 14,
	"equipment_earthbreaker_maul": 0,
	"equipment_hearth_amulet": 3,
	"equipment_alchemist_gloves": 4,
	"equipment_training_manual": 12,
	"equipment_mirror_charm": 13,
	"equipment_ruby_brooch": 10,
	"equipment_sapphire_brooch": 10,
	"equipment_emerald_brooch": 10,
	"equipment_royal_seal": 12,
	"equipment_champion_plate": 11,
	"consumable_fire_scroll": 6,
	"consumable_ice_scroll": 7,
	"consumable_earth_scroll": 8,
	"consumable_heart_scroll": 3,
	"consumable_armor_scroll": 1,
	"consumable_gold_scroll": 2,
}

const RELIC_INDEX_BY_KEY := {
	"relic_stalwart_mantle": 0,
	"relic_golden_idol": 1,
	"relic_crown_of_chains": 2,
	"relic_merchant_compass": 3,
	"relic_deep_pockets": 4,
}

const MASTERY_ORB_BY_ICON_KEY := {
	"mastery_fire": ORB_TYPE_SCRIPT.Id.FIRE,
	"mastery_ice": ORB_TYPE_SCRIPT.Id.ICE,
	"mastery_earth": ORB_TYPE_SCRIPT.Id.EARTH,
	"mastery_heart": ORB_TYPE_SCRIPT.Id.HEART,
	"mastery_armor": ORB_TYPE_SCRIPT.Id.ARMOR,
	"mastery_gold": ORB_TYPE_SCRIPT.Id.GOLD,
}

const MASTERY_BEAM_BY_ORB_ID := {
	ORB_TYPE_SCRIPT.Id.FIRE: "fire",
	ORB_TYPE_SCRIPT.Id.ICE: "ice",
	ORB_TYPE_SCRIPT.Id.EARTH: "earth",
	ORB_TYPE_SCRIPT.Id.HEART: "heart",
	ORB_TYPE_SCRIPT.Id.ARMOR: "armor",
	ORB_TYPE_SCRIPT.Id.GOLD: "gold",
}

const MASTERY_CARD_BY_ORB_ID := {
	ORB_TYPE_SCRIPT.Id.FIRE: "fire",
	ORB_TYPE_SCRIPT.Id.ICE: "ice",
	ORB_TYPE_SCRIPT.Id.EARTH: "earth",
	ORB_TYPE_SCRIPT.Id.HEART: "heart",
	ORB_TYPE_SCRIPT.Id.ARMOR: "armor",
	ORB_TYPE_SCRIPT.Id.GOLD: "gold",
}

const MASTERY_ICON_BY_ORB_ID := {
	ORB_TYPE_SCRIPT.Id.FIRE: "mastery_fire",
	ORB_TYPE_SCRIPT.Id.ICE: "mastery_ice",
	ORB_TYPE_SCRIPT.Id.EARTH: "mastery_earth",
	ORB_TYPE_SCRIPT.Id.HEART: "mastery_heart",
	ORB_TYPE_SCRIPT.Id.ARMOR: "mastery_armor",
	ORB_TYPE_SCRIPT.Id.GOLD: "mastery_gold",
}

static var runtime_orb_key_by_id_table: Dictionary = orb_catalog.get_runtime_orb_key_by_id()

const STABLE_PLACEHOLDER_ICON_COLORS := {
	"treasure_chest_elemental": Color(0.90, 0.34, 0.16, 1.0),
	"treasure_chest_fire": Color(0.90, 0.34, 0.16, 1.0),
}

static var derived_orb_filename_by_id_table: Dictionary = orb_catalog.get_derived_orb_filename_by_id()


static func asset_contract_paths() -> Dictionary:
	var imported_textures: Array[String] = [
		PATH_COMBAT_BACKGROUND,
		PATH_COMBAT_ENEMY_STAGE_SHEET,
		PATH_SHOP_BACKGROUND,
		PATH_ORB_SHEET,
		PATH_INTENT_SHEET,
		PATH_RARITY_SHEET,
		PATH_MASTERY_SHEET,
		PATH_ITEM_SHEET,
		PATH_RELIC_SHEET,
		PATH_UI_FRAME_SHEET,
		PATH_UI_BAR_SHEET,
		PATH_UI_SHOP_CARD_SHEET,
		PATH_VFX_SHEET,
		PATH_HERO_PORTRAIT,
		PATH_FALLBACK_HERO_PORTRAIT,
	]
	imported_textures.append_array(dictionary_string_values(ENEMY_PORTRAIT_PATHS))
	imported_textures.append_array(dictionary_string_values(ENEMY_STAGE_BACKGROUND_PATHS))
	imported_textures.append_array(dictionary_string_values(ENEMY_SPRITE_PATHS))
	imported_textures.append_array(derived_orb_contract_paths())
	imported_textures.append_array(path_keys(PATH_RUNTIME_SHOP_UI_DIR, ["shop_action_button_continue", "shop_action_button_reroll"]))
	(
		imported_textures
		. append_array(
			path_keys(
				PATH_DERIVED_HUD_DIR,
				[
					"combo_badge_frame",
					"enemy_hp_bar_fill",
					"enemy_hp_bar_frame",
					"hp_bar_fill",
					"hp_bar_frame",
					"intent_attack",
					"intent_attack_block",
					"intent_block",
					"rarity_common",
					"rarity_rare",
					"rarity_uncommon",
				]
			)
		)
	)
	(
		imported_textures
		. append_array(
			path_keys(
				PATH_DERIVED_CHROME_DIR,
				[
					"mastery_panel_frame",
					"mastery_preview_panel_frame",
					"panel_frame",
					"slot_frame_consumable",
					"slot_frame_equipment",
					"top_bar_frame",
				]
			)
		)
	)
	(
		imported_textures
		. append_array(
			path_keys(
				PATH_DERIVED_COMBAT_UI_DIR,
				[
					"combat_backdrop_scrim",
					"combat_block_badge",
					"combat_board_frame",
					"combat_consumables_rail_frame",
					"combat_corner_ornament",
					"combat_divider_h",
					"combat_enemy_panel",
					"combat_enemy_panel_frame",
					"combat_equipment_rail_frame",
					"combat_intent_badge_attack",
					"combat_intent_badge_block",
					"combat_intent_badge_idle",
					"combat_intent_badge_mixed",
					"combat_loadout_rail",
					"combat_mastery_rail",
					"combat_mastery_rail_frame",
					"combat_player_hud_rail",
					"combat_player_vitals_frame",
					"combat_slot_frame_empty",
					"combat_slot_frame_filled",
					"combat_stage_ash_hunter",
					"combat_stage_burning_knight",
					"combat_stage_cavern_defender",
					"combat_stage_cavern_striker",
					"combat_stage_fallback",
					"combat_stage_goldbound_keeper",
					"combat_stage_iron_gate",
					"combat_stage_prism_warden",
					"combat_stage_ruin_lancer",
					"combat_stage_vault_executioner",
					"combat_timer_center_marker",
					"combat_timer_track",
					"combat_top_bar_frame",
				]
			)
		)
	)
	(
		imported_textures
		. append_array(
			path_keys(
				PATH_DERIVED_VFX_DIR,
				[
					"mastery_beam_armor",
					"mastery_beam_earth",
					"mastery_beam_fire",
					"mastery_beam_gold",
					"mastery_beam_heart",
					"mastery_beam_ice",
					"mastery_gold_impact",
					"mastery_heal_impact",
					"mastery_hit_impact",
					"mastery_shell_armor",
				]
			)
		)
	)
	return {
		"json_files": [PATH_RUNTIME_MANIFEST],
		"directories":
		[
			PATH_DERIVED_ICON_DIR,
			PATH_DERIVED_ORB_DIR,
			PATH_DERIVED_HUD_DIR,
			PATH_DERIVED_CHROME_DIR,
			PATH_DERIVED_COMBAT_UI_DIR,
			PATH_DERIVED_COMBAT_LAYERS_DIR,
			PATH_DERIVED_VFX_DIR,
			PATH_RUNTIME_COLLECTION_UI_DIR,
			PATH_RUNTIME_SHOP_UI_DIR,
		],
		"imported_textures": unique_contract_paths(imported_textures),
		"imported_texture_groups":
		{
			"shop_merchant_header": SHOP_MERCHANT_HEADER_CANDIDATE_PATHS.duplicate(),
		},
	}


static func dictionary_string_values(source: Dictionary) -> Array[String]:
	var values: Array[String] = []
	for key in source.keys():
		var value := String(source[key])
		if value != "":
			values.append(value)
	return values


static func derived_orb_contract_paths() -> Array[String]:
	var paths: Array[String] = []
	var filename_by_id := derived_orb_filename_by_id()
	for orb_id in filename_by_id.keys():
		var file_name := String(filename_by_id[orb_id])
		if file_name != "":
			paths.append("%s/%s" % [PATH_DERIVED_ORB_DIR, file_name])
	return paths


static func runtime_orb_key_by_id() -> Dictionary:
	return runtime_orb_key_by_id_table


static func derived_orb_filename_by_id() -> Dictionary:
	return derived_orb_filename_by_id_table


static func derived_orb_filename_count() -> int:
	return orb_catalog.get_derived_orb_filename_count()


static func catalog_ownership_contract() -> Dictionary:
	return {
		"catalog_is_resource": orb_catalog is Resource and orb_catalog.get_script() == ORB_CATALOG_SCRIPT,
		"runtime_orb_key_by_id": is_same(runtime_orb_key_by_id_table, orb_catalog.get_runtime_orb_key_by_id()),
		"derived_orb_filename_by_id": is_same(derived_orb_filename_by_id_table, orb_catalog.get_derived_orb_filename_by_id()),
		"derived_orb_filename_count": derived_orb_filename_count(),
		"record_count": orb_catalog.orb_records.size(),
	}


static func path_keys(base_path: String, keys: Array) -> Array[String]:
	var paths: Array[String] = []
	for key in keys:
		var key_text := String(key)
		if key_text != "":
			paths.append("%s/%s.png" % [base_path, key_text])
	return paths


static func unique_contract_paths(paths: Array[String]) -> Array[String]:
	var seen := {}
	var unique_paths: Array[String] = []
	for path in paths:
		if path == "" or seen.has(path):
			continue
		seen[path] = true
		unique_paths.append(path)
	unique_paths.sort()
	return unique_paths
