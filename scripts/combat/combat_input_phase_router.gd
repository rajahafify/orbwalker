extends RefCounted
class_name CombatInputPhaseRouter

const PHASE_PLAYER_INPUT := 0
const PHASE_RESOLVING := 1
const PHASE_LOCKED_EXTERNAL := 2

const CALLBACK_CLEAR_HOVER_STATE := "clear_hover_state"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_SYNC_MODEL_STATE := "sync_model_state"
const CALLBACK_DRAG_ACTIVE := "drag_active"
const CALLBACK_ABORT_ACTIVE_DRAG := "abort_active_drag"

var _model: Variant = null
var _board_controller: Variant = null
var _callbacks: Dictionary = {}


func bind(context: Dictionary, callbacks: Dictionary = {}) -> void:
	_model = context.get("model", null)
	_board_controller = context.get("board_controller", null)
	_callbacks = callbacks.duplicate()


func set_phase(phase: int) -> void:
	if _model == null:
		return
	_model.set_input_phase(phase)
	var current_phase := int(_model.input_phase())
	if current_phase != PHASE_PLAYER_INPUT:
		_call(CALLBACK_CLEAR_HOVER_STATE)

	match current_phase:
		PHASE_PLAYER_INPUT:
			_set_board_input_enabled(true)
		PHASE_RESOLVING:
			_set_board_input_enabled(false)
		PHASE_LOCKED_EXTERNAL:
			_set_board_input_enabled(false)
			if _model.has_method("external_lock_reason") and String(_model.external_lock_reason()) != "":
				_call(CALLBACK_SET_STATUS_TEXT, ["Input locked: %s" % String(_model.external_lock_reason())])
	_call(CALLBACK_SYNC_MODEL_STATE)


func set_external_locked(locked: bool, reason: String = "") -> void:
	if _model == null:
		return
	_model.set_external_lock_reason(reason)
	if locked:
		if bool(_call(CALLBACK_DRAG_ACTIVE)):
			_call(CALLBACK_ABORT_ACTIVE_DRAG)
		set_phase(PHASE_LOCKED_EXTERNAL)
	else:
		set_phase(PHASE_PLAYER_INPUT)


func _set_board_input_enabled(enabled: bool) -> void:
	if _board_controller != null and _board_controller.has_method("set_input_enabled"):
		_board_controller.set_input_enabled(enabled)


func _call(name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(name, Callable())
	if callback.is_valid():
		return callback.callv(args)
	return null
