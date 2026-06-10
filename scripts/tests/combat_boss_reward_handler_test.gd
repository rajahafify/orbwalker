extends RefCounted
class_name CombatBossRewardHandlerTest

const HANDLER_SCRIPT := preload("res://scripts/combat/combat_boss_reward_handler.gd")


class FakeButton:
	extends RefCounted

	var disabled := false
	var visible := true
	var tooltip_text := ""
	var card: Dictionary = {}


class FakeOverlay:
	extends RefCounted

	var pending := false
	var selected_index := -1
	var show_body := ""
	var hide_count := 0
	var claim_callback := Callable()
	var skip_callback := Callable()
	var buttons: Array = [FakeButton.new(), FakeButton.new(), FakeButton.new()]

	func ensure_boss_reward_controls(on_claim_option: Callable, on_skip: Callable) -> void:
		claim_callback = on_claim_option
		skip_callback = on_skip

	func show_boss_reward(body: String) -> void:
		pending = true
		show_body = body

	func is_boss_reward_pending() -> bool:
		return pending

	func boss_reward_buttons() -> Array:
		return buttons

	func selected_boss_reward_index() -> int:
		return selected_index

	func set_selected_boss_reward_index(index: int) -> void:
		selected_index = index

	func set_boss_reward_pending(value: bool) -> void:
		pending = value

	func set_boss_reward_card_content(button: Variant, icon_texture: Texture2D, display_name: String, rarity: String, description: String) -> void:
		button.card = {
			"icon": icon_texture,
			"display_name": display_name,
			"rarity": rarity,
			"description": description,
		}

	func wrap_text_to_lines(text: String, _max_chars: int, _max_lines: int) -> String:
		return text

	func hide() -> void:
		hide_count += 1
		pending = false


class FakeView:
	extends RefCounted

	var body_texts: Array[String] = []
	var next_disabled_values: Array[bool] = []

	func set_outcome_body_text(value: String) -> void:
		body_texts.append(value)

	func set_outcome_next_button_disabled(value: bool) -> void:
		next_disabled_values.append(value)


class FakeModel:
	extends RefCounted

	var clear_count := 0

	func clear_pending_next_scene_path() -> void:
		clear_count += 1


class FakeVisuals:
	extends RefCounted

	var icon_keys: Array[String] = []

	func clean_icon_for_key(icon_key: String) -> Texture2D:
		icon_keys.append(icon_key)
		return null


class FakeContent:
	extends RefCounted

	var relics := {
		"relic_a": {
			"display_name": "Fallback A",
			"rarity": "common",
			"description": "Gain power.",
			"icon_key": "relic_a_icon",
		},
		"relic_b": {
			"display_name": "Fallback B",
			"rarity": "rare",
			"description": "Gain armor.",
			"icon_key": "relic_b_icon",
		},
	}

	func get_relic(relic_id: String) -> Dictionary:
		return Dictionary(relics.get(relic_id, {}))


class FakeRunState:
	extends RefCounted

	var options: Array[Dictionary] = []
	var content := FakeContent.new()
	var claim_indices: Array[int] = []
	var skip_count := 0
	var advance_count := 0
	var claim_result := {"ok": true}
	var skip_result := {"ok": true}
	var transition := {"next_scene": "res://scenes/shop.tscn"}

	func boss_relic_reward_options_snapshot() -> Array[Dictionary]:
		return options.duplicate(true)

	func ensure_content_registry() -> Variant:
		return content

	func claim_boss_relic_reward(index: int) -> Dictionary:
		claim_indices.append(index)
		return claim_result

	func skip_boss_relic_reward() -> Dictionary:
		skip_count += 1
		return skip_result

	func advance_after_boss_reward() -> Dictionary:
		advance_count += 1
		return transition


class CallbackRecorder:
	extends RefCounted

	var status_texts: Array[String] = []
	var sfx: Array[String] = []
	var layout_count := 0
	var update_hud_count := 0
	var routes: Array[Dictionary] = []

	func set_status_text(value: String) -> void:
		status_texts.append(value)

	func play_sfx(value: String) -> void:
		sfx.append(value)

	func apply_layout() -> void:
		layout_count += 1

	func update_hud() -> void:
		update_hud_count += 1

	func trace_and_change_scene(scene_path: String, source: String, trace_mark: String, payload: Dictionary) -> void:
		routes.append({
			"scene_path": scene_path,
			"source": source,
			"trace_mark": trace_mark,
			"payload": payload,
		})


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("show_summary_populates_options", _test_show_summary_populates_options, failures)
	_run_case("next_requires_selected_option", _test_next_requires_selected_option, failures)
	_run_case("select_and_claim_route_to_shop", _test_select_and_claim_route_to_shop, failures)
	_run_case("empty_options_next_skips_reward", _test_empty_options_next_skips_reward, failures)
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


