extends RefCounted
class_name MainMenuController

const AudioStreamLoader = preload("res://scripts/core/audio_stream_loader.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const MAIN_MENU_MUSIC_PATH := "res://resources/audio/music/main-menu.wav"
const MAIN_MENU_MUSIC_VOLUME_DB := -12.0
const COMBAT_SCENE_PATH := "res://scenes/combat.tscn"
const COLLECTION_SCENE_PATH := "res://scenes/collection.tscn"

var _host: Control
var _model
var _view

var _menu_music_player: AudioStreamPlayer = null
var _menu_music_retry_time := 0.0
var _menu_music_via_audio_manager := false
var _start_run_transitioning := false
var _collection_transitioning := false
var _tutorial_transitioning := false


func bind(host: Control, root_nodes: Dictionary, model, view) -> void:
	_host = host
	_model = model
	_view = view
	_view.bind(root_nodes)


func ready() -> void:
	_view.configure_ui_nodes(_host)
	if not _view.settings_speed_selected.is_connected(_on_settings_speed_selected):
		_view.settings_speed_selected.connect(_on_settings_speed_selected)
	if not _view.settings_reduced_motion_toggled.is_connected(_on_settings_reduced_motion_toggled):
		_view.settings_reduced_motion_toggled.connect(_on_settings_reduced_motion_toggled)
	if not _view.settings_game_juice_toggled.is_connected(_on_settings_game_juice_toggled):
		_view.settings_game_juice_toggled.connect(_on_settings_game_juice_toggled)
	if not _view.settings_game_juice_flag_toggled.is_connected(_on_settings_game_juice_flag_toggled):
		_view.settings_game_juice_flag_toggled.connect(_on_settings_game_juice_flag_toggled)
	if not _view.settings_defaults_reset.is_connected(_on_settings_defaults_reset):
		_view.settings_defaults_reset.connect(_on_settings_defaults_reset)
	if not _view.settings_closed.is_connected(_on_settings_closed):
		_view.settings_closed.connect(_on_settings_closed)
	_model.load_menu_assets()
	_view.apply_textures(_model.menu_texture_paths())
	_view.apply_static_text()
	_sync_generate_log_toggle()
	_view.set_continue_enabled(bool(RunState.run_active))
	_refresh_profile_overlay()
	_view.apply_chrome_styles()
	_view.layout_ui(_host.get_viewport_rect().size)
	_view.configure_focus_navigation()
	_start_menu_music.call_deferred()
	_host.set_process(true)

	var viewport := _host.get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)


func process(delta: float) -> void:
	_menu_music_retry_time -= delta
	if _menu_music_retry_time > 0.0:
		return
	_menu_music_retry_time = 0.5
	if _menu_music_via_audio_manager:
		_host.set_process(false)
		return
	if _menu_music_player == null or _menu_music_player.stream == null:
		_start_menu_music()
		return
	if not _menu_music_player.playing:
		_menu_music_player.play()
		if _menu_music_player.playing:
			_host.set_process(false)


func _on_viewport_size_changed() -> void:
	_view.layout_ui(_host.get_viewport_rect().size)


