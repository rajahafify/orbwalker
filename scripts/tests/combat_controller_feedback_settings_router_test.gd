extends RefCounted
class_name CombatControllerFeedbackSettingsRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_feedback_settings_router.gd")
const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")


class FakePresentationRouter:
	extends RefCounted

	var applied_vfx_speed_calls := 0

	func apply_vfx_speed_setting() -> void:
		applied_vfx_speed_calls += 1


class FakeSettingsTarget:
	extends RefCounted

	var calls: Dictionary = {}

	func set_refill_overshoot_enabled(value: bool) -> void:
		calls["refill_overshoot"] = value

	func set_post_match_vfx_quality(value: String) -> void:
		calls["vfx_quality"] = value

	func set_reduced_motion_enabled(value: bool) -> void:
		calls["reduced_motion"] = value

	func set_game_juice_enabled(value: bool) -> void:
		calls["game_juice"] = value

	func set_game_juice_flags(value: Dictionary) -> void:
		calls["game_juice_flags"] = value.duplicate(true)

	func set_enemy_reaction_settings(enabled: bool, reduced_motion: bool) -> void:
		calls["enemy_reaction"] = [enabled, reduced_motion]


class FakeOwner:
	extends RefCounted

	const CONTRACT := CombatControllerFeedbackSettingsRouterTest.CONTRACT

	var _presentation_router: Variant = FakePresentationRouter.new()
	var _board_controller: Variant = FakeSettingsTarget.new()
	var _combat_vfx_presenter: Variant = FakeSettingsTarget.new()
	var _resolve_presenter: Variant = FakeSettingsTarget.new()
	var _combat_audio_cue_player: Variant = FakeSettingsTarget.new()
	var _view: Variant = FakeSettingsTarget.new()

	func _presentation_callback(method_name: String) -> Callable:
		return Callable(_presentation_router, method_name)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("apply_uses_bound_targets", _test_apply_uses_bound_targets, failures)
	return {"passed": failures.is_empty(), "total": 1, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_apply_uses_bound_targets() -> String:
	var owner := FakeOwner.new()

	ROUTER_SCRIPT.apply(owner)

	if owner._presentation_router.applied_vfx_speed_calls != 1:
		return "Expected feedback settings to call the presentation router VFX-speed hook."
	if not owner._board_controller.calls.has("refill_overshoot"):
		return "Expected board controller feedback setting."
	if not owner._combat_vfx_presenter.calls.has("game_juice_flags"):
		return "Expected combat VFX presenter game-juice flags."
	if not owner._resolve_presenter.calls.has("game_juice"):
		return "Expected resolve presenter game-juice setting."
	if not owner._combat_audio_cue_player.calls.has("game_juice_flags"):
		return "Expected audio cue player game-juice flags."
	if not owner._view.calls.has("enemy_reaction"):
		return "Expected view enemy reaction settings."
	return ""
