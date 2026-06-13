extends RefCounted
class_name CombatVfxRuntimeSpawnerTest

const SPAWNER_SCRIPT := preload("res://scripts/combat/combat_vfx_runtime_spawner.gd")
const TEXTURE_FACTORY_SCRIPT := preload("res://scripts/combat/combat_runtime_vfx_texture_factory.gd")
const GAME_JUICE_FLAGS_SCRIPT := preload("res://scripts/core/game_juice_flags.gd")


class FakeVisualRegistry:
	extends RefCounted

	var texture := ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8 as Image.Format))
	var requested_effects: Array[String] = []

	func vfx_texture(effect_name: String) -> Texture2D:
		requested_effects.append(effect_name)
		return texture


class FakeMaxOverlay:
	extends RefCounted

	var handled := false
	var generic_calls := 0

	func spawn_generic(_global_center: Vector2, _draw_size: Vector2, _lifetime: float, _modulate_color: Color) -> bool:
		generic_calls += 1
		return handled


class FakeSparkBurstPresenter:
	extends RefCounted

	var burst_calls := 0

	func spawn_visible_spark_burst(_global_center: Vector2, _draw_size: Vector2, _color: Color, _lifetime: float) -> void:
		burst_calls += 1


class FakeCallbacks:
	extends RefCounted

	var use_max := false
	var enabled_flags := {
		GAME_JUICE_FLAGS_SCRIPT.IMPACT_RINGS_RESULT_LABELS: true,
	}

	func use_max_combat_vfx() -> bool:
		return use_max

	func juice_enabled(flag_key: String) -> bool:
		return bool(enabled_flags.get(flag_key, false))


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("spawn_vfx_looks_up_texture_and_places_sprite", _test_spawn_vfx_looks_up_texture_and_places_sprite, failures)
	_run_case("max_overlay_short_circuits_generic_sprite", _test_max_overlay_short_circuits_generic_sprite, failures)
	_run_case("runtime_caps_and_textures_come_from_factory", _test_runtime_caps_and_textures_come_from_factory, failures)
	return {"passed": failures.is_empty(), "total": 3, "failed": failures.size(), "failures": failures}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_spawn_vfx_looks_up_texture_and_places_sprite() -> String:
	var fixture := _fixture()
	var spawner: Variant = fixture["spawner"]
	var layer: Control = fixture["layer"]
	var registry: FakeVisualRegistry = fixture["registry"]
	var spark_burst: FakeSparkBurstPresenter = fixture["spark_burst"]

	spawner.spawn_vfx("orb_clear", Vector2(100, 140), Vector2(32, 48), 0.2, Color.RED)

	var texture_rect := layer.get_child(0) as TextureRect if layer.get_child_count() > 0 else null
	var error := ""
	if registry.requested_effects != ["orb_clear"]:
		error = "Expected runtime spawner to look up the requested effect texture."
	elif texture_rect == null:
		error = "Expected runtime spawner to add a TextureRect."
	elif texture_rect.texture != registry.texture:
		error = "Expected spawned TextureRect to use the registry texture."
	elif texture_rect.position != Vector2(84, 116):
		error = "Expected spawned TextureRect to be centered on the global target."
	elif texture_rect.z_index != 124:
		error = "Expected spawned TextureRect to use the post-match VFX z-index."
	elif spark_burst.burst_calls != 1:
		error = "Expected runtime spawner to trigger the visible spark burst collaborator."
	_cleanup_fixture(fixture)
	return error


func _test_max_overlay_short_circuits_generic_sprite() -> String:
	var fixture := _fixture()
	var spawner: Variant = fixture["spawner"]
	var layer: Control = fixture["layer"]
	var overlay: FakeMaxOverlay = fixture["overlay"]
	var callbacks: FakeCallbacks = fixture["callbacks"]
	callbacks.use_max = true
	overlay.handled = true

	spawner.spawn_vfx_texture(
		ImageTexture.create_from_image(Image.create(4, 4, false, Image.FORMAT_RGBA8 as Image.Format)), Vector2(50, 60), Vector2(20, 20), 0.3
	)

	var error := ""
	if overlay.generic_calls != 1:
		error = "Expected max overlay to receive the generic VFX spawn."
	elif layer.get_child_count() != 0:
		error = "Expected handled max overlay spawn to skip the fallback TextureRect."
	_cleanup_fixture(fixture)
	return error


func _test_runtime_caps_and_textures_come_from_factory() -> String:
	var fixture := _fixture()
	var spawner: Variant = fixture["spawner"]
	var caps: Dictionary = spawner.post_match_runtime_vfx_caps()
	var keys: Array = caps.get("texture_keys", [])
	var error := ""
	if int(caps.get("max_particles_per_burst", 0)) != 72:
		error = "Expected particle burst cap to stay at the phone-first limit."
	elif not keys.has("hex_cell"):
		error = "Expected runtime caps to expose texture factory keys."
	elif spawner.post_match_runtime_texture("hex_cell") == null:
		error = "Expected runtime spawner to return generated factory textures."
	_cleanup_fixture(fixture)
	return error


func _fixture() -> Dictionary:
	var tree := Engine.get_main_loop() as SceneTree
	var root := Control.new()
	root.name = "CombatVfxRuntimeSpawnerTestRoot"
	tree.root.add_child(root)
	var layer := Control.new()
	layer.name = "VfxLayer"
	layer.size = Vector2(300, 240)
	root.add_child(layer)
	var registry := FakeVisualRegistry.new()
	var overlay := FakeMaxOverlay.new()
	var spark_burst := FakeSparkBurstPresenter.new()
	var callbacks := FakeCallbacks.new()
	var spawner: Variant = SPAWNER_SCRIPT.new()
	(
		spawner
		. bind(
			{
				"vfx_layer": layer,
				"visual_registry": registry,
				"timer_owner": root,
				"max_vfx_overlay": overlay,
				"runtime_texture_factory": TEXTURE_FACTORY_SCRIPT.new(),
				"spark_burst_presenter": spark_burst,
			},
			{
				"use_max_combat_vfx": Callable(callbacks, "use_max_combat_vfx"),
				"juice_enabled": Callable(callbacks, "juice_enabled"),
			}
		)
	)
	return {
		"root": root,
		"layer": layer,
		"registry": registry,
		"overlay": overlay,
		"spark_burst": spark_burst,
		"callbacks": callbacks,
		"spawner": spawner,
	}


func _cleanup_fixture(fixture: Dictionary) -> void:
	var root: Node = fixture["root"]
	if root != null and is_instance_valid(root):
		root.free()
