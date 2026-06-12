extends RefCounted
class_name DebugVfxGalleryTest

const CATALOG_SCRIPT := preload("res://scripts/debug/vfx_debug_catalog.gd")
const SHOW_CONTROLS_SCRIPT := preload("res://scripts/debug/vfx_gallery_show_controls.gd")
const INDEX_SCENE_PATH := "res://scenes/debug/vfx_gallery_index.tscn"
const SHOW_SCENE_PATH := "res://scenes/debug/vfx_gallery_show.tscn"


class CallbackProbe:
	extends RefCounted

	var play_count := 0
	var selected_index := -1

	func play() -> void:
		play_count += 1

	func select(index: int) -> void:
		selected_index = index


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("catalog_entries_are_valid", _test_catalog_entries_are_valid, failures)
	_run_case("catalog_ids_are_unique", _test_catalog_ids_are_unique, failures)
	_run_case("debug_gallery_scenes_load", _test_debug_gallery_scenes_load, failures)
	_run_case("show_controls_build_contract", _test_show_controls_build_contract, failures)
	return {
		"passed": failures.is_empty(),
		"total": 4,
		"failed": failures.size(),
		"failures": failures,
	}


func _run_case(case_name: String, callable: Callable, failures: Array[String]) -> void:
	var result: Variant = callable.call()
	if not (result is String):
		failures.append("%s: Test case aborted or returned %s instead of String." % [case_name, type_string(typeof(result))])
		return
	var error_text := String(result)
	if error_text != "":
		failures.append("%s: %s" % [case_name, error_text])


func _test_catalog_entries_are_valid() -> String:
	var entries := CATALOG_SCRIPT.entries()
	if entries.is_empty():
		return "Expected at least one VFX gallery entry."
	for entry in entries:
		var entry_id := String(entry.get("id", ""))
		if entry_id == "":
			return "Expected every entry to have an id."
		if String(entry.get("name", "")) == "":
			return "Expected %s to have a display name." % entry_id
		if String(entry.get("category", "")) == "":
			return "Expected %s to have a category." % entry_id
		if String(entry.get("entry_point", "")) == "":
			return "Expected %s to have an entry point." % entry_id
		if String(entry.get("target", "")) == "":
			return "Expected %s to have a target." % entry_id
		if int(entry.get("default_amount", 0)) <= 0:
			return "Expected %s to have a positive default amount." % entry_id
		var phases := CATALOG_SCRIPT.phases_for_entry(entry)
		if phases.is_empty():
			return "Expected %s to expose at least one playback phase." % entry_id
	return ""


func _test_catalog_ids_are_unique() -> String:
	var seen := {}
	for entry in CATALOG_SCRIPT.entries():
		var entry_id := String(entry.get("id", ""))
		if seen.has(entry_id):
			return "Duplicate VFX gallery entry id: %s." % entry_id
		seen[entry_id] = true
	return ""


func _test_debug_gallery_scenes_load() -> String:
	for scene_path in [INDEX_SCENE_PATH, SHOW_SCENE_PATH]:
		if not ResourceLoader.exists(scene_path):
			return "Expected debug gallery scene at %s." % scene_path
		var scene := load(scene_path) as PackedScene
		if scene == null:
			return "Expected debug gallery scene to load at %s." % scene_path
		var instance := scene.instantiate()
		if instance == null:
			return "Expected debug gallery scene to instantiate at %s." % scene_path
		instance.free()
	return ""


func _test_show_controls_build_contract() -> String:
	var owner := Control.new()
	var probe := CallbackProbe.new()
	var nodes: Dictionary = (
		SHOW_CONTROLS_SCRIPT
		. build(
			owner,
			{
				"restart_playback": probe.play,
				"entry_selected": probe.select,
			}
		)
	)
	for key in [
		"entry_select",
		"phase_select",
		"quality_select",
		"amount_slider",
		"amount_spin",
		"speed_slider",
		"loop_toggle",
		"anchors_toggle",
		"clean_toggle",
		"play_button",
		"preset_row",
		"status_label",
		"description_label",
		"preview_root",
	]:
		if not nodes.has(key):
			owner.free()
			return "Expected VFX gallery controls to expose node key: %s." % key
	var play_button := nodes["play_button"] as Button
	play_button.pressed.emit()
	if probe.play_count != 1:
		owner.free()
		return "Expected play button to call restart callback."
	var entry_select := nodes["entry_select"] as OptionButton
	entry_select.item_selected.emit(3)
	if probe.selected_index != 3:
		owner.free()
		return "Expected entry select to call selected callback."
	var preview_root := nodes["preview_root"] as Control
	if preview_root == null or not preview_root.clip_contents:
		owner.free()
		return "Expected preview root to clip VFX preview contents."
	owner.free()
	return ""
