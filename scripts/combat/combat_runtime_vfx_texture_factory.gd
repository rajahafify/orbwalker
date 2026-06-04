extends RefCounted
class_name CombatRuntimeVfxTextureFactory

const TEXTURE_KEYS: Array[String] = [
	"soft_glow",
	"ray",
	"spark",
	"smoke",
	"coin",
	"ripple",
	"shard",
	"shield",
	"hex_cell",
]
const DEFAULT_TEXTURE_KEY := "soft_glow"

var _textures: Dictionary = {}


func texture(key: String) -> Texture2D:
	var normalized_key := normalized_texture_key(key)
	if _textures.has(normalized_key):
		return _textures[normalized_key]
	var runtime_texture := _create_texture(normalized_key)
	_textures[normalized_key] = runtime_texture
	return runtime_texture


func texture_keys() -> Array[String]:
	return TEXTURE_KEYS.duplicate()


func normalized_texture_key(key: String) -> String:
	var normalized_key := key.strip_edges().to_lower()
	if TEXTURE_KEYS.has(normalized_key):
		return normalized_key
	return DEFAULT_TEXTURE_KEY


func _create_texture(key: String) -> Texture2D:
	match key:
		"soft_glow":
			return _make_soft_glow_texture(128)
		"ray":
			return _make_ray_texture()
		"spark":
			return _make_spark_texture(64)
		"smoke":
			return _make_smoke_texture(128)
		"coin":
			return _make_coin_texture(72)
		"ripple":
			return _make_ripple_texture(128)
		"shard":
			return _make_shard_texture()
		"shield":
			return _make_shield_texture(128)
		"hex_cell":
			return _make_hex_cell_texture(128)
	return _make_soft_glow_texture(128)


func _make_soft_glow_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var distance := (Vector2(x, y) - center).length() / radius
			var alpha := pow(clampf(1.0 - distance, 0.0, 1.0), 2.15)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_ray_texture() -> Texture2D:
	var width := 256
	var height := 32
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8 as Image.Format)
	var center_y := float(height - 1) * 0.5
	for y in range(height):
		var y_falloff := pow(clampf(1.0 - abs(float(y) - center_y) / center_y, 0.0, 1.0), 2.2)
		for x in range(width):
			var t := float(x) / float(width - 1)
			var end_falloff := pow(sin(t * PI), 0.62)
			var core := 0.35 + 0.65 * pow(clampf(1.0 - abs(float(y) - center_y) / maxf(1.0, center_y * 0.28), 0.0, 1.0), 2.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, end_falloff * y_falloff * core))
	return ImageTexture.create_from_image(image)


func _make_spark_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var radial := clampf(1.0 - delta.length() / radius, 0.0, 1.0)
			var cross := maxf(
				pow(clampf(1.0 - abs(delta.y) / maxf(1.0, radius * 0.10), 0.0, 1.0), 2.0),
				pow(clampf(1.0 - abs(delta.x) / maxf(1.0, radius * 0.10), 0.0, 1.0), 2.0)
			)
			var alpha := maxf(pow(radial, 2.3), cross * pow(radial, 0.55))
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_smoke_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var distance := delta.length() / radius
			var base := pow(clampf(1.0 - distance, 0.0, 1.0), 1.25)
			var angle := atan2(delta.y, delta.x)
			var swirl := 0.5 + 0.5 * sin(angle * 5.0 + distance * 13.0)
			var noise := 0.5 + 0.5 * sin(float(x) * 0.173 + float(y) * 0.319 + sin(float(x + y) * 0.047) * 4.0)
			var alpha := base * (0.42 + swirl * 0.24 + noise * 0.24)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_coin_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.48
	for y in range(size):
		for x in range(size):
			var delta := Vector2(x, y) - center
			var normalized := Vector2(delta.x / radius, delta.y / maxf(1.0, radius * 0.82))
			var distance := normalized.length()
			if distance <= 1.0:
				var edge := clampf((1.0 - distance) / 0.12, 0.0, 1.0)
				var inner := 0.52 + 0.48 * pow(edge, 0.55)
				var glint := pow(clampf(1.0 - (Vector2(x, y) - center + Vector2(radius * 0.26, radius * 0.24)).length() / (radius * 0.38), 0.0, 1.0), 2.0)
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(inner + glint * 0.36, 0.0, 1.0)))
			else:
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.0))
	return ImageTexture.create_from_image(image)


