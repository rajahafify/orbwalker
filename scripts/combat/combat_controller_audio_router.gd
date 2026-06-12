extends RefCounted
class_name CombatControllerAudioRouter

var _cue_player: Variant = null
var _cue_player_script: Variant = null
var _runtime_binder: Variant = null
var _host: Variant = null
var _run_state: Variant = null


func bind(dependencies: Dictionary) -> void:
	_cue_player = dependencies.get("cue_player")
	_cue_player_script = dependencies.get("cue_player_script")
	_runtime_binder = dependencies.get("runtime_binder")
	_host = dependencies.get("host")
	_run_state = dependencies.get("run_state")


func cue_player() -> Variant:
	if _runtime_binder == null or _cue_player_script == null or _run_state == null:
		return _cue_player
	_cue_player = _runtime_binder.bind_audio_cue_player(_cue_player, _cue_player_script, _host, _run_state)
	return _cue_player


func play_turn_result_sfx(turn_log: Dictionary) -> void:
	var player: Variant = cue_player()
	if player != null:
		player.play_turn_result(turn_log)


func play_mastery_effect_sfx(effect_kind: String) -> void:
	var player: Variant = cue_player()
	if player != null:
		player.play_mastery_effect(effect_kind)


func play_impact_sfx(impact_kind: String, target: String = "enemy") -> void:
	var player: Variant = cue_player()
	if player == null:
		return
	if player.has_method("play_impact"):
		player.play_impact(impact_kind, target)
	else:
		player.play_mastery_effect(impact_kind)


func play_enemy_attack_result_sfx(result: Dictionary) -> void:
	var player: Variant = cue_player()
	if player == null:
		return
	if player.has_method("play_enemy_attack_result"):
		player.play_enemy_attack_result(result)
	else:
		player.play_turn_result({"enemy_attack_resolution": result})


func play_music(key: String) -> void:
	var player: Variant = cue_player()
	if player != null:
		player.play_music(key)


func play_sfx(key: String) -> void:
	var player: Variant = cue_player()
	if player != null:
		player.play_sfx(key)


func play_match_clear(combo_value: int = 1) -> void:
	var player: Variant = cue_player()
	if player != null and player.has_method("play_match_clear"):
		player.play_match_clear(combo_value)
	else:
		play_sfx("combo")
