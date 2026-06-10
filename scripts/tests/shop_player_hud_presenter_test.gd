extends RefCounted
class_name ShopPlayerHudPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/shop/shop_player_hud_presenter.gd")


class PlayerLoadoutHudStub:
	extends RefCounted

	signal equipment_slot_selected(index: int)
	signal consumable_slot_selected(index: int)
	signal sell_slot_requested(slot_type: String, slot_index: int)

	var bound_nodes: Dictionary = {}
	var layout_override: Dictionary = {}
	var layout_updates := 0
	var selected_equipment := -99
	var selected_consumable := -99
	var updated_payloads: Array[Dictionary] = []
	var mastery_rows: Array = []
	var mastery_payloads: Array[Dictionary] = []
	var chrome_nodes: Dictionary = {}
	var handled_clicks: Array[Vector2] = []
	var hidden_popovers := 0
	var lookups: Array[String] = []

	func bind_player_hud(nodes: Dictionary) -> void:
		bound_nodes = nodes.duplicate()

	func set_player_hud_layout_override(layout: Dictionary) -> void:
		layout_override = layout.duplicate(true)

	func update_player_hud_layout() -> void:
		layout_updates += 1

	func set_selected_equipment_slot(slot_index: int) -> void:
		selected_equipment = slot_index

	func set_selected_consumable_slot(slot_index: int) -> void:
		selected_consumable = slot_index

	func update_player_data(payload: Dictionary) -> void:
		updated_payloads.append(payload.duplicate(true))

	func populate_combat_mastery_panel(row: Control, mastery_levels: Dictionary) -> void:
		mastery_rows.append(row)
		mastery_payloads.append(mastery_levels.duplicate(true))

	func apply_player_hud_chrome(nodes: Dictionary) -> void:
		chrome_nodes = nodes.duplicate()

	func handle_global_click(global_position: Vector2) -> bool:
		handled_clicks.append(global_position)
		return true

	func hide_slot_detail_popover() -> void:
		hidden_popovers += 1

	func lookup_content_definition(content_id: String) -> Dictionary:
		lookups.append(content_id)
		return {"id": content_id}


