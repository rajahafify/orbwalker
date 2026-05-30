extends RefCounted
class_name BoardResolverPerformanceTest

const BOARD_MATCH_RESOLVER_SCRIPT := preload("res://scripts/board/board_match_resolver_service.gd")
const ITERATIONS := 180
const WARMUP_ITERATIONS := 20
const MAX_STEPS := 32
const AVERAGE_BUDGET_USEC := 3000
const P95_BUDGET_USEC := 8000
const MAX_SAMPLE_BUDGET_USEC := 16000

const REPRESENTATIVE_BOARDS := [
	[
		"FFFIA",
		"HAGEI",
		"IFAHG",
		"EGAIH",
		"AHIGE",
		"GEAHI",
	],
	[
		"FIAGE",
		"FIHAE",
		"FGEAI",
		"AHIEG",
		"EGAHI",
		"IAEHG",
	],
	[
		"IFIAE",
		"FFFHG",
		"IFGAH",
		"AEHIG",
		"HIAEG",
		"EGAHI",
	],
	[
		"FFFIA",
		"EEEHG",
		"AAAGI",
		"HHHIA",
		"GGGAE",
		"IIIAH",
	],
]
const CASCADE_BOARD := [
	"HAGEI",
	"AHGEF",
	"IGAHE",
	"FIIAG",
	"FAHGF",
	"FIIEA",
]


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("representative_resolves_stay_within_budget", _test_representative_resolves_stay_within_budget, failures)
	_run_case("cascade_resolves_stay_within_budget", _test_cascade_resolves_stay_within_budget, failures)

	return {
		"passed": failures.is_empty(),
		"total": 2,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var error_text: String = callable.call()
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_representative_resolves_stay_within_budget() -> String:
	var stats := _measure_boards(REPRESENTATIVE_BOARDS, MAX_STEPS, ITERATIONS)
	return _assert_budget(stats, "representative resolves")


func _test_cascade_resolves_stay_within_budget() -> String:
	var stats := _measure_boards([CASCADE_BOARD], MAX_STEPS, ITERATIONS)
	var error_text := _assert_budget(stats, "cascade resolves")
	if error_text != "":
		return error_text
	if int(stats.get("max_passes", 0)) < 2:
		return "Expected cascade benchmark board to produce at least 2 passes."
	return ""


func _measure_boards(board_rows: Array, max_steps: int, iterations: int) -> Dictionary:
	var resolver: Variant = BOARD_MATCH_RESOLVER_SCRIPT.new()
	for warmup_index in WARMUP_ITERATIONS:
		resolver.resolve_all(_board_from_rows(Array(board_rows[warmup_index % board_rows.size()])), max_steps)

	var durations_usec: Array[int] = []
	var total_combos := 0
	var max_passes := 0
	for iteration in iterations:
		var board := _board_from_rows(Array(board_rows[iteration % board_rows.size()]))
		var start_usec := Time.get_ticks_usec()
		var result: Dictionary = resolver.resolve_all(board, max_steps)
		durations_usec.append(int(Time.get_ticks_usec() - start_usec))
		total_combos += int(result.get("total_combos", 0))
		max_passes = maxi(max_passes, Array(result.get("passes", [])).size())

	return _duration_stats(durations_usec, total_combos, max_passes)


func _duration_stats(durations_usec: Array[int], total_combos: int, max_passes: int) -> Dictionary:
	var sorted_durations := durations_usec.duplicate()
	sorted_durations.sort()
	var total_usec := 0
	for duration_usec in durations_usec:
		total_usec += duration_usec
	var average_usec := int(round(float(total_usec) / float(maxi(1, durations_usec.size()))))
	var p95_index := mini(sorted_durations.size() - 1, int(ceil(float(sorted_durations.size()) * 0.95)) - 1)
	return {
		"iterations": durations_usec.size(),
		"average_usec": average_usec,
		"p95_usec": sorted_durations[p95_index],
		"max_usec": sorted_durations[sorted_durations.size() - 1],
		"total_combos": total_combos,
		"max_passes": max_passes,
	}


func _assert_budget(stats: Dictionary, label: String) -> String:
	if int(stats.get("total_combos", 0)) <= 0:
		return "Expected %s benchmark to resolve at least one combo." % label
	var average_usec := int(stats.get("average_usec", 0))
	var p95_usec := int(stats.get("p95_usec", 0))
	var max_usec := int(stats.get("max_usec", 0))
	if average_usec > AVERAGE_BUDGET_USEC:
		return "%s average %dus exceeded budget %dus (%s)." % [label, average_usec, AVERAGE_BUDGET_USEC, _format_stats(stats)]
	if p95_usec > P95_BUDGET_USEC:
		return "%s p95 %dus exceeded budget %dus (%s)." % [label, p95_usec, P95_BUDGET_USEC, _format_stats(stats)]
	if max_usec > MAX_SAMPLE_BUDGET_USEC:
		return "%s max %dus exceeded budget %dus (%s)." % [label, max_usec, MAX_SAMPLE_BUDGET_USEC, _format_stats(stats)]
	return ""


func _format_stats(stats: Dictionary) -> String:
	return "avg=%dus p95=%dus max=%dus iterations=%d combos=%d passes=%d" % [
		int(stats.get("average_usec", 0)),
		int(stats.get("p95_usec", 0)),
		int(stats.get("max_usec", 0)),
		int(stats.get("iterations", 0)),
		int(stats.get("total_combos", 0)),
		int(stats.get("max_passes", 0)),
	]


func _board_from_rows(rows: Array) -> BoardModel:
	var board := BoardModel.new()
	board.initialize(123456)
	for row in rows.size():
		var row_text := String(rows[row])
		for column in mini(row_text.length(), BoardModel.COLUMN_COUNT):
			board.set_cell(column, row, _char_to_orb_id(row_text.substr(column, 1)))
	return board


func _char_to_orb_id(symbol: String) -> int:
	match symbol:
		"F":
			return OrbType.Id.FIRE
		"I":
			return OrbType.Id.ICE
		"E":
			return OrbType.Id.EARTH
		"H":
			return OrbType.Id.HEART
		"A":
			return OrbType.Id.ARMOR
		"G":
			return OrbType.Id.GOLD
		_:
			push_error("Unsupported board benchmark character: %s" % symbol)
			return OrbType.Id.FIRE
