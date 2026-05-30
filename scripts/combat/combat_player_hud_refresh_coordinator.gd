extends RefCounted
class_name CombatPlayerHudRefreshCoordinator

const CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW := "should_show_intent_damage_preview"
const MAX_VISIBLE_RELICS := 2

var _model: Variant = null
var _player_state: Variant = null
var _enemy_state: Variant = null
var _visuals: Variant = null
var _view: Variant = null
var _hud_presenter: Variant = null
var _mastery_preview_coordinator: Variant = null
var _callbacks: Dictionary = {}


func bind(context: Dictionary, callbacks: Dictionary = {}) -> void:
	_model = context.get("model", null)
	_player_state = context.get("player_state", null)
	_enemy_state = context.get("enemy_state", null)
	_visuals = context.get("visuals", null)
	_view = context.get("view", null)
	_hud_presenter = context.get("hud_presenter", null)
	_mastery_preview_coordinator = context.get("mastery_preview_coordinator", null)
	_callbacks = callbacks.duplicate()


func refresh_build_icon_rows(progression_snapshot: Dictionary) -> Dictionary:
	var loadout_payload := build_loadout_payload(progression_snapshot)
	if _view != null and _view.has_method("render_player_loadout"):
		_view.render_player_loadout(loadout_payload, true)
	return loadout_payload


func build_loadout_payload(progression_snapshot: Dictionary) -> Dictionary:
	var player_display_values := _player_display_values()
	return {
		"player_state": _player_state,
		"progression": progression_snapshot,
		"hero_portrait": _hero_portrait(),
		"max_visible_relics": MAX_VISIBLE_RELICS,
		"selectable_equipment": true,
		"selectable_consumables": true,
		"display_values": player_display_values,
		"intent_damage_preview": _intent_damage_preview(player_display_values),
		"combat_mastery_feedback_totals": _combat_mastery_feedback_totals(),
		"combat_mastery_hover_payload": _combat_mastery_hover_payload(progression_snapshot),
	}


func _player_display_values() -> Dictionary:
	var visible_player_hp := int(_player_state.current_hp if _player_state != null else 0)
	var visible_player_armor := int(_player_state.armor if _player_state != null else 0)
	if _is_hud_staging_active():
		visible_player_hp = _staged_hud_value("player_hp", visible_player_hp)
		visible_player_armor = _staged_hud_value("player_armor", visible_player_armor)
	return {
		"current_hp": visible_player_hp,
		"current_armor": visible_player_armor,
	}


func _intent_damage_preview(player_display_values: Dictionary) -> Dictionary:
	if not _should_show_intent_damage_preview():
		return {}
	if _hud_presenter == null or not _hud_presenter.has_method("build_intent_damage_preview"):
		return {}
	var intent: Dictionary = {}
	if _enemy_state != null and _enemy_state.has_method("get_current_intent"):
		intent = _enemy_state.get_current_intent()
	return _hud_presenter.build_intent_damage_preview(
		intent, int(player_display_values.get("current_hp", 0)), int(player_display_values.get("current_armor", 0))
	)


func _should_show_intent_damage_preview() -> bool:
	var callback: Callable = _callbacks.get(CALLBACK_SHOULD_SHOW_INTENT_DAMAGE_PREVIEW, Callable())
	return callback.is_valid() and bool(callback.call())


func _is_hud_staging_active() -> bool:
	return _model != null and _model.has_method("is_hud_staging_active") and bool(_model.is_hud_staging_active())


func _staged_hud_value(key: String, fallback: int) -> int:
	if _model == null or not _model.has_method("staged_hud_value"):
		return fallback
	return int(_model.staged_hud_value(key, fallback))


func _hero_portrait() -> Variant:
	if _visuals != null and _visuals.has_method("hero_portrait"):
		return _visuals.hero_portrait()
	return null


func _combat_mastery_feedback_totals() -> Dictionary:
	if _model != null and _model.has_method("combat_mastery_preview_totals_snapshot"):
		return _model.combat_mastery_preview_totals_snapshot()
	return {}


func _combat_mastery_hover_payload(progression_snapshot: Dictionary) -> Dictionary:
	if _mastery_preview_coordinator != null and _mastery_preview_coordinator.has_method("build_hover_payload"):
		return _mastery_preview_coordinator.build_hover_payload(progression_snapshot)
	return {}
