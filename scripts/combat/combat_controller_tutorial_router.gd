extends RefCounted
class_name CombatControllerTutorialRouter

var _owner: Variant = null


func bind(owner: Variant) -> void:
	_owner = owner


func turn_summary_text() -> String:
	var tutorial_director: Variant = _owner.get("_tutorial_director")
	if tutorial_director == null:
		return ""
	return tutorial_director.turn_summary_text()


func turn_status_text() -> String:
	var tutorial_director: Variant = _owner.get("_tutorial_director")
	if tutorial_director == null:
		return ""
	var combat: Variant = _owner.get("_combat")
	return tutorial_director.turn_status_text(int(combat.turn_index if combat != null else 1))


func sync_coachmark() -> void:
	bind_coachmark_coordinator()
	_owner.get("_tutorial_coachmark_coordinator").sync()


func bind_prompt_presenter() -> void:
	_owner.set(
		"_tutorial_prompt_presenter",
		_owner.CONTRACT.COMBAT_CONTROLLER_RUNTIME_BINDER_SCRIPT.bind_tutorial_prompt_presenter(
			_owner.get("_tutorial_prompt_presenter"), _owner.CONTRACT.COMBAT_TUTORIAL_PROMPT_PRESENTER_SCRIPT, _owner.get("_host")
		)
	)


func bind_coachmark_coordinator() -> void:
	var contract: Variant = _owner.CONTRACT
	if _owner.get("_tutorial_coachmark_coordinator") == null:
		_owner.set("_tutorial_coachmark_coordinator", contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.new())
	bind_prompt_presenter()
	(
		_owner
		. get("_tutorial_coachmark_coordinator")
		. bind(
			{
				"run_state": RunState,
				"combat": _owner.get("_combat"),
				"tutorial_director": _owner.get("_tutorial_director"),
				"view": _owner.get("_view"),
				"board_view": _owner.get("_board_view"),
				"board_controller": _owner.get("_board_controller"),
				"prompt_presenter": _owner.get("_tutorial_prompt_presenter"),
			},
			{
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_INPUT_PHASE_VALUE: Callable(_owner, "_input_phase_value"),
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner.get("_view_actions"), "set_status_text"),
				contract.COMBAT_TUTORIAL_COACHMARK_COORDINATOR_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner.get("_view_actions"), "set_status_color"),
			},
			{"player_input_phase_value": int(_owner.InputPhase.PLAYER_INPUT), "warning_status_color": contract.STATUS_COLOR_WARNING}
		)
	)


func bind_drag_flow() -> void:
	var contract: Variant = _owner.CONTRACT
	if _owner.get("_tutorial_drag_flow") == null:
		_owner.set("_tutorial_drag_flow", contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.new())
	bind_coachmark_coordinator()
	var set_board_seed_callback: Callable = _owner.call("_board_debug_callback", "set_board_seed")
	(
		_owner
		. get("_tutorial_drag_flow")
		. bind(
			{
				"board_model": _owner.get("_board_model"),
				"board_controller": _owner.get("_board_controller"),
				"tutorial_director": _owner.get("_tutorial_director"),
				"coachmark_coordinator": _owner.get("_tutorial_coachmark_coordinator"),
			},
			{
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_END_DRAG: Callable(_owner, "_end_drag"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_BOARD_SEED: set_board_seed_callback,
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(_owner.get("_view_actions"), "set_status_text"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_SET_STATUS_COLOR: Callable(_owner.get("_view_actions"), "set_status_color"),
				contract.COMBAT_TUTORIAL_DRAG_FLOW_SCRIPT.CALLBACK_BOARD_MODEL_CHANGED: Callable(self, "set_board_model_from_drag_flow"),
			},
			{"warning_status_color": contract.STATUS_COLOR_WARNING}
		)
	)


func set_board_model_from_drag_flow(board_model: BoardModel) -> void:
	_owner.set("_board_model", board_model)
