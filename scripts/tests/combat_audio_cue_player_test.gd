extends RefCounted
class_name CombatAudioCuePlayerTest

const AUDIO_CUE_PLAYER_SCRIPT := preload("res://scripts/combat/combat_audio_cue_player.gd")


class FakeAudioManager:
	extends RefCounted

	var music_keys: Array[String] = []
	var sfx_keys: Array[String] = []

	func play_music(key: String) -> void:
		music_keys.append(key)

	func play_sfx(key: String) -> void:
		sfx_keys.append(key)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("delegates_music_and_sfx_keys", _test_delegates_music_and_sfx_keys, failures)
	_run_case("turn_result_hit_only_when_enemy_damages_player", _test_turn_result_hit_only_when_enemy_damages_player, failures)
	_run_case("mastery_effect_maps_known_effects", _test_mastery_effect_maps_known_effects, failures)
	_run_case("elemental_impacts_map_to_distinct_keys", _test_elemental_impacts_map_to_distinct_keys, failures)
	_run_case("result_aware_cues_map_to_existing_keys", _test_result_aware_cues_map_to_existing_keys, failures)
	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_delegates_music_and_sfx_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_music("combat")
	cue_player.play_sfx("swap")
	if audio.music_keys != ["combat"]:
		return "Expected combat music key to be delegated."
	if audio.sfx_keys != ["swap"]:
		return "Expected swap SFX key to be delegated."
	return ""


func _test_turn_result_hit_only_when_enemy_damages_player() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 0}})
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 2}})
	if audio.sfx_keys != ["impact_player_hit"]:
		return "Expected exactly one player-hit impact cue for positive enemy HP damage."
	return ""


func _test_result_aware_cues_map_to_existing_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_match_clear(1)
	cue_player.play_match_clear(3)
	cue_player.play_enemy_attack_result({"blocked_by_armor": 4, "hp_damage": 0})
	cue_player.play_enemy_attack_result({"blocked_by_armor": 0, "hp_damage": 2})
	if audio.sfx_keys != ["match", "combo", "impact_player_block", "impact_player_hit"]:
		return "Expected result-aware cues to use distinct player impact keys."
	return ""


func _test_mastery_effect_maps_known_effects() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_mastery_effect("damage")
	cue_player.play_mastery_effect("heal")
	cue_player.play_mastery_effect("armor")
	cue_player.play_mastery_effect("gold")
	cue_player.play_mastery_effect("unknown")
	if audio.sfx_keys != ["impact_enemy_hit", "impact_heal", "impact_armor", "impact_gold"]:
		return "Expected mastery effects to map to distinct impact SFX cues and ignore unknown effects."
	return ""


func _test_elemental_impacts_map_to_distinct_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_impact("fire")
	cue_player.play_impact("ice")
	cue_player.play_impact("earth")
	cue_player.play_impact("nature")
	if audio.sfx_keys != ["impact_fire", "impact_ice", "impact_earth", "impact_earth"]:
		return "Expected fire, ice, earth, and nature impact cues to map to audible elemental SFX keys."
	return ""
