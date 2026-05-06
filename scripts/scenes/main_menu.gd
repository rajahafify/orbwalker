extends Control

const MAIN_MENU_MODEL_SCRIPT := preload("res://scripts/main_menu/main_menu_model.gd")
const MAIN_MENU_VIEW_SCRIPT := preload("res://scripts/main_menu/main_menu_view.gd")
const MAIN_MENU_CONTROLLER_SCRIPT := preload("res://scripts/main_menu/main_menu_controller.gd")

@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _overlay_tint: ColorRect = $OverlayTint
@onready var _outer_frame: Control = %OuterFrame
@onready var _outer_border_texture: TextureRect = $OuterFrame/OuterBorderTexture
@onready var _logo_texture: TextureRect = %LogoTexture
@onready var _menu_button_column: VBoxContainer = %MenuButtonColumn
@onready var _start_run_button: Button = %StartRunButton
@onready var _generate_log_toggle: CheckButton = %GenerateLogToggle
@onready var _continue_button: Button = %ContinueButton
@onready var _collection_button: Button = %CollectionButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _element_row: HBoxContainer = %ElementRow
@onready var _stats_panel: Panel = %StatsPanel
@onready var _stats_row: HBoxContainer = %StatsRow
@onready var _footer_actions: HBoxContainer = %FooterActions
@onready var _profile_button: Button = $FooterActions/ProfileButton
@onready var _achievements_button: Button = $FooterActions/AchievementsButton
@onready var _footer_settings_button: Button = $FooterActions/FooterSettingsButton
@onready var _version_label: Label = %VersionLabel
@onready var _status_label: Label = %StatusLabel
@onready var _profile_overlay: Control = %ProfileOverlay
@onready var _profile_panel: PanelContainer = %ProfilePanel
@onready var _profile_title_label: Label = %ProfileTitleLabel
@onready var _profile_name_label: Label = %ProfileNameLabel
@onready var _profile_score_label: Label = %ProfileScoreLabel
@onready var _reset_profile_button: Button = %ResetProfileButton
@onready var _close_profile_button: Button = %CloseProfileButton
@onready var _element_icons: Array = [
	$ElementRow/FireCell/FireIcon,
	$ElementRow/IceCell/IceIcon,
	$ElementRow/EarthCell/EarthIcon,
	$ElementRow/HeartCell/HeartIcon,
	$ElementRow/ArmorCell/ArmorIcon,
	$ElementRow/GoldCell/GoldIcon,
]
@onready var _element_labels: Array = [
	$ElementRow/FireCell/FireLabel,
	$ElementRow/IceCell/IceLabel,
	$ElementRow/EarthCell/EarthLabel,
	$ElementRow/HeartCell/HeartLabel,
	$ElementRow/ArmorCell/ArmorLabel,
	$ElementRow/GoldCell/GoldLabel,
]
@onready var _stat_icons: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsIcon,
	$StatsPanel/StatsRow/MasteryStat/MasteryIcon,
	$StatsPanel/StatsRow/BestRunStat/BestRunIcon,
]
@onready var _stat_titles: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsText/RelicsTitle,
	$StatsPanel/StatsRow/MasteryStat/MasteryText/MasteryTitle,
	$StatsPanel/StatsRow/BestRunStat/BestRunText/BestRunTitle,
]
@onready var _stat_values: Array = [
	$StatsPanel/StatsRow/RelicsStat/RelicsText/RelicsValue,
	$StatsPanel/StatsRow/MasteryStat/MasteryText/MasteryValue,
	$StatsPanel/StatsRow/BestRunStat/BestRunText/BestRunValue,
]

var _model
var _view
var _controller

func _ready() -> void:
	_ensure_mvc()
	_controller.bind(self, _build_root_nodes(), _model, _view)
	_controller.ready()

func _process(delta: float) -> void:
	if _controller != null:
		_controller.process(delta)

func _on_viewport_size_changed() -> void:
	if _controller != null:
		_controller._on_viewport_size_changed()

func _on_start_fight_button_pressed() -> void:
	if _controller != null:
		_controller._on_start_fight_button_pressed()

func _on_collection_button_pressed() -> void:
	if _controller != null:
		_controller._on_collection_button_pressed()

func _on_profile_button_pressed() -> void:
	if _controller != null:
		_controller._on_profile_button_pressed()

func _on_close_profile_button_pressed() -> void:
	if _controller != null:
		_controller._on_close_profile_button_pressed()

func _on_reset_profile_button_pressed() -> void:
	if _controller != null:
		_controller._on_reset_profile_button_pressed()

func _on_generate_log_toggle_toggled(enabled: bool) -> void:
	if _controller != null:
		_controller._on_generate_log_toggle_toggled(enabled)

func _ensure_mvc() -> void:
	if _model == null:
		_model = MAIN_MENU_MODEL_SCRIPT.new()
	if _view == null:
		_view = MAIN_MENU_VIEW_SCRIPT.new()
	if _controller == null:
		_controller = MAIN_MENU_CONTROLLER_SCRIPT.new()

func _build_root_nodes() -> Dictionary:
	return {
		"background_texture": _background_texture,
		"overlay_tint": _overlay_tint,
		"outer_frame": _outer_frame,
		"outer_border_texture": _outer_border_texture,
		"logo_texture": _logo_texture,
		"menu_button_column": _menu_button_column,
		"start_run_button": _start_run_button,
		"generate_log_toggle": _generate_log_toggle,
		"continue_button": _continue_button,
		"collection_button": _collection_button,
		"settings_button": _settings_button,
		"quit_button": _quit_button,
		"element_row": _element_row,
		"stats_panel": _stats_panel,
		"stats_row": _stats_row,
		"footer_actions": _footer_actions,
		"profile_button": _profile_button,
		"achievements_button": _achievements_button,
		"footer_settings_button": _footer_settings_button,
		"version_label": _version_label,
		"status_label": _status_label,
		"profile_overlay": _profile_overlay,
		"profile_panel": _profile_panel,
		"profile_title_label": _profile_title_label,
		"profile_name_label": _profile_name_label,
		"profile_score_label": _profile_score_label,
		"reset_profile_button": _reset_profile_button,
		"close_profile_button": _close_profile_button,
		"element_icons": _element_icons,
		"element_labels": _element_labels,
		"stat_icons": _stat_icons,
		"stat_titles": _stat_titles,
		"stat_values": _stat_values,
	}
