extends RefCounted
class_name CombatLoadoutCommandHandler

const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_APPEND_COMBAT_LOG := "append_combat_log"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_INPUT_PHASE_VALUE := "input_phase_value"

const DEFAULT_TEST_EQUIPMENT_IDS: Array[String] = [
	"shortsword",
	"buckler",
]
const DEFAULT_TEST_CONSUMABLE_ID := "fire_scroll"

var _run_state: Variant = null
var _combat: Variant = null
var _view: Variant = null
var _board_controller: Variant = null
var _board_view: Variant = null
var _board_model: Variant = null
var _consumable_service: Variant = null
var _consumable_rng: RandomNumberGenerator = null
var _callbacks: Dictionary = {}
var _test_equipment_ids: Array[String] = DEFAULT_TEST_EQUIPMENT_IDS.duplicate()
var _test_consumable_id := DEFAULT_TEST_CONSUMABLE_ID
var _player_input_phase_value := 0


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_combat = dependencies.get("combat", null)
	_view = dependencies.get("view", null)
	_board_controller = dependencies.get("board_controller", null)
	_board_view = dependencies.get("board_view", null)
	_board_model = dependencies.get("board_model", null)
	_consumable_service = dependencies.get("consumable_service", null)
	_consumable_rng = dependencies.get("consumable_rng", null) as RandomNumberGenerator
	_callbacks = callbacks.duplicate()
	_test_equipment_ids = []
	for raw_item_id in Array(config.get("test_equipment_ids", DEFAULT_TEST_EQUIPMENT_IDS)):
		_test_equipment_ids.append(String(raw_item_id))
	_test_consumable_id = String(config.get("test_consumable_id", DEFAULT_TEST_CONSUMABLE_ID))
	_player_input_phase_value = int(config.get("player_input_phase_value", 0))


func add_test_equipment() -> void:
	if _run_state == null:
		return
	var progression_state: Variant = _run_state.ensure_player_progression_state()
	var progression_service: Variant = _run_state.ensure_player_progression_service()
	var content: Variant = _run_state.ensure_content_registry()
	var candidate_item_id := _first_missing_test_equipment(progression_state)
	var result: Dictionary = progression_service.equip_item(progression_state, candidate_item_id, content)
	if bool(result.get("ok", false)):
		_set_status_text("Added test equipment: %s" % candidate_item_id)
		_append_combat_log("Debug add equipment OK: %s" % candidate_item_id)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_set_status_text("Add test equipment failed: %s" % reason)
		_append_combat_log("Debug add equipment failed: %s" % reason)
	_update_hud()


func add_test_consumable() -> void:
	if _run_state == null:
		return
	var progression_state: Variant = _run_state.ensure_player_progression_state()
	var progression_service: Variant = _run_state.ensure_player_progression_service()
	var content: Variant = _run_state.ensure_content_registry()
	var result: Dictionary = progression_service.add_consumable(progression_state, _test_consumable_id, content)
	if bool(result.get("ok", false)):
		_set_status_text("Added test consumable: %s" % _test_consumable_id)
		_append_combat_log("Debug add consumable OK: %s" % _test_consumable_id)
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_set_status_text("Add test consumable failed: %s" % reason)
		_append_combat_log("Debug add consumable failed: %s" % reason)
	_update_hud()


func try_use_first_consumable() -> void:
	try_use_consumable_slot(0)


func try_use_consumable_slot(slot_index: int) -> void:
	if _combat == null or (_combat.has_method("is_fight_over") and bool(_combat.is_fight_over())):
		return
	if _input_phase_value() != _player_input_phase_value:
		_set_status_text("Consumables can only be used during player input.")
		return
	if _run_state == null:
		return

	var progression_state: Variant = _run_state.ensure_player_progression_state()
	var progression_service: Variant = _run_state.ensure_player_progression_service()
	var content: Variant = _run_state.ensure_content_registry()
	var use_result: Dictionary = progression_service.use_consumable(progression_state, slot_index, content)
	if not bool(use_result.get("ok", false)):
		var reason := String(use_result.get("reason", "unknown_error"))
		_set_status_text("Use consumable failed: %s" % reason)
		_append_combat_log("Use consumable failed: %s" % reason)
		_update_hud()
		return

	var payload: Dictionary = use_result.get("result", {})
	var consumable_id := String(payload.get("consumable_id", ""))
	var effects: Array = payload.get("effects", [])
	var conversion_total := _apply_consumable_effects(effects)
	_refresh_board_after_consumable()
	_set_status_text("Used %s from slot %d. Converted %d orbs." % [consumable_id, slot_index + 1, conversion_total])
	_append_combat_log("Consumable used: %s from slot %d. Converted %d orbs." % [consumable_id, slot_index + 1, conversion_total])
	_update_hud()


