extends RefCounted
class_name CombatTurnLogger

const LOG_LEVEL_NORMAL := "normal"
const LOG_LEVEL_DETAILED := "detailed"


func format_intent(intent: Dictionary) -> String:
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]


func format_intent_compact(intent: Dictionary) -> String:
	var label := _intent_action_label(String(intent.get("label", "Intent")))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	if attack > 0 and block > 0:
		return "%s Atk %d / Block %d" % [label, attack, block]
	if attack > 0:
		return "%s Atk %d" % [label, attack]
	if block > 0:
		return "%s Block %d" % [label, block]
	return label


func build_turn_summary_status(turn_log: Dictionary) -> String:
	return "Turn resolved: +%d HP, +%d Armor, +%d Gold, dealt %d (%d blocked)." % [
		int(turn_log.get("healed", 0)),
		int(turn_log.get("armor_gained", 0)),
		int(turn_log.get("gold_gained", 0)),
		int(turn_log.get("enemy_damage_taken", 0)),
		int(turn_log.get("enemy_blocked", 0)),
	]


func build_victory_status(turn_log: Dictionary, transition: Dictionary) -> String:
	var next_scene := String(transition.get("next_scene", ""))
	var next_label := "Next scene"
	if next_scene.find("shop") >= 0:
		next_label = "shop"
	elif String(transition.get("step", "")) == "boss_relic_reward":
		next_label = "boss relic reward"
	elif next_scene.find("run_summary") >= 0:
		next_label = "run summary"
	elif next_scene.find("combat_player") >= 0:
		next_label = "next fight"
	return "Victory. Enemy defeated before intent (%s). Continue to %s." % [
		"skipped" if bool(turn_log.get("enemy_intent_skipped", false)) else "resolved",
		next_label,
	]


func build_victory_gold_summary(turn_log: Dictionary) -> String:
	return "GOLD GAINED +%d" % int(turn_log.get("gold_gained", 0))


func build_run_outcome_summary(run_summary: Dictionary, max_dungeon_levels: int, fallback_cause: String = "") -> String:
	var cause := String(run_summary.get("cause", fallback_cause))
	if cause == "":
		cause = fallback_cause
	var bosses_killed := int(run_summary.get("bosses_defeated", 0))
	var monsters_killed := maxi(0, int(run_summary.get("enemies_defeated", 0)) - bosses_killed)
	return "Total Gold +%d\nMonsters Killed %d\nBosses Killed %d\nLevel Reached %d/%d\n%s" % [
		int(run_summary.get("gold_earned", 0)),
		monsters_killed,
		bosses_killed,
		int(run_summary.get("level_reached", 1)),
		max_dungeon_levels,
		cause,
	]


func build_defeat_status(turn_log: Dictionary) -> String:
	var hp_damage := int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0))
	return "Defeat. Enemy intent dealt %d HP damage." % hp_damage


func build_defeat_cause(enemy_label: String, turn_log: Dictionary) -> String:
	var intent_label := String(Dictionary(turn_log.get("enemy_intent", {})).get("label", "Unknown intent"))
	var hp_damage := int(Dictionary(turn_log.get("enemy_attack_resolution", {})).get("hp_damage", 0))
	return "%s defeated the hero with %s for %d HP." % [enemy_label, intent_label, hp_damage]


func build_turn_log_lines(turn_log: Dictionary, log_level: String, context: Dictionary) -> Array[String]:
	if log_level == LOG_LEVEL_DETAILED:
		return _build_turn_log_detailed_lines(turn_log, context)
	return _build_turn_log_normal_lines(turn_log, context)


