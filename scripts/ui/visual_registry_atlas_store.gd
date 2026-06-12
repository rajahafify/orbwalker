extends RefCounted
class_name VisualRegistryAtlasStore

const VISUAL_REGISTRY_DATA_SCRIPT := preload("res://scripts/ui/visual_registry_data.gd")
const VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/ui/visual_registry_texture_factory.gd")
const VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT := preload("res://scripts/ui/visual_registry_texture_store.gd")
const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")

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
const PATH_RUNTIME_MANIFEST := VISUAL_REGISTRY_DATA_SCRIPT.PATH_RUNTIME_MANIFEST

const _INTENT_INDEX_BY_TYPE := VISUAL_REGISTRY_DATA_SCRIPT.INTENT_INDEX_BY_TYPE
const _RARITY_INDEX := VISUAL_REGISTRY_DATA_SCRIPT.RARITY_INDEX
const _ICON_INDEX_BY_KEY := VISUAL_REGISTRY_DATA_SCRIPT.ICON_INDEX_BY_KEY
const _RELIC_INDEX_BY_KEY := VISUAL_REGISTRY_DATA_SCRIPT.RELIC_INDEX_BY_KEY
const _MASTERY_ORB_BY_ICON_KEY := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ORB_BY_ICON_KEY
const _MASTERY_CARD_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_CARD_BY_ORB_ID
const _MASTERY_ICON_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ICON_BY_ORB_ID
const _STABLE_PLACEHOLDER_ICON_COLORS := VISUAL_REGISTRY_DATA_SCRIPT.STABLE_PLACEHOLDER_ICON_COLORS

static var _derived_orb_filename_by_id: Dictionary = VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_filename_by_id()
static var _runtime_orb_key_by_id: Dictionary = VISUAL_REGISTRY_DATA_SCRIPT.runtime_orb_key_by_id()

var _warned_keys: Dictionary = {}
var _placeholder_cache: Dictionary = {}
var _orb_textures: Dictionary = {}
var _intent_textures: Dictionary = {}
var _rarity_textures: Dictionary = {}
var _mastery_textures: Dictionary = {}
var _icon_textures: Dictionary = {}
var _relic_textures: Dictionary = {}
var _derived_icon_textures: Dictionary = {}
var _derived_hud_textures: Dictionary = {}
var _derived_chrome_textures: Dictionary = {}
var _texture_factory: Resource = VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT.new()
var _texture_store = VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT.new()

var _orb_textures_built := false
var _intent_textures_built := false
var _rarity_textures_built := false
var _mastery_textures_built := false
var _icon_textures_built := false
var _relic_textures_built := false


static func lookup_table_alias_contract() -> Dictionary:
	return {
		"intent_index_by_type": is_same(_INTENT_INDEX_BY_TYPE, VISUAL_REGISTRY_DATA_SCRIPT.INTENT_INDEX_BY_TYPE),
		"rarity_index": is_same(_RARITY_INDEX, VISUAL_REGISTRY_DATA_SCRIPT.RARITY_INDEX),
		"derived_orb_filename_by_id": is_same(_derived_orb_filename_by_id, VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_filename_by_id()),
		"runtime_orb_key_by_id": is_same(_runtime_orb_key_by_id, VISUAL_REGISTRY_DATA_SCRIPT.runtime_orb_key_by_id()),
		"icon_index_by_key": is_same(_ICON_INDEX_BY_KEY, VISUAL_REGISTRY_DATA_SCRIPT.ICON_INDEX_BY_KEY),
		"relic_index_by_key": is_same(_RELIC_INDEX_BY_KEY, VISUAL_REGISTRY_DATA_SCRIPT.RELIC_INDEX_BY_KEY),
		"mastery_orb_by_icon_key": is_same(_MASTERY_ORB_BY_ICON_KEY, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ORB_BY_ICON_KEY),
		"mastery_card_by_orb_id": is_same(_MASTERY_CARD_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_CARD_BY_ORB_ID),
		"mastery_icon_by_orb_id": is_same(_MASTERY_ICON_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_ICON_BY_ORB_ID),
		"stable_placeholder_icon_colors": is_same(_STABLE_PLACEHOLDER_ICON_COLORS, VISUAL_REGISTRY_DATA_SCRIPT.STABLE_PLACEHOLDER_ICON_COLORS),
	}


func orb_texture(orb_id: int) -> Texture2D:
	_ensure_orb_textures()
	return _orb_textures.get(orb_id, placeholder_texture("orb_missing"))


func intent_badge(intent_type: int, hud_lookup: Callable) -> Texture2D:
	var hud_key := ""
	match intent_type:
		0:
			hud_key = "intent_attack"
		1:
			hud_key = "intent_block"
		2:
			hud_key = "intent_attack_block"
	if hud_key != "" and hud_lookup.is_valid():
		var hud_badge := hud_lookup.call(hud_key) as Texture2D
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


func rarity_badge(rarity: String, hud_lookup: Callable) -> Texture2D:
	var key := rarity.to_lower()
	if hud_lookup.is_valid():
		var hud_badge := hud_lookup.call("rarity_%s" % key, false) as Texture2D
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


func mastery_panel_frame_texture(chrome_lookup: Callable) -> Texture2D:
	if chrome_lookup.is_valid():
		var frame_texture := chrome_lookup.call("mastery_panel_frame", false) as Texture2D
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


func placeholder_texture(key: String, color: Color = Color(0.32, 0.32, 0.36, 1.0), size: Vector2i = Vector2i(96, 96)) -> Texture2D:
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var texture: Texture2D = _texture_factory.placeholder_texture(color, size)
	_placeholder_cache[key] = texture
	return texture


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


func _load_derived_icon(icon_key: String) -> Texture2D:
	if icon_key == "":
		return null
	if _derived_icon_textures.has(icon_key):
		return _derived_icon_textures[icon_key]
	return _load_derived_texture(PATH_DERIVED_ICON_DIR, icon_key, _derived_icon_textures)


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


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)
