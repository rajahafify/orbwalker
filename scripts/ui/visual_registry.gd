extends RefCounted
class_name VisualRegistry

const PATH_COMBAT_BACKGROUND := "res://resources/art/first_pass/backgrounds/combat_bg_dungeon_01.png"
const PATH_SHOP_BACKGROUND := "res://resources/art/first_pass/backgrounds/shop_bg_merchant_01.png"
const PATH_ORB_SHEET := "res://resources/art/first_pass/sheets/orb_icon_set_v1.png"
const PATH_INTENT_SHEET := "res://resources/art/first_pass/sheets/intent_badge_set_v1.png"
const PATH_RARITY_SHEET := "res://resources/art/first_pass/sheets/rarity_badge_set_v1.png"
const PATH_MASTERY_SHEET := "res://resources/art/first_pass/sheets/mastery_icon_set_v1.png"
const PATH_ITEM_SHEET := "res://resources/art/first_pass/sheets/item_icon_seed_set_v1.png"
const PATH_DERIVED_ICON_DIR := "res://resources/art/first_pass/derived/icons"
const PATH_DERIVED_HUD_DIR := "res://resources/art/first_pass/derived/hud"
const PATH_DERIVED_CHROME_DIR := "res://resources/art/first_pass/derived/ui_chrome"
const PATH_DERIVED_VFX_DIR := "res://resources/art/first_pass/derived/vfx"
const PATH_UI_FRAME_SHEET := "res://resources/art/first_pass/ui/ui_frame_kit_v1.png"
const PATH_UI_BAR_SHEET := "res://resources/art/first_pass/ui/bar_kit_v1.png"
const PATH_UI_SHOP_CARD_SHEET := "res://resources/art/first_pass/ui/shop_card_kit_v1.png"
const PATH_VFX_SHEET := "res://resources/art/first_pass/vfx/vfx_sprite_sheet_v1.png"
const PATH_HERO_PORTRAIT := "res://resources/art/first_pass/heroes/hero_orbwalker.png"

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
	"ruin_lancer": "res://resources/art/first_pass/enemies/enemy_ruin_lancer.png",
	"vault_executioner": "res://resources/art/first_pass/enemies/enemy_vault_executioner.png",
	"goldbound_keeper": "res://resources/art/first_pass/enemies/enemy_goldbound_keeper.png",
	"training_goblin": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"iron_gate": "res://resources/art/first_pass/enemies/boss_iron_gate.png",
	"burning_knight": "res://resources/art/first_pass/enemies/boss_burning_knight.png",
	"prism_warden": "res://resources/art/first_pass/enemies/boss_prism_warden.png",
	"striker": "res://resources/art/first_pass/enemies/enemy_cavern_striker.png",
	"defender": "res://resources/art/first_pass/enemies/enemy_cavern_defender.png",
	"charger": "res://resources/art/first_pass/enemies/enemy_ash_hunter.png",
}

const _ICON_INDEX_BY_KEY := {
	"equipment_shortsword": 0,
	"equipment_buckler": 1,
	"equipment_coin_purse": 2,
	"equipment_healing_charm": 3,
	"equipment_stone_ring": 3,
	"equipment_ember_ring": 4,
	"equipment_frost_ring": 5,
	"equipment_leather_gloves": 1,
	"equipment_iron_helm": 1,
	"equipment_combo_lens": 7,
	"equipment_twin_blades": 0,
	"equipment_war_banner": 2,
	"equipment_tower_shield": 1,
	"equipment_merchant_scales": 2,
	"equipment_battle_drum": 4,
	"equipment_earthbreaker_maul": 8,
	"equipment_hearth_amulet": 3,
	"equipment_alchemist_gloves": 2,
	"equipment_training_manual": 8,
	"equipment_mirror_charm": 3,
	"equipment_ruby_brooch": 4,
	"equipment_sapphire_brooch": 5,
	"equipment_emerald_brooch": 8,
	"equipment_royal_seal": 11,
	"equipment_champion_plate": 10,
	"consumable_fire_scroll": 6,
	"consumable_ice_scroll": 7,
	"consumable_earth_scroll": 8,
	"consumable_heart_scroll": 3,
	"consumable_armor_scroll": 1,
	"consumable_gold_scroll": 2,
	"relic_deep_pockets": 2,
	"relic_crown_of_chains": 9,
	"relic_merchant_compass": 9,
	"relic_stalwart_mantle": 10,
	"relic_golden_idol": 11,
}

