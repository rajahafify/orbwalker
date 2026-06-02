extends RefCounted
class_name MainMenuLocalizationTest

const MAIN_MENU_VIEW := preload("res://scripts/main_menu/main_menu_view.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")
const LOCALIZATION_BOOTSTRAP := preload("res://scripts/ui/localization_bootstrap.gd")
const TRANSLATION_PATHS := [
	"res://resources/localization/ui_en.tres",
	"res://resources/localization/ui_es.tres",
]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("main_menu_translation_keys_resolve", _test_main_menu_translation_keys_resolve, failures)
	_run_case("main_menu_view_applies_second_locale", _test_main_menu_view_applies_second_locale, failures)
	_run_case("main_menu_settings_uses_full_mobile_surface", _test_main_menu_settings_uses_full_mobile_surface, failures)

	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var previous_locale := TranslationServer.get_locale()
	_install_translations()
	var error_text: String = callable.call()
	TranslationServer.set_locale(previous_locale)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_main_menu_translation_keys_resolve() -> String:
	for locale in ["en", "es"]:
		TranslationServer.set_locale(locale)
		for key in MAIN_MENU_VIEW.localization_keys():
			var translated := TranslationServer.translate(String(key))
			if translated == key:
				return "Expected %s to translate key %s." % [locale, String(key)]
	return ""


func _test_main_menu_view_applies_second_locale() -> String:
	TranslationServer.set_locale("es")
	var fixture := _fixture()
	var host: Control = fixture["host"]
	var view: MainMenuView = fixture["view"]
	view.configure_ui_nodes(host)
	view.apply_static_text()
	view.show_settings({"vfx_speed": "fast", "reduced_motion": true, "game_juice": true, "game_juice_flags": GAME_JUICE_FLAGS_SCRIPT.default_flags()})

	var start_button: Button = fixture["start_run_button"]
	var settings_button: Button = fixture["settings_button"]
	var profile_button: Button = fixture["profile_button"]
	var settings_title := host.find_child("SettingsTitle", true, false) as Label
	var fast_button := host.find_child("SpeedFastButton", true, false) as Button
	var game_juice_label := host.find_child("SettingsGameJuiceLabel", true, false) as Label
	var game_juice_button := host.find_child("SettingsGameJuiceButton", true, false) as Button
	var reduced_motion_button := host.find_child("SettingsReducedMotionButton", true, false) as Button
	var screen_nudge_button := host.find_child("JuiceFlagScreenNudgeButton", true, false) as Button
	var reset_button := host.find_child("SettingsResetDefaultsButton", true, false) as Button
	var close_button := host.find_child("SettingsCloseButton", true, false) as Button

	var error := _expect_text(start_button, "INICIAR PARTIDA", "start button")
	if error != "":
		host.free()
		return error
	error = _expect_text(settings_button, "AJUSTES", "settings button")
	if error != "":
		host.free()
		return error
	error = _expect_text(profile_button, "PERFIL", "profile button")
	if error != "":
		host.free()
		return error
	error = _expect_text(settings_title, "Ajustes", "settings title")
	if error != "":
		host.free()
		return error
	error = _expect_text(fast_button, "RAPIDO  *", "selected speed button")
	if error != "":
		host.free()
		return error
	error = _expect_text(game_juice_label, "Juego jugoso", "game juice label")
	if error != "":
		host.free()
		return error
	error = _expect_text(reduced_motion_button, "MOVIMIENTO REDUCIDO: ON", "reduced motion button")
	if error != "":
		host.free()
		return error
	error = _expect_text(game_juice_button, "JUEGO JUGOSO MAESTRO: ON", "selected game juice button")
	if error != "":
		host.free()
		return error
	error = _expect_text(screen_nudge_button, "EMPUJE DE PANTALLA: ON", "screen nudge flag button")
	if error != "":
		host.free()
		return error
	error = _expect_text(reset_button, "RESTAURAR VALORES", "reset defaults button")
	if error != "":
		host.free()
		return error
	error = _expect_text(close_button, "CERRAR", "settings close button")
	if error != "":
		host.free()
		return error

	host.free()
	return ""


