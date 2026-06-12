extends RefCounted
class_name MainMenuTextureApplier


static func apply(paths: Dictionary, nodes: Dictionary, element_icons: Array, stat_icons: Array) -> void:
	(nodes.get("background_texture") as TextureRect).texture = _safe_load_texture(String(paths.get("background", "")), "main_menu_background")
	(nodes.get("logo_texture") as TextureRect).texture = _safe_load_texture(String(paths.get("logo", "")), "main_menu_logo")
	(nodes.get("outer_border_texture") as TextureRect).texture = _safe_load_texture(String(paths.get("outer_border", "")), "main_menu_outer_border")
	_safe_load_texture(String(paths.get("stats_panel", "")), "main_menu_stats_panel")

	var element_paths: Array = Array(paths.get("element_icons", []))
	for i in mini(element_icons.size(), element_paths.size()):
		(element_icons[i] as TextureRect).texture = _safe_load_texture(String(element_paths[i]), "element_%d" % i)

	var stat_paths: Array = Array(paths.get("stat_icons", []))
	for i in mini(stat_icons.size(), stat_paths.size()):
		(stat_icons[i] as TextureRect).texture = _safe_load_texture(String(stat_paths[i]), "stat_%d" % i)

	var footer_paths: Array = Array(paths.get("footer_icons", []))
	var footer_buttons: Array = Array(nodes.get("footer_buttons", []))
	for i in mini(footer_buttons.size(), footer_paths.size()):
		(footer_buttons[i] as Button).icon = null


static func _safe_load_texture(path: String, missing_key: String) -> Texture2D:
	if path == "" or not ResourceLoader.exists(path):
		push_warning("Main menu missing texture for %s at %s" % [missing_key, path])
		return null
	var loaded: Variant = load(path)
	if loaded is Texture2D:
		return loaded as Texture2D
	push_warning("Main menu invalid texture for %s at %s" % [missing_key, path])
	return null
