extends RefCounted
class_name CombatControllerRuntimeHelperFactory

const SCRIPT_KEYS := {
	"visuals": "VISUAL_REGISTRY_SCRIPT",
	"player_loadout_hud": "PLAYER_LOADOUT_HUD_SCRIPT",
	"outcome_overlay": "COMBAT_OUTCOME_OVERLAY_SCRIPT",
	"turn_log_presenter": "COMBAT_TURN_LOG_PRESENTER_SCRIPT",
	"debug_runtime": "COMBAT_DEBUG_RUNTIME_SCRIPT",
	"settings_command_handler": "COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT",
	"combat_timer_service": "COMBAT_TIMER_SERVICE_SCRIPT",
	"boss_reward_handler": "COMBAT_BOSS_REWARD_HANDLER_SCRIPT",
	"combat_vfx_presenter": "COMBAT_VFX_PRESENTER_SCRIPT",
	"board_controller": "BOARD_CONTROLLER_SCRIPT",
	"hud_presenter": "COMBAT_HUD_PRESENTER_SCRIPT",
	"hud_snapshot_provider": "COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT",
	"vfx_target_resolver": "COMBAT_VFX_TARGET_RESOLVER_SCRIPT",
	"hud_stage_coordinator": "COMBAT_HUD_STAGE_COORDINATOR_SCRIPT",
	"mastery_preview_coordinator": "COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT",
	"player_hud_refresh_coordinator": "COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT",
	"loadout_command_handler": "COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT",
	"intent_hover_handler": "COMBAT_INTENT_HOVER_HANDLER_SCRIPT",
	"scene_transition_handler": "COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT",
	"outcome_route_coordinator": "COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT",
	"turn_resolution_coordinator": "COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT",
	"tutorial_prompt_presenter": "COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT",
	"tutorial_coachmark_coordinator": "COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT",
	"tutorial_end_command_handler": "COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT",
	"tutorial_drag_flow": "COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT",
	"resolve_trace_logger": "COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT",
	"turn_replay_coordinator": "COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT",
	"state_initializer": "COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT",
	"combat_consumable_service": "COMBAT_CONSUMABLE_SERVICE_SCRIPT",
	"board_debug_command_handler": "COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT",
	"input_command_handler": "COMBAT_INPUT_COMMAND_HANDLER_SCRIPT",
	"tutorial_director": "COMBAT_GUIDANCE_DIRECTOR_SCRIPT",
}


static func ensure_helpers(current: Dictionary, scripts: Dictionary) -> Dictionary:
	var helpers := current.duplicate()
	for key in SCRIPT_KEYS.keys():
		if helpers.get(key) != null:
			continue
		var script: Variant = scripts.get(String(SCRIPT_KEYS.get(key, "")))
		if script == null:
			push_error("Missing runtime helper script for %s." % key)
			continue
		helpers[key] = script.new()
	return helpers
