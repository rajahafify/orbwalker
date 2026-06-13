extends RefCounted
class_name PlayerLoadoutInventoryRenderer

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const ICON_INNER_SIZE := Vector2(84, 84)
const SLOT_SIZE := Vector2(98, 98)
const SLOT_GAP := 10.0
const RELIC_SLOT_SIZE := Vector2(64, 64)
const RELIC_ICON_SIZE := Vector2(54, 54)
const RELIC_SLOT_GAP := 10.0

var _hooks: Dictionary = {}
var _callbacks: Dictionary = {}
var _empty_silhouette_cache: Dictionary = {}


func bind(hooks: Dictionary, callbacks: Dictionary) -> void:
	_hooks = hooks
	_callbacks = callbacks


func populate_loadout_slot_row(row: Control, ids: Array, label: String, slot_count: int, selectable_label: String = "") -> void:
	var visible_ids: Array = []
	for index in range(slot_count):
		visible_ids.append(ids[index] if index < ids.size() else "")
	populate_icon_row(row, visible_ids, label, selectable_label)


func populate_icon_row(row: Control, ids: Array, label: String, selectable_label: String = "") -> void:
	UI_UTILS.clear_children(row)
	for index in range(ids.size()):
		var id_text := String(ids[index])
		var filled := id_text != ""
		var slot := _make_slot(index, filled, label, selectable_label)
		slot.name = "%sSlot%d" % [label.capitalize(), index]
		var slot_y := maxf(0.0, (row.size.y - SLOT_SIZE.y) * 0.5)
		slot.position = Vector2(float(index) * (SLOT_SIZE.x + SLOT_GAP), slot_y)
		slot.set_meta("content_type", label)
		slot.set_meta("content_id", id_text)
		var content: Dictionary = {}

		var icon := TextureRect.new()
		icon.name = "SlotIcon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		icon.position = Vector2((SLOT_SIZE.x - ICON_INNER_SIZE.x) * 0.5, (SLOT_SIZE.y - ICON_INNER_SIZE.y) * 0.5)
		icon.size = ICON_INNER_SIZE
		icon.custom_minimum_size = ICON_INNER_SIZE

		var amount_label: Label = null
		if filled:
			content = _lookup_content_definition(id_text)
			var icon_key := String(content.get("icon_key", ""))
			icon.texture = _visual_registry().clean_icon_for_key(icon_key)
			icon.tooltip_text = String(content.get("display_name", id_text))
			slot.tooltip_text = slot_tooltip(content, id_text)
			var badge_text := _badge_text_for(label, content)
			if badge_text != "":
				amount_label = _make_badge_label(badge_text, SLOT_SIZE)
		else:
			icon.texture = _empty_slot_silhouette(label)
			icon.modulate = Color(1.0, 1.0, 1.0, 0.35)
			slot.tooltip_text = "Empty %s slot" % label

		slot.add_child(icon)
		if amount_label != null:
			slot.add_child(amount_label)
		_mastery_highlighter().add_highlight(slot, SLOT_SIZE)
		slot.mouse_entered.connect(_emit_slot_mouse_entered.bind(slot, label, index, content, id_text, filled))
		slot.mouse_exited.connect(_emit_slot_mouse_exited)
		row.add_child(slot)
	_mastery_highlighter().apply_highlights()


