extends RefCounted
class_name CombatEnemyStagePresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_stage_presenter.gd")


class VisualRegistryStub:
	extends RefCounted

	var stage_texture: Texture2D = null
	var sprite_texture: Texture2D = null

	func _init(p_stage_texture: Texture2D = null, p_sprite_texture: Texture2D = null) -> void:
		stage_texture = p_stage_texture
		sprite_texture = p_sprite_texture

	func combat_enemy_stage_texture(enemy_id: String) -> Texture2D:
		if enemy_id == "wide" or enemy_id == "cavern_striker":
			return stage_texture
		return null

	func enemy_sprite(enemy_id: String) -> Texture2D:
		if enemy_id == "wide" or enemy_id == "cavern_striker":
			return sprite_texture
		return null

	func enemy_visual_profile(enemy_id: String) -> Dictionary:
		if enemy_id == "wide":
			return {
				"scale": 1.35,
				"offset": Vector2(12.0, -18.0),
				"shadow_scale": 1.25,
				"shadow_alpha": 0.52,
			}
		return {}


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("ensure_nodes_creates_stage_chrome", _test_ensure_nodes_creates_stage_chrome, failures)
	_run_case("visual_profile_applies_offsets_and_shadow", _test_visual_profile_applies_offsets_and_shadow, failures)
	_run_case("visual_profile_uses_layout_fallback_size", _test_visual_profile_uses_layout_fallback_size, failures)
	_run_case("stage_snapshot_applies_textures_stats_and_preview", _test_stage_snapshot_applies_textures_stats_and_preview, failures)
	_run_case("stage_snapshot_uses_default_registry_texture_fallbacks", _test_stage_snapshot_uses_default_registry_texture_fallbacks, failures)
	_run_case("refresh_enemy_visuals_uses_specific_registry_textures", _test_refresh_enemy_visuals_uses_specific_registry_textures, failures)
	return {
		"passed": failures.is_empty(),
		"total": 6,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_ensure_nodes_creates_stage_chrome() -> String:
	var fixture := _fixture(Vector2(400.0, 220.0))
	var root: Control = fixture["root"]
	var stage: Control = fixture["stage"]
	var presenter: Variant = fixture["presenter"]
	presenter.ensure_nodes()
	if presenter.backdrop() == null or presenter.ground_shadow() == null or presenter.text_scrim() == null:
		root.free()
		return "Expected all enemy stage chrome nodes to be created."
	if presenter.backdrop().get_parent() != stage or presenter.ground_shadow().get_parent() != stage or presenter.text_scrim().get_parent() != stage:
		root.free()
		return "Expected stage chrome nodes to be parented under enemy stage."
	if stage.get_child(0) != presenter.backdrop():
		root.free()
		return "Expected backdrop to be first child."
	if presenter.backdrop().stretch_mode != TextureRect.StretchMode.STRETCH_KEEP_ASPECT_COVERED:
		root.free()
		return "Expected backdrop stretch mode to preserve covered art."
	if not is_equal_approx(presenter.backdrop().modulate.a, 0.94):
		root.free()
		return "Expected backdrop alpha to preserve existing value."
	if presenter.text_scrim().color != Color(0.02, 0.04, 0.06, 0.72):
		root.free()
		return "Expected text scrim color to preserve existing value."
	root.free()
	return ""


func _test_visual_profile_applies_offsets_and_shadow() -> String:
	var fixture := _fixture(Vector2(400.0, 220.0), VisualRegistryStub.new())
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var portrait: TextureRect = fixture["portrait"]
	presenter.ensure_nodes()
	portrait.visible = true
	presenter.apply_visual_profile("wide")
	if portrait.position != Vector2(12.0, -18.0):
		root.free()
		return "Expected portrait offset from visual profile."
	if not _vector_equal(portrait.size, Vector2(400.0, 220.0)):
		root.free()
		return "Expected portrait size to match stage size."
	if not _vector_equal(portrait.scale, Vector2(1.35, 1.35)):
		root.free()
		return "Expected portrait scale from visual profile."
	var shadow: Panel = presenter.ground_shadow()
	var expected_shadow_size := Vector2(180.0, 30.25)
	if not _vector_equal(shadow.size, expected_shadow_size):
		root.free()
		return "Expected shadow size from visual profile, got %s." % str(shadow.size)
	if not _vector_equal(shadow.position, Vector2(110.0, 160.6)):
		root.free()
		return "Expected shadow position from stage geometry."
	var shadow_style := shadow.get_theme_stylebox("panel") as StyleBoxFlat
	if shadow_style == null or not is_equal_approx(shadow_style.bg_color.a, 0.52):
		root.free()
		return "Expected shadow alpha from visual profile."
	root.free()
	return ""


func _test_visual_profile_uses_layout_fallback_size() -> String:
	var fixture := _fixture(Vector2.ZERO)
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var portrait: TextureRect = fixture["portrait"]
	portrait.visible = true
	presenter.ensure_nodes()
	presenter.apply_visual_profile("default", Rect2(Vector2(10.0, 20.0), Vector2(300.0, 120.0)))
	if not _vector_equal(portrait.size, Vector2(300.0, 120.0)):
		root.free()
		return "Expected portrait to use layout rect size when stage has no size."
	if not _vector_equal(presenter.ground_shadow().size, Vector2(108.0, 30.0)):
		root.free()
		return "Expected shadow to use layout fallback size and minimum height."
	root.free()
	return ""


func _test_stage_snapshot_applies_textures_stats_and_preview() -> String:
	var fixture := _fixture(Vector2(400.0, 220.0), VisualRegistryStub.new())
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var portrait: TextureRect = fixture["portrait"]
	var nodes := _bind_snapshot_nodes(root, presenter)
	var stage_texture := _texture()
	var enemy_texture := _texture()
	var result: Dictionary = presenter.apply_snapshot(
		{
			"enemy_id": "wide",
			"enemy_stage_texture": stage_texture,
			"enemy_portrait_texture": enemy_texture,
			"enemy_hp_max": 30,
			"enemy_hp_value": 12,
			"enemy_name_text": "Crystal Bat",
			"enemy_hp_text": "HP 12 / 30",
			"enemy_intent_preview": {"block": 5},
		},
		"cavern_striker"
	)
	var hp_bar := nodes.get("enemy_hp_bar") as ProgressBar
	if String(result.get("enemy_id", "")) != "wide" or int(Dictionary(result.get("enemy_intent_preview", {})).get("block", 0)) != 5:
		root.free()
		return "Expected snapshot result to carry resolved enemy id and preview."
	if presenter.backdrop().texture != stage_texture or portrait.texture != enemy_texture:
		root.free()
		return "Expected explicit snapshot textures to be applied."
	if not portrait.visible or not presenter.backdrop().visible:
		root.free()
		return "Expected portrait and backdrop to be visible."
	if hp_bar.max_value != 30.0 or hp_bar.value != 12.0:
		root.free()
		return "Expected enemy HP bar values."
	if nodes.get("enemy_name_label").text != "Crystal Bat" or nodes.get("enemy_label").text != "Crystal Bat":
		root.free()
		return "Expected enemy name labels to match snapshot."
	if nodes.get("enemy_hp_text_label").text != "HP 12 / 30":
		root.free()
		return "Expected enemy HP text label."
	root.free()
	return ""


func _test_stage_snapshot_uses_default_registry_texture_fallbacks() -> String:
	var stage_texture := _texture()
	var sprite_texture := _texture()
	var fixture := _fixture(Vector2(400.0, 220.0), VisualRegistryStub.new(stage_texture, sprite_texture))
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var portrait: TextureRect = fixture["portrait"]
	_bind_snapshot_nodes(root, presenter)
	var result: Dictionary = presenter.apply_snapshot({"enemy_id": ""}, "wide")
	if String(result.get("enemy_id", "")) != "wide":
		root.free()
		return "Expected blank snapshot enemy id to keep current id."
	if presenter.backdrop().texture != stage_texture or portrait.texture != sprite_texture:
		root.free()
		return "Expected missing snapshot textures to use default registry fallbacks."
	root.free()
	return ""


func _test_refresh_enemy_visuals_uses_specific_registry_textures() -> String:
	var stage_texture := _texture()
	var sprite_texture := _texture()
	var fixture := _fixture(Vector2(400.0, 220.0), VisualRegistryStub.new(stage_texture, sprite_texture))
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var portrait: TextureRect = fixture["portrait"]
	var resolved: String = presenter.refresh_enemy_visuals("wide", Rect2(Vector2.ZERO, Vector2(300.0, 120.0)))
	if resolved != "wide":
		root.free()
		return "Expected refresh to return resolved enemy id."
	if presenter.backdrop().texture != stage_texture or portrait.texture != sprite_texture:
		root.free()
		return "Expected refresh to use enemy-specific registry textures."
	if not portrait.visible or not presenter.backdrop().visible:
		root.free()
		return "Expected refreshed portrait and backdrop to be visible."
	if portrait.position != Vector2(12.0, -18.0):
		root.free()
		return "Expected refresh to apply enemy visual profile."
	root.free()
	return ""


func _fixture(stage_size: Vector2, visuals: Variant = null) -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var stage := Control.new()
	stage.name = "EnemyStage"
	stage.size = stage_size
	root.add_child(stage)
	var portrait := TextureRect.new()
	portrait.name = "EnemyPortrait"
	stage.add_child(portrait)
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(stage, portrait, visuals)
	return {
		"root": root,
		"stage": stage,
		"portrait": portrait,
		"presenter": presenter,
	}


func _bind_snapshot_nodes(root: Control, presenter: Variant) -> Dictionary:
	var nodes := {
		"enemy_hp_bar": ProgressBar.new(),
		"enemy_name_label": Label.new(),
		"enemy_label": Label.new(),
		"enemy_hp_text_label": Label.new(),
	}
	for key in nodes.keys():
		var node := nodes.get(key) as Node
		node.name = String(key)
		root.add_child(node)
	presenter.bind_snapshot_nodes(nodes)
	return nodes


func _texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	return ImageTexture.create_from_image(image)


func _vector_equal(left: Vector2, right: Vector2) -> bool:
	return is_equal_approx(left.x, right.x) and is_equal_approx(left.y, right.y)
