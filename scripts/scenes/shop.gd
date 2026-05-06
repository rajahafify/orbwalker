extends Control

const SHOP_MODEL_SCRIPT := preload("res://scripts/shop/shop_model.gd")
const SHOP_VIEW_SCRIPT := preload("res://scripts/shop/shop_view.gd")
const SHOP_CONTROLLER_SCRIPT := preload("res://scripts/shop/shop_controller.gd")

@onready var _background: TextureRect = %Background
@onready var _backdrop_tint: ColorRect = %BackdropTint
@onready var _layout_root: Control = %ShopLayoutRoot

var _model
var _view
var _controller
var _viewport_connected := false


func _enter_tree() -> void:
	_ensure_mvc()
	_controller.enter_tree()


func _ready() -> void:
	_ensure_mvc()
	_controller.bind(self, _build_root_nodes(), _model, _view)
	if not _viewport_connected:
		get_viewport().size_changed.connect(_on_viewport_size_changed)
		_viewport_connected = true
	_controller.ready()


func _input(event: InputEvent) -> void:
	if _controller != null:
		_controller.handle_input(event)


func _on_viewport_size_changed() -> void:
	if _controller != null:
		_controller.on_viewport_size_changed()


static func shop_layout_probe_snapshot() -> Dictionary:
	return SHOP_VIEW_SCRIPT.shop_layout_probe_snapshot()


func _shop_layout_probe_snapshot() -> Dictionary:
	return shop_layout_probe_snapshot()


func _ensure_mvc() -> void:
	if _model == null:
		_model = SHOP_MODEL_SCRIPT.new()
	if _view == null:
		_view = SHOP_VIEW_SCRIPT.new()
	if _controller == null:
		_controller = SHOP_CONTROLLER_SCRIPT.new()


func _build_root_nodes() -> Dictionary:
	return {
		"background": _background,
		"backdrop_tint": _backdrop_tint,
		"layout_root": _layout_root,
	}
