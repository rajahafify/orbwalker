extends RefCounted
class_name CombatPlayerHudRefreshCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_player_hud_refresh_coordinator.gd")


class FakeModel:
	extends RefCounted

	var staging_active := false
	var staged_values := {
		"player_hp": 31,
		"player_armor": 4,
	}
	var feedback_totals := {
		OrbType.Id.FIRE: 12,
	}

	func is_hud_staging_active() -> bool:
		return staging_active

	func staged_hud_value(key: String, fallback: int) -> int:
		return int(staged_values.get(key, fallback))

	func combat_mastery_preview_totals_snapshot() -> Dictionary:
		return feedback_totals.duplicate(true)


class FakePlayerState:
	extends RefCounted

	var current_hp := 44
	var armor := 6


class FakeEnemyState:
	extends RefCounted

	var intent := {
		"kind": "attack",
		"amount": 9,
	}

	func get_current_intent() -> Dictionary:
		return intent.duplicate(true)


class FakeVisuals:
	extends RefCounted

	func hero_portrait() -> String:
		return "hero_portrait"


class FakeView:
	extends RefCounted

	var payloads: Array[Dictionary] = []
	var deferred_flags: Array[bool] = []

	func render_player_loadout(payload: Dictionary, deferred_layout: bool = true) -> void:
		payloads.append(payload.duplicate(true))
		deferred_flags.append(deferred_layout)


class FakeHudPresenter:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func build_intent_damage_preview(intent: Dictionary, player_hp: int, player_armor: int) -> Dictionary:
		(
			calls
			. append(
				{
					"intent": intent.duplicate(true),
					"player_hp": player_hp,
					"player_armor": player_armor,
				}
			)
		)
		return {
			"kind": String(intent.get("kind", "")),
			"amount": int(intent.get("amount", 0)),
			"player_hp": player_hp,
			"player_armor": player_armor,
		}


class FakeMasteryPreviewCoordinator:
	extends RefCounted

	var calls: Array[Dictionary] = []
	var payload := {
		"orb_values_by_id": {OrbType.Id.FIRE: 5},
		"mastery_levels": {"fire": 2},
		"combat_modifiers": {"combo_flat_bonus": 1},
	}

	func build_hover_payload(progression_snapshot: Dictionary) -> Dictionary:
		calls.append(progression_snapshot.duplicate(true))
		return payload.duplicate(true)


class CallbackRecorder:
	extends RefCounted

	var show_intent_preview := false
	var calls := 0

	func should_show_intent_damage_preview() -> bool:
		calls += 1
		return show_intent_preview


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("base_payload_renders_player_loadout", _test_base_payload_renders_player_loadout, failures)
	_run_case("staged_values_feed_display_and_intent_preview", _test_staged_values_feed_display_and_intent_preview, failures)
	_run_case("intent_preview_is_gated_by_callback", _test_intent_preview_is_gated_by_callback, failures)
	_run_case("missing_view_still_returns_payload", _test_missing_view_still_returns_payload, failures)
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


func _test_base_payload_renders_player_loadout() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var player: FakePlayerState = fixture["player"]
	var model: FakeModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var mastery: FakeMasteryPreviewCoordinator = fixture["mastery"]
	var progression := {"mastery_levels": {"fire": 3}}
	var payload: Dictionary = coordinator.refresh_build_icon_rows(progression)
	if payload.get("player_state") != player:
		return "Expected payload to keep the bound player state."
	if payload.get("hero_portrait", "") != "hero_portrait":
		return "Expected payload to include the visual registry portrait."
	if int(payload.get("max_visible_relics", 0)) != 2:
		return "Expected payload to preserve the relic display limit."
	if not bool(payload.get("selectable_equipment", false)) or not bool(payload.get("selectable_consumables", false)):
		return "Expected equipment and consumables to remain selectable."
	var display_values: Dictionary = payload.get("display_values", {})
	if int(display_values.get("current_hp", -1)) != player.current_hp:
		return "Expected current player HP in display values."
	if int(display_values.get("current_armor", -1)) != player.armor:
		return "Expected current player armor in display values."
	var totals: Dictionary = payload.get("combat_mastery_feedback_totals", {})
	if int(totals.get(OrbType.Id.FIRE, -1)) != int(model.feedback_totals[OrbType.Id.FIRE]):
		return "Expected combat mastery feedback totals from the model."
	var hover_payload: Dictionary = payload.get("combat_mastery_hover_payload", {})
	if int(Dictionary(hover_payload.get("orb_values_by_id", {})).get(OrbType.Id.FIRE, -1)) != 5:
		return "Expected combat mastery hover payload from the coordinator."
	if mastery.calls != [progression]:
		return "Expected progression snapshot to be forwarded for hover payload construction."
	if view.payloads.size() != 1 or view.payloads[0] != payload:
		return "Expected payload to render through the view once."
	if view.deferred_flags != [true]:
		return "Expected loadout layout to remain deferred."
	return ""


