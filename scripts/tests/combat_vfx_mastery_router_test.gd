extends RefCounted
class_name CombatVfxMasteryRouterTest

const ROUTER_SCRIPT := preload("res://scripts/combat/combat_vfx_mastery_router.gd")


class FakeHud:
	extends RefCounted

	var card: Control = null

	func get_combat_mastery_card(_cards: Control, _orb_id: int) -> Control:
		return card


class FakeFillPresenter:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func spawn_fill_stream(
		source_local: Vector2, target_local: Vector2, orb_id: int, lifetime: float, intensity: int, streams_enabled: bool, flare_enabled: bool
	) -> void:
		(
			calls
			. append(
				{
					"source": source_local,
					"target": target_local,
					"orb_id": orb_id,
					"lifetime": lifetime,
					"intensity": intensity,
					"streams_enabled": streams_enabled,
					"flare_enabled": flare_enabled,
				}
			)
		)


class FakeCastPresenter:
	extends RefCounted

	var spool_calls := 0
	var travel_calls := 0

	func spawn_cast_spool(_source_local: Vector2, _orb_id: int, _spool_lifetime: float, _intensity: int) -> void:
		spool_calls += 1

	func spawn_cast_travel(_source_local: Vector2, _target_local: Vector2, _orb_id: int, _travel_lifetime: float, _delay: float, _intensity: int) -> void:
		travel_calls += 1


class FakeReplayPolicy:
	extends RefCounted

	func replay_result_vfx_tier(_kind: String, _amount: int) -> int:
		return 2

	func result_vfx_tier_index(_tier: int) -> int:
		return 1


class FakeStylizedReplay:
	extends RefCounted

	func replay_effect_intensity(_amount: int, _tier_index: int) -> int:
		return 5


class FakeMaxOverlay:
	extends RefCounted

	var handled := false
	var cast_calls := 0

	func spawn_mastery_cast_sequence(
		_orb_id: int, _source_point: Vector2, _target_global: Vector2, _spool_lifetime: float, _travel_lifetime: float, _amount: int
	) -> bool:
		cast_calls += 1
		return handled


class FakeBeamPresenter:
	extends RefCounted

	var calls := 0

	func spawn_mastery_beam(
		_source_orb_or_node: Variant, _target_or_start: Vector2, _orb_or_target: Variant, _lifetime: float, _streams_enabled: bool, _max_enabled: bool
	) -> void:
		calls += 1


class FakeCallbacks:
	extends RefCounted

	var use_max := false
	var enabled_flags: Dictionary = {
		GameJuiceFlags.MASTERY_FILL_STREAMS: true,
		GameJuiceFlags.MASTERY_CARD_INTAKE_FLARE: true,
	}

	func mastery_impact_kind(_orb_id: int) -> String:
		return "fire"

	func use_max_combat_vfx() -> bool:
		return use_max

	func juice_enabled(flag_key: String) -> bool:
		return bool(enabled_flags.get(flag_key, false))


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("fill_stream_routes_to_fill_presenter", _test_fill_stream_routes_to_fill_presenter, failures)
	_run_case("max_overlay_short_circuits_cast_presenters", _test_max_overlay_short_circuits_cast_presenters, failures)
	return {"passed": failures.is_empty(), "total": 2, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_fill_stream_routes_to_fill_presenter() -> String:
	var fixture := _fixture()
	var router: Variant = fixture.get("router")
	var fill: FakeFillPresenter = fixture.get("fill")

	router.spawn_mastery_fill_stream(OrbType.Id.FIRE, Vector2(20, 30), 18, 0.34, false)

	if fill.calls.size() != 1:
		return "Expected mastery router to forward one fill-stream call."
	if int(fill.calls[0].get("intensity")) != 6:
		return "Expected fill-stream intensity derived from amount."
	if not bool(fill.calls[0].get("streams_enabled")) or not bool(fill.calls[0].get("flare_enabled")):
		return "Expected enabled stream and flare flags to reach the fill presenter."
	return ""


func _test_max_overlay_short_circuits_cast_presenters() -> String:
	var fixture := _fixture()
	var router: Variant = fixture.get("router")
	var callbacks: FakeCallbacks = fixture.get("callbacks")
	var overlay: FakeMaxOverlay = fixture.get("overlay")
	var cast: FakeCastPresenter = fixture.get("cast")
	callbacks.use_max = true
	overlay.handled = true

	router.spawn_mastery_cast_sequence(OrbType.Id.FIRE, Vector2(160, 80), 0.2, 0.3, 12)

	if overlay.cast_calls != 1:
		return "Expected max overlay mastery cast to be attempted."
	if cast.spool_calls != 0 or cast.travel_calls != 0:
		return "Expected handled max overlay mastery cast to skip fallback cast presenters."
	return ""


func _fixture() -> Dictionary:
	var layer := Control.new()
	layer.size = Vector2(320, 240)
	var cards := Control.new()
	var card := Control.new()
	card.position = Vector2(40, 50)
	card.size = Vector2(48, 48)
	cards.add_child(card)
	var hud := FakeHud.new()
	hud.card = card
	var fill := FakeFillPresenter.new()
	var cast := FakeCastPresenter.new()
	var policy := FakeReplayPolicy.new()
	var stylized := FakeStylizedReplay.new()
	var overlay := FakeMaxOverlay.new()
	var beam := FakeBeamPresenter.new()
	var callbacks := FakeCallbacks.new()
	var router: Variant = ROUTER_SCRIPT.new()
	(
		router
		. bind(
			{
				"vfx_layer": layer,
				"player_loadout_hud": hud,
				"elemental_mastery_cards": cards,
				"max_vfx_overlay": overlay,
				"mastery_fill_vfx_presenter": fill,
				"mastery_cast_vfx_presenter": cast,
				"replay_result_policy": policy,
				"stylized_replay_vfx_presenter": stylized,
				"mastery_beam_presenter": beam,
			},
			{
				"mastery_impact_kind": Callable(callbacks, "mastery_impact_kind"),
				"use_max_combat_vfx": Callable(callbacks, "use_max_combat_vfx"),
				"juice_enabled": Callable(callbacks, "juice_enabled"),
			}
		)
	)
	return {"router": router, "fill": fill, "cast": cast, "overlay": overlay, "callbacks": callbacks}
