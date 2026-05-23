extends RefCounted
class_name VisualRegistry

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

const _INTENT_INDEX_BY_TYPE := {
	0: 0, # ATTACK
	1: 1, # BLOCK
	2: 2, # ATTACK_AND_BLOCK
}

const _RARITY_INDEX := {
	"common": 0,
	"uncommon": 1,
	"rare": 2,
}

const _ENEMY_PORTRAIT_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"cavern_defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"ash_hunter": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
	"ruin_lancer": "res://resources/art/first_pass/enemies/enemy_ruin_lancer.png",
	"vault_executioner": "res://resources/art/first_pass/enemies/enemy_vault_executioner.png",
	"goldbound_keeper": "res://resources/art/first_pass/enemies/enemy_goldbound_keeper.png",
	"training_goblin": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"iron_gate": "res://resources/art/first_pass/enemies/boss_iron_gate.png",
	"burning_knight": "res://resources/art/first_pass/enemies/boss_burning_knight.png",
	"prism_warden": "res://resources/art/first_pass/enemies/boss_prism_warden.png",
	"striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"charger": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
}

const _COMBAT_STAGE_ALIAS_BY_ENEMY_ID := {
	"training_goblin": "cavern_striker",
	"striker": "cavern_striker",
	"defender": "cavern_defender",
	"charger": "ruin_lancer",
}

