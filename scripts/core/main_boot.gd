extends Control

@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_status_label.text = "Milestone 0 complete. Milestone 1 board foundation is next."


func _on_start_fight_button_pressed() -> void:
	_status_label.text = "Placeholder only. Build the fight scene in Milestone 1."
