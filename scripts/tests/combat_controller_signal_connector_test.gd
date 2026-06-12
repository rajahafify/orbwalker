extends RefCounted
class_name CombatControllerSignalConnectorTest

const CONNECTOR_SCRIPT := preload("res://scripts/combat/combat_controller_signal_connector.gd")


class FakeResolver:
	extends RefCounted

	signal match_found
	signal cells_cleared
	signal gravity_applied
	signal refill_applied
	signal cascade_step_complete
	signal resolve_complete


class FakePlayerLoadoutHud:
	extends RefCounted

	signal consumable_slot_selected
	signal sell_slot_requested
	signal intent_preview_hovered
	signal intent_block_preview_hovered
	signal intent_preview_hover_ended


class FakeView:
	extends RefCounted

	signal enemy_intent_bubble_hovered
	signal enemy_block_preview_hovered
	signal intent_hover_ended
	signal tutorial_end_continue_pressed
	signal tutorial_end_main_menu_pressed
	signal settings_continue_pressed
	signal settings_new_run_pressed
	signal settings_main_menu_pressed
	signal settings_speed_selected
	signal settings_quality_selected
	signal settings_reduced_motion_toggled
	signal settings_game_juice_toggled
	signal settings_game_juice_flag_toggled
	signal settings_defaults_reset


class FakeResolveTraceLogger:
	extends RefCounted

	var events: Array[String] = []

	func on_resolver_cells_cleared() -> void:
		events.append("cells_cleared")

	func on_resolver_gravity_applied() -> void:
		events.append("gravity_applied")

	func on_resolver_refill_applied() -> void:
		events.append("refill_applied")

	func on_resolver_cascade_step_complete() -> void:
		events.append("cascade_step_complete")

	func on_resolver_complete() -> void:
		events.append("resolve_complete")


class FakeLoadoutCommandHandler:
	extends RefCounted

	var events: Array[String] = []

	func try_use_consumable_slot() -> void:
		events.append("try_use_consumable_slot")

	func sell_slot_requested() -> void:
		events.append("sell_slot_requested")


class FakeSettingsCommandHandler:
	extends RefCounted

	var events: Array[String] = []

	func continue_combat() -> void:
		events.append("continue_combat")

	func start_new_run() -> void:
		events.append("start_new_run")

	func return_to_main_menu() -> void:
		events.append("return_to_main_menu")

	func select_speed() -> void:
		events.append("select_speed")

	func select_quality() -> void:
		events.append("select_quality")

	func toggle_reduced_motion() -> void:
		events.append("toggle_reduced_motion")

	func toggle_game_juice() -> void:
		events.append("toggle_game_juice")

	func toggle_game_juice_flag() -> void:
		events.append("toggle_game_juice_flag")

	func reset_feedback_settings() -> void:
		events.append("reset_feedback_settings")


class FakeTutorialEndCommandHandler:
	extends RefCounted

	var events: Array[String] = []

	func continue_pressed() -> void:
		events.append("continue_pressed")

	func main_menu_pressed() -> void:
		events.append("main_menu_pressed")


