extends RefCounted
class_name CombatEnemyIntentBubblePresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_intent_bubble_presenter.gd")


class CallbackRecorder:
	extends RefCounted

	var hovered: Array[Dictionary] = []
	var ended_count := 0

	func intent_hovered(kind: String, entry: Dictionary) -> void:
		hovered.append({"kind": kind, "entry": entry})

	func hover_ended() -> void:
		ended_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("sync_creates_intent_buttons_and_hides_legacy_nodes", _test_sync_creates_intent_buttons_and_hides_legacy_nodes, failures)
	_run_case("hover_callbacks_emit_entry_and_end", _test_hover_callbacks_emit_entry_and_end, failures)
	_run_case("hover_emphasis_tints_matching_buttons", _test_hover_emphasis_tints_matching_buttons, failures)
	_run_case("tutorial_focus_marks_and_clears_block_button", _test_tutorial_focus_marks_and_clears_block_button, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_sync_creates_intent_buttons_and_hides_legacy_nodes() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.sync(_preview())
	var buttons: Array[Button] = presenter.buttons()
	if buttons.size() != 2:
		root.free()
		return "Expected two intent buttons."
	if not fixture["intent_row"].visible:
		root.free()
		return "Expected intent row to be visible when entries exist."
	if fixture["intent_label"].visible or fixture["intent_badge"].visible or fixture["primary_column"].visible:
		root.free()
		return "Expected legacy primary intent nodes to be hidden."
	if buttons[0].name != "EnemyIntentAttack0" or buttons[0].text != "Attack 12":
		root.free()
		return "Expected attack button naming and fallback label."
	if buttons[1].name != "EnemyIntentBlock1" or buttons[1].text != "Guard 8":
		root.free()
		return "Expected block button naming and explicit label."
	root.free()
	return ""


func _test_hover_callbacks_emit_entry_and_end() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	presenter.sync(_preview())
	var buttons: Array[Button] = presenter.buttons()
	buttons[1].emit_signal("mouse_entered")
	buttons[1].emit_signal("mouse_exited")
	if recorder.hovered.size() != 1:
		root.free()
		return "Expected one hover callback."
	if String(recorder.hovered[0].get("kind", "")) != "block":
		root.free()
		return "Expected hover callback to include block kind."
	var entry: Dictionary = recorder.hovered[0].get("entry", {})
	if int(entry.get("amount", 0)) != 8:
		root.free()
		return "Expected hover callback to include duplicated entry."
	if recorder.ended_count != 1:
		root.free()
		return "Expected hover-ended callback."
	root.free()
	return ""


func _test_hover_emphasis_tints_matching_buttons() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.sync(_preview())
	presenter.start_hover_emphasis("attack")
	var buttons: Array[Button] = presenter.buttons()
	if not _vector_equal(buttons[0].scale, Vector2(1.12, 1.12)):
		root.free()
		return "Expected attack button to scale during emphasis."
	if not _vector_equal(buttons[1].scale, Vector2.ONE):
		root.free()
		return "Expected block button to remain unscaled during attack emphasis."
	presenter.stop_hover_emphasis()
	if not _vector_equal(buttons[0].scale, Vector2.ONE):
		root.free()
		return "Expected stop to reset emphasis scale."
	root.free()
	return ""


func _test_tutorial_focus_marks_and_clears_block_button() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.sync(_preview())
	presenter.set_tutorial_focus("block")
	var buttons: Array[Button] = presenter.buttons()
	if not _vector_equal(buttons[1].scale, Vector2(1.18, 1.18)):
		root.free()
		return "Expected focused block button to scale up."
	if not _color_equal(buttons[1].modulate, Color(0.90, 0.96, 1.0, 1.0)):
		root.free()
		return "Expected focused block button tint."
	presenter.clear_tutorial_focus()
	if not _vector_equal(buttons[1].scale, Vector2.ONE):
		root.free()
		return "Expected clear to reset focused button scale."
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
	var recorder := CallbackRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(
		{
			"intent_row": intent_row,
			"intent_label": intent_label,
			"intent_badge": intent_badge,
			"primary_intent_text_column": primary_column,
		},
		{
			PRESENTER_SCRIPT.CALLBACK_HOVERED: Callable(recorder, "intent_hovered"),
			PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: Callable(recorder, "hover_ended"),
		}
	)
	return {
		"root": root,
		"intent_row": intent_row,
		"intent_label": intent_label,
		"intent_badge": intent_badge,
		"primary_column": primary_column,
		"presenter": presenter,
		"recorder": recorder,
	}


func _preview() -> Dictionary:
	return {
		"entries": [
			{"kind": "attack", "amount": 12},
			{"kind": "block", "amount": 8, "label": "Guard 8"},
		],
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)


func _color_equal(left: Color, right: Color) -> bool:
	return (
		is_equal_approx(left.r, right.r)
		and is_equal_approx(left.g, right.g)
		and is_equal_approx(left.b, right.b)
		and is_equal_approx(left.a, right.a)
	)
