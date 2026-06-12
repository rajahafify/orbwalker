extends RefCounted
class_name PlayerLoadoutIntentPreviewTest

const PREVIEW_SCRIPT := preload("res://scripts/ui/player_loadout_intent_preview.gd")


class Providers:
	extends RefCounted

	var hud_nodes := {}
	var player_data := {}

	func hud_nodes_provider() -> Dictionary:
		return hud_nodes

	func player_data_provider() -> Dictionary:
		return player_data


class Recorder:
	extends RefCounted

	var events: Array = []

	func intent_hovered(preview: Dictionary) -> void:
		events.append(["intent", preview])

	func block_hovered(preview: Dictionary) -> void:
		events.append(["block", preview])

	func hover_ended() -> void:
		events.append(["ended"])


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("sync_uses_bound_providers_and_owns_nodes", _test_sync_uses_bound_providers_and_owns_nodes, failures)
	_run_case("hover_callbacks_emit_preview_payloads", _test_hover_callbacks_emit_preview_payloads, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_sync_uses_bound_providers_and_owns_nodes() -> String:
	var providers := Providers.new()
	var hp_bar := ProgressBar.new()
	hp_bar.name = "HpBar"
	hp_bar.size = Vector2(200.0, 20.0)
	hp_bar.max_value = 40.0
	hp_bar.value = 30.0
	providers.hud_nodes = {"hp_bar": hp_bar}
	providers.player_data = {"display_values": {"current_armor": 10}}
	var preview: Variant = _bound_preview(providers, Recorder.new())
	preview._sync_intent_damage_preview({})
	var overshield := hp_bar.get_node_or_null("PlayerArmorOvershieldFill") as ColorRect
	if overshield == null:
		return "Expected intent preview to create and own the overshield node."
	if not overshield.visible or absf(overshield.size.x - 50.0) > 0.001:
		return "Expected armor overshield layout from provider data."
	if hp_bar.get_node_or_null("HpDangerPreviewButton") == null or hp_bar.get_node_or_null("PlayerBlockIntentPreviewFill") == null:
		return "Expected intent preview nodes to be parented under the provided HP bar."
	return ""


func _test_hover_callbacks_emit_preview_payloads() -> String:
	var providers := Providers.new()
	var recorder := Recorder.new()
	var preview: Variant = _bound_preview(providers, recorder)
	preview._intent_damage_preview = {"hp_loss": 4, "blocked": 2}
	preview._on_intent_damage_preview_hovered()
	preview._on_intent_block_preview_hovered()
	preview._on_intent_damage_preview_hover_ended()
	if recorder.events.size() != 3:
		return "Expected three hover callback events."
	if recorder.events[0][0] != "intent" or int(recorder.events[0][1].get("hp_loss", 0)) != 4:
		return "Expected intent hover payload."
	if recorder.events[1][0] != "block" or int(recorder.events[1][1].get("blocked", 0)) != 2:
		return "Expected block hover payload."
	if recorder.events[2][0] != "ended":
		return "Expected hover-ended callback."
	return ""


func _bound_preview(providers: Providers, recorder: Recorder) -> Variant:
	var preview: Variant = PREVIEW_SCRIPT.new()
	(
		preview
		. bind(
			{"hud_nodes_provider": Callable(providers, "hud_nodes_provider"), "player_data_provider": Callable(providers, "player_data_provider")},
			{
				PREVIEW_SCRIPT.CALLBACK_INTENT_PREVIEW_HOVERED: Callable(recorder, "intent_hovered"),
				PREVIEW_SCRIPT.CALLBACK_INTENT_BLOCK_PREVIEW_HOVERED: Callable(recorder, "block_hovered"),
				PREVIEW_SCRIPT.CALLBACK_INTENT_PREVIEW_HOVER_ENDED: Callable(recorder, "hover_ended"),
			}
		)
	)
	return preview
