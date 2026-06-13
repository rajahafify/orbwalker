extends RefCounted
class_name UiTextLegibilityRuntimeTest

const PLAYER_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const MAIN_MENU_SETTINGS_OVERLAY := preload("res://scripts/main_menu/main_menu_settings_overlay.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")
const COMBAT_SETTINGS_OVERLAY_PRESENTER := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
const COMBAT_TUTORIAL_END_OVERLAY_PRESENTER := preload("res://scripts/combat/combat_tutorial_end_overlay_presenter.gd")
const COMBAT_TUTORIAL_PROMPT_PRESENTER := preload("res://scripts/combat/combat_tutorial_prompt_presenter.gd")
const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const SHOP_PLAYER_HUD_PRESENTER := preload("res://scripts/shop/shop_player_hud_presenter.gd")
const SHOP_HELP_MODAL_PRESENTER := preload("res://scripts/shop/shop_help_modal_presenter.gd")
const SHOP_TREASURE_CHEST_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_treasure_chest_overlay_presenter.gd")
const SHOP_TUTORIAL_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_tutorial_overlay_presenter.gd")

const MIN_VISIBLE_TEXT_FONT_SIZE := 20
const TEST_VIEWPORTS := [
	Vector2(720.0, 1280.0),
	Vector2(1080.0, 1920.0),
	Vector2(1080.0, 2400.0),
]
const STANDALONE_SCENES := [
	"res://scenes/debug/vfx_gallery_index.tscn",
	"res://scenes/debug/vfx_gallery_show.tscn",
	"res://scenes/ui/elemental_mastery_hud_variants.tscn",
	"res://scenes/ui/top_header.tscn",
]
const SAFE_APP_SCENES := [
	"res://scenes/main_menu.tscn",
	"res://scenes/collection.tscn",
	"res://scenes/run_summary.tscn",
]


