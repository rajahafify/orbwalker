extends RefCounted
class_name CombatControllerStateInitializerTest

const INITIALIZER_SCRIPT := preload("res://scripts/combat/combat_controller_state_initializer.gd")


class FakePlayerState:
	extends RefCounted

	var current_hp := 28
	var max_hp := 30
	var armor := 4
	var gold := 12
	var mastery_provider: Callable = Callable()

	func set_mastery_level_provider(provider: Callable) -> void:
		mastery_provider = provider


class FakeProgressionState:
	extends RefCounted

	func mastery_level(_orb_id: int) -> int:
		return 0

	func to_snapshot() -> Dictionary:
		return {"mastery": "snapshot"}


class FakeEnemyState:
	extends RefCounted

	var display_name := ""
	var max_hp := 0
	var current_hp := 0
	var current_turn_block := 0

	func configure_from_blueprint(blueprint: Dictionary) -> void:
		display_name = String(blueprint.get("display_name", "Enemy"))
		max_hp = int(blueprint.get("max_hp", 10))
		current_hp = max_hp


class FakeEnemyStateScript:
	extends RefCounted

	func new() -> FakeEnemyState:
		return FakeEnemyState.new()


class FakeCombatState:
	extends RefCounted

	var started := false
	var player_state: Variant = null
	var enemy_state: Variant = null

	func start_fight(player: Variant, enemy: Variant) -> void:
		started = true
		player_state = player
		enemy_state = enemy


class FakeCombatStateScript:
	extends RefCounted

	func new() -> FakeCombatState:
		return FakeCombatState.new()


class FakeModel:
	extends RefCounted

	var cleared_outcome := false
	var cleared_next_scene := false

	func clear_outcome_transition_queued() -> void:
		cleared_outcome = true

	func clear_pending_next_scene_path() -> void:
		cleared_next_scene = true


class FakeViewActions:
	extends RefCounted

	var hidden := false
	var status_text := ""
	var status_color := Color.TRANSPARENT
	var boss_summary := ""
	var log_lines: Array[String] = []

	func hide_outcome_summary() -> void:
		hidden = true

	func show_boss_reward_summary(body: String) -> void:
		boss_summary = body

	func set_status_text(text: String) -> void:
		status_text = text

	func set_status_color(color: Color) -> void:
		status_color = color

	func append_combat_log(text: String) -> void:
		log_lines.append(text)


class FakeRunState:
	extends RefCounted

	var run_active := true
	var boss_reward := false
	var fight := true
	var dungeon_level := 1
	var started_new_run := false
	var player_state := FakePlayerState.new()
	var progression_state := FakeProgressionState.new()
	var marks: Array[String] = []

	func start_new_run() -> void:
		started_new_run = true
		run_active = true

	func is_current_step_boss_reward() -> bool:
		return boss_reward

	func is_current_step_fight() -> bool:
		return fight

	func ensure_player_state() -> Variant:
		return player_state

	func ensure_player_progression_state() -> Variant:
		return progression_state

	func current_level_boss_preview() -> Dictionary:
		return {"display_name": "Boss", "max_hp": 44}

	func current_encounter_snapshot() -> Dictionary:
		return {"display_name": "Slime", "max_hp": 18, "step_key": "enemy_1"}

	func validate_player_state_content() -> Array[Dictionary]:
		return []

	func level_sequence_label() -> String:
		return "Level 1-1"

	func current_level_boss_name() -> String:
		return "The Gate"

	func next_scene_path() -> String:
		return ""

	func flow_trace_mark(step: String, _details: Dictionary = {}, _route_id: String = "", _target_scene_override: String = "") -> void:
		marks.append(step)


