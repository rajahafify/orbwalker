extends RefCounted
class_name CombatControllerStateInitializer

const CALLBACK_APPLY_STATE := "apply_state"
const CALLBACK_BIND_HUD_STAGE := "bind_hud_stage"
const CALLBACK_REFRESH_CHARACTER_PORTRAITS := "refresh_character_portraits"
const CALLBACK_REFRESH_BUILD_ICON_ROWS := "refresh_build_icon_rows"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_BIND_DEBUG_STATE_PROVIDER := "bind_debug_state_provider"
const CALLBACK_ROUTE_ID := "route_id"
const CALLBACK_SCENE_ROLLBACK := "scene_rollback"
const CALLBACK_HANDLE_SCENE_CHANGE_FAILURE := "handle_scene_change_failure"

var _run_state: Variant = null
var _model: Variant = null
var _host: Variant = null
var _view_actions: Variant = null
var _enemy_state_script: Variant = null
var _combat_state_machine_script: Variant = null
var _flow_result_utils: Variant = null
var _status_color_warning := Color(1.0, 0.86, 0.54, 1.0)
var _callbacks: Dictionary = {}


func bind(dependencies: Dictionary, callbacks: Dictionary) -> void:
	_run_state = dependencies.get("run_state")
	_model = dependencies.get("model")
	_host = dependencies.get("host")
	_view_actions = dependencies.get("view_actions")
	_enemy_state_script = dependencies.get("enemy_state_script")
	_combat_state_machine_script = dependencies.get("combat_state_machine_script")
	_flow_result_utils = dependencies.get("flow_result_utils")
	_status_color_warning = dependencies.get("status_color_warning", _status_color_warning)
	_callbacks = callbacks.duplicate()


func initialize() -> void:
	if not bool(_run_state.run_active):
		_flow_mark("combat_initialize_no_active_run_starting_new")
		_run_state.start_new_run()
	if _run_state.is_current_step_boss_reward():
		_initialize_boss_reward_state()
		return
	if not _run_state.is_current_step_fight():
		_redirect_non_fight_step()
		return
	_initialize_fight_state()


func _initialize_boss_reward_state() -> void:
	var player_state: Variant = _run_state.ensure_player_state()
	var progression_state: Variant = _run_state.ensure_player_progression_state()
	player_state.set_mastery_level_provider(Callable(progression_state, "mastery_level"))
	var enemy_state: Variant = _enemy_state_script.new()
	enemy_state.configure_from_blueprint(_run_state.current_level_boss_preview())
	_apply_state({"player_state": player_state, "progression_state": progression_state, "enemy_state": enemy_state, "combat": null})
	_bind_hud_stage()
	_model.clear_outcome_transition_queued()
	_model.clear_pending_next_scene_path()
	_view_actions.hide_outcome_summary()
	_refresh_character_portraits()
	_refresh_build_icon_rows(progression_state.to_snapshot())
	_view_actions.show_boss_reward_summary("Boss defeated.")
	_view_actions.set_status_text("Boss defeated. Choose one boss relic before continuing.")
	_view_actions.set_status_color(_status_color_warning)
	_bind_debug_state_provider()
	_flow_mark("combat_initialize_boss_reward_overlay")


func _redirect_non_fight_step() -> void:
	var redirect_scene := String(_run_state.next_scene_path())
	if redirect_scene == "":
		return
	_flow_mark("combat_initialize_redirect_before_change_scene", {"source": "_initialize_combat_state"}, redirect_scene)
	var change_result: Variant = _run_state.flow_trace_change_scene(
		_host.get_tree(), redirect_scene, _route_id(), "combat._initialize_combat_state", "", _scene_rollback_callback()
	)
	if not _flow_result_utils.scene_change_succeeded(change_result):
		_handle_scene_change_failure(redirect_scene, change_result)


