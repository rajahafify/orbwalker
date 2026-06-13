extends Control
class_name VfxGalleryIndex

const CATALOG_SCRIPT := preload("res://scripts/debug/vfx_debug_catalog.gd")
const SHOW_SCENE_PATH := "res://scenes/debug/vfx_gallery_show.tscn"
const STATUS_LABEL_FONT_SIZE := 22
const ENTRY_BUTTON_FONT_SIZE := 22

var _content_root: VBoxContainer
var _status_label: Label


func _ready() -> void:
	name = "VfxGalleryIndex"
	_build_ui()
	_populate_entries()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and _content_root != null:
		_layout_content()


func _build_ui() -> void:
	anchor_right = 1.0
	anchor_bottom = 1.0

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.015, 0.02, 0.03, 1.0)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	add_child(background)

	var shell := MarginContainer.new()
	shell.name = "ContentMargin"
	shell.anchor_right = 1.0
	shell.anchor_bottom = 1.0
	shell.add_theme_constant_override("margin_left", 32)
	shell.add_theme_constant_override("margin_top", 32)
	shell.add_theme_constant_override("margin_right", 32)
	shell.add_theme_constant_override("margin_bottom", 32)
	add_child(shell)

	_content_root = VBoxContainer.new()
	_content_root.name = "ContentRoot"
	_content_root.add_theme_constant_override("separation", 18)
	shell.add_child(_content_root)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 12)
	_content_root.add_child(top_row)

	var title_column := VBoxContainer.new()
	title_column.name = "TitleColumn"
	title_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_column.add_theme_constant_override("separation", 6)
	top_row.add_child(title_column)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Combat VFX Gallery"
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(0.96, 0.90, 0.72, 1.0))
	title_column.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "Debug index for real combat VFX playback paths."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86, 1.0))
	title_column.add_child(subtitle)

	var play_all := Button.new()
	play_all.name = "PlayAllButton"
	play_all.text = "Open Show Page"
	play_all.custom_minimum_size = Vector2(190, 58)
	play_all.add_theme_font_size_override("font_size", ENTRY_BUTTON_FONT_SIZE)
	play_all.pressed.connect(_open_default_entry)
	top_row.add_child(play_all)

	_status_label = Label.new()
	_status_label.name = "StatusLabel"
	_status_label.text = ""
	_status_label.add_theme_font_size_override("font_size", STATUS_LABEL_FONT_SIZE)
	_status_label.add_theme_color_override("font_color", Color(0.68, 0.78, 0.92, 1.0))
	_content_root.add_child(_status_label)

	var scroll := ScrollContainer.new()
	scroll.name = "EntryScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content_root.add_child(scroll)

	var list := VBoxContainer.new()
	list.name = "EntryList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 18)
	scroll.add_child(list)

	_layout_content()


func _layout_content() -> void:
	if _content_root == null:
		return
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _populate_entries() -> void:
	var list := get_node_or_null("ContentMargin/ContentRoot/EntryScroll/EntryList") as VBoxContainer
	if list == null:
		return
	_clear_children(list)
	var entries := CATALOG_SCRIPT.entries()
	_status_label.text = "%d combat VFX entries. Pick one to inspect on the show page." % entries.size()
	for category in CATALOG_SCRIPT.categories():
		var category_label := Label.new()
		category_label.name = "%sHeader" % category.replace(" ", "")
		category_label.text = category
		category_label.add_theme_font_size_override("font_size", 28)
		category_label.add_theme_color_override("font_color", Color(0.95, 0.82, 0.48, 1.0))
		list.add_child(category_label)

		var grid := GridContainer.new()
		grid.name = "%sGrid" % category.replace(" ", "")
		grid.columns = 2
		grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_theme_constant_override("h_separation", 12)
		grid.add_theme_constant_override("v_separation", 12)
		list.add_child(grid)

		for entry in CATALOG_SCRIPT.entries_for_category(category):
			grid.add_child(_make_entry_button(entry))


func _make_entry_button(entry: Dictionary) -> Button:
	var button := Button.new()
	button.name = "%sButton" % String(entry.get("id", "entry")).to_pascal_case()
	button.text = (
		"%s\n%s | %s"
		% [
			String(entry.get("name", "VFX")),
			String(entry.get("entry_point", "")),
			CATALOG_SCRIPT.target_name(String(entry.get("target", ""))),
		]
	)
	button.custom_minimum_size = Vector2(420, 96)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT as HorizontalAlignment
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART as TextServer.AutowrapMode
	button.add_theme_font_size_override("font_size", ENTRY_BUTTON_FONT_SIZE)
	button.pressed.connect(_open_entry.bind(String(entry.get("id", ""))))
	return button


static func readability_font_probe() -> Dictionary:
	return {
		"status_label": STATUS_LABEL_FONT_SIZE,
		"entry_button": ENTRY_BUTTON_FONT_SIZE,
	}


func _open_default_entry() -> void:
	_open_entry(CATALOG_SCRIPT.default_entry_id())


func _open_entry(entry_id: String) -> void:
	if entry_id.strip_edges() == "":
		return
	var tree := get_tree()
	if tree == null:
		return
	tree.set_meta("vfx_gallery_entry_id", entry_id)
	tree.change_scene_to_file(SHOW_SCENE_PATH)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
