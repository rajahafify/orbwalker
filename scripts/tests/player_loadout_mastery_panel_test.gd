extends RefCounted
class_name PlayerLoadoutMasteryPanelTest

const MASTERY_PANEL_SCRIPT := preload("res://scripts/ui/player_loadout_mastery_panel.gd")


class FakeVisualRegistry:
	extends RefCounted

	var mastery_icon_calls := 0
	var mastery_card_texture_calls := 0
	var menu_mastery_icon_calls := 0

	func mastery_icon(_orb_id: int) -> Texture2D:
		mastery_icon_calls += 1
		return null

	func mastery_card_texture(_orb_id: int) -> Texture2D:
		mastery_card_texture_calls += 1
		return null

	func menu_mastery_icon(_orb_id: int) -> Texture2D:
		menu_mastery_icon_calls += 1
		return null


class FakeHighlighter:
	extends RefCounted

	var hover_payload: Dictionary = {}
	var apply_count := 0
	var clear_count := 0
	var pulsed_sources: Array = []
	var highlighted_orbs: Array[int] = []

	func set_hover_payload(payload: Dictionary) -> void:
		hover_payload = payload.duplicate(true)

	func apply_highlights() -> void:
		apply_count += 1

	func clear_highlights() -> void:
		clear_count += 1

	func pulse_sources(sources: Array) -> void:
		pulsed_sources = sources.duplicate()

	func source_lines(orb_id: int) -> Array[String]:
		return ["orb-%d source" % orb_id]

	func set_highlights_for_orb(orb_id: int) -> void:
		highlighted_orbs.append(orb_id)


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("populate_row_uses_injected_hooks", _test_populate_row_uses_injected_hooks, failures)
	_run_case("hover_detail_state_lives_in_panel", _test_hover_detail_state_lives_in_panel, failures)
	_run_case("hover_detail_popover_fits_narrow_parent", _test_hover_detail_popover_fits_narrow_parent, failures)
	_run_case("hover_detail_popover_avoids_letter_stack_when_constrained", _test_hover_detail_popover_avoids_letter_stack_when_constrained, failures)
	return {"passed": failures.is_empty(), "total": 4, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_populate_row_uses_injected_hooks() -> String:
	var fixture := _make_fixture()
	var row := Control.new()
	row.add_child(Control.new())

	fixture["panel"].populate_mastery_row(row, {3: 2})

	if int(fixture["clear_count"]) != 1:
		return "Expected populate_mastery_row to clear through injected hook."
	if row.get_child_count() != 6:
		return "Expected mastery row to render one cell for each combat mastery orb."
	if int(fixture["slot_stylebox_count"]) != 6:
		return "Expected slot styleboxes to come from injected hook."
	if fixture["visual_registry"].mastery_icon_calls != 6:
		return "Expected mastery icons to come from injected visual registry."
	row.free()
	return ""


func _test_hover_detail_state_lives_in_panel() -> String:
	var fixture := _make_fixture()
	var popover_parent := Control.new()
	popover_parent.size = Vector2(1200.0, 700.0)
	var row := Control.new()
	row.size = Vector2(1048.0, 108.0)
	fixture["hud_nodes"]["popover_parent"] = popover_parent
	fixture["hud_nodes"]["mastery_cards"] = row

	fixture["panel"].set_combat_mastery_hover_payload({"mastery_levels": {3: 4}, "orb_values_by_id": {3: 11}})
	fixture["panel"].populate_combat_mastery_panel(row, {}, {3: 5})
	var card: Control = fixture["panel"].get_combat_mastery_card(row, 3)
	if card == null:
		return "Expected combat mastery card for hovered orb."

	fixture["panel"]._on_combat_mastery_card_mouse_entered(row, 3, card)
	var bubble := popover_parent.get_node_or_null("MasteryDetailBubble") as Panel
	if bubble == null or not bubble.visible:
		return "Expected panel-owned detail bubble to be visible after hover."
	var title := bubble.get_node_or_null("MasteryDetailTitle") as Label
	if title == null or title.text.find("Mastery Lv 4") < 0:
		return "Expected detail bubble content to use panel-owned hover payload."
	if fixture["highlighter"].highlighted_orbs != [3]:
		return "Expected hover to route source highlights through injected highlighter."

	fixture["panel"]._on_combat_mastery_card_mouse_exited(row, 3)
	if bubble.visible:
		return "Expected detail bubble to hide after exiting hovered card."
	if fixture["highlighter"].clear_count != 1:
		return "Expected hover exit to clear highlights through injected highlighter."
	row.free()
	popover_parent.free()
	return ""


func _test_hover_detail_popover_fits_narrow_parent() -> String:
	var fixture := _make_fixture(false)
	var popover_parent := Control.new()
	popover_parent.size = Vector2(520.0, 620.0)
	var row := Control.new()
	row.position = Vector2(10.0, 320.0)
	row.size = Vector2(500.0, 76.0)
	popover_parent.add_child(row)
	fixture["hud_nodes"]["popover_parent"] = popover_parent
	fixture["hud_nodes"]["mastery_cards"] = row

	fixture["panel"].set_combat_mastery_hover_payload({"mastery_levels": {3: 2}, "orb_values_by_id": {3: 9}})
	fixture["panel"].populate_combat_mastery_panel(row, {}, {3: 4})
	var card: Control = fixture["panel"].get_combat_mastery_card(row, 3)
	if card == null:
		return "Expected combat mastery card in narrow parent fixture."

	fixture["panel"]._on_combat_mastery_card_mouse_entered(row, 3, card)
	var bubble := popover_parent.get_node_or_null("MasteryDetailBubble") as Panel
	if bubble == null or not bubble.visible:
		return "Expected detail bubble to be visible in narrow parent fixture."
	if bubble.size.x > popover_parent.size.x - 24.0:
		return "Expected detail bubble width to fit inside the narrow parent margins."
	if bubble.position.x < 12.0 or bubble.position.x + bubble.size.x > popover_parent.size.x - 12.0:
		return "Expected detail bubble position to stay inside the narrow parent."
	var effect := bubble.get_node_or_null("MasteryDetailEffect") as Label
	if effect == null or effect.size.x < 200.0:
		return "Expected effect label to receive a usable content rect."
	if effect.autowrap_mode == TextServer.AUTOWRAP_OFF:
		return "Expected effect label to wrap instead of collapsing into stacked letters."

	popover_parent.free()
	return ""


func _test_hover_detail_popover_avoids_letter_stack_when_constrained() -> String:
	var fixture := _make_fixture(false)
	var popover_parent := Control.new()
	popover_parent.size = Vector2(260.0, 620.0)
	var row := Control.new()
	row.position = Vector2(10.0, 320.0)
	row.size = Vector2(240.0, 76.0)
	popover_parent.add_child(row)
	fixture["hud_nodes"]["popover_parent"] = popover_parent
	fixture["hud_nodes"]["mastery_cards"] = row

	fixture["panel"].set_combat_mastery_hover_payload({"mastery_levels": {3: 2}, "orb_values_by_id": {3: 9}})
	fixture["panel"].populate_combat_mastery_panel(row, {}, {3: 4})
	var card: Control = fixture["panel"].get_combat_mastery_card(row, 3)
	if card == null:
		return "Expected combat mastery card in constrained parent fixture."

	fixture["panel"]._on_combat_mastery_card_mouse_entered(row, 3, card)
	var bubble := popover_parent.get_node_or_null("MasteryDetailBubble") as Panel
	if bubble == null or not bubble.visible:
		return "Expected detail bubble to be visible in constrained parent fixture."
	var effect := bubble.get_node_or_null("MasteryDetailEffect") as Label
	var modifiers := bubble.get_node_or_null("MasteryDetailModifiers") as Label
	if effect == null or modifiers == null:
		return "Expected wrapped detail labels to exist."
	if effect.size.x >= MASTERY_PANEL_SCRIPT.MASTERY_DETAIL_LABEL_WRAP_MIN_WIDTH:
		return "Expected constrained fixture to exercise the no-wrap fallback."
	if effect.autowrap_mode != TextServer.AUTOWRAP_OFF or modifiers.autowrap_mode != TextServer.AUTOWRAP_OFF:
		return "Expected constrained detail labels to disable wrapping instead of stacking letters."

	popover_parent.free()
	return ""


func _make_fixture(include_apply_rect_hook: bool = true) -> Dictionary:
	var panel: Variant = MASTERY_PANEL_SCRIPT.new()
	var visual_registry := FakeVisualRegistry.new()
	var highlighter := FakeHighlighter.new()
	var hud_nodes: Dictionary = {}
	var fixture := {
		"panel": panel,
		"visual_registry": visual_registry,
		"highlighter": highlighter,
		"hud_nodes": hud_nodes,
		"clear_count": 0,
		"slot_stylebox_count": 0,
	}
	var hooks := {
		"clear_children":
		func(node: Node) -> void:
			fixture["clear_count"] = int(fixture["clear_count"]) + 1
			for child in node.get_children():
				node.remove_child(child)
				child.free(),
		"slot_stylebox":
		func() -> StyleBox:
			fixture["slot_stylebox_count"] = int(fixture["slot_stylebox_count"]) + 1
			return StyleBoxFlat.new(),
		"visual_registry_provider": func() -> Variant: return visual_registry,
		"mastery_highlighter_provider": func() -> Variant: return highlighter,
		"hud_nodes_provider": func() -> Dictionary: return hud_nodes,
		"to_parent_rect": func(rect: Rect2, _parent: Control) -> Rect2: return rect,
	}
	if include_apply_rect_hook:
		hooks["apply_rect"] = func(control: Control, rect: Rect2) -> void:
			control.position = rect.position
			control.size = rect.size
	panel.bind(hooks)
	return fixture
