extends RefCounted
class_name CombatControllerIntentRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func should_show_intent_damage_preview() -> bool:
	var handler: Variant = _handler()
	return handler != null and bool(handler.should_show_preview())


func intent_damage_preview_hovered(preview: Dictionary) -> void:
	var handler: Variant = _handler()
	if handler != null:
		handler.intent_damage_preview_hovered(preview)


func intent_block_preview_hovered(preview: Dictionary) -> void:
	var handler: Variant = _handler()
	if handler != null:
		handler.intent_block_preview_hovered(preview)


func enemy_block_preview_hovered(preview: Dictionary) -> void:
	var handler: Variant = _handler()
	if handler != null:
		handler.enemy_block_preview_hovered(preview)


func intent_damage_preview_hover_ended() -> void:
	var handler: Variant = _handler()
	if handler != null:
		handler.intent_damage_preview_hover_ended()


func enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
	var handler: Variant = _handler()
	if handler != null:
		handler.enemy_intent_bubble_hovered(kind, entry)


func format_intent(intent: Dictionary) -> String:
	_owner.call("_bind_debug_state_provider")
	return String(_owner.get("_debug_state_provider").format_intent(intent))


func _handler() -> Variant:
	_owner.call("_bind_intent_hover_handler")
	return _owner.get("_intent_hover_handler")
