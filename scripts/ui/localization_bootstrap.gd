extends RefCounted
class_name LocalizationBootstrap

const TRANSLATION_PATHS := [
	"res://resources/localization/ui_en.tres",
	"res://resources/localization/ui_es.tres",
]

static var _loaded := false


static func ensure_loaded() -> void:
	if _loaded:
		return
	for path in TRANSLATION_PATHS:
		var translation := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Translation
		if translation == null:
			push_warning("Localization translation failed to load: %s" % path)
			continue
		TranslationServer.add_translation(translation)
	_loaded = true


static func translation_paths() -> Array[String]:
	var paths: Array[String] = []
	for path in TRANSLATION_PATHS:
		paths.append(String(path))
	return paths