func _test_main_menu_settings_uses_full_mobile_surface() -> String:
	TranslationServer.set_locale("en")
	var fixture := _fixture()
	var host: Control = fixture["host"]
	var view: MainMenuView = fixture["view"]
	var viewport_size := Vector2(540.0, 960.0)
	view.configure_ui_nodes(host)
	view.apply_static_text()
	view.apply_chrome_styles()
	view.layout_ui(viewport_size)
	view.show_settings({"vfx_speed": "normal", "reduced_motion": false, "game_juice": false, "game_juice_flags": GAME_JUICE_FLAGS_SCRIPT.default_flags()})
	var overlay := host.find_child("SettingsOverlay", true, false) as Control
	var panel := host.find_child("SettingsPanel", true, false) as Panel
	var scroll := host.find_child("SettingsScroll", true, false) as ScrollContainer
	var close_button := host.find_child("SettingsCloseButton", true, false) as Button
	if overlay == null or panel == null or scroll == null or close_button == null:
		host.free()
		return "Expected settings overlay, panel, scroll, and close nodes to exist."
	if not overlay.visible:
		host.free()
		return "Expected settings overlay to be visible after show_settings()."
	if panel.size.x < viewport_size.x * 0.90 or panel.size.y < viewport_size.y * 0.90:
		host.free()
		return "Expected main-menu settings panel to use most of the mobile viewport."
	if panel.position.x > 24.0 or panel.position.y > 24.0:
		host.free()
		return "Expected main-menu settings panel to avoid desktop-style centered margins on mobile."
	if close_button.custom_minimum_size.y < 64.0:
		host.free()
		return "Expected main-menu settings close button to remain touch-sized on mobile."
	host.free()
	return ""


func _install_translations() -> void:
	LOCALIZATION_BOOTSTRAP.ensure_loaded()
	for path in TRANSLATION_PATHS:
		var translation := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as Translation
		if translation != null:
			TranslationServer.add_translation(translation)


func _expect_text(node: Control, expected: String, label: String) -> String:
	if node == null:
		return "Expected %s node to exist." % label
	var actual := ""
	if node is Button:
		actual = (node as Button).text
	elif node is Label:
		actual = (node as Label).text
	else:
		return "Expected %s to be a Button or Label." % label
	if actual != expected:
		return "Expected %s text '%s', got '%s'." % [label, expected, actual]
	return ""


func _fixture() -> Dictionary:
	var host := Control.new()
	var scratch := Control.new()
	host.add_child(scratch)
	var menu_button_column := VBoxContainer.new()
	host.add_child(menu_button_column)
	var start_run_button := Button.new()
	var generate_log_toggle := CheckButton.new()
	var continue_button := Button.new()
	var collection_button := Button.new()
	var tutorial_button := Button.new()
	var settings_button := Button.new()
	var quit_button := Button.new()
	for button in [start_run_button, generate_log_toggle, continue_button, collection_button, tutorial_button, settings_button, quit_button]:
		menu_button_column.add_child(button)

	var footer_actions := HBoxContainer.new()
	host.add_child(footer_actions)
	var profile_button := Button.new()
	var achievements_button := Button.new()
	var footer_settings_button := Button.new()
	for button in [profile_button, achievements_button, footer_settings_button]:
		footer_actions.add_child(button)

	var element_labels: Array = []
	for index in range(6):
		element_labels.append(Label.new())
	var stat_titles: Array = []
	var stat_values: Array = []
	for index in range(3):
		stat_titles.append(Label.new())
		stat_values.append(Label.new())

	var root_nodes := {
		"background_texture": TextureRect.new(),
		"overlay_tint": ColorRect.new(),
		"outer_frame": Control.new(),
		"outer_border_texture": TextureRect.new(),
		"logo_texture": TextureRect.new(),
		"menu_button_column": menu_button_column,
		"start_run_button": start_run_button,
		"generate_log_toggle": generate_log_toggle,
		"continue_button": continue_button,
		"collection_button": collection_button,
		"tutorial_button": tutorial_button,
		"settings_button": settings_button,
		"quit_button": quit_button,
		"element_row": HBoxContainer.new(),
		"stats_panel": Panel.new(),
		"stats_row": HBoxContainer.new(),
		"footer_actions": footer_actions,
		"profile_button": profile_button,
		"achievements_button": achievements_button,
		"footer_settings_button": footer_settings_button,
		"version_label": Label.new(),
		"status_label": Label.new(),
		"profile_overlay": Control.new(),
		"profile_panel": PanelContainer.new(),
		"profile_title_label": Label.new(),
		"profile_name_label": Label.new(),
		"profile_score_label": Label.new(),
		"reset_profile_button": Button.new(),
		"close_profile_button": Button.new(),
		"element_icons": [],
		"element_labels": element_labels,
		"stat_icons": [],
		"stat_titles": stat_titles,
		"stat_values": stat_values,
	}
	var view: MainMenuView = MAIN_MENU_VIEW.new()
	view.bind(root_nodes)
	_parent_unowned_nodes(scratch, root_nodes)
	return {
		"host": host,
		"view": view,
		"start_run_button": start_run_button,
		"settings_button": settings_button,
		"profile_button": profile_button,
	}


func _parent_unowned_nodes(parent: Node, value: Variant) -> void:
	if value is Dictionary:
		for key in Dictionary(value).keys():
			_parent_unowned_nodes(parent, Dictionary(value)[key])
	elif value is Array:
		for item in Array(value):
			_parent_unowned_nodes(parent, item)
	elif value is Node:
		var node := value as Node
		if node.get_parent() == null:
			parent.add_child(node)
