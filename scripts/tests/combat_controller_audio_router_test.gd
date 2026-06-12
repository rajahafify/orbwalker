extends RefCounted
class_name CombatControllerAudioRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_audio_router.gd")
const RUNTIME_BINDER_SCRIPT := preload("res://scripts/combat/combat_controller_runtime_binder.gd")


class FakeCuePlayer:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func bind(_host: Node = null, _audio_manager_override: Variant = null) -> void:
		calls.append({"method": "bind"})

	func set_game_juice_enabled(enabled: bool) -> void:
		calls.append({"method": "set_game_juice_enabled", "enabled": enabled})

	func set_game_juice_flags(flags: Dictionary) -> void:
		calls.append({"method": "set_game_juice_flags", "flags": flags})

	func play_turn_result(turn_log: Dictionary) -> void:
		calls.append({"method": "play_turn_result", "turn_log": turn_log})

	func play_mastery_effect(effect_kind: String) -> void:
		calls.append({"method": "play_mastery_effect", "effect_kind": effect_kind})

	func play_impact(impact_kind: String, target: String = "enemy") -> void:
		calls.append({"method": "play_impact", "impact_kind": impact_kind, "target": target})

	func play_enemy_attack_result(result: Dictionary) -> void:
		calls.append({"method": "play_enemy_attack_result", "result": result})

	func play_music(key: String) -> void:
		calls.append({"method": "play_music", "key": key})

	func play_sfx(key: String) -> void:
		calls.append({"method": "play_sfx", "key": key})

	func play_match_clear(combo_value: int = 1) -> void:
		calls.append({"method": "play_match_clear", "combo_value": combo_value})


class FakeLegacyCuePlayer:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func play_mastery_effect(effect_kind: String) -> void:
		calls.append({"method": "play_mastery_effect", "effect_kind": effect_kind})

	func play_turn_result(turn_log: Dictionary) -> void:
		calls.append({"method": "play_turn_result", "turn_log": turn_log})

	func play_sfx(key: String) -> void:
		calls.append({"method": "play_sfx", "key": key})


class FakeRunState:
	extends RefCounted

	func game_juice_enabled() -> bool:
		return true

	func game_juice_flags() -> Dictionary:
		return {"element_impact_audio": true}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("routes_audio_calls_to_cue_player", _test_routes_audio_calls_to_cue_player, failures)
	_run_case("keeps_legacy_fallbacks", _test_keeps_legacy_fallbacks, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_routes_audio_calls_to_cue_player() -> String:
	var cue_player := FakeCuePlayer.new()
	var router: Variant = ROUTER_SCRIPT.new()
	(
		router
		. bind(
			{
				"cue_player": cue_player,
				"cue_player_script": FakeCuePlayer,
				"runtime_binder": RUNTIME_BINDER_SCRIPT,
				"host": null,
				"run_state": FakeRunState.new(),
			}
		)
	)

	router.play_music("combat")
	router.play_sfx("swap")
	router.play_turn_result_sfx({"enemy_attack_resolution": {"hp_damage": 1}})
	router.play_mastery_effect_sfx("heal")
	router.play_impact_sfx("fire", "enemy")
	router.play_enemy_attack_result_sfx({"blocked_by_armor": 2})
	router.play_match_clear(3)

	var methods := _methods(cue_player.calls)
	for expected in ["play_music", "play_sfx", "play_turn_result", "play_mastery_effect", "play_impact", "play_enemy_attack_result", "play_match_clear"]:
		if not methods.has(expected):
			return "Expected router to forward %s to the cue player." % expected
	return ""


func _test_keeps_legacy_fallbacks() -> String:
	var cue_player := FakeLegacyCuePlayer.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind({"cue_player": cue_player})

	router.play_impact_sfx("armor", "player")
	router.play_enemy_attack_result_sfx({"hp_damage": 2})
	router.play_match_clear(2)

	if cue_player.calls[0].get("method") != "play_mastery_effect":
		return "Expected impact fallback to call play_mastery_effect on legacy cue players."
	if cue_player.calls[1].get("method") != "play_turn_result":
		return "Expected enemy-attack fallback to wrap result in a turn log."
	if cue_player.calls[2].get("method") != "play_sfx" or cue_player.calls[2].get("key") != "combo":
		return "Expected match-clear fallback to play combo SFX."
	return ""


func _methods(calls: Array[Dictionary]) -> Array[String]:
	var methods: Array[String] = []
	for call in calls:
		methods.append(String(call.get("method", "")))
	return methods
