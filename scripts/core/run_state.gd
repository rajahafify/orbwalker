extends Node

const PLAYER_STATE_SCRIPT := preload("res://scripts/combat/player_state.gd")
const PLAYER_PROGRESSION_STATE_SCRIPT := preload("res://scripts/run/player_progression_state.gd")
const PLAYER_PROGRESSION_SERVICE_SCRIPT := preload("res://scripts/run/player_progression_service.gd")
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const SHOP_STATE_SCRIPT := preload("res://scripts/shop/shop_state.gd")
const SHOP_SERVICE_SCRIPT := preload("res://scripts/shop/shop_service.gd")

var player_state
var player_progression_state
var player_progression_service
var content_registry
var shop_state
var shop_service
var run_gold: int = 0
var dungeon_level: int = 1
var _relic_offer_ids_by_level: Dictionary = {}
var _player_state_content_errors: Array[Dictionary] = []


func _ready() -> void:
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	ensure_player_progression_state()
	ensure_player_progression_service()
	ensure_shop_state()
	ensure_shop_service()
	_sync_player_gold_from_run()
	validate_player_state_content()


func ensure_player_state():
	if player_state == null:
		player_state = PLAYER_STATE_SCRIPT.new()
	return player_state


func ensure_player_progression_state():
	if player_progression_state == null:
		player_progression_state = PLAYER_PROGRESSION_STATE_SCRIPT.new()
	return player_progression_state


func ensure_player_progression_service():
	if player_progression_service == null:
		player_progression_service = PLAYER_PROGRESSION_SERVICE_SCRIPT.new()
	return player_progression_service


func ensure_content_registry():
	if content_registry == null:
		content_registry = CONTENT_REGISTRY_SCRIPT.new()
	return content_registry


func ensure_shop_state():
	if shop_state == null:
		shop_state = SHOP_STATE_SCRIPT.new()
	return shop_state


func ensure_shop_service():
	if shop_service == null:
		shop_service = SHOP_SERVICE_SCRIPT.new()
	return shop_service


func validate_player_state_content() -> Array[Dictionary]:
	_player_state_content_errors = ensure_content_registry().validate_player_state_content()
	return _player_state_content_errors.duplicate(true)


func player_state_content_errors() -> Array[Dictionary]:
	return _player_state_content_errors.duplicate(true)


func progression_snapshot() -> Dictionary:
	return ensure_player_progression_state().to_snapshot()


func set_gold(amount: int) -> void:
	run_gold = maxi(0, amount)
	_sync_player_gold_from_run()


func add_gold(amount: int) -> int:
	if amount <= 0:
		return 0
	run_gold += amount
	_sync_player_gold_from_run()
	return amount


func spend_gold(amount: int) -> bool:
	if amount < 0:
		return false
	if run_gold < amount:
		return false
	run_gold -= amount
	_sync_player_gold_from_run()
	return true


func can_afford(amount: int) -> bool:
	return amount >= 0 and run_gold >= amount


func open_shop_for_current_level() -> Dictionary:
	return ensure_shop_service().open_shop(self, dungeon_level)


func reroll_shop_items() -> Dictionary:
	return ensure_shop_service().reroll_shop_items(self)


func buy_shop_offer(offer_id: String) -> Dictionary:
	return ensure_shop_service().buy_offer(self, offer_id)


func sell_equipped_item(slot_index: int) -> Dictionary:
	return ensure_shop_service().sell_equipped_item(self, slot_index)


func choose_booster_option(option_index: int) -> Dictionary:
	return ensure_shop_service().choose_booster_option(self, option_index)


func close_shop(mark_skipped: bool = false) -> void:
	ensure_shop_state().close_shop(mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return String(_relic_offer_ids_by_level.get(maxi(1, level), ""))


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_relic_offer_ids_by_level[maxi(1, level)] = relic_id


func reset_run() -> void:
	ensure_player_state().reset_for_new_run()
	run_gold = ensure_player_state().gold
	dungeon_level = 1
	_relic_offer_ids_by_level.clear()
	ensure_player_progression_state().reset_for_new_run()
	ensure_shop_state().reset_for_new_run()
	validate_player_state_content()


func _sync_player_gold_from_run() -> void:
	ensure_player_state().gold = run_gold
