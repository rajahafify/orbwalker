extends RefCounted
class_name CombatEnemyIntentPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_intent_presenter.gd")


class CallbackRecorder:
	extends RefCounted

	var intent_hovered: Array[Dictionary] = []
	var block_hovered: Array[Dictionary] = []
	var ended_count := 0

	func on_intent_hovered(kind: String, entry: Dictionary) -> void:
		intent_hovered.append({"kind": kind, "entry": entry})

	func on_block_hovered(preview: Dictionary) -> void:
		block_hovered.append(preview)

	func on_hover_ended() -> void:
		ended_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("sync_creates_intent_bubbles_and_block_preview", _test_sync_creates_intent_bubbles_and_block_preview, failures)
	_run_case("hover_callbacks_forward_intent_and_block_events", _test_hover_callbacks_forward_intent_and_block_events, failures)
	_run_case("intent_focus_and_emphasis_delegate_to_bubbles", _test_intent_focus_and_emphasis_delegate_to_bubbles, failures)
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


func _test_sync_creates_intent_bubbles_and_block_preview() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var hp_bar: ProgressBar = fixture["hp_bar"]
	presenter.sync_intent_bubbles(_preview())
	presenter.sync_block_intent_preview(_preview())
	var buttons: Array[Button] = presenter.intent_buttons()
	var block_button: Control = presenter.block_preview_button()
	var block_fill: ColorRect = presenter.block_preview_fill()
	if buttons.size() != 2:
		root.free()
		return "Expected two intent buttons."
	if block_button == null or block_fill == null:
		root.free()
		return "Expected block preview nodes to be created."
	if not block_button.visible or not block_fill.visible:
		root.free()
		return "Expected block preview nodes to be visible for positive block."
	var expected_size := Vector2(hp_bar.size.x * 0.25, hp_bar.size.y)
	if not _vector_equal(block_button.size, expected_size):
		root.free()
		return "Expected block preview to size against enemy HP bar, got %s expected %s." % [str(block_button.size), str(expected_size)]
	root.free()
	return ""


func _test_hover_callbacks_forward_intent_and_block_events() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	presenter.sync_intent_bubbles(_preview())
	presenter.sync_block_intent_preview(_preview())
	var buttons: Array[Button] = presenter.intent_buttons()
	buttons[0].emit_signal("mouse_entered")
	buttons[0].emit_signal("mouse_exited")
	presenter.block_preview_button().emit_signal("mouse_entered")
	presenter.block_preview_button().emit_signal("mouse_exited")
	if recorder.intent_hovered.size() != 1 or String(recorder.intent_hovered[0].get("kind", "")) != "attack":
		root.free()
		return "Expected attack intent hover callback."
	if int(Dictionary(recorder.intent_hovered[0].get("entry", {})).get("amount", 0)) != 12:
		root.free()
		return "Expected intent hover callback entry payload."
	if recorder.block_hovered.size() != 1 or int(recorder.block_hovered[0].get("block", 0)) != 25:
		root.free()
		return "Expected block hover callback payload."
	if recorder.ended_count != 2:
		root.free()
		return "Expected both hover-ended callbacks."
	root.free()
	return ""


func _test_intent_focus_and_emphasis_delegate_to_bubbles() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.sync_intent_bubbles(_preview())
	var buttons: Array[Button] = presenter.intent_buttons()
	presenter.start_hover_emphasis("attack")
	if not _vector_equal(buttons[0].scale, Vector2(1.12, 1.12)):
		root.free()
		return "Expected attack bubble emphasis to scale matching button."
	presenter.stop_hover_emphasis()
	if not _vector_equal(buttons[0].scale, Vector2.ONE):
		root.free()
		return "Expected emphasis stop to reset scale."
	presenter.set_tutorial_focus("block")
	if not _vector_equal(buttons[1].scale, Vector2(1.18, 1.18)):
		root.free()
		return "Expected block tutorial focus to scale matching button."
	presenter.clear_tutorial_focus()
	if not _vector_equal(buttons[1].scale, Vector2.ONE):
		root.free()
		return "Expected tutorial focus clear to reset scale."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var intent_row := HBoxContainer.new()
	intent_row.name = "IntentRow"
	root.add_child(intent_row)
	var intent_label := Label.new()
	intent_label.name = "IntentLabel"
	intent_label.visible = true
	root.add_child(intent_label)
	var intent_badge := TextureRect.new()
	intent_badge.name = "IntentBadge"
	intent_badge.visible = true
	root.add_child(intent_badge)
	var primary_column := VBoxContainer.new()
	primary_column.name = "PrimaryIntentColumn"
	primary_column.visible = true
	root.add_child(primary_column)
	var hp_row := Control.new()
	hp_row.name = "EnemyHpRow"
	root.add_child(hp_row)
	var hp_bar := ProgressBar.new()
	hp_bar.name = "EnemyHpBar"
	hp_bar.position = Vector2(8.0, 4.0)
	hp_bar.size = Vector2(200.0, 20.0)
	hp_bar.max_value = 100.0
	hp_row.add_child(hp_bar)
	var root_nodes := {
		"_intent_row": intent_row,
		"_intent_label": intent_label,
		"_intent_badge": intent_badge,
		"_primary_intent_text_column": primary_column,
		"_enemy_hp_row": hp_row,
		"_enemy_hp_bar": hp_bar,
	}
	var recorder := CallbackRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(
		root_nodes,
		{
			PRESENTER_SCRIPT.CALLBACK_INTENT_HOVERED: Callable(recorder, "on_intent_hovered"),
			PRESENTER_SCRIPT.CALLBACK_BLOCK_HOVERED: Callable(recorder, "on_block_hovered"),
			PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: Callable(recorder, "on_hover_ended"),
		}
	)
	return {
		"root": root,
		"hp_bar": hp_bar,
		"presenter": presenter,
		"recorder": recorder,
	}


func _preview() -> Dictionary:
	return {
		"block": 25,
		"max_hp": 100,
		"entries": [
			{"kind": "attack", "amount": 12},
			{"kind": "block", "amount": 25, "label": "Guard 25"},
		],
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
