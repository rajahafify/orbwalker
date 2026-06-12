extends RefCounted
class_name CombatControllerContract

const SWAP_ANIMATION_SECONDS := 0.08
const MATCH_FLASH_SECONDS := 0.12
const CLEAR_ANIMATION_SECONDS := 0.12
const GRAVITY_ANIMATION_SECONDS := 0.14
const REFILL_ANIMATION_SECONDS := 0.14

const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_service.gd")
const TEST_RUNNER_SCRIPT := preload("res://scripts/tests/run_all_tests.gd")
const COMBAT_STATE_MACHINE_SCRIPT := preload("res://scripts/combat/combat_state_machine.gd")
const ENEMY_STATE_SCRIPT := preload("res://scripts/combat/enemy_state.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const PLAYER_LOADOUT_HUD_SCRIPT := preload("res://scripts/ui/player_loadout_hud.gd")
const COMBAT_OUTCOME_OVERLAY_SCRIPT := preload("res://scripts/combat/combat_outcome_overlay.gd")
const COMBAT_RESOLVE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_resolve_presenter.gd")
const COMBAT_DEBUG_RUNTIME_SCRIPT := preload("res://scripts/combat/combat_debug_runtime.gd")
const COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_settings_command_handler.gd")
const COMBAT_TIMER_SERVICE_SCRIPT := preload("res://scripts/combat/combat_timer_service.gd")
const COMBAT_BOSS_REWARD_HANDLER_SCRIPT := preload("res://scripts/combat/combat_boss_reward_handler.gd")
const COMBAT_TURN_LOG_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_turn_log_presenter.gd")
const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const BOARD_CONTROLLER_SCRIPT := preload("res://scripts/board/board_controller.gd")
const COMBAT_HUD_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_hud_presenter.gd")
const COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT := preload("res://scripts/combat/combat_hud_snapshot_provider.gd")
const COMBAT_VFX_TARGET_RESOLVER_SCRIPT := preload("res://scripts/combat/combat_vfx_target_resolver.gd")
const COMBAT_HUD_STAGE_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_hud_stage_coordinator.gd")
const COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_mastery_preview_coordinator.gd")
const COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_player_hud_refresh_coordinator.gd")
const COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_loadout_command_handler.gd")
const COMBAT_INTENT_HOVER_HANDLER_SCRIPT := preload("res://scripts/combat/combat_intent_hover_handler.gd")
const COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT := preload("res://scripts/combat/combat_scene_transition_handler.gd")
const COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_outcome_route_coordinator.gd")
const COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_resolution_coordinator.gd")
const COMBAT_INPUT_PHASE_ROUTER_SCRIPT := preload("res://scripts/combat/combat_input_phase_router.gd")
const COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_tutorial_prompt_presenter.gd")
const COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_tutorial_coachmark_coordinator.gd")
const COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_tutorial_end_command_handler.gd")
const COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT := preload("res://scripts/combat/combat_tutorial_drag_flow.gd")
const COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT := preload("res://scripts/combat/combat_resolve_trace_logger.gd")
const COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_turn_replay_coordinator.gd")
const COMBAT_TURN_LOG_WRITER_SCRIPT := preload("res://scripts/combat/combat_turn_log_writer.gd")
const COMBAT_MASTERY_FILL_STREAMER_SCRIPT := preload("res://scripts/combat/combat_mastery_fill_streamer.gd")
const COMBAT_CONTROLLER_LIFECYCLE_SCRIPT := preload("res://scripts/combat/combat_controller_lifecycle.gd")
const COMBAT_CONTROLLER_BINDING_COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_controller_binding_coordinator.gd")
const COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT := preload("res://scripts/combat/combat_controller_runtime_binder.gd")
const COMBAT_CONTROLLER_RUNTIME_HELPER_FACTORY_SCRIPT := preload("res://scripts/combat/combat_controller_runtime_helper_factory.gd")
const COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT := preload("res://scripts/combat/combat_controller_state_initializer.gd")
const COMBAT_CONTROLLER_SCENE_BINDER_SCRIPT := preload("res://scripts/combat/combat_controller_scene_binder.gd")
const COMBAT_CONTROLLER_VIEW_ACTIONS_SCRIPT := preload("res://scripts/combat/combat_controller_view_actions.gd")
const COMBAT_CONTROLLER_PRESENTATION_DRIVER_SCRIPT := preload("res://scripts/combat/combat_controller_presentation_driver.gd")
const COMBAT_CONSUMABLE_SERVICE_SCRIPT := preload("res://scripts/combat/combat_consumable_service.gd")
const COMBAT_AUDIO_CUE_PLAYER_SCRIPT := preload("res://scripts/combat/combat_audio_cue_player.gd")
const COMBAT_DEBUG_STATE_PROVIDER_SCRIPT := preload("res://scripts/combat/combat_debug_state_provider.gd")
const COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_board_debug_command_handler.gd")
const COMBAT_INPUT_COMMAND_HANDLER_SCRIPT := preload("res://scripts/combat/combat_input_command_handler.gd")
const COMBAT_GUIDANCE_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")
const FLOW_RESULT_UTILS := preload("res://scripts/core/flow_result_utils.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const COMBAT_PHASE_INTENT_PREVIEW := 0
const COMBAT_PHASE_VICTORY := 6
const COMBAT_PHASE_DEFEAT := 7
const MAX_COMBAT_LOG_LINES := 120
const COMMAND_OUTPUT_LOG_COLOR := Color(0.45, 0.95, 0.45, 1.0)
const LOG_LEVEL_NORMAL := "normal"
const LOG_LEVEL_DETAILED := "detailed"
const STATUS_COLOR_NEUTRAL := Color(1.0, 1.0, 1.0, 1.0)
const STATUS_COLOR_POSITIVE := Color(0.65, 1.0, 0.72, 1.0)
const STATUS_COLOR_WARNING := Color(1.0, 0.86, 0.54, 1.0)
const STATUS_COLOR_NEGATIVE := Color(1.0, 0.62, 0.62, 1.0)
const COMBAT_MASTERY_FEEDBACK_STAGGER_SECONDS := 0.08
const COMBAT_SPEED_SLOW := "slow"
const COMBAT_SPEED_NORMAL := "normal"
const COMBAT_SPEED_FAST := "fast"
const COMBAT_SPEED_INSTANT := "instant"
const COMBO_COUNT_STEP_SECONDS := 0.22
const CASCADE_PASS_HOLD_SECONDS := 0.16
const TURN_REPLAY_STEP_SECONDS := 0.34
const TURN_REPLAY_FINAL_HOLD_SECONDS := 0.22
const ELEMENTAL_CAST_SPOOL_SECONDS := 0.86
const ELEMENTAL_CAST_LAUNCH_SECONDS := 0.82
const ELEMENTAL_CAST_IMPACT_HOLD_SECONDS := 0.50
const COMBAT_MASTERY_RESOLUTION_ORDER: Array[int] = [
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
]
