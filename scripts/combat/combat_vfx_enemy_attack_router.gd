extends RefCounted
class_name CombatVfxEnemyAttackRouter

var _max_vfx_overlay: Variant = null
var _enemy_attack_vfx_presenter: Variant = null
var _use_max_combat_vfx_callback: Callable = Callable()
var _spawn_replay_impact_callback: Callable = Callable()


func bind(dependencies: Dictionary, callbacks: Dictionary = {}) -> void:
	_max_vfx_overlay = dependencies.get("max_vfx_overlay")
	_enemy_attack_vfx_presenter = dependencies.get("enemy_attack_vfx_presenter")
	_use_max_combat_vfx_callback = callbacks.get("use_max_combat_vfx", Callable())
	_spawn_replay_impact_callback = callbacks.get("spawn_replay_impact", Callable())


func spawn_enemy_attack_cue(source_global: Vector2, lifetime: float = 0.26) -> void:
	if source_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_cue(source_global, lifetime):
		return
	_enemy_attack_vfx_presenter.spawn_cue(source_global, lifetime)


func spawn_enemy_attack_travel(source_global: Vector2, target_global: Vector2, lifetime: float = 0.28) -> void:
	if source_global == Vector2.ZERO or target_global == Vector2.ZERO:
		return
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_travel(source_global, target_global, lifetime):
		return
	_enemy_attack_vfx_presenter.spawn_travel(source_global, target_global, lifetime)


func spawn_enemy_attack_block_impact(target_global: Vector2, lifetime: float = 0.32, blocked_amount: int = 0) -> void:
	_spawn_replay_impact("armor", target_global, lifetime, blocked_amount)
	_enemy_attack_vfx_presenter.spawn_block_impact(target_global, lifetime)


func spawn_enemy_attack_impact(target_global: Vector2, blocked: bool, amount: int, lifetime: float = 0.32) -> void:
	if blocked:
		spawn_enemy_attack_block_impact(target_global, lifetime, amount)
	else:
		spawn_enemy_attack_hit_impact(target_global, lifetime, amount)


func spawn_enemy_attack_hit_impact(target_global: Vector2, lifetime: float = 0.32, hp_damage: int = 0) -> void:
	if _use_max_combat_vfx() and _max_vfx_overlay.spawn_enemy_attack_impact(target_global, false, hp_damage, lifetime):
		return
	_spawn_replay_impact("damage", target_global, lifetime, hp_damage)
	_enemy_attack_vfx_presenter.spawn_hit_impact(target_global, lifetime)


func _use_max_combat_vfx() -> bool:
	return _use_max_combat_vfx_callback.is_valid() and bool(_use_max_combat_vfx_callback.call())


func _spawn_replay_impact(kind: String, target_global: Vector2, lifetime: float, amount: int) -> void:
	if _spawn_replay_impact_callback.is_valid():
		_spawn_replay_impact_callback.call(target_global, kind, Vector2(90, 90), lifetime, amount)
