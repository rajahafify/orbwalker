extends RefCounted
class_name UiTextLegibilityRuntimeTest

const PLAYER_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const MAIN_MENU_SETTINGS_OVERLAY := preload("res://scripts/main_menu/main_menu_settings_overlay.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")
const COMBAT_CHROME_THEME_HELPERS := preload("res://scripts/combat/combat_chrome_theme_helpers.gd")
const COMBAT_OUTCOME_OVERLAY := preload("res://scripts/combat/combat_outcome_overlay.gd")
const COMBAT_SETTINGS_OVERLAY_PRESENTER := preload("res://scripts/combat/combat_settings_overlay_presenter.gd")
const COMBAT_TUTORIAL_END_OVERLAY_PRESENTER := preload("res://scripts/combat/combat_tutorial_end_overlay_presenter.gd")
const COMBAT_TUTORIAL_PROMPT_PRESENTER := preload("res://scripts/combat/combat_tutorial_prompt_presenter.gd")
const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const SHOP_PLAYER_HUD_PRESENTER := preload("res://scripts/shop/shop_player_hud_presenter.gd")
const SHOP_HELP_MODAL_PRESENTER := preload("res://scripts/shop/shop_help_modal_presenter.gd")
const SHOP_TREASURE_CHEST_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_treasure_chest_overlay_presenter.gd")
const SHOP_TUTORIAL_OVERLAY_PRESENTER := preload("res://scripts/shop/shop_tutorial_overlay_presenter.gd")

const MIN_VISIBLE_TEXT_FONT_SIZE := 20
const COMBAT_DESIGN_SIZE := Vector2(1080.0, 1920.0)
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
		Callable(self, "_audit_combat_outcome_overlay_for_viewport"),
		Callable(self, "_audit_combat_debug_overlay_for_viewport"),
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


func _audit_combat_outcome_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var root := Control.new()
	root.name = "CombatOutcomeOverlayAuditRoot"
	_prepare_root_control(root, viewport_size)
	tree.root.add_child(root)

	var scale_factor := minf(viewport_size.x / COMBAT_DESIGN_SIZE.x, viewport_size.y / COMBAT_DESIGN_SIZE.y)
	var layout_root := Control.new()
	layout_root.name = "CombatOutcomeOverlayLayoutRoot"
	layout_root.position = (viewport_size - (COMBAT_DESIGN_SIZE * scale_factor)) * 0.5
	layout_root.size = COMBAT_DESIGN_SIZE
	layout_root.custom_minimum_size = COMBAT_DESIGN_SIZE
	layout_root.scale = Vector2(scale_factor, scale_factor)
	root.add_child(layout_root)

	var summary_panel := Panel.new()
	summary_panel.name = "OutcomeSummaryPanel"
	layout_root.add_child(summary_panel)
	var summary_root := Control.new()
	summary_root.name = "OutcomeSummaryRoot"
	summary_panel.add_child(summary_root)
	var text_column := Control.new()
	text_column.name = "OutcomeTextColumn"
	summary_root.add_child(text_column)
	var title_label := Label.new()
	title_label.name = "OutcomeTitleLabel"
	text_column.add_child(title_label)
	var body_label := Label.new()
	body_label.name = "OutcomeBodyLabel"
	text_column.add_child(body_label)
	var next_button := Button.new()
	next_button.name = "NextButton"
	next_button.text = "Continue"
	summary_root.add_child(next_button)

	COMBAT_CHROME_THEME_HELPERS.apply_board_focus_theme(null, summary_panel, title_label, body_label, next_button)
	var overlay: Variant = COMBAT_OUTCOME_OVERLAY.new()
	(
		overlay
		. bind(
			{
				"layout_root": layout_root,
				"summary_panel": summary_panel,
				"summary_root": summary_root,
				"text_column": text_column,
				"title_label": title_label,
				"body_label": body_label,
				"next_button": next_button,
			}
		)
	)
	overlay.ensure_boss_reward_controls(Callable(self, "_ignore_boss_reward_claim"), Callable(self, "_ignore_boss_reward_skip"))
	overlay.ensure_overlay_layer()
	overlay.show_summary("Victory", "Gold gained +25\nNext fight unlocked.", true)
	overlay.sync_layout(Rect2(Vector2(0.0, 320.0), Vector2(1080.0, 820.0)))
	var result := _visible_text_result(root, _scene_label("res://runtime/combat_outcome_summary", viewport_size))
	if result == "":
		overlay.show_boss_reward("The boss is defeated.")
		var reward_buttons: Array[Button] = overlay.boss_reward_buttons()
		for index in reward_buttons.size():
			overlay.set_boss_reward_card_content(
				reward_buttons[index],
				ImageTexture.new(),
				["Iron Crown", "Lucky Coin", "Storm Idol"][index],
				["Rare", "Uncommon", "Epic"][index],
				["Gain 3 Armor after every match.", "Start each shop with extra Gold.", "Fire orbs deal more damage."][index]
			)
		overlay.sync_layout(Rect2(Vector2.ZERO, COMBAT_DESIGN_SIZE))
		result = _visible_text_result(root, _scene_label("res://runtime/combat_boss_reward_overlay", viewport_size))
	root.free()
	tree.root.size = previous_size
	return result


