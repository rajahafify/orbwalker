extends RefCounted
class_name CombatHudStageCoordinator

const CALLBACK_UPDATE_HUD := "update_hud"

var _model: Variant = null
var _player_state: Variant = null
var _enemy_state: Variant = null
var _callbacks: Dictionary = {}


func bind(model: Variant, player_state: Variant, enemy_state: Variant, callbacks: Dictionary = {}) -> void:
	_model = model
	_player_state = player_state
	_enemy_state = enemy_state
	_callbacks = callbacks.duplicate()


func capture_values() -> Dictionary:
	if _player_state == null or _enemy_state == null:
		return {}
	return {
		"player_gold": int(_player_state.gold),
		"enemy_hp": int(_enemy_state.current_hp),
		"enemy_turn_block": int(_enemy_state.current_turn_block),
		"player_hp": int(_player_state.current_hp),
		"player_armor": int(_player_state.armor),
	}


func stage_enemy_damage_step(raw_damage: int) -> void:
	if _enemy_state == null or raw_damage <= 0 or not _is_hud_staging_active():
		return
	_model.stage_enemy_damage_step(raw_damage, int(_enemy_state.current_hp), int(_enemy_state.current_turn_block))
	_update_hud()


func staged_enemy_defeated() -> bool:
	if _enemy_state == null or _model == null or not _model.has_method("staged_hud_value"):
		return false
	return int(_model.staged_hud_value("enemy_hp", int(_enemy_state.current_hp))) <= 0


func stage_enemy_result() -> void:
	if _enemy_state == null or not _is_hud_staging_active():
		return
	_model.stage_enemy_result(int(_enemy_state.current_hp), int(_enemy_state.current_turn_block))
	_update_hud()


func stage_player_hp(value: int) -> void:
	if _player_state == null or not _is_hud_staging_active():
		return
	_model.stage_player_hp(value, int(_player_state.max_hp))
	_update_hud()


func stage_player_armor(value: int) -> void:
	if not _is_hud_staging_active():
		return
	_model.stage_player_armor(value)
	_update_hud()


func stage_player_block_step(blocked_by_armor: int) -> void:
	if blocked_by_armor <= 0 or not _is_hud_staging_active():
		return
	var current_player_armor := int(_player_state.armor if _player_state != null else 0)
	_model.stage_player_block_step(blocked_by_armor, current_player_armor)
	_update_hud()


func stage_gold(value: int) -> void:
	if not _is_hud_staging_active():
		return
	_model.stage_gold(value)
	_update_hud()


func stage_player_final() -> void:
	if _player_state == null or not _is_hud_staging_active():
		return
	_model.stage_player_final(int(_player_state.current_hp), int(_player_state.armor))
	_update_hud()


func _is_hud_staging_active() -> bool:
	return _model != null and _model.has_method("is_hud_staging_active") and bool(_model.is_hud_staging_active())


func _update_hud() -> void:
	var update_hud: Callable = _callbacks.get(CALLBACK_UPDATE_HUD, Callable())
	if update_hud.is_valid():
		update_hud.call()
