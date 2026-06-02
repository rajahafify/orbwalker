extends RefCounted
class_name ShopController

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const SHOP_TRANSITION_HANDLER_SCRIPT := preload("res://scripts/shop/shop_transition_handler.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

var _host: Control
var _model
var _view
var _flow_trace_route_id := ""
var _signals_connected := false
var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()
var _transition_handler: Variant = null


func bind(host: Control, root_nodes: Dictionary, model, view) -> void:
	_host = host
	_model = model
	_view = view
	_view.bind(root_nodes, _visuals, _player_loadout_hud)
	if not _signals_connected:
		_connect_view_signals()
		_signals_connected = true
	_view.lock_transitions(_model.transition_locked)
	_view.apply_layout()


func enter_tree() -> void:
	_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"shop_scene_load",
			"res://scenes/shop.tscn",
			{"source": "shop._enter_tree"}
		)
	RunState.flow_trace_mark("shop_enter_tree", {}, _flow_trace_route_id)


func ready() -> void:
	if _host == null or _view == null:
		return
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_active_route_id()
	if _flow_trace_route_id == "":
		_flow_trace_route_id = RunState.flow_trace_begin(
			"shop_scene_load",
			"res://scenes/shop.tscn",
			{"source": "shop._ready"}
		)
	RunState.flow_trace_mark("shop_ready_start", {}, _flow_trace_route_id)
	_audio_play_music("shop")
	RunState.flow_trace_mark("shop_after_music", {}, _flow_trace_route_id)
	RunState.flow_trace_mark("shop_after_background", {}, _flow_trace_route_id)
	RunState.flow_trace_mark("shop_after_create_ui", {}, _flow_trace_route_id)
	RunState.flow_trace_mark("shop_after_hud_bind", {}, _flow_trace_route_id)
	RunState.flow_trace_mark("shop_after_chrome", {}, _flow_trace_route_id)
	_view.apply_layout()
	RunState.flow_trace_mark("shop_after_layout", {}, _flow_trace_route_id)

	if not RunState.run_active:
		_set_status("No active run. Returning to main menu.", false)
		_queue_ready_redirect("res://scenes/main_menu.tscn", "no_active_run")
		return
	if not RunState.is_current_step_shop():
		var redirect_scene := RunState.next_scene_path()
		_queue_ready_redirect(redirect_scene, "wrong_step")
		return

	RunState.flow_trace_mark("shop_before_open_shop", {}, _flow_trace_route_id)
	var open_result: Dictionary = RunState.open_shop_for_current_level()
	RunState.flow_trace_mark(
		"shop_after_open_shop",
		{"ok": bool(open_result.get("ok", false))},
		_flow_trace_route_id
	)
	var shop_open_ok := bool(open_result.get("ok", false))
	var status_message := "Failed to open shop: %s" % String(open_result.get("reason", "unknown"))
	if shop_open_ok:
		status_message = _tutorial_shop_status() if RunState.is_tutorial_run() else "Shop opened. Buy, reroll, sell, or continue."
	_set_status(status_message, shop_open_ok)
	_refresh_ui()
	RunState.flow_trace_mark("shop_after_refresh_ui", {}, _flow_trace_route_id)
	Callable(self, "_trace_flow_first_usable_frame").call_deferred()


func handle_input(event: InputEvent) -> void:
	if _view == null:
		return
	if _view.handle_global_input(event):
		_model.clear_inventory_focus()
		_refresh_ui()


func on_viewport_size_changed() -> void:
	if _view != null:
		_view.apply_layout()


func _trace_flow_first_usable_frame() -> void:
	await _host.get_tree().process_frame
	RunState.flow_trace_mark(
		"shop_first_usable_frame",
		{"source": "shop._ready_deferred"},
		_flow_trace_route_id
	)


func _queue_ready_redirect(target_scene: String, source: String) -> void:
	_bind_transition_handler()
	_transition_handler.queue_ready_redirect(target_scene, source)


