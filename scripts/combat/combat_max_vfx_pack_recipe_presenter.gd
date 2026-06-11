extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxPackRecipePresenter

var _kind_cleaner: Callable
var _layer_size_provider: Callable
var _pack_effect_spawner: Callable
var _kind_colors_provider: Callable
var _light_spawner: Callable
var _coin_rain_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_cleaner = dependencies.get("kind_cleaner", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_pack_effect_spawner = dependencies.get("pack_effect_spawner", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_light_spawner = dependencies.get("light_spawner", Callable())
	_coin_rain_spawner = dependencies.get("coin_rain_spawner", Callable())


func supports_replay_impact(_kind: String, _screen_wide: bool = false) -> bool:
	return true


func spawn_replay_impact(
	center: Vector2, kind: String, _draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	var clean_kind := _clean_kind(kind)
	var impact_scene := impact_scene_key(clean_kind, intensity, screen_wide)
	var pack_size := Vector2(base_size, base_size) * (1.15 if screen_wide else 0.72)
	_spawn_pack_effect(impact_scene, center, clean_kind, pack_size, duration, intensity, 0.0, Vector2.ZERO, 0.0, 0.0, 1.0)
	_spawn_pack_effect(hit_scene_key(clean_kind), center, clean_kind, pack_size * 0.58, duration * 0.74, intensity, 0.035, Vector2.ZERO, 0.0, 1.2, 0.82)
	if screen_wide:
		spawn_screen_wide(clean_kind, center, duration, intensity)
	if clean_kind == "gold":
		_spawn_coin_rain(center, max_size, duration, intensity, screen_wide)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	_spawn_light(center, core, 2.4 + float(intensity) * 0.34, base_size * 1.15, duration * 0.65)
	return true


func impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	if screen_wide or intensity >= 6:
		return "big_impact_02" if _clean_kind(kind) in ["ice", "armor", "heart"] else "big_impact_01"
	match _clean_kind(kind):
		"ice", "armor", "heart":
			return "impact_02"
		"earth", "gold":
			return "impact_01"
	return "impact_01"


func hit_scene_key(kind: String) -> String:
	return "hit_02" if _clean_kind(kind) in ["ice", "armor", "heart"] else "hit_01"


func spawn_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	var layer_size := _vfx_layer_size()
	if layer_size.x <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var offensive := clean_kind in ["fire", "ice", "earth", "damage"]
	var focus_y := clampf(center.y, layer_size.y * (0.08 if offensive else 0.36), layer_size.y * (0.44 if offensive else 0.86))
	var focus := Vector2(layer_size.x * 0.5, focus_y)
	var size := Vector2(layer_size.x * 0.92, layer_size.y * (0.34 if offensive else 0.44))
	_spawn_pack_effect(impact_scene_key(clean_kind, intensity, true), focus, clean_kind, size, lifetime * 1.05, intensity, 0.0, Vector2.ZERO, 0.0, -1.4, 0.62)
	_spawn_pack_effect(
		"hit_01",
		focus + Vector2(layer_size.x * 0.18, -layer_size.y * 0.03),
		clean_kind,
		size * 0.46,
		lifetime * 0.66,
		intensity,
		lifetime * 0.10,
		Vector2.ZERO,
		0.22,
		1.6,
		0.54
	)
	_spawn_pack_effect(
		"hit_02",
		focus - Vector2(layer_size.x * 0.20, -layer_size.y * 0.02),
		clean_kind,
		size * 0.40,
		lifetime * 0.62,
		intensity,
		lifetime * 0.16,
		Vector2.ZERO,
		-0.20,
		1.7,
		0.50
	)


func _clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_pack_effect(
	scene_key: String,
	center_local: Vector2,
	kind: String,
	draw_size: Vector2,
	lifetime: float,
	intensity: int,
	delay: float,
	move_offset: Vector2,
	rotation: float,
	z: float,
	alpha: float
) -> void:
	if _pack_effect_spawner.is_valid():
		_pack_effect_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)


func _spawn_light(center: Vector2, color: Color, energy: float, radius: float, duration: float) -> void:
	if _light_spawner.is_valid():
		_light_spawner.call(center, color, energy, radius, duration)


func _spawn_coin_rain(center: Vector2, base_size: float, duration: float, intensity: int, screen_wide: bool) -> void:
	if _coin_rain_spawner.is_valid():
		_coin_rain_spawner.call(center, base_size, duration, intensity, screen_wide)


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}
