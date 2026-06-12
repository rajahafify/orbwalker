extends RefCounted
class_name VisualRegistryBackend

const VISUAL_REGISTRY_DATA_SCRIPT := preload("res://scripts/ui/visual_registry_data.gd")
const VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/ui/visual_registry_texture_factory.gd")
const VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT := preload("res://scripts/ui/visual_registry_texture_store.gd")
const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")
const PATH_COMBAT_BACKGROUND := VISUAL_REGISTRY_DATA_SCRIPT.PATH_COMBAT_BACKGROUND
const PATH_COMBAT_ENEMY_STAGE_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_COMBAT_ENEMY_STAGE_SHEET
const PATH_SHOP_BACKGROUND := VISUAL_REGISTRY_DATA_SCRIPT.PATH_SHOP_BACKGROUND
const SHOP_MERCHANT_HEADER_CANDIDATE_PATHS := VISUAL_REGISTRY_DATA_SCRIPT.SHOP_MERCHANT_HEADER_CANDIDATE_PATHS
const PATH_ORB_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_ORB_SHEET
const PATH_INTENT_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_INTENT_SHEET
const PATH_RARITY_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RARITY_SHEET
const PATH_MASTERY_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_MASTERY_SHEET
const PATH_ITEM_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_ITEM_SHEET
const PATH_RELIC_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RELIC_SHEET
const PATH_DERIVED_ICON_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_ICON_DIR
const PATH_DERIVED_ORB_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_ORB_DIR
const PATH_DERIVED_HUD_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_HUD_DIR
const PATH_DERIVED_CHROME_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_CHROME_DIR
const PATH_DERIVED_COMBAT_UI_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_COMBAT_UI_DIR
const PATH_DERIVED_COMBAT_LAYERS_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_COMBAT_LAYERS_DIR
const PATH_DERIVED_VFX_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_VFX_DIR
const PATH_UI_FRAME_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_UI_FRAME_SHEET
const PATH_UI_BAR_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_UI_BAR_SHEET
const PATH_UI_SHOP_CARD_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_UI_SHOP_CARD_SHEET
const PATH_VFX_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_VFX_SHEET
const PATH_HERO_PORTRAIT := VISUAL_REGISTRY_DATA_SCRIPT.PATH_HERO_PORTRAIT
const PATH_FALLBACK_HERO_PORTRAIT := VISUAL_REGISTRY_DATA_SCRIPT.PATH_FALLBACK_HERO_PORTRAIT
const PATH_RUNTIME_MANIFEST := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RUNTIME_MANIFEST
const PATH_RUNTIME_COLLECTION_UI_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RUNTIME_COLLECTION_UI_DIR
const PATH_RUNTIME_SHOP_UI_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RUNTIME_SHOP_UI_DIR
const _INTENT_INDEX_BY_TYPE := VISUAL_REGISTRY_DATA_SCRIPT.INTENT_INDEX_BY_TYPE
const _RARITY_INDEX := VISUAL_REGISTRY_DATA_SCRIPT.RARITY_INDEX

const _ENEMY_PORTRAIT_PATHS := VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_PORTRAIT_PATHS

const _COMBAT_STAGE_ALIAS_BY_ENEMY_ID := VISUAL_REGISTRY_DATA_SCRIPT.COMBAT_STAGE_ALIAS_BY_ENEMY_ID
const _RUNTIME_ENEMY_ALIAS_BY_ID := VISUAL_REGISTRY_DATA_SCRIPT.RUNTIME_ENEMY_ALIAS_BY_ID
const _PLACEHOLDER_RUNTIME_ENEMY_KEYS := VISUAL_REGISTRY_DATA_SCRIPT.PLACEHOLDER_RUNTIME_ENEMY_KEYS
const _COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID := VISUAL_REGISTRY_DATA_SCRIPT.COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID
const _ENEMY_VISUAL_PROFILES := VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_VISUAL_PROFILES

const _ENEMY_STAGE_BACKGROUND_PATHS := VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_STAGE_BACKGROUND_PATHS

const _ENEMY_SPRITE_PATHS := VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_SPRITE_PATHS

