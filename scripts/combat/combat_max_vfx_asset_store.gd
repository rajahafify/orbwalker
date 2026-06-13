extends RefCounted
class_name CombatMaxVfxAssetStore

var _asset_catalog: Variant
var _visual_registry: Variant
var _texture_cache: Dictionary = {}
var _pack_scene_cache: Dictionary = {}
var _elemental_scene_cache: Dictionary = {}
var _status_texture_cache: Dictionary = {}
var _atmospheric_texture_cache: Dictionary = {}
var _external_scene_cache: Dictionary = {}


func bind(asset_catalog: Variant, visual_registry: Variant) -> void:
	_asset_catalog = asset_catalog
	_visual_registry = visual_registry


func required_texture_keys() -> Array[String]:
	return _asset_catalog.required_texture_keys()


func required_status_sheet_paths() -> Dictionary:
	return _asset_catalog.status_sheet_paths()


func required_atmospheric_sheet_paths() -> Dictionary:
	return _asset_catalog.atmospheric_sheet_paths()


func external_scene_paths() -> Dictionary:
	return _asset_catalog.external_scene_paths()


func status_vfx_available() -> bool:
	for key in ["burn", "freeze", "poison", "heal", "shield", "blessed"]:
		if status_texture(key) == null:
			return false
	return true


func atmospheric_vfx_available() -> bool:
	for key in ["embers", "snow", "wind", "magic_wind", "godrays"]:
		if atmospheric_texture(key) == null:
			return false
	return true


func elemental_magic_available() -> bool:
	return elemental_scene("cast") != null and elemental_scene("projectile") != null and elemental_scene("area") != null


func pack_vfx_available() -> bool:
	return pack_scene("hit_01") != null and pack_scene("impact_01") != null and pack_scene("big_impact_01") != null


func status_texture(key: String) -> Texture2D:
	if _status_texture_cache.has(key):
		return _status_texture_cache[key]
	var path: String = _asset_catalog.status_sheet_path(key)
	if path == "":
		return null
	var texture := _texture_from_path(path)
	if texture != null:
		_status_texture_cache[key] = texture
	return texture


func atmospheric_texture(key: String) -> Texture2D:
	if _atmospheric_texture_cache.has(key):
		return _atmospheric_texture_cache[key]
	var path: String = _asset_catalog.atmospheric_sheet_path(key)
	if path == "":
		return null
	var texture := _texture_from_path(path)
	if texture != null:
		_atmospheric_texture_cache[key] = texture
	return texture


func flame_scene() -> PackedScene:
	return external_scene("flame", _asset_catalog.external_scene_path("flame"))


func beam_scene() -> PackedScene:
	return external_scene("beam", _asset_catalog.external_scene_path("beam"))


func shield_scene() -> PackedScene:
	return external_scene("shield", _asset_catalog.external_scene_path("shield"))


func tornado_scene() -> PackedScene:
	return external_scene("tornado", _asset_catalog.external_scene_path("tornado"))


func elemental_scene(key: String) -> PackedScene:
	if _elemental_scene_cache.has(key):
		return _elemental_scene_cache[key]
	var path: String = _asset_catalog.elemental_magic_scene_path(key)
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_elemental_scene_cache[key] = scene
	return scene


func pack_scene(key: String) -> PackedScene:
	if _pack_scene_cache.has(key):
		return _pack_scene_cache[key]
	var path: String = _asset_catalog.pack_scene_path(key)
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if scene != null:
		_pack_scene_cache[key] = scene
	return scene


func max_texture(key: String) -> Texture2D:
	if _texture_cache.has(key):
		return _texture_cache[key]
	if _visual_registry == null or not _visual_registry.has_method("max_combat_vfx_texture"):
		return null
	var texture: Texture2D = _visual_registry.max_combat_vfx_texture(key)
	if texture != null:
		_texture_cache[key] = texture
	return texture


func external_scene(key: String, path: String) -> PackedScene:
	if _external_scene_cache.has(key):
		return _external_scene_cache[key]
	var scene := load(path) as PackedScene
	if scene != null:
		_external_scene_cache[key] = scene
	return scene


func _texture_from_path(path: String) -> Texture2D:
	var imported_texture := load(path) as Texture2D
	if imported_texture != null:
		return imported_texture
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)
