extends RefCounted
class_name CombatControllerPresentationDriver

const VISUAL_CHROME_CONFIG := {
	"font_size_title": 20,
	"font_size_value": 18,
	"font_size_meta": 15,
	"font_size_row_label": 16,
	"debug_text_font_size": 24,
	"debug_input_font_size": 24,
	"debug_input_height": 72.0,
}


static func play_resolve_animations(
	resolve_presenter: Variant, result: Dictionary, visual_board_model: BoardModel, resolve_trace_origin_usec: int, callbacks: Dictionary
) -> void:
	if int(result.get("total_combos", 0)) <= 0 or resolve_presenter == null:
		return
	await resolve_presenter.play_resolve_animations(result, visual_board_model, resolve_trace_origin_usec, callbacks)


static func wait_combat_speed(resolve_presenter: Variant, host: Variant, base_seconds: float) -> void:
	if resolve_presenter != null:
		await resolve_presenter.wait_combat_speed(base_seconds)
		return
	var tree: SceneTree = host.get_tree() if host != null else null
	if tree == null:
		return
	if base_seconds <= 0.01:
		await tree.process_frame
		return
	await tree.create_timer(base_seconds).timeout


static func can_continue_after_async_wait(host: Variant, board_view: Variant, require_board_view: bool = false) -> bool:
	if not (host != null and is_instance_valid(host) and host.is_inside_tree()):
		return false
	if host.get_tree() == null:
		return false
	if require_board_view and (board_view == null or not is_instance_valid(board_view)):
		return false
	return true


static func apply_orb_texture_map(board_view: Variant, visuals: Variant, run_state: Variant, route_id_callback: Callable) -> void:
	if board_view == null or visuals == null:
		return
	(
		board_view
		. set_orb_texture_map(
			{
				OrbType.Id.FIRE: visuals.orb_texture(OrbType.Id.FIRE),
				OrbType.Id.ICE: visuals.orb_texture(OrbType.Id.ICE),
				OrbType.Id.EARTH: visuals.orb_texture(OrbType.Id.EARTH),
				OrbType.Id.HEART: visuals.orb_texture(OrbType.Id.HEART),
				OrbType.Id.ARMOR: visuals.orb_texture(OrbType.Id.ARMOR),
				OrbType.Id.GOLD: visuals.orb_texture(OrbType.Id.GOLD),
			}
		)
	)
	var route_id := String(route_id_callback.call()) if route_id_callback.is_valid() else ""
	run_state.flow_trace_mark("combat_after_texture_map", {}, route_id)


static func apply_visual_chrome(view: Variant, run_state: Variant) -> void:
	if view == null:
		return
	view.apply_visual_chrome(VISUAL_CHROME_CONFIG)
	view.set_top_bar_text(run_state.level_sequence_label(), "Gold 0")


static func apply_combat_layout(
	view: Variant,
	host: Variant,
	combat_timer_service: Variant,
	board_controller: Variant,
	player_state: Variant,
	tutorial_prompt_presenter: Variant,
	locked_timer_state: String
) -> void:
	if view == null or host == null:
		return
	var layout_result: Dictionary = view.apply_combat_layout(
		host.get_viewport_rect().size,
		combat_timer_service.layout_timer_seconds(board_controller, player_state) if combat_timer_service != null else 0.0,
		combat_timer_service.layout_timer_state(board_controller) if combat_timer_service != null else locked_timer_state
	)
	if not bool(layout_result.get("applied", false)):
		return
	if tutorial_prompt_presenter != null and tutorial_prompt_presenter.is_visible():
		tutorial_prompt_presenter.layout()
