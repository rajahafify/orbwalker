extends RefCounted
class_name CombatMasteryFillStreamer


static func spawn(group: Dictionary, preview_amount: int, board_view: Variant, vfx_presenter: Variant, fill_lifetime: float) -> void:
	if preview_amount <= 0 or vfx_presenter == null:
		return
	if board_view == null or not is_instance_valid(board_view):
		return
	var orb_id := int(group.get("orb_id", -1))
	if not OrbType.is_valid_id(orb_id):
		return
	var source_global := _match_group_global_center(group, board_view)
	if source_global == Vector2.ZERO:
		return
	vfx_presenter.spawn_mastery_fill_stream(orb_id, source_global, preview_amount, fill_lifetime)


static func _match_group_global_center(group: Dictionary, board_view: Variant) -> Vector2:
	var cells: Array = group.get("cells", [])
	if cells.is_empty():
		return Vector2.ZERO
	var local_sum := Vector2.ZERO
	var valid_count := 0
	for raw_cell in cells:
		var cell: Vector2i = raw_cell
		if not board_view.is_cell_valid(cell):
			continue
		local_sum += board_view.get_cell_center(cell)
		valid_count += 1
	if valid_count <= 0:
		return Vector2.ZERO
	var local_center := local_sum / float(valid_count)
	return board_view.get_global_transform_with_canvas() * local_center
