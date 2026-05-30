extends RefCounted
class_name CombatCharacterVisualsPresenter

const COMBAT_PLACEHOLDER_TEXTURES_SCRIPT := preload("res://scripts/combat/combat_placeholder_textures.gd")
const DEFAULT_ENEMY_ID := "cavern_striker"
const NODE_BINDINGS := {
	"timer_icon": "_timer_icon",
	"intent_badge": "_intent_badge",
	"intent_label": "_intent_label",
	"primary_intent_text_column": "_primary_intent_text_column",
	"player_portrait": "_player_portrait",
}

var _nodes: Dictionary = {}
var _visuals: Variant = null
var _enemy_stage_presenter: Variant = null
var _enemy_panel_rect := Rect2(Vector2.ZERO, Vector2(1048.0, 432.0))


static func nodes_from_root_nodes(root_nodes: Dictionary) -> Dictionary:
	var nodes := {}
	for key in NODE_BINDINGS.keys():
		nodes[key] = root_nodes.get(String(NODE_BINDINGS[key]), null)
	return nodes


func bind(root_nodes: Dictionary, visual_registry: Variant, enemy_stage_presenter: Variant, enemy_panel_rect: Rect2) -> void:
	_nodes = nodes_from_root_nodes(root_nodes)
	_visuals = visual_registry
	_enemy_stage_presenter = enemy_stage_presenter
	_enemy_panel_rect = enemy_panel_rect


func ensure_placeholders() -> void:
	var timer_icon := _nodes.get("timer_icon") as TextureRect
	if timer_icon != null:
		if timer_icon.texture == null:
			timer_icon.texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_timer_placeholder_texture()
		timer_icon.visible = true
	_set_canvas_item_visible("intent_badge", false)
	_set_canvas_item_visible("intent_label", false)
	_set_canvas_item_visible("primary_intent_text_column", false)
	if _enemy_stage_presenter != null and _enemy_stage_presenter.has_method("ensure_backdrop_placeholder"):
		_enemy_stage_presenter.ensure_backdrop_placeholder()
	_apply_hero_portrait()


func refresh_character_portraits(enemy_id: String) -> String:
	var resolved_enemy_id := _resolved_enemy_id(enemy_id)
	if _enemy_stage_presenter != null and _enemy_stage_presenter.has_method("refresh_enemy_visuals"):
		resolved_enemy_id = String(_enemy_stage_presenter.refresh_enemy_visuals(resolved_enemy_id, _enemy_panel_rect))
	_apply_hero_portrait()
	return resolved_enemy_id


func _apply_hero_portrait() -> void:
	var player_portrait := _nodes.get("player_portrait") as TextureRect
	if player_portrait == null:
		return
	var hero_texture: Texture2D = null
	if _visuals != null:
		hero_texture = _visuals.hero_portrait()
	if hero_texture == null:
		hero_texture = COMBAT_PLACEHOLDER_TEXTURES_SCRIPT.make_hero_placeholder_texture()
	player_portrait.texture = hero_texture
	player_portrait.visible = true
	player_portrait.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _resolved_enemy_id(enemy_id: String) -> String:
	var resolved_enemy_id := enemy_id.strip_edges()
	if resolved_enemy_id == "":
		resolved_enemy_id = DEFAULT_ENEMY_ID
	return resolved_enemy_id


func _set_canvas_item_visible(node_key: String, visible: bool) -> void:
	var canvas_item := _nodes.get(node_key) as CanvasItem
	if canvas_item != null:
		canvas_item.visible = visible
