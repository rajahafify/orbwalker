extends RefCounted
class_name CombatControllerRuntimeBinder


static func bind_audio_cue_player(current: Variant, script: Variant, host: Variant, run_state: Variant) -> Variant:
	var audio_cue_player: Variant = current if current != null else script.new()
	audio_cue_player.bind(host)
	if audio_cue_player.has_method("set_game_juice_enabled"):
		audio_cue_player.set_game_juice_enabled(run_state.game_juice_enabled())
	if audio_cue_player.has_method("set_game_juice_flags"):
		audio_cue_player.set_game_juice_flags(run_state.game_juice_flags())
	return audio_cue_player


static func bind_debug_state_provider(current: Variant, script: Variant, dependencies: Dictionary) -> Variant:
	var provider: Variant = current if current != null else script.new()
	provider.bind(dependencies)
	return provider


static func bind_outcome_overlay(view: Variant, outcome_overlay: Variant) -> void:
	if outcome_overlay == null or view == null:
		return
	view.bind_outcome_overlay(outcome_overlay)


static func bind_boss_reward_handler(
	current: Variant, script: Variant, outcome_overlay: Variant, view: Variant, model: Variant, visuals: Variant, callbacks: Dictionary
) -> Variant:
	var handler: Variant = current if current != null else script.new()
	handler.bind(outcome_overlay, view, model, visuals, callbacks)
	return handler


static func bind_vfx_target_resolver(current: Variant, script: Variant, view: Variant, vfx_presenter: Variant) -> Variant:
	var resolver: Variant = current if current != null else script.new()
	resolver.bind({"view": view, "vfx_presenter": vfx_presenter})
	return resolver


static func bind_hud_stage_coordinator(
	current: Variant, script: Variant, model: Variant, player_state: Variant, enemy_state: Variant, update_hud_callback: Callable
) -> Variant:
	var coordinator: Variant = current if current != null else script.new()
	coordinator.bind(model, player_state, enemy_state, {script.CALLBACK_UPDATE_HUD: update_hud_callback})
	return coordinator


static func bind_mastery_preview_coordinator(
	current: Variant,
	script: Variant,
	model: Variant,
	player_state: Variant,
	view: Variant,
	resolution_order: Array[int],
	feedback_seconds: float,
	modifiers: Dictionary,
	presentation_dependencies: Dictionary = {}
) -> Variant:
	var coordinator: Variant = current if current != null else script.new()
	(
		coordinator
		. bind(
			model,
			player_state,
			view,
			{
				"resolution_order": resolution_order,
				"feedback_stagger_seconds": feedback_seconds,
				"combat_modifiers": modifiers,
				"board_view": presentation_dependencies.get("board_view"),
				"combat_vfx_presenter": presentation_dependencies.get("combat_vfx_presenter"),
				"combat_speed_duration_callback": presentation_dependencies.get("combat_speed_duration_callback", Callable()),
			}
		)
	)
	return coordinator


static func bind_tutorial_prompt_presenter(current: Variant, script: Variant, host: Variant) -> Variant:
	var presenter: Variant = current if current != null else script.new()
	presenter.bind(host)
	return presenter


static func bind_resolve_trace_logger(current: Variant, script: Variant, model: Variant) -> Variant:
	var logger: Variant = current if current != null else script.new()
	logger.bind(model)
	return logger


static func bind_lifecycle(current: Variant, script: Variant, owner: Variant) -> Variant:
	var lifecycle: Variant = current if current != null else script.new()
	lifecycle.bind(owner)
	return lifecycle


static func bind_turn_replay_coordinator(current: Variant, script: Variant, owner: Variant) -> Variant:
	var coordinator: Variant = current if current != null else script.new()
	coordinator.bind(owner)
	return coordinator


static func bind_tutorial_end_command_handler(
	current: Variant, script: Variant, run_state: Variant, tutorial_director: Variant, view: Variant, owner: Variant, neutral_color: Color
) -> Variant:
	var handler: Variant = current if current != null else script.new()
	handler.bind_for_combat_controller(run_state, tutorial_director, view, owner, neutral_color)
	return handler
