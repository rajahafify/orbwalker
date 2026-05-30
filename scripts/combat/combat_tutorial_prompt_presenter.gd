extends RefCounted
class_name CombatTutorialPromptPresenter

const TUTORIAL_DIRECTOR_SCRIPT := preload("res://scripts/combat/tutorial_director.gd")

var _host: Control = null
var _prompt_panel: Panel = null
var _prompt_label: Label = null
var _prompt_parent: Control = null
var _prompt_anchor := TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD


func bind(host: Control) -> void:
	_host = host


func show(message: String, prompt_anchor: String = TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD) -> void:
	_ensure_prompt()
	if _prompt_panel == null or _prompt_label == null:
		return
	_prompt_anchor = prompt_anchor
	_prompt_label.add_theme_font_size_override("font_size", _font_size_for_anchor(prompt_anchor))
	_prompt_label.text = message
	layout()
	_prompt_panel.visible = true


func hide() -> void:
	if _prompt_panel != null:
		_prompt_panel.visible = false
	_prompt_anchor = TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_ABOVE_BOARD


func is_visible() -> bool:
	return _prompt_panel != null and is_instance_valid(_prompt_panel) and _prompt_panel.visible


func layout() -> void:
	if _prompt_panel == null or _prompt_label == null or _host == null:
		return
	var parent_control := _prompt_parent if _prompt_parent != null and is_instance_valid(_prompt_parent) else _host
	var board_rect := Rect2(Vector2(276.0, 650.0), Vector2(528.0, 126.0))
	var board_panel := _host.get_node_or_null("CombatLayoutRoot/BoardPanel") as Control
	if board_panel != null and is_instance_valid(board_panel):
		var host_inverse := parent_control.get_global_transform().affine_inverse()
		var panel_rect: Rect2 = board_panel.get_global_rect()
		board_rect = Rect2(host_inverse * panel_rect.position, panel_rect.size)
	var width := minf(860.0, maxf(520.0, board_rect.size.x + 228.0)) if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM else minf(720.0, maxf(520.0, board_rect.size.x + 148.0))
	var height := 236.0 if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM else 96.0 if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BELOW_INTENT else 116.0
	var parent_width := maxf(parent_control.size.x, width + 56.0)
	var x := clampf(board_rect.get_center().x - width * 0.5, 28.0, maxf(28.0, parent_width - width - 28.0))
	var y := maxf(332.0, board_rect.position.y - height - 24.0)
	if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BELOW_INTENT:
		y = _prompt_below_intent_y(parent_control, board_rect, height)
	elif _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM:
		y = _prompt_bottom_y(parent_control, height)
	_prompt_panel.position = Vector2(x, y)
	_prompt_panel.size = Vector2(width, height)
	var label_margin_y := 18.0 if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM else 6.0 if _prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BELOW_INTENT else 10.0
	_prompt_label.position = Vector2(20.0, label_margin_y)
	_prompt_label.size = _prompt_panel.size - Vector2(40.0, label_margin_y * 2.0)


func prompt_panel() -> Panel:
	return _prompt_panel


func prompt_label() -> Label:
	return _prompt_label


func _ensure_prompt() -> void:
	if _prompt_panel != null and is_instance_valid(_prompt_panel):
		return
	if _host == null:
		return
	_prompt_parent = _host.get_node_or_null("CombatLayoutRoot") as Control
	if _prompt_parent == null:
		_prompt_parent = _host
	_prompt_panel = Panel.new()
	_prompt_panel.name = "TutorialSwapPrompt"
	_prompt_panel.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	_prompt_panel.z_index = 145
	_prompt_panel.add_theme_stylebox_override("panel", _prompt_style())
	_prompt_parent.add_child(_prompt_panel)

	_prompt_label = Label.new()
	_prompt_label.name = "TutorialSwapPromptLabel"
	_prompt_label.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER
	_prompt_label.vertical_alignment = VerticalAlignment.VERTICAL_ALIGNMENT_CENTER
	_prompt_label.autowrap_mode = TextServer.AutowrapMode.AUTOWRAP_WORD_SMART
	_prompt_label.clip_text = true
	_prompt_label.add_theme_font_size_override("font_size", 24)
	_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68, 1.0))
	_prompt_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	_prompt_label.add_theme_constant_override("outline_size", 3)
	_prompt_panel.add_child(_prompt_label)


func _prompt_below_intent_y(parent_control: Control, board_rect: Rect2, prompt_height: float) -> float:
	var intent_row := _host.get_node_or_null("CombatLayoutRoot/EnemyPanel/EnemyPanelRoot/IntentRow") as Control
	if intent_row != null and is_instance_valid(intent_row):
		var host_inverse := parent_control.get_global_transform().affine_inverse()
		var intent_rect: Rect2 = intent_row.get_global_rect()
		var local_intent_rect := Rect2(host_inverse * intent_rect.position, intent_rect.size)
		return local_intent_rect.end.y + 8.0
	return maxf(236.0, board_rect.position.y - prompt_height - 12.0)


func _prompt_bottom_y(parent_control: Control, prompt_height: float) -> float:
	var parent_height := maxf(parent_control.size.y, prompt_height + 56.0)
	var player_hud := _host.get_node_or_null("CombatLayoutRoot/PlayerHudSection") as Control
	if player_hud != null and is_instance_valid(player_hud):
		var host_inverse := parent_control.get_global_transform().affine_inverse()
		var player_rect: Rect2 = player_hud.get_global_rect()
		var local_player_rect := Rect2(host_inverse * player_rect.position, player_rect.size)
		return clampf(local_player_rect.position.y + 18.0, 28.0, parent_height - prompt_height - 28.0)
	return parent_height - prompt_height - 36.0


func _prompt_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.045, 0.065, 0.085, 0.96)
	style.border_color = Color(1.0, 0.72, 0.16, 0.98)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.45)
	style.shadow_size = 10
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _font_size_for_anchor(prompt_anchor: String) -> int:
	if prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BOTTOM:
		return 38
	if prompt_anchor == TUTORIAL_DIRECTOR_SCRIPT.PROMPT_ANCHOR_BELOW_INTENT:
		return 20
	return 24
