extends RefCounted
class_name SceneRouter

var _owner
var _enabled := true
var _route_retention_max := 50
var _routes: Dictionary = {}
var _route_order: Array[String] = []
var _route_serial: int = 0
var _active_route_id: String = ""
var _transition_generation: int = 0


func _init(owner, enabled: bool = true, route_retention_max: int = 50) -> void:
	_owner = owner
	_enabled = enabled
	_route_retention_max = maxi(1, route_retention_max)


func transition_snapshot() -> Dictionary:
	return {
		"flow_trace_routes": _routes.duplicate(true),
		"flow_trace_route_order": _route_order.duplicate(),
		"flow_trace_route_serial": _route_serial,
		"flow_trace_active_route_id": _active_route_id,
		"flow_trace_transition_generation": _transition_generation,
	}


func restore_transition_snapshot(snapshot: Dictionary) -> void:
	_routes = Dictionary(snapshot.get("flow_trace_routes", _routes)).duplicate(true)
	_route_order = Array(snapshot.get("flow_trace_route_order", _route_order)).duplicate()
	_route_serial = maxi(0, int(snapshot.get("flow_trace_route_serial", _route_serial)))
	_active_route_id = String(snapshot.get("flow_trace_active_route_id", _active_route_id))
	_transition_generation = maxi(0, int(snapshot.get("flow_trace_transition_generation", _transition_generation)))
	_flow_trace_prune_routes()
	if _active_route_id != "" and not _routes.has(_active_route_id):
		_active_route_id = ""


func flow_trace_begin(route_name: String, target_scene: String, details: Dictionary = {}) -> String:
	if not _enabled:
		return ""
	_route_serial += 1
	var route_id := "%s_%d" % [route_name, _route_serial]
	var now := Time.get_ticks_usec()
	_routes[route_id] = {
		"route_name": route_name,
		"target_scene": target_scene,
		"start_usec": now,
		"last_usec": now,
	}
	_active_route_id = route_id
	_flow_trace_mark_internal(route_id, "route_begin", details, target_scene)
	return route_id


func flow_trace_mark(step: String, details: Dictionary = {}, route_id: String = "", target_scene_override: String = "") -> void:
	if not _enabled:
		return
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = _active_route_id
	if resolved_route_id == "":
		return
	_flow_trace_mark_internal(resolved_route_id, step, details, target_scene_override)


func flow_trace_change_scene(
	tree: SceneTree,
	target_scene: String,
	route_id: String = "",
	source: String = "",
	before_step: String = "",
	post_ready_failure_callback: Callable = Callable(),
	rollback_snapshot: Dictionary = {}
) -> int:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()

	if before_step != "":
		var before_details := {}
		if source != "":
			before_details["source"] = source
		flow_trace_mark(before_step, before_details, resolved_route_id, target_scene)

	var prepared := flow_trace_prepare_scene(target_scene, resolved_route_id, source)
	if not bool(prepared.get("ok", false)):
		return int(prepared.get("error_code", ERR_CANT_OPEN))
	if post_ready_failure_callback.is_valid():
		prepared["post_ready_failure_callback"] = post_ready_failure_callback
	if not rollback_snapshot.is_empty():
		prepared["rollback_snapshot"] = rollback_snapshot

	return flow_trace_attach_prepared_scene(tree, prepared, target_scene, resolved_route_id, source)


