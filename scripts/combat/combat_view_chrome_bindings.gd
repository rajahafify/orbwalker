extends RefCounted
class_name CombatViewChromeBindings


static func apply_visual_chrome(chrome_styler_script: Variant, root_nodes: Dictionary, extras: Dictionary, style_config: Dictionary) -> void:
	chrome_styler_script.apply_visual_chrome(chrome_styler_script.nodes_from_root_nodes(root_nodes, extras), style_config)


static func apply_zone_guides(chrome_styler_script: Variant, zones: Dictionary, enabled: bool) -> void:
	for label_text in zones.keys():
		chrome_styler_script.apply_zone_guide(zones[label_text], String(label_text), enabled)
