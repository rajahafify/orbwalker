extends Resource
class_name VisualRegistryTextureFactory

const POST_MATCH_VFX_SPECS := {
	"post_match_fire": {"accent": Color(1.0, 0.34, 0.12, 1.0), "core": Color(1.0, 0.86, 0.42, 1.0), "shape": "burst"},
	"post_match_ice": {"accent": Color(0.42, 0.86, 1.0, 1.0), "core": Color(0.88, 0.98, 1.0, 1.0), "shape": "shards"},
	"post_match_earth": {"accent": Color(0.45, 0.78, 0.34, 1.0), "core": Color(0.88, 1.0, 0.58, 1.0), "shape": "stone"},
	"post_match_gold": {"accent": Color(1.0, 0.76, 0.18, 1.0), "core": Color(1.0, 0.96, 0.52, 1.0), "shape": "sparkle"},
	"post_match_heart": {"accent": Color(0.34, 1.0, 0.52, 1.0), "core": Color(0.86, 1.0, 0.82, 1.0), "shape": "heal"},
	"post_match_armor": {"accent": Color(0.55, 0.78, 1.0, 1.0), "core": Color(0.92, 0.98, 1.0, 1.0), "shape": "shield"},
	"post_match_damage": {"accent": Color(1.0, 0.18, 0.16, 1.0), "core": Color(1.0, 0.72, 0.56, 1.0), "shape": "slash"},
}


func post_match_vfx_contract() -> Dictionary:
	var textures := post_match_vfx_textures()
	return {
		"factory_is_resource": self is Resource and has_method("post_match_vfx_textures"),
		"spec_count": POST_MATCH_VFX_SPECS.size(),
		"alias_healing": textures["post_match_healing"] == textures["post_match_heart"],
		"alias_armor_gain": textures["post_match_armor_gain"] == textures["post_match_armor"],
	}


func placeholder_texture(color: Color, size: Vector2i) -> Texture2D:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8 as Image.Format)
	image.fill(color)
	return ImageTexture.create_from_image(image)


func post_match_vfx_textures() -> Dictionary:
	var textures := {}
	for key in POST_MATCH_VFX_SPECS.keys():
		textures[key] = post_match_vfx_texture(key)
	textures["post_match_healing"] = textures["post_match_heart"]
	textures["post_match_armor_gain"] = textures["post_match_armor"]
	return textures


func post_match_vfx_texture(key: String) -> Texture2D:
	var normalized_key := key.strip_edges().to_lower()
	if normalized_key == "post_match_healing":
		normalized_key = "post_match_heart"
	elif normalized_key == "post_match_armor_gain":
		normalized_key = "post_match_armor"
	var spec := Dictionary(POST_MATCH_VFX_SPECS.get(normalized_key, {}))
	if spec.is_empty():
		return null
	return _make_post_match_vfx_texture(String(spec.get("shape", "burst")), spec.get("accent", Color.WHITE) as Color, spec.get("core", Color.WHITE) as Color)


func _make_post_match_vfx_texture(shape: String, accent: Color, core: Color) -> Texture2D:
	var size := 192
	var center := Vector2(95.5, 95.5)
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	image.fill(Color(1.0, 1.0, 1.0, 0.0))
	for y in range(size):
		for x in range(size):
			var point := Vector2(float(x), float(y))
			var offset := point - center
			var distance := offset.length()
			var angle := atan2(offset.y, offset.x)
			var radial := clampf(1.0 - distance / 88.0, 0.0, 1.0)
			var soft_glow := radial * radial * 0.38
			var rim := maxf(0.0, 1.0 - absf(distance - 51.0) / 9.0) * 0.42
			var hot_core := maxf(0.0, 1.0 - distance / 22.0) * 0.72
			var shape_alpha := _post_match_shape_alpha(shape, offset, distance, angle)
			var alpha := maxf(soft_glow, maxf(rim, maxf(hot_core, shape_alpha)))
			if alpha <= 0.01:
				continue
			var mix := clampf(distance / 88.0, 0.0, 1.0)
			var color := core.lerp(accent, mix)
			if hot_core > 0.1:
				color = color.lightened(hot_core * 0.34)
			if shape == "ice" or shape == "shards":
				color = color.lightened(maxf(0.0, shape_alpha - 0.34) * 0.25)
			color.a = alpha
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