const _MASTERY_ORB_BY_ICON_KEY := {
	"mastery_fire": OrbType.Id.FIRE,
	"mastery_ice": OrbType.Id.ICE,
	"mastery_earth": OrbType.Id.EARTH,
	"mastery_heart": OrbType.Id.HEART,
	"mastery_armor": OrbType.Id.ARMOR,
	"mastery_gold": OrbType.Id.GOLD,
}

const _MASTERY_BEAM_BY_ORB_ID := {
	OrbType.Id.FIRE: "fire",
	OrbType.Id.ICE: "ice",
	OrbType.Id.EARTH: "earth",
	OrbType.Id.HEART: "heart",
	OrbType.Id.ARMOR: "armor",
	OrbType.Id.GOLD: "gold",
}
const _MASTERY_CARD_BY_ORB_ID := {
	OrbType.Id.FIRE: "fire",
	OrbType.Id.ICE: "ice",
	OrbType.Id.EARTH: "earth",
	OrbType.Id.HEART: "heart",
	OrbType.Id.ARMOR: "armor",
	OrbType.Id.GOLD: "gold",
}
const _MASTERY_ICON_BY_ORB_ID := {
	OrbType.Id.FIRE: "mastery_fire",
	OrbType.Id.ICE: "mastery_ice",
	OrbType.Id.EARTH: "mastery_earth",
	OrbType.Id.HEART: "mastery_heart",
	OrbType.Id.ARMOR: "mastery_armor",
	OrbType.Id.GOLD: "mastery_gold",
}

const _STABLE_PLACEHOLDER_ICON_COLORS := {
	"booster_elemental": Color(0.90, 0.34, 0.16, 1.0),
	"booster_fire": Color(0.90, 0.34, 0.16, 1.0),
}

var _warned_keys: Dictionary = {}
var _placeholder_cache: Dictionary = {}
var _orb_textures: Dictionary = {}
var _intent_textures: Dictionary = {}
var _rarity_textures: Dictionary = {}
var _mastery_textures: Dictionary = {}
var _icon_textures: Dictionary = {}
var _derived_icon_textures: Dictionary = {}
var _derived_hud_textures: Dictionary = {}
var _derived_chrome_textures: Dictionary = {}
var _vfx_textures: Dictionary = {}

var _combat_background: Texture2D
var _shop_background: Texture2D
var _hero_portrait: Texture2D
var _ui_frames: Texture2D
var _ui_bars: Texture2D
var _ui_shop_cards: Texture2D


func _init() -> void:
	_combat_background = _safe_load_texture(PATH_COMBAT_BACKGROUND, "combat_background")
	_shop_background = _safe_load_texture(PATH_SHOP_BACKGROUND, "shop_background")
	_hero_portrait = _safe_load_texture(PATH_HERO_PORTRAIT, "hero_portrait")
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
	var normalized_id := enemy_id.strip_edges().to_lower()
	var path := String(_ENEMY_PORTRAIT_PATHS.get(normalized_id, ""))
	if path == "":
		_warn_missing("enemy_id:%s" % normalized_id)
		var fallback := String(_ENEMY_PORTRAIT_PATHS.get("cavern_striker", ""))
		return _safe_load_texture(fallback, "enemy_fallback")
	var loaded := _safe_load_texture(path, "enemy:%s" % normalized_id)
	return loaded if loaded != null else placeholder_texture("enemy_portrait")


