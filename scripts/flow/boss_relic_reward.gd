extends Control

@onready var _title_label: Label = %TitleLabel
@onready var _summary_label: Label = %SummaryLabel
@onready var _option_buttons: Array[Button] = [
	%OptionButton1,
	%OptionButton2,
	%OptionButton3,
]
@onready var _continue_button: Button = %ContinueButton


func _ready() -> void:
	if not RunState.run_active:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		return
	if not RunState.is_current_step_boss_reward():
		get_tree().call_deferred("change_scene_to_file", RunState.next_scene_path())
		return

	_title_label.text = "Boss Relic Reward - %s" % RunState.level_sequence_label()
	_summary_label.text = "Choose one relic reward before the next shop."
	_refresh_options()


func _refresh_options() -> void:
	var options: Array = RunState.boss_relic_reward_options_snapshot()
	_continue_button.disabled = false
	if options.is_empty():
		_summary_label.text = "%s\nNo relic options were generated. Continue to shop." % _summary_label.text.split("\n")[0]
		for button in _option_buttons:
			button.text = "No option"
			button.disabled = true
		return

	for index in _option_buttons.size():
		var button := _option_buttons[index]
		if index >= options.size():
			button.text = "No option"
			button.disabled = true
			continue
		var option: Dictionary = options[index]
		button.text = "%s (%s)" % [
			String(option.get("display_name", "Relic")),
			String(option.get("rarity", "common")),
		]
		button.disabled = false


func _pick_option(index: int) -> void:
	var result: Dictionary = RunState.claim_boss_relic_reward(index)
	if bool(result.get("ok", false)):
		var payload: Dictionary = result.get("result", {})
		if bool(payload.get("already_owned", false)):
			_summary_label.text = "Reward selected: %s (already owned). Continue to shop." % String(payload.get("display_name", "Relic"))
		else:
			_summary_label.text = "Claimed relic: %s. Continue to shop." % String(payload.get("display_name", "Relic"))
		_refresh_options()
		return
	_summary_label.text = "Failed to claim relic: %s" % String(result.get("reason", "unknown"))


func _on_option_button_1_pressed() -> void:
	_pick_option(0)


func _on_option_button_2_pressed() -> void:
	_pick_option(1)


func _on_option_button_3_pressed() -> void:
	_pick_option(2)


func _on_skip_button_pressed() -> void:
	var transition: Dictionary = RunState.advance_after_boss_reward()
	get_tree().change_scene_to_file(String(transition.get("next_scene", "res://scenes/main.tscn")))


func _on_continue_button_pressed() -> void:
	var transition: Dictionary = RunState.advance_after_boss_reward()
	get_tree().change_scene_to_file(String(transition.get("next_scene", "res://scenes/main.tscn")))