func _on_start_fight_button_pressed() -> void:
	if _start_run_transitioning:
		return
	_start_run_transitioning = true
	_view.set_start_run_locked(true)
	_audio_play_sfx("ui_accept")
	var source := "main_menu.start_button"
	var route_id := RunState.flow_trace_begin("start_run_to_combat", COMBAT_SCENE_PATH, {"source": source})
	var prepared_scene: Dictionary = RunState.flow_trace_prepare_scene(COMBAT_SCENE_PATH, route_id, source)
	if not bool(prepared_scene.get("ok", false)):
		_start_run_transitioning = false
		_view.set_start_run_locked(false)
		var prepare_failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(prepared_scene)
		_view.show_status("Start Run failed: %s" % prepare_failure_reason)
		push_error("Start Run prepare failed: %s -> %s (%s)" % [route_id, COMBAT_SCENE_PATH, prepare_failure_reason])
		return
	var pre_run_state: Dictionary = RunState.snapshot_run_transition_state()
	if not pre_run_state.is_empty():
		prepared_scene["rollback_snapshot"] = pre_run_state
	prepared_scene["post_ready_failure_callback"] = _on_start_run_post_ready_rollback
	RunState.flow_trace_mark("before_start_new_run", {}, route_id)
	RunState.start_new_run()
	RunState.flow_trace_mark("after_start_new_run", {}, route_id)
	_stop_local_menu_music()
	_audio_play_music("combat")
	var next_scene := RunState.next_scene_path()
	RunState.flow_trace_mark("before_change_scene_to_file", {"source": source}, route_id, next_scene)
	var transition_result: Variant = RunState.flow_trace_attach_prepared_scene(_host.get_tree(), prepared_scene, next_scene, route_id, source)
	if FLOW_RESULT_UTILS.scene_change_succeeded(transition_result):
		return
	_start_run_transitioning = false
	_view.set_start_run_locked(false)
	if not pre_run_state.is_empty():
		if not bool(RunState.restore_run_transition_state(pre_run_state)):
			RunState.reset_run()
	else:
		RunState.reset_run()
	_start_menu_music()
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(transition_result)
	_view.show_status("Start Run failed: %s" % failure_reason)
	push_error("Start Run transition failed: %s -> %s (%s)" % [route_id, next_scene, failure_reason])


func _on_start_run_post_ready_rollback(result: Dictionary) -> void:
	_start_run_transitioning = false
	_view.set_start_run_locked(false)
	_start_menu_music()
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_view.show_status("Start Run failed: %s" % failure_reason)


func _on_collection_button_pressed() -> void:
	if _collection_transitioning:
		return
	_collection_transitioning = true
	_view.set_collection_locked(true)
	_audio_play_sfx("ui_accept")
	var route_id := RunState.flow_trace_begin("main_menu_to_collection", COLLECTION_SCENE_PATH, {"source": "main_menu.collection_button"})
	RunState.flow_trace_mark("before_change_scene_to_file", {"source": "main_menu.collection_button"}, route_id, COLLECTION_SCENE_PATH)
	var transition_result: Variant = RunState.flow_trace_change_scene(
		_host.get_tree(),
		COLLECTION_SCENE_PATH,
		route_id,
		"main_menu.collection_button",
		"",
		_on_collection_post_ready_rollback
	)
	if FLOW_RESULT_UTILS.scene_change_succeeded(transition_result):
		return
	_collection_transitioning = false
	_view.set_collection_locked(false)
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(transition_result)
	_view.show_status("Collection failed: %s" % failure_reason)
	push_error("Collection transition failed: %s -> %s (%s)" % [route_id, COLLECTION_SCENE_PATH, failure_reason])


func _on_continue_button_pressed() -> void:
	if not bool(RunState.run_active):
		_view.show_status("No run to continue.")
		_view.set_continue_enabled(false)
		return
	_audio_play_sfx("ui_accept")
	var next_scene := RunState.next_scene_path()
	if next_scene == "":
		next_scene = COMBAT_SCENE_PATH
	var route_id := RunState.flow_trace_begin("main_menu_continue_run", next_scene, {"source": "main_menu.continue_button"})
	RunState.flow_trace_mark("before_change_scene_to_file", {"source": "main_menu.continue_button"}, route_id, next_scene)
	var transition_result: Variant = RunState.flow_trace_change_scene(
		_host.get_tree(),
		next_scene,
		route_id,
		"main_menu.continue_button",
		"",
		_on_continue_post_ready_rollback
	)
	if FLOW_RESULT_UTILS.scene_change_succeeded(transition_result):
		return
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(transition_result)
	_view.show_status("Continue failed: %s" % failure_reason)
	push_error("Continue transition failed: %s -> %s (%s)" % [route_id, next_scene, failure_reason])