func flow_trace_prepare_scene(target_scene: String, route_id: String = "", source: String = "") -> Dictionary:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()

	var transition_details := {}
	if source != "":
		transition_details["source"] = source
	flow_trace_mark("transition_manual_start", transition_details, resolved_route_id, target_scene)
	flow_trace_mark("before_resource_load", transition_details, resolved_route_id, target_scene)

	if target_scene.strip_edges() == "":
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": 0,
				"error": "target_scene_empty",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_OPEN,
			"reason": "target_scene_empty",
			"route_id": resolved_route_id,
		}

	var load_start_usec := Time.get_ticks_usec()
	var loaded_resource: Resource = ResourceLoader.load(target_scene)
	var load_ms := int((Time.get_ticks_usec() - load_start_usec) / 1000.0)
	if loaded_resource == null:
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": load_ms,
				"error": "resource_load_failed",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_OPEN,
			"reason": "resource_load_failed",
			"route_id": resolved_route_id,
		}
	if not (loaded_resource is PackedScene):
		flow_trace_mark(
			"after_resource_load",
			{
				"ok": false,
				"load_ms": load_ms,
				"resource_type": loaded_resource.get_class(),
				"error": "resource_not_packed_scene",
			},
			resolved_route_id,
			target_scene
		)
		return {
			"ok": false,
			"error_code": ERR_INVALID_DATA,
			"reason": "resource_not_packed_scene",
			"route_id": resolved_route_id,
		}

	var packed_scene := loaded_resource as PackedScene
	flow_trace_mark(
		"after_resource_load",
		{
			"ok": true,
			"load_ms": load_ms,
			"resource_type": packed_scene.get_class(),
		},
		resolved_route_id,
		target_scene
	)
	flow_trace_mark("before_scene_instantiate", transition_details, resolved_route_id, target_scene)

	var instantiate_start_usec := Time.get_ticks_usec()
	var instantiated_scene = packed_scene.instantiate()
	var instantiate_ms := int((Time.get_ticks_usec() - instantiate_start_usec) / 1000.0)
	if instantiated_scene == null:
		flow_trace_mark(
			"after_scene_instantiate",
			{
				"ok": false,
				"instantiate_ms": instantiate_ms,
				"error": "instantiate_returned_null",
			},
			resolved_route_id,
			target_scene
		)
		push_error("[FlowTrace] flow_trace_change_scene instantiate failed for %s (null)" % target_scene)
		return {
			"ok": false,
			"error_code": ERR_CANT_CREATE,
			"reason": "instantiate_returned_null",
			"route_id": resolved_route_id,
		}
	if not (instantiated_scene is Node):
		flow_trace_mark(
			"after_scene_instantiate",
			{
				"ok": false,
				"instantiate_ms": instantiate_ms,
				"node_type": instantiated_scene.get_class(),
				"error": "instantiate_not_node",
			},
			resolved_route_id,
			target_scene
		)
		push_error(
			"[FlowTrace] flow_trace_change_scene instantiate returned non-Node for %s: %s"
			% [target_scene, instantiated_scene.get_class()]
		)
		return {
			"ok": false,
			"error_code": ERR_CANT_CREATE,
			"reason": "instantiate_not_node",
			"route_id": resolved_route_id,
		}

	var new_scene := instantiated_scene as Node
	flow_trace_mark(
		"after_scene_instantiate",
		{
			"ok": true,
			"instantiate_ms": instantiate_ms,
			"node_type": new_scene.get_class(),
			"node_name": new_scene.name,
		},
		resolved_route_id,
		target_scene
	)
	return {
		"ok": true,
		"error_code": OK,
		"scene": new_scene,
		"route_id": resolved_route_id,
	}


