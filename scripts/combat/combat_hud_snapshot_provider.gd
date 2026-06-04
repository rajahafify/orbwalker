extends RefCounted
class_name CombatHudSnapshotProvider

const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")

var _run_state: Variant
var _model: Variant
var _player_state: Variant
var _enemy_state: Variant
var _combat: Variant
var _view: Variant
var _visuals: Variant
var _turn_log_presenter: Variant
var _input_phase_value: Callable
var _drag_active: Callable
var _drag_move_time_left: Callable
var _timer_ready_seconds: Callable
var _show_intent_preview: Callable
var _player_input_phase_value := 0


func bind(dependencies: Dictionary, callbacks: Dictionary, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state")
	_model = dependencies.get("model")
	_player_state = dependencies.get("player_state")
	_enemy_state = dependencies.get("enemy_state")
	_combat = dependencies.get("combat")
	_view = dependencies.get("view")
	_visuals = dependencies.get("visuals")
	_turn_log_presenter = dependencies.get("turn_log_presenter")
	_input_phase_value = callbacks.get("input_phase_value", Callable())
	_drag_active = callbacks.get("drag_active", Callable())
	_drag_move_time_left = callbacks.get("drag_move_time_left", Callable())
	_timer_ready_seconds = callbacks.get("timer_ready_seconds", Callable())
	_show_intent_preview = callbacks.get("show_intent_preview", Callable())
	_player_input_phase_value = int(config.get("player_input_phase_value", 0))


func build_snapshot() -> Dictionary:
	if _run_state == null or _model == null or _player_state == null or _enemy_state == null or _combat == null:
		return {}
	var progression_snapshot: Dictionary = _run_state.progression_snapshot()
	var intent: Dictionary = _enemy_state.get_current_intent()
	var timer_seconds := _drag_move_time_left_seconds() if _is_drag_active() else _ready_timer_seconds()
	var turn_summary_text := ""
	if _view != null:
		turn_summary_text = _view.turn_summary_text()
	var enemy_stage_texture: Texture2D = null
	var enemy_portrait_texture := _enemy_portrait_texture()
	if _visuals != null:
		enemy_stage_texture = _visuals.combat_enemy_stage_texture(_enemy_state.enemy_id)
	var player_gold: int = _staged_hud_value("player_gold", int(_player_state.gold))
	var enemy_hp: int = _staged_hud_value("enemy_hp", int(_enemy_state.current_hp))
	var enemy_turn_block: int = _staged_hud_value("enemy_turn_block", int(_enemy_state.current_turn_block))
	var player_hp: int = _staged_hud_value("player_hp", int(_player_state.current_hp))
	var player_armor: int = _staged_hud_value("player_armor", int(_player_state.armor))
	return {
		"progression_snapshot": progression_snapshot,
		"intent": intent,
		"show_intent_preview": _should_show_intent_preview(),
		"dungeon_level": int(_run_state.dungeon_level),
		"max_dungeon_levels": int(_run_state.MAX_DUNGEON_LEVELS),
		"current_step_key": String(_run_state.current_step_key),
		"player_gold": player_gold,
		"enemy_id": String(_enemy_state.enemy_id),
		"enemy_name_text": _enemy_state.display_name,
		"enemy_hp": enemy_hp,
		"enemy_max_hp": int(_enemy_state.max_hp),
		"enemy_turn_block": enemy_turn_block,
		"enemy_stage_texture": enemy_stage_texture,
		"enemy_portrait_texture": enemy_portrait_texture,
		"combat_turn_index": int(_combat.turn_index),
		"combat_phase_name": _combat.phase_name(),
		"is_player_input_phase": _input_phase() == _player_input_phase_value,
		"drag_active": _is_drag_active(),
		"timer_seconds": timer_seconds,
		"player_hp": player_hp,
		"player_max_hp": int(_player_state.max_hp),
		"player_armor": player_armor,
		"fire_orb_value": int(_player_state.orb_value(OrbType.Id.FIRE)),
		"armor_orb_value": int(_player_state.orb_value(OrbType.Id.ARMOR)),
		"heart_orb_id": int(OrbType.Id.HEART),
		"gold_orb_id": int(OrbType.Id.GOLD),
		"turn_summary_text": turn_summary_text,
		"format_intent_compact": Callable(_turn_log_presenter, "format_intent_compact") if _turn_log_presenter != null else Callable(),
	}


func _enemy_portrait_texture() -> Texture2D:
	var enemy_portrait_texture: Texture2D = null
	if _visuals != null:
		enemy_portrait_texture = _visuals.enemy_sprite(_enemy_state.enemy_id)
	if enemy_portrait_texture == null and _visuals != null:
		enemy_portrait_texture = _visuals.enemy_sprite("cavern_striker")
	if enemy_portrait_texture == null:
		enemy_portrait_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	return enemy_portrait_texture


func _staged_hud_value(key: String, fallback_value: int) -> int:
	return int(_model.staged_hud_value(key, fallback_value))


func _input_phase() -> int:
	if _input_phase_value.is_valid():
		return int(_input_phase_value.call())
	return 0


func _is_drag_active() -> bool:
	return _drag_active.is_valid() and bool(_drag_active.call())


func _drag_move_time_left_seconds() -> float:
	if _drag_move_time_left.is_valid():
		return float(_drag_move_time_left.call())
	return 0.0


func _ready_timer_seconds() -> float:
	if _timer_ready_seconds.is_valid():
		return float(_timer_ready_seconds.call())
	return 0.0


func _should_show_intent_preview() -> bool:
	return _show_intent_preview.is_valid() and bool(_show_intent_preview.call())
