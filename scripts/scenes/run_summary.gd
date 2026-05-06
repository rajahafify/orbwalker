extends Control

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

@onready var _summary_label: Label = %SummaryLabel
@onready var _title_label: Label = %TitleLabel
@onready var _center_container: CenterContainer = $CenterContainer
@onready var _panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var _content_box: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer
@onready var _new_run_button: Button = $CenterContainer/PanelContainer/VBoxContainer/NewRunButton
@onready var _main_menu_button: Button = $CenterContainer/PanelContainer/VBoxContainer/MainMenuButton
@onready var _achievement_toast: Control = %AchievementToast

const BACKGROUND_PATH := "res://resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png"

const COLOR_PANEL := Color(0.07, 0.055, 0.045, 0.94)
const COLOR_PANEL_EDGE := Color(0.86, 0.63, 0.24, 1.0)
const COLOR_CARD := Color(0.13, 0.105, 0.08, 0.94)
const COLOR_CARD_EDGE := Color(0.42, 0.30, 0.13, 1.0)
const COLOR_TEXT := Color(0.94, 0.88, 0.74, 1.0)
const COLOR_MUTED := Color(0.72, 0.66, 0.54, 1.0)
const COLOR_GOLD := Color(1.0, 0.77, 0.25, 1.0)
const COLOR_VICTORY := Color(1.0, 0.86, 0.36, 1.0)
const COLOR_DEFEAT := Color(0.95, 0.36, 0.32, 1.0)

var _is_transitioning := false


func _ready() -> void:
	var summary: Dictionary = RunState.run_summary_snapshot()
	var victory := bool(summary.get("victory", false))
	_apply_static_layout()
	_apply_summary(summary, victory)
	if victory:
		_consume_recent_unlocks_for_toast()
	else:
		_discard_recent_unlocks()


func _on_main_menu_button_pressed() -> void:
	_route_from_summary(false)


func _on_new_run_button_pressed() -> void:
	_route_from_summary(true)


func _route_from_summary(start_new_run: bool) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_set_action_buttons_disabled(true)
	var source := "run_summary.main_menu"
	var route_name := "final_summary_to_main_menu"
	var target_scene := "res://scenes/main_menu.tscn"
	var pre_run_state: Dictionary = {}
	var prepared_scene: Dictionary = {}
	if start_new_run:
		source = "run_summary.new_run"
		route_name = "final_summary_to_combat"
		target_scene = "res://scenes/combat.tscn"
	var route_id := RunState.flow_trace_begin(route_name, target_scene, {"source": source})
	if start_new_run:
		prepared_scene = RunState.flow_trace_prepare_scene(target_scene, route_id, source)
		if not bool(prepared_scene.get("ok", false)):
			var prepare_failure := _scene_change_failure_reason(prepared_scene)
			push_error("Final summary prepare failed: %s -> %s (%s)" % [source, target_scene, prepare_failure])
			_summary_label.text = "Transition failed: %s" % prepare_failure
			_summary_label.add_theme_color_override("font_color", COLOR_DEFEAT)
			_is_transitioning = false
			_set_action_buttons_disabled(false)
			return
		pre_run_state = RunState.snapshot_run_transition_state()
		if not pre_run_state.is_empty():
			prepared_scene["rollback_snapshot"] = pre_run_state
		prepared_scene["post_ready_failure_callback"] = _on_new_run_post_ready_rollback
		RunState.flow_trace_mark("final_summary_before_start_new_run", {"source": source}, route_id, target_scene)
		RunState.start_new_run()
		RunState.flow_trace_mark("final_summary_after_start_new_run", {"source": source}, route_id, target_scene)
		target_scene = RunState.next_scene_path()
	RunState.flow_trace_mark("final_summary_before_change_scene", {"source": source}, route_id, target_scene)
	var transition_result: Variant
	if start_new_run:
		transition_result = RunState.flow_trace_attach_prepared_scene(get_tree(), prepared_scene, target_scene, route_id, source)
	else:
		transition_result = RunState.flow_trace_change_scene(
			get_tree(),
			target_scene,
			route_id,
			source,
			"",
			_on_summary_post_ready_rollback
		)
	if _scene_change_succeeded(transition_result):
		return
	if start_new_run and not pre_run_state.is_empty():
		RunState.restore_run_transition_state(pre_run_state)
	var failure := _scene_change_failure_reason(transition_result)
	push_error("Final summary transition failed: %s -> %s (%s)" % [source, target_scene, failure])
	_summary_label.text = "Transition failed: %s" % failure
	_summary_label.add_theme_color_override("font_color", COLOR_DEFEAT)
	_is_transitioning = false
	_set_action_buttons_disabled(false)


