extends RefCounted
class_name CombatOutcomeOverlay

const OUTCOME_SUMMARY_RECT := Rect2(Vector2(144, 168), Vector2(760, 452))
const BOSS_REWARD_SUMMARY_RECT := Rect2(Vector2(56, 390), Vector2(968, 860))
const BOSS_REWARD_CARD_GAP := 16.0
const BOSS_REWARD_ROW_TOP := 136.0
const BOSS_REWARD_CARD_HEIGHT := 142.0
const BOSS_REWARD_ICON_SIZE := Vector2(104, 104)
const BOSS_REWARD_SKIP_BUTTON_SIZE := Vector2(190, 58)
const BOSS_REWARD_NEXT_BUTTON_SIZE := Vector2(420, 72)
const OUTCOME_MODAL_Z_INDEX := 180
const OUTCOME_SCRIM_Z_INDEX := 170
const OUTCOME_BOSS_SCRIM_COLOR := Color(0.0, 0.0, 0.0, 0.62)
const OUTCOME_BUTTON_FONT_SIZE := 24
const BOSS_REWARD_NAME_FONT_SIZE := 30
const BOSS_REWARD_RARITY_FONT_SIZE := 20
const BOSS_REWARD_DESCRIPTION_FONT_SIZE := 22

var _layout_root: Control
var _outcome_summary_panel: Panel
var _outcome_summary_root: Control
var _outcome_text_column: Control
var _outcome_title_label: Label
var _outcome_body_label: Label
var _next_button: Button

var _boss_reward_buttons: Array[Button] = []
var _boss_reward_skip_button: Button
var _boss_reward_pending := false
var _boss_reward_overlay_active := false
var _boss_reward_selected_index := -1
var _outcome_scrim: ColorRect

var _config: Dictionary = {}


static func default_config() -> Dictionary:
	return {
		"outcome_summary_rect": OUTCOME_SUMMARY_RECT,
		"boss_reward_summary_rect": BOSS_REWARD_SUMMARY_RECT,
		"boss_reward_card_gap": BOSS_REWARD_CARD_GAP,
		"boss_reward_row_top": BOSS_REWARD_ROW_TOP,
		"boss_reward_card_height": BOSS_REWARD_CARD_HEIGHT,
		"boss_reward_icon_size": BOSS_REWARD_ICON_SIZE,
		"boss_reward_skip_button_size": BOSS_REWARD_SKIP_BUTTON_SIZE,
		"boss_reward_next_button_size": BOSS_REWARD_NEXT_BUTTON_SIZE,
		"outcome_modal_z_index": OUTCOME_MODAL_Z_INDEX,
		"outcome_scrim_z_index": OUTCOME_SCRIM_Z_INDEX,
		"outcome_boss_scrim_color": OUTCOME_BOSS_SCRIM_COLOR,
	}


static func readability_font_probe() -> Dictionary:
	return {
		"outcome_button": OUTCOME_BUTTON_FONT_SIZE,
		"boss_reward_name": BOSS_REWARD_NAME_FONT_SIZE,
		"boss_reward_rarity": BOSS_REWARD_RARITY_FONT_SIZE,
		"boss_reward_description": BOSS_REWARD_DESCRIPTION_FONT_SIZE,
	}


func bind(nodes: Dictionary, config: Dictionary = {}) -> void:
	_layout_root = nodes.get("layout_root") as Control
	_outcome_summary_panel = nodes.get("summary_panel") as Panel
	_outcome_summary_root = nodes.get("summary_root") as Control
	_outcome_text_column = nodes.get("text_column") as Control
	_outcome_title_label = nodes.get("title_label") as Label
	_outcome_body_label = nodes.get("body_label") as Label
	_next_button = nodes.get("next_button") as Button
	_config = default_config()
	for key in config.keys():
		_config[key] = config[key]


func is_boss_reward_pending() -> bool:
	return _boss_reward_pending


func is_boss_reward_overlay_active() -> bool:
	return _boss_reward_overlay_active


