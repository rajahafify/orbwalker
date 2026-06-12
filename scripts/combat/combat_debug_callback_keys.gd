extends RefCounted
class_name CombatDebugCallbackKeys

const SET_STATUS_TEXT := "set_status_text"
const STATE_SNAPSHOT_DATA := "state_snapshot_data"
const SKIP_TO_FIGHT := "skip_to_fight"
const BOARD_PRINT_DATA := "board_print_data"
const BOARD_REROLL := "board_reroll"
const BOARD_SEED := "board_seed"
const GOLD_ADD := "gold_add"
const GOLD_SET := "gold_set"
const MASTERY_ADD := "mastery_add"
const MASTERY_LIST := "mastery_list"
const CONSUMABLE_ADD := "consumable_add"
const CONSUMABLE_LIST := "consumable_list"
const EQUIPMENT_LIST := "equipment_list"
const EQUIPMENT_DETAILS := "equipment_details"
const EQUIPMENT_ADD := "equipment_add"
const RELIC_LIST := "relic_list"
const RELIC_DETAILS := "relic_details"
const RELIC_ADD := "relic_add"
const FIGHT_WIN := "fight_win"
const FIGHT_LOSE := "fight_lose"

const COMBAT_STATE := "combat_state"
const ENEMY_STATE := "enemy_state"
const PLAYER_HP := "player_hp"
const PLAYER_MAX_HP := "player_max_hp"
const PLAYER_ARMOR := "player_armor"
const ENEMY_DISPLAY_NAME := "enemy_display_name"
const ENEMY_HP := "enemy_hp"
const ENEMY_MAX_HP := "enemy_max_hp"
const ENEMY_TURN_BLOCK := "enemy_turn_block"
const INPUT_PHASE_VALUE := "input_phase_value"
const FORMAT_INTENT := "format_intent"
const BOARD_DEBUG_TEXT := "board_debug_text"

const ON_SKIP_SUCCESS := "on_skip_success"
const CREATE_NEW_BOARD := "create_new_board"
const SET_BOARD_SEED := "set_board_seed"
const UPDATE_HUD := "update_hud"
const SET_INPUT_PHASE := "set_input_phase"
const SET_PENDING_NEXT_SCENE_PATH := "set_pending_next_scene_path"
const SHOW_OUTCOME_SUMMARY := "show_outcome_summary"
const BUILD_RUN_OUTCOME_SUMMARY := "build_run_outcome_summary"

const COMMAND_CALLBACK_KEYS := [
	SET_STATUS_TEXT,
	STATE_SNAPSHOT_DATA,
	SKIP_TO_FIGHT,
	BOARD_PRINT_DATA,
	BOARD_REROLL,
	BOARD_SEED,
	GOLD_ADD,
	GOLD_SET,
	MASTERY_ADD,
	MASTERY_LIST,
	CONSUMABLE_ADD,
	CONSUMABLE_LIST,
	EQUIPMENT_LIST,
	EQUIPMENT_DETAILS,
	EQUIPMENT_ADD,
	RELIC_LIST,
	RELIC_DETAILS,
	RELIC_ADD,
	FIGHT_WIN,
	FIGHT_LOSE,
]

const CONTROLLER_ACTION_CALLBACK_KEYS := [
	SET_STATUS_TEXT,
	ON_SKIP_SUCCESS,
	CREATE_NEW_BOARD,
	SET_BOARD_SEED,
	UPDATE_HUD,
	SET_INPUT_PHASE,
	SET_PENDING_NEXT_SCENE_PATH,
	SHOW_OUTCOME_SUMMARY,
	BUILD_RUN_OUTCOME_SUMMARY,
]

const STATE_CALLBACK_KEYS := [
	COMBAT_STATE,
	ENEMY_STATE,
	PLAYER_HP,
	PLAYER_MAX_HP,
	PLAYER_ARMOR,
	ENEMY_DISPLAY_NAME,
	ENEMY_HP,
	ENEMY_MAX_HP,
	ENEMY_TURN_BLOCK,
	INPUT_PHASE_VALUE,
	FORMAT_INTENT,
	BOARD_SEED,
	BOARD_DEBUG_TEXT,
]


static func controller_action_callbacks(controller: Object) -> Dictionary:
	controller.call("_bind_hud_update_router")
	controller.call("_bind_board_debug_router")
	controller.call("_bind_input_router")
	var hud_update_router: Variant = controller.get("_hud_update_router")
	var board_debug_router: Variant = controller.get("_board_debug_router")
	var input_router: Variant = controller.get("_input_router")
	return {
		SET_STATUS_TEXT: Callable(controller.get("_view_actions"), "console_set_status_text"),
		ON_SKIP_SUCCESS: Callable(board_debug_router, "console_on_skip_success"),
		CREATE_NEW_BOARD: Callable(board_debug_router, "create_new_board"),
		SET_BOARD_SEED: Callable(board_debug_router, "set_board_seed"),
		UPDATE_HUD: Callable(hud_update_router, "update_hud"),
		SET_INPUT_PHASE: Callable(input_router, "debug_set_input_phase"),
		SET_PENDING_NEXT_SCENE_PATH: Callable(input_router, "debug_set_pending_next_scene_path"),
		SHOW_OUTCOME_SUMMARY: Callable(controller.get("_view_actions"), "show_outcome_summary"),
		BUILD_RUN_OUTCOME_SUMMARY: Callable(controller, "_build_run_outcome_summary"),
	}
