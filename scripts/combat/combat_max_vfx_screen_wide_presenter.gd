extends RefCounted
class_name CombatMaxVfxScreenWidePresenter

var _kind_colors_provider: Callable
var _impact_key_provider: Callable
var _layer_size_provider: Callable
var _light_spawner: Callable
var _flipbook_spawner: Callable
var _coin_rain_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_impact_key_provider = dependencies.get("impact_key_provider", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_coin_rain_spawner = dependencies.get("coin_rain_spawner", Callable())


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var colors := _kind_colors(kind)
	var core: Color = colors.get("core", Color.WHITE)
	var offensive := kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.46 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 1.15, layer_size.y * (0.46 if offensive else 0.62))
	_spawn_light(focus, core, 3.0 + float(intensity) * 0.28, layer_size.x * 0.72, lifetime * 0.72)
	_spawn_flipbook(_impact_key(kind), focus, size, lifetime * 0.86, Color(1, 1, 1, 0.40), 0.0, Vector2.ZERO, 1.06, -2.0, 0.0)
	for i in range(7 + mini(intensity, 8)):
		var y := focus_y + (float(i) - 3.0) * layer_size.y * 0.045
		_spawn_flipbook("light_rays", Vector2(layer_size.x * 0.5, y), Vector2(layer_size.x * (0.72 + float(i % 3) * 0.10), 48 + intensity * 4), lifetime * 0.50, Color(core.r, core.g, core.b, 0.48), lifetime * (0.04 + float(i % 5) * 0.025), Vector2(sin(float(i)) * 34.0, -12.0), 0.48, -1.0, -0.22 + sin(float(i)) * 0.20)
	if kind == "gold":
		_spawn_coin_rain(focus, layer_size.x * 0.34, lifetime * 1.2, intensity, true)


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _impact_key(kind: String) -> String:
	if _impact_key_provider.is_valid():
		return String(_impact_key_provider.call(kind))
	return kind


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation)


func _spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, base_size, lifetime, intensity, screen_wide)
