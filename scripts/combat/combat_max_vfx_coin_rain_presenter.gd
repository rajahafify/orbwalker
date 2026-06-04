extends RefCounted
class_name CombatMaxVfxCoinRainPresenter

var _layer_size_provider: Callable
var _flipbook_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())


func spawn_coin_rain(center: Vector2, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	var layer_size := _vfx_layer_size()
	var count := 24 + intensity * (8 if screen_wide else 5)
	for i in range(count):
		var spread := layer_size.x * 0.88 if screen_wide else base_size * 2.1
		var x := center.x + (float(i % 13) / 12.0 - 0.5) * spread + sin(float(i) * 1.9) * 22.0
		var y := -40.0 - float(i % 5) * 28.0 if screen_wide else center.y - base_size * (0.74 + float(i % 4) * 0.12)
		var travel_y := layer_size.y * (0.75 + float(i % 4) * 0.06) if screen_wide else base_size * (1.25 + float(i % 4) * 0.08)
		_spawn_flipbook("coin_spin", Vector2(x, y), Vector2(50 + intensity * 4, 50 + intensity * 4), lifetime * 1.05, Color(1.0, 0.86, 0.24, 0.96), float(i % 9) * lifetime * 0.020, Vector2(sin(float(i) * 2.4) * 36.0, travel_y), 0.76, 2.0, sin(float(i)) * 0.4, 1.4)


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, spin: float) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, spin)
