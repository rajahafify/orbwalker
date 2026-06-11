extends CombatMaxVfxPresenterContract
class_name CombatMaxVfxReplayImpactRouter

const COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_max_vfx_replay_fallback_presenter.gd")

var _routes: Array[Dictionary] = []
var _fallback_presenter: Variant = COMBAT_MAX_VFX_REPLAY_FALLBACK_PRESENTER_SCRIPT.new()


func bind(dependencies: Dictionary) -> void:
	# Route entries require an available bool/callable and may include a kind_filter callable.
	_bind_fallback_presenter(dependencies)
	_routes.clear()
	for raw_route in _configured_routes(dependencies):
		_routes.append(Dictionary(raw_route))


func supports_replay_impact(kind: String, screen_wide: bool = false) -> bool:
	# The default lightweight fallback route accepts every kind, so production callers should treat this as capability coverage, not a selective gate.
	for route in _routes:
		if _route_supports(route, kind, screen_wide):
			return true
	return false


func spawn_replay_impact(
	center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	for route in _routes:
		if not _route_supports(route, kind, screen_wide):
			continue
		if _spawn_route(route, center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide):
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


func _route_supports(route: Dictionary, kind: String, screen_wide: bool) -> bool:
	if _supported_presenter(route, kind, screen_wide) != null:
		return true
	if not _route_available(route):
		return false
	if not _route_accepts_kind(route, kind):
		return false
	var supports: Callable = route.get("supports", Callable())
	if supports.is_valid():
		return bool(supports.call(kind, screen_wide))
	var spawn: Callable = route.get("spawn", Callable())
	return spawn.is_valid()


func _spawn_route(
	route: Dictionary, center: Vector2, kind: String, draw_size: Vector2, max_size: float, base_size: float, duration: float, intensity: int, screen_wide: bool
) -> bool:
	var presenter: Variant = _supported_presenter(route, kind, screen_wide)
	if presenter != null:
		return presenter.spawn_replay_impact(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide)
	var spawn: Callable = route.get("spawn", Callable())
	if not spawn.is_valid():
		return false
	return bool(spawn.call(center, kind, draw_size, max_size, base_size, duration, intensity, screen_wide))


func _route_available(route: Dictionary) -> bool:
	var availability: Variant = route.get("available", false)
	if availability is Callable and availability.is_valid():
		return bool(availability.call())
	return bool(availability)


func _route_accepts_kind(route: Dictionary, kind: String) -> bool:
	var kind_filter: Callable = route.get("kind_filter", Callable())
	if kind_filter.is_valid():
		return bool(kind_filter.call(kind))
	return true


func _bind_fallback_presenter(dependencies: Dictionary) -> void:
	_fallback_presenter = dependencies.get("fallback_presenter", _fallback_presenter)
	if _fallback_presenter != null and _fallback_presenter.has_method("bind"):
		_fallback_presenter.bind(dependencies)


func _configured_routes(dependencies: Dictionary) -> Array:
	if dependencies.has("routes"):
		return Array(dependencies.get("routes", []))
	return [
		{
			"available": Callable(self, "_armor_replay_fallback_available"),
			"kind_filter": Callable(self, "_is_armor_kind"),
			"spawn": Callable(_fallback_presenter, "spawn_armor_replay_fallback"),
		},
		{"presenter": dependencies.get("status_presenter"), "available": dependencies.get("status_available", false)},
		{
			"presenter": dependencies.get("elemental_presenter"),
			"available": dependencies.get("elemental_available", false),
			"kind_filter": dependencies.get("should_use_elemental", Callable()),
		},
		{"presenter": dependencies.get("pack_presenter"), "available": dependencies.get("pack_available", false)},
		{"available": true, "spawn": Callable(_fallback_presenter, "spawn_lightweight_replay_fallback")},
	]


func _armor_replay_fallback_available() -> bool:
	# Default route order puts the status presenter first; the armor fallback intentionally mirrors the old "status unavailable" short-circuit.
	for route in _routes:
		if route.get("presenter") != null:
			return not _route_available(route)
	return true


func _is_armor_kind(kind: String) -> bool:
	return kind == "armor"
