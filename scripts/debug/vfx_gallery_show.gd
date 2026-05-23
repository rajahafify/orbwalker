extends Control
class_name VfxGalleryShow

const CATALOG_SCRIPT := preload("res://scripts/debug/vfx_debug_catalog.gd")
const COMBAT_VFX_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_vfx_presenter.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")
const INDEX_SCENE_PATH := "res://scenes/debug/vfx_gallery_index.tscn"

const ORB_ORDER: Array[int] = [
	OrbType.Id.FIRE,
	OrbType.Id.ICE,
	OrbType.Id.EARTH,
	OrbType.Id.HEART,
	OrbType.Id.ARMOR,
	OrbType.Id.GOLD,
]

var _entry_select: OptionButton
var _phase_select: OptionButton
var _amount_slider: HSlider
var _amount_spin: SpinBox
var _speed_slider: HSlider
var _loop_toggle: CheckBox
var _anchors_toggle: CheckBox
var _clean_toggle: CheckBox
var _play_button: Button
var _preset_row: HBoxContainer
var _status_label: Label
var _description_label: Label
var _preview_root: Control
var _vfx_layer: Control
var _anchor_layer: Control
var _enemy_target: Panel
var _board_target: Panel
var _hp_bar_target: ProgressBar
var _gold_target: Panel
var _mastery_cards: Control

var _visual_registry: VisualRegistry
var _presenter: CombatVfxPresenter
var _loadout_adapter: RefCounted
var _play_generation := 0
var _syncing_amount := false


class PreviewLoadoutHud:
	extends RefCounted

	func get_combat_mastery_card(row: Control, orb_id: int) -> Control:
		if row == null:
			return null
		return row.get_node_or_null("CombatMasteryCard%d" % orb_id) as Control


func _ready() -> void:
	name = "VfxGalleryShow"
	_visual_registry = VISUAL_REGISTRY_SCRIPT.new()
	_loadout_adapter = PreviewLoadoutHud.new()
	_build_ui()
	_populate_entry_dropdown(_initial_entry_id())
	await get_tree().process_frame
	_layout_preview()
	_restart_playback()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_preview()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.012, 0.016, 0.024, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)

	var margin := MarginContainer.new()
	margin.name = "PageMargin"
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	var page := VBoxContainer.new()
	page.name = "PageRoot"
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	page.add_child(_make_header())
	page.add_child(_make_control_panel())
	page.add_child(_make_preview_panel())


func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.name = "Header"
	row.custom_minimum_size = Vector2(0, 58)
	row.add_theme_constant_override("separation", 12)

	var back := Button.new()
	back.name = "BackButton"
	back.text = "< Index"
	back.custom_minimum_size = Vector2(132, 52)
	back.pressed.connect(_on_back_pressed)
	row.add_child(back)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "VFX Show Page"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72, 1.0))
	row.add_child(title)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = "Ready"
	_status_label.custom_minimum_size = Vector2(270, 52)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT as HorizontalAlignment
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	_status_label.add_theme_font_size_override("font_size", 18)
	_status_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.92, 1.0))
	row.add_child(_status_label)

	return row


