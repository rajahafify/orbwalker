extends RefCounted
class_name CombatCharacterVisualsPresenterTest

const PRESENTER_SCRIPT := preload("res://scripts/combat/combat_character_visuals_presenter.gd")


class VisualRegistryStub:
	extends RefCounted

	var hero_texture: Texture2D = null

	func _init(p_hero_texture: Texture2D = null) -> void:
		hero_texture = p_hero_texture

	func hero_portrait() -> Texture2D:
		return hero_texture


class EnemyStagePresenterStub:
	extends RefCounted

	var ensure_backdrop_calls := 0
	var refresh_calls: Array[Dictionary] = []
	var refresh_result := "cavern_striker"

	func ensure_backdrop_placeholder() -> void:
		ensure_backdrop_calls += 1

	func refresh_enemy_visuals(enemy_id: String, enemy_panel_rect: Rect2) -> String:
		refresh_calls.append({
			"enemy_id": enemy_id,
			"enemy_panel_rect": enemy_panel_rect,
		})
		return refresh_result


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("ensure_placeholders_sets_timer_hero_and_hides_legacy_intent", _test_ensure_placeholders_sets_timer_hero_and_hides_legacy_intent, failures)
	_run_case("refresh_character_portraits_resolves_enemy_and_refreshes_hero", _test_refresh_character_portraits_resolves_enemy_and_refreshes_hero, failures)
	_run_case("missing_nodes_and_visuals_use_safe_fallbacks", _test_missing_nodes_and_visuals_use_safe_fallbacks, failures)
	return {
		"passed": failures.is_empty(),
		"total": 3,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_ensure_placeholders_sets_timer_hero_and_hides_legacy_intent() -> String:
	var hero_texture := _texture()
	var fixture := _fixture(VisualRegistryStub.new(hero_texture))
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	var stage: EnemyStagePresenterStub = fixture["stage"]
	root_nodes.get("_intent_badge").visible = true
	root_nodes.get("_intent_label").visible = true
	root_nodes.get("_primary_intent_text_column").visible = true
	presenter.ensure_placeholders()
	if root_nodes.get("_timer_icon").texture == null or not root_nodes.get("_timer_icon").visible:
		root.free()
		return "Expected timer placeholder texture and visibility."
	if root_nodes.get("_intent_badge").visible or root_nodes.get("_intent_label").visible or root_nodes.get("_primary_intent_text_column").visible:
		root.free()
		return "Expected legacy intent nodes to be hidden."
	if root_nodes.get("_player_portrait").texture != hero_texture or not root_nodes.get("_player_portrait").visible:
		root.free()
		return "Expected hero portrait from visual registry."
	if root_nodes.get("_player_portrait").modulate != Color.WHITE:
		root.free()
		return "Expected hero portrait modulation to reset."
	if stage.ensure_backdrop_calls != 1:
		root.free()
		return "Expected enemy stage backdrop placeholder to be ensured."
	root.free()
	return ""


func _test_refresh_character_portraits_resolves_enemy_and_refreshes_hero() -> String:
	var hero_texture := _texture()
	var fixture := _fixture(VisualRegistryStub.new(hero_texture), Rect2(Vector2(4.0, 8.0), Vector2(300.0, 120.0)))
	var root: Control = fixture["root"]
	var presenter: Variant = fixture["presenter"]
	var root_nodes: Dictionary = fixture["root_nodes"]
	var stage: EnemyStagePresenterStub = fixture["stage"]
	stage.refresh_result = "boss"
	var resolved: String = presenter.refresh_character_portraits("")
	if resolved != "boss":
		root.free()
		return "Expected stage presenter resolved id to be returned."
	if stage.refresh_calls.size() != 1:
		root.free()
		return "Expected one stage refresh call."
	if stage.refresh_calls[0].get("enemy_id") != "cavern_striker":
		root.free()
		return "Expected blank enemy id to resolve to default before stage refresh."
	if stage.refresh_calls[0].get("enemy_panel_rect") != Rect2(Vector2(4.0, 8.0), Vector2(300.0, 120.0)):
		root.free()
		return "Expected enemy panel rect to pass through."
	if root_nodes.get("_player_portrait").texture != hero_texture:
		root.free()
		return "Expected hero portrait refresh during character refresh."
	root.free()
	return ""


func _test_missing_nodes_and_visuals_use_safe_fallbacks() -> String:
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind({}, null, null, Rect2())
	presenter.ensure_placeholders()
	var root := Control.new()
	var root_nodes := {"_player_portrait": TextureRect.new()}
	root.add_child(root_nodes.get("_player_portrait"))
	presenter.bind(root_nodes, null, null, Rect2())
	var resolved: String = presenter.refresh_character_portraits("  ")
	if resolved != "cavern_striker":
		root.free()
		return "Expected blank refresh id to resolve to default without a stage presenter."
	if root_nodes.get("_player_portrait").texture == null:
		root.free()
		return "Expected hero placeholder texture when visual registry is missing."
	root.free()
	return ""


func _fixture(visuals: Variant = null, enemy_panel_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(1048.0, 432.0))) -> Dictionary:
	var root := Control.new()
	root.name = "Root"
	var root_nodes := {
		"_timer_icon": _add_texture_rect(root, "TimerIcon"),
		"_intent_badge": _add_texture_rect(root, "IntentBadge"),
		"_intent_label": _add_label(root, "IntentLabel"),
		"_primary_intent_text_column": _add_control(root, "PrimaryIntentTextColumn"),
		"_player_portrait": _add_texture_rect(root, "PlayerPortrait"),
	}
	var stage := EnemyStagePresenterStub.new()
	var presenter: Variant = PRESENTER_SCRIPT.new()
	presenter.bind(root_nodes, visuals, stage, enemy_panel_rect)
	return {
		"root": root,
		"root_nodes": root_nodes,
		"stage": stage,
		"presenter": presenter,
	}


func _add_texture_rect(root: Control, node_name: String) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	root.add_child(texture_rect)
	return texture_rect


func _add_label(root: Control, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	root.add_child(label)
	return label


func _add_control(root: Control, node_name: String) -> Control:
	var control := Control.new()
	control.name = node_name
	root.add_child(control)
	return control


func _texture() -> Texture2D:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)
