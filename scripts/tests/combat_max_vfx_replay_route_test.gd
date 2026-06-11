extends RefCounted
class_name CombatMaxVfxReplayRouteTest

const COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_pack_recipe_presenter.gd")
const COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_presenter.gd")
const COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_status_recipe_presenter.gd")
const COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_fallback_presenter.gd")
const COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_impact_router.gd")
const COMBAT_MAX_VFX_REPLAY_ROUTE_POLICY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_route_policy.gd")
const COMBAT_MAX_VFX_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")


class FakeReplayRoutePresenter:
	extends RefCounted

	var label: String
	var supports_result := true
	var supports_screen_wide := true
	var spawn_result := true
	var spawn_calls: Array[Dictionary] = []

	func _init(presenter_label: String) -> void:
		label = presenter_label

	func bind(_dependencies: Dictionary) -> void:
		pass

	func supports_replay_impact(_kind: String, screen_wide: bool = false) -> bool:
		return supports_result and (supports_screen_wide or not screen_wide)

	func spawn_replay_impact(
		_center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
	) -> bool:
		spawn_calls.append(
			{
				"presenter": label,
				"kind": kind,
				"draw_size": draw_size,
				"max_size": max_size,
				"base_size": base_size,
				"duration": duration,
				"intensity": intensity,
				"screen_wide": screen_wide
			}
		)
		return spawn_result


class FakeReplayRouteOverlay:
	extends COMBAT_MAX_VFX_OVERLAY_SCRIPT
	var force_status_available := true
	var force_elemental_available := true
	var force_pack_available := true

	func _status_vfx_available() -> bool:
		return force_status_available

	func _elemental_magic_available() -> bool:
		return force_elemental_available

	func _pack_vfx_available() -> bool:
		return force_pack_available


