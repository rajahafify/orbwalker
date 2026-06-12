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


static func bind_turn_replay_coordinator(current: Variant, script: Variant, owner: Variant, run_state: Variant) -> Variant:
	var coordinator: Variant = current if current != null else script.new()
	Callable(owner, "_bind_hud_stage_coordinator").call()
	Callable(owner, "_bind_vfx_target_resolver").call()
	Callable(owner, "_bind_mastery_preview_coordinator").call()
	Callable(owner, "_bind_audio_router").call()
	var contract: Variant = owner.CONTRACT
	var audio_router: Variant = owner.get("_audio_router")
	var dependencies := {
		"model": owner.get("_model"),
		"player_state": owner.get("_player_state"),
		"view": owner.get("_view"),
		"vfx_presenter": owner.get("_combat_vfx_presenter"),
		"hud_stage_coordinator": owner.get("_hud_stage_coordinator"),
		"vfx_target_resolver": owner.get("_vfx_target_resolver"),
		"mastery_preview_coordinator": owner.get("_mastery_preview_coordinator"),
		"combat_modifiers": run_state.current_combat_modifiers(),
	}
	var callbacks := {
		script.CALLBACK_COMBAT_SPEED_DURATION: Callable(owner, "_combat_speed_duration"),
		script.CALLBACK_WAIT_COMBAT_SPEED: Callable(owner, "_wait_combat_speed"),
		script.CALLBACK_CAN_CONTINUE: Callable(owner, "_can_continue_after_async_wait"),
		script.CALLBACK_PLAY_IMPACT_SFX: Callable(audio_router, "play_impact_sfx"),
		script.CALLBACK_PLAY_ENEMY_ATTACK_SFX: Callable(audio_router, "play_enemy_attack_result_sfx"),
	}
	var config := {
		script.CONFIG_TURN_REPLAY_STEP_SECONDS: contract.TURN_REPLAY_STEP_SECONDS,
		script.CONFIG_TURN_REPLAY_FINAL_HOLD_SECONDS: contract.TURN_REPLAY_FINAL_HOLD_SECONDS,
		script.CONFIG_ELEMENTAL_CAST_SPOOL_SECONDS: contract.ELEMENTAL_CAST_SPOOL_SECONDS,
		script.CONFIG_ELEMENTAL_CAST_LAUNCH_SECONDS: contract.ELEMENTAL_CAST_LAUNCH_SECONDS,
		script.CONFIG_ELEMENTAL_CAST_IMPACT_HOLD_SECONDS: contract.ELEMENTAL_CAST_IMPACT_HOLD_SECONDS,
	}
	coordinator.bind(dependencies, callbacks, config)
	return coordinator


static func bind_tutorial_end_command_handler(
	current: Variant, script: Variant, run_state: Variant, tutorial_director: Variant, view: Variant, owner: Variant, neutral_color: Color
) -> Variant:
	var handler: Variant = current if current != null else script.new()
	Callable(owner, "_bind_audio_router").call()
	Callable(owner, "_bind_view_actions").call()
	var audio_router: Variant = owner.get("_audio_router")
	var view_actions: Variant = owner.get("_view_actions")
	var current_turn_index := func() -> int:
		var combat: Variant = owner.get("_combat")
		return int(combat.turn_index if combat != null else 1)
	var show_shop_damage_modal := func() -> void:
		if view != null and view.has_method("show_tutorial_end_modal"):
			view.show_tutorial_end_modal("shop_damage")
	var callbacks := {
		script.CALLBACK_CURRENT_ROUTE_ID: Callable(owner, "_flow_trace_route_id_value"),
		script.CALLBACK_CURRENT_TURN_INDEX: current_turn_index,
		script.CALLBACK_SHOW_SHOP_DAMAGE_MODAL: show_shop_damage_modal,
		script.CALLBACK_PLAY_SFX: Callable(audio_router, "play_sfx"),
		script.CALLBACK_SET_STATUS_TEXT: Callable(view_actions, "set_status_text"),
		script.CALLBACK_SET_STATUS_COLOR: Callable(view_actions, "set_status_color"),
		script.CALLBACK_UPDATE_HUD: Callable(owner, "_update_hud"),
		script.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(owner, "_trace_and_change_scene_to_target"),
	}
	handler.bind({"run_state": run_state, "tutorial_director": tutorial_director, "view": view}, callbacks, {"neutral_status_color": neutral_color})
	return handler