class Recorder:
	extends RefCounted

	var events: Array[String] = []

	func on_resolver_match_found() -> void:
		events.append("resolver_match_found")

	func on_intent_damage_preview_hovered() -> void:
		events.append("intent_damage_preview_hovered")

	func on_intent_block_preview_hovered() -> void:
		events.append("intent_block_preview_hovered")

	func on_intent_damage_preview_hover_ended() -> void:
		events.append("intent_damage_preview_hover_ended")

	func on_enemy_intent_bubble_hovered() -> void:
		events.append("enemy_intent_bubble_hovered")

	func on_enemy_block_preview_hovered() -> void:
		events.append("enemy_block_preview_hovered")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("connects_resolver_signals", _test_connects_resolver_signals, failures)
	_run_case("connects_player_loadout_signals", _test_connects_player_loadout_signals, failures)
	_run_case("connects_view_signals_once", _test_connects_view_signals_once, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_connects_resolver_signals() -> String:
	var fixture := _fixture()
	fixture.connector.connect_resolver_signals()
	fixture.resolver.emit_signal("match_found")
	fixture.resolver.emit_signal("cells_cleared")
	fixture.resolver.emit_signal("gravity_applied")
	fixture.resolver.emit_signal("refill_applied")
	fixture.resolver.emit_signal("cascade_step_complete")
	fixture.resolver.emit_signal("resolve_complete")
	if fixture.recorder.events != ["resolver_match_found"]:
		return "Expected resolver match signal to use injected callback."
	if fixture.resolve_trace_logger.events != ["cells_cleared", "gravity_applied", "refill_applied", "cascade_step_complete", "resolve_complete"]:
		return "Expected resolver trace signals to connect to the trace logger."
	return ""


func _test_connects_player_loadout_signals() -> String:
	var fixture := _fixture()
	fixture.connector.connect_player_loadout_signals()
	fixture.player_loadout_hud.emit_signal("consumable_slot_selected")
	fixture.player_loadout_hud.emit_signal("sell_slot_requested")
	fixture.player_loadout_hud.emit_signal("intent_preview_hovered")
	fixture.player_loadout_hud.emit_signal("intent_block_preview_hovered")
	fixture.player_loadout_hud.emit_signal("intent_preview_hover_ended")
	if fixture.loadout_command_handler.events != ["try_use_consumable_slot", "sell_slot_requested"]:
		return "Expected player loadout action signals to reach the loadout command handler."
	if fixture.recorder.events != ["intent_damage_preview_hovered", "intent_block_preview_hovered", "intent_damage_preview_hover_ended"]:
		return "Expected player loadout intent hover signals to use injected callbacks."
	return ""


func _test_connects_view_signals_once() -> String:
	var fixture := _fixture()
	fixture.connector.connect_view_signals()
	fixture.connector.connect_view_signals()
	fixture.view.emit_signal("enemy_intent_bubble_hovered")
	fixture.view.emit_signal("enemy_block_preview_hovered")
	fixture.view.emit_signal("intent_hover_ended")
	fixture.view.emit_signal("tutorial_end_continue_pressed")
	fixture.view.emit_signal("tutorial_end_main_menu_pressed")
	fixture.view.emit_signal("settings_continue_pressed")
	fixture.view.emit_signal("settings_new_run_pressed")
	fixture.view.emit_signal("settings_main_menu_pressed")
	fixture.view.emit_signal("settings_speed_selected")
	fixture.view.emit_signal("settings_quality_selected")
	fixture.view.emit_signal("settings_reduced_motion_toggled")
	fixture.view.emit_signal("settings_game_juice_toggled")
	fixture.view.emit_signal("settings_game_juice_flag_toggled")
	fixture.view.emit_signal("settings_defaults_reset")
	if fixture.recorder.events != ["enemy_intent_bubble_hovered", "enemy_block_preview_hovered", "intent_damage_preview_hover_ended"]:
		return "Expected view hover signals to connect once through callbacks."
	if fixture.tutorial_end_command_handler.events != ["continue_pressed", "main_menu_pressed"]:
		return "Expected tutorial end signals to reach tutorial end command handler once."
	if fixture.settings_command_handler.events.size() != 9:
		return "Expected all settings view signals to reach settings command handler once."
	if fixture.settings_command_handler.events[0] != "continue_combat" or fixture.settings_command_handler.events[-1] != "reset_feedback_settings":
		return "Expected settings signal order to match view signal order."
	return ""


func _fixture() -> Dictionary:
	var connector: Variant = CONNECTOR_SCRIPT.new()
	var resolver := FakeResolver.new()
	var resolve_trace_logger := FakeResolveTraceLogger.new()
	var player_loadout_hud := FakePlayerLoadoutHud.new()
	var loadout_command_handler := FakeLoadoutCommandHandler.new()
	var view := FakeView.new()
	var settings_command_handler := FakeSettingsCommandHandler.new()
	var tutorial_end_command_handler := FakeTutorialEndCommandHandler.new()
	var recorder := Recorder.new()
	(
		connector
		. bind(
			{
				"resolver": resolver,
				"resolve_trace_logger": resolve_trace_logger,
				"player_loadout_hud": player_loadout_hud,
				"loadout_command_handler": loadout_command_handler,
				"view": view,
				"settings_command_handler": settings_command_handler,
				"tutorial_end_command_handler": tutorial_end_command_handler,
			},
			{
				CONNECTOR_SCRIPT.CALLBACK_ON_RESOLVER_MATCH_FOUND: Callable(recorder, "on_resolver_match_found"),
				CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVERED: Callable(recorder, "on_intent_damage_preview_hovered"),
				CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_BLOCK_PREVIEW_HOVERED: Callable(recorder, "on_intent_block_preview_hovered"),
				CONNECTOR_SCRIPT.CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED: Callable(recorder, "on_intent_damage_preview_hover_ended"),
				CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_INTENT_BUBBLE_HOVERED: Callable(recorder, "on_enemy_intent_bubble_hovered"),
				CONNECTOR_SCRIPT.CALLBACK_ON_ENEMY_BLOCK_PREVIEW_HOVERED: Callable(recorder, "on_enemy_block_preview_hovered"),
			}
		)
	)
	return {
		"connector": connector,
		"resolver": resolver,
		"resolve_trace_logger": resolve_trace_logger,
		"player_loadout_hud": player_loadout_hud,
		"loadout_command_handler": loadout_command_handler,
		"view": view,
		"settings_command_handler": settings_command_handler,
		"tutorial_end_command_handler": tutorial_end_command_handler,
		"recorder": recorder,
	}
