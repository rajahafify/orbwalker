extends Control

const AudioStreamLoader = preload("res://scripts/core/audio_stream_loader.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const MENU_ASSET_MAP_PATH := "res://resources/visual/first_pass_asset_map.json"

const FALLBACK_BG_PATH := "res://resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png"
const FALLBACK_LOGO_PATH := "res://resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png"
const FALLBACK_OUTER_BORDER_PATH := "res://resources/art/first_pass/menu/main_menu_border_outer_v1.png"
const FALLBACK_BUTTON_PRIMARY_PATH := "res://resources/art/first_pass/menu/main_menu_button_primary_v1.png"
const FALLBACK_BUTTON_SECONDARY_PATH := "res://resources/art/first_pass/menu/main_menu_button_secondary_v1.png"
const FALLBACK_STATS_PANEL_PATH := "res://resources/art/first_pass/menu/main_menu_stats_triptych_panel_v1.png"
const MAIN_MENU_MUSIC_PATH := "res://resources/audio/music/main-menu.wav"
const MAIN_MENU_MUSIC_VOLUME_DB := -12.0
const COLLECTION_SCENE_PATH := "res://scenes/flow/collection.tscn"

const ELEMENT_KEYS: Array[String] = ["fire", "ice", "earth", "heart", "armor", "gold"]
const ELEMENT_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/first_pass/derived/icons/mastery_fire.png",
	"res://resources/art/first_pass/derived/icons/mastery_ice.png",
	"res://resources/art/first_pass/derived/icons/mastery_earth.png",
	"res://resources/art/first_pass/derived/icons/mastery_heart.png",
	"res://resources/art/first_pass/derived/icons/mastery_armor.png",
	"res://resources/art/first_pass/derived/icons/mastery_gold.png",
]
const STAT_MENU_ICON_KEYS: Array[String] = ["relics_unlocked", "mastery_progress", "best_run"]
const STAT_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/first_pass/menu/main_menu_icon_relic_chest_v1.png",
	"res://resources/art/first_pass/menu/main_menu_icon_mastery_progress_v1.png",
	"res://resources/art/first_pass/menu/main_menu_icon_best_run_demon_v1.png",
]
const FOOTER_MENU_ICON_KEYS: Array[String] = ["profile", "achievements", "settings"]
const FOOTER_ICON_FALLBACK_PATHS: Array[String] = [
	"res://resources/art/first_pass/menu/main_menu_icon_profile_v1.png",
	"res://resources/art/first_pass/menu/main_menu_icon_achievements_v1.png",
	"res://resources/art/first_pass/menu/main_menu_icon_settings_v1.png",
]

@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _overlay_tint: ColorRect = $OverlayTint
@onready var _outer_frame: Control = %OuterFrame
@onready var _outer_border_texture: TextureRect = $OuterFrame/OuterBorderTexture
@onready var _logo_texture: TextureRect = %LogoTexture
@onready var _menu_button_column: VBoxContainer = %MenuButtonColumn
@onready var _start_run_button: Button = %StartRunButton
@onready var _generate_log_toggle: CheckButton = %GenerateLogToggle
@onready var _continue_button: Button = %ContinueButton
@onready var _collection_button: Button = %CollectionButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _element_row: HBoxContainer = %ElementRow
@onready var _stats_panel: Panel = %StatsPanel
@onready var _stats_row: HBoxContainer = %StatsRow
@onready var _footer_actions: HBoxContainer = %FooterActions
@onready var _profile_button: Button = $FooterActions/ProfileButton
@onready var _achievements_button: Button = $FooterActions/AchievementsButton
@onready var _footer_settings_button: Button = $FooterActions/FooterSettingsButton
@onready var _version_label: Label = %VersionLabel
@onready var _status_label: Label = %StatusLabel
@onready var _profile_overlay: Control = %ProfileOverlay
@onready var _profile_panel: PanelContainer = %ProfilePanel
@onready var _profile_title_label: Label = %ProfileTitleLabel
@onready var _profile_name_label: Label = %ProfileNameLabel
@onready var _profile_score_label: Label = %ProfileScoreLabel
@onready var _reset_profile_button: Button = %ResetProfileButton
@onready var _close_profile_button: Button = %CloseProfileButton

@onready var _element_icons: Array = [
	$ElementRow/FireCell/FireIcon,
	$ElementRow/IceCell/IceIcon,
	$ElementRow/EarthCell/EarthIcon,
	$ElementRow/HeartCell/HeartIcon,
	$ElementRow/ArmorCell/ArmorIcon,
	$ElementRow/GoldCell/GoldIcon,
]

