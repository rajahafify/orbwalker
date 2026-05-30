extends RefCounted
class_name CombatSurfacePresenter

const COMBAT_TIMER_DISPLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_timer_display_presenter.gd")
const SURFACE_NODE_BINDINGS := {
	"background": "_background",
	"status_label": "_status_label",
	"turn_summary_label": "_turn_summary_label",
	"combat_log_text": "_combat_log_text",
	"console_input": "_console_input",
	"debug_toggle_button": "_debug_toggle_button",
	"debug_overlay": "_debug_overlay",
	"layout_root": "_layout_root",
	"outcome_summary_panel": "_outcome_summary_panel",
	"outcome_summary_root": "_outcome_summary_root",
	"outcome_text_column": "_outcome_text_column",
	"outcome_title_label": "_outcome_title_label",
	"outcome_body_label": "_outcome_body_label",
	"next_button": "_next_button",
	"vfx_layer": "_vfx_layer",
	"timer_track": "_timer_track",
	"timer_fill": "_timer_fill",
	"timer_label": "_timer_label",
	"timer_state_label": "_timer_state_label",
	"timer_icon": "_timer_icon",
}

var _nodes: Dictionary = {}
var _debug_console: Variant = null


static func nodes_from_root_nodes(root_nodes: Dictionary, extras: Dictionary = {}) -> Dictionary:
	var nodes := {}
	for surface_key in SURFACE_NODE_BINDINGS.keys():
		nodes[surface_key] = root_nodes.get(String(SURFACE_NODE_BINDINGS[surface_key]), null)
	for key in extras.keys():
		nodes[key] = extras[key]
	return nodes


func bind(root_nodes: Dictionary, extras: Dictionary = {}) -> void:
	_nodes = nodes_from_root_nodes(root_nodes, extras)
	_debug_console = extras.get("debug_console", _debug_console)


func set_status_text(text: String) -> void:
	var status_label := _label("status_label")
	if status_label != null:
		status_label.text = text


func set_status_color(color: Color) -> void:
	var status_label := _label("status_label")
	if status_label != null:
		status_label.modulate = color


func set_turn_summary_text(text: String) -> void:
	var summary_label := _label("turn_summary_label")
	if summary_label != null:
		summary_label.text = text


func turn_summary_text() -> String:
	var summary_label := _label("turn_summary_label")
	if summary_label == null:
		return ""
	return summary_label.text


func pulse_turn_summary(tint: Color) -> void:
	var summary_label := _label("turn_summary_label")
	if summary_label == null:
		return
	summary_label.modulate = tint
	summary_label.modulate = Color(1.0, 1.0, 1.0, 1.0)


func debug_console_nodes() -> Dictionary:
	return {
		"combat_log_text": _node("combat_log_text"),
		"console_input": _node("console_input"),
	}


func connect_debug_console_submit(on_submitted: Callable) -> void:
	var console_input := _line_edit("console_input")
	if console_input == null or not console_input.visible:
		return
	if console_input.text_submitted.is_connected(on_submitted):
		return
	console_input.text_submitted.connect(on_submitted)


func set_debug_toggle_button_visible(visible: bool) -> void:
	var debug_toggle_button := _button("debug_toggle_button")
	if debug_toggle_button != null:
		debug_toggle_button.visible = visible


func set_debug_overlay_visible(visible: bool) -> void:
	var debug_overlay := _canvas_item("debug_overlay")
	if debug_overlay != null:
		debug_overlay.visible = visible
	if _debug_console != null and _debug_console.has_method("set_overlay_visible"):
		_debug_console.set_overlay_visible(visible)


func toggle_debug_overlay() -> bool:
	var visible := not is_debug_overlay_visible()
	set_debug_overlay_visible(visible)
	return visible


func is_debug_overlay_visible() -> bool:
	var debug_overlay := _canvas_item("debug_overlay")
	if debug_overlay == null:
		return false
	return debug_overlay.visible


func outcome_overlay_nodes() -> Dictionary:
	return {
		"layout_root": _node("layout_root"),
		"summary_panel": _node("outcome_summary_panel"),
		"summary_root": _node("outcome_summary_root"),
		"text_column": _node("outcome_text_column"),
		"title_label": _node("outcome_title_label"),
		"body_label": _node("outcome_body_label"),
		"next_button": _node("next_button"),
	}


func bind_outcome_overlay(outcome_overlay: Variant, config: Dictionary = {}) -> void:
	if outcome_overlay == null:
		return
	outcome_overlay.bind(outcome_overlay_nodes(), config)


func set_outcome_body_text(text: String) -> void:
	var body_label := _label("outcome_body_label")
	if body_label != null:
		body_label.text = text


func set_outcome_next_button_disabled(disabled: bool) -> void:
	var next_button := _button("next_button")
	if next_button != null:
		next_button.disabled = disabled


func next_button_text() -> String:
	var next_button := _button("next_button")
	if next_button == null:
		return ""
	return next_button.text


func bootstrap_background() -> void:
	var background := _texture_rect("background")
	if background == null:
		return
	background.texture = null
	background.modulate = Color(0.16, 0.17, 0.20, 1.0)


func set_vfx_layer_visible(visible: bool) -> void:
	var vfx_layer := _canvas_item("vfx_layer")
	if vfx_layer != null:
		vfx_layer.visible = visible


func sync_timer_display(seconds_left: float, state: String) -> void:
	COMBAT_TIMER_DISPLAY_PRESENTER_SCRIPT.apply_to_nodes(
		{
			"timer_track": _node("timer_track"),
			"timer_fill": _node("timer_fill"),
			"timer_label": _node("timer_label"),
			"timer_state_label": _node("timer_state_label"),
			"timer_icon": _node("timer_icon"),
		},
		seconds_left,
		state
	)


func _node(key: String) -> Variant:
	var value: Variant = _nodes.get(key, null)
	if value == null:
		return null
	if value is Object and not is_instance_valid(value):
		return null
	return value


func _label(key: String) -> Label:
	var value: Variant = _node(key)
	if value is Label:
		return value as Label
	return null


func _button(key: String) -> Button:
	var value: Variant = _node(key)
	if value is Button:
		return value as Button
	return null


func _line_edit(key: String) -> LineEdit:
	var value: Variant = _node(key)
	if value is LineEdit:
		return value as LineEdit
	return null


func _texture_rect(key: String) -> TextureRect:
	var value: Variant = _node(key)
	if value is TextureRect:
		return value as TextureRect
	return null


func _canvas_item(key: String) -> CanvasItem:
	var value: Variant = _node(key)
	if value is CanvasItem:
		return value as CanvasItem
	return null
