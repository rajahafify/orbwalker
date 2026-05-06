extends Control

const COLLECTION_MODEL_SCRIPT := preload("res://scripts/collection/collection_model.gd")
const COLLECTION_VIEW_SCRIPT := preload("res://scripts/collection/collection_view.gd")
const COLLECTION_CONTROLLER_SCRIPT := preload("res://scripts/collection/collection_controller.gd")

@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _overlay_tint: ColorRect = %OverlayTint
@onready var _main_margin: MarginContainer = %MainMargin
@onready var _title_label: Label = %TitleLabel
@onready var _score_label: Label = %ScoreLabel
@onready var _families_scroll: ScrollContainer = %FamiliesScroll
@onready var _families_vbox: VBoxContainer = %FamiliesVBox
@onready var _back_button: Button = %BackButton
@onready var _status_label: Label = %StatusLabel
@onready var _achievement_toast: Control = %AchievementToast

var _model
var _view
var _controller

func _ready() -> void:
	_ensure_mvc()
	_controller.bind(self, _build_root_nodes(), _model, _view)
	_controller.ready()

func _on_back_button_pressed() -> void:
	if _controller != null:
		_controller._on_back_button_pressed()

func _ensure_mvc() -> void:
	if _model == null:
		_model = COLLECTION_MODEL_SCRIPT.new()
	if _view == null:
		_view = COLLECTION_VIEW_SCRIPT.new()
	if _controller == null:
		_controller = COLLECTION_CONTROLLER_SCRIPT.new()

func _build_root_nodes() -> Dictionary:
	return {
		"background_texture": _background_texture,
		"overlay_tint": _overlay_tint,
		"main_margin": _main_margin,
		"title_label": _title_label,
		"score_label": _score_label,
		"families_scroll": _families_scroll,
		"families_vbox": _families_vbox,
		"back_button": _back_button,
		"status_label": _status_label,
		"achievement_toast": _achievement_toast,
	}
