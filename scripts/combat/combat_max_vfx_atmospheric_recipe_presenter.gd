extends RefCounted
class_name CombatMaxVfxAtmosphericRecipePresenter

var _atmospheric_available_provider: Callable
var _kind_cleaner: Callable
var _kind_colors_provider: Callable
var _atmospheric_travel_key_provider: Callable
var _atmospheric_impact_key_provider: Callable
var _atmospheric_secondary_key_provider: Callable
var _atmospheric_flipbook_spawner: Callable


func bind(dependencies: Dictionary) -> void:
	_atmospheric_available_provider = dependencies.get("atmospheric_available_provider", Callable())
	_kind_cleaner = dependencies.get("kind_cleaner", Callable())
	_kind_colors_provider = dependencies.get("kind_colors_provider", Callable())
	_atmospheric_travel_key_provider = dependencies.get("atmospheric_travel_key_provider", Callable())
	_atmospheric_impact_key_provider = dependencies.get("atmospheric_impact_key_provider", Callable())
	_atmospheric_secondary_key_provider = dependencies.get("atmospheric_secondary_key_provider", Callable())
	_atmospheric_flipbook_spawner = dependencies.get("atmospheric_flipbook_spawner", Callable())


func spawn_replay_layer(kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool) -> void:
	if not _atmospheric_vfx_available():
		return
	var clean_kind := _clean_kind(kind)
	var key := _atmospheric_impact_key(clean_kind)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var wide := Vector2(base_size * (1.26 if screen_wide else 0.82), base_size * (0.74 if screen_wide else 0.48))
	if clean_kind in ["heart", "armor", "gold"]:
		wide = Vector2(base_size * (1.05 if screen_wide else 0.72), base_size * (0.88 if screen_wide else 0.62))
	if clean_kind == "earth":
		wide *= Vector2(1.12, 0.76)
	_spawn_atmospheric_flipbook(key, center, wide, lifetime * 1.06, Color(core.r, core.g, core.b, 0.34), 0.0, Vector2.ZERO, 1.04, 0.55, 0.0, 1)
	if intensity >= 5:
		var secondary := _atmospheric_secondary_key(clean_kind)
		_spawn_atmospheric_flipbook(secondary, center + Vector2(0.0, -max_size * 0.10), wide * Vector2(1.12, 0.76), lifetime * 0.88, Color(accent.r, accent.g, accent.b, 0.24), lifetime * 0.04, Vector2(0.0, -max_size * 0.06), 0.96, 0.42, sin(float(intensity)) * 0.10, 1)


func spawn_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	if not _atmospheric_vfx_available() or delta.length() <= 1.0:
		return
	var clean_kind := _clean_kind(kind)
	var colors := _kind_colors(clean_kind)
	var core: Color = colors.get("core", Color.WHITE)
	var accent: Color = colors.get("accent", Color.WHITE)
	var length := delta.length()
	var lane_height := maxf(78.0 + float(intensity) * 12.0, length * (0.18 + float(intensity) * 0.008))
	var lane_length := length * (0.92 + float(intensity) * 0.035)
	var center := source + delta * 0.50
	if clean_kind == "earth":
		lane_height *= 1.16
		center += Vector2(0.0, 16.0)
	elif clean_kind == "heart":
		center += Vector2(0.0, -12.0)
	elif clean_kind == "armor":
		lane_height *= 1.08
	var key := _atmospheric_travel_key(clean_kind)
	_spawn_atmospheric_flipbook(key, center, Vector2(lane_length, lane_height), travel_duration * 1.20, Color(core.r, core.g, core.b, 0.46), launch_delay, Vector2.ZERO, 1.02, 1.15, angle, 1)
	if intensity >= 4:
		var secondary_key := _atmospheric_secondary_key(clean_kind)
		var normal := Vector2(-delta.y, delta.x).normalized()
		_spawn_atmospheric_flipbook(secondary_key, center + normal * (10.0 + float(intensity) * 1.8), Vector2(lane_length * 0.86, lane_height * 0.72), travel_duration * 1.00, Color(accent.r, accent.g, accent.b, 0.32), launch_delay + travel_duration * 0.10, Vector2.ZERO, 0.96, 1.0, angle + 0.05, 1)
	if intensity >= 7:
		_spawn_atmospheric_flipbook(key, center, Vector2(lane_length * 1.20, lane_height * 1.28), travel_duration * 1.32, Color(core.r, core.g, core.b, 0.26), launch_delay, Vector2.ZERO, 1.04, 0.80, angle, 1)


func _atmospheric_vfx_available() -> bool:
	if _atmospheric_available_provider.is_valid():
		return bool(_atmospheric_available_provider.call())
	return false


func _clean_kind(kind: String) -> String:
	if _kind_cleaner.is_valid():
		return String(_kind_cleaner.call(kind))
	return kind.strip_edges().to_lower()


func _kind_colors(kind: String) -> Dictionary:
	if _kind_colors_provider.is_valid():
		return _kind_colors_provider.call(kind)
	return {}


func _atmospheric_travel_key(kind: String) -> String:
	if _atmospheric_travel_key_provider.is_valid():
		return String(_atmospheric_travel_key_provider.call(kind))
	return "magic_wind"


func _atmospheric_impact_key(kind: String) -> String:
	if _atmospheric_impact_key_provider.is_valid():
		return String(_atmospheric_impact_key_provider.call(kind))
	return "fog"


func _atmospheric_secondary_key(kind: String) -> String:
	if _atmospheric_secondary_key_provider.is_valid():
		return String(_atmospheric_secondary_key_provider.call(kind))
	return "fog"


func _spawn_atmospheric_flipbook(sheet_key: String, center_local: Vector2, draw_size: Vector2, lifetime: float, color: Color, delay: float, move_offset: Vector2, target_scale: float, z: float, rotation: float, loops: int) -> void:
	if _atmospheric_flipbook_spawner.is_valid():
		_atmospheric_flipbook_spawner.call(sheet_key, center_local, draw_size, lifetime, color, delay, move_offset, target_scale, z, rotation, loops)
