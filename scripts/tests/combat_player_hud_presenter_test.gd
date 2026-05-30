extends RefCounted
class_name CombatPlayerHudPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_player_hud_presenter.gd")


class PlayerLoadoutHudStub:
	extends RefCounted

	var bound_nodes: Dictionary = {}
	var updated_payloads: Array[Dictionary] = []
	var rail_layout_calls: Array[Dictionary] = []
	var handled_clicks: Array[Vector2] = []
	var hidden_popovers := 0
	var lookups: Array[String] = []
	var hovered: Array[int] = []
	var clear_hovered_count := 0
	var feedback: Array[Dictionary] = []
	var clear_feedback_count := 0
	var pulsed_sources: Array = []
	var clear_hover_ui_count := 0

	func bind_player_hud(nodes: Dictionary) -> void:
		bound_nodes = nodes.duplicate()

	func update_player_data(payload: Dictionary) -> void:
		updated_payloads.append(payload.duplicate(true))

	func apply_loadout_rail_layout(equipment_icons: Control, equipment_rect: Rect2, consumable_icons: Control, consumable_rect: Rect2) -> void:
		rail_layout_calls.append({
			"equipment_icons": equipment_icons,
			"equipment_rect": equipment_rect,
			"consumable_icons": consumable_icons,
			"consumable_rect": consumable_rect,
		})

	func handle_global_click(global_position: Vector2) -> bool:
		handled_clicks.append(global_position)
		return true

	func hide_slot_detail_popover() -> void:
		hidden_popovers += 1

	func lookup_content_definition(item_id: String) -> Dictionary:
		lookups.append(item_id)
		return {"id": item_id}

	func clear_hovered_combat_mastery(_cards: Control) -> void:
		clear_hovered_count += 1

	func set_hovered_combat_mastery(_cards: Control, orb_id: int) -> void:
		hovered.append(orb_id)

	func clear_combat_mastery_feedback(_cards: Control) -> void:
		clear_feedback_count += 1

	func set_combat_mastery_feedback(_cards: Control, orb_id: int, total: int) -> void:
		feedback.append({"orb_id": orb_id, "total": total})

	func pulse_modifier_sources(sources: Array) -> void:
		pulsed_sources = sources.duplicate(true)

	func clear_combat_mastery_hover_ui(_cards: Control) -> void:
		clear_hover_ui_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("hud_nodes_from_root_nodes_preserves_contract_keys", _test_hud_nodes_from_root_nodes_preserves_contract_keys, failures)
	_run_case("bind_player_hud_uses_layout_root_as_default_popover_parent", _test_bind_player_hud_uses_layout_root_as_default_popover_parent, failures)
	_run_case("render_player_loadout_updates_data_layout_and_hidden_rows", _test_render_player_loadout_updates_data_layout_and_hidden_rows, failures)
	_run_case("hud_forwarders_and_vfx_targets_delegate", _test_hud_forwarders_and_vfx_targets_delegate, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_hud_nodes_from_root_nodes_preserves_contract_keys() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var popover_parent := Control.new()
	root.add_child(popover_parent)
	var nodes: Dictionary = PRESENTER_SCRIPT.hud_nodes_from_root_nodes(fixture["root_nodes"], popover_parent, 345)
	for key in PRESENTER_SCRIPT.HUD_NODE_BINDINGS.keys():
		if not nodes.has(key):
			root.free()
			return "Expected HUD binding key: %s." % key
	if nodes.get("popover_parent") != popover_parent or int(nodes.get("popover_z_index", 0)) != 345:
		root.free()
		return "Expected popover options to be included when provided."
	root.free()
	return ""


func _test_bind_player_hud_uses_layout_root_as_default_popover_parent() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	presenter.bind_player_hud()
	if hud.bound_nodes.get("popover_parent") != fixture["root_nodes"].get("_layout_root"):
		root.free()
		return "Expected layout root as default popover parent."
	if int(hud.bound_nodes.get("popover_z_index", 0)) != 210:
		root.free()
		return "Expected default popover z-index."
	if hud.bound_nodes.get("section") != fixture["root_nodes"].get("_player_hud_section"):
		root.free()
		return "Expected section binding to resolve from root nodes."
	root.free()
	return ""


func _test_render_player_loadout_updates_data_layout_and_hidden_rows() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	presenter.render_player_loadout({"hp": 7})
	if hud.updated_payloads.size() != 1 or int(hud.updated_payloads[0].get("hp", 0)) != 7:
		root.free()
		return "Expected render to update player data."
	if hud.rail_layout_calls.size() != 1:
		root.free()
		return "Expected render to apply rail layout immediately."
	if hud.rail_layout_calls[0].get("equipment_icons") != fixture["root_nodes"].get("_equipment_icons"):
		root.free()
		return "Expected equipment icons to be passed to rail layout."
	if fixture["root_nodes"].get("_relic_row").visible or fixture["root_nodes"].get("_mastery_strip").visible:
		root.free()
		return "Expected relic row and mastery strip to be hidden after render."
	root.free()
	return ""


func _test_hud_forwarders_and_vfx_targets_delegate() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var hud: PlayerLoadoutHudStub = fixture["hud"]
	if not presenter.handle_global_click(Vector2(5.0, 6.0)):
		root.free()
		return "Expected handled click to return true from HUD."
	presenter.hide_slot_popover()
	var lookup: Dictionary = presenter.lookup_content_definition("sword")
	presenter.clear_hovered_mastery()
	presenter.set_hovered_mastery(2)
	presenter.clear_mastery_feedback()
	presenter.set_mastery_feedback(3, 11)
	presenter.pulse_modifier_sources([{"id": "ring"}])
	presenter.clear_mastery_hover_ui()
	if hud.handled_clicks != [Vector2(5.0, 6.0)] or hud.hidden_popovers != 1 or lookup.get("id") != "sword":
		root.free()
		return "Expected click, popover, and lookup to delegate."
	if hud.clear_hovered_count != 1 or hud.hovered != [2] or hud.clear_feedback_count != 1:
		root.free()
		return "Expected mastery hover/feedback clears to delegate."
	if hud.feedback.size() != 1 or int(hud.feedback[0].get("total", 0)) != 11:
		root.free()
		return "Expected mastery feedback total to delegate."
	if hud.pulsed_sources.size() != 1 or hud.clear_hover_ui_count != 1:
		root.free()
		return "Expected modifier pulse and hover UI clear to delegate."
	var target: Vector2 = presenter.vfx_target_global("_player_hp_bar", 0.25)
	if not _vector_equal(target, Vector2(140.0, 65.0)):
		root.free()
		return "Expected VFX target from control global rect."
	if not _vector_equal(presenter.vfx_size("_player_hp_bar"), Vector2(80.0, 20.0)):
		root.free()
		return "Expected VFX size from control global rect."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var root_nodes := {
		"_layout_root": root,
	}
	for key in PRESENTER_SCRIPT.HUD_NODE_BINDINGS.values():
		var node := Control.new()
		node.name = String(key).trim_prefix("_")
		node.visible = true
		root.add_child(node)
		root_nodes[String(key)] = node
	var player_hp_bar := Control.new()
	player_hp_bar.name = "PlayerHpBarTarget"
	player_hp_bar.position = Vector2(100.0, 60.0)
	player_hp_bar.size = Vector2(80.0, 20.0)
	root.add_child(player_hp_bar)
	root_nodes["_player_hp_bar"] = player_hp_bar
	root_nodes["_enemy_portrait"] = root_nodes.get("_hero_portrait")
	root_nodes["_player_portrait"] = root_nodes.get("_hero_portrait")
	var hud := PlayerLoadoutHudStub.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(hud, root_nodes)
	return {
		"root": root,
		"root_nodes": root_nodes,
		"hud": hud,
		"presenter": presenter,
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