const _ICON_INDEX_BY_KEY := VISUAL_REGISTRY_DATA_SCRIPT.ICON_INDEX_BY_KEY
const _RELIC_INDEX_BY_KEY := VISUAL_REGISTRY_DATA_SCRIPT.RELIC_INDEX_BY_KEY
const _MASTERY_ORB_BY_ICON_KEY := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ORB_BY_ICON_KEY
const _MASTERY_BEAM_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_BEAM_BY_ORB_ID
const _MASTERY_CARD_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_CARD_BY_ORB_ID
const _MASTERY_ICON_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ICON_BY_ORB_ID
const _STABLE_PLACEHOLDER_ICON_COLORS := VISUAL_REGISTRY_DATA_SCRIPT.STABLE_PLACEHOLDER_ICON_COLORS

static var _derived_orb_filename_by_id: Dictionary = VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_filename_by_id()
static var _runtime_orb_key_by_id: Dictionary = VISUAL_REGISTRY_DATA_SCRIPT.runtime_orb_key_by_id()

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
var _texture_factory: Resource = VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT.new()
var _texture_store = VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT.new()

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


func _init() -> void:
	pass


static func asset_contract_paths() -> Dictionary:
	return VISUAL_REGISTRY_DATA_SCRIPT.asset_contract_paths()


static func lookup_table_alias_contract() -> Dictionary:
	return {
		"intent_index_by_type": is_same(_INTENT_INDEX_BY_TYPE, VISUAL_REGISTRY_DATA_SCRIPT.INTENT_INDEX_BY_TYPE),
		"rarity_index": is_same(_RARITY_INDEX, VISUAL_REGISTRY_DATA_SCRIPT.RARITY_INDEX),
		"enemy_portrait_paths": is_same(_ENEMY_PORTRAIT_PATHS, VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_PORTRAIT_PATHS),
		"enemy_stage_background_paths": is_same(_ENEMY_STAGE_BACKGROUND_PATHS, VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_STAGE_BACKGROUND_PATHS),
		"enemy_sprite_paths": is_same(_ENEMY_SPRITE_PATHS, VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_SPRITE_PATHS),
		"derived_orb_filename_by_id": is_same(_derived_orb_filename_by_id, VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_filename_by_id()),
		"runtime_orb_key_by_id": is_same(_runtime_orb_key_by_id, VISUAL_REGISTRY_DATA_SCRIPT.runtime_orb_key_by_id()),
		"combat_stage_alias_by_enemy_id": is_same(_COMBAT_STAGE_ALIAS_BY_ENEMY_ID, VISUAL_REGISTRY_DATA_SCRIPT.COMBAT_STAGE_ALIAS_BY_ENEMY_ID),
		"runtime_enemy_alias_by_id": is_same(_RUNTIME_ENEMY_ALIAS_BY_ID, VISUAL_REGISTRY_DATA_SCRIPT.RUNTIME_ENEMY_ALIAS_BY_ID),
		"placeholder_runtime_enemy_keys": is_same(_PLACEHOLDER_RUNTIME_ENEMY_KEYS, VISUAL_REGISTRY_DATA_SCRIPT.PLACEHOLDER_RUNTIME_ENEMY_KEYS),
		"combat_stage_sheet_index_by_enemy_id":
		is_same(_COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID, VISUAL_REGISTRY_DATA_SCRIPT.COMBAT_STAGE_SHEET_INDEX_BY_ENEMY_ID),
		"enemy_visual_profiles": is_same(_ENEMY_VISUAL_PROFILES, VISUAL_REGISTRY_DATA_SCRIPT.ENEMY_VISUAL_PROFILES),
		"icon_index_by_key": is_same(_ICON_INDEX_BY_KEY, VISUAL_REGISTRY_DATA_SCRIPT.ICON_INDEX_BY_KEY),
		"relic_index_by_key": is_same(_RELIC_INDEX_BY_KEY, VISUAL_REGISTRY_DATA_SCRIPT.RELIC_INDEX_BY_KEY),
		"mastery_orb_by_icon_key": is_same(_MASTERY_ORB_BY_ICON_KEY, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ORB_BY_ICON_KEY),
		"mastery_beam_by_orb_id": is_same(_MASTERY_BEAM_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_BEAM_BY_ORB_ID),
		"mastery_card_by_orb_id": is_same(_MASTERY_CARD_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_CARD_BY_ORB_ID),
		"mastery_icon_by_orb_id": is_same(_MASTERY_ICON_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ICON_BY_ORB_ID),
		"stable_placeholder_icon_colors": is_same(_STABLE_PLACEHOLDER_ICON_COLORS, VISUAL_REGISTRY_DATA_SCRIPT.STABLE_PLACEHOLDER_ICON_COLORS),
		"texture_factory_is_resource":
		VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT.new() is Resource and VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT.new().has_method("post_match_vfx_textures"),
		"texture_store_is_refcounted":
		VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT.new() is RefCounted and VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT.new().has_method("runtime_texture"),
	}


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
		var fallback_texture := _texture_store.safe_load_texture(fallback, "enemy_fallback")
		if fallback_texture != null:
			_enemy_portrait_textures[normalized_id] = fallback_texture
			return fallback_texture
		return placeholder_texture("enemy_portrait")
	var loaded := _texture_store.safe_load_texture(path, "enemy:%s" % normalized_id)
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
	var loaded := _texture_store.safe_load_texture(path, "enemy_stage_bg:%s" % normalized_id)
	if loaded != null:
		_enemy_stage_background_textures[normalized_id] = loaded
		return loaded
	return combat_background()


