extends RefCounted
class_name CombatMaxVfxOverlayLifecycleTest

const LIFECYCLE_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay_lifecycle.gd")
const CATALOG_SCRIPT := preload("res://scripts/combat/combat_max_vfx_effect_key_catalog.gd")
const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")


class FakePresenter:
	var bindings: Array[Dictionary] = []

	func bind(dependencies: Dictionary) -> void:
		bindings.append(dependencies)


class FakeCallbacks:
	var _vfx_layer := Control.new()
	var _timer_owner := Node.new()

	func _init() -> void:
		_vfx_layer.size = Vector2(640, 360)

	func vfx_layer_size() -> Vector2:
		return _vfx_layer.size


class FakeLifecycleHarness:
	var callbacks := FakeCallbacks.new()
	var _flipbook_presenter := FakePresenter.new()
	var _imported_scene_presenter := FakePresenter.new()
	var _sheet_flipbook_presenter := FakePresenter.new()
	var _pack_scene_presenter := FakePresenter.new()
	var _elemental_scene_presenter := FakePresenter.new()
	var _fire_ambient_presenter := FakePresenter.new()
	var _fire_impact_presenter := FakePresenter.new()
	var _fire_attack_presenter := FakePresenter.new()
	var _fire_recipe_presenter := FakePresenter.new()
	var _ice_recipe_presenter := FakePresenter.new()
	var _earth_recipe_presenter := FakePresenter.new()
	var _pack_recipe_presenter := FakePresenter.new()
	var _elemental_recipe_presenter := FakePresenter.new()
	var _atmospheric_recipe_presenter := FakePresenter.new()
	var _coin_rain_presenter := FakePresenter.new()
	var _status_recipe_presenter := FakePresenter.new()
	var _mastery_recipe_presenter := FakePresenter.new()
	var _burst_particles_presenter := FakePresenter.new()
	var _screen_wide_presenter := FakePresenter.new()
	var _gpu_particles_presenter := FakePresenter.new()
	var _light_presenter := FakePresenter.new()
	var _cleanup_presenter := FakePresenter.new()
	var _camera_kick_presenter := FakePresenter.new()
	var _projector := FakePresenter.new()
	var _replay_impact_router := FakePresenter.new()
	var _effect_key_catalog: Variant = CATALOG_SCRIPT.new()

	func dependencies() -> Dictionary:
		return {
			"vfx_layer": callbacks._vfx_layer,
			"timer_owner": callbacks._timer_owner,
			"effect_key_catalog": _effect_key_catalog,
			"presenters":
			{
				"flipbook": _flipbook_presenter,
				"imported_scene": _imported_scene_presenter,
				"sheet_flipbook": _sheet_flipbook_presenter,
				"pack_scene": _pack_scene_presenter,
				"elemental_scene": _elemental_scene_presenter,
				"fire_ambient": _fire_ambient_presenter,
				"fire_impact": _fire_impact_presenter,
				"fire_attack": _fire_attack_presenter,
				"fire_recipe": _fire_recipe_presenter,
				"ice_recipe": _ice_recipe_presenter,
				"earth_recipe": _earth_recipe_presenter,
				"pack_recipe": _pack_recipe_presenter,
				"elemental_recipe": _elemental_recipe_presenter,
				"atmospheric_recipe": _atmospheric_recipe_presenter,
				"coin_rain": _coin_rain_presenter,
				"status_recipe": _status_recipe_presenter,
				"mastery_recipe": _mastery_recipe_presenter,
				"burst_particles": _burst_particles_presenter,
				"screen_wide": _screen_wide_presenter,
				"gpu_particles": _gpu_particles_presenter,
				"light": _light_presenter,
				"cleanup": _cleanup_presenter,
				"camera_kick": _camera_kick_presenter,
				"projector": _projector,
				"replay_impact_router": _replay_impact_router,
			},
			"callbacks":
			{
				"vfx_layer_size": callbacks.vfx_layer_size,
			},
		}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("overlay_lifecycle_creates_viewport_and_binds_presenters", _test_overlay_lifecycle_creates_viewport_and_binds_presenters, failures)
	return {
		"passed": failures.is_empty(),
		"total": 1,
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


func _test_overlay_lifecycle_creates_viewport_and_binds_presenters() -> String:
	var harness := FakeLifecycleHarness.new()
	var lifecycle = LIFECYCLE_SCRIPT.new()
	lifecycle.bind(harness.dependencies())
	if not lifecycle.ensure_overlay():
		return "Expected lifecycle to create an overlay for a valid layer."
	var container := harness.callbacks._vfx_layer.get_node_or_null("CombatMaxVfx3DOverlay") as SubViewportContainer
	if container == null:
		return "Expected lifecycle to add the SubViewportContainer to the VFX layer."
	var sub_viewport := container.get_node_or_null("CombatMaxVfxViewport") as SubViewport
	if sub_viewport == null:
		return "Expected lifecycle to create a viewport node."
	var root_3d := sub_viewport.get_node_or_null("CombatMaxVfxRoot3D") as Node3D
	if root_3d == null:
		return "Expected lifecycle to create a root node."
	var camera := root_3d.get_node_or_null("CombatMaxVfxCamera") as Camera3D
	if camera == null:
		return "Expected lifecycle to create viewport, root, and camera nodes."
	if camera.size != 360.0:
		return "Expected camera size to match layer height."
	if harness._mastery_recipe_presenter.bindings.is_empty():
		return "Expected mastery presenter to be rebound."
	var mastery_bind: Dictionary = harness._mastery_recipe_presenter.bindings.back()
	if not mastery_bind.has("kind_for_orb_provider"):
		return "Expected mastery presenter to receive the orb-kind provider."
	if mastery_bind.get("kind_for_orb_provider").call(ORB_TYPE_SCRIPT.Id.FIRE) != "fire":
		return "Expected orb-kind provider to preserve fire routing."
	var replay_bind: Dictionary = harness._replay_impact_router.bindings.back()
	if replay_bind.get("status_presenter") != harness._status_recipe_presenter:
		return "Expected replay router to bind the current status presenter."
	if not replay_bind.has("flipbook_spawner") or not replay_bind.has("light_spawner"):
		return "Expected replay router to keep the armor fallback render spawners."
	harness.callbacks._vfx_layer.queue_free()
	harness.callbacks._timer_owner.queue_free()
	return ""