@onready var _element_labels: Array = [
	$ElementRow/FireCell/FireLabel,
	$ElementRow/IceCell/IceLabel,
	$ElementRow/EarthCell/EarthLabel,
	$ElementRow/HeartCell/HeartLabel,
	$ElementRow/ArmorCell/ArmorLabel,
	$ElementRow/GoldCell/GoldLabel,
]

@onready var _stat_icons: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsIcon,
	$StatsPanel/StatsRow/MasteryStat/MasteryIcon,
	$StatsPanel/StatsRow/BestRunStat/BestRunIcon,
]

@onready var _stat_titles: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsText/RelicsTitle,
	$StatsPanel/StatsRow/MasteryStat/MasteryText/MasteryTitle,
	$StatsPanel/StatsRow/BestRunStat/BestRunText/BestRunTitle,
]

@onready var _stat_values: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsText/RelicsValue,
	$StatsPanel/StatsRow/MasteryStat/MasteryText/MasteryValue,
	$StatsPanel/StatsRow/BestRunStat/BestRunText/BestRunValue,
]

var _asset_map: Dictionary = {}
var _menu_assets: Dictionary = {}
var _menu_icons: Dictionary = {}
var _primary_button_texture: Texture2D = null
var _secondary_button_texture: Texture2D = null
var _stats_panel_texture: Texture2D = null
var _menu_music_player: AudioStreamPlayer = null
var _menu_music_retry_time := 0.0
var _menu_music_via_audio_manager := false
var _start_run_transitioning := false
var _collection_transitioning := false


func _ready() -> void:
	_configure_ui_nodes()
	_asset_map = _load_asset_map()
	_menu_assets = _asset_map.get("menu", {})
	_menu_icons = _resolve_menu_icons()
	_load_textures()
	_apply_static_text()
	_sync_generate_log_toggle()
	_apply_chrome_styles()
	_layout_ui()
	_start_menu_music.call_deferred()
	set_process(true)

	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_layout_ui()


func _on_start_fight_button_pressed() -> void:
	if _start_run_transitioning:
		return
	_start_run_transitioning = true
	_start_run_button.disabled = true
	_audio_play_sfx("ui_accept")
	var target_scene := "res://scenes/combat/combat_player.tscn"
	var source := "main_boot.start_button"
	var route_id := RunState.flow_trace_begin(
		"start_run_to_combat",
		target_scene,
		{"source": source}
	)
	var prepared_scene: Dictionary = RunState.flow_trace_prepare_scene(target_scene, route_id, source)
	if not bool(prepared_scene.get("ok", false)):
		_start_run_transitioning = false
		_start_run_button.disabled = false
		var prepare_failure_reason := _scene_change_failure_reason(prepared_scene)
		_status_label.text = "Start Run failed: %s" % prepare_failure_reason
		_status_label.visible = true
		push_error("Start Run prepare failed: %s -> %s (%s)" % [route_id, target_scene, prepare_failure_reason])
		return
	var pre_run_state: Dictionary = {}
	if RunState.has_method("snapshot_run_transition_state"):
		pre_run_state = RunState.snapshot_run_transition_state()
	if not pre_run_state.is_empty():
		prepared_scene["rollback_snapshot"] = pre_run_state
	prepared_scene["post_ready_failure_callback"] = Callable(self, "_on_start_run_post_ready_rollback")
	RunState.flow_trace_mark("before_start_new_run", {}, route_id)
	RunState.start_new_run()
	RunState.flow_trace_mark("after_start_new_run", {}, route_id)
	_stop_local_menu_music()
	_audio_play_music("combat")
	var next_scene := RunState.next_scene_path()
	RunState.flow_trace_mark(
		"before_change_scene_to_file",
		{"source": source},
		route_id,
		next_scene
	)
	var transition_result: Variant = RunState.flow_trace_attach_prepared_scene(
		get_tree(),
		prepared_scene,
		next_scene,
		route_id,
		source
	)
	if _scene_change_succeeded(transition_result):
		return
	_start_run_transitioning = false
	_start_run_button.disabled = false
	if RunState.has_method("restore_run_transition_state") and not pre_run_state.is_empty():
		if not bool(RunState.restore_run_transition_state(pre_run_state)):
			RunState.reset_run()
	else:
		RunState.reset_run()
	_start_menu_music()
	var failure_reason := _scene_change_failure_reason(transition_result)
	_status_label.text = "Start Run failed: %s" % failure_reason
	_status_label.visible = true
	push_error("Start Run transition failed: %s -> %s (%s)" % [route_id, next_scene, failure_reason])