func _make_control_panel() -> Control:
	var panel := PanelContainer.new()
	panel.name = "ControlPanel"
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.047, 0.067, 0.95), Color(0.33, 0.43, 0.56, 0.9), 2))

	var box := VBoxContainer.new()
	box.name = "ControlBox"
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var first_row := HBoxContainer.new()
	first_row.name = "SelectorRow"
	first_row.add_theme_constant_override("separation", 10)
	box.add_child(first_row)

	_entry_select = OptionButton.new()
	_entry_select.name = "EntrySelect"
	_entry_select.custom_minimum_size = Vector2(330, 48)
	_entry_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_entry_select.item_selected.connect(_on_entry_selected)
	first_row.add_child(_entry_select)

	_phase_select = OptionButton.new()
	_phase_select.name = "PhaseSelect"
	_phase_select.custom_minimum_size = Vector2(210, 48)
	_phase_select.item_selected.connect(_on_phase_selected)
	first_row.add_child(_phase_select)

	_play_button = Button.new()
	_play_button.name = "PlayButton"
	_play_button.text = "Play"
	_play_button.custom_minimum_size = Vector2(112, 48)
	_play_button.pressed.connect(_restart_playback)
	first_row.add_child(_play_button)

	var second_row := HBoxContainer.new()
	second_row.name = "AmountRow"
	second_row.add_theme_constant_override("separation", 10)
	box.add_child(second_row)

	second_row.add_child(_make_small_label("Amount"))
	_amount_slider = HSlider.new()
	_amount_slider.name = "AmountSlider"
	_amount_slider.min_value = 1.0
	_amount_slider.max_value = 60.0
	_amount_slider.step = 1.0
	_amount_slider.value = 12.0
	_amount_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_amount_slider.value_changed.connect(_on_amount_slider_changed)
	second_row.add_child(_amount_slider)

	_amount_spin = SpinBox.new()
	_amount_spin.name = "AmountSpin"
	_amount_spin.min_value = 1.0
	_amount_spin.max_value = 60.0
	_amount_spin.step = 1.0
	_amount_spin.value = 12.0
	_amount_spin.custom_minimum_size = Vector2(104, 48)
	_amount_spin.value_changed.connect(_on_amount_spin_changed)
	second_row.add_child(_amount_spin)

	second_row.add_child(_make_small_label("Speed"))
	_speed_slider = HSlider.new()
	_speed_slider.name = "SpeedSlider"
	_speed_slider.min_value = 0.35
	_speed_slider.max_value = 1.25
	_speed_slider.step = 0.05
	_speed_slider.value = 0.55
	_speed_slider.custom_minimum_size = Vector2(170, 40)
	_speed_slider.value_changed.connect(_on_speed_changed)
	second_row.add_child(_speed_slider)

	var third_row := HBoxContainer.new()
	third_row.name = "PresetRow"
	third_row.add_theme_constant_override("separation", 10)
	box.add_child(third_row)

	_preset_row = HBoxContainer.new()
	_preset_row.name = "AmountPresets"
	_preset_row.add_theme_constant_override("separation", 8)
	_preset_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	third_row.add_child(_preset_row)

	_loop_toggle = CheckBox.new()
	_loop_toggle.name = "LoopToggle"
	_loop_toggle.text = "Loop"
	_loop_toggle.toggled.connect(_on_loop_toggled)
	third_row.add_child(_loop_toggle)

	_anchors_toggle = CheckBox.new()
	_anchors_toggle.name = "AnchorsToggle"
	_anchors_toggle.text = "Anchors"
	_anchors_toggle.button_pressed = true
	_anchors_toggle.toggled.connect(_on_anchor_toggle_changed)
	third_row.add_child(_anchors_toggle)

	_clean_toggle = CheckBox.new()
	_clean_toggle.name = "CleanToggle"
	_clean_toggle.text = "Clean"
	_clean_toggle.toggled.connect(_on_clean_toggle_changed)
	third_row.add_child(_clean_toggle)

	_description_label = Label.new()
	_description_label.name = "DescriptionLabel"
	_description_label.text = ""
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	_description_label.add_theme_font_size_override("font_size", 17)
	_description_label.add_theme_color_override("font_color", Color(0.68, 0.74, 0.82, 1.0))
	box.add_child(_description_label)

	return panel


func _make_preview_panel() -> Control:
	var frame := PanelContainer.new()
	frame.name = "PreviewFrame"
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", _panel_style(Color(0.0, 0.0, 0.0, 0.96), Color(0.78, 0.60, 0.24, 0.95), 2))

	_preview_root = Control.new()
	_preview_root.name = "PreviewRoot"
	_preview_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_preview_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_preview_root.clip_contents = true
	frame.add_child(_preview_root)

	_build_preview_contents()
	return frame


