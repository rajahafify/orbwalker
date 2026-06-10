extends RefCounted
class_name CombatLayoutPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_layout_presenter.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("nodes_from_root_nodes_preserves_layout_contract", _test_nodes_from_root_nodes_preserves_layout_contract, failures)
	_run_case("nodes_from_root_nodes_derives_top_bar_row_and_runtime_extras", _test_nodes_from_root_nodes_derives_top_bar_row_and_runtime_extras, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
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


func _test_nodes_from_root_nodes_preserves_layout_contract() -> String:
	var root := Control.new()
	var root_nodes := {}
	for root_key in PRESENTER_SCRIPT.LAYOUT_NODE_BINDINGS.values():
		var key := String(root_key)
		var node := Control.new()
		node.name = key.trim_prefix("_")
		root.add_child(node)
		root_nodes[key] = node
	var nodes: Dictionary = PRESENTER_SCRIPT.nodes_from_root_nodes(root_nodes)
	for layout_key in PRESENTER_SCRIPT.LAYOUT_NODE_BINDINGS.keys():
		if not nodes.has(layout_key):
			root.free()
			return "Expected layout node key: %s." % layout_key
		var expected_key := String(PRESENTER_SCRIPT.LAYOUT_NODE_BINDINGS[layout_key])
		if nodes.get(layout_key) != root_nodes.get(expected_key):
			root.free()
			return "Expected %s to resolve from %s." % [layout_key, expected_key]
	root.free()
	return ""


func _test_nodes_from_root_nodes_derives_top_bar_row_and_runtime_extras() -> String:
	var top_bar := Control.new()
	var top_bar_row := Control.new()
	top_bar_row.name = "TopBarRow"
	top_bar.add_child(top_bar_row)
	var runtime_backdrop := TextureRect.new()
	var player_loadout_hud := RefCounted.new()
	var outcome_overlay := RefCounted.new()
	var nodes: Dictionary = PRESENTER_SCRIPT.nodes_from_root_nodes(
		{"_top_bar": top_bar},
		{
			"enemy_stage_backdrop": runtime_backdrop,
			"player_loadout_hud": player_loadout_hud,
			"outcome_overlay": outcome_overlay,
		}
	)
	if nodes.get("top_bar_row") != top_bar_row:
		top_bar.free()
		runtime_backdrop.free()
		return "Expected top_bar_row to be derived from top_bar child."
	if nodes.get("enemy_stage_backdrop") != runtime_backdrop:
		top_bar.free()
		runtime_backdrop.free()
		return "Expected runtime backdrop extra to be carried through."
	if nodes.get("player_loadout_hud") != player_loadout_hud or nodes.get("outcome_overlay") != outcome_overlay:
		top_bar.free()
		runtime_backdrop.free()
		return "Expected non-node layout extras to be carried through."
	top_bar.free()
	runtime_backdrop.free()
	return ""
