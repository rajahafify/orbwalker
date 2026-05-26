extends Node

const RUNTIME_SERVER := "GDAIRuntimeServer"


func _enter_tree() -> void:
	if not ClassDB.class_exists(RUNTIME_SERVER):
		return
	if not ClassDB.can_instantiate(RUNTIME_SERVER):
		return
	var runtime_server: Variant = ClassDB.instantiate(RUNTIME_SERVER)
	if runtime_server is Node:
		add_child(runtime_server)
