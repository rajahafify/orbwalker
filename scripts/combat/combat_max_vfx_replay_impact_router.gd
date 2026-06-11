extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxReplayImpactRouter

const COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_fallback_presenter.gd")
const COMBAT_MAX_VFX_REPLAY_ROUTE_POLICY_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_route_policy.gd")

var _routes: Array[Dictionary] = []
var _fallback_presenter: Variant = COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT.new()
var _route_policy: Variant = COMBAT_MAX_VFX_REPLAY_ROUTE_POLICY_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	_bind_route_policy(dependencies)
	_bind_fallback_presenter(dependencies)
	_routes.clear()
	for raw_route in _configured_routes(dependencies):
		_routes.append(Dictionary(raw_route))


func supports_replay_impact(kind: String, screen_wide: bool = false) -> bool:
	# The default lightweight fallback route accepts every kind, so production callers should treat this as capability coverage, not a selective gate.
	for route in _routes:
		if _route_policy.route_supports(route, kind, screen_wide):
			return true
	return false


func spawn_replay_impact(
	center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	for route in _routes:
		if not _route_policy.route_supports(route, kind, screen_wide):
			continue
		if _spawn_route(route, center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide):
			return true
	return false


func _spawn_route(
	route: Dictionary, center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	var presenter: Variant = _route_policy.supported_presenter(route, kind, screen_wide)
	if presenter != null:
		return presenter.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide)
	var spawn: Callable = route.get("spawn", Callable())
	if not spawn.is_valid():
		return false
	return bool(spawn.call(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide))


func _bind_route_policy(dependencies: Dictionary) -> void:
	_route_policy = dependencies.get("route_policy", _route_policy)
	if _route_policy != null and _route_policy.has_method("bind"):
		_route_policy.bind(dependencies)


func _bind_fallback_presenter(dependencies: Dictionary) -> void:
	_fallback_presenter = dependencies.get("fallback_presenter", _fallback_presenter)
	if _fallback_presenter != null and _fallback_presenter.has_method("bind"):
		_fallback_presenter.bind(dependencies)


func _configured_routes(dependencies: Dictionary) -> Array:
	if dependencies.has("routes"):
		return Array(dependencies.get("routes", []))
	return _route_policy.default_routes(dependencies, _fallback_presenter, Callable(self, "_is_armor_kind"))


func _is_armor_kind(kind: String) -> bool:
	return kind == "armor"
