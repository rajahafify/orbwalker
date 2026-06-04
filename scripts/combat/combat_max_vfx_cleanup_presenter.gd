extends RefCounted
class_name CombatMaxVfxCleanupPresenter

var _timer_owner: Node


func bind(dependencies: Dictionary) -> void:
	_timer_owner = dependencies.get("timer_owner") as Node


func queue_free_after(node: Node, delay: float) -> void:
	if node == null:
		return
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		node.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_interval(maxf(0.05, delay))
	tween.finished.connect(func() -> void:
		if is_instance_valid(node):
			node.queue_free()
	)
