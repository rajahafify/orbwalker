extends RefCounted
class_name ContentRegistryShopPricing

const SHOP_MULTIPLIER_MIN := 0.1
const REROLL_COST_CEILING_DEFAULT := 30

var _shop_pricing_config := {
	"rarity_base":
	{
		"common": 10,
		"uncommon": 16,
		"rare": 24,
	},
	"level_step": 2,
	"reroll_base": 1,
	"reroll_step": 1,
	"reroll_max": REROLL_COST_CEILING_DEFAULT,
}
var _prototype_balance_levers := {
	"shop_price_multiplier": 1.0,
	"reroll_cost_multiplier": 1.0,
}


func shop_pricing_config() -> Dictionary:
	var pricing := _shop_pricing_config.duplicate(true)
	var price_multiplier := maxf(SHOP_MULTIPLIER_MIN, float(_prototype_balance_levers.get("shop_price_multiplier", 1.0)))
	var reroll_multiplier := maxf(SHOP_MULTIPLIER_MIN, float(_prototype_balance_levers.get("reroll_cost_multiplier", 1.0)))
	pricing["prototype_balance"] = {
		"temporary": true,
		"shop_price_multiplier": price_multiplier,
		"reroll_cost_multiplier": reroll_multiplier,
	}
	pricing["reroll_max"] = maxi(int(pricing.get("reroll_base", 1)), maxi(1, int(pricing.get("reroll_max", REROLL_COST_CEILING_DEFAULT))))
	return pricing


func set_prototype_balance_levers(levers: Dictionary) -> void:
	_prototype_balance_levers["shop_price_multiplier"] = maxf(
		SHOP_MULTIPLIER_MIN, float(levers.get("shop_price_multiplier", _prototype_balance_levers.get("shop_price_multiplier", 1.0)))
	)
	_prototype_balance_levers["reroll_cost_multiplier"] = maxf(
		SHOP_MULTIPLIER_MIN, float(levers.get("reroll_cost_multiplier", _prototype_balance_levers.get("reroll_cost_multiplier", 1.0)))
	)
