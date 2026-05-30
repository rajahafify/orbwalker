extends RefCounted
class_name CombatDebugStateProvider

var _combat: Variant = null
var _enemy_state: Variant = null
var _player_state: Variant = null
var _board_model: Variant = null
var _board_controller: Variant = null
var _turn_log_presenter: Variant = null
var _input_phase_value: Callable = Callable()


func bind(context: Dictionary) -> void:
	_combat = context.get("combat", null)
	_enemy_state = context.get("enemy_state", null)
	_player_state = context.get("player_state", null)
	_board_model = context.get("board_model", null)
	_board_controller = context.get("board_controller", null)
	_turn_log_presenter = context.get("turn_log_presenter", null)
	var input_phase_callback: Variant = context.get("input_phase_value", Callable())
	if input_phase_callback is Callable:
		_input_phase_value = input_phase_callback as Callable
	else:
		_input_phase_value = Callable()


func callbacks() -> Dictionary:
	return {
		"combat_state": Callable(self, "combat_state"),
		"enemy_state": Callable(self, "enemy_state"),
		"player_hp": Callable(self, "player_hp"),
		"player_max_hp": Callable(self, "player_max_hp"),
		"player_armor": Callable(self, "player_armor"),
		"enemy_display_name": Callable(self, "enemy_display_name"),
		"enemy_hp": Callable(self, "enemy_hp"),
		"enemy_max_hp": Callable(self, "enemy_max_hp"),
		"enemy_turn_block": Callable(self, "enemy_turn_block"),
		"input_phase_value": Callable(self, "input_phase_value"),
		"format_intent": Callable(self, "format_intent"),
		"board_seed": Callable(self, "board_seed"),
		"board_debug_text": Callable(self, "board_debug_text"),
	}


func combat_state() -> Variant:
	return _combat


func enemy_state() -> Variant:
	return _enemy_state


func player_hp() -> int:
	return int(_player_state.current_hp if _player_state != null else 0)


func player_max_hp() -> int:
	return int(_player_state.max_hp if _player_state != null else 0)


func player_armor() -> int:
	return int(_player_state.armor if _player_state != null else 0)


func enemy_display_name() -> String:
	return String(_enemy_state.display_name if _enemy_state != null else "Unknown")


func enemy_hp() -> int:
	return int(_enemy_state.current_hp if _enemy_state != null else 0)


func enemy_max_hp() -> int:
	return int(_enemy_state.max_hp if _enemy_state != null else 0)


func enemy_turn_block() -> int:
	return int(_enemy_state.current_turn_block if _enemy_state != null else 0)


func input_phase_value() -> int:
	if _input_phase_value.is_valid():
		return int(_input_phase_value.call())
	return 0


func format_intent(intent: Dictionary) -> String:
	if _turn_log_presenter != null and _turn_log_presenter.has_method("format_intent"):
		return String(_turn_log_presenter.format_intent(intent))
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func board_seed() -> int:
	if _board_controller != null and _board_controller.has_method("board_seed"):
		return int(_board_controller.board_seed())
	return int(_board_model.rng_seed if _board_model != null else 0)


func board_debug_text() -> String:
	if _board_controller != null and _board_controller.has_method("board_debug_string"):
		return String(_board_controller.board_debug_string())
	return String(_board_model.to_debug_string() if _board_model != null else "")