func set_boss_reward_pending(pending: bool) -> void:
	_boss_reward_pending = pending


func selected_boss_reward_index() -> int:
	return _boss_reward_selected_index


func set_selected_boss_reward_index(selected_index: int) -> void:
	_boss_reward_selected_index = selected_index
	for index in _boss_reward_buttons.size():
		_apply_boss_reward_button_theme(_boss_reward_buttons[index], index == _boss_reward_selected_index)
		var accent := _boss_reward_buttons[index].get_node_or_null("SelectedAccent") as ColorRect
		if accent != null:
			accent.visible = index == _boss_reward_selected_index


func boss_reward_buttons() -> Array[Button]:
	return _boss_reward_buttons


func boss_reward_skip_button() -> Button:
	return _boss_reward_skip_button


func show_summary(title: String, body: String, show_next: bool, button_text: String = "Continue") -> void:
	if _outcome_title_label != null:
		_outcome_title_label.text = title
	if _outcome_body_label != null:
		_outcome_body_label.text = body
	_boss_reward_pending = false
	_boss_reward_overlay_active = false
	_boss_reward_selected_index = -1
	set_boss_reward_controls_visible(false)
	if _next_button != null:
		_next_button.text = button_text
		_next_button.visible = show_next
		_next_button.disabled = not show_next
	if _outcome_summary_panel != null:
		_outcome_summary_panel.visible = true
	sync_visibility()


func hide() -> void:
	if _outcome_summary_panel != null:
		_outcome_summary_panel.visible = false
	set_boss_reward_controls_visible(false)
	_boss_reward_pending = false
	_boss_reward_overlay_active = false
	_boss_reward_selected_index = -1
	if _next_button != null:
		_next_button.text = "Continue"
		_next_button.visible = false
		_next_button.disabled = true
	sync_visibility()


func show_boss_reward(body: String) -> void:
	if _outcome_title_label != null:
		_outcome_title_label.text = "Boss Victory"
	if _outcome_body_label != null:
		_outcome_body_label.text = "%s\nChoose one relic." % body
	if _outcome_summary_panel != null:
		_outcome_summary_panel.visible = true
	_boss_reward_pending = true
	_boss_reward_overlay_active = true
	_boss_reward_selected_index = -1
	if _next_button != null:
		_next_button.text = "Continue To Shop"
		_next_button.visible = true
		_next_button.disabled = true
	set_boss_reward_controls_visible(true)
	sync_visibility()


func set_boss_reward_controls_visible(should_show: bool) -> void:
	for button in _boss_reward_buttons:
		button.visible = should_show
	if _boss_reward_skip_button != null:
		_boss_reward_skip_button.visible = false


func ensure_boss_reward_controls(on_claim_option: Callable, on_skip: Callable) -> void:
	if not _boss_reward_buttons.is_empty() or _outcome_summary_root == null:
		return
	for index in 3:
		var button := Button.new()
		button.name = "BossRewardButton%d" % (index + 1)
		button.visible = false
		button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
		button.z_index = 1
		button.text = ""
		button.pressed.connect(on_claim_option.bind(index))
		_outcome_summary_root.add_child(button)
		_apply_boss_reward_button_theme(button, false)
		_ensure_boss_reward_card_children(button)
		_boss_reward_buttons.append(button)
	_boss_reward_skip_button = Button.new()
	_boss_reward_skip_button.name = "BossRewardSkipButton"
	_boss_reward_skip_button.text = ""
	_boss_reward_skip_button.visible = false
	_boss_reward_skip_button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
	_boss_reward_skip_button.z_index = 1
	_boss_reward_skip_button.pressed.connect(on_skip)
	_outcome_summary_root.add_child(_boss_reward_skip_button)
	_apply_outcome_button_theme(_boss_reward_skip_button)


