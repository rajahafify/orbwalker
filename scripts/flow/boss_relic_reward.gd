extends Control

const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const RARITY_COLORS := {
	"common": Color(0.82, 0.75, 0.62, 1.0),
	"uncommon": Color(0.47, 0.86, 0.34, 1.0),
	"rare": Color(0.96, 0.40, 0.30, 1.0),
}

@onready var _title_label: Label = %TitleLabel
@onready var _run_progress_label: Label = %RunProgressLabel
@onready var _summary_label: Label = %SummaryLabel
@onready var _detail_label: Label = %DetailLabel
@onready var _option_buttons: Array[Button] = [
	%OptionButton1,
	%OptionButton2,
	%OptionButton3,
]
@onready var _continue_button: Button = %ContinueButton

var _visuals = VISUAL_REGISTRY_SCRIPT.new()

func _ready() -> void:
	if not RunState.run_active:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
		return
	if not RunState.is_current_step_boss_reward():
		get_tree().call_deferred("change_scene_to_file", RunState.next_scene_path())
		return

	_title_label.text = "Boss Relic Reward - %s" % RunState.level_sequence_label()
	_run_progress_label.text = "Run: %s" % RunState.level_sequence_label()
	_summary_label.text = "Choose one relic reward before the next shop."
	_detail_label.text = "Pick one relic reward. Boss preview: %s" % RunState.current_level_boss_name()
	_apply_button_chrome()
	_refresh_options()


func _refresh_options() -> void:
	var options: Array = RunState.boss_relic_reward_options_snapshot()
	_continue_button.disabled = false
	if options.is_empty():
		_summary_label.text = "%s\nNo relic options were generated. Continue to shop." % _summary_label.text.split("\n")[0]
		for button in _option_buttons:
			button.text = "No Option"
			button.icon = null
			button.tooltip_text = ""
			button.disabled = true
		return

	for index in _option_buttons.size():
		var button := _option_buttons[index]
		if index >= options.size():
			button.text = "No Option"
			button.icon = null
			button.tooltip_text = ""
			button.disabled = true
			continue
		var option: Dictionary = options[index]
		var rarity := String(option.get("rarity", "common")).to_lower()
		var rarity_color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
		var relic_id := String(option.get("id", ""))
		var content := RunState.ensure_content_registry().get_relic(relic_id)
		button.icon = _visuals.icon_for_key(String(content.get("icon_key", "")))
		button.text = "%s\n%s relic\n%s" % [
			String(option.get("display_name", "Relic")),
			rarity.capitalize(),
			String(content.get("description", "")),
		]
		button.tooltip_text = "%s\n%s" % [String(option.get("display_name", "Relic")), String(content.get("description", ""))]
		button.add_theme_color_override("font_color", rarity_color)
		button.disabled = false


func _pick_option(index: int) -> void:
	var result: Dictionary = RunState.claim_boss_relic_reward(index)
	if bool(result.get("ok", false)):
		var payload: Dictionary = result.get("result", {})
		if bool(payload.get("already_owned", false)):
			_summary_label.text = "Reward selected: %s (already owned)." % String(payload.get("display_name", "Relic"))
		else:
			_summary_label.text = "Claimed relic: %s." % String(payload.get("display_name", "Relic"))
		_detail_label.text = "Reward choice locked."
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


func _apply_button_chrome() -> void:
	for button in _option_buttons:
		button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.expand_icon = true
		button.add_theme_font_size_override("font_size", 18)
		button.add_theme_constant_override("h_separation", 12)
		button.add_theme_stylebox_override("normal", _panel_style(Color(0.08, 0.09, 0.12, 0.96), Color(0.58, 0.43, 0.20, 0.96)))
		button.add_theme_stylebox_override("hover", _panel_style(Color(0.13, 0.11, 0.08, 0.98), Color(0.80, 0.62, 0.26, 1.0)))
		button.add_theme_stylebox_override("pressed", _panel_style(Color(0.15, 0.12, 0.09, 0.98), Color(0.89, 0.72, 0.32, 1.0)))
		button.add_theme_stylebox_override("disabled", _panel_style(Color(0.05, 0.06, 0.07, 0.88), Color(0.24, 0.25, 0.29, 0.92)))
		button.add_theme_color_override("font_disabled_color", Color(0.55, 0.56, 0.60, 1.0))
	_continue_button.add_theme_stylebox_override("normal", _panel_style(Color(0.12, 0.30, 0.06, 0.96), Color(0.54, 0.78, 0.24, 1.0)))
	_continue_button.add_theme_stylebox_override("hover", _panel_style(Color(0.18, 0.40, 0.08, 0.98), Color(0.62, 0.85, 0.29, 1.0)))
	_continue_button.add_theme_stylebox_override("pressed", _panel_style(Color(0.14, 0.33, 0.07, 0.98), Color(0.50, 0.72, 0.22, 1.0)))
	_continue_button.add_theme_stylebox_override("disabled", _panel_style(Color(0.05, 0.06, 0.07, 0.88), Color(0.24, 0.25, 0.29, 0.92)))


func _panel_style(bg_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10.0
	style.content_margin_right = 10.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style
