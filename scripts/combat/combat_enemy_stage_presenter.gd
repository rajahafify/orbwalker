extends RefCounted
class_name CombatEnemyStagePresenter

const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")
const DEFAULT_ENEMY_ID := "cavern_striker"
const FALLBACK_PANEL_RECT := Rect2(Vector2.ZERO, Vector2(1048.0, 432.0))

var _enemy_stage: Control = null
var _enemy_portrait: TextureRect = null
var _visuals: Variant = null
var _snapshot_nodes: Dictionary = {}
var _backdrop: TextureRect = null
var _ground_shadow: Panel = null
var _text_scrim: ColorRect = null
var _reaction_enabled := false
var _reaction_reduced_motion := false
var _attention_tween: Tween = null
var _hit_tween: Tween = null
var _base_portrait_position := Vector2.ZERO
var _base_portrait_scale := Vector2.ONE


func bind(enemy_stage: Control, enemy_portrait: TextureRect, visuals: Variant = null) -> void:
	_enemy_stage = enemy_stage
	_enemy_portrait = enemy_portrait
	_visuals = visuals


func bind_snapshot_nodes(nodes: Dictionary) -> void:
	_snapshot_nodes = nodes


func set_reaction_settings(enabled: bool, reduced_motion: bool) -> void:
	_reaction_enabled = enabled
	_reaction_reduced_motion = reduced_motion
	if not _reaction_enabled or _reaction_reduced_motion:
		_stop_attention_motion()
		_reset_reaction_visuals()
		return
	_start_attention_motion()


