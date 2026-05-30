extends RefCounted
class_name CombatEnemyBlockPreviewPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_block_preview_presenter.gd")


class CallbackRecorder:
	extends RefCounted

	var hovered: Array[Dictionary] = []
	var ended_count := 0

	func block_hovered(preview: Dictionary) -> void:
		hovered.append(preview)

	func hover_ended() -> void:
		ended_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("empty_preview_hides_nodes", _test_empty_preview_hides_nodes, failures)
	_run_case("block_preview_sizes_against_hp_bar", _test_block_preview_sizes_against_hp_bar, failures)
	_run_case("hover_callbacks_emit_preview_and_end", _test_hover_callbacks_emit_preview_and_end, failures)
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


func _test_empty_preview_hides_nodes() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	presenter.sync({})
	if presenter.button() == null or presenter.fill() == null:
		root.free()
		return "Expected sync() to create preview nodes."
	if presenter.button().visible:
		root.free()
		return "Expected empty preview to hide button."
	if presenter.fill().visible:
		root.free()
		return "Expected empty preview to hide fill."
	root.free()
	return ""


func _test_block_preview_sizes_against_hp_bar() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var hp_bar: ProgressBar = fixture["hp_bar"]
	presenter.sync({"block": 25, "max_hp": 100})
	var button: Control = presenter.button()
	var fill: ColorRect = presenter.fill()
	if button == null or fill == null:
		root.free()
		return "Expected block preview nodes to exist."
	if not button.visible:
		root.free()
		return "Expected button to be visible for positive block."
	if not fill.visible:
		root.free()
		return "Expected fill to be visible for positive block."
	if button.position != hp_bar.position:
		root.free()
		return "Expected button position to match hp bar."
	var button_size := button.size
	var expected_size := Vector2(50.0, hp_bar.size.y)
	if not _vector_equal(button_size, expected_size):
		root.free()
		return "Expected button size to be 25%% of the hp bar width and match its height, got %s." % str(button_size)
	if not _vector_equal(fill.position, Vector2.ZERO):
		root.free()
		return "Expected fill position to be local origin."
	if not _vector_equal(fill.size, button.size):
		root.free()
		return "Expected fill size to match button."
	if button.mouse_filter != Control.MouseFilter.MOUSE_FILTER_STOP:
		root.free()
		return "Expected visible preview to stop mouse input."
	if not is_equal_approx(fill.modulate.a, 0.68):
		root.free()
		return "Expected fill modulate alpha to preserve existing pulse value."
	root.free()
	return ""


func _test_hover_callbacks_emit_preview_and_end() -> String:
	var fixture := _fixture()
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	presenter.sync({"block": 30, "max_hp": 100})
	presenter.button().emit_signal("mouse_entered")
	presenter.button().emit_signal("mouse_exited")
	if recorder.hovered.size() != 1:
		root.free()
		return "Expected hover callback to receive one preview."
	if int(recorder.hovered[0].get("block", 0)) != 30:
		root.free()
		return "Expected hover callback preview to include block value."
	if recorder.ended_count != 1:
		root.free()
		return "Expected hover-ended callback to be emitted once."
	root.free()
	return ""


func _fixture() -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var hp_row := Control.new()
	hp_row.name = "EnemyHpRow"
	root.add_child(hp_row)
	var hp_bar := ProgressBar.new()
	hp_bar.name = "EnemyHpBar"
	hp_bar.position = Vector2(10.0, 4.0)
	hp_bar.size = Vector2(200.0, 18.0)
	hp_bar.max_value = 100.0
	hp_row.add_child(hp_bar)
	var recorder := CallbackRecorder.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(
		hp_row,
		hp_bar,
		{
			PRESENTER_SCRIPT.CALLBACK_HOVERED: Callable(recorder, "block_hovered"),
			PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: Callable(recorder, "hover_ended"),
		}
	)
	return {
		"root": root,
		"hp_bar": hp_bar,
		"presenter": presenter,
		"recorder": recorder,
	}


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
