extends RefCounted
class_name CombatVfxRuntimeSpawner

const COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_texture_factory.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")

const POST_MATCH_EFFECT_Z_INDEX := 124
const POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST := 72
const POST_MATCH_MAX_SCREEN_RAYS := 18
const POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS := 10

var _vfx_layer: Control
var _visual_registry: Variant
var _timer_owner: Node
var _max_vfx_overlay: Variant
var _runtime_texture_factory: Variant = COMBAT_RUNTIME_VFX_TEXTURE_FACTORY_SCRIPT.new()
var _spark_burst_presenter: Variant
var _use_max_combat_vfx_callback: Callable = Callable()
var _juice_enabled_callback: Callable = Callable()


func bind(dependencies: Dictionary, callbacks: Dictionary = {}) -> void:
	_vfx_layer = dependencies.get("vfx_layer") as Control
	_visual_registry = dependencies.get("visual_registry")
	_timer_owner = dependencies.get("timer_owner") as Node
	_max_vfx_overlay = dependencies.get("max_vfx_overlay")
	_runtime_texture_factory = dependencies.get("runtime_texture_factory", _runtime_texture_factory)
	_spark_burst_presenter = dependencies.get("spark_burst_presenter")
	_use_max_combat_vfx_callback = callbacks.get("use_max_combat_vfx", Callable())
	_juice_enabled_callback = callbacks.get("juice_enabled", Callable())


func spawn_vfx(effect_name: String, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)) -> void:
	if _visual_registry == null:
		return
	var texture: Texture2D = _visual_registry.vfx_texture(effect_name)
	if texture == null:
		return
	spawn_vfx_texture(texture, global_center, draw_size, lifetime, modulate_color)


func spawn_vfx_texture(
	texture: Texture2D, global_center: Vector2, draw_size: Vector2, lifetime: float, modulate_color: Color = Color(1.0, 1.0, 1.0, 1.0)
) -> void:
	if texture == null or _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return
	if (
		_use_max_combat_vfx()
		and _juice_enabled(GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS)
		and _max_vfx_overlay != null
		and _max_vfx_overlay.spawn_generic(global_center, draw_size, lifetime, modulate_color)
	):
		return
	var sprite := TextureRect.new()
	sprite.texture = texture
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
	sprite.custom_minimum_size = draw_size
	sprite.size = draw_size
	sprite.modulate = modulate_color
	sprite.z_index = POST_MATCH_EFFECT_Z_INDEX
	_vfx_layer.add_child(sprite)
	var local_center := global_to_vfx_local(global_center)
	sprite.position = local_center - draw_size * 0.5
	_tween_fade_cleanup(sprite, lifetime)
	_spawn_visible_spark_burst(global_center, draw_size, modulate_color, lifetime)


func post_match_runtime_vfx_caps() -> Dictionary:
	return {
		"max_particles_per_burst": POST_MATCH_MAX_RUNTIME_PARTICLES_PER_BURST,
		"max_screen_rays": POST_MATCH_MAX_SCREEN_RAYS,
		"max_simultaneous_emitters": POST_MATCH_MAX_SIMULTANEOUS_RUNTIME_EMITTERS,
		"texture_keys": _runtime_texture_factory.texture_keys(),
	}


func post_match_runtime_texture(key: String) -> Texture2D:
	return _runtime_texture_factory.texture(key)


func global_to_vfx_local(global_position: Vector2) -> Vector2:
	if _vfx_layer == null or not is_instance_valid(_vfx_layer):
		return global_position
	var inverse_canvas := _vfx_layer.get_global_transform_with_canvas().affine_inverse()
	return inverse_canvas * global_position


func _use_max_combat_vfx() -> bool:
	return _use_max_combat_vfx_callback.is_valid() and bool(_use_max_combat_vfx_callback.call())


func _juice_enabled(flag_key: String) -> bool:
	return _juice_enabled_callback.is_valid() and bool(_juice_enabled_callback.call(flag_key))


func _spawn_visible_spark_burst(global_center: Vector2, draw_size: Vector2, color: Color, lifetime: float) -> void:
	if _spark_burst_presenter != null:
		_spark_burst_presenter.spawn_visible_spark_burst(global_center, draw_size, color, lifetime)


func _tween_fade_cleanup(control: Control, lifetime: float) -> void:
	if control == null:
		return
	var duration := maxf(0.08, lifetime)
	if _timer_owner == null or not is_instance_valid(_timer_owner) or not _timer_owner.is_inside_tree():
		control.queue_free()
		return
	var tween := _timer_owner.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	tween.finished.connect(
		func() -> void:
			if is_instance_valid(control):
				control.queue_free()
	)