func _on_start_run_post_ready_rollback(result: Dictionary) -> void:
	_start_run_transitioning = false
	if _start_run_button != null and is_instance_valid(_start_run_button):
		_start_run_button.disabled = false
	_start_menu_music()
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	if _status_label != null and is_instance_valid(_status_label):
		_status_label.text = "Start Run failed: %s" % failure_reason
		_status_label.visible = true


func _on_collection_button_pressed() -> void:
	if _collection_transitioning:
		return
	_collection_transitioning = true
	_collection_button.disabled = true
	_audio_play_sfx("ui_accept")
	var route_id := RunState.flow_trace_begin(
		"main_menu_to_collection",
		COLLECTION_SCENE_PATH,
		{"source": "main_boot.collection_button"}
	)
	RunState.flow_trace_mark(
		"before_change_scene_to_file",
		{"source": "main_boot.collection_button"},
		route_id,
		COLLECTION_SCENE_PATH
	)
	var transition_result: Variant = RunState.flow_trace_change_scene(
		get_tree(),
		COLLECTION_SCENE_PATH,
		route_id,
		"main_boot.collection_button",
		"",
		Callable(self, "_on_collection_post_ready_rollback")
	)
	if _scene_change_succeeded(transition_result):
		return
	_collection_transitioning = false
	_collection_button.disabled = false
	var failure_reason := _scene_change_failure_reason(transition_result)
	_status_label.text = "Collection failed: %s" % failure_reason
	_status_label.visible = true
	push_error("Collection transition failed: %s -> %s (%s)" % [route_id, COLLECTION_SCENE_PATH, failure_reason])


func _on_collection_post_ready_rollback(result: Dictionary) -> void:
	_collection_transitioning = false
	if _collection_button != null and is_instance_valid(_collection_button):
		_collection_button.disabled = false
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	if _status_label != null and is_instance_valid(_status_label):
		_status_label.text = "Collection failed: %s" % failure_reason
		_status_label.visible = true


func _on_profile_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	_refresh_profile_overlay()
	_profile_overlay.visible = true


func _on_close_profile_button_pressed() -> void:
	_audio_play_sfx("ui_accept")
	_profile_overlay.visible = false


func _on_reset_profile_button_pressed() -> void:
	_reset_profile_button.disabled = true
	var reset_result: Variant = _reset_profile()
	if not _result_ok(reset_result):
		_status_label.text = "Reset Profile failed: %s" % _result_failure_reason(reset_result)
		_status_label.visible = true
		_reset_profile_button.disabled = false
		return
	_audio_play_sfx("ui_accept")
	_refresh_profile_overlay()
	_status_label.text = "Profile reset."
	_status_label.visible = true
	_reset_profile_button.disabled = false


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	return int(result) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	return "error_code_%d" % int(result)


