extends RefCounted
class_name CombatBoardDebugCommandHandler

const CALLBACK_SET_INPUT_PHASE := "set_input_phase"
const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_APPEND_COMBAT_LOG := "append_combat_log"
const CALLBACK_SYNC_TUTORIAL_COACHMARK := "sync_tutorial_coachmark"

var _board_controller: Variant = null
var _board_model: Variant = null
var _settings: Variant = null
var _combat: Variant = null
var _run_state: Variant = null
var _player_input_phase_value := 0
var _print_to_stdout := true
var _callbacks: Dictionary = {}


func bind(context: Dictionary, callbacks: Dictionary = {}) -> void:
	_board_controller = context.get("board_controller", null)
	_board_model = context.get("board_model", null)
	_settings = context.get("settings", null)
	_combat = context.get("combat", null)
	_run_state = context.get("run_state", null)
	_player_input_phase_value = int(context.get("player_input_phase_value", _player_input_phase_value))
	_print_to_stdout = bool(context.get("print_to_stdout", true))
	_callbacks = callbacks


func create_new_board() -> Dictionary:
	var board_seed := _resolve_seed()
	var result := set_board_seed(board_seed)
	if not bool(result.get("ok", false)):
		return result
	if _combat != null and not _combat.is_fight_over():
		_set_status_text("Seed: %d | Turn %d ready." % [board_seed, int(_combat.turn_index)])
	else:
		_set_status_text("Seed: %d | Fight complete." % board_seed)
	_call(CALLBACK_SYNC_TUTORIAL_COACHMARK)
	return result


func set_board_seed(board_seed: int) -> Dictionary:
	if _board_controller == null:
		push_error("CombatBoardDebugCommandHandler.set_board_seed called before BoardController was bound.")
		return {"ok": false, "reason": "board_controller_missing", "board_model": _board_model}
	_board_controller.abort()
	_board_controller.clear_board_presentation()
	_board_controller.initialize_board(board_seed, _settings)
	_board_model = _board_controller.current_board_model()
	if _combat != null and not _combat.is_fight_over():
		_call(CALLBACK_SET_INPUT_PHASE, [_player_input_phase_value])
	return {"ok": true, "seed": board_seed, "board_model": _board_model}


func print_board_model() -> Dictionary:
	var board_data := board_debug_data()
	var board_seed := int(board_data.get("seed", 0))
	var debug_text := String(board_data.get("debug_text", ""))
	if _print_to_stdout:
		print("\n[Board Debug] Seed=", board_seed)
		print(debug_text)
	_append_board_model_to_console(board_seed, debug_text)
	_set_status_text("Printed board for seed %d to output." % board_seed)
	return board_data


func board_debug_data() -> Dictionary:
	if _board_controller != null:
		return {
			"seed": int(_board_controller.board_seed()),
			"debug_text": String(_board_controller.board_debug_string()),
		}
	return {
		"seed": int(_board_model.rng_seed if _board_model != null else 0),
		"debug_text": String(_board_model.to_debug_string() if _board_model != null else ""),
	}


func _resolve_seed() -> int:
	if (
		_run_state != null
		and _run_state.has_method("is_tutorial_run")
		and _run_state.has_method("tutorial_board_seed_for_turn")
		and _run_state.is_tutorial_run()
	):
		var tutorial_seed := int(_run_state.tutorial_board_seed_for_turn(_combat.turn_index if _combat != null else 1))
		if tutorial_seed > 0:
			return tutorial_seed
	return int(Time.get_ticks_usec())


func _append_board_model_to_console(board_seed: int, board_debug_text: String) -> void:
	_call(CALLBACK_APPEND_COMBAT_LOG, ["Board seed: %d" % board_seed])
	var lines: PackedStringArray = board_debug_text.split("\n", false)
	for line in lines:
		_call(CALLBACK_APPEND_COMBAT_LOG, ["  %s" % line])


func _set_status_text(message: String) -> void:
	_call(CALLBACK_SET_STATUS_TEXT, [message])


func _call(name: String, args: Array = []) -> Variant:
	var callback: Callable = _callbacks.get(name, Callable())
	if callback.is_valid():
		return callback.callv(args)
	return null
