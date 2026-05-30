extends RefCounted
class_name CombatHudSnapshotPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_hud_snapshot_presenter.gd")


class CallbackStub:
	extends RefCounted

	var progression_payloads: Array[Dictionary] = []

	func refresh_build_icon_rows(progression_snapshot: Dictionary) -> void:
		progression_payloads.append(progression_snapshot.duplicate(true))


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("top_hud_formats_gold_text", _test_top_hud_formats_gold_text, failures)
	_run_case("primary_intent_badge_hides_legacy_nodes", _test_primary_intent_badge_hides_legacy_nodes, failures)
	_run_case("tempo_and_player_strip_apply_labels_bars_and_callback", _test_tempo_and_player_strip_apply_labels_bars_and_callback, failures)
	_run_case("debug_overlay_updates_labels_and_missing_nodes_are_safe", _test_debug_overlay_updates_labels_and_missing_nodes_are_safe, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_top_hud_formats_gold_text() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	presenter.apply_top_hud({
		"level_text": "Dungeon 2-3",
		"enemy_step_text": "BOSS",
		"gold_text": "GOLD 42",
	})
	if root_nodes.get("_title_label").text != "Dungeon 2-3":
		root.free()
		return "Expected level text to update."
	if root_nodes.get("_enemy_step_label").text != "BOSS":
		root.free()
		return "Expected enemy step text to update."
	if root_nodes.get("_hint_label").text != "$42":
		root.free()
		return "Expected GOLD text to format as currency."
	presenter.apply_top_hud({"gold_text": "$ 9"})
	if root_nodes.get("_hint_label").text != "$9":
		root.free()
		return "Expected dollar-prefixed text to normalize spacing."
	root.free()
	return ""


func _test_primary_intent_badge_hides_legacy_nodes() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	for key in [
		"_intent_badge",
		"_primary_intent_text_column",
		"_primary_intent_title_label",
		"_primary_intent_amount_label",
		"_primary_intent_detail_label",
	]:
		root_nodes.get(key).visible = true
	presenter.apply_primary_intent_badge({"kind": "attack"})
	for key in [
		"_intent_badge",
		"_primary_intent_text_column",
		"_primary_intent_title_label",
		"_primary_intent_amount_label",
		"_primary_intent_detail_label",
	]:
		if root_nodes.get(key).visible:
			root.free()
			return "Expected %s to be hidden." % key
	root.free()
	return ""


func _test_tempo_and_player_strip_apply_labels_bars_and_callback() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	var callback_stub := CallbackStub.new()
	presenter.apply_tempo_row({
		"phase_text": "Turn 2 Player Input",
		"timer_seconds": 2.5,
		"timer_state": "active",
	})
	if root_nodes.get("_phase_label").text != "Turn 2 Player Input":
		root.free()
		return "Expected tempo phase text."
	if root_nodes.get("_timer_label").text != "3 SEC":
		root.free()
		return "Expected active timer label."
	if root_nodes.get("_timer_state_label").text != "MOVE":
		root.free()
		return "Expected active timer state."
	presenter.apply_player_strip(
		{
			"player_text": "HP 18 / 30",
			"player_hp_max": 30,
			"player_hp_value": 18,
			"player_armor_max": 12,
			"player_armor_value": 7,
			"player_armor_text": "7 / 12",
			"armor_badge_text": "BLOCK +7",
			"attack_stat_text": "ATK 4",
			"armor_stat_text": "ARM 3",
			"heart_stat_text": "HEART 10%",
			"gold_stat_text": "GOLD 5%",
			"run_progress_text": "Depth 2",
			"phase_text": "Player Strip Phase",
			"turn_summary_text": "Matched fire.",
			"progression_snapshot": {"equipment_slots": ["shortsword"]},
		},
		{"refresh_build_icon_rows": Callable(callback_stub, "refresh_build_icon_rows")}
	)
	var hp_bar := root_nodes.get("_player_hp_bar") as ProgressBar
	var armor_bar := root_nodes.get("_player_armor_bar") as ProgressBar
	if hp_bar.max_value != 30.0 or hp_bar.value != 18.0:
		root.free()
		return "Expected player HP bar values."
	if armor_bar.max_value != 12.0 or armor_bar.value != 7.0:
		root.free()
		return "Expected player armor bar values."
	if root_nodes.get("_player_label").text != "HP 18 / 30" or root_nodes.get("_player_armor_label").text != "7 / 12":
		root.free()
		return "Expected player strip labels."
	if root_nodes.get("_armor_badge").visible:
		root.free()
		return "Expected armor badge to remain hidden."
	if root_nodes.get("_phase_label").text != "Player Strip Phase" or root_nodes.get("_turn_summary_label").text != "Matched fire.":
		root.free()
		return "Expected player strip phase and turn summary to apply after tempo row."
	if callback_stub.progression_payloads.size() != 1 or callback_stub.progression_payloads[0].get("equipment_slots") != ["shortsword"]:
		root.free()
		return "Expected refresh callback to receive progression snapshot."
	root.free()
	return ""


func _test_debug_overlay_updates_labels_and_missing_nodes_are_safe() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	presenter.apply_debug_overlay({
		"status_text": "Dungeon 1-1 | Turn 2.",
		"enemy_text": "Slime HP 3 / 8 Block 2",
	})
	if root_nodes.get("_status_label").text != "Dungeon 1-1 | Turn 2.":
		root.free()
		return "Expected status debug text."
	if root_nodes.get("_enemy_debug_label").text != "Slime HP 3 / 8 Block 2":
		root.free()
		return "Expected enemy debug text."
	var missing_presenter: Variant = PRESENTER_SCRIPT.new()
	missing_presenter.bind({})
	missing_presenter.apply_top_hud({})
	missing_presenter.apply_player_strip({})
	missing_presenter.apply_debug_overlay({})
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var root_nodes := {}
	root_nodes["_title_label"] = _add_label(root, "TitleLabel")
	root_nodes["_enemy_step_label"] = _add_label(root, "EnemyStepLabel")
	root_nodes["_hint_label"] = _add_label(root, "HintLabel")
	root_nodes["_intent_badge"] = _add_texture_rect(root, "IntentBadge")
	root_nodes["_primary_intent_text_column"] = _add_control(root, "PrimaryIntentTextColumn")
	root_nodes["_primary_intent_title_label"] = _add_label(root, "PrimaryIntentTitleLabel")
	root_nodes["_primary_intent_amount_label"] = _add_label(root, "PrimaryIntentAmountLabel")
	root_nodes["_primary_intent_detail_label"] = _add_label(root, "PrimaryIntentDetailLabel")
	root_nodes["_phase_label"] = _add_label(root, "PhaseLabel")
	var timer_track := _add_control(root, "TimerTrack")
	timer_track.size = Vector2(100.0, 20.0)
	root_nodes["_timer_track"] = timer_track
	root_nodes["_timer_fill"] = _add_color_rect(root, "TimerFill")
	root_nodes["_timer_label"] = _add_label(root, "TimerLabel")
	root_nodes["_timer_state_label"] = _add_label(root, "TimerStateLabel")
	root_nodes["_timer_icon"] = _add_texture_rect(root, "TimerIcon")
	root_nodes["_player_label"] = _add_label(root, "PlayerLabel")
	root_nodes["_player_hp_bar"] = _add_progress_bar(root, "PlayerHpBar")
	root_nodes["_player_armor_bar"] = _add_progress_bar(root, "PlayerArmorBar")
	root_nodes["_player_armor_label"] = _add_label(root, "PlayerArmorLabel")
	root_nodes["_armor_badge"] = _add_control(root, "ArmorBadge")
	root_nodes["_armor_badge_label"] = _add_label(root, "ArmorBadgeLabel")
	root_nodes["_attack_stat_label"] = _add_label(root, "AttackStatLabel")
	root_nodes["_armor_stat_label"] = _add_label(root, "ArmorStatLabel")
	root_nodes["_heart_stat_label"] = _add_label(root, "HeartStatLabel")
	root_nodes["_gold_stat_label"] = _add_label(root, "GoldStatLabel")
	root_nodes["_run_progress_label"] = _add_label(root, "RunProgressLabel")
	root_nodes["_turn_summary_label"] = _add_label(root, "TurnSummaryLabel")
	root_nodes["_status_label"] = _add_label(root, "StatusLabel")
	root_nodes["_enemy_debug_label"] = _add_label(root, "EnemyDebugLabel")
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root_nodes)
	return {
		"root": root,
		"root_nodes": root_nodes,
		"presenter": presenter,
	}


func _add_label(root: Control, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	root.add_child(label)
	return label


func _add_control(root: Control, node_name: String) -> Control:
	var control := Control.new()
	control.name = node_name
	root.add_child(control)
	return control


func _add_texture_rect(root: Control, node_name: String) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	root.add_child(texture_rect)
	return texture_rect


func _add_color_rect(root: Control, node_name: String) -> ColorRect:
	var color_rect := ColorRect.new()
	color_rect.name = node_name
	root.add_child(color_rect)
	return color_rect


func _add_progress_bar(root: Control, node_name: String) -> ProgressBar:
	var progress_bar := ProgressBar.new()
	progress_bar.name = node_name
	root.add_child(progress_bar)
	return progress_bar
