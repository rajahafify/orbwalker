extends RefCounted
class_name VisualRegistryTextureStore

var _runtime_manifest: Dictionary = {}
var _runtime_texture_cache: Dictionary = {}
var _warned_keys: Dictionary = {}
var _runtime_manifest_loaded := false


func runtime_texture(manifest_path: String, category: String, key: String) -> Texture2D:
	if category == "" or key == "":
		return null
	var entry := runtime_texture_entry(manifest_path, category, key)
	var path := String(entry.get("path", ""))
	if path == "":
		return null
	return cached_png_texture(path, "runtime:%s:%s" % [category, key])


func runtime_texture_entry(manifest_path: String, category: String, key: String) -> Dictionary:
	if category == "" or key == "":
		return {}
	_ensure_runtime_manifest(manifest_path)
	if _runtime_manifest.is_empty():
		return {}
	var categories := Dictionary(_runtime_manifest.get("categories", {}))
	var category_entries := Dictionary(categories.get(category, {}))
	return Dictionary(category_entries.get(key, {}))


func cached_png_texture(path: String, key: String) -> Texture2D:
	if path == "":
		return null
	if _runtime_texture_cache.has(path):
		return _runtime_texture_cache[path]
	var texture := load_png_texture(path, key)
	if texture != null:
		_runtime_texture_cache[path] = texture
	return texture


func safe_load_texture(path: String, key: String) -> Texture2D:
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


func load_png_texture(path: String, key: String) -> Texture2D:
	if ResourceLoader.exists(path):
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


func _ensure_runtime_manifest(manifest_path: String) -> void:
	if _runtime_manifest_loaded:
		return
	_runtime_manifest_loaded = true
	if not FileAccess.file_exists(manifest_path):
		return
	var file := FileAccess.open(manifest_path, FileAccess.READ)
	if file == null:
		_warn_missing("runtime_manifest")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_runtime_manifest = parsed
	else:
		_warn_missing("runtime_manifest_parse")


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)
