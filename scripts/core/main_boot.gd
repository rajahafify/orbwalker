extends Control

const DESIGN_SIZE := Vector2(1080.0, 1920.0)
const MENU_ASSET_MAP_PATH := "res://resources/visual/first_pass_asset_map.json"

const FALLBACK_BG_PATH := "res://resources/art/first_pass/menu/main_menu_bg_orbwalker_cavern_city_v1.png"
const FALLBACK_LOGO_PATH := "res://resources/art/first_pass/menu/main_menu_logo_orbwalker_v1_alpha.png"

const ELEMENT_ICON_PATHS: Array[String] = [
	"res://resources/art/first_pass/derived/icons/mastery_fire.png",
	"res://resources/art/first_pass/derived/icons/mastery_ice.png",
	"res://resources/art/first_pass/derived/icons/mastery_earth.png",
	"res://resources/art/first_pass/derived/icons/mastery_heart.png",
	"res://resources/art/first_pass/derived/icons/mastery_armor.png",
	"res://resources/art/first_pass/derived/icons/mastery_gold.png",
]

const STAT_ICON_PATHS: Array[String] = [
	"res://resources/art/first_pass/derived/icons/relic_golden_idol.png",
	"res://resources/art/first_pass/derived/icons/relic_merchant_compass.png",
	"res://resources/art/first_pass/derived/icons/relic_crown_of_chains.png",
]

const FOOTER_ICON_PATHS: Array[String] = [
	"res://resources/art/first_pass/derived/icons/equipment_iron_helm.png",
	"res://resources/art/first_pass/derived/icons/equipment_royal_seal.png",
	"res://resources/art/first_pass/derived/icons/equipment_training_manual.png",
]

@onready var _background_texture: TextureRect = %BackgroundTexture
@onready var _overlay_tint: ColorRect = $OverlayTint
@onready var _outer_frame: Control = %OuterFrame
@onready var _outer_border: Panel = $OuterFrame/OuterBorder
@onready var _inner_border: Panel = $OuterFrame/InnerBorder
@onready var _logo_texture: TextureRect = %LogoTexture
@onready var _menu_button_column: VBoxContainer = %MenuButtonColumn
@onready var _start_run_button: Button = %StartRunButton
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
@onready var _debug_button: Button = %DebugCombatButton
@onready var _version_label: Label = %VersionLabel
@onready var _status_label: Label = %StatusLabel

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

var _asset_map: Dictionary = {}


func _ready() -> void:
	_configure_ui_nodes()
	_asset_map = _load_asset_map()
	_load_textures()
	_apply_static_text()
	_apply_chrome_styles()
	_layout_ui()
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)


func _on_viewport_size_changed() -> void:
	_layout_ui()


func _on_start_fight_button_pressed() -> void:
	RunState.start_new_run()
	get_tree().change_scene_to_file(RunState.next_scene_path())


func _on_debug_fight_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/combat/board_debug.tscn")


func _configure_ui_nodes() -> void:
	# Prevent source texture dimensions from forcing container minimum sizes.
	_logo_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_logo_texture.custom_minimum_size = Vector2.ZERO

	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.custom_minimum_size = Vector2.ZERO

	for icon_node in _stat_icons:
		var stat_icon := icon_node as TextureRect
		if stat_icon != null:
			stat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			stat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			stat_icon.custom_minimum_size = Vector2.ZERO

	for container in [_menu_button_column, _element_row, _stats_row, _footer_actions]:
		container.custom_minimum_size = Vector2.ZERO

	clip_contents = true
	_element_row.clip_contents = true
	_stats_panel.clip_contents = true
	_footer_actions.clip_contents = true


func _load_textures() -> void:
	_background_texture.texture = _safe_load_texture(_resolve_background_path(), "main_menu_background")
	_logo_texture.texture = _safe_load_texture(_resolve_logo_path(), "main_menu_logo")

	for i in _element_icons.size():
		_element_icons[i].texture = _safe_load_texture(ELEMENT_ICON_PATHS[i], "element_%d" % i)

	for i in _stat_icons.size():
		_stat_icons[i].texture = _safe_load_texture(STAT_ICON_PATHS[i], "stat_%d" % i)

	var footer_buttons := [_profile_button, _achievements_button, _footer_settings_button]
	for i in footer_buttons.size():
		var icon := _safe_load_texture(FOOTER_ICON_PATHS[i], "footer_%d" % i)
		if icon != null:
			footer_buttons[i].icon = _scaled_texture(icon, 70)