class FakeVisuals:
	extends RefCounted

	var hero_portrait_requests := 0

	func hero_portrait() -> Texture2D:
		hero_portrait_requests += 1
		return ImageTexture.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("ensure_scene_and_hud_nodes_preserve_contract", _test_ensure_scene_and_hud_nodes_preserve_contract, failures)
	_run_case("bind_layout_and_chrome_delegate_to_loadout_hud", _test_bind_layout_and_chrome_delegate_to_loadout_hud, failures)
	_run_case("render_and_forwarders_delegate_to_loadout_hud", _test_render_and_forwarders_delegate_to_loadout_hud, failures)
	_run_case("loadout_hud_signals_forward_through_presenter", _test_loadout_hud_signals_forward_through_presenter, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_ensure_scene_and_hud_nodes_preserve_contract() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.ensure_scene()
	var nodes: Dictionary = presenter.hud_nodes()
	var result := ""
	if presenter.section() == null or presenter.section().name != "PlayerHudSection":
		result = "Expected presenter to instance the shared PlayerHudSection scene."
	elif presenter.section().get_parent() != root:
		result = "Expected PlayerHudSection to be added under the supplied parent."
	elif String(presenter.section().scene_file_path) != PRESENTER_SCRIPT.player_hud_scene_path():
		result = "Expected shop PlayerHUD section to use the shared HUD scene."
	elif nodes.get("section") != presenter.section():
		result = "Expected HUD node map to include the section node."
	else:
		for key in PRESENTER_SCRIPT.HUD_NODE_NAMES.keys():
			if not nodes.has(key):
				result = "Expected HUD node map key: %s." % key
				break
			if nodes.get(key) == null:
				result = "Expected HUD node map to resolve key: %s." % key
				break
	root.free()
	return result


func _test_bind_layout_and_chrome_delegate_to_loadout_hud() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	var presenter: Variant = fixture["presenter"]
	var popover_parent := Control.new()
	root.add_child(popover_parent)
	presenter.bind_player_hud(popover_parent, 51)
	presenter.set_layout_override({"section": Rect2(Vector2(1, 2), Vector2(3, 4))})
	presenter.update_layout()
	presenter.apply_chrome()
	var result := ""
	if hud.bound_nodes.get("popover_parent") != popover_parent or int(hud.bound_nodes.get("popover_z_index", 0)) != 51:
		result = "Expected bind_player_hud to include popover routing."
	elif hud.bound_nodes.get("section") != presenter.section():
		result = "Expected bind_player_hud to pass the presenter HUD section."
	elif Rect2(hud.layout_override.get("section", Rect2())) != Rect2(Vector2(1, 2), Vector2(3, 4)):
		result = "Expected layout override to delegate to PlayerLoadoutHud."
	elif hud.layout_updates != 1:
		result = "Expected update_layout to delegate once."
	elif hud.chrome_nodes.get("section") != presenter.section():
		result = "Expected apply_chrome to delegate HUD nodes."
	root.free()
	return result


func _test_render_and_forwarders_delegate_to_loadout_hud() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	var visuals: FakeVisuals = fixture["visuals"]
	var presenter: Variant = fixture["presenter"]
	presenter.render_player_build({
		"selected_equipment_slot": 2,
		"selected_consumable_slot": 1,
		"player_state": {"hp": 8},
		"progression": {"mastery_levels": {"Fire": 2}},
	})
	presenter.render_elemental_mastery_panel({"Fire": 2})
	var handled: bool = presenter.handle_global_click(Vector2(10, 20))
	presenter.clear_inventory_focus()
	var lookup: Dictionary = presenter.lookup_content_definition("shortsword")
	var result := ""
	if hud.selected_equipment != -1 or hud.selected_consumable != -1:
		result = "Expected clear_inventory_focus to clear both selected slots after render."
	elif hud.updated_payloads.size() != 1 or not bool(hud.updated_payloads[0].get("selectable_equipment", false)):
		result = "Expected render_player_build to send selectable shop HUD payload."
	elif visuals.hero_portrait_requests != 1:
		result = "Expected render_player_build to request the hero portrait."
	elif hud.mastery_rows != [presenter.mastery_cards()] or hud.mastery_payloads.size() != 1:
		result = "Expected mastery panel rendering to target the shared mastery cards."
	elif not handled or hud.handled_clicks != [Vector2(10, 20)]:
		result = "Expected global click handling to delegate."
	elif hud.hidden_popovers != 1:
		result = "Expected clear_inventory_focus to hide the slot detail popover."
	elif lookup.get("id") != "shortsword" or hud.lookups != ["shortsword"]:
		result = "Expected content lookup to delegate."
	root.free()
	return result


func _test_loadout_hud_signals_forward_through_presenter() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	var presenter: Variant = fixture["presenter"]
	var counters := {
		"equipment": -1,
		"consumable": -1,
		"sell_type": "",
		"sell_index": -1,
	}
	presenter.equipment_slot_selected.connect(func(index: int): counters["equipment"] = index)
	presenter.consumable_slot_selected.connect(func(index: int): counters["consumable"] = index)
	presenter.sell_slot_requested.connect(func(slot_type: String, slot_index: int):
		counters["sell_type"] = slot_type
		counters["sell_index"] = slot_index
	)
	hud.equipment_slot_selected.emit(3)
	hud.consumable_slot_selected.emit(2)
	hud.sell_slot_requested.emit("equipment", 1)
	var result := ""
	if counters["equipment"] != 3:
		result = "Expected equipment slot signal to forward."
	elif counters["consumable"] != 2:
		result = "Expected consumable slot signal to forward."
	elif counters["sell_type"] != "equipment" or counters["sell_index"] != 1:
		result = "Expected sell slot signal to forward."
	root.free()
	return result


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "ShopRoot"
	var hud := PlayerLoadoutHudStub.new()
	var visuals := FakeVisuals.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root, hud, visuals)
	return {
		"root": root,
		"hud": hud,
		"visuals": visuals,
		"presenter": presenter,
	}
