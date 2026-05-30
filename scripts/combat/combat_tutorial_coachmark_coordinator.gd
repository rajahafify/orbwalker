extends RefCounted
class_name CombatTutorialCoachmarkCoordinator

const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")

const CALLBACK_INPUT_PHASE_VALUE := "input_phase_value"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SET_STATUS_COLOR := "set_status_color"

var _run_state: Variant = null
var _combat: Variant = null
var _tutorial_director: Variant = null
var _view: Variant = null
var _board_view: Variant = null
var _board_controller: Variant = null
var _prompt_presenter: Variant = null
var _callbacks: Dictionary = {}
var _player_input_phase_value := 0
var _warning_status_color := Color.WHITE


func bind(dependencies: Dictionary, callbacks: Dictionary = {}, config: Dictionary = {}) -> void:
	_run_state = dependencies.get("run_state", null)
	_combat = dependencies.get("combat", null)
	_tutorial_director = dependencies.get("tutorial_director", null)
	_view = dependencies.get("view", null)
	_board_view = dependencies.get("board_view", null)
	_board_controller = dependencies.get("board_controller", null)
	_prompt_presenter = dependencies.get("prompt_presenter", null)
	_callbacks = callbacks.duplicate()
	_player_input_phase_value = int(config.get("player_input_phase_value", 0))
	_warning_status_color = config.get("warning_status_color", Color.WHITE)


func sync() -> void:
	var step := active_step()
	if step == TUTORIAL_DIRECTOR_SCRIPT.STEP_SHOP_DAMAGE:
		show_shop_damage_modal()
		return
	var tutorial_path := active_drag_path_for_step(step)
	if not tutorial_path.is_empty():
		_focus_tutorial_intent_for_step(step)
		_apply_tutorial_drag_coachmark(
			tutorial_path,
			_tutorial_director.prompt_message(step),
			_tutorial_director.prompt_anchor(step)
		)
		return
	if _view != null and _view.has_method("is_tutorial_end_modal_visible") and bool(_view.is_tutorial_end_modal_visible()):
		_view.hide_tutorial_end_modal()
	hide_coachmark()


func show_shop_damage_modal() -> void:
	hide_coachmark()
	if _view == null or not _view.has_method("show_tutorial_end_modal"):
		return
	var post_shop_step: String = _tutorial_director.post_shop_step() if _tutorial_director != null else TUTORIAL_DIRECTOR_SCRIPT.POST_SHOP_END
	_view.show_tutorial_end_modal(post_shop_step)
	if _tutorial_director != null:
		_set_status_text(_tutorial_director.end_modal_status_text(post_shop_step))
	_set_status_color(_warning_status_color)


func hide_coachmark() -> void:
	if _prompt_presenter != null and _prompt_presenter.has_method("hide"):
		_prompt_presenter.hide()
	_clear_tutorial_enemy_intent_focus()
	if _board_view != null and _board_view.has_method("clear_tutorial_hint"):
		_board_view.clear_tutorial_hint()
	if _board_controller != null:
		if _board_controller.has_method("clear_restricted_drag_path"):
			_board_controller.clear_restricted_drag_path()
		elif _board_controller.has_method("clear_restricted_swap"):
			_board_controller.clear_restricted_swap()


func active_drag_path() -> Array[Vector2i]:
	return active_drag_path_for_step(active_step())


func active_drag_path_for_step(step: String) -> Array[Vector2i]:
	if _tutorial_director == null:
		return []
	return _tutorial_director.drag_path_for_step(step)


func active_retry_status_text() -> String:
	if _tutorial_director == null:
		return ""
	return _tutorial_director.retry_status_text(active_step())


func active_step() -> String:
	if _tutorial_director == null or _run_state == null:
		return TUTORIAL_DIRECTOR_SCRIPT.STEP_NONE
	return _tutorial_director.active_step({
		"tutorial_run_active": _is_tutorial_run(),
		"fight_over": _combat == null or (_combat.has_method("is_fight_over") and bool(_combat.is_fight_over())),
		"input_is_player_input": _input_phase_value() == _player_input_phase_value,
		"dungeon_level": int(_run_state.dungeon_level),
		"step_key": String(_run_state.current_step_key),
		"turn_index": int(_combat.turn_index if _combat != null else 1),
		"progression_snapshot": _progression_snapshot(),
	})


func _apply_tutorial_drag_coachmark(path: Array[Vector2i], message: String, prompt_anchor: String) -> void:
	if path.is_empty():
		return
	var from_cell := path[0]
	var to_cell := path[path.size() - 1]
	if _board_view != null and _board_view.has_method("set_tutorial_hint"):
		_board_view.set_tutorial_hint(from_cell, to_cell, path)
	if _board_controller != null:
		if _board_controller.has_method("set_restricted_drag_path"):
			_board_controller.set_restricted_drag_path(path)
		elif path.size() >= 2 and _board_controller.has_method("set_restricted_swap"):
			_board_controller.set_restricted_swap(path[0], path[1])
	if _prompt_presenter != null and _prompt_presenter.has_method("show"):
		_prompt_presenter.show(message, prompt_anchor)


func _focus_tutorial_intent_for_step(step: String) -> void:
	if _tutorial_director == null:
		return
	match _tutorial_director.intent_focus_kind(step):
		"attack":
			_focus_tutorial_enemy_intent("attack")
		"block":
			_focus_tutorial_enemy_intent("block")


func _focus_tutorial_enemy_intent(kind: String) -> void:
	if _view == null:
		return
	if _view.has_method("set_tutorial_enemy_intent_focus"):
		_view.set_tutorial_enemy_intent_focus(kind)
	if _view.has_method("start_enemy_intent_hover_emphasis"):
		_view.start_enemy_intent_hover_emphasis(kind)


func _clear_tutorial_enemy_intent_focus() -> void:
	if _view == null:
		return
	if _view.has_method("clear_tutorial_enemy_intent_focus"):
		_view.clear_tutorial_enemy_intent_focus()
	elif _view.has_method("stop_enemy_intent_hover_emphasis"):
		_view.stop_enemy_intent_hover_emphasis()


func _is_tutorial_run() -> bool:
	return _run_state != null and _run_state.has_method("is_tutorial_run") and bool(_run_state.is_tutorial_run())


func _progression_snapshot() -> Dictionary:
	if _run_state != null and _run_state.has_method("progression_snapshot"):
		return _run_state.progression_snapshot()
	return {}


func _input_phase_value() -> int:
	var input_phase_value: Callable = _callbacks.get(CALLBACK_INPUT_PHASE_VALUE, Callable())
	if input_phase_value.is_valid():
		return int(input_phase_value.call())
	return _player_input_phase_value


func _set_status_text(value: String) -> void:
	var set_status_text: Callable = _callbacks.get(CALLBACK_SET_STATUS_TEXT, Callable())
	if set_status_text.is_valid():
		set_status_text.call(value)


func _set_status_color(value: Color) -> void:
	var set_status_color: Callable = _callbacks.get(CALLBACK_SET_STATUS_COLOR, Callable())
	if set_status_color.is_valid():
		set_status_color.call(value)
