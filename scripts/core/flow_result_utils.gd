extends RefCounted
class_name FlowResultUtils


static func scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	if result is int:
		return int(result) == OK
	return false


static func scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is bool:
		return "unknown"
	if result is int:
		return "error_code_%d" % int(result)
	return "unknown"


static func result_ok(result: Variant) -> bool:
	return scene_change_succeeded(result)


static func result_failure_reason(result: Variant) -> String:
	return scene_change_failure_reason(result)
