extends RefCounted
class_name CollectionModel

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

var _profile_snapshot: Dictionary = {}
var _unlocked_item_ids: Dictionary = {}
var _total_score: int = 0

func refresh_from_run_state() -> void:
	_profile_snapshot = _profile_state_snapshot()
	_total_score = _extract_total_score(_profile_snapshot)
	_unlocked_item_ids = _extract_unlocked_item_ids(_profile_snapshot)


func score_text() -> String:
	return "Total Score: %d" % _total_score


func family_view_models() -> Array[Dictionary]:
	var families: Array[Dictionary] = []
	for family in FAMILY_DEFINITIONS:
		var family_id := String(family.get("id", ""))
		var entry := {
			"family_id": family_id,
			"display_name": String(family.get("display_name", "Family")),
			"tiers": [],
		}
		var tiers: Array = entry["tiers"]
		for tier_index in TIER_ORDER.size():
			var tier_id := TIER_ORDER[tier_index]
			var tier_info: Dictionary = Dictionary(Dictionary(family.get("tiers", {})).get(tier_id, {}))
			var item_id := String(tier_info.get("item_id", ""))
			var previous_unlocked := true
			if tier_index > 0:
				var previous_tier_id := TIER_ORDER[tier_index - 1]
				var previous_info: Dictionary = _family_tier_info(family_id, previous_tier_id)
				previous_unlocked = _is_tier_unlocked(family_id, previous_tier_id, String(previous_info.get("item_id", "")))
			var unlocked := _is_tier_unlocked(family_id, tier_id, item_id)
			var required_score := int(TIER_REQUIRED_SCORE.get(tier_id, 0))
			var claimable := not unlocked and previous_unlocked and _total_score >= required_score
			var state_text := "Unlocked" if unlocked else "Locked"
			var state_color := Color(0.52, 0.90, 0.62, 1.0) if unlocked else Color(0.95, 0.58, 0.50, 1.0)
			var tier_color: Color = Color(TIER_COLORS.get(tier_id, Color.WHITE))
			tiers.append({
				"family_id": family_id,
				"tier_id": tier_id,
				"tier_index": tier_index,
				"item_id": item_id,
				"item_display_name": String(tier_info.get("display_name", _title_case_id(item_id))),
				"tier_label": String(TIER_DISPLAY_NAME.get(tier_id, tier_id)).to_upper(),
				"tier_color": tier_color,
				"requirement_text": _tier_requirement_text(tier_id),
				"required_score": required_score,
				"previous_unlocked": previous_unlocked,
				"unlocked": unlocked,
				"state_text": state_text,
				"state_color": state_color,
				"claimable": claimable and has_claim_unlock_api(),
				"claim_button_text": _claim_button_text(tier_id, unlocked),
			})
		families.append(entry)
	return families


func validate_claim(payload: Dictionary) -> Dictionary:
	var item_id := String(payload.get("item_id", ""))
	if item_id == "":
		return {"ok": false, "reason": "missing item id."}
	if not bool(payload.get("previous_unlocked", false)):
		return {"ok": false, "reason": "unlock previous tier first."}
	var required_score := int(payload.get("required_score", 0))
	if _total_score < required_score:
		return {"ok": false, "reason": "requires %d total score." % required_score}
	return {"ok": true}


func has_claim_unlock_api() -> bool:
	return RunState.has_method("claim_equipment_unlock") or RunState.has_method("claim_meta_equipment_unlock")


func consume_recent_unlock_entries() -> Array[Dictionary]:
	return _normalize_unlock_entries(_consume_recent_unlock_payload())


func snapshot() -> Dictionary:
	return {
		"profile_snapshot": _profile_snapshot.duplicate(true),
		"total_score": _total_score,
		"unlocked_count": _unlocked_item_ids.size(),
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
	if tier_map.has(family_id) and bool(Dictionary(tier_map.get(family_id, {})).get(tier_id, false)):
		return true
	return false


func _family_tier_info(family_id: String, tier_id: String) -> Dictionary:
	for family in FAMILY_DEFINITIONS:
		if String(family.get("id", "")) == family_id:
			return Dictionary(Dictionary(family.get("tiers", {})).get(tier_id, {}))
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
	return "Claim (%d Score)" % int(TIER_REQUIRED_SCORE.get(tier_id, 0))


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


func _title_case_id(value: String) -> String:
	var words := value.replace("_", " ").split(" ", false)
	for index in words.size():
		words[index] = String(words[index]).capitalize()
	return " ".join(words)
