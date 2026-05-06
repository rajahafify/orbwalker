extends Control

const RUN_SUMMARY_MODEL_SCRIPT := preload("res://scripts/run_summary/run_summary_model.gd")
const RUN_SUMMARY_VIEW_SCRIPT := preload("res://scripts/run_summary/run_summary_view.gd")
const RUN_SUMMARY_CONTROLLER_SCRIPT := preload("res://scripts/run_summary/run_summary_controller.gd")

@onready var _summary_label: Label = %SummaryLabel
@onready var _title_label: Label = %TitleLabel
@onready var _center_container: CenterContainer = $CenterContainer
@onready var _panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var _content_box: VBoxContainer = $CenterContainer/PanelContainer/VBoxContainer
@onready var _new_run_button: Button = $CenterContainer/PanelContainer/VBoxContainer/NewRunButton
@onready var _main_menu_button: Button = $CenterContainer/PanelContainer/VBoxContainer/MainMenuButton
@onready var _achievement_toast: Control = %AchievementToast

var _model
var _view
var _controller

func _ready() -> void:
	_ensure_mvc()
	_controller.bind(self, _build_root_nodes(), _model, _view)
	_controller.ready()

func _on_main_menu_button_pressed() -> void:
	if _controller != null:
		_controller._on_main_menu_button_pressed()

func _on_new_run_button_pressed() -> void:
	if _controller != null:
		_controller._on_new_run_button_pressed()

func _ensure_mvc() -> void:
	if _model == null:
		_model = RUN_SUMMARY_MODEL_SCRIPT.new()
	if _view == null:
		_view = RUN_SUMMARY_VIEW_SCRIPT.new()
	if _controller == null:
		_controller = RUN_SUMMARY_CONTROLLER_SCRIPT.new()

func _build_root_nodes() -> Dictionary:
	return {
		"summary_label": _summary_label,
		"title_label": _title_label,
		"center_container": _center_container,
		"panel_container": _panel_container,
		"content_box": _content_box,
		"new_run_button": _new_run_button,
		"main_menu_button": _main_menu_button,
		"achievement_toast": _achievement_toast,
	}
