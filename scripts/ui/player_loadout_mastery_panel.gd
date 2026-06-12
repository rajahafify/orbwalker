extends RefCounted
class_name PlayerLoadoutMasteryPanel

const HUD_CHROME_STYLER_SCRIPT := preload("res://scripts/ui/player_loadout_hud_chrome_styler.gd")
const ORB_TYPE := preload("res://scripts/board/orb_type.gd")
const MASTERY_ICON_INNER_SIZE := Vector2(34, 34)
const MASTERY_SLOT_SIZE := Vector2(44, 44)
const MASTERY_CELL_WIDTH := 92.0
const MASTERY_CELL_GAP := 24.0
const COMBAT_MASTERY_CARD_SIZE := Vector2(170, 102)
const COMBAT_MASTERY_CARD_GAP := 2.0
const COMBAT_MASTERY_ICON_SIZE := Vector2(82, 82)
const COMBAT_MASTERY_COMPACT_CARD_SIZE := Vector2(102, 76)
const COMBAT_MASTERY_COMPACT_CARD_GAP := 2.0
const COMBAT_MASTERY_COMPACT_ICON_SIZE := Vector2(58, 58)
const COMBAT_MASTERY_FEEDBACK_NUMBER_FONT_SIZE := 42
const COMBAT_MASTERY_COMPACT_FEEDBACK_NUMBER_FONT_SIZE := 34
const COMBAT_MASTERY_FEEDBACK_POP_SECONDS := 0.18
const COMBAT_MASTERY_ACTIVATION_BASE_ALPHA := 0.14
const COMBAT_MASTERY_ACTIVATION_ALPHA_STEP := 0.08
const COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS := 0.24
const COMBAT_MASTERY_HOVER_ALPHA := 0.20
const COMBAT_MASTERY_HOVER_BORDER_ALPHA := 0.90
const COMBAT_MASTERY_ORDER: Array[int] = [3, 4, 5, 0, 1, 2]
const COMBAT_MASTERY_ROOT_RECT := Rect2(Vector2.ZERO, Vector2(1048, 108))
const MASTERY_DETAIL_BUBBLE_SIZE := Vector2(960.0, 468.0)

var _hud: Variant


func bind(hud: Variant) -> void:
	_hud = hud


func populate_mastery_row(row: Control, mastery_levels: Dictionary) -> void:
	_hud._clear_children(row)
	for index in range(COMBAT_MASTERY_ORDER.size()):
		var orb_id: int = COMBAT_MASTERY_ORDER[index]
		var cell := Control.new()
		cell.name = "MasteryCell%d" % orb_id
		cell.size = Vector2(MASTERY_CELL_WIDTH, MASTERY_SLOT_SIZE.y)
		cell.position = Vector2(float(index) * (MASTERY_CELL_WIDTH + MASTERY_CELL_GAP), 0.0)

		var slot := PanelContainer.new()
		slot.name = "MasteryIconSlot"
		slot.custom_minimum_size = MASTERY_SLOT_SIZE
		slot.size = MASTERY_SLOT_SIZE
		slot.position = Vector2.ZERO
		slot.add_theme_stylebox_override("panel", _hud._slot_stylebox())

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.custom_minimum_size = MASTERY_ICON_INNER_SIZE
		icon.size = MASTERY_ICON_INNER_SIZE
		icon.position = Vector2((MASTERY_SLOT_SIZE.x - MASTERY_ICON_INNER_SIZE.x) * 0.5, (MASTERY_SLOT_SIZE.y - MASTERY_ICON_INNER_SIZE.y) * 0.5)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.texture = _hud._visual_registry().mastery_icon(orb_id)
		var level := int(mastery_levels.get(orb_id, 0))
		icon.tooltip_text = "%s Mastery %d" % [ORB_TYPE.display_name(orb_id), level]
		if level <= 0:
			icon.modulate = Color(0.6, 0.6, 0.6, 0.7)
		slot.add_child(icon)

		var amount_label := Label.new()
		amount_label.name = "MasteryAmount"
		amount_label.text = str(level)
		amount_label.position = Vector2(52.0, 0.0)
		amount_label.size = Vector2(28.0, MASTERY_SLOT_SIZE.y)
		amount_label.custom_minimum_size = amount_label.size
		amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		amount_label.add_theme_font_size_override("font_size", 24)
		amount_label.add_theme_color_override("font_color", Color(0.95, 0.84, 0.42, 1.0))
		amount_label.add_theme_constant_override("outline_size", 2)
		amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))

		cell.add_child(slot)
		cell.add_child(amount_label)
		row.add_child(cell)


