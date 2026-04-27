extends RefCounted
class_name VisualRegistry

const PATH_COMBAT_BACKGROUND := "res://resources/art/first_pass/backgrounds/combat_bg_dungeon_01.png"
const PATH_SHOP_BACKGROUND := "res://resources/art/first_pass/backgrounds/shop_bg_merchant_01.png"
const PATH_ORB_SHEET := "res://resources/art/first_pass/sheets/orb_icon_set_v1.png"
const PATH_INTENT_SHEET := "res://resources/art/first_pass/sheets/intent_badge_set_v1.png"
const PATH_RARITY_SHEET := "res://resources/art/first_pass/sheets/rarity_badge_set_v1.png"
const PATH_MASTERY_SHEET := "res://resources/art/first_pass/sheets/mastery_icon_set_v1.png"
const PATH_ITEM_SHEET := "res://resources/art/first_pass/sheets/item_icon_seed_set_v1.png"
const PATH_UI_FRAME_SHEET := "res://resources/art/first_pass/ui/ui_frame_kit_v1.png"
const PATH_UI_BAR_SHEET := "res://resources/art/first_pass/ui/bar_kit_v1.png"
const PATH_UI_SHOP_CARD_SHEET := "res://resources/art/first_pass/ui/shop_card_kit_v1.png"
const PATH_VFX_SHEET := "res://resources/art/first_pass/vfx/vfx_sprite_sheet_v1.png"

const _INTENT_INDEX_BY_TYPE := {
	0: 0, # ATTACK
	1: 1, # BLOCK
	2: 2, # ATTACK_AND_BLOCK
}

const _RARITY_INDEX := {
	"common": 0,
	"uncommon": 1,
	"rare": 2,
}

const _ENEMY_PORTRAIT_PATHS := {
	"cavern_striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"cavern_defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"ash_hunter": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
	"iron_gate": "res://resources/art/first_pass/enemies/boss_iron_gate.png",
	"burning_knight": "res://resources/art/first_pass/enemies/boss_burning_knight.png",
	"prism_warden": "res://resources/art/first_pass/enemies/boss_prism_warden.png",
}

const _ICON_INDEX_BY_KEY := {
	"equipment_shortsword": 0,
	"equipment_buckler": 1,
	"equipment_coin_purse": 2,
	"equipment_stone_ring": 3,
	"equipment_ember_ring": 4,
	"equipment_frost_ring": 5,
	"consumable_fire_scroll": 6,
	"consumable_ice_scroll": 7,
	"consumable_earth_scroll": 8,
	"relic_merchant_compass": 9,
	"relic_stalwart_mantle": 10,
	"relic_golden_idol": 11,
}

var _warned_keys: Dictionary = {}
var _placeholder_cache: Dictionary = {}
var _orb_textures: Dictionary = {}
var _intent_textures: Dictionary = {}
var _rarity_textures: Dictionary = {}
var _mastery_textures: Dictionary = {}
var _icon_textures: Dictionary = {}
var _vfx_textures: Dictionary = {}

var _combat_background: Texture2D
var _shop_background: Texture2D
var _ui_frames: Texture2D
var _ui_bars: Texture2D
var _ui_shop_cards: Texture2D


func _init() -> void:
	_combat_background = _safe_load_texture(PATH_COMBAT_BACKGROUND, "combat_background")
	_shop_background = _safe_load_texture(PATH_SHOP_BACKGROUND, "shop_background")
	_ui_frames = _safe_load_texture(PATH_UI_FRAME_SHEET, "ui_frame_sheet")
	_ui_bars = _safe_load_texture(PATH_UI_BAR_SHEET, "ui_bar_sheet")
	_ui_shop_cards = _safe_load_texture(PATH_UI_SHOP_CARD_SHEET, "ui_shop_card_sheet")
	_build_orb_textures()
	_build_intent_textures()
	_build_rarity_textures()
	_build_mastery_textures()
	_build_icon_textures()
	_build_vfx_textures()


