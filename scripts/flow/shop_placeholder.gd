extends Control

@onready var _summary_label: Label = %SummaryLabel


func _ready() -> void:
	_summary_label.text = "Enemy defeated. This placeholder represents shop or boss reward transition for Milestone 5."


func _on_next_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
