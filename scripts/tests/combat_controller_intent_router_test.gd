extends RefCounted
class_name CombatControllerIntentRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_controller_intent_router.gd")


class FakeIntentHoverHandler:
	extends RefCounted

	var show_preview := true
	var calls: Array[Dictionary] = []

	func should_show_preview() -> bool:
		calls.append({"method": "should_show_preview"})
		return show_preview

	func intent_damage_preview_hovered(preview: Dictionary) -> void:
		calls.append({"method": "intent_damage_preview_hovered", "preview": preview})

	func intent_block_preview_hovered(preview: Dictionary) -> void:
		calls.append({"method": "intent_block_preview_hovered", "preview": preview})

	func enemy_block_preview_hovered(preview: Dictionary) -> void:
		calls.append({"method": "enemy_block_preview_hovered", "preview": preview})

	func intent_damage_preview_hover_ended() -> void:
		calls.append({"method": "intent_damage_preview_hover_ended"})

	func enemy_intent_bubble_hovered(kind: String, entry: Dictionary) -> void:
		calls.append({"method": "enemy_intent_bubble_hovered", "kind": kind, "entry": entry})


class FakeDebugStateProvider:
	extends RefCounted

	var intents: Array[Dictionary] = []

	func format_intent(intent: Dictionary) -> String:
		intents.append(intent)
		return "formatted:%s" % String(intent.get("kind", ""))


class FakeOwner:
	extends RefCounted

	var _intent_hover_handler: Variant = FakeIntentHoverHandler.new()
	var _debug_state_provider: Variant = FakeDebugStateProvider.new()
	var bind_calls := 0
	var bind_debug_calls := 0

	func _bind_intent_hover_handler() -> void:
		bind_calls += 1

	func _bind_debug_state_provider() -> void:
		bind_debug_calls += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("should_show_preview_uses_handler", _test_should_show_preview_uses_handler, failures)
	_run_case("hover_events_forward_to_handler", _test_hover_events_forward_to_handler, failures)
	_run_case("format_intent_uses_debug_state_provider", _test_format_intent_uses_debug_state_provider, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_should_show_preview_uses_handler() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	if not router.should_show_intent_damage_preview():
		return "Expected should_show_intent_damage_preview to return handler state."
	if owner.bind_calls != 1:
		return "Expected should_show_intent_damage_preview to bind the intent handler."
	return ""


func _test_hover_events_forward_to_handler() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	router.intent_damage_preview_hovered({"hp_loss": 3})
	router.intent_block_preview_hovered({"blocked": 2})
	router.enemy_block_preview_hovered({"blocked": 4})
	router.intent_damage_preview_hover_ended()
	router.enemy_intent_bubble_hovered("attack", {"damage": 8})

	var handler: FakeIntentHoverHandler = owner._intent_hover_handler
	var methods: Array[String] = []
	for call: Dictionary in handler.calls:
		methods.append(String(call.get("method", "")))
	if (
		methods
		!= [
			"intent_damage_preview_hovered",
			"intent_block_preview_hovered",
			"enemy_block_preview_hovered",
			"intent_damage_preview_hover_ended",
			"enemy_intent_bubble_hovered",
		]
	):
		return "Expected every intent hover event to forward in order."
	if owner.bind_calls != 5:
		return "Expected each intent hover event to bind the handler before forwarding."
	return ""


func _test_format_intent_uses_debug_state_provider() -> String:
	var owner := FakeOwner.new()
	var router: Variant = ROUTER_SCRIPT.new()
	router.bind(owner)

	var text := String(router.format_intent({"kind": "attack"}))

	var provider: FakeDebugStateProvider = owner._debug_state_provider
	if text != "formatted:attack":
		return "Expected format_intent to return debug state provider formatting."
	if provider.intents != [{"kind": "attack"}]:
		return "Expected format_intent to forward the intent payload."
	if owner.bind_debug_calls != 1:
		return "Expected format_intent to bind the debug state provider."
	return ""