func combat_background() -> Texture2D:
	return _combat_background if _combat_background != null else placeholder_texture("combat_background")


func shop_background() -> Texture2D:
	return _shop_background if _shop_background != null else placeholder_texture("shop_background")


func enemy_portrait(enemy_id: String) -> Texture2D:
	var path := String(_ENEMY_PORTRAIT_PATHS.get(enemy_id, ""))
	if path == "":
		_warn_missing("enemy_id:%s" % enemy_id)
		var fallback := String(_ENEMY_PORTRAIT_PATHS.get("cavern_striker", ""))
		return _safe_load_texture(fallback, "enemy_fallback")
	var loaded := _safe_load_texture(path, "enemy:%s" % enemy_id)
	return loaded if loaded != null else placeholder_texture("enemy_portrait")


func orb_texture(orb_id: int) -> Texture2D:
	return _orb_textures.get(orb_id, placeholder_texture("orb_missing"))


func intent_badge(intent_type: int) -> Texture2D:
	var index := int(_INTENT_INDEX_BY_TYPE.get(intent_type, -1))
	if index < 0:
		_warn_missing("intent_type:%d" % intent_type)
		return placeholder_texture("intent_missing")
	return _intent_textures.get(index, placeholder_texture("intent_missing"))


func rarity_badge(rarity: String) -> Texture2D:
	var key := rarity.to_lower()
	var index := int(_RARITY_INDEX.get(key, -1))
	if index < 0:
		_warn_missing("rarity:%s" % rarity)
		return placeholder_texture("rarity_missing")
	return _rarity_textures.get(index, placeholder_texture("rarity_missing"))


func mastery_icon(orb_id: int) -> Texture2D:
	return _mastery_textures.get(orb_id, placeholder_texture("mastery_missing"))


func icon_for_key(icon_key: String) -> Texture2D:
	var index := int(_ICON_INDEX_BY_KEY.get(icon_key, -1))
	if index < 0:
		_warn_missing("icon_key:%s" % icon_key)
		return placeholder_texture("icon_missing")
	return _icon_textures.get(index, placeholder_texture("icon_missing"))


func ui_frame_sheet() -> Texture2D:
	return _ui_frames if _ui_frames != null else placeholder_texture("ui_frames")


func ui_bar_sheet() -> Texture2D:
	return _ui_bars if _ui_bars != null else placeholder_texture("ui_bars")


func ui_shop_card_sheet() -> Texture2D:
	return _ui_shop_cards if _ui_shop_cards != null else placeholder_texture("ui_shop_cards")


func vfx_texture(effect_name: String) -> Texture2D:
	var key := effect_name.to_lower()
	return _vfx_textures.get(key, placeholder_texture("vfx_missing"))


func placeholder_texture(key: String, color: Color = Color(0.32, 0.32, 0.36, 1.0), size: Vector2i = Vector2i(96, 96)) -> Texture2D:
	if _placeholder_cache.has(key):
		return _placeholder_cache[key]
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture := ImageTexture.create_from_image(image)
	_placeholder_cache[key] = texture
	return texture


func _build_orb_textures() -> void:
	var sheet := _safe_load_texture(PATH_ORB_SHEET, "orb_sheet")
	if sheet == null:
		return
	var orb_count := 6
	var slice_width := float(sheet.get_width()) / float(orb_count)
	var orb_ids := [
		OrbType.Id.FIRE,
		OrbType.Id.ICE,
		OrbType.Id.EARTH,
		OrbType.Id.HEART,
		OrbType.Id.ARMOR,
		OrbType.Id.GOLD,
	]
	for index in orb_count:
		var region := Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height()))
		_orb_textures[orb_ids[index]] = _processed_orb_region(sheet, region)


