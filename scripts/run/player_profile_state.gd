extends RefCounted
class_name PlayerProfileState

const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")
const CURRENT_SCHEMA_VERSION := 1
const LEGACY_SCHEMA_VERSION := 0
const DEFAULT_PROFILE_ID := "default"
const DEFAULT_PROFILE_NAME := "Default Profile"
const PROFILE_ID_KEY := "profile_id"
const DISPLAY_NAME_KEY := "display_name"
const LEGACY_PROFILE_NAME_KEY := "profile_name"
const SCHEMA_VERSION_KEY := "schema_version"
const CREATED_UNIX_KEY := "created_unix"
const UPDATED_UNIX_KEY := "updated_unix"

var profile_id: String = DEFAULT_PROFILE_ID
var display_name: String = DEFAULT_PROFILE_NAME
var schema_version: int = CURRENT_SCHEMA_VERSION
var created_unix: int = 0
var updated_unix: int = 0
var meta_profile: MetaProfileState = META_PROFILE_STATE_SCRIPT.new()


func reset_to_default(now_unix: int = 0) -> void:
	var timestamp := _resolved_timestamp(now_unix)
	profile_id = DEFAULT_PROFILE_ID
	display_name = DEFAULT_PROFILE_NAME
	schema_version = CURRENT_SCHEMA_VERSION
	created_unix = timestamp
	updated_unix = timestamp
	meta_profile = META_PROFILE_STATE_SCRIPT.new()


func load_from_config(config: ConfigFile, section: String, apply_migrations: bool = true) -> void:
	if apply_migrations:
		migrate_config_to_current(config, section)
	profile_id = String(config.get_value(section, PROFILE_ID_KEY, DEFAULT_PROFILE_ID)).strip_edges()
	if profile_id == "":
		profile_id = DEFAULT_PROFILE_ID
	display_name = String(config.get_value(section, DISPLAY_NAME_KEY, DEFAULT_PROFILE_NAME)).strip_edges()
	if display_name == "":
		display_name = DEFAULT_PROFILE_NAME
	schema_version = mini(CURRENT_SCHEMA_VERSION, maxi(1, int(config.get_value(section, SCHEMA_VERSION_KEY, CURRENT_SCHEMA_VERSION))))
	created_unix = maxi(0, int(config.get_value(section, CREATED_UNIX_KEY, 0)))
	updated_unix = maxi(created_unix, int(config.get_value(section, UPDATED_UNIX_KEY, created_unix)))
	meta_profile = META_PROFILE_STATE_SCRIPT.new()
	meta_profile.load_from_config(config, section)


func save_to_config(config: ConfigFile, section: String) -> void:
	schema_version = CURRENT_SCHEMA_VERSION
	mark_updated()
	config.set_value(section, PROFILE_ID_KEY, profile_id)
	config.set_value(section, DISPLAY_NAME_KEY, display_name)
	config.set_value(section, SCHEMA_VERSION_KEY, schema_version)
	config.set_value(section, CREATED_UNIX_KEY, created_unix)
	config.set_value(section, UPDATED_UNIX_KEY, updated_unix)
	meta_profile.save_to_config(config, section)


func to_snapshot() -> Dictionary:
	var meta_data: Dictionary = meta_snapshot()
	var snapshot: Dictionary = {
		"profile_id": profile_id,
		"display_name": display_name,
		"schema_version": schema_version,
		"created_unix": created_unix,
		"updated_unix": updated_unix,
		"meta_profile": meta_data.duplicate(true),
	}
	for key in meta_data.keys():
		snapshot[key] = meta_data[key]
	return snapshot


func meta_snapshot() -> Dictionary:
	return meta_profile.to_snapshot()


