extends RefCounted
class_name CombatTutorialEndOverlayCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_overlay_coordinator.gd")


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
	_run_case("show_uses_latest_board_panel_rect_for_layout", _test_show_uses_latest_board_panel_rect_for_layout, failures)
	_run_case("buttons_emit_bound_callbacks", _test_buttons_emit_bound_callbacks, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_show_uses_latest_board_panel_rect_for_layout() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var coordinator: Variant = fixture["coordinator"]
	coordinator.set_board_panel_rect(Rect2(Vector2(16.0, 500.0), Vector2(1048.0, 756.0)))
	coordinator.show("end")
	if not coordinator.is_visible():
		root.free()
		return "Expected show() to make tutorial end overlay visible."
	if root.get_node_or_null("TutorialEndOverlay") == null:
		root.free()
		return "Expected coordinator to create TutorialEndOverlay under the bound parent."
	var modal: Panel = coordinator.modal()
	if modal == null:
		root.free()
		return "Expected modal node to be exposed after show()."
	if not is_equal_approx(modal.position.y, 564.0):
		root.free()
		return "Expected modal y-position to use latest board panel rect, got %s." % str(modal.position.y)
	coordinator.hide()
	if coordinator.is_visible():
		root.free()
		return "Expected hide() to make tutorial end overlay invisible."
	root.free()
	return ""


func _test_buttons_emit_bound_callbacks() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var coordinator: Variant = fixture["coordinator"]
	var recorder: CallbackRecorder = fixture["recorder"]
	coordinator.show("end")
	coordinator.continue_button().emit_signal("pressed")
	coordinator.main_menu_button().emit_signal("pressed")
	if recorder.continue_count != 1 or recorder.main_menu_count != 1:
		root.free()
		return "Expected tutorial end callbacks to route through coordinator."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	root.size = Vector2(1080.0, 1920.0)
	var equipment_icons := HBoxContainer.new()
	equipment_icons.name = "EquipmentIcons"
	root.add_child(equipment_icons)
	var equipment_slot := Control.new()
	equipment_slot.name = "EquipmentSlot"
	equipment_slot.visible = true
	equipment_slot.position = Vector2(40.0, 120.0)
	equipment_slot.size = Vector2(80.0, 80.0)
	equipment_icons.add_child(equipment_slot)
	var mastery_panel := Panel.new()
	mastery_panel.name = "ElementalMasteryPanel"
	mastery_panel.position = Vector2(20.0, 1400.0)
	mastery_panel.size = Vector2(1040.0, 160.0)
	root.add_child(mastery_panel)
	var recorder := CallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(
		root,
		{
			"equipment_icons": equipment_icons,
			"elemental_mastery_panel": mastery_panel,
		},
		{
			"continue": Callable(recorder, "continue_pressed"),
			"main_menu": Callable(recorder, "main_menu_pressed"),
		}
	)
	return {
		"root": root,
		"coordinator": coordinator,
		"recorder": recorder,
	}
