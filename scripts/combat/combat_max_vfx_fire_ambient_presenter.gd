extends RefCounted
class_name CombatMaxVfxFireAmbientPresenter

var _atmospheric_available_provider: Callable
var _layer_size_provider: Callable
var _atmospheric_flipbook_spawner: Callable
var _flipbook_spawner: Callable
var _light_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_atmospheric_available_provider = dependencies.get("atmospheric_available_provider", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())
	_flipbook_spawner = dependencies.get("flipbook_spawner", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())


func spawn_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if not _atmospheric_vfx_available():
		return
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var screen_center := layer_size * 0.5
	var attack_focus_y := clampf(center.y, layer_size.y * 0.10, layer_size.y * 0.52)
	var attack_focus := Vector2(layer_size.x * 0.5, attack_focus_y)
	var full_screen := Vector2(layer_size.x * 1.24, layer_size.y * 1.14)
	var top_screen := Vector2(layer_size.x * 1.16, layer_size.y * 0.58)
	_spawn_atmospheric_flipbook("fog", screen_center, full_screen * Vector2(1.16, 1.04), lifetime * 1.22, Color(1.0, 0.12, 0.03, 0.30 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.025), 1.02, -0.90, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", screen_center, full_screen, lifetime * 1.28, Color(1.0, 0.24, 0.04, 0.78 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.070), 1.04, -0.45, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", screen_center + Vector2(0.0, layer_size.y * 0.08), full_screen * Vector2(1.10, 0.96), lifetime * 1.08, Color(1.0, 0.48, 0.12, 0.52 * alpha_scale), delay + lifetime * 0.05, Vector2(0.0, -layer_size.y * 0.090), 0.98, 0.20, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", attack_focus, top_screen, lifetime * 1.14, Color(1.0, 0.16, 0.02, 0.64 * alpha_scale), delay + lifetime * 0.02, Vector2(0.0, -layer_size.y * 0.055), 1.03, 0.50, 0.0, 2)
	_spawn_atmospheric_flipbook("embers", attack_focus + Vector2(0.0, -layer_size.y * 0.05), top_screen * Vector2(0.92, 0.66), lifetime * 0.94, Color(1.0, 0.26, 0.04, 0.30 * alpha_scale), delay + lifetime * 0.09, Vector2(0.0, layer_size.y * 0.040), 0.94, 0.38, 0.0, 1)
	_spawn_light(screen_center, Color(1.0, 0.20, 0.03, 1.0), 2.5 + float(intensity) * 0.20, layer_size.x * 1.05, lifetime * 0.78)


func spawn_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	if not _atmospheric_vfx_available():
		return
	var count := 6 + mini(18, intensity * 2 + tier * 3)
	for i in range(count):
		var angle := TAU * float(i) / float(count) + sin(float(i) * 1.37) * 0.36
		var direction := Vector2(cos(angle), sin(angle))
		var start := center + direction * radius * (0.08 + float(i % 3) * 0.015)
		var travel := direction * radius * (0.34 + float(i % 5) * 0.055)
		travel.y -= radius * (0.10 + float(i % 4) * 0.025)
		var size := Vector2(52.0 + float(intensity) * 5.0, 34.0 + float(intensity) * 3.0) * (1.0 + float(tier) * 0.08)
		var spark_delay := delay + float(i % 6) * lifetime * 0.018
		var alpha := 0.36 + float(tier) * 0.05
		_spawn_atmospheric_flipbook("embers", start, size, lifetime * (0.48 + float(i % 4) * 0.045), Color(1.0, 0.40, 0.10, alpha), spark_delay, travel, 0.42, 2.6, angle, 1)


func spawn_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	if not _atmospheric_vfx_available() or delta.length() <= 1.0:
		return
	var length := delta.length()
	var normal := Vector2(-delta.y, delta.x).normalized()
	var center := source + delta * 0.50
	var lane_height := maxf(104.0 + float(intensity) * 11.0, length * (0.22 + float(tier) * 0.018))
	var lane_length := length * (0.96 + float(tier) * 0.035)
	_spawn_atmospheric_flipbook("embers", center, Vector2(lane_length, lane_height), travel_duration * 1.20, Color(1.0, 0.38, 0.10, 0.48), launch_delay, Vector2.ZERO, 1.02, 1.05, angle, 1)
	if tier >= 2:
		_spawn_atmospheric_flipbook("embers", center + normal * (10.0 + float(intensity) * 1.4), Vector2(lane_length * 0.82, lane_height * 0.66), travel_duration * 0.94, Color(1.0, 0.44, 0.14, 0.32), launch_delay + travel_duration * 0.09, Vector2.ZERO, 0.94, 1.12, angle + 0.05, 1)
	if tier >= 3:
		_spawn_atmospheric_flipbook("embers", center, Vector2(lane_length * 1.18, lane_height * 1.38), travel_duration * 1.28, Color(1.0, 0.22, 0.04, 0.34), launch_delay, Vector2.ZERO, 1.05, 0.72, angle, 2)


func spawn_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	if not _atmospheric_vfx_available():
		return
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0 or layer_size.y <= 1.0:
		return
	var focus_y := clampf(center.y, layer_size.y * 0.08, layer_size.y * 0.44)
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var aurora_size := Vector2(layer_size.x * (1.05 + float(maxi(0, intensity - 5)) * 0.035), layer_size.y * (0.34 + float(mini(intensity, 8)) * 0.016))
	_spawn_atmospheric_flipbook("aurora", focus, aurora_size, lifetime * 1.24, Color(1.0, 0.40, 0.16, 0.36 * alpha_scale), delay, Vector2(0.0, -layer_size.y * 0.025), 1.03, -1.85, 0.0, 1)
	_spawn_atmospheric_flipbook("godrays", focus + Vector2(0.0, -layer_size.y * 0.02), Vector2(layer_size.x * 0.92, layer_size.y * 0.30), lifetime * 0.86, Color(1.0, 0.32, 0.08, 0.24 * alpha_scale), delay + lifetime * 0.03, Vector2(0.0, -layer_size.y * 0.02), 0.82, -1.70, 0.0, 1)
	_spawn_atmospheric_flipbook("embers", focus + Vector2(0.0, layer_size.y * 0.02), Vector2(layer_size.x * 0.98, layer_size.y * 0.26), lifetime * 1.08, Color(1.0, 0.22, 0.04, 0.32 * alpha_scale), delay + lifetime * 0.04, Vector2(0.0, -layer_size.y * 0.035), 1.02, -1.55, 0.0, 2)
	var ray_count := 5 + mini(5, intensity)
	for i in range(ray_count):
		var progress := float(i) / float(maxi(1, ray_count - 1))
		var ray_y := focus_y + (progress - 0.50) * layer_size.y * 0.22
		var ray_width := layer_size.x * (0.72 + float(i % 3) * 0.10)
		var ray_delay := delay + lifetime * (0.05 + float(i % 4) * 0.025)
		_spawn_flipbook("light_rays", Vector2(layer_size.x * 0.5, ray_y), Vector2(ray_width, 46.0 + float(intensity) * 4.0), lifetime * 0.52, Color(1.0, 0.34, 0.08, 0.34 * alpha_scale), ray_delay, Vector2(sin(float(i)) * 32.0, -10.0), 0.58, -1.25, -0.18 + sin(float(i)) * 0.20)


func _atmospheric_vfx_available() -> bool:
	if _atmospheric_available_provider.is_valid():
		return bool(_atmospheric_available_provider.call())
	return false


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
	if _atmospheric_flipbook_spawner.is_valid():
		_atmospheric_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)


func _spawn_flipbook(key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float) -> void:
	if _flipbook_spawner.is_valid():
		_flipbook_spawner.call(key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, lifetime: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, lifetime)
