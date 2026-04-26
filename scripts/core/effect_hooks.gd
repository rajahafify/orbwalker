extends RefCounted
class_name EffectHooks

const ON_ITEM_EQUIPPED := "on_item_equipped"
const ON_ITEM_UNEQUIPPED := "on_item_unequipped"
const ON_ITEM_SOLD := "on_item_sold"
const ON_MASTERY_GRANTED := "on_mastery_granted"
const ON_CONSUMABLE_ADDED := "on_consumable_added"
const ON_CONSUMABLE_USED := "on_consumable_used"
const ON_RELIC_ADDED := "on_relic_added"

const PLAYER_STATE_ACTION_HOOKS: Array[String] = [
	ON_ITEM_EQUIPPED,
	ON_ITEM_UNEQUIPPED,
	ON_ITEM_SOLD,
	ON_MASTERY_GRANTED,
	ON_CONSUMABLE_ADDED,
	ON_CONSUMABLE_USED,
	ON_RELIC_ADDED,
]


static func is_valid_hook(hook_name: String) -> bool:
	return hook_name in PLAYER_STATE_ACTION_HOOKS
