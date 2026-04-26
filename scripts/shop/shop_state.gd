extends RefCounted
class_name ShopState

const SHOP_ITEM_SLOT_COUNT := 3

var active: bool = false
var dungeon_level: int = 1
var item_offers: Array[Dictionary] = []
var relic_offer: Dictionary = {}
var reroll_count: int = 0
var reroll_cost: int = 0
var pending_booster_options: Array[Dictionary] = []
var pending_booster_offer_id: String = ""
var offer_sequence: int = 1
var skipped: bool = false


func reset_for_new_run() -> void:
	active = false
	dungeon_level = 1
	item_offers.clear()
	relic_offer = {}
	reroll_count = 0
	reroll_cost = 0
	pending_booster_options.clear()
	pending_booster_offer_id = ""
	offer_sequence = 1
	skipped = false


func open_for_level(level: int) -> void:
	active = true
	dungeon_level = maxi(1, level)
	item_offers.clear()
	reroll_count = 0
	pending_booster_options.clear()
	pending_booster_offer_id = ""
	skipped = false


func close_shop(mark_skipped: bool = false) -> void:
	active = false
	skipped = mark_skipped
	pending_booster_options.clear()
	pending_booster_offer_id = ""


func next_offer_id(prefix: String) -> String:
	var id := "%s_%d" % [prefix, offer_sequence]
	offer_sequence += 1
	return id


func to_snapshot() -> Dictionary:
	return {
		"active": active,
		"dungeon_level": dungeon_level,
		"item_offers": item_offers.duplicate(true),
		"relic_offer": relic_offer.duplicate(true),
		"reroll_count": reroll_count,
		"reroll_cost": reroll_cost,
		"pending_booster_options": pending_booster_options.duplicate(true),
		"pending_booster_offer_id": pending_booster_offer_id,
		"skipped": skipped,
	}
