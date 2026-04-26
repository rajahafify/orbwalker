extends Control

@onready var _board_view: BoardView = %BoardView
@onready var _status_label: Label = %StatusLabel
@onready var _seed_input: LineEdit = %SeedInput
@onready var _use_seed_check: CheckBox = %UseSeedCheckBox

var _settings := BoardGenerationSettings.new()
var _board_state := BoardState.new()


func _ready() -> void:
	_seed_input.text = str(1337)
	_create_new_board()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_create_new_board()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_P:
			_print_board_state()
			get_viewport().set_input_as_handled()


func _on_regenerate_button_pressed() -> void:
	_create_new_board()


func _on_print_board_button_pressed() -> void:
	_print_board_state()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _create_new_board() -> void:
	var board_seed := _resolve_seed()
	_board_state.initialize(board_seed, _settings)
	_board_view.board_state = _board_state
	_status_label.text = "Seed: %d | Matches on spawn: %s" % [board_seed, str(_board_state.has_any_match())]


func _resolve_seed() -> int:
	if _use_seed_check.button_pressed:
		var parsed := _seed_input.text.to_int()
		return parsed
	return int(Time.get_ticks_usec())


func _print_board_state() -> void:
	var debug_text := _board_state.to_debug_string()
	print("\n[Board Debug] Seed=", _board_state.rng_seed)
	print(debug_text)
	_status_label.text = "Printed board for seed %d to output." % _board_state.rng_seed