func _make_ripple_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.5
	for y in range(size):
		for x in range(size):
			var distance := (Vector2(x, y) - center).length() / radius
			var outer := clampf(1.0 - abs(distance - 0.70) / 0.055, 0.0, 1.0)
			var inner := clampf(1.0 - abs(distance - 0.44) / 0.030, 0.0, 1.0) * 0.42
			var alpha := maxf(pow(outer, 0.62), inner) * clampf(1.0 - maxf(0.0, distance - 0.94) / 0.06, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return ImageTexture.create_from_image(image)


func _make_shard_texture() -> Texture2D:
	var width := 64
	var height := 96
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(width - 1), float(height - 1)) * 0.5
	for y in range(height):
		for x in range(width):
			var nx: float = (float(x) - center.x) / (float(width) * 0.50)
			var ny: float = (float(y) - center.y) / (float(height) * 0.50)
			var diamond: float = absf(nx) * 0.88 + absf(ny)
			var alpha := clampf((1.0 - diamond) / 0.18, 0.0, 1.0)
			var spine := pow(clampf(1.0 - absf(nx) / 0.10, 0.0, 1.0), 2.0) * clampf(1.0 - absf(ny) * 0.72, 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, maxf(alpha * 0.88, spine * 0.82)))
	return ImageTexture.create_from_image(image)


func _make_shield_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	for y in range(size):
		for x in range(size):
			var nx: float = (float(x) - center.x) / (float(size) * 0.48)
			var ny: float = (float(y) - center.y) / (float(size) * 0.48)
			var lower_taper := maxf(0.0, ny) * 0.34
			var upper_round := maxf(0.0, -ny - 0.10) * 0.12
			var allowed_width := 0.82 - lower_taper + upper_round
			var inside: bool = absf(nx) <= allowed_width and ny > -0.82 and ny < 0.94
			var alpha := 0.0
			if inside:
				var edge_x := clampf((allowed_width - absf(nx)) / 0.11, 0.0, 1.0)
				var edge_y := clampf(minf(ny + 0.82, 0.94 - ny) / 0.12, 0.0, 1.0)
				var edge := minf(edge_x, edge_y)
				var glass := pow(clampf(1.0 - (Vector2(nx + 0.18, ny + 0.26)).length() / 0.72, 0.0, 1.0), 1.8) * 0.24
				alpha = maxf(0.22 + glass, 1.0 - edge)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)


func _make_hex_cell_texture(size: int) -> Texture2D:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8 as Image.Format)
	var center := Vector2(float(size - 1), float(size - 1)) * 0.5
	var radius := float(size) * 0.43
	for y in range(size):
		for x in range(size):
			var nx := (float(x) - center.x) / radius
			var ny := (float(y) - center.y) / radius
			var qx := absf(nx)
			var qy := absf(ny)
			var hex_distance := maxf(qx * 0.866 + qy * 0.50, qy)
			var signed_distance := hex_distance - 0.92
			var edge := clampf((-signed_distance) / 0.11, 0.0, 1.0)
			var border := clampf(1.0 - absf(signed_distance) / 0.12, 0.0, 1.0)
			var inner_outline := clampf(1.0 - absf(hex_distance - 0.56) / 0.045, 0.0, 1.0) * edge
			var fill := clampf((-signed_distance - 0.02) / 0.72, 0.0, 1.0)
			var diagonal_scan := clampf(1.0 - absf((nx * 0.52 + ny) + 0.18) / 0.075, 0.0, 1.0) * 0.28
			var alpha := maxf(border, maxf(inner_outline * 0.72, fill * 0.58 + diagonal_scan)) * edge
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, clampf(alpha, 0.0, 1.0)))
	return ImageTexture.create_from_image(image)
