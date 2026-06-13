extends Node

signal gold_changed(payload: Dictionary)
signal run_step_changed(payload: Dictionary)
signal run_state_changed(payload: Dictionary)
signal profile_changed(payload: Dictionary)
signal run_summary_changed(payload: Dictionary)

const RUN_STATE_DEPENDENCY_REGISTRY_SCRIPT := preload("res://scripts/core/run_state_dependency_registry.gd")
const SHOP_SESSION_SCRIPT := preload("res://scripts/shop/shop_session.gd")
const RUN_LOG_EXPORT_DIR := "res://logs"
const VFX_SPEED_SLOW := "slow"
const VFX_SPEED_NORMAL := "normal"
const VFX_SPEED_FAST := "fast"
const VFX_SPEED_INSTANT := "instant"
const COMBAT_VFX_QUALITY_LOW := "low"
const COMBAT_VFX_QUALITY_HIGH := "high"
const SCENE_MAIN := "res://scenes/main_menu.tscn"
const SCENE_COMBAT := "res://scenes/combat.tscn"
const SCENE_SHOP := "res://scenes/shop.tscn"
const SCENE_RUN_SUMMARY := "res://scenes/run_summary.tscn"
const MAX_DUNGEON_LEVELS := 3
const TUTORIAL_SEED := 271828
const FLOW_TRACE_ENABLED := true
const FLOW_TRACE_ROUTE_RETENTION_MAX := 50
const LEVEL_SEQUENCE: Array[String] = [
	"enemy_1",
	"shop",
	"enemy_2",
	"shop",
	"boss",
	"boss_relic_reward",
	"shop",
	"advance",
]

var player_state: PlayerState
var player_progression_state: PlayerProgressionState
var player_progression_service: PlayerProgressionService
var content_registry: ContentRegistry
var shop_state: ShopState
var shop_service: ShopService
var shop_session: ShopSession
var wallet_service: WalletService
var player_profile_state: PlayerProfileState
var meta_profile_state: MetaProfileState
var run_gold: int = 0
var run_score: int = 0
var _run_score_banked: bool = false
var dungeon_level: int = 1
var _relic_offer_ids_by_level: Dictionary = {}
var _player_state_content_errors: Array[Dictionary] = []
var run_active: bool = false
var run_victory: bool = false
var tutorial_run_active: bool = false
var tutorial_seed: int = TUTORIAL_SEED
var current_step_key: String = LEVEL_SEQUENCE[0]
var _step_index: int = 0
var enemies_defeated: int = 0
var bosses_defeated: int = 0
var total_gold_earned: int = 0
var _current_encounter: Dictionary = {}
var _boss_relic_reward_options: Array[Dictionary] = []
var _boss_reward_claimed_relic_id: String = ""
var _run_summary: Dictionary = {}
var _reward_rng := RandomNumberGenerator.new()
var _dependencies: RefCounted
var _profile_repository: Variant = null


func _ready() -> void:
	ensure_player_state()
	ensure_player_progression_state()
	ensure_player_progression_service()
	ensure_shop_state()
	ensure_shop_service()
	_reward_rng.randomize()
	load_user_settings()
	_load_meta_profile()
	_sync_meta_profile_default_unlocks()
	_sync_player_gold_from_run()
	validate_player_state_content()
	reset_run()


func _ensure_dependencies() -> RefCounted:
	if _dependencies == null:
		_dependencies = RUN_STATE_DEPENDENCY_REGISTRY_SCRIPT.new(self)
	return _dependencies


func ensure_player_state():
	return _ensure_dependencies().ensure_player_state()


func ensure_player_progression_state():
	return _ensure_dependencies().ensure_player_progression_state()


func ensure_player_progression_service():
	return _ensure_dependencies().ensure_player_progression_service()


func ensure_content_registry():
	return _ensure_dependencies().ensure_content_registry()


func ensure_shop_state():
	return _ensure_dependencies().ensure_shop_state()


func ensure_shop_service():
	return _ensure_dependencies().ensure_shop_service()


func ensure_shop_session():
	return _ensure_dependencies().ensure_shop_session(_shop_session_hooks())


