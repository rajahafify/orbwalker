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
	var gold_weight_multiplier := _prototype_gold_weight_multiplier()

	for index in OrbType.ALL_TYPES.size():
		var weight := 1.0
		if index < spawn_weights.size():
			weight = maxf(spawn_weights[index], 0.0)
		if int(OrbType.ALL_TYPES[index]) == int(OrbType.Id.GOLD):
			weight *= gold_weight_multiplier
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


func _prototype_gold_weight_multiplier() -> float:
	var project_setting_path := "matchatro/prototype_balance/gold_orb_spawn_weight_multiplier"
	var project_multiplier := float(ProjectSettings.get_setting(project_setting_path, 1.0))
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return maxf(0.0, project_multiplier)
	var run_state := tree.root.get_node_or_null("RunState")
	if run_state == null or not run_state.has_method("prototype_balance_levers_snapshot"):
		return maxf(0.0, project_multiplier)
	var levers: Dictionary = run_state.prototype_balance_levers_snapshot()
	return maxf(0.0, float(levers.get("gold_orb_spawn_weight_multiplier", project_multiplier)))
