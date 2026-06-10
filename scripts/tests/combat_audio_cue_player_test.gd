extends RefCounted
class_name CombatAudioCuePlayerTest

const AUDIO_CUE_PLAYER_SCRIPT := preload("res://scripts/combat/combat_audio_cue_player.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")


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
	_run_case("turn_result_uses_baseline_when_master_disabled", _test_turn_result_uses_baseline_when_master_disabled, failures)
	_run_case("turn_result_respects_elemental_impact_flag", _test_turn_result_respects_elemental_impact_flag, failures)
	_run_case("mastery_effect_maps_known_effects", _test_mastery_effect_maps_known_effects, failures)
	_run_case("baseline_impacts_use_generic_keys_when_juice_disabled", _test_baseline_impacts_use_generic_keys_when_juice_disabled, failures)
	_run_case("elemental_impacts_map_to_distinct_keys", _test_elemental_impacts_map_to_distinct_keys, failures)
	_run_case("elemental_impact_flag_disabled_uses_baseline_keys", _test_elemental_impact_flag_disabled_uses_baseline_keys, failures)
	_run_case("combo_rhythm_flag_escalates_combo_cue", _test_combo_rhythm_flag_escalates_combo_cue, failures)
	_run_case("result_aware_cues_map_to_existing_keys", _test_result_aware_cues_map_to_existing_keys, failures)
	return {
		"passed": failures.is_empty(),
		"total": 10,
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


func _test_delegates_music_and_sfx_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
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
	cue_player.set_game_juice_enabled(true)
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 0}})
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 2}})
	if audio.sfx_keys != ["impact_player_hit"]:
		return "Expected exactly one player-hit impact cue for positive enemy HP damage."
	return ""


func _test_turn_result_uses_baseline_when_master_disabled() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(false)
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 5, "blocked_by_armor": 0}})
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 0, "blocked_by_armor": 3}})
	if audio.sfx_keys != ["hit", "armor"]:
		return "Expected baseline turn result cues with master juice disabled, got %s." % [audio.sfx_keys]
	return ""


func _test_turn_result_respects_elemental_impact_flag() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	var flags := GAME_JUICE_FLAGS_SCRIPT.default_flags()
	flags[GAME_JUICE_FLAGS_SCRIPT.ELEMENT_IMPACT_AUDIO] = false
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
	cue_player.set_game_juice_flags(flags)
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 5, "blocked_by_armor": 0}})
	cue_player.play_turn_result({"enemy_attack_resolution": {"hp_damage": 0, "blocked_by_armor": 3}})
	if audio.sfx_keys != ["hit", "armor"]:
		return "Expected baseline turn result cues with elemental impact audio disabled, got %s." % [audio.sfx_keys]
	return ""


func _test_result_aware_cues_map_to_existing_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
	var flags := GAME_JUICE_FLAGS_SCRIPT.default_flags()
	flags[GAME_JUICE_FLAGS_SCRIPT.COMBO_RHYTHM_PULSE] = false
	cue_player.set_game_juice_flags(flags)
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
	cue_player.set_game_juice_enabled(true)
	cue_player.play_mastery_effect("damage")
	cue_player.play_mastery_effect("heal")
	cue_player.play_mastery_effect("armor")
	cue_player.play_mastery_effect("gold")
	cue_player.play_mastery_effect("unknown")
	if audio.sfx_keys != ["impact_enemy_hit", "impact_heal", "impact_armor", "impact_gold"]:
		return "Expected mastery effects to map to distinct impact SFX cues and ignore unknown effects."
	return ""


func _test_baseline_impacts_use_generic_keys_when_juice_disabled() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.play_impact("fire")
	cue_player.play_impact("ice")
	cue_player.play_impact("earth")
	cue_player.play_impact("heal")
	cue_player.play_impact("armor")
	cue_player.play_impact("gold")
	if audio.sfx_keys != ["hit", "hit", "hit", "heal", "armor", "gold"]:
		return "Expected disabled game juice to use baseline generic impact SFX keys."
	return ""


func _test_elemental_impacts_map_to_distinct_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
	cue_player.play_impact("fire")
	cue_player.play_impact("ice")
	cue_player.play_impact("earth")
	cue_player.play_impact("nature")
	if audio.sfx_keys != ["impact_fire", "impact_ice", "impact_earth", "impact_earth"]:
		return "Expected fire, ice, earth, and nature impact cues to map to audible elemental SFX keys."
	return ""


func _test_elemental_impact_flag_disabled_uses_baseline_keys() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	var flags := GAME_JUICE_FLAGS_SCRIPT.default_flags()
	flags[GAME_JUICE_FLAGS_SCRIPT.ELEMENT_IMPACT_AUDIO] = false
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
	cue_player.set_game_juice_flags(flags)
	cue_player.play_impact("fire")
	cue_player.play_impact("ice")
	cue_player.play_impact("earth")
	cue_player.play_impact("heal")
	cue_player.play_impact("armor")
	cue_player.play_impact("gold")
	if audio.sfx_keys != ["hit", "hit", "hit", "heal", "armor", "gold"]:
		return "Expected disabled elemental impact audio flag to use baseline keys even when master juice is enabled."
	return ""


func _test_combo_rhythm_flag_escalates_combo_cue() -> String:
	var audio := FakeAudioManager.new()
	var cue_player: Variant = AUDIO_CUE_PLAYER_SCRIPT.new()
	cue_player.bind(null, audio)
	cue_player.set_game_juice_enabled(true)
	cue_player.play_match_clear(2)
	cue_player.play_match_clear(3)
	cue_player.play_match_clear(4)
	if audio.sfx_keys != ["combo", "combo_rhythm_mid", "combo_rhythm_high"]:
		return "Expected combo rhythm flag to escalate combo SFX by combo value."
	return ""