func _test_staged_values_feed_display_and_intent_preview() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: FakeModel = fixture["model"]
	var hud_presenter: FakeHudPresenter = fixture["hud_presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	model.staging_active = true
	recorder.show_intent_preview = true
	var payload: Dictionary = coordinator.refresh_build_icon_rows({})
	var display_values: Dictionary = payload.get("display_values", {})
	if int(display_values.get("current_hp", -1)) != 31:
		return "Expected staged player HP to be displayed."
	if int(display_values.get("current_armor", -1)) != 4:
		return "Expected staged player armor to be displayed."
	if hud_presenter.calls.size() != 1:
		return "Expected intent preview to be built once."
	var call: Dictionary = hud_presenter.calls[0]
	if int(call.get("player_hp", -1)) != 31 or int(call.get("player_armor", -1)) != 4:
		return "Expected intent preview to use staged display values."
	var preview: Dictionary = payload.get("intent_damage_preview", {})
	if String(preview.get("kind", "")) != "attack" or int(preview.get("amount", 0)) != 9:
		return "Expected intent preview payload from the HUD presenter."
	if recorder.calls != 1:
		return "Expected preview visibility callback to be queried once."
	return ""


func _test_intent_preview_is_gated_by_callback() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var hud_presenter: FakeHudPresenter = fixture["hud_presenter"]
	var recorder: CallbackRecorder = fixture["recorder"]
	recorder.show_intent_preview = false
	var payload: Dictionary = coordinator.refresh_build_icon_rows({})
	if payload.get("intent_damage_preview", {}) != {}:
		return "Expected intent preview payload to be empty while gated off."
	if not hud_presenter.calls.is_empty():
		return "Expected hidden intent preview not to call the HUD presenter."
	if recorder.calls != 1:
		return "Expected callback to be queried for preview visibility."
	return ""


func _test_missing_view_still_returns_payload() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	(
		coordinator
		. bind(
			{
				"model": fixture["model"],
				"player_state": fixture["player"],
				"enemy_state": fixture["enemy"],
				"visuals": fixture["visuals"],
				"hud_presenter": fixture["hud_presenter"],
				"mastery_preview_coordinator": fixture["mastery"],
			},
			{
				COORDINATOR_SCRIPT.CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW: Callable(fixture["recorder"], "should_show_intent_damage_preview"),
			}
		)
	)
	var payload: Dictionary = coordinator.refresh_build_icon_rows({})
	var display_values: Dictionary = payload.get("display_values", {})
	if int(display_values.get("current_hp", -1)) != 44:
		return "Expected payload construction to work without a view."
	return ""


func _fixture() -> Dictionary:
	var model := FakeModel.new()
	var player := FakePlayerState.new()
	var enemy := FakeEnemyState.new()
	var visuals := FakeVisuals.new()
	var view := FakeView.new()
	var hud_presenter := FakeHudPresenter.new()
	var mastery := FakeMasteryPreviewCoordinator.new()
	var recorder := CallbackRecorder.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	(
		coordinator
		. bind(
			{
				"model": model,
				"player_state": player,
				"enemy_state": enemy,
				"visuals": visuals,
				"view": view,
				"hud_presenter": hud_presenter,
				"mastery_preview_coordinator": mastery,
			},
			{
				COORDINATOR_SCRIPT.CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW: Callable(recorder, "should_show_intent_damage_preview"),
			}
		)
	)
	return {
		"coordinator": coordinator,
		"model": model,
		"player": player,
		"enemy": enemy,
		"visuals": visuals,
		"view": view,
		"hud_presenter": hud_presenter,
		"mastery": mastery,
		"recorder": recorder,
	}