func _apply_static_text() -> void:
	_status_label.text = "Start Run and Debug Combat are active. Other buttons are placeholders."
	_status_label.visible = false
	_continue_button.disabled = true
	_collection_button.disabled = true
	_settings_button.disabled = true
	_quit_button.disabled = true
	_profile_button.disabled = true
	_achievements_button.disabled = true
	_footer_settings_button.disabled = true


func _apply_chrome_styles() -> void:
	_outer_border.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.0, 0.0, 0.0, 0.0), Color(0.78, 0.62, 0.31, 0.95), 2, 0)
	)
	_inner_border.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.0, 0.0, 0.0, 0.0), Color(0.75, 0.58, 0.25, 0.75), 1, 0)
	)
	_stats_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(Color(0.03, 0.08, 0.14, 0.90), Color(0.63, 0.49, 0.23, 0.94), 2, 8)
	)

	_apply_menu_button_style(_start_run_button, true, false)
	_apply_menu_button_style(_continue_button, false, true)
	_apply_menu_button_style(_collection_button, false, true)
	_apply_menu_button_style(_settings_button, false, true)
	_apply_menu_button_style(_quit_button, false, true)
	_apply_footer_button_style(_profile_button)
	_apply_footer_button_style(_achievements_button)
	_apply_footer_button_style(_footer_settings_button)
	_apply_debug_button_style(_debug_button)

	_set_label_color(_version_label, Color(0.78, 0.63, 0.35, 0.95))
	_set_label_color(_status_label, Color(0.81, 0.83, 0.87, 0.88))
	for label_node in _element_labels:
		var label := label_node as Label
		if label != null:
			_set_label_color(label, Color(0.83, 0.73, 0.49, 0.96))
	for title_node in _stat_titles:
		var title := title_node as Label
		if title != null:
			_set_label_color(title, Color(0.86, 0.75, 0.51, 0.96))
	for value_node in _stat_values:
		var value := value_node as Label
		if value != null:
			_set_label_color(value, Color(0.96, 0.89, 0.74, 0.99))


func _layout_ui() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var safe_rect := _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (40.0 / DESIGN_SIZE.x))

	_set_control_rect(_background_texture, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_overlay_tint, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_frame, Rect2(Vector2.ZERO, viewport_size))
	_set_control_rect(_outer_border, _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (14.0 / DESIGN_SIZE.x)))
	_set_control_rect(_inner_border, _inset_rect(Rect2(Vector2.ZERO, viewport_size), viewport_size.x * (26.0 / DESIGN_SIZE.x)))

	_set_control_rect(_logo_texture, _rect_from_percent_in_rect(safe_rect, 0.02, 0.015, 0.96, 0.16))
	_set_control_rect(_menu_button_column, _rect_from_percent_in_rect(safe_rect, 0.36, 0.22, 0.60, 0.31))
	_set_control_rect(_element_row, _rect_from_percent_in_rect(safe_rect, 0.04, 0.55, 0.92, 0.15))
	_set_control_rect(_stats_panel, _rect_from_percent_in_rect(safe_rect, 0.02, 0.71, 0.96, 0.14))
	_set_control_rect(_footer_actions, _rect_from_percent_in_rect(safe_rect, 0.02, 0.86, 0.96, 0.085))
	_set_control_rect(_debug_button, _rect_from_percent_in_rect(safe_rect, 0.02, 0.948, 0.30, 0.028))
	_set_control_rect(_version_label, _rect_from_percent_in_rect(safe_rect, 0.34, 0.95, 0.32, 0.022))
	_set_control_rect(_status_label, _rect_from_percent_in_rect(safe_rect, 0.04, 0.975, 0.92, 0.019))
	_set_control_rect(_stats_row, _inset_rect(Rect2(Vector2.ZERO, _stats_panel.size), viewport_size.x * (16.0 / DESIGN_SIZE.x)))

	var menu_button_min_height := int(round(viewport_size.y * 0.052))
	for button in [_start_run_button, _continue_button, _collection_button, _settings_button, _quit_button]:
		button.custom_minimum_size = Vector2(0.0, float(menu_button_min_height))

	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var element_icon_size := int(round(clampf(96.0 * scale_factor, 52.0, 108.0)))
	var element_cell_width := _element_row.size.x / 6.0
	if element_icon_size > int(round(element_cell_width * 0.75)):
		element_icon_size = int(round(element_cell_width * 0.75))
	for icon_node in _element_icons:
		var icon := icon_node as TextureRect
		if icon != null:
			icon.custom_minimum_size = Vector2(element_icon_size, element_icon_size)

	var stat_icon_size := int(round(clampf(84.0 * scale_factor, 48.0, 94.0)))
	for icon_node in _stat_icons:
		var stat_icon := icon_node as TextureRect
		if stat_icon != null:
			stat_icon.custom_minimum_size = Vector2(stat_icon_size, stat_icon_size)

	var footer_button_height := int(round(_footer_actions.size.y))
	var footer_icon_max_width := int(round(clampf(58.0 * scale_factor, 34.0, 66.0)))
	for button in [_profile_button, _achievements_button, _footer_settings_button]:
		button.custom_minimum_size = Vector2(0.0, float(footer_button_height))
		button.add_theme_constant_override("icon_max_width", footer_icon_max_width)
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.expand_icon = false

	_apply_font_sizes(viewport_size)


