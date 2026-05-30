extends RefCounted
class_name TopHeaderContractProbe

const TOP_HEADER_SCENE_PATH := "res://scenes/ui/top_header.tscn"
const TOP_HEADER_SCRIPT_PATH := "res://scripts/ui/top_header.gd"
const COMBAT_SCENE_PATH := "res://scenes/combat.tscn"
const SHOP_VIEW_SCRIPT_PATH := "res://scripts/shop/shop_view.gd"
const COMBAT_LAYOUT_PRESENTER_SCRIPT := preload("res://scripts/combat/combat_layout_presenter.gd")
const TOP_HEADER_SCRIPT := preload(TOP_HEADER_SCRIPT_PATH)
const SHOP_VIEW_SCRIPT := preload(SHOP_VIEW_SCRIPT_PATH)
const SHARED_TOP_HEADER_RECT := Rect2(Vector2(16, 8), Vector2(1048, 116))

const REQUIRED_SHARED_NODE_NAMES := [
	"TitleLabel",
	"GoldPill",
	"GoldLabel",
	"HelpButton",
	"SettingsButton",
	"MainMenuButton",
	"CrestPanel",
	"CrestLabel",
	"RunProgressLabel",
	"EnemyStepLabel",
	"DebugToggleButton",
]


static func run_probe() -> Dictionary:
	var failures: Array[String] = []
	_check_shared_scene_tree(failures)
	_check_combat_instances_shared_scene(failures)
	_check_shop_instances_shared_scene(failures)
	_check_layout_probe_uses_shared_geometry(failures)
	return {
		"status": "ok" if failures.is_empty() else "failed",
		"failures": failures,
	}


static func run_all() -> Dictionary:
	var report := run_probe()
	var failures: Array[String] = []
	for failure in Array(report.get("failures", [])):
		failures.append(String(failure))
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


static func _check_shared_scene_tree(failures: Array[String]) -> void:
	var packed := ResourceLoader.load(TOP_HEADER_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		failures.append("Shared TopHeader scene failed to load: %s" % TOP_HEADER_SCENE_PATH)
		return
	var header := packed.instantiate()
	if header.scene_file_path != TOP_HEADER_SCENE_PATH:
		failures.append("TopHeader scene_file_path mismatch: %s" % header.scene_file_path)
	for node_name in REQUIRED_SHARED_NODE_NAMES:
		if header.get_node_or_null("%s%s" % ["%", node_name]) == null:
			failures.append("Shared TopHeader scene is missing node: %s" % node_name)
	if header.get_script() == null or header.get_script().resource_path != TOP_HEADER_SCRIPT_PATH:
		failures.append("Shared TopHeader scene must use script: %s" % TOP_HEADER_SCRIPT_PATH)
	header.free()


static func _check_combat_instances_shared_scene(failures: Array[String]) -> void:
	var packed := ResourceLoader.load(COMBAT_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		failures.append("Combat scene failed to load: %s" % COMBAT_SCENE_PATH)
		return
	var combat := packed.instantiate()
	var header := combat.get_node_or_null("CombatLayoutRoot/TopBar")
	if header == null:
		failures.append("Combat scene is missing CombatLayoutRoot/TopBar")
	elif header.scene_file_path != TOP_HEADER_SCENE_PATH:
		failures.append("Combat TopBar must instance %s, got %s" % [TOP_HEADER_SCENE_PATH, header.scene_file_path])
	combat.free()


static func _check_shop_instances_shared_scene(failures: Array[String]) -> void:
	var scene_path := String(SHOP_VIEW_SCRIPT.top_header_scene_path())
	if scene_path != TOP_HEADER_SCENE_PATH:
		failures.append("Shop TopBar must instance %s, got %s" % [TOP_HEADER_SCENE_PATH, scene_path])
	_check_shop_layout_probe_uses_shared_geometry(failures)


static func _check_shop_layout_probe_uses_shared_geometry(failures: Array[String]) -> void:
	var shop_probe: Dictionary = SHOP_VIEW_SCRIPT.shop_layout_probe_snapshot()
	var top_bar_rect: Rect2 = shop_probe.get("top_bar", Rect2())
	if top_bar_rect != SHARED_TOP_HEADER_RECT:
		failures.append("Shop TopBar rect must match shared top header rect")
	var top_controls: Dictionary = shop_probe.get("top_controls", {})
	var expected_controls: Dictionary = TOP_HEADER_SCRIPT.layout_snapshot_for(Rect2(Vector2.ZERO, top_bar_rect.size))
	for key in ["title", "gold_counter", "help_button", "settings_button"]:
		if top_controls.get(key, Rect2()) != expected_controls.get(key, Rect2()):
			failures.append("Shop layout probe must use shared TopHeader geometry for %s" % key)


static func _check_layout_probe_uses_shared_geometry(failures: Array[String]) -> void:
	var combat_probe: Dictionary = COMBAT_LAYOUT_PRESENTER_SCRIPT.build_layout_probe(Vector2(1080, 1920))
	var combat_primary: Dictionary = Dictionary(Dictionary(combat_probe.get("zone_rects", {})).get("primary", {}))
	var combat_header_rect: Rect2 = combat_primary.get("top_bar", Rect2())
	if combat_header_rect != SHARED_TOP_HEADER_RECT:
		failures.append("Combat and shop top header rects must match exactly")
	var shared_combat_controls: Dictionary = TOP_HEADER_SCRIPT.layout_snapshot_for(combat_header_rect)
	var combat_segments: Dictionary = Dictionary(Dictionary(combat_probe.get("zone_rects", {})).get("player_hud_internals", {}))
	var expected_pairs := {
		"top_title": shared_combat_controls.get("title", Rect2()),
		"top_gold": shared_combat_controls.get("gold_counter", Rect2()),
		"top_help": shared_combat_controls.get("help_button", Rect2()),
		"top_settings": shared_combat_controls.get("settings_button", Rect2()),
	}
	for key in expected_pairs.keys():
		if combat_segments.get(key, Rect2()) != expected_pairs[key]:
			failures.append("Combat layout probe must use shared TopHeader geometry for %s" % key)
