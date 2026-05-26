extends RefCounted
class_name MainMenuModel

const MENU_ASSET_MAP_PATH := "res://resources/visual/first_pass_asset_map.json"

const FALLBACK_BG_PATH := "res://resources/art/assetgen/main_menu/main_menu_background_candidate_01.png"
const FALLBACK_LOGO_PATH := "res://resources/art/assetgen/main_menu/game_title_logo_candidate_01_alpha.png"
const FALLBACK_OUTER_BORDER_PATH := "res://resources/art/assetgen/main_menu/main_menu_border_outer_candidate_05.png"
const FALLBACK_BUTTON_PRIMARY_PATH := "res://resources/art/assetgen/main_menu/main_menu_button_primary_candidate_05.png"
const FALLBACK_BUTTON_SECONDARY_PATH := "res://resources/art/assetgen/main_menu/main_menu_button_secondary_candidate_05.png"
const FALLBACK_STATS_PANEL_PATH := "res://resources/art/assetgen/main_menu/main_menu_stats_panel_candidate_05.png"

const ELEMENT_KEYS: Array[String] = ["fire", "ice", "earth", "heart", "armor", "gold"]
const ELEMENT_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/first_pass/derived/icons/mastery_fire.png",
	"res://resources/art/first_pass/derived/icons/mastery_ice.png",
	"res://resources/art/first_pass/derived/icons/mastery_earth.png",
	"res://resources/art/first_pass/derived/icons/mastery_heart.png",
	"res://resources/art/first_pass/derived/icons/mastery_armor.png",
	"res://resources/art/first_pass/derived/icons/mastery_gold.png",
]
const STAT_MENU_ICON_KEYS: Array[String] = ["relics_unlocked", "mastery_progress", "best_run"]
const STAT_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/assetgen/main_menu/main_menu_icon_relic_chest_candidate_05_semantic.png",
	"res://resources/art/assetgen/main_menu/main_menu_icon_mastery_progress_candidate_05_semantic.png",
	"res://resources/art/assetgen/main_menu/main_menu_icon_best_run_candidate_05_semantic.png",
]
const FOOTER_MENU_ICON_KEYS: Array[String] = ["profile", "achievements", "settings"]
const FOOTER_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/assetgen/main_menu/main_menu_icon_profile_candidate_05_semantic.png",
	"res://resources/art/assetgen/main_menu/main_menu_icon_achievements_candidate_05_semantic.png",
	"res://resources/art/assetgen/main_menu/main_menu_icon_settings_candidate_05_semantic.png",
]

var _asset_map: Dictionary = {}
var _menu_assets: Dictionary = {}
var _menu_icons: Dictionary = {}
var _profile_snapshot: Dictionary = {}
var _profile_name: String = "Default Profile"
var _profile_total_score: int = 0

func load_menu_assets() -> void:
	_asset_map = _load_asset_map()
	_menu_assets = Dictionary(_asset_map.get("menu", {}))
	_menu_icons = _resolve_menu_icons()


func menu_texture_paths() -> Dictionary:
	return {
		"background": _resolve_background_path(),
		"logo": _resolve_logo_path(),
		"outer_border": _resolve_menu_texture("outer_border", FALLBACK_OUTER_BORDER_PATH),
		"button_primary": _resolve_menu_texture("button_primary", FALLBACK_BUTTON_PRIMARY_PATH),
		"button_secondary": _resolve_menu_texture("button_secondary", FALLBACK_BUTTON_SECONDARY_PATH),
		"stats_panel": _resolve_menu_texture("stats_panel", FALLBACK_STATS_PANEL_PATH),
		"element_icons": _resolve_mastery_icon_paths(),
		"stat_icons": _resolve_menu_icon_paths(STAT_MENU_ICON_KEYS, STAT_ICON_FALLBACK_PATHS),
		"footer_icons": _resolve_menu_icon_paths(FOOTER_MENU_ICON_KEYS, FOOTER_ICON_FALLBACK_PATHS),
	}


func refresh_profile_snapshot(profile_data: Dictionary) -> void:
	_profile_snapshot = profile_data.duplicate(true)
	_profile_name = _extract_profile_name(_profile_snapshot)
	_profile_total_score = _extract_total_score(_profile_snapshot)


func profile_name() -> String:
	return _profile_name


func profile_score_text() -> String:
	return "Total Score: %d" % _profile_total_score


func model_snapshot() -> Dictionary:
	return {
		"profile_name": _profile_name,
		"profile_total_score": _profile_total_score,
		"profile_snapshot": _profile_snapshot.duplicate(true),
		"menu_assets_loaded": not _asset_map.is_empty(),
	}


func _load_asset_map() -> Dictionary:
	if not FileAccess.file_exists(MENU_ASSET_MAP_PATH):
		return {}
	var file := FileAccess.open(MENU_ASSET_MAP_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _resolve_background_path() -> String:
	var backgrounds: Dictionary = Dictionary(_asset_map.get("backgrounds", {}))
	if backgrounds.has("main_menu"):
		return String(backgrounds.get("main_menu", FALLBACK_BG_PATH))
	return _resolve_menu_texture("background", FALLBACK_BG_PATH)


func _resolve_logo_path() -> String:
	return _resolve_menu_texture("logo", FALLBACK_LOGO_PATH)


func _resolve_menu_texture(entry_key: String, fallback_path: String) -> String:
	if _menu_assets.has(entry_key):
		return String(_menu_assets.get(entry_key, fallback_path))
	return fallback_path


func _resolve_menu_icons() -> Dictionary:
	var icon_map: Dictionary = Dictionary(_menu_assets.get("menu_icons", {}))
	return icon_map.duplicate(true)


func _resolve_menu_icon_path(icon_key: String, fallback_path: String) -> String:
	if _menu_icons.has(icon_key):
		return String(_menu_icons.get(icon_key, fallback_path))
	return fallback_path


func _resolve_menu_icon_paths(keys: Array[String], fallback_paths: Array[String]) -> Array[String]:
	var resolved: Array[String] = []
	for i in keys.size():
		resolved.append(_resolve_menu_icon_path(keys[i], fallback_paths[i]))
	return resolved


func _resolve_mastery_icon_paths() -> Array[String]:
	var resolved_paths: Array[String] = []
	var mastery_icons: Dictionary = Dictionary(_menu_assets.get("reused_mastery_icons", {}))
	for i in ELEMENT_KEYS.size():
		var key := ELEMENT_KEYS[i]
		if mastery_icons.has(key):
			resolved_paths.append(String(mastery_icons.get(key, ELEMENT_ICON_FALLBACK_PATHS[i])))
		else:
			resolved_paths.append(ELEMENT_ICON_FALLBACK_PATHS[i])
	return resolved_paths


func _extract_profile_name(profile_data: Dictionary) -> String:
	var display_name := String(profile_data.get("display_name", profile_data.get("profile_name", "Default Profile"))).strip_edges()
	if display_name == "":
		return "Default Profile"
	return display_name


func _extract_total_score(profile_data: Dictionary) -> int:
	if profile_data.has("total_score"):
		return maxi(0, int(profile_data.get("total_score", 0)))
	if profile_data.has("score"):
		return maxi(0, int(profile_data.get("score", 0)))
	if profile_data.has("meta_score"):
		return maxi(0, int(profile_data.get("meta_score", 0)))
	var stats: Dictionary = Dictionary(profile_data.get("stats", {}))
	if stats.has("total_score"):
		return maxi(0, int(stats.get("total_score", 0)))
	return 0