static func migrate_config_to_current(config: ConfigFile, section: String) -> Dictionary:
	var from_version := _config_schema_version(config, section)
	var steps: Array[String] = []
	if from_version > CURRENT_SCHEMA_VERSION:
		return {
			"ok": false,
			"reason": "unsupported_schema_version",
			"from_schema_version": from_version,
			"to_schema_version": CURRENT_SCHEMA_VERSION,
			"migrated": false,
			"steps": steps,
		}

	if from_version <= LEGACY_SCHEMA_VERSION:
		_migrate_legacy_profile_identity(config, section, steps)
		_migrate_legacy_timestamps(config, section, steps)

	var meta_migration: Dictionary = META_PROFILE_STATE_SCRIPT.migrate_config_to_current(config, section)
	for step_value in Array(meta_migration.get("steps", [])):
		steps.append("meta_%s" % String(step_value))

	if from_version != CURRENT_SCHEMA_VERSION:
		config.set_value(section, SCHEMA_VERSION_KEY, CURRENT_SCHEMA_VERSION)
		steps.append("schema_version_to_current")

	return {
		"ok": true,
		"reason": "",
		"from_schema_version": from_version,
		"to_schema_version": CURRENT_SCHEMA_VERSION,
		"migrated": not steps.is_empty(),
		"steps": steps,
	}


func reset_meta_progress(now_unix: int = 0) -> void:
	var timestamp := _resolved_timestamp(now_unix)
	meta_profile = META_PROFILE_STATE_SCRIPT.new()
	updated_unix = timestamp
	if created_unix <= 0:
		created_unix = timestamp


func mark_updated(now_unix: int = 0) -> void:
	var timestamp := _resolved_timestamp(now_unix)
	if created_unix <= 0:
		created_unix = timestamp
	updated_unix = timestamp


func _resolved_timestamp(now_unix: int) -> int:
	if now_unix > 0:
		return now_unix
	return int(Time.get_unix_time_from_system())


static func _config_schema_version(config: ConfigFile, section: String) -> int:
	if not _has_config_value(config, section, SCHEMA_VERSION_KEY):
		return LEGACY_SCHEMA_VERSION
	return maxi(LEGACY_SCHEMA_VERSION, int(config.get_value(section, SCHEMA_VERSION_KEY, LEGACY_SCHEMA_VERSION)))


static func _migrate_legacy_profile_identity(config: ConfigFile, section: String, steps: Array[String]) -> void:
	var profile_id_value := String(config.get_value(section, PROFILE_ID_KEY, DEFAULT_PROFILE_ID)).strip_edges()
	if profile_id_value == "":
		profile_id_value = DEFAULT_PROFILE_ID
	if profile_id_value != String(config.get_value(section, PROFILE_ID_KEY, "")).strip_edges():
		steps.append("profile_id_defaulted")
	config.set_value(section, PROFILE_ID_KEY, profile_id_value)

	var display_name_value := String(config.get_value(section, DISPLAY_NAME_KEY, "")).strip_edges()
	if display_name_value == "":
		display_name_value = String(config.get_value(section, LEGACY_PROFILE_NAME_KEY, "")).strip_edges()
		if display_name_value != "":
			steps.append("profile_name_to_display_name")
	if display_name_value == "":
		display_name_value = DEFAULT_PROFILE_NAME
		steps.append("display_name_defaulted")
	if display_name_value != String(config.get_value(section, DISPLAY_NAME_KEY, "")).strip_edges():
		config.set_value(section, DISPLAY_NAME_KEY, display_name_value)


static func _migrate_legacy_timestamps(config: ConfigFile, section: String, steps: Array[String]) -> void:
	var stored_created_unix := maxi(0, int(config.get_value(section, CREATED_UNIX_KEY, 0)))
	var stored_updated_unix := maxi(stored_created_unix, int(config.get_value(section, UPDATED_UNIX_KEY, stored_created_unix)))
	var changed := false
	if not _has_config_value(config, section, CREATED_UNIX_KEY):
		config.set_value(section, CREATED_UNIX_KEY, stored_created_unix)
		changed = true
	if not _has_config_value(config, section, UPDATED_UNIX_KEY):
		config.set_value(section, UPDATED_UNIX_KEY, stored_updated_unix)
		changed = true
	if changed:
		steps.append("timestamps_initialized")


static func _has_config_value(config: ConfigFile, section: String, key: String) -> bool:
	return config.has_section(section) and config.has_section_key(section, key)