func _on_new_run_post_ready_rollback(result: Dictionary) -> void:
	_on_post_ready_rollback(result)


func _on_summary_post_ready_rollback(result: Dictionary) -> void:
	_on_post_ready_rollback(result)


func _on_post_ready_rollback(result: Dictionary) -> void:
	_is_transitioning = false
	_set_action_buttons_disabled(false)
	var failure_reason := String(result.get("reason", "prepared_scene_post_ready_check_failed"))
	if _summary_label != null and is_instance_valid(_summary_label):
		_summary_label.text = "Transition failed: %s" % failure_reason
		_summary_label.add_theme_color_override("font_color", COLOR_DEFEAT)


func _set_action_buttons_disabled(disabled: bool) -> void:
	if _new_run_button != null:
		_new_run_button.disabled = disabled
	if _main_menu_button != null:
		_main_menu_button.disabled = disabled


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	return int(result) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	return "error_code_%d" % int(result)


func _apply_static_layout() -> void:
	var background := TextureRect.new()
	background.name = "SummaryBackground"
	background.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	background.texture = load(BACKGROUND_PATH)
	background.modulate = Color(0.52, 0.48, 0.42, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	add_child(background)
	move_child(background, 0)

	var scrim := ColorRect.new()
	scrim.name = "SummaryScrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT as Control.LayoutPreset)
	scrim.color = Color(0.02, 0.018, 0.014, 0.54)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	add_child(scrim)
	move_child(scrim, 1)

	_center_container.custom_minimum_size = Vector2(1080, 1920)
	_panel_container.custom_minimum_size = Vector2(860, 1160)
	_panel_container.add_theme_stylebox_override("panel", UI_UTILS.panel_style(COLOR_PANEL, COLOR_PANEL_EDGE, 5, 22, Vector4(24, 20, 24, 20)))
	_content_box.custom_minimum_size = Vector2(760, 1020)
	_content_box.add_theme_constant_override("separation", 18)
	_content_box.add_theme_constant_override("margin_left", 34)
	_content_box.add_theme_constant_override("margin_right", 34)
	_content_box.add_theme_constant_override("margin_top", 34)
	_content_box.add_theme_constant_override("margin_bottom", 34)

	_title_label.add_theme_font_size_override("font_size", 62)
	_title_label.add_theme_color_override("font_color", COLOR_VICTORY)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment

	_summary_label.add_theme_font_size_override("font_size", 28)
	_summary_label.add_theme_color_override("font_color", COLOR_MUTED)
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode

	_style_action_button(_new_run_button, true)
	_style_action_button(_main_menu_button, false)


func _apply_summary(summary: Dictionary, victory: bool) -> void:
	_title_label.text = "VICTORY" if victory else "DEFEAT"
	_title_label.add_theme_color_override("font_color", COLOR_VICTORY if victory else COLOR_DEFEAT)
	_summary_label.text = _summary_subtitle(summary, victory)

	var button_parent := _new_run_button.get_parent()
	button_parent.remove_child(_new_run_button)
	button_parent.remove_child(_main_menu_button)

	_content_box.add_child(_make_spacer(8))
	_content_box.add_child(_make_stats_grid(summary))
	_content_box.add_child(_make_loadout_section("Equipment", _format_named_slots(summary.get("equipment_slots", []))))
	_content_box.add_child(_make_loadout_section("Relics", _format_named_ids(summary.get("relic_ids", []))))
	_content_box.add_child(_make_action_row())


func _summary_subtitle(summary: Dictionary, victory: bool) -> String:
	if victory:
		return "Final boss defeated. Prototype run cleared."
	var cause := String(summary.get("cause", "Run ended."))
	return cause


func _make_stats_grid(summary: Dictionary) -> GridContainer:
	var grid := GridContainer.new()
	grid.name = "SummaryStats"
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 18)
	var bosses_killed := int(summary.get("bosses_defeated", 0))
	var monsters_killed := maxi(0, int(summary.get("enemies_defeated", 0)) - bosses_killed)
	_add_stat_card(grid, "LEVEL", "%d / %d" % [int(summary.get("level_reached", 1)), RunState.MAX_DUNGEON_LEVELS])
	_add_stat_card(grid, "MONSTERS", str(monsters_killed))
	_add_stat_card(grid, "BOSSES", str(bosses_killed))
	_add_stat_card(grid, "GOLD EARNED", "+%d" % int(summary.get("gold_earned", 0)), COLOR_GOLD)
	_add_stat_card(grid, "FINAL GOLD", str(int(summary.get("final_gold", 0))), COLOR_GOLD)
	_add_stat_card(grid, "RESULT", "CLEAR" if bool(summary.get("victory", false)) else "FALLEN")
	return grid


