extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 7 started. Start a new 3-level run with boss previews, boss relic rewards, shops, and run summary endpoints."


func _on_start_fight_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")
