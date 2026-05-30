extends RefCounted
class_name TutorialDirector

const STEP_NONE := ""
const STEP_FIRST_SWAP := "first_swap"
const STEP_ARMOR_BLOCK := "armor_block"
const STEP_HEART_HEAL := "heart_heal"
const STEP_COMBO_FINISHER := "combo_finisher"
const STEP_SHOP_DAMAGE := "shop_damage"

const POST_SHOP_SHORTSWORD := "shortsword"
const POST_SHOP_MASTERY := "mastery"
const POST_SHOP_END := "end"

const PROMPT_ANCHOR_ABOVE_BOARD := "above_board"
const PROMPT_ANCHOR_BELOW_INTENT := "below_intent"
const PROMPT_ANCHOR_BOTTOM := "bottom"

const FIRST_SWAP_PATH: Array[Vector2i] = [
	Vector2i(0, 2),
	Vector2i(1, 2),
]
const ARMOR_BLOCK_PATH: Array[Vector2i] = [
	Vector2i(2, 2),
	Vector2i(2, 3),
	Vector2i(2, 4),
	Vector2i(1, 4),
	Vector2i(1, 5),
]
const HEART_HEAL_PATH: Array[Vector2i] = [
	Vector2i(3, 3),
	Vector2i(2, 3),
]
const COMBO_FINISHER_PATH: Array[Vector2i] = [
	Vector2i(4, 0),
	Vector2i(4, 1),
	Vector2i(3, 1),
	Vector2i(2, 1),
	Vector2i(1, 1),
	Vector2i(1, 2),
	Vector2i(1, 3),
	Vector2i(1, 4),
	Vector2i(1, 5),
	Vector2i(2, 5),
	Vector2i(3, 5),
	Vector2i(4, 5),
	Vector2i(4, 4),
	Vector2i(4, 3),
	Vector2i(4, 2),
	Vector2i(4, 1),
]

var _end_choice_dismissed := false
var _post_shop_step := POST_SHOP_SHORTSWORD


func reset() -> void:
	_end_choice_dismissed = false
	_post_shop_step = POST_SHOP_SHORTSWORD


func post_shop_step() -> String:
	return _post_shop_step


func end_choice_dismissed() -> bool:
	return _end_choice_dismissed


func dismiss_end_choice() -> void:
	_end_choice_dismissed = true


func advance_post_shop_step() -> String:
	if _post_shop_step == POST_SHOP_SHORTSWORD:
		_post_shop_step = POST_SHOP_MASTERY
		return _post_shop_step
	if _post_shop_step == POST_SHOP_MASTERY:
		_post_shop_step = POST_SHOP_END
		return _post_shop_step
	_end_choice_dismissed = true
	return ""


func active_step(context: Dictionary) -> String:
	if not bool(context.get("tutorial_run_active", false)):
		return STEP_NONE
	if bool(context.get("fight_over", true)):
		return STEP_NONE
	if not bool(context.get("input_is_player_input", false)):
		return STEP_NONE

	var dungeon_level := int(context.get("dungeon_level", 0))
	var step_key := String(context.get("step_key", ""))
	var turn_index := int(context.get("turn_index", 1))
	if dungeon_level == 1 and step_key == "enemy_1":
		return _first_fight_step(turn_index)
	if dungeon_level == 1 and step_key == "enemy_2":
		return _post_shop_combat_step(turn_index, Dictionary(context.get("progression_snapshot", {})))
	return STEP_NONE


func turn_summary_text() -> String:
	return "Tutorial: drag to line up 3+ matching orbs. Mastery cards show what each orb type does."


func turn_status_text(turn_index: int) -> String:
	if turn_index <= 1:
		return "Tutorial: swap the highlighted Gold and Fire orbs to make a vertical Fire match."
	if turn_index == 2:
		return "Tutorial: the enemy is attacking. Match Shield orbs to gain block before damage lands."
	if turn_index == 3:
		return "Tutorial: match Heart orbs to heal the damage you took."
	if turn_index == 4:
		return "Tutorial: make multiple combos to finish the Training Striker."
	return "Tutorial: match Fire/Ice/Earth for damage, Heart to heal, Armor to block, and Gold for shop money."


