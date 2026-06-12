extends RefCounted
class_name PlayerLoadoutSlotDetailPopoverTest

const POPOVER_SCRIPT := preload("res://scripts/ui/player_loadout_slot_detail_popover.gd")


class Providers:
	extends RefCounted

	var hud_nodes := {}
	var player_data := {}
	var selected_equipment_slot := -1
	var selected_consumable_slot := -1
	var rects: Array = []

	func hud_nodes_provider() -> Dictionary:
		return hud_nodes

	func player_data_provider() -> Dictionary:
		return player_data

	func selected_equipment_slot_provider() -> int:
		return selected_equipment_slot

	func selected_consumable_slot_provider() -> int:
		return selected_consumable_slot

	func lookup_content(content_id: String) -> Dictionary:
		return {"display_name": "Sword", "description": "A clean edge.", "sell_value": 3, "icon_key": content_id}

	func apply_rect(control: Control, rect: Rect2) -> void:
		rects.append([control.name, rect])
		control.position = rect.position
		control.size = rect.size


class Recorder:
	extends RefCounted

	var sell_events: Array = []

	func sell_slot_requested(slot_type: String, slot_index: int) -> void:
		sell_events.append([slot_type, slot_index])


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("creates_bubble_from_bound_nodes", _test_creates_bubble_from_bound_nodes, failures)
	_run_case("selected_slot_sell_uses_providers_and_callback", _test_selected_slot_sell_uses_providers_and_callback, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_creates_bubble_from_bound_nodes() -> String:
	var providers := _providers()
	var recorder := Recorder.new()
	var popover: Variant = _bound_popover(providers, recorder)
	popover._ensure_slot_detail_popover()
	if providers.hud_nodes.get("popover_parent").get_node_or_null("SlotDetailBubble") == null:
		return "Expected popover bubble under provided parent."
	popover._set_slot_popover_content("equipment", 0, "Sword", "A clean edge.", Rect2(Vector2(20, 20), Vector2(50, 50)))
	if popover._slot_detail_bubble == null or not popover._slot_detail_bubble.visible:
		return "Expected helper-owned bubble to become visible."
	if popover._slot_detail_title.text != "Sword" or popover._slot_detail_description.text != "A clean edge.":
		return "Expected helper-owned title and description."
	return ""


func _test_selected_slot_sell_uses_providers_and_callback() -> String:
	var providers := _providers()
	var recorder := Recorder.new()
	providers.selected_equipment_slot = 0
	providers.player_data = {"progression": {"equipment_slots": ["sword"], "consumable_slots": []}}
	var equipment_row := Control.new()
	equipment_row.name = "EquipmentRow"
	var equipment_slot := Control.new()
	equipment_slot.name = "EquipmentSlot0"
	equipment_slot.size = Vector2(50, 50)
	equipment_row.add_child(equipment_slot)
	providers.hud_nodes["equipment_icons"] = equipment_row
	var popover: Variant = _bound_popover(providers, recorder)
	popover._ensure_slot_detail_popover()
	popover._update_selected_slot_popover()
	if not popover._slot_detail_sell_button.visible:
		return "Expected sell button for selected filled equipment slot."
	if popover._slot_detail_sell_button.text != "Sell  +3 gold":
		return "Expected sell value from content lookup provider."
	popover._on_slot_detail_sell_pressed()
	if recorder.sell_events != [["equipment", 0]]:
		return "Expected sell callback with selected slot."
	return ""


func _providers() -> Providers:
	var providers := Providers.new()
	var parent := Control.new()
	parent.name = "PopoverParent"
	parent.size = Vector2(640, 360)
	providers.hud_nodes = {"popover_parent": parent, "popover_z_index": 210}
	return providers


func _bound_popover(providers: Providers, recorder: Recorder) -> Variant:
	var popover: Variant = POPOVER_SCRIPT.new()
	(
		popover
		. bind(
			{
				"hud_nodes_provider": Callable(providers, "hud_nodes_provider"),
				"player_data_provider": Callable(providers, "player_data_provider"),
				"selected_equipment_slot_provider": Callable(providers, "selected_equipment_slot_provider"),
				"selected_consumable_slot_provider": Callable(providers, "selected_consumable_slot_provider"),
				"content_lookup": Callable(providers, "lookup_content"),
				"apply_rect": Callable(providers, "apply_rect"),
			},
			{POPOVER_SCRIPT.CALLBACK_SELL_SLOT_REQUESTED: Callable(recorder, "sell_slot_requested")}
		)
	)
	return popover
