extends SceneTree
class_name MainMenuAccessibilityAudit

const MAIN_MENU_VIEW := preload("res://scripts/main_menu/main_menu_view.gd")
const AUDIT_VIEWPORTS := [
	Vector2(1080.0, 1920.0),
	Vector2(720.0, 1280.0),
]


func _initialize() -> void:
	var report := run_report()
	_print_report(report)
	quit(0 if bool(report.get("passed", false)) else 1)


static func run_report() -> Dictionary:
	var failures: Array[String] = []
	var checked_contrast := 0
	var checked_targets := 0
	var checked_focus_controls := 0

	for viewport_size in AUDIT_VIEWPORTS:
		var snapshot: Dictionary = MAIN_MENU_VIEW.accessibility_audit_snapshot(viewport_size)
		for pair_value in Array(snapshot.get("contrast_pairs", [])):
			var pair := Dictionary(pair_value)
			checked_contrast += 1
			var ratio := _contrast_ratio(pair.get("foreground", Color.BLACK), pair.get("background", Color.WHITE))
			var minimum_ratio := float(pair.get("minimum_ratio", 0.0))
			if ratio + 0.001 < minimum_ratio:
				failures.append("%s contrast %.2f is below %.2f at %s." % [
					String(pair.get("label", "unknown")),
					ratio,
					minimum_ratio,
					str(viewport_size),
				])
		for target_value in Array(snapshot.get("touch_targets", [])):
			var target := Dictionary(target_value)
			checked_targets += 1
			var size: Vector2 = target.get("size", Vector2.ZERO)
			var minimum_size := float(target.get("minimum_size", 0.0))
			var effective_width := size.x if size.x > 0.0 else minimum_size
			if minf(effective_width, size.y) + 0.001 < minimum_size:
				failures.append("%s touch target %s is below %.1fpx at %s." % [
					String(target.get("label", "unknown")),
					str(size),
					minimum_size,
					str(viewport_size),
				])
		checked_focus_controls += Array(snapshot.get("keyboard_focus_controls", [])).size()

	if checked_contrast == 0:
		failures.append("Expected at least one contrast pair in main-menu accessibility snapshot.")
	if checked_targets == 0:
		failures.append("Expected at least one touch target in main-menu accessibility snapshot.")
	if checked_focus_controls == 0:
		failures.append("Expected keyboard focus controls in main-menu accessibility snapshot.")

	return {
		"passed": failures.is_empty(),
		"viewports": AUDIT_VIEWPORTS.size(),
		"contrast_pairs": checked_contrast,
		"touch_targets": checked_targets,
		"keyboard_focus_controls": checked_focus_controls,
		"failures": failures,
	}


static func _contrast_ratio(foreground: Color, background: Color) -> float:
	var lighter := maxf(_relative_luminance(foreground), _relative_luminance(background))
	var darker := minf(_relative_luminance(foreground), _relative_luminance(background))
	return (lighter + 0.05) / (darker + 0.05)


static func _relative_luminance(color: Color) -> float:
	return (
		0.2126 * _linearized_channel(color.r)
		+ 0.7152 * _linearized_channel(color.g)
		+ 0.0722 * _linearized_channel(color.b)
	)


static func _linearized_channel(channel: float) -> float:
	if channel <= 0.03928:
		return channel / 12.92
	return pow((channel + 0.055) / 1.055, 2.4)


static func _print_report(report: Dictionary) -> void:
	print("[MainMenuAccessibilityAudit] viewports=%d contrast_pairs=%d touch_targets=%d focus_controls=%d failed=%d" % [
		int(report.get("viewports", 0)),
		int(report.get("contrast_pairs", 0)),
		int(report.get("touch_targets", 0)),
		int(report.get("keyboard_focus_controls", 0)),
		Array(report.get("failures", [])).size(),
	])
	for failure in Array(report.get("failures", [])):
		printerr("[MainMenuAccessibilityAudit][FAIL] %s" % String(failure))
