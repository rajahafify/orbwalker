extends RefCounted
class_name CombatControllerReadyFlowBinder


func bind_resolve_presenter(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary) -> Variant:
	var resolve_presenter: Variant = dependencies.get("resolve_presenter")
	if resolve_presenter == null:
		var presenter_script: Variant = dependencies.get("resolve_presenter_script")
		resolve_presenter = presenter_script.new() if presenter_script != null else null
	if resolve_presenter == null:
		return null
	var spawn_vfx_texture_callback: Callable = callbacks.get("spawn_vfx_texture", Callable())
	var combo_sound_callback: Callable = callbacks.get("combo_sound", Callable())
	var bindings := {
		"board": dependencies.get("board"),
		"board_view": dependencies.get("board_view"),
		"board_panel": null,
		"board_controller": dependencies.get("board_controller"),
		"timer_owner": dependencies.get("host"),
		"spawn_vfx_texture_callback": spawn_vfx_texture_callback,
		"combo_sound_callback": combo_sound_callback,
	}
	var view: Variant = dependencies.get("view")
	if view != null and view.has_method("resolve_presenter_bindings"):
		bindings = view.resolve_presenter_bindings(
			dependencies.get("board_controller"), dependencies.get("host"), spawn_vfx_texture_callback, combo_sound_callback
		)
	resolve_presenter.bind(bindings)
	if resolve_presenter.has_method("set_combat_speed"):
		resolve_presenter.set_combat_speed(String(config.get("combat_speed", "")))
	return resolve_presenter


func bootstrap_view(dependencies: Dictionary, view_actions: Variant) -> void:
	var view: Variant = dependencies.get("view")
	if view != null and view.has_method("bootstrap_background"):
		view.bootstrap_background()
	_call_view_action(view_actions, "ensure_boss_reward_controls")
	_call_view_action(view_actions, "ensure_outcome_overlay_layer")
	if view == null:
		return
	if view.has_method("set_dependencies"):
		(
			view
			. set_dependencies(
				{
					"visual_registry": dependencies.get("visuals"),
					"player_loadout_hud": dependencies.get("player_loadout_hud"),
					"debug_console": dependencies.get("debug_console"),
					"outcome_overlay": dependencies.get("outcome_overlay"),
				}
			)
		)
	if view.has_method("setup_rendering_helpers"):
		view.setup_rendering_helpers()
	if view.has_method("bind_player_hud"):
		view.bind_player_hud()
	if view.has_method("bind_layout_presenter"):
		view.bind_layout_presenter()


func activate_scene(dependencies: Dictionary, callbacks: Dictionary) -> void:
	var debug_runtime: Variant = dependencies.get("debug_runtime")
	if debug_runtime != null and debug_runtime.has_method("bootstrap_hidden"):
		debug_runtime.bootstrap_hidden(callbacks.get("console_input_submitted", Callable()))
	var host: Variant = dependencies.get("host")
	if host != null:
		var viewport: Variant = host.get_viewport() if host.has_method("get_viewport") else null
		if viewport != null and viewport.has_signal("size_changed"):
			var viewport_size_changed: Callable = callbacks.get("viewport_size_changed", Callable())
			if viewport_size_changed.is_valid() and not viewport.size_changed.is_connected(viewport_size_changed):
				viewport.size_changed.connect(viewport_size_changed)
		if host.has_method("set_process"):
			host.set_process(true)
	var view: Variant = dependencies.get("view")
	if view != null and view.has_method("set_vfx_layer_visible"):
		view.set_vfx_layer_visible(true)
	_call(callbacks.get("apply_combat_layout"))
	_call(callbacks.get("trace_first_usable_frame"), true)
	_call(callbacks.get("apply_orb_texture_map_deferred"), true)


func _call(callback: Variant, deferred := false) -> void:
	if not (callback is Callable):
		return
	if not callback.is_valid():
		return
	if deferred:
		callback.call_deferred()
		return
	callback.call()


func _call_view_action(view_actions: Variant, method_name: String) -> void:
	if view_actions == null or not view_actions.has_method(method_name):
		return
	Callable(view_actions, method_name).call()
