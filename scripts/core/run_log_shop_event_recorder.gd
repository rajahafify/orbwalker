extends RefCounted
class_name RunLogShopEventRecorder

var _logger_provider: Callable


func _init(logger_provider: Callable) -> void:
	_logger_provider = logger_provider


func append_run_log(event_type: String, payload: Dictionary) -> void:
	_logger().run_log_append(event_type, payload)


func result_brief(result: Dictionary) -> Dictionary:
	return _logger().run_log_result_brief(result)


func record_shop_action(action: String, result: Dictionary, request: Dictionary = {}, shop_before_snapshot: Dictionary = {}, gold_before: int = -1) -> void:
	_logger().run_log_shop_action(action, result, request, shop_before_snapshot, gold_before)


func sanitize_shop_snapshot(shop_snapshot: Dictionary, gold_value: int) -> Dictionary:
	return _logger().run_log_sanitize_shop_snapshot(shop_snapshot, gold_value)


func next_shop_ordinal() -> int:
	return _logger().run_log_next_shop_ordinal()


func _logger():
	return _logger_provider.call()