const _RUNTIME_ENEMY_ALIAS_BY_ID := {
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

const _PLACEHOLDER_RUNTIME_ENEMY_KEYS := {
	"enemy_charger": true,
	"enemy_ruin_lancer": true,
	"enemy_vault_executioner": true,
	"enemy_goldbound_keeper": true,
}

const _COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID := {
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

const _ENEMY_VISUAL_PROFILES := {
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

const _ENEMY_STAGE_BACKGROUND_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/derived/combat_layers/generated_cavern_dungeon_bg_v1.png",
}

const _ENEMY_SPRITE_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/enemy_sprites/generated_cavern_striker_sprite_wide_v1.png",
}

const _ICON_INDEX_BY_KEY := {
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

const _RELIC_INDEX_BY_KEY := {
	"relic_stalwart_mantle": 0,
	"relic_golden_idol": 1,
	"relic_crown_of_chains": 2,
	"relic_merchant_compass": 3,
	"relic_deep_pockets": 4,
}

const _MASTERY_ORB_BY_ICON_KEY := {
	"mastery_fire": OrbType.Id.FIRE,
	"mastery_ice": OrbType.Id.ICE,
	"mastery_earth": OrbType.Id.EARTH,
	"mastery_heart": OrbType.Id.HEART,
	"mastery_armor": OrbType.Id.ARMOR,
	"mastery_gold": OrbType.Id.GOLD,
}

const _MASTERY_BEAM_BY_ORB_ID := {
	OrbType.Id.FIRE: "fire",
	OrbType.Id.ICE: "ice",
	OrbType.Id.EARTH: "earth",
	OrbType.Id.HEART: "heart",
	OrbType.Id.ARMOR: "armor",
	OrbType.Id.GOLD: "gold",
}
const _MASTERY_CARD_BY_ORB_ID := {
	OrbType.Id.FIRE: "fire",
	OrbType.Id.ICE: "ice",
	OrbType.Id.EARTH: "earth",
	OrbType.Id.HEART: "heart",
	OrbType.Id.ARMOR: "armor",
	OrbType.Id.GOLD: "gold",
}
const _MASTERY_ICON_BY_ORB_ID := {
	OrbType.Id.FIRE: "mastery_fire",
	OrbType.Id.ICE: "mastery_ice",
	OrbType.Id.EARTH: "mastery_earth",
	OrbType.Id.HEART: "mastery_heart",
	OrbType.Id.ARMOR: "mastery_armor",
	OrbType.Id.GOLD: "mastery_gold",
}
const _DERIVED_ORB_FILENAME_BY_ID := {
	OrbType.Id.FIRE: "orb_fire_clean.png",
	OrbType.Id.ICE: "orb_ice_clean.png",
	OrbType.Id.EARTH: "orb_earth_clean.png",
	OrbType.Id.HEART: "orb_heart_clean.png",
	OrbType.Id.ARMOR: "orb_armor_clean.png",
	OrbType.Id.GOLD: "orb_gold_clean.png",
}
const _RUNTIME_ORB_KEY_BY_ID := {
	OrbType.Id.FIRE: "fire",
	OrbType.Id.ICE: "ice",
	OrbType.Id.EARTH: "earth",
	OrbType.Id.HEART: "heart",
	OrbType.Id.ARMOR: "armor",
	OrbType.Id.GOLD: "gold",
}

const _STABLE_PLACEHOLDER_ICON_COLORS := {
	"treasure_chest_elemental": Color(0.90, 0.34, 0.16, 1.0),
	"treasure_chest_fire": Color(0.90, 0.34, 0.16, 1.0),
}

var _warned_keys: Dictionary = {}
var _placeholder_cache: Dictionary = {}
var _enemy_portrait_textures: Dictionary = {}
var _enemy_stage_background_textures: Dictionary = {}
var _enemy_sprite_textures: Dictionary = {}
var _combat_enemy_stage_textures: Dictionary = {}
var _orb_textures: Dictionary = {}
var _intent_textures: Dictionary = {}
var _rarity_textures: Dictionary = {}
var _mastery_textures: Dictionary = {}
var _icon_textures: Dictionary = {}
var _relic_textures: Dictionary = {}
var _derived_icon_textures: Dictionary = {}
var _derived_hud_textures: Dictionary = {}
var _derived_chrome_textures: Dictionary = {}
var _derived_combat_ui_textures: Dictionary = {}
var _vfx_textures: Dictionary = {}
var _runtime_manifest: Dictionary = {}
var _runtime_texture_cache: Dictionary = {}

var _combat_background: Texture2D
var _combat_enemy_stage_sheet: Texture2D
var _shop_background: Texture2D
var _shop_merchant_header: Texture2D
var _hero_portrait: Texture2D
var _ui_frames: Texture2D
var _ui_bars: Texture2D
var _ui_shop_cards: Texture2D
var _backgrounds_loaded := false
var _shop_merchant_header_loaded := false
var _hero_portrait_loaded := false
var _ui_sheets_loaded := false
var _orb_textures_built := false
var _intent_textures_built := false
var _rarity_textures_built := false
var _mastery_textures_built := false
var _icon_textures_built := false
var _relic_textures_built := false
var _vfx_textures_built := false
var _runtime_manifest_loaded := false


func _init() -> void:
	pass


func combat_background() -> Texture2D:
	_ensure_background_textures()
	return _combat_background if _combat_background != null else placeholder_texture("combat_background")


func shop_background() -> Texture2D:
	_ensure_background_textures()
	return _shop_background if _shop_background != null else placeholder_texture("shop_background")


func shop_merchant_header() -> Texture2D:
	_ensure_shop_merchant_header_texture()
	if _shop_merchant_header != null:
		return _shop_merchant_header
	return shop_background()


func enemy_portrait(enemy_id: String) -> Texture2D:
	var normalized_id := enemy_id.strip_edges().to_lower()
	if _enemy_portrait_textures.has(normalized_id):
		return _enemy_portrait_textures[normalized_id]
	var path := String(_ENEMY_PORTRAIT_PATHS.get(normalized_id, ""))
	if path == "":
		_warn_missing("enemy_id:%s" % normalized_id)
		var fallback := String(_ENEMY_PORTRAIT_PATHS.get("cavern_striker", ""))
		var fallback_texture := _safe_load_texture(fallback, "enemy_fallback")
		if fallback_texture != null:
			_enemy_portrait_textures[normalized_id] = fallback_texture
			return fallback_texture
		return placeholder_texture("enemy_portrait")
	var loaded := _safe_load_texture(path, "enemy:%s" % normalized_id)
	if loaded != null:
		_enemy_portrait_textures[normalized_id] = loaded
		return loaded
	return placeholder_texture("enemy_portrait")


func enemy_stage_background(enemy_id: String) -> Texture2D:
	var normalized_id := _normalized_enemy_visual_id(enemy_id)
	if _enemy_stage_background_textures.has(normalized_id):
		return _enemy_stage_background_textures[normalized_id]
	var path := String(_ENEMY_STAGE_BACKGROUND_PATHS.get(normalized_id, ""))
	if path == "":
		return combat_background()
	var loaded := _safe_load_texture(path, "enemy_stage_bg:%s" % normalized_id)
	if loaded != null:
		_enemy_stage_background_textures[normalized_id] = loaded
		return loaded
	return combat_background()


func enemy_sprite(enemy_id: String) -> Texture2D:
	var normalized_id := _normalized_enemy_visual_id(enemy_id)
	if _enemy_sprite_textures.has(normalized_id):
		return _enemy_sprite_textures[normalized_id]
	var runtime_key := _runtime_enemy_key(enemy_id)
	var runtime_texture := _runtime_texture("enemies", runtime_key)
	if runtime_texture != null:
		_enemy_sprite_textures[normalized_id] = runtime_texture
		return runtime_texture
	_warn_missing("runtime_enemy:%s:%s" % [normalized_id, runtime_key])
	var path := String(_ENEMY_SPRITE_PATHS.get(normalized_id, ""))
	if path != "":
		var loaded := _safe_load_texture(path, "enemy_sprite:%s" % normalized_id)
		if loaded != null:
			_enemy_sprite_textures[normalized_id] = loaded
			return loaded
	var fallback := enemy_portrait(normalized_id)
	_enemy_sprite_textures[normalized_id] = fallback
	return fallback


func enemy_visual_profile(enemy_id: String) -> Dictionary:
	var normalized_id := _normalized_enemy_visual_id(enemy_id)
	var profile := Dictionary(_ENEMY_VISUAL_PROFILES.get(normalized_id, _ENEMY_VISUAL_PROFILES["default"])).duplicate(true)
	var offset: Variant = profile.get("offset", Vector2.ZERO)
	if not (offset is Vector2):
		profile["offset"] = Vector2.ZERO
	return profile


func combat_enemy_visual_debug_info(enemy_id: String) -> Dictionary:
	var normalized_id := _normalized_enemy_visual_id(enemy_id)
	var runtime_key := _runtime_enemy_key(enemy_id)
	var runtime_entry := _runtime_texture_entry("enemies", runtime_key)
	var stage_key := "combat_stage_%s" % normalized_id
	var stage_path := _combat_stage_sheet_debug_path(normalized_id)
	var stage_fallback := false
	if stage_path == "":
		stage_path = _derived_texture_path(PATH_DERIVED_COMBAT_UI_DIR, stage_key)
	if stage_path == "":
		stage_path = _derived_texture_path(PATH_DERIVED_COMBAT_UI_DIR, "combat_stage_fallback")
		stage_fallback = stage_path != ""
	var sprite_path := String(runtime_entry.get("path", ""))
	var sprite_fallback := sprite_path == "" or not _resource_or_file_exists(sprite_path)
	if sprite_fallback:
		sprite_path = String(_ENEMY_SPRITE_PATHS.get(normalized_id, ""))
	if sprite_path == "":
		sprite_path = String(_ENEMY_PORTRAIT_PATHS.get(normalized_id, ""))
	return {
		"enemy_id": enemy_id,
		"normalized_id": normalized_id,
		"runtime_key": runtime_key,
		"sprite_path": sprite_path,
		"sprite_source": String(runtime_entry.get("source", "")),
		"sprite_background_removed": String(runtime_entry.get("background_removed", "")),
		"sprite_placeholder_like": _runtime_enemy_placeholder_like(runtime_key, runtime_entry),
		"sprite_fallback": sprite_fallback,
		"stage_key": stage_key,
		"stage_path": stage_path,
		"stage_fallback": stage_fallback,
		"profile": enemy_visual_profile(enemy_id),
	}


func hero_portrait() -> Texture2D:
	_ensure_hero_portrait()
	if _hero_portrait != null:
		return _hero_portrait
	var fallback := placeholder_texture("hero_portrait_missing", Color(0.10, 0.16, 0.24, 1.0), Vector2i(192, 192))
	return fallback


func orb_texture(orb_id: int) -> Texture2D:
	_ensure_orb_textures()
	return _orb_textures.get(orb_id, placeholder_texture("orb_missing"))


func intent_badge(intent_type: int) -> Texture2D:
	var hud_key := ""
	match intent_type:
		0:
			hud_key = "intent_attack"
		1:
			hud_key = "intent_block"
		2:
			hud_key = "intent_attack_block"
	if hud_key != "":
		var hud_badge := clean_hud_texture(hud_key)
		if hud_badge != null:
			return hud_badge
	_ensure_intent_textures()
	var index := int(_INTENT_INDEX_BY_TYPE.get(intent_type, -1))
	if index < 0:
		_warn_missing("intent_type:%d" % intent_type)
		return placeholder_texture("intent_missing")
	var texture: Texture2D = _intent_textures.get(index, null)
	if texture != null:
		return texture
	return null


func rarity_badge(rarity: String) -> Texture2D:
	var key := rarity.to_lower()
	var hud_badge := hud_texture("rarity_%s" % key, false)
	if hud_badge != null:
		return hud_badge
	var index := int(_RARITY_INDEX.get(key, -1))
	if index < 0:
		_warn_missing("rarity:%s" % rarity)
		return placeholder_texture("rarity_missing")
	_ensure_rarity_textures()
	return _rarity_textures.get(index, placeholder_texture("rarity_missing"))


func mastery_icon(orb_id: int) -> Texture2D:
	var runtime_key := String(_MASTERY_ICON_BY_ORB_ID.get(orb_id, ""))
	if runtime_key != "":
		var runtime_texture := _runtime_texture("mastery", runtime_key)
		if runtime_texture != null:
			return runtime_texture
	_ensure_mastery_textures()
	return _mastery_textures.get(orb_id, placeholder_texture("mastery_missing"))


func menu_mastery_icon(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return placeholder_texture("mastery_missing")
	var icon_key := String(_MASTERY_ICON_BY_ORB_ID.get(orb_id, ""))
	if icon_key == "":
		return placeholder_texture("mastery_missing")
	var runtime_icon := _runtime_icon_texture(icon_key)
	if runtime_icon != null:
		return runtime_icon
	var menu_icon := _load_derived_icon(icon_key)
	if menu_icon != null:
		return menu_icon
	var fallback := mastery_icon(orb_id)
	return fallback if fallback != null else placeholder_texture("mastery_missing")


func icon_for_key(icon_key: String) -> Texture2D:
	var clean_icon := clean_icon_for_key(icon_key, false)
	if clean_icon != null:
		return clean_icon
	_warn_missing("icon_key:%s" % icon_key)
	return placeholder_texture("icon_missing")


func mastery_beam_texture(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return null
	var beam_suffix := String(_MASTERY_BEAM_BY_ORB_ID.get(orb_id, ""))
	if beam_suffix == "":
		return null
	return _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_beam_%s" % beam_suffix, _vfx_textures)


func mastery_panel_frame_texture() -> Texture2D:
	var frame_texture := chrome_texture("mastery_panel_frame", false)
	if frame_texture != null:
		return frame_texture
	return placeholder_texture("mastery_panel_frame_missing", Color(0.10, 0.10, 0.14, 0.94), Vector2i(8, 8))


func mastery_card_texture(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_missing", _derived_chrome_textures)
	var card_suffix := String(_MASTERY_CARD_BY_ORB_ID.get(orb_id, ""))
	if card_suffix == "":
		return _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_missing", _derived_chrome_textures)
	var card_texture := _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_%s" % card_suffix, _derived_chrome_textures)
	if card_texture != null:
		return card_texture
	card_texture = _load_derived_texture(PATH_DERIVED_HUD_DIR, "mastery_card_%s" % card_suffix, _derived_hud_textures)
	if card_texture != null:
		return card_texture
	return mastery_icon(orb_id)


func mastery_shell_texture() -> Texture2D:
	var shell_texture := _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell_armor", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	shell_texture = _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	return placeholder_texture("mastery_shell_missing", Color(0.25, 0.34, 0.52, 0.90), Vector2i(120, 120))


func mastery_impact_texture(kind: String) -> Texture2D:
	var clean_kind := kind.strip_edges().to_lower()
	if clean_kind == "":
		return null
	_ensure_vfx_textures()
	var post_match_key := "post_match_%s" % clean_kind
	if _vfx_textures.has(post_match_key):
		return _vfx_textures[post_match_key]
	if clean_kind == "heal":
		return _vfx_textures.get("post_match_heart", null)
	if clean_kind == "block":
		return _vfx_textures.get("post_match_armor", null)
	if clean_kind == "damage":
		return _vfx_textures.get("post_match_damage", null)
	if clean_kind == "armor":
		var armor_texture: Texture2D = _vfx_textures.get("post_match_armor", null)
		if armor_texture != null:
			return armor_texture
		return mastery_shell_texture()
	var impact_lookup := {
		"fire": "hit",
		"ice": "hit",
		"earth": "hit",
		"heart": "heal",
		"gold": "gold",
	}
	var impact_suffix := String(impact_lookup.get(clean_kind, ""))
	if impact_suffix != "":
		var impact_texture := _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_%s_impact" % impact_suffix, _vfx_textures)
		if impact_texture != null:
			return impact_texture
	return null


func clean_icon_for_key(icon_key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := icon_key.strip_edges().to_lower()
	var runtime_icon := _runtime_icon_texture(normalized_key)
	if runtime_icon != null:
		return runtime_icon
	if _MASTERY_ORB_BY_ICON_KEY.has(normalized_key):
		return mastery_icon(int(_MASTERY_ORB_BY_ICON_KEY[normalized_key]))
	var relic_index := int(_RELIC_INDEX_BY_KEY.get(normalized_key, -1))
	if relic_index >= 0:
		_ensure_relic_textures()
		var relic_texture: Texture2D = _relic_textures.get(relic_index, null)
		if relic_texture != null:
			return relic_texture
	var concrete_icon := _load_derived_icon(normalized_key)
	if concrete_icon != null:
		return concrete_icon
	var index := int(_ICON_INDEX_BY_KEY.get(normalized_key, -1))
	if index >= 0:
		_ensure_icon_textures()
		var atlas_texture: Texture2D = _icon_textures.get(index, null)
		if atlas_texture != null:
			return atlas_texture
	if _STABLE_PLACEHOLDER_ICON_COLORS.has(normalized_key):
		var placeholder_color: Color = _STABLE_PLACEHOLDER_ICON_COLORS[normalized_key]
		return placeholder_texture("stable_icon_%s" % normalized_key, placeholder_color)
	if index < 0:
		if use_placeholder:
			_warn_missing("icon_key:%s" % icon_key)
			return placeholder_texture("icon_missing")
		return null
	if use_placeholder:
		return placeholder_texture("icon_missing")
	return null


func ui_frame_sheet() -> Texture2D:
	_ensure_ui_sheets()
	return _ui_frames if _ui_frames != null else placeholder_texture("ui_frames")


func ui_bar_sheet() -> Texture2D:
	_ensure_ui_sheets()
	return _ui_bars if _ui_bars != null else placeholder_texture("ui_bars")


func ui_shop_card_sheet() -> Texture2D:
	_ensure_ui_sheets()
	return _ui_shop_cards if _ui_shop_cards != null else placeholder_texture("ui_shop_cards")


func hud_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	var texture := _load_derived_texture(PATH_DERIVED_HUD_DIR, normalized_key, _derived_hud_textures)
	if texture != null:
		return texture
	if use_placeholder:
		_warn_missing("hud:%s" % normalized_key)
		return placeholder_texture("hud_%s_missing" % normalized_key)
	return null


func chrome_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	var texture := _load_derived_texture(PATH_DERIVED_CHROME_DIR, normalized_key, _derived_chrome_textures)
	if texture != null:
		return texture
	if use_placeholder:
		_warn_missing("chrome:%s" % normalized_key)
		return placeholder_texture("chrome_%s_missing" % normalized_key)
	return null


func combat_ui_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	var texture := _load_derived_texture(PATH_DERIVED_COMBAT_UI_DIR, normalized_key, _derived_combat_ui_textures)
	if texture != null:
		return texture
	if use_placeholder:
		_warn_missing("combat_ui:%s" % normalized_key)
		return placeholder_texture("combat_ui_%s_missing" % normalized_key, Color(0.08, 0.09, 0.12, 0.78), Vector2i(64, 64))
	return null


func combat_backdrop_scrim_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_backdrop_scrim", false)
	if texture != null:
		return texture
	return placeholder_texture("combat_backdrop_scrim_missing", Color(0.0, 0.0, 0.0, 0.34), Vector2i(1080, 1920))


func combat_enemy_stage_texture(enemy_id: String) -> Texture2D:
	var normalized_id := enemy_id.strip_edges().to_lower()
	if _COMBAT_STAGE_ALIAS_BY_ENEMY_ID.has(normalized_id):
		normalized_id = String(_COMBAT_STAGE_ALIAS_BY_ENEMY_ID[normalized_id])
	var stage_sheet_texture := _combat_stage_sheet_texture(normalized_id)
	if stage_sheet_texture != null:
		return stage_sheet_texture
	var stage_texture := combat_ui_texture("combat_stage_%s" % normalized_id, false)
	if stage_texture != null:
		return stage_texture
	stage_texture = combat_ui_texture("combat_stage_fallback", false)
	if stage_texture != null:
		return stage_texture
	var portrait_fallback := enemy_portrait(normalized_id)
	return portrait_fallback if portrait_fallback != null else placeholder_texture(
		"combat_stage_fallback_missing",
		Color(0.08, 0.09, 0.12, 0.84),
		Vector2i(1048, 336)
	)


func _normalized_enemy_visual_id(enemy_id: String) -> String:
	var normalized_id := enemy_id.strip_edges().to_lower()
	if _COMBAT_STAGE_ALIAS_BY_ENEMY_ID.has(normalized_id):
		normalized_id = String(_COMBAT_STAGE_ALIAS_BY_ENEMY_ID[normalized_id])
	return normalized_id


func _runtime_enemy_key(enemy_id: String) -> String:
	var normalized_id := enemy_id.strip_edges().to_lower()
	if _RUNTIME_ENEMY_ALIAS_BY_ID.has(normalized_id):
		return String(_RUNTIME_ENEMY_ALIAS_BY_ID[normalized_id])
	if normalized_id.begins_with("boss_") or normalized_id.begins_with("enemy_"):
		return normalized_id
	return "enemy_%s" % normalized_id


func _runtime_enemy_placeholder_like(runtime_key: String, runtime_entry: Dictionary) -> bool:
	if bool(runtime_entry.get("placeholder_like", false)):
		return true
	var source := String(runtime_entry.get("source", ""))
	if not _PLACEHOLDER_RUNTIME_ENEMY_KEYS.has(runtime_key):
		return false
	return source.begins_with("res://resources/art/first_pass/enemies/")


func _combat_stage_sheet_texture(normalized_id: String) -> Texture2D:
	if _combat_enemy_stage_textures.has(normalized_id):
		return _combat_enemy_stage_textures[normalized_id]
	var index := int(_COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID.get(normalized_id, -1))
	if index < 0:
		return null
	if _combat_enemy_stage_sheet == null:
		_combat_enemy_stage_sheet = _safe_load_texture(PATH_COMBAT_ENEMY_STAGE_SHEET, "combat_enemy_stage_sheet")
	if _combat_enemy_stage_sheet == null:
		return null
	var columns := 2
	var rows := 2
	var column := index % columns
	var row := int(floor(float(index) / float(columns)))
	var cell_width := float(_combat_enemy_stage_sheet.get_width()) / float(columns)
	var cell_height := float(_combat_enemy_stage_sheet.get_height()) / float(rows)
	var stage_texture := _atlas_region(
		_combat_enemy_stage_sheet,
		Rect2(cell_width * column, cell_height * row, cell_width, cell_height)
	)
	_combat_enemy_stage_textures[normalized_id] = stage_texture
	return stage_texture


func _combat_stage_sheet_debug_path(normalized_id: String) -> String:
	var index := int(_COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID.get(normalized_id, -1))
	if index < 0:
		return ""
	if ResourceLoader.exists(PATH_COMBAT_ENEMY_STAGE_SHEET) or FileAccess.file_exists(PATH_COMBAT_ENEMY_STAGE_SHEET):
		return "%s#cell_%d" % [PATH_COMBAT_ENEMY_STAGE_SHEET, index]
	return ""


func combat_intent_badge_texture(kind: String) -> Texture2D:
	var normalized_kind := kind.strip_edges().to_lower()
	var badge_key := "combat_intent_badge_idle"
	match normalized_kind:
		"attack":
			badge_key = "combat_intent_badge_attack"
		"block":
			badge_key = "combat_intent_badge_block"
		"mixed", "attack_and_block", "attack+block":
			badge_key = "combat_intent_badge_mixed"
		_:
			badge_key = "combat_intent_badge_idle"
	var texture := combat_ui_texture(badge_key, false)
	if texture != null:
		return texture
	return combat_ui_texture("combat_intent_badge_idle", false)


func combat_top_bar_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_top_bar_frame", false)
	if texture != null:
		return texture
	return chrome_texture("top_bar_frame", false)


func combat_enemy_panel_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_enemy_panel_frame", false)
	if texture != null:
		return texture
	return combat_ui_texture("combat_enemy_panel", false)


func combat_enemy_panel_texture() -> Texture2D:
	return combat_enemy_panel_frame_texture()


func combat_board_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_board_frame", false)
	return texture


func combat_mastery_rail_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_mastery_rail_frame", false)
	if texture != null:
		return texture
	return combat_ui_texture("combat_mastery_rail", false)


func combat_mastery_rail_texture() -> Texture2D:
	return combat_mastery_rail_frame_texture()


func combat_player_vitals_frame_texture() -> Texture2D:
	return combat_ui_texture("combat_player_vitals_frame", false)


func combat_equipment_rail_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_equipment_rail_frame", false)
	if texture != null:
		return texture
	return combat_ui_texture("combat_loadout_rail", false)


func combat_consumables_rail_frame_texture() -> Texture2D:
	var texture := combat_ui_texture("combat_consumables_rail_frame", false)
	if texture != null:
		return texture
	return combat_ui_texture("combat_loadout_rail", false)


func combat_slot_frame_texture(filled: bool) -> Texture2D:
	if filled:
		return combat_ui_texture("combat_slot_frame_filled", false)
	return combat_ui_texture("combat_slot_frame_empty", false)


func combat_player_hud_rail_texture() -> Texture2D:
	return combat_ui_texture("combat_player_hud_rail", false)


func combat_loadout_rail_texture() -> Texture2D:
	return combat_ui_texture("combat_loadout_rail", false)


func combat_block_badge_texture() -> Texture2D:
	return combat_ui_texture("combat_block_badge", false)


func combat_timer_track_texture() -> Texture2D:
	return combat_ui_texture("combat_timer_track", false)


func combat_timer_center_marker_texture() -> Texture2D:
	return combat_ui_texture("combat_timer_center_marker", false)


func combat_divider_texture() -> Texture2D:
	return combat_ui_texture("combat_divider_h", false)


func combat_corner_ornament_texture() -> Texture2D:
	return combat_ui_texture("combat_corner_ornament", false)


func clean_hud_texture(key: String) -> Texture2D:
	var texture := hud_texture(key, false)
	if texture == null:
		return null
	return texture


func clean_chrome_texture(key: String) -> Texture2D:
	var texture := chrome_texture(key, false)
	if texture == null:
		return null
	return texture


func vfx_texture(effect_name: String) -> Texture2D:
	_ensure_vfx_textures()
	var key := effect_name.to_lower()
	return _vfx_textures.get(key, placeholder_texture("vfx_missing"))


func placeholder_texture(key: String, color: Color = Color(0.32, 0.32, 0.36, 1.0), size: Vector2i = Vector2i(96, 96)) -> Texture2D:
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8 as Image.Format)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_placeholder_cache[key] = texture
	return texture


func _ensure_background_textures() -> void:
	if _backgrounds_loaded:
		return
	_backgrounds_loaded = true
	_combat_background = _safe_load_texture(PATH_COMBAT_BACKGROUND, "combat_background")
	_shop_background = _safe_load_texture(PATH_SHOP_BACKGROUND, "shop_background")


func _ensure_hero_portrait() -> void:
	if _hero_portrait_loaded:
		return
	_hero_portrait_loaded = true
	_hero_portrait = _runtime_texture("heroes", "hero_orbwalker")
	if _hero_portrait == null:
		_hero_portrait = _safe_load_texture(PATH_FALLBACK_HERO_PORTRAIT, "hero_portrait_fallback")
	if _hero_portrait == null:
		_hero_portrait = _safe_load_texture(PATH_HERO_PORTRAIT, "hero_portrait")


func _ensure_shop_merchant_header_texture() -> void:
	if _shop_merchant_header_loaded:
		return
	_shop_merchant_header_loaded = true
	for path in SHOP_MERCHANT_HEADER_CANDIDATE_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var loaded := _safe_load_texture(path, "shop_merchant_header")
		if loaded != null:
			_shop_merchant_header = loaded
			return


func _ensure_ui_sheets() -> void:
	if _ui_sheets_loaded:
		return
	_ui_sheets_loaded = true
	_ui_frames = _safe_load_texture(PATH_UI_FRAME_SHEET, "ui_frame_sheet")
	_ui_bars = _safe_load_texture(PATH_UI_BAR_SHEET, "ui_bar_sheet")
	_ui_shop_cards = _safe_load_texture(PATH_UI_SHOP_CARD_SHEET, "ui_shop_card_sheet")


func _ensure_orb_textures() -> void:
	if _orb_textures_built:
		return
	_orb_textures_built = true
	_build_orb_textures()


func _ensure_intent_textures() -> void:
	if _intent_textures_built:
		return
	_intent_textures_built = true
	_build_intent_textures()


func _ensure_rarity_textures() -> void:
	if _rarity_textures_built:
		return
	_rarity_textures_built = true
	_build_rarity_textures()


func _ensure_mastery_textures() -> void:
	if _mastery_textures_built:
		return
	_mastery_textures_built = true
	_build_mastery_textures()


func _ensure_icon_textures() -> void:
	if _icon_textures_built:
		return
	_icon_textures_built = true
	_build_icon_textures()


func _ensure_relic_textures() -> void:
	if _relic_textures_built:
		return
	_relic_textures_built = true
	_build_relic_textures()


func _ensure_vfx_textures() -> void:
	if _vfx_textures_built:
		return
	_vfx_textures_built = true
	_build_vfx_textures()


func _build_orb_textures() -> void:
	if _try_build_runtime_orb_textures():
		return
	if _try_build_derived_orb_textures():
		return
	var sheet := _safe_load_texture(PATH_ORB_SHEET, "orb_sheet")
	if sheet == null:
		return
	var columns := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / 2.0
	var orb_ids: Array[int] = [
		OrbType.Id.FIRE,
		OrbType.Id.ICE,
		OrbType.Id.EARTH,
		OrbType.Id.HEART,
		OrbType.Id.ARMOR,
		OrbType.Id.GOLD,
	]
	for index in orb_ids.size():
		var column := index % columns
		var row := int(floor(float(index) / float(columns)))
		var region := Rect2(cell_width * column, cell_height * row, cell_width, cell_height)
		var orb_id := int(orb_ids[index])
		_orb_textures[orb_id] = _atlas_region(sheet, region)
	if _orb_textures.size() < orb_ids.size():
		_try_build_derived_orb_textures()


func _try_build_runtime_orb_textures() -> bool:
	var loaded_orbs: Dictionary = {}
	for orb_id in _RUNTIME_ORB_KEY_BY_ID.keys():
		var runtime_key := String(_RUNTIME_ORB_KEY_BY_ID[orb_id])
		var texture := _runtime_texture("orbs", runtime_key)
		if texture == null:
			return false
		loaded_orbs[orb_id] = texture
	if loaded_orbs.size() != _RUNTIME_ORB_KEY_BY_ID.size():
		return false
	for orb_id in loaded_orbs.keys():
		_orb_textures[orb_id] = loaded_orbs[orb_id]
	return true


func _try_build_derived_orb_textures() -> bool:
	var loaded_orbs: Dictionary = {}
	for orb_id in _DERIVED_ORB_FILENAME_BY_ID.keys():
		var file_name := String(_DERIVED_ORB_FILENAME_BY_ID[orb_id])
		if file_name == "":
			return false
		var path := "%s/%s" % [PATH_DERIVED_ORB_DIR, file_name]
		var texture := _safe_load_texture(path, "derived_orb:%s" % file_name)
		if texture == null:
			return false
		loaded_orbs[orb_id] = texture
	if loaded_orbs.size() != _DERIVED_ORB_FILENAME_BY_ID.size():
		return false
	for orb_id in loaded_orbs.keys():
		_orb_textures[orb_id] = loaded_orbs[orb_id]
	return true


func _build_intent_textures() -> void:
	var sheet := _safe_load_texture(PATH_INTENT_SHEET, "intent_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_intent_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_rarity_textures() -> void:
	var sheet := _safe_load_texture(PATH_RARITY_SHEET, "rarity_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_rarity_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_mastery_textures() -> void:
	var sheet := _safe_load_texture(PATH_MASTERY_SHEET, "mastery_sheet")
	if sheet == null:
		return
	var columns := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / 2.0
	var orb_ids: Array[int] = [
		OrbType.Id.FIRE,
		OrbType.Id.ICE,
		OrbType.Id.EARTH,
		OrbType.Id.HEART,
		OrbType.Id.ARMOR,
		OrbType.Id.GOLD,
	]
	for index in orb_ids.size():
		var column := index % columns
		var row := int(floor(float(index) / float(columns)))
		var orb_id := int(orb_ids[index])
		_mastery_textures[orb_id] = _atlas_region(sheet, Rect2(cell_width * column, cell_height * row, cell_width, cell_height))


func _build_icon_textures() -> void:
	var sheet := _safe_load_texture(PATH_ITEM_SHEET, "item_sheet")
	if sheet == null:
		return
	var columns := 5
	var rows := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / float(rows)
	var atlas_index := 0
	for row in rows:
		for column in columns:
			var region := Rect2(
				cell_width * column,
				cell_height * row,
				cell_width,
				cell_height
			)
			_icon_textures[atlas_index] = _atlas_region(sheet, region)
			atlas_index += 1


func _build_relic_textures() -> void:
	var sheet := _safe_load_texture(PATH_RELIC_SHEET, "relic_sheet")
	if sheet == null:
		return
	var columns := 5
	var cell_width := float(sheet.get_width()) / float(columns)
	for index in columns:
		_relic_textures[index] = _atlas_region(sheet, Rect2(cell_width * index, 0.0, cell_width, float(sheet.get_height())))


func _build_vfx_textures() -> void:
	var sheet := _safe_load_texture(PATH_VFX_SHEET, "vfx_sheet")
	if sheet == null:
		_build_post_match_vfx_textures()
		return
	var columns := 4
	var rows := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / float(rows)
	_vfx_textures["hit_flash"] = _atlas_region(sheet, Rect2(0.0, 0.0, cell_width, cell_height))
	_vfx_textures["orb_clear"] = _atlas_region(sheet, Rect2(cell_width, 0.0, cell_width, cell_height))
	_vfx_textures["gold_gain"] = _atlas_region(sheet, Rect2(cell_width * 2.0, 0.0, cell_width, cell_height))
	_build_post_match_vfx_textures()


func _build_post_match_vfx_textures() -> void:
	var specs := {
		"post_match_fire": {
			"accent": Color(1.0, 0.34, 0.12, 1.0),
			"core": Color(1.0, 0.86, 0.42, 1.0),
			"shape": "burst",
		},
		"post_match_ice": {
			"accent": Color(0.42, 0.86, 1.0, 1.0),
			"core": Color(0.88, 0.98, 1.0, 1.0),
			"shape": "shards",
		},
		"post_match_earth": {
			"accent": Color(0.45, 0.78, 0.34, 1.0),
			"core": Color(0.88, 1.0, 0.58, 1.0),
			"shape": "stone",
		},
		"post_match_gold": {
			"accent": Color(1.0, 0.76, 0.18, 1.0),
			"core": Color(1.0, 0.96, 0.52, 1.0),
			"shape": "sparkle",
		},
		"post_match_heart": {
			"accent": Color(0.34, 1.0, 0.52, 1.0),
			"core": Color(0.86, 1.0, 0.82, 1.0),
			"shape": "heal",
		},
		"post_match_armor": {
			"accent": Color(0.55, 0.78, 1.0, 1.0),
			"core": Color(0.92, 0.98, 1.0, 1.0),
			"shape": "shield",
		},
		"post_match_damage": {
			"accent": Color(1.0, 0.18, 0.16, 1.0),
			"core": Color(1.0, 0.72, 0.56, 1.0),
			"shape": "slash",
		},
	}
	specs["post_match_healing"] = specs["post_match_heart"]
	specs["post_match_armor_gain"] = specs["post_match_armor"]
	for key in specs.keys():
		var spec: Dictionary = specs[key]
		_vfx_textures[key] = _make_post_match_vfx_texture(
			String(spec.get("shape", "burst")),
			spec.get("accent", Color.WHITE) as Color,
			spec.get("core", Color.WHITE) as Color
		)


func _make_post_match_vfx_texture(shape: String, accent: Color, core: Color) -> Texture2D:
	var size := 192
	var center := Vector2(95.5, 95.5)
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	image.fill(Color(1.0, 1.0, 1.0, 0.0))
	for y in range(size):
		for x in range(size):
			var point := Vector2(float(x), float(y))
			var offset := point - center
			var distance := offset.length()
			var angle := atan2(offset.y, offset.x)
			var radial := clampf(1.0 - distance / 88.0, 0.0, 1.0)
			var soft_glow := radial * radial * 0.38
			var rim := maxf(0.0, 1.0 - absf(distance - 51.0) / 9.0) * 0.42
			var hot_core := maxf(0.0, 1.0 - distance / 22.0) * 0.72
			var shape_alpha := _post_match_shape_alpha(shape, offset, distance, angle)
			var alpha := maxf(soft_glow, maxf(rim, maxf(hot_core, shape_alpha)))
			if alpha <= 0.01:
				continue
			var mix := clampf(distance / 88.0, 0.0, 1.0)
			var color := core.lerp(accent, mix)
			if hot_core > 0.1:
				color = color.lightened(hot_core * 0.34)
			if shape == "ice" or shape == "shards":
				color = color.lightened(maxf(0.0, shape_alpha - 0.34) * 0.25)
			color.a = alpha
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _post_match_shape_alpha(shape: String, offset: Vector2, distance: float, angle: float) -> float:
	match shape:
		"burst":
			var flame := maxf(0.0, sin(angle * 5.0 + distance * 0.05))
			var upper_lift := clampf((34.0 - offset.y) / 72.0, 0.0, 1.0)
			var tongues := flame * clampf(1.0 - distance / 82.0, 0.0, 1.0)
			var vertical_core := maxf(0.0, 1.0 - absf(offset.x) / (20.0 + upper_lift * 28.0)) * clampf((64.0 - offset.y) / 118.0, 0.0, 1.0)
			return maxf(tongues * 0.70, vertical_core * 0.86)
		"shards":
			var primary := absf(offset.y + offset.x * 0.22)
			var secondary := absf(offset.y - offset.x * 0.72)
			var radial_spike := maxf(0.0, 1.0 - absf(sin(angle * 6.0)) / 0.16) * clampf(distance / 20.0, 0.0, 1.0)
			var shards := maxf(clampf(1.0 - primary / 4.8, 0.0, 1.0), clampf(1.0 - secondary / 4.8, 0.0, 1.0))
			return maxf(shards * clampf(1.0 - distance / 88.0, 0.0, 1.0), radial_spike * clampf(1.0 - distance / 84.0, 0.0, 1.0)) * 0.88
		"stone":
			var chunky := maxf(absf(offset.x * 0.92), absf(offset.y * 0.72))
			var slab := clampf(1.0 - absf(chunky - 38.0) / 9.0, 0.0, 1.0)
			var crack_a := clampf(1.0 - absf(offset.y + sin(offset.x * 0.10) * 16.0) / 4.0, 0.0, 1.0)
			var crack_b := clampf(1.0 - absf(offset.x - cos(offset.y * 0.09) * 22.0) / 4.0, 0.0, 1.0)
			return maxf(slab * 0.68, maxf(crack_a, crack_b) * clampf(1.0 - distance / 78.0, 0.0, 1.0) * 0.48)
		"sparkle":
			var cross := maxf(0.0, 1.0 - minf(absf(offset.x), absf(offset.y)) / 3.6) * clampf(1.0 - distance / 84.0, 0.0, 1.0)
			var diagonal := maxf(0.0, 1.0 - absf(absf(offset.x) - absf(offset.y)) / 3.6) * clampf(1.0 - distance / 66.0, 0.0, 1.0)
			var coin := clampf(1.0 - absf((offset / Vector2(28.0, 19.0)).length() - 1.0) / 0.16, 0.0, 1.0)
			return maxf(maxf(cross * 0.92, diagonal * 0.50), coin * 0.56)
		"heal":
			var stream := maxf(0.0, 1.0 - absf(offset.x + sin(offset.y * 0.08) * 10.0) / 8.0) * clampf((66.0 - offset.y) / 128.0, 0.0, 1.0)
			var leaf_a := maxf(0.0, 1.0 - (offset - Vector2(-13.0, -20.0)).length() / 20.0)
			var leaf_b := maxf(0.0, 1.0 - (offset - Vector2(13.0, -27.0)).length() / 18.0)
			var heart_lobes := maxf(
				maxf(0.0, 1.0 - (offset - Vector2(-13.0, -8.0)).length() / 18.0),
				maxf(0.0, 1.0 - (offset - Vector2(13.0, -8.0)).length() / 18.0)
			)
			return maxf(stream * 0.66, maxf(maxf(leaf_a, leaf_b) * 0.58, heart_lobes * 0.42))
		"shield":
			var top := maxf(absf(offset.x) / 43.0, absf(offset.y + 17.0) / 36.0)
			var point := clampf(1.0 - absf(absf(offset.x) + offset.y - 56.0) / 8.0, 0.0, 1.0)
			var rim := clampf(1.0 - absf(top - 1.0) / 0.10, 0.0, 1.0)
			var center_bar := maxf(0.0, 1.0 - absf(offset.x) / 4.2) * clampf(1.0 - absf(offset.y + 2.0) / 42.0, 0.0, 1.0)
			return maxf(maxf(rim, point) * 0.82, center_bar * 0.52)
		"slash":
			var slash_a := absf(offset.y + offset.x * 0.46)
			var slash_b := absf(offset.y + offset.x * 0.46 + 26.0)
			var cut := maxf(clampf(1.0 - slash_a / 5.5, 0.0, 1.0), clampf(1.0 - slash_b / 6.0, 0.0, 1.0) * 0.78)
			return cut * clampf(1.0 - distance / 86.0, 0.0, 1.0) * 0.92
		_:
			return clampf(1.0 - distance / 78.0, 0.0, 1.0) * 0.55


func _load_derived_icon(icon_key: String) -> Texture2D:
	if icon_key == "":
		return null
	if _derived_icon_textures.has(icon_key):
		return _derived_icon_textures[icon_key]
	return _load_derived_texture(PATH_DERIVED_ICON_DIR, icon_key, _derived_icon_textures)


func _derived_texture_path(base_path: String, key: String) -> String:
	if base_path == "" or key == "":
		return ""
	var path := "%s/%s.png" % [base_path, key]
	if _resource_or_file_exists(path):
		return path
	return ""


func _resource_or_file_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)


func _load_derived_texture(base_path: String, key: String, cache: Dictionary) -> Texture2D:
	if key == "":
		return null
	if cache.has(key):
		return cache[key]
	var path := "%s/%s.png" % [base_path, key]
	var loaded: Variant = null
	if ResourceLoader.exists(path):
		loaded = load(path)
	if loaded == null:
		var safe_loaded := _safe_load_texture(path, key)
		if safe_loaded == null:
			return null
		cache[key] = safe_loaded
		return safe_loaded
	var texture := loaded as Texture2D
	if texture == null:
		return null
	cache[key] = texture
	return texture


func _atlas_region(sheet: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = region
	return atlas


func _processed_icon_region(sheet: Texture2D, region: Rect2, remove_baked_checker: bool = false) -> Texture2D:
	var source_image: Image = sheet.get_image()
	if source_image == null:
		return _atlas_region(sheet, region)

	var x0 := int(floor(region.position.x))
	var y0 := int(floor(region.position.y))
	var w := int(floor(region.size.x))
	var h := int(floor(region.size.y))
	if w <= 0 or h <= 0:
		return _atlas_region(sheet, region)

	var cropped := Image.create(w, h, false, Image.FORMAT_RGBA8 as Image.Format)
	for y in h:
		for x in w:
			var c := source_image.get_pixel(x0 + x, y0 + y)
			if _is_checker_pixel(c) or (remove_baked_checker and _is_bright_neutral_background_candidate(c)):
				c.a = 0.0
			cropped.set_pixel(x, y, c)

	_clear_edge_checker_noise(cropped)
	if not remove_baked_checker:
		_clear_edge_sampled_background(cropped)
	_keep_significant_icon_components(cropped)
	var bounds := _content_bounds(cropped)
	var min_x := int(bounds.x)
	var min_y := int(bounds.y)
	var max_x := int(bounds.z)
	var max_y := int(bounds.w)
	if max_x >= min_x and max_y >= min_y:
		var padding := 4
		var trim_left := maxi(0, min_x - padding)
		var trim_top := maxi(0, min_y - padding)
		var trim_right := mini(w - 1, max_x + padding)
		var trim_bottom := mini(h - 1, max_y + padding)
		cropped = cropped.get_region(Rect2i(
			Vector2i(trim_left, trim_top),
			Vector2i(trim_right - trim_left + 1, trim_bottom - trim_top + 1)
		))

	return ImageTexture.create_from_image(cropped)


func _processed_orb_region(sheet: Texture2D, region: Rect2) -> Texture2D:
	var source_image: Image = sheet.get_image()
	if source_image == null:
		return _atlas_region(sheet, region)

	var x0 := int(floor(region.position.x))
	var y0 := int(floor(region.position.y))
	var w := int(floor(region.size.x))
	var h := int(floor(region.size.y))
	if w <= 0 or h <= 0:
		return _atlas_region(sheet, region)

	var cropped := Image.create(w, h, false, Image.FORMAT_RGBA8 as Image.Format)
	for y in h:
		for x in w:
			var c := source_image.get_pixel(x0 + x, y0 + y)
			if _is_checker_pixel(c):
				c.a = 0.0
			elif c.a > 0.01:
				c = _tone_map_board_orb_color(c)
			cropped.set_pixel(x, y, c)

	_clear_edge_checker_noise(cropped)
	_keep_primary_orb_component(cropped)

	# Trim transparent borders so the orb fills BoardView cells instead of appearing tiny.
	var bounds := _content_bounds(cropped)
	var min_x := int(bounds.x)
	var min_y := int(bounds.y)
	var max_x := int(bounds.z)
	var max_y := int(bounds.w)
	if max_x >= min_x and max_y >= min_y:
		var padding := 4
		var trim_left := maxi(0, min_x - padding)
		var trim_top := maxi(0, min_y - padding)
		var trim_right := mini(w - 1, max_x + padding)
		var trim_bottom := mini(h - 1, max_y + padding)
		var trim_position := Vector2i(trim_left, trim_top)
		var trim_size := Vector2i(trim_right - trim_left + 1, trim_bottom - trim_top + 1)
		var trim_rect := Rect2i(trim_position, trim_size)
		cropped = cropped.get_region(trim_rect)

	return ImageTexture.create_from_image(cropped)


func _content_bounds(image: Image) -> Vector4i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			if c.a <= 0.01:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	return Vector4i(min_x, min_y, max_x, max_y)


func _tone_map_board_orb_color(c: Color) -> Color:
	var alpha := c.a
	var luminance := c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722
	var saturation_factor := 1.04
	var brightness_factor := 0.94
	var floor_lift := 0.025
	c.r = clampf(lerpf(luminance, c.r, saturation_factor) * brightness_factor + floor_lift, 0.0, 1.0)
	c.g = clampf(lerpf(luminance, c.g, saturation_factor) * brightness_factor + floor_lift, 0.0, 1.0)
	c.b = clampf(lerpf(luminance, c.b, saturation_factor) * brightness_factor + floor_lift, 0.0, 1.0)
	c.a = alpha
	return c


func _keep_primary_orb_component(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var labels := PackedInt32Array()
	labels.resize(width * height)
	var component_sizes: Array[int] = []
	var component_touches_center: Array[bool] = []
	var component_index := 0
	var center_x: int = int(width * 0.5)
	var center_y: int = int(height * 0.5)
	var center_radius_sq := 16

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if visited[idx] == 1:
				continue
			var c := image.get_pixel(x, y)
			if c.a <= 0.01:
				visited[idx] = 1
				continue

			component_index += 1
			var size := 0
			var touches_center := false
			var queue: Array[Vector2i] = [Vector2i(x, y)]
			visited[idx] = 1
			labels[idx] = component_index
			while not queue.is_empty():
				var p: Vector2i = queue.pop_back()
				size += 1
				var dx := p.x - center_x
				var dy := p.y - center_y
				if dx * dx + dy * dy <= center_radius_sq:
					touches_center = true
				for n in [Vector2i(p.x - 1, p.y), Vector2i(p.x + 1, p.y), Vector2i(p.x, p.y - 1), Vector2i(p.x, p.y + 1)]:
					if n.x < 0 or n.x >= width or n.y < 0 or n.y >= height:
						continue
					var n_idx: int = n.y * width + n.x
					if visited[n_idx] == 1:
						continue
					visited[n_idx] = 1
					var nc := image.get_pixel(n.x, n.y)
					if nc.a <= 0.01:
						continue
					labels[n_idx] = component_index
					queue.append(n)

			component_sizes.append(size)
			component_touches_center.append(touches_center)

	if component_index <= 1:
		return

	var keep_component := -1
	for i in range(component_sizes.size()):
		if component_touches_center[i]:
			keep_component = i + 1
			break
	if keep_component == -1:
		var best_size := -1
		for i in range(component_sizes.size()):
			if component_sizes[i] > best_size:
				best_size = component_sizes[i]
				keep_component = i + 1

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if labels[idx] != keep_component:
				var cc := image.get_pixel(x, y)
				if cc.a > 0.01:
					cc.a = 0.0
					image.set_pixel(x, y, cc)


func _keep_significant_icon_components(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var labels := PackedInt32Array()
	labels.resize(width * height)
	var component_sizes: Array[int] = []
	var component_centers: Array[Vector2] = []
	var component_index := 0

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if visited[idx] == 1:
				continue
			var c := image.get_pixel(x, y)
			if c.a <= 0.01:
				visited[idx] = 1
				continue

			component_index += 1
			var size := 0
			var sum := Vector2.ZERO
			var queue: Array[Vector2i] = [Vector2i(x, y)]
			visited[idx] = 1
			labels[idx] = component_index
			while not queue.is_empty():
				var p: Vector2i = queue.pop_back()
				size += 1
				sum += Vector2(float(p.x), float(p.y))
				for n in [Vector2i(p.x - 1, p.y), Vector2i(p.x + 1, p.y), Vector2i(p.x, p.y - 1), Vector2i(p.x, p.y + 1)]:
					if n.x < 0 or n.x >= width or n.y < 0 or n.y >= height:
						continue
					var n_idx: int = n.y * width + n.x
					if visited[n_idx] == 1:
						continue
					visited[n_idx] = 1
					var nc := image.get_pixel(n.x, n.y)
					if nc.a <= 0.01:
						continue
					labels[n_idx] = component_index
					queue.append(n)

			component_sizes.append(size)
			component_centers.append(sum / float(maxi(1, size)))

	if component_index <= 1:
		return

	var max_size := 0
	for size in component_sizes:
		max_size = maxi(max_size, size)
	if max_size <= 0:
		return

	var keep_labels := {}
	var center := Vector2(float(width) * 0.5, float(height) * 0.5)
	var max_distance := center.length()
	for i in range(component_sizes.size()):
		var size_ratio := float(component_sizes[i]) / float(max_size)
		var distance_ratio := component_centers[i].distance_to(center) / maxf(1.0, max_distance)
		if size_ratio >= 0.18 or (size_ratio >= 0.08 and distance_ratio <= 0.45):
			keep_labels[i + 1] = true

	if keep_labels.is_empty():
		var largest_label := 1
		var largest_size := component_sizes[0]
		for i in range(1, component_sizes.size()):
			if component_sizes[i] > largest_size:
				largest_size = component_sizes[i]
				largest_label = i + 1
		keep_labels[largest_label] = true

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if labels[idx] != 0 and not keep_labels.has(labels[idx]):
				var cc := image.get_pixel(x, y)
				if cc.a > 0.01:
					cc.a = 0.0
					image.set_pixel(x, y, cc)


func _is_checker_pixel(c: Color) -> bool:
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	if rg_diff > 0.02 or gb_diff > 0.02:
		return false
	var brightness := (c.r + c.g + c.b) / 3.0
	return brightness >= 0.72 and brightness <= 0.96 and c.a >= 0.99


func _is_loose_checker_pixel(c: Color) -> bool:
	if c.a <= 0.01:
		return false
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	if rg_diff > 0.06 or gb_diff > 0.06:
		return false
	var brightness := (c.r + c.g + c.b) / 3.0
	return brightness >= 0.20 and brightness <= 0.95


func _clear_edge_checker_noise(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var stack: Array[Vector2i] = []

	for x in range(width):
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, height - 1))
	for y in range(height):
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(width - 1, y))

	while not stack.is_empty():
		var p_variant: Variant = stack.pop_back()
		if not (p_variant is Vector2i):
			continue
		var p: Vector2i = p_variant
		var x: int = p.x
		var y: int = p.y
		if x < 0 or x >= width or y < 0 or y >= height:
			continue
		var index: int = y * width + x
		if visited[index] == 1:
			continue
		visited[index] = 1
		var c := image.get_pixel(x, y)
		if not _is_loose_checker_pixel(c):
			continue
		c.a = 0.0
		image.set_pixel(x, y, c)
		stack.append(Vector2i(x - 1, y))
		stack.append(Vector2i(x + 1, y))
		stack.append(Vector2i(x, y - 1))
		stack.append(Vector2i(x, y + 1))


func _clear_edge_sampled_background(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var samples: Array[Color] = []
	for x in range(width):
		_add_unique_background_sample(samples, image.get_pixel(x, 0))
		_add_unique_background_sample(samples, image.get_pixel(x, height - 1))
	for y in range(height):
		_add_unique_background_sample(samples, image.get_pixel(0, y))
		_add_unique_background_sample(samples, image.get_pixel(width - 1, y))
	if samples.is_empty():
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var stack: Array[Vector2i] = []
	for x in range(width):
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, height - 1))
	for y in range(height):
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(width - 1, y))

	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.x >= width or p.y < 0 or p.y >= height:
			continue
		var index := p.y * width + p.x
		if visited[index] == 1:
			continue
		visited[index] = 1
		var c := image.get_pixel(p.x, p.y)
		if not _matches_sampled_background(c, samples):
			continue
		c.a = 0.0
		image.set_pixel(p.x, p.y, c)
		stack.append(Vector2i(p.x - 1, p.y))
		stack.append(Vector2i(p.x + 1, p.y))
		stack.append(Vector2i(p.x, p.y - 1))
		stack.append(Vector2i(p.x, p.y + 1))


func _add_unique_background_sample(samples: Array[Color], c: Color) -> void:
	if c.a <= 0.01:
		return
	if not _is_neutral_background_candidate(c):
		return
	for sample in samples:
		if _color_distance_rgb(c, sample) <= 0.08:
			return
	if samples.size() < 6:
		samples.append(c)


func _matches_sampled_background(c: Color, samples: Array[Color]) -> bool:
	if c.a <= 0.01:
		return false
	if not _is_neutral_background_candidate(c):
		return false
	for sample in samples:
		if _color_distance_rgb(c, sample) <= 0.10:
			return true
	return false


func _is_neutral_background_candidate(c: Color) -> bool:
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	var rb_diff := absf(c.r - c.b)
	var brightness := (c.r + c.g + c.b) / 3.0
	return rg_diff <= 0.08 and gb_diff <= 0.08 and rb_diff <= 0.08 and (brightness <= 0.18 or brightness >= 0.72)


func _is_bright_neutral_background_candidate(c: Color) -> bool:
	if c.a <= 0.01:
		return false
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	var rb_diff := absf(c.r - c.b)
	var brightness := (c.r + c.g + c.b) / 3.0
	return rg_diff <= 0.08 and gb_diff <= 0.08 and rb_diff <= 0.08 and brightness >= 0.72


func _color_distance_rgb(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)


func _runtime_icon_texture(icon_key: String) -> Texture2D:
	return _runtime_texture("icons", icon_key.strip_edges().to_lower())


func _runtime_texture_entry(category: String, key: String) -> Dictionary:
	if category == "" or key == "":
		return {}
	_ensure_runtime_manifest()
	if _runtime_manifest.is_empty():
		return {}
	var categories := Dictionary(_runtime_manifest.get("categories", {}))
	var category_entries := Dictionary(categories.get(category, {}))
	return Dictionary(category_entries.get(key, {}))


func _runtime_texture(category: String, key: String) -> Texture2D:
	if category == "" or key == "":
		return null
	var entry := _runtime_texture_entry(category, key)
	var path := String(entry.get("path", ""))
	if path == "":
		return null
	if _runtime_texture_cache.has(path):
		return _runtime_texture_cache[path]
	var texture := _load_runtime_png_texture(path, "runtime:%s:%s" % [category, key])
	if texture != null:
		_runtime_texture_cache[path] = texture
	return texture


func _ensure_runtime_manifest() -> void:
	if _runtime_manifest_loaded:
		return
	_runtime_manifest_loaded = true
	if not FileAccess.file_exists(PATH_RUNTIME_MANIFEST):
		return
	var file := FileAccess.open(PATH_RUNTIME_MANIFEST, FileAccess.READ)
	if file == null:
		_warn_missing("runtime_manifest")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_runtime_manifest = parsed
	else:
		_warn_missing("runtime_manifest_parse")


func _load_runtime_png_texture(path: String, key: String) -> Texture2D:
	var loaded: Variant = load(path)
	var imported_texture := loaded as Texture2D
	if imported_texture != null:
		return imported_texture
	if FileAccess.file_exists(path):
		var image := Image.new()
		var load_error := image.load(path)
		if load_error == OK:
			return ImageTexture.create_from_image(image)
	_warn_missing("texture_path:%s" % key)
	return null


func _safe_load_texture(path: String, key: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var loaded: Variant = load(path)
		var texture := loaded as Texture2D
		if texture != null:
			return texture
	if FileAccess.file_exists(path):
		var image := Image.new()
		var load_error := image.load(path)
		if load_error == OK:
			return ImageTexture.create_from_image(image)
	_warn_missing("texture_path:%s" % key)
	return null


func _load_image_texture(path: String, key: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		_warn_missing("texture_path:%s" % key)
		return null
	var image := Image.new()
	var load_error := image.load(path)
	if load_error == OK:
		return ImageTexture.create_from_image(image)
	return null


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)
