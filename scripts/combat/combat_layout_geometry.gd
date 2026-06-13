extends RefCounted
class_name CombatLayoutGeometry

const TOP_HEADER_SCRIPT := preload("res://scripts/ui/top_header.gd")
const COMBAT_CHROME_STYLER_SCRIPT := preload("res://scripts/combat/combat_chrome_styler.gd")
const PLAYER_HUD_LAYOUT_SCRIPT := preload("res://scripts/ui/player_loadout_hud_layout.gd")

const DESIGN_SIZE = Vector2(1080, 1920)
const TOP_BAR_RECT = Rect2(Vector2(16, 8), Vector2(1048, 116))
const ENEMY_PANEL_RECT = Rect2(Vector2(16, 132), Vector2(1048, 432))
const COMBAT_STRIP_RECT = Rect2(Vector2(16, 576), Vector2(1048, 64))
const BOARD_PANEL_RECT = Rect2(Vector2(16, 660), Vector2(1048, 756))
const ENEMY_INTENT_RECT = Rect2(Vector2(724, 332), Vector2(300, 76))
const ENEMY_STAGE_RECT = Rect2(Vector2(0, 0), Vector2(1048, 432))
const ENEMY_HP_ROW_RECT = Rect2(Vector2(24, 292), Vector2(682, 124))
const ENEMY_FIGURE_TARGET_RECT = Rect2(Vector2(0, 0), Vector2(1048, 432))
const ENEMY_HP_BAR_SIZE = Vector2(612, 52)
const BOARD_SIZE = Vector2(480, 576)
const BOARD_TOP = 4.0
const BOARD_SIDE_PADDING = 4.0
const BOARD_BOTTOM_PADDING = 4.0
const BOARD_SHADOW_OFFSET = Vector2(0, 0)
const BOARD_SHADOW_EXPAND = Vector2(36, 18)
const PLAYER_STAT_CHIP_RECT = Rect2(Vector2(222, 110), Vector2(552, 42))
const PLAYER_META_RECT = Rect2(Vector2(230, 190), Vector2(740, 32))
const PLAYER_SUMMARY_RECT = Rect2(Vector2(230, 224), Vector2(740, 28))
const PLAYER_PORTRAIT_SIZE = Vector2(188, 194)
const TIMER_TRACK_SIZE = Vector2(980, 32)
const TIMER_ICON_SIZE = Vector2.ZERO
const TIMER_CENTER_MARKER_SIZE = Vector2(18, 32)
const EQUIPMENT_RAIL_RECT = Rect2(Vector2(16, 16), Vector2(472, 88))
const CONSUMABLE_RAIL_RECT = Rect2(Vector2(696, 16), Vector2(280, 88))
const PLAYER_HUD_SECTION_BASE_RECT = Rect2(Vector2(0, 1428), Vector2(1080, 492))
const PLAYER_HUD_MASTERY_PANEL_RECT = Rect2(Vector2(16, 0), Vector2(1048, 160))
const PLAYER_HUD_MASTERY_TITLE_RECT = Rect2(Vector2(0, 6), Vector2(1048, 50))
const PLAYER_HUD_MASTERY_CARDS_RECT = Rect2(Vector2(0, 58), Vector2(1048, 102))
const PLAYER_HUD_FOOTER_PANEL_RECT = Rect2(Vector2(0, 168), Vector2(1080, 324))
const COMPACT_VITALS_PANEL_RECT = Rect2(Vector2(228, 12), Vector2(836, 152))
const COMPACT_PLAYER_HP_BAR_RECT = Rect2(Vector2(14, 16), Vector2(806, 58))
const COMPACT_PLAYER_LOADOUT_RECT = Rect2(Vector2(16, 168), Vector2(1048, 156))
const COMPACT_EQUIPMENT_RAIL_RECT = Rect2(Vector2(20, 34), Vector2(540, 106))
const COMPACT_CONSUMABLE_RAIL_RECT = Rect2(Vector2(714, 34), Vector2(314, 106))
const COMPACT_VITALS_RELIC_ICONS_RECT = Rect2(Vector2(126, 82), Vector2(402, 64))
const DIVIDER_SIZE = Vector2(700, 20)
const CORNER_ORNAMENT_SIZE = Vector2(56, 56)
const MIN_READABLE_ENEMY_INTENT = Vector2(280, 56)
const MIN_READABLE_TIMER = Vector2(860, 32)
const MIN_READABLE_BOARD = Vector2(470, 560)
const MIN_READABLE_MASTERY = Vector2(1000, 96)
const MIN_READABLE_HP = Vector2(760, 56)
const MIN_READABLE_LOADOUT = Vector2(860, 120)
const MIN_READABLE_FONT_SIZES := {
	"timer_label": 36,
	"enemy_name_label": 40,
	"enemy_hp_text_label": 30,
	"primary_intent_title_label": 24,
	"primary_intent_amount_label": 42,
	"primary_intent_detail_label": 20,
	"run_progress_label": 20,
	"phase_label": 20,
	"turn_summary_label": 20,
	"equipment_row_label": 20,
	"consumable_row_label": 20,
	"relic_row_label": 20,
	"mastery_row_label": 20,
	"player_label": 28,
	"player_armor_label": 24,
	"intent_label": 24,
	"hp_label": 34,
	"equipment_label": 22,
	"consumable_label": 22,
	"relic_label": 20,
}