func build_state_snapshot_lines(snapshot: Dictionary) -> Array[String]:
	var run_data: Dictionary = snapshot.get("run", {})
	var combat_data: Dictionary = snapshot.get("combat", {})
	var player_data: Dictionary = snapshot.get("player", {})
	var enemy_data: Dictionary = snapshot.get("enemy", {})
	var progression_data: Dictionary = snapshot.get("progression", {})

	return [
		"State snapshot:",
		"Run: active=%s, level=%d, step=%s, label=%s" % [
			str(run_data.get("active", false)),
			int(run_data.get("level", 0)),
			String(run_data.get("step", "")),
			String(run_data.get("label", "")),
		],
		"Combat: turn=%d, phase=%s, input_phase=%s" % [
			int(combat_data.get("turn", 0)),
			String(combat_data.get("phase", "N/A")),
			str(combat_data.get("input_phase", "N/A")),
		],
		"Player: HP %d/%d, Armor %d, Gold %d" % [
			int(player_data.get("hp", 0)),
			int(player_data.get("max_hp", 0)),
			int(player_data.get("armor", 0)),
			int(player_data.get("gold", 0)),
		],
		"Enemy: %s HP %d/%d, TurnBlock %d, Intent %s" % [
			String(enemy_data.get("display_name", "Unknown")),
			int(enemy_data.get("hp", 0)),
			int(enemy_data.get("max_hp", 0)),
			int(enemy_data.get("turn_block", 0)),
			String(enemy_data.get("intent", "-")),
		],
		"Eq: %s" % format_slot_line(progression_data.get("equipment_slots", [])),
		"Cons: %s" % format_slot_line(progression_data.get("consumable_slots", [])),
		"Relics: %s" % format_id_line(progression_data.get("relic_ids", [])),
		"Mastery: %s" % format_mastery_line(progression_data.get("mastery_levels", {})),
	]


func format_signed_delta(value: int) -> String:
	if value >= 0:
		return "+%d" % value
	return "%d" % value


