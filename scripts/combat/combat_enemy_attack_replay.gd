extends RefCounted
class_name CombatEnemyAttackReplay

const CALLBACK_COMBAT_SPEED_DURATION := "combat_speed_duration"
const CALLBACK_WAIT_COMBAT_SPEED := "wait_combat_speed"
const CALLBACK_CAN_CONTINUE := "can_continue"
const CALLBACK_PLAY_ENEMY_ATTACK_SFX := "play_enemy_attack_sfx"

var _view: Variant = null
var _vfx_presenter: Variant = null
var _hud_stage_coordinator: Variant = null
var _callbacks: Dictionary = {}
var _turn_replay_step_seconds := 0.34


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_view = dependencies.get("view", null)
	_vfx_presenter = dependencies.get("vfx_presenter", null)
	_hud_stage_coordinator = dependencies.get("hud_stage_coordinator", null)
	_callbacks = callbacks.duplicate()
	_turn_replay_step_seconds = float(config.get("turn_replay_step_seconds", 0.34))


func replay(turn_log: Dictionary, player_target: Vector2, label_lifetime: float) -> void:
	if bool(turn_log.get("enemy_intent_skipped", false)):
		return
	var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
	var blocked_by_armor := int(enemy_attack.get("blocked_by_armor", 0))
	var hp_damage := int(enemy_attack.get("hp_damage", 0))
	if blocked_by_armor <= 0 and hp_damage <= 0:
		return
	var targets := _attack_targets(player_target)
	var player_impact_target: Vector2 = targets.get("player_impact_target", player_target)
	var cue_lifetime := _combat_speed_duration(0.24)
	var travel_lifetime := _combat_speed_duration(0.28)
	var impact_lifetime := _combat_speed_duration(0.34)
	var enemy_attack_router: Variant = _enemy_attack_router()
	if enemy_attack_router != null:
		enemy_attack_router.spawn_enemy_attack_cue(targets.get("enemy_source", Vector2.ZERO), cue_lifetime)
		enemy_attack_router.spawn_enemy_attack_travel(targets.get("enemy_source", Vector2.ZERO), player_impact_target, travel_lifetime)
	if blocked_by_armor > 0:
		await _replay_blocked_damage(blocked_by_armor, hp_damage, player_target, player_impact_target, impact_lifetime, label_lifetime)
		if hp_damage <= 0:
			return
	if hp_damage > 0:
		await _replay_hp_damage(hp_damage, player_target, player_impact_target, impact_lifetime, label_lifetime)
	_stage_player_final()


func _replay_blocked_damage(
	blocked_by_armor: int, hp_damage: int, player_target: Vector2, player_impact_target: Vector2, impact_lifetime: float, label_lifetime: float
) -> void:
	var enemy_attack_router: Variant = _enemy_attack_router()
	if _vfx_presenter != null:
		if enemy_attack_router != null:
			enemy_attack_router.spawn_enemy_attack_block_impact(player_impact_target, impact_lifetime, blocked_by_armor)
		_vfx_presenter.screen_nudge(blocked_by_armor, player_impact_target)
		_vfx_presenter.spawn_result_label("-%d Damage Blocked" % blocked_by_armor, player_target, "block", label_lifetime, Vector2(0, 18))
	_play_enemy_attack_sfx({"blocked_by_armor": blocked_by_armor, "hp_damage": 0})
	if _vfx_presenter != null:
		await _vfx_presenter.hit_stop(0.035)
	await _wait_combat_speed(_turn_replay_step_seconds)
	if not _can_continue():
		return
	if _hud_stage_coordinator != null:
		_hud_stage_coordinator.stage_player_block_step(blocked_by_armor)
	if hp_damage <= 0:
		_stage_player_final()


func _replay_hp_damage(hp_damage: int, player_target: Vector2, player_impact_target: Vector2, impact_lifetime: float, label_lifetime: float) -> void:
	var enemy_attack_router: Variant = _enemy_attack_router()
	if _vfx_presenter != null:
		if enemy_attack_router != null:
			enemy_attack_router.spawn_enemy_attack_hit_impact(player_impact_target, impact_lifetime, hp_damage)
		_vfx_presenter.screen_nudge(hp_damage + 2, player_impact_target)
		_vfx_presenter.spawn_result_label("-%d HP" % hp_damage, player_target, "damage", label_lifetime, Vector2(0, -54))
	_play_enemy_attack_sfx({"blocked_by_armor": 0, "hp_damage": hp_damage})
	if _vfx_presenter != null:
		await _vfx_presenter.hit_stop(0.045)
	await _wait_combat_speed(_turn_replay_step_seconds)
	if not _can_continue():
		return


func _attack_targets(player_target: Vector2) -> Dictionary:
	var enemy_source := Vector2.ZERO
	var player_impact_target := Vector2.ZERO
	if _view != null:
		enemy_source = _view.enemy_vfx_target_global(0.56)
		player_impact_target = _view.player_vfx_target_global(0.58)
	if player_impact_target == Vector2.ZERO:
		player_impact_target = player_target
	return {"enemy_source": enemy_source, "player_impact_target": player_impact_target}


func _enemy_attack_router() -> Variant:
	if _vfx_presenter == null or not _vfx_presenter.has_method("enemy_attack_router"):
		return null
	return _vfx_presenter.enemy_attack_router()


func _stage_player_final() -> void:
	if _hud_stage_coordinator != null:
		_hud_stage_coordinator.stage_player_final()


func _combat_speed_duration(base_seconds: float) -> float:
	var callback: Callable = _callbacks.get(CALLBACK_COMBAT_SPEED_DURATION, Callable())
	return float(callback.call(base_seconds)) if callback.is_valid() else base_seconds


func _wait_combat_speed(base_seconds: float) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_WAIT_COMBAT_SPEED, Callable())
	if callback.is_valid():
		await callback.call(base_seconds)


func _can_continue() -> bool:
	var callback: Callable = _callbacks.get(CALLBACK_CAN_CONTINUE, Callable())
	return bool(callback.call()) if callback.is_valid() else true


func _play_enemy_attack_sfx(result: Dictionary) -> void:
	var callback: Callable = _callbacks.get(CALLBACK_PLAY_ENEMY_ATTACK_SFX, Callable())
	if callback.is_valid():
		callback.call(result)
