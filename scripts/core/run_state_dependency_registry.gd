extends RefCounted
class_name RunStateDependencyRegistry

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const PLAYER_PROFILE_STATE_SCRIPT := preload("res://scripts/run/player_profile_state.gd")
const META_PROFILE_STATE_SCRIPT := preload("res://scripts/run/meta_profile_state.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const SHOP_STATE_SCRIPT := preload("res://scripts/shop/shop_state.gd")
const SHOP_SERVICE_SCRIPT := preload("res://scripts/shop/shop_service.gd")
const SHOP_SESSION_SCRIPT := preload("res://scripts/shop/shop_session.gd")
const WALLET_SERVICE_SCRIPT := preload("res://scripts/run/wallet_service.gd")
const RUN_LOGGER_SCRIPT := preload("res://scripts/core/run_logger.gd")
const RUN_LOG_CORE_EVENT_RECORDER_SCRIPT := preload("res://scripts/core/run_log_core_event_recorder.gd")
const RUN_LOG_SHOP_EVENT_RECORDER_SCRIPT := preload("res://scripts/core/run_log_shop_event_recorder.gd")
const SCENE_ROUTER_SCRIPT := preload("res://scripts/core/scene_router.gd")
const PROFILE_REPOSITORY_SCRIPT := preload("res://scripts/core/profile_repository.gd")
const BALANCE_MANAGER_SCRIPT := preload("res://scripts/core/balance_manager.gd")
const RUN_USER_SETTINGS_STORE_SCRIPT := preload("res://scripts/core/run_user_settings_store.gd")
const RUN_PROFILE_UNLOCK_SERVICE_SCRIPT := preload("res://scripts/core/run_profile_unlock_service.gd")
const RUN_STATE_SIGNAL_EMITTER_SCRIPT := preload("res://scripts/core/run_state_signal_emitter.gd")
const RUN_TRANSITION_STATE_STORE_SCRIPT := preload("res://scripts/core/run_transition_state_store.gd")
const RUN_PROFILE_FACADE_SCRIPT := preload("res://scripts/core/run_profile_facade.gd")
const RUN_SHOP_FACADE_SCRIPT := preload("res://scripts/core/run_shop_facade.gd")
const RUN_STATE_CONTRACT_REPORTER_SCRIPT := preload("res://scripts/core/run_state_contract_reporter.gd")
const RUN_ENCOUNTER_CATALOG_SCRIPT := preload("res://scripts/core/run_encounter_catalog.gd")
const RUN_OUTCOME_SERVICE_SCRIPT := preload("res://scripts/core/run_outcome_service.gd")

var _owner
var _run_logger: RunLogger
var _run_log_core_event_recorder: RunLogCoreEventRecorder
var _run_log_shop_event_recorder: RunLogShopEventRecorder
var _scene_router: SceneRouter
var _profile_repository: ProfileRepository
var _balance_manager: BalanceManager
var _user_settings_store
var _profile_unlock_service
var _signal_emitter
var _transition_state_store
var _profile_facade
var _shop_facade
var _contract_reporter
var _encounter_catalog
var _outcome_service


func _init(owner) -> void:
	_owner = owner


func ensure_player_state():
	if _owner.player_state == null:
		_owner.player_state = PLAYER_STATE_SCRIPT.new()
	return _owner.player_state


func ensure_player_progression_state():
	if _owner.player_progression_state == null:
		_owner.player_progression_state = PLAYER_PROGRESSION_STATE_SCRIPT.new()
	return _owner.player_progression_state


func ensure_player_progression_service():
	if _owner.player_progression_service == null:
		_owner.player_progression_service = PLAYER_PROGRESSION_SERVICE_SCRIPT.new()
	return _owner.player_progression_service


func ensure_content_registry():
	if _owner.content_registry == null:
		_owner.content_registry = CONTENT_REGISTRY_SCRIPT.new()
	ensure_balance_manager().sync_content_registry(_owner.content_registry)
	return _owner.content_registry


func ensure_shop_state():
	if _owner.shop_state == null:
		_owner.shop_state = SHOP_STATE_SCRIPT.new()
	return _owner.shop_state


func ensure_shop_service():
	if _owner.shop_service == null:
		_owner.shop_service = SHOP_SERVICE_SCRIPT.new()
	return _owner.shop_service


func ensure_shop_session(hooks: Dictionary):
	if _owner.shop_session == null:
		_owner.shop_session = SHOP_SESSION_SCRIPT.new()
		_owner.shop_session.configure_hooks(hooks)
	return _owner.shop_session


func ensure_wallet_service():
	if _owner.wallet_service == null:
		_owner.wallet_service = WALLET_SERVICE_SCRIPT.new()
	return _owner.wallet_service


func ensure_run_logger():
	if _run_logger == null:
		_run_logger = RUN_LOGGER_SCRIPT.new(_owner)
	return _run_logger


func ensure_run_log_core_event_recorder():
	if _run_log_core_event_recorder == null:
		_run_log_core_event_recorder = RUN_LOG_CORE_EVENT_RECORDER_SCRIPT.new(ensure_run_logger)
	return _run_log_core_event_recorder


func ensure_run_log_shop_event_recorder() -> RunLogShopEventRecorder:
	if _run_log_shop_event_recorder == null:
		_run_log_shop_event_recorder = RUN_LOG_SHOP_EVENT_RECORDER_SCRIPT.new(ensure_run_logger)
	return _run_log_shop_event_recorder


func ensure_scene_router(flow_trace_enabled: bool, flow_trace_route_retention_max: int):
	if _scene_router == null:
		_scene_router = SCENE_ROUTER_SCRIPT.new(_owner, flow_trace_enabled, flow_trace_route_retention_max)
	return _scene_router


func ensure_profile_repository(profile_repository_override: Variant = null):
	if profile_repository_override != null:
		return profile_repository_override
	if _profile_repository == null:
		_profile_repository = PROFILE_REPOSITORY_SCRIPT.new()
	return _profile_repository


func ensure_balance_manager():
	if _balance_manager == null:
		_balance_manager = BALANCE_MANAGER_SCRIPT.new()
	return _balance_manager


func ensure_user_settings_store():
	if _user_settings_store == null:
		_user_settings_store = RUN_USER_SETTINGS_STORE_SCRIPT.new()
	return _user_settings_store


func ensure_profile_unlock_service(save_profile_callback: Callable):
	if _profile_unlock_service == null:
		_profile_unlock_service = RUN_PROFILE_UNLOCK_SERVICE_SCRIPT.new(_owner, save_profile_callback)
	return _profile_unlock_service


func ensure_signal_emitter(step_index_provider: Callable, run_summary_provider: Callable):
	if _signal_emitter == null:
		_signal_emitter = RUN_STATE_SIGNAL_EMITTER_SCRIPT.new(_owner, step_index_provider, run_summary_provider)
	return _signal_emitter


func ensure_transition_state_store(hooks: Dictionary):
	if _transition_state_store == null:
		_transition_state_store = RUN_TRANSITION_STATE_STORE_SCRIPT.new(_owner, hooks)
	return _transition_state_store


func ensure_profile_facade(hooks: Dictionary):
	if _profile_facade == null:
		_profile_facade = RUN_PROFILE_FACADE_SCRIPT.new(_owner, hooks)
	return _profile_facade


func ensure_shop_facade(relic_offer_ids_by_level: Dictionary, step_index_provider: Callable):
	if _shop_facade == null:
		_shop_facade = RUN_SHOP_FACADE_SCRIPT.new(_owner, relic_offer_ids_by_level, step_index_provider)
	return _shop_facade


func ensure_contract_reporter():
	if _contract_reporter == null:
		_contract_reporter = RUN_STATE_CONTRACT_REPORTER_SCRIPT.new(_owner)
	return _contract_reporter


func ensure_encounter_catalog():
	if _encounter_catalog == null:
		_encounter_catalog = RUN_ENCOUNTER_CATALOG_SCRIPT.new()
	return _encounter_catalog


func ensure_outcome_service(hooks: Dictionary):
	if _outcome_service == null:
		_outcome_service = RUN_OUTCOME_SERVICE_SCRIPT.new(_owner, hooks)
	return _outcome_service


func ensure_player_profile_state() -> PlayerProfileState:
	if _owner.player_profile_state == null:
		_owner.player_profile_state = PLAYER_PROFILE_STATE_SCRIPT.new()
		_owner.meta_profile_state = _owner.player_profile_state.meta_profile
	return _owner.player_profile_state


func ensure_meta_profile_state() -> MetaProfileState:
	var profile: PlayerProfileState = ensure_player_profile_state()
	_owner.meta_profile_state = profile.meta_profile
	return profile.meta_profile
