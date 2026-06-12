extends RefCounted
class_name MainMenuFocusNavigator


static func configure(main_controls: Array, profile_controls: Array, settings_controls: Array, settings_visible: bool, profile_overlay: Control) -> void:
	_apply_focus_chain(_focusable_buttons(main_controls))
	_apply_focus_chain(_focusable_buttons(profile_controls))
	_apply_focus_chain(_focusable_buttons(settings_controls))
	var start_run_button := main_controls.front() as Button if not main_controls.is_empty() else null
	if _can_grab_main_menu_focus(settings_visible, profile_overlay) and start_run_button != null and not start_run_button.disabled:
		start_run_button.grab_focus.call_deferred()


static func focus_first(raw_controls: Array) -> void:
	for raw_control in raw_controls:
		var control := raw_control as Button
		if control != null and not control.disabled and control.visible:
			control.grab_focus.call_deferred()
			return


static func can_grab_main_menu_focus(settings_visible: bool, profile_overlay: Control) -> bool:
	return _can_grab_main_menu_focus(settings_visible, profile_overlay)


static func _focusable_buttons(raw_controls: Array) -> Array[Button]:
	var controls: Array[Button] = []
	for raw_control in raw_controls:
		var control := raw_control as Button
		if control == null:
			continue
		control.focus_mode = Control.FOCUS_ALL as Control.FocusMode
		if not control.disabled and control.visible:
			controls.append(control)
	return controls


static func _apply_focus_chain(controls: Array[Button]) -> void:
	if controls.is_empty():
		return
	for control in controls:
		control.focus_mode = Control.FOCUS_ALL as Control.FocusMode
	if controls.size() == 1:
		return
	for index in controls.size():
		var control := controls[index]
		var previous_control := controls[(index - 1 + controls.size()) % controls.size()]
		var next_control := controls[(index + 1) % controls.size()]
		if not _can_link_focus_neighbor(control, previous_control) or not _can_link_focus_neighbor(control, next_control):
			continue
		var previous_path := control.get_path_to(previous_control)
		var next_path := control.get_path_to(next_control)
		control.set("focus_previous", previous_path)
		control.set("focus_next", next_path)
		control.set("focus_neighbor_top", previous_path)
		control.set("focus_neighbor_left", previous_path)
		control.set("focus_neighbor_bottom", next_path)
		control.set("focus_neighbor_right", next_path)


static func _can_link_focus_neighbor(control: Control, target: Control) -> bool:
	return (
		control != null
		and target != null
		and (
			(control.is_inside_tree() and target.is_inside_tree() and control.get_tree() == target.get_tree())
			or (not control.is_inside_tree() and not target.is_inside_tree() and control.get_parent() != null and control.get_parent() == target.get_parent())
		)
	)


static func _can_grab_main_menu_focus(settings_visible: bool, profile_overlay: Control) -> bool:
	return not settings_visible and not _is_overlay_visible(profile_overlay)


static func _is_overlay_visible(overlay: Control) -> bool:
	return overlay != null and overlay.visible
