extends RefCounted
class_name CombatControllerRuntimeHelperFactoryTest

const CONTRACT := preload("res://scripts/combat/combat_controller_contract.gd")
const FACTORY := preload("res://scripts/combat/combat_controller_runtime_helper_factory.gd")


class FakePlayerLoadoutHud:
	extends RefCounted

	var visual_registry: Variant = null

	func set_visual_registry(value: Variant) -> void:
		visual_registry = value


class FakeDebugRuntime:
	extends RefCounted

	var console_ref := RefCounted.new()

	func console() -> Variant:
		return console_ref


class FakeConsumableService:
	extends RefCounted

	var bind_args: Array[Dictionary] = []

	func bind(callbacks: Dictionary) -> void:
		bind_args.append(callbacks)


class FakeOwner:
	extends RefCounted

	const CONTRACT := CombatControllerRuntimeHelperFactoryTest.CONTRACT

	var _visuals: Variant = "visuals"
	var _player_loadout_hud: Variant = FakePlayerLoadoutHud.new()
	var _outcome_overlay: Variant = null
	var _turn_log_presenter: Variant = null
	var _debug_runtime: Variant = FakeDebugRuntime.new()
	var _settings_command_handler: Variant = null
	var _combat_timer_service: Variant = null
	var _boss_reward_handler: Variant = null
	var _combat_vfx_presenter: Variant = null
	var _board_controller: Variant = null
	var _hud_presenter: Variant = null
	var _hud_snapshot_provider: Variant = null
	var _vfx_target_resolver: Variant = null
	var _hud_stage_coordinator: Variant = null
	var _mastery_preview_coordinator: Variant = null
	var _player_hud_refresh_coordinator: Variant = null
	var _loadout_command_handler: Variant = null
	var _intent_hover_handler: Variant = null
	var _scene_transition_handler: Variant = null
	var _outcome_route_coordinator: Variant = null
	var _turn_resolution_coordinator: Variant = null
	var _tutorial_prompt_presenter: Variant = null
	var _tutorial_coachmark_coordinator: Variant = null
	var _tutorial_end_command_handler: Variant = null
	var _tutorial_drag_flow: Variant = null
	var _resolve_trace_logger: Variant = null
	var _turn_replay_coordinator: Variant = null
	var _state_initializer: Variant = null
	var _combat_consumable_service: Variant = FakeConsumableService.new()
	var _board_debug_command_handler: Variant = null
	var _input_command_handler: Variant = null
	var _tutorial_director: Variant = null
	var _debug_console: Variant = null
	var bind_audio_calls := 0
	var bind_debug_state_calls := 0

	func _bind_audio_router() -> void:
		bind_audio_calls += 1

	func _bind_debug_state_provider() -> void:
		bind_debug_state_calls += 1

	func _convert_random_non_target_orbs(_target_orb_id: int, _count: int, _rng: RandomNumberGenerator) -> int:
		return 0


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("factory_creates_missing_helpers", _test_factory_creates_missing_helpers, failures)
	_run_case("factory_preserves_existing_helpers", _test_factory_preserves_existing_helpers, failures)
	_run_case("factory_applies_owner_helpers", _test_factory_applies_owner_helpers, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_factory_creates_missing_helpers() -> String:
	var helpers: Dictionary = FACTORY.ensure_helpers({}, _script_map())
	var missing: Array[String] = []
	for key in FACTORY.SCRIPT_KEYS.keys():
		if helpers.get(key) == null:
			missing.append(String(key))
	if not missing.is_empty():
		return "Expected factory to create every runtime helper; missing %s." % ", ".join(missing)
	return ""


func _test_factory_preserves_existing_helpers() -> String:
	var existing := RefCounted.new()
	var helpers: Dictionary = FACTORY.ensure_helpers({"visuals": existing}, _script_map())
	if helpers.get("visuals") != existing:
		return "Expected factory to preserve existing helper instances."
	return ""


func _test_factory_applies_owner_helpers() -> String:
	var owner := FakeOwner.new()

	FACTORY.ensure_owner_helpers(owner)

	if owner._outcome_overlay == null or owner._turn_log_presenter == null:
		return "Expected owner helper creation to write missing helpers back to owner."
	if owner._player_loadout_hud.visual_registry != "visuals":
		return "Expected owner helper creation to sync visual registry into player HUD."
	if owner._debug_console != owner._debug_runtime.console_ref:
		return "Expected owner helper creation to sync debug console from debug runtime."
	if owner.bind_audio_calls != 1 or owner.bind_debug_state_calls != 1:
		return "Expected owner helper creation to bind audio and debug state providers."
	var consumable_service: FakeConsumableService = owner._combat_consumable_service
	if consumable_service.bind_args.size() != 1:
		return "Expected owner helper creation to bind combat consumable callbacks."
	if not (consumable_service.bind_args[0].get("convert_random_non_target_orbs") is Callable):
		return "Expected consumable service to receive board conversion callback."
	return ""


func _script_map() -> Dictionary:
	return {
		"VISUAL_REGISTRY_SCRIPT": CONTRACT.VISUAL_REGISTRY_SCRIPT,
		"PLAYER_LOADOUT_HUD_SCRIPT": CONTRACT.PLAYER_LOADOUT_HUD_SCRIPT,
		"COMBAT_OUTCOME_OVERLAY_SCRIPT": CONTRACT.COMBAT_OUTCOME_OVERLAY_SCRIPT,
		"COMBAT_TURN_LOG_PRESENTER_SCRIPT": CONTRACT.COMBAT_TURN_LOG_PRESENTER_SCRIPT,
		"COMBAT_DEBUG_RUNTIME_SCRIPT": CONTRACT.COMBAT_DEBUG_RUNTIME_SCRIPT,
		"COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT": CONTRACT.COMBAT_SETTINGS_COMMAND_HANDLER_SCRIPT,
		"COMBAT_TIMER_SERVICE_SCRIPT": CONTRACT.COMBAT_TIMER_SERVICE_SCRIPT,
		"COMBAT_BOSS_REWARD_HANDLER_SCRIPT": CONTRACT.COMBAT_BOSS_REWARD_HANDLER_SCRIPT,
		"COMBAT_VFX_PRESENTER_SCRIPT": CONTRACT.COMBAT_VFX_PRESENTER_SCRIPT,
		"BOARD_CONTROLLER_SCRIPT": CONTRACT.BOARD_CONTROLLER_SCRIPT,
		"COMBAT_HUD_PRESENTER_SCRIPT": CONTRACT.COMBAT_HUD_PRESENTER_SCRIPT,
		"COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT": CONTRACT.COMBAT_HUD_SNAPSHOT_PROVIDER_SCRIPT,
		"COMBAT_VFX_TARGET_RESOLVER_SCRIPT": CONTRACT.COMBAT_VFX_TARGET_RESOLVER_SCRIPT,
		"COMBAT_HUD_STAGE_COORDINATOR_SCRIPT": CONTRACT.COMBAT_HUD_STAGE_COORDINATOR_SCRIPT,
		"COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT": CONTRACT.COMBAT_MASTERY_PREVIEW_COORDINATOR_SCRIPT,
		"COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT": CONTRACT.COMBAT_PLAYER_HUD_REFRESH_COORDINATOR_SCRIPT,
		"COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT": CONTRACT.COMBAT_LOADOUT_COMMAND_HANDLER_SCRIPT,
		"COMBAT_INTENT_HOVER_HANDLER_SCRIPT": CONTRACT.COMBAT_INTENT_HOVER_HANDLER_SCRIPT,
		"COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT": CONTRACT.COMBAT_SCENE_TRANSITION_HANDLER_SCRIPT,
		"COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT": CONTRACT.COMBAT_OUTCOME_ROUTE_COORDINATOR_SCRIPT,
		"COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT": CONTRACT.COMBAT_TURN_RESOLUTION_COORDINATOR_SCRIPT,
		"COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT": CONTRACT.COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT,
		"COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT": CONTRACT.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT,
		"COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT": CONTRACT.COMBAT_TUTORIAL_END_COMMAND_HANDLER_SCRIPT,
		"COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT": CONTRACT.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT,
		"COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT": CONTRACT.COMBAT_RESOLVE_TRACE_LOGGER_SCRIPT,
		"COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT": CONTRACT.COMBAT_TURN_REPLAY_COORDINATOR_SCRIPT,
		"COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT": CONTRACT.COMBAT_CONTROLLER_STATE_INITIALIZER_SCRIPT,
		"COMBAT_CONSUMABLE_SERVICE_SCRIPT": CONTRACT.COMBAT_CONSUMABLE_SERVICE_SCRIPT,
		"COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT": CONTRACT.COMBAT_BOARD_DEBUG_COMMAND_HANDLER_SCRIPT,
		"COMBAT_INPUT_COMMAND_HANDLER_SCRIPT": CONTRACT.COMBAT_INPUT_COMMAND_HANDLER_SCRIPT,
		"COMBAT_GUIDANCE_DIRECTOR_SCRIPT": CONTRACT.COMBAT_GUIDANCE_DIRECTOR_SCRIPT,
	}
