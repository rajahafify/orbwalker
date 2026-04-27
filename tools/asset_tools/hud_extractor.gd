@tool
extends RefCounted

const BAR_SHEET := "res://resources/art/first_pass/ui/bar_kit_v1.png"
const INTENT_SHEET := "res://resources/art/first_pass/sheets/intent_badge_set_v1.png"
const RARITY_SHEET := "res://resources/art/first_pass/sheets/rarity_badge_set_v1.png"
const OUT_DIR := "res://resources/art/first_pass/derived/hud"

const BAR_ROWS: Array[Vector2i] = [
	Vector2i(47, 175),
	Vector2i(213, 308),
	Vector2i(352, 475),
	Vector2i(516, 609),
	Vector2i(653, 775),
	Vector2i(814, 911),
]

const BAR_XS: Array[Vector2i] = [
	Vector2i(79, 1535),
	Vector2i(86, 1526),
	Vector2i(79, 1534),
	Vector2i(87, 1526),
	Vector2i(82, 1531),
	Vector2i(87, 1525),
]

const INTENT_RECT := Rect2i(96, 104, 1772, 582)
const INTENT_COLS: Array[Vector2i] = [
	Vector2i(96, 653),
	Vector2i(701, 1259),
	Vector2i(1310, 1867),
]

const RARITY_RECT := Rect2i(103, 93, 1703, 614)
const RARITY_COLS: Array[Vector2i] = [
	Vector2i(103, 652),
	Vector2i(690, 1233),
	Vector2i(1267, 1805),
]

static func _ensure_out_dir() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

static func _load_image(path: String) -> Image:
	var img := Image.new()
	var err := img.load(path)
	if err != OK:
		push_error("HUD extractor failed to load image: %s (err %d)" % [path, err])
	return img

static func _crop(src: Image, rect: Rect2i) -> Image:
	return src.get_region(rect)

static func _cut_checkerboard_to_alpha(img: Image) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var visited := PackedByteArray()
	visited.resize(w * h)
	for i in range(visited.size()):
		visited[i] = 0

	var queue: Array[Vector2i] = []
	var enqueue := func(p: Vector2i) -> void:
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			return
		var idx: int = p.y * w + p.x
		if visited[idx] == 1:
			return
		visited[idx] = 1
		var c: Color = img.get_pixel(p.x, p.y)
		var max_c: float = max(c.r, max(c.g, c.b))
		var min_c: float = min(c.r, min(c.g, c.b))
		var is_bg_like: bool = (max_c - min_c) <= 0.03 and min_c >= 0.86
		if is_bg_like:
			queue.append(p)

	for x in range(w):
		enqueue.call(Vector2i(x, 0))
		enqueue.call(Vector2i(x, h - 1))
	for y in range(h):
		enqueue.call(Vector2i(0, y))
		enqueue.call(Vector2i(w - 1, y))

	while not queue.is_empty():
		var p: Vector2i = queue.pop_back()
		img.set_pixel(p.x, p.y, Color(0, 0, 0, 0))
		enqueue.call(Vector2i(p.x + 1, p.y))
		enqueue.call(Vector2i(p.x - 1, p.y))
		enqueue.call(Vector2i(p.x, p.y + 1))
		enqueue.call(Vector2i(p.x, p.y - 1))

static func _save_png(img: Image, out_name: String) -> void:
	var out_path := "%s/%s" % [OUT_DIR, out_name]
	var err := img.save_png(out_path)
	if err != OK:
		push_error("HUD extractor failed to save %s (err %d)" % [out_path, err])

static func _bar_rect(idx: int) -> Rect2i:
	var y_range: Vector2i = BAR_ROWS[idx]
	var x_range: Vector2i = BAR_XS[idx]
	return Rect2i(
		x_range.x,
		y_range.x,
		(x_range.y - x_range.x + 1),
		(y_range.y - y_range.x + 1)
	)

static func _bar_fill_rect(idx: int) -> Rect2i:
	var base: Rect2i = _bar_rect(idx)
	var inset_x: int = 64
	var inset_y: int = 15
	return Rect2i(
		base.position.x + inset_x,
		base.position.y + inset_y,
		base.size.x - inset_x * 2,
		base.size.y - inset_y * 2
	)

static func _extract_bar_assets(bar: Image) -> void:
	# HP uses red style
	var hp_frame := _crop(bar, _bar_rect(0))
	var hp_fill := _crop(bar, _bar_fill_rect(1))
	_cut_checkerboard_to_alpha(hp_frame)
	_cut_checkerboard_to_alpha(hp_fill)
	_save_png(hp_frame, "hp_bar_frame.png")
	_save_png(hp_fill, "hp_bar_fill.png")

	# Mana uses blue style
	var mana_frame := _crop(bar, _bar_rect(2))
	var mana_fill := _crop(bar, _bar_fill_rect(3))
	_cut_checkerboard_to_alpha(mana_frame)
	_cut_checkerboard_to_alpha(mana_fill)
	_save_png(mana_frame, "mana_bar_frame.png")
	_save_png(mana_fill, "mana_bar_fill.png")

	# Enemy HP uses purple style
	var enemy_frame := _crop(bar, _bar_rect(4))
	var enemy_fill := _crop(bar, _bar_fill_rect(5))
	_cut_checkerboard_to_alpha(enemy_frame)
	_cut_checkerboard_to_alpha(enemy_fill)
	_save_png(enemy_frame, "enemy_hp_bar_frame.png")
	_save_png(enemy_fill, "enemy_hp_bar_fill.png")

	# Timer uses blue style as first pass.
	var timer_frame := _crop(bar, _bar_rect(2))
	var timer_fill := _crop(bar, _bar_fill_rect(3))
	_cut_checkerboard_to_alpha(timer_frame)
	_cut_checkerboard_to_alpha(timer_fill)
	_save_png(timer_frame, "timer_bar_frame.png")
	_save_png(timer_fill, "timer_bar_fill.png")

static func _extract_sheet_icons(sheet: Image, cols: Array[Vector2i], y0: int, y1: int, names: Array[String]) -> void:
	var h: int = y1 - y0 + 1
	for i in range(names.size()):
		var x0: int = cols[i].x
		var x1: int = cols[i].y
		var w: int = x1 - x0 + 1
		var cut := _crop(sheet, Rect2i(x0, y0, w, h))
		_cut_checkerboard_to_alpha(cut)
		_save_png(cut, names[i])

static func run_extraction() -> Dictionary:
	_ensure_out_dir()
	var bar := _load_image(BAR_SHEET)
	var intent := _load_image(INTENT_SHEET)
	var rarity := _load_image(RARITY_SHEET)

	_extract_bar_assets(bar)
	_extract_sheet_icons(
		intent,
		INTENT_COLS,
		INTENT_RECT.position.y,
		INTENT_RECT.position.y + INTENT_RECT.size.y - 1,
		["intent_attack.png", "intent_block.png", "intent_attack_block.png"]
	)
	_extract_sheet_icons(
		rarity,
		RARITY_COLS,
		RARITY_RECT.position.y,
		RARITY_RECT.position.y + RARITY_RECT.size.y - 1,
		["rarity_common.png", "rarity_uncommon.png", "rarity_rare.png"]
	)

	var combo := _crop(intent, Rect2i(INTENT_COLS[2].x, INTENT_RECT.position.y, INTENT_COLS[2].y - INTENT_COLS[2].x + 1, INTENT_RECT.size.y))
	_cut_checkerboard_to_alpha(combo)
	_save_png(combo, "combo_badge_frame.png")

	return {
		"out_dir": OUT_DIR,
		"count": 15
	}