class FakeReplayFallbackPresenter:
	extends RefCounted

	var bind_calls := 0
	var armor_calls: Array[Dictionary] = []
	var lightweight_calls: Array[Dictionary] = []

	func bind(_dependencies: Dictionary) -> void:
		bind_calls += 1

	func spawn_armor_replay_fallback(
		center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
	) -> bool:
		armor_calls.append(_call_record(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide))
		return true

	func spawn_lightweight_replay_fallback(
		center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
	) -> bool:
		lightweight_calls.append(_call_record(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide))
		return true

	func _call_record(
		center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
	) -> Dictionary:
		return {
			"center": center,
			"kind": kind,
			"draw_size": draw_size,
			"max_size": max_size,
			"base_size": base_size,
			"duration": duration,
			"intensity": intensity,
			"screen_wide": screen_wide
		}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("combat_max_vfx_pack_recipe_presenter_replay_impact_contract", _test_combat_max_vfx_pack_recipe_presenter_replay_impact_contract, failures)
	_run_case(
		"combat_max_vfx_elemental_recipe_presenter_replay_impact_contract", _test_combat_max_vfx_elemental_recipe_presenter_replay_impact_contract, failures
	)
	_run_case("combat_max_vfx_status_recipe_presenter_replay_impact_contract", _test_combat_max_vfx_status_recipe_presenter_replay_impact_contract, failures)
	_run_case("combat_max_vfx_replay_router_uses_first_handled_route", _test_combat_max_vfx_replay_router_uses_first_handled_route, failures)
	_run_case("combat_max_vfx_replay_router_respects_route_gates", _test_combat_max_vfx_replay_router_respects_route_gates, failures)
	_run_case("combat_max_vfx_replay_router_supports_callable_routes", _test_combat_max_vfx_replay_router_supports_callable_routes, failures)
	_run_case(
		"combat_max_vfx_replay_route_policy_uses_explicit_status_availability",
		_test_combat_max_vfx_replay_route_policy_uses_explicit_status_availability,
		failures
	)
	_run_case("combat_max_vfx_replay_route_policy_default_route_contract", _test_combat_max_vfx_replay_route_policy_default_route_contract, failures)
	_run_case(
		"combat_max_vfx_replay_router_default_armor_fallback_precedes_presenter_routes",
		_test_combat_max_vfx_replay_router_default_armor_fallback_precedes_presenter_routes,
		failures
	)
	_run_case(
		"combat_max_vfx_replay_router_default_lightweight_fallback_is_final_catch_all",
		_test_combat_max_vfx_replay_router_default_lightweight_fallback_is_final_catch_all,
		failures
	)
	_run_case(
		"combat_max_vfx_replay_router_armor_fallback_uses_status_availability_not_presenter_order",
		_test_combat_max_vfx_replay_router_armor_fallback_uses_status_availability_not_presenter_order,
		failures
	)
	_run_case("combat_max_vfx_replay_fallback_presenter_armor_contract", _test_combat_max_vfx_replay_fallback_presenter_armor_contract, failures)
	_run_case("combat_max_vfx_replay_fallback_presenter_lightweight_contract", _test_combat_max_vfx_replay_fallback_presenter_lightweight_contract, failures)
	_run_case("combat_max_vfx_overlay_routes_replay_to_status_presenter", _test_combat_max_vfx_overlay_routes_replay_to_status_presenter, failures)
	_run_case("combat_max_vfx_overlay_falls_back_to_pack_route", _test_combat_max_vfx_overlay_falls_back_to_pack_route, failures)
	_run_case("combat_max_vfx_overlay_armor_fallback_precedes_pack_route", _test_combat_max_vfx_overlay_armor_fallback_precedes_pack_route, failures)
	return {
		"passed": failures.is_empty(),
		"total": 16,
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


func _replay_route_overlay_fixture() -> Dictionary:
	var root := Control.new()
	root.name = "CombatVfxReplayRouteFixture"
	root.size = Vector2(1080, 1920)
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(root)
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = root.size
	root.add_child(layer)
	var overlay := FakeReplayRouteOverlay.new()
	(
		overlay
		. bind(
			{
				"vfx_layer": layer,
				"visual_registry": VISUAL_REGISTRY_SCRIPT.new(),
				"timer_owner": root,
			}
		)
	)
	return {
		"root": root,
		"layer": layer,
		"overlay": overlay,
	}


func _cleanup_vfx_fixture(fixture: Dictionary) -> void:
	var root := fixture.get("root") as Node
	if root != null and is_instance_valid(root):
		root.free()


func _test_combat_max_vfx_pack_recipe_presenter_replay_impact_contract() -> String:
	var pack_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"kind_cleaner":
			func(kind: String) -> String:
				var clean_kind := kind.strip_edges().to_lower()
				if clean_kind == "heal":
					return "heart"
				return clean_kind,
			"layer_size_provider": func() -> Vector2: return Vector2(1000, 800),
			"pack_effect_spawner":
			func(
				scene_key: String,
				center_local: Vector2,
				kind: String,
				draw_size: Vector2,
				lifetime: float,
				intensity: int,
				delay: float,
				move_offset: Vector2,
				rotation: float,
				z: float,
				alpha: float
			) -> void:
				pack_calls.append(
					{
						"key": scene_key,
						"center": center_local,
						"kind": kind,
						"size": draw_size,
						"lifetime": lifetime,
						"intensity": intensity,
						"delay": delay,
						"rotation": rotation,
						"z": z,
						"alpha": alpha
					}
				),
		}
	)
	if not presenter.supports_replay_impact("earth"):
		return "Expected pack presenter to support replay impact."
	if not presenter.spawn_replay_impact(Vector2(100, 160), "earth", Vector2(140, 120), 140.0, 188.0, 1.0, 4, false):
		return "Expected pack presenter replay impact to return true."
	if pack_calls.size() != 2:
		return "Expected pack replay impact to emit impact and hit layers."
	return ""


