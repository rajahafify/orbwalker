extends RefCounted
class_name CombatSceneContractTest

const COMBAT_SCENE := preload("res://scenes/combat.tscn")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("combat_root_node_bindings_resolve", _test_combat_root_node_bindings_resolve, failures)
	_run_case("combat_root_node_bindings_have_expected_types", _test_combat_root_node_bindings_have_expected_types, failures)
	_run_case("board_view_resolves_from_combat_scene", _test_board_view_resolves_from_combat_scene, failures)
	_run_case("header_buttons_are_scene_connected", _test_header_buttons_are_scene_connected, failures)

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