func get_combat_mastery_card(row: Control, orb_id: int) -> Control:
	if row == null:
		return null
	var card_name := _combat_mastery_card_name(orb_id)
	for child in row.get_children():
		if child.name == card_name:
			return child as Control
	return null


func populate_combat_mastery_panel(row: Control, _mastery_levels: Dictionary, feedback_totals: Dictionary = {}) -> void:
	_hud._clear_children(row)
	var compact_mode := row.size.y > 0.0 and row.size.y <= 90.0
	var card_size := COMBAT_MASTERY_COMPACT_CARD_SIZE if compact_mode else COMBAT_MASTERY_CARD_SIZE
	var card_gap := COMBAT_MASTERY_COMPACT_CARD_GAP if compact_mode else COMBAT_MASTERY_CARD_GAP
	var icon_size := COMBAT_MASTERY_COMPACT_ICON_SIZE if compact_mode else COMBAT_MASTERY_ICON_SIZE
	var row_width := row.size.x if row.size.x > 0.0 else COMBAT_MASTERY_ROOT_RECT.size.x
	var total_cards_width := card_size.x * float(COMBAT_MASTERY_ORDER.size())
	total_cards_width += card_gap * float(COMBAT_MASTERY_ORDER.size() - 1)
	var start_x := maxf(0.0, (row_width - total_cards_width) * 0.5)
	for index in range(COMBAT_MASTERY_ORDER.size()):
		var orb_id: int = COMBAT_MASTERY_ORDER[index]
		var feedback_value := int(feedback_totals.get(orb_id, 0))

		var card := Control.new()
		card.name = _combat_mastery_card_name(orb_id)
		card.clip_contents = true
		card.mouse_filter = Control.MOUSE_FILTER_STOP as Control.MouseFilter
		card.size = card_size
		card.position = Vector2(start_x + float(index) * (card_size.x + card_gap), 0.0)

		var panel := Panel.new()
		panel.name = "CardPanel"
		panel.custom_minimum_size = card_size
		panel.size = card_size
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		panel.add_theme_stylebox_override("panel", _combat_mastery_card_stylebox(orb_id))

		var card_background := TextureRect.new()
		card_background.name = "CardTexture"
		card_background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		card_background.position = Vector2.ZERO
		card_background.size = card_size
		card_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		card_background.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
		card_background.texture = _hud._visual_registry().mastery_card_texture(orb_id)
		card_background.modulate = Color(1.0, 1.0, 1.0, 0.18)

		var activation_glow := ColorRect.new()
		activation_glow.name = "ActivationGlow"
		activation_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		activation_glow.position = Vector2(4.0, 4.0)
		activation_glow.size = card_size - Vector2(8.0, 8.0)
		var activation_accent := ORB_TYPE.color(orb_id)
		activation_glow.color = Color(activation_accent.r, activation_accent.g, activation_accent.b, 0.0)
		activation_glow.visible = false

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.custom_minimum_size = icon_size
		icon.size = icon_size
		icon.position = Vector2((card_size.x - icon_size.x) * 0.5, (card_size.y - icon_size.y) * 0.5)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.texture = _hud._visual_registry().menu_mastery_icon(orb_id)

		var feedback_label := Label.new()
		feedback_label.name = "MasteryFeedback"
		feedback_label.text = _combat_mastery_feedback_number_text(feedback_value)
		feedback_label.position = Vector2.ZERO
		feedback_label.size = card_size
		feedback_label.add_theme_font_size_override(
			"font_size", COMBAT_MASTERY_COMPACT_FEEDBACK_NUMBER_FONT_SIZE if compact_mode else COMBAT_MASTERY_FEEDBACK_NUMBER_FONT_SIZE
		)
		feedback_label.add_theme_color_override("font_color", Color(1.0, 0.94, 0.62, 1.0))
		feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
		feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
		feedback_label.pivot_offset = card_size * 0.5
		feedback_label.add_theme_constant_override("outline_size", 2)
		feedback_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.98))
		feedback_label.visible = feedback_value > 0
		feedback_label.modulate = Color(1.0, 0.95, 0.66, 1.0) if feedback_label.visible else Color(1.0, 1.0, 1.0, 0.38)

		var activation_frame := Panel.new()
		activation_frame.name = "ActivationFrame"
		activation_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		activation_frame.position = Vector2.ZERO
		activation_frame.size = card_size
		activation_frame.visible = false

		var hover_highlight := ColorRect.new()
		hover_highlight.name = "HoverHighlight"
		hover_highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		hover_highlight.position = Vector2(2.0, 2.0)
		hover_highlight.size = card_size - Vector2(4.0, 4.0)
		hover_highlight.color = Color(1.0, 1.0, 1.0, 0.0)
		hover_highlight.visible = false

		var hover_frame := Panel.new()
		hover_frame.name = "HoverFrame"
		hover_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		hover_frame.position = Vector2.ZERO
		hover_frame.size = card_size
		hover_frame.visible = false

		panel.add_child(card_background)
		panel.add_child(activation_glow)
		panel.add_child(icon)
		panel.add_child(feedback_label)
		panel.add_child(activation_frame)
		panel.add_child(hover_highlight)
		panel.add_child(hover_frame)
		card.add_child(panel)
		row.add_child(card)
		card.mouse_entered.connect(_on_combat_mastery_card_mouse_entered.bind(row, orb_id, card))
		card.mouse_exited.connect(_on_combat_mastery_card_mouse_exited.bind(row, orb_id))
		_apply_combat_mastery_activation(card, orb_id, feedback_value, false)
	_apply_hovered_combat_mastery(row)