class Recorder:
	extends RefCounted

	var state: Dictionary = {}
	var bind_hud_stage_count := 0
	var refresh_portraits_count := 0
	var update_hud_count := 0
	var bind_debug_count := 0
	var build_snapshot: Dictionary = {}

	func apply_state(next_state: Dictionary) -> void:
		state = next_state

	func bind_hud_stage() -> void:
		bind_hud_stage_count += 1

	func refresh_character_portraits() -> void:
		refresh_portraits_count += 1

	func refresh_build_icon_rows(snapshot: Dictionary) -> void:
		build_snapshot = snapshot

	func update_hud() -> void:
		update_hud_count += 1

	func bind_debug_state_provider() -> void:
		bind_debug_count += 1

	func route_id() -> String:
		return "route-1"

	func scene_rollback() -> void:
		pass

	func handle_scene_change_failure(_scene: String, _route_id: String, _source: String, _result: Variant) -> void:
		pass


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("fight_state_initialization_applies_state_and_logs", _test_fight_state_initialization_applies_state_and_logs, failures)
	_run_case("boss_reward_initialization_applies_overlay_state", _test_boss_reward_initialization_applies_overlay_state, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_fight_state_initialization_applies_state_and_logs() -> String:
	var fixture := _fixture()
	fixture.initializer.initialize()
	var combat: Variant = fixture.recorder.state.get("combat")
	if combat == null or not bool(combat.started):
		return "Expected initializer to create and start combat state."
	if fixture.recorder.bind_hud_stage_count != 1 or fixture.recorder.update_hud_count != 1:
		return "Expected fight initialization to bind HUD stage and update HUD."
	if not fixture.view_actions.log_lines.has("Milestone 5 content validation: OK."):
		return "Expected fight initialization to append content validation log."
	return ""


func _test_boss_reward_initialization_applies_overlay_state() -> String:
	var fixture := _fixture()
	fixture.run_state.boss_reward = true
	fixture.initializer.initialize()
	if fixture.recorder.state.get("combat") != null:
		return "Expected boss reward state to clear combat."
	if fixture.view_actions.boss_summary != "Boss defeated.":
		return "Expected boss reward summary to be shown."
	if fixture.recorder.build_snapshot.get("mastery") != "snapshot":
		return "Expected boss reward initialization to refresh build icon rows."
	if not fixture.run_state.marks.has("combat_initialize_boss_reward_overlay"):
		return "Expected boss reward flow trace mark."
	return ""


func _fixture() -> Dictionary:
	var initializer := INITIALIZER_SCRIPT.new()
	var run_state := FakeRunState.new()
	var model := FakeModel.new()
	var view_actions := FakeViewActions.new()
	var recorder := Recorder.new()
	(
		initializer
		. bind(
			{
				"run_state": run_state,
				"model": model,
				"host": RefCounted.new(),
				"view_actions": view_actions,
				"enemy_state_script": FakeEnemyStateScript.new(),
				"combat_state_machine_script": FakeCombatStateScript.new(),
				"flow_result_utils": RefCounted.new(),
				"status_color_warning": Color(1.0, 0.86, 0.54, 1.0),
			},
			{
				INITIALIZER_SCRIPT.CALLBACK_APPLY_STATE: Callable(recorder, "apply_state"),
				INITIALIZER_SCRIPT.CALLBACK_BIND_HUD_STAGE: Callable(recorder, "bind_hud_stage"),
				INITIALIZER_SCRIPT.CALLBACK_REFRESH_CHARACTER_PORTRAITS: Callable(recorder, "refresh_character_portraits"),
				INITIALIZER_SCRIPT.CALLBACK_REFRESH_BUILD_ICON_ROWS: Callable(recorder, "refresh_build_icon_rows"),
				INITIALIZER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
				INITIALIZER_SCRIPT.CALLBACK_BIND_DEBUG_STATE_PROVIDER: Callable(recorder, "bind_debug_state_provider"),
				INITIALIZER_SCRIPT.CALLBACK_ROUTE_ID: Callable(recorder, "route_id"),
				INITIALIZER_SCRIPT.CALLBACK_SCENE_ROLLBACK: Callable(recorder, "scene_rollback"),
				INITIALIZER_SCRIPT.CALLBACK_HANDLE_SCENE_CHANGE_FAILURE: Callable(recorder, "handle_scene_change_failure"),
			}
		)
	)
	return {"initializer": initializer, "run_state": run_state, "model": model, "view_actions": view_actions, "recorder": recorder}
