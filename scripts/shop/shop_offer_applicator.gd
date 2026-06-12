extends RefCounted
class_name ShopOfferApplicator

const HANDLERS_SCRIPT := preload("res://scripts/shop/shop_offer_type_handlers.gd")

var _handlers: Dictionary = {}


func _init(handlers: Dictionary = {}) -> void:
	_handlers = HANDLERS_SCRIPT.default_handlers()
	for offer_type in handlers.keys():
		register_handler(String(offer_type), handlers[offer_type])


func register_handler(offer_type: String, handler: Variant) -> void:
	if offer_type == "" or handler == null:
		return
	_handlers[offer_type] = handler


func handler_keys() -> Array[String]:
	var keys: Array[String] = []
	for key in _handlers.keys():
		keys.append(String(key))
	keys.sort()
	return keys


func apply_offer(context: Dictionary, offer: Dictionary) -> Dictionary:
	return _call_handler(String(offer.get("type", "")), "apply_offer", [context, offer], "unsupported_offer_type")


func apply_treasure_chest_option(context: Dictionary, option: Dictionary) -> Dictionary:
	return _call_handler(String(option.get("type", "")), "apply_treasure_chest_option", [context, option], "unsupported_treasure_chest_option")


func replace_treasure_chest_option(context: Dictionary, option: Dictionary, slot_index: int, sell_replaced: bool) -> Dictionary:
	return _call_handler(
		String(option.get("type", "")), "replace_treasure_chest_option", [context, option, slot_index, sell_replaced], "unsupported_replacement_option"
	)


func _call_handler(offer_type: String, method_name: String, args: Array, unsupported_reason: String) -> Dictionary:
	var handler: Variant = _handlers.get(offer_type)
	if handler == null or not handler.has_method(method_name):
		return {"ok": false, "reason": unsupported_reason}
	return Dictionary(handler.callv(method_name, args))