func _audit_combat_debug_overlay_for_viewport(tree: SceneTree, viewport_size: Vector2) -> String:
	var saved_snapshot: Dictionary = RunState.snapshot_run_transition_state()
	RunState.start_new_run()
	var previous_size := tree.root.size
	tree.root.size = Vector2i(int(viewport_size.x), int(viewport_size.y))
	var instance := _instantiate_scene("res://scenes/combat.tscn")
	if instance == null:
		tree.root.size = previous_size
		RunState.restore_run_transition_state(saved_snapshot)
		return "Expected combat scene to instantiate for debug overlay audit."
	_prepare_root_control(instance, viewport_size)
	tree.root.add_child(instance)
	var debug_overlay := instance.get_node_or_null("%DebugOverlay") as Control
	if debug_overlay == null:
		instance.free()
		tree.root.size = previous_size
		RunState.restore_run_transition_state(saved_snapshot)
		return "Expected combat debug overlay audit to resolve DebugOverlay."
	debug_overlay.visible = true
	var combat_log := instance.get_node_or_null("%CombatLogText") as RichTextLabel
	if combat_log != null:
		combat_log.text = "Combat log\nSeed ready"
	var console_input := instance.get_node_or_null("%ConsoleInput") as LineEdit
	if console_input != null:
		console_input.placeholder_text = "Type /help"
	var failures := _visible_text_failures(debug_overlay, _scene_label("res://runtime/combat_debug_overlay", viewport_size))
	instance.free()
	tree.root.size = previous_size
	RunState.restore_run_transition_state(saved_snapshot)
	if not failures.is_empty():
		return _summarize_failures(failures)
	return ""


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


func _ignore_boss_reward_claim(_index: int) -> void:
	pass


func _ignore_boss_reward_skip() -> void:
	pass


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
		var effective_font_size := _effective_font_size(control, font_size)
		if font_size < MIN_VISIBLE_TEXT_FONT_SIZE:
			failures.append("%s %s text='%s' font_size=%d" % [scene_path, String(control.get_path()), text.left(32), font_size])
		if effective_font_size < float(MIN_VISIBLE_TEXT_FONT_SIZE):
			failures.append(
				(
					"%s %s text='%s' effective_font_size=%.2f base_font_size=%d"
					% [scene_path, String(control.get_path()), text.left(32), effective_font_size, font_size]
				)
			)
		var text_rect_size := control.get_global_rect().size
		var min_text_size := _minimum_visible_text_control_size(control, text, effective_font_size, _audited_font(control))
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


func _audited_font(control: Control) -> Font:
	if control is RichTextLabel:
		var rich_text := control as RichTextLabel
		var normal_font := rich_text.get_theme_font("normal_font")
		if normal_font != null:
			return normal_font
	return control.get_theme_font("font")


func _effective_font_size(control: Control, font_size: int) -> float:
	var transform := control.get_global_transform_with_canvas()
	var scale_x := transform.x.length()
	var scale_y := transform.y.length()
	var effective_scale := minf(scale_x, scale_y)
	return float(font_size) * effective_scale


func _summarize_failures(failures: Array[String]) -> String:
	var summary := failures.duplicate()
	if summary.size() > 5:
		summary.resize(5)
		summary.append("...and %d more." % (failures.size() - 5))
	return "; ".join(summary)


func _scene_label(scene_path: String, viewport_size: Vector2) -> String:
	return "%s@%dx%d" % [scene_path, int(viewport_size.x), int(viewport_size.y)]


func _minimum_visible_text_control_size(control: Control, text: String, font_size: float, font: Font) -> Vector2:
	var min_height := maxf(18.0, font_size * 0.75)
	var min_width := maxf(24.0, font_size * 1.6)
	if text.length() > 1:
		min_width = minf(180.0, maxf(48.0, font_size * minf(8.0, float(text.length()) * 0.42)))
	if control is Label and (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF:
		min_width = maxf(min_width, font_size * 5.0)
	var metric_size := _minimum_metric_text_size(control, text, font_size, font)
	min_width = maxf(min_width, metric_size.x)
	min_height = maxf(min_height, metric_size.y)
	return Vector2(min_width, min_height)


func _minimum_metric_text_size(control: Control, text: String, font_size: float, font: Font) -> Vector2:
	if font == null:
		return Vector2.ZERO
	var metric_font_size := maxi(1, int(ceil(font_size)))
	var line_height := font.get_height(metric_font_size)
	var min_height := maxf(18.0, line_height * 0.82)
	var min_width := 0.0
	if _control_wraps_text(control):
		min_width = _longest_measured_word_width(text, font, metric_font_size)
	else:
		min_width = _longest_measured_line_width(text, font, metric_font_size)
	if control is Button or control is OptionButton:
		min_width += font_size * 1.5
	if control is LineEdit or control is SpinBox:
		min_width += font_size * 0.8
	return Vector2(minf(320.0, maxf(0.0, min_width)), min_height)


func _control_wraps_text(control: Control) -> bool:
	if control is Label:
		return (control as Label).autowrap_mode != TextServer.AUTOWRAP_OFF
	if control is RichTextLabel:
		return (control as RichTextLabel).autowrap_mode != TextServer.AUTOWRAP_OFF
	if control is Button:
		return (control as Button).autowrap_mode != TextServer.AUTOWRAP_OFF
	return false


func _longest_measured_line_width(text: String, font: Font, font_size: int) -> float:
	var longest := 0.0
	for line in text.split("\n", false):
		var candidate := String(line).strip_edges()
		if candidate == "":
			continue
		longest = maxf(longest, font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x)
	return longest


func _longest_measured_word_width(text: String, font: Font, font_size: int) -> float:
	var longest := 0.0
	var normalized := text.replace("\n", " ").replace("\t", " ")
	for word in normalized.split(" ", false):
		var candidate := String(word).strip_edges()
		if candidate == "":
			continue
		longest = maxf(longest, font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x)
	return longest
