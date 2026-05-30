extends RefCounted
class_name CombatHudSnapshotPresenter

const COMBAT_TIMER_DISPLAY_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_timer_display_presenter.gd")
const NODE_BINDINGS := {
	"title_label": "_title_label",
	"enemy_step_label": "_enemy_step_label",
	"hint_label": "_hint_label",
	"intent_badge": "_intent_badge",
	"primary_intent_text_column": "_primary_intent_text_column",
	"primary_intent_title_label": "_primary_intent_title_label",
	"primary_intent_amount_label": "_primary_intent_amount_label",
	"primary_intent_detail_label": "_primary_intent_detail_label",
	"phase_label": "_phase_label",
	"timer_track": "_timer_track",
	"timer_fill": "_timer_fill",
	"timer_label": "_timer_label",
	"timer_state_label": "_timer_state_label",
	"timer_icon": "_timer_icon",
	"player_label": "_player_label",
	"player_hp_bar": "_player_hp_bar",
	"player_armor_bar": "_player_armor_bar",
	"player_armor_label": "_player_armor_label",
	"armor_badge": "_armor_badge",
	"armor_badge_label": "_armor_badge_label",
	"attack_stat_label": "_attack_stat_label",
	"armor_stat_label": "_armor_stat_label",
	"heart_stat_label": "_heart_stat_label",
	"gold_stat_label": "_gold_stat_label",
	"run_progress_label": "_run_progress_label",
	"turn_summary_label": "_turn_summary_label",
	"status_label": "_status_label",
	"enemy_debug_label": "_enemy_debug_label",
}

var _nodes: Dictionary = {}


static func nodes_from_root_nodes(root_nodes: Dictionary) -> Dictionary:
	var nodes := {}
	for key in NODE_BINDINGS.keys():
		nodes[key] = root_nodes.get(String(NODE_BINDINGS[key]), null)
	return nodes


func bind(root_nodes: Dictionary) -> void:
	_nodes = nodes_from_root_nodes(root_nodes)


func apply_top_hud(snapshot: Dictionary) -> void:
	_set_label_text("title_label", String(snapshot.get("level_text", "LEVEL")))
	_set_label_text("enemy_step_label", String(snapshot.get("enemy_step_text", "FIGHT")))
	_set_label_text("hint_label", format_top_gold_text(String(snapshot.get("gold_text", "GOLD 0"))))


func apply_primary_intent_badge(_snapshot: Dictionary) -> void:
	_set_canvas_item_visible("intent_badge", false)
	_set_canvas_item_visible("primary_intent_text_column", false)
	_set_canvas_item_visible("primary_intent_title_label", false)
	_set_canvas_item_visible("primary_intent_amount_label", false)
	_set_canvas_item_visible("primary_intent_detail_label", false)


func apply_tempo_row(snapshot: Dictionary) -> void:
	_set_label_text("phase_label", String(snapshot.get("phase_text", "")))
	COMBAT_TIMER_DISPLAY_PRESENTER_SCRIPT.apply_to_nodes(
		{
			"timer_track": _nodes.get("timer_track", null),
			"timer_fill": _nodes.get("timer_fill", null),
			"timer_label": _nodes.get("timer_label", null),
			"timer_state_label": _nodes.get("timer_state_label", null),
			"timer_icon": _nodes.get("timer_icon", null),
		},
		float(snapshot.get("timer_seconds", 0.0)),
		String(snapshot.get("timer_state", "ready"))
	)


func apply_player_strip(snapshot: Dictionary, callbacks: Dictionary = {}) -> void:
	_set_label_text("player_label", String(snapshot.get("player_text", "")))
	var hp_bar := _nodes.get("player_hp_bar") as ProgressBar
	if hp_bar != null:
		hp_bar.max_value = float(maxi(1, int(snapshot.get("player_hp_max", 1))))
		hp_bar.value = float(int(snapshot.get("player_hp_value", 0)))
	var armor_bar := _nodes.get("player_armor_bar") as ProgressBar
	if armor_bar != null:
		armor_bar.max_value = float(maxi(1, int(snapshot.get("player_armor_max", 1))))
		armor_bar.value = float(maxi(0, int(snapshot.get("player_armor_value", 0))))
	_set_label_text("player_armor_label", String(snapshot.get("player_armor_text", "0 / 0")))
	_set_canvas_item_visible("armor_badge", false)
	_set_label_text("armor_badge_label", String(snapshot.get("armor_badge_text", "")))
	_set_label_text("attack_stat_label", String(snapshot.get("attack_stat_text", "")))
	_set_label_text("armor_stat_label", String(snapshot.get("armor_stat_text", "")))
	_set_label_text("heart_stat_label", String(snapshot.get("heart_stat_text", "")))
	_set_label_text("gold_stat_label", String(snapshot.get("gold_stat_text", "")))
	_set_label_text("run_progress_label", String(snapshot.get("run_progress_text", "")))
	_set_label_text("phase_label", String(snapshot.get("phase_text", "")))
	_set_label_text("turn_summary_label", String(snapshot.get("turn_summary_text", "")))
	var progression_snapshot: Dictionary = snapshot.get("progression_snapshot", {})
	var refresh_callback: Variant = callbacks.get("refresh_build_icon_rows", Callable())
	if refresh_callback is Callable and (refresh_callback as Callable).is_valid():
		(refresh_callback as Callable).call(progression_snapshot)


func apply_debug_overlay(snapshot: Dictionary) -> void:
	_set_label_text("status_label", String(snapshot.get("status_text", "")))
	_set_label_text("enemy_debug_label", String(snapshot.get("enemy_text", "")))


static func format_top_gold_text(text: String) -> String:
	var clean_text := text.strip_edges()
	if clean_text.begins_with("$"):
		return "$%s" % clean_text.substr(1).strip_edges()
	if clean_text.to_upper().begins_with("GOLD"):
		var amount_text := clean_text.substr(4).strip_edges()
		return "$%s" % amount_text
	return clean_text


func _set_label_text(node_key: String, text: String) -> void:
	var label := _nodes.get(node_key) as Label
	if label != null:
		label.text = text


func _set_canvas_item_visible(node_key: String, visible: bool) -> void:
	var canvas_item := _nodes.get(node_key) as CanvasItem
	if canvas_item != null:
		canvas_item.visible = visible
