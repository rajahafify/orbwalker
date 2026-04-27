extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 9 art integration: player-facing combat and shop are active. Debug scene is still available."


func _on_start_fight_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.next_scene_path())


func _on_debug_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")