func _shop_session_hooks() -> Dictionary:
	var shop_log_recorder: RunLogShopEventRecorder = _ensure_dependencies().ensure_run_log_shop_event_recorder()
	return {
		SHOP_SESSION_SCRIPT.HOOK_APPLY_TUTORIAL_SHOP_SEED: _apply_tutorial_shop_seed,
		SHOP_SESSION_SCRIPT.HOOK_APPEND_RUN_LOG: shop_log_recorder.append_run_log,
		SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_RESULT_BRIEF: shop_log_recorder.result_brief,
		SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_SHOP_ACTION: shop_log_recorder.record_shop_action,
		SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_SANITIZE_SHOP_SNAPSHOT: shop_log_recorder.sanitize_shop_snapshot,
		SHOP_SESSION_SCRIPT.HOOK_RUN_LOG_NEXT_SHOP_ORDINAL: shop_log_recorder.next_shop_ordinal,
	}


func ensure_wallet_service():
	return _ensure_dependencies().ensure_wallet_service()


# gdformat: off
func _transition_state_store_hooks() -> Dictionary:
	return {
		"run_score_banked": func() -> bool: return _run_score_banked,
		"set_run_score_banked": func(value: bool) -> void: _run_score_banked = value,
		"step_index": func() -> int: return _step_index,
		"set_step_index": func(value: int) -> void: _step_index = value,
		"current_encounter": func() -> Dictionary: return _current_encounter,
		"set_current_encounter": func(value: Dictionary) -> void: _current_encounter = value,
		"boss_relic_reward_options": func() -> Array[Dictionary]: return _boss_relic_reward_options,
		"set_boss_relic_reward_options": func(value: Array) -> void: _boss_relic_reward_options = value,
		"boss_reward_claimed_relic_id": func() -> String: return _boss_reward_claimed_relic_id,
		"set_boss_reward_claimed_relic_id": func(value: String) -> void: _boss_reward_claimed_relic_id = value,
		"relic_offer_ids_by_level": func() -> Dictionary: return _relic_offer_ids_by_level,
		"set_relic_offer_ids_by_level": func(value: Dictionary) -> void: _relic_offer_ids_by_level = value,
		"run_summary": func() -> Dictionary: return _run_summary,
		"set_run_summary": func(value: Dictionary) -> void: _run_summary = value,
		"run_logger_transition_snapshot": func() -> Dictionary: return _ensure_dependencies().ensure_run_logger().transition_snapshot(),
		"restore_run_logger_transition_snapshot":
		func(snapshot: Dictionary) -> void: _ensure_dependencies().ensure_run_logger().restore_transition_snapshot(snapshot),
		"scene_router_transition_snapshot": _scene_router_transition_snapshot,
		"restore_scene_router_transition_snapshot": _restore_scene_router_transition_snapshot,
		"capture_run_signal_state": _capture_run_signal_state,
		"sync_player_gold_from_run": _sync_player_gold_from_run,
		"emit_run_state_signals": _emit_run_state_signals,
	}


# gdformat: on


func _scene_router_transition_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).transition_snapshot()


func _restore_scene_router_transition_snapshot(snapshot: Dictionary) -> void:
	_ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).restore_transition_snapshot(snapshot)


func _profile_facade_hooks() -> Dictionary:
	return {
		"capture_run_signal_state": _capture_run_signal_state,
		"sync_meta_profile_default_unlocks": _sync_meta_profile_default_unlocks,
		"save_profile": _save_profile,
		"save_meta_profile": _save_meta_profile,
		"emit_run_state_signals": _emit_run_state_signals,
		"emit_profile_changed": _emit_profile_changed,
		"profile_unlock_service": func(): return _ensure_dependencies().ensure_profile_unlock_service(Callable(self, "_save_meta_profile")),
	}