func populate_relic_row(row: Control, relic_ids: Array, max_visible: int = 4) -> void:
	UI_UTILS.clear_children(row)
	var visible_ids: Array[String] = []
	for raw_id in relic_ids:
		var relic_id := String(raw_id)
		if relic_id != "":
			visible_ids.append(relic_id)
	if visible_ids.is_empty():
		row.tooltip_text = "No relics"
		_mastery_highlighter().apply_highlights()
		return

	var show_count := mini(max_visible, visible_ids.size())
	for index in range(show_count):
		var relic_id := visible_ids[index]
		var slot := PanelContainer.new()
		slot.name = "RelicSlot%d" % index
		slot.custom_minimum_size = RELIC_SLOT_SIZE
		slot.size = RELIC_SLOT_SIZE
		var slot_y := maxf(0.0, (row.size.y - RELIC_SLOT_SIZE.y) * 0.5)
		slot.position = Vector2(float(index) * (RELIC_SLOT_SIZE.x + RELIC_SLOT_GAP), slot_y)
		slot.set_meta("content_type", "relic")
		slot.set_meta("content_id", relic_id)
		slot.add_theme_stylebox_override("panel", slot_stylebox())

		var content := _lookup_content_definition(relic_id)
		slot.tooltip_text = slot_tooltip(content, relic_id)

		var icon := TextureRect.new()
		icon.name = "RelicIcon"
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		icon.position = Vector2((RELIC_SLOT_SIZE.x - RELIC_ICON_SIZE.x) * 0.5, (RELIC_SLOT_SIZE.y - RELIC_ICON_SIZE.y) * 0.5)
		icon.size = RELIC_ICON_SIZE
		icon.custom_minimum_size = RELIC_ICON_SIZE
		icon.texture = _visual_registry().clean_icon_for_key(String(content.get("icon_key", "")))
		slot.add_child(icon)
		_mastery_highlighter().add_highlight(slot, RELIC_SLOT_SIZE)
		slot.mouse_entered.connect(_emit_slot_mouse_entered.bind(slot, "relic", index, content, relic_id, true))
		slot.mouse_exited.connect(_emit_slot_mouse_exited)
		row.add_child(slot)

	if visible_ids.size() > show_count:
		var overflow := Label.new()
		overflow.name = "RelicOverflow"
		overflow.text = "+%d" % (visible_ids.size() - show_count)
		overflow.position = Vector2(float(show_count) * (RELIC_SLOT_SIZE.x + RELIC_SLOT_GAP) + 4.0, 15.0)
		overflow.size = Vector2(50.0, 28.0)
		overflow.add_theme_font_size_override("font_size", 20)
		overflow.add_theme_color_override("font_color", Color(0.95, 0.84, 0.42, 1.0))
		overflow.add_theme_constant_override("outline_size", 2)
		overflow.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
		row.add_child(overflow)
	_mastery_highlighter().apply_highlights()


func slot_tooltip(content: Dictionary, fallback_id: String) -> String:
	var display_name := String(content.get("display_name", fallback_id))
	var description := String(content.get("description", ""))
	return display_name if description == "" else "%s\n%s" % [display_name, description]


func slot_stylebox(selected: bool = false, empty: bool = false) -> StyleBox:
	var slot_texture: Texture2D = _visual_registry().combat_slot_frame_texture(not empty)
	if slot_texture != null and not selected:
		return _texture_stylebox(slot_texture, 20, 20, 20, 20, 6.0)
	var style := StyleBoxFlat.new()
	if empty:
		style.bg_color = Color(0.03, 0.05, 0.08, 0.98)
		style.border_color = Color(0.34, 0.30, 0.22, 0.80)
	elif selected:
		style.bg_color = Color(0.16, 0.11, 0.05, 0.99)
		style.border_color = Color(0.95, 0.70, 0.25, 1.0)
	else:
		style.bg_color = Color(0.08, 0.07, 0.10, 0.98)
		style.border_color = Color(0.68, 0.49, 0.23, 0.96)
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 6.0
	style.content_margin_right = 6.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _make_slot(index: int, filled: bool, slot_label: String, selectable_label: String = "") -> Control:
	var selectable := selectable_label != "" and slot_label == selectable_label
	if selectable:
		var button := Button.new()
		button.text = ""
		button.size = SLOT_SIZE
		button.custom_minimum_size = SLOT_SIZE
		button.focus_mode = Control.FOCUS_NONE as Control.FocusMode
		button.disabled = not filled
		var selected := false
		if slot_label == "equipment":
			selected = index == int(_call_hook("selected_equipment_slot", []))
		elif slot_label == "consumable":
			selected = index == int(_call_hook("selected_consumable_slot", []))
		button.add_theme_stylebox_override("normal", slot_stylebox(selected, not filled))
		button.add_theme_stylebox_override("hover", slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("pressed", slot_stylebox(true, not filled))
		button.add_theme_stylebox_override("disabled", slot_stylebox(selected, not filled))
		if filled:
			if slot_label == "equipment":
				button.pressed.connect(_emit_equipment_slot_pressed.bind(index))
			elif slot_label == "consumable":
				button.pressed.connect(_emit_consumable_slot_pressed.bind(index))
		return button

	var panel := PanelContainer.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.size = SLOT_SIZE
	panel.add_theme_stylebox_override("panel", slot_stylebox(false, not filled))
	return panel


func _make_badge_label(text: String, slot_size: Vector2) -> Label:
	var amount_label := Label.new()
	amount_label.name = "SlotBadge"
	amount_label.text = text
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM as VerticalAlignment
	amount_label.add_theme_font_size_override("font_size", 21)
	amount_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.34, 1.0))
	amount_label.add_theme_constant_override("outline_size", 3)
	amount_label.add_theme_color_override("font_outline_color", Color(0.02, 0.01, 0.00, 0.95))
	amount_label.position = Vector2.ZERO
	amount_label.size = slot_size
	amount_label.anchors_preset = Control.PRESET_FULL_RECT as Control.LayoutPreset
	return amount_label


