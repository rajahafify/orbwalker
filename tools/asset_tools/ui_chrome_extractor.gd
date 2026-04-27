@tool
extends EditorScript

const UI_SHEET_PATH := "res://resources/art/first_pass/ui/ui_frame_kit_v1.png"
const SHOP_SHEET_PATH := "res://resources/art/first_pass/ui/shop_card_kit_v1.png"
const OUTPUT_DIR := "res://resources/art/first_pass/derived/ui_chrome"

const CROP_MAP := {
	"top_bar_frame.png": {"sheet": "ui", "rect": Rect2i(50, 31, 1436, 166)},
	"panel_frame.png": {"sheet": "ui", "rect": Rect2i(47, 232, 731, 595)},
	"board_cell_frame.png": {"sheet": "ui", "rect": Rect2i(1137, 675, 131, 131)},
	"slot_frame_equipment.png": {"sheet": "shop", "rect": Rect2i(46, 138, 482, 701)},
	"slot_frame_consumable.png": {"sheet": "shop", "rect": Rect2i(580, 93, 450, 764)},
	"divider_h.png": {"sheet": "ui", "rect": Rect2i(66, 904, 1408, 55)},
	"button_round_frame.png": {"sheet": "shop", "rect": Rect2i(1177, 486, 294, 308)},
}

func _run() -> void:
	var ui_sheet := Image.new()
	var shop_sheet := Image.new()
	var ui_err := ui_sheet.load(UI_SHEET_PATH)
	var shop_err := shop_sheet.load(SHOP_SHEET_PATH)
	if ui_err != OK or shop_err != OK:
		push_error("ui_chrome_extractor: failed to load source sheets.")
		return

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

	for name in CROP_MAP.keys():
		var entry: Dictionary = CROP_MAP[name]
		var source: Image = ui_sheet if String(entry["sheet"]) == "ui" else shop_sheet
		var rect: Rect2i = entry["rect"]
		var region := source.get_region(rect)
		var out_path := "%s/%s" % [OUTPUT_DIR, name]
		var save_err := region.save_png(out_path)
		if save_err != OK:
			push_warning("ui_chrome_extractor: failed to save %s" % out_path)

	var divider_h_path := "%s/divider_h.png" % OUTPUT_DIR
	var divider_h := Image.new()
	if divider_h.load(divider_h_path) != OK:
		push_warning("ui_chrome_extractor: failed to load divider_h.png for divider_v.")
		return

	var divider_v := _rotate_90_clockwise(divider_h)
	var divider_v_path := "%s/divider_v.png" % OUTPUT_DIR
	if divider_v.save_png(divider_v_path) != OK:
		push_warning("ui_chrome_extractor: failed to save divider_v.png")

func _rotate_90_clockwise(source: Image) -> Image:
	var out := Image.create(source.get_height(), source.get_width(), false, source.get_format())
	for y in range(source.get_height()):
		for x in range(source.get_width()):
			out.set_pixel(source.get_height() - 1 - y, x, source.get_pixel(x, y))
	return out
