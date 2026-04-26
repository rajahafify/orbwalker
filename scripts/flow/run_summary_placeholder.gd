extends Control

@onready var _summary_label: Label = %SummaryLabel


func _ready() -> void:
	_summary_label.text = "Run ended. This placeholder represents the Milestone 5 run summary transition."


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_new_run_button_pressed() -> void:
	RunState.reset_run()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
