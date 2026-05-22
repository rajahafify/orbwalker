extends SceneTree

const OUT_DIR := "res://assets/qa/reports"
const PREVIEW_DIR := "res://assets/qa/reports/combat_enemy_stage_previews"
const REPORT_PATH := "res://assets/qa/reports/combat_enemy_stage_visual_report.html"
const CANVAS_SIZE := Vector2i(1048, 432)
const ENEMY_IDS := [
	"cavern_striker",
	"cavern_defender",
	"ash_hunter",
	"ruin_lancer",
	"vault_executioner",
	"goldbound_keeper",
	"iron_gate",
	"burning_knight",
	"prism_warden",
	"training_goblin",
	"striker",
	"defender",
	"charger",
]


func _init() -> void:
	call_deferred("_render")


func _render() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PREVIEW_DIR))
	var visuals := VisualRegistry.new()
	var rows: Array[Dictionary] = []
	var failure_count := 0
	for enemy_id in ENEMY_IDS:
		var info := visuals.combat_enemy_visual_debug_info(enemy_id)
		var stage_texture: Texture2D = visuals.combat_enemy_stage_texture(enemy_id)
		var sprite_texture: Texture2D = visuals.enemy_sprite(enemy_id)
		var preview_file := "%s.png" % enemy_id
		var preview_path := "%s/%s" % [PREVIEW_DIR, preview_file]
		var rendered := _render_preview(preview_path, stage_texture, sprite_texture, Dictionary(info.get("profile", {})))
		var failed := stage_texture == null or sprite_texture == null or bool(info.get("sprite_fallback", false)) or bool(info.get("stage_fallback", false)) or bool(info.get("sprite_placeholder_like", false)) or not rendered
		if failed:
			failure_count += 1
		rows.append({
			"enemy_id": enemy_id,
			"normalized_id": String(info.get("normalized_id", "")),
			"runtime_key": String(info.get("runtime_key", "")),
			"stage_path": String(info.get("stage_path", "")),
			"sprite_path": String(info.get("sprite_path", "")),
			"sprite_source": String(info.get("sprite_source", "")),
			"sprite_background_removed": String(info.get("sprite_background_removed", "")),
			"sprite_placeholder_like": bool(info.get("sprite_placeholder_like", false)),
			"stage_fallback": bool(info.get("stage_fallback", false)),
			"sprite_fallback": bool(info.get("sprite_fallback", false)),
			"preview": "combat_enemy_stage_previews/%s" % preview_file,
			"failed": failed,
		})
	_write_report(rows, failure_count)
	print("combat_enemy_stage_visual_report=", ProjectSettings.globalize_path(REPORT_PATH))
	print("combat_enemy_stage_visual_failures=", failure_count)
	quit(1 if failure_count > 0 else 0)


func _render_preview(path: String, stage_texture: Texture2D, sprite_texture: Texture2D, profile: Dictionary) -> bool:
	if stage_texture == null or sprite_texture == null:
		return false
	var canvas := Image.create(CANVAS_SIZE.x, CANVAS_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.01, 0.02, 0.03, 1.0))
	_blit_cover(canvas, stage_texture.get_image(), Rect2i(Vector2i.ZERO, CANVAS_SIZE))
	var scale := float(profile.get("scale", 1.0))
	var offset: Vector2 = profile.get("offset", Vector2.ZERO)
	var shadow_scale := float(profile.get("shadow_scale", 1.0))
	var shadow_alpha := float(profile.get("shadow_alpha", 0.34))
	_draw_shadow(canvas, shadow_scale, shadow_alpha)
	_blit_enemy(canvas, sprite_texture.get_image(), scale, offset)
	canvas.save_png(path)
	return true


