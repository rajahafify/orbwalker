extends RefCounted
class_name CombatVfxTargetResolver

var _view: Variant
var _vfx_presenter: Variant


func bind(dependencies: Dictionary, _callbacks: Dictionary = {}, _config: Dictionary = {}) -> void:
	_view = dependencies.get("view")
	_vfx_presenter = dependencies.get("vfx_presenter")


func replay_targets() -> Dictionary:
	var enemy_target := Vector2.ZERO
	var player_target := Vector2.ZERO
	var player_hp_target := Vector2.ZERO
	var player_hp_impact_size := Vector2(180, 76)
	var armor_target := Vector2.ZERO
	var armor_impact_size := Vector2(360, 360)
	if _view != null:
		enemy_target = _view.enemy_vfx_target_global(0.48)
		player_target = _view.player_vfx_target_global(0.64)
		player_hp_target = _view.player_hp_bar_vfx_target_global(0.50)
		armor_target = _view.board_vfx_target_global()
		var fullscreen_vfx_size: Vector2 = _view.board_fullscreen_vfx_size()
		if fullscreen_vfx_size.x > 0.0 and fullscreen_vfx_size.y > 0.0:
			var armor_extent := minf(fullscreen_vfx_size.x, fullscreen_vfx_size.y) * 0.34
			armor_impact_size = Vector2(armor_extent, armor_extent)
		var hp_bar_size: Vector2 = _view.player_hp_bar_vfx_size()
		if hp_bar_size.x > 0.0 and hp_bar_size.y > 0.0:
			player_hp_impact_size = Vector2(
				clampf(hp_bar_size.x * 0.58, 180.0, 420.0),
				clampf(hp_bar_size.y * 1.90, 76.0, 130.0)
			)
	if player_hp_target == Vector2.ZERO:
		player_hp_target = player_target
	if armor_target == Vector2.ZERO:
		armor_target = player_hp_target
	return {
		"enemy_target": enemy_target,
		"player_target": player_target,
		"player_hp_target": player_hp_target,
		"armor_target": armor_target,
		"enemy_impact_size": Vector2(84, 84),
		"player_hp_impact_size": player_hp_impact_size,
		"armor_impact_size": armor_impact_size,
		"gold_impact_size": Vector2(70, 70),
	}


func enemy_result_impact_size(orb_id: int, fallback_size: Vector2, amount: int) -> Vector2:
	if orb_id != OrbType.Id.FIRE or _view == null or not _view.has_method("enemy_vfx_size"):
		return fallback_size
	if _vfx_presenter == null or not _vfx_presenter.has_method("replay_result_is_screen_wide"):
		return fallback_size
	if not bool(_vfx_presenter.replay_result_is_screen_wide("fire", amount)):
		return fallback_size
	var enemy_size: Vector2 = _view.enemy_vfx_size()
	if enemy_size.x <= 1.0 or enemy_size.y <= 1.0:
		return fallback_size
	var scale := 1.0
	if _vfx_presenter != null and _vfx_presenter.has_method("result_vfx_size_scale"):
		scale = maxf(1.0, float(_vfx_presenter.result_vfx_size_scale("fire", amount)))
	return Vector2(
		maxf(fallback_size.x, enemy_size.x / scale),
		maxf(fallback_size.y, enemy_size.y / scale)
	)