func _build_preview_contents() -> void:
	var backdrop := ColorRect.new()
	backdrop.name = "PreviewBackdrop"
	backdrop.color = Color(0.015, 0.019, 0.026, 1.0)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	backdrop.anchor_right = 1.0
	backdrop.anchor_bottom = 1.0
	_preview_root.add_child(backdrop)

	_enemy_target = Panel.new()
	_enemy_target.name = "EnemyTarget"
	_enemy_target.add_theme_stylebox_override("panel", _panel_style(Color(0.08, 0.065, 0.05, 0.95), Color(0.86, 0.54, 0.28, 0.7), 2))
	_preview_root.add_child(_enemy_target)
	_enemy_target.add_child(_make_anchor_caption("ENEMY TARGET"))

	_board_target = Panel.new()
	_board_target.name = "BoardTarget"
	_board_target.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.03, 0.04, 0.95), Color(0.82, 0.63, 0.26, 0.9), 3))
	_preview_root.add_child(_board_target)
	_build_board_cells()

	_mastery_cards = Control.new()
	_mastery_cards.name = "ElementalMasteryCards"
	_preview_root.add_child(_mastery_cards)
	_build_mastery_cards()

	var hp_panel := Panel.new()
	hp_panel.name = "HpBarTargetPanel"
	hp_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.045, 0.06, 0.92), Color(0.45, 0.58, 0.76, 0.75), 2))
	_preview_root.add_child(hp_panel)

	_hp_bar_target = ProgressBar.new()
	_hp_bar_target.name = "HpBarTarget"
	_hp_bar_target.show_percentage = false
	_hp_bar_target.max_value = 100.0
	_hp_bar_target.value = 74.0
	hp_panel.add_child(_hp_bar_target)

	var hp_label := Label.new()
	hp_label.name = "HpLabel"
	hp_label.text = "HP BAR TARGET"
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	hp_label.add_theme_font_size_override("font_size", 18)
	hp_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.92, 1.0))
	hp_panel.add_child(hp_label)

	_gold_target = Panel.new()
	_gold_target.name = "GoldTarget"
	_gold_target.add_theme_stylebox_override("panel", _panel_style(Color(0.12, 0.08, 0.02, 0.92), Color(1.0, 0.72, 0.18, 0.8), 2))
	_preview_root.add_child(_gold_target)
	_gold_target.add_child(_make_anchor_caption("GOLD TARGET"))

	_anchor_layer = Control.new()
	_anchor_layer.name = "AnchorLayer"
	_anchor_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_anchor_layer.anchor_right = 1.0
	_anchor_layer.anchor_bottom = 1.0
	_preview_root.add_child(_anchor_layer)

	_vfx_layer = Control.new()
	_vfx_layer.name = "VfxLayer"
	_vfx_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_vfx_layer.anchor_right = 1.0
	_vfx_layer.anchor_bottom = 1.0
	_vfx_layer.z_index = 100
	_preview_root.add_child(_vfx_layer)


func _build_board_cells() -> void:
	for index in range(30):
		var orb_id: int = ORB_ORDER[index % ORB_ORDER.size()]
		var cell := TextureRect.new()
		cell.name = "BoardOrb%d" % index
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		cell.texture = _visual_registry.orb_texture(orb_id)
		cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		cell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		cell.modulate = Color(1.0, 1.0, 1.0, 0.54)
		_board_target.add_child(cell)


func _build_mastery_cards() -> void:
	for orb_id in ORB_ORDER:
		var card := Control.new()
		card.name = "CombatMasteryCard%d" % orb_id
		card.clip_contents = true
		_mastery_cards.add_child(card)

		var panel := Panel.new()
		panel.name = "CardPanel"
		panel.add_theme_stylebox_override("panel", _panel_style(Color(0.025, 0.035, 0.045, 0.92), OrbType.color(orb_id), 2, 4))
		card.add_child(panel)

		var icon := TextureRect.new()
		icon.name = "MasteryIcon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
		icon.texture = _visual_registry.menu_mastery_icon(orb_id)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE as TextureRect.ExpandMode
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED as TextureRect.StretchMode
		panel.add_child(icon)