func hero_portrait() -> Texture2D:
	if _hero_portrait != null:
		return _hero_portrait
	var fallback := placeholder_texture("hero_portrait_missing", Color(0.10, 0.16, 0.24, 1.0), Vector2i(192, 192))
	return fallback


func orb_texture(orb_id: int) -> Texture2D:
	return _orb_textures.get(orb_id, placeholder_texture("orb_missing"))


func intent_badge(intent_type: int) -> Texture2D:
	var hud_key := ""
	match intent_type:
		0:
			hud_key = "intent_attack"
		1:
			hud_key = "intent_block"
		2:
			hud_key = "intent_attack_block"
	if hud_key != "":
		var hud_badge := clean_hud_texture(hud_key)
		if hud_badge != null:
			return hud_badge
	var index := int(_INTENT_INDEX_BY_TYPE.get(intent_type, -1))
	if index < 0:
		_warn_missing("intent_type:%d" % intent_type)
		return placeholder_texture("intent_missing")
	var texture: Texture2D = _intent_textures.get(index, null)
	if texture != null and not _looks_like_checkerboard_texture(texture):
		return texture
	return null


func rarity_badge(rarity: String) -> Texture2D:
	var key := rarity.to_lower()
	var hud_badge := hud_texture("rarity_%s" % key, false)
	if hud_badge != null:
		return hud_badge
	var index := int(_RARITY_INDEX.get(key, -1))
	if index < 0:
		_warn_missing("rarity:%s" % rarity)
		return placeholder_texture("rarity_missing")
	return _rarity_textures.get(index, placeholder_texture("rarity_missing"))


func mastery_icon(orb_id: int) -> Texture2D:
	return _mastery_textures.get(orb_id, placeholder_texture("mastery_missing"))


