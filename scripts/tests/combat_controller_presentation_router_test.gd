extends RefCounted
class_name CombatControllerPresentationRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_presentation_router.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakeVfxPresenter:
	extends RefCounted

	var speed_scales: Array[float] = []
	var spawned_textures: Array[Dictionary] = []

	func set_post_match_vfx_speed_scale(value: float) -> void:
		speed_scales.append(value)

	func spawn_vfx_texture(texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color) -> void:
		(
			spawned_textures
			. append(
				{
					"texture": texture,
					"global_center": global_center,
					"draw_size": draw_size,
					"lifetime": lifetime,
					"modulate_color": modulate_color,
				}
			)
		)


class FakeResolvePresenter:
	extends RefCounted

	func combat_speed_duration(base_seconds: float) -> float:
		return base_seconds * 2.0


class FakeEnemyState:
	extends RefCounted

	var enemy_id := "ember_imp"


class FakeView:
	extends RefCounted

	var refreshed_ids: Array[String] = []

	func refresh_character_portraits(enemy_id: String) -> void:
		refreshed_ids.append(enemy_id)


class FakeOwner:
	extends RefCounted

	const CONTRACT := CombatControllerPresentationRouterTest.CONTRACT

	var _combat_vfx_presenter: Variant = FakeVfxPresenter.new()
	var _resolve_presenter: Variant = FakeResolvePresenter.new()
	var _view: Variant = FakeView.new()
	var _enemy_state: Variant = FakeEnemyState.new()
	var _vfx_target_resolver: Variant = null
	var combat_speed := "normal"

	func _combat_speed_value() -> String:
		return combat_speed


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("applies_vfx_speed_scale_from_combat_speed", _test_applies_vfx_speed_scale_from_combat_speed, failures)
	_run_case("forwards_spawn_and_portrait_refresh", _test_forwards_spawn_and_portrait_refresh, failures)
	_run_case("binds_vfx_target_resolver_and_preserves_speed_duration", _test_binds_vfx_target_resolver_and_preserves_speed_duration, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_applies_vfx_speed_scale_from_combat_speed() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	owner.combat_speed = "slow"
	router.apply_vfx_speed_setting()
	owner.combat_speed = "fast"
	router.apply_vfx_speed_setting()
	owner.combat_speed = "instant"
	router.apply_vfx_speed_setting()
	owner.combat_speed = "normal"
	router.apply_vfx_speed_setting()

	var presenter: FakeVfxPresenter = owner._combat_vfx_presenter
	if presenter.speed_scales != [0.35, 1.0, 2.0, 0.55]:
		return "Expected VFX speed scales to match combat speed settings."
	return ""


func _test_forwards_spawn_and_portrait_refresh() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)
	var texture := ImageTexture.new()

	router.spawn_vfx_texture(texture, Vector2(10, 20), Vector2(30, 40), 0.5, Color.RED)
	router.refresh_character_portraits()

	var presenter: FakeVfxPresenter = owner._combat_vfx_presenter
	var view: FakeView = owner._view
	if presenter.spawned_textures.size() != 1:
		return "Expected spawn_vfx_texture to forward to the combat VFX presenter."
	if presenter.spawned_textures[0].get("global_center") != Vector2(10, 20):
		return "Expected spawn_vfx_texture to preserve the global center."
	if view.refreshed_ids != ["ember_imp"]:
		return "Expected refresh_character_portraits to forward the enemy id."
	return ""


func _test_binds_vfx_target_resolver_and_preserves_speed_duration() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.bind_vfx_target_resolver()

	if owner._vfx_target_resolver == null:
		return "Expected bind_vfx_target_resolver to write the resolver back to the owner."
	if not is_equal_approx(router.combat_speed_duration(0.4), 0.8):
		return "Expected combat_speed_duration to use the resolve presenter when available."
	return ""
