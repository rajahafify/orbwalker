extends RefCounted
class_name AssetPipelineTest

const ASSET_INVENTORY_PATH := "res://assets.json"
const COLLECTION_VIEW_SCRIPT := preload("res://scripts/collection/collection_view.gd")
const MAIN_MENU_MODEL_SCRIPT := preload("res://scripts/main_menu/main_menu_model.gd")
const RUN_SUMMARY_VIEW_SCRIPT := preload("res://scripts/run_summary/run_summary_view.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const VISUAL_REGISTRY_DATA_SCRIPT := preload("res://scripts/ui/visual_registry_data.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("fallback_contract_textures_import", _test_fallback_contract_textures_import, failures)
	_run_case("first_pass_asset_map_paths_import", _test_first_pass_asset_map_paths_import, failures)
	_run_case("runtime_manifest_paths_import", _test_runtime_manifest_paths_import, failures)
	_run_case("visual_registry_lookup_tables_alias_data_script", _test_visual_registry_lookup_tables_alias_data_script, failures)
	_run_case("production_asset_inventory_schema_and_paths", _test_production_asset_inventory_schema_and_paths, failures)

	return {
		"passed": failures.is_empty(),
		"total": 5,
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


func _test_fallback_contract_textures_import() -> String:
	var contract_paths := _merge_contract_paths(
		[
			MAIN_MENU_MODEL_SCRIPT.asset_contract_paths(),
			VISUAL_REGISTRY_SCRIPT.asset_contract_paths(),
			{
				"imported_textures":
				[
					COLLECTION_VIEW_SCRIPT.BACKGROUND_PATH,
					RUN_SUMMARY_VIEW_SCRIPT.BACKGROUND_PATH,
				],
			},
		]
	)
	var json_error := _assert_files_exist(Array(contract_paths.get("json_files", [])), "JSON contract file")
	if json_error != "":
		return json_error
	var directory_error := _assert_directories_exist(Array(contract_paths.get("directories", [])))
	if directory_error != "":
		return directory_error
	var texture_error := _assert_imported_textures(Array(contract_paths.get("imported_textures", [])), "fallback contract texture")
	if texture_error != "":
		return texture_error
	var texture_groups := Dictionary(contract_paths.get("imported_texture_groups", {}))
	for group_name in texture_groups.keys():
		var group_error := _assert_any_imported_texture(Array(texture_groups.get(group_name, [])), String(group_name))
		if group_error != "":
			return group_error
	return ""


func _test_first_pass_asset_map_paths_import() -> String:
	var contract := MAIN_MENU_MODEL_SCRIPT.asset_contract_paths()
	var asset_map_path := String(Array(contract.get("json_files", []))[0])
	var parsed := _load_json_dictionary(asset_map_path)
	var parse_error := String(parsed.get("__error", ""))
	if parse_error != "":
		return parse_error
	var paths: Array[String] = []
	_collect_res_paths(parsed, paths)
	return _assert_imported_textures(_unique_paths(paths), "asset map texture")


func _test_runtime_manifest_paths_import() -> String:
	var contract := VISUAL_REGISTRY_SCRIPT.asset_contract_paths()
	var manifest_path := String(Array(contract.get("json_files", []))[0])
	var parsed := _load_json_dictionary(manifest_path)
	var parse_error := String(parsed.get("__error", ""))
	if parse_error != "":
		return parse_error
	var categories := Dictionary(parsed.get("categories", {}))
	if categories.is_empty():
		return "Expected runtime manifest to define non-empty categories."
	var texture_paths: Array[String] = []
	for category_name in categories.keys():
		var entries := Dictionary(categories.get(category_name, {}))
		if entries.is_empty():
			return "Expected runtime manifest category '%s' to have entries." % String(category_name)
		for entry_name in entries.keys():
			var entry := Dictionary(entries.get(entry_name, {}))
			var path := String(entry.get("path", ""))
			if not path.begins_with("res://"):
				return "Expected runtime manifest %s/%s to define a res:// path." % [String(category_name), String(entry_name)]
			texture_paths.append(path)
			var source := String(entry.get("source", ""))
			if source.begins_with("res://"):
				texture_paths.append(source)
			var size := Array(entry.get("size", []))
			if size.size() != 2 or int(size[0]) <= 0 or int(size[1]) <= 0:
				return "Expected runtime manifest %s/%s to define positive size metadata." % [String(category_name), String(entry_name)]
	return _assert_imported_textures(_unique_paths(texture_paths), "runtime manifest texture")


func _test_visual_registry_lookup_tables_alias_data_script() -> String:
	var alias_contract := VISUAL_REGISTRY_SCRIPT.lookup_table_alias_contract()
	if not bool(alias_contract.get("intent_index_by_type", false)):
		return "VisualRegistry intent indexes must alias VisualRegistryData, not duplicate them."
	if not bool(alias_contract.get("rarity_index", false)):
		return "VisualRegistry rarity indexes must alias VisualRegistryData, not duplicate them."
	if not bool(alias_contract.get("enemy_portrait_paths", false)):
		return "VisualRegistry enemy portrait paths must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("enemy_stage_background_paths", false)):
		return "VisualRegistry enemy stage background paths must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("enemy_sprite_paths", false)):
		return "VisualRegistry enemy sprite paths must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("derived_orb_filename_by_id", false)):
		return "VisualRegistry derived orb filenames must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("runtime_orb_key_by_id", false)):
		return "VisualRegistry runtime orb keys must alias VisualRegistryData, not duplicate them."
	if not bool(alias_contract.get("combat_stage_alias_by_enemy_id", false)):
		return "VisualRegistry combat stage aliases must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("runtime_enemy_alias_by_id", false)):
		return "VisualRegistry runtime enemy aliases must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("placeholder_runtime_enemy_keys", false)):
		return "VisualRegistry placeholder runtime enemy keys must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("combat_stage_sheet_index_by_enemy_id", false)):
		return "VisualRegistry combat stage sheet indexes must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("enemy_visual_profiles", false)):
		return "VisualRegistry enemy visual profiles must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("icon_index_by_key", false)):
		return "VisualRegistry icon indexes must alias VisualRegistryData, not duplicate them."
	if not bool(alias_contract.get("relic_index_by_key", false)):
		return "VisualRegistry relic indexes must alias VisualRegistryData, not duplicate them."
	if not bool(alias_contract.get("mastery_orb_by_icon_key", false)):
		return "VisualRegistry mastery icon orb lookup must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("mastery_beam_by_orb_id", false)):
		return "VisualRegistry mastery beam lookup must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("mastery_card_by_orb_id", false)):
		return "VisualRegistry mastery card lookup must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("mastery_icon_by_orb_id", false)):
		return "VisualRegistry mastery icon lookup must alias VisualRegistryData, not duplicate it."
	if not bool(alias_contract.get("stable_placeholder_icon_colors", false)):
		return "VisualRegistry stable placeholder icon colors must alias VisualRegistryData, not duplicate them."
	var orb_paths := VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_contract_paths()
	if orb_paths.size() != VISUAL_REGISTRY_DATA_SCRIPT.derived_orb_filename_count():
		return "Derived orb contract paths must cover every entry in DERIVED_ORB_FILENAME_BY_ID."
	var contract_textures := _unique_paths(Array(VISUAL_REGISTRY_DATA_SCRIPT.asset_contract_paths().get("imported_textures", [])))
	for orb_path in orb_paths:
		if not contract_textures.has(orb_path):
			return "Derived orb contract path %s missing from imported_textures contract." % orb_path
	return ""


func _test_production_asset_inventory_schema_and_paths() -> String:
	var parsed := _load_json_dictionary(ASSET_INVENTORY_PATH)
	var parse_error := String(parsed.get("__error", ""))
	if parse_error != "":
		return parse_error
	if int(parsed.get("schema_version", 0)) <= 0:
		return "Expected assets.json to define a positive schema_version."
	var groups := Array(parsed.get("asset_groups", []))
	if groups.is_empty():
		return "Expected assets.json to define asset_groups."
	for group_value in groups:
		if not (group_value is Dictionary):
			return "Expected every asset group to be a Dictionary."
		var group := Dictionary(group_value)
		for key in ["id", "display_name", "priority", "production_status"]:
			if String(group.get(key, "")).strip_edges() == "":
				return "Expected asset group to define '%s'." % key
		var entries := Array(group.get("needed_for_production", []))
		if entries.is_empty():
			return "Expected asset group '%s' to define needed_for_production entries." % String(group.get("id", ""))
		for entry_value in entries:
			if not (entry_value is Dictionary):
				return "Expected asset entry in group '%s' to be a Dictionary." % String(group.get("id", ""))
			var entry := Dictionary(entry_value)
			for key in ["asset_id", "name", "status"]:
				if String(entry.get(key, "")).strip_edges() == "":
					return "Expected asset entry in group '%s' to define '%s'." % [String(group.get("id", "")), key]
			if entry.has("current_paths") and not (entry.get("current_paths") is Array):
				return "Expected current_paths for '%s' to be an Array." % String(entry.get("asset_id", ""))
			if entry.has("current_path") and not (entry.get("current_path") is String):
				return "Expected current_path for '%s' to be a String." % String(entry.get("asset_id", ""))
	var paths: Array[String] = []
	_collect_res_paths(parsed, paths)
	return _assert_files_or_directories_exist(_unique_paths(paths), "assets.json res:// reference")


func _merge_contract_paths(contracts: Array) -> Dictionary:
	var merged_imported_textures: Array[String] = []
	var merged_json_files: Array[String] = []
	var merged_directories: Array[String] = []
	var merged_groups := {}
	for contract_value in contracts:
		var contract := Dictionary(contract_value)
		for path in Array(contract.get("imported_textures", [])):
			merged_imported_textures.append(String(path))
		for path in Array(contract.get("json_files", [])):
			merged_json_files.append(String(path))
		for path in Array(contract.get("directories", [])):
			merged_directories.append(String(path))
		var groups := Dictionary(contract.get("imported_texture_groups", {}))
		for group_name in groups.keys():
			merged_groups[String(group_name)] = Array(groups[group_name])
	return {
		"imported_textures": _unique_paths(merged_imported_textures),
		"json_files": _unique_paths(merged_json_files),
		"directories": _unique_paths(merged_directories),
		"imported_texture_groups": merged_groups,
	}


func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"__error": "Expected JSON file to exist: %s." % path}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"__error": "Expected JSON file to open: %s." % path}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"__error": "Expected JSON file to parse as a Dictionary: %s." % path}
	return parsed