func menu_mastery_icon(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return placeholder_texture("mastery_missing")
	var icon_key := String(_MASTERY_ICON_BY_ORB_ID.get(orb_id, ""))
	if icon_key == "":
		return placeholder_texture("mastery_missing")
	var menu_icon := _load_derived_icon(icon_key)
	if menu_icon != null and not _looks_like_checkerboard_texture(menu_icon):
		return menu_icon
	var fallback := mastery_icon(orb_id)
	return fallback if fallback != null else placeholder_texture("mastery_missing")


func icon_for_key(icon_key: String) -> Texture2D:
	var clean_icon := clean_icon_for_key(icon_key, false)
	if clean_icon != null:
		return clean_icon
	_warn_missing("icon_key:%s" % icon_key)
	return placeholder_texture("icon_missing")


func mastery_beam_texture(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return null
	var beam_suffix := String(_MASTERY_BEAM_BY_ORB_ID.get(orb_id, ""))
	if beam_suffix == "":
		return null
	return _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_beam_%s" % beam_suffix, _vfx_textures)


func mastery_panel_frame_texture() -> Texture2D:
	var frame_texture := chrome_texture("mastery_panel_frame", false)
	if frame_texture != null:
		return frame_texture
	return placeholder_texture("mastery_panel_frame_missing", Color(0.10, 0.10, 0.14, 0.94), Vector2i(8, 8))


func mastery_card_texture(orb_id: int) -> Texture2D:
	if not OrbType.is_valid_id(orb_id):
		return _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_missing", _derived_chrome_textures)
	var card_suffix := String(_MASTERY_CARD_BY_ORB_ID.get(orb_id, ""))
	if card_suffix == "":
		return _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_missing", _derived_chrome_textures)
	var card_texture := _load_derived_texture(PATH_DERIVED_CHROME_DIR, "mastery_card_%s" % card_suffix, _derived_chrome_textures)
	if card_texture != null:
		return card_texture
	card_texture = _load_derived_texture(PATH_DERIVED_HUD_DIR, "mastery_card_%s" % card_suffix, _derived_hud_textures)
	if card_texture != null:
		return card_texture
	return mastery_icon(orb_id)


func mastery_shell_texture() -> Texture2D:
	var shell_texture := _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell_armor", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	shell_texture = _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_shell", _vfx_textures)
	if shell_texture != null:
		return shell_texture
	return placeholder_texture("mastery_shell_missing", Color(0.25, 0.34, 0.52, 0.90), Vector2i(120, 120))


func mastery_impact_texture(kind: String) -> Texture2D:
	var clean_kind := kind.strip_edges().to_lower()
	if clean_kind == "":
		return null
	if clean_kind == "armor":
		return mastery_shell_texture()
	var impact_lookup := {
		"fire": "hit",
		"ice": "hit",
		"earth": "hit",
		"heart": "heal",
		"gold": "gold",
	}
	var impact_suffix := String(impact_lookup.get(clean_kind, ""))
	if impact_suffix != "":
		var impact_texture := _load_derived_texture(PATH_DERIVED_VFX_DIR, "mastery_%s_impact" % impact_suffix, _vfx_textures)
		if impact_texture != null:
			return impact_texture
	return null


func clean_icon_for_key(icon_key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := icon_key.strip_edges().to_lower()
	var concrete_icon := _load_derived_icon(normalized_key)
	if concrete_icon != null and not _looks_like_checkerboard_texture(concrete_icon):
		return concrete_icon
	if _MASTERY_ORB_BY_ICON_KEY.has(normalized_key):
		return mastery_icon(int(_MASTERY_ORB_BY_ICON_KEY[normalized_key]))
	if _STABLE_PLACEHOLDER_ICON_COLORS.has(normalized_key):
		var placeholder_color: Color = _STABLE_PLACEHOLDER_ICON_COLORS[normalized_key]
		return placeholder_texture("stable_icon_%s" % normalized_key, placeholder_color)
	var index := int(_ICON_INDEX_BY_KEY.get(normalized_key, -1))
	if index < 0:
		if use_placeholder:
			_warn_missing("icon_key:%s" % icon_key)
			return placeholder_texture("icon_missing")
		return null
	var fallback_texture: Texture2D = _icon_textures.get(index, null)
	if fallback_texture != null and not _looks_like_checkerboard_texture(fallback_texture):
		return fallback_texture
	if use_placeholder:
		return placeholder_texture("icon_missing")
	return null


func ui_frame_sheet() -> Texture2D:
	return _ui_frames if _ui_frames != null else placeholder_texture("ui_frames")


func ui_bar_sheet() -> Texture2D:
	return _ui_bars if _ui_bars != null else placeholder_texture("ui_bars")


func ui_shop_card_sheet() -> Texture2D:
	return _ui_shop_cards if _ui_shop_cards != null else placeholder_texture("ui_shop_cards")


func hud_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	var texture := _load_derived_texture(PATH_DERIVED_HUD_DIR, normalized_key, _derived_hud_textures)
	if texture != null:
		return texture
	if use_placeholder:
		_warn_missing("hud:%s" % normalized_key)
		return placeholder_texture("hud_%s_missing" % normalized_key)
	return null


func chrome_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	var texture := _load_derived_texture(PATH_DERIVED_CHROME_DIR, normalized_key, _derived_chrome_textures)
	if texture != null:
		return texture
	if use_placeholder:
		_warn_missing("chrome:%s" % normalized_key)
		return placeholder_texture("chrome_%s_missing" % normalized_key)
	return null


func clean_hud_texture(key: String) -> Texture2D:
	var texture := hud_texture(key, false)
	if texture == null:
		return null
	return null if _looks_like_checkerboard_texture(texture) else texture


func clean_chrome_texture(key: String) -> Texture2D:
	var texture := chrome_texture(key, false)
	if texture == null:
		return null
	return null if _looks_like_checkerboard_texture(texture) else texture


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


func _load_derived_icon(icon_key: String) -> Texture2D:
	if icon_key == "":
		return null
	if _derived_icon_textures.has(icon_key):
		return _derived_icon_textures[icon_key]
	return _load_derived_texture(PATH_DERIVED_ICON_DIR, icon_key, _derived_icon_textures)


func _load_derived_texture(base_path: String, key: String, cache: Dictionary) -> Texture2D:
	if key == "":
		return null
	if cache.has(key):
		return cache[key]
	var path := "%s/%s.png" % [base_path, key]
	var loaded: Variant = null
	if ResourceLoader.exists(path):
		loaded = load(path)
	if loaded == null:
		var safe_loaded := _safe_load_texture(path, key)
		if safe_loaded == null:
			return null
		cache[key] = safe_loaded
		return safe_loaded
	var texture := loaded as Texture2D
	if texture == null:
		return null
	cache[key] = texture
	return texture


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
	var radius := minf(float(w), float(h)) * 0.43
	var radius_sq := radius * radius
	var min_x := w
	var min_y := h
	var max_x := -1
	var max_y := -1
	for y in h:
		for x in w:
			var c := source_image.get_pixel(x0 + x, y0 + y)
			var p := Vector2(float(x), float(y))
			var delta := p - center
			# Keep only the orb footprint; source sheet contains baked checkerboard outside the orb.
			if delta.length_squared() > radius_sq:
				c.a = 0.0
			elif _is_checker_pixel(c):
				c.a = 0.0
			cropped.set_pixel(x, y, c)
			if c.a > 0.01:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)

	_clear_edge_checker_noise(cropped)
	_keep_primary_orb_component(cropped)

	# Trim transparent borders so the orb fills BoardView cells instead of appearing tiny.
	if max_x >= min_x and max_y >= min_y:
		var padding := 1
		var trim_left := maxi(0, min_x - padding)
		var trim_top := maxi(0, min_y - padding)
		var trim_right := mini(w - 1, max_x + padding)
		var trim_bottom := mini(h - 1, max_y + padding)
		var trim_position := Vector2i(trim_left, trim_top)
		var trim_size := Vector2i(trim_right - trim_left + 1, trim_bottom - trim_top + 1)
		var trim_rect := Rect2i(trim_position, trim_size)
		cropped = cropped.get_region(trim_rect)

	return ImageTexture.create_from_image(cropped)


func _keep_primary_orb_component(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var labels := PackedInt32Array()
	labels.resize(width * height)
	var component_sizes: Array[int] = []
	var component_touches_center: Array[bool] = []
	var component_index := 0
	var center_x: int = int(width * 0.5)
	var center_y: int = int(height * 0.5)
	var center_radius_sq := 16

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if visited[idx] == 1:
				continue
			var c := image.get_pixel(x, y)
			if c.a <= 0.01:
				visited[idx] = 1
				continue

			component_index += 1
			var size := 0
			var touches_center := false
			var queue: Array[Vector2i] = [Vector2i(x, y)]
			visited[idx] = 1
			labels[idx] = component_index
			while not queue.is_empty():
				var p: Vector2i = queue.pop_back()
				size += 1
				var dx := p.x - center_x
				var dy := p.y - center_y
				if dx * dx + dy * dy <= center_radius_sq:
					touches_center = true
				for n in [Vector2i(p.x - 1, p.y), Vector2i(p.x + 1, p.y), Vector2i(p.x, p.y - 1), Vector2i(p.x, p.y + 1)]:
					if n.x < 0 or n.x >= width or n.y < 0 or n.y >= height:
						continue
					var n_idx: int = n.y * width + n.x
					if visited[n_idx] == 1:
						continue
					visited[n_idx] = 1
					var nc := image.get_pixel(n.x, n.y)
					if nc.a <= 0.01:
						continue
					labels[n_idx] = component_index
					queue.append(n)

			component_sizes.append(size)
			component_touches_center.append(touches_center)

	if component_index <= 1:
		return

	var keep_component := -1
	for i in range(component_sizes.size()):
		if component_touches_center[i]:
			keep_component = i + 1
			break
	if keep_component == -1:
		var best_size := -1
		for i in range(component_sizes.size()):
			if component_sizes[i] > best_size:
				best_size = component_sizes[i]
				keep_component = i + 1

	for y in range(height):
		for x in range(width):
			var idx := y * width + x
			if labels[idx] != keep_component:
				var cc := image.get_pixel(x, y)
				if cc.a > 0.01:
					cc.a = 0.0
					image.set_pixel(x, y, cc)


func _is_checker_pixel(c: Color) -> bool:
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	if rg_diff > 0.02 or gb_diff > 0.02:
		return false
	var brightness := (c.r + c.g + c.b) / 3.0
	return brightness >= 0.72 and brightness <= 0.96 and c.a >= 0.99


func _is_loose_checker_pixel(c: Color) -> bool:
	if c.a <= 0.01:
		return false
	var rg_diff := absf(c.r - c.g)
	var gb_diff := absf(c.g - c.b)
	if rg_diff > 0.06 or gb_diff > 0.06:
		return false
	var brightness := (c.r + c.g + c.b) / 3.0
	return brightness >= 0.20 and brightness <= 0.95


func _clear_edge_checker_noise(image: Image) -> void:
	var width: int = image.get_width()
	var height: int = image.get_height()
	if width <= 0 or height <= 0:
		return

	var visited := PackedByteArray()
	visited.resize(width * height)
	var stack: Array[Vector2i] = []

	for x in range(width):
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, height - 1))
	for y in range(height):
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(width - 1, y))

	while not stack.is_empty():
		var p_variant: Variant = stack.pop_back()
		if not (p_variant is Vector2i):
			continue
		var p: Vector2i = p_variant
		var x: int = p.x
		var y: int = p.y
		if x < 0 or x >= width or y < 0 or y >= height:
			continue
		var index: int = y * width + x
		if visited[index] == 1:
			continue
		visited[index] = 1
		var c := image.get_pixel(x, y)
		if not _is_loose_checker_pixel(c):
			continue
		c.a = 0.0
		image.set_pixel(x, y, c)
		stack.append(Vector2i(x - 1, y))
		stack.append(Vector2i(x + 1, y))
		stack.append(Vector2i(x, y - 1))
		stack.append(Vector2i(x, y + 1))


