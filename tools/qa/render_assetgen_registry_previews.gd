extends SceneTree

const OUT_DIR := "res://assets/qa/reports"


func _init() -> void:
	call_deferred("_render")


func _render() -> void:
	var visuals := VisualRegistry.new()
	_render_single("assetgen_verify_hero.png", visuals.hero_portrait(), Vector2i(220, 220))
	_render_row("assetgen_verify_equipment.png", [
		visuals.clean_icon_for_key("equipment_leather_gloves"),
		visuals.clean_icon_for_key("equipment_coin_purse"),
		visuals.clean_icon_for_key("equipment_shortsword"),
		visuals.clean_icon_for_key("equipment_tower_shield"),
	], Vector2i(132, 132))
	_render_row("assetgen_verify_relics.png", [
		visuals.clean_icon_for_key("relic_stalwart_mantle"),
		visuals.clean_icon_for_key("relic_golden_idol"),
		visuals.clean_icon_for_key("relic_crown_of_chains"),
		visuals.clean_icon_for_key("relic_merchant_compass"),
		visuals.clean_icon_for_key("relic_deep_pockets"),
	], Vector2i(132, 132))
	_render_row("assetgen_verify_mastery.png", [
		visuals.mastery_icon(OrbType.Id.FIRE),
		visuals.mastery_icon(OrbType.Id.ICE),
		visuals.mastery_icon(OrbType.Id.EARTH),
		visuals.mastery_icon(OrbType.Id.HEART),
		visuals.mastery_icon(OrbType.Id.ARMOR),
		visuals.mastery_icon(OrbType.Id.GOLD),
	], Vector2i(120, 120))
	_render_row("assetgen_verify_orbs.png", [
		visuals.orb_texture(OrbType.Id.FIRE),
		visuals.orb_texture(OrbType.Id.ICE),
		visuals.orb_texture(OrbType.Id.EARTH),
		visuals.orb_texture(OrbType.Id.HEART),
		visuals.orb_texture(OrbType.Id.ARMOR),
		visuals.orb_texture(OrbType.Id.GOLD),
	], Vector2i(96, 96))
	print("assetgen_registry_previews_saved=", ProjectSettings.globalize_path(OUT_DIR))
	quit()


func _render_single(file_name: String, texture: Texture2D, target_size: Vector2i) -> void:
	var canvas := Image.create(target_size.x + 32, target_size.y + 32, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.02, 0.025, 0.03, 1.0))
	_blit_centered(canvas, texture, Rect2i(Vector2i(16, 16), target_size))
	canvas.save_png("%s/%s" % [OUT_DIR, file_name])


func _render_row(file_name: String, textures: Array, slot_size: Vector2i) -> void:
	var gap := 16
	var canvas_size := Vector2i((slot_size.x + gap) * textures.size() + gap, slot_size.y + gap * 2)
	var canvas := Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.02, 0.025, 0.03, 1.0))
	for index in textures.size():
		var slot := Rect2i(Vector2i(gap + index * (slot_size.x + gap), gap), slot_size)
		_draw_slot(canvas, slot)
		_blit_centered(canvas, textures[index] as Texture2D, slot.grow(-8))
	canvas.save_png("%s/%s" % [OUT_DIR, file_name])


func _draw_slot(canvas: Image, slot: Rect2i) -> void:
	for y in range(slot.position.y, slot.position.y + slot.size.y):
		for x in range(slot.position.x, slot.position.x + slot.size.x):
			if x < 0 or y < 0 or x >= canvas.get_width() or y >= canvas.get_height():
				continue
			var border := x == slot.position.x or y == slot.position.y or x == slot.position.x + slot.size.x - 1 or y == slot.position.y + slot.size.y - 1
			canvas.set_pixel(x, y, Color(0.86, 0.62, 0.16, 1.0) if border else Color(0.055, 0.045, 0.035, 1.0))


func _blit_centered(canvas: Image, texture: Texture2D, rect: Rect2i) -> void:
	if texture == null:
		return
	var image := texture.get_image()
	if image == null or image.get_width() <= 0 or image.get_height() <= 0:
		return
	var fitted := image.duplicate()
	var scale := minf(float(rect.size.x) / float(fitted.get_width()), float(rect.size.y) / float(fitted.get_height()))
	var size := Vector2i(maxi(1, int(round(fitted.get_width() * scale))), maxi(1, int(round(fitted.get_height() * scale))))
	fitted.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	var dest := rect.position + Vector2i((rect.size.x - size.x) / 2, (rect.size.y - size.y) / 2)
	canvas.blend_rect(fitted, Rect2i(Vector2i.ZERO, size), dest)