func clear_combat_mastery_feedback(row: Control) -> void:
	for orb_id in COMBAT_MASTERY_ORDER:
		set_combat_mastery_feedback(row, int(orb_id), 0)


func set_combat_mastery_feedback(row: Control, orb_id: int, feedback_value: int) -> void:
	if not ORB_TYPE.is_valid_id(orb_id):
		return
	var card: Control = get_combat_mastery_card(row, orb_id)
	if card == null:
		return
	var panel: Control = card.get_node_or_null("CardPanel") as Control
	if panel == null:
		return
	var feedback_label: Label = panel.get_node_or_null("MasteryFeedback") as Label
	if feedback_label == null:
		return
	var previous_text := feedback_label.text
	var feedback_text := _combat_mastery_feedback_number_text(feedback_value)
	feedback_label.text = feedback_text
	feedback_label.visible = feedback_value > 0
	feedback_label.modulate = Color(1.0, 0.95, 0.66, 1.0) if feedback_label.visible else Color(1.0, 1.0, 1.0, 0.38)
	if feedback_value > 0 and previous_text != feedback_text:
		_pulse_combat_mastery_feedback_label(feedback_label)
	_apply_combat_mastery_activation(card, orb_id, feedback_value, true)


func set_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_sync_combat_mastery_hover_payload(payload)


func set_hovered_combat_mastery(row: Control, orb_id: int) -> void:
	_hud._hovered_mastery_orb_id = orb_id if ORB_TYPE.is_valid_id(orb_id) else -1
	_apply_hovered_combat_mastery(row)


func clear_hovered_combat_mastery(row: Control) -> void:
	_hud._hovered_mastery_orb_id = -1
	_apply_hovered_combat_mastery(row)
	if _hud._mastery_detail_hovered_orb_id < 0:
		_hide_mastery_detail()


func clear_combat_mastery_hover_ui(row: Control) -> void:
	_hud._hovered_mastery_orb_id = -1
	_hud._mastery_detail_hovered_orb_id = -1
	_apply_hovered_combat_mastery(row)
	_hide_mastery_detail()
	_clear_mastery_source_highlights()


