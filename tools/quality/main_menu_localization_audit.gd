extends SceneTree
class_name MainMenuLocalizationAudit

const MAIN_MENU_VIEW := preload("res://scripts/main_menu/main_menu_view.gd")

const AUDITED_SCRIPT_PATHS := [
	"res://scripts/main_menu/main_menu_view.gd",
]
const AUDITED_SCENE_PATHS := [
	"res://scenes/main_menu.tscn",
]
const TRANSLATION_PATHS := [
	"res://resources/localization/ui_en.tres",
	"res://resources/localization/ui_es.tres",
]
const SCRIPT_LITERAL_DISPLAY_PATTERN := "(?:^|\\s)(?:[A-Za-z_][A-Za-z0-9_]*\\.)?(?:text|tooltip_text|placeholder_text)\\s*=\\s*\"([^\"]*)\""
const SCENE_DISPLAY_PROPERTY_PATTERN := "^\\s*(?:text|tooltip_text|placeholder_text)\\s*=\\s*\"([^\"]*)\""
const LOCALIZATION_KEY_PREFIX := "MAIN_MENU_"


func _initialize() -> void:
	var report := run_report()
	_print_report(report)
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var failures: Array[String] = []
	var scene_keys := _collect_scene_display_keys(failures)
	var required_keys := _required_keys(scene_keys)
	_check_script_literal_display_assignments(failures)
	_check_translations(required_keys, failures)
	return {
		"passed": failures.is_empty(),
		"required_keys": required_keys.size(),
		"scene_keys": scene_keys.size(),
		"translation_files": TRANSLATION_PATHS.size(),
		"failures": failures,
	}


static func _required_keys(scene_keys: Array[String]) -> Array[String]:
	var seen := {}
	var keys: Array[String] = []
	for key in MAIN_MENU_VIEW.localization_keys():
		_add_key(String(key), seen, keys)
	for key in scene_keys:
		_add_key(key, seen, keys)
	keys.sort()
	return keys


static func _add_key(key: String, seen: Dictionary, keys: Array[String]) -> void:
	if key == "" or seen.has(key):
		return
	seen[key] = true
	keys.append(key)


static func _collect_scene_display_keys(failures: Array[String]) -> Array[String]:
	var regex := RegEx.new()
	if regex.compile(SCENE_DISPLAY_PROPERTY_PATTERN) != OK:
		failures.append("Failed to compile scene display-property regex.")
		return []
	var keys: Array[String] = []
	for path in AUDITED_SCENE_PATHS:
		var source := FileAccess.get_file_as_string(path)
		if source.is_empty():
			failures.append("Expected audited scene to be readable: %s." % path)
			continue
		for line_number in range(source.split("\n").size()):
			var line := String(source.split("\n")[line_number])
			var result := regex.search(line)
			if result == null:
				continue
			var value := result.get_string(1)
			if value == "":
				continue
			if not value.begins_with(LOCALIZATION_KEY_PREFIX):
				failures.append("%s:%d uses literal display text '%s'; use a %s key." % [
					path,
					line_number + 1,
					value,
					LOCALIZATION_KEY_PREFIX,
				])
				continue
			keys.append(value)
	return keys


static func _check_script_literal_display_assignments(failures: Array[String]) -> void:
	var regex := RegEx.new()
	if regex.compile(SCRIPT_LITERAL_DISPLAY_PATTERN) != OK:
		failures.append("Failed to compile script display-assignment regex.")
		return
	for path in AUDITED_SCRIPT_PATHS:
		var source := FileAccess.get_file_as_string(path)
		if source.is_empty():
			failures.append("Expected audited script to be readable: %s." % path)
			continue
		var lines := source.split("\n")
		for line_number in range(lines.size()):
			var result := regex.search(String(lines[line_number]))
			if result == null:
				continue
			failures.append("%s:%d assigns literal display text '%s'; use tr(...) with a %s key." % [
				path,
				line_number + 1,
				result.get_string(1),
				LOCALIZATION_KEY_PREFIX,
			])


static func _check_translations(required_keys: Array[String], failures: Array[String]) -> void:
	for path in TRANSLATION_PATHS:
		var translation := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Translation
		if translation == null:
			failures.append("Expected translation resource to load: %s." % path)
			continue
		var messages := {}
		for message in translation.get_message_list():
			messages[String(message)] = true
		for key in required_keys:
			if not messages.has(key):
				failures.append("Expected %s to define translation key %s." % [path, key])


static func _print_report(report: Dictionary) -> void:
	print("[MainMenuLocalizationAudit] keys=%d scene_keys=%d translation_files=%d failed=%d" % [
		int(report.get("required_keys", 0)),
		int(report.get("scene_keys", 0)),
		int(report.get("translation_files", 0)),
		Array(report.get("failures", [])).size(),
	])
	for failure in Array(report.get("failures", [])):
		printerr("[MainMenuLocalizationAudit][FAIL] %s" % String(failure))