func _result_ok(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	if result is int:
		return int(result) == OK
	return false


func _result_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is int:
		return "error_code_%d" % int(result)
	return "unknown"


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


func _refresh_profile_overlay() -> void:
	var snapshot: Dictionary = _profile_snapshot()
	var profile_name := String(snapshot.get("display_name", snapshot.get("profile_name", "Default Profile"))).strip_edges()
	if profile_name == "":
		profile_name = "Default Profile"
	_profile_name_label.text = profile_name
	_profile_score_label.text = "Total Score: %d" % maxi(0, int(snapshot.get("total_score", 0)))


func _process(delta: float) -> void:
	_menu_music_retry_time -= delta
	if _menu_music_retry_time > 0.0:
		return
	_menu_music_retry_time = 0.5
	if _menu_music_via_audio_manager:
		set_process(false)
		return
	if _menu_music_player == null:
		_start_menu_music()
		return
	if _menu_music_player.stream == null:
		_start_menu_music()
		return
	if not _menu_music_player.playing:
		_menu_music_player.play()
		if _menu_music_player.playing:
			set_process(false)


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(get_tree())


func _start_menu_music() -> void:
	if OS.has_feature("android") or OS.has_feature("template"):
		_menu_music_via_audio_manager = _try_route_menu_music_via_audio_manager()
		if _menu_music_player != null and _menu_music_player.playing:
			_menu_music_player.stop()
		if _menu_music_via_audio_manager:
			set_process(false)
			print("Main menu music routed via AudioManager: android=%s template=%s volume_db=%s" % [
				str(OS.has_feature("android")),
				str(OS.has_feature("template")),
				str(MAIN_MENU_MUSIC_VOLUME_DB),
			])
		else:
			set_process(true)
		return

	_menu_music_via_audio_manager = false
	_stop_shared_audio_manager_music()
	if _menu_music_player == null:
		_menu_music_player = AudioStreamPlayer.new()
		_menu_music_player.name = "MainMenuMusicPlayer"
		_menu_music_player.bus = "Master"
		add_child(_menu_music_player)
		if not _menu_music_player.finished.is_connected(_on_menu_music_finished):
			_menu_music_player.finished.connect(_on_menu_music_finished)
	_menu_music_player.volume_db = MAIN_MENU_MUSIC_VOLUME_DB
	_menu_music_player.stream = _load_menu_music_stream()
	if _menu_music_player.stream != null:
		_menu_music_player.play()
		if _menu_music_player.playing:
			set_process(false)
			print("Main menu music playing: android=%s template=%s stream=%s playing=%s volume_db=%s bus=%s" % [
				str(OS.has_feature("android")),
				str(OS.has_feature("template")),
				_menu_music_player.stream.get_class(),
				str(_menu_music_player.playing),
				str(_menu_music_player.volume_db),
				_menu_music_player.bus,
			])
		else:
			set_process(true)
	else:
		set_process(true)


func _stop_shared_audio_manager_music() -> void:
	var audio := get_node_or_null("/root/AudioManager")
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
		set_process(true)
		return
	_menu_music_player.play()
	if not _menu_music_player.playing:
		set_process(true)


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


func _configure_ui_nodes() -> void:
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_logo_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_outer_border_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_outer_border_texture.stretch_mode = TextureRect.STRETCH_SCALE

	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2.ZERO

	for icon_node in _stat_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2.ZERO

	for container in [_menu_button_column, _element_row, _stats_row, _footer_actions]:
		container.custom_minimum_size = Vector2.ZERO

	clip_contents = true
	_element_row.clip_contents = true
	_stats_panel.clip_contents = true
	_footer_actions.clip_contents = true


func _load_textures() -> void:
	_background_texture.texture = _safe_load_texture(_resolve_background_path(), "main_menu_background")
	_logo_texture.texture = _safe_load_texture(_resolve_logo_path(), "main_menu_logo")
	_outer_border_texture.texture = _safe_load_texture(
		_resolve_menu_texture("outer_border", FALLBACK_OUTER_BORDER_PATH),
		"main_menu_outer_border"
	)
	_primary_button_texture = _safe_load_texture(
		_resolve_menu_texture("button_primary", FALLBACK_BUTTON_PRIMARY_PATH),
		"main_menu_button_primary"
	)
	_secondary_button_texture = _safe_load_texture(
		_resolve_menu_texture("button_secondary", FALLBACK_BUTTON_SECONDARY_PATH),
		"main_menu_button_secondary"
	)
	_stats_panel_texture = _safe_load_texture(
		_resolve_menu_texture("stats_panel", FALLBACK_STATS_PANEL_PATH),
		"main_menu_stats_panel"
	)

	var element_paths := _resolve_mastery_icon_paths()
	for i in _element_icons.size():
		_element_icons[i].texture = _safe_load_texture(element_paths[i], "element_%d" % i)

	for i in _stat_icons.size():
		var stat_path := _resolve_menu_icon_path(STAT_MENU_ICON_KEYS[i], STAT_ICON_FALLBACK_PATHS[i])
		_stat_icons[i].texture = _safe_load_texture(stat_path, "stat_%d" % i)

	var footer_buttons := [_profile_button, _achievements_button, _footer_settings_button]
	for i in footer_buttons.size():
		var icon_path := _resolve_menu_icon_path(FOOTER_MENU_ICON_KEYS[i], FOOTER_ICON_FALLBACK_PATHS[i])
		var icon := _safe_load_texture(icon_path, "footer_%d" % i)
		if icon != null:
			footer_buttons[i].icon = _scaled_texture(icon, 84)


func _apply_static_text() -> void:
	_start_run_button.text = "START RUN"
	_generate_log_toggle.text = "GENERATE LOG"
	_continue_button.text = "CONTINUE"
	_collection_button.text = "COLLECTION"
	_settings_button.text = "SETTINGS"
	_quit_button.text = "QUIT"
	_profile_button.text = "PROFILE"
	_achievements_button.text = "ACHIEVEMENTS"
	_footer_settings_button.text = "SETTINGS"
	_version_label.text = "VERSION 0.1"

	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			label.text = label.text.to_upper()

	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			title.text = title.text.to_upper()

	var value_label := _stat_values[2] as Label
	if value_label != null:
		value_label.text = value_label.text.to_upper()

	_status_label.text = "Main menu runtime surface."
	_status_label.visible = false
	_continue_button.disabled = true
	_collection_button.disabled = false
	_settings_button.disabled = true
	_quit_button.disabled = true
	_profile_button.disabled = false
	_achievements_button.disabled = true
	_footer_settings_button.disabled = true


func _sync_generate_log_toggle() -> void:
	if RunState.has_method("load_user_settings"):
		RunState.load_user_settings()
	_generate_log_toggle.set_pressed_no_signal(RunState.generate_run_log_files_enabled())


func _on_generate_log_toggle_toggled(enabled: bool) -> void:
	RunState.set_generate_run_log_files_enabled(enabled)
	_status_label.text = "Run Log export %s." % ("enabled" if enabled else "disabled")
	_status_label.visible = true


func _apply_chrome_styles() -> void:
	_stats_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.03, 0.08, 0.14, 0.88), Color(0.66, 0.52, 0.24, 0.90), 2, 8)
	)
	if _stats_panel_texture != null:
		var stats_style := _make_texture_style(_stats_panel_texture, 0.0, 26.0, 18.0, 0.0)
		_stats_panel.add_theme_stylebox_override("panel", stats_style)

	_apply_menu_button_style(_start_run_button, _primary_button_texture, true, false)
	_apply_menu_button_style(_generate_log_toggle, _secondary_button_texture, false, false)
	_apply_menu_button_style(_continue_button, _secondary_button_texture, false, true)
	_apply_menu_button_style(_collection_button, _secondary_button_texture, false, false)
	_apply_menu_button_style(_settings_button, _secondary_button_texture, false, true)
	_apply_menu_button_style(_quit_button, _secondary_button_texture, false, true)
	_apply_footer_button_style(_profile_button, _secondary_button_texture)
	_apply_footer_button_style(_achievements_button, _secondary_button_texture)
	_apply_footer_button_style(_footer_settings_button, _secondary_button_texture)
	_apply_profile_overlay_style()

	_set_label_style(_version_label, Color(0.86, 0.73, 0.46, 0.96), Color(0.05, 0.06, 0.10, 0.95), 2)
	_set_label_style(_status_label, Color(0.86, 0.73, 0.46, 0.88), Color(0.05, 0.06, 0.10, 0.95), 2)
	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, Color(0.86, 0.75, 0.51, 0.98), Color(0.04, 0.05, 0.08, 0.96), 2)
	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			_set_label_style(title, Color(0.86, 0.75, 0.51, 0.98), Color(0.04, 0.05, 0.08, 0.96), 2)
	for value_node in _stat_values:
		var value := value_node as Label
		if value != null:
			_set_label_style(value, Color(0.96, 0.90, 0.76, 0.99), Color(0.05, 0.06, 0.10, 0.96), 2)