func _post_match_shape_alpha(shape: String, offset: Vector2, distance: float, angle: float) -> float:
	match shape:
		"burst":
			var flame := maxf(0.0, sin(angle * 5.0 + distance * 0.05))
			var upper_lift := clampf((34.0 - offset.y) / 72.0, 0.0, 1.0)
			var tongues := flame * clampf(1.0 - distance / 82.0, 0.0, 1.0)
			var vertical_core := maxf(0.0, 1.0 - absf(offset.x) / (20.0 + upper_lift * 28.0)) * clampf((64.0 - offset.y) / 118.0, 0.0, 1.0)
			return maxf(tongues * 0.70, vertical_core * 0.86)
		"shards":
			var primary := absf(offset.y + offset.x * 0.22)
			var secondary := absf(offset.y - offset.x * 0.72)
			var radial_spike := maxf(0.0, 1.0 - absf(sin(angle * 6.0)) / 0.16) * clampf(distance / 20.0, 0.0, 1.0)
			var shards := maxf(clampf(1.0 - primary / 4.8, 0.0, 1.0), clampf(1.0 - secondary / 4.8, 0.0, 1.0))
			return maxf(shards * clampf(1.0 - distance / 88.0, 0.0, 1.0), radial_spike * clampf(1.0 - distance / 84.0, 0.0, 1.0)) * 0.88
		"stone":
			var chunky := maxf(absf(offset.x * 0.92), absf(offset.y * 0.72))
			var slab := clampf(1.0 - absf(chunky - 38.0) / 9.0, 0.0, 1.0)
			var crack_a := clampf(1.0 - absf(offset.y + sin(offset.x * 0.10) * 16.0) / 4.0, 0.0, 1.0)
			var crack_b := clampf(1.0 - absf(offset.x - cos(offset.y * 0.09) * 22.0) / 4.0, 0.0, 1.0)
			return maxf(slab * 0.68, maxf(crack_a, crack_b) * clampf(1.0 - distance / 78.0, 0.0, 1.0) * 0.48)
		"sparkle":
			var cross := maxf(0.0, 1.0 - minf(absf(offset.x), absf(offset.y)) / 3.6) * clampf(1.0 - distance / 84.0, 0.0, 1.0)
			var diagonal := maxf(0.0, 1.0 - absf(absf(offset.x) - absf(offset.y)) / 3.6) * clampf(1.0 - distance / 66.0, 0.0, 1.0)
			var coin := clampf(1.0 - absf((offset / Vector2(28.0, 19.0)).length() - 1.0) / 0.16, 0.0, 1.0)
			return maxf(maxf(cross * 0.92, diagonal * 0.50), coin * 0.56)
		"heal":
			var stream := maxf(0.0, 1.0 - absf(offset.x + sin(offset.y * 0.08) * 10.0) / 8.0) * clampf((66.0 - offset.y) / 128.0, 0.0, 1.0)
			var leaf_a := maxf(0.0, 1.0 - (offset - Vector2(-13.0, -20.0)).length() / 20.0)
			var leaf_b := maxf(0.0, 1.0 - (offset - Vector2(13.0, -27.0)).length() / 18.0)
			var heart_lobes := maxf(
				maxf(0.0, 1.0 - (offset - Vector2(-13.0, -8.0)).length() / 18.0), maxf(0.0, 1.0 - (offset - Vector2(13.0, -8.0)).length() / 18.0)
			)
			return maxf(stream * 0.66, maxf(maxf(leaf_a, leaf_b) * 0.58, heart_lobes * 0.42))
		"shield":
			var top := maxf(absf(offset.x) / 43.0, absf(offset.y + 17.0) / 36.0)
			var point := clampf(1.0 - absf(absf(offset.x) + offset.y - 56.0) / 8.0, 0.0, 1.0)
			var rim := clampf(1.0 - absf(top - 1.0) / 0.10, 0.0, 1.0)
			var center_bar := maxf(0.0, 1.0 - absf(offset.x) / 4.2) * clampf(1.0 - absf(offset.y + 2.0) / 42.0, 0.0, 1.0)
			return maxf(maxf(rim, point) * 0.82, center_bar * 0.52)
		"slash":
			var slash_a := absf(offset.y + offset.x * 0.46)
			var slash_b := absf(offset.y + offset.x * 0.46 + 26.0)
			var cut := maxf(clampf(1.0 - slash_a / 5.5, 0.0, 1.0), clampf(1.0 - slash_b / 6.0, 0.0, 1.0) * 0.78)
			return cut * clampf(1.0 - distance / 86.0, 0.0, 1.0) * 0.92
		_:
			return clampf(1.0 - distance / 78.0, 0.0, 1.0) * 0.55
