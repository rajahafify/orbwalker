extends Control

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const SHOW_SECONDS := 2.4
const FADE_SECONDS := 0.20
const TOAST_MIN_WIDTH := 340.0
const TOAST_MAX_WIDTH_RATIO := 0.42

@onready var _toast_panel: PanelContainer = $ToastPanel
@onready var _toast_title: Label = $ToastPanel/ToastBody/TitleLabel
@onready var _toast_message: Label = $ToastPanel/ToastBody/MessageLabel

var _queue: Array[Dictionary] = []
var _showing := false
var _active_tween: Tween = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_apply_chrome()
	_layout_panel()
	var viewport: Viewport = get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)
	_toast_panel.visible = false


func enqueue_unlock(item_name: String) -> void:
	enqueue_toast("Achievement Unlocked", "%s unlocked" % item_name)


func enqueue_toast(title: String, message: String) -> void:
	_queue.append({
		"title": title,
		"message": message,
	})
	if not _showing:
		_show_next()


func enqueue_unlock_entries(entries: Array) -> void:
	for entry in entries:
		if entry is Dictionary:
			var typed_entry: Dictionary = entry as Dictionary
			var title: String = String(typed_entry.get("title", "Achievement Unlocked"))
			var message: String = String(typed_entry.get("message", ""))
			if message == "":
				var display_name: String = String(typed_entry.get("display_name", typed_entry.get("item_name", typed_entry.get("item_id", "Unknown Item"))))
				message = "%s unlocked" % display_name
			enqueue_toast(title, message)
		elif entry is String:
			enqueue_unlock(String(entry))


func clear_queue() -> void:
	_queue.clear()
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_showing = false
	_toast_panel.visible = false


func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		_toast_panel.visible = false
		return
	_showing = true
	var queue_entry: Dictionary = Dictionary(_queue[0])
	_queue.remove_at(0)
	var title: String = String(queue_entry.get("title", "Achievement Unlocked"))
	var message: String = String(queue_entry.get("message", ""))
	_toast_title.text = title
	_toast_message.text = message
	_toast_panel.visible = true
	_toast_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = create_tween()
	_active_tween.tween_property(_toast_panel, "modulate:a", 1.0, FADE_SECONDS)
	_active_tween.tween_interval(SHOW_SECONDS)
	_active_tween.tween_property(_toast_panel, "modulate:a", 0.0, FADE_SECONDS)
	_active_tween.tween_callback(Callable(self, "_on_toast_complete"))


func _on_toast_complete() -> void:
	_toast_panel.visible = false
	_show_next()


func _on_viewport_size_changed() -> void:
	_layout_panel()


func _layout_panel() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var panel_width := clampf(viewport_size.x * TOAST_MAX_WIDTH_RATIO, TOAST_MIN_WIDTH, 460.0)
	var right_margin := clampf(viewport_size.x * 0.03, 18.0, 44.0)
	var bottom_margin := clampf(viewport_size.y * 0.028, 22.0, 56.0)
	_toast_panel.anchor_left = 1.0
	_toast_panel.anchor_right = 1.0
	_toast_panel.anchor_top = 1.0
	_toast_panel.anchor_bottom = 1.0
	_toast_panel.offset_left = -right_margin - panel_width
	_toast_panel.offset_right = -right_margin
	_toast_panel.offset_top = -bottom_margin - 124.0
	_toast_panel.offset_bottom = -bottom_margin


func _apply_chrome() -> void:
	_toast_panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(
			Color(0.08, 0.06, 0.04, 0.95),
			Color(0.98, 0.78, 0.34, 1.0),
			3,
			12,
			Vector4(16, 12, 16, 12)
		)
	)
	_toast_title.add_theme_font_size_override("font_size", 24)
	_toast_title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48, 1.0))
	_toast_title.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.96))
	_toast_title.add_theme_constant_override("outline_size", 2)
	_toast_message.add_theme_font_size_override("font_size", 21)
	_toast_message.add_theme_color_override("font_color", Color(0.95, 0.90, 0.82, 1.0))
	_toast_message.add_theme_color_override("font_outline_color", Color(0.04, 0.03, 0.02, 0.94))
	_toast_message.add_theme_constant_override("outline_size", 1)
