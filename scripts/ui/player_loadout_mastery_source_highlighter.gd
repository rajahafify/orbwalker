extends RefCounted
class_name PlayerLoadoutMasterySourceHighlighter

const MASTERY_SOURCE_HIGHLIGHT_ALPHA := 0.22
const MASTERY_SOURCE_HIGHLIGHT_BORDER_ALPHA := 0.94
const MODIFIER_SOURCE_WIGGLE_SECONDS := 0.30
const MODIFIER_SOURCE_WIGGLE_DEGREES := 6.0
const MODIFIER_SOURCE_WIGGLE_SCALE := 1.08

var _hud_nodes: Dictionary = {}
var _mastery_hover_payload: Dictionary = {}
var _highlighted_mastery_source_ids: Dictionary = {}


func bind_hud_nodes(nodes: Dictionary) -> void:
	_hud_nodes = nodes


func set_hover_payload(payload: Dictionary) -> void:
	_mastery_hover_payload = payload.duplicate(true)


func source_lines(orb_id: int) -> Array[String]:
	var lines: Array[String] = []
	for source in _modifier_sources(orb_id):
		var source_name := String(source.get("display_name", source.get("source_id", "Unknown")))
		lines.append(source_name)
	return lines


func set_highlights_for_orb(orb_id: int) -> void:
	_highlighted_mastery_source_ids.clear()
	for source in _modifier_sources(orb_id):
		var source_type := String(source.get("source_type", ""))
		var source_id := String(source.get("source_id", ""))
		if source_type == "" or source_id == "":
			continue
		_highlighted_mastery_source_ids[_source_key(source_type, source_id)] = true
	apply_highlights()


func clear_highlights() -> void:
	_highlighted_mastery_source_ids.clear()
	apply_highlights()


func apply_highlights() -> void:
	_apply_highlights_to_row(_hud_nodes.get("equipment_icons") as Control)
	_apply_highlights_to_row(_hud_nodes.get("relic_icons") as Control)


func add_highlight(slot: Control, slot_size: Vector2) -> void:
	var highlight := Panel.new()
	highlight.name = "MasterySourceHighlight"
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	highlight.position = Vector2.ZERO
	highlight.size = slot_size
	highlight.custom_minimum_size = slot_size
	highlight.visible = false
	highlight.add_theme_stylebox_override("panel", _highlight_stylebox())
	slot.add_child(highlight)


func pulse_sources(sources: Array) -> void:
	for raw_source in sources:
		var source: Dictionary = raw_source
		var source_type := String(source.get("source_type", ""))
		var source_id := String(source.get("source_id", ""))
		if source_type == "" or source_id == "":
			continue
		var source_slot := _find_source_slot(source_type, source_id)
		_pulse_source_slot(source_slot)


func _modifier_sources(orb_id: int) -> Array[Dictionary]:
	var matching_sources: Array[Dictionary] = []
	var combat_modifiers: Dictionary = _mastery_hover_payload.get("combat_modifiers", {})
	var sources: Array = combat_modifiers.get("sources", [])
	for raw_source in sources:
		var source: Dictionary = raw_source
		var source_modifiers: Dictionary = source.get("combat_modifiers", {})
		if not _source_affects_orb_mastery(orb_id, source_modifiers):
			continue
		matching_sources.append(source)
	return matching_sources


func _apply_highlights_to_row(row: Control) -> void:
	if row == null:
		return
	for child in row.get_children():
		var slot := child as Control
		if slot == null:
			continue
		var highlight := slot.get_node_or_null("MasterySourceHighlight") as Panel
		if highlight == null:
			continue
		var content_type := String(slot.get_meta("content_type", ""))
		var content_id := String(slot.get_meta("content_id", ""))
		highlight.visible = _highlighted_mastery_source_ids.has(_source_key(content_type, content_id))


func _source_key(source_type: String, source_id: String) -> String:
	return "%s:%s" % [source_type, source_id]