# gdformat: off
func _outcome_service_hooks() -> Dictionary:
	return {
		"boss_relic_reward_options": func() -> Array[Dictionary]: return _boss_relic_reward_options,
		"set_boss_reward_claimed_relic_id": func(value: String) -> void: _boss_reward_claimed_relic_id = value,
		"current_encounter": func() -> Dictionary: return _current_encounter,
		"reward_rng": func() -> RandomNumberGenerator: return _reward_rng,
		"run_score_banked": func() -> bool: return _run_score_banked,
		"set_run_score_banked": func(value: bool) -> void: _run_score_banked = value,
		"run_summary": func() -> Dictionary: return _run_summary,
		"set_run_summary": func(value: Dictionary) -> void: _run_summary = value,
		"run_log_core_event_recorder": func(): return _ensure_dependencies().ensure_run_log_core_event_recorder(),
		"run_log_shop_event_recorder": func(): return _ensure_dependencies().ensure_run_log_shop_event_recorder(),
		"profile_unlock_service": func(): return _ensure_dependencies().ensure_profile_unlock_service(Callable(self, "_save_meta_profile")),
		"run_log_append": _run_log_append,
		"advance_sequence": _advance_sequence,
		"transition_result": _transition_result,
		"capture_run_signal_state": _capture_run_signal_state,
		"should_export_run_log_files": func() -> bool: return _ensure_dependencies().ensure_run_logger().should_export_run_log_files(),
		"run_log_export_to_disk": _run_log_export_to_disk,
		"emit_run_state_signals": _emit_run_state_signals,
	}


# gdformat: on


func ensure_player_profile_state() -> PlayerProfileState:
	return _ensure_dependencies().ensure_player_profile_state()


func ensure_meta_profile_state() -> MetaProfileState:
	return _ensure_dependencies().ensure_meta_profile_state()


func validate_player_state_content() -> Array[Dictionary]:
	_player_state_content_errors = ensure_content_registry().validate_player_state_content()
	return _player_state_content_errors.duplicate(true)


func prototype_balance_levers_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_balance_manager().levers_snapshot()


func prototype_fight_gold_reward_for(level: int, _step_key: String = "") -> int:
	return _ensure_dependencies().ensure_balance_manager().fight_gold_reward_for(level, MAX_DUNGEON_LEVELS)


# gdformat: off
func progression_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).progression_snapshot()


func profile_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).profile_snapshot()


func meta_profile_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).meta_profile_snapshot()


# gdformat: on


func reset_profile() -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).reset_profile()


func is_equipment_unlocked(item_id: String) -> bool:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).is_equipment_unlocked(item_id)


func unlock_equipment(item_id: String, source: String, emit_profile_signal: bool = true) -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).unlock_equipment(item_id, source, emit_profile_signal)


func claim_equipment_unlock(item_id: String) -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).claim_equipment_unlock(item_id)


func add_total_score(amount: int) -> int:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).add_total_score(amount)


func current_combat_modifiers() -> Dictionary:
	return _ensure_dependencies().ensure_profile_facade(_profile_facade_hooks()).current_combat_modifiers()


func set_gold(amount: int) -> void:
	var signal_before := _capture_run_signal_state()
	ensure_wallet_service().set_gold(self, amount)
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "set_gold", "set_gold")


func add_gold(amount: int, source: String = "combat_gain") -> int:
	if amount <= 0:
		return 0
	var signal_before := _capture_run_signal_state()
	ensure_wallet_service().add_gold(self, amount, source)
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "add_gold", source)
	return amount


func spend_gold(amount: int) -> bool:
	var signal_before := _capture_run_signal_state()
	if not ensure_wallet_service().spend_gold(self, amount):
		return false
	_sync_player_gold_from_run()
	_emit_run_state_signals(signal_before, "spend_gold", "spend_gold")
	return true


func can_afford(amount: int) -> bool:
	return ensure_wallet_service().can_afford(self, amount)


func open_shop_for_current_level() -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).open_shop_for_current_level()


func reroll_shop_items() -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).reroll_shop_items()


func buy_shop_offer(offer_id: String) -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).buy_shop_offer(offer_id)


func sell_equipped_item(slot_index: int) -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).sell_equipped_item(slot_index)


func sell_consumable_item(slot_index: int) -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).sell_consumable_item(slot_index)


func choose_treasure_chest_option(option_index: int) -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).choose_treasure_chest_option(option_index)


