extends RefCounted
class_name CombatMaxVfxElementalRecipeGateway

var _presenters: Dictionary = {}
var _elemental_recipe_policy: Variant


func bind(presenters: Dictionary, elemental_recipe_policy: Variant) -> void:
	_presenters = presenters
	_elemental_recipe_policy = elemental_recipe_policy


func callbacks() -> Dictionary:
	return {
		"fire_vfx_tier": Callable(self, "fire_vfx_tier"),
		"ice_vfx_tier": Callable(self, "ice_vfx_tier"),
		"earth_vfx_tier": Callable(self, "earth_vfx_tier"),
		"replay_impact_basis_size": Callable(self, "replay_impact_basis_size"),
		"spawn_fire_replay_layers": Callable(self, "spawn_fire_replay_layers"),
		"spawn_fire_cast_layers": Callable(self, "spawn_fire_cast_layers"),
		"spawn_fire_beam_layers": Callable(self, "spawn_fire_beam_layers"),
		"spawn_fire_ember_lane": Callable(self, "spawn_fire_ember_lane"),
		"spawn_fireball_spell_layers": Callable(self, "spawn_fireball_spell_layers"),
		"spawn_fireball_impact_layers": Callable(self, "spawn_fireball_impact_layers"),
		"spawn_fire_meteor_attack_layers": Callable(self, "spawn_fire_meteor_attack_layers"),
		"spawn_fire_meteor_impact_layers": Callable(self, "spawn_fire_meteor_impact_layers"),
		"spawn_fire_fragmented_impact_cluster": Callable(self, "spawn_fire_fragmented_impact_cluster"),
		"spawn_fire_screen_ember_field": Callable(self, "spawn_fire_screen_ember_field"),
		"spawn_fire_spark_spray": Callable(self, "spawn_fire_spark_spray"),
		"spawn_fire_aurora_layer": Callable(self, "spawn_fire_aurora_layer"),
		"spawn_ice_replay_layers": Callable(self, "spawn_ice_replay_layers"),
		"spawn_ice_cast_layers": Callable(self, "spawn_ice_cast_layers"),
		"spawn_windy_ice_block_travel_layers": Callable(self, "spawn_windy_ice_block_travel_layers"),
		"spawn_earth_replay_layers": Callable(self, "spawn_earth_replay_layers"),
		"spawn_earth_cast_layers": Callable(self, "spawn_earth_cast_layers"),
		"spawn_earth_fracture_travel_layers": Callable(self, "spawn_earth_fracture_travel_layers"),
	}


func fire_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.fire_tier(intensity, screen_wide)


func ice_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.ice_tier(intensity, screen_wide)


func earth_vfx_tier(intensity: int, screen_wide: bool = false) -> int:
	return _elemental_recipe_policy.earth_tier(intensity, screen_wide)


func replay_impact_basis_size(kind: String, draw_size: Vector2, fallback_size: float) -> float:
	return _elemental_recipe_policy.replay_impact_basis_size(kind, draw_size, fallback_size)


func spawn_fire_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("fire_recipe").spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_fire_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_presenter("fire_recipe").spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func spawn_fire_beam_layers(source: Vector2, delta: Vector2, duration: float, intensity: int, angle: float) -> void:
	_presenter("fire_recipe").spawn_beam_layers(source, delta, duration, intensity, angle)


func spawn_fire_ember_lane(source: Vector2, delta: Vector2, launch_delay: float, travel_duration: float, intensity: int, angle: float, tier: int) -> void:
	_presenter("fire_ambient").spawn_ember_lane(source, delta, launch_delay, travel_duration, intensity, angle, tier)


func spawn_fireball_spell_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	source_size: Vector2,
	impact_size: Vector2,
	launch_delay: float,
	travel_duration: float,
	intensity: int,
	angle: float
) -> void:
	_presenter("fire_attack").spawn_fireball_spell_layers(source, target, delta, source_size, impact_size, launch_delay, travel_duration, intensity, angle)


func spawn_fireball_impact_layers(center: Vector2, impact_size: Vector2, duration: float, intensity: int, max_size: float) -> void:
	_presenter("fire_impact").spawn_fireball_impact_layers(center, impact_size, duration, intensity, max_size)


func spawn_fire_meteor_attack_layers(target: Vector2, launch_delay: float, travel_duration: float, intensity: int, impact_size: Vector2) -> void:
	_presenter("fire_attack").spawn_meteor_attack_layers(target, launch_delay, travel_duration, intensity, impact_size)


func spawn_fire_meteor_impact_layers(
	center: Vector2, impact_size: Vector2, duration: float, intensity: int, delay: float, fragmented_wide: bool = false
) -> void:
	_presenter("fire_impact").spawn_meteor_impact_layers(center, impact_size, duration, intensity, delay, fragmented_wide)


func spawn_fire_fragmented_impact_cluster(
	center: Vector2, draw_size: Vector2, duration: float, intensity: int, delay: float, alpha_scale: float = 1.0, rotation: float = 0.0
) -> void:
	_presenter("fire_impact").spawn_fragmented_impact_cluster(center, draw_size, duration, intensity, delay, alpha_scale, rotation)


func spawn_fire_screen_ember_field(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_presenter("fire_ambient").spawn_screen_ember_field(center, lifetime, intensity, delay, alpha_scale)


func spawn_fire_spark_spray(center: Vector2, radius: float, lifetime: float, intensity: int, delay: float, tier: int) -> void:
	_presenter("fire_ambient").spawn_spark_spray(center, radius, lifetime, intensity, delay, tier)


func spawn_fire_aurora_layer(center: Vector2, lifetime: float, intensity: int, delay: float, alpha_scale: float) -> void:
	_presenter("fire_ambient").spawn_aurora_layer(center, lifetime, intensity, delay, alpha_scale)


func spawn_ice_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("ice_recipe").spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_ice_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_presenter("ice_recipe").spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func spawn_windy_ice_block_travel_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	normal: Vector2,
	source_size: Vector2,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	angle: float
) -> void:
	_presenter("ice_recipe").spawn_windy_block_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle)


func spawn_earth_replay_layers(
	center: Vector2, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> void:
	_presenter("earth_recipe").spawn_replay_layers(center, draw_size, max_size, base_size, duration, intensity, screen_wide)


func spawn_earth_cast_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	spool_size: Vector2,
	spool_duration: float,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	core: Color
) -> void:
	_presenter("earth_recipe").spawn_cast_layers(source, target, delta, spool_size, spool_duration, travel_duration, launch_delay, intensity, core)


func spawn_earth_fracture_travel_layers(
	source: Vector2,
	target: Vector2,
	delta: Vector2,
	normal: Vector2,
	source_size: Vector2,
	travel_duration: float,
	launch_delay: float,
	intensity: int,
	angle: float,
	tier: int
) -> void:
	_presenter("earth_recipe").spawn_fracture_travel_layers(source, target, delta, normal, source_size, travel_duration, launch_delay, intensity, angle, tier)


func _presenter(key: String) -> Variant:
	return _presenters.get(key)
