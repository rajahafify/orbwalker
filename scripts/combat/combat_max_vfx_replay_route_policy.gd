extends RefCounted
class_name CombatMaxVfxReplayRoutePolicy

const ROUTE_ARMOR_FALLBACK := "armor_fallback"
const ROUTE_STATUS := "status"
const ROUTE_ELEMENTAL := "elemental"
const ROUTE_PACK := "pack"
const ROUTE_LIGHTWEIGHT_FALLBACK := "lightweight_fallback"
const DEFAULT_ROUTE_IDS: Array[String] = [
	ROUTE_ARMOR_FALLBACK,
	ROUTE_STATUS,
	ROUTE_ELEMENTAL,
	ROUTE_PACK,
	ROUTE_LIGHTWEIGHT_FALLBACK,
]

var _status_available: Variant = false


func bind(dependencies: Dictionary) -> void:
	_status_available = dependencies.get("status_available", false)


func default_routes(dependencies: Dictionary, fallback_presenter: Variant, armor_kind_filter: Callable) -> Array[Dictionary]:
	return [
		{
			"id": ROUTE_ARMOR_FALLBACK,
			"available": Callable(self, "armor_fallback_available"),
			"kind_filter": armor_kind_filter,
			"spawn": Callable(fallback_presenter, "spawn_armor_replay_fallback"),
		},
		{
			"id": ROUTE_STATUS,
			"presenter": dependencies.get("status_presenter"),
			"available": dependencies.get("status_available", false),
		},
		{
			"id": ROUTE_ELEMENTAL,
			"presenter": dependencies.get("elemental_presenter"),
			"available": dependencies.get("elemental_available", false),
			"kind_filter": dependencies.get("should_use_elemental", Callable()),
		},
		{
			"id": ROUTE_PACK,
			"presenter": dependencies.get("pack_presenter"),
			"available": dependencies.get("pack_available", false),
		},
		{
			"id": ROUTE_LIGHTWEIGHT_FALLBACK,
			"available": true,
			"spawn": Callable(fallback_presenter, "spawn_lightweight_replay_fallback"),
		},
	]


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