static func build_layout_probe(viewport_size: Vector2) -> Dictionary:
	if viewport_size.y <= 0.0:
		return {"applied": false}
	var snapshot := compute_layout_rects(viewport_size)
	var section_rect: Rect2 = snapshot["player_hud_section_rect"]
	var enemy_panel_rect: Rect2 = snapshot["enemy_panel_rect"]
	var combat_strip_rect: Rect2 = snapshot["combat_strip_rect"]
	var board_panel_rect: Rect2 = snapshot["board_panel_rect"]
	var mastery_panel_local: Rect2 = snapshot["player_hud_mastery_panel_rect"]
	var footer_panel_local: Rect2 = snapshot["player_hud_footer_panel_rect"]
	var mastery_panel_global := _offset_rect(mastery_panel_local, section_rect.position)
	var footer_panel_global := _offset_rect(footer_panel_local, section_rect.position)
	var top_bar_rect: Rect2 = snapshot["top_bar_rect"]
	var shared_top_controls: Dictionary = TOP_HEADER_SCRIPT.layout_snapshot_for(top_bar_rect)
	var top_segments := {
		"top_title": shared_top_controls.get("title", Rect2()),
		"top_gold": shared_top_controls.get("gold_counter", Rect2()),
		"top_help": shared_top_controls.get("help_button", Rect2()),
		"top_settings": shared_top_controls.get("settings_button", Rect2()),
	}
	var primary_zone_rects := {
		"top_bar": top_bar_rect,
		"enemy_panel": snapshot["enemy_panel_rect"],
		"combat_strip": snapshot["combat_strip_rect"],
		"board_panel": snapshot["board_panel_rect"],
		"player_hud_section": section_rect,
	}
	var enemy_intent_rect := _offset_rect(ENEMY_INTENT_RECT, enemy_panel_rect.position)
	var enemy_name_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 4.0), Vector2(548.0, 42.0)
	)
	var enemy_hp_text_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 54.0), ENEMY_HP_BAR_SIZE
	)
	var timer_track_rect := _timer_track_rect(combat_strip_rect)
	var board_rect := _board_rect(board_panel_rect)
	var enemy_hp_bar_rect := Rect2(
		enemy_panel_rect.position + Vector2(ENEMY_HP_ROW_RECT.position.x + 18.0, ENEMY_HP_ROW_RECT.position.y + 54.0), ENEMY_HP_BAR_SIZE
	)
	var mastery_rail_rect := mastery_panel_global
	var hero_vitals_rect := _offset_rect(COMPACT_VITALS_PANEL_RECT, footer_panel_global.position)
	var equipment_rail_rect := _offset_rect(COMPACT_EQUIPMENT_RAIL_RECT, _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_panel_global.position).position)
	var consumable_rail_rect := _offset_rect(COMPACT_CONSUMABLE_RAIL_RECT, _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_panel_global.position).position)
	var relic_rail_rect := _offset_rect(COMPACT_VITALS_RELIC_ICONS_RECT, hero_vitals_rect.position)
	var outcome_overlay_rect := Rect2(board_panel_rect.position + Vector2(224.0, 164.0), Vector2(600.0, 372.0))
	var hp_bar_rect := _player_hp_zone_rect(section_rect, footer_panel_local)
	var loadout_rails_rect := _player_loadout_rails_rect(section_rect, footer_panel_local)
	var readability_zones := {
		"top_segments": top_bar_rect,
		"enemy_name": enemy_name_rect,
		"enemy_hp": enemy_hp_text_rect,
		"primary_intent_badge": enemy_intent_rect,
		"timer": timer_track_rect,
		"board": board_rect,
		"mastery_rail": mastery_rail_rect,
		"hero_vitals": hero_vitals_rect,
		"relic_rail": relic_rail_rect,
		"equipment_rail": equipment_rail_rect,
		"consumable_rail": consumable_rail_rect,
		"outcome_overlay": outcome_overlay_rect,
		"enemy_hp_bar": enemy_hp_bar_rect,
		"player_hp": hp_bar_rect,
		"loadout_rails": loadout_rails_rect,
	}
	var readability_actionable_zone_rects := {
		"top_segments": top_bar_rect,
		"enemy_name": enemy_name_rect,
		"enemy_hp": enemy_hp_text_rect,
		"primary_intent_badge": enemy_intent_rect,
		"timer": timer_track_rect,
		"board": board_rect,
		"mastery_rail": mastery_rail_rect,
		"hero_vitals": hero_vitals_rect,
		"relic_rail": relic_rail_rect,
		"equipment_rail": equipment_rail_rect,
		"consumable_rail": consumable_rail_rect,
	}
	var player_hud_internal_zone_rects := {
		"player_hud_mastery_panel": mastery_panel_global,
		"player_hud_footer_panel": footer_panel_global,
	}
	for key in top_segments.keys():
		player_hud_internal_zone_rects[key] = top_segments[key]
	var primary_overlaps := _collect_zone_overlaps(primary_zone_rects)
	var player_hud_internal_overlaps := _collect_zone_overlaps(player_hud_internal_zone_rects)
	var readability_overlaps := _collect_zone_overlaps(readability_zones)
	var readability_actionable_overlaps := _collect_zone_overlaps(readability_actionable_zone_rects)
	readability_actionable_overlaps = _filter_actionable_readability_overlaps(readability_actionable_overlaps, readability_actionable_zone_rects)
	var actionable_overlaps: Array = []
	actionable_overlaps.append_array(primary_overlaps)
	actionable_overlaps.append_array(player_hud_internal_overlaps)
	actionable_overlaps.append_array(readability_actionable_overlaps)
	var readability := _build_readability_report(readability_zones)
	return {
		"applied": true,
		"viewport_size": viewport_size,
		"layout_root_size": snapshot["layout_root_size"],
		"scale_factor": snapshot["scale_factor"],
		"zone_rects":
		{
			"primary": primary_zone_rects,
			"readability": readability_zones,
			"player_hud_internals": player_hud_internal_zone_rects,
		},
		"overlaps_primary": primary_overlaps,
		"overlaps_player_hud_internals": player_hud_internal_overlaps,
		"overlaps_readability": readability_overlaps,
		"overlaps_readability_actionable": readability_actionable_overlaps,
		"overlaps": actionable_overlaps,
		"overlap_count": actionable_overlaps.size(),
		"board_size": board_size_for_rect(board_panel_rect),
		"readability": readability,
	}


