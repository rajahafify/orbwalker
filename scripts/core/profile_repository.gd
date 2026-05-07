extends RefCounted
class_name ProfileRepository

const PROFILE_PATH := "user://matchatro_profile.cfg"
const PROFILE_SECTION := "profile"
const META_PROFILE_PATH := "user://matchatro_meta_profile.cfg"
const META_PROFILE_SECTION := "meta_profile"

var _last_load_result: Dictionary = {}
var _last_save_result: Dictionary = {}


func load_profile(profile: PlayerProfileState) -> Dictionary:
	var result := {
		"ok": true,
		"source": "",
		"profile_path": PROFILE_PATH,
		"profile_load_error": OK,
		"legacy_path": META_PROFILE_PATH,
		"legacy_load_error": ERR_FILE_NOT_FOUND,
		"migration_saved": false,
		"load_unix": int(Time.get_unix_time_from_system()),
	}
	if profile == null:
		result["ok"] = false
		result["source"] = "invalid_profile"
		result["reason"] = "profile_null"
		_last_load_result = result.duplicate(true)
		return result

	var config := ConfigFile.new()
	var profile_load_error := config.load(PROFILE_PATH)
	result["profile_load_error"] = profile_load_error
	if profile_load_error == OK:
		profile.load_from_config(config, PROFILE_SECTION)
		result["source"] = "profile"
		_last_load_result = result.duplicate(true)
		return result

	var legacy_config := ConfigFile.new()
	var legacy_load_error := legacy_config.load(META_PROFILE_PATH)
	result["legacy_load_error"] = legacy_load_error
	if legacy_load_error == OK:
		profile.reset_to_default()
		profile.meta_profile.load_from_config(legacy_config, META_PROFILE_SECTION)
		profile.mark_updated()
		result["source"] = "legacy_meta_profile"
		var migration_save := save_profile(profile)
		result["migration_saved"] = bool(migration_save.get("ok", false))
		result["save_result"] = migration_save.duplicate(true)
		result["ok"] = result["migration_saved"]
		_last_load_result = result.duplicate(true)
		return result

	profile.reset_to_default()
	result["source"] = "default_profile"
	var default_save := save_profile(profile)
	result["save_result"] = default_save.duplicate(true)
	result["ok"] = bool(default_save.get("ok", false))
	_last_load_result = result.duplicate(true)
	return result


func save_profile(profile: PlayerProfileState) -> Dictionary:
	var result := {
		"ok": true,
		"path": PROFILE_PATH,
		"error_code": OK,
		"saved_unix": int(Time.get_unix_time_from_system()),
	}
	if profile == null:
		result["ok"] = false
		result["error_code"] = ERR_INVALID_PARAMETER
		result["reason"] = "profile_null"
		_last_save_result = result.duplicate(true)
		push_warning("Failed to save player profile at %s: profile is null" % PROFILE_PATH)
		return result

	var config := ConfigFile.new()
	profile.save_to_config(config, PROFILE_SECTION)
	var error_code := config.save(PROFILE_PATH)
	result["error_code"] = error_code
	if error_code != OK:
		result["ok"] = false
		push_warning("Failed to save player profile at %s: %d" % [PROFILE_PATH, error_code])
	_last_save_result = result.duplicate(true)
	return result


func last_io_snapshot() -> Dictionary:
	return {
		"last_load_result": _last_load_result.duplicate(true),
		"last_save_result": _last_save_result.duplicate(true),
	}
