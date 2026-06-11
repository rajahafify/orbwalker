extends Resource
class_name VisualRegistryOrbCatalog

const ORB_TYPE_SCRIPT := preload("res://scripts/board/orb_type.gd")

const DEFAULT_ORB_RECORDS := [
	{"orb_id": ORB_TYPE_SCRIPT.Id.FIRE, "runtime_key": "fire", "derived_filename": "orb_fire_clean.png"},
	{"orb_id": ORB_TYPE_SCRIPT.Id.ICE, "runtime_key": "ice", "derived_filename": "orb_ice_clean.png"},
	{"orb_id": ORB_TYPE_SCRIPT.Id.EARTH, "runtime_key": "earth", "derived_filename": "orb_earth_clean.png"},
	{"orb_id": ORB_TYPE_SCRIPT.Id.HEART, "runtime_key": "heart", "derived_filename": "orb_heart_clean.png"},
	{"orb_id": ORB_TYPE_SCRIPT.Id.ARMOR, "runtime_key": "armor", "derived_filename": "orb_armor_clean.png"},
	{"orb_id": ORB_TYPE_SCRIPT.Id.GOLD, "runtime_key": "gold", "derived_filename": "orb_gold_clean.png"},
]

@export var orb_records: Array[Dictionary] = []

var _runtime_orb_key_by_id := {}
var _derived_orb_filename_by_id := {}

static var _default_catalog: Resource


func _init(records: Array = []) -> void:
	orb_records.clear()
	var source_records := records if not records.is_empty() else DEFAULT_ORB_RECORDS
	for record in source_records:
		orb_records.append(Dictionary(record).duplicate(true))
	_rebuild_indexes()


static func default_catalog() -> Resource:
	if _default_catalog == null:
		_default_catalog = load("res://scripts/ui/visual_registry_orb_catalog.gd").new()
	return _default_catalog


static func runtime_orb_key_by_id() -> Dictionary:
	return default_catalog().get_runtime_orb_key_by_id()


static func derived_orb_filename_by_id() -> Dictionary:
	return default_catalog().get_derived_orb_filename_by_id()


static func derived_orb_filename_count() -> int:
	return default_catalog().get_derived_orb_filename_count()


static func record_count() -> int:
	return default_catalog().orb_records.size()


func get_runtime_orb_key_by_id() -> Dictionary:
	return _runtime_orb_key_by_id


func get_derived_orb_filename_by_id() -> Dictionary:
	return _derived_orb_filename_by_id


func get_derived_orb_filename_count() -> int:
	return _derived_orb_filename_by_id.size()


func _rebuild_indexes() -> void:
	_runtime_orb_key_by_id.clear()
	_derived_orb_filename_by_id.clear()
	for record in orb_records:
		var orb_id := int(record.get("orb_id", -1))
		if orb_id < 0:
			continue
		var runtime_key := String(record.get("runtime_key", ""))
		if runtime_key != "":
			_runtime_orb_key_by_id[orb_id] = runtime_key
		var derived_filename := String(record.get("derived_filename", ""))
		if derived_filename != "":
			_derived_orb_filename_by_id[orb_id] = derived_filename