func _apply_font_sizes(viewport_size: Vector2) -> void:
	var scale_factor := minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var menu_size := maxi(16, int(round(34.0 * scale_factor)))
	var element_size := maxi(13, int(round(22.0 * scale_factor)))
	var stat_title_size := maxi(12, int(round(16.0 * scale_factor)))
	var stat_value_size := maxi(16, int(round(22.0 * scale_factor)))
	var footer_size := maxi(12, int(round(19.0 * scale_factor)))
	var version_size := maxi(11, int(round(17.0 * scale_factor)))
	var status_size := maxi(10, int(round(13.0 * scale_factor)))
	var debug_size := maxi(10, int(round(13.0 * scale_factor)))

	for button in [_start_run_button, _continue_button, _collection_button, _settings_button, _quit_button]:
		button.add_theme_font_size_override("font_size", menu_size)
	for label_node in _element_labels:
		var element_label := label_node as Label
		if element_label != null:
			element_label.add_theme_font_size_override("font_size", element_size)
	for title_node in _stat_titles:
		var stat_title := title_node as Label
		if stat_title != null:
			stat_title.add_theme_font_size_override("font_size", stat_title_size)
	for value_node in _stat_values:
		var stat_value := value_node as Label
		if stat_value != null:
			stat_value.add_theme_font_size_override("font_size", stat_value_size)
	for button in [_profile_button, _achievements_button, _footer_settings_button]:
		button.add_theme_font_size_override("font_size", footer_size)
	_version_label.add_theme_font_size_override("font_size", version_size)
	_status_label.add_theme_font_size_override("font_size", status_size)
	_debug_button.add_theme_font_size_override("font_size", debug_size)


func _apply_menu_button_style(button: Button, is_primary: bool, is_disabled: bool) -> void:
	var normal_fill := Color(0.05, 0.11, 0.19, 0.96)
	var normal_border := Color(0.61, 0.47, 0.21, 0.95)
	var hover_fill := Color(0.07, 0.15, 0.25, 0.98)
	var hover_border := Color(0.76, 0.58, 0.26, 0.98)

	if is_primary:
		normal_fill = Color(0.07, 0.17, 0.30, 0.98)
		normal_border = Color(0.88, 0.68, 0.33, 0.99)
		hover_fill = Color(0.10, 0.22, 0.36, 0.99)
		hover_border = Color(0.94, 0.74, 0.37, 1.0)

	button.add_theme_stylebox_override("normal", _make_panel_style(normal_fill, normal_border, 2, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_fill, hover_border, 2, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.04, 0.09, 0.15, 0.98), normal_border, 2, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(hover_fill, hover_border, 2, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(0.03, 0.07, 0.12, 0.82), Color(0.43, 0.33, 0.16, 0.70), 2, 10))
	if is_disabled:
		button.modulate = Color(1.0, 1.0, 1.0, 0.92)
	else:
		button.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _apply_footer_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.03, 0.07, 0.12, 0.90), Color(0.50, 0.38, 0.18, 0.85), 1, 10))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(0.03, 0.07, 0.12, 0.90), Color(0.50, 0.38, 0.18, 0.85), 1, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.05, 0.10, 0.16, 0.94), Color(0.62, 0.47, 0.22, 0.90), 1, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.02, 0.05, 0.10, 0.94), Color(0.46, 0.35, 0.16, 0.90), 1, 10))
	button.add_theme_stylebox_override("focus", _make_panel_style(Color(0.05, 0.10, 0.16, 0.94), Color(0.62, 0.47, 0.22, 0.90), 1, 10))