func _looks_like_checkerboard_texture(texture: Texture2D) -> bool:
	var image := texture.get_image()
	if image == null:
		return false
	var width := image.get_width()
	var height := image.get_height()
	if width <= 0 or height <= 0:
		return false

	var checker_hits := 0
	var sample_count := 0
	var x_step := maxi(1, int(floor(float(width) / 16.0)))
	var y_step := maxi(1, int(floor(float(height) / 16.0)))
	for y in range(0, height, y_step):
		for x in range(0, width, x_step):
			sample_count += 1
			if _is_checker_pixel(image.get_pixel(x, y)):
				checker_hits += 1
	if sample_count == 0:
		return false
	return float(checker_hits) / float(sample_count) > 0.28


func _safe_load_texture(path: String, key: String) -> Texture2D:
	var loaded: Variant = load(path)
	var texture := loaded as Texture2D
	if texture != null:
		return texture
	if FileAccess.file_exists(path):
		var image := Image.new()
		var load_error := image.load(path)
		if load_error == OK:
			return ImageTexture.create_from_image(image)
	_warn_missing("texture_path:%s" % key)
	return null


func _warn_missing(key: String) -> void:
	if _warned_keys.has(key):
		return
	_warned_keys[key] = true
	push_warning("VisualRegistry fallback used for %s" % key)