func _connect_view_signals() -> void:
	_view.offer_pressed.connect(_buy_offer_at)
	_view.relic_pressed.connect(_buy_relic_offer)
	_view.reroll_pressed.connect(_on_reroll_pressed)
	_view.sell_pressed.connect(_on_sell_pressed)
	_view.continue_pressed.connect(_on_continue_pressed)
	_view.main_menu_pressed.connect(_on_main_menu_pressed)
	_view.treasure_chest_option_pressed.connect(_choose_treasure_chest_option)
	_view.skip_treasure_chest_pressed.connect(_skip_pending_treasure_chest)
	_view.equipment_slot_selected.connect(_select_equipment_slot)
	_view.consumable_slot_selected.connect(_select_consumable_slot)
	_view.hud_sell_slot_requested.connect(_on_player_hud_sell_slot_requested)


func _refresh_ui() -> void:
	if _view == null:
		return
	_view.render(_model.snapshot())
	_view.lock_transitions(_model.transition_locked)


func _buy_offer_at(index: int) -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	var item_offers: Array = shop_snapshot.get("item_offers", [])
	if index < 0 or index >= item_offers.size():
		return
	var offer: Dictionary = item_offers[index]
	if _tutorial_shop_phase() != "":
		if _tutorial_shop_phase() != "buy_shortsword" or String(offer.get("content_id", "")) != "shortsword":
			_set_status(_tutorial_shop_status(), false)
			_refresh_ui()
			return
	var result: Dictionary = RunState.buy_shop_offer(String(offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	if bool(result.get("ok", false)) and RunState.is_tutorial_run():
		_set_status(_tutorial_shop_status(), true)
	else:
		_set_status(_result_message("Buy %s" % String(offer.get("display_name", "offer")), result), bool(result.get("ok", false)))
	_refresh_ui()
	if bool(result.get("ok", false)) and _shop_feedback_motion_enabled() and _view.has_method("play_purchase_feedback"):
		_view.play_purchase_feedback("offer", index)


func _buy_relic_offer() -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	if _tutorial_shop_phase() != "":
		_set_status(_tutorial_shop_status(), false)
		_refresh_ui()
		return
	var relic_offer: Dictionary = RunState.ensure_shop_state().relic_offer
	if relic_offer.is_empty():
		return
	var result: Dictionary = RunState.buy_shop_offer(String(relic_offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	_set_status(_result_message("Buy %s" % String(relic_offer.get("display_name", "relic")), result), bool(result.get("ok", false)))
	_refresh_ui()
	if bool(result.get("ok", false)) and _shop_feedback_motion_enabled() and _view.has_method("play_purchase_feedback"):
		_view.play_purchase_feedback("relic", -1)


func _on_reroll_pressed() -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	if _tutorial_shop_phase() != "" and _tutorial_shop_phase() != "reroll":
		_set_status(_tutorial_shop_status(), false)
		_refresh_ui()
		return
	var result: Dictionary = RunState.reroll_shop_items()
	_play_shop_result_sfx(result, "ui_accept")
	if bool(result.get("ok", false)) and RunState.is_tutorial_run():
		_set_status(_tutorial_shop_status(), true)
	else:
		_set_status(_result_message("Reroll", result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_sell_pressed() -> void:
	if not _model.try_begin_shop_action():
		return
	if _tutorial_shop_phase() != "":
		_set_status(_tutorial_shop_status(), false)
		_refresh_ui()
		return
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var selected_kind: String = _model.selected_slot_kind(progression_snapshot)
	if selected_kind == "":
		_set_status("Sell failed: select an occupied equipment or consumable slot first.", false)
		return
	var slot_index: int = _model.selected_equipment_slot if selected_kind == "equipment" else _model.selected_consumable_slot
	var result: Dictionary = RunState.sell_equipped_item(slot_index) if selected_kind == "equipment" else RunState.sell_consumable_item(slot_index)
	_play_shop_result_sfx(result, "gold")
	var action := "Sell equipment slot %d" % slot_index if selected_kind == "equipment" else "Sell consumable slot %d" % slot_index
	_set_status(_result_message(action, result), bool(result.get("ok", false)))
	if bool(result.get("ok", false)):
		if selected_kind == "equipment":
			_model.selected_equipment_slot = -1
		else:
			_model.selected_consumable_slot = -1
	_refresh_ui()


func _on_player_hud_sell_slot_requested(slot_type: String, slot_index: int) -> void:
	if not _model.try_begin_shop_action():
		return
	if _tutorial_shop_phase() != "":
		_set_status(_tutorial_shop_status(), false)
		_refresh_ui()
		return
	var result: Dictionary = RunState.sell_equipped_item(slot_index) if slot_type == "equipment" else RunState.sell_consumable_item(slot_index)
	_play_shop_result_sfx(result, "gold")
	var action := "Sell equipment slot %d" % slot_index if slot_type == "equipment" else "Sell consumable slot %d" % slot_index
	_set_status(_result_message(action, result), bool(result.get("ok", false)))
	if bool(result.get("ok", false)):
		_model.clear_inventory_focus()
		_view.clear_inventory_focus()
	_refresh_ui()


func _choose_treasure_chest_option(index: int) -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.choose_treasure_chest_option(index)
	_play_shop_result_sfx(result, "purchase")
	if not bool(result.get("ok", false)) and _is_full_slot_reason(String(result.get("reason", ""))):
		_set_status("No free slot for this reward. Sell from the loadout HUD, then pick again, or press Skip.", false)
	else:
		_set_status(_result_message("Chest pick", result), bool(result.get("ok", false)))
	_refresh_ui()


func _skip_pending_treasure_chest() -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.discard_pending_treasure_chest_options()
	_play_shop_result_sfx(result, "ui_cancel")
	var message := _result_message("Skip chest reward", result)
	if bool(result.get("ok", false)):
		message = "Skipped chest reward. Gold %d." % RunState.run_gold
	_set_status(message, bool(result.get("ok", false)))
	_refresh_ui()


func _select_equipment_slot(index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var equipment_slots: Array = progression_snapshot.get("equipment_slots", [])
	if index < 0 or index >= equipment_slots.size() or String(equipment_slots[index]) == "":
		_model.selected_equipment_slot = -1
		_set_status("Select a filled equipment slot before selling.", false)
	else:
		_model.selected_equipment_slot = index
		_model.selected_consumable_slot = -1
		var content := _lookup_content_definition(String(equipment_slots[index]))
		_set_status("Selected %s for selling." % String(content.get("display_name", equipment_slots[index])), true)
	_refresh_ui()


func _select_consumable_slot(index: int) -> void:
	var progression_snapshot: Dictionary = RunState.progression_snapshot()
	var consumable_slots: Array = progression_snapshot.get("consumable_slots", [])
	if index < 0 or index >= consumable_slots.size() or String(consumable_slots[index]) == "":
		_model.selected_consumable_slot = -1
		_set_status("Select a filled consumable slot before selling.", false)
	else:
		_model.selected_consumable_slot = index
		_model.selected_equipment_slot = -1
		var content := _lookup_content_definition(String(consumable_slots[index]))
		_set_status("Selected %s for selling." % String(content.get("display_name", consumable_slots[index])), true)
	_refresh_ui()


func _on_continue_pressed() -> void:
	_bind_transition_handler()
	_transition_handler.continue_pressed()


func _on_main_menu_pressed() -> void:
	_bind_transition_handler()
	_transition_handler.main_menu_pressed()


func _set_status(message: String, positive: bool) -> void:
	_model.set_status(message, positive)
	_view.set_status(message, positive)


func _tutorial_shop_status() -> String:
	match _tutorial_shop_phase():
		"buy_shortsword":
			return "Tutorial: buy Iron Shortsword first."
		"reroll":
			return "Tutorial: reroll once to see new shop stock."
		"continue":
			return "Tutorial: continue to the next fight."
		_:
			return "Tutorial: buy an item if you can afford it, reroll to change stock, then Continue to the next fight."


func _tutorial_shop_phase() -> String:
	if not RunState.is_tutorial_run():
		return ""
	if RunState.dungeon_level != 1 or String(RunState.current_step_key) != "shop":
		return ""
	if RunState.has_method("current_shop_ordinal_in_level") and int(RunState.current_shop_ordinal_in_level()) != 1:
		return ""
	var progression_snapshot := RunState.progression_snapshot()
	var has_shortsword := false
	for raw_id in progression_snapshot.get("equipment_slots", []):
		if String(raw_id) == "shortsword":
			has_shortsword = true
			break
	if not has_shortsword:
		return "buy_shortsword"
	var shop_snapshot: Dictionary = RunState.ensure_shop_state().to_snapshot()
	if int(shop_snapshot.get("reroll_count", 0)) <= 0:
		return "reroll"
	return "continue"


func _clear_inventory_focus() -> void:
	_model.clear_inventory_focus()
	_view.clear_inventory_focus()


func _bind_transition_handler() -> void:
	if _transition_handler == null:
		_transition_handler = SHOP_TRANSITION_HANDLER_SCRIPT.new()
	_transition_handler.bind(
		{
			"run_state": RunState,
			"host": _host,
			"model": _model,
			"view": _view,
		},
		{
			SHOP_TRANSITION_HANDLER_SCRIPT.CALLBACK_SET_STATUS: Callable(self, "_set_status"),
			SHOP_TRANSITION_HANDLER_SCRIPT.CALLBACK_CLEAR_INVENTORY_FOCUS: Callable(self, "_clear_inventory_focus"),
			SHOP_TRANSITION_HANDLER_SCRIPT.CALLBACK_TUTORIAL_SHOP_PHASE: Callable(self, "_tutorial_shop_phase"),
			SHOP_TRANSITION_HANDLER_SCRIPT.CALLBACK_TUTORIAL_SHOP_STATUS: Callable(self, "_tutorial_shop_status"),
			SHOP_TRANSITION_HANDLER_SCRIPT.CALLBACK_REFRESH_UI: Callable(self, "_refresh_ui"),
		},
		{"route_id": _flow_trace_route_id}
	)


func _result_message(action: String, result: Dictionary) -> String:
	if bool(result.get("ok", false)):
		return "%s: OK. Gold %d." % [action, RunState.run_gold]
	return "%s: failed (%s)." % [action, String(result.get("reason", "unknown"))]


func _play_shop_result_sfx(result: Dictionary, success_key: String) -> void:
	if not bool(result.get("ok", false)):
		_audio_play_sfx("error")
		return
	if success_key == "purchase" and _shop_feedback_enabled():
		_audio_play_sfx("purchase_juice")
		return
	_audio_play_sfx(success_key)


func _shop_feedback_enabled() -> bool:
	return RunState.game_juice_flag_enabled(GAME_JUICE_FLAGS_SCRIPT.SHOP_CHOICE_FEEDBACK)


func _shop_feedback_motion_enabled() -> bool:
	return _shop_feedback_enabled() and not RunState.reduced_motion_enabled()


func _audio_play_music(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_music"):
		audio.call("play_music", key)


func _audio_play_sfx(key: String) -> void:
	var audio := _audio_manager_node()
	if audio != null and audio.has_method("play_sfx"):
		audio.call("play_sfx", key)


func _audio_manager_node() -> Node:
	if _host == null:
		return null
	return AUDIO_MANAGER_RESOLVER_SCRIPT.audio_manager_node(_host.get_tree())


func _lookup_content_definition(content_id: String) -> Dictionary:
	return _player_loadout_hud.lookup_content_definition(content_id)


func _is_full_slot_reason(reason: String) -> bool:
	return reason == "equipment_slots_full" or reason == "consumable_slots_full"
