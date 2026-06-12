extends RefCounted
class_name CombatControllerFeedbackSettingsRouter


static func apply(owner: Variant) -> void:
	var contract: Variant = owner.CONTRACT
	owner.call("_presentation_callback", "apply_vfx_speed_setting").call()
	var raw_game_juice_flags := RunState.game_juice_flags()
	var effective_game_juice_flags := _effective_game_juice_flags_for_motion(contract, raw_game_juice_flags)
	var refill_overshoot_enabled := (
		RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(contract.GAME_JUICE_FLAGS_SCRIPT.GRAVITY_REFILL_OVERSHOOT, true))
	)
	var board_controller: Variant = owner.get("_board_controller")
	if board_controller != null and board_controller.has_method("set_refill_overshoot_enabled"):
		board_controller.set_refill_overshoot_enabled(refill_overshoot_enabled)
	var combat_vfx_presenter: Variant = owner.get("_combat_vfx_presenter")
	if combat_vfx_presenter != null:
		if combat_vfx_presenter.has_method("set_post_match_vfx_quality"):
			combat_vfx_presenter.set_post_match_vfx_quality(RunState.combat_vfx_quality())
		if combat_vfx_presenter.has_method("set_reduced_motion_enabled"):
			combat_vfx_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
		if combat_vfx_presenter.has_method("set_game_juice_enabled"):
			combat_vfx_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
		if combat_vfx_presenter.has_method("set_game_juice_flags"):
			combat_vfx_presenter.set_game_juice_flags(effective_game_juice_flags)
	var resolve_presenter: Variant = owner.get("_resolve_presenter")
	if resolve_presenter != null and resolve_presenter.has_method("set_reduced_motion_enabled"):
		resolve_presenter.set_reduced_motion_enabled(RunState.reduced_motion_enabled())
	if resolve_presenter != null and resolve_presenter.has_method("set_game_juice_enabled"):
		resolve_presenter.set_game_juice_enabled(RunState.game_juice_enabled())
	if resolve_presenter != null and resolve_presenter.has_method("set_game_juice_flags"):
		resolve_presenter.set_game_juice_flags(effective_game_juice_flags)
	var combat_audio_cue_player: Variant = owner.get("_combat_audio_cue_player")
	if combat_audio_cue_player != null and combat_audio_cue_player.has_method("set_game_juice_enabled"):
		combat_audio_cue_player.set_game_juice_enabled(RunState.game_juice_enabled())
	if combat_audio_cue_player != null and combat_audio_cue_player.has_method("set_game_juice_flags"):
		combat_audio_cue_player.set_game_juice_flags(raw_game_juice_flags)
	var view: Variant = owner.get("_view")
	if view != null and view.has_method("set_enemy_reaction_settings"):
		view.set_enemy_reaction_settings(
			RunState.game_juice_enabled() and bool(effective_game_juice_flags.get(contract.GAME_JUICE_FLAGS_SCRIPT.ENEMY_REACTION_CHARACTER, true)),
			RunState.reduced_motion_enabled()
		)


static func _effective_game_juice_flags_for_motion(contract: Variant, flags: Dictionary) -> Dictionary:
	var game_juice_flags_script: Variant = contract.GAME_JUICE_FLAGS_SCRIPT
	var effective: Dictionary = game_juice_flags_script.normalized_flags(flags)
	if not RunState.reduced_motion_enabled():
		return effective
	for flag_key in game_juice_flags_script.all_keys():
		if game_juice_flags_script.is_motion_heavy(flag_key):
			effective[flag_key] = false
	return effective