func _blit_cover(canvas: Image, image: Image, rect: Rect2i) -> void:
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return
	var fitted := image.duplicate()
	if fitted.get_format() != Image.FORMAT_RGBA8:
		fitted.convert(Image.FORMAT_RGBA8)
	var scale := maxf(float(rect.size.x) / float(fitted.get_width()), float(rect.size.y) / float(fitted.get_height()))
	var size := Vector2i(maxi(1, int(ceil(fitted.get_width() * scale))), maxi(1, int(ceil(fitted.get_height() * scale))))
	fitted.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var src := Rect2i(Vector2i((size.x - rect.size.x) / 2, (size.y - rect.size.y) / 2), rect.size)
	canvas.blit_rect(fitted, src, rect.position)


func _blit_enemy(canvas: Image, image: Image, scale: float, offset: Vector2) -> void:
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return
	var fitted := image.duplicate()
	if fitted.get_format() != Image.FORMAT_RGBA8:
		fitted.convert(Image.FORMAT_RGBA8)
	var target_height := int(round(float(CANVAS_SIZE.y) * scale))
	var fit_scale := float(target_height) / float(fitted.get_height())
	var size := Vector2i(maxi(1, int(round(fitted.get_width() * fit_scale))), maxi(1, target_height))
	fitted.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var dest := Vector2i(
		int(round((CANVAS_SIZE.x - size.x) * 0.5 + offset.x)),
		int(round((CANVAS_SIZE.y - size.y) * 0.5 + offset.y))
	)
	canvas.blend_rect(fitted, Rect2i(Vector2i.ZERO, size), dest)


func _draw_shadow(canvas: Image, shadow_scale: float, alpha: float) -> void:
	var shadow_size := Vector2(float(CANVAS_SIZE.x) * 0.36 * shadow_scale, maxf(30.0, float(CANVAS_SIZE.y) * 0.11 * shadow_scale))
	var center := Vector2(float(CANVAS_SIZE.x) * 0.5, float(CANVAS_SIZE.y) * 0.73 + shadow_size.y * 0.5)
	var radius := shadow_size * 0.5
	for y in range(maxi(0, int(center.y - radius.y)), mini(CANVAS_SIZE.y, int(center.y + radius.y) + 1)):
		for x in range(maxi(0, int(center.x - radius.x)), mini(CANVAS_SIZE.x, int(center.x + radius.x) + 1)):
			var normalized := Vector2((float(x) - center.x) / radius.x, (float(y) - center.y) / radius.y)
			var distance := normalized.length_squared()
			if distance > 1.0:
				continue
			var fade := pow(1.0 - distance, 1.8)
			var original := canvas.get_pixel(x, y)
			canvas.set_pixel(x, y, original.lerp(Color(0.0, 0.0, 0.0, 1.0), clampf(alpha * fade, 0.0, 0.65)))


