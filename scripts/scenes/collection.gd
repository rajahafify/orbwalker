extends Control

const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const BACKGROUND_PATH := "res://resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png"
const MAIN_MENU_SCENE_PATH := "res://scenes/main_menu.tscn"

const TIER_ORDER: Array[String] = ["common", "uncommon", "rare"]
const TIER_REQUIRED_SCORE := {
	"common": 0,
	"uncommon": 100,
	"rare": 300,
}
const TIER_DISPLAY_NAME := {
	"common": "Common",
	"uncommon": "Uncommon",
	"rare": "Rare",
}
const TIER_COLORS := {
	"common": Color(1.0, 1.0, 1.0, 1.0),
	"uncommon": Color(0.45, 0.67, 1.0, 1.0),
	"rare": Color(0.74, 0.49, 1.0, 1.0),
}

const FAMILY_DEFINITIONS: Array[Dictionary] = [
	{
		"id": "shortsword",
		"display_name": "Shortsword",
		"tiers": {
			"common": {"item_id": "shortsword", "display_name": "Iron Shortsword"},
			"uncommon": {"item_id": "shortsword_knight", "display_name": "Knight Shortsword"},
			"rare": {"item_id": "shortsword_royal", "display_name": "Royal Shortsword"},
		},
	},
	{
		"id": "buckler",
		"display_name": "Buckler",
		"tiers": {
			"common": {"item_id": "buckler", "display_name": "Wooden Buckler"},
			"uncommon": {"item_id": "buckler_iron", "display_name": "Iron Buckler"},
			"rare": {"item_id": "buckler_guardian", "display_name": "Guardian Buckler"},
		},
	},
	{
		"id": "coin_purse",
		"display_name": "Coin Purse",
		"tiers": {
			"common": {"item_id": "coin_purse", "display_name": "Worn Coin Purse"},
			"uncommon": {"item_id": "coin_purse_merchant", "display_name": "Merchant Coin Purse"},
			"rare": {"item_id": "coin_purse_noble", "display_name": "Noble Coin Purse"},
		},
	},
	{
		"id": "healing_charm",
		"display_name": "Healing Charm",
		"tiers": {
			"common": {"item_id": "healing_charm", "display_name": "Linen Healing Charm"},
			"uncommon": {"item_id": "healing_charm_blessed", "display_name": "Blessed Healing Charm"},
			"rare": {"item_id": "healing_charm_saint", "display_name": "Saint's Healing Charm"},
		},
	},
	{
		"id": "leather_gloves",
		"display_name": "Leather Gloves",
		"tiers": {
			"common": {"item_id": "leather_gloves", "display_name": "Leather Gloves"},
			"uncommon": {"item_id": "leather_gloves_duelist", "display_name": "Duelist Gloves"},
			"rare": {"item_id": "leather_gloves_blademaster", "display_name": "Blademaster Gloves"},
		},
	},
]

@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _overlay_tint: ColorRect = %OverlayTint
@onready var _main_margin: MarginContainer = %MainMargin
@onready var _title_label: Label = %TitleLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _families_scroll: ScrollContainer = %FamiliesScroll
@onready var _families_vbox: VBoxContainer = %FamiliesVBox
@onready var _back_button: Button = %BackButton
@onready var _status_label: Label = %StatusLabel
@onready var _achievement_toast: Control = %AchievementToast

var _profile_snapshot: Dictionary = {}
var _unlocked_item_ids: Dictionary = {}
var _total_score: int = 0
var _is_transitioning: bool = false


func _ready() -> void:
	_apply_static_chrome()
	_reload_profile_snapshot()
	_render_collection_cards()
	_consume_recent_unlocks_for_toast()