func ensure_overlay_layer() -> void:
	if _layout_root == null or _outcome_summary_panel == null:
		return
	if _outcome_scrim == null:
		var scrim := ColorRect.new()
		scrim.name = "OutcomeScrim"
		scrim.visible = false
		scrim.color = _config.get("outcome_boss_scrim_color", OUTCOME_BOSS_SCRIM_COLOR)
		scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		scrim.z_as_relative = false
		scrim.z_index = int(_config.get("outcome_scrim_z_index", OUTCOME_SCRIM_Z_INDEX))
		_layout_root.add_child(scrim)
		_outcome_scrim = scrim
	if _outcome_summary_panel.get_parent() != _layout_root:
		var current_parent := _outcome_summary_panel.get_parent()
		if current_parent != null:
			current_parent.remove_child(_outcome_summary_panel)
		_layout_root.add_child(_outcome_summary_panel)
	_outcome_summary_panel.z_as_relative = false
	_outcome_summary_panel.z_index = int(_config.get("outcome_modal_z_index", OUTCOME_MODAL_Z_INDEX))
	_outcome_summary_panel.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
	if _next_button != null:
		_next_button.z_index = 1
	sync_visibility()


func sync_visibility() -> void:
	if _outcome_scrim != null and _outcome_summary_panel != null:
		var show_scrim := _outcome_summary_panel.visible and _boss_reward_overlay_active
		_outcome_scrim.visible = show_scrim
		_outcome_scrim.mouse_filter = (Control.MOUSE_FILTER_STOP if show_scrim else Control.MOUSE_FILTER_IGNORE) as Control.MouseFilter


func sync_layout(board_panel_rect: Rect2) -> void:
	if _layout_root == null or _outcome_summary_panel == null:
		return
	if _outcome_scrim != null:
		_outcome_scrim.position = Vector2.ZERO
		_outcome_scrim.size = _layout_root.size
	if _boss_reward_overlay_active:
		_apply_design_rect(_outcome_summary_panel, _config.get("boss_reward_summary_rect", BOSS_REWARD_SUMMARY_RECT))
		layout_boss_reward()
	else:
		var outcome_summary_rect: Rect2 = _config.get("outcome_summary_rect", OUTCOME_SUMMARY_RECT)
		var standard_rect := Rect2(board_panel_rect.position + outcome_summary_rect.position, outcome_summary_rect.size)
		_apply_design_rect(_outcome_summary_panel, standard_rect)
		layout_standard()
	sync_visibility()


func layout_standard() -> void:
	if (
		_outcome_summary_root == null
		or _outcome_text_column == null
		or _outcome_title_label == null
		or _outcome_body_label == null
		or _next_button == null
		or _outcome_summary_panel == null
	):
		return
	_outcome_summary_root.position = Vector2(48.0, 40.0)
	_outcome_summary_root.size = _outcome_summary_panel.size - Vector2(96.0, 80.0)
	_outcome_text_column.position = Vector2.ZERO
	_outcome_text_column.size = Vector2(_outcome_summary_root.size.x, 244.0)
	_outcome_title_label.custom_minimum_size = Vector2.ZERO
	_outcome_body_label.custom_minimum_size = Vector2.ZERO
	_outcome_title_label.position = Vector2.ZERO
	_outcome_title_label.size = Vector2(_outcome_text_column.size.x, 92.0)
	_outcome_body_label.position = Vector2(0.0, 112.0)
	_outcome_body_label.size = Vector2(_outcome_text_column.size.x, 146.0)
	_next_button.position = Vector2((_outcome_summary_root.size.x - 340.0) * 0.5, _outcome_summary_root.size.y - 92.0)
	_next_button.size = Vector2(340.0, 82.0)


