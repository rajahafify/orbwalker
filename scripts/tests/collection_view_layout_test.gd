extends RefCounted
class_name CollectionViewLayoutTest

const COLLECTION_VIEW_SCRIPT_PATH := "res://scripts/collection/collection_view.gd"
const CONTENT_REGISTRY_SCRIPT := preload("res://scripts/content/content_registry.gd")
const VISUAL_REGISTRY_SCRIPT := preload("res://scripts/ui/visual_registry.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("card_geometry_is_non_overlapping", _test_card_geometry_is_non_overlapping, failures)
	_run_case("rarity_surfaces_are_distinct_without_tags", _test_rarity_surfaces_are_distinct_without_tags, failures)
	_run_case("collection_textures_resolve", _test_collection_textures_resolve, failures)
	_run_case("equipment_icons_resolve_semantically", _test_equipment_icons_resolve_semantically, failures)

	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_card_geometry_is_non_overlapping() -> String:
	var probe: Dictionary = _collection_view_script().collection_card_layout_probe_snapshot()
	if int(probe.get("family_count", 0)) != 5:
		return "Expected probe to cover five equipment families."
	if int(probe.get("tiers_per_family", 0)) != 3:
		return "Expected probe to cover three cards per family."
	for key in ["title_overlaps_art", "title_overlaps_copy", "art_overlaps_copy", "copy_overlaps_badge"]:
		if bool(probe.get(key, true)):
			return "Expected card geometry not to report %s." % key
	if not bool(probe.get("badge_inside_card", false)):
		return "Expected badge to stay inside card."
	if not bool(probe.get("art_inside_card", false)):
		return "Expected art to stay inside card."
	if bool(probe.get("uses_horizontal_scroll", true)):
		return "Expected portrait collection cards to avoid horizontal scrolling."
	if int(probe.get("portrait_columns", 0)) != 1 or int(probe.get("wide_columns", 0)) != 3:
		return "Expected collection cards to use one portrait column and three wide columns."
	var card_rect: Rect2 = probe.get("card_rect", Rect2())
	var art_rect: Rect2 = probe.get("art_rect", Rect2())
	var copy_rect: Rect2 = probe.get("copy_rect", Rect2())
	if card_rect.size.x < 320.0 or card_rect.size.y < 460.0:
		return "Expected portrait collection card to be large enough for readable text."
	if art_rect.size.x < 160.0 or art_rect.size.y < 160.0:
		return "Expected card art stage to stay large enough for production item art."
	if copy_rect.size.x < 220.0 or copy_rect.size.y < 60.0:
		return "Expected card copy rect to be large enough for wrapped effect text."
	if int(probe.get("copy_max_chars", 99)) > 24:
		return "Expected card copy to be pre-wrapped before it can overflow horizontally."
	if bool(probe.get("copy_uses_ellipsis", true)):
		return "Expected card copy to wrap instead of hiding text behind ellipses."
	if not bool(probe.get("active_badge_pops", false)):
		return "Expected available card badges to pop visually."
	if bool(probe.get("active_badge_uses_external_shadow", true)):
		return "Expected active card badges not to use an external glow or shadow."
	if bool(probe.get("active_badge_rect_glow_visible", true)):
		return "Expected active card badges not to use a rectangular glow panel."
	if int(probe.get("copy_font_size", 0)) < 22:
		return "Expected card copy font to stay readable at shop scale."
	if int(probe.get("badge_font_size", 0)) < 24:
		return "Expected card badge font to stay readable at shop scale."
	if int(probe.get("copy_outline_size", 0)) < 3 or int(probe.get("badge_outline_size", 0)) < 3:
		return "Expected card copy and badge text to keep strong outlines for dark art."
	return ""


func _test_rarity_surfaces_are_distinct_without_tags() -> String:
	var probe: Dictionary = _collection_view_script().collection_card_layout_probe_snapshot()
	if bool(probe.get("renders_rarity_tag", true)):
		return "Expected collection cards not to render rarity tags."
	var common: Color = probe.get("common_surface", Color.BLACK)
	var uncommon: Color = probe.get("uncommon_surface", Color.BLACK)
	var rare: Color = probe.get("rare_surface", Color.BLACK)
	if _color_distance(common, uncommon) < 0.18:
		return "Expected uncommon card surface to read distinct from common."
	if _color_distance(uncommon, rare) < 0.18:
		return "Expected rare card surface to read distinct from uncommon."
	if not (uncommon.b > uncommon.r and uncommon.b > uncommon.g * 0.85):
		return "Expected uncommon surface to be blue-led."
	if not (rare.r > rare.g and rare.b > rare.g):
		return "Expected rare surface to be purple-led."
	return ""


func _test_collection_textures_resolve() -> String:
	var visuals = VISUAL_REGISTRY_SCRIPT.new()
	for rarity in ["common", "uncommon", "rare"]:
		var frame: Texture2D = visuals.collection_card_frame(rarity)
		if frame == null or frame.get_width() < 500 or frame.get_height() < 700:
			return "Expected collection frame for %s to resolve to full card dimensions." % rarity
		var relic_banner: Texture2D = visuals.collection_relic_banner_frame(rarity)
		if relic_banner == null or relic_banner.get_width() < 1000 or relic_banner.get_height() < 140:
			return "Expected collection relic banner frame for %s to resolve to a wide simple banner." % rarity
	var badge: Texture2D = visuals.collection_price_badge()
	if badge == null or badge.get_width() < 400 or badge.get_height() < 120:
		return "Expected collection price badge to resolve."
	var slot_frame: Texture2D = visuals.collection_hud_slot_frame()
	if slot_frame == null or slot_frame.get_width() < 90 or slot_frame.get_height() < 90:
		return "Expected collection HUD slot frame to resolve."
	return ""


func _test_equipment_icons_resolve_semantically() -> String:
	var visuals = VISUAL_REGISTRY_SCRIPT.new()
	var content = CONTENT_REGISTRY_SCRIPT.new()
	var expected_keys := {
		"shortsword": "equipment_shortsword",
		"shortsword_knight": "equipment_shortsword_knight",
		"shortsword_royal": "equipment_shortsword_royal",
		"buckler": "equipment_buckler",
		"buckler_iron": "equipment_buckler_iron",
		"buckler_guardian": "equipment_buckler_guardian",
		"coin_purse": "equipment_coin_purse",
		"coin_purse_merchant": "equipment_coin_purse_merchant",
		"coin_purse_noble": "equipment_coin_purse_noble",
		"healing_charm": "equipment_healing_charm",
		"healing_charm_blessed": "equipment_healing_charm_blessed",
		"healing_charm_saint": "equipment_healing_charm_saint",
		"leather_gloves": "equipment_leather_gloves",
		"leather_gloves_duelist": "equipment_leather_gloves_duelist",
		"leather_gloves_blademaster": "equipment_leather_gloves_blademaster",
	}
	for item_id in expected_keys.keys():
		var item := content.get_equipment(String(item_id))
		var icon_key := String(item.get("icon_key", ""))
		if icon_key != String(expected_keys[item_id]):
			return "Expected %s to use semantic icon key %s, got %s." % [item_id, expected_keys[item_id], icon_key]
		var texture: Texture2D = visuals.icon_for_key(icon_key)
		if texture == null or texture.get_width() < 300 or texture.get_height() < 300:
			return "Expected semantic icon %s to resolve to generated item art." % icon_key
	return ""


func _color_distance(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)


func _collection_view_script() -> GDScript:
	return ResourceLoader.load(COLLECTION_VIEW_SCRIPT_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