func _layout_ui() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var safe_rect := _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (34.0 / DESIGN_SIZE.x))

	_set_control_rect(_background_texture, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_overlay_tint, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_frame, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_border_texture, _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (12.0 / DESIGN_SIZE.x)))

	_set_control_rect(_logo_texture, _rect_from_percent_in_rect(safe_rect, 0.01, 0.025, 0.98, 0.17))
	_set_control_rect(_menu_button_column, _rect_from_percent_in_rect(safe_rect, 0.40, 0.22, 0.57, 0.34))
	_set_control_rect(_element_row, _rect_from_percent_in_rect(safe_rect, 0.03, 0.57, 0.94, 0.12))
	_set_control_rect(_stats_panel, _rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14))
	_set_control_rect(_footer_actions, _rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.077))
	_set_control_rect(_version_label, _rect_from_percent_in_rect(safe_rect, 0.33, 0.946, 0.34, 0.022))
	_set_control_rect(_status_label, _rect_from_percent_in_rect(safe_rect, 0.04, 0.973, 0.92, 0.019))
	_set_control_rect(
		_stats_row,
		Rect2(
			Vector2(_stats_panel.size.x * 0.055, _stats_panel.size.y * 0.28),
			Vector2(_stats_panel.size.x * 0.89, _stats_panel.size.y * 0.48)
		)
	)

	_menu_button_column.add_theme_constant_override("separation", int(round(clampf(6.0 * (viewport_size.y / DESIGN_SIZE.y), 4.0, 10.0))))
	_footer_actions.add_theme_constant_override("separation", int(round(clampf(10.0 * (viewport_size.x / DESIGN_SIZE.x), 8.0, 16.0))))

	var menu_button_min_height := int(round(viewport_size.y * 0.052))
	for button in [_start_run_button, _generate_log_toggle, _continue_button, _collection_button, _settings_button, _quit_button]:
		button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))

	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var element_icon_size := int(round(clampf(118.0 * scale_factor, 58.0, 136.0)))
	var element_cell_width := _element_row.size.x / 6.0
	if element_icon_size > int(round(element_cell_width * 0.78)):
		element_icon_size = int(round(element_cell_width * 0.78))
	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.custom_minimum_size = Vector2(element_icon_size, element_icon_size)

	var stat_icon_size := int(round(clampf(88.0 * scale_factor, 48.0, 100.0)))
	for icon_node in _stat_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.custom_minimum_size = Vector2(stat_icon_size, stat_icon_size)

	var footer_button_height := int(round(_footer_actions.size.y))
	var footer_icon_max_width := int(round(clampf(72.0 * scale_factor, 36.0, 84.0)))
	for button in [_profile_button, _achievements_button, _footer_settings_button]:
		button.custom_minimum_size = Vector2(0.0, float(footer_button_height))
		button.add_theme_constant_override("icon_max_width", footer_icon_max_width)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = false

	_profile_panel.custom_minimum_size = Vector2(
		clampf(viewport_size.x * 0.78, 520.0, 760.0),
		clampf(viewport_size.y * 0.22, 330.0, 460.0)
	)
	_reset_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))
	_close_profile_button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))

	_apply_font_sizes(viewport_size)


