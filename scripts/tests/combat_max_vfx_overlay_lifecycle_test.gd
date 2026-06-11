extends RefCounted
class_name CombatMaxVfxOverlayLifecycleTest

const LIFECYCLE_SCRIPT := preload("res://scripts/combat/combat_max_vfx_overlay_lifecycle.gd")
const CATALOG_SCRIPT := preload("res://scripts/combat/combat_max_vfx_effect_key_catalog.gd")
const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")


class FakePresenter:
	var bindings: Array[Dictionary] = []

	func bind(dependencies: Dictionary) -> void:
		bindings.append(dependencies)


class FakeOwner:
	var _vfx_layer := Control.new()
	var _visual_registry: Variant = null
	var _timer_owner := Node.new()
	var _container: SubViewportContainer
	var _sub_viewport: SubViewport
	var _root_3d: Node3D
	var _camera: Camera3D
	var _ambient_light: DirectionalLight3D
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

	func _init() -> void:
		_vfx_layer.size = Vector2(640, 360)

	func _vfx_layer_size() -> Vector2:
		return _vfx_layer.size


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
	var owner := FakeOwner.new()
	var lifecycle = LIFECYCLE_SCRIPT.new()
	if not lifecycle.ensure_overlay(owner):
		return "Expected lifecycle to create an overlay for a valid layer."
	if owner._vfx_layer.get_node_or_null("CombatMaxVfx3DOverlay") == null:
		return "Expected lifecycle to add the SubViewportContainer to the VFX layer."
	if owner._sub_viewport == null or owner._root_3d == null or owner._camera == null:
		return "Expected lifecycle to create viewport, root, and camera nodes."
	if owner._camera.size != 360.0:
		return "Expected camera size to match layer height."
	if owner._mastery_recipe_presenter.bindings.is_empty():
		return "Expected mastery presenter to be rebound."
	var mastery_bind: Dictionary = owner._mastery_recipe_presenter.bindings.back()
	if not mastery_bind.has("kind_for_orb_provider"):
		return "Expected mastery presenter to receive the orb-kind provider."
	if mastery_bind.get("kind_for_orb_provider").call(ORB_TYPE_SCRIPT.Id.FIRE) != "fire":
		return "Expected orb-kind provider to preserve fire routing."
	var replay_bind: Dictionary = owner._replay_impact_router.bindings.back()
	if replay_bind.get("status_presenter") != owner._status_recipe_presenter:
		return "Expected replay router to bind the current status presenter."
	if not replay_bind.has("armor_grid_snap_spawner"):
		return "Expected replay router to keep the armor fallback spawner."
	owner._vfx_layer.queue_free()
	owner._timer_owner.queue_free()
	return ""