func enemy_sprite(enemy_id: String) -> Texture2D:
	var normalized_id := _normalized_enemy_visual_id(enemy_id)
	if _enemy_sprite_textures.has(normalized_id):
		return _enemy_sprite_textures[normalized_id]
	var runtime_key := _runtime_enemy_key(enemy_id)
	var runtime_texture := _texture_store.runtime_texture(PATH_RUNTIME_MANIFEST, "enemies", runtime_key)
	if runtime_texture != null:
		_enemy_sprite_textures[normalized_id] = runtime_texture
		return runtime_texture
	_warn_missing("runtime_enemy:%s:%s" % [normalized_id, runtime_key])
	var path := String(_ENEMY_SPRITE_PATHS.get(normalized_id, ""))
	if path != "":
		var loaded := _texture_store.safe_load_texture(path, "enemy_sprite:%s" % normalized_id)
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
	var runtime_entry := _texture_store.runtime_texture_entry(PATH_RUNTIME_MANIFEST, "enemies", runtime_key)
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
		var runtime_texture := _texture_store.runtime_texture(PATH_RUNTIME_MANIFEST, "mastery", runtime_key)
		if runtime_texture != null:
			return runtime_texture
	_ensure_mastery_textures()
	return _mastery_textures.get(orb_id, placeholder_texture("mastery_missing"))


func menu_mastery_icon(orb_id: int) -> Texture2D:
	if not ORB_TYPE_SCRIPT.is_valid_id(orb_id):
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
	if not ORB_TYPE_SCRIPT.is_valid_id(orb_id):
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
	if not ORB_TYPE_SCRIPT.is_valid_id(orb_id):
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


func collection_card_frame(rarity: String) -> Texture2D:
	var normalized := rarity.strip_edges().to_lower()
	if normalized != "uncommon" and normalized != "rare":
		normalized = "common"
	var texture := _collection_ui_texture("card_frame_%s" % normalized)
	return (
		texture if texture != null else placeholder_texture("collection_card_frame_%s_missing" % normalized, Color(0.12, 0.10, 0.08, 1.0), Vector2i(505, 720))
	)


func collection_relic_banner_frame(rarity: String) -> Texture2D:
	var normalized := rarity.strip_edges().to_lower()
	if normalized != "uncommon" and normalized != "rare":
		normalized = "common"
	var texture := _collection_ui_texture("relic_banner_frame_%s" % normalized)
	return (
		texture
		if texture != null
		else placeholder_texture("collection_relic_banner_frame_%s_missing" % normalized, Color(0.12, 0.07, 0.14, 1.0), Vector2i(1032, 178))
	)


func collection_price_badge() -> Texture2D:
	var texture := _collection_ui_texture("price_badge")
	return texture if texture != null else placeholder_texture("collection_price_badge_missing", Color(0.48, 0.27, 0.06, 1.0), Vector2i(486, 180))


func collection_hud_slot_frame() -> Texture2D:
	var texture := _collection_ui_texture("hud_slot_frame")
	return texture if texture != null else placeholder_texture("collection_hud_slot_frame_missing", Color(0.16, 0.13, 0.09, 1.0), Vector2i(96, 96))


