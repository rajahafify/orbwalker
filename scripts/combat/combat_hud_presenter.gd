extends RefCounted
class_name CombatHudPresenter

const TIMER_STATE_READY := "ready"
const TIMER_STATE_ACTIVE := "active"
const TIMER_STATE_LOCKED := "locked"


func build_hud_snapshot(data: Dictionary) -> Dictionary:
	var progression_snapshot: Dictionary = data.get("progression_snapshot", {})
	var mastery_levels: Dictionary = progression_snapshot.get("mastery_levels", {})
	var intent: Dictionary = data.get("intent", {})
	var enemy_hp := int(data.get("enemy_hp", 0))
	var enemy_max_hp := maxi(1, int(data.get("enemy_max_hp", 1)))
	var enemy_intent_preview: Dictionary = {}
	if bool(data.get("show_intent_preview", false)):
		enemy_intent_preview = _enemy_intent_preview_data(intent, enemy_hp, enemy_max_hp)
	var player_gold := int(data.get("player_gold", 0))
	var top_level_text := "LEVEL %d / %d" % [
		int(data.get("dungeon_level", 0)),
		maxi(1, int(data.get("max_dungeon_levels", 1))),
	]
	var top_enemy_step_text := _top_enemy_step_text(String(data.get("current_step_key", "")))
	var top_gold_text := "GOLD %d" % player_gold
	var primary_intent_badge := _primary_intent_badge_snapshot(intent, _compact_formatter(data))
	var hud_snapshot: Dictionary = build_snapshot(
		{
			"top_level_text": top_level_text,
			"top_enemy_step_text": top_enemy_step_text,
			"top_gold_text": top_gold_text,
			"enemy_name_text": String(data.get("enemy_name_text", "Enemy")),
			"enemy_hp": enemy_hp,
			"enemy_max_hp": enemy_max_hp,
			"enemy_hp_text": "HP %d / %d" % [enemy_hp, enemy_max_hp],
			"enemy_turn_block": int(data.get("enemy_turn_block", 0)),
			"enemy_intent_preview": enemy_intent_preview,
			"enemy_stage_texture": data.get("enemy_stage_texture", null),
			"enemy_portrait_texture": data.get("enemy_portrait_texture", null),
			"primary_intent_badge": primary_intent_badge,
			"combat_turn_index": int(data.get("combat_turn_index", 0)),
			"combat_phase_name": String(data.get("combat_phase_name", "N/A")),
			"timer_state": _timer_state(data),
			"timer_seconds": float(data.get("timer_seconds", 0.0)),
			"player_hp": int(data.get("player_hp", 0)),
			"player_max_hp": int(data.get("player_max_hp", 1)),
			"player_armor": int(data.get("player_armor", 0)),
			"fire_orb_value": int(data.get("fire_orb_value", 0)),
			"armor_orb_value": int(data.get("armor_orb_value", 0)),
			"heart_mastery_level": int(mastery_levels.get(data.get("heart_orb_id", -1), 0)),
			"gold_mastery_level": int(mastery_levels.get(data.get("gold_orb_id", -1), 0)),
			"turn_summary_text": String(data.get("turn_summary_text", "")),
			"progression_snapshot": progression_snapshot,
		}
	)
	var enemy_stage_snapshot: Dictionary = Dictionary(hud_snapshot.get("enemy_stage", {}))
	enemy_stage_snapshot["enemy_portrait_texture"] = data.get("enemy_portrait_texture", null)
	hud_snapshot["enemy_stage"] = enemy_stage_snapshot
	return hud_snapshot


func build_intent_damage_preview(intent: Dictionary, player_hp: int, player_armor: int) -> Dictionary:
	return _intent_damage_preview_data(intent, player_hp, player_armor)


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


func _timer_state(data: Dictionary) -> String:
	if bool(data.get("drag_active", false)):
		return TIMER_STATE_ACTIVE
	if bool(data.get("is_player_input_phase", false)):
		return TIMER_STATE_READY
	return TIMER_STATE_LOCKED


func _top_enemy_step_text(current_step_key: String) -> String:
	match current_step_key:
		"enemy_1":
			return "ENEMY 1"
		"enemy_2":
			return "ENEMY 2"
		"boss":
			return "BOSS"
		"shop":
			return "SHOP"
		_:
			return current_step_key.to_upper()


func _primary_intent_badge_snapshot(intent: Dictionary, format_intent_compact: Callable = Callable()) -> Dictionary:
	if intent.is_empty():
		return {
			"kind": "idle",
			"title": "Intent",
			"amount": "--",
			"detail": "No immediate action.",
		}
	var entries := _intent_entries_data(intent)
	if entries.is_empty():
		return {
			"kind": "idle",
			"title": "Intent",
			"amount": "--",
			"detail": _format_intent_compact(intent, format_intent_compact),
		}
	var attack_amount := 0
	var block_amount := 0
	for entry in entries:
		var entry_kind := String(entry.get("kind", ""))
		var amount := maxi(0, int(entry.get("amount", 0)))
		if entry_kind == "attack":
			attack_amount += amount
		elif entry_kind == "block":
			block_amount += amount
	var badge_kind := "idle"
	var title := "Intent"
	var amount_text := "--"
	var detail_text := ""
	if attack_amount > 0 and block_amount > 0:
		badge_kind = "mixed"
		title = "Strike + Guard"
		amount_text = "%d / %d" % [attack_amount, block_amount]
		detail_text = "Deals %d and gains %d block." % [attack_amount, block_amount]
	elif attack_amount > 0:
		badge_kind = "attack"
		title = "Attack"
		amount_text = str(attack_amount)
		detail_text = "Incoming damage %d." % attack_amount
	elif block_amount > 0:
		badge_kind = "block"
		title = "Block"
		amount_text = str(block_amount)
		detail_text = "Enemy gains %d block." % block_amount
	else:
		detail_text = _format_intent_compact(intent, format_intent_compact)
	return {
		"kind": badge_kind,
		"title": title,
		"amount": amount_text,
		"detail": detail_text,
	}