func _apply_font_sizes(viewport_size: Vector2) -> void:
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var menu_size := maxi(18, int(round(40.0 * scale_factor)))
	var element_size := maxi(14, int(round(24.0 * scale_factor)))
	var stat_title_size := maxi(11, int(round(15.0 * scale_factor)))
	var stat_value_size := maxi(17, int(round(27.0 * scale_factor)))
	var footer_size := maxi(13, int(round(25.0 * scale_factor)))
	var version_size := maxi(12, int(round(18.0 * scale_factor)))
	var status_size := maxi(10, int(round(13.0 * scale_factor)))

	for button in [_start_run_button, _generate_log_toggle, _continue_button, _collection_button, _settings_button, _quit_button]:
		button.add_theme_font_size_override("font_size", menu_size)
	for label_node in _element_labels:
		var element_label := label_node as Label
		if element_label != null:
			element_label.add_theme_font_size_override("font_size", element_size)
	for title_node in _stat_titles:
		var stat_title := title_node as Label
		if stat_title != null:
			stat_title.add_theme_font_size_override("font_size", stat_title_size)
	for value_node in _stat_values:
		var stat_value := value_node as Label
		if stat_value != null:
			stat_value.add_theme_font_size_override("font_size", stat_value_size)
	for button in [_profile_button, _achievements_button, _footer_settings_button]:
		button.add_theme_font_size_override("font_size", footer_size)
	_profile_title_label.add_theme_font_size_override("font_size", maxi(32, int(round(52.0 * scale_factor))))
	_profile_name_label.add_theme_font_size_override("font_size", maxi(24, int(round(34.0 * scale_factor))))
	_profile_score_label.add_theme_font_size_override("font_size", maxi(22, int(round(30.0 * scale_factor))))
	_reset_profile_button.add_theme_font_size_override("font_size", maxi(18, int(round(28.0 * scale_factor))))
	_close_profile_button.add_theme_font_size_override("font_size", maxi(18, int(round(28.0 * scale_factor))))
	_version_label.add_theme_font_size_override("font_size", version_size)
	_status_label.add_theme_font_size_override("font_size", status_size)


