extends RefCounted
class_name ShopSettingsControllerTest

const SHOP_CONTROLLER_SCRIPT := preload("res://scripts/shop/shop_controller.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")


class FakeShopView:
	extends RefCounted

	signal offer_pressed(index: int)
	signal relic_pressed
	signal reroll_pressed
	signal sell_pressed
	signal continue_pressed
	signal main_menu_pressed
	signal settings_pressed
	signal treasure_chest_option_pressed(index: int)
	signal skip_treasure_chest_pressed
	signal equipment_slot_selected(index: int)
	signal consumable_slot_selected(index: int)
	signal hud_sell_slot_requested(slot_type: String, slot_index: int)

	var statuses: Array[Dictionary] = []
	var locks: Array[bool] = []
	var global_input_count := 0

	func bind(_root_nodes: Dictionary, _visuals: Variant, _player_loadout_hud: Variant) -> void:
		pass

	func lock_transitions(enabled: bool) -> void:
		locks.append(enabled)

	func apply_layout() -> void:
		pass

	func set_status(message: String, positive: bool) -> void:
		statuses.append({
			"message": message,
			"positive": positive,
		})

	func handle_global_input(_event: InputEvent) -> bool:
		global_input_count += 1
		return false

	func clear_inventory_focus() -> void:
		pass


class FakeShopModel:
	extends RefCounted

	var transition_locked := false
	var status_message := ""
	var status_positive := true
	var clear_count := 0

	func set_status(message: String, positive: bool) -> void:
		status_message = message
		status_positive = positive

	func clear_inventory_focus() -> void:
		clear_count += 1


class FakeTransitionHandler:
	extends RefCounted

	var bind_count := 0
	var main_menu_count := 0
	var new_run_count := 0

	func bind(_dependencies: Dictionary, _callbacks: Dictionary = {}, _config: Dictionary = {}) -> void:
		bind_count += 1

	func main_menu_pressed() -> void:
		main_menu_count += 1

	func new_run_pressed() -> void:
		new_run_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	var previous_settings := _preserve_settings()
	_run_case("settings_button_opens_overlay_and_updates_speed", _test_settings_button_opens_overlay_and_updates_speed, failures)
	_run_case("settings_action_buttons_route_through_shop_transition_handler", _test_settings_action_buttons_route_through_shop_transition_handler, failures)
	_run_case("settings_overlay_blocks_shop_global_input", _test_settings_overlay_blocks_shop_global_input, failures)
	_restore_settings(previous_settings)

	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_settings_button_opens_overlay_and_updates_speed() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var view: FakeShopView = fixture["view"]
	var model: FakeShopModel = fixture["model"]
	var controller: Variant = fixture["controller"]

	view.settings_pressed.emit()
	var overlay := root.get_node_or_null("CombatSettingsOverlay") as Control
	if overlay == null or not overlay.visible:
		root.free()
		return "Expected shop settings button to show the shared settings overlay."
	if model.status_message != "Settings opened." or view.statuses.back().get("message", "") != "Settings opened.":
		root.free()
		return "Expected opening settings to report shop status."
	var coordinator: Variant = controller.get("_settings_overlay_coordinator")
	if coordinator == null or coordinator.speed_buttons().size() != 4:
		root.free()
		return "Expected controller to bind speed buttons through the settings overlay coordinator."
	coordinator.speed_buttons()[2].emit_signal("pressed")
	if RunState.vfx_speed() != "fast":
		root.free()
		return "Expected speed selection from shop settings to update RunState."
	if model.status_message != "VFX speed: Fast.":
		root.free()
		return "Expected speed selection to update shop status."
	if not overlay.visible:
		root.free()
		return "Expected speed selection to keep the settings overlay open."
	coordinator.continue_button().emit_signal("pressed")
	if overlay.visible:
		root.free()
		return "Expected settings Continue action to close the overlay."
	if model.status_message != "Settings closed.":
		root.free()
		return "Expected closing settings to update shop status."
	root.free()
	return ""


func _test_settings_action_buttons_route_through_shop_transition_handler() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var view: FakeShopView = fixture["view"]
	var controller: Variant = fixture["controller"]
	var transition_handler := FakeTransitionHandler.new()
	controller.set("_transition_handler", transition_handler)

	view.settings_pressed.emit()
	var coordinator: Variant = controller.get("_settings_overlay_coordinator")
	coordinator.main_menu_button().emit_signal("pressed")
	if transition_handler.main_menu_count != 1:
		root.free()
		return "Expected settings Main Menu action to route through the shop transition handler."
	if coordinator.is_visible():
		root.free()
		return "Expected settings Main Menu action to hide the overlay before routing."
	view.settings_pressed.emit()
	coordinator.new_run_button().emit_signal("pressed")
	if transition_handler.new_run_count != 1:
		root.free()
		return "Expected settings New Run action to route through the shop transition handler."
	root.free()
	return ""


func _test_settings_overlay_blocks_shop_global_input() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var view: FakeShopView = fixture["view"]
	var model: FakeShopModel = fixture["model"]
	var controller: Variant = fixture["controller"]

	view.settings_pressed.emit()
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	controller.handle_input(event)
	if view.global_input_count != 0:
		root.free()
		return "Expected visible settings overlay to block shop global input forwarding."
	if model.clear_count != 0:
		root.free()
		return "Expected visible settings overlay not to clear inventory focus through global input."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "ShopLayoutRoot"
	var view := FakeShopView.new()
	var model := FakeShopModel.new()
	var controller: Variant = SHOP_CONTROLLER_SCRIPT.new()
	controller.bind(root, {"layout_root": root}, model, view)
	return {
		"root": root,
		"view": view,
		"model": model,
		"controller": controller,
	}


func _preserve_settings() -> Dictionary:
	return {
		"vfx_speed": RunState.vfx_speed(),
		"combat_vfx_quality": RunState.combat_vfx_quality(),
		"reduced_motion": RunState.reduced_motion_enabled(),
		"game_juice": RunState.game_juice_enabled(),
		"game_juice_flags": RunState.game_juice_flags(),
	}


func _restore_settings(settings: Dictionary) -> void:
	RunState.set_vfx_speed(String(settings.get("vfx_speed", "normal")))
	RunState.set_combat_vfx_quality(String(settings.get("combat_vfx_quality", "low")))
	RunState.set_reduced_motion_enabled(bool(settings.get("reduced_motion", false)))
	RunState.set_game_juice_enabled(bool(settings.get("game_juice", true)))
	var flags := Dictionary(settings.get("game_juice_flags", GAME_JUICE_FLAGS_SCRIPT.default_flags()))
	for flag_key in GAME_JUICE_FLAGS_SCRIPT.all_keys():
		RunState.set_game_juice_flag_enabled(flag_key, bool(flags.get(flag_key, true)))