func flow_trace_attach_prepared_scene(
	tree: SceneTree,
	prepared: Dictionary,
	target_scene: String,
	route_id: String = "",
	source: String = ""
) -> int:
	var resolved_route_id := route_id
	if resolved_route_id == "":
		resolved_route_id = String(prepared.get("route_id", ""))
	if resolved_route_id == "":
		resolved_route_id = flow_trace_active_route_id()
	if not bool(prepared.get("ok", false)):
		var prepared_error_code := int(prepared.get("error_code", ERR_INVALID_DATA))
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": prepared_error_code,
				"attach_ms": 0,
				"error": "prepared_scene_invalid",
			},
			resolved_route_id,
			target_scene
		)
		return prepared_error_code
	var new_scene := prepared.get("scene", null) as Node
	if new_scene == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_INVALID_DATA,
				"attach_ms": 0,
				"error": "prepared_scene_missing",
			},
			resolved_route_id,
			target_scene
		)
		return ERR_INVALID_DATA
	var old_scene: Node = null
	var old_scene_name := ""
	var old_scene_path := ""
	if tree != null:
		old_scene = tree.current_scene
	if old_scene != null and is_instance_valid(old_scene):
		old_scene_name = old_scene.name
		if old_scene.is_inside_tree():
			old_scene_path = String(old_scene.get_path())

	flow_trace_mark(
		"before_scene_attach",
		{
			"source": source,
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
		},
		resolved_route_id,
		target_scene
	)

	if tree == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_UNAVAILABLE,
				"attach_ms": 0,
				"error": "scene_tree_null",
			},
			resolved_route_id,
			target_scene
		)
		new_scene.free()
		push_error("[FlowTrace] flow_trace_change_scene failed: SceneTree is null for %s" % target_scene)
		return ERR_UNAVAILABLE

	var tree_root := tree.root
	if tree_root == null:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_UNAVAILABLE,
				"attach_ms": 0,
				"error": "scene_tree_root_null",
			},
			resolved_route_id,
			target_scene
		)
		new_scene.free()
		push_error("[FlowTrace] flow_trace_change_scene failed: SceneTree root is null for %s" % target_scene)
		return ERR_UNAVAILABLE

	var attach_start_usec := Time.get_ticks_usec()
	tree_root.add_child(new_scene)
	tree.current_scene = new_scene
	var attach_ms := int((Time.get_ticks_usec() - attach_start_usec) / 1000.0)
	if tree.current_scene != new_scene:
		flow_trace_mark(
			"after_scene_attach",
			{
				"ok": false,
				"error_code": ERR_CANT_CREATE,
				"attach_ms": attach_ms,
				"error": "current_scene_not_updated",
			},
			resolved_route_id,
			target_scene
		)
		if is_instance_valid(new_scene):
			new_scene.queue_free()
		push_error("[FlowTrace] flow_trace_change_scene failed: current_scene assignment failed for %s" % target_scene)
		return ERR_CANT_CREATE

	if old_scene != null and is_instance_valid(old_scene) and old_scene != new_scene:
		old_scene.process_mode = Node.PROCESS_MODE_DISABLED
		if old_scene is CanvasItem:
			(old_scene as CanvasItem).visible = false

	var new_scene_path := ""
	if new_scene.is_inside_tree():
		new_scene_path = String(new_scene.get_path())
	flow_trace_mark(
		"after_scene_attach",
		{
			"ok": true,
			"error_code": OK,
			"attach_ms": attach_ms,
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
			"new_scene_name": new_scene.name,
			"new_scene_path": new_scene_path,
		},
		resolved_route_id,
		target_scene
	)

	if old_scene != null and is_instance_valid(old_scene) and old_scene != new_scene:
		var post_ready_failure_callback: Callable = prepared.get("post_ready_failure_callback", Callable())
		_transition_generation += 1
		_deferred_finish_prepared_scene_attach.call_deferred(
			tree,
			old_scene,
			new_scene,
			target_scene,
			source,
			resolved_route_id,
			_transition_generation,
			old_scene_name,
			old_scene_path,
			Dictionary(prepared.get("rollback_snapshot", {})),
			post_ready_failure_callback
		)

	return OK


func _deferred_finish_prepared_scene_attach(
	tree: SceneTree,
	old_scene: Node,
	new_scene: Node,
	target_scene: String,
	source: String,
	route_id: String,
	transition_generation: int,
	old_scene_name: String,
	old_scene_path: String,
	rollback_snapshot: Dictionary = {},
	post_ready_failure_callback: Callable = Callable()
) -> void:
	var owner_tree: SceneTree = _owner.get_tree()
	if owner_tree == null:
		return
	await owner_tree.process_frame
	if transition_generation != _transition_generation:
		flow_trace_mark(
			"prepared_scene_post_ready_stale_generation_skip",
			{
				"expected_generation": transition_generation,
				"current_generation": _transition_generation,
				"old_scene_name": old_scene_name,
				"old_scene_path": old_scene_path,
			},
			route_id,
			target_scene
		)
		if old_scene != null and is_instance_valid(old_scene):
			if tree == null or tree.current_scene != old_scene:
				old_scene.queue_free()
		if is_instance_valid(new_scene):
			if tree == null or tree.current_scene != new_scene:
				new_scene.queue_free()
		return
	var new_scene_healthy := (
		tree != null
		and is_instance_valid(new_scene)
		and new_scene.is_inside_tree()
		and tree.current_scene == new_scene
	)
	if new_scene_healthy:
		flow_trace_mark(
			"before_old_scene_free",
			{
				"old_scene_name": old_scene_name,
				"old_scene_path": old_scene_path,
				"post_ready_check": true,
			},
			route_id,
			target_scene
		)
		if old_scene != null and is_instance_valid(old_scene):
			old_scene.queue_free()
		return

	flow_trace_mark(
		"prepared_scene_post_ready_check_failed",
		{
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
			"new_scene_valid": is_instance_valid(new_scene),
		},
		route_id,
		target_scene
	)
	if not rollback_snapshot.is_empty():
		_owner.restore_run_transition_state(rollback_snapshot)
	if old_scene != null and is_instance_valid(old_scene):
		old_scene.process_mode = Node.PROCESS_MODE_INHERIT
		if old_scene is CanvasItem:
			(old_scene as CanvasItem).visible = true
		if tree != null:
			tree.current_scene = old_scene
	if is_instance_valid(new_scene):
		new_scene.queue_free()
	if post_ready_failure_callback.is_valid():
		post_ready_failure_callback.call({
			"ok": false,
			"reason": "prepared_scene_post_ready_check_failed",
			"target_scene": target_scene,
			"route_id": route_id,
			"source": source,
			"old_scene_name": old_scene_name,
			"old_scene_path": old_scene_path,
		})
	push_error("[FlowTrace] prepared scene post-ready check failed for %s; restored previous scene when available" % target_scene)


