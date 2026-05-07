extends RefCounted
class_name CombatConsumableService

var _convert_random_non_target_orbs: Callable = Callable()


func bind(dependencies: Dictionary) -> void:
	_convert_random_non_target_orbs = dependencies.get("convert_random_non_target_orbs", Callable())


func apply_effects(effects: Array, rng: RandomNumberGenerator) -> int:
	var total_converted := 0
	for raw_effect in effects:
		var effect: Dictionary = raw_effect
		var operation := String(effect.get("operation", ""))
		if operation != "convert_random_orbs":
			continue
		var value: Dictionary = effect.get("value", {})
		var target_orb_id := int(value.get("target_orb_id", -1))
		var count := int(value.get("count", 0))
		total_converted += _convert_orbs(target_orb_id, count, rng)
	return total_converted


func _convert_orbs(target_orb_id: int, count: int, rng: RandomNumberGenerator) -> int:
	if not _convert_random_non_target_orbs.is_valid():
		return 0
	return int(_convert_random_non_target_orbs.call(target_orb_id, count, rng))
