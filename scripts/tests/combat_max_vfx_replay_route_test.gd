extends RefCounted
class_name CombatMaxVfxReplayRouteTest

const COMBAT_MAX_VFX_PACK_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_pack_recipe_presenter.gd")
const COMBAT_MAX_VFX_ELEMENTAL_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_elemental_recipe_presenter.gd")
const COMBAT_MAX_VFX_STATUS_RECIPE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_status_recipe_presenter.gd")
const COMBAT_MAX_VFX_REPLAY_IMPACT_ROUTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_impact_router.gd")
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
	_run_case("combat_max_vfx_overlay_routes_replay_to_status_presenter", _test_combat_max_vfx_overlay_routes_replay_to_status_presenter, failures)
	_run_case("combat_max_vfx_overlay_falls_back_to_pack_route", _test_combat_max_vfx_overlay_falls_back_to_pack_route, failures)
	_run_case("combat_max_vfx_overlay_armor_fallback_precedes_pack_route", _test_combat_max_vfx_overlay_armor_fallback_precedes_pack_route, failures)
	return {
		"passed": failures.is_empty(),
		"total": 9,
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
