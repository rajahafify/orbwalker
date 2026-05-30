extends RefCounted
class_name CombatMasteryPreviewCoordinatorTest

const COORDINATOR_SCRIPT := preload("res://scripts/combat/combat_mastery_preview_coordinator.gd")

const RESOLUTION_ORDER: Array[int] = [
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
]


class FakeView:
	extends RefCounted

	var feedback: Dictionary = {}
	var set_calls: Array[Dictionary] = []
	var pulses: Array = []
	var clear_count := 0

	func set_combat_mastery_feedback(orb_id: int, amount: int) -> void:
		feedback[orb_id] = amount
		set_calls.append({"orb_id": orb_id, "amount": amount})

	func clear_combat_mastery_feedback() -> void:
		clear_count += 1
		feedback.clear()

	func pulse_combat_modifier_sources(sources: Array[Dictionary]) -> void:
		pulses.append(sources.duplicate(true))


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("fire_feedback_projects_combo_scaled_total", _test_fire_feedback_projects_combo_scaled_total, failures)
	_run_case("heart_feedback_uses_base_total_without_combo_scaling", _test_heart_feedback_uses_base_total_without_combo_scaling, failures)
	_run_case("release_and_reset_clear_model_and_view", _test_release_and_reset_clear_model_and_view, failures)
	_run_case("modifier_sources_filter_and_dedupe", _test_modifier_sources_filter_and_dedupe, failures)
	_run_case("end_modifier_feedback_accumulates_and_pulses", _test_end_modifier_feedback_accumulates_and_pulses, failures)
	return {
		"passed": failures.is_empty(),
		"total": 5,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_fire_feedback_projects_combo_scaled_total() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var fire_group := {"orb_id": OrbType.Id.FIRE, "cells": [Vector2i.ZERO, Vector2i.RIGHT, Vector2i.DOWN]}
	coordinator.show_match_feedback(fire_group, 2)
	if model.combat_mastery_preview_total(OrbType.Id.FIRE) != 36:
		return "Expected Fire total to include orb bonus, combo flat bonus, and combo multiplier."
	if int(view.feedback.get(OrbType.Id.FIRE, -1)) != 36:
		return "Expected Fire feedback to be mirrored to the view."
	if view.pulses.size() != 1 or Array(view.pulses[0]).size() != 2:
		return "Expected unique Fire orb-bonus and combo-scaling sources to pulse once."
	return ""


func _test_heart_feedback_uses_base_total_without_combo_scaling() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var heart_group := {"orb_id": OrbType.Id.HEART, "cells": [Vector2i.ZERO, Vector2i.RIGHT]}
	coordinator.show_match_feedback(heart_group, 5)
	if model.combat_mastery_preview_total(OrbType.Id.HEART) != 6:
		return "Expected Heart total to use base orb value and ignore combo scaling."
	if coordinator.preview_match_feedback_value(heart_group, 5) != 6:
		return "Expected preview value to match the non-scaling Heart total."
	return ""


func _test_release_and_reset_clear_model_and_view() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var view: FakeView = fixture["view"]
	var initial_token := model.combat_mastery_feedback_token()
	coordinator.show_match_feedback({"orb_id": OrbType.Id.FIRE, "cells": [Vector2i.ZERO]}, 1)
	coordinator.release_feedback(OrbType.Id.FIRE)
	if model.combat_mastery_preview_total(OrbType.Id.FIRE) != 0:
		return "Expected release_feedback to clear the model total."
	if int(view.feedback.get(OrbType.Id.FIRE, -1)) != 0:
		return "Expected release_feedback to clear the view total."
	coordinator.reset(_modifiers())
	if model.combat_mastery_feedback_token() != initial_token + 1:
		return "Expected reset to forward to CombatModel."
	if view.clear_count != 1:
		return "Expected reset to clear view feedback."
	return ""


func _test_modifier_sources_filter_and_dedupe() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var combo_sources: Array[Dictionary] = coordinator.modifier_sources_for_key("combo_multiplier_mult")
	if combo_sources.size() != 1:
		return "Expected duplicate combo multiplier sources to be deduped."
	if String(combo_sources[0].get("source_id", "")) != "combo_scaler":
		return "Expected combo multiplier source id."
	var damage_sources: Array[Dictionary] = coordinator.modifier_sources_for_key("flat_damage_bonus")
	if damage_sources.size() != 1 or String(damage_sources[0].get("source_id", "")) != "damage_charm":
		return "Expected flat damage source to be returned."
	return ""


func _test_end_modifier_feedback_accumulates_and_pulses() -> String:
	var fixture := _fixture()
	var coordinator: Variant = fixture["coordinator"]
	var model: CombatModel = fixture["model"]
	var view: FakeView = fixture["view"]
	model.set_combat_mastery_preview_total(OrbType.Id.FIRE, 3)
	var sources: Array[Dictionary] = [{"source_type": "relic", "source_id": "damage_charm"}]
	coordinator.apply_end_modifier_feedback(
		OrbType.Id.FIRE,
		4,
		sources
	)
	if model.combat_mastery_preview_total(OrbType.Id.FIRE) != 7:
		return "Expected end modifier feedback to accumulate on the model total."
	if int(view.feedback.get(OrbType.Id.FIRE, -1)) != 7:
		return "Expected end modifier feedback to update the view."
	if view.pulses.size() != 1:
		return "Expected end modifier sources to pulse once."
	return ""


func _fixture() -> Dictionary:
	var model := CombatModel.new()
	var player := PlayerState.new()
	var view := FakeView.new()
	var coordinator: Variant = COORDINATOR_SCRIPT.new()
	coordinator.bind(model, player, view, {
		"resolution_order": RESOLUTION_ORDER,
		"feedback_stagger_seconds": 0.001,
	})
	coordinator.reset(_modifiers())
	view.clear_count = 0
	return {
		"coordinator": coordinator,
		"model": model,
		"player": player,
		"view": view,
	}


func _modifiers() -> Dictionary:
	return {
		"orb_bonus_by_id": {
			OrbType.Id.FIRE: 1,
			OrbType.Id.HEART: 2,
		},
		"combo_flat_bonus": 1,
		"combo_multiplier_mult": 2.0,
		"sources": [
			{
				"source_type": "relic",
				"source_id": "fire_orb",
				"combat_modifiers": {"orb_bonus_by_id": {OrbType.Id.FIRE: 1}},
			},
			{
				"source_type": "relic",
				"source_id": "heart_orb",
				"combat_modifiers": {"orb_bonus_by_id": {OrbType.Id.HEART: 2}},
			},
			{
				"source_type": "relic",
				"source_id": "combo_scaler",
				"combat_modifiers": {"combo_flat_bonus": 1, "combo_multiplier_mult": 2.0},
			},
			{
				"source_type": "relic",
				"source_id": "combo_scaler",
				"combat_modifiers": {"combo_multiplier_mult": 2.0},
			},
			{
				"source_type": "relic",
				"source_id": "damage_charm",
				"combat_modifiers": {"flat_damage_bonus": 4},
			},
		],
	}
