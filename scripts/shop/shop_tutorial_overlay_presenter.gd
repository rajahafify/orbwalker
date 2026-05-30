extends RefCounted
class_name ShopTutorialOverlayPresenter

const SHOP_VIEW_NODE_FACTORY := preload("res://scripts/shop/shop_view_node_factory.gd")
const UI_UTILS := preload("res://scripts/ui/ui_utils.gd")

const HIDDEN_RECT := Rect2(Vector2(-9999, -9999), Vector2(1, 1))
const PROMPT_SIZE := Vector2(720.0, 148.0)

var _parent: Control = null
var _offer_cards: Array[Button] = []
var _reroll_button: Button = null
var _continue_button: Button = null
var _phase := ""
var _overlay: Control = null
var _focus_frame: Panel = null
var _prompt_panel: Panel = null
var _prompt_label: Label = null


func bind(parent: Control, targets: Dictionary = {}) -> void:
	_parent = parent
	_offer_cards = _typed_button_array(Array(targets.get("offer_cards", [])))
	_reroll_button = targets.get("reroll_button") as Button
	_continue_button = targets.get("continue_button") as Button


func ensure_overlay() -> void:
	if _overlay != null and is_instance_valid(_overlay):
		return
	if _parent == null:
		return
	_overlay = SHOP_VIEW_NODE_FACTORY.make_root("TutorialShopOverlay", _parent)
	_overlay.visible = false
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_overlay.z_index = 80
	_focus_frame = SHOP_VIEW_NODE_FACTORY.make_panel("TutorialShopFocusFrame", _overlay)
	_focus_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_focus_frame.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(1.0, 0.82, 0.12, 0.08), Color(1.0, 0.85, 0.18, 1.0), 5, 8, Vector4(8, 6, 8, 6)))
	_prompt_panel = SHOP_VIEW_NODE_FACTORY.make_panel("TutorialShopPrompt", _overlay)
	_prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE as Control.MouseFilter
	_prompt_panel.add_theme_stylebox_override("panel", UI_UTILS.panel_style(Color(0.045, 0.065, 0.085, 0.96), Color(1.0, 0.72, 0.16, 0.98), 3, 8, Vector4(12, 10, 12, 10)))
	_prompt_label = SHOP_VIEW_NODE_FACTORY.make_label("TutorialShopPromptLabel", _prompt_panel, "", 30, Color(1.0, 0.92, 0.68, 1.0), HORIZONTAL_ALIGNMENT_CENTER, true)
	_prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER as VerticalAlignment


func render(phase: String) -> void:
	ensure_overlay()
	if _overlay == null:
		return
	_phase = phase
	_overlay.visible = _phase != ""
	if not _overlay.visible:
		return
	_prompt_label.text = message_for_phase(_phase)


func layout(logical_size: Vector2) -> void:
	ensure_overlay()
	if _overlay == null or _focus_frame == null or _prompt_panel == null or _prompt_label == null:
		return
	_apply_rect(_overlay, Rect2(Vector2.ZERO, logical_size))
	if not _overlay.visible:
		return
	var focus_rect := _focus_rect()
	_apply_rect(_focus_frame, focus_rect)
	var prompt_x := clampf(focus_rect.get_center().x - PROMPT_SIZE.x * 0.5, 28.0, maxf(28.0, logical_size.x - PROMPT_SIZE.x - 28.0))
	var prompt_y := focus_rect.position.y - PROMPT_SIZE.y - 18.0
	if prompt_y < 140.0:
		prompt_y = focus_rect.end.y + 18.0
	prompt_y = clampf(prompt_y, 28.0, maxf(28.0, logical_size.y - PROMPT_SIZE.y - 28.0))
	_apply_rect(_prompt_panel, Rect2(Vector2(prompt_x, prompt_y), PROMPT_SIZE))
	_apply_rect(_prompt_label, Rect2(Vector2(22.0, 12.0), PROMPT_SIZE - Vector2(44.0, 24.0)))


func overlay() -> Control:
	return _overlay


func focus_frame() -> Panel:
	return _focus_frame


func prompt_panel() -> Panel:
	return _prompt_panel


func prompt_label() -> Label:
	return _prompt_label


static func message_for_phase(phase: String) -> String:
	match phase:
		"buy_shortsword":
			return "Buy Iron Shortsword.\nEquipment makes future fights easier."
		"reroll":
			return "Reroll changes shop stock.\nTap Reroll now."
		"continue":
			return "Continue leaves the shop.\nTap Continue to enter the next fight."
		_:
			return ""


func _focus_rect() -> Rect2:
	match _phase:
		"buy_shortsword":
			if not _offer_cards.is_empty():
				return _control_rect_in_overlay(_offer_cards[0]).grow(10.0)
		"reroll":
			return _control_rect_in_overlay(_reroll_button).grow(10.0)
		"continue":
			return _control_rect_in_overlay(_continue_button).grow(10.0)
	return HIDDEN_RECT


func _control_rect_in_overlay(control: Control) -> Rect2:
	if control == null or _overlay == null:
		return HIDDEN_RECT
	var inverse := _overlay.get_global_transform().affine_inverse()
	var rect := control.get_global_rect()
	return Rect2(inverse * rect.position, rect.size)


func _typed_button_array(values: Array) -> Array[Button]:
	var buttons: Array[Button] = []
	for value in values:
		if value is Button:
			buttons.append(value as Button)
	return buttons


func _apply_rect(control: Control, rect: Rect2) -> void:
	if control == null:
		return
	control.position = rect.position
	control.size = rect.size
