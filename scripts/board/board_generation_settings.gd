extends Resource
class_name BoardGenerationSettings

@export var spawn_weights: PackedFloat32Array = PackedFloat32Array([
	1.0, # Fire
	1.0, # Ice
	1.0, # Earth
	1.0, # Heart
	1.0, # Armor
	0.45, # Gold (rarer by default)
])


func normalized_weights() -> PackedFloat32Array:
	var fixed_weights := PackedFloat32Array()
	fixed_weights.resize(OrbType.ALL_TYPES.size())

	for index in OrbType.ALL_TYPES.size():
		var weight := 1.0
		if index < spawn_weights.size():
			weight = maxf(spawn_weights[index], 0.0)
		fixed_weights[index] = weight

	var total := 0.0
	for weight in fixed_weights:
		total += weight

	if total <= 0.0:
		var fallback := 1.0 / float(OrbType.ALL_TYPES.size())
		for index in fixed_weights.size():
			fixed_weights[index] = fallback
		return fixed_weights

	for index in fixed_weights.size():
		fixed_weights[index] /= total

	return fixed_weights
