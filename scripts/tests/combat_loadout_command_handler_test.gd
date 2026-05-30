extends RefCounted
class_name CombatLoadoutCommandHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_loadout_command_handler.gd")


class FakeCombat:
	extends RefCounted

	var fight_over := false

	func is_fight_over() -> bool:
		return fight_over


class FakeProgressionState:
	extends RefCounted

	var equipped_item_ids: Array[String] = ["shortsword", "", "", "", ""]
	var held_consumable_ids: Array[String] = ["fire_scroll", "", ""]


class FakeProgressionService:
	extends RefCounted

	var equipped_ids: Array[String] = []
	var added_consumables: Array[String] = []
	var used_slots: Array[int] = []
	var equip_result := {"ok": true}
	var add_consumable_result := {"ok": true}
	var use_consumable_result := {
		"ok": true,
		"result": {
			"consumable_id": "fire_scroll",
			"effects": [{"operation": "convert_random_orbs", "value": {"target_orb_id": OrbType.Id.FIRE, "count": 2}}],
		},
	}

	func equip_item(_state, item_id: String, _content) -> Dictionary:
		equipped_ids.append(item_id)
		return equip_result

	func add_consumable(_state, consumable_id: String, _content) -> Dictionary:
		added_consumables.append(consumable_id)
		return add_consumable_result

	func use_consumable(_state, slot_index: int, _content) -> Dictionary:
		used_slots.append(slot_index)
		return use_consumable_result


class FakeRunState:
	extends RefCounted

	var run_gold := 17
	var progression_state := FakeProgressionState.new()
	var progression_service := FakeProgressionService.new()
	var content := RefCounted.new()
	var sell_equipment_results: Array[Dictionary] = [{"ok": true}]
	var sell_consumable_results: Array[Dictionary] = [{"ok": true}]
	var sold_equipment_slots: Array[int] = []
	var sold_consumable_slots: Array[int] = []

	func ensure_player_progression_state() -> Variant:
		return progression_state

	func ensure_player_progression_service() -> Variant:
		return progression_service

	func ensure_content_registry() -> Variant:
		return content

	func progression_snapshot() -> Dictionary:
		return {
			"equipment_slots": progression_state.equipped_item_ids.duplicate(),
			"consumable_slots": progression_state.held_consumable_ids.duplicate(),
		}

	func sell_equipped_item(slot_index: int) -> Dictionary:
		sold_equipment_slots.append(slot_index)
		return sell_equipment_results.pop_front() if not sell_equipment_results.is_empty() else {"ok": true}

	func sell_consumable_item(slot_index: int) -> Dictionary:
		sold_consumable_slots.append(slot_index)
		return sell_consumable_results.pop_front() if not sell_consumable_results.is_empty() else {"ok": true}


class FakeView:
	extends RefCounted

	var hide_popover_count := 0
	var lookup_ids: Array[String] = []
	var content_by_id := {
		"shortsword": {"display_name": "Shortsword"},
		"fire_scroll": {"display_name": "Fire Scroll"},
	}

	func lookup_player_hud_content_definition(item_id: String) -> Dictionary:
		lookup_ids.append(item_id)
		return Dictionary(content_by_id.get(item_id, {}))

	func hide_player_hud_slot_popover() -> void:
		hide_popover_count += 1


class FakeBoardController:
	extends RefCounted

	var bind_count := 0
	var glow_count := 0

	func bind_view_model() -> void:
		bind_count += 1

	func refresh_match_glow() -> void:
		glow_count += 1


class FakeConsumableService:
	extends RefCounted

	var effects_seen: Array = []
	var rng_seen: RandomNumberGenerator = null
	var converted_total := 4

	func apply_effects(effects: Array, rng: RandomNumberGenerator) -> int:
		effects_seen = effects.duplicate(true)
		rng_seen = rng
		return converted_total