func pulse_modifier_sources(sources: Array) -> void:
	_hud._mastery_highlighter().pulse_sources(sources)


func _combat_mastery_feedback_number_text(value: int) -> String:
	if value <= 0:
		return ""
	return str(value)


func _pulse_combat_mastery_feedback_label(feedback_label: Label) -> void:
	if feedback_label == null or not feedback_label.is_inside_tree():
		return
	feedback_label.scale = Vector2(1.18, 1.18)
	var tween := feedback_label.create_tween()
	(
		tween
		. tween_property(feedback_label, "scale", Vector2(1.0, 1.0), COMBAT_MASTERY_FEEDBACK_POP_SECONDS)
		. set_trans(Tween.TRANS_BACK as Tween.TransitionType)
		. set_ease(Tween.EASE_OUT as Tween.EaseType)
	)


func _combat_mastery_card_stylebox(orb_id: int, activation_tier: int = 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := ORB_TYPE.color(orb_id)
	style.bg_color = Color(0.02, 0.05, 0.07, 0.70)
	var border_alpha := 0.42 + 0.10 * float(maxi(0, activation_tier))
	style.border_color = Color(accent.r, accent.g, accent.b, clampf(border_alpha, 0.0, 0.86))
	style.border_blend = true
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 1
	style.border_width_bottom = 1
	if activation_tier >= 2:
		style.border_width_right = 2
		style.border_width_bottom = 2
	style.set_corner_radius_all(4)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 3
	style.shadow_offset = Vector2(1.0, 2.0)
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style


func _apply_combat_mastery_activation(card: Control, orb_id: int, feedback_value: int, animate: bool) -> void:
	if card == null:
		return
	var panel := card.get_node_or_null("CardPanel") as Control
	if panel == null:
		return
	var glow := panel.get_node_or_null("ActivationGlow") as ColorRect
	var frame := panel.get_node_or_null("ActivationFrame") as Panel
	var card_background := panel.get_node_or_null("CardTexture") as TextureRect
	var icon := panel.get_node_or_null("MasteryIcon") as TextureRect
	var feedback_label := panel.get_node_or_null("MasteryFeedback") as Label
	var active := feedback_value > 0
	var tier := _combat_mastery_activation_tier(feedback_value)
	var accent := ORB_TYPE.color(orb_id)
	panel.add_theme_stylebox_override("panel", _combat_mastery_card_stylebox(orb_id, tier))
	if card_background != null:
		card_background.modulate = Color(1.0, 1.0, 1.0, 0.08 if active else 0.18)
	if icon != null:
		icon.visible = not active
	if feedback_label != null:
		feedback_label.visible = active
	if glow != null:
		glow.color = Color(accent.r, accent.g, accent.b, _combat_mastery_activation_alpha(tier) if active else 0.0)
		glow.visible = active
		glow.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if frame != null:
		frame.add_theme_stylebox_override("panel", _combat_mastery_activation_frame_stylebox(orb_id, tier))
		frame.visible = active
		frame.modulate = Color(1.0, 1.0, 1.0, 0.82 if active else 0.0)
	if active and animate:
		_pulse_combat_mastery_activation(glow, frame, tier)


func _combat_mastery_activation_tier(feedback_value: int) -> int:
	if feedback_value <= 0:
		return 0
	return clampi(int(ceil(float(feedback_value) / 5.0)), 1, 4)


func _combat_mastery_activation_alpha(tier: int) -> float:
	if tier <= 0:
		return 0.0
	return clampf(COMBAT_MASTERY_ACTIVATION_BASE_ALPHA + COMBAT_MASTERY_ACTIVATION_ALPHA_STEP * float(tier - 1), 0.0, 0.42)


func _pulse_combat_mastery_activation(glow: ColorRect, frame: Panel, tier: int) -> void:
	var target: Control = glow
	if target == null:
		target = frame
	if target == null or tier <= 0 or not target.is_inside_tree():
		return
	var pulse_alpha := 0.16 + 0.05 * float(tier)
	var tween := target.create_tween()
	tween.set_parallel(true)
	if glow != null:
		var original_glow_alpha := glow.modulate.a
		tween.tween_property(glow, "modulate:a", minf(1.0, original_glow_alpha + pulse_alpha), COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)
		tween.tween_property(glow, "modulate:a", original_glow_alpha, COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS).set_delay(
			COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5
		)
	if frame != null:
		var original_frame_alpha := frame.modulate.a
		tween.tween_property(frame, "modulate:a", minf(1.0, original_frame_alpha + pulse_alpha), COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5)
		tween.tween_property(frame, "modulate:a", original_frame_alpha, COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS).set_delay(
			COMBAT_MASTERY_ACTIVATION_PULSE_SECONDS * 0.5
		)


func _combat_mastery_activation_frame_stylebox(orb_id: int, tier: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := ORB_TYPE.color(orb_id)
	var strength := 0.42 + 0.10 * float(maxi(1, tier))
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.0)
	style.border_color = Color(accent.r, accent.g, accent.b, clampf(strength, 0.0, 0.88))
	style.set_border_width_all(1 + mini(2, maxi(0, tier - 1)))
	style.set_corner_radius_all(6)
	return style


func _combat_mastery_card_name(orb_id: int) -> String:
	return "CombatMasteryCard%d" % orb_id


func _sync_combat_mastery_hover_payload(payload: Dictionary) -> void:
	_hud._mastery_hover_payload = payload.duplicate(true)
	_hud._mastery_highlighter().set_hover_payload(payload)
	if _hud._mastery_detail_hovered_orb_id >= 0:
		_show_mastery_detail(_hud._mastery_detail_hovered_orb_id)
	else:
		_hud._mastery_highlighter().apply_highlights()


func _apply_hovered_combat_mastery(row: Control) -> void:
	if row == null:
		return
	for orb_id in COMBAT_MASTERY_ORDER:
		var card := get_combat_mastery_card(row, orb_id)
		if card == null:
			continue
		var panel := card.get_node_or_null("CardPanel") as Control
		if panel == null:
			continue
		var hover_highlight := panel.get_node_or_null("HoverHighlight") as ColorRect
		var hover_frame := panel.get_node_or_null("HoverFrame") as Panel
		var active: bool = int(orb_id) == int(_hud._hovered_mastery_orb_id)
		if hover_highlight != null:
			var accent := ORB_TYPE.color(int(orb_id))
			hover_highlight.color = Color(accent.r, accent.g, accent.b, COMBAT_MASTERY_HOVER_ALPHA if active else 0.0)
			hover_highlight.visible = active
		if hover_frame != null:
			hover_frame.add_theme_stylebox_override("panel", _combat_mastery_hover_frame_stylebox(int(orb_id)))
			hover_frame.visible = active


func _combat_mastery_hover_frame_stylebox(orb_id: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var accent := ORB_TYPE.color(orb_id)
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.0)
	style.border_color = Color(accent.r, accent.g, accent.b, COMBAT_MASTERY_HOVER_BORDER_ALPHA)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _on_combat_mastery_card_mouse_entered(row: Control, orb_id: int, card: Control) -> void:
	if not ORB_TYPE.is_valid_id(orb_id):
		return
	_hud._mastery_detail_hovered_orb_id = orb_id
	set_hovered_combat_mastery(row, orb_id)
	_show_mastery_detail(orb_id, card)


func _on_combat_mastery_card_mouse_exited(row: Control, orb_id: int) -> void:
	if _hud._mastery_detail_hovered_orb_id == orb_id:
		_hud._mastery_detail_hovered_orb_id = -1
		_hide_mastery_detail()
	_hud._mastery_highlighter().clear_highlights()
	if _hud._hovered_mastery_orb_id == orb_id:
		_hud._hovered_mastery_orb_id = -1
	_apply_hovered_combat_mastery(row)


func _ensure_mastery_detail_bubble() -> void:
	if _hud._mastery_detail_bubble != null:
		return
	var parent := _hud._hud_nodes.get("popover_parent", null) as Control
	if parent == null:
		parent = _hud._hud_nodes.get("section", null) as Control
	if parent == null:
		return

	_hud._mastery_detail_bubble = Panel.new()
	_hud._mastery_detail_bubble.name = "MasteryDetailBubble"
	_hud._mastery_detail_bubble.visible = false
	_hud._mastery_detail_bubble.z_index = int(_hud._hud_nodes.get("popover_z_index", 210))
	_hud._mastery_detail_bubble.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	parent.add_child(_hud._mastery_detail_bubble)

	_hud._mastery_detail_title = Label.new()
	_hud._mastery_detail_title.name = "MasteryDetailTitle"
	_hud._mastery_detail_bubble.add_child(_hud._mastery_detail_title)

	_hud._mastery_detail_effect = Label.new()
	_hud._mastery_detail_effect.name = "MasteryDetailEffect"
	_hud._mastery_detail_bubble.add_child(_hud._mastery_detail_effect)

	_hud._mastery_detail_value = Label.new()
	_hud._mastery_detail_value.name = "MasteryDetailValue"
	_hud._mastery_detail_bubble.add_child(_hud._mastery_detail_value)

	_hud._mastery_detail_modifiers = Label.new()
	_hud._mastery_detail_modifiers.name = "MasteryDetailModifiers"
	_hud._mastery_detail_modifiers.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	_hud._mastery_detail_bubble.add_child(_hud._mastery_detail_modifiers)

	_apply_mastery_detail_popover_chrome()


func _apply_mastery_detail_popover_chrome() -> void:
	if _hud._mastery_detail_bubble == null:
		return
	var bubble_style := StyleBoxFlat.new()
	bubble_style.bg_color = Color(0.03, 0.04, 0.05, 0.98)
	bubble_style.border_color = Color(0.52, 0.60, 0.72, 0.94)
	bubble_style.set_border_width_all(2)
	bubble_style.set_corner_radius_all(8)
	_hud._mastery_detail_bubble.add_theme_stylebox_override("panel", bubble_style)

	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._mastery_detail_title, Color(0.96, 0.93, 0.86, 1.0), 36)
	_hud._mastery_detail_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._mastery_detail_effect, Color(0.79, 0.86, 0.93, 1.0), 28)
	_hud._mastery_detail_effect.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._mastery_detail_value, Color(0.90, 0.95, 0.72, 1.0), 28)
	_hud._mastery_detail_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	HUD_CHROME_STYLER_SCRIPT._apply_hud_label_style(_hud._mastery_detail_modifiers, Color(0.74, 0.78, 0.84, 1.0), 26)
	_hud._mastery_detail_modifiers.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	_hud._mastery_detail_modifiers.vertical_alignment = VERTICAL_ALIGNMENT_TOP as VerticalAlignment


