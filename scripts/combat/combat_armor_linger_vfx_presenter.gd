extends RefCounted
class_name CombatArmorLingerVfxPresenter

const POST_MATCH_BAR_LINGER_Z_INDEX := 131

var _runtime_sprite_presenter: Variant
var _runtime_primitive_presenter: Variant


func bind(dependencies: Dictionary) -> void:
	_runtime_sprite_presenter = dependencies.get("runtime_sprite_presenter")
	_runtime_primitive_presenter = dependencies.get("runtime_primitive_presenter")


func spawn_armor_linger(center_local: Vector2, draw_size: Vector2, lifetime: float, intensity: int) -> void:
	var board_extent := maxf(180.0, maxf(draw_size.x, draw_size.y))
	var shell_size := Vector2(board_extent, board_extent) * (1.08 + float(intensity) * 0.020)
	_spawn_hex_grid(center_local, shell_size, lifetime, intensity)
	_spawn_edge_snap_bars(center_local, shell_size, lifetime, intensity)


func _spawn_hex_grid(center_local: Vector2, shell_size: Vector2, lifetime: float, intensity: int) -> void:
	var cell_size := maxf(50.0, shell_size.x * (0.24 + float(intensity) * 0.006))
	var gap := cell_size * 0.82
	var start := Vector2(-gap, -gap)
	for row in range(3):
		for column in range(3):
			var index := row * 3 + column
			var offset := start + Vector2(float(column) * gap + (cell_size * 0.28 if row % 2 == 1 else 0.0), float(row) * gap)
			var delay := lifetime * (0.04 + float(abs(row - 1) + abs(column - 1)) * 0.036 + float(index % 2) * 0.015)
			_spawn_runtime_sprite_local(
				"ArmorGridHexCell",
				"hex_cell",
				center_local + offset,
				Vector2(cell_size, cell_size * 1.12),
				Color(0.86, 0.98, 1.0, 0.84),
				lifetime * 0.90,
				Vector2(1.12, 1.12),
				delay,
				Vector2.ZERO,
				0.0,
				POST_MATCH_BAR_LINGER_Z_INDEX + 8,
				PI / 6.0
			)


func _spawn_edge_snap_bars(center_local: Vector2, shell_size: Vector2, lifetime: float, intensity: int) -> void:
	var half := shell_size * 0.50
	var bar_length := shell_size.x * (0.78 + float(intensity) * 0.012)
	var bar_thickness := maxf(9.0, 7.0 + float(intensity) * 1.0)
	var specs := [
		{"offset": Vector2(0.0, -half.y), "rotation": 0.0, "move": Vector2(0.0, 24.0)},
		{"offset": Vector2(0.0, half.y), "rotation": 0.0, "move": Vector2(0.0, -24.0)},
		{"offset": Vector2(-half.x, 0.0), "rotation": PI * 0.5, "move": Vector2(24.0, 0.0)},
		{"offset": Vector2(half.x, 0.0), "rotation": PI * 0.5, "move": Vector2(-24.0, 0.0)},
	]
	for i in range(specs.size()):
		var spec: Dictionary = specs[i]
		_spawn_runtime_sprite_local(
			"ArmorGridSnapBar",
			"ray",
			center_local + Vector2(spec.get("offset", Vector2.ZERO)),
			Vector2(bar_length, bar_thickness),
			Color(0.92, 0.99, 1.0, 0.92),
			lifetime * 0.52,
			Vector2(0.82, 0.58),
			lifetime * (0.05 + float(i) * 0.025),
			Vector2(spec.get("move", Vector2.ZERO)),
			0.0,
			POST_MATCH_BAR_LINGER_Z_INDEX + 9,
			float(spec.get("rotation", 0.0))
		)


func _spawn_runtime_sprite_local(name: String, texture_key: String, center_local: Vector2, draw_size: Vector2, color: Color, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, z_index: int = POST_MATCH_BAR_LINGER_Z_INDEX, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> TextureRect:
	if _runtime_sprite_presenter == null:
		return null
	return _runtime_sprite_presenter.spawn_sprite_local(name, texture_key, center_local, draw_size, color, lifetime, target_scale, delay, move_offset, spin, z_index, rotation, move_ease)


func _spawn_local_effect_panel(name: String, center_local: Vector2, size: Vector2, fill: Color, border: Color, border_width: int, corner_radius: int, z_index: int, lifetime: float, target_scale: Vector2, delay: float = 0.0, move_offset: Vector2 = Vector2.ZERO, spin: float = 0.0, rotation: float = 0.0, move_ease: Tween.EaseType = Tween.EASE_OUT as Tween.EaseType) -> void:
	if _runtime_primitive_presenter == null:
		return
	_runtime_primitive_presenter.spawn_local_effect_panel(name, center_local, size, fill, border, border_width, corner_radius, z_index, lifetime, target_scale, delay, move_offset, spin, rotation, move_ease)
