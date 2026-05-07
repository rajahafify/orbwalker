extends RefCounted
class_name CombatView

var _root_nodes: Dictionary = {}


func bind(root_nodes: Dictionary) -> void:
	_root_nodes = root_nodes


func nodes_snapshot() -> Dictionary:
	return _root_nodes


func node(key: String) -> Variant:
	return _root_nodes.get(key)
