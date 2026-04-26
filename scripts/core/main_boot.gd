extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 8 started. Initial content pack is in progress: mastery cards and consumable scrolls are live, with equipment, relics, and content pools next."


func _on_start_fight_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")
