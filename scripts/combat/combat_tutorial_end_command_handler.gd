extends RefCounted
class_name CombatTutorialEndCommandHandler

const CALLBACK_CURRENT_ROUTE_ID := "current_route_id"
const CALLBACK_CURRENT_TURN_INDEX := "current_turn_index"
const CALLBACK_SHOW_SHOP_DAMAGE_MODAL := "show_shop_damage_modal"
const CALLBACK_PLAY_SFX := "play_sfx"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_TRACE_AND_CHANGE_SCENE := "trace_and_change_scene"

const SCENE_MAIN_MENU := "res://scenes/main_menu.tscn"
const TRACE_SOURCE_MAIN_MENU := "tutorial_end_main_menu"
const TRACE_MARK_MAIN_MENU := "combat_before_change_scene_to_file_tutorial_end_main_menu"

var _run_state: Variant = null
var _tutorial_director: Variant = null
var _view: Variant = null
var _callbacks: Dictionary = {}
var _neutral_status_color := Color.WHITE


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_tutorial_director = dependencies.get("tutorial_director", null)
	_view = dependencies.get("view", null)
	_callbacks = callbacks.duplicate()
	_neutral_status_color = config.get("neutral_status_color", Color.WHITE)


func bind_for_combat_controller(
	run_state: Variant,
	tutorial_director: Variant,
	view: Variant,
	controller: Object,
	neutral_status_color: Color
) -> void:
	bind(
		{
			"run_state": run_state,
			"tutorial_director": tutorial_director,
			"view": view,
		},
		{
			CALLBACK_CURRENT_ROUTE_ID: Callable(controller, "_flow_trace_route_id_value"),
			CALLBACK_CURRENT_TURN_INDEX: Callable(controller, "_settings_current_turn_index"),
			CALLBACK_SHOW_SHOP_DAMAGE_MODAL: Callable(controller, "_show_shop_damage_tutorial_end_modal"),
			CALLBACK_PLAY_SFX: Callable(controller, "_audio_play_sfx"),
			CALLBACK_SET_STATUS_TEXT: Callable(controller, "_set_status_text"),
			CALLBACK_SET_STATUS_COLOR: Callable(controller, "_set_status_color"),
			CALLBACK_UPDATE_HUD: Callable(controller, "_update_hud"),
			CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(controller, "_trace_and_change_scene_to_target"),
		},
		{
			"neutral_status_color": neutral_status_color,
		}
	)


func continue_pressed() -> void:
	if _tutorial_director != null and _tutorial_director.has_method("advance_post_shop_step"):
		if String(_tutorial_director.advance_post_shop_step()) != "":
			_show_shop_damage_modal()
			_play_sfx("ui_accept")
			return
	_finish_tutorial_guidance()
	_hide_tutorial_end_modal()
	_play_sfx("ui_accept")
	_set_status_text("%s | Turn %d." % [_level_sequence_label(), _current_turn_index()])
	_set_status_color(_neutral_status_color)
	_update_hud()


func main_menu_pressed() -> void:
	if _tutorial_director != null and _tutorial_director.has_method("dismiss_end_choice"):
		_tutorial_director.dismiss_end_choice()
	_finish_tutorial_guidance()
	_hide_tutorial_end_modal()
	_play_sfx("ui_accept")
	_trace_and_change_scene(
		SCENE_MAIN_MENU,
		_current_route_id(),
		TRACE_SOURCE_MAIN_MENU,
		TRACE_MARK_MAIN_MENU
	)


func _finish_tutorial_guidance() -> void:
	if _run_state != null and _run_state.has_method("finish_tutorial_guidance"):
		_run_state.finish_tutorial_guidance()


func _hide_tutorial_end_modal() -> void:
	if _view != null and _view.has_method("hide_tutorial_end_modal"):
		_view.hide_tutorial_end_modal()


func _current_route_id() -> String:
	var current_route_id: Callable = _callbacks.get(CALLBACK_CURRENT_ROUTE_ID, Callable())
	if current_route_id.is_valid():
		return String(current_route_id.call())
	return ""


func _current_turn_index() -> int:
	var current_turn_index: Callable = _callbacks.get(CALLBACK_CURRENT_TURN_INDEX, Callable())
	if current_turn_index.is_valid():
		return int(current_turn_index.call())
	return 1


func _level_sequence_label() -> String:
	if _run_state != null and _run_state.has_method("level_sequence_label"):
		return String(_run_state.level_sequence_label())
	return "Combat"


func _show_shop_damage_modal() -> void:
	var show_shop_damage_modal: Callable = _callbacks.get(CALLBACK_SHOW_SHOP_DAMAGE_MODAL, Callable())
	if show_shop_damage_modal.is_valid():
		show_shop_damage_modal.call()


func _play_sfx(key: String) -> void:
	var play_sfx: Callable = _callbacks.get(CALLBACK_PLAY_SFX, Callable())
	if play_sfx.is_valid():
		play_sfx.call(key)


func _set_status_text(value: String) -> void:
	var set_status_text: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if set_status_text.is_valid():
		set_status_text.call(value)


func _set_status_color(value: Color) -> void:
	var set_status_color: Callable = _callbacks.get(CALLBACK_SET_STATUS_COLOR, Callable())
	if set_status_color.is_valid():
		set_status_color.call(value)


func _update_hud() -> void:
	var update_hud: Callable = _callbacks.get(CALLBACK_UPDATE_HUD, Callable())
	if update_hud.is_valid():
		update_hud.call()


func _trace_and_change_scene(scene_path: String, route_id: String, source: String, trace_mark: String) -> void:
	var trace_and_change_scene: Callable = _callbacks.get(CALLBACK_TRACE_AND_CHANGE_SCENE, Callable())
	if trace_and_change_scene.is_valid():
		trace_and_change_scene.call(scene_path, route_id, source, trace_mark)
