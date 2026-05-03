extends RefCounted
class_name UiUtils


static func panel_style(
	fill: Color,
	border: Color,
	border_width: int = 2,
	radius: int = 6,
	margins: Vector4 = Vector4.ZERO
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.content_margin_left = margins.x
	style.content_margin_top = margins.y
	style.content_margin_right = margins.z
	style.content_margin_bottom = margins.w
	return style
