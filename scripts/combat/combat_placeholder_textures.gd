extends RefCounted


static func make_timer_placeholder_texture() -> Texture2D:
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.04, 0.10, 0.16, 0.0))
	image.fill_rect(Rect2i(28, 14, 40, 12), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(28, 70, 40, 12), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(34, 24, 28, 14), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(34, 58, 28, 14), Color(0.78, 0.88, 0.98, 1.0))
	image.fill_rect(Rect2i(38, 38, 20, 20), Color(0.44, 0.74, 1.0, 0.95))
	return ImageTexture.create_from_image(image)


static func make_intent_placeholder_texture() -> Texture2D:
	var image := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.06, 0.08, 0.11, 0.95))
	image.fill_rect(Rect2i(4, 4, 88, 88), Color(0.15, 0.10, 0.08, 1.0))
	image.fill_rect(Rect2i(8, 8, 80, 80), Color(0.45, 0.12, 0.10, 1.0))
	image.fill_rect(Rect2i(44, 18, 8, 60), Color(0.92, 0.86, 0.72, 1.0))
	image.fill_rect(Rect2i(26, 48, 44, 8), Color(0.92, 0.86, 0.72, 1.0))
	return ImageTexture.create_from_image(image)


static func make_enemy_placeholder_texture() -> Texture2D:
	var image := Image.create(260, 230, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.08, 0.11, 0.94))
	image.fill_rect(Rect2i(4, 4, 252, 222), Color(0.48, 0.38, 0.18, 0.95))
	image.fill_rect(Rect2i(8, 8, 244, 214), Color(0.09, 0.13, 0.17, 0.98))
	image.fill_rect(Rect2i(98, 28, 64, 58), Color(0.19, 0.24, 0.29, 1.0))
	image.fill_rect(Rect2i(72, 92, 116, 106), Color(0.16, 0.21, 0.27, 1.0))
	image.fill_rect(Rect2i(42, 122, 50, 74), Color(0.13, 0.18, 0.24, 1.0))
	image.fill_rect(Rect2i(168, 122, 50, 74), Color(0.13, 0.18, 0.24, 1.0))
	return ImageTexture.create_from_image(image)


static func make_hero_placeholder_texture() -> Texture2D:
	var image := Image.create(192, 192, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.07, 0.10, 0.96))
	image.fill_rect(Rect2i(4, 4, 184, 184), Color(0.50, 0.38, 0.18, 0.95))
	image.fill_rect(Rect2i(8, 8, 176, 176), Color(0.11, 0.13, 0.17, 0.98))
	image.fill_rect(Rect2i(66, 34, 60, 58), Color(0.20, 0.23, 0.28, 1.0))
	image.fill_rect(Rect2i(44, 104, 104, 58), Color(0.16, 0.19, 0.25, 1.0))
	image.fill_rect(Rect2i(134, 120, 28, 42), Color(0.16, 0.27, 0.42, 1.0))
	return ImageTexture.create_from_image(image)