func _test_combat_max_vfx_elemental_recipe_presenter_replay_impact_contract() -> String:
	var elemental_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"kind_cleaner":
			func(kind: String) -> String:
				var clean_kind := kind.strip_edges().to_lower()
				if clean_kind == "heal":
					return "heart"
				return clean_kind,
			"layer_size_provider": func() -> Vector2: return Vector2(1000, 800),
			"elemental_effect_spawner":
			func(
				scene_key: String,
				center_local: Vector2,
				kind: String,
				draw_size: Vector2,
				lifetime: float,
				intensity: int,
				delay: float,
				move_offset: Vector2,
				rotation: float,
				z: float,
				alpha: float
			) -> Node3D:
				elemental_calls.append(
					{
						"scene_key": scene_key,
						"center": center_local,
						"kind": kind,
						"size": draw_size,
						"duration": lifetime,
						"intensity": intensity,
						"delay": delay,
						"rotation": rotation,
						"z": z,
						"alpha": alpha
					}
				)
				return null,
			"pack_impact_scene_key_provider": func(kind: String, intensity: int, screen_wide: bool) -> String: return "impact_%s_%d" % [kind, intensity],
			"pack_layer_spawner":
			func(
				scene_key: String,
				center: Vector2,
				kind: String,
				draw_size: Vector2,
				lifetime: float,
				intensity: int,
				delay: float,
				rotation: float,
				z: float,
				alpha: float
			) -> void:
				pass,
			"kind_colors_provider": func(kind: String) -> Dictionary: return {"core": Color(0.8, 0.6, 0.2, 1.0), "accent": Color(1.0, 0.8, 0.2, 1.0)},
			"coin_rain_spawner": func(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void: pass,
			"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void: pass,
			"camera_kick_spawner": func(direction: Vector2, delay: float) -> void: pass,
		}
	)
	if not presenter.supports_replay_impact("fire"):
		return "Expected elemental presenter to support fire replay impact."
	if not presenter.spawn_replay_impact(Vector2(100, 160), "fire", Vector2(140, 120), 140.0, 188.0, 1.0, 4, false):
		return "Expected elemental replay impact to return true."
	if elemental_calls.size() < 1:
		return "Expected elemental replay impact to emit elemental effects."
	return ""