func _apply_debug_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.02, 0.05, 0.09, 0.84), Color(0.33, 0.39, 0.52, 0.85), 1, 7))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.04, 0.08, 0.14, 0.90), Color(0.42, 0.50, 0.66, 0.92), 1, 7))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.02, 0.04, 0.08, 0.92), Color(0.31, 0.37, 0.49, 0.95), 1, 7))
	button.add_theme_stylebox_override("focus", _make_panel_style(Color(0.04, 0.08, 0.14, 0.90), Color(0.42, 0.50, 0.66, 0.92), 1, 7))
	button.add_theme_color_override("font_color", Color(0.74, 0.83, 0.95, 0.92))


func _set_label_color(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)


func _make_panel_style(fill: Color, border: Color, border_width: int, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	return style


func _load_asset_map() -> Dictionary:
	if not FileAccess.file_exists(MENU_ASSET_MAP_PATH):
		return {}
	var file := FileAccess.open(MENU_ASSET_MAP_PATH, FileAccess.READ)
	if file == null:
		return {}
	var raw := file.get_as_text()
	var parsed: Variant = JSON.parse_string(raw)
	if parsed is Dictionary:
		return parsed
	return {}


func _resolve_background_path() -> String:
	var backgrounds: Dictionary = _asset_map.get("backgrounds", {})
	var menu: Dictionary = _asset_map.get("menu", {})
	if backgrounds.has("main_menu"):
		return String(backgrounds.get("main_menu", FALLBACK_BG_PATH))
	if menu.has("background"):
		return String(menu.get("background", FALLBACK_BG_PATH))
	return FALLBACK_BG_PATH


func _resolve_logo_path() -> String:
	var menu: Dictionary = _asset_map.get("menu", {})
	if menu.has("logo"):
		return String(menu.get("logo", FALLBACK_LOGO_PATH))
	return FALLBACK_LOGO_PATH


func _safe_load_texture(path: String, missing_key: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		push_warning("Main menu missing texture for %s at %s" % [missing_key, path])
		return null
	var loaded: Variant = load(path)
	if loaded is Texture2D:
		return loaded as Texture2D
	push_warning("Main menu invalid texture for %s at %s" % [missing_key, path])
	return null


func _scaled_texture(texture: Texture2D, max_side: int) -> Texture2D:
	var image := texture.get_image()
	if image == null:
		return texture
	var source_size := image.get_size()
	var largest_source_side := maxi(source_size.x, source_size.y)
	if largest_source_side <= max_side:
		return texture

	var ratio := float(max_side) / float(largest_source_side)
	var target_size := Vector2i(
		maxi(1, int(round(source_size.x * ratio))),
		maxi(1, int(round(source_size.y * ratio)))
	)
	image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)


func _rect_from_percent(viewport_size: Vector2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(
		Vector2(viewport_size.x * left, viewport_size.y * top),
		Vector2(viewport_size.x * width, viewport_size.y * height)
	)


func _rect_from_percent_in_rect(base_rect: Rect2, left: float, top: float, width: float, height: float) -> Rect2:
	return Rect2(
		base_rect.position + Vector2(base_rect.size.x * left, base_rect.size.y * top),
		Vector2(base_rect.size.x * width, base_rect.size.y * height)
	)


func _inset_rect(rect: Rect2, inset: float) -> Rect2:
	return Rect2(
		rect.position + Vector2(inset, inset),
		Vector2(maxf(0.0, rect.size.x - inset * 2.0), maxf(0.0, rect.size.y - inset * 2.0))
	)


func _set_control_rect(control: Control, rect: Rect2) -> void:
	control.anchor_left = 0.0
	control.anchor_top = 0.0
	control.anchor_right = 0.0
	control.anchor_bottom = 0.0
	control.position = rect.position
	control.size = rect.size
