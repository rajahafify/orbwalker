extends RefCounted
class_name CombatBossRewardHandler

const CALLBACK_SET_STATUS_TEXT := "set_status_text"
const CALLBACK_UPDATE_HUD := "update_hud"
const CALLBACK_PLAY_SFX := "play_sfx"
const CALLBACK_APPLY_LAYOUT := "apply_layout"
const CALLBACK_TRACE_AND_CHANGE_SCENE := "trace_and_change_scene"

const DEFAULT_NEXT_SCENE := "res://scenes/main_menu.tscn"
const TRACE_SOURCE_CLAIM := "boss_reward_claim"
const TRACE_SOURCE_SKIP := "boss_reward_skip"
const TRACE_MARK_CLAIM := "combat_before_change_scene_to_file_boss_reward_claim"
const TRACE_MARK_SKIP := "combat_before_change_scene_to_file_boss_reward_skip"

var _overlay: Variant = null
var _view: Variant = null
var _model: Variant = null
var _visuals: Variant = null
var _run_state: Variant = RunState
var _callbacks: Dictionary = {}


func bind(
	overlay: Variant,
	view: Variant,
	model: Variant,
	visuals: Variant,
	callbacks: Dictionary = {},
	config: Dictionary = {}
) -> void:
	_overlay = overlay
	_view = view
	_model = model
	_visuals = visuals
	_callbacks = callbacks.duplicate()
	_run_state = config.get("run_state", RunState)


func ensure_controls() -> void:
	if _overlay == null or not _overlay.has_method("ensure_boss_reward_controls"):
		return
	_overlay.ensure_boss_reward_controls(Callable(self, "select_option"), Callable(self, "skip_option"))


func show_summary(body: String) -> void:
	if _overlay == null:
		return
	_overlay.show_boss_reward(body)
	if _model != null and _model.has_method("clear_pending_next_scene_path"):
		_model.clear_pending_next_scene_path()
	_call_callback(CALLBACK_APPLY_LAYOUT)
	_populate_reward_options(body)


func handle_next_pressed() -> bool:
	if not is_pending():
		return false
	var options: Array = _reward_options()
	if options.is_empty():
		skip_option()
		return true
	var selected_index := int(_overlay.selected_boss_reward_index())
	if selected_index < 0:
		_call_callback(CALLBACK_PLAY_SFX, ["error"])
		_call_callback(CALLBACK_SET_STATUS_TEXT, ["Choose one boss relic before continuing."])
		return true
	claim_option(selected_index)
	return true


func select_option(index: int) -> void:
	if not is_pending():
		return
	_overlay.set_selected_boss_reward_index(index)
	if _view != null and _view.has_method("set_outcome_next_button_disabled"):
		_view.set_outcome_next_button_disabled(false)
	_call_callback(CALLBACK_SET_STATUS_TEXT, ["Boss relic selected. Continue to shop when ready."])
	_call_callback(CALLBACK_PLAY_SFX, ["ui_accept"])


func claim_option(index: int) -> void:
	if not is_pending():
		return
	var result: Dictionary = _run_state.claim_boss_relic_reward(index)
	if not bool(result.get("ok", false)):
		_call_callback(CALLBACK_SET_STATUS_TEXT, ["Boss relic claim failed: %s" % String(result.get("reason", "unknown"))])
		return
	var transition: Dictionary = _run_state.advance_after_boss_reward()
	_overlay.set_boss_reward_pending(false)
	_call_callback(CALLBACK_UPDATE_HUD)
	_call_callback(CALLBACK_PLAY_SFX, ["ui_accept"])
	_hide_overlay()
	_call_callback(CALLBACK_TRACE_AND_CHANGE_SCENE, [
		String(transition.get("next_scene", DEFAULT_NEXT_SCENE)),
		TRACE_SOURCE_CLAIM,
		TRACE_MARK_CLAIM,
		{"option_index": index},
	])


func skip_option() -> void:
	if not is_pending():
		return
	var skip_result: Dictionary = _run_state.skip_boss_relic_reward()
	if not bool(skip_result.get("ok", false)):
		_call_callback(CALLBACK_SET_STATUS_TEXT, ["Boss relic skip failed: %s" % String(skip_result.get("reason", "unknown"))])
		return
	var transition: Dictionary = _run_state.advance_after_boss_reward()
	_overlay.set_boss_reward_pending(false)
	_call_callback(CALLBACK_PLAY_SFX, ["ui_accept"])
	_hide_overlay()
	_call_callback(CALLBACK_TRACE_AND_CHANGE_SCENE, [
		String(transition.get("next_scene", DEFAULT_NEXT_SCENE)),
		TRACE_SOURCE_SKIP,
		TRACE_MARK_SKIP,
		{},
	])


func is_pending() -> bool:
	return _overlay != null and _overlay.has_method("is_boss_reward_pending") and bool(_overlay.is_boss_reward_pending())


func _populate_reward_options(body: String) -> void:
	var options: Array = _reward_options()
	var boss_reward_buttons: Array = _overlay.boss_reward_buttons() if _overlay != null and _overlay.has_method("boss_reward_buttons") else []
	for index in boss_reward_buttons.size():
		var button: Variant = boss_reward_buttons[index]
		if index >= options.size():
			_overlay.set_boss_reward_card_content(button, null, "No Relic", "", "")
			button.disabled = true
			continue
		var option: Dictionary = options[index]
		var relic_id := String(option.get("relic_id", option.get("id", "")))
		var content: Dictionary = _content_relic(relic_id)
		var description := String(content.get("description", ""))
		_overlay.set_boss_reward_card_content(
			button,
			_clean_icon_for_key(String(content.get("icon_key", ""))),
			String(option.get("display_name", content.get("display_name", "Relic"))),
			String(option.get("rarity", content.get("rarity", "common"))).to_upper(),
			_overlay.wrap_text_to_lines(description, 48, 2)
		)
		button.tooltip_text = "%s\n%s\n%s" % [
			String(option.get("display_name", content.get("display_name", "Relic"))),
			String(option.get("rarity", content.get("rarity", "common"))).to_upper(),
			description,
		]
		button.disabled = false
	if options.is_empty():
		if _view != null and _view.has_method("set_outcome_body_text"):
			_view.set_outcome_body_text("%s\nNo boss relic options generated. Continue to shop." % body)
		for button in boss_reward_buttons:
			button.visible = false
			button.disabled = true
		if _view != null and _view.has_method("set_outcome_next_button_disabled"):
			_view.set_outcome_next_button_disabled(false)


func _reward_options() -> Array:
	if _run_state == null or not _run_state.has_method("boss_relic_reward_options_snapshot"):
		return []
	return Array(_run_state.boss_relic_reward_options_snapshot())


func _content_relic(relic_id: String) -> Dictionary:
	if _run_state == null or not _run_state.has_method("ensure_content_registry"):
		return {}
	var content: Variant = _run_state.ensure_content_registry()
	if content != null and content.has_method("get_relic"):
		return Dictionary(content.get_relic(relic_id))
	return {}


func _clean_icon_for_key(icon_key: String) -> Texture2D:
	if _visuals != null and _visuals.has_method("clean_icon_for_key"):
		return _visuals.clean_icon_for_key(icon_key)
	return null


func _hide_overlay() -> void:
	if _overlay != null and _overlay.has_method("hide"):
		_overlay.hide()


func _call_callback(name: String, args: Array = []) -> Variant:
	var callback := _callback(name)
	if callback.is_valid():
		return callback.callv(args)
	return null


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
