extends RefCounted
class_name SceneRouterTest

const SCENE_ROUTER_SCRIPT := preload("res://scripts/core/scene_router.gd")
const BOARD_SCENE_PATH := "res://scenes/ui/board.tscn"


class FakeOwner:
	extends RefCounted

	var dungeon_level := 1
	var run_active := false
	var current_step_key := "enemy_1"


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("warm_packed_scene_caches_prepared_scene", _test_warm_packed_scene_caches_prepared_scene, failures)
	_run_case("warm_packed_scene_rejects_blank_path", _test_warm_packed_scene_rejects_blank_path, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_warm_packed_scene_caches_prepared_scene() -> String:
	var router: Variant = SCENE_ROUTER_SCRIPT.new(FakeOwner.new())
	if not bool(router.warm_packed_scene(BOARD_SCENE_PATH)):
		return "Expected board scene warm-up request to be accepted."
	var route_id: String = router.flow_trace_begin("test_to_board", BOARD_SCENE_PATH)
	var prepared: Dictionary = router.flow_trace_prepare_scene(BOARD_SCENE_PATH, route_id, "scene_router_test")
	if not bool(prepared.get("ok", false)):
		return "Expected warmed board scene to prepare successfully: %s" % String(prepared.get("reason", "unknown"))
	var scene := prepared.get("scene", null) as Node
	if scene == null:
		return "Expected prepared scene to include an instantiated node."
	scene.free()
	if not router.cached_packed_scene_paths().has(BOARD_SCENE_PATH):
		return "Expected prepared warmed scene to be retained in the packed-scene cache."
	return ""


func _test_warm_packed_scene_rejects_blank_path() -> String:
	var router: Variant = SCENE_ROUTER_SCRIPT.new(FakeOwner.new())
	if bool(router.warm_packed_scene("   ")):
		return "Expected blank scene path warm-up to be rejected."
	return ""