func _collect_res_paths(value: Variant, paths: Array[String]) -> void:
	if value is Dictionary:
		for key in Dictionary(value).keys():
			_collect_res_paths(Dictionary(value)[key], paths)
	elif value is Array:
		for item in Array(value):
			_collect_res_paths(item, paths)
	elif value is String:
		var path := String(value).strip_edges()
		if path.begins_with("res://"):
			paths.append(path)


func _assert_imported_textures(paths: Array, label: String) -> String:
	var missing: Array[String] = []
	var unloadable: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		if path == "":
			continue
		if not ResourceLoader.exists(path):
			missing.append(path)
			continue
		var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if not (loaded is Texture2D):
			unloadable.append("%s (%s)" % [path, loaded.get_class() if loaded != null else "<null>"])
	if not missing.is_empty():
		return "Expected %s imports to exist; missing %s." % [label, _format_path_list(missing)]
	if not unloadable.is_empty():
		return "Expected %s imports to load as Texture2D; got %s." % [label, _format_path_list(unloadable)]
	return ""


func _assert_any_imported_texture(paths: Array, label: String) -> String:
	var missing: Array[String] = []
	var unloadable: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		if path == "":
			continue
		if not ResourceLoader.exists(path):
			missing.append(path)
			continue
		var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded is Texture2D:
			return ""
		unloadable.append("%s (%s)" % [path, loaded.get_class() if loaded != null else "<null>"])
	return (
		"Expected at least one imported texture for %s; missing %s, unloadable %s."
		% [
			label,
			_format_path_list(missing),
			_format_path_list(unloadable),
		]
	)