func _initialize_fight_state() -> void:
	var player_state: Variant = _run_state.ensure_player_state()
	var progression_state: Variant = _run_state.ensure_player_progression_state()
	player_state.set_mastery_level_provider(Callable(progression_state, "mastery_level"))
	var encounter: Dictionary = _run_state.current_encounter_snapshot()
	var enemy_state: Variant = _enemy_state_script.new()
	enemy_state.configure_from_blueprint(encounter)
	var combat: Variant = _combat_state_machine_script.new()
	combat.start_fight(player_state, enemy_state)
	_apply_state({"player_state": player_state, "progression_state": progression_state, "enemy_state": enemy_state, "combat": combat})
	_bind_hud_stage()
	_refresh_character_portraits()
	var content_errors: Array[Dictionary] = _run_state.validate_player_state_content()
	_model.clear_outcome_transition_queued()
	_model.clear_pending_next_scene_path()
	_view_actions.hide_outcome_summary()
	_update_hud()
	_clear_debug_log()
	_append_fight_start_log(encounter, player_state, enemy_state, content_errors)
	_bind_debug_state_provider()


func _append_fight_start_log(encounter: Dictionary, player_state: Variant, enemy_state: Variant, content_errors: Array[Dictionary]) -> void:
	_view_actions.append_combat_log("Run flow: %s" % _run_state.level_sequence_label())
	if String(encounter.get("step_key", "")) == "enemy_1":
		_view_actions.append_combat_log("Level %d boss preview: %s." % [_run_state.dungeon_level, _run_state.current_level_boss_name()])
	_view_actions.append_combat_log("Fight started: %s HP %d." % [enemy_state.display_name, enemy_state.max_hp])
	_view_actions.append_combat_log("Player start: HP %d/%d, Gold %d." % [player_state.current_hp, player_state.max_hp, player_state.gold])
	if content_errors.is_empty():
		_view_actions.append_combat_log("Milestone 5 content validation: OK.")
		return
	_view_actions.append_combat_log("Milestone 5 content validation: %d issue(s)." % content_errors.size())
	for error in content_errors:
		_view_actions.append_combat_log("  - [%s] %s" % [String(error.get("item_id", "?")), String(error.get("reason", "unknown"))])


func _apply_state(state: Dictionary) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_APPLY_STATE, Callable())
	if callback.is_valid():
		callback.call(state)


func _bind_hud_stage() -> void:
	var callback: Callable = _callbacks.get(CALLBACK_BIND_HUD_STAGE, Callable())
	if callback.is_valid():
		callback.call()


func _refresh_character_portraits() -> void:
	var callback: Callable = _callbacks.get(CALLBACK_REFRESH_CHARACTER_PORTRAITS, Callable())
	if callback.is_valid():
		callback.call()


func _refresh_build_icon_rows(snapshot: Dictionary) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_REFRESH_BUILD_ICON_ROWS, Callable())
	if callback.is_valid():
		callback.call(snapshot)


func _update_hud() -> void:
	var callback: Callable = _callbacks.get(CALLBACK_UPDATE_HUD, Callable())
	if callback.is_valid():
		callback.call()


func _clear_debug_log() -> void:
	var debug_runtime: Variant = _callbacks.get("debug_runtime")
	if debug_runtime != null:
		debug_runtime.clear_log()


func _bind_debug_state_provider() -> void:
	var callback: Callable = _callbacks.get(CALLBACK_BIND_DEBUG_STATE_PROVIDER, Callable())
	if callback.is_valid():
		callback.call()


func _flow_mark(step: String, details: Dictionary = {}, target_scene_override: String = "") -> void:
	_run_state.flow_trace_mark(step, details, _route_id(), target_scene_override)


func _route_id() -> String:
	var callback: Callable = _callbacks.get(CALLBACK_ROUTE_ID, Callable())
	if callback.is_valid():
		return String(callback.call())
	return ""


func _scene_rollback_callback() -> Callable:
	var callback: Variant = _callbacks.get(CALLBACK_SCENE_ROLLBACK, Callable())
	return callback as Callable if callback is Callable else Callable()


func _handle_scene_change_failure(redirect_scene: String, change_result: Variant) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_HANDLE_SCENE_CHANGE_FAILURE, Callable())
	if callback.is_valid():
		callback.call(redirect_scene, _route_id(), "combat._initialize_combat_state", change_result)