func sell_slot_requested(slot_type: String, slot_index: int) -> void:
	if _run_state == null:
		return
	var progression_snapshot: Dictionary = _run_state.progression_snapshot()
	var slots: Array = progression_snapshot.get("equipment_slots", []) if slot_type == "equipment" else progression_snapshot.get("consumable_slots", [])
	if slot_index < 0 or slot_index >= slots.size() or String(slots[slot_index]) == "":
		_set_status_text("Sell failed: select an occupied equipment or consumable slot first.")
		_append_combat_log("Sell failed: no occupied loadout slot selected.")
		return
	var item_id := String(slots[slot_index])
	var item_content: Dictionary = {}
	if _view != null and _view.has_method("lookup_player_hud_content_definition"):
		item_content = _view.lookup_player_hud_content_definition(item_id)
	var result: Dictionary = _run_state.sell_equipped_item(slot_index) if slot_type == "equipment" else _run_state.sell_consumable_item(slot_index)
	var display_name := String(item_content.get("display_name", item_id))
	if bool(result.get("ok", false)):
		_set_status_text("Sold %s for gold. Gold %d." % [display_name, int(_run_state.run_gold)])
		_append_combat_log("Sold %s from %s slot %d. Gold %d." % [display_name, slot_type, slot_index + 1, int(_run_state.run_gold)])
		if _view != null and _view.has_method("hide_player_hud_slot_popover"):
			_view.hide_player_hud_slot_popover()
	else:
		var reason := String(result.get("reason", "unknown_error"))
		_set_status_text("Sell failed: %s" % reason)
		_append_combat_log("Sell %s failed: %s" % [display_name, reason])
	_update_hud()


func _first_missing_test_equipment(progression_state: Variant) -> String:
	for item_id in _test_equipment_ids:
		if not progression_state.equipped_item_ids.has(item_id):
			return item_id
	if _test_equipment_ids.is_empty():
		return ""
	return _test_equipment_ids[0]


func _apply_consumable_effects(effects: Array) -> int:
	if _consumable_service == null or not _consumable_service.has_method("apply_effects"):
		return 0
	return int(_consumable_service.apply_effects(effects, _consumable_rng))


func _refresh_board_after_consumable() -> void:
	if _board_controller != null:
		if _board_controller.has_method("bind_view_model"):
			_board_controller.bind_view_model()
		if _board_controller.has_method("refresh_match_glow"):
			_board_controller.refresh_match_glow()
		return
	if _board_view != null and _board_view.has_method("set_board_presentation_model"):
		_board_view.set_board_presentation_model(_board_model)


func _input_phase_value() -> int:
	var input_phase_value: Callable = _callbacks.get(CALLBACK_INPUT_PHASE_VALUE, Callable())
	if input_phase_value.is_valid():
		return int(input_phase_value.call())
	return _player_input_phase_value


func _set_status_text(value: String) -> void:
	var set_status_text: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if set_status_text.is_valid():
		set_status_text.call(value)


func _append_combat_log(value: String) -> void:
	var append_combat_log: Callable = _callbacks.get(CALLBACK_APPEND_COMBAT_LOG, Callable())
	if append_combat_log.is_valid():
		append_combat_log.call(value)


func _update_hud() -> void:
	var update_hud: Callable = _callbacks.get(CALLBACK_UPDATE_HUD, Callable())
	if update_hud.is_valid():
		update_hud.call()
