extends RefCounted
class_name CombatChromeStylerTest

const STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const THEME_HELPERS := preload("res://scripts/combat/combat_chrome_theme_helpers.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("nodes_from_root_nodes_preserves_chrome_contract", _test_nodes_from_root_nodes_preserves_chrome_contract, failures)
	_run_case("nodes_from_root_nodes_overlays_runtime_extras", _test_nodes_from_root_nodes_overlays_runtime_extras, failures)
	_run_case("theme_helpers_apply_progressbar_flat_style", _test_theme_helpers_apply_progressbar_flat_style, failures)
	_run_case("theme_helpers_apply_board_focus_theme", _test_theme_helpers_apply_board_focus_theme, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_nodes_from_root_nodes_preserves_chrome_contract() -> String:
	var root := Control.new()
	var root_nodes := {"_board_view": root}
	for root_key in STYLER_SCRIPT.CHROME_NODE_BINDINGS.values():
		var key := String(root_key)
		if key == "_board_view":
			continue
		var node := Control.new()
		node.name = key.trim_prefix("_")
		root.add_child(node)
		root_nodes[key] = node
	var nodes: Dictionary = STYLER_SCRIPT.nodes_from_root_nodes(root_nodes)
	for chrome_key in STYLER_SCRIPT.CHROME_NODE_BINDINGS.keys():
		if not nodes.has(chrome_key):
			root.free()
			return "Expected chrome node key: %s." % chrome_key
		var expected_key := String(STYLER_SCRIPT.CHROME_NODE_BINDINGS[chrome_key])
		if nodes.get(chrome_key) != root_nodes.get(expected_key):
			root.free()
			return "Expected %s to resolve from %s." % [chrome_key, expected_key]
	root.free()
	return ""


func _test_nodes_from_root_nodes_overlays_runtime_extras() -> String:
	var root_node := Control.new()
	var root_nodes := {"_top_bar": root_node}
	var runtime_node := Control.new()
	var debug_console := RefCounted.new()
	var player_hud_nodes := {"section": Control.new()}
	var visual_registry := RefCounted.new()
	var nodes: Dictionary = (
		STYLER_SCRIPT
		. nodes_from_root_nodes(
			root_nodes,
			{
				"top_bar": runtime_node,
				"debug_console": debug_console,
				"player_hud_nodes": player_hud_nodes,
				"visual_registry": visual_registry,
			}
		)
	)
	if nodes.get("top_bar") != runtime_node:
		root_node.free()
		runtime_node.free()
		player_hud_nodes.get("section").free()
		return "Expected extras to override mapped root nodes when needed."
	if nodes.get("debug_console") != debug_console or nodes.get("visual_registry") != visual_registry:
		root_node.free()
		runtime_node.free()
		player_hud_nodes.get("section").free()
		return "Expected runtime extras to be carried through."
	if nodes.get("player_hud_nodes") != player_hud_nodes:
		root_node.free()
		runtime_node.free()
		player_hud_nodes.get("section").free()
		return "Expected player HUD node contract to be carried through."
	root_node.free()
	runtime_node.free()
	player_hud_nodes.get("section").free()
	return ""


func _test_theme_helpers_apply_progressbar_flat_style() -> String:
	var bar := ProgressBar.new()
	THEME_HELPERS.apply_progressbar_flat_style(bar, Color(0.25, 0.5, 0.75, 1.0))
	var background := bar.get_theme_stylebox("background") as StyleBoxFlat
	var fill := bar.get_theme_stylebox("fill") as StyleBoxFlat
	if background == null or fill == null:
		bar.free()
		return "Expected flat progressbar helper to install background and fill styleboxes."
	if background.border_color != Color(0.54, 0.42, 0.20, 0.82):
		bar.free()
		return "Expected progressbar background border color to match combat chrome."
	if fill.bg_color != Color(0.25, 0.5, 0.75, 1.0):
		bar.free()
		return "Expected progressbar fill color to use the supplied value."
	bar.free()
	return ""


func _test_theme_helpers_apply_board_focus_theme() -> String:
	var panel := Panel.new()
	var title := Label.new()
	THEME_HELPERS.apply_board_focus_theme(null, panel, title, null, null)
	var panel_style := panel.get_theme_stylebox("panel") as StyleBoxFlat
	if panel_style == null:
		panel.free()
		title.free()
		return "Expected board focus helper to style the outcome panel."
	if panel_style.content_margin_left != 40.0:
		panel.free()
		title.free()
		return "Expected outcome summary panel margins to be preserved."
	if title.get_theme_font_size("font_size") != 58:
		panel.free()
		title.free()
		return "Expected outcome title font size to be preserved."
	panel.free()
	title.free()
	return ""