func _apply_menu_button_style(button: Button, texture: Texture2D, is_primary: bool, is_disabled: bool) -> void:
	if texture != null:
		var normal := _make_texture_style(texture, 0.0, 56.0, 24.0, 0.0)
		var hover := _make_texture_style(texture, 0.0, 56.0, 24.0, 0.0)
		var pressed := _make_texture_style(texture, 0.0, 56.0, 24.0, 0.0)
		var focus := _make_texture_style(texture, 0.0, 56.0, 24.0, 0.0)
		var disabled := _make_texture_style(texture, 0.0, 56.0, 24.0, 0.0)
		hover.modulate_color = Color(1.05, 1.05, 1.05, 1.0)
		pressed.modulate_color = Color(0.90, 0.90, 0.90, 1.0)
		focus.modulate_color = Color(1.03, 1.03, 1.03, 1.0)
		disabled.modulate_color = Color(0.60, 0.60, 0.60, 0.86)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_stylebox_override("disabled", disabled)
	else:
		var border_color := Color(0.61, 0.47, 0.21, 0.95)
		var fill_color := Color(0.05, 0.11, 0.19, 0.96)
		if is_primary:
			border_color = Color(0.88, 0.68, 0.33, 0.99)
			fill_color = Color(0.07, 0.17, 0.30, 0.98)
		button.add_theme_stylebox_override("normal", _make_panel_style(fill_color, border_color, 2, 10))
		button.add_theme_stylebox_override("hover", _make_panel_style(fill_color.lightened(0.12), border_color, 2, 10))
		button.add_theme_stylebox_override("pressed", _make_panel_style(fill_color.darkened(0.10), border_color, 2, 10))
		button.add_theme_stylebox_override("focus", _make_panel_style(fill_color.lightened(0.08), border_color, 2, 10))
		button.add_theme_stylebox_override("disabled", _make_panel_style(fill_color.darkened(0.18), border_color.darkened(0.22), 2, 10))

	var font_color := Color(0.89, 0.77, 0.52, 1.0)
	var hover_color := Color(0.96, 0.86, 0.62, 1.0)
	if is_primary:
		font_color = Color(0.96, 0.87, 0.66, 1.0)
		hover_color = Color(0.98, 0.91, 0.74, 1.0)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", hover_color)
	button.add_theme_color_override("font_pressed_color", Color(0.84, 0.71, 0.47, 1.0))
	button.add_theme_color_override("font_focus_color", hover_color)
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.62, 0.43, 0.80))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.96))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 10)
	button.modulate = Color(1.0, 1.0, 1.0, (0.92 if is_disabled else 1.0))


func _apply_footer_button_style(button: Button, texture: Texture2D) -> void:
	if texture != null:
		var normal := _make_texture_style(texture, 0.0, 48.0, 18.0, 0.0)
		var hover := _make_texture_style(texture, 0.0, 48.0, 18.0, 0.0)
		var pressed := _make_texture_style(texture, 0.0, 48.0, 18.0, 0.0)
		var focus := _make_texture_style(texture, 0.0, 48.0, 18.0, 0.0)
		var disabled := _make_texture_style(texture, 0.0, 48.0, 18.0, 0.0)
		hover.modulate_color = Color(1.03, 1.03, 1.03, 1.0)
		pressed.modulate_color = Color(0.90, 0.90, 0.90, 1.0)
		focus.modulate_color = Color(1.03, 1.03, 1.03, 1.0)
		disabled.modulate_color = Color(0.58, 0.58, 0.58, 0.86)
		button.add_theme_stylebox_override("normal", normal)
		button.add_theme_stylebox_override("hover", hover)
		button.add_theme_stylebox_override("pressed", pressed)
		button.add_theme_stylebox_override("focus", focus)
		button.add_theme_stylebox_override("disabled", disabled)
	else:
		button.add_theme_stylebox_override(
			"normal",
			_make_panel_style(Color(0.03, 0.07, 0.12, 0.90), Color(0.50, 0.38, 0.18, 0.85), 1, 10)
		)
		button.add_theme_stylebox_override(
			"hover",
			_make_panel_style(Color(0.05, 0.10, 0.16, 0.94), Color(0.62, 0.47, 0.22, 0.90), 1, 10)
		)
		button.add_theme_stylebox_override(
			"pressed",
			_make_panel_style(Color(0.02, 0.05, 0.10, 0.94), Color(0.46, 0.35, 0.16, 0.90), 1, 10)
		)
		button.add_theme_stylebox_override(
			"focus",
			_make_panel_style(Color(0.05, 0.10, 0.16, 0.94), Color(0.62, 0.47, 0.22, 0.90), 1, 10)
		)
		button.add_theme_stylebox_override(
			"disabled",
			_make_panel_style(Color(0.03, 0.07, 0.12, 0.90), Color(0.50, 0.38, 0.18, 0.85), 1, 10)
		)

	button.add_theme_color_override("font_color", Color(0.88, 0.77, 0.55, 0.98))
	button.add_theme_color_override("font_hover_color", Color(0.95, 0.86, 0.66, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.81, 0.70, 0.50, 0.98))
	button.add_theme_color_override("font_focus_color", Color(0.95, 0.86, 0.66, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.72, 0.62, 0.44, 0.80))
	button.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.96))
	button.add_theme_color_override("icon_normal_color", Color(1.0, 1.0, 1.0, 0.94))
	button.add_theme_color_override("icon_disabled_color", Color(0.72, 0.72, 0.72, 0.62))
	button.add_theme_constant_override("outline_size", 2)
	button.add_theme_constant_override("h_separation", 12)


