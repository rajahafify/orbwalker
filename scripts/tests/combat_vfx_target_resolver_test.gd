extends RefCounted
class_name CombatVfxTargetResolverTest

const RESOLVER_SCRIPT := preload("res://scripts/combat/combat_vfx_target_resolver.gd")
const VIEW_BINDINGS_SCRIPT := preload("res://scripts/combat/combat_view_vfx_bindings.gd")


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


class FakePlayerHudPresenter:
	extends RefCounted

	var requested_targets: Array = []
	var requested_sizes: Array = []

	func vfx_target_global(node_key: String, vertical_bias: float) -> Vector2:
		requested_targets.append([node_key, vertical_bias])
		return Vector2(12, 34)

	func vfx_size(node_key: String) -> Vector2:
		requested_sizes.append(node_key)
		return Vector2(56, 78)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("replay_targets_scale_from_view_metrics", _test_replay_targets_scale_from_view_metrics, failures)
	_run_case("enemy_result_impact_size_uses_fire_screen_wide_size", _test_enemy_result_impact_size_uses_fire_screen_wide_size, failures)
	_run_case("view_vfx_bindings_delegate_targets_and_sizes", _test_view_vfx_bindings_delegate_targets_and_sizes, failures)
	_run_case("view_vfx_bindings_build_presenter_dictionaries", _test_view_vfx_bindings_build_presenter_dictionaries, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_view_vfx_bindings_delegate_targets_and_sizes() -> String:
	var hud := FakePlayerHudPresenter.new()
	var target := VIEW_BINDINGS_SCRIPT.presenter_target_global(hud, "_enemy_portrait", 0.35)
	if target != Vector2(12, 34):
		return "Expected presenter target helper to return HUD presenter target."
	if hud.requested_targets != [["_enemy_portrait", 0.35]]:
		return "Expected presenter target helper to forward node key and bias."
	var size := VIEW_BINDINGS_SCRIPT.presenter_size(hud, "_player_hp_bar")
	if size != Vector2(56, 78):
		return "Expected presenter size helper to return HUD presenter size."
	if hud.requested_sizes != ["_player_hp_bar"]:
		return "Expected presenter size helper to forward node key."
	if VIEW_BINDINGS_SCRIPT.presenter_target_global(null, "_enemy_portrait", 0.5) != Vector2.ZERO:
		return "Expected missing presenter target to return zero."
	return ""


func _test_view_vfx_bindings_build_presenter_dictionaries() -> String:
	var layer := Control.new()
	layer.position = Vector2(10, 20)
	layer.size = Vector2(300, 400)
	var board := Control.new()
	board.position = Vector2(30, 40)
	board.size = Vector2(100, 120)
	var panel := Control.new()
	panel.position = Vector2(1, 2)
	panel.size = Vector2(10, 20)
	var cards := Control.new()
	var timer_owner := Node.new()
	var bindings: Dictionary = VIEW_BINDINGS_SCRIPT.vfx_presenter_bindings(
		layer, "fallback_visuals", "fallback_hud", cards, panel, null, "override_hud", timer_owner
	)
	if bindings.get("visual_registry") != "fallback_visuals" or bindings.get("player_loadout_hud") != "override_hud":
		layer.free()
		board.free()
		panel.free()
		cards.free()
		timer_owner.free()
		return "Expected VFX presenter bindings to resolve override/fallback dependencies."
	if bindings.get("vfx_layer") != layer or bindings.get("elemental_mastery_cards") != cards:
		layer.free()
		board.free()
		panel.free()
		cards.free()
		timer_owner.free()
		return "Expected VFX presenter bindings to include scene targets."
	var board_center: Vector2 = VIEW_BINDINGS_SCRIPT.board_target_global(board, panel)
	if board_center != Vector2(80, 100):
		layer.free()
		board.free()
		panel.free()
		cards.free()
		timer_owner.free()
		return "Expected board target helper to use board center."
	var fullscreen_size: Vector2 = VIEW_BINDINGS_SCRIPT.board_fullscreen_size(layer, board, panel)
	if fullscreen_size != Vector2(300, 400):
		layer.free()
		board.free()
		panel.free()
		cards.free()
		timer_owner.free()
		return "Expected fullscreen helper to include VFX layer extent."
	layer.free()
	board.free()
	panel.free()
	cards.free()
	timer_owner.free()
	return ""