func _on_tutorial_button_pressed() -> void:
	if _tutorial_transitioning:
		return
	_tutorial_transitioning = true
	_view.set_tutorial_locked(true)
	_audio_play_sfx("ui_accept")
	var route_id := RunState.flow_trace_begin("main_menu_to_tutorial_combat", COMBAT_SCENE_PATH, {"source": "main_menu.tutorial_button"})
	var pre_run_state: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_tutorial_run()
	RunState.flow_trace_mark("before_change_scene_to_file", {"source": "main_menu.tutorial_button"}, route_id, COMBAT_SCENE_PATH)
	var transition_result: Variant = RunState.flow_trace_change_scene(
		_host.get_tree(),
		COMBAT_SCENE_PATH,
		route_id,
		"main_menu.tutorial_button",
		"",
		_on_tutorial_post_ready_rollback,
		pre_run_state
	)
	if FLOW_RESULT_UTILS.scene_change_succeeded(transition_result):
		return
	_tutorial_transitioning = false
	_view.set_tutorial_locked(false)
	if not pre_run_state.is_empty():
		RunState.restore_run_transition_state(pre_run_state)
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(transition_result)
	_view.show_status("Tutorial failed: %s" % failure_reason)
	push_error("Tutorial transition failed: %s -> %s (%s)" % [route_id, COMBAT_SCENE_PATH, failure_reason])


func _on_tutorial_post_ready_rollback(result: Dictionary) -> void:
	_tutorial_transitioning = false
	_view.set_tutorial_locked(false)
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_view.show_status("Tutorial failed: %s" % failure_reason)


func _on_collection_post_ready_rollback(result: Dictionary) -> void:
	_collection_transitioning = false
	_view.set_collection_locked(false)
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_view.show_status("Collection failed: %s" % failure_reason)


func _on_continue_post_ready_rollback(result: Dictionary) -> void:
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_view.show_status("Continue failed: %s" % failure_reason)


func _on_settings_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	RunState.load_user_settings()
	_view.show_settings(RunState.combat_feedback_settings())


func _on_settings_speed_selected(speed: String) -> void:
	RunState.set_vfx_speed(speed)
	_view.show_settings(RunState.combat_feedback_settings())
	_view.show_status("VFX speed: %s." % RunState.vfx_speed().capitalize())


func _on_settings_reduced_motion_toggled() -> void:
	RunState.set_reduced_motion_enabled(not RunState.reduced_motion_enabled())
	_view.show_settings(RunState.combat_feedback_settings())
	_view.show_status("Reduced motion: %s." % ("On" if RunState.reduced_motion_enabled() else "Off"))


func _on_settings_game_juice_toggled() -> void:
	RunState.set_game_juice_enabled(not RunState.game_juice_enabled())
	_view.show_settings(RunState.combat_feedback_settings())
	_view.show_status("Game juice: %s." % ("On" if RunState.game_juice_enabled() else "Off"))


func _on_settings_game_juice_flag_toggled(flag_key: String) -> void:
	if not GAME_JUICE_FLAGS_SCRIPT.is_valid_key(flag_key):
		return
	var flags := RunState.game_juice_flags()
	var next_enabled := not bool(flags.get(flag_key, true))
	RunState.set_game_juice_flag_enabled(flag_key, next_enabled)
	_view.show_settings(RunState.combat_feedback_settings())
	_view.show_status("%s: %s." % [tr(GAME_JUICE_FLAGS_SCRIPT.label_key(flag_key)), "On" if next_enabled else "Off"])


func _on_settings_defaults_reset() -> void:
	RunState.reset_combat_feedback_settings()
	_view.show_settings(RunState.combat_feedback_settings())
	_view.show_status("Combat feedback settings reset.")


func _on_settings_closed() -> void:
	_audio_play_sfx("ui_accept")
	_view.hide_settings()


func _on_profile_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	_refresh_profile_overlay()
	_view.set_profile_overlay_visible(true)


func _on_close_profile_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	_view.set_profile_overlay_visible(false)


func _on_reset_profile_button_pressed() -> void:
	_view.set_reset_profile_locked(true)
	var reset_result: Variant = _reset_profile()
	if not FLOW_RESULT_UTILS.result_ok(reset_result):
		_view.show_status("Reset Profile failed: %s" % FLOW_RESULT_UTILS.result_failure_reason(reset_result))
		_view.set_reset_profile_locked(false)
		return
	_audio_play_sfx("ui_accept")
	_refresh_profile_overlay()
	_view.show_status("Profile reset.")
	_view.set_reset_profile_locked(false)


