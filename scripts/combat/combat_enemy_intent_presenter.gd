extends RefCounted
class_name CombatEnemyIntentPresenter

const COMBAT_ENEMY_INTENT_BUBBLE_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_intent_bubble_presenter.gd")
const COMBAT_ENEMY_BLOCK_PREVIEW_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_enemy_block_preview_presenter.gd")
const CALLBACK_INTENT_HOVERED := "intent_hovered"
const CALLBACK_BLOCK_HOVERED := "block_hovered"
const CALLBACK_HOVER_ENDED := "hover_ended"

var _root_nodes: Dictionary = {}
var _callbacks: Dictionary = {}
var _intent_bubble_presenter: Variant = null
var _block_preview_presenter: Variant = null


func bind(root_nodes: Dictionary, callbacks: Dictionary = {}) -> void:
	_root_nodes = root_nodes
	_callbacks = callbacks.duplicate()


func sync_intent_bubbles(preview: Dictionary) -> void:
	_ensure_intent_bubble_presenter()
	if _intent_bubble_presenter != null:
		_intent_bubble_presenter.sync(preview)


func start_hover_emphasis(kind: String) -> void:
	_ensure_intent_bubble_presenter()
	if _intent_bubble_presenter != null:
		_intent_bubble_presenter.start_hover_emphasis(kind)


func stop_hover_emphasis() -> void:
	if _intent_bubble_presenter != null:
		_intent_bubble_presenter.stop_hover_emphasis()


func set_tutorial_focus(kind: String) -> void:
	_ensure_intent_bubble_presenter()
	if _intent_bubble_presenter != null:
		_intent_bubble_presenter.set_tutorial_focus(kind)


func clear_tutorial_focus() -> void:
	if _intent_bubble_presenter != null:
		_intent_bubble_presenter.clear_tutorial_focus()


func ensure_block_preview_nodes() -> void:
	_ensure_block_preview_presenter()
	if _block_preview_presenter != null:
		_block_preview_presenter.ensure_nodes()


func sync_block_intent_preview(preview: Dictionary) -> void:
	_ensure_block_preview_presenter()
	if _block_preview_presenter != null:
		_block_preview_presenter.sync(preview)


func layout_block_intent_preview() -> void:
	_ensure_block_preview_presenter()
	if _block_preview_presenter != null:
		_block_preview_presenter.layout()


func intent_buttons() -> Array[Button]:
	if _intent_bubble_presenter == null:
		return []
	return _intent_bubble_presenter.buttons()


func block_preview_button() -> Control:
	if _block_preview_presenter == null:
		return null
	return _block_preview_presenter.button()


func block_preview_fill() -> ColorRect:
	if _block_preview_presenter == null:
		return null
	return _block_preview_presenter.fill()


func _ensure_intent_bubble_presenter() -> void:
	var intent_row := _root_nodes.get("_intent_row") as HBoxContainer
	if intent_row == null:
		return
	if _intent_bubble_presenter == null:
		_intent_bubble_presenter = COMBAT_ENEMY_INTENT_BUBBLE_PRESENTER_SCRIPT.new()
	_intent_bubble_presenter.bind(
		{
			"intent_row": intent_row,
			"intent_label": _root_nodes.get("_intent_label"),
			"intent_badge": _root_nodes.get("_intent_badge"),
			"primary_intent_text_column": _root_nodes.get("_primary_intent_text_column"),
		},
		{
			COMBAT_ENEMY_INTENT_BUBBLE_PRESENTER_SCRIPT.CALLBACK_HOVERED: _callback(CALLBACK_INTENT_HOVERED),
			COMBAT_ENEMY_INTENT_BUBBLE_PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: _callback(CALLBACK_HOVER_ENDED),
		}
	)


func _ensure_block_preview_presenter() -> void:
	var enemy_hp_row := _root_nodes.get("_enemy_hp_row") as Control
	if enemy_hp_row == null:
		return
	if _block_preview_presenter == null:
		_block_preview_presenter = COMBAT_ENEMY_BLOCK_PREVIEW_PRESENTER_SCRIPT.new()
	_block_preview_presenter.bind(
		enemy_hp_row,
		_root_nodes.get("_enemy_hp_bar") as ProgressBar,
		{
			COMBAT_ENEMY_BLOCK_PREVIEW_PRESENTER_SCRIPT.CALLBACK_HOVERED: _callback(CALLBACK_BLOCK_HOVERED),
			COMBAT_ENEMY_BLOCK_PREVIEW_PRESENTER_SCRIPT.CALLBACK_HOVER_ENDED: _callback(CALLBACK_HOVER_ENDED),
		}
	)


func _callback(name: String) -> Callable:
	var raw_callback: Variant = _callbacks.get(name, Callable())
	if raw_callback is Callable:
		return raw_callback
	return Callable()
