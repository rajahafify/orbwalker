extends RefCounted


func build_snapshot(data: Dictionary) -> Dictionary:
	var level_text := String(data.get("top_level_text", "Level"))
	var enemy_step_text := String(data.get("top_enemy_step_text", "Fight"))
	var gold_text := String(data.get("top_gold_text", "Gold 0"))
	var enemy_name_text := String(data.get("enemy_name_text", "Enemy"))
	var enemy_hp := int(data.get("enemy_hp", 0))
	var enemy_max_hp := maxi(1, int(data.get("enemy_max_hp", 1)))
	var enemy_hp_text := String(data.get("enemy_hp_text", "HP %d/%d" % [enemy_hp, enemy_max_hp]))
	var enemy_turn_block := int(data.get("enemy_turn_block", 0))
	var enemy_intent_preview: Dictionary = data.get("enemy_intent_preview", {})
	var enemy_stage_texture = data.get("enemy_stage_texture", null)
	var timer_seconds := float(data.get("timer_seconds", 0.0))
	var timer_state := String(data.get("timer_state", "ready"))
	var combat_turn_index := int(data.get("combat_turn_index", 0))
	var combat_phase_name := String(data.get("combat_phase_name", "N/A"))
	var player_hp := int(data.get("player_hp", 0))
	var player_max_hp := maxi(1, int(data.get("player_max_hp", 1)))
	var player_armor := maxi(0, int(data.get("player_armor", 0)))
	var fire_orb_value := int(data.get("fire_orb_value", 0))
	var armor_orb_value := int(data.get("armor_orb_value", 0))
	var heart_mastery_level := int(data.get("heart_mastery_level", 0))
	var gold_mastery_level := int(data.get("gold_mastery_level", 0))
	var turn_summary_text := String(data.get("turn_summary_text", ""))
	var progression_snapshot: Dictionary = data.get("progression_snapshot", {})
	var primary_intent_badge: Dictionary = data.get("primary_intent_badge", {})
	return {
		"top_hud": {
			"level_text": level_text,
			"enemy_step_text": enemy_step_text,
			"gold_text": gold_text,
		},
		"enemy_stage": {
			"enemy_name_text": enemy_name_text,
			"enemy_hp_text": enemy_hp_text,
			"enemy_stage_texture": enemy_stage_texture,
			"enemy_hp_max": enemy_max_hp,
			"enemy_hp_value": enemy_hp,
			"enemy_turn_block": enemy_turn_block,
			"enemy_intent_preview": enemy_intent_preview,
		},
		"primary_intent_badge": {
			"kind": String(primary_intent_badge.get("kind", "idle")),
			"title": String(primary_intent_badge.get("title", "Intent")),
			"amount": String(primary_intent_badge.get("amount", "--")),
			"detail": String(primary_intent_badge.get("detail", "No immediate action.")),
		},
		"tempo_row": {
			"phase_text": "Turn %d  %s" % [combat_turn_index, combat_phase_name],
			"timer_seconds": timer_seconds,
			"timer_state": timer_state,
		},
		"player_strip": {
			"player_text": "HP %d / %d" % [player_hp, player_max_hp],
			"player_hp_max": player_max_hp,
			"player_hp_value": player_hp,
			"player_armor_max": maxi(30, player_armor + 10),
			"player_armor_value": player_armor,
			"player_armor_text": "%d / %d" % [player_armor, maxi(30, player_armor + 10)],
			"armor_badge_visible": false,
			"armor_badge_text": "BLOCK +%d" % player_armor,
			"attack_stat_text": "ATK  %d" % fire_orb_value,
			"armor_stat_text": "ARM  %d" % armor_orb_value,
			"heart_stat_text": "HEART  %d%%" % (heart_mastery_level * 5),
			"gold_stat_text": "GOLD  %d%%" % (gold_mastery_level * 5),
			"run_progress_text": "",
			"phase_text": "",
			"turn_summary_text": turn_summary_text.substr(0, mini(70, turn_summary_text.length())),
			"progression_snapshot": progression_snapshot,
		},
		"debug_overlay": {
			"status_text": "%s | Turn %d." % [level_text, combat_turn_index],
			"enemy_text": "%s %s Block %d" % [enemy_name_text, enemy_hp_text, enemy_turn_block],
		},
	}