func _layout_preview() -> void:
	if _preview_root == null:
		return
	var size := _preview_root.size
	if size.x <= 2.0 or size.y <= 2.0:
		size = get_viewport_rect().size
	_preview_root.custom_minimum_size = Vector2(0, 720)
	_vfx_layer.position = Vector2.ZERO
	_vfx_layer.size = size
	if _anchor_layer != null:
		_anchor_layer.position = Vector2.ZERO
		_anchor_layer.size = size

	var margin_x := maxf(18.0, size.x * 0.035)
	var enemy_h := clampf(size.y * 0.21, 150.0, 250.0)
	_enemy_target.position = Vector2(margin_x, 18.0)
	_enemy_target.size = Vector2(size.x - margin_x * 2.0, enemy_h)
	_layout_child_fill(_enemy_target)

	var board_size := minf(size.x * 0.64, size.y * 0.42)
	board_size = clampf(board_size, 300.0, 560.0)
	_board_target.position = Vector2((size.x - board_size) * 0.5, enemy_h + 54.0)
	_board_target.size = Vector2(board_size, board_size)
	_layout_board_cells()

	var mastery_h := 82.0
	_mastery_cards.position = Vector2(margin_x, size.y - mastery_h - 118.0)
	_mastery_cards.size = Vector2(size.x - margin_x * 2.0, mastery_h)
	_layout_mastery_cards()

	var hp_panel := _hp_bar_target.get_parent() as Control
	if hp_panel != null:
		hp_panel.position = Vector2(margin_x + size.x * 0.14, size.y - 100.0)
		hp_panel.size = Vector2(size.x - margin_x * 2.0 - size.x * 0.24, 62.0)
		_hp_bar_target.position = Vector2(18.0, 16.0)
		_hp_bar_target.size = Vector2(hp_panel.size.x - 36.0, 30.0)
		var hp_label := hp_panel.get_node_or_null("HpLabel") as Label
		if hp_label != null:
			hp_label.position = Vector2.ZERO
			hp_label.size = hp_panel.size

	_gold_target.position = Vector2(size.x - margin_x - 150.0, size.y - 100.0)
	_gold_target.size = Vector2(150.0, 62.0)
	_layout_child_fill(_gold_target)


func _layout_board_cells() -> void:
	if _board_target == null:
		return
	var columns := 5
	var rows := 6
	var gap := 4.0
	var cell_size := Vector2(
		(_board_target.size.x - gap * float(columns + 1)) / float(columns),
		(_board_target.size.y - gap * float(rows + 1)) / float(rows)
	)
	for index in range(_board_target.get_child_count()):
		var child := _board_target.get_child(index) as Control
		if child == null:
			continue
		var column := index % columns
		var row := int(index / columns)
		child.position = Vector2(gap + float(column) * (cell_size.x + gap), gap + float(row) * (cell_size.y + gap))
		child.size = cell_size


func _layout_mastery_cards() -> void:
	if _mastery_cards == null:
		return
	var count := maxi(1, _mastery_cards.get_child_count())
	var gap := 8.0
	var card_w := (_mastery_cards.size.x - gap * float(count - 1)) / float(count)
	var card_size := Vector2(card_w, _mastery_cards.size.y)
	for index in range(count):
		var card := _mastery_cards.get_child(index) as Control
		if card == null:
			continue
		card.position = Vector2(float(index) * (card_w + gap), 0.0)
		card.size = card_size
		var panel := card.get_node_or_null("CardPanel") as Control
		if panel != null:
			panel.position = Vector2.ZERO
			panel.size = card_size
			var icon := panel.get_node_or_null("MasteryIcon") as TextureRect
			if icon != null:
				var icon_size := minf(card_size.x, card_size.y) * 0.72
				icon.position = (card_size - Vector2(icon_size, icon_size)) * 0.5
				icon.size = Vector2(icon_size, icon_size)


func _layout_child_fill(parent: Control) -> void:
	for child in parent.get_children():
		if child is Control:
			var control := child as Control
			control.position = Vector2.ZERO
			control.size = parent.size


