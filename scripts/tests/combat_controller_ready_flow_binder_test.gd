extends RefCounted
class_name CombatControllerReadyFlowBinderTest

const BINDER_SCRIPT := preload("res://scripts/combat/combat_controller_ready_flow_binder.gd")


class FakeResolvePresenter:
	extends RefCounted

	var bind_args: Array = []
	var combat_speed := ""

	func bind(bindings: Dictionary) -> void:
		bind_args.append(bindings)

	func set_combat_speed(value: String) -> void:
		combat_speed = value


class FakeResolvePresenterScript:
	extends RefCounted

	func new() -> FakeResolvePresenter:
		return FakeResolvePresenter.new()


class FakeView:
	extends RefCounted

	var resolve_binding_calls: Array = []
	var bootstrap_calls := 0
	var dependencies := {}
	var rendering_calls := 0
	var hud_bind_calls := 0
	var layout_bind_calls := 0
	var vfx_visible_values: Array = []

	func resolve_presenter_bindings(board_controller: Variant, host: Variant, spawn_callback: Callable, combo_callback: Callable) -> Dictionary:
		resolve_binding_calls.append([board_controller, host, spawn_callback, combo_callback])
		return {"from_view": true, "board_controller": board_controller, "timer_owner": host}

	func bootstrap_background() -> void:
		bootstrap_calls += 1

	func set_dependencies(value: Dictionary) -> void:
		dependencies = value

	func setup_rendering_helpers() -> void:
		rendering_calls += 1

	func bind_player_hud() -> void:
		hud_bind_calls += 1

	func bind_layout_presenter() -> void:
		layout_bind_calls += 1

	func set_vfx_layer_visible(value: bool) -> void:
		vfx_visible_values.append(value)


class FakeViewActions:
	extends RefCounted

	var boss_controls := 0
	var outcome_layers := 0

	func ensure_boss_reward_controls() -> void:
		boss_controls += 1

	func ensure_outcome_overlay_layer() -> void:
		outcome_layers += 1


class FakeDebugRuntime:
	extends RefCounted

	var hidden_callbacks: Array = []

	func bootstrap_hidden(callback: Callable) -> void:
		hidden_callbacks.append(callback)


class FakeHost:
	extends RefCounted

	signal size_changed

	var process_values: Array = []

	func get_viewport() -> Variant:
		return self

	func set_process(value: bool) -> void:
		process_values.append(value)


class Recorder:
	extends RefCounted

	var layout_calls := 0
	var first_frame_calls := 0
	var texture_map_calls := 0

	func apply_layout() -> void:
		layout_calls += 1

	func first_frame() -> void:
		first_frame_calls += 1

	func texture_map() -> void:
		texture_map_calls += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("bind_resolve_presenter_prefers_view_bindings", _test_bind_resolve_presenter_prefers_view_bindings, failures)
	_run_case("bootstrap_view_wires_dependencies_and_helpers", _test_bootstrap_view_wires_dependencies_and_helpers, failures)
	_run_case("activate_scene_bootstraps_debug_view_and_deferred_callbacks", _test_activate_scene_bootstraps_debug_view_and_deferred_callbacks, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_bind_resolve_presenter_prefers_view_bindings() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var view := FakeView.new()
	var presenter: FakeResolvePresenter = (
		binder
		. bind_resolve_presenter(
			{
				"resolve_presenter": null,
				"resolve_presenter_script": FakeResolvePresenterScript.new(),
				"board": "board",
				"board_view": "board_view",
				"board_controller": "board_controller",
				"host": "host",
				"view": view,
			},
			{"spawn_vfx_texture": Callable(), "combo_sound": Callable()},
			{"combat_speed": "fast"}
		)
	)
	if presenter == null:
		return "Expected resolve presenter to be created."
	if view.resolve_binding_calls.size() != 1:
		return "Expected view resolve binding hook to be used."
	if presenter.bind_args.size() != 1 or not bool(presenter.bind_args[0].get("from_view", false)):
		return "Expected presenter to bind with view-provided bindings."
	if presenter.combat_speed != "fast":
		return "Expected combat speed config to be forwarded."
	return ""


func _test_bootstrap_view_wires_dependencies_and_helpers() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var view := FakeView.new()
	var view_actions := FakeViewActions.new()
	(
		binder
		. bootstrap_view(
			{
				"view": view,
				"visuals": "visuals",
				"player_loadout_hud": "hud",
				"debug_console": "console",
				"outcome_overlay": "outcome",
			},
			view_actions
		)
	)
	if view.bootstrap_calls != 1 or view_actions.boss_controls != 1 or view_actions.outcome_layers != 1:
		return "Expected view background and overlay controls to be bootstrapped."
	if view.dependencies.get("visual_registry") != "visuals" or view.dependencies.get("debug_console") != "console":
		return "Expected view dependencies to be forwarded."
	if view.rendering_calls != 1 or view.hud_bind_calls != 1 or view.layout_bind_calls != 1:
		return "Expected rendering, HUD, and layout bind hooks."
	return ""


func _test_activate_scene_bootstraps_debug_view_and_deferred_callbacks() -> String:
	var binder: Variant = BINDER_SCRIPT.new()
	var debug_runtime := FakeDebugRuntime.new()
	var host := FakeHost.new()
	var view := FakeView.new()
	var recorder := Recorder.new()
	(
		binder
		. activate_scene(
			{"debug_runtime": debug_runtime, "host": host, "view": view},
			{
				"console_input_submitted": Callable(),
				"viewport_size_changed": Callable(recorder, "apply_layout"),
				"apply_combat_layout": Callable(recorder, "apply_layout"),
				"trace_first_usable_frame": Callable(recorder, "first_frame"),
				"apply_orb_texture_map_deferred": Callable(recorder, "texture_map"),
			}
		)
	)
	if debug_runtime.hidden_callbacks.size() != 1:
		return "Expected debug runtime to bootstrap hidden console."
	if host.process_values != [true] or view.vfx_visible_values != [true]:
		return "Expected process and VFX layer activation."
	if recorder.layout_calls != 1:
		return "Expected layout callback to run synchronously."
	return ""
