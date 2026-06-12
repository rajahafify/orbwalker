extends RefCounted
class_name CombatControllerSignalConnector

const CALLBACK_ON_RESOLVER_MATCH_FOUND := "on_resolver_match_found"
const CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVERED := "on_intent_damage_preview_hovered"
const CALLBACK_ON_INTENT_BLOCK_PREVIEW_HOVERED := "on_intent_block_preview_hovered"
const CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED := "on_intent_damage_preview_hover_ended"
const CALLBACK_ON_ENEMY_INTENT_BUBBLE_HOVERED := "on_enemy_intent_bubble_hovered"
const CALLBACK_ON_ENEMY_BLOCK_PREVIEW_HOVERED := "on_enemy_block_preview_hovered"

var _resolver: Variant = null
var _resolve_trace_logger: Variant = null
var _player_loadout_hud: Variant = null
var _loadout_command_handler: Variant = null
var _view: Variant = null
var _settings_command_handler: Variant = null
var _tutorial_end_command_handler: Variant = null
var _callbacks: Dictionary = {}


func bind(dependencies: Dictionary, callbacks: Dictionary) -> void:
	_resolver = dependencies.get("resolver")
	_resolve_trace_logger = dependencies.get("resolve_trace_logger")
	_player_loadout_hud = dependencies.get("player_loadout_hud")
	_loadout_command_handler = dependencies.get("loadout_command_handler")
	_view = dependencies.get("view")
	_settings_command_handler = dependencies.get("settings_command_handler")
	_tutorial_end_command_handler = dependencies.get("tutorial_end_command_handler")
	_callbacks = callbacks.duplicate()


func connect_all() -> void:
	connect_resolver_signals()
	connect_player_loadout_signals()
	connect_view_signals()


func connect_resolver_signals() -> void:
	if _resolver == null or _resolve_trace_logger == null:
		return
	_connect_once(_resolver, "match_found", _callback(CALLBACK_ON_RESOLVER_MATCH_FOUND))
	_connect_once(_resolver, "cells_cleared", Callable(_resolve_trace_logger, "on_resolver_cells_cleared"))
	_connect_once(_resolver, "gravity_applied", Callable(_resolve_trace_logger, "on_resolver_gravity_applied"))
	_connect_once(_resolver, "refill_applied", Callable(_resolve_trace_logger, "on_resolver_refill_applied"))
	_connect_once(_resolver, "cascade_step_complete", Callable(_resolve_trace_logger, "on_resolver_cascade_step_complete"))
	_connect_once(_resolver, "resolve_complete", Callable(_resolve_trace_logger, "on_resolver_complete"))


func connect_player_loadout_signals() -> void:
	if _player_loadout_hud == null or _loadout_command_handler == null:
		return
	_connect_once(_player_loadout_hud, "consumable_slot_selected", Callable(_loadout_command_handler, "try_use_consumable_slot"))
	_connect_once(_player_loadout_hud, "sell_slot_requested", Callable(_loadout_command_handler, "sell_slot_requested"))
	_connect_once(_player_loadout_hud, "intent_preview_hovered", _callback(CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVERED))
	_connect_once(_player_loadout_hud, "intent_block_preview_hovered", _callback(CALLBACK_ON_INTENT_BLOCK_PREVIEW_HOVERED))
	_connect_once(_player_loadout_hud, "intent_preview_hover_ended", _callback(CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED))


func connect_view_signals() -> void:
	if _view == null:
		return
	_connect_once(_view, "enemy_intent_bubble_hovered", _callback(CALLBACK_ON_ENEMY_INTENT_BUBBLE_HOVERED))
	_connect_once(_view, "enemy_block_preview_hovered", _callback(CALLBACK_ON_ENEMY_BLOCK_PREVIEW_HOVERED))
	_connect_once(_view, "intent_hover_ended", _callback(CALLBACK_ON_INTENT_DAMAGE_PREVIEW_HOVER_ENDED))
	if _tutorial_end_command_handler != null:
		_connect_once(_view, "tutorial_end_continue_pressed", Callable(_tutorial_end_command_handler, "continue_pressed"))
		_connect_once(_view, "tutorial_end_main_menu_pressed", Callable(_tutorial_end_command_handler, "main_menu_pressed"))
	if _settings_command_handler != null:
		_connect_once(_view, "settings_continue_pressed", Callable(_settings_command_handler, "continue_combat"))
		_connect_once(_view, "settings_new_run_pressed", Callable(_settings_command_handler, "start_new_run"))
		_connect_once(_view, "settings_main_menu_pressed", Callable(_settings_command_handler, "return_to_main_menu"))
		_connect_once(_view, "settings_speed_selected", Callable(_settings_command_handler, "select_speed"))
		_connect_once(_view, "settings_quality_selected", Callable(_settings_command_handler, "select_quality"))
		_connect_once(_view, "settings_reduced_motion_toggled", Callable(_settings_command_handler, "toggle_reduced_motion"))
		_connect_once(_view, "settings_game_juice_toggled", Callable(_settings_command_handler, "toggle_game_juice"))
		_connect_once(_view, "settings_game_juice_flag_toggled", Callable(_settings_command_handler, "toggle_game_juice_flag"))
		_connect_once(_view, "settings_defaults_reset", Callable(_settings_command_handler, "reset_feedback_settings"))


func _callback(callback_name: String) -> Callable:
	return _callbacks.get(callback_name, Callable())


func _connect_once(emitter: Object, signal_name: StringName, target: Callable) -> void:
	if emitter == null or not target.is_valid():
		return
	if not emitter.has_signal(signal_name):
		return
	if emitter.is_connected(signal_name, target):
		return
	emitter.connect(signal_name, target)
