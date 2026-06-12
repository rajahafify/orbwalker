extends RefCounted
class_name MainMenuTextCatalog

const SETTINGS_OVERLAY_SCRIPT := preload("res://scripts/main_menu/main_menu_settings_overlay.gd")

const TEXT_KEYS := {
	"start_run": "MAIN_MENU_START_RUN",
	"generate_log": "MAIN_MENU_GENERATE_LOG",
	"continue": "MAIN_MENU_CONTINUE",
	"collection": "MAIN_MENU_COLLECTION",
	"tutorial": "MAIN_MENU_TUTORIAL",
	"settings": "MAIN_MENU_SETTINGS",
	"quit": "MAIN_MENU_QUIT",
	"profile": "MAIN_MENU_PROFILE",
	"achievements": "MAIN_MENU_ACHIEVEMENTS",
	"version": "MAIN_MENU_DEMO_VERSION",
	"runtime_status": "MAIN_MENU_RUNTIME_STATUS",
	"profile_title": "MAIN_MENU_PROFILE",
	"profile_default": "MAIN_MENU_DEFAULT_PROFILE",
	"profile_score_zero": "MAIN_MENU_PROFILE_SCORE_ZERO",
	"reset_profile": "MAIN_MENU_RESET_PROFILE",
	"close": "MAIN_MENU_CLOSE",
}
const ELEMENT_LABEL_KEYS := [
	"MAIN_MENU_ELEMENT_FIRE",
	"MAIN_MENU_ELEMENT_ICE",
	"MAIN_MENU_ELEMENT_EARTH",
	"MAIN_MENU_ELEMENT_HEART",
	"MAIN_MENU_ELEMENT_ARMOR",
	"MAIN_MENU_ELEMENT_GOLD",
]
const STAT_TITLE_KEYS := [
	"MAIN_MENU_RELICS_UNLOCKED",
	"MAIN_MENU_MASTERY_PROGRESS",
	"MAIN_MENU_BEST_RUN",
]
const STAT_VALUE_KEYS := [
	"MAIN_MENU_STAT_RELICS_VALUE",
	"MAIN_MENU_STAT_MASTERY_VALUE",
	"MAIN_MENU_STAT_BEST_RUN_VALUE",
]


static func text(key_name: String) -> String:
	return TranslationServer.translate(String(TEXT_KEYS.get(key_name, key_name)))


static func localization_keys() -> Array[String]:
	var keys: Array[String] = []
	for value in TEXT_KEYS.values():
		keys.append(String(value))
	for value in ELEMENT_LABEL_KEYS:
		keys.append(String(value))
	for value in STAT_TITLE_KEYS:
		keys.append(String(value))
	for value in STAT_VALUE_KEYS:
		keys.append(String(value))
	keys.append_array(SETTINGS_OVERLAY_SCRIPT.localization_keys())
	keys.sort()
	return keys