static func compute_layout_rects(viewport_size: Vector2) -> Dictionary:
	var aspect = viewport_size.x / viewport_size.y
	var design_aspect = DESIGN_SIZE.x / DESIGN_SIZE.y
	var fits_tall_portrait = aspect <= design_aspect
	var scale_factor: float
	var layout_root_size: Vector2
	if fits_tall_portrait:
		scale_factor = viewport_size.x / DESIGN_SIZE.x
		layout_root_size = Vector2(DESIGN_SIZE.x, viewport_size.y / maxf(0.001, scale_factor))
	else:
		scale_factor = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
		layout_root_size = DESIGN_SIZE
	var rects := compute_layout_rects_from_root_size(layout_root_size)
	rects["layout_root_size"] = layout_root_size
	rects["scale_factor"] = scale_factor
	return rects


static func compute_layout_rects_from_root_size(layout_root_size: Vector2) -> Dictionary:
	var top_bar_rect := TOP_BAR_RECT
	var enemy_panel_rect := ENEMY_PANEL_RECT
	var combat_strip_rect := COMBAT_STRIP_RECT
	var board_panel_rect := BOARD_PANEL_RECT
	var player_hud_section_rect := PLAYER_HUD_SECTION_BASE_RECT
	var extra_height = maxf(0.0, layout_root_size.y - DESIGN_SIZE.y)
	if extra_height <= 0.0:
		var base_player_override := player_hud_layout_override_for_section(player_hud_section_rect)
		return {
			"top_bar_rect": top_bar_rect,
			"enemy_panel_rect": enemy_panel_rect,
			"combat_strip_rect": combat_strip_rect,
			"board_panel_rect": board_panel_rect,
			"player_hud_section_rect": player_hud_section_rect,
			"player_hud_mastery_panel_rect": base_player_override["mastery_panel"],
			"player_hud_mastery_title_rect": base_player_override["mastery_title"],
			"player_hud_mastery_cards_rect": base_player_override["mastery_cards"],
			"player_hud_footer_panel_rect": base_player_override["footer_panel"],
		}
	var board_top = board_panel_rect.position.y
	var board_gap = 12.0
	var player_section_base_size = player_hud_section_rect.size
	var max_board_width = BOARD_PANEL_RECT.size.x - (BOARD_SIDE_PADDING * 2.0)
	var board_panel_max_height = (max_board_width * (BOARD_SIZE.y / BOARD_SIZE.x)) + BOARD_TOP + BOARD_BOTTOM_PADDING
	var board_growth_capacity = maxf(0.0, board_panel_max_height - BOARD_PANEL_RECT.size.y)
	var board_growth = minf(extra_height, board_growth_capacity)
	var player_growth = extra_height - board_growth
	board_panel_rect = Rect2(BOARD_PANEL_RECT.position, Vector2(BOARD_PANEL_RECT.size.x, BOARD_PANEL_RECT.size.y + board_growth))
	var section_position = Vector2(0.0, board_top + board_panel_rect.size.y + board_gap)
	player_hud_section_rect = Rect2(section_position, Vector2(player_section_base_size.x, player_section_base_size.y + player_growth))
	var player_override := player_hud_layout_override_for_section(player_hud_section_rect)
	return {
		"top_bar_rect": top_bar_rect,
		"enemy_panel_rect": enemy_panel_rect,
		"combat_strip_rect": combat_strip_rect,
		"board_panel_rect": board_panel_rect,
		"player_hud_section_rect": player_hud_section_rect,
		"player_hud_mastery_panel_rect": player_override["mastery_panel"],
		"player_hud_mastery_title_rect": player_override["mastery_title"],
		"player_hud_mastery_cards_rect": player_override["mastery_cards"],
		"player_hud_footer_panel_rect": player_override["footer_panel"],
	}