func _test_combat_max_vfx_status_recipe_presenter_replay_impact_contract() -> String:
	var status_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"kind_cleaner":
			func(kind: String) -> String:
				var clean_kind := kind.strip_edges().to_lower()
				if clean_kind == "heal":
					return "heart"
				return clean_kind,
			"layer_size_provider": func() -> Vector2: return Vector2(1000, 800),
			"kind_colors_provider": func(kind: String) -> Dictionary: return {"core": Color(0.8, 0.6, 0.2, 1.0)},
			"status_sheet_key_provider": func(kind: String) -> String: return "sheet_%s" % kind,
			"status_trail_key_provider": func(kind: String) -> String: return "trail_%s" % kind,
			"status_flipbook_spawner":
			func(
				sheet_key: String,
				center_local: Vector2,
				draw_size: Vector2,
				lifetime: float,
				color: Color,
				delay: float,
				move_offset: Vector2,
				target_scale: float,
				z: float,
				rotation: float,
				loops: int
			) -> void:
				status_calls.append(
					{"key": sheet_key, "kind": sheet_key, "size": draw_size, "lifetime": lifetime, "color": color, "delay": delay, "loops": loops}
				),
			"light_spawner": func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void: pass,
			"burst_particles_spawner": func(kind: String, center: Vector2, base_size: float, lifetime: float, intensity: int) -> void: pass,
			"atmospheric_replay_layer_spawner":
			func(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void: pass,
			"coin_rain_spawner": func(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void: pass,
			"pack_impact_scene_key_provider": func(kind: String, intensity: int, screen_wide: bool) -> String: return "impact_%s_%d" % [kind, intensity],
			"pack_layer_spawner":
			func(
				scene_key: String,
				center: Vector2,
				kind: String,
				draw_size: Vector2,
				lifetime: float,
				intensity: int,
				delay: float,
				rotation: float,
				z: float,
				alpha: float
			) -> void:
				pass,
			"fire_replay_layers_spawner":
			func(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void: pass,
			"ice_replay_layers_spawner":
			func(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void: pass,
			"earth_replay_layers_spawner":
			func(center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void: pass,
			"fire_cast_layers_spawner":
			func(
				source: Vector2,
				target: Vector2,
				delta: Vector2,
				spool_size: Vector2,
				spool_duration: float,
				travel_duration: float,
				launch_delay: float,
				intensity: int,
				core: Color
			) -> void:
				pass,
			"ice_cast_layers_spawner":
			func(
				source: Vector2,
				target: Vector2,
				delta: Vector2,
				spool_size: Vector2,
				spool_duration: float,
				travel_duration: float,
				launch_delay: float,
				intensity: int,
				core: Color
			) -> void:
				pass,
			"earth_cast_layers_spawner":
			func(
				source: Vector2,
				target: Vector2,
				delta: Vector2,
				spool_size: Vector2,
				spool_duration: float,
				travel_duration: float,
				launch_delay: float,
				intensity: int,
				core: Color
			) -> void:
				pass,
			"fire_beam_layers_spawner": func(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void: pass,
			"windy_ice_block_travel_spawner":
			func(
				source: Vector2,
				target: Vector2,
				delta: Vector2,
				normal: Vector2,
				travel_size: Vector2,
				duration: float,
				launch_delay: float,
				intensity: int,
				angle: float
			) -> void:
				pass,
			"earth_fracture_travel_spawner":
			func(
				source: Vector2,
				target: Vector2,
				delta: Vector2,
				normal: Vector2,
				travel_size: Vector2,
				duration: float,
				launch_delay: float,
				intensity: int,
				angle: float,
				tier: int
			) -> void:
				pass,
			"earth_tier_provider": func(intensity: int) -> int: return intensity,
			"atmospheric_travel_spawner":
			func(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void: pass,
			"beam_effect_spawner":
			func(source: Vector2, delta: Vector2, kind: String, duration: float, intensity: int, delay: float, radius_scale: float) -> void: pass,
			"camera_kick_spawner": func(direction: Vector2, delay: float) -> void: pass,
		}
	)
	if not presenter.supports_replay_impact("damage"):
		return "Expected status presenter to support replay impact."
	if not presenter.spawn_replay_impact(Vector2(100, 160), "damage", Vector2(140, 120), 140.0, 188.0, 1.0, 4, false):
		return "Expected status replay impact to return true."
	if status_calls.size() == 0:
		return "Expected status replay impact to emit status flipbooks."
	return ""


func _test_combat_max_vfx_replay_router_uses_first_handled_route() -> String:
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	status_presenter.spawn_result = false
	elemental_presenter.spawn_result = true
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	(
		router
		. bind(
			{
				"routes":
				[
					{"presenter": status_presenter, "available": true},
					{"presenter": elemental_presenter, "available": true},
					{"presenter": pack_presenter, "available": true},
				]
			}
		)
	)
	if not router.supports_replay_impact("fire", false):
		return "Expected router to report replay support when any available route supports it."
	if not router.spawn_replay_impact(Vector2(100, 160), "fire", Vector2(140, 120), 140.0, 188.0, 1.0, 4, false):
		return "Expected router to return true when a later route handles replay impact."
	if status_presenter.spawn_calls.size() != 1 or elemental_presenter.spawn_calls.size() != 1:
		return "Expected router to try status, then elemental."
	if not pack_presenter.spawn_calls.is_empty():
		return "Expected router to stop after the first handled route."
	return ""


func _test_combat_max_vfx_replay_router_respects_route_gates() -> String:
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	var status_available := false
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	router.bind(
		{
			"routes":
			[
				{"presenter": status_presenter, "available": func() -> bool: return status_available},
				{"presenter": elemental_presenter, "available": true, "kind_filter": func(kind: String) -> bool: return kind == "fire"},
				{"presenter": pack_presenter, "available": true},
			]
		}
	)
	if not router.spawn_replay_impact(Vector2(100, 160), "earth", Vector2(140, 120), 140.0, 188.0, 1.0, 4, false):
		return "Expected router to fall through disabled and filtered routes to pack."
	if not status_presenter.spawn_calls.is_empty() or not elemental_presenter.spawn_calls.is_empty():
		return "Expected unavailable status and filtered elemental routes not to spawn."
	if pack_presenter.spawn_calls.size() != 1:
		return "Expected pack route to handle after gates decline earlier routes."
	return ""


func _test_combat_max_vfx_replay_router_supports_callable_routes() -> String:
	var presenter := FakeReplayRoutePresenter.new("presenter")
	presenter.supports_screen_wide = false
	presenter.spawn_result = false
	var callable_calls: Array[Dictionary] = []
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	router.bind(
		{
			"routes":
			[
				{"presenter": presenter, "available": true},
				{
					"available": true,
					"kind_filter": func(kind: String) -> bool: return kind == "gold",
					"supports": func(kind: String, screen_wide: bool) -> bool: return kind == "gold" and not screen_wide,
					"spawn":
					func(
						center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
					) -> bool:
						callable_calls.append(
							{
								"center": center,
								"kind": kind,
								"draw_size": draw_size,
								"max_size": max_size,
								"base_size": base_size,
								"duration": duration,
								"intensity": intensity,
								"screen_wide": screen_wide
							}
						)
						return true,
				},
			]
		}
	)
	if not router.supports_replay_impact("gold", false):
		return "Expected router to report support for callable replay routes."
	if router.supports_replay_impact("gold", true):
		return "Expected callable route support gate to receive screen-wide flag."
	if not router.spawn_replay_impact(Vector2(10, 20), "gold", Vector2(30, 40), 40.0, 90.0, 0.7, 3, false):
		return "Expected callable replay route to handle after presenter declines."
	if presenter.spawn_calls.size() != 1 or callable_calls.size() != 1:
		return "Expected router to try presenter route before callable fallback."
	return ""


func _test_combat_max_vfx_replay_route_policy_uses_explicit_status_availability() -> String:
	var availability_state := {"status_available": true}
	var policy = COMBAT_MAX_VFX_REPLAY_ROUTE_POLICY_SCRIPT.new()
	policy.bind({"status_available": func() -> bool: return bool(availability_state["status_available"])})
	if policy.armor_fallback_available():
		return "Expected armor fallback to stay disabled while status availability is true."
	availability_state["status_available"] = false
	if not policy.armor_fallback_available():
		return "Expected armor fallback to enable when explicit status availability is false."
	return ""


func _test_combat_max_vfx_replay_route_policy_default_route_contract() -> String:
	var fallback_presenter := FakeReplayFallbackPresenter.new()
	var policy = COMBAT_MAX_VFX_REPLAY_ROUTE_POLICY_SCRIPT.new()
	policy.bind({"status_available": false})
	var routes := policy.default_routes(
		{
			"status_presenter": FakeReplayRoutePresenter.new("status"),
			"status_available": true,
			"elemental_presenter": FakeReplayRoutePresenter.new("elemental"),
			"elemental_available": true,
			"should_use_elemental": func(kind: String) -> bool: return kind == "fire",
			"pack_presenter": FakeReplayRoutePresenter.new("pack"),
			"pack_available": true,
		},
		fallback_presenter,
		func(kind: String) -> bool: return kind == "armor"
	)
	if routes.size() != policy.DEFAULT_ROUTE_IDS.size():
		return "Expected policy default route count to match the explicit route id list."
	for index in range(policy.DEFAULT_ROUTE_IDS.size()):
		if String(routes[index].get("id", "")) != policy.DEFAULT_ROUTE_IDS[index]:
			return "Expected default replay route order to preserve %s at index %d." % [policy.DEFAULT_ROUTE_IDS[index], index]
	if not policy.route_supports(routes[0], "armor", false):
		return "Expected armor fallback route to support armor through its fallback spawn callable."
	if policy.route_supports(routes[0], "fire", false):
		return "Expected armor fallback route to reject non-armor kinds."
	if not policy.route_supports(routes[4], "unmapped", true):
		return "Expected lightweight fallback route to remain the final catch-all."
	return ""


func _test_combat_max_vfx_replay_router_default_armor_fallback_precedes_presenter_routes() -> String:
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	var fallback_presenter := FakeReplayFallbackPresenter.new()
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	router.bind(
		{
			"fallback_presenter": fallback_presenter,
			"status_presenter": status_presenter,
			"status_available": false,
			"elemental_presenter": elemental_presenter,
			"elemental_available": true,
			"should_use_elemental": func(_kind: String) -> bool: return true,
			"pack_presenter": pack_presenter,
			"pack_available": true,
		}
	)
	if not router.spawn_replay_impact(Vector2(10, 20), "armor", Vector2(30, 40), 40.0, 90.0, 0.7, 3, false):
		return "Expected default armor replay fallback to handle before presenter routes when status is unavailable."
	if fallback_presenter.bind_calls != 1 or fallback_presenter.armor_calls.size() != 1:
		return "Expected router to bind and call the fallback presenter armor surface."
	if not status_presenter.spawn_calls.is_empty() or not elemental_presenter.spawn_calls.is_empty() or not pack_presenter.spawn_calls.is_empty():
		return "Expected default armor fallback to precede presenter routes."
	return ""


func _test_combat_max_vfx_replay_router_default_lightweight_fallback_is_final_catch_all() -> String:
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	var fallback_presenter := FakeReplayFallbackPresenter.new()
	status_presenter.spawn_result = false
	elemental_presenter.spawn_result = false
	pack_presenter.spawn_result = false
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	router.bind(
		{
			"fallback_presenter": fallback_presenter,
			"status_presenter": status_presenter,
			"status_available": true,
			"elemental_presenter": elemental_presenter,
			"elemental_available": true,
			"should_use_elemental": func(kind: String) -> bool: return kind == "fire",
			"pack_presenter": pack_presenter,
			"pack_available": true,
		}
	)
	if not router.spawn_replay_impact(Vector2(10, 20), "gold", Vector2(30, 40), 40.0, 90.0, 0.7, 3, true):
		return "Expected default lightweight fallback to handle after presenter routes decline."
	if status_presenter.spawn_calls.size() != 1 or not elemental_presenter.spawn_calls.is_empty() or pack_presenter.spawn_calls.size() != 1:
		return "Expected router to try available matching presenter routes before lightweight fallback."
	if fallback_presenter.lightweight_calls.size() != 1 or not fallback_presenter.armor_calls.is_empty():
		return "Expected lightweight fallback to be the final catch-all route."
	return ""


func _test_combat_max_vfx_replay_router_armor_fallback_uses_status_availability_not_presenter_order() -> String:
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	var fallback_presenter := FakeReplayFallbackPresenter.new()
	var router = COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT.new()
	router.bind(
		{
			"fallback_presenter": fallback_presenter,
			"status_presenter": status_presenter,
			"status_available": true,
			"elemental_presenter": elemental_presenter,
			"elemental_available": false,
			"should_use_elemental": func(_kind: String) -> bool: return true,
			"pack_presenter": pack_presenter,
			"pack_available": false,
		}
	)
	if not router.spawn_replay_impact(Vector2(10, 20), "armor", Vector2(30, 40), 40.0, 90.0, 0.7, 3, false):
		return "Expected status route to handle armor when explicit status availability is true."
	if fallback_presenter.armor_calls.size() != 0:
		return "Expected armor fallback to stay gated by explicit status availability."
	if status_presenter.spawn_calls.size() != 1:
		return "Expected status presenter to receive armor when status is available."
	return ""


func _test_combat_max_vfx_replay_fallback_presenter_armor_contract() -> String:
	var armor_calls: Array[Dictionary] = []
	var light_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"kind_colors": func(_kind: String) -> Dictionary: return {"core": Color(0.2, 0.4, 0.8, 1.0)},
			"armor_grid_snap_spawner":
			func(center: Vector2, radius: float, duration: float, intensity: int) -> void:
				armor_calls.append({"center": center, "radius": radius, "duration": duration, "intensity": intensity}),
			"light_spawner":
			func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
				light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
		}
	)
	if not presenter.spawn_armor_replay_fallback(Vector2(5, 6), "armor", Vector2(20, 20), 80.0, 100.0, 0.9, 4, false):
		return "Expected armor replay fallback presenter to spawn when required callbacks are bound."
	if armor_calls.size() != 1 or light_calls.size() != 1:
		return "Expected armor replay fallback to emit grid snap and light."
	if not is_equal_approx(float(armor_calls[0]["radius"]), 74.0):
		return "Expected armor grid snap radius to preserve base-size scaling."
	if not is_equal_approx(float(light_calls[0]["energy"]), 3.7):
		return "Expected armor light energy to preserve intensity scaling."
	return ""


func _test_combat_max_vfx_replay_fallback_presenter_lightweight_contract() -> String:
	var light_calls: Array[Dictionary] = []
	var flipbook_calls: Array[Dictionary] = []
	var burst_calls: Array[Dictionary] = []
	var screen_wide_calls: Array[Dictionary] = []
	var coin_calls: Array[Dictionary] = []
	var presenter = COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"kind_colors": func(_kind: String) -> Dictionary: return {"accent": Color(1.0, 0.8, 0.2, 1.0), "core": Color(1.0, 0.6, 0.1, 1.0)},
			"impact_key": func(kind: String) -> String: return "impact_%s" % kind,
			"mist_key": func(kind: String) -> String: return "mist_%s" % kind,
			"light_spawner":
			func(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
				light_calls.append({"center": center, "color": color, "energy": energy, "radius": radius, "lifetime": lifetime}),
			"flipbook_spawner":
			func(
				key: String,
				center: Vector2,
				draw_size: Vector2,
				lifetime: float,
				color: Color,
				delay: float,
				move_offset: Vector2,
				target_scale: float,
				z: float,
				rotation: float
			) -> void:
				flipbook_calls.append(
					{
						"key": key,
						"center": center,
						"draw_size": draw_size,
						"lifetime": lifetime,
						"color": color,
						"delay": delay,
						"move_offset": move_offset,
						"target_scale": target_scale,
						"z": z,
						"rotation": rotation
					}
				),
			"burst_particles_spawner":
			func(kind: String, center: Vector2, max_size: float, lifetime: float, intensity: int) -> void:
				burst_calls.append({"kind": kind, "center": center, "max_size": max_size, "lifetime": lifetime, "intensity": intensity}),
			"screen_wide_spawner":
			func(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
				screen_wide_calls.append({"kind": kind, "center": center, "lifetime": lifetime, "intensity": intensity}),
			"coin_rain_spawner":
			func(center: Vector2, max_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
				coin_calls.append({"center": center, "max_size": max_size, "lifetime": lifetime, "intensity": intensity, "screen_wide": screen_wide}),
		}
	)
	if not presenter.spawn_lightweight_replay_fallback(Vector2(5, 6), "gold", Vector2(20, 20), 80.0, 100.0, 0.9, 4, true):
		return "Expected lightweight replay fallback presenter to spawn when required callbacks are bound."
	if light_calls.size() != 1 or flipbook_calls.size() != 3:
		return "Expected lightweight fallback to emit light and three flipbook layers."
	if String(flipbook_calls[0]["key"]) != "impact_gold" or String(flipbook_calls[2]["key"]) != "mist_gold":
		return "Expected lightweight fallback to use injected impact and mist keys."
	if burst_calls.size() != 1 or screen_wide_calls.size() != 1 or coin_calls.size() != 1:
		return "Expected lightweight fallback to keep optional burst, screen-wide, and gold coin effects."
	if bool(coin_calls[0]["screen_wide"]):
		return "Expected gold coin fallback to preserve the legacy non-screen-wide coin flag."
	return ""


func _test_combat_max_vfx_overlay_routes_replay_to_status_presenter() -> String:
	var fixture := _replay_route_overlay_fixture()
	var overlay := fixture["overlay"] as FakeReplayRouteOverlay
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	elemental_presenter.supports_result = false
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	pack_presenter.supports_result = false
	overlay._status_recipe_presenter = status_presenter
	overlay._elemental_recipe_presenter = elemental_presenter
	overlay._pack_recipe_presenter = pack_presenter
	overlay._bind_replay_impact_router()
	var handled := overlay.spawn_replay_impact(Vector2(540, 960), "fire", Vector2(240, 120), 0.45, 4, 4, false)
	_cleanup_vfx_fixture(fixture)
	if not handled:
		return "Expected overlay replay impact to route through status presenter."
	if status_presenter.spawn_calls.size() != 1:
		return "Expected status presenter replay route to run once."
	if not elemental_presenter.spawn_calls.is_empty() or not pack_presenter.spawn_calls.is_empty():
		return "Expected overlay replay route to stop at status presenter when handled."
	return ""


func _test_combat_max_vfx_overlay_armor_fallback_precedes_pack_route() -> String:
	var fixture := _replay_route_overlay_fixture()
	var overlay := fixture["overlay"] as FakeReplayRouteOverlay
	overlay.force_status_available = false
	overlay.force_pack_available = true
	var status_presenter := FakeReplayRoutePresenter.new("status")
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	overlay._status_recipe_presenter = status_presenter
	overlay._elemental_recipe_presenter = elemental_presenter
	overlay._pack_recipe_presenter = pack_presenter
	overlay._bind_replay_impact_router()
	var handled := overlay.spawn_replay_impact(Vector2(540, 960), "armor", Vector2(240, 120), 0.45, 4, 4, false)
	_cleanup_vfx_fixture(fixture)
	if not handled:
		return "Expected armor replay fallback to handle when status sheets are unavailable."
	if not status_presenter.spawn_calls.is_empty() or not elemental_presenter.spawn_calls.is_empty() or not pack_presenter.spawn_calls.is_empty():
		return "Expected armor replay fallback to run before presenter-backed routes."
	return ""


func _test_combat_max_vfx_overlay_falls_back_to_pack_route() -> String:
	var fixture := _replay_route_overlay_fixture()
	var overlay := fixture["overlay"] as FakeReplayRouteOverlay
	var status_presenter := FakeReplayRoutePresenter.new("status")
	status_presenter.spawn_result = false
	var elemental_presenter := FakeReplayRoutePresenter.new("elemental")
	elemental_presenter.spawn_result = false
	var pack_presenter := FakeReplayRoutePresenter.new("pack")
	overlay._status_recipe_presenter = status_presenter
	overlay._elemental_recipe_presenter = elemental_presenter
	overlay._pack_recipe_presenter = pack_presenter
	overlay._bind_replay_impact_router()
	var handled := overlay.spawn_replay_impact(Vector2(540, 960), "earth", Vector2(240, 120), 0.45, 4, 4, false)
	_cleanup_vfx_fixture(fixture)
	if not handled:
		return "Expected overlay replay impact to route to pack presenter when status and elemental decline."
	if status_presenter.spawn_calls.size() != 1 or elemental_presenter.spawn_calls.size() != 1:
		return "Expected status and elemental presenters to be attempted before pack fallback."
	if pack_presenter.spawn_calls.size() != 1:
		return "Expected pack presenter replay impact to be invoked."
	return ""