func _add_stat_card(parent: GridContainer, label_text: String, value_text: String, value_color: Color = COLOR_TEXT) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(368, 118)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", UI_UTILS.panel_style(COLOR_CARD, COLOR_CARD_EDGE, 3, 14, Vector4(24, 20, 24, 20)))
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER as BoxContainer.AlignmentMode
	box.add_theme_constant_override("separation", 3)
	card.add_child(box)
	var label := Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", COLOR_MUTED)
	box.add_child(label)
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	value.add_theme_font_size_override("font_size", 42)
	value.add_theme_color_override("font_color", value_color)
	box.add_child(value)
	parent.add_child(card)


func _make_loadout_section(title: String, values: Array[String]) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "%sSection" % title.replace(" ", "")
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.095, 0.078, 0.06, 0.92), COLOR_CARD_EDGE, 2, 12, Vector4(24, 20, 24, 20)))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 9)
	panel.add_child(box)
	var heading := Label.new()
	heading.text = title.to_upper()
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", COLOR_GOLD)
	box.add_child(heading)
	var body := Label.new()
	body.text = "\n".join(values)
	body.add_theme_font_size_override("font_size", 28)
	body.add_theme_color_override("font_color", COLOR_TEXT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	box.add_child(body)
	return panel


func _make_action_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "SummaryActions"
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 18)
	row.add_child(_new_run_button)
	row.add_child(_main_menu_button)
	return row


func _format_named_slots(values: Array) -> Array[String]:
	var parts: Array[String] = []
	for index in values.size():
		var value := String(values[index])
		parts.append("%d. %s" % [index + 1, value if value != "" else "Empty"])
	return parts


func _format_named_ids(values: Array) -> Array[String]:
	if values.is_empty():
		return ["None claimed"]
	var parts: Array[String] = []
	for value in values:
		parts.append(_title_case_id(String(value)))
	return parts


func _title_case_id(value: String) -> String:
	var words := value.replace("_", " ").split(" ", false)
	for index in words.size():
		words[index] = String(words[index]).capitalize()
	return " ".join(words)


func _style_action_button(button: Button, primary: bool) -> void:
	button.custom_minimum_size = Vector2(0, 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color(0.08, 0.055, 0.025, 1.0) if primary else COLOR_TEXT)
	var normal_color := Color(0.95, 0.68, 0.20, 1.0) if primary else Color(0.16, 0.13, 0.10, 1.0)
	var edge_color := Color(1.0, 0.86, 0.42, 1.0) if primary else COLOR_CARD_EDGE
	button.add_theme_stylebox_override("normal", UI_UTILS.panel_style(normal_color, edge_color, 3, 12, Vector4(24, 20, 24, 20)))
	button.add_theme_stylebox_override("hover", UI_UTILS.panel_style(normal_color.lightened(0.08), edge_color.lightened(0.1), 3, 12, Vector4(24, 20, 24, 20)))
	button.add_theme_stylebox_override("pressed", UI_UTILS.panel_style(normal_color.darkened(0.12), edge_color, 3, 12, Vector4(24, 20, 24, 20)))


func _make_spacer(height: int) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, height)
	return spacer


func _consume_recent_unlocks_for_toast() -> void:
	if _achievement_toast == null:
		return
	var entries: Array[Dictionary] = _normalize_unlock_entries(_consume_recent_unlock_payload())
	if entries.is_empty():
		return
	if _achievement_toast.has_method("enqueue_unlock_entries"):
		_achievement_toast.call("enqueue_unlock_entries", entries)
		return
	if _achievement_toast.has_method("enqueue_unlock"):
		for entry in entries:
			var display_name := String(entry.get("display_name", entry.get("item_name", entry.get("item_id", "Unknown Item"))))
			_achievement_toast.call("enqueue_unlock", display_name)


func _consume_recent_unlock_payload() -> Variant:
	for method_name in ["consume_recent_equipment_unlocks", "consume_recent_unlocks", "consume_recent_meta_unlocks"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name)
	return []


func _discard_recent_unlocks() -> void:
	_consume_recent_unlock_payload()


func _normalize_unlock_entries(payload: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if payload is Array:
		for entry in payload as Array:
			if entry is Dictionary:
				out.append((entry as Dictionary).duplicate(true))
			elif entry is String:
				out.append({"item_id": String(entry), "display_name": _title_case_id(String(entry))})
		return out
	if payload is Dictionary:
		var typed_payload := payload as Dictionary
		for key in ["unlocks", "recent_unlocks", "recent_equipment_unlocks"]:
			if typed_payload.has(key):
				return _normalize_unlock_entries(typed_payload.get(key, []))
	return out