func play_hit_reaction(intensity: int = 1) -> void:
	if not _reaction_enabled or _reaction_reduced_motion:
		return
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	if _hit_tween != null and is_instance_valid(_hit_tween):
		_hit_tween.kill()
	_stop_attention_motion()
	_enemy_portrait.position = _base_portrait_position
	_enemy_portrait.scale = _base_portrait_scale
	var kick := clampf(6.0 + float(maxi(0, intensity)) * 1.8, 6.0, 22.0)
	var punch := clampf(1.04 + float(maxi(0, intensity)) * 0.006, 1.04, 1.14)
	_hit_tween = _enemy_portrait.create_tween()
	_hit_tween.tween_property(_enemy_portrait, "position", _base_portrait_position + Vector2(kick, -kick * 0.28), 0.055).set_trans(Tween.TRANS_BACK as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	_hit_tween.parallel().tween_property(_enemy_portrait, "scale", _base_portrait_scale * punch, 0.055).set_trans(Tween.TRANS_BACK as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	_hit_tween.tween_property(_enemy_portrait, "position", _base_portrait_position, 0.12).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	_hit_tween.parallel().tween_property(_enemy_portrait, "scale", _base_portrait_scale, 0.12).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	_hit_tween.finished.connect(func() -> void:
		_start_attention_motion()
	)


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
	_base_portrait_position = offset
	_base_portrait_scale = Vector2(scale, scale)
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


func apply_snapshot(snapshot: Dictionary, current_enemy_visual_id: String = DEFAULT_ENEMY_ID, enemy_panel_rect: Rect2 = FALLBACK_PANEL_RECT) -> Dictionary:
	var resolved_enemy_id := _resolved_enemy_id(snapshot, current_enemy_visual_id)
	ensure_backdrop()
	_apply_backdrop_texture(snapshot.get("enemy_stage_texture", null), resolved_enemy_id)
	_apply_enemy_portrait_texture(snapshot.get("enemy_portrait_texture", null), resolved_enemy_id)
	apply_visual_profile(resolved_enemy_id, enemy_panel_rect)
	_apply_enemy_stats(snapshot)
	_apply_reaction_state(snapshot)
	return {
		"enemy_id": resolved_enemy_id,
		"enemy_intent_preview": Dictionary(snapshot.get("enemy_intent_preview", {})),
	}


func ensure_backdrop_placeholder() -> void:
	ensure_backdrop()
	_apply_backdrop_texture(null, DEFAULT_ENEMY_ID)


func refresh_enemy_visuals(enemy_id: String, enemy_panel_rect: Rect2 = FALLBACK_PANEL_RECT) -> String:
	var resolved_enemy_id := enemy_id.strip_edges()
	if resolved_enemy_id == "":
		resolved_enemy_id = DEFAULT_ENEMY_ID
	ensure_backdrop()
	ensure_ground_shadow()
	_apply_backdrop_texture_for_enemy(resolved_enemy_id)
	_apply_enemy_portrait_texture_for_enemy(resolved_enemy_id)
	apply_visual_profile(resolved_enemy_id, enemy_panel_rect)
	return resolved_enemy_id


func backdrop() -> TextureRect:
	return _backdrop


func ground_shadow() -> Panel:
	return _ground_shadow


func text_scrim() -> ColorRect:
	return _text_scrim


func _resolved_enemy_id(snapshot: Dictionary, current_enemy_visual_id: String) -> String:
	var enemy_id := String(snapshot.get("enemy_id", current_enemy_visual_id)).strip_edges()
	if enemy_id == "":
		enemy_id = current_enemy_visual_id.strip_edges()
	if enemy_id == "":
		enemy_id = DEFAULT_ENEMY_ID
	return enemy_id


func _apply_backdrop_texture(raw_texture: Variant, _enemy_id: String) -> void:
	if _backdrop == null or not is_instance_valid(_backdrop):
		return
	var backdrop_texture := raw_texture as Texture2D
	if backdrop_texture == null and _visuals != null:
		backdrop_texture = _visuals.combat_enemy_stage_texture(DEFAULT_ENEMY_ID)
	if backdrop_texture == null:
		backdrop_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_backdrop.texture = backdrop_texture
	_backdrop.visible = true


func _apply_enemy_portrait_texture(raw_texture: Variant, _enemy_id: String) -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	var enemy_figure_texture := raw_texture as Texture2D
	if enemy_figure_texture == null and _visuals != null:
		enemy_figure_texture = _visuals.enemy_sprite(DEFAULT_ENEMY_ID)
	if enemy_figure_texture == null:
		enemy_figure_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_figure_texture
	_enemy_portrait.visible = true


func _apply_backdrop_texture_for_enemy(enemy_id: String) -> void:
	if _backdrop == null or not is_instance_valid(_backdrop):
		return
	var backdrop_texture: Texture2D = null
	if _visuals != null:
		backdrop_texture = _visuals.combat_enemy_stage_texture(enemy_id)
		if backdrop_texture == null:
			backdrop_texture = _visuals.combat_enemy_stage_texture(DEFAULT_ENEMY_ID)
	if backdrop_texture == null:
		backdrop_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_backdrop.texture = backdrop_texture
	_backdrop.visible = true


func _apply_enemy_portrait_texture_for_enemy(enemy_id: String) -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	var enemy_figure_texture: Texture2D = null
	if _visuals != null:
		enemy_figure_texture = _visuals.enemy_sprite(enemy_id)
		if enemy_figure_texture == null:
			enemy_figure_texture = _visuals.enemy_sprite(DEFAULT_ENEMY_ID)
	if enemy_figure_texture == null:
		enemy_figure_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_enemy_placeholder_texture()
	_enemy_portrait.texture = enemy_figure_texture
	_enemy_portrait.visible = true


func _apply_enemy_stats(snapshot: Dictionary) -> void:
	var enemy_hp_bar := _snapshot_nodes.get("enemy_hp_bar") as ProgressBar
	if enemy_hp_bar != null:
		enemy_hp_bar.max_value = float(maxi(1, int(snapshot.get("enemy_hp_max", 1))))
		enemy_hp_bar.value = float(int(snapshot.get("enemy_hp_value", 0)))
	var name_text := String(snapshot.get("enemy_name_text", "Enemy"))
	var enemy_name_label := _snapshot_nodes.get("enemy_name_label") as Label
	if enemy_name_label != null:
		enemy_name_label.text = name_text
	var enemy_label := _snapshot_nodes.get("enemy_label") as Label
	if enemy_label != null:
		enemy_label.text = name_text
	var enemy_hp_text_label := _snapshot_nodes.get("enemy_hp_text_label") as Label
	if enemy_hp_text_label != null:
		enemy_hp_text_label.text = String(snapshot.get("enemy_hp_text", "HP 0 / 0"))


func _apply_reaction_state(snapshot: Dictionary) -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	if not _reaction_enabled:
		_reset_reaction_visuals()
		return
	var hp_max := maxf(1.0, float(snapshot.get("enemy_hp_max", 1)))
	var hp_value := maxf(0.0, float(snapshot.get("enemy_hp_value", hp_max)))
	var low_hp := hp_value > 0.0 and hp_value / hp_max <= 0.25
	if low_hp:
		_enemy_portrait.modulate = Color(0.78, 0.66, 0.66, 1.0)
	elif _enemy_portrait.modulate != Color.WHITE:
		_enemy_portrait.modulate = Color.WHITE
	if _reaction_reduced_motion:
		_stop_attention_motion()
	else:
		_start_attention_motion()


func _start_attention_motion() -> void:
	if not _reaction_enabled or _reaction_reduced_motion:
		return
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	if _attention_tween != null and is_instance_valid(_attention_tween):
		return
	_attention_tween = _enemy_portrait.create_tween()
	_attention_tween.set_loops(0)
	_attention_tween.tween_property(_enemy_portrait, "position", _base_portrait_position + Vector2(0.0, -4.0), 0.74).set_trans(Tween.TRANS_SINE as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)
	_attention_tween.tween_property(_enemy_portrait, "position", _base_portrait_position, 0.74).set_trans(Tween.TRANS_SINE as Tween.TransitionType).set_ease(Tween.EASE_IN_OUT as Tween.EaseType)


func _stop_attention_motion() -> void:
	if _attention_tween != null and is_instance_valid(_attention_tween):
		_attention_tween.kill()
	_attention_tween = null
	if _enemy_portrait != null and is_instance_valid(_enemy_portrait):
		_enemy_portrait.position = _base_portrait_position


func _reset_reaction_visuals() -> void:
	if _enemy_portrait == null or not is_instance_valid(_enemy_portrait):
		return
	_enemy_portrait.modulate = Color.WHITE
	_enemy_portrait.position = _base_portrait_position
	_enemy_portrait.scale = _base_portrait_scale


func _reparent_to_stage(node: Control) -> void:
	if _enemy_stage == null or node.get_parent() == _enemy_stage:
		return
	var existing_parent := node.get_parent()
	if existing_parent != null:
		existing_parent.remove_child(node)
	_enemy_stage.add_child(node)
