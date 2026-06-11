extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxReplayImpactRouter

var _routes: Array[Dictionary] = []


func bind(dependencies: Dictionary) -> void:
	_routes.clear()
	for raw_route in Array(dependencies.get("routes", [])):
		_routes.append(Dictionary(raw_route))


func supports_replay_impact(kind: String, screen_wide: bool = false) -> bool:
	for route in _routes:
		var presenter: Variant = _supported_presenter(route, kind, screen_wide)
		if presenter != null:
			return true
	return false


func spawn_replay_impact(
	center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	for route in _routes:
		var presenter: Variant = _supported_presenter(route, kind, screen_wide)
		if presenter == null:
			continue
		if presenter.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide):
			return true
	return false


func _supported_presenter(route: Dictionary, kind: String, screen_wide: bool) -> Variant:
	if not _route_available(route):
		return null
	if not _route_accepts_kind(route, kind):
		return null
	var presenter: Variant = route.get("presenter")
	if presenter == null or not presenter.supports_replay_impact(kind, screen_wide):
		return null
	return presenter


func _route_available(route: Dictionary) -> bool:
	var availability: Callable = route.get("available", Callable())
	if availability.is_valid():
		return bool(availability.call())
	return bool(route.get("available", false))


func _route_accepts_kind(route: Dictionary, kind: String) -> bool:
	var kind_filter: Callable = route.get("kind_filter", Callable())
	if kind_filter.is_valid():
		return bool(kind_filter.call(kind))
	return true
