extends RefCounted
class_name MainMenuModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("profile_name_defaults_and_trims", _test_profile_name_defaults_and_trims, failures)
	_run_case("score_text_uses_supported_score_keys_and_clamps", _test_score_text_uses_supported_score_keys_and_clamps, failures)
	_run_case("snapshot_is_deep_copy", _test_snapshot_is_deep_copy, failures)
	_run_case("menu_texture_paths_expose_expected_groups", _test_menu_texture_paths_expose_expected_groups, failures)

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


func _test_profile_name_defaults_and_trims() -> String:
	var model := MainMenuModel.new()
	if model.profile_name() != "Default Profile":
		return "Expected default profile name before refresh."
	model.refresh_profile_snapshot({"display_name": "  Ada  "})
	if model.profile_name() != "Ada":
		return "Expected display_name to trim whitespace."
	model.refresh_profile_snapshot({"display_name": "   ", "profile_name": "Fallback"})
	if model.profile_name() != "Default Profile":
		return "Expected blank display_name to use default profile name."
	model.refresh_profile_snapshot({"profile_name": "Runner"})
	if model.profile_name() != "Runner":
		return "Expected profile_name fallback when display_name is missing."
	return ""


func _test_score_text_uses_supported_score_keys_and_clamps() -> String:
	var model := MainMenuModel.new()
	model.refresh_profile_snapshot({"total_score": 12, "score": 99})
	if model.profile_score_text() != "Total Score: 12":
		return "Expected total_score to have priority."
	model.refresh_profile_snapshot({"score": 8})
	if model.profile_score_text() != "Total Score: 8":
		return "Expected score to be used."
	model.refresh_profile_snapshot({"meta_score": 7})
	if model.profile_score_text() != "Total Score: 7":
		return "Expected meta_score to be used."
	model.refresh_profile_snapshot({"stats": {"total_score": 6}})
	if model.profile_score_text() != "Total Score: 6":
		return "Expected stats.total_score to be used."
	model.refresh_profile_snapshot({"total_score": -20})
	if model.profile_score_text() != "Total Score: 0":
		return "Expected negative score to clamp to zero."
	return ""


func _test_snapshot_is_deep_copy() -> String:
	var model := MainMenuModel.new()
	model.refresh_profile_snapshot({"display_name": "Ada", "stats": {"total_score": 5}})
	var snapshot := model.model_snapshot()
	Dictionary(snapshot["profile_snapshot"])["display_name"] = "Changed"
	if model.profile_name() != "Ada":
		return "Expected mutating snapshot copy not to alter model state."
	if int(snapshot.get("profile_total_score", -1)) != 5:
		return "Expected snapshot to include extracted score."
	return ""


func _test_menu_texture_paths_expose_expected_groups() -> String:
	var model := MainMenuModel.new()
	model.load_menu_assets()
	var paths := model.menu_texture_paths()
	for key in ["background", "logo", "outer_border", "button_primary", "button_secondary", "stats_panel"]:
		if String(paths.get(key, "")) == "":
			return "Expected menu texture key '%s' to resolve." % key
	if Array(paths.get("element_icons", [])).size() != MainMenuModel.ELEMENT_KEYS.size():
		return "Expected one element icon path per element key."
	if Array(paths.get("stat_icons", [])).size() != MainMenuModel.STAT_MENU_ICON_KEYS.size():
		return "Expected one stat icon path per stat key."
	if Array(paths.get("footer_icons", [])).size() != MainMenuModel.FOOTER_MENU_ICON_KEYS.size():
		return "Expected one footer icon path per footer key."
	return ""