func _on_back_button_pressed() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	_back_button.disabled = true
	var route_id := _flow_trace_begin("collection_to_main_menu", MAIN_MENU_SCENE_PATH, {"source": "collection.back_button"})
	_flow_trace_mark("collection_before_change_scene", {"source": "collection.back_button"}, route_id, MAIN_MENU_SCENE_PATH)
	var transition_result: Variant = _flow_trace_change_scene(
		MAIN_MENU_SCENE_PATH,
		route_id,
		"collection.back_button",
		_on_back_post_ready_rollback
	)
	if _scene_change_succeeded(transition_result):
		return
	_is_transitioning = false
	_back_button.disabled = false
	_set_status("Main Menu failed: %s" % _scene_change_failure_reason(transition_result), true)


func _on_back_post_ready_rollback(result: Dictionary) -> void:
	_is_transitioning = false
	if _back_button != null and is_instance_valid(_back_button):
		_back_button.disabled = false
	_set_status("Main Menu failed: %s" % String(result.get("reason", "prepared_scene_post_ready_check_failed")), true)


func _reload_profile_snapshot() -> void:
	_profile_snapshot = _profile_state_snapshot()
	_total_score = _extract_total_score(_profile_snapshot)
	_unlocked_item_ids = _extract_unlocked_item_ids(_profile_snapshot)
	_score_label.text = "Total Score: %d" % _total_score


func _render_collection_cards() -> void:
	UI_UTILS.clear_children(_families_vbox)
	for family in FAMILY_DEFINITIONS:
		_families_vbox.add_child(_make_family_card(family))


func _make_family_card(family: Dictionary) -> PanelContainer:
	var family_id := String(family.get("id", ""))
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(
			Color(0.08, 0.065, 0.048, 0.94),
			Color(0.68, 0.51, 0.22, 0.96),
			2,
			12,
			Vector4(18, 14, 18, 14)
		)
	)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title := Label.new()
	title.text = String(family.get("display_name", "Family")).to_upper()
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.95, 0.86, 0.62, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.95))
	title.add_theme_constant_override("outline_size", 2)
	vbox.add_child(title)

	for tier_index in TIER_ORDER.size():
		var tier_id := TIER_ORDER[tier_index]
		var tier_info: Dictionary = Dictionary(Dictionary(family.get("tiers", {})).get(tier_id, {}))
		var row := _make_tier_row(family_id, tier_id, tier_index, tier_info)
		vbox.add_child(row)

	return panel


