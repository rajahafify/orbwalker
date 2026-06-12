extends RefCounted
class_name ShopOfferApplicatorTest

const APPLICATOR_SCRIPT := preload("res://scripts/shop/shop_offer_applicator.gd")
const HANDLERS_SCRIPT := preload("res://scripts/shop/shop_offer_type_handlers.gd")


class FakeProgressionState:
	extends RefCounted

	var equipped_item_ids: Array[String] = ["old_sword"]
	var held_consumable_ids: Array[String] = ["potion"]


class FakeProgressionService:
	extends RefCounted

	var equipped: Array[String] = []
	var consumables: Array[String] = []
	var mastery: Array[Dictionary] = []
	var relics: Array[String] = []
	var replaced_equipment := ""

	func equip_item(_state: Variant, content_id: String, _content: Variant) -> Dictionary:
		equipped.append(content_id)
		return {"ok": true, "reason": "", "result": {"item_id": content_id}}

	func add_consumable(_state: Variant, content_id: String, _content: Variant) -> Dictionary:
		consumables.append(content_id)
		return {"ok": true, "reason": "", "result": {"consumable_id": content_id}}

	func grant_mastery(_state: Variant, orb_id: int, amount: int) -> Dictionary:
		mastery.append({"orb_id": orb_id, "amount": amount})
		return {"ok": true, "reason": "", "result": mastery.back()}

	func add_relic(_state: Variant, content_id: String, _content: Variant) -> Dictionary:
		relics.append(content_id)
		return {"ok": true, "reason": "", "result": {"relic_id": content_id}}

	func replace_equipment(_state: Variant, _slot_index: int, content_id: String, _content: Variant) -> Dictionary:
		replaced_equipment = content_id
		return {"ok": true, "reason": "", "result": {"item_id": content_id}}


class FakeContent:
	extends RefCounted

	func get_mastery_card(_content_id: String) -> Dictionary:
		return {"target_orb_id": OrbType.Id.FIRE, "amount": 2}

	func get_equipment(_content_id: String) -> Dictionary:
		return {"base_price": 9, "sell_value": 6}


class FakeRunState:
	extends RefCounted

	var gold_added := 0

	func add_gold(amount: int, _source: String = "") -> int:
		gold_added += amount
		return gold_added


class CustomHandler:
	extends RefCounted

	func apply_offer(_context: Dictionary, offer: Dictionary) -> Dictionary:
		return {"ok": true, "reason": "", "result": {"custom_id": String(offer.get("content_id", ""))}}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("default_handler_inventory_is_registered", _test_default_handler_inventory_is_registered, failures)
	_run_case("custom_offer_type_can_register_without_service_edit", _test_custom_offer_type_can_register_without_service_edit, failures)
	_run_case("equipment_replacement_handler_preserves_sell_refund", _test_equipment_replacement_handler_preserves_sell_refund, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_default_handler_inventory_is_registered() -> String:
	var applicator: Variant = APPLICATOR_SCRIPT.new()
	var keys: Array[String] = applicator.handler_keys()
	var expected := [
		HANDLERS_SCRIPT.ITEM_TYPE_CONSUMABLE,
		HANDLERS_SCRIPT.ITEM_TYPE_EQUIPMENT,
		HANDLERS_SCRIPT.ITEM_TYPE_MASTERY_CARD,
		HANDLERS_SCRIPT.ITEM_TYPE_RELIC,
		HANDLERS_SCRIPT.ITEM_TYPE_TREASURE_CHEST,
	]
	if keys != expected:
		return "Expected default shop offer handlers %s, got %s." % [str(expected), str(keys)]
	return ""


func _test_custom_offer_type_can_register_without_service_edit() -> String:
	var applicator: Variant = APPLICATOR_SCRIPT.new()
	applicator.register_handler("voucher", CustomHandler.new())
	var result: Dictionary = applicator.apply_offer(_context(), {"type": "voucher", "content_id": "starter_voucher"})
	if not bool(result.get("ok", false)):
		return "Expected custom registered voucher handler to apply."
	if String(Dictionary(result.get("result", {})).get("custom_id", "")) != "starter_voucher":
		return "Expected custom handler to receive the offer payload."
	return ""


func _test_equipment_replacement_handler_preserves_sell_refund() -> String:
	var applicator: Variant = APPLICATOR_SCRIPT.new()
	var context := _context()
	var result: Dictionary = applicator.replace_treasure_chest_option(
		context, {"type": HANDLERS_SCRIPT.ITEM_TYPE_EQUIPMENT, "content_id": "new_sword"}, 0, true
	)
	var run_state: FakeRunState = context["run_state"]
	var service: FakeProgressionService = context["progression_service"]
	if not bool(result.get("ok", false)):
		return "Expected equipment replacement to succeed."
	if service.replaced_equipment != "new_sword":
		return "Expected equipment handler to call replace_equipment."
	if run_state.gold_added != 6:
		return "Expected sell replacement refund to add 6 gold, got %d." % run_state.gold_added
	if int(Dictionary(result.get("result", {})).get("gold_gained", 0)) != 6:
		return "Expected replacement result to include gold_gained."
	return ""


func _context() -> Dictionary:
	return {
		"run_state": FakeRunState.new(),
		"content": FakeContent.new(),
		"shop": RefCounted.new(),
		"offer_policy": RefCounted.new(),
		"progression_state": FakeProgressionState.new(),
		"progression_service": FakeProgressionService.new(),
	}