func _test_show_summary_populates_options() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var overlay: FakeOverlay = fixture["overlay"]
	var model: FakeModel = fixture["model"]
	var visuals: FakeVisuals = fixture["visuals"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.show_summary("Boss defeated.")
	if overlay.show_body != "Boss defeated.":
		return "Expected handler to show the boss reward overlay."
	if model.clear_count != 1:
		return "Expected handler to clear pending next-scene path."
	if recorder.layout_count != 1:
		return "Expected handler to request layout after showing the overlay."
	if overlay.buttons[0].card.get("display_name", "") != "Relic A":
		return "Expected first reward card to use option display name."
	if overlay.buttons[0].card.get("rarity", "") != "RARE":
		return "Expected first reward rarity to be uppercased."
	if overlay.buttons[0].disabled:
		return "Expected populated reward buttons to be enabled."
	if overlay.buttons[2].card.get("display_name", "") != "No Relic" or not overlay.buttons[2].disabled:
		return "Expected missing reward slots to be disabled placeholders."
	if visuals.icon_keys != ["relic_a_icon", "relic_b_icon"]:
		return "Expected reward icon keys to be resolved through visuals."
	return ""


func _test_next_requires_selected_option() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.show_summary("Boss defeated.")
	if not handler.handle_next_pressed():
		return "Expected pending boss reward to handle next button presses."
	if recorder.sfx != ["error"]:
		return "Expected missing selection to play the error SFX."
	if recorder.status_texts != ["Choose one boss relic before continuing."]:
		return "Expected missing selection status text."
	return ""


func _test_select_and_claim_route_to_shop() -> String:
	var fixture := _fixture()
	var handler: Variant = fixture["handler"]
	var overlay: FakeOverlay = fixture["overlay"]
	var view: FakeView = fixture["view"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.show_summary("Boss defeated.")
	handler.select_option(0)
	if overlay.selected_index != 0:
		return "Expected select_option to update overlay selection."
	if view.next_disabled_values != [false]:
		return "Expected selecting a reward to enable the next button."
	if recorder.status_texts.back() != "Boss relic selected. Continue to shop when ready.":
		return "Expected selecting a reward to update status."
	if not handler.handle_next_pressed():
		return "Expected claim flow to handle next button presses."
	if run_state.claim_indices != [0]:
		return "Expected selected boss reward option to be claimed."
	if run_state.advance_count != 1:
		return "Expected claim flow to advance after boss reward."
	if recorder.update_hud_count != 1:
		return "Expected claim flow to refresh HUD."
	if overlay.hide_count != 1:
		return "Expected claim flow to hide the overlay."
	if recorder.routes.size() != 1:
		return "Expected claim flow to emit one scene route."
	if String(recorder.routes[0].get("source", "")) != HANDLER_SCRIPT.TRACE_SOURCE_CLAIM:
		return "Expected claim flow trace source."
	if Dictionary(recorder.routes[0].get("payload", {})).get("option_index") != 0:
		return "Expected claim flow to preserve option index payload."
	return ""


func _test_empty_options_next_skips_reward() -> String:
	var fixture := _fixture([])
	var handler: Variant = fixture["handler"]
	var overlay: FakeOverlay = fixture["overlay"]
	var view: FakeView = fixture["view"]
	var run_state: FakeRunState = fixture["run_state"]
	var recorder: CallbackRecorder = fixture["recorder"]
	handler.show_summary("Boss defeated.")
	if view.body_texts.is_empty() or view.body_texts.back().find("No boss relic options generated") < 0:
		return "Expected no-option summary to explain the empty reward state."
	for button in overlay.buttons:
		if button.visible or not button.disabled:
			return "Expected no-option reward buttons to be hidden and disabled."
	if view.next_disabled_values != [false]:
		return "Expected no-option summary to enable next."
	if not handler.handle_next_pressed():
		return "Expected no-option next press to be handled by skip."
	if run_state.skip_count != 1:
		return "Expected no-option next press to skip boss reward."
	if recorder.routes.size() != 1:
		return "Expected skip flow to emit one scene route."
	if String(recorder.routes[0].get("source", "")) != HANDLER_SCRIPT.TRACE_SOURCE_SKIP:
		return "Expected skip flow trace source."
	return ""


func _fixture(options: Array[Dictionary] = [
	{"relic_id": "relic_a", "display_name": "Relic A", "rarity": "rare"},
	{"relic_id": "relic_b", "display_name": "Relic B", "rarity": "uncommon"},
]) -> Dictionary:
	var overlay := FakeOverlay.new()
	var view := FakeView.new()
	var model := FakeModel.new()
	var visuals := FakeVisuals.new()
	var run_state := FakeRunState.new()
	run_state.options = options.duplicate(true)
	var recorder := CallbackRecorder.new()
	var handler: Variant = HANDLER_SCRIPT.new()
	handler.bind(
		overlay,
		view,
		model,
		visuals,
		{
			HANDLER_SCRIPT.CALLBACK_SET_STATUS_TEXT: Callable(recorder, "set_status_text"),
			HANDLER_SCRIPT.CALLBACK_UPDATE_HUD: Callable(recorder, "update_hud"),
			HANDLER_SCRIPT.CALLBACK_PLAY_SFX: Callable(recorder, "play_sfx"),
			HANDLER_SCRIPT.CALLBACK_APPLY_LAYOUT: Callable(recorder, "apply_layout"),
			HANDLER_SCRIPT.CALLBACK_TRACE_AND_CHANGE_SCENE: Callable(recorder, "trace_and_change_scene"),
		},
		{"run_state": run_state}
	)
	return {
		"handler": handler,
		"overlay": overlay,
		"view": view,
		"model": model,
		"visuals": visuals,
		"run_state": run_state,
		"recorder": recorder,
	}