func shop_action_button_frame(kind: String) -> Texture2D:
	var normalized := kind.strip_edges().to_lower()
	if normalized != "continue":
		normalized = "reroll"
	var texture := _shop_ui_texture("shop_action_button_%s" % normalized)
	var placeholder_color := Color(0.08, 0.26, 0.38, 1.0) if normalized == "reroll" else Color(0.12, 0.36, 0.08, 1.0)
	return texture if texture != null else placeholder_texture("shop_action_button_%s_missing" % normalized, placeholder_color, Vector2i(1200, 160))


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
	return (
		portrait_fallback
		if portrait_fallback != null
		else placeholder_texture("combat_stage_fallback_missing", Color(0.08, 0.09, 0.12, 0.84), Vector2i(1048, 336))
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
		_combat_enemy_stage_sheet = _texture_store.safe_load_texture(PATH_COMBAT_ENEMY_STAGE_SHEET, "combat_enemy_stage_sheet")
	if _combat_enemy_stage_sheet == null:
		return null
	var columns := 2
	var rows := 2
	var column := index % columns
	var row := int(floor(float(index) / float(columns)))
	var cell_width := float(_combat_enemy_stage_sheet.get_width()) / float(columns)
	var cell_height := float(_combat_enemy_stage_sheet.get_height()) / float(rows)
	var stage_texture := _atlas_region(_combat_enemy_stage_sheet, Rect2(cell_width * column, cell_height * row, cell_width, cell_height))
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
	var texture: Texture2D = _texture_factory.placeholder_texture(color, size)
	_placeholder_cache[key] = texture
	return texture


func _ensure_background_textures() -> void:
	if _backgrounds_loaded:
		return
	_backgrounds_loaded = true
	_combat_background = _texture_store.safe_load_texture(PATH_COMBAT_BACKGROUND, "combat_background")
	_shop_background = _texture_store.safe_load_texture(PATH_SHOP_BACKGROUND, "shop_background")


func _ensure_hero_portrait() -> void:
	if _hero_portrait_loaded:
		return
	_hero_portrait_loaded = true
	_hero_portrait = _texture_store.runtime_texture(PATH_RUNTIME_MANIFEST, "heroes", "hero_orbwalker")
	if _hero_portrait == null:
		_hero_portrait = _texture_store.safe_load_texture(PATH_FALLBACK_HERO_PORTRAIT, "hero_portrait_fallback")
	if _hero_portrait == null:
		_hero_portrait = _texture_store.safe_load_texture(PATH_HERO_PORTRAIT, "hero_portrait")


func _ensure_shop_merchant_header_texture() -> void:
	if _shop_merchant_header_loaded:
		return
	_shop_merchant_header_loaded = true
	for path in SHOP_MERCHANT_HEADER_CANDIDATE_PATHS:
		if not ResourceLoader.exists(path):
			continue
		var loaded := _texture_store.safe_load_texture(path, "shop_merchant_header")
		if loaded != null:
			_shop_merchant_header = loaded
			return


func _ensure_ui_sheets() -> void:
	if _ui_sheets_loaded:
		return
	_ui_sheets_loaded = true
	_ui_frames = _texture_store.safe_load_texture(PATH_UI_FRAME_SHEET, "ui_frame_sheet")
	_ui_bars = _texture_store.safe_load_texture(PATH_UI_BAR_SHEET, "ui_bar_sheet")
	_ui_shop_cards = _texture_store.safe_load_texture(PATH_UI_SHOP_CARD_SHEET, "ui_shop_card_sheet")


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
	var sheet := _texture_store.safe_load_texture(PATH_ORB_SHEET, "orb_sheet")
	if sheet == null:
		return
	var columns := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / 2.0
	var orb_ids: Array[int] = [
		ORB_TYPE_SCRIPT.Id.FIRE,
		ORB_TYPE_SCRIPT.Id.ICE,
		ORB_TYPE_SCRIPT.Id.EARTH,
		ORB_TYPE_SCRIPT.Id.HEART,
		ORB_TYPE_SCRIPT.Id.ARMOR,
		ORB_TYPE_SCRIPT.Id.GOLD,
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
	for orb_id in _runtime_orb_key_by_id.keys():
		var runtime_key := String(_runtime_orb_key_by_id[orb_id])
		var texture := _texture_store.runtime_texture(PATH_RUNTIME_MANIFEST, "orbs", runtime_key)
		if texture == null:
			return false
		loaded_orbs[orb_id] = texture
	if loaded_orbs.size() != _runtime_orb_key_by_id.size():
		return false
	for orb_id in loaded_orbs.keys():
		_orb_textures[orb_id] = loaded_orbs[orb_id]
	return true


func _try_build_derived_orb_textures() -> bool:
	var loaded_orbs: Dictionary = {}
	for orb_id in _derived_orb_filename_by_id.keys():
		var file_name := String(_derived_orb_filename_by_id[orb_id])
		if file_name == "":
			return false
		var path := "%s/%s" % [PATH_DERIVED_ORB_DIR, file_name]
		var texture := _texture_store.safe_load_texture(path, "derived_orb:%s" % file_name)
		if texture == null:
			return false
		loaded_orbs[orb_id] = texture
	if loaded_orbs.size() != _derived_orb_filename_by_id.size():
		return false
	for orb_id in loaded_orbs.keys():
		_orb_textures[orb_id] = loaded_orbs[orb_id]
	return true


func _build_intent_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_INTENT_SHEET, "intent_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_intent_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_rarity_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_RARITY_SHEET, "rarity_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_rarity_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_mastery_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_MASTERY_SHEET, "mastery_sheet")
	if sheet == null:
		return
	var columns := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / 2.0
	var orb_ids: Array[int] = [
		ORB_TYPE_SCRIPT.Id.FIRE,
		ORB_TYPE_SCRIPT.Id.ICE,
		ORB_TYPE_SCRIPT.Id.EARTH,
		ORB_TYPE_SCRIPT.Id.HEART,
		ORB_TYPE_SCRIPT.Id.ARMOR,
		ORB_TYPE_SCRIPT.Id.GOLD,
	]
	for index in orb_ids.size():
		var column := index % columns
		var row := int(floor(float(index) / float(columns)))
		var orb_id := int(orb_ids[index])
		_mastery_textures[orb_id] = _atlas_region(sheet, Rect2(cell_width * column, cell_height * row, cell_width, cell_height))


func _build_icon_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_ITEM_SHEET, "item_sheet")
	if sheet == null:
		return
	var columns := 5
	var rows := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / float(rows)
	var atlas_index := 0
	for row in rows:
		for column in columns:
			var region := Rect2(cell_width * column, cell_height * row, cell_width, cell_height)
			_icon_textures[atlas_index] = _atlas_region(sheet, region)
			atlas_index += 1


