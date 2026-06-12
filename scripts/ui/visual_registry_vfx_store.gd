extends RefCounted
class_name VisualRegistryVfxStore

const VISUAL_REGISTRY_DATA_SCRIPT := preload("res://scripts/ui/visual_registry_data.gd")
const VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/ui/visual_registry_texture_factory.gd")
const VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT := preload("res://scripts/ui/visual_registry_texture_store.gd")
const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")

const PATH_DERIVED_VFX_DIR := VISUAL_REGISTRY_DATA_SCRIPT.PATH_DERIVED_VFX_DIR
const PATH_VFX_SHEET := VISUAL_REGISTRY_DATA_SCRIPT.PATH_VFX_SHEET
const _MASTERY_BEAM_BY_ORB_ID := VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_BEAM_BY_ORB_ID

var _warned_keys: Dictionary = {}
var _placeholder_cache: Dictionary = {}
var _vfx_textures: Dictionary = {}
var _texture_factory: Resource = VISUAL_REGISTRY_TEXTURE_FACTORY_SCRIPT.new()
var _texture_store = VISUAL_REGISTRY_TEXTURE_STORE_SCRIPT.new()
var _vfx_textures_built := false


static func lookup_table_alias_contract() -> Dictionary:
	return {
		"mastery_beam_by_orb_id": is_same(_MASTERY_BEAM_BY_ORB_ID, VISUAL_REGISTRY_DATA_SCRIPT.MASTERY_BEAM_BY_ORB_ID),
	}


func mastery_beam_texture(orb_id: int) -> Texture2D:
	if not ORB_TYPE_SCRIPT.is_valid_id(orb_id):
		return null
	var beam_suffix := String(_MASTERY_BEAM_BY_ORB_ID.get(orb_id, ""))
	if beam_suffix == "":
		return null
	return _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_beam_%s" % beam_suffix, _vfx_textures)


func mastery_shell_texture() -> Texture2D:
	var shell_texture := _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell_armor", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	shell_texture = _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	return _placeholder_texture("mastery_shell_missing", Color(0.25, 0.34, 0.52, 0.90), Vector2i(120, 120))


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


func vfx_texture(effect_name: String) -> Texture2D:
	_ensure_vfx_textures()
	var key := effect_name.to_lower()
	return _vfx_textures.get(key, _placeholder_texture("vfx_missing"))


func _ensure_vfx_textures() -> void:
	if _vfx_textures_built:
		return
	_vfx_textures_built = true
	_build_vfx_textures()


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


func _placeholder_texture(key: String, color: Color = Color(0.32, 0.32, 0.36, 1.0), size: Vector2i = Vector2i(96, 96)) -> Texture2D:
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var texture: Texture2D = _texture_factory.placeholder_texture(color, size)
	_placeholder_cache[key] = texture
	return texture