func _build_intent_textures() -> void:
	var sheet := _safe_load_texture(PATH_INTENT_SHEET, "intent_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_intent_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_rarity_textures() -> void:
	var sheet := _safe_load_texture(PATH_RARITY_SHEET, "rarity_sheet")
	if sheet == null:
		return
	var count := 3
	var slice_width := float(sheet.get_width()) / float(count)
	for index in count:
		_rarity_textures[index] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_mastery_textures() -> void:
	var sheet := _safe_load_texture(PATH_MASTERY_SHEET, "mastery_sheet")
	if sheet == null:
		return
	var count := 6
	var slice_width := float(sheet.get_width()) / float(count)
	var orb_ids := [
		OrbType.Id.FIRE,
		OrbType.Id.ICE,
		OrbType.Id.EARTH,
		OrbType.Id.HEART,
		OrbType.Id.ARMOR,
		OrbType.Id.GOLD,
	]
	for index in count:
		_mastery_textures[orb_ids[index]] = _atlas_region(sheet, Rect2(slice_width * index, 0.0, slice_width, float(sheet.get_height())))


func _build_icon_textures() -> void:
	var sheet := _safe_load_texture(PATH_ITEM_SHEET, "item_sheet")
	if sheet == null:
		return
	var columns := 4
	var rows := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / float(rows)
	var atlas_index := 0
	for row in rows:
		for column in columns:
			var region := Rect2(
				cell_width * column,
				cell_height * row,
				cell_width,
				cell_height
			)
			_icon_textures[atlas_index] = _atlas_region(sheet, region)
			atlas_index += 1


func _build_vfx_textures() -> void:
	var sheet := _safe_load_texture(PATH_VFX_SHEET, "vfx_sheet")
	if sheet == null:
		return
	var columns := 4
	var rows := 3
	var cell_width := float(sheet.get_width()) / float(columns)
	var cell_height := float(sheet.get_height()) / float(rows)
	_vfx_textures["hit_flash"] = _atlas_region(sheet, Rect2(0.0, 0.0, cell_width, cell_height))
	_vfx_textures["orb_clear"] = _atlas_region(sheet, Rect2(cell_width, 0.0, cell_width, cell_height))
	_vfx_textures["gold_gain"] = _atlas_region(sheet, Rect2(cell_width * 2.0, 0.0, cell_width, cell_height))


func _atlas_region(sheet: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = sheet
	atlas.region = region
	return atlas


func _processed_orb_region(sheet: Texture2D, region: Rect2) -> Texture2D:
	var source_image: Image = sheet.get_image()
	if source_image == null:
		return _atlas_region(sheet, region)

	var x0 := int(floor(region.position.x))
	var y0 := int(floor(region.position.y))
	var w := int(floor(region.size.x))
	var h := int(floor(region.size.y))
	if w <= 0 or h <= 0:
		return _atlas_region(sheet, region)

	var cropped := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var center := Vector2((w - 1) * 0.5, (h - 1) * 0.5)
	var radius := minf(float(w), float(h)) * 0.36
	var radius_sq := radius * radius
	for y in h:
		for x in w:
			var c := source_image.get_pixel(x0 + x, y0 + y)
			var p := Vector2(float(x), float(y))
			var delta := p - center
			# Keep only the circular orb footprint; this removes baked checkerboard previews.
			if delta.length_squared() > radius_sq:
				c.a = 0.0
			elif _is_checker_pixel(c):
				c.a = 0.0
			cropped.set_pixel(x, y, c)
	return ImageTexture.create_from_image(cropped)


func _is_checker_pixel(c: Color) -> bool:
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	if rg_diff > 0.02 or gb_diff > 0.02:
		return false
	var brightness := (c.r + c.g + c.b) / 3.0
	return brightness >= 0.72 and brightness <= 0.96 and c.a >= 0.99


func _safe_load_texture(path: String, key: String) -> Texture2D:
	var loaded: Variant = load(path)
	if loaded == null:
		_warn_missing("texture_path:%s" % key)
		return null
	return loaded as Texture2D


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)