class FakeTreasureChestVisuals:
	extends RefCounted

	func icon_for_key(_key: String) -> Texture2D:
		return ImageTexture.new()


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("standalone_scenes_keep_visible_text_readable", _test_standalone_scenes_keep_visible_text_readable, failures)
	_run_case("initialized_player_hud_keeps_visible_text_readable", _test_initialized_player_hud_keeps_visible_text_readable, failures)
	_run_case(
		"initialized_player_hud_mastery_tooltip_keeps_visible_text_readable", _test_initialized_player_hud_mastery_tooltip_keeps_visible_text_readable, failures
	)
	_run_case(
		"initialized_player_hud_slot_detail_popover_keeps_visible_text_readable",
		_test_initialized_player_hud_slot_detail_popover_keeps_visible_text_readable,
		failures
	)
	_run_case("shop_treasure_chest_overlay_keeps_visible_text_readable", _test_shop_treasure_chest_overlay_keeps_visible_text_readable, failures)
	_run_case("interactive_overlays_keep_visible_text_readable", _test_interactive_overlays_keep_visible_text_readable, failures)
	_run_case("app_scenes_keep_visible_text_readable", _test_app_scenes_keep_visible_text_readable, failures)
	_run_case("stateful_gameplay_scenes_keep_visible_text_readable", _test_stateful_gameplay_scenes_keep_visible_text_readable, failures)
	return {
		"passed": failures.is_empty(),
		"total": 8,
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


func _test_standalone_scenes_keep_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for runtime UI text audit."
	for scene_path in STANDALONE_SCENES:
		for viewport_size in TEST_VIEWPORTS:
			var result := _audit_scene_for_viewport(tree, scene_path, viewport_size)
			if result != "":
				return result
	return ""


func _test_initialized_player_hud_keeps_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for initialized Player HUD audit."
	for viewport_size in TEST_VIEWPORTS:
		var result := _audit_initialized_player_hud_for_viewport(tree, viewport_size)
		if result != "":
			return result
	return ""


func _test_initialized_player_hud_mastery_tooltip_keeps_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for initialized Player HUD mastery tooltip audit."
	for viewport_size in TEST_VIEWPORTS:
		var result := _audit_initialized_player_hud_mastery_tooltip_for_viewport(tree, viewport_size)
		if result != "":
			return result
	return ""


func _test_initialized_player_hud_slot_detail_popover_keeps_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for initialized Player HUD slot detail popover audit."
	for viewport_size in TEST_VIEWPORTS:
		var result := _audit_initialized_player_hud_slot_detail_popover_for_viewport(tree, viewport_size)
		if result != "":
			return result
	return ""


func _test_shop_treasure_chest_overlay_keeps_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for shop treasure chest overlay audit."
	for viewport_size in TEST_VIEWPORTS:
		var result := _audit_shop_treasure_chest_overlay_for_viewport(tree, viewport_size)
		if result != "":
			return result
	return ""


func _test_interactive_overlays_keep_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for interactive overlay text audit."
	for viewport_size in TEST_VIEWPORTS:
		var result := _audit_interactive_overlays_for_viewport(tree, viewport_size)
		if result != "":
			return result
	return ""


func _test_app_scenes_keep_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for app-scene UI text audit."
	for scene_path in SAFE_APP_SCENES:
		for viewport_size in TEST_VIEWPORTS:
			var result := _audit_scene_for_viewport(tree, scene_path, viewport_size)
			if result != "":
				return result
	return ""


func _test_stateful_gameplay_scenes_keep_visible_text_readable() -> String:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return "Expected SceneTree for gameplay UI text audit."
	for viewport_size in TEST_VIEWPORTS:
		var combat_result := _audit_combat_scene_for_viewport(tree, viewport_size)
		if combat_result != "":
			return combat_result
		var shop_result := _audit_shop_scene_for_viewport(tree, viewport_size)
		if shop_result != "":
			return shop_result
	return ""


func _audit_combat_scene_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_new_run()
	var result := _audit_scene_for_viewport(tree, "res://scenes/combat.tscn", viewport_size)
	RunState.restore_run_transition_state(saved_snapshot)
	return result


func _audit_shop_scene_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_tutorial_run()
	RunState.mark_fight_victory()
	RunState.set_gold(200)
	var result := _audit_scene_for_viewport(tree, "res://scenes/shop.tscn", viewport_size)
	RunState.restore_run_transition_state(saved_snapshot)
	return result


func _audit_scene_for_viewport(tree: SceneTree, scene_path: String, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var instance := _instantiate_scene(scene_path)
	if instance == null:
		tree.root.size = previous_size
		return "Expected UI scene to instantiate: %s." % scene_path
	_prepare_root_control(instance, viewport_size)
	tree.root.add_child(instance)
	var failures := _visible_text_failures(instance, _scene_label(scene_path, viewport_size))
	instance.free()
	tree.root.size = previous_size
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _audit_initialized_player_hud_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var instance := _instantiate_scene("res://scenes/ui/player_hud.tscn")
	if instance == null:
		tree.root.size = previous_size
		return "Expected Player HUD scene to instantiate."
	_prepare_root_control(instance, viewport_size)
	tree.root.add_child(instance)

	var hud: Variant = PLAYER_HUD_SCRIPT.new()
	var nodes: Dictionary = SHOP_PLAYER_HUD_PRESENTER.hud_nodes_from_section(instance)
	nodes["popover_parent"] = instance
	nodes["popover_z_index"] = 210
	hud.bind_player_hud(nodes)
	hud.update_player_hud_layout()
	hud.update_player_data({"progression": {"equipment_slots": [], "consumable_slots": [], "relic_ids": [], "mastery_levels": {}}})

	var failures := _visible_text_failures(instance, _scene_label("res://scenes/ui/player_hud.tscn", viewport_size))
	instance.free()
	tree.root.size = previous_size
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _audit_initialized_player_hud_mastery_tooltip_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var instance := _instantiate_scene("res://scenes/ui/player_hud.tscn")
	if instance == null:
		tree.root.size = previous_size
		return "Expected Player HUD scene to instantiate for mastery tooltip audit."
	_prepare_root_control(instance, viewport_size)
	tree.root.add_child(instance)

	var hud: Variant = PLAYER_HUD_SCRIPT.new()
	var nodes: Dictionary = SHOP_PLAYER_HUD_PRESENTER.hud_nodes_from_section(instance)
	nodes["popover_parent"] = instance
	nodes["popover_z_index"] = 210
	hud.bind_player_hud(nodes)
	hud.update_player_hud_layout()
	var mastery_levels := {3: 2, 4: 1, 5: 1, 0: 3, 1: 1, 2: 1}
	var mastery_player_data := {
		"progression":
		{
			"equipment_slots": ["shortsword"],
			"consumable_slots": [],
			"relic_ids": [],
			"mastery_levels": mastery_levels,
		},
		"combat_mastery_feedback_totals": {3: 4},
		"combat_mastery_hover_payload":
		{
			"mastery_levels": mastery_levels,
			"orb_values_by_id": {3: 9, 4: 7, 5: 7, 0: 11, 1: 8, 2: 8},
		},
	}
	hud.call("update_player_data", mastery_player_data)
	var row := nodes.get("mastery_cards") as Control
	var card: Control = hud.get_combat_mastery_card(row, 3)
	if card == null:
		instance.free()
		tree.root.size = previous_size
		return "Expected mastery tooltip audit to resolve the hovered mastery card."
	hud._on_combat_mastery_card_mouse_entered(row, 3, card)

	var failures := _visible_text_failures(instance, _scene_label("res://scenes/ui/player_hud_mastery_tooltip", viewport_size))
	instance.free()
	tree.root.size = previous_size
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _audit_initialized_player_hud_slot_detail_popover_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var instance := _instantiate_scene("res://scenes/ui/player_hud.tscn")
	if instance == null:
		tree.root.size = previous_size
		return "Expected Player HUD scene to instantiate for slot detail popover audit."
	_prepare_root_control(instance, viewport_size)
	tree.root.add_child(instance)

	var hud: Variant = PLAYER_HUD_SCRIPT.new()
	var nodes: Dictionary = SHOP_PLAYER_HUD_PRESENTER.hud_nodes_from_section(instance)
	nodes["popover_parent"] = instance
	nodes["popover_z_index"] = 210
	hud.bind_player_hud(nodes)
	hud.update_player_hud_layout()
	hud.set_selected_equipment_slot(0)
	var slot_player_data := {
		"progression":
		{
			"equipment_slots": ["shortsword"],
			"consumable_slots": [],
			"relic_ids": [],
			"mastery_levels": {},
		},
	}
	hud.call("update_player_data", slot_player_data)
	var bubble := instance.get_node_or_null("SlotDetailBubble") as Control
	if bubble == null or not bubble.visible:
		instance.free()
		tree.root.size = previous_size
		return "Expected slot detail popover audit to show the selected equipment popover."

	var failures := _visible_text_failures(instance, _scene_label("res://scenes/ui/player_hud_slot_detail_popover", viewport_size))
	instance.free()
	tree.root.size = previous_size
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _audit_shop_treasure_chest_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "ShopTreasureChestOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)

	var presenter: Variant = SHOP_TREASURE_CHEST_OVERLAY_PRESENTER.new()
	presenter.bind(root, FakeTreasureChestVisuals.new(), Callable(self, "_lookup_treasure_chest_content_definition"))
	(
		presenter
		. render(
			[
				{"type": "equipment", "display_name": "Iron Shortsword", "content_id": "iron_shortsword"},
				{"type": "relic", "display_name": "Lucky Coin", "content_id": "lucky_coin"},
				{"type": "consumable", "display_name": "Potion", "content_id": "potion"},
			]
		)
	)
	presenter.apply_chrome()
	presenter.layout(viewport_size)

	var failures := _visible_text_failures(root, _scene_label("res://runtime/shop_treasure_chest_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _lookup_treasure_chest_content_definition(content_id: String) -> Dictionary:
	return {"icon_key": "icon/%s" % content_id}


func _audit_interactive_overlays_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	for audit_callable in [
		Callable(self, "_audit_main_menu_settings_overlay_for_viewport"),
		Callable(self, "_audit_combat_settings_overlay_for_viewport"),
		Callable(self, "_audit_shop_help_modal_for_viewport"),
		Callable(self, "_audit_shop_tutorial_overlay_for_viewport"),
		Callable(self, "_audit_combat_tutorial_prompt_for_viewport"),
		Callable(self, "_audit_combat_tutorial_end_overlay_for_viewport"),
	]:
		var result: String = audit_callable.call(tree, viewport_size)
		if result != "":
			return result
	return ""


func _audit_main_menu_settings_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "MainMenuSettingsOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)

	var overlay: Variant = MAIN_MENU_SETTINGS_OVERLAY.new()
	overlay.ensure(root)
	overlay.layout(viewport_size)
	overlay.show(_settings_payload())
	var result := _visible_text_result(root, _scene_label("res://runtime/main_menu_settings_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_combat_settings_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "CombatSettingsOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)

	var presenter: Variant = COMBAT_SETTINGS_OVERLAY_PRESENTER.new()
	presenter.bind(root, {}, {"design_size": viewport_size})
	presenter.show(_settings_payload())
	var result := _visible_text_result(root, _scene_label("res://runtime/combat_settings_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_shop_help_modal_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "ShopHelpModalAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)

	var presenter: Variant = SHOP_HELP_MODAL_PRESENTER.new()
	presenter.bind(root)
	presenter.show()
	presenter.apply_chrome()
	presenter.layout(viewport_size)
	var result := _visible_text_result(root, _scene_label("res://runtime/shop_help_modal", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_shop_tutorial_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "ShopTutorialOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)
	var offer_card := _audit_target_control(root, "OfferCard1", Rect2(Vector2(96.0, 220.0), Vector2(320.0, 450.0)))
	var reroll_button := _audit_target_button(root, "RerollButton", Rect2(Vector2(120.0, viewport_size.y - 520.0), Vector2(280.0, 100.0)), "REROLL")
	var continue_button := _audit_target_button(
		root, "ContinueButton", Rect2(Vector2(viewport_size.x - 400.0, viewport_size.y - 520.0), Vector2(280.0, 100.0)), "CONTINUE"
	)

	var presenter: Variant = SHOP_TUTORIAL_OVERLAY_PRESENTER.new()
	presenter.bind(root, {"offer_cards": [offer_card], "reroll_button": reroll_button, "continue_button": continue_button})
	presenter.render("buy_shortsword")
	presenter.layout(viewport_size)
	var result := _visible_text_result(root, _scene_label("res://runtime/shop_tutorial_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_combat_tutorial_prompt_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := _combat_prompt_host(viewport_size)
	tree.root.add_child(root)

	var presenter: Variant = COMBAT_TUTORIAL_PROMPT_PRESENTER.new()
	presenter.bind(root)
	presenter.show("Swap these two orbs.", TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD)
	var result := _visible_text_result(root, _scene_label("res://runtime/combat_tutorial_prompt", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_combat_tutorial_end_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "CombatTutorialEndOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)
	var equipment_icons := _audit_target_control(root, "EquipmentIcons", Rect2(Vector2(24.0, viewport_size.y - 430.0), Vector2(260.0, 90.0)))
	_audit_target_control(equipment_icons, "IronShortswordIcon", Rect2(Vector2(6.0, 6.0), Vector2(64.0, 64.0)))
	var mastery_panel := _audit_target_control(root, "ElementalMasteryPanel", Rect2(Vector2(100.0, viewport_size.y - 650.0), Vector2(300.0, 120.0)))

	var presenter: Variant = COMBAT_TUTORIAL_END_OVERLAY_PRESENTER.new()
	presenter.bind(root, {"equipment_icons": equipment_icons, "elemental_mastery_panel": mastery_panel})
	presenter.show("end", {"board_panel_rect": Rect2(Vector2(16.0, viewport_size.y * 0.34), Vector2(viewport_size.x - 32.0, viewport_size.y * 0.36))})
	var result := _visible_text_result(root, _scene_label("res://runtime/combat_tutorial_end_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _settings_payload() -> Dictionary:
	return {
		"vfx_speed": "normal",
		"combat_vfx_quality": "high",
		"reduced_motion": false,
		"game_juice": true,
		"game_juice_flags": GAME_JUICE_FLAGS_SCRIPT.default_flags(),
	}


func _visible_text_result(root: Node, scene_path: String) -> String:
	var failures := _visible_text_failures(root, scene_path)
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


func _audit_target_control(parent: Node, node_name: String, rect: Rect2) -> Control:
	var control := Control.new()
	control.name = node_name
	control.position = rect.position
	control.size = rect.size
	control.custom_minimum_size = rect.size
	parent.add_child(control)
	return control


func _audit_target_button(parent: Node, node_name: String, rect: Rect2, text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.custom_minimum_size = rect.size
	button.add_theme_font_size_override("font_size", 24)
	parent.add_child(button)
	return button


func _combat_prompt_host(viewport_size: Vector2) -> Control:
	var host := Control.new()
	host.name = "CombatPromptAuditHost"
	_prepare_root_control(host, viewport_size)
	var layout_root := _audit_target_control(host, "CombatLayoutRoot", Rect2(Vector2.ZERO, viewport_size))
	_audit_target_control(
		layout_root, "BoardPanel", Rect2(Vector2(viewport_size.x * 0.24, viewport_size.y * 0.34), Vector2(viewport_size.x * 0.52, viewport_size.x * 0.52))
	)
	var enemy_panel := _audit_target_control(layout_root, "EnemyPanel", Rect2(Vector2.ZERO, Vector2(viewport_size.x, viewport_size.y * 0.30)))
	var enemy_panel_root := _audit_target_control(enemy_panel, "EnemyPanelRoot", Rect2(Vector2.ZERO, enemy_panel.size))
	_audit_target_control(enemy_panel_root, "IntentRow", Rect2(Vector2(viewport_size.x * 0.20, viewport_size.y * 0.18), Vector2(viewport_size.x * 0.60, 72.0)))
	_audit_target_control(layout_root, "PlayerHudSection", Rect2(Vector2(0.0, viewport_size.y * 0.78), Vector2(viewport_size.x, viewport_size.y * 0.18)))
	return host


func _instantiate_scene(scene_path: String) -> Node:
	var packed_scene := ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed_scene == null:
		return null
	return packed_scene.instantiate()


func _prepare_root_control(node: Node, target_size: Vector2) -> void:
	var control := node as Control
	if control == null:
		return
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = Vector2.ZERO
	control.size = target_size
	control.custom_minimum_size = target_size


func _visible_text_failures(root: Node, scene_path: String) -> Array[String]:
	var failures: Array[String] = []
	_collect_visible_text_failures(root, scene_path, failures)
	return failures


func _collect_visible_text_failures(node: Node, scene_path: String, failures: Array[String]) -> void:
	var control := node as Control
	if control != null and _has_audited_visible_text(control):
		var text := _audited_text(control).strip_edges()
		var font_size := _audited_font_size(control)
		if font_size < MIN_VISIBLE_TEXT_FONT_SIZE:
			failures.append("%s %s text='%s' font_size=%d" % [scene_path, String(control.get_path()), text.left(32), font_size])
		var text_rect_size := control.get_global_rect().size
		var min_text_size := _minimum_visible_text_control_size(control, text, font_size)
		if text_rect_size.x < min_text_size.x or text_rect_size.y < min_text_size.y:
			failures.append(
				"%s %s text='%s' rect_size=%s min_size=%s" % [scene_path, String(control.get_path()), text.left(32), str(text_rect_size), str(min_text_size)]
			)
	for child in node.get_children():
		_collect_visible_text_failures(child, scene_path, failures)


func _has_audited_visible_text(control: Control) -> bool:
	if not control.is_visible_in_tree():
		return false
	if control.modulate.a <= 0.05:
		return false
	return _audited_text(control).strip_edges() != ""


func _audited_text(control: Control) -> String:
	if control is OptionButton:
		var option_button := control as OptionButton
		if option_button.item_count <= 0:
			return ""
		var selected := option_button.selected
		if selected < 0:
			selected = 0
		return option_button.get_item_text(selected)
	if control is SpinBox:
		return str((control as SpinBox).value)
	if control is LineEdit:
		var line_edit := control as LineEdit
		if line_edit.text.strip_edges() != "":
			return line_edit.text
		return line_edit.placeholder_text
	if control is Button:
		return (control as Button).text
	if control is RichTextLabel:
		return (control as RichTextLabel).text
	if control is Label:
		return (control as Label).text
	return ""


func _audited_font_size(control: Control) -> int:
	if control is RichTextLabel:
		var rich_text := control as RichTextLabel
		var normal_font_size := rich_text.get_theme_font_size("normal_font_size")
		if normal_font_size > 0:
			return normal_font_size
	return control.get_theme_font_size("font_size")


func _summarize_failures(failures: Array[String]) -> String:
	var summary := failures.duplicate()
	if summary.size() > 5:
		summary.resize(5)
		summary.append("...and %d more." % (failures.size() - 5))
	return "; ".join(summary)


func _scene_label(scene_path: String, viewport_size: Vector2) -> String:
	return "%s@%dx%d" % [scene_path, int(viewport_size.x), int(viewport_size.y)]


func _minimum_visible_text_control_size(control: Control, text: String, font_size: int) -> Vector2:
	var min_height := maxf(18.0, float(font_size) * 0.75)
	var min_width := maxf(24.0, float(font_size) * 1.6)
	if text.length() > 1:
		min_width = minf(180.0, maxf(48.0, float(font_size) * minf(8.0, float(text.length()) * 0.42)))
	if control is Label and (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF:
		min_width = maxf(min_width, float(font_size) * 5.0)
	return Vector2(min_width, min_height)
