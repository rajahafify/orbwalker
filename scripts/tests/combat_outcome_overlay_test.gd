extends RefCounted
class_name CombatOutcomeOverlayTest

const OVERLAY_SCRIPT := preload("res://scripts/combat/combat_outcome_overlay.gd")


class CallbackSink:
	extends RefCounted

	var claimed_indices: Array[int] = []
	var skip_count := 0

	func claim(index: int) -> void:
		claimed_indices.append(index)

	func skip() -> void:
		skip_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("default_config_exposes_outcome_design_values", _test_default_config_exposes_outcome_design_values, failures)
	_run_case("bind_without_config_uses_standard_summary_rect", _test_bind_without_config_uses_standard_summary_rect, failures)
	_run_case("boss_reward_layout_uses_overlay_defaults", _test_boss_reward_layout_uses_overlay_defaults, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_default_config_exposes_outcome_design_values() -> String:
	var config: Dictionary = OVERLAY_SCRIPT.default_config()
	if config.get("outcome_summary_rect") != OVERLAY_SCRIPT.OUTCOME_SUMMARY_RECT:
		return "Expected standard summary rect to live on CombatOutcomeOverlay."
	if config.get("boss_reward_summary_rect") != OVERLAY_SCRIPT.BOSS_REWARD_SUMMARY_RECT:
		return "Expected boss reward summary rect to live on CombatOutcomeOverlay."
	if int(config.get("outcome_modal_z_index", 0)) != OVERLAY_SCRIPT.OUTCOME_MODAL_Z_INDEX:
		return "Expected outcome modal z-index to live on CombatOutcomeOverlay."
	if int(config.get("outcome_scrim_z_index", 0)) != OVERLAY_SCRIPT.OUTCOME_SCRIM_Z_INDEX:
		return "Expected outcome scrim z-index to live on CombatOutcomeOverlay."
	return ""


func _test_bind_without_config_uses_standard_summary_rect() -> String:
	var fixture := _fixture()
	var overlay: Variant = fixture["overlay"]
	var summary_panel: Panel = fixture["summary_panel"]
	overlay.show_summary("Victory", "Body", true)
	overlay.sync_layout(Rect2(Vector2(10.0, 20.0), Vector2(500.0, 500.0)))
	var expected_rect: Rect2 = OVERLAY_SCRIPT.OUTCOME_SUMMARY_RECT
	var expected_position := Vector2(10.0, 20.0) + expected_rect.position
	if summary_panel.position != expected_position:
		fixture["layout_root"].free()
		return "Expected standard summary position %s, got %s." % [expected_position, summary_panel.position]
	if summary_panel.size != expected_rect.size:
		fixture["layout_root"].free()
		return "Expected standard summary size %s, got %s." % [expected_rect.size, summary_panel.size]
	fixture["layout_root"].free()
	return ""


func _test_boss_reward_layout_uses_overlay_defaults() -> String:
	var fixture := _fixture()
	var overlay: Variant = fixture["overlay"]
	var layout_root: Control = fixture["layout_root"]
	var summary_panel: Panel = fixture["summary_panel"]
	var next_button: Button = fixture["next_button"]
	var sink := CallbackSink.new()
	overlay.ensure_boss_reward_controls(Callable(sink, "claim"), Callable(sink, "skip"))
	overlay.ensure_overlay_layer()
	overlay.show_boss_reward("Boss defeated.")
	overlay.sync_layout(Rect2(Vector2(99.0, 99.0), Vector2(500.0, 500.0)))
	if summary_panel.position != OVERLAY_SCRIPT.BOSS_REWARD_SUMMARY_RECT.position:
		layout_root.free()
		return "Expected boss reward summary to use absolute overlay default position."
	if summary_panel.size != OVERLAY_SCRIPT.BOSS_REWARD_SUMMARY_RECT.size:
		layout_root.free()
		return "Expected boss reward summary to use overlay default size."
	if summary_panel.z_index != OVERLAY_SCRIPT.OUTCOME_MODAL_Z_INDEX:
		layout_root.free()
		return "Expected outcome panel z-index to come from overlay defaults."
	if next_button.size != OVERLAY_SCRIPT.BOSS_REWARD_NEXT_BUTTON_SIZE:
		layout_root.free()
		return "Expected boss reward next button size to come from overlay defaults."
	var buttons: Array[Button] = overlay.boss_reward_buttons()
	if buttons.size() != 3:
		layout_root.free()
		return "Expected three boss reward buttons."
	if buttons[0].size.y != OVERLAY_SCRIPT.BOSS_REWARD_CARD_HEIGHT:
		layout_root.free()
		return "Expected boss reward card height to come from overlay defaults."
	layout_root.free()
	return ""


func _fixture() -> Dictionary:
	var layout_root := Control.new()
	layout_root.name = "LayoutRoot"
	layout_root.size = Vector2(1080.0, 1920.0)

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
	summary_root.add_child(next_button)

	var overlay: Variant = OVERLAY_SCRIPT.new()
	overlay.bind({
		"layout_root": layout_root,
		"summary_panel": summary_panel,
		"summary_root": summary_root,
		"text_column": text_column,
		"title_label": title_label,
		"body_label": body_label,
		"next_button": next_button,
	})
	return {
		"overlay": overlay,
		"layout_root": layout_root,
		"summary_panel": summary_panel,
		"next_button": next_button,
	}
