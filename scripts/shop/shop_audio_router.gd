extends RefCounted
class_name ShopAudioRouter

const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

var _host: Control
var _audio_manager: Node


func bind(host: Control, audio_manager: Node = null) -> void:
	_host = host
	_audio_manager = audio_manager


func play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func play_shop_result_sfx(result: Dictionary, success_key: String) -> void:
	if not bool(result.get("ok", false)):
		play_sfx("error")
		return
	if success_key == "purchase" and shop_feedback_enabled():
		play_sfx("purchase_juice")
		return
	play_sfx(success_key)


func shop_feedback_enabled() -> bool:
	return RunState.game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SHOP_CHOICE_FEEDBACK)


func shop_feedback_motion_enabled() -> bool:
	return shop_feedback_enabled() and not RunState.reduced_motion_enabled()


func _audio_manager_node() -> Node:
	if _audio_manager != null and is_instance_valid(_audio_manager):
		return _audio_manager
	if _host == null or not is_instance_valid(_host) or _host.get_tree() == null:
		return null
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(_host.get_tree())