func _badge_text_for(label: String, content: Dictionary) -> String:
	if label == "equipment":
		return _equipment_badge_text(content)
	if label == "consumable":
		return "1"
	return ""


func _equipment_badge_text(content: Dictionary) -> String:
	var modifiers: Dictionary = content.get("combat_modifiers", {})
	if int(modifiers.get("flat_damage_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_damage_bonus", 0))
	if int(modifiers.get("start_turn_armor", 0)) != 0:
		return "+%d" % int(modifiers.get("start_turn_armor", 0))
	if int(modifiers.get("flat_heal_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_heal_bonus", 0))
	if int(modifiers.get("flat_gold_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("flat_gold_bonus", 0))
	var orb_bonus_by_id: Dictionary = modifiers.get("orb_bonus_by_id", {})
	for value in orb_bonus_by_id.values():
		if int(value) != 0:
			return "+%d" % int(value)
	if int(modifiers.get("combo_flat_bonus", 0)) != 0:
		return "+%d" % int(modifiers.get("combo_flat_bonus", 0))
	var combo_mult := float(modifiers.get("combo_multiplier_mult", 1.0))
	if not is_equal_approx(combo_mult, 1.0):
		return "x%.1f" % combo_mult
	return ""


func _empty_slot_silhouette(label: String) -> Texture2D:
	var key := "%s_empty_silhouette" % label
	if _empty_silhouette_cache.has(key):
		return _empty_silhouette_cache[key]
	var base := Color(0.00, 0.00, 0.00, 0.0)
	var tone := Color(0.56, 0.62, 0.72, 0.82)
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(base)
	if label == "equipment":
		image.fill_rect(Rect2i(45, 16, 6, 46), tone)
		image.fill_rect(Rect2i(34, 46, 28, 8), tone)
		image.fill_rect(Rect2i(36, 54, 24, 10), Color(tone.r, tone.g, tone.b, 0.58))
		image.fill_rect(Rect2i(42, 62, 12, 14), Color(tone.r, tone.g, tone.b, 0.52))
	elif label == "consumable":
		image.fill_rect(Rect2i(34, 18, 28, 12), tone)
		image.fill_rect(Rect2i(38, 30, 20, 10), Color(tone.r, tone.g, tone.b, 0.70))
		image.fill_rect(Rect2i(31, 40, 34, 36), Color(tone.r, tone.g, tone.b, 0.62))
		image.fill_rect(Rect2i(42, 52, 12, 12), Color(tone.r, tone.g, tone.b, 0.34))
	else:
		image.fill_rect(Rect2i(30, 30, 36, 36), tone)
	var texture := ImageTexture.create_from_image(image)
	_empty_silhouette_cache[key] = texture
	return texture


func _texture_stylebox(texture: Texture2D, left: int, right: int, top: int, bottom: int, content_margin: float = 8.0) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = left
	style.texture_margin_right = right
	style.texture_margin_top = top
	style.texture_margin_bottom = bottom
	style.content_margin_left = content_margin
	style.content_margin_right = content_margin
	style.content_margin_top = content_margin
	style.content_margin_bottom = content_margin
	return style


func _lookup_content_definition(content_id: String) -> Dictionary:
	var lookup: Callable = _hooks.get("content_lookup", Callable())
	return lookup.call(content_id) if lookup.is_valid() else {}


func _visual_registry() -> Variant:
	var provider: Callable = _hooks.get("visual_registry_provider", Callable())
	return provider.call() if provider.is_valid() else null


func _mastery_highlighter() -> Variant:
	var provider: Callable = _hooks.get("mastery_highlighter_provider", Callable())
	return provider.call() if provider.is_valid() else null


func _emit_equipment_slot_pressed(index: int) -> void:
	_call_callback("equipment_slot_pressed", [index])


func _emit_consumable_slot_pressed(index: int) -> void:
	_call_callback("consumable_slot_pressed", [index])


func _emit_slot_mouse_entered(slot: Control, slot_type: String, slot_index: int, content: Dictionary, fallback_id: String, filled: bool) -> void:
	_call_callback("slot_mouse_entered", [slot, slot_type, slot_index, content, fallback_id, filled])


func _emit_slot_mouse_exited() -> void:
	_call_callback("slot_mouse_exited", [])


func _call_hook(key: String, args: Array) -> Variant:
	var hook: Callable = _hooks.get(key, Callable())
	return hook.callv(args) if hook.is_valid() else null


func _call_callback(key: String, args: Array) -> void:
	var callback: Callable = _callbacks.get(key, Callable())
	if callback.is_valid():
		callback.callv(args)
