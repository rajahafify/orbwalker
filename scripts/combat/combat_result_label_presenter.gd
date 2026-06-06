extends RefCounted
class_name CombatResultLabelPresenter

const BASE_FONT_SIZE := 42.0
const BASE_OUTLINE_SIZE := 11.0
const BASE_LABEL_SIZE := Vector2(240, 70)
const RESULT_LABEL_Z_INDEX := 500

var _vfx_layer: Control
var _timer_owner: Node


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node


func spawn_result_label(text: String, global_center: Vector2, lifetime: float, offset: Vector2, label_scale: float, font_color: Color, rise_distance: float = 54.0) -> Label:
	if text.strip_edges() == "" or global_center == Vector2.ZERO:
		return null
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.autowrap_mode = TextServer.AUTOWRAP_OFF as TextServer.AutowrapMode
	label.add_theme_font_size_override("font_size", int(round(BASE_FONT_SIZE * label_scale)))
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", int(round(BASE_OUTLINE_SIZE * label_scale)))
	label.custom_minimum_size = BASE_LABEL_SIZE * label_scale
	label.size = label.custom_minimum_size
	label.pivot_offset = label.size * 0.5
	label.z_index = RESULT_LABEL_Z_INDEX
	label.z_as_relative = false
	_vfx_layer.add_child(label)
	label.move_to_front()
	var local_center := _global_to_vfx_local(global_center) + offset
	label.position = local_center - label.size * 0.5
	_tween_cleanup(label, lifetime, rise_distance)
	return label


func _global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _tween_cleanup(label: Label, lifetime: float, rise_distance: float) -> void:
	if label == null:
		return
	var duration := maxf(0.12, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		return
	var tween := _timer_owner.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - rise_distance, duration).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	tween.tween_property(label, "modulate:a", 0.0, duration).set_delay(duration * 0.36)
	tween.finished.connect(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)