func _show_mastery_detail(orb_id: int, anchor_card: Control = null) -> void:
	if not ORB_TYPE.is_valid_id(orb_id):
		_hide_mastery_detail()
		return
	_ensure_mastery_detail_bubble()
	if _hud._mastery_detail_bubble == null:
		return
	var detail := _combat_mastery_detail_data(orb_id)
	_hud._mastery_detail_title.text = String(detail.get("title", ""))
	_hud._mastery_detail_effect.text = String(detail.get("effect", ""))
	_hud._mastery_detail_value.text = String(detail.get("value", ""))
	_hud._mastery_detail_modifiers.text = String(detail.get("modifiers", ""))
	_hud._mastery_detail_bubble.size = MASTERY_DETAIL_BUBBLE_SIZE
	_hud._mastery_detail_bubble.visible = true
	_set_mastery_source_highlights_for_orb(orb_id)
	_layout_mastery_detail_bubble(anchor_card)


func _hide_mastery_detail() -> void:
	if _hud._mastery_detail_bubble == null:
		return
	_hud._mastery_detail_bubble.visible = false


func _layout_mastery_detail_bubble(anchor_card: Control = null) -> void:
	if _hud._mastery_detail_bubble == null:
		return
	var parent := _hud._mastery_detail_bubble.get_parent() as Control
	if parent == null:
		return
	var anchor_rect := Rect2(Vector2.ZERO, Vector2.ZERO)
	if anchor_card != null and is_instance_valid(anchor_card):
		anchor_rect = _hud._to_parent_rect(anchor_card.get_global_rect(), parent)
	elif _hud._mastery_detail_hovered_orb_id >= 0:
		var row := _hud._hud_nodes.get("mastery_cards") as Control
		var fallback_card := get_combat_mastery_card(row, _hud._mastery_detail_hovered_orb_id)
		if fallback_card != null:
			anchor_rect = _hud._to_parent_rect(fallback_card.get_global_rect(), parent)
	if anchor_rect.size == Vector2.ZERO:
		return

	var bubble_size: Vector2 = _hud._mastery_detail_bubble.size
	var local_x: float = anchor_rect.position.x + (anchor_rect.size.x - bubble_size.x) * 0.5
	local_x = clampf(local_x, 0.0, maxf(0.0, parent.size.x - bubble_size.x))
	var local_y: float = anchor_rect.position.y - bubble_size.y - 10.0
	if local_y < 0.0:
		local_y = anchor_rect.end.y + 10.0
	_hud._mastery_detail_bubble.position = Vector2(local_x, local_y)

	_hud._apply_rect(_hud._mastery_detail_title, Rect2(Vector2(24.0, 20.0), Vector2(bubble_size.x - 48.0, 52.0)))
	_hud._apply_rect(_hud._mastery_detail_effect, Rect2(Vector2(24.0, 88.0), Vector2(bubble_size.x - 48.0, 46.0)))
	_hud._apply_rect(_hud._mastery_detail_value, Rect2(Vector2(24.0, 146.0), Vector2(bubble_size.x - 48.0, 46.0)))
	_hud._apply_rect(_hud._mastery_detail_modifiers, Rect2(Vector2(24.0, 208.0), Vector2(bubble_size.x - 48.0, bubble_size.y - 232.0)))


