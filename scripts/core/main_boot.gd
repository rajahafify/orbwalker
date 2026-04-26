extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 1 ready. Open board debug scene to validate generation and rendering."


func _on_start_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")
