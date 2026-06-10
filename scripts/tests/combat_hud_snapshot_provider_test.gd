extends RefCounted
class_name CombatHudSnapshotProviderTest

const PROVIDER_SCRIPT := preload("res://scripts/combat/combat_hud_snapshot_provider.gd")


class FakeRunState:
	extends RefCounted

	const MAX_DUNGEON_LEVELS := 3

	var dungeon_level := 2
	var current_step_key := "enemy_2"

	func progression_snapshot() -> Dictionary:
		return {"equipment_slots": ["shortsword"], "relic_ids": ["ember"]}


class FakeModel:
	extends RefCounted

	var staged_values := {
		"player_gold": 44,
		"enemy_hp": 7,
		"enemy_turn_block": 3,
		"player_hp": 18,
		"player_armor": 5,
	}

	func staged_hud_value(key: String, fallback_value: int) -> int:
		return int(staged_values.get(key, fallback_value))


class FakePlayerState:
	extends RefCounted

	var gold := 30
	var current_hp := 12
	var max_hp := 28
	var armor := 2

	func orb_value(orb_id: int) -> int:
		return 10 + orb_id


class FakeEnemyState:
	extends RefCounted

	var enemy_id := "cavern_brute"
	var display_name := "Cavern Brute"
	var current_hp := 15
	var max_hp := 20
	var current_turn_block := 1

	func get_current_intent() -> Dictionary:
		return {"kind": "attack", "amount": 6}


class FakeCombat:
	extends RefCounted

	var turn_index := 4

	func phase_name() -> String:
		return "Player Input"


class FakeView:
	extends RefCounted

	func turn_summary_text() -> String:
		return "Matched fire."


class FakeVisuals:
	extends RefCounted

	var stage_texture := ImageTexture.create_from_image(Image.create(2, 2, false, Image.FORMAT_RGBA8))
	var enemy_texture := ImageTexture.create_from_image(Image.create(3, 3, false, Image.FORMAT_RGBA8))
	var fallback_texture := ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8))

	func combat_enemy_stage_texture(enemy_id: String) -> Texture2D:
		return stage_texture if enemy_id == "cavern_brute" else null

	func enemy_sprite(enemy_id: String) -> Texture2D:
		if enemy_id == "cavern_brute":
			return enemy_texture
		if enemy_id == "cavern_striker":
			return fallback_texture
		return null


class FakeTurnLogPresenter:
	extends RefCounted

	func format_intent_compact(intent: Dictionary) -> String:
		return "%s:%d" % [String(intent.get("kind", "")), int(intent.get("amount", 0))]


class CallbackState:
	extends RefCounted

	var input_phase := 0
	var drag_active := false
	var drag_time_left := 1.25
	var ready_seconds := 2.5
	var show_preview := true

	func input_phase_value() -> int:
		return input_phase

	func is_drag_active() -> bool:
		return drag_active

	func drag_move_time_left() -> float:
		return drag_time_left

	func timer_ready_seconds() -> float:
		return ready_seconds

	func show_intent_preview() -> bool:
		return show_preview


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("build_snapshot_uses_staged_values_and_ready_timer", _test_build_snapshot_uses_staged_values_and_ready_timer, failures)
	_run_case("build_snapshot_uses_drag_timer_and_fallback_portrait", _test_build_snapshot_uses_drag_timer_and_fallback_portrait, failures)
	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_build_snapshot_uses_staged_values_and_ready_timer() -> String:
	var fixture := _fixture()
	var provider: Variant = fixture["provider"]
	var callbacks: CallbackState = fixture["callbacks"]
	callbacks.input_phase = 0
	callbacks.drag_active = false
	var snapshot: Dictionary = provider.build_snapshot()
	if int(snapshot.get("player_gold", 0)) != 44 or int(snapshot.get("enemy_hp", 0)) != 7:
		return "Expected staged HUD values to override raw state values."
	if not bool(snapshot.get("show_intent_preview", false)):
		return "Expected intent preview callback value in snapshot."
	if not bool(snapshot.get("is_player_input_phase", false)):
		return "Expected configured player input phase to be recognized."
	if not is_equal_approx(float(snapshot.get("timer_seconds", 0.0)), 2.5):
		return "Expected ready timer when drag is inactive."
	if String(snapshot.get("turn_summary_text", "")) != "Matched fire.":
		return "Expected view turn summary text."
	if snapshot.get("enemy_stage_texture") == null or snapshot.get("enemy_portrait_texture") == null:
		return "Expected visual textures in snapshot."
	var formatter: Callable = snapshot.get("format_intent_compact", Callable())
	if not formatter.is_valid() or String(formatter.call({"kind": "attack", "amount": 6})) != "attack:6":
		return "Expected compact intent formatter callback."
	return ""


func _test_build_snapshot_uses_drag_timer_and_fallback_portrait() -> String:
	var fixture := _fixture()
	var provider: Variant = fixture["provider"]
	var callbacks: CallbackState = fixture["callbacks"]
	var enemy_state: FakeEnemyState = fixture["enemy_state"]
	var visuals: FakeVisuals = fixture["visuals"]
	callbacks.input_phase = 2
	callbacks.drag_active = true
	callbacks.drag_time_left = 0.75
	callbacks.show_preview = false
	enemy_state.enemy_id = "unknown_enemy"
	var snapshot: Dictionary = provider.build_snapshot()
	if bool(snapshot.get("show_intent_preview", true)):
		return "Expected preview callback false value in snapshot."
	if bool(snapshot.get("is_player_input_phase", true)):
		return "Expected non-player input phase to be false."
	if not bool(snapshot.get("drag_active", false)) or not is_equal_approx(float(snapshot.get("timer_seconds", 0.0)), 0.75):
		return "Expected drag timer when drag is active."
	if snapshot.get("enemy_portrait_texture") != visuals.fallback_texture:
		return "Expected cavern striker fallback portrait when enemy sprite is missing."
	return ""


func _fixture() -> Dictionary:
	var provider: Variant = PROVIDER_SCRIPT.new()
	var callbacks := CallbackState.new()
	var enemy_state := FakeEnemyState.new()
	var visuals := FakeVisuals.new()
	provider.bind(
		{
			"run_state": FakeRunState.new(),
			"model": FakeModel.new(),
			"player_state": FakePlayerState.new(),
			"enemy_state": enemy_state,
			"combat": FakeCombat.new(),
			"view": FakeView.new(),
			"visuals": visuals,
			"turn_log_presenter": FakeTurnLogPresenter.new(),
		},
		{
			"input_phase_value": Callable(callbacks, "input_phase_value"),
			"drag_active": Callable(callbacks, "is_drag_active"),
			"drag_move_time_left": Callable(callbacks, "drag_move_time_left"),
			"timer_ready_seconds": Callable(callbacks, "timer_ready_seconds"),
			"show_intent_preview": Callable(callbacks, "show_intent_preview"),
		},
		{
			"player_input_phase_value": 0,
		}
	)
	return {
		"provider": provider,
		"callbacks": callbacks,
		"enemy_state": enemy_state,
		"visuals": visuals,
	}
