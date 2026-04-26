extends Node

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")

var player_state: PlayerState
var player_progression_state: PlayerProgressionState
var player_progression_service: PlayerProgressionService
var content_registry: ContentRegistry
var _player_state_content_errors: Array[Dictionary] = []


func _ready() -> void:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	ensure_player_progression_state()
	ensure_player_progression_service()
	validate_player_state_content()


func ensure_player_state() -> PlayerState:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	return player_state


func ensure_player_progression_state() -> PlayerProgressionState:
	if player_progression_state == null:
		player_progression_state = PLAYER_PROGRESSION_STATE_SCRIPT.new()
	return player_progression_state


func ensure_player_progression_service() -> PlayerProgressionService:
	if player_progression_service == null:
		player_progression_service = PLAYER_PROGRESSION_SERVICE_SCRIPT.new()
	return player_progression_service


func ensure_content_registry() -> ContentRegistry:
	if content_registry == null:
		content_registry = CONTENT_REGISTRY_SCRIPT.new()
	return content_registry


func validate_player_state_content() -> Array[Dictionary]:
	_player_state_content_errors = ensure_content_registry().validate_player_state_content()
	return _player_state_content_errors.duplicate(true)


func player_state_content_errors() -> Array[Dictionary]:
	return _player_state_content_errors.duplicate(true)


func progression_snapshot() -> Dictionary:
	return ensure_player_progression_state().to_snapshot()


func reset_run() -> void:
	ensure_player_state().reset_for_new_run()
	ensure_player_progression_state().reset_for_new_run()
	validate_player_state_content()