func layout_boss_reward() -> void:
	if (
		_outcome_summary_root == null
		or _outcome_text_column == null
		or _outcome_title_label == null
		or _outcome_body_label == null
		or _next_button == null
		or _outcome_summary_panel == null
	):
		return
	var boss_reward_card_gap := float(_config.get("boss_reward_card_gap", BOSS_REWARD_CARD_GAP))
	var boss_reward_row_top := float(_config.get("boss_reward_row_top", BOSS_REWARD_ROW_TOP))
	var boss_reward_card_height := float(_config.get("boss_reward_card_height", BOSS_REWARD_CARD_HEIGHT))
	var boss_reward_next_button_size: Vector2 = _config.get("boss_reward_next_button_size", BOSS_REWARD_NEXT_BUTTON_SIZE)

	_outcome_summary_root.position = Vector2(44.0, 38.0)
	_outcome_summary_root.size = _outcome_summary_panel.size - Vector2(88.0, 76.0)
	_outcome_text_column.position = Vector2.ZERO
	_outcome_text_column.size = Vector2(_outcome_summary_root.size.x, 146.0)
	_outcome_title_label.custom_minimum_size = Vector2.ZERO
	_outcome_body_label.custom_minimum_size = Vector2.ZERO
	_outcome_title_label.position = Vector2.ZERO
	_outcome_title_label.size = Vector2(_outcome_text_column.size.x, 66.0)
	_outcome_body_label.position = Vector2(0.0, 76.0)
	_outcome_body_label.size = Vector2(_outcome_text_column.size.x, 70.0)

	var row_width := _outcome_summary_root.size.x
	for index in _boss_reward_buttons.size():
		var y := boss_reward_row_top + (float(index) * (boss_reward_card_height + boss_reward_card_gap))
		_boss_reward_buttons[index].position = Vector2(0.0, y)
		_boss_reward_buttons[index].size = Vector2(row_width, boss_reward_card_height)
		layout_boss_reward_card_children(_boss_reward_buttons[index])

	if _boss_reward_skip_button != null:
		_boss_reward_skip_button.visible = false
	_next_button.size = boss_reward_next_button_size
	_next_button.position = Vector2((_outcome_summary_root.size.x - _next_button.size.x) * 0.5, _outcome_summary_root.size.y - _next_button.size.y - 6.0)


func layout_boss_reward_card_children(button: Button) -> void:
	var boss_reward_icon_size: Vector2 = _config.get("boss_reward_icon_size", BOSS_REWARD_ICON_SIZE)
	var content_left := boss_reward_icon_size.x + 34.0
	var content_width := maxf(0.0, button.size.x - content_left - 18.0)
	var name_label := button.get_node_or_null("RelicName") as Label
	if name_label != null:
		name_label.position = Vector2(content_left, 16.0)
		name_label.size = Vector2(content_width, 38.0)
	var rarity_label := button.get_node_or_null("RelicRarity") as Label
	if rarity_label != null:
		rarity_label.position = Vector2(content_left, 55.0)
		rarity_label.size = Vector2(content_width, 26.0)
	var icon := button.get_node_or_null("RelicIcon") as TextureRect
	if icon != null:
		icon.position = Vector2(18.0, (button.size.y - boss_reward_icon_size.y) * 0.5)
		icon.size = boss_reward_icon_size
	var description_label := button.get_node_or_null("RelicDescription") as Label
	if description_label != null:
		description_label.position = Vector2(content_left, 84.0)
		description_label.size = Vector2(content_width, button.size.y - 92.0)
	var accent := button.get_node_or_null("SelectedAccent") as ColorRect
	if accent != null:
		accent.position = Vector2(8.0, 8.0)
		accent.size = Vector2(5.0, maxf(0.0, button.size.y - 16.0))


func set_boss_reward_card_content(button: Button, icon_texture: Texture2D, display_name: String, rarity: String, description: String) -> void:
	button.text = ""
	button.icon = null
	_ensure_boss_reward_card_children(button)
	var icon := button.get_node_or_null("RelicIcon") as TextureRect
	if icon != null:
		icon.texture = icon_texture
		icon.visible = icon_texture != null
	var name_label := button.get_node_or_null("RelicName") as Label
	if name_label != null:
		name_label.text = display_name
	var rarity_label := button.get_node_or_null("RelicRarity") as Label
	if rarity_label != null:
		rarity_label.text = rarity
	var description_label := button.get_node_or_null("RelicDescription") as Label
	if description_label != null:
		description_label.text = description
	layout_boss_reward_card_children(button)


