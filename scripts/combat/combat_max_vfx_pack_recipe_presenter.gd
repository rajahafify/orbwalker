extends RefCounted
class_name CombatMaxVfxPackRecipePresenter

var _kind_cleaner: Callable
var _layer_size_provider: Callable
var _pack_effect_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_kind_cleaner = dependencies.get("kind_cleaner", Callable())
	_layer_size_provider = dependencies.get("layer_size_provider", Callable())
	_pack_effect_spawner = dependencies.get("pack_effect_spawner", Callable())


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
	_spawn_pack_effect("hit_01", focus + Vector2(layer_size.x * 0.18, -layer_size.y * 0.03), clean_kind, size * 0.46, lifetime * 0.66, intensity, lifetime * 0.10, Vector2.ZERO, 0.22, 1.6, 0.54)
	_spawn_pack_effect("hit_02", focus - Vector2(layer_size.x * 0.20, -layer_size.y * 0.02), clean_kind, size * 0.40, lifetime * 0.62, intensity, lifetime * 0.16, Vector2.ZERO, -0.20, 1.7, 0.50)


func _clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func _vfx_layer_size() -> Vector2:
	if _layer_size_provider.is_valid():
		return _layer_size_provider.call()
	return Vector2.ZERO


func _spawn_pack_effect(scene_key: String, center_local: Vector2, kind: String, draw_size: Vector2, lifetime: float, intensity: int, delay: float, move_offset: Vector2, rotation: float, z: float, alpha: float) -> void:
	if _pack_effect_spawner.is_valid():
		_pack_effect_spawner.call(scene_key, center_local, kind, draw_size, lifetime, intensity, delay, move_offset, rotation, z, alpha)