static func player_hud_layout_override_for_section(section_rect: Rect2) -> Dictionary:
	var mastery_panel_rect = PLAYER_HUD_MASTERY_PANEL_RECT
	var mastery_title_rect = PLAYER_HUD_MASTERY_TITLE_RECT
	var mastery_cards_rect = PLAYER_HUD_MASTERY_CARDS_RECT
	var footer_panel_rect = PLAYER_HUD_FOOTER_PANEL_RECT
	var section_delta = maxf(0.0, section_rect.size.y - PLAYER_HUD_SECTION_BASE_RECT.size.y)
	if section_delta > 0.0:
		footer_panel_rect.size.y += section_delta
	return {
		"section": section_rect,
		"mastery_panel": mastery_panel_rect,
		"mastery_title": mastery_title_rect,
		"mastery_cards": mastery_cards_rect,
		"footer_panel": footer_panel_rect,
	}


static func board_size_for_rect(board_panel_rect: Rect2) -> Vector2:
	var board_aspect = BOARD_SIZE.x / BOARD_SIZE.y
	var max_board_height = maxf(64.0, board_panel_rect.size.y - BOARD_TOP - BOARD_BOTTOM_PADDING)
	var max_board_width = maxf(64.0, board_panel_rect.size.x - (BOARD_SIDE_PADDING * 2.0))
	var board_height = minf(max_board_height, max_board_width / maxf(0.001, board_aspect))
	var board_width = board_height * board_aspect
	return Vector2(board_width, board_height)


