extends RefCounted
class_name RunShopFacade

var _owner


func _init(owner) -> void:
	_owner = owner


func open_shop_for_current_level() -> Dictionary:
	return _owner.ensure_shop_session().open_for_current_level(_owner)


func reroll_shop_items() -> Dictionary:
	return _owner.ensure_shop_session().reroll_items(_owner)


func buy_shop_offer(offer_id: String) -> Dictionary:
	return _owner.ensure_shop_session().buy_offer(_owner, offer_id)


func sell_equipped_item(slot_index: int) -> Dictionary:
	return _owner.ensure_shop_session().sell_equipped_item(_owner, slot_index)


func sell_consumable_item(slot_index: int) -> Dictionary:
	return _owner.ensure_shop_session().sell_consumable_item(_owner, slot_index)


func choose_treasure_chest_option(option_index: int) -> Dictionary:
	return _owner.ensure_shop_session().choose_treasure_chest_option(_owner, option_index)


func replace_pending_treasure_chest_option(option_index: int, slot_index: int, sell_replaced: bool = false) -> Dictionary:
	return _owner.ensure_shop_session().replace_pending_treasure_chest_option(_owner, option_index, slot_index, sell_replaced)


func discard_pending_treasure_chest_options() -> Dictionary:
	return _owner.ensure_shop_session().discard_pending_treasure_chest_options(_owner)


func close_shop(mark_skipped: bool = false) -> void:
	_owner.ensure_shop_session().close(_owner, mark_skipped)


func relic_offer_id_for_level(level: int) -> String:
	return String(_owner._relic_offer_ids_by_level.get(maxi(1, level), ""))


func set_relic_offer_id_for_level(level: int, relic_id: String) -> void:
	_owner._relic_offer_ids_by_level[maxi(1, level)] = relic_id


func apply_tutorial_shop_seed(action_offset: int) -> void:
	if not _owner.tutorial_run_active:
		return
	var shop_seed: int = _owner.tutorial_seed + 50000 + _owner.dungeon_level * 1000 + _owner._step_index * 100 + maxi(0, action_offset)
	_owner.ensure_shop_service().set_rng_seed(shop_seed)
