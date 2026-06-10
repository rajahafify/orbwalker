extends RefCounted
class_name ProfileMigrationTest

const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")
const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")

const FIXTURE_CASES := [
	{
		"path": "res://scripts/tests/fixtures/profile_saves/v0_profile_aliases.cfg",
		"section": "profile",
		"legacy_meta": false,
		"expect_migrated": true,
		"display_name": "Legacy Runner",
		"total_score": 42,
		"unlocked_equipment_ids": ["buckler", "coin_purse", "shortsword"],
		"recent_unlock_item_ids": ["healing_charm", "leather_gloves"],
	},
	{
		"path": "res://scripts/tests/fixtures/profile_saves/v1_current_profile.cfg",
		"section": "profile",
		"legacy_meta": false,
		"expect_migrated": false,
		"display_name": "Current Runner",
		"total_score": 99,
		"unlocked_equipment_ids": ["buckler", "shortsword"],
		"recent_unlock_item_ids": ["coin_purse"],
	},
	{
		"path": "res://scripts/tests/fixtures/profile_saves/legacy_meta_profile.cfg",
		"section": "meta_profile",
		"legacy_meta": true,
		"expect_migrated": true,
		"display_name": "Default Profile",
		"total_score": 23,
		"unlocked_equipment_ids": ["buckler", "shortsword"],
		"recent_unlock_item_ids": ["coin_purse"],
	},
]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("historical_profile_fixtures_migrate_to_current", _test_historical_profile_fixtures_migrate_to_current, failures)
	_run_case("future_profile_schema_is_rejected", _test_future_profile_schema_is_rejected, failures)
	_run_case("save_writes_current_schema", _test_save_writes_current_schema, failures)

	return {
		"passed": failures.is_empty(),
		"total": 3,
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


func _test_historical_profile_fixtures_migrate_to_current() -> String:
	for fixture in FIXTURE_CASES:
		var error := _assert_fixture_loads(Dictionary(fixture))
		if error != "":
			return error
	return ""


func _test_future_profile_schema_is_rejected() -> String:
	var config := ConfigFile.new()
	config.set_value("profile", "schema_version", PLAYER_PROFILE_STATE_SCRIPT.CURRENT_SCHEMA_VERSION + 1)
	var migration: Dictionary = PLAYER_PROFILE_STATE_SCRIPT.migrate_config_to_current(config, "profile")
	if bool(migration.get("ok", true)):
		return "Expected future schema versions to be rejected."
	if String(migration.get("reason", "")) != "unsupported_schema_version":
		return "Expected unsupported_schema_version, got %s." % String(migration.get("reason", ""))
	return ""


func _test_save_writes_current_schema() -> String:
	var profile = PLAYER_PROFILE_STATE_SCRIPT.new()
	profile.schema_version = 0
	profile.meta_profile.add_total_score(5)
	var config := ConfigFile.new()
	profile.save_to_config(config, "profile")
	if int(config.get_value("profile", "schema_version", 0)) != PLAYER_PROFILE_STATE_SCRIPT.CURRENT_SCHEMA_VERSION:
		return "Expected save_to_config to persist the current schema version."
	if int(config.get_value("profile", "total_score", 0)) != 5:
		return "Expected save_to_config to preserve meta profile data."
	return ""


func _assert_fixture_loads(fixture: Dictionary) -> String:
	var path := String(fixture.get("path", ""))
	var section := String(fixture.get("section", "profile"))
	var config := ConfigFile.new()
	var error_code := config.load(path)
	if error_code != OK:
		return "Expected fixture %s to load; error %d." % [path, error_code]

	var profile = PLAYER_PROFILE_STATE_SCRIPT.new()
	var migration: Dictionary = {}
	if bool(fixture.get("legacy_meta", false)):
		profile.reset_to_default(1000)
		migration = META_PROFILE_STATE_SCRIPT.migrate_config_to_current(config, section)
		profile.meta_profile.load_from_config(config, section)
	else:
		migration = PLAYER_PROFILE_STATE_SCRIPT.migrate_config_to_current(config, section)
		if not bool(migration.get("ok", false)):
			return "Expected fixture %s to migrate; got %s." % [path, String(migration.get("reason", ""))]
		profile.load_from_config(config, section, false)

	if bool(fixture.get("expect_migrated", false)) != bool(migration.get("migrated", false)):
		return "Expected fixture %s migrated=%s, got %s." % [
			path,
			str(fixture.get("expect_migrated", false)),
			str(migration.get("migrated", false)),
		]
	return _assert_profile_matches(profile, fixture, path)


func _assert_profile_matches(profile: Variant, fixture: Dictionary, path: String) -> String:
	var snapshot: Dictionary = profile.to_snapshot()
	if int(snapshot.get("schema_version", 0)) != PLAYER_PROFILE_STATE_SCRIPT.CURRENT_SCHEMA_VERSION:
		return "Expected %s to load at current schema version." % path
	if String(snapshot.get("display_name", "")) != String(fixture.get("display_name", "")):
		return "Expected %s display_name to be %s, got %s." % [
			path,
			String(fixture.get("display_name", "")),
			String(snapshot.get("display_name", "")),
		]
	var meta := Dictionary(snapshot.get("meta_profile", {}))
	if int(meta.get("total_score", -1)) != int(fixture.get("total_score", -1)):
		return "Expected %s total_score to be preserved." % path
	var loaded_ids := _sorted_string_array(Array(meta.get("unlocked_equipment_ids", [])))
	var expected_ids := _sorted_string_array(Array(fixture.get("unlocked_equipment_ids", [])))
	if loaded_ids != expected_ids:
		return "Expected %s unlocked ids %s, got %s." % [path, str(expected_ids), str(loaded_ids)]
	var loaded_recent_ids := _recent_unlock_item_ids(Array(meta.get("recent_equipment_unlocks", [])))
	var expected_recent_ids := _sorted_string_array(Array(fixture.get("recent_unlock_item_ids", [])))
	if loaded_recent_ids != expected_recent_ids:
		return "Expected %s recent unlock ids %s, got %s." % [path, str(expected_recent_ids), str(loaded_recent_ids)]
	return ""


func _sorted_string_array(values: Array) -> Array[String]:
	var out: Array[String] = []
	for value in values:
		var text := String(value).strip_edges()
		if text != "":
			out.append(text)
	out.sort()
	return out


func _recent_unlock_item_ids(unlocks: Array) -> Array[String]:
	var ids: Array[String] = []
	for raw_unlock in unlocks:
		var unlock := Dictionary(raw_unlock)
		var item_id := String(unlock.get("item_id", "")).strip_edges()
		if item_id != "":
			ids.append(item_id)
	ids.sort()
	return ids