class CallbackRecorder:
	extends RefCounted

	var status_texts: Array[String] = []
	var log_lines: Array[String] = []
	var update_count := 0
	var phase := 0

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func append_combat_log(value: String) -> void:
		log_lines.append(value)

	func update_hud() -> void:
		update_count += 1

	func input_phase_value() -> int:
		return phase


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("add_test_equipment_chooses_first_missing_item", _test_add_test_equipment_chooses_first_missing_item, failures)
	_run_case("add_test_consumable_reports_failure", _test_add_test_consumable_reports_failure, failures)
	_run_case("use_consumable_requires_player_input", _test_use_consumable_requires_player_input, failures)
	_run_case("use_consumable_applies_effects_and_refreshes_board", _test_use_consumable_applies_effects_and_refreshes_board, failures)
	_run_case("sell_slot_routes_to_run_state_and_hides_popover", _test_sell_slot_routes_to_run_state_and_hides_popover, failures)
	_run_case("sell_empty_slot_reports_failure_without_update", _test_sell_empty_slot_reports_failure_without_update, failures)
	return {
		"passed": failures.is_empty(),
		"total": 6,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_add_test_equipment_chooses_first_missing_item() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.add_test_equipment()
	if run_state.progression_service.equipped_ids != ["buckler"]:
		return "Expected first missing debug equipment to be equipped."
	if recorder.status_texts.back() != "Added test equipment: buckler":
		return "Expected debug equipment success status."
	if recorder.log_lines.back() != "Debug add equipment OK: buckler":
		return "Expected debug equipment success log."
	if recorder.update_count != 1:
		return "Expected debug equipment command to refresh HUD."
	return ""


func _test_add_test_consumable_reports_failure() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	run_state.progression_service.add_consumable_result = {"ok": false, "reason": "consumable_slots_full"}
	handler.add_test_consumable()
	if run_state.progression_service.added_consumables != ["fire_scroll"]:
		return "Expected debug consumable command to request the configured consumable."
	if recorder.status_texts.back() != "Add test consumable failed: consumable_slots_full":
		return "Expected debug consumable failure status."
	if recorder.log_lines.back() != "Debug add consumable failed: consumable_slots_full":
		return "Expected debug consumable failure log."
	if recorder.update_count != 1:
		return "Expected debug consumable failure to refresh HUD."
	return ""


func _test_use_consumable_requires_player_input() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	recorder.phase = 2
	handler.try_use_consumable_slot(0)
	if not run_state.progression_service.used_slots.is_empty():
		return "Expected locked input to prevent consumable use."
	if recorder.status_texts.back() != "Consumables can only be used during player input.":
		return "Expected locked input consumable status."
	if recorder.update_count != 0:
		return "Expected locked input consumable attempt not to refresh HUD."
	return ""


func _test_use_consumable_applies_effects_and_refreshes_board() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var board: FakeBoardController = fixture["board"]
	var consumable_service: FakeConsumableService = fixture["consumable_service"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.try_use_consumable_slot(0)
	if run_state.progression_service.used_slots != [0]:
		return "Expected slot zero consumable to be used."
	if consumable_service.effects_seen.is_empty() or consumable_service.rng_seen == null:
		return "Expected consumable effects to be applied with the bound RNG."
	if board.bind_count != 1 or board.glow_count != 1:
		return "Expected board controller to refresh after consumable use."
	if recorder.status_texts.back() != "Used fire_scroll from slot 1. Converted 4 orbs.":
		return "Expected consumable success status."
	if recorder.log_lines.back() != "Consumable used: fire_scroll from slot 1. Converted 4 orbs.":
		return "Expected consumable success log."
	if recorder.update_count != 1:
		return "Expected consumable success to refresh HUD."
	return ""


func _test_sell_slot_routes_to_run_state_and_hides_popover() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var view: FakeView = fixture["view"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.sell_slot_requested("equipment", 0)
	if run_state.sold_equipment_slots != [0]:
		return "Expected equipment sell to route to RunState."
	if view.lookup_ids != ["shortsword"] or view.hide_popover_count != 1:
		return "Expected sell success to look up display content and hide popover."
	if recorder.status_texts.back() != "Sold Shortsword for gold. Gold 17.":
		return "Expected sell success status."
	if recorder.log_lines.back() != "Sold Shortsword from equipment slot 1. Gold 17.":
		return "Expected sell success log."
	if recorder.update_count != 1:
		return "Expected sell success to refresh HUD."
	return ""


func _test_sell_empty_slot_reports_failure_without_update() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.sell_slot_requested("equipment", 1)
	if not run_state.sold_equipment_slots.is_empty():
		return "Expected empty slot to avoid sell routing."
	if recorder.status_texts.back() != "Sell failed: select an occupied equipment or consumable slot first.":
		return "Expected empty slot sell status."
	if recorder.log_lines.back() != "Sell failed: no occupied loadout slot selected.":
		return "Expected empty slot sell log."
	if recorder.update_count != 0:
		return "Expected empty slot sell not to refresh HUD."
	return ""


func _fixture() -> Dictionary:
	var run_state := FakeRunState.new()
	var combat := FakeCombat.new()
	var view := FakeView.new()
	var board := FakeBoardController.new()
	var consumable_service := FakeConsumableService.new()
	var recorder := CallbackRecorder.new()
	var rng := RandomNumberGenerator.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		{
			"run_state": run_state,
			"combat": combat,
			"view": view,
			"board_controller": board,
			"board_view": null,
			"board_model": null,
			"consumable_service": consumable_service,
			"consumable_rng": rng,
		},
		{
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_APPEND_COMBAT_LOG: Callable(recorder, "append_combat_log"),
			HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
			HANDLER_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(recorder, "input_phase_value"),
		},
		{
			"test_equipment_ids": ["shortsword", "buckler"],
			"test_consumable_id": "fire_scroll",
			"player_input_phase_value": 0,
		}
	)
	return {
		"handler": handler,
		"run_state": run_state,
		"combat": combat,
		"view": view,
		"board": board,
		"consumable_service": consumable_service,
		"recorder": recorder,
		"rng": rng,
	}
