extends RefCounted
class_name CombatHudStageCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_hud_stage_coordinator.gd")


class FakePlayerState:
	extends RefCounted

	var gold := 21
	var current_hp := 72
	var max_hp := 100
	var armor := 9


class FakeEnemyState:
	extends RefCounted

	var current_hp := 90
	var current_turn_block := 12


class CallbackRecorder:
	extends RefCounted

	var update_count := 0

	func update_hud() -> void:
		update_count += 1


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("capture_values_reads_bound_states", _test_capture_values_reads_bound_states, failures)
	_run_case("enemy_damage_staging_updates_model_and_notifies", _test_enemy_damage_staging_updates_model_and_notifies, failures)
	_run_case("player_staging_updates_model_and_notifies", _test_player_staging_updates_model_and_notifies, failures)
	_run_case("inactive_staging_is_noop", _test_inactive_staging_is_noop, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
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


func _test_capture_values_reads_bound_states() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var values: Dictionary = coordinator.capture_values()
	if int(values.get("player_gold", -1)) != 21:
		return "Expected player gold to be captured."
	if int(values.get("enemy_hp", -1)) != 90:
		return "Expected enemy HP to be captured."
	if int(values.get("enemy_turn_block", -1)) != 12:
		return "Expected enemy turn block to be captured."
	if int(values.get("player_hp", -1)) != 72 or int(values.get("player_armor", -1)) != 9:
		return "Expected player HP and armor to be captured."
	return ""


func _test_enemy_damage_staging_updates_model_and_notifies() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	model.begin_hud_staging(coordinator.capture_values())
	coordinator.stage_enemy_damage_step(15)
	if int(model.staged_hud_value("enemy_turn_block", -1)) != 0:
		return "Expected damage to consume staged enemy block first."
	if int(model.staged_hud_value("enemy_hp", -1)) != 87:
		return "Expected unblocked damage to reduce staged enemy HP."
	if recorder.update_count != 1:
		return "Expected enemy damage staging to refresh HUD once."
	coordinator.stage_enemy_damage_step(500)
	if not bool(coordinator.staged_enemy_defeated()):
		return "Expected staged enemy defeat after lethal damage."
	return ""


func _test_player_staging_updates_model_and_notifies() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var player: FakePlayerState = fixture["player"]
	var recorder: CallbackRecorder = fixture["recorder"]
	model.begin_hud_staging(coordinator.capture_values())
	coordinator.stage_player_hp(130)
	coordinator.stage_player_armor(-4)
	coordinator.stage_gold(-8)
	player.armor = 7
	coordinator.stage_player_block_step(3)
	player.current_hp = 64
	player.armor = 5
	coordinator.stage_player_final()
	if int(model.staged_hud_value("player_hp", -1)) != 64:
		return "Expected final player HP to use bound player state."
	if int(model.staged_hud_value("player_armor", -1)) != 5:
		return "Expected final player armor to use bound player state."
	if int(model.staged_hud_value("player_gold", -1)) != 0:
		return "Expected staged gold to clamp at zero."
	if recorder.update_count != 5:
		return "Expected each player staging operation to refresh HUD."
	return ""


func _test_inactive_staging_is_noop() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var recorder: CallbackRecorder = fixture["recorder"]
	coordinator.stage_enemy_damage_step(12)
	coordinator.stage_player_hp(44)
	if model.staged_hud_values_snapshot() != {}:
		return "Expected inactive HUD staging to leave the model unchanged."
	if recorder.update_count != 0:
		return "Expected inactive HUD staging not to refresh HUD."
	return ""


func _fixture() -> Dictionary:
	var model := CombatModel.new()
	var player := FakePlayerState.new()
	var enemy := FakeEnemyState.new()
	var recorder := CallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(model, player, enemy, {
		COORDINATOR_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
	})
	return {
		"coordinator": coordinator,
		"model": model,
		"player": player,
		"enemy": enemy,
		"recorder": recorder,
	}
