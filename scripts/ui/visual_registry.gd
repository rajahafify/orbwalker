extends RefCounted
class_name VisualRegistry

const VISUAL_REGISTRY_BACKEND_SCRIPT := preload("res://scripts/ui/visual_registry_backend.gd")

var _backend: RefCounted = VISUAL_REGISTRY_BACKEND_SCRIPT.new()

static func asset_contract_paths() -> Dictionary:
	return VISUAL_REGISTRY_BACKEND_SCRIPT.asset_contract_paths()

static func lookup_table_alias_contract() -> Dictionary:
	var contract := VISUAL_REGISTRY_BACKEND_SCRIPT.lookup_table_alias_contract()
	var backend := VISUAL_REGISTRY_BACKEND_SCRIPT.new()
	contract["backend_is_refcounted"] = backend is RefCounted
	contract["backend_has_orb_texture"] = backend.has_method("orb_texture")
	contract["backend_has_placeholder_texture"] = backend.has_method("placeholder_texture")
	return contract

func backend_contract() -> Dictionary:
	return {
		"backend_is_refcounted": _backend is RefCounted,
		"backend_has_combat_background": _backend.has_method("combat_background"),
		"backend_has_orb_texture": _backend.has_method("orb_texture"),
		"backend_has_placeholder_texture": _backend.has_method("placeholder_texture"),
	}

func combat_background() -> Texture2D:
	return _backend.combat_background()

func shop_background() -> Texture2D:
	return _backend.shop_background()

func shop_merchant_header() -> Texture2D:
	return _backend.shop_merchant_header()

func enemy_portrait(enemy_id: String) -> Texture2D:
	return _backend.enemy_portrait(enemy_id)

func enemy_stage_background(enemy_id: String) -> Texture2D:
	return _backend.enemy_stage_background(enemy_id)

func enemy_sprite(enemy_id: String) -> Texture2D:
	return _backend.enemy_sprite(enemy_id)

func enemy_visual_profile(enemy_id: String) -> Dictionary:
	return _backend.enemy_visual_profile(enemy_id)

func combat_enemy_visual_debug_info(enemy_id: String) -> Dictionary:
	return _backend.combat_enemy_visual_debug_info(enemy_id)

func hero_portrait() -> Texture2D:
	return _backend.hero_portrait()

func orb_texture(orb_id: int) -> Texture2D:
	return _backend.orb_texture(orb_id)

func intent_badge(intent_type: int) -> Texture2D:
	return _backend.intent_badge(intent_type)

func rarity_badge(rarity: String) -> Texture2D:
	return _backend.rarity_badge(rarity)

func mastery_icon(orb_id: int) -> Texture2D:
	return _backend.mastery_icon(orb_id)

func menu_mastery_icon(orb_id: int) -> Texture2D:
	return _backend.menu_mastery_icon(orb_id)

func icon_for_key(icon_key: String) -> Texture2D:
	return _backend.icon_for_key(icon_key)

func mastery_beam_texture(orb_id: int) -> Texture2D:
	return _backend.mastery_beam_texture(orb_id)

func mastery_panel_frame_texture() -> Texture2D:
	return _backend.mastery_panel_frame_texture()

func mastery_card_texture(orb_id: int) -> Texture2D:
	return _backend.mastery_card_texture(orb_id)

func mastery_shell_texture() -> Texture2D:
	return _backend.mastery_shell_texture()

func mastery_impact_texture(kind: String) -> Texture2D:
	return _backend.mastery_impact_texture(kind)

func clean_icon_for_key(icon_key: String, use_placeholder: bool = true) -> Texture2D:
	return _backend.clean_icon_for_key(icon_key, use_placeholder)

func ui_frame_sheet() -> Texture2D:
	return _backend.ui_frame_sheet()

func ui_bar_sheet() -> Texture2D:
	return _backend.ui_bar_sheet()

func ui_shop_card_sheet() -> Texture2D:
	return _backend.ui_shop_card_sheet()

func hud_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	return _backend.hud_texture(key, use_placeholder)

func chrome_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	return _backend.chrome_texture(key, use_placeholder)

func collection_card_frame(rarity: String) -> Texture2D:
	return _backend.collection_card_frame(rarity)

func collection_relic_banner_frame(rarity: String) -> Texture2D:
	return _backend.collection_relic_banner_frame(rarity)

func collection_price_badge() -> Texture2D:
	return _backend.collection_price_badge()

func collection_hud_slot_frame() -> Texture2D:
	return _backend.collection_hud_slot_frame()

func shop_action_button_frame(kind: String) -> Texture2D:
	return _backend.shop_action_button_frame(kind)

func combat_ui_texture(key: String, use_placeholder: bool = true) -> Texture2D:
	return _backend.combat_ui_texture(key, use_placeholder)

func combat_backdrop_scrim_texture() -> Texture2D:
	return _backend.combat_backdrop_scrim_texture()

func combat_enemy_stage_texture(enemy_id: String) -> Texture2D:
	return _backend.combat_enemy_stage_texture(enemy_id)

func combat_intent_badge_texture(kind: String) -> Texture2D:
	return _backend.combat_intent_badge_texture(kind)

func combat_top_bar_frame_texture() -> Texture2D:
	return _backend.combat_top_bar_frame_texture()

func combat_enemy_panel_frame_texture() -> Texture2D:
	return _backend.combat_enemy_panel_frame_texture()

func combat_enemy_panel_texture() -> Texture2D:
	return _backend.combat_enemy_panel_texture()

func combat_board_frame_texture() -> Texture2D:
	return _backend.combat_board_frame_texture()

func combat_mastery_rail_frame_texture() -> Texture2D:
	return _backend.combat_mastery_rail_frame_texture()

func combat_mastery_rail_texture() -> Texture2D:
	return _backend.combat_mastery_rail_texture()

func combat_player_vitals_frame_texture() -> Texture2D:
	return _backend.combat_player_vitals_frame_texture()

func combat_equipment_rail_frame_texture() -> Texture2D:
	return _backend.combat_equipment_rail_frame_texture()

func combat_consumables_rail_frame_texture() -> Texture2D:
	return _backend.combat_consumables_rail_frame_texture()

func combat_slot_frame_texture(filled: bool) -> Texture2D:
	return _backend.combat_slot_frame_texture(filled)

func combat_player_hud_rail_texture() -> Texture2D:
	return _backend.combat_player_hud_rail_texture()

func combat_loadout_rail_texture() -> Texture2D:
	return _backend.combat_loadout_rail_texture()

func combat_block_badge_texture() -> Texture2D:
	return _backend.combat_block_badge_texture()

func combat_timer_track_texture() -> Texture2D:
	return _backend.combat_timer_track_texture()

func combat_timer_center_marker_texture() -> Texture2D:
	return _backend.combat_timer_center_marker_texture()

func combat_divider_texture() -> Texture2D:
	return _backend.combat_divider_texture()

func combat_corner_ornament_texture() -> Texture2D:
	return _backend.combat_corner_ornament_texture()

func clean_hud_texture(key: String) -> Texture2D:
	return _backend.clean_hud_texture(key)

func clean_chrome_texture(key: String) -> Texture2D:
	return _backend.clean_chrome_texture(key)

func vfx_texture(effect_name: String) -> Texture2D:
	return _backend.vfx_texture(effect_name)

func placeholder_texture(key: String, color: Color = Color(0.32, 0.32, 0.36, 1.0), size: Vector2i = Vector2i(96, 96)) -> Texture2D:
	return _backend.placeholder_texture(key, color, size)
