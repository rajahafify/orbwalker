extends RefCounted


func build_snapshot(data: Dictionary) -> Dictionary:
	var run_label := String(data.get("run_label", ""))
	var player_gold := int(data.get("player_gold", 0))
	var enemy_display_name := String(data.get("enemy_display_name", "Enemy"))
	var enemy_hp := int(data.get("enemy_hp", 0))
	var enemy_max_hp := maxi(1, int(data.get("enemy_max_hp", 1)))
	var enemy_turn_block := int(data.get("enemy_turn_block", 0))
	var enemy_intent_text := String(data.get("enemy_intent_text", ""))
	var enemy_intent_preview: Dictionary = data.get("enemy_intent_preview", {})
	var enemy_texture = data.get("enemy_texture", null)
	var combat_turn_index := int(data.get("combat_turn_index", 0))
	var combat_phase_name := String(data.get("combat_phase_name", "N/A"))
	var timer_seconds := float(data.get("timer_seconds", 0.0))
	var timer_state := String(data.get("timer_state", "ready"))
	var player_hp := int(data.get("player_hp", 0))
	var player_max_hp := maxi(1, int(data.get("player_max_hp", 1)))
	var player_armor := maxi(0, int(data.get("player_armor", 0)))
	var fire_orb_value := int(data.get("fire_orb_value", 0))
	var armor_orb_value := int(data.get("armor_orb_value", 0))
	var heart_mastery_level := int(data.get("heart_mastery_level", 0))
	var gold_mastery_level := int(data.get("gold_mastery_level", 0))
	var turn_summary_text := String(data.get("turn_summary_text", ""))
	var progression_snapshot: Dictionary = data.get("progression_snapshot", {})

	return {
		"top_hud": {
			"title_text": run_label.replace(" | ", "  |  "),
			"hint_text": "Gold %d" % player_gold,
		},
		"enemy_stage": {
			"intent_text": enemy_intent_text,
			"enemy_texture": enemy_texture,
			"enemy_hp_max": enemy_max_hp,
			"enemy_hp_value": enemy_hp,
			"enemy_text": "%s HP %d/%d  Block %d" % [
				enemy_display_name,
				enemy_hp,
				enemy_max_hp,
				enemy_turn_block,
			],
			"enemy_intent_preview": enemy_intent_preview,
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
			"status_text": "%s | Turn %d." % [run_label, combat_turn_index],
			"enemy_text": "%s HP %d/%d Block %d" % [
				enemy_display_name,
				enemy_hp,
				enemy_max_hp,
				enemy_turn_block,
			],
		},
	}
