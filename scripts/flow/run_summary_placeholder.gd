extends Control

@onready var _summary_label: Label = %SummaryLabel
@onready var _title_label: Label = %TitleLabel


func _ready() -> void:
	var summary: Dictionary = RunState.run_summary_snapshot()
	var victory := bool(summary.get("victory", false))
	_title_label.text = "Victory Summary" if victory else "Defeat Summary"
	_summary_label.text = _format_summary(summary)


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_new_run_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.next_scene_path())


func _format_summary(summary: Dictionary) -> String:
	var equipment_slots: Array = summary.get("equipment_slots", [])
	var relic_ids: Array = summary.get("relic_ids", [])
	return "Result: %s\nLevel reached: %d\nMonsters defeated: %d\nBosses defeated: %d\nGold earned: %d (Final %d)\nCause: %s\nEquipped: %s\nRelics: %s" % [
		"Victory" if bool(summary.get("victory", false)) else "Defeat",
		int(summary.get("level_reached", 1)),
		maxi(0, int(summary.get("enemies_defeated", 0)) - int(summary.get("bosses_defeated", 0))),
		int(summary.get("bosses_defeated", 0)),
		int(summary.get("gold_earned", 0)),
		int(summary.get("final_gold", 0)),
		String(summary.get("cause", "Unknown")),
		_format_slots(equipment_slots),
		_format_ids(relic_ids),
	]


func _format_slots(values: Array) -> String:
	var parts: Array[String] = []
	for value in values:
		var text := String(value)
		parts.append(text if text != "" else "-")
	return "[" + ", ".join(parts) + "]"


func _format_ids(values: Array) -> String:
	if values.is_empty():
		return "-"
	var parts: Array[String] = []
	for value in values:
		parts.append(String(value))
	return "[" + ", ".join(parts) + "]"
