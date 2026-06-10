extends RefCounted
class_name ShopModelTest


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("status_focus_and_transition_lock", _test_status_focus_and_transition_lock, failures)
	_run_case("action_guard_allows_once_per_frame", _test_action_guard_allows_once_per_frame, failures)
	_run_case("selected_slot_kind_requires_occupied_slot", _test_selected_slot_kind_requires_occupied_slot, failures)

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


func _test_status_focus_and_transition_lock() -> String:
	var model := ShopModel.new()
	model.set_status("Bought item.", true)
	if model.status_message != "Bought item." or not model.status_positive:
		return "Expected set_status to update text and polarity."
	model.reset_status()
	if model.status_message != ShopModel.DEFAULT_STATUS or not model.status_positive:
		return "Expected reset_status to restore default status."
	model.selected_equipment_slot = 2
	model.selected_consumable_slot = 1
	model.clear_inventory_focus()
	if model.selected_equipment_slot != -1 or model.selected_consumable_slot != -1:
		return "Expected clear_inventory_focus to clear both selected slots."
	model.begin_transition_lock()
	if not model.transition_locked:
		return "Expected begin_transition_lock to set transition_locked."
	model.end_transition_lock()
	if model.transition_locked:
		return "Expected end_transition_lock to clear transition_locked."
	return ""


func _test_action_guard_allows_once_per_frame() -> String:
	var model := ShopModel.new()
	if not model.try_begin_shop_action():
		return "Expected first action in a frame to be allowed."
	if model.try_begin_shop_action():
		return "Expected second action in same frame to be rejected."
	return ""


func _test_selected_slot_kind_requires_occupied_slot() -> String:
	var model := ShopModel.new()
	var progression := {
		"equipment_slots": ["shortsword", "", "buckler"],
		"consumable_slots": ["potion", ""],
	}
	model.selected_equipment_slot = 0
	if model.selected_slot_kind(progression) != "equipment":
		return "Expected occupied equipment slot to select equipment."
	model.selected_equipment_slot = 1
	if model.selected_slot_kind(progression) != "":
		return "Expected empty equipment slot not to select a kind."
	model.selected_equipment_slot = -1
	model.selected_consumable_slot = 0
	if model.selected_slot_kind(progression) != "consumable":
		return "Expected occupied consumable slot to select consumable."
	model.selected_consumable_slot = 8
	if model.selected_slot_kind(progression) != "":
		return "Expected out-of-range consumable slot not to select a kind."
	return ""
