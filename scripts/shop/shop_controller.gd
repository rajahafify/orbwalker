extends RefCounted
class_name ShopController

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const AUDIO_MANAGER_RESOLVER_SCRIPT := preload("res://scripts/core/audio_manager_resolver.gd")
const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")

var _host: Control
var _model
var _view
var _flow_trace_route_id := ""
var _signals_connected := false
var _visuals = VISUAL_REGISTRY_SCRIPT.new()
var _player_loadout_hud = PLAYER_LOADOUT_HUD_SCRIPT.new()


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
	_set_status(
		"Shop opened. Buy, reroll, sell, or continue." if bool(open_result.get("ok", false))
		else "Failed to open shop: %s" % String(open_result.get("reason", "unknown")),
		bool(open_result.get("ok", false))
	)
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
	RunState.flow_trace_mark(
		"shop_ready_redirect_before_change_scene",
		{"source": source},
		_flow_trace_route_id,
		target_scene
	)
	Callable(self, "_deferred_ready_redirect").bind(target_scene, source).call_deferred()


func _deferred_ready_redirect(target_scene: String, source: String) -> void:
	if _model.transition_locked:
		return
	_begin_transition_lock()
	var transition_source := "shop_ready_redirect_%s" % source
	var scene_change_result := RunState.flow_trace_change_scene(
		_host.get_tree(),
		target_scene,
		_flow_trace_route_id,
		transition_source,
		"",
		Callable(self, "_on_scene_change_post_ready_rollback")
	)
	if scene_change_result == OK:
		return
	var failure_reason := FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result)
	_set_status("Redirect failed: %s" % failure_reason, false)
	RunState.flow_trace_mark(
		"shop_ready_redirect_change_scene_failed",
		{
			"source": source,
			"reason": failure_reason,
		},
		_flow_trace_route_id,
		target_scene
	)
	_end_transition_lock()


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
	var result: Dictionary = RunState.buy_shop_offer(String(offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	_set_status(_result_message("Buy %s" % String(offer.get("display_name", "offer")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _buy_relic_offer() -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	var relic_offer: Dictionary = RunState.ensure_shop_state().relic_offer
	if relic_offer.is_empty():
		return
	var result: Dictionary = RunState.buy_shop_offer(String(relic_offer.get("offer_id", "")))
	_play_shop_result_sfx(result, "purchase")
	_set_status(_result_message("Buy %s" % String(relic_offer.get("display_name", "relic")), result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_reroll_pressed() -> void:
	if not _model.try_begin_shop_action():
		return
	_clear_inventory_focus()
	var result: Dictionary = RunState.reroll_shop_items()
	_play_shop_result_sfx(result, "ui_accept")
	_set_status(_result_message("Reroll", result), bool(result.get("ok", false)))
	_refresh_ui()


func _on_sell_pressed() -> void:
	if not _model.try_begin_shop_action():
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
	if _model.transition_locked:
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	RunState.flow_trace_mark(
		"shop_continue_button_pressed",
		{"button_text": "Continue"},
		_flow_trace_route_id
	)
	var pre_transition_state := RunState.snapshot_run_transition_state()
	RunState.flow_trace_mark("shop_before_advance_after_shop", {}, _flow_trace_route_id)
	var transition: Dictionary = RunState.advance_after_shop(false)
	var next_scene := String(transition.get("next_scene", "res://scenes/main_menu.tscn"))
	RunState.flow_trace_mark(
		"shop_after_advance_after_shop",
		{
			"ok": bool(transition.get("ok", false)),
			"step": String(transition.get("step", "")),
		},
		_flow_trace_route_id,
		next_scene
	)
	if not bool(transition.get("ok", false)):
		_set_status("Continue failed: %s" % String(transition.get("reason", "unknown")), false)
		_restore_transition_snapshot(pre_transition_state)
		_end_transition_lock()
		return
	var route_id := _flow_trace_route_id
	if next_scene.find("combat.tscn") >= 0:
		route_id = RunState.flow_trace_begin(
			"shop_to_combat",
			next_scene,
			{"source": "shop_continue_button"}
		)
	RunState.flow_trace_mark(
		"shop_before_change_scene_to_file",
		{"source": "shop_continue_button"},
		route_id,
		next_scene
	)
	var scene_change_result := RunState.flow_trace_change_scene(
		_host.get_tree(),
		next_scene,
		route_id,
		"shop_continue_button",
		"",
		Callable(self, "_on_scene_change_post_ready_rollback"),
		pre_transition_state
	)
	if scene_change_result != OK:
		_set_status("Continue failed: %s" % FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result), false)
		_restore_transition_snapshot(pre_transition_state)
		_end_transition_lock()


func _on_main_menu_pressed() -> void:
	if _model.transition_locked:
		return
	_begin_transition_lock()
	_clear_inventory_focus()
	RunState.flow_trace_mark(
		"shop_main_menu_button_pressed",
		{"button_text": "Menu"},
		_flow_trace_route_id,
		"res://scenes/main_menu.tscn"
	)
	RunState.flow_trace_mark(
		"shop_before_change_scene_to_file_main_menu",
		{"source": "shop_main_menu_button"},
		_flow_trace_route_id,
		"res://scenes/main_menu.tscn"
	)
	var scene_change_result := RunState.flow_trace_change_scene(
		_host.get_tree(),
		"res://scenes/main_menu.tscn",
		_flow_trace_route_id,
		"shop_main_menu_button",
		"",
		Callable(self, "_on_scene_change_post_ready_rollback")
	)
	if scene_change_result != OK:
		_set_status("Main menu failed: %s" % FLOW_RESULT_UTILS.scene_change_failure_reason(scene_change_result), false)
		_end_transition_lock()


func _on_scene_change_post_ready_rollback(result: Dictionary) -> void:
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	_set_status("Transition failed: %s" % failure_reason, false)
	RunState.flow_trace_mark(
		"shop_post_ready_scene_change_failed",
		{
			"source": String(result.get("source", "shop")),
			"reason": failure_reason,
		},
		String(result.get("route_id", _flow_trace_route_id)),
		String(result.get("target_scene", ""))
	)
	_end_transition_lock()


func _set_status(message: String, positive: bool) -> void:
	_model.set_status(message, positive)
	_view.set_status(message, positive)


func _clear_inventory_focus() -> void:
	_model.clear_inventory_focus()
	_view.clear_inventory_focus()


func _begin_transition_lock() -> void:
	_model.begin_transition_lock()
	_view.lock_transitions(true)


func _end_transition_lock() -> void:
	_model.end_transition_lock()
	_view.lock_transitions(false)


func _result_message(action: String, result: Dictionary) -> String:
	if bool(result.get("ok", false)):
		return "%s: OK. Gold %d." % [action, RunState.run_gold]
	return "%s: failed (%s)." % [action, String(result.get("reason", "unknown"))]


func _restore_transition_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return
	RunState.restore_run_transition_state(snapshot)


func _play_shop_result_sfx(result: Dictionary, success_key: String) -> void:
	_audio_play_sfx(success_key if bool(result.get("ok", false)) else "error")


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
