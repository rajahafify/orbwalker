extends RefCounted
class_name ExportReleaseGuardTest

const EXPORT_PRESETS_PATH := "res://export_presets.cfg"
const PROJECT_SETTINGS_PATH := "res://project.godot"
const GDAI_RUNTIME_PROXY_PATH := "*res://scripts/core/gdai_mcp_runtime_proxy.gd"
const DEV_EXCLUDE_PATTERNS := [
	"addons/*",
	"android/*",
	"build/*",
	"docs/*",
	"logs/*",
	"scripts/debug/*",
	"scenes/debug/*",
	"tmp/*",
	"tools/*",
	"wiki/*",
	".claude/*",
	".codex/*",
	".memsearch/*",
	".obsidian/*",
	"*.apk",
	"*.aab",
	"*.apks",
	"*.idsig",
]
const DEBUG_EXPORT_PATHS := [
	"scripts/debug/ar01_combat_result_probe.gd",
	"scripts/debug/mobile_combat_layout_probe.gd",
	"scripts/debug/player_hud_contract_probe.gd",
	"scripts/debug/top_header_contract_probe.gd",
	"scripts/debug/vfx_debug_catalog.gd",
	"scripts/debug/vfx_gallery_index.gd",
	"scripts/debug/vfx_gallery_show.gd",
	"scenes/debug/vfx_gallery_index.tscn",
	"scenes/debug/vfx_gallery_show.tscn",
]
const RAW_MUSIC_INCLUDE_PATTERN := "resources/audio/raw_music/*.wav.bin"
const IMPORTED_MUSIC_EXCLUDE_PATTERN := "resources/audio/music/*.wav"
const RAW_MUSIC_EXPORT_PRESETS := ["Android", "Web"]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("release_presets_exclude_dev_tooling_paths", _test_release_presets_exclude_dev_tooling_paths, failures)
	_run_case("debug_entrypoints_match_release_exclude_filters", _test_debug_entrypoints_match_release_exclude_filters, failures)
	_run_case("gdai_autoload_uses_guarded_runtime_proxy", _test_gdai_autoload_uses_guarded_runtime_proxy, failures)
	_run_case("raw_music_exports_exclude_imported_music_duplicates", _test_raw_music_exports_exclude_imported_music_duplicates, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_release_presets_exclude_dev_tooling_paths() -> String:
	var config_result := _load_config(EXPORT_PRESETS_PATH)
	if config_result.has("__error"):
		return String(config_result["__error"])
	var config: ConfigFile = config_result["config"]
	for preset_section in _preset_sections(config):
		var preset_name := String(config.get_value(preset_section, "name", preset_section))
		var excludes := _exclude_patterns_for(config, preset_section)
		for pattern in DEV_EXCLUDE_PATTERNS:
			if not excludes.has(pattern):
				return "Expected export preset '%s' to exclude '%s'." % [preset_name, pattern]
	return ""


func _test_debug_entrypoints_match_release_exclude_filters() -> String:
	var config_result := _load_config(EXPORT_PRESETS_PATH)
	if config_result.has("__error"):
		return String(config_result["__error"])
	var config: ConfigFile = config_result["config"]
	for preset_section in _preset_sections(config):
		var preset_name := String(config.get_value(preset_section, "name", preset_section))
		var excludes := _exclude_patterns_for(config, preset_section)
		for path in DEBUG_EXPORT_PATHS:
			if not _path_matches_any_pattern(path, excludes):
				return "Expected export preset '%s' to exclude debug path '%s'." % [preset_name, path]
	return ""


func _test_gdai_autoload_uses_guarded_runtime_proxy() -> String:
	var config_result := _load_config(PROJECT_SETTINGS_PATH)
	if config_result.has("__error"):
		return String(config_result["__error"])
	var config: ConfigFile = config_result["config"]
	var autoload_path := String(config.get_value("autoload", "GDAIMCPRuntime", ""))
	if autoload_path != GDAI_RUNTIME_PROXY_PATH:
		return "Expected GDAIMCPRuntime autoload to use %s, got %s." % [GDAI_RUNTIME_PROXY_PATH, autoload_path]
	if autoload_path.find("addons/gdai-mcp-plugin-godot") >= 0:
		return "Expected exported autoload path not to reference the editor MCP addon directly."
	return ""


func _test_raw_music_exports_exclude_imported_music_duplicates() -> String:
	var config_result := _load_config(EXPORT_PRESETS_PATH)
	if config_result.has("__error"):
		return String(config_result["__error"])
	var config: ConfigFile = config_result["config"]
	for preset_section in _preset_sections(config):
		var preset_name := String(config.get_value(preset_section, "name", preset_section))
		if not RAW_MUSIC_EXPORT_PRESETS.has(preset_name):
			continue
		var includes := _include_patterns_for(config, preset_section)
		var excludes := _exclude_patterns_for(config, preset_section)
		if not includes.has(RAW_MUSIC_INCLUDE_PATTERN):
			return "Expected export preset '%s' to include '%s'." % [preset_name, RAW_MUSIC_INCLUDE_PATTERN]
		if not excludes.has(IMPORTED_MUSIC_EXCLUDE_PATTERN):
			return "Expected export preset '%s' to exclude imported music WAV duplicates via '%s'." % [preset_name, IMPORTED_MUSIC_EXCLUDE_PATTERN]
	return ""


func _load_config(path: String) -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(path)
	if error != OK:
		return {"__error": "Expected ConfigFile.load(%s) to succeed; error %d." % [path, error]}
	return {"config": config}


func _preset_sections(config: ConfigFile) -> Array[String]:
	var sections: Array[String] = []
	for section in config.get_sections():
		var section_name := String(section)
		if section_name.begins_with("preset.") and not section_name.ends_with(".options"):
			sections.append(section_name)
	sections.sort()
	return sections


func _exclude_patterns_for(config: ConfigFile, preset_section: String) -> Array[String]:
	var raw := String(config.get_value(preset_section, "exclude_filter", ""))
	var patterns: Array[String] = []
	for pattern in raw.split(",", false):
		var trimmed := String(pattern).strip_edges()
		if trimmed != "":
			patterns.append(trimmed)
	return patterns


func _include_patterns_for(config: ConfigFile, preset_section: String) -> Array[String]:
	var raw := String(config.get_value(preset_section, "include_filter", ""))
	var patterns: Array[String] = []
	for pattern in raw.split(",", false):
		var trimmed := String(pattern).strip_edges()
		if trimmed != "":
			patterns.append(trimmed)
	return patterns


func _path_matches_any_pattern(path: String, patterns: Array[String]) -> bool:
	for pattern in patterns:
		if path.match(pattern):
			return true
	return false