func drag_path_for_step(step: String) -> Array[Vector2i]:
	match step:
		STEP_FIRST_SWAP:
			return _copy_path(FIRST_SWAP_PATH)
		STEP_ARMOR_BLOCK:
			return _copy_path(ARMOR_BLOCK_PATH)
		STEP_HEART_HEAL:
			return _copy_path(HEART_HEAL_PATH)
		STEP_COMBO_FINISHER:
			return _copy_path(COMBO_FINISHER_PATH)
		_:
			return []


func prompt_message(step: String) -> String:
	match step:
		STEP_FIRST_SWAP:
			return "Swap these two orbs.\nDrag Gold right into Fire."
		STEP_ARMOR_BLOCK:
			return "Enemy attack incoming.\nMove Earth: down 2, left 1, down 1.\nShield orbs block damage."
		STEP_HEART_HEAL:
			return "You blocked the attack partially,\nbut still take some damage.\nMatch Heart Orbs to heal the damage."
		STEP_COMBO_FINISHER:
			return "Win by manipulating the board to create multiple combo.\n(Damage is multiplied by combo counts)"
		_:
			return ""


func prompt_anchor(step: String) -> String:
	if step == STEP_FIRST_SWAP:
		return PROMPT_ANCHOR_ABOVE_BOARD
	if step == STEP_ARMOR_BLOCK or step == STEP_HEART_HEAL or step == STEP_COMBO_FINISHER:
		return PROMPT_ANCHOR_BOTTOM
	return PROMPT_ANCHOR_ABOVE_BOARD


func retry_status_text(step: String) -> String:
	match step:
		STEP_ARMOR_BLOCK:
			return "Tutorial: free-move the highlighted Earth orb down 2, left 1, then down 1."
		STEP_HEART_HEAL:
			return "Tutorial: drag the highlighted Heart orb left to make a vertical Heart match."
		STEP_COMBO_FINISHER:
			return "Tutorial: follow the highlighted path to build a finishing combo chain."
		_:
			return "Tutorial: drag the highlighted Gold orb right into the highlighted Fire orb."


func intent_focus_kind(step: String) -> String:
	match step:
		STEP_ARMOR_BLOCK, STEP_COMBO_FINISHER:
			return "attack"
		STEP_HEART_HEAL:
			return "block"
		_:
			return ""


func end_modal_status_text(step: String) -> String:
	match step:
		POST_SHOP_SHORTSWORD:
			return "Tutorial: Iron Shortsword adds +2 Attack."
		POST_SHOP_MASTERY:
			return "Tutorial: Mastery sets each orb type's base power."
		_:
			return "Tutorial complete."


func did_complete_drag_path(drag_path: Array, expected_path: Array[Vector2i]) -> bool:
	if drag_path.size() < expected_path.size():
		return false
	for index in expected_path.size():
		if not (drag_path[index] is Vector2i):
			return false
		if (drag_path[index] as Vector2i) != expected_path[index]:
			return false
	return true


func _first_fight_step(turn_index: int) -> String:
	match turn_index:
		1:
			return STEP_FIRST_SWAP
		2:
			return STEP_ARMOR_BLOCK
		3:
			return STEP_HEART_HEAL
		4:
			return STEP_COMBO_FINISHER
		_:
			return STEP_NONE


func _post_shop_combat_step(turn_index: int, progression_snapshot: Dictionary) -> String:
	if _end_choice_dismissed:
		return STEP_NONE
	if turn_index != 1:
		return STEP_NONE
	if not _has_equipped_item(progression_snapshot, "shortsword"):
		return STEP_NONE
	return STEP_SHOP_DAMAGE


func _has_equipped_item(progression_snapshot: Dictionary, item_id: String) -> bool:
	for raw_id in Array(progression_snapshot.get("equipment_slots", [])):
		if String(raw_id) == item_id:
			return true
	return false


func _copy_path(source: Array[Vector2i]) -> Array[Vector2i]:
	var copied: Array[Vector2i] = []
	copied.append_array(source)
	return copied