func _intent_damage_preview_data(intent: Dictionary, player_hp: int, player_armor: int) -> Dictionary:
	if intent.is_empty():
		return {}
	var attack_entries := _intent_entries_for_kind(intent, "attack")
	if attack_entries.is_empty():
		return {}
	var visible_hp := maxi(0, player_hp)
	if visible_hp <= 0:
		return {}
	var visible_armor := maxi(0, player_armor)
	var attack := 0
	var blocked := 0
	var hp_loss := 0
	for entry in attack_entries:
		var amount := maxi(0, int(entry.get("amount", 0)))
		if amount <= 0:
			continue
		attack += amount
		var entry_blocked := mini(amount, visible_armor - blocked)
		blocked += maxi(0, entry_blocked)
		hp_loss = mini(visible_hp, hp_loss + maxi(0, amount - entry_blocked))
	if blocked <= 0 and hp_loss <= 0:
		return {}
	return {
		"attack": attack,
		"blocked": blocked,
		"hp_loss": hp_loss,
		"current_hp": visible_hp,
		"current_armor": visible_armor,
		"fully_blocked": hp_loss <= 0 and blocked > 0,
	}


func _enemy_intent_preview_data(intent: Dictionary, enemy_hp: int, enemy_max_hp: int) -> Dictionary:
	if intent.is_empty():
		return {}
	var entries := _intent_entries_data(intent)
	if entries.is_empty():
		return {}
	var max_hp := maxi(1, enemy_max_hp)
	var block := 0
	for entry in entries:
		if String(entry.get("kind", "")) == "block":
			block += maxi(0, int(entry.get("amount", 0)))
	return {
		"block": block,
		"current_hp": maxi(0, enemy_hp),
		"max_hp": max_hp,
		"entries": entries,
	}


func _intent_entries_data(intent: Dictionary) -> Array[Dictionary]:
	var raw_entries: Array = []
	if intent.has("entries") and intent.get("entries") is Array:
		raw_entries = intent.get("entries")
	elif intent.has("intents") and intent.get("intents") is Array:
		raw_entries = intent.get("intents")
	var entries: Array[Dictionary] = []
	for raw in raw_entries:
		if not (raw is Dictionary):
			continue
		var raw_entry := raw as Dictionary
		var kind := String(raw_entry.get("kind", raw_entry.get("type", ""))).to_lower()
		var amount := maxi(0, int(raw_entry.get("amount", raw_entry.get(kind, 0))))
		if kind == "attack" and amount <= 0:
			amount = maxi(0, int(raw_entry.get("damage", raw_entry.get("attack", 0))))
		if kind == "block" and amount <= 0:
			amount = maxi(0, int(raw_entry.get("block", 0)))
		if amount <= 0 or (kind != "attack" and kind != "block"):
			continue
		entries.append({
			"id": String(raw_entry.get("id", "%s_%d" % [kind, entries.size()])),
			"kind": kind,
			"amount": amount,
			"label": String(raw_entry.get("label", _intent_entry_label(kind, amount))),
		})
	if entries.is_empty():
		var attack := maxi(0, int(intent.get("attack", 0)))
		if attack > 0:
			entries.append({"id": "attack_0", "kind": "attack", "amount": attack, "label": _intent_entry_label("attack", attack)})
		var block := maxi(0, int(intent.get("block", 0)))
		if block > 0:
			entries.append({"id": "block_%d" % entries.size(), "kind": "block", "amount": block, "label": _intent_entry_label("block", block)})
	return entries


func _intent_entries_for_kind(intent: Dictionary, kind: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry in _intent_entries_data(intent):
		if String(entry.get("kind", "")) == kind:
			entries.append(entry)
	return entries


func _intent_entry_label(kind: String, amount: int) -> String:
	match kind:
		"attack":
			return "Attack %d" % amount
		"block":
			return "Block %d" % amount
		_:
			return "%s %d" % [kind.capitalize(), amount]


func _compact_formatter(data: Dictionary) -> Callable:
	var formatter: Variant = data.get("format_intent_compact", Callable())
	if formatter is Callable and (formatter as Callable).is_valid():
		return formatter as Callable
	return Callable()


func _format_intent_compact(intent: Dictionary, format_intent_compact: Callable) -> String:
	if format_intent_compact.is_valid():
		return String(format_intent_compact.call(intent))
	var label := String(intent.get("label", "Unknown"))
	var attack := int(intent.get("attack", 0))
	var block := int(intent.get("block", 0))
	return "%s (Atk %d / Block %d)" % [label, attack, block]
