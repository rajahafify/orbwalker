extends RefCounted
class_name CombatVfxTargetResolverTest

const RESOLVER_SCRIPT := preload("res://scripts/combat/combat_vfx_target_resolver.gd")


class FakeView:
	extends RefCounted

	var enemy_target := Vector2(100, 200)
	var player_target := Vector2(300, 400)
	var player_hp_target := Vector2(310, 420)
	var armor_target := Vector2(500, 600)
	var fullscreen_size := Vector2(800, 1000)
	var hp_bar_size := Vector2(600, 80)
	var enemy_size := Vector2(900, 420)

	func enemy_vfx_target_global(_anchor: float) -> Vector2:
		return enemy_target

	func player_vfx_target_global(_anchor: float) -> Vector2:
		return player_target

	func player_hp_bar_vfx_target_global(_anchor: float) -> Vector2:
		return player_hp_target

	func board_vfx_target_global() -> Vector2:
		return armor_target

	func board_fullscreen_vfx_size() -> Vector2:
		return fullscreen_size

	func player_hp_bar_vfx_size() -> Vector2:
		return hp_bar_size

	func enemy_vfx_size() -> Vector2:
		return enemy_size


class FakeVfxPresenter:
	extends RefCounted

	var screen_wide := true
	var size_scale := 3.0

	func replay_result_is_screen_wide(kind: String, amount: int) -> bool:
		return kind == "fire" and amount >= 10 and screen_wide

	func result_vfx_size_scale(kind: String, _amount: int) -> float:
		return size_scale if kind == "fire" else 1.0


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("replay_targets_scale_from_view_metrics", _test_replay_targets_scale_from_view_metrics, failures)
	_run_case("enemy_result_impact_size_uses_fire_screen_wide_size", _test_enemy_result_impact_size_uses_fire_screen_wide_size, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_replay_targets_scale_from_view_metrics() -> String:
	var view := FakeView.new()
	var resolver: Variant = RESOLVER_SCRIPT.new()
	resolver.bind({"view": view, "vfx_presenter": FakeVfxPresenter.new()})
	var targets: Dictionary = resolver.replay_targets()
	var hp_size: Vector2 = targets.get("player_hp_impact_size", Vector2.ZERO)
	var armor_size: Vector2 = targets.get("armor_impact_size", Vector2.ZERO)
	if targets.get("enemy_target") != view.enemy_target or targets.get("player_target") != view.player_target:
		return "Expected replay targets to use view VFX anchors."
	if targets.get("player_hp_target") != view.player_hp_target or targets.get("armor_target") != view.armor_target:
		return "Expected support targets to use HP bar and board anchors."
	if not is_equal_approx(hp_size.x, 348.0) or not is_equal_approx(hp_size.y, 130.0):
		return "Expected HP impact size to clamp from HP bar metrics."
	if not is_equal_approx(armor_size.x, 272.0) or not is_equal_approx(armor_size.y, 272.0):
		return "Expected armor impact size to derive from fullscreen extent."
	return ""


func _test_enemy_result_impact_size_uses_fire_screen_wide_size() -> String:
	var view := FakeView.new()
	var vfx := FakeVfxPresenter.new()
	var resolver: Variant = RESOLVER_SCRIPT.new()
	resolver.bind({"view": view, "vfx_presenter": vfx})
	var fallback := Vector2(84, 84)
	var fire_size: Vector2 = resolver.enemy_result_impact_size(OrbType.Id.FIRE, fallback, 12)
	if not is_equal_approx(fire_size.x, 300.0) or not is_equal_approx(fire_size.y, 140.0):
		return "Expected fire screen-wide impact to use enemy size divided by VFX scale."
	var ice_size: Vector2 = resolver.enemy_result_impact_size(OrbType.Id.ICE, fallback, 12)
	if ice_size != fallback:
		return "Expected non-fire impacts to keep fallback size."
	vfx.screen_wide = false
	var disabled_size: Vector2 = resolver.enemy_result_impact_size(OrbType.Id.FIRE, fallback, 12)
	if disabled_size != fallback:
		return "Expected non-screen-wide fire impacts to keep fallback size."
	return ""
