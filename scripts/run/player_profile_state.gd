extends RefCounted
class_name PlayerProfileState

const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")
const CURRENT_SCHEMA_VERSION := 1
const DEFAULT_PROFILE_ID := "default"
const DEFAULT_PROFILE_NAME := "Default Profile"

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


func load_from_config(config: ConfigFile, section: String) -> void:
	profile_id = String(config.get_value(section, "profile_id", DEFAULT_PROFILE_ID)).strip_edges()
	if profile_id == "":
		profile_id = DEFAULT_PROFILE_ID
	display_name = String(config.get_value(section, "display_name", DEFAULT_PROFILE_NAME)).strip_edges()
	if display_name == "":
		display_name = DEFAULT_PROFILE_NAME
	schema_version = maxi(1, int(config.get_value(section, "schema_version", CURRENT_SCHEMA_VERSION)))
	created_unix = maxi(0, int(config.get_value(section, "created_unix", 0)))
	updated_unix = maxi(created_unix, int(config.get_value(section, "updated_unix", created_unix)))
	meta_profile = META_PROFILE_STATE_SCRIPT.new()
	meta_profile.load_from_config(config, section)


func save_to_config(config: ConfigFile, section: String) -> void:
	mark_updated()
	config.set_value(section, "profile_id", profile_id)
	config.set_value(section, "display_name", display_name)
	config.set_value(section, "schema_version", schema_version)
	config.set_value(section, "created_unix", created_unix)
	config.set_value(section, "updated_unix", updated_unix)
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
