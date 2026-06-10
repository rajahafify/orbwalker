extends RefCounted
class_name ShopViewNodeFactoryTest

const FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")


func run_all() -> Dictionary:
	var failures: Array[String] = []
	_run_case("make_controls_configures_common_defaults", _test_make_controls_configures_common_defaults, failures)
	_run_case("labels_apply_text_layout_and_theme", _test_labels_apply_text_layout_and_theme, failures)
	_run_case("dynamic_nodes_apply_rects", _test_dynamic_nodes_apply_rects, failures)
	_run_case("clear_children_removes_owned_nodes", _test_clear_children_removes_owned_nodes, failures)

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


func _test_make_controls_configures_common_defaults() -> String:
	var root := Control.new()
	var panel := FACTORY.make_panel("PanelA", root)
	var button := FACTORY.make_button("ButtonA", root, "Buy")
	var texture := FACTORY.make_texture("TextureA", root)
	var color_rect := FACTORY.make_color_rect("TintA", root, Color(0.1, 0.2, 0.3, 0.4))
	var child_root := FACTORY.make_root("RootA", root)
	var result := ""
	if panel.name != "PanelA" or panel.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		result = "Expected panel defaults to be applied."
	elif button.name != "ButtonA" or button.text != "Buy" or button.focus_mode != Control.FOCUS_NONE:
		result = "Expected button defaults to be applied."
	elif texture.name != "TextureA" or texture.expand_mode != TextureRect.EXPAND_IGNORE_SIZE or texture.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		result = "Expected texture defaults to be applied."
	elif color_rect.color != Color(0.1, 0.2, 0.3, 0.4) or color_rect.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		result = "Expected color rect defaults to be applied."
	elif child_root.name != "RootA" or child_root.mouse_filter != Control.MOUSE_FILTER_IGNORE:
		result = "Expected root control defaults to be applied."
	root.free()
	return result


func _test_labels_apply_text_layout_and_theme() -> String:
	var root := Control.new()
	var label := FACTORY.make_label("LabelA", root, "Hello", 24, Color.RED, HORIZONTAL_ALIGNMENT_CENTER, true)
	var result := ""
	if label.name != "LabelA" or label.text != "Hello":
		result = "Expected label name and text to be applied."
	elif label.horizontal_alignment != HORIZONTAL_ALIGNMENT_CENTER or label.autowrap_mode != TextServer.AUTOWRAP_WORD_SMART:
		result = "Expected label alignment and wrapping to be applied."
	elif label.get_theme_font_size("font_size") != 24 or label.get_theme_color("font_color") != Color.RED:
		result = "Expected label font theme overrides to be applied."
	root.free()
	return result


func _test_dynamic_nodes_apply_rects() -> String:
	var root := Control.new()
	var rect := Rect2(Vector2(12, 34), Vector2(56, 78))
	var panel := FACTORY.make_dynamic_panel(root, rect, StyleBoxEmpty.new())
	var label := FACTORY.make_dynamic_label(root, "Copy", rect, Color.WHITE, 18, HORIZONTAL_ALIGNMENT_LEFT, false)
	var card_root_parent := Control.new()
	card_root_parent.size = Vector2(90, 120)
	root.add_child(card_root_parent)
	var card_root := FACTORY.make_child_root(card_root_parent)
	var result := ""
	if panel.position != rect.position or panel.size != rect.size:
		result = "Expected dynamic panel rect to be applied."
	elif label.position != rect.position or label.size != rect.size or label.custom_minimum_size != rect.size:
		result = "Expected dynamic label rect to be applied."
	elif card_root.position != Vector2.ZERO or card_root.size != card_root_parent.size:
		result = "Expected child root to inherit parent size."
	root.free()
	return result


func _test_clear_children_removes_owned_nodes() -> String:
	var root := Control.new()
	FACTORY.make_root("ChildA", root)
	FACTORY.make_root("ChildB", root)
	if root.get_child_count() != 2:
		root.free()
		return "Expected setup to create two children."
	FACTORY.clear_children(root)
	var result := ""
	if root.get_child_count() != 0:
		result = "Expected clear_children to remove all children."
	root.free()
	return result