func _find_source_slot(source_type: String, source_id: String) -> Control:
	var rows := {
		"equipment": _hud_nodes.get("equipment_icons") as Control,
		"relic": _hud_nodes.get("relic_icons") as Control,
	}
	var row := rows.get(source_type, null) as Control
	if row == null:
		return null
	for child in row.get_children():
		var slot := child as Control
		if slot == null:
			continue
		if String(slot.get_meta("content_type", "")) != source_type:
			continue
		if String(slot.get_meta("content_id", "")) == source_id:
			return slot
	return null


func _pulse_source_slot(slot: Control) -> void:
	if slot == null or not slot.is_inside_tree():
		return
	if slot.has_meta("modifier_wiggle_tween"):
		var old_tween: Variant = slot.get_meta("modifier_wiggle_tween")
		if old_tween is Tween and is_instance_valid(old_tween):
			(old_tween as Tween).kill()
	slot.pivot_offset = slot.size * 0.5
	slot.rotation_degrees = 0.0
	slot.scale = Vector2.ONE
	var tween := slot.create_tween()
	slot.set_meta("modifier_wiggle_tween", tween)
	tween.set_parallel(true)
	(
		tween
		. tween_property(slot, "scale", Vector2(MODIFIER_SOURCE_WIGGLE_SCALE, MODIFIER_SOURCE_WIGGLE_SCALE), MODIFIER_SOURCE_WIGGLE_SECONDS * 0.30)
		. set_trans(Tween.TRANS_BACK as Tween.TransitionType)
		. set_ease(Tween.EASE_OUT as Tween.EaseType)
	)
	tween.tween_property(slot, "rotation_degrees", -MODIFIER_SOURCE_WIGGLE_DEGREES, MODIFIER_SOURCE_WIGGLE_SECONDS * 0.18)
	tween.chain().tween_property(slot, "rotation_degrees", MODIFIER_SOURCE_WIGGLE_DEGREES, MODIFIER_SOURCE_WIGGLE_SECONDS * 0.28)
	tween.chain().tween_property(slot, "rotation_degrees", -MODIFIER_SOURCE_WIGGLE_DEGREES * 0.45, MODIFIER_SOURCE_WIGGLE_SECONDS * 0.22)
	tween.chain().set_parallel(true)
	tween.tween_property(slot, "rotation_degrees", 0.0, MODIFIER_SOURCE_WIGGLE_SECONDS * 0.30)
	tween.tween_property(slot, "scale", Vector2.ONE, MODIFIER_SOURCE_WIGGLE_SECONDS * 0.30)


func _highlight_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.86, 0.26, MASTERY_SOURCE_HIGHLIGHT_ALPHA)
	style.border_color = Color(1.0, 0.93, 0.48, MASTERY_SOURCE_HIGHLIGHT_BORDER_ALPHA)
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	return style


func _source_affects_orb_mastery(orb_id: int, modifiers: Dictionary) -> bool:
	var orb_bonus_by_id: Dictionary = modifiers.get("orb_bonus_by_id", {})
	if int(orb_bonus_by_id.get(orb_id, 0)) != 0:
		return true
	match orb_id:
		OrbType.Id.FIRE, OrbType.Id.ICE, OrbType.Id.EARTH:
			return (
				int(modifiers.get("flat_damage_bonus", 0)) != 0
				or int(modifiers.get("combo_flat_bonus", 0)) != 0
				or not is_equal_approx(float(modifiers.get("combo_multiplier_mult", 1.0)), 1.0)
			)
		OrbType.Id.ARMOR:
			return int(modifiers.get("start_turn_armor", 0)) != 0
		OrbType.Id.HEART:
			return int(modifiers.get("flat_heal_bonus", 0)) != 0
		OrbType.Id.GOLD:
			return int(modifiers.get("flat_gold_bonus", 0)) != 0
	return false