func _populate_entry_dropdown(selected_id: String) -> void:
	_entry_select.clear()
	var selected_index := 0
	var index := 0
	for entry in CATALOG_SCRIPT.entries():
		_entry_select.add_item(String(entry.get("name", "VFX")))
		_entry_select.set_item_metadata(index, String(entry.get("id", "")))
		if String(entry.get("id", "")) == selected_id:
			selected_index = index
		index += 1
	_entry_select.select(selected_index)
	_sync_entry_controls()


func _sync_entry_controls() -> void:
	var entry := _selected_entry()
	if entry.is_empty():
		return
	_description_label.text = "%s Target: %s." % [
		String(entry.get("description", "")),
		CATALOG_SCRIPT.target_name(String(entry.get("target", ""))),
	]
	_populate_phase_dropdown(entry)
	_populate_amount_presets(entry)
	_set_amount(float(entry.get("default_amount", 12)))
	_status_label.text = String(entry.get("name", "VFX"))


func _populate_phase_dropdown(entry: Dictionary) -> void:
	var current_phase := _selected_phase()
	_phase_select.clear()
	var phases := CATALOG_SCRIPT.phases_for_entry(entry)
	var selected_index := 0
	for index in range(phases.size()):
		var phase: Dictionary = phases[index]
		_phase_select.add_item(String(phase.get("name", "Phase")))
		_phase_select.set_item_metadata(index, String(phase.get("id", CATALOG_SCRIPT.PHASE_FULL)))
		if String(phase.get("id", "")) == current_phase:
			selected_index = index
	_phase_select.select(selected_index)


func _populate_amount_presets(entry: Dictionary) -> void:
	_clear_children(_preset_row)
	_preset_row.add_child(_make_small_label("Presets"))
	var presets: Array = entry.get("amount_presets", [])
	for raw_amount in presets:
		var amount := int(raw_amount)
		var button := Button.new()
		button.name = "Preset%d" % amount
		button.text = str(amount)
		button.custom_minimum_size = Vector2(62, 42)
		button.pressed.connect(_on_amount_preset_pressed.bind(amount))
		_preset_row.add_child(button)


func _selected_entry() -> Dictionary:
	if _entry_select == null or _entry_select.item_count <= 0:
		return {}
	var entry_id := String(_entry_select.get_item_metadata(_entry_select.selected))
	return CATALOG_SCRIPT.entry_by_id(entry_id)


func _selected_phase() -> String:
	if _phase_select == null or _phase_select.item_count <= 0:
		return CATALOG_SCRIPT.PHASE_FULL
	return String(_phase_select.get_item_metadata(_phase_select.selected))


func _selected_amount() -> int:
	if _amount_spin == null:
		return 12
	return int(round(_amount_spin.value))


func _restart_playback() -> void:
	_play_generation += 1
	_play_loop(_play_generation)


func _play_loop(generation: int) -> void:
	while generation == _play_generation:
		await _play_once(generation)
		if generation != _play_generation or not _loop_toggle.button_pressed:
			return
		var still_current := await _wait_seconds(0.38, generation)
		if not still_current:
			return


func _play_once(generation: int) -> void:
	var entry := _selected_entry()
	if entry.is_empty():
		return
	_clear_vfx()
	await get_tree().process_frame
	if generation != _play_generation:
		return
	_bind_presenter()
	var phase := _selected_phase()
	var amount := _selected_amount()
	var entry_point := String(entry.get("entry_point", ""))
	match entry_point:
		CATALOG_SCRIPT.ENTRY_POINT_MASTERY_SEQUENCE:
			await _play_elemental_sequence(entry, phase, amount, generation)
		CATALOG_SCRIPT.ENTRY_POINT_MASTERY_RESULT:
			await _play_mastery_result(entry, phase, amount, generation)
		CATALOG_SCRIPT.ENTRY_POINT_IMPACT:
			await _play_impact_result(entry, phase, amount, generation)
		CATALOG_SCRIPT.ENTRY_POINT_ARMOR_LINGER:
			await _play_armor_linger(entry, phase, amount, generation)
		CATALOG_SCRIPT.ENTRY_POINT_ENEMY_ATTACK:
			await _play_enemy_attack(entry, phase, amount, generation)
		CATALOG_SCRIPT.ENTRY_POINT_GENERIC_VFX:
			await _play_generic_vfx(entry, phase, amount, generation)


