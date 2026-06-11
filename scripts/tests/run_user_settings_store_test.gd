extends RefCounted
class_name RunUserSettingsStoreTest

const STORE_SCRIPT := preload("res://scripts/core/run_user_settings_store.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")
const TEST_SETTINGS_PATH := "user://run_user_settings_store_test.cfg"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("settings_round_trip_normalizes_values", _test_settings_round_trip_normalizes_values, failures)
	_run_case("invalid_game_juice_flag_is_ignored", _test_invalid_game_juice_flag_is_ignored, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_settings_round_trip_normalizes_values() -> String:
	_cleanup_test_settings()
	var saved = STORE_SCRIPT.new()
	saved.settings_path = TEST_SETTINGS_PATH
	saved.set_generate_run_log_files(true)
	saved.set_vfx_speed(" FAST ")
	saved.set_combat_vfx_quality("HIGH")
	saved.set_reduced_motion_enabled(true)
	saved.set_game_juice_enabled(false)
	saved.set_game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SCREEN_NUDGE, false)

	var loaded = STORE_SCRIPT.new()
	loaded.settings_path = TEST_SETTINGS_PATH
	loaded.load()
	_cleanup_test_settings()
	if not loaded.generate_run_log_files:
		return "Expected run-log generation setting to round-trip."
	if loaded.vfx_speed != STORE_SCRIPT.VFX_SPEED_FAST:
		return "Expected vfx speed to normalize to fast."
	if loaded.combat_vfx_quality != STORE_SCRIPT.COMBAT_VFX_QUALITY_HIGH:
		return "Expected combat VFX quality to normalize to high."
	if not loaded.reduced_motion:
		return "Expected reduced motion to round-trip."
	if loaded.game_juice_enabled:
		return "Expected game juice master toggle to round-trip false."
	if loaded.game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SCREEN_NUDGE):
		return "Expected disabled screen nudge flag to round-trip."
	return ""


func _test_invalid_game_juice_flag_is_ignored() -> String:
	var store = STORE_SCRIPT.new()
	var before: Dictionary = store.game_juice_flags.duplicate(true)
	store.set_game_juice_flag_enabled("not_a_real_flag", false)
	if store.game_juice_flags != before:
		return "Expected unknown game juice flag writes to be ignored."
	return ""


func _cleanup_test_settings() -> void:
	if FileAccess.file_exists(TEST_SETTINGS_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS_PATH))
