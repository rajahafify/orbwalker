extends RefCounted
class_name CombatViewVfxBindings


static func presenter_target_global(player_hud_presenter: Variant, node_key: String, vertical_bias: float) -> Vector2:
	if player_hud_presenter == null:
		return Vector2.ZERO
	return player_hud_presenter.vfx_target_global(node_key, vertical_bias)


static func presenter_size(player_hud_presenter: Variant, node_key: String) -> Vector2:
	if player_hud_presenter == null:
		return Vector2.ZERO
	return player_hud_presenter.vfx_size(node_key)


static func board_target_global(board: Control, board_panel: Control) -> Vector2:
	return control_center_global(board if board != null else board_panel)


static func board_fullscreen_size(vfx_layer: Control, board: Control, board_panel: Control) -> Vector2:
	var layer_size := Vector2.ZERO
	if vfx_layer != null:
		layer_size = vfx_layer.get_global_rect().size
	var board_size := Vector2.ZERO
	var board_control := board if board != null else board_panel
	if board_control != null:
		board_size = board_control.get_global_rect().size
	return Vector2(maxf(layer_size.x, board_size.x * 1.55), maxf(layer_size.y, board_size.y * 1.55))


static func vfx_presenter_bindings(
	vfx_layer: Control,
	visuals: Variant,
	player_loadout_hud: Variant,
	elemental_mastery_cards: Control,
	layout_root: Control,
	visual_registry: Variant,
	player_loadout_hud_override: Variant,
	timer_owner: Node
) -> Dictionary:
	var resolved_visual_registry: Variant = visual_registry if visual_registry != null else visuals
	var resolved_player_loadout_hud: Variant = player_loadout_hud_override if player_loadout_hud_override != null else player_loadout_hud
	return {
		"vfx_layer": vfx_layer,
		"visual_registry": resolved_visual_registry,
		"player_loadout_hud": resolved_player_loadout_hud,
		"elemental_mastery_cards": elemental_mastery_cards,
		"timer_owner": timer_owner,
		"shake_target": layout_root,
	}


static func resolve_presenter_bindings(
	board: Control,
	board_view: BoardView,
	board_panel: Control,
	board_controller: Variant,
	timer_owner: Node,
	spawn_vfx_texture_callback: Callable,
	combo_sound_callback: Callable
) -> Dictionary:
	return {
		"board": board,
		"board_view": board_view,
		"board_panel": board_panel,
		"board_controller": board_controller,
		"timer_owner": timer_owner,
		"spawn_vfx_texture_callback": spawn_vfx_texture_callback,
		"combo_sound_callback": combo_sound_callback,
	}


static func control_center_global(control: Control) -> Vector2:
	if control == null:
		return Vector2.ZERO
	var rect := control.get_global_rect()
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return Vector2.ZERO
	return rect.position + rect.size * 0.5