func _make_tier_row(family_id: String, tier_id: String, tier_index: int, tier_info: Dictionary) -> HBoxContainer:
	var item_id := String(tier_info.get("item_id", ""))
	var item_display := String(tier_info.get("display_name", _title_case_id(item_id)))
	var unlocked := _is_tier_unlocked(family_id, tier_id, item_id)
	var previous_unlocked := true
	if tier_index > 0:
		var previous_tier_id := TIER_ORDER[tier_index - 1]
		var previous_info: Dictionary = _family_tier_info(family_id, previous_tier_id)
		previous_unlocked = _is_tier_unlocked(family_id, previous_tier_id, String(previous_info.get("item_id", "")))

	var required_score := int(TIER_REQUIRED_SCORE.get(tier_id, 0))
	var meets_score := _total_score >= required_score
	var claimable := not unlocked and previous_unlocked and meets_score and _has_claim_unlock_api()

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 10)

	var text_column := VBoxContainer.new()
	text_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_column.add_theme_constant_override("separation", 2)
	row.add_child(text_column)

	var primary_label := Label.new()
	primary_label.text = "%s  %s" % [String(TIER_DISPLAY_NAME.get(tier_id, tier_id)).to_upper(), item_display]
	primary_label.add_theme_font_size_override("font_size", 22)
	var tier_color := Color.WHITE
	if TIER_COLORS.has(tier_id):
		tier_color = TIER_COLORS[tier_id]
	primary_label.add_theme_color_override("font_color", tier_color)
	text_column.add_child(primary_label)

	var requirement_label := Label.new()
	requirement_label.text = _tier_requirement_text(tier_id)
	requirement_label.add_theme_font_size_override("font_size", 16)
	requirement_label.add_theme_color_override("font_color", Color(0.78, 0.73, 0.66, 0.95))
	requirement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	text_column.add_child(requirement_label)

	var state_label := Label.new()
	state_label.custom_minimum_size = Vector2(100, 0)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	state_label.add_theme_font_size_override("font_size", 16)
	if unlocked:
		state_label.text = "Unlocked"
		state_label.add_theme_color_override("font_color", Color(0.52, 0.90, 0.62, 1.0))
	else:
		state_label.text = "Locked"
		state_label.add_theme_color_override("font_color", Color(0.95, 0.58, 0.50, 1.0))
	row.add_child(state_label)

	var claim_button := Button.new()
	claim_button.custom_minimum_size = Vector2(208, 56)
	claim_button.text = _claim_button_text(tier_id, unlocked)
	claim_button.disabled = not claimable
	claim_button.add_theme_font_size_override("font_size", 18)
	claim_button.add_theme_stylebox_override(
		"normal",
		UI_UTILS.panel_style(Color(0.20, 0.15, 0.11, 0.98), Color(0.72, 0.54, 0.22, 1.0), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.add_theme_stylebox_override(
		"hover",
		UI_UTILS.panel_style(Color(0.25, 0.18, 0.13, 1.0), Color(0.83, 0.65, 0.31, 1.0), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.add_theme_stylebox_override(
		"disabled",
		UI_UTILS.panel_style(Color(0.13, 0.10, 0.08, 0.92), Color(0.40, 0.32, 0.20, 0.86), 2, 10, Vector4(12, 8, 12, 8))
	)
	claim_button.pressed.connect(_on_claim_button_pressed.bind(family_id, tier_id, item_id, item_display, previous_unlocked, required_score))
	row.add_child(claim_button)

	return row


func _on_claim_button_pressed(
	_family_id: String,
	_tier_id: String,
	item_id: String,
	item_display_name: String,
	previous_unlocked: bool,
	required_score: int
) -> void:
	if item_id == "":
		_set_status("Claim failed: missing item id.", true)
		return
	if not previous_unlocked:
		_set_status("Claim failed: unlock previous tier first.", true)
		return
	if _total_score < required_score:
		_set_status("Claim failed: requires %d total score." % required_score, true)
		return
	var claim_result: Variant = _claim_equipment_unlock(item_id)
	if not _result_ok(claim_result):
		_set_status("Claim failed: %s" % _result_failure_reason(claim_result), true)
		return
	_set_status("Claimed %s." % item_display_name, false)
	if _achievement_toast != null and _achievement_toast.has_method("enqueue_unlock"):
		_achievement_toast.call("enqueue_unlock", item_display_name)
	_reload_profile_snapshot()
	_render_collection_cards()


func _claim_equipment_unlock(item_id: String) -> Variant:
	for method_name in ["claim_equipment_unlock", "claim_meta_equipment_unlock"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name, item_id)
	return {
		"ok": false,
		"reason": "missing_claim_equipment_unlock_api",
	}


func _profile_state_snapshot() -> Dictionary:
	for method_name in ["profile_snapshot", "player_profile_snapshot"]:
		if RunState.has_method(method_name):
			var result: Variant = RunState.call(method_name)
			if result is Dictionary:
				return (result as Dictionary).duplicate(true)
	return _meta_profile_snapshot()


func _meta_profile_snapshot() -> Dictionary:
	for method_name in ["meta_profile_snapshot", "meta_profile", "meta_progress_snapshot"]:
		if RunState.has_method(method_name):
			var result: Variant = RunState.call(method_name)
			if result is Dictionary:
				return (result as Dictionary).duplicate(true)
	return {}


func _extract_total_score(snapshot: Dictionary) -> int:
	if snapshot.has("total_score"):
		return maxi(0, int(snapshot.get("total_score", 0)))
	if snapshot.has("score"):
		return maxi(0, int(snapshot.get("score", 0)))
	if snapshot.has("meta_score"):
		return maxi(0, int(snapshot.get("meta_score", 0)))
	var stats: Dictionary = Dictionary(snapshot.get("stats", {}))
	if stats.has("total_score"):
		return maxi(0, int(stats.get("total_score", 0)))
	return 0


func _extract_unlocked_item_ids(snapshot: Dictionary) -> Dictionary:
	var unlocked: Dictionary = {}
	for key in ["unlocked_equipment_ids", "unlocked_equipment_item_ids", "equipment_unlock_ids"]:
		for raw_id in Array(snapshot.get(key, [])):
			var item_id := String(raw_id)
			if item_id != "":
				unlocked[item_id] = true

	for key in ["equipment_unlocks", "equipment_unlock_state", "equipment_unlock_flags"]:
		var mapping := Dictionary(snapshot.get(key, {}))
		for unlock_key in mapping.keys():
			if bool(mapping.get(unlock_key, false)):
				unlocked[String(unlock_key)] = true

	return unlocked


func _is_tier_unlocked(family_id: String, tier_id: String, item_id: String) -> bool:
	if item_id != "" and _unlocked_item_ids.has(item_id):
		return true

	var families := Dictionary(_profile_snapshot.get("equipment_families", {}))
	if families.has(family_id):
		var family_entry := Dictionary(families.get(family_id, {}))
		if bool(family_entry.get(tier_id, false)):
			return true
		var tier_entry: Variant = Dictionary(family_entry.get("tiers", {})).get(tier_id, {})
		if tier_entry is Dictionary and bool((tier_entry as Dictionary).get("unlocked", false)):
			return true

	var tier_map := Dictionary(_profile_snapshot.get("equipment_unlock_tiers", {}))
	if tier_map.has(family_id):
		if bool(Dictionary(tier_map.get(family_id, {})).get(tier_id, false)):
			return true

	return false


func _family_tier_info(family_id: String, tier_id: String) -> Dictionary:
	for family in FAMILY_DEFINITIONS:
		if String(family.get("id", "")) == family_id:
			var tiers: Dictionary = Dictionary(family.get("tiers", {}))
			return Dictionary(tiers.get(tier_id, {}))
	return {}


func _tier_requirement_text(tier_id: String) -> String:
	match tier_id:
		"common":
			return "Requirement: 0 Total Score."
		"uncommon":
			return "Requirement: Common unlocked and 100 Total Score."
		"rare":
			return "Requirement: Uncommon unlocked and 300 Total Score."
		_:
			return "Requirement: Unknown."


func _claim_button_text(tier_id: String, unlocked: bool) -> String:
	if unlocked:
		return "Claimed"
	var score: int = int(TIER_REQUIRED_SCORE.get(tier_id, 0))
	return "Claim (%d Score)" % score


func _has_claim_unlock_api() -> bool:
	return RunState.has_method("claim_equipment_unlock") or RunState.has_method("claim_meta_equipment_unlock")


func _consume_recent_unlocks_for_toast() -> void:
	var payload: Variant = _consume_recent_unlock_payload()
	var entries: Array[Dictionary] = _normalize_unlock_entries(payload)
	if entries.is_empty():
		return
	if _achievement_toast != null and _achievement_toast.has_method("enqueue_unlock_entries"):
		_achievement_toast.call("enqueue_unlock_entries", entries)
		return
	if _achievement_toast != null and _achievement_toast.has_method("enqueue_unlock"):
		for entry in entries:
			var display_name := String(entry.get("display_name", entry.get("item_name", entry.get("item_id", "Unknown Item"))))
			_achievement_toast.call("enqueue_unlock", display_name)


func _consume_recent_unlock_payload() -> Variant:
	for method_name in ["consume_recent_equipment_unlocks", "consume_recent_unlocks", "consume_recent_meta_unlocks"]:
		if RunState.has_method(method_name):
			return RunState.call(method_name)
	return []


func _normalize_unlock_entries(payload: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if payload is Array:
		for entry in payload as Array:
			if entry is Dictionary:
				out.append((entry as Dictionary).duplicate(true))
			elif entry is String:
				out.append({"item_id": String(entry), "display_name": _title_case_id(String(entry))})
		return out
	if payload is Dictionary:
		var typed_payload := payload as Dictionary
		for key in ["unlocks", "recent_unlocks", "recent_equipment_unlocks"]:
			if typed_payload.has(key):
				return _normalize_unlock_entries(typed_payload.get(key, []))
	return out


func _flow_trace_begin(route_name: String, target_scene: String, details: Dictionary) -> String:
	return String(RunState.flow_trace_begin(route_name, target_scene, details))


func _flow_trace_mark(step: String, details: Dictionary, route_id: String, target_scene: String) -> void:
	RunState.flow_trace_mark(step, details, route_id, target_scene)


func _flow_trace_change_scene(
	target_scene: String,
	route_id: String,
	source: String,
	post_ready_failure_callback: Callable = Callable()
) -> Variant:
	return RunState.flow_trace_change_scene(get_tree(), target_scene, route_id, source, "", post_ready_failure_callback)


func _scene_change_succeeded(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	return (int(result) as Error) == OK


func _scene_change_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is bool:
		return "unknown"
	return "error_code_%d" % int(result)


func _result_ok(result: Variant) -> bool:
	if result is Dictionary:
		return bool((result as Dictionary).get("ok", false))
	if result is bool:
		return bool(result)
	if result is int:
		return (int(result) as Error) == OK
	return false


func _result_failure_reason(result: Variant) -> String:
	if result is Dictionary:
		var typed_result := result as Dictionary
		return String(typed_result.get("reason", typed_result.get("error", "unknown")))
	if result is int:
		return "error_code_%d" % int(result)
	return "unknown"


func _set_status(message: String, is_error: bool) -> void:
	_status_label.text = message
	_status_label.add_theme_color_override(
		"font_color",
		Color(0.95, 0.45, 0.41, 1.0) if is_error else Color(0.66, 0.90, 0.70, 1.0)
	)


func _title_case_id(value: String) -> String:
	var words := value.replace("_", " ").split(" ", false)
	for index in words.size():
		words[index] = String(words[index]).capitalize()
	return " ".join(words)


func _apply_static_chrome() -> void:
	_background_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
	_background_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED as TextureRect.StretchMode
	_background_texture.texture = load(BACKGROUND_PATH)
	_overlay_tint.color = Color(0.02, 0.03, 0.05, 0.54)

	_main_margin.add_theme_constant_override("margin_left", 34)
	_main_margin.add_theme_constant_override("margin_top", 44)
	_main_margin.add_theme_constant_override("margin_right", 34)
	_main_margin.add_theme_constant_override("margin_bottom", 30)

	_title_label.add_theme_font_size_override("font_size", 64)
	_title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.46, 1.0))
	_title_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.03, 0.95))
	_title_label.add_theme_constant_override("outline_size", 3)

	_score_label.add_theme_font_size_override("font_size", 32)
	_score_label.add_theme_color_override("font_color", Color(0.95, 0.90, 0.80, 1.0))
	_score_label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.02, 0.95))
	_score_label.add_theme_constant_override("outline_size", 2)

	_families_scroll.add_theme_stylebox_override(
		"panel",
		UI_UTILS.panel_style(Color(0.05, 0.045, 0.04, 0.75), Color(0.52, 0.39, 0.20, 0.76), 2, 10, Vector4(8, 8, 8, 8))
	)
	_families_vbox.custom_minimum_size = Vector2(960, 0)

	_back_button.custom_minimum_size = Vector2(220, 62)
	_back_button.add_theme_font_size_override("font_size", 24)
	_back_button.add_theme_stylebox_override(
		"normal",
		UI_UTILS.panel_style(Color(0.14, 0.11, 0.09, 0.95), Color(0.70, 0.52, 0.24, 0.98), 2, 10, Vector4(18, 12, 18, 12))
	)
	_back_button.add_theme_stylebox_override(
		"hover",
		UI_UTILS.panel_style(Color(0.20, 0.15, 0.11, 0.98), Color(0.82, 0.64, 0.32, 1.0), 2, 10, Vector4(18, 12, 18, 12))
	)

	_status_label.add_theme_font_size_override("font_size", 18)
	_status_label.add_theme_color_override("font_color", Color(0.80, 0.75, 0.68, 1.0))