func _on_quit_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	_host.get_tree().quit()


func _on_generate_log_toggle_toggled(enabled: bool) -> void:
	RunState.set_generate_run_log_files_enabled(enabled)
	_view.show_status("Run Log export %s." % ("enabled" if enabled else "disabled"))


func _sync_generate_log_toggle() -> void:
	if RunState.has_method("load_user_settings"):
		RunState.load_user_settings()
	_view.set_generate_log_toggle(RunState.generate_run_log_files_enabled())


func _refresh_profile_overlay() -> void:
	_model.refresh_profile_snapshot(_profile_snapshot())
	_view.set_profile_content(_model.profile_name(), _model.profile_score_text())


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(_host.get_tree())


func _start_menu_music() -> void:
	if OS.has_feature("android") or OS.has_feature("template"):
		_menu_music_via_audio_manager = _try_route_menu_music_via_audio_manager()
		if _menu_music_player != null and _menu_music_player.playing:
			_menu_music_player.stop()
		_host.set_process(not _menu_music_via_audio_manager)
		return

	_menu_music_via_audio_manager = false
	_stop_shared_audio_manager_music()
	if _menu_music_player == null:
		_menu_music_player = AudioStreamPlayer.new()
		_menu_music_player.name = "MainMenuMusicPlayer"
		_menu_music_player.bus = "Master"
		_host.add_child(_menu_music_player)
		if not _menu_music_player.finished.is_connected(_on_menu_music_finished):
			_menu_music_player.finished.connect(_on_menu_music_finished)
	_menu_music_player.volume_db = MAIN_MENU_MUSIC_VOLUME_DB
	_menu_music_player.stream = _load_menu_music_stream()
	if _menu_music_player.stream != null:
		_menu_music_player.play()
		_host.set_process(not _menu_music_player.playing)
	else:
		_host.set_process(true)


func _stop_shared_audio_manager_music() -> void:
	var audio := _host.get_tree().root.get_node_or_null("AudioManager")
	if audio != null and audio.has_method("stop_music"):
		audio.call("stop_music")


func _stop_local_menu_music() -> void:
	if _menu_music_player != null and _menu_music_player.playing:
		_menu_music_player.stop()


func _try_route_menu_music_via_audio_manager() -> bool:
	var audio := _audio_manager_node()
	if audio == null or not audio.has_method("play_music"):
		return false
	audio.call("play_music", "menu")
	return true


func _on_menu_music_finished() -> void:
	if _menu_music_via_audio_manager:
		return
	if _menu_music_player == null or _menu_music_player.stream == null:
		_host.set_process(true)
		return
	_menu_music_player.play()
	if not _menu_music_player.playing:
		_host.set_process(true)


func _load_menu_music_stream() -> AudioStream:
	if not ResourceLoader.exists(MAIN_MENU_MUSIC_PATH):
		push_warning("Main menu music missing at %s" % MAIN_MENU_MUSIC_PATH)
		return null
	var stream := AudioStreamLoader.load_pcm16_wav_stream(MAIN_MENU_MUSIC_PATH, false)
	if stream != null:
		return stream
	var imported_stream := AudioStreamLoader.load_imported_audio_stream(MAIN_MENU_MUSIC_PATH, false)
	if imported_stream != null:
		return imported_stream
	push_warning("Main menu music is not a playable AudioStream: %s" % MAIN_MENU_MUSIC_PATH)
	return null


func _reset_profile() -> Variant:
	for method_name in ["reset_profile", "create_default_profile"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name)
	return {
		"ok": false,
		"reason": "missing_reset_profile_api",
	}


func _profile_snapshot() -> Dictionary:
	for method_name in ["profile_snapshot", "player_profile_snapshot", "meta_profile_snapshot"]:
		if RunState.has_method(method_name):
			var result: Variant = RunState.call(method_name)
			if result is Dictionary:
				return (result as Dictionary).duplicate(true)
	return {}
