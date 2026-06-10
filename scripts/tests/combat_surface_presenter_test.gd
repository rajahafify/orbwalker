extends RefCounted
class_name CombatSurfacePresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_surface_presenter.gd")


class DebugConsoleStub:
	extends RefCounted

	var overlay_values: Array[bool] = []

	func set_overlay_visible(visible: bool) -> void:
		overlay_values.append(visible)


class OutcomeOverlayStub:
	extends RefCounted

	var bound_nodes: Dictionary = {}
	var bound_config: Dictionary = {}

	func bind(nodes: Dictionary, config: Dictionary = {}) -> void:
		bound_nodes = nodes.duplicate()
		bound_config = config.duplicate()


var _submitted_values: Array[String] = []


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("nodes_from_root_nodes_preserves_surface_contract", _test_nodes_from_root_nodes_preserves_surface_contract, failures)
	_run_case("surface_state_and_debug_visibility_delegate_to_nodes", _test_surface_state_and_debug_visibility_delegate_to_nodes, failures)
	_run_case("outcome_background_vfx_and_timer_state_delegate_to_nodes", _test_outcome_background_vfx_and_timer_state_delegate_to_nodes, failures)
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


func _test_nodes_from_root_nodes_preserves_surface_contract() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var nodes: Dictionary = PRESENTER_SCRIPT.nodes_from_root_nodes(fixture["root_nodes"])
	for surface_key in PRESENTER_SCRIPT.SURFACE_NODE_BINDINGS.keys():
		if not nodes.has(surface_key):
			root.free()
			return "Expected surface node key: %s." % surface_key
		var expected_key := String(PRESENTER_SCRIPT.SURFACE_NODE_BINDINGS[surface_key])
		if nodes.get(surface_key) != fixture["root_nodes"].get(expected_key):
			root.free()
			return "Expected %s to resolve from %s." % [surface_key, expected_key]
	root.free()
	return ""


func _test_surface_state_and_debug_visibility_delegate_to_nodes() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var debug_console: DebugConsoleStub = fixture["debug_console"]
	var status_label: Label = fixture["root_nodes"].get("_status_label")
	var turn_summary_label: Label = fixture["root_nodes"].get("_turn_summary_label")
	var debug_toggle_button: Button = fixture["root_nodes"].get("_debug_toggle_button")
	var debug_overlay: CanvasItem = fixture["root_nodes"].get("_debug_overlay")
	var console_input: LineEdit = fixture["root_nodes"].get("_console_input")
	presenter.set_status_text("Ready")
	presenter.set_status_color(Color(0.2, 0.3, 0.4, 1.0))
	presenter.set_turn_summary_text("Turn Summary: Test")
	presenter.pulse_turn_summary(Color.RED)
	presenter.set_debug_toggle_button_visible(false)
	presenter.set_debug_overlay_visible(true)
	var toggled_visible: bool = presenter.toggle_debug_overlay()
	_submitted_values.clear()
	presenter.connect_debug_console_submit(Callable(self, "_record_submitted_value"))
	console_input.text_submitted.emit("debug")
	if status_label.text != "Ready" or not _color_equal(status_label.modulate, Color(0.2, 0.3, 0.4, 1.0)):
		root.free()
		return "Expected status text and color to update."
	if presenter.turn_summary_text() != "Turn Summary: Test" or not _color_equal(turn_summary_label.modulate, Color.WHITE):
		root.free()
		return "Expected turn summary text and pulse reset."
	if debug_toggle_button.visible or debug_overlay.visible or toggled_visible:
		root.free()
		return "Expected debug toggle and overlay visibility to delegate."
	if debug_console.overlay_values != [true, false]:
		root.free()
		return "Expected debug console overlay visibility calls."
	if _submitted_values != ["debug"]:
		root.free()
		return "Expected console submit callable to be connected."
	root.free()
	return ""


func _test_outcome_background_vfx_and_timer_state_delegate_to_nodes() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var background: TextureRect = fixture["root_nodes"].get("_background")
	var vfx_layer: Control = fixture["root_nodes"].get("_vfx_layer")
	var body_label: Label = fixture["root_nodes"].get("_outcome_body_label")
	var next_button: Button = fixture["root_nodes"].get("_next_button")
	var timer_track: Control = fixture["root_nodes"].get("_timer_track")
	var timer_fill: ColorRect = fixture["root_nodes"].get("_timer_fill")
	var timer_label: Label = fixture["root_nodes"].get("_timer_label")
	var timer_state_label: Label = fixture["root_nodes"].get("_timer_state_label")
	var outcome_overlay := OutcomeOverlayStub.new()
	timer_track.size = Vector2(100.0, 20.0)
	next_button.text = "Continue"
	presenter.bind_outcome_overlay(outcome_overlay, {"mode": "test"})
	presenter.set_outcome_body_text("Victory")
	presenter.set_outcome_next_button_disabled(true)
	presenter.bootstrap_background()
	presenter.set_vfx_layer_visible(false)
	presenter.sync_timer_display(3.0, "active")
	if outcome_overlay.bound_nodes.get("body_label") != body_label or outcome_overlay.bound_config.get("mode") != "test":
		root.free()
		return "Expected outcome overlay binding nodes and config."
	if body_label.text != "Victory" or not next_button.disabled or presenter.next_button_text() != "Continue":
		root.free()
		return "Expected outcome body and next button state."
	if not _color_equal(background.modulate, Color(0.16, 0.17, 0.20, 1.0)) or vfx_layer.visible:
		root.free()
		return "Expected background bootstrap and VFX layer visibility."
	if timer_label.text != "3 SEC" or timer_state_label.text != "MOVE" or not timer_fill.visible or timer_fill.size.x <= 0.0:
		root.free()
		return "Expected active timer display to apply to nodes."
	root.free()
	return ""


func _record_submitted_value(value: String) -> void:
	_submitted_values.append(value)


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var root_nodes := {}
	for root_key in PRESENTER_SCRIPT.SURFACE_NODE_BINDINGS.values():
		var key := String(root_key)
		var node := _node_for_root_key(key)
		node.name = key.trim_prefix("_")
		root.add_child(node)
		root_nodes[key] = node
	var debug_console := DebugConsoleStub.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root_nodes, {"debug_console": debug_console})
	return {
		"root": root,
		"root_nodes": root_nodes,
		"debug_console": debug_console,
		"presenter": presenter,
	}


func _node_for_root_key(key: String) -> Node:
	match key:
		"_background", "_timer_icon":
			return TextureRect.new()
		"_status_label", "_turn_summary_label", "_outcome_title_label", "_outcome_body_label", "_timer_label", "_timer_state_label":
			return Label.new()
		"_combat_log_text":
			return RichTextLabel.new()
		"_console_input":
			var input := LineEdit.new()
			input.visible = true
			return input
		"_debug_toggle_button", "_next_button":
			return Button.new()
		"_timer_fill":
			return ColorRect.new()
		_:
			return Control.new()


func _color_equal(left: Color, right: Color) -> bool:
	return (
		is_equal_approx(left.r, right.r)
		and is_equal_approx(left.g, right.g)
		and is_equal_approx(left.b, right.b)
		and is_equal_approx(left.a, right.a)
	)
