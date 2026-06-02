extends RefCounted
class_name CombatAudioCuePlayer

const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")

var _host: Node = null
var _audio_manager_override: Variant = null


func bind(host: Node = null, audio_manager_override: Variant = null) -> void:
	_host = host
	_audio_manager_override = audio_manager_override


func play_music(key: String) -> void:
	var audio: Variant = _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func play_sfx(key: String) -> void:
	var audio: Variant = _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func play_turn_result(turn_log: Dictionary) -> void:
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	if int(enemy_attack.get("hp_damage", 0)) > 0:
		play_sfx("hit")
	elif int(enemy_attack.get("blocked_by_armor", 0)) > 0:
		play_sfx("armor")


func play_mastery_effect(effect_kind: String) -> void:
	match effect_kind:
		"damage":
			play_sfx("hit")
		"heal":
			play_sfx("heal")
		"armor":
			play_sfx("armor")
		"gold":
			play_sfx("gold")


func play_match_clear(combo_value: int = 1) -> void:
	if combo_value >= 2:
		play_sfx("combo")
	else:
		play_sfx("match")


func play_enemy_attack_result(result: Dictionary) -> void:
	if int(result.get("hp_damage", 0)) > 0:
		play_sfx("hit")
	elif int(result.get("blocked_by_armor", 0)) > 0:
		play_sfx("armor")


func _audio_manager_node() -> Variant:
	if _audio_manager_override != null:
		return _audio_manager_override
	if _host == null or not is_instance_valid(_host):
		return null
	var tree := _host.get_tree()
	if tree == null:
		return null
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(tree)
