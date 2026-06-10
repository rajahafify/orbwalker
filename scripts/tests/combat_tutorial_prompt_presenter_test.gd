extends RefCounted
class_name CombatTutorialPromptPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_prompt_presenter.gd")
const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("show_creates_prompt_under_layout_root", _test_show_creates_prompt_under_layout_root, failures)
	_run_case("bottom_anchor_uses_large_prompt_layout", _test_bottom_anchor_uses_large_prompt_layout, failures)
	_run_case("hide_and_relayout_preserve_prompt_instance", _test_hide_and_relayout_preserve_prompt_instance, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
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


func _test_show_creates_prompt_under_layout_root() -> String:
	var fixture := _fixture()
	var host: Control = fixture["host"]
	var layout_root: Control = fixture["layout_root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("Swap these two orbs.", TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD)
	var panel: Panel = presenter.prompt_panel()
	var label: Label = presenter.prompt_label()
	var error := ""
	if panel == null or label == null:
		error = "Expected prompt panel and label to be created."
	elif panel.get_parent() != layout_root:
		error = "Expected prompt panel under CombatLayoutRoot."
	elif not panel.visible or not presenter.is_visible():
		error = "Expected prompt to be visible after show."
	elif label.text != "Swap these two orbs.":
		error = "Expected prompt label text to be applied."
	elif int(label.get_theme_font_size("font_size")) != 24:
		error = "Expected above-board prompt font size."
	host.free()
	return error


func _test_bottom_anchor_uses_large_prompt_layout() -> String:
	var fixture := _fixture()
	var host: Control = fixture["host"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("Long bottom prompt.", TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM)
	var panel: Panel = presenter.prompt_panel()
	var label: Label = presenter.prompt_label()
	var error := ""
	if panel == null or label == null:
		error = "Expected prompt nodes to be created."
	elif int(label.get_theme_font_size("font_size")) != 38:
		error = "Expected bottom prompt font size."
	elif absf(panel.size.y - 236.0) > 0.01:
		error = "Expected bottom prompt height."
	elif panel.position.y < 0.0:
		error = "Expected bottom prompt to stay inside parent bounds."
	host.free()
	return error


func _test_hide_and_relayout_preserve_prompt_instance() -> String:
	var fixture := _fixture()
	var host: Control = fixture["host"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("Intent prompt.", TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BELOW_INTENT)
	var panel: Panel = presenter.prompt_panel()
	presenter.hide()
	presenter.layout()
	var error := ""
	if presenter.prompt_panel() != panel:
		error = "Expected hide/layout to preserve the prompt panel instance."
	elif presenter.is_visible():
		error = "Expected prompt to be hidden."
	host.free()
	return error


func _fixture() -> Dictionary:
	var host := Control.new()
	host.name = "Combat"
	host.size = Vector2(1080, 1920)

	var layout_root := Control.new()
	layout_root.name = "CombatLayoutRoot"
	layout_root.size = Vector2(1080, 1920)
	host.add_child(layout_root)

	var board_panel := Control.new()
	board_panel.name = "BoardPanel"
	board_panel.position = Vector2(276, 650)
	board_panel.size = Vector2(528, 528)
	layout_root.add_child(board_panel)

	var enemy_panel := Control.new()
	enemy_panel.name = "EnemyPanel"
	layout_root.add_child(enemy_panel)
	var enemy_panel_root := Control.new()
	enemy_panel_root.name = "EnemyPanelRoot"
	enemy_panel.add_child(enemy_panel_root)
	var intent_row := Control.new()
	intent_row.name = "IntentRow"
	intent_row.position = Vector2(220, 350)
	intent_row.size = Vector2(640, 72)
	enemy_panel_root.add_child(intent_row)

	var player_hud := Control.new()
	player_hud.name = "PlayerHudSection"
	player_hud.position = Vector2(0, 1500)
	player_hud.size = Vector2(1080, 280)
	layout_root.add_child(player_hud)

	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(host)
	return {
		"host": host,
		"layout_root": layout_root,
		"presenter": presenter,
	}
