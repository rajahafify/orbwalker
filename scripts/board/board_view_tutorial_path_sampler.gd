extends RefCounted
class_name BoardViewTutorialPathSampler


static func sample_path(path_points: Array[Vector2], distance: float) -> Dictionary:
	var remaining_distance := distance
	for index in range(path_points.size() - 1):
		var segment_start: Vector2 = path_points[index]
		var segment_end: Vector2 = path_points[index + 1]
		var segment := segment_end - segment_start
		var segment_length := segment.length()
		if segment_length <= 0.01:
			continue
		var segment_direction := segment / segment_length
		if remaining_distance <= segment_length:
			return {
				"position": segment_start + segment_direction * remaining_distance,
				"direction": segment_direction,
			}
		remaining_distance -= segment_length
	var final_start: Vector2 = path_points[path_points.size() - 2]
	var final_end: Vector2 = path_points[path_points.size() - 1]
	return {
		"position": final_end,
		"direction": (final_end - final_start).normalized(),
	}