func format_matched_counts(matched_counts: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		var count: int = int(matched_counts.get(orb_id, 0))
		if count <= 0:
			continue
		parts.append("%s=%d" % [OrbType.debug_symbol(orb_id), count])
	if parts.is_empty():
		return "none"
	return ", ".join(parts)


func format_slot_line(slot_values: Array) -> String:
	var parts: Array[String] = []
	for value in slot_values:
		var text := String(value)
		parts.append(text if text != "" else "-")
	return "[" + ", ".join(parts) + "]"


func format_id_line(values: Array) -> String:
	if values.is_empty():
		return "-"
	var rendered: Array[String] = []
	for value in values:
		rendered.append(String(value))
	return "[" + ", ".join(rendered) + "]"


func format_mastery_line(levels: Dictionary) -> String:
	var parts: Array[String] = []
	for orb_id in OrbType.ALL_TYPES:
		parts.append("%s:%d" % [OrbType.debug_symbol(orb_id), int(levels.get(orb_id, 0))])
	return "[" + ", ".join(parts) + "]"


func _intent_action_label(raw_label: String) -> String:
	var parts := raw_label.strip_edges().split(" ", false)
	var action_parts: Array[String] = []
	for part in parts:
		if not String(part).is_valid_int():
			action_parts.append(part)
	if action_parts.is_empty():
		return "Intent"
	return " ".join(action_parts)


func _build_turn_log_normal_lines(turn_log: Dictionary, context: Dictionary) -> Array[String]:
	var resolved_turn := int(turn_log.get("resolved_turn_index", 0))
	var combo_count := int(turn_log.get("combo_count", 0))
	var combo_count_with_bonus := int(turn_log.get("combo_count_with_bonus", combo_count))
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	var player_end: Dictionary = context.get("player_end", {})
	var enemy_end: Dictionary = context.get("enemy_end", {})

	var lines: Array[String] = [
		"---- Turn %d ----" % resolved_turn,
		"Matches: combos=%d (effective %d) | %s" % [combo_count, combo_count_with_bonus, format_matched_counts(matched_counts)],
		"Player gains: Heal +%d, Armor +%d, Gold +%d." % [
			int(turn_log.get("healed", 0)),
			int(turn_log.get("armor_gained", 0)),
			int(turn_log.get("gold_gained", 0)),
		],
		"Damage dealt: Fire %d + Ice %d + Earth %d = %d (enemy blocked %d, enemy took %d)." % [
			int(turn_log.get("fire_damage", 0)),
			int(turn_log.get("ice_damage", 0)),
			int(turn_log.get("earth_damage", 0)),
			int(turn_log.get("total_elemental_damage", 0)),
			int(turn_log.get("enemy_blocked", 0)),
			int(turn_log.get("enemy_damage_taken", 0)),
		],
	]

	if bool(turn_log.get("enemy_intent_skipped", false)):
		lines.append("Enemy intent: skipped (enemy defeated first).")
	else:
		var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
		lines.append(
			"Enemy intent: incoming %d, blocked %d, HP damage %d." % [
				int(enemy_attack.get("incoming", 0)),
				int(enemy_attack.get("blocked_by_armor", 0)),
				int(enemy_attack.get("hp_damage", 0)),
			]
		)

	lines.append("Armor expired after enemy action: %d." % int(turn_log.get("expired_armor", 0)))
	lines.append(
		"End state: Player HP %d/%d Armor %d Gold %d | Enemy HP %d/%d" % [
			int(player_end.get("hp", 0)),
			int(player_end.get("max_hp", 0)),
			int(player_end.get("armor", 0)),
			int(player_end.get("gold", 0)),
			int(enemy_end.get("hp", 0)),
			int(enemy_end.get("max_hp", 0)),
		]
	)
	return lines


func _build_turn_log_detailed_lines(turn_log: Dictionary, context: Dictionary) -> Array[String]:
	var lines := _build_turn_log_normal_lines(turn_log, context)

	var combo_count := int(turn_log.get("combo_count", 0))
	var combo_flat_bonus := int(turn_log.get("combo_flat_bonus", 0))
	var combo_count_with_bonus := int(turn_log.get("combo_count_with_bonus", combo_count))
	var increase_combo_modifier := int(turn_log.get("increase_combo_modifier", 0))
	var more_combo_modifier := float(turn_log.get("more_combo_modifier", 1.0))
	var combo_multiplier_mult := float(turn_log.get("combo_multiplier_mult", 1.0))
	var damage_combo_multiplier := float(turn_log.get("damage_combo_multiplier", 0.0))
	var prep_armor_added := int(turn_log.get("prep_armor_added", 0))
	var flat_damage_bonus := int(turn_log.get("flat_damage_bonus", 0))
	var flat_heal_bonus := int(turn_log.get("flat_heal_bonus", 0))
	var flat_gold_bonus := int(turn_log.get("flat_gold_bonus", 0))
	var matched_counts: Dictionary = turn_log.get("matched_counts", {})
	var orb_bonus_by_id: Dictionary = turn_log.get("orb_bonus_by_id", {})
	var modifier_sources: Array = turn_log.get("modifier_sources", [])
	var orb_values_by_id: Dictionary = context.get("orb_values_by_id", {})

	lines.append("Detailed combat breakdown:")
	lines.append(
		"Modifier totals: combo+%d, combo_mult_x%.2f, prep_armor+%d, flat_damage+%d, flat_heal+%d, flat_gold+%d." % [
			combo_flat_bonus,
			combo_multiplier_mult,
			prep_armor_added,
			flat_damage_bonus,
			flat_heal_bonus,
			flat_gold_bonus,
		]
	)
	lines.append(
		"Orb bonuses: F:+%d I:+%d E:+%d H:+%d A:+%d G:+%d." % [
			int(orb_bonus_by_id.get(OrbType.Id.FIRE, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.ICE, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.EARTH, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.HEART, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.ARMOR, 0)),
			int(orb_bonus_by_id.get(OrbType.Id.GOLD, 0)),
		]
	)

	lines.append("Formula path:")
	lines.append("effective_combo = %d + %d = %d" % [combo_count, combo_flat_bonus, combo_count_with_bonus])
	lines.append(
		"damage_multiplier = ((increase_combo_modifier + effective_combo) * more_combo_modifier) * combo_multiplier_mult = ((%d + %d) * %.2f) * %.2f = %.2f" % [
			increase_combo_modifier,
			combo_count_with_bonus,
			more_combo_modifier,
			combo_multiplier_mult,
			damage_combo_multiplier,
		]
	)
	var heart_orbs := int(matched_counts.get(OrbType.Id.HEART, 0))
	var armor_orbs := int(matched_counts.get(OrbType.Id.ARMOR, 0))
	var gold_orbs := int(matched_counts.get(OrbType.Id.GOLD, 0))
	var heart_mastery := int(orb_values_by_id.get(OrbType.Id.HEART, 1)) - 1
	var armor_mastery := int(orb_values_by_id.get(OrbType.Id.ARMOR, 1)) - 1
	var gold_mastery := int(orb_values_by_id.get(OrbType.Id.GOLD, 1)) - 1
	var heart_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.HEART, 0))
	var armor_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.ARMOR, 0))
	var gold_orb_bonus := int(orb_bonus_by_id.get(OrbType.Id.GOLD, 0))
	var heart_base := int(turn_log.get("heart_base", 0))
	var armor_base := int(turn_log.get("armor_base", 0))
	var gold_base := int(turn_log.get("gold_base", 0))
	var total_armor_gain := int(turn_log.get("armor_gained", 0))
	var armor_from_matches := maxi(0, total_armor_gain - prep_armor_added)
	var heal_formula_total := heart_base + (flat_heal_bonus if heart_base > 0 else 0)
	var gold_formula_total := gold_base + (flat_gold_bonus if gold_base > 0 else 0)
	lines.append(
		"Health: heart_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; heal = heart_base%s = %d (applied %d)." % [
			heart_orbs,
			heart_mastery,
			heart_orb_bonus,
			heart_base,
			(" + flat_heal_bonus(%d)" % flat_heal_bonus) if heart_base > 0 and flat_heal_bonus > 0 else "",
			heal_formula_total,
			int(turn_log.get("healed", 0)),
		]
	)
	lines.append(
		"Armor: armor_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; armor_from_matches = round(armor_base * damage_multiplier) = round(%d * %.2f) = %d; total_armor_gain = armor_from_matches + prep_armor_bonus = %d + %d = %d." % [
			armor_orbs,
			armor_mastery,
			armor_orb_bonus,
			armor_base,
			armor_base,
			damage_combo_multiplier,
			armor_from_matches,
			armor_from_matches,
			prep_armor_added,
			total_armor_gain,
		]
	)
	lines.append(
		"Gold: gold_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; gold = gold_base%s = %d (applied %d)." % [
			gold_orbs,
			gold_mastery,
			gold_orb_bonus,
			gold_base,
			(" + flat_gold_bonus(%d)" % flat_gold_bonus) if gold_base > 0 and flat_gold_bonus > 0 else "",
			gold_formula_total,
			int(turn_log.get("gold_gained", 0)),
		]
	)
	lines.append(_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, orb_values_by_id, OrbType.Id.FIRE, "fire", damage_combo_multiplier))
	lines.append(_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, orb_values_by_id, OrbType.Id.ICE, "ice", damage_combo_multiplier))
	lines.append(_detailed_element_formula_line(turn_log, matched_counts, orb_bonus_by_id, orb_values_by_id, OrbType.Id.EARTH, "earth", damage_combo_multiplier))
	lines.append(
		"total_damage = fire_damage + ice_damage + earth_damage + flat_damage_bonus = %d + %d + %d + %d = %d" % [
			int(turn_log.get("fire_damage", 0)),
			int(turn_log.get("ice_damage", 0)),
			int(turn_log.get("earth_damage", 0)),
			flat_damage_bonus,
			int(turn_log.get("total_elemental_damage", 0)),
		]
	)
	lines.append(
		"final_enemy_damage = max(0, total_damage - enemy_block) = max(0, %d - %d) = %d" % [
			int(turn_log.get("total_elemental_damage", 0)),
			int(turn_log.get("enemy_blocked", 0)),
			int(turn_log.get("enemy_damage_taken", 0)),
		]
	)

	if modifier_sources.is_empty():
		lines.append("Modifier sources: none.")
	else:
		lines.append("Modifier sources:")
		for raw_source in modifier_sources:
			var source: Dictionary = raw_source
			lines.append(
				"  - [%s] %s (%s): %s" % [
					String(source.get("source_type", "unknown")),
					String(source.get("display_name", source.get("source_id", "unknown"))),
					String(source.get("source_id", "")),
					JSON.stringify(source.get("combat_modifiers", {})),
				]
			)

	var player_start: Dictionary = turn_log.get("player_start", {})
	var player_end: Dictionary = turn_log.get("player_end", {})
	var enemy_start: Dictionary = turn_log.get("enemy_start", {})
	var enemy_end: Dictionary = turn_log.get("enemy_end", {})
	lines.append(
		"Player delta: HP %d -> %d (delta %s), Armor %d -> %d (delta %s), Gold %d -> %d (delta %s)." % [
			int(player_start.get("hp", 0)),
			int(player_end.get("hp", 0)),
			format_signed_delta(int(player_end.get("hp", 0)) - int(player_start.get("hp", 0))),
			int(player_start.get("armor", 0)),
			int(player_end.get("armor", 0)),
			format_signed_delta(int(player_end.get("armor", 0)) - int(player_start.get("armor", 0))),
			int(player_start.get("gold", 0)),
			int(player_end.get("gold", 0)),
			format_signed_delta(int(player_end.get("gold", 0)) - int(player_start.get("gold", 0))),
		]
	)
	lines.append(
		"Enemy delta: HP %d -> %d (delta %s), Block %d -> %d (delta %s)." % [
			int(enemy_start.get("hp", 0)),
			int(enemy_end.get("hp", 0)),
			format_signed_delta(int(enemy_end.get("hp", 0)) - int(enemy_start.get("hp", 0))),
			int(enemy_start.get("turn_block", 0)),
			int(enemy_end.get("turn_block", 0)),
			format_signed_delta(int(enemy_end.get("turn_block", 0)) - int(enemy_start.get("turn_block", 0))),
		]
	)

	if bool(turn_log.get("enemy_intent_skipped", false)):
		lines.append("Enemy attack resolution: skipped because enemy died before acting.")
	else:
		var enemy_attack: Dictionary = turn_log.get("enemy_attack_resolution", {})
		lines.append(
			"Enemy attack resolution: incoming=%d, blocked_by_armor=%d, hp_damage=%d, post_hp=%d, post_armor=%d." % [
				int(enemy_attack.get("incoming", 0)),
				int(enemy_attack.get("blocked_by_armor", 0)),
				int(enemy_attack.get("hp_damage", 0)),
				int(enemy_attack.get("remaining_hp", 0)),
				int(enemy_attack.get("remaining_armor", 0)),
			]
		)
	lines.append("Armor expiration after enemy action: %d." % int(turn_log.get("expired_armor", 0)))
	return lines


func _detailed_element_formula_line(
	turn_log: Dictionary,
	matched_counts: Dictionary,
	orb_bonus_by_id: Dictionary,
	orb_values_by_id: Dictionary,
	orb_id: int,
	element_name: String,
	damage_multiplier: float
) -> String:
	var orbs_matched := int(matched_counts.get(orb_id, 0))
	var mastery_level := int(orb_values_by_id.get(orb_id, 1)) - 1
	var orb_bonus := int(orb_bonus_by_id.get(orb_id, 0))
	var base_key := "%s_base" % element_name
	var damage_key := "%s_damage" % element_name
	return "%s: element_base = matched_orbs * (1 + mastery + orb_bonus) = %d * (1 + %d + %d) = %d; element_damage = round(element_base * damage_multiplier) = round(%d * %.2f) = %d" % [
		element_name.capitalize(),
		orbs_matched,
		mastery_level,
		orb_bonus,
		int(turn_log.get(base_key, 0)),
		int(turn_log.get(base_key, 0)),
		damage_multiplier,
		int(turn_log.get(damage_key, 0)),
	]