func _assert_files_exist(paths: Array, label: String) -> String:
	var missing: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		if path == "":
			continue
		if not FileAccess.file_exists(path):
			missing.append(path)
	if not missing.is_empty():
		return "Expected %s to exist; missing %s." % [label, _format_path_list(missing)]
	return ""


func _assert_directories_exist(paths: Array) -> String:
	var missing: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		if path == "":
			continue
		if DirAccess.open(path) == null:
			missing.append(path)
	if not missing.is_empty():
		return "Expected asset directories to exist; missing %s." % _format_path_list(missing)
	return ""


func _assert_files_or_directories_exist(paths: Array, label: String) -> String:
	var missing: Array[String] = []
	for path_value in paths:
		var path := String(path_value)
		if path == "":
			continue
		if not _file_resource_or_directory_exists(path):
			missing.append(path)
	if not missing.is_empty():
		return "Expected %s to exist; missing %s." % [label, _format_path_list(missing)]
	return ""


func _file_resource_or_directory_exists(path: String) -> bool:
	return ResourceLoader.exists(path) or FileAccess.file_exists(path) or DirAccess.open(path) != null


func _unique_paths(paths: Array) -> Array[String]:
	var seen := {}
	var unique_paths: Array[String] = []
	for path_value in paths:
		var path := String(path_value).strip_edges()
		if path == "" or seen.has(path):
			continue
		seen[path] = true
		unique_paths.append(path)
	unique_paths.sort()
	return unique_paths


func _format_path_list(paths: Array[String], limit: int = 8) -> String:
	var visible: Array[String] = []
	for index in mini(paths.size(), limit):
		visible.append(paths[index])
	if paths.size() > limit:
		visible.append("... +%d more" % (paths.size() - limit))
	return ", ".join(visible)
