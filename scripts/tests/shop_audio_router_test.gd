extends RefCounted
class_name ShopAudioRouterTest

const ROUTER_SCRIPT := preload("res://scripts/shop/shop_audio_router.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")


class FakeAudioManager:
	extends Node

	var music_calls: Array[String] = []
	var sfx_calls: Array[String] = []

	func play_music(key: String) -> void:
		music_calls.append(key)

	func play_sfx(key: String) -> void:
		sfx_calls.append(key)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("routes_music_and_result_sfx", _test_routes_music_and_result_sfx, failures)
	_run_case("feedback_motion_respects_juice_and_reduced_motion", _test_feedback_motion_respects_juice_and_reduced_motion, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_routes_music_and_result_sfx() -> String:
	var fixture := _fixture()
	var router: Variant = fixture["router"]
	var audio: FakeAudioManager = fixture["audio"]
	RunState.set_game_juice_enabled(true)
	RunState.set_game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SHOP_CHOICE_FEEDBACK, true)

	router.play_music("shop")
	router.play_shop_result_sfx({"ok": false}, "purchase")
	router.play_shop_result_sfx({"ok": true}, "purchase")
	router.play_shop_result_sfx({"ok": true}, "gold")

	var result := ""
	if audio.music_calls != ["shop"]:
		result = "Expected shop music to route through the audio manager."
	elif audio.sfx_calls != ["error", "purchase_juice", "gold"]:
		result = "Expected result SFX to route error, juice purchase, and success keys."
	_cleanup_fixture(fixture)
	return result


func _test_feedback_motion_respects_juice_and_reduced_motion() -> String:
	var fixture := _fixture()
	var router: Variant = fixture["router"]
	RunState.set_game_juice_enabled(true)
	RunState.set_game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SHOP_CHOICE_FEEDBACK, true)
	RunState.set_reduced_motion_enabled(false)

	var result := ""
	if not router.shop_feedback_motion_enabled():
		result = "Expected shop feedback motion when juice flag is enabled and reduced motion is off."
	RunState.set_reduced_motion_enabled(true)
	if result == "" and router.shop_feedback_motion_enabled():
		result = "Expected reduced motion to disable shop feedback motion."
	RunState.set_reduced_motion_enabled(false)
	RunState.set_game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SHOP_CHOICE_FEEDBACK, false)
	if result == "" and router.shop_feedback_enabled():
		result = "Expected disabled shop feedback flag to disable feedback."
	_cleanup_fixture(fixture)
	return result


func _fixture() -> Dictionary:
	var previous_settings := RunState.combat_feedback_settings()
	var tree := Engine.get_main_loop() as SceneTree
	var host := Control.new()
	host.name = "ShopAudioRouterTestHost"
	tree.root.add_child(host)
	var audio := FakeAudioManager.new()
	audio.name = "AudioManager"
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(host, audio)
	return {
		"host": host,
		"audio": audio,
		"previous_settings": previous_settings,
		"router": router,
	}


func _cleanup_fixture(fixture: Dictionary) -> void:
	var audio: Node = fixture["audio"]
	var host: Node = fixture["host"]
	var previous_settings: Dictionary = fixture["previous_settings"]
	if audio != null and is_instance_valid(audio):
		audio.free()
	if host != null and is_instance_valid(host):
		host.free()
	RunState.set_reduced_motion_enabled(bool(previous_settings.get("reduced_motion", false)))
	RunState.set_game_juice_enabled(bool(previous_settings.get("game_juice", true)))
	for flag_key in Dictionary(previous_settings.get("game_juice_flags", {})).keys():
		RunState.set_game_juice_flag_enabled(String(flag_key), bool(Dictionary(previous_settings.get("game_juice_flags", {})).get(flag_key, true)))