static func _offset_rect(rect: Rect2, offset: Vector2) -> Rect2:
	return Rect2(rect.position + offset, rect.size)


static func _timer_track_rect(combat_strip_rect: Rect2) -> Rect2:
	return Rect2(
		Vector2(
			combat_strip_rect.position.x + (combat_strip_rect.size.x - TIMER_TRACK_SIZE.x) * 0.5,
			combat_strip_rect.position.y + (combat_strip_rect.size.y - TIMER_TRACK_SIZE.y) * 0.5
		),
		TIMER_TRACK_SIZE
	)


static func _board_rect(board_panel_rect: Rect2) -> Rect2:
	var board_size := board_size_for_rect(board_panel_rect)
	return Rect2(Vector2(board_panel_rect.position.x + (board_panel_rect.size.x - board_size.x) * 0.5, board_panel_rect.position.y + BOARD_TOP), board_size)


static func _player_hp_zone_rect(section_rect: Rect2, footer_panel_local: Rect2) -> Rect2:
	var footer_global := _offset_rect(footer_panel_local, section_rect.position)
	var vitals_rect := _offset_rect(COMPACT_VITALS_PANEL_RECT, footer_global.position)
	return _offset_rect(COMPACT_PLAYER_HP_BAR_RECT, vitals_rect.position)


static func _player_loadout_rails_rect(section_rect: Rect2, footer_panel_local: Rect2) -> Rect2:
	var footer_global := _offset_rect(footer_panel_local, section_rect.position)
	var loadout_rect := _offset_rect(COMPACT_PLAYER_LOADOUT_RECT, footer_global.position)
	var equipment_rect := _offset_rect(COMPACT_EQUIPMENT_RAIL_RECT, loadout_rect.position)
	var consumable_rect := _offset_rect(COMPACT_CONSUMABLE_RAIL_RECT, loadout_rect.position)
	return equipment_rect.merge(consumable_rect)


static func _build_readability_report(zone_rects: Dictionary) -> Dictionary:
	var thresholds := {
		"primary_intent_badge": MIN_READABLE_ENEMY_INTENT,
		"timer": MIN_READABLE_TIMER,
		"board": MIN_READABLE_BOARD,
		"mastery_rail": MIN_READABLE_MASTERY,
		"player_hp": MIN_READABLE_HP,
		"equipment_rail": Vector2(500, 100),
		"consumable_rail": Vector2(308, 100),
	}
	var checks: Dictionary = {}
	var passing_count := 0
	for key in thresholds.keys():
		var zone_rect: Variant = zone_rects.get(key, Rect2())
		if not (zone_rect is Rect2):
			continue
		var min_size: Vector2 = thresholds.get(key, Vector2.ZERO)
		var rect_value: Rect2 = zone_rect
		var pass_size := rect_value.size.x >= min_size.x and rect_value.size.y >= min_size.y
		if pass_size:
			passing_count += 1
		checks[key] = {
			"rect": rect_value,
			"size": rect_value.size,
			"min_size": min_size,
			"passes_minimum": pass_size,
		}
	var font_sizes := _readability_font_sizes()
	var font_checks := _build_font_readability_checks(font_sizes)
	var font_passing_count := 0
	for font_check in font_checks.values():
		if font_check is Dictionary and bool(font_check.get("passes_minimum", false)):
			font_passing_count += 1
	return {
		"checks": checks,
		"font_sizes": font_sizes,
		"font_checks": font_checks,
		"passing_count": passing_count,
		"required_count": thresholds.size(),
		"font_passing_count": font_passing_count,
		"font_required_count": font_checks.size(),
		"font_all_pass": font_passing_count == font_checks.size(),
		"all_pass": passing_count == thresholds.size() and font_passing_count == font_checks.size(),
	}


