extends RefCounted
class_name CombatTutorialEndOverlayPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_overlay_presenter.gd")


class CallbackRecorder:
	extends RefCounted

	var continue_count := 0
	var main_menu_count := 0

	func continue_pressed() -> void:
		continue_count += 1

	func main_menu_pressed() -> void:
		main_menu_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("end_step_creates_modal_and_menu_actions", _test_end_step_creates_modal_and_menu_actions, failures)
	_run_case("shortsword_step_focuses_first_equipment", _test_shortsword_step_focuses_first_equipment, failures)
	_run_case("hide_clears_visibility", _test_hide_clears_visibility, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_end_step_creates_modal_and_menu_actions() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	presenter.show("end", _layout_config())
	if not presenter.is_visible():
		root.free()
		return "Expected end overlay to be visible."
	if presenter.overlay() == null or presenter.overlay().get_parent() != root:
		root.free()
		return "Expected overlay to be parented under the bound root."
	if presenter.title_label().text != "End of tutorial":
		root.free()
		return "Expected end step title."
	if presenter.continue_button().text != "CONTINUE":
		root.free()
		return "Expected end step continue text."
	if not presenter.main_menu_button().visible:
		root.free()
		return "Expected main-menu button to be visible on final step."
	if not _vector_equal(presenter.modal().size, Vector2(820.0, 438.0)):
		root.free()
		return "Expected final modal size to match current combat layout."
	presenter.continue_button().emit_signal("pressed")
	presenter.main_menu_button().emit_signal("pressed")
	if recorder.continue_count != 1 or recorder.main_menu_count != 1:
		root.free()
		return "Expected buttons to forward callbacks."
	root.free()
	return ""


func _test_shortsword_step_focuses_first_equipment() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("shortsword", _layout_config())
	if presenter.title_label().text != "Iron Shortsword":
		root.free()
		return "Expected shortsword step title."
	if presenter.continue_button().text != "NEXT":
		root.free()
		return "Expected shortsword step continue text."
	if presenter.main_menu_button().visible:
		root.free()
		return "Expected main-menu button to be hidden before the final step."
	var focus: Panel = presenter.equipment_focus()
	if focus == null or not focus.visible:
		root.free()
		return "Expected equipment focus to be visible."
	if not _vector_equal(focus.position, Vector2(20.0, 30.0)):
		root.free()
		return "Expected equipment focus to grow around first equipment icon."
	if not _vector_equal(focus.size, Vector2(84.0, 84.0)):
		root.free()
		return "Expected equipment focus size to grow around first equipment icon."
	if presenter.mastery_focus().visible or presenter.attack_focus().visible:
		root.free()
		return "Expected only equipment focus to be visible."
	root.free()
	return ""


func _test_hide_clears_visibility() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.show("mastery", _layout_config())
	presenter.hide()
	if presenter.is_visible():
		root.free()
		return "Expected hide() to clear overlay visibility."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	root.size = Vector2(1080.0, 1920.0)
	var equipment_icons := Control.new()
	equipment_icons.name = "EquipmentIcons"
	equipment_icons.position = Vector2(24.0, 34.0)
	equipment_icons.size = Vector2(260.0, 90.0)
	root.add_child(equipment_icons)
	var equipment_icon := Control.new()
	equipment_icon.name = "IronShortswordIcon"
	equipment_icon.position = Vector2(6.0, 6.0)
	equipment_icon.size = Vector2(64.0, 64.0)
	equipment_icons.add_child(equipment_icon)
	var mastery_panel := Panel.new()
	mastery_panel.name = "ElementalMasteryPanel"
	mastery_panel.position = Vector2(100.0, 200.0)
	mastery_panel.size = Vector2(300.0, 120.0)
	root.add_child(mastery_panel)
	var recorder := CallbackRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(
		root,
		{
			"equipment_icons": equipment_icons,
			"elemental_mastery_panel": mastery_panel,
		},
		{
			PRESENTER_SCRIPT.CALLBACK_CONTINUE: Callable(recorder, "continue_pressed"),
			PRESENTER_SCRIPT.CALLBACK_MAIN_MENU: Callable(recorder, "main_menu_pressed"),
		}
	)
	return {
		"root": root,
		"presenter": presenter,
		"recorder": recorder,
	}


func _layout_config() -> Dictionary:
	return {"board_panel_rect": Rect2(Vector2(16.0, 660.0), Vector2(1048.0, 756.0))}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