func _combat_mastery_detail_data(orb_id: int) -> Dictionary:
	var mastery_levels: Dictionary = _hud._mastery_hover_payload.get("mastery_levels", {})
	var level := int(mastery_levels.get(orb_id, 0))
	var orb_values: Dictionary = _hud._mastery_hover_payload.get("orb_values_by_id", {})
	var orb_value := int(orb_values.get(orb_id, 0))
	var effect_text := _mastery_base_effect_text(orb_id, level)
	var value_text := _mastery_value_text(orb_id, orb_value)
	var source_lines := _mastery_modifier_source_lines(orb_id)
	var modifiers_text := "No equipment or relic modifiers"
	if not source_lines.is_empty():
		modifiers_text = "Modifiers: %s" % "; ".join(source_lines)
	return {
		"title": "%s Mastery Lv %d" % [ORB_TYPE.display_name(orb_id), level],
		"effect": effect_text,
		"value": value_text,
		"modifiers": modifiers_text,
	}


func _mastery_base_effect_text(orb_id: int, level: int) -> String:
	match orb_id:
		ORB_TYPE.Id.HEART:
			return "Base effect: restore HP (mastery bonus +%d)" % level
		ORB_TYPE.Id.ARMOR:
			return "Base effect: gain Armor (mastery bonus +%d)" % level
		ORB_TYPE.Id.GOLD:
			return "Base effect: gain Gold (mastery bonus +%d)" % level
		_:
			return "Base effect: deal Damage (mastery bonus +%d)" % level


func _mastery_value_text(orb_id: int, orb_value: int) -> String:
	var label := "Per orb value"
	match orb_id:
		ORB_TYPE.Id.HEART:
			label = "Per orb heal"
		ORB_TYPE.Id.ARMOR:
			label = "Per orb armor"
		ORB_TYPE.Id.GOLD:
			label = "Per orb gold"
		_:
			label = "Per orb damage"
	return "%s: %d" % [label, orb_value]


func _mastery_modifier_source_lines(orb_id: int) -> Array[String]:
	return _hud._mastery_highlighter().source_lines(orb_id)


func _set_mastery_source_highlights_for_orb(orb_id: int) -> void:
	_hud._mastery_highlighter().set_highlights_for_orb(orb_id)


func _clear_mastery_source_highlights() -> void:
	_hud._mastery_highlighter().clear_highlights()
