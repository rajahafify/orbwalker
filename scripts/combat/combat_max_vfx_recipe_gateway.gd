extends RefCounted
class_name CombatMaxVfxRecipeGateway

var _presenters: Dictionary = {}


func bind(presenters: Dictionary) -> void:
	_presenters = presenters


func callbacks() -> Dictionary:
	return {
		"spawn_status_replay_recipe": Callable(self, "spawn_status_replay_recipe"),
		"spawn_status_armor_linger": Callable(self, "spawn_status_armor_linger"),
		"spawn_status_cast_recipe": Callable(self, "spawn_status_cast_recipe"),
		"spawn_status_beam_recipe": Callable(self, "spawn_status_beam_recipe"),
		"spawn_status_path_afterimage": Callable(self, "spawn_status_path_afterimage"),
		"spawn_status_screen_wide": Callable(self, "spawn_status_screen_wide"),
		"spawn_atmospheric_replay_layer": Callable(self, "spawn_atmospheric_replay_layer"),
		"spawn_atmospheric_travel": Callable(self, "spawn_atmospheric_travel"),
		"spawn_elemental_replay_recipe": Callable(self, "spawn_elemental_replay_recipe"),
		"spawn_elemental_cast_recipe": Callable(self, "spawn_elemental_cast_recipe"),
		"spawn_elemental_beam_recipe": Callable(self, "spawn_elemental_beam_recipe"),
		"spawn_elemental_path_afterimage": Callable(self, "spawn_elemental_path_afterimage"),
		"spawn_elemental_screen_wide": Callable(self, "spawn_elemental_screen_wide"),
		"pack_impact_scene_key": Callable(self, "pack_impact_scene_key"),
		"pack_hit_scene_key": Callable(self, "pack_hit_scene_key"),
		"spawn_pack_screen_wide": Callable(self, "spawn_pack_screen_wide"),
	}


func spawn_status_replay_recipe(
	kind: String, center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("status_recipe").spawn_replay_recipe(kind, center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_status_armor_linger(center: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	_presenter("status_recipe").spawn_armor_linger(center, draw_size, lifetime, intensity)


func spawn_status_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color,
	accent: Color
) -> void:
	_presenter("status_recipe").spawn_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core, accent)


func spawn_status_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_presenter("status_recipe").spawn_beam_recipe(kind, source, delta, lifetime, intensity, angle)


func spawn_status_path_afterimage(
	kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float
) -> void:
	_presenter("status_recipe").spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func spawn_status_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_presenter("status_recipe").spawn_screen_wide(kind, center, lifetime, intensity)


func spawn_atmospheric_replay_layer(
	kind: String, center: Vector2, max_size: float, base_size: float, lifetime: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("atmospheric_recipe").spawn_replay_layer(kind, center, max_size, base_size, lifetime, intensity, screen_wide)


func spawn_atmospheric_travel(kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float) -> void:
	_presenter("atmospheric_recipe").spawn_travel(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func spawn_elemental_replay_recipe(
	kind: String, center: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("elemental_recipe").spawn_replay_recipe(kind, center, max_size, base_size, duration, intensity, screen_wide)


func spawn_elemental_cast_recipe(
	kind: String,
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_lifetime: float,
	travel_lifetime: float,
	intensity: int,
	core: Color
) -> void:
	_presenter("elemental_recipe").spawn_cast_recipe(kind, source, target, delta, spool_size, spool_lifetime, travel_lifetime, intensity, core)


func spawn_elemental_beam_recipe(kind: String, source: Vector2, delta: Vector2, lifetime: float, intensity: int, angle: float) -> void:
	_presenter("elemental_recipe").spawn_beam_layers(kind, source, delta, lifetime, intensity, angle)


func spawn_elemental_path_afterimage(
	kind: String, source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float
) -> void:
	_presenter("elemental_recipe").spawn_path_afterimage(kind, source, delta, launch_delay, travel_duration, intensity, angle)


func spawn_elemental_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_presenter("elemental_recipe").spawn_screen_wide(kind, center, lifetime, intensity)


func pack_impact_scene_key(kind: String, intensity: int, screen_wide: bool) -> String:
	return _presenter("pack_recipe").impact_scene_key(kind, intensity, screen_wide)


func pack_hit_scene_key(kind: String) -> String:
	return _presenter("pack_recipe").hit_scene_key(kind)


func spawn_pack_screen_wide(kind: String, center: Vector2, lifetime: float, intensity: int) -> void:
	_presenter("pack_recipe").spawn_screen_wide(kind, center, lifetime, intensity)


func _presenter(key: String) -> Variant:
	return _presenters.get(key)