func _play_elemental_sequence(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	var target := _target_global_center(String(entry.get("target", CATALOG_SCRIPT.TARGET_ENEMY)))
	var orb_id := int(entry.get("orb_id", OrbType.Id.FIRE))
	var kind := String(entry.get("kind", "fire"))
	var spool := 1.12
	var travel := 1.05
	match phase:
		CATALOG_SCRIPT.PHASE_SPOOL:
			_presenter.spawn_mastery_cast_sequence(orb_id, target, 1.45, 0.06, amount)
			await _wait_seconds(1.70, generation)
		CATALOG_SCRIPT.PHASE_TRAVEL:
			_presenter.spawn_mastery_cast_sequence(orb_id, target, 0.06, 1.45, amount)
			await _wait_seconds(1.70, generation)
		CATALOG_SCRIPT.PHASE_CAST_TRAVEL:
			_presenter.spawn_mastery_cast_sequence(orb_id, target, spool, travel, amount)
			await _wait_seconds(spool + travel + 0.28, generation)
		CATALOG_SCRIPT.PHASE_IMPACT:
			_spawn_impact(entry, amount)
			await _wait_seconds(1.55, generation)
		CATALOG_SCRIPT.PHASE_LABEL:
			_spawn_label(entry, amount)
			await _wait_seconds(1.20, generation)
		_:
			_presenter.spawn_mastery_cast_sequence(orb_id, target, spool, travel, amount)
			var still_current := await _wait_seconds(spool + travel, generation)
			if not still_current:
				return
			_spawn_impact(entry, amount)
			_spawn_label(entry, amount)
			_status_label.text = "%s | %s %d" % [String(entry.get("name", "VFX")), kind, amount]
			await _wait_seconds(1.65, generation)


func _play_mastery_result(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	var target := _target_global_center(String(entry.get("target", CATALOG_SCRIPT.TARGET_HP_BAR)))
	var orb_id := int(entry.get("orb_id", OrbType.Id.HEART))
	match phase:
		CATALOG_SCRIPT.PHASE_CAST_TRAVEL:
			_presenter.spawn_mastery_beam(orb_id, target, 1.10)
		CATALOG_SCRIPT.PHASE_IMPACT:
			_spawn_impact(entry, amount)
		CATALOG_SCRIPT.PHASE_LABEL:
			_spawn_label(entry, amount)
		_:
			_spawn_impact(entry, amount)
			if String(entry.get("kind", "")) == "armor":
				_presenter.spawn_armor_bar_linger(target, Vector2(240, 78), 1.20, amount)
			_presenter.spawn_mastery_beam(orb_id, target, 1.10)
			_spawn_label(entry, amount)
	await _wait_seconds(1.70, generation)


func _play_impact_result(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	if phase == CATALOG_SCRIPT.PHASE_LABEL:
		_spawn_label(entry, amount)
	else:
		_spawn_impact(entry, amount)
		if phase == CATALOG_SCRIPT.PHASE_FULL:
			_spawn_label(entry, amount)
	await _wait_seconds(1.55, generation)


func _play_armor_linger(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	var target := _target_global_center(String(entry.get("target", CATALOG_SCRIPT.TARGET_HP_BAR)))
	if phase == CATALOG_SCRIPT.PHASE_LABEL:
		_spawn_label(entry, amount)
	else:
		_presenter.spawn_armor_bar_linger(target, Vector2(260, 82), 1.55, amount)
		if phase == CATALOG_SCRIPT.PHASE_FULL:
			_spawn_label(entry, amount)
	await _wait_seconds(1.90, generation)


func _play_enemy_attack(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	var source := _target_global_center(CATALOG_SCRIPT.TARGET_ENEMY)
	var target := _target_global_center(CATALOG_SCRIPT.TARGET_HP_BAR)
	match phase:
		CATALOG_SCRIPT.PHASE_CAST_TRAVEL:
			_presenter.spawn_enemy_attack_cue(source, 0.42)
			var still_current := await _wait_seconds(0.24, generation)
			if not still_current:
				return
			_presenter.spawn_enemy_attack_travel(source, target, 0.76)
		CATALOG_SCRIPT.PHASE_IMPACT:
			_presenter.spawn_enemy_attack_impact(target, false, amount, 1.05)
		CATALOG_SCRIPT.PHASE_LABEL:
			_spawn_label(entry, amount)
		_:
			_presenter.spawn_enemy_attack_cue(source, 0.42)
			var current := await _wait_seconds(0.24, generation)
			if not current:
				return
			_presenter.spawn_enemy_attack_travel(source, target, 0.76)
			current = await _wait_seconds(0.68, generation)
			if not current:
				return
			_presenter.spawn_enemy_attack_impact(target, false, amount, 1.05)
			_spawn_label(entry, amount)
	await _wait_seconds(1.35, generation)


func _play_generic_vfx(entry: Dictionary, phase: String, amount: int, generation: int) -> void:
	if phase == CATALOG_SCRIPT.PHASE_LABEL:
		_spawn_label(entry, amount)
	else:
		var target := _target_global_center(String(entry.get("target", CATALOG_SCRIPT.TARGET_BOARD)))
		_presenter.spawn_vfx(String(entry.get("effect_name", "orb_clear")), target, Vector2(126, 126), 1.0, Color(1.0, 1.0, 1.0, 0.95))
		if phase == CATALOG_SCRIPT.PHASE_FULL:
			_spawn_label(entry, amount)
	await _wait_seconds(1.35, generation)


func _spawn_impact(entry: Dictionary, amount: int) -> void:
	var target_id := String(entry.get("target", CATALOG_SCRIPT.TARGET_ENEMY))
	var target := _target_global_center(target_id)
	var kind := String(entry.get("kind", "damage"))
	_presenter.spawn_replay_impact(target, kind, _draw_size_for_entry(entry, amount), 0.85, amount)


func _spawn_label(entry: Dictionary, amount: int) -> void:
	var target_id := String(entry.get("target", CATALOG_SCRIPT.TARGET_ENEMY))
	var target := _target_global_center(target_id)
	var offset := Vector2(0, -54)
	if target_id == CATALOG_SCRIPT.TARGET_GOLD:
		offset = Vector2(0, -42)
	elif target_id == CATALOG_SCRIPT.TARGET_BOARD:
		offset = Vector2(0, 0)
	_presenter.spawn_result_label(
		CATALOG_SCRIPT.result_label_text(entry, amount),
		target,
		CATALOG_SCRIPT.label_kind(entry),
		1.15,
		offset,
		amount
	)


func _bind_presenter() -> void:
	_presenter = COMBAT_VFX_PRESENTER_SCRIPT.new()
	_presenter.bind({
		"vfx_layer": _vfx_layer,
		"visual_registry": _visual_registry,
		"player_loadout_hud": _loadout_adapter,
		"elemental_mastery_cards": _mastery_cards,
		"timer_owner": self,
	})
	_presenter.set_post_match_vfx_speed_scale(float(_speed_slider.value))


func _clear_vfx() -> void:
	if _vfx_layer == null:
		return
	for child in _vfx_layer.get_children():
		child.queue_free()
	_presenter = null


func _target_global_center(target_id: String) -> Vector2:
	match target_id:
		CATALOG_SCRIPT.TARGET_ENEMY:
			return _enemy_target.get_global_rect().get_center()
		CATALOG_SCRIPT.TARGET_BOARD:
			return _board_target.get_global_rect().get_center()
		CATALOG_SCRIPT.TARGET_HP_BAR:
			return _hp_bar_target.get_global_rect().get_center()
		CATALOG_SCRIPT.TARGET_GOLD:
			return _gold_target.get_global_rect().get_center()
	return _preview_root.get_global_rect().get_center()


func _draw_size_for_target(target_id: String) -> Vector2:
	match target_id:
		CATALOG_SCRIPT.TARGET_HP_BAR:
			return Vector2(240, 78)
		CATALOG_SCRIPT.TARGET_GOLD:
			return Vector2(130, 96)
		CATALOG_SCRIPT.TARGET_BOARD:
			return Vector2(128, 128)
	return Vector2(104, 104)


func _draw_size_for_entry(entry: Dictionary, amount: int) -> Vector2:
	var target_id := String(entry.get("target", CATALOG_SCRIPT.TARGET_ENEMY))
	var kind := String(entry.get("kind", "damage"))
	if target_id == CATALOG_SCRIPT.TARGET_ENEMY and kind == "fire" and _enemy_target != null:
		if _presenter == null or not _presenter.replay_result_is_screen_wide(kind, amount):
			return _draw_size_for_target(target_id)
		var enemy_size := _enemy_target.get_global_rect().size
		if enemy_size.x > 1.0 and enemy_size.y > 1.0:
			var scale := 1.0
			scale = maxf(1.0, _presenter.result_vfx_size_scale(kind, amount))
			return Vector2(
				maxf(104.0, enemy_size.x / scale),
				maxf(104.0, enemy_size.y / scale)
			)
	return _draw_size_for_target(target_id)


func _wait_seconds(seconds: float, generation: int) -> bool:
	var tree := get_tree()
	if tree == null:
		return false
	await tree.create_timer(maxf(0.01, seconds)).timeout
	return generation == _play_generation


func _on_entry_selected(_index: int) -> void:
	_sync_entry_controls()
	_restart_playback()


func _on_phase_selected(_index: int) -> void:
	_restart_playback()


func _on_amount_slider_changed(value: float) -> void:
	if _syncing_amount:
		return
	_set_amount(value)


func _on_amount_spin_changed(value: float) -> void:
	if _syncing_amount:
		return
	_set_amount(value)


func _on_amount_preset_pressed(amount: int) -> void:
	_set_amount(float(amount))
	_restart_playback()


func _on_speed_changed(_value: float) -> void:
	_restart_playback()


func _on_loop_toggled(_enabled: bool) -> void:
	_restart_playback()


func _on_anchor_toggle_changed(enabled: bool) -> void:
	if _anchor_layer != null:
		_anchor_layer.visible = enabled


func _on_clean_toggle_changed(enabled: bool) -> void:
	_description_label.visible = not enabled
	_anchors_toggle.button_pressed = false if enabled else _anchors_toggle.button_pressed
	if _anchor_layer != null:
		_anchor_layer.visible = not enabled and _anchors_toggle.button_pressed


func _on_back_pressed() -> void:
	var tree := get_tree()
	if tree == null:
		return
	tree.change_scene_to_file(INDEX_SCENE_PATH)


func _set_amount(value: float) -> void:
	_syncing_amount = true
	var clamped := clampf(roundf(value), _amount_slider.min_value, _amount_slider.max_value)
	_amount_slider.value = clamped
	_amount_spin.value = clamped
	_syncing_amount = false


func _initial_entry_id() -> String:
	var tree := get_tree()
	if tree != null and tree.has_meta("vfx_gallery_entry_id"):
		var entry_id := String(tree.get_meta("vfx_gallery_entry_id"))
		if not CATALOG_SCRIPT.entry_by_id(entry_id).is_empty():
			return entry_id
	return CATALOG_SCRIPT.default_entry_id()


func _make_small_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(0, 42)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86, 1.0))
	return label


func _make_anchor_caption(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER as HorizontalAlignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.86, 0.90, 0.96, 0.92))
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.88))
	label.add_theme_constant_override("outline_size", 4)
	return label


func _panel_style(bg: Color, border: Color, border_width: int = 2, radius: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
