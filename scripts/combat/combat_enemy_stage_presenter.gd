extends RefCounted
class_name CombatEnemyStagePresenter

const FALLBACK_PANEL_RECT := Rect2(Vector2.ZERO, Vector2(1048.0, 432.0))

var _enemy_stage: Control = null
var _enemy_portrait: TextureRect = null
var _visuals: Variant = null
var _backdrop: TextureRect = null
var _ground_shadow: Panel = null
var _text_scrim: ColorRect = null


func bind(enemy_stage: Control, enemy_portrait: TextureRect, visuals: Variant = null) -> void:
	_enemy_stage = enemy_stage
	_enemy_portrait = enemy_portrait
	_visuals = visuals


func ensure_nodes() -> void:
	ensure_backdrop()
	ensure_ground_shadow()
	ensure_text_scrim()


func ensure_backdrop() -> void:
	if _enemy_stage == null:
		return
	if _backdrop != null and is_instance_valid(_backdrop):
		_reparent_to_stage(_backdrop)
		_enemy_stage.move_child(_backdrop, 0)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyStageBackdrop")
	if existing is TextureRect:
		_backdrop = existing as TextureRect
	else:
		_backdrop = TextureRect.new()
		_backdrop.name = "EnemyStageBackdrop"
		_enemy_stage.add_child(_backdrop)
	_backdrop.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_backdrop.expand_mode = TextureRect.ExpandMode.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_backdrop.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_backdrop.modulate = Color(1.0, 1.0, 1.0, 0.94)
	_backdrop.visible = true
	_enemy_stage.move_child(_backdrop, 0)


func ensure_ground_shadow() -> void:
	if _enemy_stage == null:
		return
	if _ground_shadow != null and is_instance_valid(_ground_shadow):
		_reparent_to_stage(_ground_shadow)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyGroundShadow")
	if existing is Panel:
		_ground_shadow = existing as Panel
	else:
		_ground_shadow = Panel.new()
		_ground_shadow.name = "EnemyGroundShadow"
		_enemy_stage.add_child(_ground_shadow)
	_ground_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_ground_shadow.z_index = 1
	_ground_shadow.visible = true


func ensure_text_scrim() -> void:
	if _enemy_stage == null:
		return
	if _text_scrim != null and is_instance_valid(_text_scrim):
		_reparent_to_stage(_text_scrim)
		return
	var existing := _enemy_stage.get_node_or_null("EnemyTextScrim")
	if existing is ColorRect:
		_text_scrim = existing as ColorRect
	else:
		_text_scrim = ColorRect.new()
		_text_scrim.name = "EnemyTextScrim"
		_enemy_stage.add_child(_text_scrim)
	_text_scrim.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_text_scrim.color = Color(0.02, 0.04, 0.06, 0.72)
	_text_scrim.visible = true


func apply_visual_profile(enemy_id: String, enemy_panel_rect: Rect2 = FALLBACK_PANEL_RECT) -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	var stage_size := _enemy_stage.size if _enemy_stage != null else Vector2.ZERO
	if stage_size.x <= 0.0 or stage_size.y <= 0.0:
		stage_size = enemy_panel_rect.size
	var profile := {}
	if _visuals != null and _visuals.has_method("enemy_visual_profile"):
		profile = Dictionary(_visuals.enemy_visual_profile(enemy_id))
	var scale := float(profile.get("scale", 1.0))
	var offset: Vector2 = profile.get("offset", Vector2.ZERO)
	var shadow_scale := float(profile.get("shadow_scale", 1.0))
	var shadow_alpha := float(profile.get("shadow_alpha", 0.34))

	_enemy_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	_enemy_portrait.position = offset
	_enemy_portrait.size = stage_size
	_enemy_portrait.pivot_offset = stage_size * 0.5
	_enemy_portrait.scale = Vector2(scale, scale)
	_enemy_portrait.z_index = 2
	if _backdrop != null and is_instance_valid(_backdrop):
		_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS as CanvasItem.TextureFilter
	if _text_scrim != null and is_instance_valid(_text_scrim):
		_text_scrim.z_index = 3

	ensure_ground_shadow()
	if _ground_shadow == null or not is_instance_valid(_ground_shadow):
		return
	var shadow_size := Vector2(stage_size.x * 0.36 * shadow_scale, maxf(30.0, stage_size.y * 0.11 * shadow_scale))
	_ground_shadow.position = Vector2((stage_size.x - shadow_size.x) * 0.5, stage_size.y * 0.73)
	_ground_shadow.size = shadow_size
	_ground_shadow.z_index = 1
	_ground_shadow.visible = _enemy_portrait.visible
	var shadow_style := StyleBoxFlat.new()
	shadow_style.bg_color = Color(0.0, 0.0, 0.0, clampf(shadow_alpha, 0.0, 0.65))
	shadow_style.border_color = Color(0.0, 0.0, 0.0, 0.0)
	shadow_style.set_corner_radius_all(999)
	_ground_shadow.add_theme_stylebox_override("panel", shadow_style)


func backdrop() -> TextureRect:
	return _backdrop


func ground_shadow() -> Panel:
	return _ground_shadow


func text_scrim() -> ColorRect:
	return _text_scrim


func _reparent_to_stage(node: Control) -> void:
	if _enemy_stage == null or node.get_parent() == _enemy_stage:
		return
	var existing_parent := node.get_parent()
	if existing_parent != null:
		existing_parent.remove_child(node)
	_enemy_stage.add_child(node)
