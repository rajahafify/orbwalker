extends RefCounted
class_name CombatMaxVfxReplayRoutePolicy

var _status_available: Variant = false


func bind(dependencies: Dictionary) -> void:
	_status_available = dependencies.get("status_available", false)


func armor_fallback_available() -> bool:
	return not route_available({"available": _status_available})


func supported_presenter(route: Dictionary, kind: String, screen_wide: bool) -> Variant:
	if not route_available(route):
		return null
	if not route_accepts_kind(route, kind):
		return null
	var presenter: Variant = route.get("presenter")
	if presenter == null or not presenter.supports_replay_impact(kind, screen_wide):
		return null
	return presenter


func route_supports(route: Dictionary, kind: String, screen_wide: bool) -> bool:
	if supported_presenter(route, kind, screen_wide) != null:
		return true
	if not route_available(route):
		return false
	if not route_accepts_kind(route, kind):
		return false
	var supports: Callable = route.get("supports", Callable())
	if supports.is_valid():
		return bool(supports.call(kind, screen_wide))
	var spawn: Callable = route.get("spawn", Callable())
	return spawn.is_valid()


func route_available(route: Dictionary) -> bool:
	var availability: Variant = route.get("available", false)
	if availability is Callable and availability.is_valid():
		return bool(availability.call())
	return bool(availability)


func route_accepts_kind(route: Dictionary, kind: String) -> bool:
	var kind_filter: Callable = route.get("kind_filter", Callable())
	if kind_filter.is_valid():
		return bool(kind_filter.call(kind))
	return true
