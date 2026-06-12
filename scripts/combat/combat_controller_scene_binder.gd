extends RefCounted
class_name CombatControllerSceneBinder


static func bind_scene(controller: Object, host: Control, root_nodes: Dictionary, model: Variant, view: Variant) -> Dictionary:
	var resolved_model: Variant = model
	if resolved_model == null:
		resolved_model = CombatModel.new()
	var resolved_view: Variant = view
	if resolved_model != null:
		resolved_model.set_combat_speed(resolved_model.combat_speed())
	if resolved_view != null:
		resolved_view.bind(root_nodes)
	for node_name in root_nodes.keys():
		if node_name in controller:
			controller.set(node_name, root_nodes[node_name])
	return {
		"host": host,
		"model": resolved_model,
		"view": resolved_view,
		"board_view": resolve_board_view(host, controller.get("_board")),
	}


static func resolve_board_view(host: Control, board: Control) -> BoardView:
	if board != null and is_instance_valid(board):
		var board_scene_unique: Node = board.get_node_or_null("%BoardView")
		if board_scene_unique is BoardView:
			return board_scene_unique as BoardView
		var board_scene_path: Node = board.get_node_or_null("BoardFrame/BoardAspect/BoardView")
		if board_scene_path is BoardView:
			return board_scene_path as BoardView
	if host != null:
		var absolute_path: Node = host.get_node_or_null("CombatLayoutRoot/BoardPanel/Board/BoardFrame/BoardAspect/BoardView")
		if absolute_path is BoardView:
			return absolute_path as BoardView
	push_error("CombatPlayerController: unable to resolve BoardView under CombatLayoutRoot/BoardPanel/Board.")
	return null
