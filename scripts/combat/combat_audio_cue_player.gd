extends RefCounted
class_name CombatAudioCuePlayer

const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

var _host: Node = null
var _audio_manager_override: Variant = null
var _game_juice_enabled := false
var _game_juice_flags: Dictionary = GAME_JUICE_FLAGS_SCRIPT.default_flags()


func bind(host: Node = null, audio_manager_override: Variant = null) -> void:
	_host = host
	_audio_manager_override = audio_manager_override


func set_game_juice_enabled(enabled: bool) -> void:
	_game_juice_enabled = enabled


func set_game_juice_flags(flags: Dictionary) -> void:
	_game_juice_flags = GAME_JUICE_FLAGS_SCRIPT.normalized_flags(flags)


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
	play_enemy_attack_result(enemy_attack)


func play_mastery_effect(effect_kind: String) -> void:
	play_impact(effect_kind)


func play_impact(impact_kind: String, target: String = "enemy") -> void:
	var clean_kind := impact_kind.strip_edges().to_lower()
	if not _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.ELEMENT_IMPACT_AUDIO):
		match clean_kind:
			"heal":
				play_sfx("heal")
			"armor", "block":
				play_sfx("armor")
			"gold":
				play_sfx("gold")
			_:
				play_sfx("hit")
		return
	match clean_kind:
		"fire":
			play_sfx("impact_fire")
		"ice":
			play_sfx("impact_ice")
		"earth", "nature":
			play_sfx("impact_earth")
		"damage", "hit":
			play_sfx("impact_player_hit" if target == "player" else "impact_enemy_hit")
		"heal":
			play_sfx("impact_heal")
		"armor", "block":
			play_sfx("impact_player_block" if target == "player" else "impact_armor")
		"gold":
			play_sfx("impact_gold")


func play_match_clear(combo_value: int = 1) -> void:
	if combo_value >= 2:
		if _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.COMBO_RHYTHM_PULSE):
			if combo_value >= 4:
				play_sfx("combo_rhythm_high")
			elif combo_value >= 3:
				play_sfx("combo_rhythm_mid")
			else:
				play_sfx("combo")
		else:
			play_sfx("combo")
	else:
		play_sfx("match")


func play_enemy_attack_result(result: Dictionary) -> void:
	if int(result.get("hp_damage", 0)) > 0:
		play_impact("damage", "player")
	elif int(result.get("blocked_by_armor", 0)) > 0:
		play_impact("block", "player")


func _audio_manager_node() -> Variant:
	if _audio_manager_override != null:
		return _audio_manager_override
	if _host == null or not is_instance_valid(_host):
		return null
	var tree := _host.get_tree()
	if tree == null:
		return null
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(tree)


func _juice_enabled(flag_key: String) -> bool:
	return _game_juice_enabled and bool(_game_juice_flags.get(flag_key, true))