func flow_trace_active_route_id() -> String:
	return _active_route_id


func flow_trace_debug_snapshot() -> Dictionary:
	return {
		"route_count": _routes.size(),
		"active_route_id": _active_route_id,
		"transition_generation": _transition_generation,
	}


func flow_trace_bump_transition_generation() -> void:
	_transition_generation += 1


func _flow_trace_register_route(route_id: String) -> void:
	if route_id == "":
		return
	if _route_order.has(route_id):
		_route_order.erase(route_id)
	_route_order.append(route_id)


func _flow_trace_prune_routes() -> void:
	var retained_order: Array[String] = []
	for raw_route_id in _route_order:
		var route_id := String(raw_route_id)
		if _routes.has(route_id):
			retained_order.append(route_id)
	_route_order = retained_order
	while _routes.size() > _route_retention_max:
		var prune_route_id := ""
		for ordered_route_id in _route_order:
			var candidate_id := String(ordered_route_id)
			if candidate_id == _active_route_id:
				continue
			prune_route_id = candidate_id
			break
		if prune_route_id == "":
			for raw_candidate in _routes.keys():
				var candidate := String(raw_candidate)
				if candidate == _active_route_id:
					continue
				prune_route_id = candidate
				break
		if prune_route_id == "":
			break
		_routes.erase(prune_route_id)
		_route_order.erase(prune_route_id)


func _flow_trace_mark_internal(route_id: String, step: String, details: Dictionary, target_scene_override: String) -> void:
	var route_data: Dictionary = _routes.get(route_id, {})
	if route_data.is_empty():
		var now_missing := Time.get_ticks_usec()
		route_data = {
			"route_name": "unknown",
			"target_scene": target_scene_override,
			"start_usec": now_missing,
			"last_usec": now_missing,
		}
	var now := Time.get_ticks_usec()
	var start_usec := int(route_data.get("start_usec", now))
	var last_usec := int(route_data.get("last_usec", start_usec))
	var target_scene := String(route_data.get("target_scene", ""))
	if target_scene_override != "":
		target_scene = target_scene_override
	var elapsed_ms := int((now - start_usec) / 1000.0)
	var delta_ms := int((now - last_usec) / 1000.0)
	route_data["last_usec"] = now
	route_data["target_scene"] = target_scene
	_routes[route_id] = route_data
	_flow_trace_register_route(route_id)
	_flow_trace_prune_routes()

	var details_text := ""
	if not details.is_empty():
		details_text = " details=%s" % str(details)
	print(
		"[FlowTrace] route_id=%s route=%s target_scene=%s elapsed_ms=%d delta_ms=%d step=%s dungeon_level=%d run_active=%s current_step=%s%s"
		% [
			route_id,
			String(route_data.get("route_name", "unknown")),
			target_scene,
			elapsed_ms,
			delta_ms,
			step,
			_owner.dungeon_level,
			str(_owner.run_active),
			_owner.current_step_key,
			details_text,
		]
	)