func _build_relic_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_RELIC_SHEET, "relic_sheet")
	if sheet == null:
		return
	var columns := 5
	var cell_width := float(sheet.get_width()) / float(columns)
	for index in columns:
		_relic_textures[index] = _atlas_region(sheet, Rect2(cell_width * index, 0.0, cell_width, float(sheet.get_height())))


func _build_vfx_textures() -> void:
	var sheet := _texture_store.safe_load_texture(PATH_VFX_SHEET, "vfx_sheet")
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
	var textures: Dictionary = _texture_factory.post_match_vfx_textures()
	for key in textures.keys():
		_vfx_textures[key] = textures[key]


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
		var safe_loaded := _texture_store.safe_load_texture(path, key)
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


func _runtime_icon_texture(icon_key: String) -> Texture2D:
	return _texture_store.runtime_texture(PATH_RUNTIME_MANIFEST, "icons", icon_key.strip_edges().to_lower())


func _collection_ui_texture(key: String) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	if normalized_key == "":
		return null
	var path := "%s/%s.png" % [PATH_RUNTIME_COLLECTION_UI_DIR, normalized_key]
	return _texture_store.cached_png_texture(path, "collection_ui:%s" % normalized_key)


func _shop_ui_texture(key: String) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	if normalized_key == "":
		return null
	var path := "%s/%s.png" % [PATH_RUNTIME_SHOP_UI_DIR, normalized_key]
	return _texture_store.cached_png_texture(path, "shop_ui:%s" % normalized_key)


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)


static func _dictionary_string_values(source: Dictionary) -> Array[String]:
	return VISUAL_REGISTRY_DATA_SCRIPT.dictionary_string_values(source)


static func _derived_orb_contract_paths() -> Array[String]:
	return VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_contract_paths()


static func _path_keys(base_path: String, keys: Array) -> Array[String]:
	return VISUAL_REGISTRY_DATA_SCRIPT.path_keys(base_path, keys)


static func _unique_contract_paths(paths: Array[String]) -> Array[String]:
	return VISUAL_REGISTRY_DATA_SCRIPT.unique_contract_paths(paths)
