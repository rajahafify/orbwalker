extends RefCounted
class_name CombatVfxReplayResultPolicyTest

const POLICY_SCRIPT := preload("res://scripts/combat/combat_vfx_replay_result_policy.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("profile_scales_by_tier_and_speed", _test_profile_scales_by_tier_and_speed, failures)
	_run_case(
		"kind_aliases_and_screen_wide_thresholds_match_presenter_contract", _test_kind_aliases_and_screen_wide_thresholds_match_presenter_contract, failures
	)
	_run_case("impact_colors_brighten_by_tier", _test_impact_colors_brighten_by_tier, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_profile_scales_by_tier_and_speed() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	var medium: Dictionary = policy.replay_result_impact_profile("fire", 6, Vector2(100, 100), 1.0, 0.5)
	var high: Dictionary = policy.replay_result_impact_profile("fire", 10, Vector2(100, 100), 1.0, 0.5)

	if int(medium.get("tier")) != 1 or medium.get("draw_size") != Vector2(185, 185):
		return "Expected medium fire profile to use tier-1 size scale."
	if int(high.get("tier")) != 2 or high.get("draw_size") != Vector2(225, 225):
		return "Expected high fire profile to use tier-2 size scale."
	if not is_equal_approx(float(high.get("lifetime")), 2.48):
		return "Expected profile lifetime to apply tier and speed scale."
	return ""


func _test_kind_aliases_and_screen_wide_thresholds_match_presenter_contract() -> String:
	var policy: Variant = POLICY_SCRIPT.new()

	if policy.result_vfx_kind_key("heal") != "heart":
		return "Expected heal to normalize to heart."
	if policy.result_vfx_kind_key("block") != "armor":
		return "Expected block to normalize to armor."
	if policy.replay_result_is_screen_wide("fire", 15):
		return "Expected fire amount below signature threshold to stay local."
	if not policy.replay_result_is_screen_wide("fire", 16):
		return "Expected fire signature threshold to be screen-wide."
	if not policy.replay_result_is_screen_wide("gold", 10):
		return "Expected gold signature threshold to be screen-wide."
	if policy.replay_result_is_screen_wide("heart", 3):
		return "Expected low heart result to stay local."
	return ""


func _test_impact_colors_brighten_by_tier() -> String:
	var policy: Variant = POLICY_SCRIPT.new()
	var base: Color = policy.result_impact_modulate_color("damage", 1)
	var signature: Color = policy.result_impact_modulate_color("damage", 3)

	if signature.r < base.r or signature.g < base.g or signature.b < base.b:
		return "Expected signature-tier damage color to be at least as bright as tier 1."
	if not is_equal_approx(base.a, 0.98):
		return "Expected tier-1 alpha to match result VFX profile."
	if not is_equal_approx(signature.a, 1.0):
		return "Expected signature-tier alpha to match result VFX profile."
	return ""