func replace_pending_treasure_chest_option(option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	return (
		_ensure_dependencies()
		. ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index)
		. replace_pending_treasure_chest_option(option_index, slot_index, sell_replaced)
	)


func discard_pending_treasure_chest_options() -> Dictionary:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).discard_pending_treasure_chest_options()


func close_shop(mark_skipped: bool = false) -> void:
	_ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).close_shop(mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return _ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).relic_offer_id_for_level(level)


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).set_relic_offer_id_for_level(level, relic_id)


func _apply_tutorial_shop_seed(action_offset: int) -> void:
	_ensure_dependencies().ensure_shop_facade(_relic_offer_ids_by_level, func() -> int: return _step_index).apply_tutorial_shop_seed(action_offset)


func reset_run(reason: String = "reset_run", emit_signals: bool = true) -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	ensure_player_state().reset_for_new_run()
	_sync_meta_profile_default_unlocks()
	ensure_wallet_service().reset_for_new_run(self, _ensure_dependencies().ensure_balance_manager().starting_gold())
	_run_score_banked = false
	ensure_player_state().gold = run_gold
	dungeon_level = 1
	_relic_offer_ids_by_level.clear()
	ensure_player_progression_state().reset_for_new_run()
	ensure_shop_state().reset_for_new_run()
	run_active = false
	run_victory = false
	tutorial_run_active = false
	tutorial_seed = TUTORIAL_SEED
	current_step_key = LEVEL_SEQUENCE[0]
	_step_index = 0
	enemies_defeated = 0
	bosses_defeated = 0
	_current_encounter.clear()
	_boss_relic_reward_options.clear()
	_boss_reward_claimed_relic_id = ""
	_run_summary.clear()
	_run_log_reset()
	validate_player_state_content()
	if emit_signals:
		_emit_run_state_signals(signal_before, reason, reason)


func start_new_run() -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	reset_run("start_new_run", false)
	tutorial_run_active = false
	_reward_rng.randomize()
	ensure_shop_service().randomize_rng()
	run_active = true
	_ensure_dependencies().ensure_run_log_core_event_recorder().record_run_start(dungeon_level, current_step_key)
	_assign_current_fight()
	_emit_run_state_signals(signal_before, "start_new_run", "start_new_run")


func start_tutorial_run(seed_value: int = TUTORIAL_SEED) -> void:
	var signal_before := _capture_run_signal_state()
	_flow_trace_bump_transition_generation()
	reset_run("start_tutorial_run", false)
	tutorial_run_active = true
	tutorial_seed = maxi(1, seed_value)
	run_active = true
	_reward_rng.seed = tutorial_seed + 9000
	(
		_ensure_dependencies()
		. ensure_run_log_core_event_recorder()
		. record_run_start(
			dungeon_level,
			current_step_key,
			{
				"source": "tutorial",
				"tutorial": true,
				"seed": tutorial_seed,
			}
		)
	)
	_assign_current_fight()
	_emit_run_state_signals(signal_before, "start_tutorial_run", "start_tutorial_run")


func snapshot_run_transition_state() -> Dictionary:
	return _ensure_dependencies().ensure_transition_state_store(_transition_state_store_hooks()).snapshot()


func restore_run_transition_state(snapshot: Dictionary) -> bool:
	return _ensure_dependencies().ensure_transition_state_store(_transition_state_store_hooks()).restore(snapshot)


func is_current_step_fight() -> bool:
	return current_step_key == "enemy_1" or current_step_key == "enemy_2" or current_step_key == "boss"


func is_tutorial_run() -> bool:
	return tutorial_run_active


func finish_tutorial_guidance() -> void:
	if not tutorial_run_active:
		return
	var signal_before := _capture_run_signal_state()
	tutorial_run_active = false
	_run_log_append(
		"tutorial_end",
		{
			"dungeon_level": dungeon_level,
			"step": current_step_key,
		}
	)
	_emit_run_state_signals(signal_before, "finish_tutorial_guidance", "")