static func _readability_font_sizes() -> Dictionary:
	var font_sizes: Dictionary = COMBAT_CHROME_STYLER_SCRIPT.readability_font_probe()
	var footer_fonts: Dictionary = PLAYER_HUD_LAYOUT_SCRIPT.player_footer_font_probe(true)
	font_sizes["hp_label"] = footer_fonts.get("hp_label", 0)
	font_sizes["equipment_label"] = footer_fonts.get("equipment_label", 0)
	font_sizes["consumable_label"] = footer_fonts.get("consumable_label", 0)
	font_sizes["relic_label"] = footer_fonts.get("relic_label", 0)
	return font_sizes


static func _build_font_readability_checks(font_sizes: Dictionary) -> Dictionary:
	var checks := {}
	for key in MIN_READABLE_FONT_SIZES.keys():
		var font_size := int(font_sizes.get(key, 0))
		var min_size := int(MIN_READABLE_FONT_SIZES.get(key, 0))
		checks[key] = {
			"font_size": font_size,
			"min_size": min_size,
			"passes_minimum": font_size >= min_size,
		}
	return checks


static func _collect_zone_overlaps(zone_rects: Dictionary) -> Array:
	var keys := zone_rects.keys()
	var overlaps: Array = []
	for i in range(keys.size()):
		var key_a: String = String(keys[i])
		var rect_a: Variant = zone_rects.get(key_a, Rect2())
		if not (rect_a is Rect2):
			continue
		for j in range(i + 1, keys.size()):
			var key_b: String = String(keys[j])
			var rect_b: Variant = zone_rects.get(key_b, Rect2())
			if not (rect_b is Rect2):
				continue
			var intersection: Rect2 = (rect_a as Rect2).intersection(rect_b as Rect2)
			if intersection.size.x > 0.0 and intersection.size.y > 0.0:
				(
					overlaps
					. append(
						{
							"a": key_a,
							"b": key_b,
							"intersection": intersection,
						}
					)
				)
	return overlaps


static func _filter_actionable_readability_overlaps(overlaps: Array, zone_rects: Dictionary) -> Array:
	var filtered: Array = []
	var hero_vitals_rect: Rect2 = zone_rects.get("hero_vitals", Rect2())
	var relic_rail_rect: Rect2 = zone_rects.get("relic_rail", Rect2())
	var is_embedded_relic_rail := _rect_contains_rect(hero_vitals_rect, relic_rail_rect)
	for overlap_entry in overlaps:
		var a := String(overlap_entry.get("a", ""))
		var b := String(overlap_entry.get("b", ""))
		var is_relic_inside_vitals_pair := (a == "hero_vitals" and b == "relic_rail") or (a == "relic_rail" and b == "hero_vitals")
		if is_embedded_relic_rail and is_relic_inside_vitals_pair:
			continue
		filtered.append(overlap_entry)
	return filtered


static func _rect_contains_rect(container: Rect2, candidate: Rect2) -> bool:
	if container.size.x <= 0.0 or container.size.y <= 0.0:
		return false
	if candidate.size.x <= 0.0 or candidate.size.y <= 0.0:
		return false
	var clipped := container.intersection(candidate)
	return is_equal_approx(clipped.size.x, candidate.size.x) and is_equal_approx(clipped.size.y, candidate.size.y)
