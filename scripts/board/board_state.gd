extends RefCounted
class_name BoardState

const COLUMN_COUNT := 5
const ROW_COUNT := 6
const CELL_COUNT := COLUMN_COUNT * ROW_COUNT

var rng_seed: int = 0
var generation_settings: BoardGenerationSettings

var _rng := RandomNumberGenerator.new()
var _cells := PackedInt32Array()
var _weights := PackedFloat32Array()


func _init() -> void:
	_cells.resize(CELL_COUNT)
	for index in CELL_COUNT:
		_cells[index] = OrbType.Id.FIRE
	generation_settings = BoardGenerationSettings.new()
	_weights = generation_settings.normalized_weights()


func initialize(new_seed: int, settings: BoardGenerationSettings = null) -> void:
	rng_seed = new_seed
	if settings != null:
		generation_settings = settings
	else:
		generation_settings = BoardGenerationSettings.new()

	_weights = generation_settings.normalized_weights()
	_rng.seed = rng_seed
	_generate_starting_board_without_matches()


func clone() -> BoardState:
	var copy := BoardState.new()
	copy.rng_seed = rng_seed
	copy.generation_settings = generation_settings
	copy._weights = _weights.duplicate()
	copy._cells = _cells.duplicate()
	copy._rng.state = _rng.state
	return copy


func in_bounds(column: int, row: int) -> bool:
	return column >= 0 and column < COLUMN_COUNT and row >= 0 and row < ROW_COUNT


func get_cell(column: int, row: int) -> int:
	if not in_bounds(column, row):
		push_error("BoardState.get_cell out of bounds: (%d, %d)" % [column, row])
		return -1
	return _cells[_index(column, row)]


func set_cell(column: int, row: int, orb_id: int) -> void:
	if not in_bounds(column, row):
		push_error("BoardState.set_cell out of bounds: (%d, %d)" % [column, row])
		return
	if not OrbType.is_valid_id(orb_id):
		push_error("BoardState.set_cell invalid orb id: %d" % orb_id)
		return
	_cells[_index(column, row)] = orb_id


func swap_cells(column_a: int, row_a: int, column_b: int, row_b: int) -> bool:
	if not in_bounds(column_a, row_a) or not in_bounds(column_b, row_b):
		push_error("BoardState.swap_cells out of bounds: (%d, %d) <-> (%d, %d)" % [
			column_a,
			row_a,
			column_b,
			row_b,
		])
		return false

	var index_a := _index(column_a, row_a)
	var index_b := _index(column_b, row_b)
	var temp := _cells[index_a]
	_cells[index_a] = _cells[index_b]
	_cells[index_b] = temp
	return true


func regenerate(new_seed: int = -1) -> void:
	if new_seed >= 0:
		rng_seed = new_seed
	else:
		rng_seed = int(Time.get_ticks_usec())
	_rng.seed = rng_seed
	_generate_starting_board_without_matches()


func to_debug_string() -> String:
	var lines: Array[String] = []
	for row in ROW_COUNT:
		var row_symbols: Array[String] = []
		for column in COLUMN_COUNT:
			row_symbols.append(OrbType.debug_symbol(get_cell(column, row)))
		lines.append(" ".join(row_symbols))
	return "\n".join(lines)


func has_any_match() -> bool:
	# If any line of 3+ exists, the board already contains an automatic match.
	for row in ROW_COUNT:
		var run_orb := get_cell(0, row)
		var run_length := 1
		for column in range(1, COLUMN_COUNT):
			var next_orb := get_cell(column, row)
			if next_orb == run_orb:
				run_length += 1
				if run_length >= 3:
					return true
			else:
				run_orb = next_orb
				run_length = 1

	for column in COLUMN_COUNT:
		var run_orb := get_cell(column, 0)
		var run_length := 1
		for row in range(1, ROW_COUNT):
			var next_orb := get_cell(column, row)
			if next_orb == run_orb:
				run_length += 1
				if run_length >= 3:
					return true
			else:
				run_orb = next_orb
				run_length = 1

	return false


func _generate_starting_board_without_matches() -> void:
	for row in ROW_COUNT:
		for column in COLUMN_COUNT:
			_cells[_index(column, row)] = _roll_orb_without_local_match(column, row)


func _roll_orb_without_local_match(column: int, row: int) -> int:
	var excluded_orbs := {}
	if column >= 2:
		var left_1 := get_cell(column - 1, row)
		var left_2 := get_cell(column - 2, row)
		if left_1 == left_2:
			excluded_orbs[left_1] = true
	if row >= 2:
		var up_1 := get_cell(column, row - 1)
		var up_2 := get_cell(column, row - 2)
		if up_1 == up_2:
			excluded_orbs[up_1] = true

	return _roll_weighted_orb(excluded_orbs)


func _roll_weighted_orb(excluded_orbs: Dictionary) -> int:
	var total := 0.0
	for orb_id in OrbType.ALL_TYPES:
		if excluded_orbs.has(orb_id):
			continue
		total += _weights[orb_id]

	if total <= 0.0:
		# Should never happen with six orb types and only line-of-3 prevention, but keep a safe fallback.
		return OrbType.ALL_TYPES[_rng.randi_range(0, OrbType.ALL_TYPES.size() - 1)]

	var roll := _rng.randf_range(0.0, total)
	var cumulative := 0.0
	for orb_id in OrbType.ALL_TYPES:
		if excluded_orbs.has(orb_id):
			continue
		cumulative += _weights[orb_id]
		if roll <= cumulative:
			return orb_id

	return OrbType.Id.FIRE


func _index(column: int, row: int) -> int:
	return row * COLUMN_COUNT + column