func tutorial_board_seed_for_turn(turn_index: int) -> int:
	if not tutorial_run_active:
		return -1
	var step_seed := (_step_index + 1) * 1000
	var level_seed := dungeon_level * 10000
	var turn_seed := maxi(1, turn_index) * 37
	return tutorial_seed + level_seed + step_seed + turn_seed


func is_current_step_shop() -> bool:
	return current_step_key == "shop"


func current_shop_ordinal_in_level() -> int:
	if not is_current_step_shop():
		return 0
	var ordinal := 0
	for index in range(_step_index + 1):
		if String(LEVEL_SEQUENCE[index]) == "shop":
			ordinal += 1
	return ordinal


func is_current_step_boss_reward() -> bool:
	return current_step_key == "boss_relic_reward"


func level_sequence_label() -> String:
	var step_label := _step_display_name(current_step_key)
	return "Level %d/%d | %s" % [dungeon_level, MAX_DUNGEON_LEVELS, step_label]


func current_level_boss_preview() -> Dictionary:
	return _ensure_dependencies().ensure_balance_manager().apply_to_encounter(
		_ensure_dependencies().ensure_encounter_catalog().boss_encounter(dungeon_level), dungeon_level, MAX_DUNGEON_LEVELS
	)


func current_level_boss_name() -> String:
	return String(current_level_boss_preview().get("display_name", "Unknown Boss"))


func skip_to_fight(level: int, fight: int) -> Dictionary:
	if level < 1 or level > MAX_DUNGEON_LEVELS:
		return {"ok": false, "reason": "level_must_be_1_to_%d" % MAX_DUNGEON_LEVELS, "next_scene": SCENE_COMBAT}
	if fight < 1 or fight > 3:
		return {"ok": false, "reason": "fight_must_be_1_to_3", "next_scene": SCENE_COMBAT}

	var signal_before := _capture_run_signal_state()
	if not run_active:
		reset_run("skip_to_fight_reset", false)
	run_active = true
	run_victory = false
	_run_summary.clear()
	_boss_relic_reward_options.clear()
	_boss_reward_claimed_relic_id = ""
	dungeon_level = level
	match fight:
		1:
			_step_index = 0
		2:
			_step_index = 2
		3:
			_step_index = 4
	current_step_key = LEVEL_SEQUENCE[_step_index]
	_ensure_dependencies().ensure_run_log_core_event_recorder().record_run_start(dungeon_level, current_step_key, {"source": "skip_to_fight"})
	_assign_current_fight()
	_emit_run_state_signals(signal_before, "skip_to_fight", "skip_to_fight")
	return _transition_result()


func current_encounter_snapshot() -> Dictionary:
	return _current_encounter.duplicate(true)


func boss_relic_reward_options_snapshot() -> Array[Dictionary]:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).boss_relic_reward_options_snapshot()


func claim_boss_relic_reward(option_index: int) -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).claim_boss_relic_reward(option_index)


func skip_boss_relic_reward() -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).skip_boss_relic_reward()


func advance_after_boss_reward() -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).advance_after_boss_reward()


func mark_fight_victory() -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).mark_fight_victory()


func mark_player_defeated(cause: String) -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).mark_player_defeated(cause)


func advance_after_shop(mark_skipped: bool) -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).advance_after_shop(mark_skipped)


func run_summary_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).run_summary_snapshot()


func run_log_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_run_logger().run_log_snapshot()


func generate_run_log_files_enabled() -> bool:
	return _ensure_dependencies().ensure_user_settings_store().generate_run_log_files


func set_generate_run_log_files_enabled(enabled: bool) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_generate_run_log_files(enabled)


func load_user_settings() -> void:
	_ensure_dependencies().ensure_user_settings_store().load()


func vfx_speed() -> String:
	return _ensure_dependencies().ensure_user_settings_store().vfx_speed


func set_vfx_speed(speed: String) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_vfx_speed(speed)


func combat_vfx_quality() -> String:
	return _ensure_dependencies().ensure_user_settings_store().combat_vfx_quality


func set_combat_vfx_quality(quality: String) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_combat_vfx_quality(quality)


func reduced_motion_enabled() -> bool:
	return _ensure_dependencies().ensure_user_settings_store().reduced_motion


