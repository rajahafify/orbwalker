extends RefCounted
class_name RunSummaryViewTest

const RUN_SUMMARY_VIEW_SCRIPT := preload("res://scripts/run_summary/run_summary_view.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("run_summary_fonts_keep_readable_floors", _test_run_summary_fonts_keep_readable_floors, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
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


func _test_run_summary_fonts_keep_readable_floors() -> String:
	var fixture := _fixture()
	var view: Variant = fixture["view"]
	var host: Control = fixture["host"]
	var title_label: Label = fixture["title_label"]
	var summary_label: Label = fixture["summary_label"]
	var new_run_button: Button = fixture["new_run_button"]
	var main_menu_button: Button = fixture["main_menu_button"]
	view.apply_static_layout(host)
	var stats_rows: Array[Dictionary] = [{"label": "Gold Earned", "value": "123", "accent": "gold"}]
	var equipment_lines: Array[String] = ["Shortsword"]
	var relic_lines: Array[String] = ["Spark Gem"]
	view.render_summary("Victory", "Level 3 cleared", true, stats_rows, equipment_lines, relic_lines)
	var probe: Dictionary = RUN_SUMMARY_VIEW_SCRIPT.readability_font_probe()
	if title_label.get_theme_font_size("font_size") < int(probe.get("title", 0)):
		host.free()
		return "Expected run-summary title font to match the readable floor."
	if summary_label.get_theme_font_size("font_size") < int(probe.get("summary", 0)):
		host.free()
		return "Expected run-summary subtitle font to match the readable floor."
	if new_run_button.get_theme_font_size("font_size") < int(probe.get("action_button", 0)):
		host.free()
		return "Expected New Run button font to match the readable floor."
	if main_menu_button.get_theme_font_size("font_size") < int(probe.get("action_button", 0)):
		host.free()
		return "Expected Main Menu button font to match the readable floor."
	var stats_grid := _find_child_by_name(fixture["content_box"] as Node, "SummaryStats") as GridContainer
	if stats_grid == null or stats_grid.get_child_count() == 0:
		host.free()
		return "Expected run-summary stats grid to render."
	var stat_box := (stats_grid.get_child(0) as PanelContainer).get_child(0) as VBoxContainer
	var stat_label := stat_box.get_child(0) as Label
	var stat_value := stat_box.get_child(1) as Label
	if stat_label.get_theme_font_size("font_size") < int(probe.get("stat_label", 0)):
		host.free()
		return "Expected run-summary stat label font to match the readable floor."
	if stat_value.get_theme_font_size("font_size") < int(probe.get("stat_value", 0)):
		host.free()
		return "Expected run-summary stat value font to match the readable floor."
	host.free()
	return ""


func _fixture() -> Dictionary:
	var host := Control.new()
	host.name = "RunSummaryViewTestHost"
	var summary_label := Label.new()
	var title_label := Label.new()
	var center_container := CenterContainer.new()
	var panel_container := PanelContainer.new()
	var content_box := VBoxContainer.new()
	var action_staging := HBoxContainer.new()
	var new_run_button := Button.new()
	var main_menu_button := Button.new()
	center_container.add_child(panel_container)
	panel_container.add_child(content_box)
	content_box.add_child(action_staging)
	action_staging.add_child(new_run_button)
	action_staging.add_child(main_menu_button)
	host.add_child(center_container)
	var view: Variant = RUN_SUMMARY_VIEW_SCRIPT.new()
	(
		view
		. bind(
			{
				"summary_label": summary_label,
				"title_label": title_label,
				"center_container": center_container,
				"panel_container": panel_container,
				"content_box": content_box,
				"new_run_button": new_run_button,
				"main_menu_button": main_menu_button,
			}
		)
	)
	return {
		"view": view,
		"host": host,
		"summary_label": summary_label,
		"title_label": title_label,
		"content_box": content_box,
		"new_run_button": new_run_button,
		"main_menu_button": main_menu_button,
	}


func _find_child_by_name(root: Node, target_name: String) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found := _find_child_by_name(child, target_name)
		if found != null:
			return found
	return null