func wrap_text_to_lines(text: String, max_chars: int, max_lines: int) -> String:
	var words := text.strip_edges().split(" ", false)
	var lines: Array[String] = []
	var current_line := ""
	for word in words:
		var candidate := word if current_line.is_empty() else "%s %s" % [current_line, word]
		if candidate.length() <= max_chars:
			current_line = candidate
			continue
		if not current_line.is_empty():
			lines.append(current_line)
		current_line = word
		if lines.size() >= max_lines:
			break
	if lines.size() < max_lines and not current_line.is_empty():
		lines.append(current_line)
	if lines.size() > max_lines:
		lines.resize(max_lines)
	var result := "\n".join(lines)
	if words.size() > 0 and text.length() > result.replace("\n", " ").length():
		result = result.trim_suffix(".") + "..."
	return result


func _apply_design_rect(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size


func _apply_outcome_button_theme(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(0.92, 0.88, 0.72, 1.0))
	button.add_theme_font_size_override("font_size", OUTCOME_BUTTON_FONT_SIZE)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.07, 0.10, 0.96)
	style.border_color = Color(0.72, 0.54, 0.24, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color(0.10, 0.10, 0.08, 0.98)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)


func _apply_boss_reward_button_theme(button: Button, selected: bool) -> void:
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_font_size_override("font_size", 1)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.13, 0.18, 0.98)
	style.border_color = Color(0.72, 0.54, 0.24, 0.92)
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 0.0
	style.content_margin_right = 0.0
	style.content_margin_top = 0.0
	style.content_margin_bottom = 0.0
	button.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = Color(0.10, 0.18, 0.25, 0.99)
	hover.border_color = Color(0.96, 0.78, 0.34, 1.0)
	button.add_theme_stylebox_override("hover", hover)
	var pressed := hover.duplicate()
	pressed.bg_color = Color(0.13, 0.21, 0.28, 1.0)
	button.add_theme_stylebox_override("pressed", pressed)
	var disabled := style.duplicate()
	disabled.bg_color = Color(0.05, 0.07, 0.09, 0.8)
	disabled.border_color = Color(0.22, 0.22, 0.22, 0.8)
	button.add_theme_stylebox_override("disabled", disabled)
	if selected:
		var selected_style := style.duplicate()
		selected_style.bg_color = Color(0.10, 0.19, 0.28, 0.99)
		selected_style.border_color = Color(1.0, 0.86, 0.44, 1.0)
		selected_style.set_border_width_all(4)
		button.add_theme_stylebox_override("normal", selected_style)
		button.add_theme_stylebox_override("hover", selected_style)
		button.add_theme_stylebox_override("pressed", selected_style)


func _ensure_boss_reward_card_children(button: Button) -> void:
	if button.get_node_or_null("RelicIcon") != null:
		return
	var icon := TextureRect.new()
	icon.name = "RelicIcon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	button.add_child(icon)

	var accent := ColorRect.new()
	accent.name = "SelectedAccent"
	accent.visible = false
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	accent.color = Color(1.0, 0.82, 0.32, 1.0)
	button.add_child(accent)

	var name_label := Label.new()
	name_label.name = "RelicName"
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	name_label.add_theme_font_size_override("font_size", BOSS_REWARD_NAME_FONT_SIZE)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.82, 1.0))
	button.add_child(name_label)

	var rarity_label := Label.new()
	rarity_label.name = "RelicRarity"
	rarity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	rarity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	rarity_label.add_theme_font_size_override("font_size", BOSS_REWARD_RARITY_FONT_SIZE)
	rarity_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.36, 1.0))
	button.add_child(rarity_label)

	var description_label := Label.new()
	description_label.name = "RelicDescription"
	description_label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	description_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	description_label.add_theme_font_size_override("font_size", BOSS_REWARD_DESCRIPTION_FONT_SIZE)
	description_label.add_theme_color_override("font_color", Color(0.90, 0.84, 0.73, 1.0))
	button.add_child(description_label)