func _write_report(rows: Array[Dictionary], failure_count: int) -> void:
	var lines: Array[String] = []
	lines.append("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">")
	lines.append("<title>Combat Enemy Stage Visual Report</title>")
	lines.append("<style>body{margin:0;font:14px/1.45 Segoe UI,Arial,sans-serif;background:#111820;color:#edf3f8}header{padding:24px 28px;background:#071018;border-bottom:3px solid #c58b2b}h1{margin:0 0 6px;font-size:28px}.summary{color:#d7c9aa}.doc{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px;padding:20px 20px 0}.doc section{background:#18232d;border:1px solid #344253;border-radius:8px;padding:14px}.doc h2{font-size:16px;margin:0 0 8px;color:#f3cc73}.doc ul{margin:0;padding-left:18px}.doc li{margin:4px 0}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(340px,1fr));gap:16px;padding:20px}.card{background:#18232d;border:1px solid #344253;border-radius:8px;overflow:hidden}.card.fail{border-color:#c94d4d}.preview{display:block;width:100%;height:auto;background:#05080b}.body{padding:12px 14px}.ok{color:#8be28b}.failtext{color:#ff9b9b}dl{display:grid;grid-template-columns:110px 1fr;gap:5px 10px;margin:10px 0 0}dt{color:#d7c9aa}dd{margin:0;overflow-wrap:anywhere}code{font-family:Consolas,monospace}</style></head><body>")
	lines.append("<header><h1>Combat Enemy Stage Visual Report</h1><div class=\"summary\">%d enemies checked, %d fallback/missing/placeholder failures.</div></header>" % [rows.size(), failure_count])
	lines.append("<div class=\"doc\">")
	lines.append("<section><h2>Implemented Fixes</h2><ul>")
	lines.append("<li>Enemy figures resolve through runtime manifest keys before legacy portrait fallbacks.</li>")
	lines.append("<li>Combat top stage uses the per-enemy combat stage texture path.</li>")
	lines.append("<li>Enemy visual profiles apply figure scale, offset, mipmapped filtering, and contact shadow.</li>")
	lines.append("<li>Placeholder-grade enemy sources are flagged as QA failures.</li>")
	lines.append("</ul></section>")
	lines.append("<section><h2>Asset Corrections</h2><ul>")
	lines.append("<li>Ruin Lancer, Vault Executioner, Goldbound Keeper, and Charger runtime art are sliced from the AssetGen enemy portrait sheet.</li>")
	lines.append("<li>Boss and first-pass portrait composites use a soft stage matte to reduce rectangular backdrop edges.</li>")
	lines.append("<li>Generated previews below show each enemy over its resolved combat stage.</li>")
	lines.append("</ul></section>")
	lines.append("<section><h2>Verification</h2><ul>")
	lines.append("<li>Report generator fails on missing stage textures, missing figures, fallbacks, or placeholder-like runtime enemy sources.</li>")
	lines.append("<li>Expected result for this pass is zero fallback/missing/placeholder failures.</li>")
	lines.append("<li>Lower combat board, mastery strip, player HUD, loadout rails, and matched-orb behavior were not changed by this pass.</li>")
	lines.append("</ul></section>")
	lines.append("</div>")
	lines.append("<main class=\"grid\">")
	for row in rows:
		var failed := bool(row.get("failed", false))
		lines.append("<section class=\"card%s\">" % (" fail" if failed else ""))
		lines.append("<img class=\"preview\" src=\"%s\" alt=\"%s preview\">" % [_html(String(row.get("preview", ""))), _html(String(row.get("enemy_id", "")))])
		lines.append("<div class=\"body\"><strong>%s</strong> <span class=\"%s\">%s</span>" % [
			_html(String(row.get("enemy_id", ""))),
			"failtext" if failed else "ok",
			"FAIL" if failed else "OK",
		])
		lines.append("<dl>")
		lines.append("<dt>Normalized</dt><dd><code>%s</code></dd>" % _html(String(row.get("normalized_id", ""))))
		lines.append("<dt>Runtime key</dt><dd><code>%s</code></dd>" % _html(String(row.get("runtime_key", ""))))
		lines.append("<dt>Sprite</dt><dd><code>%s</code></dd>" % _html(String(row.get("sprite_path", ""))))
		lines.append("<dt>Source</dt><dd><code>%s</code></dd>" % _html(String(row.get("sprite_source", ""))))
		lines.append("<dt>Cleanup</dt><dd><code>%s</code></dd>" % _html(String(row.get("sprite_background_removed", ""))))
		lines.append("<dt>Stage</dt><dd><code>%s</code></dd>" % _html(String(row.get("stage_path", ""))))
		lines.append("<dt>Fallback</dt><dd>sprite=%s, stage=%s, placeholder=%s</dd>" % [
			str(row.get("sprite_fallback", false)),
			str(row.get("stage_fallback", false)),
			str(row.get("sprite_placeholder_like", false)),
		])
		lines.append("</dl></div></section>")
	lines.append("</main></body></html>")
	var file := FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	file.store_string("\n".join(lines))


func _html(value: String) -> String:
	return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