func _apply_profile_overlay_style() -> void:
	_profile_panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(Color(0.07, 0.055, 0.045, 0.96), Color(0.86, 0.63, 0.24, 1.0), 3, 18, Vector4(28, 24, 28, 24))
	)
	for label_node in [_profile_title_label, _profile_name_label, _profile_score_label]:
		var label := label_node as Label
		if label != null:
			_set_label_style(label, Color(0.95, 0.88, 0.72, 1.0), Color(0.04, 0.03, 0.02, 0.96), 2)
	_set_label_style(_profile_title_label, Color(1.0, 0.78, 0.30, 1.0), Color(0.04, 0.03, 0.02, 0.96), 3)
	_apply_menu_button_style(_reset_profile_button, _secondary_button_texture, false, false)
	_apply_menu_button_style(_close_profile_button, _secondary_button_texture, false, false)


func _set_label_style(label: Label, color: Color, outline_color: Color, outline_size: int) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", outline_color)
	label.add_theme_constant_override("outline_size", outline_size)


func _make_texture_style(
	texture: Texture2D,
	texture_margin: float,
	content_margin_horizontal: float,
	content_margin_vertical: float,
	expand_margin: float
) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.set_texture_margin_all(texture_margin)
	style.set_expand_margin_all(expand_margin)
	style.content_margin_left = content_margin_horizontal
	style.content_margin_right = content_margin_horizontal
	style.content_margin_top = content_margin_vertical
	style.content_margin_bottom = content_margin_vertical
	return style


func _make_panel_style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	return UI_UTILS.panel_style(fill, border, border_width, corner_radius, Vector4(8, 6, 8, 6))


func _load_asset_map() -> Dictionary:
	if not FileAccess.file_exists(MENU_ASSET_MAP_PATH):
		return {}
	var file := FileAccess.open(MENU_ASSET_MAP_PATH, FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed is Dictionary:
		return parsed
	return {}


func _resolve_background_path() -> String:
	var backgrounds: Dictionary = _asset_map.get("backgrounds", {})
	if backgrounds.has("main_menu"):
		return String(backgrounds.get("main_menu", FALLBACK_BG_PATH))
	return _resolve_menu_texture("background", FALLBACK_BG_PATH)


func _resolve_logo_path() -> String:
	return _resolve_menu_texture("logo", FALLBACK_LOGO_PATH)


func _resolve_menu_texture(entry_key: String, fallback_path: String) -> String:
	if _menu_assets.has(entry_key):
		return String(_menu_assets.get(entry_key, fallback_path))
	return fallback_path


func _resolve_menu_icons() -> Dictionary:
	var icon_map: Dictionary = _menu_assets.get("menu_icons", {})
	if icon_map is Dictionary:
		return icon_map
	return {}


func _resolve_menu_icon_path(icon_key: String, fallback_path: String) -> String:
	if _menu_icons.has(icon_key):
		return String(_menu_icons.get(icon_key, fallback_path))
	return fallback_path


func _resolve_mastery_icon_paths() -> Array[String]:
	var resolved_paths: Array[String] = []
	var mastery_icons: Dictionary = _menu_assets.get("reused_mastery_icons", {})
	for i in ELEMENT_KEYS.size():
		var key := ELEMENT_KEYS[i]
		if mastery_icons.has(key):
			resolved_paths.append(String(mastery_icons.get(key, ELEMENT_ICON_FALLBACK_PATHS[i])))
		else:
			resolved_paths.append(ELEMENT_ICON_FALLBACK_PATHS[i])
	return resolved_paths


func _safe_load_texture(path: String, missing_key: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		push_warning("Main menu missing texture for %s at %s" % [missing_key, path])
		return null
	var loaded: Variant = load(path)
	if loaded is Texture2D:
		return loaded as Texture2D
	push_warning("Main menu invalid texture for %s at %s" % [missing_key, path])
	return null


func _scaled_texture(texture: Texture2D, max_side: int) -> Texture2D:
	var image := texture.get_image()
	if image == null:
		return texture
	var source_size := image.get_size()
	var largest_source_side := maxi(source_size.x, source_size.y)
	if largest_source_side <= max_side:
		return texture

	var ratio := float(max_side) / float(largest_source_side)
	var target_size := Vector2i(
		maxi(1, int(round(source_size.x * ratio))),
		maxi(1, int(round(source_size.y * ratio)))
	)
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


func _rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(
		base_rect.position + Vector2(base_rect.size.x * left, base_rect.size.y * top),
		Vector2(base_rect.size.x * width, base_rect.size.y * height)
	)


func _inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(
		rect.position + Vector2(inset, inset),
		Vector2(maxf(0.0, rect.size.x - inset * 2.0), maxf(0.0, rect.size.y - inset * 2.0))
	)


func _set_control_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect.position
	control.size = rect.size
