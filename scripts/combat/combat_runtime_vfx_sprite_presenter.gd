extends RefCounted
class_name CombatRuntimeVfxSpritePresenter

var _vfx_layer: Control
var _timer_owner: Node
var _texture_factory: Variant
var _runtime_material: ShaderMaterial


func bind(dependencies: Dictionary) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_timer_owner = dependencies.get("timer_owner") as Node
	_texture_factory = dependencies.get("runtime_texture_factory")


func spawn_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = 0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _texture_factory == null:
		return null
	var texture: Texture2D = _texture_factory.texture(texture_key)
	return spawn_texture_local(name, texture, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func spawn_texture_local(name: String, texture: Texture2D, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = 0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if texture == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return null
	var sprite := TextureRect.new()
	sprite.name = name
	sprite.set_meta("effect_name", name)
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_SCALE as TextureRect.StretchMode
	sprite.material = _runtime_shader_material()
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.pivot_offset = draw_size * 0.5
	sprite.position = center_local - draw_size * 0.5
	sprite.rotation = rotation
	sprite.z_index = z_index
	sprite.modulate = Color(color.r, color.g, color.b, 0.0 if delay > 0.0 else color.a)
	_vfx_layer.add_child(sprite)
	_tween_effect_cleanup(sprite, lifetime, target_scale, delay, move_offset, spin, color.a, move_ease)
	return sprite


func _runtime_shader_material() -> ShaderMaterial:
	if _runtime_material != null:
		return _runtime_material
	var shader := Shader.new()
	shader.code = "\n".join([
		"shader_type canvas_item;",
		"render_mode blend_add, unshaded;",
		"void fragment() {",
		"	vec4 texel = texture(TEXTURE, UV);",
		"	COLOR = vec4(texel.rgb * COLOR.rgb, texel.a * COLOR.a);",
		"}",
	])
	_runtime_material = ShaderMaterial.new()
	_runtime_material.shader = shader
	return _runtime_material


func _tween_effect_cleanup(control: Control, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, target_alpha: float = 1.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if control == null:
		return
	var duration := maxf(0.12, lifetime)
	var tween_owner: Node = control if control.is_inside_tree() else _timer_owner
	if tween_owner == null or not is_instance_valid(tween_owner) or not tween_owner.is_inside_tree():
		return
	var start_position := control.position
	var start_rotation := control.rotation
	var tween := tween_owner.create_tween()
	tween.set_parallel(true)
	if delay > 0.0:
		tween.tween_property(control, "modulate:a", target_alpha, 0.05).set_delay(delay)
	tween.tween_property(control, "scale", target_scale, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(Tween.EASE_OUT as Tween.EaseType)
	if move_offset != Vector2.ZERO:
		tween.tween_property(control, "position", start_position + move_offset, duration).set_delay(delay).set_trans(Tween.TRANS_CUBIC as Tween.TransitionType).set_ease(move_ease)
	if not is_zero_approx(spin):
		tween.tween_property(control, "rotation", start_rotation + spin, duration).set_delay(delay)
	tween.tween_property(control, "modulate:a", 0.0, duration * 0.70).set_delay(delay + duration * 0.30)
	tween.finished.connect(func() -> void:
		if is_instance_valid(control):
			control.queue_free()
	)
