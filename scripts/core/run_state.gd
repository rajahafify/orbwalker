extends Node

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")

var player_state: PlayerState


func _ready() -> void:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()


func ensure_player_state() -> PlayerState:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	return player_state


func reset_run() -> void:
	ensure_player_state().reset_for_new_run()