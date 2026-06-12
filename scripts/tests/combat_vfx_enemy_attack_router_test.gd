extends RefCounted
class_name CombatVfxEnemyAttackRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_vfx_enemy_attack_router.gd")


class FakeMaxOverlay:
	extends RefCounted

	var cue_handled := false
	var travel_handled := false
	var impact_handled := false
	var cue_calls := 0
	var travel_calls := 0
	var impact_calls := 0

	func spawn_enemy_attack_cue(_source_global: Vector2, _lifetime: float) -> bool:
		cue_calls += 1
		return cue_handled

	func spawn_enemy_attack_travel(_source_global: Vector2, _target_global: Vector2, _lifetime: float) -> bool:
		travel_calls += 1
		return travel_handled

	func spawn_enemy_attack_impact(_target_global: Vector2, _blocked: bool, _amount: int, _lifetime: float) -> bool:
		impact_calls += 1
		return impact_handled


class FakeFallbackPresenter:
	extends RefCounted

	var cue_calls := 0
	var travel_calls := 0
	var block_calls := 0
	var hit_calls := 0

	func spawn_cue(_source_global: Vector2, _lifetime: float) -> void:
		cue_calls += 1

	func spawn_travel(_source_global: Vector2, _target_global: Vector2, _lifetime: float) -> void:
		travel_calls += 1

	func spawn_block_impact(_target_global: Vector2, _lifetime: float) -> void:
		block_calls += 1

	func spawn_hit_impact(_target_global: Vector2, _lifetime: float) -> void:
		hit_calls += 1


class FakeCallbacks:
	extends RefCounted

	var use_max := false
	var replay_calls: Array[Dictionary] = []

	func use_max_combat_vfx() -> bool:
		return use_max

	func spawn_replay_impact(target_global: Vector2, kind: String, draw_size: Vector2, lifetime: float, amount: int) -> void:
		replay_calls.append({"target": target_global, "kind": kind, "draw_size": draw_size, "lifetime": lifetime, "amount": amount})


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("max_overlay_short_circuits_cue_and_travel", _test_max_overlay_short_circuits_cue_and_travel, failures)
	_run_case("fallback_impacts_route_replay_and_presenter", _test_fallback_impacts_route_replay_and_presenter, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_max_overlay_short_circuits_cue_and_travel() -> String:
	var overlay := FakeMaxOverlay.new()
	overlay.cue_handled = true
	overlay.travel_handled = true
	var fallback := FakeFallbackPresenter.new()
	var callbacks := FakeCallbacks.new()
	callbacks.use_max = true
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(
		{"max_vfx_overlay": overlay, "enemy_attack_vfx_presenter": fallback},
		{"use_max_combat_vfx": Callable(callbacks, "use_max_combat_vfx"), "spawn_replay_impact": Callable(callbacks, "spawn_replay_impact")}
	)

	router.spawn_enemy_attack_cue(Vector2(1, 2), 0.2)
	router.spawn_enemy_attack_travel(Vector2(1, 2), Vector2(3, 4), 0.3)

	if overlay.cue_calls != 1 or overlay.travel_calls != 1:
		return "Expected max overlay to receive cue and travel calls."
	if fallback.cue_calls != 0 or fallback.travel_calls != 0:
		return "Expected handled max overlay cue/travel to skip fallback presenter."
	return ""


func _test_fallback_impacts_route_replay_and_presenter() -> String:
	var overlay := FakeMaxOverlay.new()
	var fallback := FakeFallbackPresenter.new()
	var callbacks := FakeCallbacks.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(
		{"max_vfx_overlay": overlay, "enemy_attack_vfx_presenter": fallback},
		{"use_max_combat_vfx": Callable(callbacks, "use_max_combat_vfx"), "spawn_replay_impact": Callable(callbacks, "spawn_replay_impact")}
	)

	router.spawn_enemy_attack_block_impact(Vector2(5, 6), 0.4, 7)
	router.spawn_enemy_attack_hit_impact(Vector2(8, 9), 0.5, 11)

	if fallback.block_calls != 1 or fallback.hit_calls != 1:
		return "Expected block and hit fallback presenter calls."
	if callbacks.replay_calls.size() != 2:
		return "Expected block and hit impacts to emit replay impact calls."
	if callbacks.replay_calls[0].get("kind") != "armor" or callbacks.replay_calls[1].get("kind") != "damage":
		return "Expected block/hit impacts to route armor and damage replay kinds."
	return ""