func set_reduced_motion_enabled(enabled: bool) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_reduced_motion_enabled(enabled)


func game_juice_enabled() -> bool:
	return _ensure_dependencies().ensure_user_settings_store().game_juice_enabled


func set_game_juice_enabled(enabled: bool) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_game_juice_enabled(enabled)


func game_juice_flags() -> Dictionary:
	return _ensure_dependencies().ensure_user_settings_store().game_juice_flags.duplicate()


func game_juice_flag_enabled(flag_key: String) -> bool:
	return _ensure_dependencies().ensure_user_settings_store().game_juice_flag_enabled(flag_key)


func set_game_juice_flag_enabled(flag_key: String, enabled: bool) -> void:
	_ensure_dependencies().ensure_user_settings_store().set_game_juice_flag_enabled(flag_key, enabled)


func reset_combat_feedback_settings() -> void:
	_ensure_dependencies().ensure_user_settings_store().reset_to_defaults()


func combat_feedback_settings() -> Dictionary:
	return _ensure_dependencies().ensure_user_settings_store().combat_feedback_settings()


func _load_meta_profile() -> void:
	_load_profile()


func _load_profile() -> void:
	var profile: PlayerProfileState = ensure_player_profile_state()
	_ensure_dependencies().ensure_profile_repository(_profile_repository).load_profile(profile)
	meta_profile_state = profile.meta_profile


func _save_meta_profile() -> void:
	_save_profile()


func _save_profile() -> void:
	var profile: PlayerProfileState = ensure_player_profile_state()
	_ensure_dependencies().ensure_profile_repository(_profile_repository).save_profile(profile)
	meta_profile_state = profile.meta_profile


func log_turn_result(turn_log: Dictionary, context: Dictionary = {}) -> void:
	_ensure_dependencies().ensure_run_log_core_event_recorder().record_turn_result(turn_log, context)


func _advance_sequence(reason: String = "advance_sequence") -> void:
	var signal_before := _capture_run_signal_state()
	_step_index += 1
	if _step_index >= LEVEL_SEQUENCE.size():
		_step_index = LEVEL_SEQUENCE.size() - 1
	current_step_key = LEVEL_SEQUENCE[_step_index]

	if current_step_key != "advance":
		if is_current_step_fight():
			_assign_current_fight()
		_emit_run_state_signals(signal_before, reason, "")
		return

	if dungeon_level >= MAX_DUNGEON_LEVELS:
		_emit_run_state_signals(signal_before, reason, "")
		_ensure_dependencies().ensure_outcome_service(_outcome_service_hooks()).finalize_run(true, "Final boss defeated.")
		return

	dungeon_level += 1
	_step_index = 0
	current_step_key = LEVEL_SEQUENCE[_step_index]
	_assign_current_fight()
	_emit_run_state_signals(signal_before, reason, "")


func _assign_current_fight() -> void:
	if not is_current_step_fight():
		_current_encounter.clear()
		return

	var encounter: Dictionary = {}
	var uses_tutorial_encounter := false
	if tutorial_run_active:
		encounter = _ensure_dependencies().ensure_encounter_catalog().tutorial_encounter_for(dungeon_level, current_step_key)
		uses_tutorial_encounter = not encounter.is_empty()
	if encounter.is_empty():
		if current_step_key == "boss":
			encounter = _ensure_dependencies().ensure_encounter_catalog().boss_encounter(dungeon_level)
		else:
			encounter = _ensure_dependencies().ensure_encounter_catalog().normal_encounter(dungeon_level, current_step_key)

	if encounter.is_empty():
		encounter = _ensure_dependencies().ensure_encounter_catalog().fallback_encounter(current_step_key)

	if not uses_tutorial_encounter:
		encounter = _ensure_dependencies().ensure_balance_manager().apply_to_encounter(encounter, dungeon_level, MAX_DUNGEON_LEVELS)
	encounter["dungeon_level"] = dungeon_level
	encounter["step_key"] = current_step_key
	encounter["boss_preview_name"] = current_level_boss_name()
	_current_encounter = encounter
	_ensure_dependencies().ensure_run_log_core_event_recorder().record_fight_start(_current_encounter)


