extends RefCounted
class_name CombatSceneContractTest

const COMBAT_SCENE := preload("res://scenes/combat.tscn")
const COMBAT_VIEW_SCRIPT := preload("res://scripts/combat/combat_view.gd")


class FakeCombatController:
	extends RefCounted

	var back_count := 0

	func on_back_button_pressed() -> void:
		back_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("combat_scene_script_is_attached", _test_combat_scene_script_is_attached, failures)
	_run_case("combat_root_node_bindings_resolve", _test_combat_root_node_bindings_resolve, failures)
	_run_case("combat_root_node_bindings_have_expected_types", _test_combat_root_node_bindings_have_expected_types, failures)
	_run_case("board_view_resolves_from_combat_scene", _test_board_view_resolves_from_combat_scene, failures)
	_run_case("combat_view_exposes_board_centered_fullscreen_vfx_target", _test_combat_view_exposes_board_centered_fullscreen_vfx_target, failures)
	_run_case("header_buttons_are_scene_connected", _test_header_buttons_are_scene_connected, failures)
	_run_case("header_help_press_is_debounced", _test_header_help_press_is_debounced, failures)
	_run_case("turn_result_audio_not_replayed_after_visual_replay", _test_turn_result_audio_not_replayed_after_visual_replay, failures)

	return {
		"passed": failures.is_empty(),
		"total": 8,
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


func _test_combat_scene_script_is_attached() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var has_script := root.get_script() != null
	var has_root_builder := root.has_method("_build_root_nodes")
	var has_type_contract := root.has_method("_root_node_types")
	root.free()
	if not has_script:
		return "Expected combat scene root script to be attached and compiled."
	if not has_root_builder:
		return "Expected combat scene root to expose _build_root_nodes()."
	if not has_type_contract:
		return "Expected combat scene root to expose _root_node_types()."
	return ""


func _test_combat_root_node_bindings_resolve() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var nodes: Dictionary = root.call("_build_root_nodes")
	var missing: Array[String] = []
	for node_name in nodes.keys():
		if nodes[node_name] == null:
			missing.append(String(node_name))
	root.free()
	if not missing.is_empty():
		return "Expected all combat root node bindings to resolve; missing %s." % ", ".join(missing)
	return ""


func _test_combat_root_node_bindings_have_expected_types() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var nodes: Dictionary = root.call("_build_root_nodes")
	var expected_types: Dictionary = root.call("_root_node_types")
	var missing_type_keys: Array[String] = []
	var unexpected_type_keys: Array[String] = []
	var mismatches: Array[String] = []
	for node_name in nodes.keys():
		if not expected_types.has(node_name):
			missing_type_keys.append(String(node_name))
	for node_name in expected_types.keys():
		if not nodes.has(node_name):
			unexpected_type_keys.append(String(node_name))
			continue
		var node: Node = nodes[node_name] as Node
		var expected_type := String(expected_types[node_name])
		if node == null:
			mismatches.append("%s expected %s, got <null>" % [String(node_name), expected_type])
		elif not _node_matches_expected_type(node, expected_type):
			mismatches.append("%s expected %s, got %s" % [String(node_name), expected_type, _node_type_label(node)])
	root.free()
	if not missing_type_keys.is_empty():
		return "Expected every combat root node binding to declare a type; missing %s." % ", ".join(missing_type_keys)
	if not unexpected_type_keys.is_empty():
		return "Expected every typed combat root node to resolve; extra type keys %s." % ", ".join(unexpected_type_keys)
	if not mismatches.is_empty():
		return "Expected combat root node binding types to match; mismatches %s." % "; ".join(mismatches)
	return ""


func _test_board_view_resolves_from_combat_scene() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var nodes: Dictionary = root.call("_build_root_nodes")
	var board_view: BoardView = nodes.get("_board_view") as BoardView
	var resolved := board_view != null
	root.free()
	if not resolved:
		return "Expected _board_view to resolve to BoardView."
	return ""


func _test_combat_view_exposes_board_centered_fullscreen_vfx_target() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	root.set_anchors_preset(Control.PRESET_TOP_LEFT as Control.LayoutPreset)
	root.size = Vector2(1080.0, 1920.0)
	var nodes: Dictionary = root.call("_build_root_nodes")
	var board := nodes.get("_board") as Control
	var board_panel := nodes.get("_board_panel") as Control
	var vfx_layer := nodes.get("_vfx_layer") as Control
	if board == null or board_panel == null or vfx_layer == null:
		root.free()
		return "Expected combat scene to expose board, board panel, and VFX layer nodes."
	for control in [board, board_panel, vfx_layer]:
		control.set_anchors_preset(Control.PRESET_TOP_LEFT as Control.LayoutPreset)
	board.position = Vector2(128.0, 700.0)
	board.size = Vector2(760.0, 760.0)
	board_panel.position = Vector2(16.0, 660.0)
	board_panel.size = Vector2(1048.0, 756.0)
	vfx_layer.position = Vector2.ZERO
	vfx_layer.size = root.size
	var view: CombatView = COMBAT_VIEW_SCRIPT.new()
	view.bind(nodes)
	var target := view.board_vfx_target_global()
	var expected_target := board.get_global_rect().position + board.get_global_rect().size * 0.5
	if not target.is_equal_approx(expected_target):
		root.free()
		return "Expected board VFX target to resolve to the board center."
	var fullscreen_size := view.board_fullscreen_vfx_size()
	if fullscreen_size.x < root.size.x or fullscreen_size.y < root.size.y:
		root.free()
		return "Expected board fullscreen VFX size to cover the combat viewport."
	var screen_safe_armor_base_extent := minf(fullscreen_size.x, fullscreen_size.y) * 0.34
	if screen_safe_armor_base_extent * 3.0 > minf(fullscreen_size.x, fullscreen_size.y) * 1.04:
		root.free()
		return "Expected armor mastery base sizing to remain screen-bounded after tier scaling."
	root.free()
	return ""


func _test_header_buttons_are_scene_connected() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var missing: Array[String] = []
	_assert_scene_button_connection(root, "CombatLayoutRoot/TopBar/HelpButton", "_on_back_button_pressed", missing)
	_assert_scene_button_connection(root, "CombatLayoutRoot/TopBar/DebugToggleButton", "_on_debug_toggle_button_pressed", missing)
	_assert_scene_button_connection(root, "CombatLayoutRoot/TopBar/SettingsButton", "_on_settings_button_pressed", missing)
	root.free()
	if not missing.is_empty():
		return "Expected header button connections to be declared in combat.tscn; missing %s." % ", ".join(missing)
	return ""


func _test_header_help_press_is_debounced() -> String:
	var root := _instantiate_combat_scene()
	if root == null:
		return "Expected combat scene to instantiate."
	var controller := FakeCombatController.new()
	root.set("_controller", controller)
	root.call("_on_back_button_pressed")
	root.call("_on_back_button_pressed")
	var back_count := controller.back_count
	root.free()
	if back_count != 1:
		return "Expected duplicate header help dispatch to debounce to 1 press, got %d." % [back_count]
	return ""


func _test_turn_result_audio_not_replayed_after_visual_replay() -> String:
	var source := _script_source("res://scripts/combat/combat_controller.gd")
	if source == "":
		return "Expected combat controller source to be readable."
	if source.find("\n\t_play_turn_result_sfx(turn_log)") >= 0:
		return "Combat controller still replays turn result audio after visual replay."
	return ""


func _instantiate_combat_scene() -> Control:
	var root: Node = COMBAT_SCENE.instantiate()
	if root is Control:
		return root as Control
	if root != null:
		root.free()
	return null


func _assert_scene_button_connection(root: Control, button_path: String, method_name: String, missing: Array[String]) -> void:
	var button := root.get_node_or_null(button_path) as Button
	if button == null:
		missing.append("%s button" % button_path)
		return
	var callback := Callable(root, method_name)
	if not button.pressed.is_connected(callback):
		missing.append("%s -> %s" % [button_path, method_name])


func _script_source(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return ""
	return file.get_as_text()


func _node_matches_expected_type(node: Node, expected_type: String) -> bool:
	match expected_type:
		"BoardView":
			return node is BoardView
		"TopHeader":
			return node is TopHeader
		_:
			return node.is_class(expected_type)


func _node_type_label(node: Node) -> String:
	if node is BoardView:
		return "BoardView"
	if node is TopHeader:
		return "TopHeader"
	return node.get_class()
