extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 9 UI build: combat HUD, readable shop/inventory flow, and run summaries are now integrated for repeated playtesting."


func _on_start_fight_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")