func _run_log_reset() -> void:
	_ensure_dependencies().ensure_run_log_core_event_recorder().reset_run_log()


func _run_log_append(event_type: String, payload: Dictionary) -> void:
	_ensure_dependencies().ensure_run_log_core_event_recorder().append_event(event_type, payload)


func _run_log_export_to_disk() -> void:
	_ensure_dependencies().ensure_run_logger().run_log_export_to_disk(RUN_LOG_EXPORT_DIR)


func _transition_result(extra: Dictionary = {}) -> Dictionary:
	var result := {
		"ok": true,
		"reason": "",
		"next_scene": next_scene_path(),
		"step": current_step_key,
		"dungeon_level": dungeon_level,
	}
	for key in extra.keys():
		result[key] = extra[key]
	return result


func next_scene_path() -> String:
	if not run_active:
		if not _run_summary.is_empty():
			return SCENE_RUN_SUMMARY
		return SCENE_MAIN
	if is_current_step_fight():
		return SCENE_COMBAT
	if is_current_step_shop():
		return SCENE_SHOP
	if is_current_step_boss_reward():
		return SCENE_COMBAT
	return SCENE_MAIN


func _sync_meta_profile_default_unlocks() -> void:
	_ensure_dependencies().ensure_profile_unlock_service(Callable(self, "_save_meta_profile")).sync_default_unlocks()


func flow_trace_begin(route_name: String, target_scene: String, details: Dictionary = {}) -> String:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_begin(route_name, target_scene, details)


func flow_trace_mark(step: String, details: Dictionary = {}, route_id: String = "", target_scene_override: String = "") -> void:
	_ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_mark(
		step, details, route_id, target_scene_override
	)


func flow_trace_change_scene(
	tree: SceneTree,
	target_scene: String,
	route_id: String = "",
	source: String = "",
	before_step: String = "",
	post_ready_failure_callback: Callable = Callable(),
	rollback_snapshot: Dictionary = {}
) -> int:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_change_scene(
		tree, target_scene, route_id, source, before_step, post_ready_failure_callback, rollback_snapshot
	)


func flow_trace_prepare_scene(target_scene: String, route_id: String = "", source: String = "") -> Dictionary:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_prepare_scene(
		target_scene, route_id, source
	)


func warm_packed_scene(target_scene: String) -> bool:
	return bool(_ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).warm_packed_scene(target_scene))


func flow_trace_attach_prepared_scene(tree: SceneTree, prepared: Dictionary, target_scene: String, route_id: String = "", source: String = "") -> int:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_attach_prepared_scene(
		tree, prepared, target_scene, route_id, source
	)


func flow_trace_active_route_id() -> String:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_active_route_id()


func flow_trace_debug_snapshot() -> Dictionary:
	return _ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_debug_snapshot()


func _flow_trace_bump_transition_generation() -> void:
	_ensure_dependencies().ensure_scene_router(FLOW_TRACE_ENABLED, FLOW_TRACE_ROUTE_RETENTION_MAX).flow_trace_bump_transition_generation()


func _step_display_name(step: String) -> String:
	return _ensure_dependencies().ensure_encounter_catalog().step_display_name(step)


func _sync_player_gold_from_run() -> void:
	ensure_player_state().gold = run_gold


func _capture_run_signal_state() -> Dictionary:
	return _ensure_dependencies().ensure_signal_emitter(func() -> int: return _step_index, func() -> Dictionary: return _run_summary).capture()


func _emit_run_state_signals(previous: Dictionary, reason: String, gold_source: String) -> void:
	(
		_ensure_dependencies()
		. ensure_signal_emitter(func() -> int: return _step_index, func() -> Dictionary: return _run_summary)
		. emit_run_state_signals(previous, reason, gold_source)
	)


func _emit_profile_changed(reason: String, score_delta: int = 0, unlock: Dictionary = {}) -> void:
	(
		_ensure_dependencies()
		. ensure_signal_emitter(func() -> int: return _step_index, func() -> Dictionary: return _run_summary)
		. emit_profile_changed(reason, score_delta, unlock)
	)
